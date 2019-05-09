# About

Scripts to deploy a kubernetes application from scratch. The name was chosen because [baklava](https://en.wikipedia.org/wiki/Baklava) consists of small pieces, like we put many technologies together, and has many layers as in Docker images.

# Technologies

- Terraform
- Ansible
- Kubespray

# Usage

## 1-Pull the Docker image from Docker Hub or build it

### To pull it:

```shell
docker pull nlesc/baklava:latest
```

### To build it:

```shell
docker build --network=host -t nlesc/baklava ./Docker
```

## 2-Settings

### 2.1 VM configuration (template)

Edit **config/opennebula_k8s.tpl** to adjust the following VM settings:

    CPU = "1.0"
    VCPU = "2"
    IMAGE_ID = "YOUR_IMAGE_ID"
    MEMORY = "4096"
    NIC = [
      NETWORK = "INTERNAL_NETWORK_NAME",
      NETWORK_UNAME = "NETWORK_USERNAME" ]

### 2.2 Credentials

Edit **config/variables.tf** and set user credentials.

## 3-Deploy the cluster

```shell
docker run --rm --net=host -it \
  -v $(pwd)/config:/baklava/config \
  -v $(pwd)/deployment:/baklava/deployment \
  nlesc/baklava:latest
```

Confirm the planned changes by typing **yes**

# Connecting to the nodes

## ssh to nodes
```shell
ssh -i /baklava/id_rsa_baklava root@SERVER_IP
```

# Notes

The firewall is disabled at the moment.

# TODO

- Kubespray addons
- Enable dashboard by default
- Persistent volumes
- Load balancer