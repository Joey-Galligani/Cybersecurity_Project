#!/bin/bash
##-------------------------------------------------------------------------------------------------------------------------------------
## Installation automatisé du GOAD sur virtualbox 
##-------------------------------------------------------------------------------------------------------------------------------------
# Cloner le dépôt Git
git clone https://github.com/Orange-Cyberdefense/GOAD

# Accéder au répertoire cloné
cd GOAD

# Exécuter la première commande
./goad.sh -t check -l GOAD -p virtualbox -m docker

# Exécuter la deuxième commande
./goad.sh -t install -l GOAD -p virtualbox -m docker  
