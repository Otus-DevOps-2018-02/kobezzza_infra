terraform {
  backend "gcs" {
    bucket = "storage-kobezzza-test"
    prefix = "terraform/state"
  }
}
