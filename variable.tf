# AWS Region
variable "aws_Access_key" {
  description = "The AWS region to deploy resources"
  type        = string

}
variable "aws_Secrete_key" {
  description = "The AWS region to deploy resources"
  type        = string

}
variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string

}
# VPC CIDR Block
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string

}

# Availability Zones
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)

}

# AMI ID
variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

# Instance Type
variable "instance_type" {
  description = "The type of instance to create"
  type        = map(string)
  default = {
    dev  = "t2.micro",
    prod = "t2.small"
  }
}
variable "Master-servers" {
  type = list(any)

}

variable "vpc_name" {}
variable "igw_name" {}
variable "public-route-table" {}
variable "public-subnet" {}
variable "SG_allow-ssh" {}

#variable "environment" {
# description = "The environment name (e.g., dev, prod)"
#type        = string
#default     = terraform.workspace  # Use the current workspace as default
#}
#variable "key_name" {
#description = "The Keypair for the EC2 instance"
#type        = string

#}
variable "ingress_ports" {
  type    = list(string)
  default = [22, 80, 443, 389, 3389, 8001, 8002, 8000, 9100, 8010, 9443, 8080]
}
