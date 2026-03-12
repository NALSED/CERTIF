
# Réponses — Exercices `grep` RHCSA

---

## Niveau 1 — Fichiers système

1. Lignes non commentées de `sshd_config`
```bash
grep -v "^#" /etc/ssh/sshd_config
```

2. Lignes non vides et non commentées de `/etc/fstab`
```bash
grep -v "^#" /etc/fstab | grep -v "^$"
```

3. Shell de `root` dans `/etc/passwd`
```bash
grep "^root" /etc/passwd
```

4. Utilisateurs avec `/bin/bash`
```bash
grep "/bin/bash" /etc/passwd
```

5. Groupes contenant `wheel` dans `/etc/group`
```bash
grep "wheel" /etc/group
```

6. Lignes `NOPASSWD` dans `/etc/sudoers`
```bash
grep "NOPASSWD" /etc/sudoers
```

---

## Niveau 2 — Services & logs

7. Erreurs dans `/var/log/messages`
```bash
grep -i "error" /var/log/messages
```

8. Lignes `Failed` dans `/var/log/secure`
```bash
grep "Failed" /var/log/secure
```

9. Tentatives SSH échouées pour `root`
```bash
grep "Failed.*root" /var/log/secure
```

10. 2 lignes après chaque `ERROR`
```bash
grep -A 2 "ERROR" /tmp/serveurs.log
```

11. Compter les échecs d'authentification
```bash
grep -c "Failed" /var/log/secure
```

12. Port Apache dans `/etc/httpd/`
```bash
grep -r "Listen" /etc/httpd/
```

---

## Niveau 3 — Réseau & SELinux

13. Interfaces dans `network-scripts`
```bash
grep -l "DEVICE" /etc/sysconfig/network-scripts/ifcfg-*
```

14. `BOOTPROTO` dans tous les `ifcfg-*`
```bash
grep "BOOTPROTO" /etc/sysconfig/network-scripts/ifcfg-*
```

15. Règles firewalld contenant `ssh`
```bash
grep -r "ssh" /etc/firewalld/zones/
```

16. Mode SELinux
```bash
grep "enforcing" /etc/selinux/config
```

17. `denied` dans audit.log
```bash
grep -i "denied" /var/log/audit/audit.log
```

---

## Niveau 4 — Expressions régulières

18. Extraire les adresses IP
```bash
grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" /tmp/serveurs.log
```

19. Utilisateurs avec UID 1000–9999
```bash
grep -E "^[^:]+:[^:]+:[1-9][0-9]{3}:" /etc/passwd
```

20. Partitions `xfs` dans `/etc/fstab`
```bash
grep "xfs" /etc/fstab
```

21. `ERROR` ou `WARNING`
```bash
grep -E "ERROR|WARNING" /tmp/serveurs.log
```

22. Lignes actives de `/etc/hosts`
```bash
grep -v "^#" /etc/hosts | grep -v "^$"
```

---

## Niveau 5 — Redirections & pipelines

23. Sauvegarder les `ERROR`
```bash
grep "ERROR" /tmp/serveurs.log > /tmp/erreurs.txt
```

24. Supprimer stderr
```bash
grep "root" /etc/passwd 2>/dev/null
```

25. Afficher et sauvegarder avec `tee`
```bash
grep "ERROR" /tmp/serveurs.log | tee /tmp/erreurs_tee.txt
```

26. Compter les utilisateurs avec shell valide
```bash
grep -c "/bin/bash\|/bin/sh\|/bin/zsh" /etc/passwd
```

27. Paquets contenant `selinux`
```bash
rpm -qa | grep "selinux"
# ou
dnf list installed | grep "selinux"
```

---
---
