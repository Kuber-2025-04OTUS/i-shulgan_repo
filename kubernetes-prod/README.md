1) Создание и обновление кластера k8s c помощью kubeadm.

Для создания и конфигурирования виртуальных машин скопируйте/переименуйте файл `kubeadm/terraform/local.auto.tfvars.example` в `kubeadm/terraform/local.auto.tfvars`, замените в нем переменные и выполните команды:

```shell
terraform -chdir=kubeadm/terraform init
terraform -chdir=kubeadm/terraform apply -auto-approve
ansible-playbook -i kubeadm/inventory.ini kubeadm/install-playbook.yaml
```

Подлюкчетесь к ВМ master-01 по ssh (пользователь debian) и от имени пользоватля root выполните команду:
```
root@master-01:~# kubectl get nodes -o wide
NAME        STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION   CONTAINER-RUNTIME
master-01   Ready    control-plane   67s   v1.32.7   10.0.0.13     <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-37-amd64   containerd://1.6.20
worker-01   Ready    <none>          37s   v1.32.7   10.0.0.26     <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-37-amd64   containerd://1.6.20
worker-02   Ready    <none>          36s   v1.32.7   10.0.0.29     <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-37-amd64   containerd://1.6.20
worker-03   Ready    <none>          37s   v1.32.7   10.0.0.8      <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-37-amd64   containerd://1.6.20
```

```shell
ansible-playbook -i kubeadm/inventory.ini kubeadm/upgrade-k8s-playbook.yaml
```

Подлюкчетесь к ВМ master-01 по ssh (пользователь debian) и от имени пользоватля root выполните команду:
```
root@master-01:~# kubectl get nodes -o wide
NAME        STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION   CONTAINER-RUNTIME
master-01   Ready    control-plane   16m   v1.33.3   10.0.0.13     <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-37-amd64   containerd://1.6.20
worker-01   Ready    <none>          15m   v1.33.3   10.0.0.26     <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-37-amd64   containerd://1.6.20
worker-02   Ready    <none>          15m   v1.33.3   10.0.0.29     <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-37-amd64   containerd://1.6.20
worker-03   Ready    <none>          15m   v1.33.3   10.0.0.8      <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-37-amd64   containerd://1.6.20
```

2) Создание и обновление кластера k8s c помощью kubespray.
Для создания и конфигурирования виртуальных машин скопируйте/переименуйте файл `kubespray/terraform/local.auto.tfvars.example` в `kubespray/terraform/local.auto.tfvars`, замените в нем переменные и выполните команды:

```shell
terraform -chdir=kubespray/terraform init
terraform -chdir=kubespray/terraform apply -auto-approve
docker run --rm -it --mount type=bind,source="$(pwd)"/kubespray/inventory/prod/,dst=/kubespray/inventory/prod/ \
  --mount type=bind,source="$(pwd)"/kubespray/id_ed25519,dst=/root/.ssh/id_ed25519 \
  quay.io/kubespray/kubespray:v2.28.0 bash
```
А затем в контейнере запуститете kubespray с помощью команды:
```shell
 ansible-playbook -i inventory/prod/inventory.ini cluster.yml --private-key /root/.ssh/id_ed25519
```

Подлюкчетесь к ВМ master-01 по ssh (пользователь debian) и от имени пользоватля root выполните команду:
```
root@master-01:~# kubectl get nodes -o wide
NAME        STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION   CONTAINER-RUNTIME
master-01   Ready    control-plane   15m   v1.32.5   10.0.0.24     <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-37-amd64   containerd://2.0.5
master-02   Ready    control-plane   14m   v1.32.5   10.0.0.35     <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-37-amd64   containerd://2.0.5
master-03   Ready    control-plane   14m   v1.32.5   10.0.0.30     <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-37-amd64   containerd://2.0.5
worker-01   Ready    <none>          13m   v1.32.5   10.0.0.37     <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-37-amd64   containerd://2.0.5
worker-02   Ready    <none>          13m   v1.32.5   10.0.0.8      <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-37-amd64   containerd://2.0.5
```