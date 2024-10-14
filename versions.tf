terraform {
  required_version = "1.9.5"

  required_providers {
    aws = {
      version = "5.65.0"
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket="hisham-practice"
    region = "eu-central-1"
    dynamodb_table = "hisham-practice-state-locking"
    //encrypt = true
    key = "newserver.tfstate"
  }
}

provider "aws" {
  region = "eu-central-1"
}
