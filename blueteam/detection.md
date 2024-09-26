# Détection sur Wazuh :
![Alt text](img/premierscanagressif.png)

Après le scan on remarque 9 alertes.

![Alt text](<img/résultat dupremierscan .png>)
Je supprime les faux positifs 

![Alt text](img/filtresortdesfauxpostifis.png)

Je spécifie les 2 rule.id qui me géne car rapidement le serveur se remplie de connexion Windows inutiles


![Alt text](img/fullrequest.png)


Sur le scan 

    nmap -A <ip>

On remarque des informations SQL ,je suppose que pour générer cette réponse il doit causer des erreurs SQL
![Alt text](img/mysqlscan1.png)
Sur le SIEM, on remarque une erreur SQL qui correspond à la bonne heure.
![Alt text](img/sourceattaque1.png)


Je relance un scan "namp" -A pour regarder les changements.

![s](img/secondnmap-a.png)

Il créé une erreur windows


Je lance des scans smb 

![Alt text](img/cmehostrep.png)


On remarque rapidement les alertes : 

![Alt text](img/r%C3%A9ponsecmew.png)

En cherchant sur le site  : T1078
https://attack.mitre.org/techniques/T1078/


Les adversaires peuvent 
obtenir et abuser des informations d'identification des comptes existants afin d'obtenir un accès initial. 
l'accès initial, la persistance, l'escalade des privilèges ou l'évasion de la défense. 
Les informations d'identification compromises peuvent être utilisées pour contourner les contrôles d'accès placés sur 
diverses ressources sur les systèmes au sein du réseau et peuvent même être utilisées pour
 pour accéder de manière persistante à des systèmes distants et à des services disponibles à l'extérieur, 
tels que les VPN, Outlook Web Access, les périphériques réseau et le bureau à distance.
 Les informations d'identification compromises peuvent également accorder à un adversaire des privilèges accrus
 à des systèmes spécifiques ou l'accès à des zones restreintes du réseau. 
Les adversaires peuvent choisir de ne pas utiliser de logiciels malveillants ou d'outils en conjonction avec l'accès légitime à ces informations d'identification. 
l'accès légitime fourni par ces identifiants afin de rendre plus difficile la 
difficile de détecter leur présence.
Dans certains cas, les adversaires peuvent abuser 
comptes inactifs : par exemple, ceux qui appartiennent à des personnes qui ne font plus partie d'une organisation. 
qui ne font plus partie d'une organisation. L'utilisation de ces comptes peut permettre à l'adversaire 
d'échapper à la détection, car l'utilisateur du compte d'origine ne sera pas 
pour identifier toute activité anormale se déroulant sur son compte. 

En cherchant sur le site :T1531 https://attack.mitre.org/techniques/T1531/

Les adversaires peuvent interrompre la disponibilité des ressources du système et du réseau en empêchant l'accès aux comptes utilisés par des utilisateurs légitimes. Les comptes peuvent être supprimés, verrouillés ou manipulés (ex : modification des informations d'identification) afin d'en supprimer l'accès. Les adversaires peuvent également se déconnecter et/ou procéder à un arrêt/redémarrage du système pour mettre en place les changements malveillants.

Sous Windows, les utilitaires Net, Set-LocalUser et Set-ADAccountPassword PowerShell cmdlets peuvent être utilisés par des adversaires pour modifier des comptes d'utilisateurs. Sous Linux, l'utilitaire passwd peut être utilisé pour modifier les mots de passe. Les comptes peuvent également être désactivés par la stratégie de groupe.

Les adversaires qui utilisent des ransomwares ou des attaques similaires peuvent d'abord effectuer ce comportement et d'autres comportements d'impact, tels que la destruction de données et la défiguration, afin d'entraver la réponse à l'incident/la récupération avant de réaliser l'objectif Données chiffrées pour l'impact.



### Notre interpreation : 

![Alt text](img/compr%C3%A9hension.png)

On remarque que le packet utilisé pour l'authentification est NTML, il est posstible que le packet crackmapexec utilise une sorte de brute force NTLM pour afficher des informations sur le système. Il doit surrement utiliser les réponse de l'utilisateur.


Je passe par Wireshark pour mieux comprendre : 

![Alt text](img/wireshark.png)


