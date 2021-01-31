resource "random_id" "service_account_id" {
  prefix      = "k8s-demo-"
  byte_length = 3
}

resource "google_service_account" "k8s_service_account" {
  account_id   = random_id.service_account_id.dec
  display_name = "K8s Demo Service Account"
  project      = var.project_id
}

resource "google_project_service" "container" {
  project                    = var.project_id
  service                    = "container.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_container_cluster" "primary" {
  name               = "k8s-demo"
  project            = var.project_id
  depends_on         = [google_project_service.container]
  location           = "us-west1-a"
  initial_node_count = 1
  node_config {
    service_account = google_service_account.k8s_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    preemptible  = true
    machine_type = "e2-micro"
    labels = {
      env = "sandbox"
    }
    tags = ["k8s", "demo", "sandbox"]
  }
  timeouts {
    create = "30m"
    update = "40m"
  }
}
