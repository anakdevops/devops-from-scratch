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
    source      = "aplikasi.anakdevops.online.conf"
    destination = "/tmp/aplikasi.anakdevops.online.conf"

    connection {
      type        = "ssh"
      user        = "docker"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }

      provisioner "file" {
    source      = "nginx.conf"
    destination = "/tmp/nginx.conf"

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
      "sudo ansible-playbook /tmp/install.yaml",
      "sudo mkdir -p /tmp/nginxcert",
      "sudo wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64",
      "sudo mv mkcert-v1.4.3-linux-amd64 /usr/bin/mkcert",
      "sudo chmod +x /usr/bin/mkcert",
      "cd /tmp/nginxcert",
      "sudo mkcert -cert-file git.anakdevops.online.crt -key-file git.anakdevops.online.key git.anakdevops.online",
      "sudo mkcert -cert-file argocd.anakdevops.online.crt -key-file argocd.anakdevops.online.key argocd.anakdevops.online",
      "sudo mkcert -install",
      "cd /tmp",
      "sudo chmod 777 -R /tmp/jenkins_compose/",
      "docker compose up -d"
    ]

    connection {
      type        = "ssh"
      user        = "docker"
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }

  tags = ["nodeport-access", "rancher-server", "ssh-access", "https-server", "http-server", "allow-gitlab"]
}


