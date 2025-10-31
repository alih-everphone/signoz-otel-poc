variable "gcp_project_id" {
  description = "GCP project ID where resources will be created"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for the cluster"
  type        = string
  default     = "us-central1"
}

variable "vpc_name" {
  description = "Name for the custom VPC"
  type        = string
  default     = "signoz-vpc"
}

variable "subnet_name" {
  description = "Name for the subnet"
  type        = string
  default     = "signoz-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.2.0.0/16"
}

variable "cluster_name" {
  description = "Name for the GKE Autopilot cluster"
  type        = string
  default     = "signoz-cluster"
}

variable "signoz_namespace" {
  description = "Namespace for SigNoz installation"
  type        = string
  default     = "platform"
}

variable "signoz_chart_version" {
  description = "Version of the SigNoz Helm chart"
  type        = string
  default     = "0.98.1" # Check https://charts.signoz.io for latest
}

variable "signoz_storage_class" {
  description = "Storage class to use for SigNoz (Autopilot default is gce-resizable)"
  type        = string
  default     = "standard-rwo"
}
