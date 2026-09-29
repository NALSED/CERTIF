## LABS

---

### === Consignes ===

<img width="785" height="158" alt="image" src="https://github.com/user-attachments/assets/791158d4-83de-4aaf-94ac-ac5508e6828a" />

---


- `role`
````
kubectl create role role-view -n default --verb=watch,list,get --resource=pods
````

- `rolebinding`

⚠️ LA COMMANDE SUIVANTE NE MARCHE PAS ⚠️
- En  effet `*` ne peux être utilisé que pour :
   - `verb`
   - `resources`
````
kubectl create rolebinding binding-role-view --role=role-view --user=*
````

- Afin de pourvoir cibler un groupe d'utilisateur / un mode d'authentification etc...
````
kubectl get clusterolebinding | grep user

# Sortie
system:basic-user ClusterRole/system:basic-user 10d
````

- 🟢 COMMANDE CORRECT 🟢
````
kubectl create rolebinding binding-role-view -n default \
--role=role-view \
--user=system:basic-user
````
