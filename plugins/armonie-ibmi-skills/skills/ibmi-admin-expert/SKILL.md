---
name: ibmi-admin-expert
description: Expert administration IBM i (AS/400). Couvre sous-systemes, JOBQ, JOBD, OUTQ, profils utilisateurs, bibliotheques, Library List, messages, spools, objets, surveillance, sauvegarde/restauration, TCP/IP, journalisation, PTF, securite, IFS. Reference de 2399 commandes QSYS. Use when user asks about IBM i administration, subsystem management, job queues, user profiles, spool management, message queues, library list, object security, backup/restore, TCP/IP, journaling, PTF, IFS, or any CL command. Triggers - sous-systeme, SBSD, JOBQ, JOBD, OUTQ, CRTUSRPRF, CRTSBSD, bibliotheque, LIBL, spool, WRKSPLF, WRKACTJOB, WRKSBS, DSPMSG, MSGQ, WRKOBJ, securite, IPL, SAVLIB, RSTLIB, TCP/IP, JRN, PTF, IFS, WRKLNK, commande CL, commande IBM i, QSYS, DSPSYSVAL, CHGSYSVAL. Do NOT use for RPG programming, SQL development, or webservices coding.
---

# IBM i Administration Expert - Exploitation et Administration Systeme

Skill de reference pour l'administration et l'exploitation du systeme IBM i (AS/400).
Base sur le livre "Exploitation IBM i" de Sylvain Aktepe (IBM Champion 2025, Notos/Armonie).
Enrichi avec la reference complete de 2399 commandes systeme issues de QSYS, QSYSV7R3M0 et QSYSV7R4M0.

## Instructions

### Etape 1 : Identifier le type de besoin

Analyser la demande et classifier :

| Type de besoin | Reference a lire EN PREMIER | Exemple de script |
|----------------|----------------------------|-------------------|
| Sous-systemes (creer, configurer, routage) | `references/sous-systemes.md` | `scripts/creer-sous-systeme.clle` |
| Job Queues (JOBQ) | `references/jobq-jobd.md` | `scripts/creer-sous-systeme.clle` |
| Job Descriptions (JOBD) | `references/jobq-jobd.md` | `scripts/creer-jobd-complete.clle` |
| Profils utilisateurs | `references/profils-utilisateurs.md` | `scripts/creer-utilisateur-metier.clle` |
| Bibliotheques et Library List | `references/bibliotheques.md` | `scripts/gestion-libl.clle` |
| Messages (MSGQ, SNDMSG, SNDBRKMSG) | `references/messages.md` | `scripts/gestion-messages.clle` |
| Impressions et spools (OUTQ, WRKSPLF) | `references/impressions-spools.md` | — |
| Objets (types, securite, commandes) | `references/objets-systeme.md` | — |
| Surveillance systeme (WRKACTJOB, WRKSBS) | `references/surveillance-systeme.md` | `scripts/surveillance-systeme.clle` |
| Architecture IBM i (MI, DB2, couches) | `references/architecture-ibmi.md` | — |
| Sauvegarde et restauration | `references/commandes-par-domaine.md` section Sauvegarde | — |
| TCP/IP et reseau | `references/commandes-par-domaine.md` section TCP/IP | — |
| Journalisation et audit | `references/commandes-par-domaine.md` section Journalisation | — |
| PTF et maintenance | `references/commandes-par-domaine.md` section PTF | — |
| IFS et systeme de fichiers | `references/commandes-par-domaine.md` section IFS | — |
| Configuration materielle | `references/commandes-par-domaine.md` section Configuration | — |
| Recherche d'une commande specifique | `references/commandes-ibmi-reference.md` | — |

### Etape 2 : Lire les references AVANT de repondre

CRITICAL: Toujours lire le guide de reference correspondant AVANT de generer des commandes ou des explications.
Si le besoin couvre plusieurs domaines (ex: creer un sous-systeme + JOBQ + JOBD + profil), lire TOUS les guides concernes.

