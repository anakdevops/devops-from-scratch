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

# Generate SSH Key Pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to a local file
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "docker-key.pem"
}

# Create VM Instances for Rancher Kubernetes Cluster
resource "google_compute_instance" "vm_instance" {
  count        = 1
  name         = "node-docker-${count.index + 1}"
  machine_type = "n2-standard-4"
  zone         = "us-central1-c"

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
    ssh-keys = "docker:${tls_private_key.ssh_key.public_key_openssh}"
  }

    provisioner "file" {
    source      = "install.yaml"
    destination = "/tmp/install.yaml"

    connection {
      type        = "ssh"
      user        = "docker"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }

    provisioner "file" {
    source      = "docker-compose.yml"
    destination = "/tmp/docker-compose.yml"

    connection {
      type        = "ssh"
      user        = "docker"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }

      provisioner "file" {
    source      = "nginx-proxy-manager/docker-compose.yml"
    destination = "/tmp/nginpm/docker-compose.yml"

    connection {
      type        = "ssh"
      user        = "docker"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl git ansible",
      "sudo ansible-playbook /tmp/install.yaml"
    ]

    connection {
      type        = "ssh"
      user        = "docker"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }

  tags = ["rancher-server", "ssh-access", "https-server", "http-server", "allow-gitlab"]
}


