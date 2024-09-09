# ================================================================================================================
# Variables
# ================================================================================================================

// ----------- GLOBAL -----------
variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project" {
  type    = string
  default = "kafka"
}

// ----------- VPC -----------
variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_availability_zone" {
  type    = string
  default = "eu-west-1a"
}

variable "subnet_cidr_block" {
  type    = string
  default = "10.0.0.0/24"
}

variable "ingress_ips" {
  type    = string
}

// ----------- LOCALS -----------
locals {
  tags = {
    "databricks:deployment" = "terraform",
    "databricks:region"     = var.region,
    "databricks:env"        = var.environment
    "databricks:project"    = var.project
  }
}