# Kubernetes Demo

## GCP Project Set Up

GKE free tier using **paid** `e2-micro` nodes. These instructions assume that a personal GCP account is being used and does not cover setting up an organization.

This can also be done using the [Google Cloud Console](https://cloud.google.com/).

The examples use the following values which will need to be replaced:

* `k8s-demo-123456` - Your unique project ID
* `yourpersonaladdress@gmail.com` - Your personal Google Account
* `012345-6789AB-CDEF01` - Your billing account ID (see step 6)

1. Download and install [gcloud command-line tool](https://cloud.google.com/sdk/gcloud)
2. Authenticate the gcloud CLI

        gcloud auth application-default login
3. Create a GCP project. When prompted, accept the ID that is randomly assigned.

        gcloud projects create --name="k8s-demo"
4. List projects and make note of the `project_id`

        $ gcloud projects list
        PROJECT_ID            NAME          PROJECT_NUMBER
        k8s-demo-123456       k8s-demo      123456789012
5. Set the default project

        gcloud config set project k8s-demo-123456

6. Find the `account_id` using the `gcloud` UI (Create a billing account using the web interface if needed)

        gcloud alpha billing accounts list
        ACCOUNT_ID            NAME                OPEN  MASTER_ACCOUNT_ID
        012345-6789AB-CDEF01  My Billing Account  True

7. Link the billing account to the project

        gcloud alpha billing projects link k8s-demo-123456 --billing-account=012345-6789AB-CDEF01

## Terraform Set Up

1. [Download Terraform](https://www.terraform.io/downloads.html)
2. Place the binary in your path (ex. `~/bin`)

## Create Infrastruction

Uses Terraform to create a Kubernetes cluster. State is managed locally.

        cd gcp
        terraform init
        terraform plan -var 'project_id=k9s-demo-123456' -out my.plan
        terraform apply my.plan

## Destroy Infrastructure

GKE Compute nodes cost money. Terraform allows you to destroy the infrastructure and recreate it (using `plan` and `apply`) when it is needed again.

        terraform destroy -var 'project_id=k8s-demo-303322' -target=google_container_cluster.primary
