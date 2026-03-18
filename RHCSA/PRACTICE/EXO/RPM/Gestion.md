Tâches

1. Désactive tous les repos existants sans les supprimer
2. Crée un fichier /etc/yum.repos.d/exam.repo contenant deux sections BaseOS et AppStream pointant vers l'ISO, avec vérification GPG activée
3. Importe la clé GPG depuis l'ISO
4. Vérifie que les deux repos sont bien détectés par DNF
5. Installe le paquet ftp uniquement depuis tes repos locaux
6. Vérifie que ftp est bien installé et identifie quel fichier binaire il a installé
7. Vérifie l'intégrité des fichiers installés par ftp
