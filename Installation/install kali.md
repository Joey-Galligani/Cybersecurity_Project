## Téléchargements de l'iso KaliLinux

### Configuration de Virtualbox : 

    10GB RAM, 50Go stockage, 3CPU
  
### Configuration de l'OS :

    setxkbmap fr 
### Configuration des utilisateurs 
    adduser joey
        pswd : joey
    adduser alexis 
        pswd : alexis 
    adduser ilker
        pswd : ilker

### Ajout des droits :
    
    sudo su
    nano /etc/sudoers
    -> %alexis  ALL=(ALL:ALL) ALL
    -> %joey    ALL=(ALL:ALL) ALL
    -> %ilker   ALL=(ALL:ALL) ALL

