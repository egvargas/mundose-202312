terraform {
  backend "s3" {
    bucket = "mundose-202312"
    key    = "terraform/terraform.tfstate"
    region = "us-east-2"
  }
}
