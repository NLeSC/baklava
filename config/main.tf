variable "DEPLOY_FOLDER" {}

provider "opennebula" {
        endpoint = "${var.endpoint_url}"
        username = "${var.one_username}"
        password = "${var.one_password}"
}

data "template_file" "one-kube-template" {
        template = "${file("opennebula_k8s.tpl")}"
}

resource "opennebula_template" "one-kube-template" {
        name = "k8s-template"
        description = "${data.template_file.one-kube-template.rendered}"
        permissions = "600"
}

resource "opennebula_vm" "kube-node" {
        name = "node${count.index+1}"
        template_id = "${opennebula_template.one-kube-template.id}"
        permissions = "600"
        count = "${var.number_of_nodes}"
}

resource "null_resource" "kubernetes" {

        provisioner "local-exec" {
                command = "ansible-playbook /baklava/config/kubespray_addons.yml"
        }

        provisioner "local-exec" {
                command = "cp -rfp /baklava/kubespray/inventory/sample ${var.DEPLOY_FOLDER}/${var.cluster_name}"
        }

        provisioner "local-exec" {
                command = "/bin/bash -c \"declare -a IPS=(${join(" ", opennebula_vm.kube-node.*.ip)})\""
        }

        provisioner "local-exec" {
                command = "CONFIG_FILE=${var.DEPLOY_FOLDER}/${var.cluster_name}/hosts.yaml python3 /baklava/inventory_builder/inventory.py ${join(" ", opennebula_vm.kube-node.*.ip)}"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${var.DEPLOY_FOLDER}/${var.cluster_name}/hosts.yaml /baklava/config/firewall.yml --private-key=/baklava/id_rsa_baklava"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${var.DEPLOY_FOLDER}/${var.cluster_name}/hosts.yaml /baklava/kubespray/cluster.yml --private-key=/baklava/id_rsa_baklava -v"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${var.DEPLOY_FOLDER}/${var.cluster_name}/hosts.yaml /baklava/kubespray/contrib/metallb/metallb.yml --private-key=/baklava/id_rsa_baklava -v"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${var.DEPLOY_FOLDER}/${var.cluster_name}/hosts.yaml /baklava/config/fix_glusterfs_ppa.yml --private-key=/baklava/id_rsa_baklava"
        }

        provisioner "local-exec" {
                command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False; cd /baklava/kubespray; ansible-playbook -b --become-user=root -i ${var.DEPLOY_FOLDER}/${var.cluster_name}/hosts.yaml --user=root /baklava/kubespray/contrib/network-storage/glusterfs/glusterfs.yml --private-key=/baklava/id_rsa_baklava -v"
        }

}

output "kube-node-vm_id" {
        value = "${opennebula_vm.kube-node.*.id}"
}

output "kube-node-vm_ip" {
        value = "${opennebula_vm.kube-node.*.ip}"
}

