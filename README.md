# Monitoring Demo

## Kind Project Set Up

[Kind](https://kind.sigs.k8s.io/) is a tool for running local Kubernetes clusters.

### Pre-requisites

* [Docker](https://docs.docker.com/get-docker/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Helm](https://helm.sh/docs/intro/install/)

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

        kubectl proxy

5. Open [the dashboard](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

### Load Demo

1. Build Images

        docker build -t demo/gc-thrasher:0.1 services/gc-thrasher
        docker build -t demo/node-api:0.1 services/node-api
        ...

2. Load images into the cluster

        kind --name demo load docker-image demo/gc-thrasher:0.1
        kind --name demo load docker-image demo/node-api:0.1
        ...

3. Start the demo

        kubectl apply -f kind/demo-workload.yaml

4. Verify functionality

        $ curl -isSk https://localhost/api/healthz
        HTTP/2 200
        ...

        {"status":"up"}

### DataDog Agent for Kubernetes

1. Obtain your `DATADOG_API_KEY` from the [DataDog agent set up page](https://app.datadoghq.com/account/settings#agent/kubernetes) and save it as an environment variable.
2. Set a custom name for your cluster as an environment variable.
3. Install the daemon set using `helm`.

        export DATADOG_API_KEY=REDACTED
        export CLUSTER_NAME=kind-demo-jane-doe
        helm repo add datadog https://helm.datadoghq.com
        helm repo add stable https://charts.helm.sh/stable --force-update
        helm repo update
        helm install $CLUSTER_NAME -f datadog/k8s-agent-values.yaml --set datadog.clusterName=$CLUSTER_NAME --set datadog.apiKey=$DATADOG_API_KEY datadog/datadog 

### Clean-up

        kind delete cluster --name demo
