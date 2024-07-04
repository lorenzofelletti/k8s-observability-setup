# Kubernetes Observability
Spin up a Kubernetes cluster with Prometheus and Grafana installed using Docker, and Terraform.
The repo provides IaC to create a Kubernetes cluster using Kind, but the Prometheus and Grafana setup can be used with any Kubernetes cluster.

## Setup MinIO
Run the following command to start MinIO:
```bash
make minio-up
```
> If you want to customise the MinIO setup, create a `.env` file in the `minio` directory using the `default.env` file as a template.
>
> The `default.env` file provides default values good enough for local development.

## Setup Terraform State Backend on MinIO
1. Connect to the MinIO web interface and create a bucket named `terraform-states` with
    - Locking enabled
    - Versioning enabled.

2. Create another bucket named `cluster-kubeconfig` to store the kubeconfig file for the Kind cluster (which will be useless at the moment,
because MinIO Terraform provider does not provide a way to read from bucket yet).

3. Create a user with the necessary permissions to read/write to the buckets (choose the IAM setup that suits your needs best).

4. Create a pair of keys for the user, take note of them and download the `credentials.json` file. Then copy the credentials file
to the root of this repository.

5. Create a `.config.s3.tfbackend` file in both `terraform/kind-cluster` and `terraform/observability` directories with the following content:
    ```hcl
    bucket = "terraform-states"
    endpoints = {
      s3 = "http://localhost:9000"
    }
    # e.g "kind-cluster/terraform.tfstate" or "observability/terraform  tfstate"
    # but it could be any value (as long as it is unique for each state file)
    key = "<DIRECTORY_NAME>/terraform.tfstate"

    access_key = "<YOUR_ACCESS_KEY>"
    secret_key = "<YOUR_SECRET_KEY>"

    region                      = "main"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
    ```

## Create Cluster
The cluster IaC is in the `terraform/kind-cluster` directory.
A `dev.tfvars` file is provided to set up a cluster using a pre-packaged configuration.

Run the following command to create the cluster:
```bash
# file path is relative to the terraform/kind-cluster directory
make init STACK=kind ARGS="-backend-config=.config.s3.tfbackend"
make plan STACK=kind ARGS="-var-file=dev.tfvars"
make apply STACK=kind ARGS="-var-file=dev.tfvars"
```

### Setup Prometheus And Grafana
Once that the cluster is created, run the following command to set up Prometheus and Grafana:
```bash
make init STACK=observability ARGS="-backend-config=.config.s3.tfbackend"
make plan STACK=observability ARGS="-var-file=dev.tfvars"
make apply STACK=observability ARGS="-var-file=dev.tfvars"
```
