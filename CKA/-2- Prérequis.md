## Installation `k8s` et prérequis.

---

### -1- Installation Sur RHEL 10

### -2- Installation sur Ubuntu Server

---

<details>
<summary>
<h2>
-1- Installation Sur RHEL 10
</h2>
</summary>

- Ici l'installation se fait via un script. (À l'examen le cluster est fourni)


- Lancer le script sur chaque machine
````
#!/bin/bash
set -e

echo "=== Prérequis système ==="

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

echo "Install terminée sur $(hostname)"
echo "Rappel: kubeadm init se lance uniquement sur k8s-master"
````

--- 

- Uniquement sur k8s-master `192.168.0.2`

- Initialisation de `Calico` qui sera le `CNI` du cluster, son rôle :

   - Gérer le réseau des pods => Attribution IP  

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

- Sortie attendue :
````
NAME         STATUS   ROLES           AGE    VERSION
k8s-master   Ready    control-plane   8m5s   v1.37.0
````

---

- Sur k8s-worker1 et k8s-worker2, pour rattacher worker1 et worker2 au node master.
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





</details>



---
---


<details>
<summary>
<h2>
-2- Installation sur Ubuntu Server 
</h2>
</summary>


# ⚠️ IP Address ⚠️

### Spécificité à mon lab :

- `DHCP` pfsense et client `Ubuntu Server 26`

- Problème : les deux serveurs Ubuntu ne prennent pas les adresses IP des lease pfsense

- Cause : Bug au niveau de l'indexation des demandes de lease :

    - DUID côté client, réservation indexée sur MAC côté serveur

- Solution : forcer le client à s'identifier par MAC, pas par DUID. 
````
sudo vim /etc/netplan/00-installer-config.yaml
````

````
network:
  ethernets:
    ens18:
      dhcp4: true
      dhcp6: true
      dhcp-identifier: mac
      match:
        macaddress: bc:24:11:59:76:8f    # adapte pour chaque VM
      set-name: ens18
  version: 2
````

````
sudo netplan apply
sudo networkctl reconfigure ens18
ip a show ens18
````
---

# Installation de Kubernetes sur Ubuntu Server

