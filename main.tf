# Create a custom VPC Network
resource "google_compute_network" "app_network" {
  name                    = "app-network" # Renamed to avoid conflict with subnetwork name
  auto_create_subnetworks = false         # Important: set to false when defining custom subnetworks
}

# Create a Subnetwork within the custom VPC Network
resource "google_compute_subnetwork" "app_subnet" {
  name          = "app"           # Name of the subnetwork
  ip_cidr_range = "10.2.0.0/16"   # CIDR range for the subnetwork
  region        = "us-west1"      # Region for the subnetwork
  network       = google_compute_network.app_network.self_link # Reference the network's self_link
}

# Data source to get the latest Ubuntu 22.04 LTS image
data "google_compute_image" "ubuntu" {
  most_recent = true
  project     = "ubuntu-os-cloud"
  family      = "ubuntu-2204-lts"
}

# Create a Google Compute Engine instance
resource "google_compute_instance" "web" {
  name         = "web"
  machine_type = "e2-micro"
  zone         = "us-west1-b" # IMPORTANT: Instances require a zone within the specified region

  # Boot disk configuration
  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link # Reference the Ubuntu image
    }
  }

  # Network interface configuration
  network_interface {
    network    = google_compute_network.app_network.self_link # Reference the network's self_link
    subnetwork = google_compute_subnetwork.app_subnet.self_link # CORRECTED: Reference the subnetwork's self_link
    access_config {
      # Leave empty for dynamic public IP. This block creates an external IP.
    }
  }

  # Allows the instance to be stopped and updated without being deleted and recreated
  allow_stopping_for_update = true
}