Fichiers de reference disponibles :
- `references/sous-systemes.md` — CRTSBSD, ADDRTGE, ADDJOBQE, STRSBS, ENDSBS, routage
- `references/jobq-jobd.md` — CRTJOBQ, CRTJOBD, RTGDTA, INLLIBL, liens sous-systeme
- `references/profils-utilisateurs.md` — CRTUSRPRF, classes, LMTCPB, SPCAUT, securite
- `references/bibliotheques.md` — CRTLIB, DSPLIBL, EDTLIBL, ADDLIBLE, LIBL, CURLIB
- `references/messages.md` — CRTMSGQ, SNDMSG, SNDBRKMSG, DSPMSG, QSYSOPR, modes reception
- `references/impressions-spools.md` — OUTQ, WRKSPLF, WRKOUTQ, STRPRTWTR, PRTF, writers
- `references/objets-systeme.md` — Types objets, securite, autorisations, commandes gestion
- `references/surveillance-systeme.md` — WRKACTJOB, WRKSBS, DSPSBSD, diagnostic, performance
- `references/architecture-ibmi.md` — MI, TIMI, SLIC, DB2 for i, stockage unifie, historique
- `references/commandes-par-domaine.md` — Aide-memoire des commandes par domaine fonctionnel (400+ commandes essentielles)
- `references/commandes-ibmi-reference.md` — Reference COMPLETE de 2399 commandes systeme classees par verbe (ADD, CHG, CRT, DLT, DSP, WRK, etc.)

### Etape 3 : Appliquer les regles critiques

Regles OBLIGATOIRES dans toute reponse :

