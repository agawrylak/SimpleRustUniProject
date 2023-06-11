provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "ag_zad2_s3" {
  bucket = "ag-zad2-s3"
}

resource "aws_elastic_beanstalk_application" "ag-zad2" {
  name = "ag_zad_2"
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
}

