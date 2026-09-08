## Installation `k8s` et prérequis.

---

- Ici l'installation se fait via un script. (A l'examen le cluster est fourni)


- Lancer le script sur chaque machine
````
#!/bin/bash
set -e

echo "=== Prerequis systeme ==="

swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
net.ipv6.ip_forward                 = 1
EOF
sysctl --system

setenforce 0
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

systemctl disable --now firewalld

echo "=== Containerd ==="

dnf install -y yum-utils
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install -y containerd.io

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl enable --now containerd

echo "=== kubeadm kubelet kubectl ==="

cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.37/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.37/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet

echo "Install terminee sur $(hostname)"
echo "Rappel: kubeadm init se lance uniquement sur k8s-master"
````

--- 

- Uniquement sur k8s-master `192.168.0.2`

- Initialisation de `Calico` qui sera le `CNI` du cluster, son rôle :

   - Gérer le réseau des pods => Atribution IP  

   - NetworkPolicy : applique les règles de firewall entre pods.

````
kubeadm init \
  --apiserver-advertise-address=192.168.0.2 \
  --pod-network-cidr=172.16.0.0/16
````

- Sortie
````
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.0.2:6443 --token p6yhss.kz1mefair5utz9am \
        --discovery-token-ca-cert-hash sha256:1d8aea0e9966e7d322772854ecfbd3a9729a19877edfd50b77066e1b1abf8228
````

---

- Pour que kubectl fonctionne directement avec sednal
````
mkdir -p ~/.kube
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
````

- Test Master
````
kubectl get nodes
````

- Sortie attendu:
````
NAME         STATUS   ROLES           AGE    VERSION
k8s-master   Ready    control-plane   8m5s   v1.37.0
````

---

- Sur k8s-worker1 et k8sworker2 pour, implémenter les worker1 et worker2 au node de master.
````
# !!! En root !!!
kubeadm join 192.168.0.2:6443 --token p6yhss.kz1mefair5utz9am \
        --discovery-token-ca-cert-hash sha256:1d8aea0e9966e7d322772854ecfbd3a9729a19877edfd50b77066e1b1abf8228
````

- Sortie worker
````
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.
````

- Sortie master avec `kubectl get nodes`
````
NAME          STATUS   ROLES           AGE    VERSION
k8s-master    Ready    control-plane   13m    v1.37.0
k8s-worker1   Ready    <none>          108s   v1.37.0
k8s-worker2   Ready    <none>          117s   v1.37.0
````





















---