1. **Commandes completes** — Toujours fournir la commande CL complete avec tous les parametres importants
2. **Qualifier les objets** — Toujours utiliser le format LIB/OBJET (ex: MONAPP/JOBQVENTE, pas juste JOBQVENTE)
3. **Ordre de creation** — Respecter l'ordre : Bibliotheque → Sous-systeme → Routage → JOBQ → Lien JOBQ/SBS → JOBD → Profil → Demarrage
4. **Securite par defaut** — Toujours proposer des configurations securisees (LMTCPB(*YES), SPCAUT(*NONE) pour les utilisateurs metier)
5. **Expliquer en francais** — Commentaires et explications en francais
6. **Verbes IBM i** — Utiliser la nomenclature IBM i standard (voir section Nomenclature ci-dessous)
7. **Verification** — Toujours proposer une commande de verification apres creation (DSPSBSD, DSPJOBD, WRKJOBQ, DSPUSRPRF)
8. **Pas de confusion** — Ne pas confondre JOBQ (file d'attente) et JOBD (description), ni OUTQ (sortie) et MSGQ (messages)
9. **Contexte pratique** — Toujours accompagner d'un exemple concret quand c'est possible
10. **Metaphores simples** — Utiliser des metaphores pour les concepts complexes (salle d'attente, fiche de configuration, etc.)

### Etape 4 : Valider avant de fournir la reponse

Checklist de qualite :

- [ ] Commandes CL completes et qualifiees (LIB/OBJ)
- [ ] Ordre logique de creation respecte
- [ ] Parametres de securite adaptes au contexte
- [ ] Commandes de verification fournies
- [ ] Explications claires en francais
- [ ] Exemples concrets si pertinent
- [ ] Liens entre objets expliques (SBS ↔ JOBQ ↔ JOBD ↔ USRPRF)
- [ ] Mise en garde si action dangereuse (ENDSBS *ALL *IMMED, DLTLIB, etc.)

## Nomenclature complete des verbes IBM i

Toutes les commandes IBM i suivent un schema **VERBE + NOM** (ex: CRT + LIB = CRTLIB).

### Verbes principaux (les plus utilises)

| Verbe | Francais | Description | Exemple |
|-------|----------|-------------|---------|
| ADD | Ajouter | Ajoute un element a un objet existant | ADDLIBLE, ADDRTGE, ADDJOBQE |
| CHG | Modifier | Modifie les attributs d'un objet | CHGUSRPRF, CHGJOB, CHGSYSVAL |
| CLR | Mettre a blanc | Vide le contenu sans supprimer l'objet | CLRJOBQ, CLRMSGQ, CLROUTQ |
| CPY | Copier | Copie un objet vers un autre | CPYF, CPYLIB, CPYSPLF |
| CRT | Creer | Cree un nouvel objet | CRTLIB, CRTPF, CRTUSRPRF |
| DLT | Supprimer | Supprime definitivement un objet | DLTLIB, DLTF, DLTUSRPRF |
| DMP | Clicher | Cree un dump pour diagnostic | DMPJOB, DMPOBJ, DMPSYSOBJ |
| DSP | Afficher | Affiche les informations d'un objet | DSPLIB, DSPOBJ, DSPJOB |
| EDT | Editer | Ouvre un editeur interactif | EDTLIBL, EDTAUTL, EDTOBJAUT |
| END | Arreter | Arrete un processus ou service | ENDSBS, ENDJOB, ENDTCP |
| GRT | Accorder | Accorde des droits ou autorisations | GRTOBJAUT, GRTUSRAUT |
| HLD | Suspendre | Suspend temporairement | HLDJOB, HLDJOBQ, HLDOUTQ |
| MOV | Deplacer | Deplace un objet | MOVOBJ, MOV |
| OVR | Substituer | Substitue un fichier par un autre | OVRDBF, OVRPRTF, OVRDSPF |
| PRT | Imprimer | Genere un rapport imprime | PRTSYSINF, PRTUSRPRF |
| RCL | Recuperer | Recupere des ressources | RCLSTG, RCLSPLSTG, RCLACTGRP |
| RGZ | Reorganiser | Reorganise physiquement un fichier | RGZPFM |
| RLS | Liberer | Libere un element suspendu | RLSJOB, RLSJOBQ, RLSOUTQ |
| RMV | Enlever | Enleve un element d'un objet | RMVLIBLE, RMVRTGE, RMVJOBQE |
| RST | Restaurer | Restaure depuis une sauvegarde | RSTLIB, RSTOBJ, RSTAUT |
| RTV | Extraire | Extrait une valeur en variable CL | RTVJOBA, RTVSYSVAL, RTVDTAARA |
| RUN | Executer | Execute un programme ou requete | RUNQRY, RUNSQLSTM, RUNSQL |
| SAV | Sauvegarder | Sauvegarde un objet | SAVLIB, SAVOBJ, SAVSYS |
| SBM | Soumettre | Soumet un travail | SBMJOB, SBMDBJOB |
| SET | Definir | Definit une valeur | SETASPGRP, SETATNPGM |
| SND | Envoyer | Envoie un message ou fichier | SNDMSG, SNDBRKMSG, SNDSPLF |
| STR | Demarrer | Demarre un service ou outil | STRSBS, STRTCP, STRDBG |
| TFR | Transferer | Transfere un travail ou controle | TFRJOB, TFRBCHJOB |
| TRC | Tracer | Active un trace diagnostic | TRCJOB, TRCTCPAPP |
| VFY | Verifier | Verifie une configuration | VFYCMN, VFYIMGCLG |
| VRY | Varier | Change l'etat d'une configuration | VRYCFG |
| WRK | Gerer | Ecran de gestion interactif 5250 | WRKACTJOB, WRKSBS, WRKOBJ |

### Verbes secondaires

| Verbe | Francais | Description |
|-------|----------|-------------|
| ALC | Allouer | Alloue une ressource (ALCOBJ) |
| ANS | Repondre | Repond a un appel (ANSLIN) |
| ANZ | Analyser | Analyse performances (ANZDBF, ANZCMDPFR) |
| CHK | Verifier | Verifie integrite (CHKOBJ, CHKOBJITG) |
| CMP | Comparer | Compare deux objets (CMPPFM, CMPJRNIMG) |
| CVT | Convertir | Convertit un format (CVTDAT, CVTDIR) |
| DLC | Desallouer | Libere une allocation (DLCOBJ) |
| FND | Rechercher | Recherche une chaine (FNDSTRPDM) |
| INS | Installer | Installe un composant (INSPTF) |
| MON | Intercepter | Intercepte un message CL (MONMSG) |
| MRG | Fusionner | Fusionne des elements (MRGMSGF, MRGSRC) |
| OPN | Ouvrir | Ouvre un fichier (OPNDBF, OPNQRYF) |
| RCV | Recevoir | Recoit un message/fichier (RCVMSG, RCVF) |
| RNM | Renommer | Renomme un objet (RNMOBJ, RNMM) |
| RSM | Reprendre | Reprend un processus (RSMBKP) |
| SNP | Snapshot | Cree un snapshot |

### Noms courants (suffixes)

| Suffixe | Signification | Exemple |
|---------|---------------|---------|
| LIB | Bibliotheque | CRTLIB, DLTLIB, DSPLIB |
| OBJ | Objet generique | WRKOBJ, DSPOBJ, MOVOBJ |
| PF | Fichier physique | CRTPF, DSPFD |
| LF | Fichier logique | CRTLF |
| DSPF | Fichier ecran | CRTDSPF |
| PRTF | Fichier d'impression | CRTPRTF |
| SRCPF | Fichier source | CRTSRCPF |
| SBSD | Description sous-systeme | CRTSBSD, DSPSBSD |
| JOBQ | File de travaux | CRTJOBQ, WRKJOBQ |
| JOBD | Description de travail | CRTJOBD, DSPJOBD |
| OUTQ | File de sortie | CRTOUTQ, WRKOUTQ |
| MSGQ | File de messages | CRTMSGQ, DSPMSG |
| MSGF | Fichier de messages | CRTMSGF |
| USRPRF | Profil utilisateur | CRTUSRPRF, DSPUSRPRF |
| DTAARA | Data area | CRTDTAARA, DSPDTAARA |
| DTAQ | Data queue | CRTDTAQ |
| SPLF | Fichier spoule | WRKSPLF, DLTSPLF |
| JRN | Journal | CRTJRN, DSPJRN |
| JRNRCV | Recepteur de journal | CRTJRNRCV |
| AUTL | Liste d'autorisation | CRTAUTL, EDTAUTL |
| BNDDIR | Repertoire de liage | CRTBNDDIR |
| SRVPGM | Programme de service | CRTSRVPGM |
| CMD | Commande | CRTCMD |
| CLS | Classe | CRTCLS |
| SYSVAL | Valeur systeme | DSPSYSVAL, CHGSYSVAL |
| PTF | Correction logicielle | DSPPTF, INSPTF |

## Exemples

### Exemple 1 : Creer un environnement complet pour un service

Utilisateur dit : "Je veux creer un environnement pour le service comptabilite"

Actions :
1. Lire `references/sous-systemes.md` + `references/jobq-jobd.md` + `references/profils-utilisateurs.md`
2. Creer dans l'ordre : Bibliotheque → Sous-systeme → Routage → JOBQ → Lien JOBQ/SBS → JOBD → Profil
3. Fournir les commandes de verification
4. Expliquer le flux complet : Utilisateur → JOBD → JOBQ → Sous-systeme → Execution

Resultat : Environnement complet et securise pret a l'emploi.

### Exemple 2 : Diagnostiquer un job bloque

Utilisateur dit : "Mon job batch est bloque, comment le trouver ?"

Actions :
1. Lire `references/surveillance-systeme.md`
2. Guider avec WRKACTJOB SBS(xxx) ou WRKACTJOB JOB(xxx)
3. Expliquer comment lire l'etat du job (MSGW, RUN, DEQW, etc.)
4. Proposer des actions correctives (DSPMSG QSYSOPR, repondre au message, ENDJOB si necessaire)

Resultat : Diagnostic clair avec actions correctives.

### Exemple 3 : Gestion des spools et impressions

Utilisateur dit : "Comment gerer les fichiers spoules d'un utilisateur ?"

Actions :
1. Lire `references/impressions-spools.md`
2. Montrer WRKSPLF SELECT(utilisateur)
3. Expliquer les options (5=Afficher, 4=Supprimer, 2=Modifier)
4. Montrer comment rediriger un spool vers une autre OUTQ

Resultat : Guide pratique de gestion des impressions.

### Exemple 4 : Trouver une commande IBM i

Utilisateur dit : "Quelle commande pour sauvegarder une bibliotheque ?"

Actions :
1. Consulter `references/commandes-par-domaine.md` section Sauvegarde
2. Identifier SAVLIB comme commande principale
3. Fournir la syntaxe complete : SAVLIB LIB(MALIB) DEV(*SAVF) SAVF(QGPL/MONSAVF)
4. Proposer des alternatives si pertinent (SAVOBJ pour objets individuels)

Resultat : Commande exacte avec syntaxe et exemple.

### Exemple 5 : Recherche par verbe

Utilisateur dit : "Quelles sont toutes les commandes WRK* ?"

Actions :
1. Consulter `references/commandes-ibmi-reference.md` section WRK
2. Lister les 238 commandes WRK disponibles
3. Mettre en avant les plus courantes (WRKACTJOB, WRKSBS, WRKOBJ, WRKSPLF, etc.)

Resultat : Liste exhaustive organisee par sous-categorie.

## Troubleshooting

### Job bloque en MSGW
**Cause** : Un message attend une reponse dans QSYSOPR ou dans la MSGQ du job.
**Solution** : `DSPMSG QSYSOPR` puis repondre au message. Ou `WRKJOB` option 7 pour voir les messages du job.

### Sous-systeme ne demarre pas
**Cause** : Pas de poste de routage (RTGE) ou pas de JOBQ liee.
**Solution** : Verifier avec `DSPSBSD SBSD(LIB/SBSNOM)` que les postes de routage et les entrees JOBQ existent.

### Job va dans le mauvais sous-systeme
**Cause** : La RTGDTA du job ne correspond pas a la valeur de comparaison du poste de routage.
**Solution** : Verifier la RTGDTA dans la JOBD (`DSPJOBD`) et la valeur de comparaison dans le sous-systeme (`DSPSBSD` option routage).

### OUTQ saturee
**Cause** : Trop de fichiers spoules non traites.
**Solution** : `WRKOUTQ OUTQ(LIB/OUTQ)` pour voir les spools. `CLROUTQ` pour purger (ATTENTION: irreversible).

### Utilisateur ne peut pas se connecter
**Cause** : Profil desactive, mot de passe expire, ou sous-systeme QINTER non actif.
**Solution** : `DSPUSRPRF USRPRF(xxx)` pour verifier l'etat. `CHGUSRPRF USRPRF(xxx) STATUS(*ENABLED)` pour reactiver.

### Library List incomplete
**Cause** : La JOBD de l'utilisateur ne contient pas les bonnes bibliotheques dans INLLIBL.
**Solution** : `DSPJOBD JOBD(LIB/JOBD)` pour verifier. `CHGJOBD` pour corriger la liste initiale.

### Message non recu par l'utilisateur
**Cause** : Mode de reception en *HOLD (messages stockes sans notification).
**Solution** : `CHGMSGQ MSGQ(xxx) DLVRY(*NOTIFY)` ou `DLVRY(*BREAK)` pour reception immediate.

### Espace disque insuffisant
**Cause** : ASP systeme sature.
**Solution** : `WRKSYSSTS` pour voir le % utilise. `WRKDSKSTS` pour le detail par disque. `RCLSTG` pour recuperer de l'espace. `DSPSTGSTS` pour le detail du stockage.

### PTF qui ne s'installe pas
**Cause** : Prerequis manquant ou IPL requis.
**Solution** : `DSPPTF PTFID(SIxxxxx)` pour verifier le statut. Verifier les prerequis avec `DSPPTF` option 1. Planifier un IPL si necessaire.

### Connexion TCP/IP echouee
**Cause** : Interface non active, route manquante ou service arrete.
**Solution** : `WRKTCPSTS OPTION(*IFC)` pour les interfaces. `PING` pour tester. `STRTCPSVR` pour demarrer un service.

## Commandes essentielles - Aide-memoire rapide

### Gestion des sous-systemes
| Commande | Description |
|----------|-------------|
| WRKSBS | Afficher les sous-systemes actifs |
| STRSBS SBSD(LIB/SBS) | Demarrer un sous-systeme |
| ENDSBS SBS(xxx) OPTION(*CNTRLD) DELAY(60) | Arreter proprement |
| DSPSBSD SBSD(LIB/SBS) | Afficher la description |

### Gestion des travaux
| Commande | Description |
|----------|-------------|
| WRKACTJOB | Voir tous les jobs actifs |
| WRKACTJOB SBS(xxx) | Jobs actifs dans un sous-systeme |
| WRKSBMJOB | Voir les jobs soumis |
| WRKJOBQ JOBQ(LIB/JQ) | Voir la file d'attente |
| SBMJOB CMD(xxx) JOBQ(LIB/JQ) | Soumettre un job |

### Gestion des impressions
| Commande | Description |
|----------|-------------|
| WRKSPLF | Voir ses fichiers spoules |
| WRKSPLF SELECT(USER) | Spoules d'un utilisateur |
| WRKOUTQ OUTQ(LIB/OQ) | Voir une file de sortie |
| STRPRTWTR DEV(PRT01) | Demarrer un writer |

### Gestion des messages
| Commande | Description |
|----------|-------------|
| DSPMSG MSGQ(QSYSOPR) | Messages operateur |
| SNDMSG MSG('texte') TOUSR(xxx) | Envoyer un message |
| SNDBRKMSG MSG('texte') TOMSGQ(*ALLWS) | Message d'interruption a tous |

### Sauvegarde et restauration
| Commande | Description |
|----------|-------------|
| SAVLIB LIB(xxx) DEV(*SAVF) SAVF(LIB/SAVF) | Sauvegarder une bibliotheque |
| SAVOBJ OBJ(xxx) LIB(yyy) DEV(*SAVF) SAVF(LIB/SAVF) | Sauvegarder un objet |
| RSTLIB SAVLIB(xxx) DEV(*SAVF) SAVF(LIB/SAVF) | Restaurer une bibliotheque |
| SAVSYS | Sauvegarder le systeme complet |
| SAVSECDTA | Sauvegarder les donnees de securite |

### TCP/IP et reseau
| Commande | Description |
|----------|-------------|
| STRTCP | Demarrer TCP/IP |
| WRKTCPSTS OPTION(*IFC) | Voir les interfaces reseau |
| CFGTCP | Configurer TCP/IP (menu) |
| PING | Tester la connectivite |
| STRHOSTSVR SERVER(*ALL) | Demarrer les serveurs IBM i Access |

### Systeme et maintenance
| Commande | Description |
|----------|-------------|
| WRKSYSSTS | Etat du systeme (CPU, memoire) |
| DSPSYSVAL SYSVAL(xxx) | Afficher une valeur systeme |
| CHGSYSVAL SYSVAL(xxx) VALUE(yyy) | Modifier une valeur systeme |
| DSPPTF | Afficher les PTF |
| PWRDWNSYS OPTION(*CNTRLD) DELAY(600) | Arreter le systeme proprement |
| DSPLOG | Afficher le journal systeme (QHST) |
| DSPJOBLOG | Afficher le joblog |

### IFS (Integrated File System)
| Commande | Description |
|----------|-------------|
| WRKLNK | Naviguer dans l'IFS |
| CPYTOSTMF | Copier vers un stream file |
| CPYFRMSTMF | Copier depuis un stream file |
| CRTDIR DIR('/chemin') | Creer un repertoire IFS |
| QSH / STRQSH | Lancer un shell QShell |

### Journalisation
| Commande | Description |
|----------|-------------|
| CRTJRN JRN(LIB/JRN) JRNRCV(LIB/RCV) | Creer un journal |
| CRTJRNRCV JRNRCV(LIB/RCV) | Creer un recepteur de journal |
| STRJRNPF FILE(LIB/FILE) JRN(LIB/JRN) | Journaliser un fichier physique |
| DSPJRN JRN(LIB/JRN) | Afficher les postes de journal |

## Prerequis IBM i

- IBM i 7.3 ou superieur
- Autorisations QSECOFR ou equivalent pour la creation de sous-systemes et profils
- Connaissance des commandes CL de base
- Acces a la ligne de commande (LMTCPB(*NO) sur le profil administrateur)

## Performance Notes

- CRITICAL: Toujours lire les references AVANT de repondre
- Pour rechercher une commande specifique, consulter `references/commandes-ibmi-reference.md` (2399 commandes classees par verbe)
- Pour un apercu par domaine, consulter `references/commandes-par-domaine.md` (commandes essentielles par theme)
- Qualite et precision des commandes > rapidite de reponse
- Ne pas sauter les etapes de verification
- Pour les operations complexes (creation d'environnement complet), proceder etape par etape
- TOUJOURS avertir avant les commandes destructives (DLTLIB, CLROUTQ, ENDSBS *ALL *IMMED, ENDJOB *IMMED)
