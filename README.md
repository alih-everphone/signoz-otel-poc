# SigNoz PoC - Terraform Deployment

This Terraform configuration deploys a Google Cloud Platform (GCP) GKE cluster for SigNoz.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- GCP project with billing enabled
- Appropriate IAM permissions to create GKE clusters

## Configuration

The main configuration deploys a GKE cluster with the following settings:

- **Autopilot Mode**: Enabled for simplified cluster management
- **Release Channel**: REGULAR (default channel with regular updates)
- **Network**: Uses default VPC and subnet
- **Deletion Protection**: Disabled for easier cleanup in PoC

### Required Variables

Create a `terraform.tfvars` file or set environment variables:

```
cluster_name = "signoz-cluster"
gcp_region   = "us-central1"
```

## Deployment Steps

### 1. Initialize Terraform

```bash
terraform init
```

This downloads the required GCP provider and initializes the Terraform working directory.

### 2. Plan the Deployment

```bash
terraform plan
```

Reviews all resources that will be created. Verify the GKE cluster configuration before proceeding.

### 3. Apply and Create the Cluster

```bash
terraform apply --target=google_container_cluster.signoz_cluster
```

Creates only the GKE cluster resource. This approach is useful when you have multiple resources and want to deploy them selectively.

Alternatively, apply all resources:

```bash
terraform apply
```

## Cleanup

To destroy the cluster:

```bash
terraform destroy
```

## Notes

- The `deletion_protection = false` setting allows easier cleanup for PoC environments
- Ensure you have sufficient GCP quotas for GKE cluster creation
- Monitor GCP billing to manage costs