- Installation via le GitHub de [Sander van Vugt](https://github.com/sandervanvugt/cka)
````
git clone https://github.com/sandervanvugt/cka
````

- Installation via les scripts suivants :
````
cd $HOME/cka
````


- `-1-`
````
./setup-container.sh
````


- `-2-`
````
./setup-kubetools-previousversion.sh
````

- État de containerd
````
sudo systemctl status containerd.service
````

!!! Uniquement sur le node choisi pour être le `control plane` !!!

- Ici ajout de `--pod-network-cidr=172.16.0.0/16` car mon réseau LAN est en 192.168.0.0/24 et le manifeste Calico par défaut utilise 192.168.0.0/16

- Sans cette option : routage cassé, nœuds qui restent NotReady
````
sudo kubeadm init --pod-network-cidr=172.16.0.0/16
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

kubeadm join 192.168.0.5:6443 --token yul2cd.ipu5ita9k5xaywrd \
        --discovery-token-ca-cert-hash sha256:7cb06b4e9b6213f8eea2b8f57cf88057e6a1231ce830a9e31cc2d1da31e25f2e
````

- Sur le master 
````
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
````

- Test
````
kubectl get all

# Sortie
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   25m
````


- Gestion Network :

- Télécharger le yaml de `Calico` 
````
cd $HOME
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/calico.yaml
ls -lh calico.yaml
````

- !!! Changer le fichier, pour correspondre à notre plage IP !!!
````
vim calico.yaml

# Rechercher
/CALICO_IPV4POOL_CIDR

# Changer la valeur existante par :
172.16.0.0/16

# Et suppression du commentaire sur les lignes
- name: CALICO_IPV4POOL_CIDR
  value: "172.16.0.0/16"
````


- Appliquer les modifications
````
kubectl apply -f calico.yaml
````

- Vérification
````
watch kubectl get pods -n kube-system
````
- Sortie Attendue : STATUS => Running pour tout le monde
  

---

- Ajouter des Nodes, à réaliser sur chaque worker
````
sudo kubeadm join 192.168.0.5:6443 --token yul2cd.ipu5ita9k5xaywrd \
        --discovery-token-ca-cert-hash sha256:7cb06b4e9b6213f8eea2b8f57cf88057e6a1231ce830a9e31cc2d1da31e25f2e
````

- Vérification
````
kubectl get nodes

# Sortie
NAME          STATUS   ROLES           AGE    VERSION
k8s-master    Ready    control-plane   67m    v1.36.4
k8s-worker1   Ready    <none>          2m3s   v1.36.4
k8s-worker2   Ready    <none>          113s   v1.36.4
````


---

- Et pour finir l'installation à réaliser sur les 3 VM :
````
vim $HOME/.bashrc
````
````
# === Kubernetes ===
alias k=kubectl
source <(kubectl completion bash)
complete -o default -F __start_kubectl k
````
````
source ~/.bashrc
````

### ⚠️ les commandes ci-dessus sont les premières à réaliser le jour de l'examen ⚠️

</details>


---
---


<details>
<summary>
<h2>
-3- Ajout Node Master (HA) sur cluster existent
</h2>
</summary>

### Cette procédure s’applique dans le cas ou l'on souhaite ajouter des `Node Master` sur un cluster existant, dans l'objectif de fair de la `H.A` et en suivant les cours de Sander van Vugt.

- Ici :

- Master : k8s-master 192.168.0.5

- Worker-1 : k8s-worker1 192.168.0.6

- Worker-2 : k8s-worker2 192.168.0.7


- Installation via le GitHub de [Sander van Vugt](https://github.com/sandervanvugt/cka)
````
git clone https://github.com/sandervanvugt/cka
````
 
### `-1-` Installation `kubernetes` via les scripts suivants : sur (`192.168.0.8` / `192.168.0.9`)
````
cd $HOME/cka
````
 
`- 1.1`
````
./setup-container.sh
````
 
 `- 1.2`
````
./setup-kubetools-previousversion.sh
````
 
`- 1.3` État de containerd
````
sudo systemctl status containerd.service
````
 
---

### `-2-`Mise en place du Load Balancer (HAProxy + keepalived)

`[NOTE]`

- `HAProxy` = le load balancer — reçoit le trafic sur 6443 et le répartit entre les 3 API servers (k8s-master, k8s-master-2, k8s-master-3)

- `keepalived` = gère la VIP (Virtual IP) — décide quel nœud la porte à un instant donné, et la fait basculer automatiquement vers un autre nœud si celui qui l'a actuellement tombe (via le protocole VRRP).

`- 2.1` Installation (sur `192.168.0.5` / `192.168.0.8` / `192.168.0.9`)
````
sudo apt update && sudo apt install -y haproxy keepalived
````

`- 2.2` Autoriser HAProxy à bind sur une IP pas encore locale (sur `192.168.0.5` / `192.168.0.8` / `192.168.0.9`)
````
sudo sysctl -w net.ipv4.ip_nonlocal_bind=1
echo "net.ipv4.ip_nonlocal_bind = 1" | sudo tee /etc/sysctl.d/99-haproxy-vip.conf
````

`- 2.3` Editer le  fichier de configuartion `/etc/haproxy/haproxy.cfg` (sur `192.168.0.5` / `192.168.0.8` / `192.168.0.9`)
````
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon

defaults
    log     global
    mode    tcp
    option  tcplog
    timeout connect 5s
    timeout client  50s
    timeout server  50s

frontend apiserver
    bind 192.168.0.15:6443
    mode tcp
    option tcplog
    default_backend apiserver

backend apiserver
    mode tcp
    option tcp-check
    balance roundrobin
    server k8s-master    192.168.0.5:6443 check
    server k8s-master-2  192.168.0.8:6443 check
    server k8s-master-3  192.168.0.9:6443 check
````

`- 2.4` Editer le script : `/etc/keepalived/check_apiserver.sh` (sur `192.168.0.5` / `192.168.0.8` / `192.168.0.9`)
````
#!/bin/sh

errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

curl --silent --max-time 2 --insecure https://localhost:6443/ -o /dev/null || errorExit "Error GET https://localhost:6443/"
if ip addr | grep -q 192.168.0.15; then
    curl --silent --max-time 2 --insecure https://192.168.0.15:6443/ -o /dev/null || errorExit "Error GET https://192.168.0.15:6443/"
fi
````

`- 2.5` Executable
````
sudo chmod +x /etc/keepalived/check_apiserver.sh
````

`- 2.6` - Editer les ficher de configuration `/etc/keepalived/keepalived.conf` !!! Bien prendre le fichier de la machine corespondante !!! (sur `192.168.0.5` / `192.168.0.8` / `192.168.0.9`)

** === 192.168.0.5 === **
````
sudo vim /etc/keepalived/keepalived.conf
````
````
! Configuration File for keepalived
global_defs {
    enable_script_security
    router_id LVS_DEVEL
}

vrrp_script check_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state MASTER
    interface ens18
    virtual_router_id 151
    priority 255
    authentication {
        auth_type PASS
        auth_pass Password
    }
    virtual_ipaddress {
        192.168.0.15/24
    }
    track_script {
        check_apiserver
    }
}
````

** 192.168.0.8 **
````
sudo vim /etc/keepalived/keepalived.conf
````
````
! Configuration File for keepalived
global_defs {
    enable_script_security
    router_id LVS_DEVEL
}

vrrp_script check_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state SLAVE
    interface ens18
    virtual_router_id 151
    priority 254
    authentication {
        auth_type PASS
        auth_pass Password
    }
    virtual_ipaddress {
        192.168.0.15/24
    }
    track_script {
        check_apiserver
    }
}
````


