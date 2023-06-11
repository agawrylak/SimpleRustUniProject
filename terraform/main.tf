provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "ag_zad2_s3" {
  bucket = "ag-zad2-s3"
}

resource "aws_elastic_beanstalk_application" "ag-zad2" {
  name = "ag_zad_2"
}

data "aws_secretsmanager_secret_version" "ipgeo_api_key" {
  secret_id = "IPGEOLOCATION_API_KEY"
}

locals {
  ipgeolocation_api_key = jsondecode(data.aws_secretsmanager_secret_version.ipgeo_api_key.secret_string)["IPGEOLOCATION_API_KEY"]
}

resource "aws_elastic_beanstalk_environment" "ag-zad2-env" {
  name                = "ag-zad2-env"
  application         = aws_elastic_beanstalk_application.ag-zad2.name
  solution_stack_name = "64bit Amazon Linux 2 v3.5.8 running Docker"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     =  "terraform-aws"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "LOG_STREAMING_ENABLED"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "IPGEOLOCATION_API_KEY"
    value     = local.ipgeolocation_api_key
  }
}

