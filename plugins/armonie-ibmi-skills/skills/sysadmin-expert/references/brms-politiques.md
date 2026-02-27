# BRMS - Politiques et Groupes de Controle

## Les trois types de politiques BRMS

### 1. Politique de sauvegarde (Backup Policy)

Definit **QUOI** sauvegarder et **COMMENT**.

#### Gestion des politiques
```
-- Lister / gerer les politiques de sauvegarde
WRKPCYBRM TYPE(*BKU)

-- Creer une politique de sauvegarde
-- Via le menu BRMS :
GO BRMS → Option 1 (Politiques) → Option 1 (Sauvegarde) → F6 (Creer)
```

#### Parametres cles d'une politique de sauvegarde

| Parametre | Description | Valeurs courantes |
|-----------|-------------|-------------------|
| Nom politique | Identifiant unique | FULL, INCR, CUML, SYSLIB |
| Type sauvegarde | Complet ou incrementale | *FULL, *CUML, *INCR |
| Fichiers spoules | Inclure les spools | *YES, *NO |
| Donnees securite | Sauver les donnees de securite | *YES, *NO |
| Objets modifies | Seulement les objets modifies | *YES (pour incrementale) |
| Compression | Compresser les donnees | *YES, *LOW, *MEDIUM, *HIGH |
| Politique media | Lien vers la politique media | Nom de la politique media |
| Cible | Peripherique ou SAVF | *MEDPCY, *SAVF |

#### Types de sauvegarde BRMS

**Sauvegarde complete (*FULL)**
- Sauvegarde TOUS les objets selectionnes
- La plus longue mais la plus simple a restaurer
- Base de reference pour les incrementales

**Sauvegarde cumulative (*CUML)**
- Sauvegarde tout ce qui a change depuis la derniere *FULL
- Restauration : *FULL + derniere *CUML
- Bon compromis temps/securite

