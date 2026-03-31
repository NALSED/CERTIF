# Exercice de Sander Van Vugt

---

1) Installer `git`
```
sudo dnf -y install git
```


2) Cloner le repo
```
git clone https://github.com/sandervanvugt/rhcsa
```


3) Lancer le processus Zombie :
```
# Dans le dossier rhcsa
./zombie &
```


4) Les processus Zombie sont définie par l'adjectif `defunct`, on le recherche avec `ps` et `grep`
```
ps aux | grep "defunct"
ou
pas aux | grep "Z"

# Sortie
sednal   4523  0.0  0.0      0     0 pts/0        Z    16:40   0:00 [zombie] <defunct>
```

- Faire un `kill 4523` ou  `kill 9 4523`, ne fonctionne pas on le peux pas tuer un zombie.


5) Il faut trouver le processus parent
```
ps fax | less
```

- Ici Parent process : 4519 et Child process : 4523

6) Utiliser le signal `SIGCHLD` sur le process parent
```
kill SIGCHLD 4519
kill 4519
```

7) Maintenant la commande `ps` pour chercher le zombie nous montre qu'il à dispar
```
ps aux | grep "defunct"
```







 
