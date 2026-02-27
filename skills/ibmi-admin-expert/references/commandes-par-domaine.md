# Aide-memoire des commandes IBM i par domaine fonctionnel

Reference rapide des commandes les plus utilisees, classees par domaine d'administration.
Pour la liste COMPLETE des 2399 commandes systeme, consulter `references/commandes-ibmi-reference.md`.

## Gestion des sous-systemes

| Commande | Description |
|----------|-------------|
| CRTSBSD | Créer description sous-système |
| DSPSBSD | Afficher descr de sous-système |
| WRKSBS | Gérer les sous-systèmes |
| STRSBS | Démarrer un sous-système |
| ENDSBS | Arrêter un sous-système |
| CHGSBSD | Modifier descr de sous-système |
| DLTSBSD | Supprimer desc de sous-système |
| ADDAJE | Ajouter poste travail auto |
| CHGAJE | Modifier poste travail auto |
| RMVAJE | Enlever poste travail auto |
| ADDRTGE | Ajouter un poste de routage |
| RMVRTGE | Enlever un poste de routage |
| ADDJOBQE | Ajouter poste file de travaux |
| RMVJOBQE | Enlever poste file de travaux |
| CHGJOBQE | Modifier poste file de travaux |
| ADDWSE | Ajouter poste écran à s-syst |
| RMVWSE | Enlever un poste écran |
| ADDCMNE | Ajouter poste communications |
| RMVCMNE | Enlever poste communications |
| ADDPJE | Ajouter poste trav anticipés |

## Gestion des travaux (jobs)

| Commande | Description |
|----------|-------------|
| WRKACTJOB | Gérer les travaux actifs |
| WRKJOB | Gérer un travail |
| WRKSBMJOB | Gérer les travaux soumis |
| WRKSBSJOB | Gérer travaux de sous-systèmes |
| DSPJOB | Afficher l'état d'un travail |
| DSPJOBLOG | Afficher historique du travail |
| SBMJOB | Soumettre un travail |
| HLDJOB | Suspendre un travail |
| RLSJOB | Libérer un travail |
| ENDJOB | Arrêter un travail |
| CHGJOB | Modifier un travail |
| TFRBCHJOB | Transférer un travail par lots |
| TFRJOB | Transférer un travail |
| CRTJOBQ | Créer une file de travaux |
| CHGJOBQ | Modifier file de travaux |
| DLTJOBQ | Supprimer une file de travaux |
| WRKJOBQ | Gérer les files de travaux |
| DSPJOBQ | — |
| HLDJOBQ | Suspendre une file de travaux |
| RLSJOBQ | Libérer une file de travaux |
| CLRJOBQ | Mettre à blanc file de travaux |
| CRTJOBD | Créer description de travail |
| CHGJOBD | Modifier description travail |
| DLTJOBD | Supprimer description travail |
| DSPJOBD | Afficher description travail |
| WRKJOBD | Gérer descriptions de travail |
| CRTCLS | Créer une classe |
| CHGCLS | Modifier une classe |
| DLTCLS | Supprimer une classe |
| DSPCLS | Afficher une classe |
| WRKCLS | Gérer les classes |
| ADDSCDE | — |
| CHGSCDE | — |
| RMVSCDE | — |
| WRKJOBSCDE | Gérer postes planning travaux |

## Gestion des profils utilisateurs

| Commande | Description |
|----------|-------------|
| CRTUSRPRF | Créer un profil utilisateur |
| CHGUSRPRF | Modifier un profil utilisateur |
| DLTUSRPRF | Supprimer profil utilisateur |
| DSPUSRPRF | Afficher un profil utilisateur |
| WRKUSRPRF | Gérer les profils utilisateur |
| CHGPWD | Modifier son mot de passe |
| DSPACTPRFL | Afficher liste profils actifs |
| CHGACTPRFL | Modifier liste profils actifs |
| CHGACTSCDE | Modifier planning activation |
| GRTUSRAUT | Accorder droits d'un utilisat |
| RSTAUT | Restaurer les droits |
| DSPAUTUSR | Afficher utilisat autorisés |
| PRTUSRPRF | Imprimer profils utilisateur |
| PRTSYSINF | Imprimer informations système |

## Securite et autorisations

