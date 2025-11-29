# SigNoz PoC - Terraform Deployment

This Terraform configuration deploys a Google Cloud Platform (GCP) GKE cluster for SigNoz.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- GCP project with billing enabled
- Appropriate IAM permissions to create GKE clusters
- [Helm](https://helm.sh/docs/intro/install/) >= 3.0 (for SigNoz deployment)

## Configuration

The main configuration deploys a GKE cluster with the following settings:

- **Autopilot Mode**: Enabled for simplified cluster management
- **Release Channel**: REGULAR (default channel with regular updates)
- **Network**: Uses default VPC and subnet
- **Deletion Protection**: Disabled for easier cleanup in PoC
- **Region**: eu-west3 (Frankfurt, Germany)

### Required Variables

Create a `terraform.tfvars` file or set environment variables:

```
cluster_name = "signoz-cluster"
gcp_region   = "eu-west3"
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

### 4. Configure kubectl Access

After the cluster is created, configure kubectl:

```bash
gcloud container clusters get-credentials signoz-cluster --region eu-west3
```

### 5. Update values.yaml

Before deploying SigNoz, update the `values.yaml` file with your cluster-specific settings:

```bash
# Edit the values.yaml file
nano values.yaml
```

Key settings to configure:

- **Storage**: Adjust storage class and size for persistent volumes
- **Resources**: Set CPU and memory limits based on your cluster capacity
- **Ingress**: Configure ingress settings for external access
- **Database**: Update database credentials if using external services

For detailed configuration options and examples, refer to the official SigNoz Helm charts documentation:

📚 [SigNoz Helm Charts](https://github.com/SigNoz/charts/tree/main/charts)

### 6. Update DNS Records (Using GCP Console GUI)

After deployment completes, retrieve the Load Balancer IPs and update your DNS records via the GCP Console.

#### Get Frontend Ingress Load Balancer IP

```bash
kubectl get ingress signoz-frontend-ingress -n signoz -o wide
```

Copy the **EXTERNAL-IP**, then update DNS via GCP Console:

1. Open [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **Network Services** → **Cloud DNS**
3. Select your DNS zone
4. Find or create the DNS record for `signoz.everphone.dev`
5. Edit the A record and set the IP to the **EXTERNAL-IP** from above
6. Click **Save**

#### Get OTEL Collector Ingress Load Balancer IP

```bash
kubectl get ingress signoz-otel-ingress -n signoz -o wide
```

Copy the **EXTERNAL-IP**, then update DNS via GCP Console:

1. Open [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **Network Services** → **Cloud DNS**
3. Select your DNS zone
4. Find or create the DNS record for `signoz-ingest.everphone.dev`
5. Edit the A record and set the IP to the **EXTERNAL-IP** from above
6. Click **Save**

**Note**: It may take a few minutes for the Load Balancer IPs to be assigned. If the IP is not showing, wait a moment and retry the command.

## Cleanup

To destroy the cluster:

```bash
terraform destroy
```

## Notes

- The `deletion_protection = false` setting allows easier cleanup for PoC environments
- Ensure you have sufficient GCP quotas for GKE cluster creation in eu-west3
- Monitor GCP billing to manage costs
- Review and customize `values.yaml` before deploying SigNoz Helm chart
- Consult the [SigNoz Helm charts repository](https://github.com/SigNoz/charts/tree/main/charts) for deployment best practices and advanced configurations
- DNS propagation may take up to 5-10 mins
