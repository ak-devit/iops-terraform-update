#=====================================================================
#Providers
#=====================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "2.23.1"
    }
  }
}


#=====================================================================
#Configure the AWS Provider
#=====================================================================

provider "aws" {
  region                   = var.region
  shared_credentials_files = var.shared_credentials_files
  profile                  = var.profile
}

#=====================================================================
#Docker
#=====================================================================

provider "docker" {
  host = var.host
}