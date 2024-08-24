provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "bucket" {
  backend = "local"

  config = {
    path = "../bucket/terraform.tfstate"
  }
}

# Generate SSH Key Pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to a local file
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "rancher-key.pem"
}

# Define a list of zones to choose from
locals {
  zones = ["us-central1-a", "us-central1-b", "us-central1-c", "us-central1-f"]
}



# Create VM Instances for Rancher Kubernetes Cluster
resource "google_compute_instance" "vm_instance" {
  count        = 2
  name         = "rancher-node-${count.index + 1}"
  # Alternating machine types to balance the distribution
  machine_type = count.index % 2 == 0 ? "n2-standard-4" : "e2-medium"
  # Balanced selection of zones
  zone = local.zones[count.index % length(local.zones)]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20230615"
      size  = 50  # Set boot disk size to 50GB
    }
  }

  network_interface {
    network    = data.terraform_remote_state.vpc.outputs.vpc_id
    subnetwork = data.terraform_remote_state.vpc.outputs.subnet_id
    access_config {}
  }

  
  metadata = {
    ssh-keys = "rancher:${tls_private_key.ssh_key.public_key_openssh}"
  }

    provisioner "file" {
    source      = "install.yaml"
    destination = "/tmp/install.yaml"

    connection {
      type        = "ssh"
      user        = "rancher"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl git ansible gnupg ca-certificates",
      "echo 'deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main' | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list",
      "curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.gpg",
      "sudo apt-get update",
      "sudo apt-get install -y gcsfuse",
      "sudo mkdir -p /mnt/bucket",
      "echo 'gcsfuse#${data.terraform_remote_state.bucket.outputs.bucket_name} /mnt/bucket fuse rw,allow_other,default_permissions 0 0' | sudo tee -a /etc/fstab",
      "echo '[Unit]\nDescription=Mount GCS Bucket\nAfter=network-online.target\n\n[Service]\nExecStart=/usr/bin/gcsfuse ${data.terraform_remote_state.bucket.outputs.bucket_name} /mnt/bucket\nExecStop=/bin/fusermount -u /mnt/bucket\nType=forking\n\n[Install]\nWantedBy=multi-user.target' | sudo tee /etc/systemd/system/gcsfuse.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable gcsfuse",
      "sudo systemctl start gcsfuse"
     
    ]

    connection {
      type        = "ssh"
      user        = "rancher"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }

  tags = ["nodeport-access", "rancher-server", "ssh-access", "https-server", "http-server"]
}


