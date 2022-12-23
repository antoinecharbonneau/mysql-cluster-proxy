# Projet LOG8415e

Si toutes les data nodes sont up, mais pogné à starting:
Prob. un problème de security group, juste accepter le traffic sur le réseau local.

## Proxy

Deux socket, un qui reçoit, un qui refile en fonction du type de requête

Si la requête est un select, envoie la requête à un slave node, sinon envoie la requête au master node.

Pour authentifier le client, on simule l'authentification avec un des slave nodes.

Ensuite, pour les requêtes, on peut, au besoin, créer une connexion temporaires avec le master node.