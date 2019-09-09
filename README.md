# Baklava

This repository includes scripts to deploy a kubernetes cluster and applications from scratch. Currently, it supports [OpenNebula](https://opennebula.org) platform. 

The name was chosen because [baklava](https://en.wikipedia.org/wiki/Baklava) consists of small pieces, like we put many technologies together, and has many layers as in Docker images.

## Technologies & Tools

- [Terraform Client](https://www.terraform.io)
- [Runtastic Terraform Opennebula provider](https://github.com/runtastic/terraform-provider-opennebula)
- [Ansible](https://www.ansible.com/)
- [Kubespray](https://github.com/kubernetes-sigs/kubespray)
- [Metallb](https://metallb.universe.tf/)
- [Heketi](https://github.com/heketi/heketi)
- [Gluster](https://www.gluster.org)

## Usage

### 1-Pull the Docker image from Docker Hub

```bash
docker pull nlesc/baklava:latest
```

### 2-Settings

#### 2.1 VM configuration (template)

Edit **config/opennebula_k8s.tpl** to adjust the following VM settings:

    CPU = "2.0"
    VCPU = "2"
    IMAGE_ID = "YOUR_IMAGE_ID"
    MEMORY = "4096"
    NIC = [
      NETWORK = "INTERNAL_NETWORK_NAME",
      NETWORK_UNAME = "NETWORK_USERNAME" ]

There are two **SIZE** variables. The first one is for the cluster itselft and the second one is for the persistent storage. The default values are about 15G and 30G.

#### 2.2 Credentials

Edit **config/variables.tf** and set user credentials.

### 3-Deploy the cluster

```bash
docker run --rm --net=host -it \
  -v $(pwd)/config:/baklava/config \
  -v $(pwd)/deployment:/baklava/deployment \
  nlesc/baklava:latest
```

Confirm the planned changes by typing **yes**

Configuration and the ssh-keys of each deployed cluster will be stored under **deployment/clusterX** folder.

## Connecting to the nodes

### ssh to nodes

You can connect to the nodes using generated ssh keys. For example:

```bash
ssh -i ./deployment/cluster0/id_rsa_baklava root@SERVER_IP
```

## Kubernetes info

### Kubernetes dashboard

You can connect to Kubernetes dashboard (web-ui) using the link below.

[https://MASTER_IP:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy](https://MASTER_IP:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy)

**MASTER_IP** is the ip address of the master node (usually node1).

You can also find this url by running:

```bash
kubectl cluster-info | grep dashboard
```

In order to login to the dashboard,  you need to create an acount for the dashboard. Follow the steps below.

- Create service account (run on the master node):

  ```bash
  kubectl create serviceaccount cluster-admin-dashboard-sa
  ```

- Bind ClusterAdmin role to the service account (run on the master node):

  ```bash
  kubectl create clusterrolebinding cluster-admin-dashboard-sa \
    --clusterrole=cluster-admin \
    --serviceaccount=default:cluster-admin-dashboard-sa
  ```

In order to login to the dashboard you will need a token. You can get the token by running the following command on the master node:

  ```bash
  kubectl describe secret $(kubectl -n kube-system get secret | awk '/^cluster-admin-dashboard-sa-token-/{print $1}') | awk '$1=="token:"{print $2}' | head -n1
  ```

### Kubernetes cluster info

Basic info about the cluster can be obtained by running:

```bash
kubectl cluster-info
```

If you want to get more detailed info, you can run:

```bash
kubectl cluster-info dump
```

List of nodes:

```bash
kubectl get nodes
```

List of podes:

```bash
kubectl get pods --all-namespaces 
```

Get detailed info about a pod:

```bash
kubectl describe pod kubernetes-dashboard-6c7466966c-q4z8q -n kube-system
```

List all services:

```bash
kubectl get services
```

### Kubernetes cheatsheet

Some other useful example commands can be found in [Kubernetes cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/).

## Important notes

The firewall is disabled at the moment.

## TODO

- Install [Minio](https://github.com/minio/minio-operator)
- Setup Ingress
- Configure LoadBalancer
- Manage k8s using [ansible k8s module](https://docs.ansible.com/ansible/latest/modules/k8s_module.html)
- Setup a firewall
- Add an example for application deployment
- Example helm chart installations (Spark, JupyterHub, Dask)
- Add links and credits
