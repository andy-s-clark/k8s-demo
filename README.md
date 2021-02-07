# Kubernetes Demo

## Kind Project Set Up

[Kind](https://kind.sigs.k8s.io/) is a tool for running local Kubernetes clusters.

### Pre-requisites

* Docker

### Installation

Download the binary for you architecture, make the file executable, and place the file in your path.

See the [Kind Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) for details.

### Cluster Set up

1. Create the cluster

        kind create cluster --name demo --config kind/demo-cluster.yaml

2. Verify that the cluster is up

        kubectl cluster-info --context kind-demo
        kubectl get nodes
        kubectl get namespaces
        kubectl get pods -A

3. Enable Nginx Ingress and wait for it to be ready

        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

        kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s

4. Add a `master` Ingress for `localhost`

        kubectl apply -f kind/localhost-ingress-master.yaml

*Note that `kubectl` commands need the context of `kind-demo` if you have another k8s clusters as the default in your `kubectl` config.*

#### Start the echo-test service *(optional)*

1. Start the `echo-test` deployment, service, and ingress minion.

        kubectl apply -f kind/echo-test.yaml

2. Verify functionality after waiting a few seconds

        $ curl -isSk https://localhost/echo
        HTTP/2 200 
        ...

        Success

#### Set up K8s Dashboard  *(optional)*

1. Deploy the web UI

        kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

2. Create an admin user, bind the `cluster-admin` role, and look up the name of the user's secret.

        kubectl apply -f kind/dashboard-admin-user.yaml

3. Get a `token` for use in the `kubernetes-dashboard`

    1. Easy Method (requires bash)

                kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"

    2. Look up the name of the user's secret (ex. `admin-user-token-w58cq`) and use it to get a token .

                kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}"

                kubectl -n kubernetes-dashboard get secret admin-user-token-w58cq -o go-template="{{.data.token | base64decode}}"

4. Start a proxy

        kubectl proxy &

5. Open [the dashboard](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

### Clean-up

        kind delete cluster --name demo

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