| Commande | Description |
|----------|-------------|
| GRTOBJAUT | Accorder droits sur un objet |
| RVKOBJAUT | Révoquer droits sur un objet |
| DSPOBJAUT | Afficher droits sur objet |
| EDTOBJAUT | Réviser droits sur un objet |
| CHKOBJITG | Vérifier intégrité des objets |
| CRTAUTL | Créer une liste d'autorisation |
| DLTAUTL | Supprimer liste d'autorisation |
| DSPAUTL | Afficher liste d'autorisation |
| EDTAUTL | Réviser liste d'autorisation |
| WRKAUTL | Gérer listes d'autorisation |
| ADDAUTLE | Ajouter poste liste autorisat |
| RMVAUTLE | Enlever poste liste autorisat |
| CRTAUTHLR | Créer un dépositaire de droits |
| DLTAUTHLR | Supprimer dépositaire de droit |
| DSPAUTHLR | Afficher dépositaires droits |
| GRTACCAUT | Accorder droits/codes d'accès |
| RVKACCAUT | Révoquer droits/codes d'accès |
| DSPACCAUT | Afficher droits/codes d'accès |
| PRTADPOBJ | Imprimer objets adoptant |
| PRTCMNSEC | Imprimer sécurité communicat |
| PRTPVTAUT | Imprimer droits privés |
| PRTPUBAUT | Imprimer objets droits publics |
| PRTSYSSECA | Imprimer attributs de sécurité |
| CHKOBJ | Vérifier existence d'un objet |
| CHKOBJITG | Vérifier intégrité des objets |
| WRKREGINF | Work with Registration Info |

## Bibliotheques et Library List

| Commande | Description |
|----------|-------------|
| CRTLIB | Créer une bibliothèque |
| DLTLIB | Supprimer une bibliothèque |
| CLRLIB | Mettre à blanc bibliothèque |
| DSPLIB | Afficher une bibliothèque |
| DSPLIBL | Afficher liste bibliothèques |
| WRKLIB | Gérer les bibliothèques |
| WRKLIBPDM | Gérer bibliothèques avec PDM |
| ADDLIBLE | Ajouter poste liste biblio |
| RMVLIBLE | Enlever poste de liste biblio |
| EDTLIBL | Réviser liste bibliothèques |
| CHGCURLIB | Modifier bibliothèque en cours |
| CHGSYSLIBL | Modifier liste biblio système |
| WRKOBJ | Gérer les objets |
| DSPOBJ | — |
| DSPOBJD | Afficher description d'objet |
| MOVOBJ | Déplacer un objet |
| RNMOBJ | Rebaptiser un objet |
| CRTDUPOBJ | Créer un objet dupliqué |
| WRKOBJPDM | Gérer les objets avec PDM |
| WRKOBJLCK | Gérer verrouillages d'objet |
| ALCOBJ | Allouer un objet |
| DLCOBJ | Désallouer un objet |
| CHKOBJITG | Vérifier intégrité des objets |

## Fichiers base de donnees

| Commande | Description |
|----------|-------------|
| CRTPF | Créer un fichier physique |
| CRTLF | Créer un fichier logique |
| CRTSRCPF | Créer un fichier source |
| CHGPF | Modifier un fichier physique |
| CHGLF | Modifier un fichier logique |
| DLTF | Supprimer un fichier |
| DSPFD | Afficher description fichier |
| DSPFFD | Afficher description des zones |
| DSPDBR | Afficher relations BD |
| DSPDB | — |
| WRKF | Gérer les fichiers |
| WRKMBR | — |
| WRKMBRPDM | Gérer les membres avec PDM |
| RGZPFM | Réorganiser membre fich phys |
| CMPPFM | Comparer membre fich physique |
| CPYF | Copier un fichier |
| CLRPFM | Mettre à blanc membre fichier |
| ADDPFM | Ajouter membre à fich physique |
| RMVM | Enlever un membre |
| RNMM | Rebaptiser un membre |
| ADDPFCST | Ajouter contrainte fich phys |
| RMVPFCST | Enlever contrainte fich phys |
| CHGPFCST | Modifier contrainte fich phys |
| DSPPFM | Afficher membre fich physique |
| ADDPFTRG | Add Physical File Trigger |
| RMVPFTRG | Enlever déclencheur fichier |
| DSPFD | Afficher description fichier |
| OVRDBF | Substituer un fichier BD |
| OPNDBF | Ouvrir fichier base de données |
| OPNQRYF | Ouvrir un fichier de requête |
| RUNQRY | Lancer une analyse |
| ANZDBF | Analyze Database Files |
| RCLDBXREF | Récupérer réf croisée BD |

## Messages et files de messages

