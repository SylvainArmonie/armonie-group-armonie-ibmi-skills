# BRMS - Recuperation et Restauration

## La commande STRRCYBRM

STRRCYBRM est la commande centrale de recuperation BRMS. Elle peut :
- Generer un rapport de recuperation detaille
- Executer une restauration assistee
- Restaurer un systeme complet ou partiel

### Syntaxe de base
```
STRRCYBRM OPTION(*SYSTEM | *ALLUSR | *ALLLIB | *REPORT)
          ACTION(*RECOVER | *REPORT)
```

### Modes d'utilisation

| Mode | Commande | Description |
|------|----------|-------------|
| Rapport seul | STRRCYBRM OPTION(*REPORT) ACTION(*REPORT) | Genere le rapport sans rien restaurer |
| Recuperation systeme | STRRCYBRM OPTION(*SYSTEM) | Restaure le systeme complet |
| Recuperation utilisateur | STRRCYBRM OPTION(*ALLUSR) | Restaure toutes les bibs utilisateur |
| Recuperation bibliotheque | STRRCYBRM OPTION(*LIB) LIB(MALIB) | Restaure une bibliotheque specifique |
| Recuperation IFS | STRRCYBRM OPTION(*LINK) OBJ('/chemin') | Restaure un chemin IFS |

## Le rapport de recuperation

### Pourquoi c'est CRITIQUE

Le rapport de recuperation est le **document le plus important** de votre strategie de sauvegarde. Il liste :
- Toutes les etapes pour restaurer le systeme de A a Z
- L'ordre exact des operations
- Les medias necessaires (avec leurs numeros de volume)
- Les commandes de restauration a executer
- Les actions manuelles requises

**REGLE D'OR** : Generez et imprimez ce rapport au minimum une fois par mois. Conservez une copie hors-site.

### Generer le rapport
```
-- Generer le rapport de recuperation complet
STRRCYBRM OPTION(*REPORT) ACTION(*REPORT)

-- Le rapport est genere dans un fichier spoule
-- Le consulter via WRKSPLF
WRKSPLF SELECT(QSECOFR) → chercher QPRTRCY
```

### Contenu du rapport de recuperation

```
Le rapport contient typiquement :

Section 1 : Informations systeme
- Nom du systeme, modele, numero de serie
- Version OS, niveau de PTF
- Configuration materielle

Section 2 : Etapes de recuperation (dans l'ordre)
  Etape 1 : IPL depuis le media d'installation (SAVSYS)
  Etape 2 : Restaurer le systeme d'exploitation
  Etape 3 : Restaurer les donnees de securite (RSTAUT)
  Etape 4 : Restaurer la configuration systeme (RSTCFG)
  Etape 5 : Restaurer les bibliotheques utilisateur
  Etape 6 : Restaurer les objets IFS
  Etape 7 : Restaurer les autorisations (RSTAUT)
  Etape 8 : Verifications post-restauration

Section 3 : Liste des medias necessaires
- Volume, type, contenu, emplacement actuel

Section 4 : Actions manuelles
- Verifications a effectuer
- Services a redemarrer
- Tests fonctionnels
```

## Scenarios de recuperation

### Scenario 1 : Restauration d'une bibliotheque unique

```
-- Identifier le media contenant la bibliotheque
WRKMEDIBRM → F17 (Recherche) → saisir le nom de la bibliotheque

-- OU utiliser STRRCYBRM en mode rapport
STRRCYBRM OPTION(*LIB) LIB(APPLIB1) ACTION(*REPORT)

-- Restaurer la bibliotheque
STRRCYBRM OPTION(*LIB) LIB(APPLIB1) ACTION(*RECOVER)

-- Verification
DSPLIB LIB(APPLIB1)
DSPLIBL
```

### Scenario 2 : Restauration d'un objet specifique

```
-- Trouver l'objet dans l'historique BRMS
-- Via GO BRMS → Option 6 (Historique) → Recherche

-- Restaurer l'objet
RSTOBJ OBJ(MONPGM) SAVLIB(APPLIB1) DEV(*SAVF)
       SAVF(SAVFBRM/BKUQUO01)

-- OU via BRMS (plus simple)
STRRCYBRM OPTION(*OBJ) OBJ(APPLIB1/MONPGM) ACTION(*RECOVER)
```

### Scenario 3 : Restauration systeme complete (Disaster Recovery)

**ATTENTION** : Cette procedure repart de zero. A ne faire qu'en cas de perte totale.

```
Etape 1 : Preparation
- Rassembler TOUS les medias identifies dans le rapport de recuperation
- Avoir le media d'installation IBM i (ou SAVSYS)
- Disposer d'un systeme IBM i avec la meme version de hardware/OS
- Imprimer le rapport de recuperation (si pas deja fait)

Etape 2 : IPL depuis le media d'installation
- Inserer le media SAVSYS ou le media d'installation
- IPL mode D (DST → Option 3 → Option 2 → Option 1)
- Choisir "Install the operating system"
- Option "Restore from distribution media" ou "Restore from save media"

Etape 3 : Restauration du systeme d'exploitation
RSTLICPGM LICPGM(*ALL) DEV(TAP01)

Etape 4 : IPL normal et configuration initiale
- IPL normal
- Se connecter en QSECOFR
- Verifier la configuration de base

Etape 5 : Restauration des donnees de securite
RSTUSRPRF USRPRF(*ALL) DEV(TAP01)

Etape 6 : Restauration de la configuration
RSTCFG OBJ(*ALL) DEV(TAP01)

Etape 7 : Restauration des bibliotheques utilisateur
-- Via BRMS (recommande)
STRRCYBRM OPTION(*ALLUSR) ACTION(*RECOVER)

-- OU manuellement
RSTLIB SAVLIB(*ALLUSR) DEV(TAP01)

Etape 8 : Restauration des objets IFS
STRRCYBRM OPTION(*LINK) OBJ('/') ACTION(*RECOVER)

-- OU manuellement
RST DEV(TAP01) OBJ(('/') ('/QSYS.LIB' *OMIT) ('/QDLS' *OMIT))

Etape 9 : Restauration des autorisations
RSTAUT

Etape 10 : Verifications post-restauration
- Verifier les sous-systemes : WRKSBS
- Verifier les services TCP/IP : WRKTCPSTS
- Verifier les travaux : WRKACTJOB
- Verifier les utilisateurs : DSPAUTUSR
- Lancer les applications et tester
```