** 192.168.0.9 **
````
sudo vim /etc/keepalived/keepalived.conf
````
````
! Configuration File for keepalived
global_defs {
    enable_script_security
    router_id LVS_DEVEL
}

vrrp_script check_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 3
    weight -2
    fall 10
    rise 2
}

vrrp_instance VI_1 {
    state SLAVE
    interface ens18
    virtual_router_id 151
    priority 253
    authentication {
        auth_type PASS
        auth_pass Password
    }
    virtual_ipaddress {
        192.168.0.15/24
    }
    track_script {
        check_apiserver
    }
}

````

`- 2.7` Démarrage
````
sudo systemctl enable haproxy --now
sudo systemctl enable keepalived --now

````


---
## -3- Joindre 192.168.0.8 / 192.168.0.9 / 192.168.0.5

### À réaliser sur k8s-master (192.168.0.5), pour générer un nouveau token et la certificate-key.

`- 3.1` A réaliser (sur `192.168.0.5` / `192.168.0.8` / `192.168.0.9`).

````
sudo kubeadm reset
````
 
`- 3.2` kubeadm init sur (`192.168.0.5`)
````
# Sur k8s-master uniquement
sudo kubeadm init \
  --control-plane-endpoint=192.168.0.15:6443 \
  --pod-network-cidr=172.16.0.0/16
````

`- 3.3` Initialisation Certificats pour le cluster
````
sudo kubeadm init phase upload-certs --upload-certs
````

`- 3.4` Config kubectl (sur `192.168.0.5`)
````
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
````

`- 3.5` Installation Calico et configuration (sur `192.168.0.5`)
````
cd $HOME
````
````
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.32.2/manifests/calico.yaml
````
````
ls -lh calico.yaml
````


- Application Scop IP pod (sur `192.168.0.5`)
````
sed -i \
  -e 's/^\(\s*\)# - name: CALICO_IPV4POOL_CIDR/\1- name: CALICO_IPV4POOL_CIDR/' \
  -e 's/^\(\s*\)#   value: "192\.168\.0\.0\/16"/\1  value: "172.16.0.0\/16"/' \
  calico.yaml
````

- Appliquer la configuration de Calico (sur `192.168.0.5`)
````
kubectl apply -f calico.yaml
````



`- 3.6` Faire rentrer les workers dans le cluster (sur 192.168.0.6 / 192.168.0.7)
````
sudo kubeadm join 192.168.0.15:6443 --token 7qxayn.gz8u4n139tqc0uvm \
        --discovery-token-ca-cert-hash sha256:1de1d2f9bce63e0c23b8fc870a15acc046242dcb1a7ffa10dad823cfc10f9435
````

`- 3.7` Faire entrer les autre master dans le cluster (sur 192.168.0.8 / 192.168.0.9)
````
sudo kubeadm join 192.168.0.15:6443 --token 7qxayn.gz8u4n139tqc0uvm \
        --discovery-token-ca-cert-hash sha256:1de1d2f9bce63e0c23b8fc870a15acc046242dcb1a7ffa10dad823cfc10f9435 \
        --control-plane \
        --certificate-key <`- 3.3` Initialisation Certificats pour le cluster>
````

`- 3.8` vérif depuis n'import quel master
````
kubectl get nodes
 
# Sortie attendue
NAME            STATUS   ROLES           AGE   VERSION
k8s-master      Ready    control-plane   ...   v1.36.4
k8s-master-2    Ready    control-plane   ...   v1.36.4
k8s-master-3    Ready    control-plane   ...   v1.36.4
k8s-worker1     Ready    <none>          ...   v1.36.4
k8s-worker2     Ready    <none>          ...   v1.36.4
````
 

---

- Et pour finir l'installation à réaliser sur les 3 VM :
````
vim $HOME/.bashrc
````
````
# === Kubernetes ===
alias k=kubectl
source <(kubectl completion bash)
complete -o default -F __start_kubectl k
````
````
source ~/.bashrc
````

### ⚠️ les commandes ci-dessus sont les premières à réaliser le jour de l'examen ⚠️

</details>