| Commande | Description |
|----------|-------------|
| SNDMSG | Envoyer un message |
| SNDBRKMSG | Envoyer message d'interruption |
| SNDPGMMSG | Envoyer un message programme |
| SNDUSRMSG | Envoyer un message utilisateur |
| SNDNETMSG | Envoyer un message au réseau |
| DSPMSG | Afficher les messages |
| RCVMSG | Recevoir un message |
| MONMSG | Intercepter message |
| RPLMSG | — |
| CRTMSGQ | Créer une file de messages |
| CHGMSGQ | Modifier une file de messages |
| DLTMSGQ | Supprimer une file de messages |
| WRKMSGQ | Gérer les files de messages |
| CLRMSGQ | Mettre à blanc file de message |
| CRTMSGF | Créer un fichier message |
| CHGMSGF | Modifier fichier message |
| DLTMSGF | Supprimer fichier message |
| DSPMSGD | Afficher description message |
| WRKMSGD | Gérer descriptions de messages |
| ADDMSGD | Ajouter description de message |
| CHGMSGD | Modifier description message |
| RMVMSGD | Enlever description de message |
| MRGMSGF | Fusionner fichiers message |

## Impressions, spools et files de sortie

| Commande | Description |
|----------|-------------|
| WRKSPLF | Gérer les fichiers spoule |
| CHGSPLFA | Modifier attributs fich spoule |
| DLTSPLF | Supprimer un fichier spoule |
| DSPSPLF | Afficher un fichier spoule |
| CPYSPLF | Copier un fichier spoule |
| SNDSPLF | — |
| CRTOUTQ | Créer une file de sortie |
| CHGOUTQ | Modifier une file de sortie |
| DLTOUTQ | Supprimer une file de sortie |
| WRKOUTQ | Gérer les files de sortie |
| CLROUTQ | Mettre à blanc file de sortie |
| HLDOUTQ | Suspendre une file de sortie |
| RLSOUTQ | Libérer une file de sortie |
| STRPRTWTR | Démarrer un éditeur imprimante |
| ENDWTR | Arrêter un éditeur de spoule |
| HLDWTR | Suspendre un éditeur de spoule |
| CHGWTR | Modifier un éditeur de spoule |
| WRKWTR | Gérer les éditeurs de spoule |
| CRTPRTF | Créer un fichier imprimante |
| CHGPRTF | Modifier un fichier imprimante |
| OVRPRTF | Substituer fichier imprimante |
| CRTDEVPRT | Créer une unité imprimante |
| CHGDEVPRT | Modifier une unité imprimante |
| VRYCFG | Changer état configuration |

## Sauvegarde et restauration

| Commande | Description |
|----------|-------------|
| SAVLIB | Sauvegarder bibliothèque |
| SAVOBJ | Sauvegarder objet |
| SAVCHGOBJ | Sauvegarder objets modifiés |
| SAVSYS | Sauvegarder le système |
| SAVSECDTA | Sauvegarder données sécurité |
| SAVCFG | Sauvegarder la configuration |
| SAVSTG | — |
| SAV | Sauvegarder objet |
| SAVDLO | Sauvegarder doc ou dossier |
| SAVLICPGM | Sauvegarder logiciel s/licence |
| SAVRSTLIB | SAVE RESTORE LIBRARY |
| SAVRSTCHG | SAVE RESTORE CHANGED OBJECTS |
| SAVRSTOBJ | SAVE RESTORE OBJECT |
| RSTLIB | Restaurer bibliothèque |
| RSTOBJ | Restaurer objet |
| RST | Restaurer objet |
| RSTDLO | Restaurer document ou dossier |
| RSTAUT | Restaurer les droits |
| RSTCFG | Restaurer configuration |
| RSTSECDTA | — |
| CRTIMGCLG | Créer catalogue images CD-ROM |
| ADDIMGCLGE | Ajouter poste catalogue images |
| WRKIMGCLGE | Gérer les postes de catalogue |
| VFYIMGCLG | Vérifier catalogue d'images |
| LODIMGCLGE | Charg/déchar/mont poste IMGCLG |
| DSPTAP | Afficher contenu d'une bande |
| CHKTAP | Vérifier existence sur bande |
| INZTAP | Initialiser une bande |
| DUPTAP | Dupliquer une bande |
| RUNBCKUP | Lancer la sauvegarde |
| RTVBCKUP | Extraire options de sauvegarde |
| STRMNTBRM | Start Maintenance for BRM |
| WRKMEDBRM | Work with Media using BRM |
| WRKPCYBRM | Work with Policies using BRM |

## TCP/IP et reseau

