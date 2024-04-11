# JEU PERMANENT GCU 2024

### POWERED BY: 
Baden Powell Belgian Lonescouts - Commission jeu permanent GCU 2024

### SOME INFO :

Le Jeu permanent du GCU 2024 est un jeu de stratégie qui se déroule sur une carte fictive matérialisée par une grande table en bois. Les règles du jeu seront complètement décrites dans un document PDF annexe à ce code.

Le jeu est relativement complexe et il est physiquement compliqué de représenter toutes les données en temps réel sur le plateau. Il a donc été décidé de stocker l'ensemble des informations du jeu dans un logiciel, afin de :

- Simplifier l'exécution des différents tours en automatisant la plupart des actions ;
- Permettre aux joueurs d'accéder plus rapidement et de manière plus claire aux informations du jeu.

Ce logiciel est codé en `Julia` (extension .jl) et l'interface utilisée est un notebook `Pluto` (il s'agit du document que vous êtes en train de lire). Un tutoriel pour installer tout le nécessaire pour faire tourner le code sera présenté dans un document PDF annexe.

Ce notebook `Pluto` est structuré de sorte à faciliter la compréhension des administrateurs du jeu (chefs et Staff des Troupes). Il est divisé en 2 grandes parties :

- **La partie A** : Dans cette partie, toutes les structures et fonctions du jeu sont présentées. Chaque fonction est accompagnée d'un paragraphe - encadré dans un box grisâtre - qui décrit son fonctionnement. Pour accéder au code des fonctions, l'utilisateur doit cliquer sur l'icône d'œil qui se présente en haut à gauche de la box grisâtre qui décrit la fonction.

- **La partie B** : Dans cette partie, l'interface du jeu est disposée.

**REMARQUE** : Il est vivement déconseillé de modifier quoi que ce soit dans la partie A, sous risque de modifier le fonctionnement du jeu. Lors du déroulement du jeu, seule la partie B doit être modifiée.
