# Baklava

Scripts to deploy a kubernetes application from scratch. The name was chosen because [baklava](https://en.wikipedia.org/wiki/Baklava) consists of small pieces, like we put many technologies together, and has many layers as in Docker images.

## Technologies

- Terraform
- Ansible
- Kubespray
- [Metallb](https://metallb.universe.tf/) load balancer

## Usage

### 1-Pull the Docker image from Docker Hub

#### To pull it:

```shell
docker pull nlesc/baklava:latest
```

If you want to build the Docker image yourself:

```shell
docker build --network=host -t nlesc/baklava ./Docker
```

### 2-Settings

#### 2.1 VM configuration (template)

Edit **config/opennebula_k8s.tpl** to adjust the following VM settings:

    CPU = "1.0"
    VCPU = "2"
    IMAGE_ID = "YOUR_IMAGE_ID"
    MEMORY = "4096"
    NIC = [
      NETWORK = "INTERNAL_NETWORK_NAME",
      NETWORK_UNAME = "NETWORK_USERNAME" ]

#### 2.2 Credentials

Edit **config/variables.tf** and set user credentials.

### 3-Deploy the cluster

```shell
docker run --rm --net=host -it \
  -v $(pwd)/config:/baklava/config \
  -v $(pwd)/deployment:/baklava/deployment \
  nlesc/baklava:latest
```

Confirm the planned changes by typing **yes**

Configuration and the ssh-keys of the deployed cluster willbe stored under **deployment** folder.


## Connecting to the nodes

### ssh to nodes

You can connecte to nodes using generated ssh keys. For example:

```shell
ssh -i ./deployment/cluster0/id_rsa_baklava root@SERVER_IP
```

## Kubernetes info

### Kubernetes dashboard

You can connect to Kubernetes dashboard (web ui) using the link below.

[https://MASTER_IP:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy](https://MASTER_IP:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy)

**MASTER_IP** is the ip address of the master node (usually node1).

In order to login to the dashboard you will need a token. You can get the token by running the following command on the master node:

```shell
kubectl describe secret $(kubectl -n kube-system get secret | awk '/^cluster-admin-dashboard-sa-token-/{print $1}') | awk '$1=="token:"{print $2}'
```

### Kubernetes cluster info

Basic info about the cluster can be obtained by running:

```shell
kubectl cluster-info
```

If you want to get more detailed info, you can run:

```shell
kubectl cluster-info dump
```

### Get list of pods

```shell
kubectl get --all-namespaces pods
```

## Important notes

The firewall is disabled at the moment.

## TODO

- Persistent volumes