| Commande | Description |
|----------|-------------|
| STRTCP | Start TCP/IP |
| ENDTCP | End TCP/IP |
| CFGTCP | Configure TCP/IP |
| WRKTCPSTS | Work with TCP/IP Network Sts |
| ADDTCPIFC | Add TCP/IP Interface |
| CHGTCPIFC | Change TCP/IP Interface |
| RMVTCPIFC | Remove TCP/IP Interface |
| DSPTCPIFC | — |
| ADDTCPRTE | Add TCP/IP Route |
| CHGTCPRTE | Change TCP/IP Route |
| RMVTCPRTE | Remove TCP/IP Route |
| DSPTCPRTE | — |
| ADDTCPPORT | Add TCP/IP Port Restriction |
| CHGTCPPORT | — |
| RMVTCPPORT | Remove TCP/IP Port Restriction |
| STRHOSTSVR | Démarrer serveur hôte |
| ENDHOSTSVR | Arrêter serveur hôte |
| CHGHOSTSVR | — |
| STRSVR | — |
| ENDSVR | — |
| STRTCPSVR | Start TCP/IP Server |
| ENDTCPSVR | End TCP/IP Server |
| CHGTCPSVR | Change TCP/IP Server |
| STRTCPFTP | Start TCP/IP File Transfer |
| ENDTCPFTP | — |
| PING | Verify TCP/IP Connection |
| TRACERT | — |
| NETSTAT | Work with TCP/IP Network Sts |
| CFGIPSEC | — |
| WRKLNK | Work with Object Links |

## Journalisation et audit

| Commande | Description |
|----------|-------------|
| CRTJRN | Créer un journal |
| DLTJRN | Supprimer un journal |
| WRKJRN | Gérer la journalisation |
| CHGJRN | Modifier un journal |
| DSPJRN | Afficher un journal |
| CRTJRNRCV | Créer un récepteur de journal |
| DLTJRNRCV | Supprimer récepteur de journal |
| DSPJRNRCVA | Afficher attributs récepteur |
| CHGJRNRCV | — |
| STRJRNPF | Démarrer journalisation fich |
| ENDJRNPF | Arrêter fich physique journal |
| STRJRNOBJ | Démarrer journalisation objet |
| ENDJRNOBJ | Arrêter journalisation objet |
| STRJRNAP | Démarrer journalisation chemin |
| ENDJRNAP | Arrêter journalisation chemin |
| RCVJRNE | Recevoir un poste de journal |
| DSPJRNE | — |
| CPYAUDJRNE | Copier postes journal d'audit |
| CMPJRNIMG | Comparer des images de journal |
| CHGAUD | Modifier la valeur d'audit |
| DSPAUD | — |

## PTF et maintenance systeme

| Commande | Description |
|----------|-------------|
| DSPPTF | Afficher les PTF |
| INSPTF | Installer des PTF |
| DLTPTF | Supprimer une PTF |
| WRKPTFGRP | Gérer les groupes de PTF |
| CPYPTF | Copier des PTF |
| SNDPTFORD | Envoyer une demande de PTF |
| STRSST | Start System Service Tools |
| STRDST | — |
| PWRDWNSYS | Mettre le système hors tension |
| WRKSYSSTS | Gérer l'état du système |
| DSPSYSVAL | Afficher une valeur système |
| CHGSYSVAL | Modifier une valeur système |
| WRKSYSVAL | Gérer les valeurs système |
| DSPSYSSTS | Afficher l'état du système |
| DSPSTGSTS | — |
| CRTLICPGM | — |
| DLTLICPGM | Supprimer logiciel ss/licence |
| DSPLICINF | — |
| RSTLICPGM | Restaurer logiciel ss/licence |
| WRKLICKEY | — |
| CLNUP | — |
| RCLSTG | Récupérer mémoire secondaire |
| RCLTMPSTG | Récupérer mémoire temporaire |
| RCLSPLSTG | Récupérer mémoire du spoule |
| DSPLOG | Afficher historique du système |
| DSPJOBLOG | Afficher historique du travail |

## Programmation et compilation

