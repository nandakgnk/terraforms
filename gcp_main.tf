provider "google" {
  //version = "~> 1.20"
  version = "~> 2.5"
  project = "gcp-test-prod-legacy"
}

variable "test" {
    type = "list"
    default = [
        { testhostname1 = "us-central1-c" },
        { testhostname2 = "us-central1-f" },
   ]
 }

resource "google_compute_disk" "test-servers-disk" {
    count = length(var.test)
    zone = "${element(values(var.test[count.index]),0)}"
    name = "${element(keys(var.test[count.index]),0)}-clients"
    size = 50
}

resource "google_compute_address" "test-Web-Servers-IPS" {
    count = length(var.test)
    name = "${element(keys(var.test[count.index]),0)}-ip"
    address_type = "INTERNAL"
    region = "us-central1"
    subnetwork = "https://www.googleapis.com/compute/v1/projects/gcp-test-host/regions/us-central1/subnetworks/us-central1-subnet-prod-gke-nodes-1"
  }

 resource "google_compute_instance" "Web-Servers"
     count = length(var.test)
     name  = "${element(keys(var.test[count.index]),0)}"
     machine_type = "n1-standard-4"
     tags = ["web", "app"]
     zone = "${element(values(var.test[count.index]),0)}"

   boot_disk {
    initialize_params {
     image = "gcp-test-prod-legacy/test-server-image"
    }
  }

  attached_disk {
    source = "${google_compute_disk.test-page-servers-disk[count.index].self_link}"
  }

  network_interface {
    subnetwork = "https://www.googleapis.com/compute/v1/projects/gcp-test-host/regions/us-central1/subnetworks/us-central1-subnet-prod-gke-nodes-1"
    network_ip = "${google_compute_address.test-Web-Servers-IPS[count.index].self_link}"

  }
  hostname = "${element(keys(var.test[count.index]),0)}.gcp.test.com"
}