### Scenario 4 : Restauration d'un chemin IFS

```
-- Restaurer un repertoire IFS specifique
STRRCYBRM OPTION(*LINK) OBJ('/appdata/documents') ACTION(*RECOVER)

-- OU manuellement
RST DEV(TAP01) OBJ(('/appdata/documents'))
```

### Scenario 5 : Restauration des fichiers spoules

```
-- Lister les fichiers spoules sauvegardes
WRKSPRBRM

-- Restaurer un fichier spoule specifique
-- Via WRKSPRBRM → Option 9 (Restaurer)

-- Restaurer tous les fichiers spoules d'un utilisateur
WRKSPRBRM → Filtrer par utilisateur → F21 (Selectionner tout) → 9
```

## Test de restauration (VITAL)

### Pourquoi tester ?

Une sauvegarde non testee est une sauvegarde qui ne fonctionne PAS. Les tests reguliers sont indispensables.

### Plan de test recommande

| Frequence | Test | Methode |
|-----------|------|---------|
| Mensuel | Restaurer 1 bibliotheque | STRRCYBRM OPTION(*LIB) sur partition de test |
| Trimestriel | Restaurer les donnees utilisateur | STRRCYBRM OPTION(*ALLUSR) sur partition de test |
| Semestriel | Restauration systeme complete | Disaster Recovery complet sur hardware de test |
| Apres changement | Test apres toute modification BRMS | Verification du rapport + restauration partielle |

### Procedure de test type

```
1. Generer le rapport de recuperation
   STRRCYBRM OPTION(*REPORT) ACTION(*REPORT)

2. Verifier que tous les medias sont disponibles
   Consulter le rapport → section medias necessaires

3. Sur une partition de test (LPAR) :
   - Restaurer selon le rapport
   - Chronometrer chaque etape
   - Noter les problemes rencontres

4. Documenter les resultats :
   - Duree totale de restauration
   - Problemes rencontres et solutions
   - Ecarts par rapport au rapport
   - Actions correctives
```

## Historique BRMS

### Consulter l'historique des sauvegardes
```
-- Historique par media
WRKMEDIBRM → Option 5 (Contenu)

-- Historique par objet sauvegarde
-- Via GO BRMS → Option 6 (Historique)

-- Rechercher quand un objet a ete sauvegarde
-- Via GO BRMS → Option 6 → F17 (Recherche)
```

### Nettoyage de l'historique
L'historique est nettoye automatiquement par STRMNTBRM selon les politiques de retention.

Pour un nettoyage manuel :
```
-- Purger l'historique ancien (ATTENTION)
STRMNTBRM EXPMED(*YES) EXPRCYINF(*YES)
```

## Troubleshooting restauration

### Erreur : Media non trouvee
```
Cause : Le volume necessaire n'est pas monte ou n'est pas dans la bibliotheque
Solution :
1. Verifier l'emplacement du media : DSPMEDIBRM VOL(xxx)
2. Si hors-site, le faire revenir
3. Monter le media dans le lecteur
4. Relancer la restauration
```

### Erreur : Objet existe deja
```
Cause : L'objet qu'on essaie de restaurer existe deja
Solution :
- RSTLIB avec OPTION(*OLD) pour ecraser les objets existants
- Ou renommer/deplacer l'objet existant avant restauration
```

### Erreur : Autorisations
```
Cause : Le profil utilisateur n'a pas les droits suffisants
Solution :
- Utiliser QSECOFR pour les restaurations
- Verifier *ALLOBJ et *SAVSYS dans les autorisations speciales
- Executer RSTAUT apres la restauration des profils
```

### Erreur : Version incompatible
```
Cause : Tentative de restaurer sur une version IBM i inferieure
Solution :
- IBM i peut restaurer depuis une version anterieure ou identique
- Impossible de restaurer depuis une version superieure
- Mettre a jour la cible avant de restaurer si necessaire
```

### Erreur : Journalisation
```
Cause : Fichiers journalises avec des journaux manquants
Solution :
1. Restaurer d'abord les recepteurs de journaux
2. Puis restaurer les fichiers journalises
3. BRMS gere normalement cet ordre via le rapport de recuperation
```

## Checklist Disaster Recovery BRMS

- [ ] Rapport de recuperation genere et imprime (moins d'un mois)
- [ ] Copie du rapport hors-site
- [ ] Tous les medias identifies et localises
- [ ] Au moins un jeu complet de medias hors-site
- [ ] Media d'installation IBM i disponible
- [ ] Hardware de remplacement identifie (ou contrat)
- [ ] Test de restauration effectue (moins de 6 mois)
- [ ] Contacts d'urgence documentes (IBM support, prestataire)
- [ ] QUSRBRM sauvegardee (sinon BRMS ne peut pas aider a la restauration)
- [ ] Documentation de la configuration reseau
- [ ] Mots de passe administrateur documentes (coffre securise)
- [ ] Procedure de communication de crise
