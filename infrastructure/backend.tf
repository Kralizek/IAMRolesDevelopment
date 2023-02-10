terraform {
  required_providers {
    aws = {

    }

    random = {
      source = "hashicorp/random"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      "Environment" = terraform.workspace
      "Project"     = local.project_name
    }
  }
}

provider "random" {

}

locals {
  project_name = "IAMRoles"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