| Commande | Description |
|----------|-------------|
| CRTRPGMOD | Créer un module RPG |
| CRTBNDRPG | Créer un programme RPG lié |
| CRTSQLRPGI | Créer un objet RPG ILE SQL |
| CRTRPGPGM | Créer un programme RPG/400 |
| CRTCMOD | Create C Module |
| CRTBNDC | Create Bound C Program |
| CRTSQLCI | Créer un objet C ILE SQL |
| CRTCBLMOD | Créer un module COBOL |
| CRTBNDCBL | Créer un programme COBOL lié |
| CRTSQLCBLI | Créer un objet COBOL ILE SQL |
| CRTCLMOD | Create CL Module |
| CRTBNDCL | Create Bound CL Program |
| CRTCLPGM | Créer un programme CL |
| CRTSRVPGM | Créer un programme de service |
| CRTPGM | Créer un programme |
| UPDPGM | Mettre à jour un programme |
| UPDSRVPGM | Mettre à jour pgm de service |
| CRTBNDDIR | Créer un répertoire de liage |
| ADDBNDDIRE | Ajouter poste répertoire liage |
| RMVBNDDIRE | Enlever poste répertoire liage |
| DSPBNDDIR | Afficher répertoire de liage |
| CRTCMD | Create Command |
| CHGCMD | Modifier une commande |
| DLTCMD | Supprimer une commande |
| SLTCMD | Choix d'une commande |
| CRTPNLGRP | Créer un groupe de panneaux |
| CRTMNU | Créer un menu |
| CRTDSPF | Créer un fichier écran |
| CRTPRTF | Créer un fichier imprimante |
| STRDBG | Démarrer le débogage |
| ENDDBG | Arrêter le mode débogage |
| STRPDM | Démarrer PDM |
| STRSEU | Démarrer Editeur de source |
| STRSDA | Démarrer SDA |
| STRDFU | Démarrer DFU |

## IFS et systeme de fichiers integre

| Commande | Description |
|----------|-------------|
| WRKLNK | Work with Object Links |
| DSPLNK | Display Object Links |
| CHGAUT | Modifier les droits |
| DSPAUT | Afficher les droits |
| CHGOWN | Modifier le propriétaire |
| CHGPGP | Modifier le groupe principal |
| CPYFRMSTMF | Copier depuis fichier STREAM |
| CPYTOSTMF | Copier dans fichier STREAM |
| CPY | Copier un objet |
| MOV | Déplacer un objet |
| CRTDIR | Créer un répertoire |
| RMVDIR | Enlever un répertoire |
| RMVLNK | Enlever un lien |
| RCLSTG | Récupérer mémoire secondaire |
| QSH | Start QSH |
| STRQSH | Start QSH |
| WRKDLO | — |
| DSPDLONAM | Afficher nom doc ou dossier |

## Configuration materielle

| Commande | Description |
|----------|-------------|
| WRKHDWRSC | Gérer les ressources matériel |
| WRKCFGSTS | Gérer état de la configuration |
| VRYCFG | Changer état configuration |
| CRTCTLD | — |
| CHGCTLD | — |
| DLTCTLD | Supprimer descr de contrôleur |
| DSPCTLD | Afficher descr de contrôleur |
| CRTDEVD | — |
| CHGDEVD | — |
| DLTDEVD | Supprimer description d'unité |
| DSPDEVD | Description d'unité |
| WRKDEVD | Gérer descriptions d'unités |
| CRTLINETH | Créer une ligne Ethernet |
| CHGLINETH | Modifier une ligne Ethernet |
| DLTLIND | Supprimer description de ligne |
| DSPLIND | Afficher description de ligne |
| CRTNWSD | Créer desc de serveur réseau |
| CHGNWSD | Modifier desc serveur réseau |
| DLTNWSD | Supprimer desc serveur réseau |
| DSPNWSD | Description serveur de réseau |
| CRTDEVASP | Créer desc unité (ASP) |
| CFGDEVASP | Configurer ASP unité |
| CHGDEVASP | Modifier desc unité (ASP) |
| DLTDEVASP | — |
| WRKDSKSTS | Gérer l'état des disques |
| WRKASPBRM | Work with ASP Descriptions |
| SETASPGRP | Définir groupe ASP |

## Data areas, data queues et espaces utilisateur

| Commande | Description |
|----------|-------------|
| CRTDTAARA | Créer une zone de données |
| CHGDTAARA | Modifier une zone de données |
| DLTDTAARA | Supprimer une zone de données |
| DSPDTAARA | Afficher une zone de données |
| RTVDTAARA | Extraire une zone de données |
| CRTDTAQ | Créer une file de données |
| DLTDTAQ | Supprimer une file de données |
| DSPDTAQ | — |
| WRKDTAQ | Gérer les files de données |
| CRTUSRSPC | — |
| DLTUSRSPC | Delete User Space |
| DSPUSRSPC | — |
| CRTUSRIDX | — |
| DLTUSRIDX | Delete User Index |
| CRTUSRQ | — |
| DLTUSRQ | Delete User Queue |
