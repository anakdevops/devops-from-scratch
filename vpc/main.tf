provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

# Membuat VPC
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

# Membuat Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.cidr_range
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Firewall Rule untuk Akses Publik HTTP dan HTTPS
resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"]
}

# Firewall Rule untuk Akses SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-access"]
}

# Firewall Rule untuk Akses gitlab
resource "google_compute_firewall" "allow_gitlab" {
  name    = "allow-gitlab"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-gitlab"]
}

# Firewall Rule untuk NodePort
resource "google_compute_firewall" "allow_nodeport" {
  name    = "allow-nodeport"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["nodeport-access"]
}

# Firewall Rule untuk Rancher
resource "google_compute_firewall" "allow_rancher" {
  name    = "allow-rancher"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "2376", "2379-2380", "6443", "10250", "10254", "8472", "9345", "9796"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["rancher-server"]
}