**Sauvegarde incrementale (*INCR)**
- Sauvegarde uniquement ce qui a change depuis la derniere sauvegarde (quelle qu'elle soit)
- La plus rapide
- Restauration : *FULL + toutes les *INCR dans l'ordre
- Plus risquee si un media est endommage

#### Exemples de politiques de sauvegarde

```
Politique FULLSYS (Sauvegarde systeme complete) :
- Type : *FULL
- Fichiers spoules : *YES
- Donnees securite : *YES
- Compression : *MEDIUM
- Politique media : MENSUEL

Politique CUMLAPP (Cumulative applicative) :
- Type : *CUML
- Fichiers spoules : *NO
- Donnees securite : *NO
- Compression : *LOW
- Politique media : HEBDO

Politique INCRQUO (Incrementale quotidienne) :
- Type : *INCR
- Fichiers spoules : *NO
- Donnees securite : *NO
- Compression : *LOW
- Politique media : QUOTIDIEN
```

### 2. Politique de media (Media Policy)

Definit la **RETENTION** et la **ROTATION** des medias.

#### Gestion des politiques media
```
-- Lister / gerer les politiques de media
WRKPCYBRM TYPE(*MED)
```

#### Parametres cles d'une politique media

| Parametre | Description | Valeurs courantes |
|-----------|-------------|-------------------|
| Nom politique | Identifiant unique | QUOTIDIEN, HEBDO, MENSUEL |
| Retention (jours) | Nombre de jours de conservation | 7, 30, 90, 365 |
| Retention (versions) | Nombre de versions a conserver | 1, 2, 5 |
| Type expiration | Par date ou par version | *DAYS, *VERSIONS, *PERM |
| Politique de deplacement | Lien vers politique de deplacement | Nom ou *NONE |
| Initialisation auto | Reinitialiser les medias expires | *YES, *NO |

#### Strategies de retention courantes

```
Strategie GFS (Grand-pere / Pere / Fils) :

QUOTIDIEN (Fils) :
- Retention : 7 jours
- 5 medias en rotation (lundi a vendredi)

HEBDO (Pere) :
- Retention : 35 jours
- 5 medias en rotation (semaines 1 a 5)

MENSUEL (Grand-pere) :
- Retention : 365 jours
- 12 medias en rotation (janvier a decembre)

ANNUEL (Archive) :
- Retention : *PERM (permanent)
- Conservation illimitee
```

### 3. Politique de deplacement (Move Policy)

Definit le **DEPLACEMENT HORS-SITE** des medias.

#### Gestion des politiques de deplacement
```
-- Lister / gerer les politiques de deplacement
WRKPCYBRM TYPE(*MOV)

-- Deplacer les medias selon la politique
MOVMEDBRM
```

#### Parametres d'une politique de deplacement

| Parametre | Description |
|-----------|-------------|
| Calendrier | Quand deplacer (jour, semaine, mois) |
| Emplacement source | Ou se trouve le media actuellement |
| Emplacement destination | Ou envoyer le media |
| Verification | Verifier avant le deplacement |

#### Emplacements BRMS

BRMS gere la localisation des medias avec des codes d'emplacement :

```
Emplacements typiques :
- *HOME      → Salle machine (emplacement par defaut)
- COFFRE     → Coffre-fort sur site
- HORSSITE   → Site de stockage distant
- PRESTATAIRE → Chez le prestataire de securite
- CLOUD      → Stockage cloud (VTL cloud)

-- Creer un emplacement
-- Via GO BRMS → Option 3 (Medias) → Option 5 (Emplacements)
```

## Groupes de controle (Control Groups)

### Concept

Un groupe de controle est une **sequence ordonnee** d'elements a sauvegarder. Chaque element (entree) specifie :
- Ce qu'il faut sauvegarder (bibliotheque, IFS, systeme...)
- Quelle politique appliquer
- L'ordre d'execution

### Gestion des groupes de controle
```
-- Lister / gerer les groupes de controle de sauvegarde
WRKCTLGBRM TYPE(*BKU)

-- Executer un groupe de controle
STRBKUBRM CTLGRP(nomgroupe)

-- Creer un groupe de controle
-- Via GO BRMS → Option 2 (Groupes de controle) → F6 (Creer)
```

### Structure d'un groupe de controle

```
Groupe de controle : QUOTIDIEN
Seq  Type              Objet               Politique
---  ----------------  ------------------  ----------
10   *SAVSECDTA        (donnees securite)  INCRQUO
20   *SAVCFG           (configuration)     INCRQUO
30   Bibliotheque      APPLIB1             INCRQUO
40   Bibliotheque      APPLIB2             INCRQUO
50   Bibliotheque      APPLIB3             INCRQUO
60   *LINK /appdata    (repertoire IFS)    INCRQUO
```

### Groupes de controle types pour une entreprise

#### Groupe QUOTIDIEN (lundi-vendredi)
```
Seq  Type              Objet               Politique    Notes
10   *SAVSECDTA        Securite            INCRQUO      Profils, autorisations
20   *SAVCFG           Configuration       INCRQUO      Config systeme
30   Bibliotheque      *ALLUSR             INCRQUO      Toutes les bibs utilisateur
40   *LINK             /appdata            INCRQUO      Donnees IFS applicatives
50   *LINK             /www               INCRQUO      Serveur web
```

#### Groupe HEBDO (samedi)
```
Seq  Type              Objet               Politique    Notes
10   *SAVSECDTA        Securite            CUMLAPP      Cumulative securite
20   *SAVCFG           Configuration       CUMLAPP      Cumulative config
30   Bibliotheque      *ALLUSR             CUMLAPP      Cumulative toutes bibs
40   *LINK             /                   CUMLAPP      Cumulative IFS complet
50   *SAVSYSINF        Info systeme        CUMLAPP      Informations systeme
```

#### Groupe MENSUEL (1er du mois)
```
Seq  Type              Objet               Politique    Notes
10   *SAVSYS           Systeme complet     FULLSYS      Sauvegarde systeme
20   Bibliotheque      *ALLUSR             FULLSYS      Full toutes bibs
30   *LINK             /                   FULLSYS      Full IFS complet
40   *SAVSECDTA        Securite            FULLSYS      Full securite
50   *SAVCFG           Configuration       FULLSYS      Full configuration
60   *SAVSYSINF        Info systeme        FULLSYS      Informations systeme
```

### Options avancees des groupes de controle

#### Sequencement et dependances
- Chaque entree a un numero de sequence (10, 20, 30...)
- Les entrees s'executent dans l'ordre de la sequence
- En cas d'erreur, on peut configurer : arreter le groupe ou continuer

#### Actions de fin de groupe
```
Options de fin de groupe :
- *NONE     → Pas d'action speciale
- *RUNBKUACT → Executer une commande apres la sauvegarde
- *PWRDWNSYS → Eteindre le systeme apres la sauvegarde
- *ENDSBS    → Arreter les sous-systemes apres la sauvegarde
```

#### Sous-systemes a arreter avant sauvegarde
BRMS peut automatiquement arreter et redemarrer des sous-systemes :
```
-- Dans le groupe de controle, specifier :
Sous-systemes a arreter : QINTER, QBATCH, APPROD
Delai d'arret : 120 secondes
Redemarrer apres : *YES
```

### Bonnes pratiques groupes de controle

1. **Nommer clairement** — QUOTIDIEN, HEBDO, MENSUEL, ANNUEL, APPLI_COMPTA, etc.
2. **Tester les nouveaux groupes** — Lancer manuellement avant de planifier
3. **Documenter** — Commentaire dans chaque entree du groupe
4. **Sauvegarder QUSRBRM** — Inclure la bibliotheque BRMS dans les sauvegardes
5. **Verifier les resultats** — Controler systematiquement les joblogs
6. **Rapport de recuperation** — Generer regulierement via STRRCYBRM OPTION(*REPORT)
