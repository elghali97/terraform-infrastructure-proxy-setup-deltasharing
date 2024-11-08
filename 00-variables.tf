# ================================================================================================================
# Variables
# ================================================================================================================

// ----------- General -----------
variable "location" {
  type        = string
  description = "(Required) The location for the resources in this module"
}

variable "location_short_name" {
  type        = string
  description = "(Required) The short name of location for the resources in this module"
}

variable "environment" {
  type        = string
  description = "(Required) The environment name for the deployment"
}

variable "project_name" {
  type        = string
  description = "(Required) The name of the project associated with the infrastructure to be managed by Terraform"
}

variable "project_short_name" {
  type        = string
  description = "(Required) The short name of the project associated with the infrastructure to be managed by Terraform"
}

variable "owner" {
  type        = string
  default     = "elghali.benchekroun@databricks.com"
  description = "(Optional) Owner of the resources deployed on Azure"
}

variable "remove_after" {
  type        = string
  description = "(Required) A valid date in YYYY-MM-DD format"
}

// ----------- Resource Group -----------
variable "shared_resource_group_name" {
  type        = string
  description = "(Required) The name of the Resource Group to deploy resources in it"
}

// ----------- Networking -----------
variable "vnet_address_cidr" {
  type        = string
  description = "(Required) The address space for the shared Virtual Network"
}

// --------- Storage Account --------
variable "storage_account" {
  type        = string
  description = "(Required) Names of the storage account used"
}

variable "ingress_ips" {
  type        =  string
  description = "(Required) ZScaler Databricks Ingress IPs"
}

locals {
  tags = {
    "databricks:deployment"  = "terraform",
    "databricks:location"    = var.location,
    "databricks:region"      = var.location_short_name
    "databricks:environment" = var.environment,
    "databricks:project"     = var.project_name,
    "databricks:short-name"  = var.project_short_name,
    "Owner"                  = var.owner,
    "RemoveAfter"            = var.remove_after
  }
}