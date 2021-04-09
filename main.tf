terraform {
  backend "local" {}
  required_version = ">= 0.14"
}

provider "aws" {
  region = "us-east-1"
  access_key = "AKIAU7D2TEMANVDFZYHB"
  secret_key = "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"
}

locals {
  system_name = "vouch-operations"
}