Voici les paquets émis par ma machine au déclenchement de ma carte réseau

Je remarque du TCP, j'essaye de suivre les flux TCP 



![Alt text](img/followtcpstrem.png)


Je remarque qu'il parle de smb (en rapport avec l'énumération du partage smb ) et de NTLM (0.12. Un version ? )
Hypothése du fonctionnement de l'attaque 
Je remarque toute fois que la machine (kali linux ) initie une connexion TCP SYN, le ACK l'autorise mais une fois autorisé, il essaye de produire une modification smb qui ne passe pas et la machine castelblack(.176) réinitialise la connexion.

![Alt text](img/sessionwire.png)

Contrairement à l'hypostèse on peut retracer les actions qui sont effectuées en rapport avec les partages SMB sont présentes.

![Alt text](img/smbecahnge.png)

On remarque une tentative de session avec de la communication NTLM pour les partages smb, l'utilisateur qui semble se connecter est User: \, la réponse est une erreur coté client à cause d'aucun utilisateur ou de mot de passe (INVALID PARAMETER)


![Alt text](img/ntlm.png)

On remarque la précense du NTLM.


La capture Wireshark est sur github : cme.pcacng

Les filtres utilisés sont mon IP souce,l'Ip de destination et les séquence TCP: 10.202.0.130 
ip.src==10.202.0.130
ip.dest=10.202.0.176
tcp.stream.eq 5
tcp.stream.eq 0

Une autre attaque  :  Kerberoasting
 


J'utilise les identifiants récupérés dans la partie pentesdugoad pour faire mon attaque 

    cme ldap 10.202.0.150 -u brandon.stark -p 'iseedeadpeople' -d north.sevenkingdoms.local --kerberoasting KERBEROASTING


![Alt text](img/kerberoasting.png)

Je récupére les hashs du compte sql_svc et jon.snow grâce à cette attaque, dans mon cas ils sont dans le fichier hash.

Nous allons détecter l'attaque sur Wazuh : 


![Alt text](img/attackkerbdetectiononwazuh.png)


Avec l'information des connexions valides :

![Alt text](img/logonsuccestulker.png)



![Alt text](img/ntlmv2.png)

On rermarque l'utilisation du compte brandon.stark


Les règles Mittre utilisé  :T1550.002, T1078.002


# Détection sur Splunk 

Voici la détection d'un crackmap exec sur les machines du domaine.

![Alt text](img/detectioncmesplunl.png)

On remarque la source en 10.202.0.130 (Ip du Kali linux)
On remarque des informations identiques à Wazuh, l'utilisation de NTLM et la connexion en anonyme.

J'utilise les logs Active Directory : 


![Alt text](img/Typedelogsursplunk.png)

Je réalise plusieur enum4linux pour énumérer l'AD de manière anonyme.

Aucune détection n'est présente dans le SIEMs
![Alt text](img/activedirectorynonfonctionnel.png)

Les attaques sont détectés sur Splunk.

<br><br>

# Detection des attaques avec Elatsicsearch :

<br>

#### Afin d'analyser les logs des attaques nous allons expliquer la démarche que nous avons suivis pour une alerte de sécurité remontée par un agents Elatsic.

Voici l'alerte en détail :

![Alt text](img/elastic-log-attaque.png)

Tout d'abord nous pouvons nous servir de l'identification de l'attaque via MITRE ATT&CK qui ici indique une attaque d'escalade de privilèges (TA0004) avec une manipulation de token d'accès (T1134) et ensuite une création de processus avec ce token (T1134.002). Avec ces informations nous pouvons nous rendre sur le site [MITRE ATT&CK](https://attack.mitre.org/) afin de connaitre plus de détails à propos de l'attaque, ses objectifs et sa source.

<br> 

Ensuite pour comprendre le déroulement de l'attaque et pouvoir corriger la faille si possible nous allons nous servir de **"Alert reason"** :

<br> 

Nous apprenons ici qu'un processus a été créé avec le script WmiPrvSE.exe avec l'utilisateur SYSTEM (droit administrateur local) sur l'utilisateur "castelblack". Cela a créé une alerte de haut niveau.
Nous apprenons aussi que le script se situe dans *C:\Windows\system32\wbem\wmiprvse.exe*, nous voyons aussi le token manipulé et le numéro du peocessus (7192).
