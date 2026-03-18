Tâches
1. Monte l'ISO sur /mnt/iso de façon persistante (survit au reboot)
2. Désactive tous les repos existants sans les supprimer
3. Crée un fichier /etc/yum.repos.d/exam.repo contenant deux sections BaseOS et AppStream pointant vers l'ISO, avec vérification GPG activée
4. Importe la clé GPG depuis l'ISO
5. Vérifie que les deux repos sont bien détectés par DNF
6. Installe le paquet ftp uniquement depuis tes repos locaux
7. Vérifie que ftp est bien installé et identifie quel fichier binaire il a installé
8. Vérifie l'intégrité des fichiers installés par ftp
