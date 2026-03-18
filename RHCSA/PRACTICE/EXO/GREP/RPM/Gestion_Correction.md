# Correction — Gestion des dépôts RPM (RHCSA)

## 1. Monter l'ISO

```bash
mkdir /mnt/iso
mount /dev/sr0 /mnt/iso
```

## 2. Désactiver les repos existants

```bash
sudo dnf config-manager --disable "*"
```

## 3. Créer le fichier de dépôt

```bash
sudo tee /etc/yum.repos.d/exam.repo << EOF
[BaseOS]
name=BaseOS local
baseurl=file:///mnt/iso/BaseOS
enabled=1
gpgcheck=1
gpgkey=file:///mnt/iso/RPM-GPG-KEY-redhat-release

[AppStream]
name=AppStream local
baseurl=file:///mnt/iso/AppStream
enabled=1
gpgcheck=1
gpgkey=file:///mnt/iso/RPM-GPG-KEY-redhat-release
EOF
```

## 4. Importer la clé GPG

```bash
sudo rpm --import /mnt/iso/RPM-GPG-KEY-redhat-release
```

## 5. Vérifier les dépôts

```bash
dnf repolist
```

## 6. Installer un paquet depuis le dépôt local

```bash
sudo dnf install --disablerepo="*" --enablerepo="BaseOS,AppStream" ftp -y
```

## 7. Vérifier l'installation

```bash
rpm -qi ftp
rpm -ql ftp
rpm -qf /usr/bin/ftp
```

## 8. Vérifier l'intégrité

```bash
rpm -V ftp
```
