# BRMS - Gestion des Medias et Bibliotheques de Medias

## Types de medias supportes par BRMS

### Medias physiques
| Type | Description | Capacite typique | Usage |
|------|-------------|-----------------|-------|
| LTO-8 | Bande LTO generation 8 | 12 To (natif) / 30 To (compresse) | Production courante |
| LTO-9 | Bande LTO generation 9 | 18 To (natif) / 45 To (compresse) | Haute capacite |
| 3592 | Bande IBM enterprise | 20+ To | Gros volumes, mainframe |

### Medias virtuels
| Type | Description | Usage |
|------|-------------|-------|
| *SAVF | Save File (fichier sur disque IBM i) | Petites sauvegardes, transferts |
| VTL | Virtual Tape Library | Remplacement bandes par disque |
| Cloud VTL | VTL repliquee vers le cloud | Externalisation, PRA |

## Inscription des medias dans BRMS

### Inscrire un nouveau volume de bande
```
-- Initialiser la bande (ATTENTION : efface le contenu)
INZTAP DEV(TAP01) NEWVOL(VOL001) CHECK(*NO)

-- Inscrire dans BRMS
ADDMEDIBRM VOL(VOL001) MEDPCY(QUOTIDIEN)
```

### Inscrire plusieurs volumes en lot
```
-- Inscrire une serie de volumes
ADDMEDIBRM VOL(VOL001) MEDPCY(QUOTIDIEN)
ADDMEDIBRM VOL(VOL002) MEDPCY(QUOTIDIEN)
ADDMEDIBRM VOL(VOL003) MEDPCY(QUOTIDIEN)
ADDMEDIBRM VOL(VOL004) MEDPCY(HEBDO)
ADDMEDIBRM VOL(VOL005) MEDPCY(HEBDO)
ADDMEDIBRM VOL(VOL006) MEDPCY(MENSUEL)
```

### Inscrire des Save Files comme medias
```
-- Creer un SAVF
CRTSAVF FILE(SAVFLIB/BKUQUO01)

-- Inscrire le SAVF dans BRMS
ADDMEDIBRM MEDPCY(QUOTIDIEN) VOL(BKUQUO01)
            DEV(*SAVF) SAVF(SAVFLIB/BKUQUO01)
```

## Gestion des medias

### Commandes de gestion courantes
```
-- Lister tous les medias inscrits
WRKMEDIBRM

-- Afficher les details d'un media
DSPMEDIBRM VOL(VOL001)

-- Modifier les attributs d'un media
-- Via WRKMEDIBRM → Option 2 (Modifier)

-- Supprimer un media de l'inventaire
-- Via WRKMEDIBRM → Option 4 (Supprimer)
```

### Etats d'un media BRMS

| Etat | Signification | Actions possibles |
|------|--------------|-------------------|
| *ACTIVE | Contient des donnees non expirees | Lecture seule, pas de reinitialisation |
| *EXPIRED | Toutes les donnees expirees | Reinitialisation possible |
| *SCRATCH | Vierge, pret a l'emploi | Disponible pour sauvegarde |
| *ERROR | Erreur de lecture/ecriture | Diagnostic necessaire |
| *MOVED | Deplace hors site | Ramener sur site avant utilisation |
| *EJECT | En attente d'ejection | A retirer de la bibliotheque |

### Cycle de vie d'un media

```
*SCRATCH (vierge)
    │
    ▼
*ACTIVE (sauvegarde effectuee)
    │
    │ ... retention selon politique ...
    │
    ▼
*EXPIRED (donnees expirees par STRMNTBRM)
    │
    ▼
*SCRATCH (reinitialise, pret a reutiliser)
```

## Bibliotheques de medias (Media Libraries)

### Qu'est-ce qu'une bibliotheque de medias ?

Une bibliotheque de medias est un dispositif robotise (autoloader, tape library) qui gere automatiquement le chargement et le dechargement des bandes.

### Configuration d'une bibliotheque de medias
```
-- Lister les bibliotheques de medias
WRKMLBBRM

-- Inventorier une bibliotheque de medias
-- Via WRKMLBBRM → Option 9 (Inventaire)
```

### Types de bibliotheques de medias IBM i

| Dispositif | Description | Capacite |
|-----------|-------------|----------|
| 3573 | IBM TS3100 / TS3200 | 24-48 slots LTO |
| 3576 | IBM TS3310 / TS3500 | 128-4000+ slots |
| 3592 | IBM TS1160 / enterprise | Tres haute capacite |
| VTL | Virtual Tape Library | Limite par disque |

### Operations courantes sur bibliotheques de medias

```
-- Inventaire de la bibliotheque
WRKMLBBRM → Option 9

-- Monter un volume dans un lecteur
-- Via WRKMLBBRM → Option 7 (Monter)

-- Ejection d'un volume
-- Via WRKMLBBRM → Option 8 (Ejecter)

-- Importer des volumes dans la bibliotheque
-- Via WRKMLBBRM → Option 6 (Importer)
```

## Sauvegarde vers Save Files (*SAVF)

### Avantages des Save Files
- Pas besoin de bande physique
- Transferable via FTP/SFTP
- Rapide pour petites sauvegardes
- Ideal pour developpement/test

### Inconvenients des Save Files
- Consomme de l'espace disque IBM i
- Moins performant pour gros volumes
- Pas de compression materielle
- Risque si disque defaillant (pas de separation physique)

### Configuration BRMS pour Save Files
```
-- Creer la bibliotheque pour les Save Files
CRTLIB LIB(SAVFBRM) TYPE(*PROD) TEXT('Save Files pour BRMS')

-- Creer les Save Files
CRTSAVF FILE(SAVFBRM/BKUQUO01) TEXT('Backup quotidien 01')
CRTSAVF FILE(SAVFBRM/BKUQUO02) TEXT('Backup quotidien 02')
CRTSAVF FILE(SAVFBRM/BKUHEB01) TEXT('Backup hebdo 01')
CRTSAVF FILE(SAVFBRM/BKUMEN01) TEXT('Backup mensuel 01')

-- Inscrire dans BRMS
ADDMEDIBRM VOL(BKUQUO01) DEV(*SAVF) SAVF(SAVFBRM/BKUQUO01) MEDPCY(QUOTIDIEN)
ADDMEDIBRM VOL(BKUQUO02) DEV(*SAVF) SAVF(SAVFBRM/BKUQUO02) MEDPCY(QUOTIDIEN)
ADDMEDIBRM VOL(BKUHEB01) DEV(*SAVF) SAVF(SAVFBRM/BKUHEB01) MEDPCY(HEBDO)
ADDMEDIBRM VOL(BKUMEN01) DEV(*SAVF) SAVF(SAVFBRM/BKUMEN01) MEDPCY(MENSUEL)
```

## Virtual Tape Library (VTL)

### Concept
Une VTL emule des bandes physiques sur des disques. Pour IBM i, la VTL apparait comme une bibliotheque de bandes classique.

### Avantages
- Performances disque (beaucoup plus rapide que les bandes)
- Pas de manipulation physique
- Compatible avec BRMS sans modification
- Replication vers site distant ou cloud possible
- Pas d'usure mecanique

### Configuration BRMS avec VTL
La VTL est vue comme un peripherique de bande standard. La configuration BRMS est identique a celle avec des bandes physiques. Il suffit de :
1. Configurer la VTL au niveau IBM i (CFGDEVMLB ou CRTDEVMLB)
2. Inscrire les volumes virtuels dans BRMS
3. Utiliser normalement les politiques et groupes de controle

## Deplacement des medias (Move Management)

### Pourquoi deplacer les medias hors-site ?
- Protection contre les sinistres (incendie, inondation)
- Conformite reglementaire
- Separation physique des donnees

### Gestion des deplacements
```
-- Deplacer des medias selon la politique
MOVMEDBRM

-- Lister les medias a deplacer
MOVMEDBRM OPTION(*LIST)

-- Effectuer le deplacement
MOVMEDBRM OPTION(*MOVE)

-- Verifier les medias hors-site
WRKMEDIBRM → Filtrer par emplacement
```

### Procedure de deplacement type

```
1. Identifier les medias a deplacer :
   MOVMEDBRM OPTION(*LIST)

2. Preparer les medias physiquement :
   - Ejecter de la bibliotheque si necessaire
   - Etiqueter avec le numero de volume

3. Effectuer le deplacement dans BRMS :
   MOVMEDBRM OPTION(*MOVE)

4. Transporter physiquement les medias

5. Verifier que BRMS a bien enregistre le deplacement :
   WRKMEDIBRM → verifier l'emplacement
```

## Rapports medias

### Rapports disponibles
```
-- Rapport d'inventaire des medias
PRTRPTBRM TYPE(*MEDIINV)

-- Rapport des medias par politique
PRTRPTBRM TYPE(*MEDIPCY)

-- Rapport des medias expires
PRTRPTBRM TYPE(*MEDIEXP)

-- Rapport des mouvements de medias
PRTRPTBRM TYPE(*MEDIMOV)

-- Rapport d'utilisation des medias
PRTRPTBRM TYPE(*MEDIUSE)
```

## Bonnes pratiques gestion des medias

1. **Etiquetage** — Toujours etiqueter physiquement les medias avec le numero de volume BRMS
2. **Inventaire regulier** — Faire un inventaire WRKMLBBRM au moins une fois par mois
3. **Test de lecture** — Tester la lecture des medias critiques regulierement
4. **Rotation** — Respecter la rotation GFS (Grand-pere/Pere/Fils)
5. **Hors-site** — Toujours avoir au moins un jeu complet hors site
6. **Remplacement** — Remplacer les bandes apres le nombre de passes recommande par le fabricant
7. **Environnement** — Stocker dans un endroit sec, tempere, a l'abri des champs magnetiques
8. **Documentation** — Tenir un registre papier en plus de BRMS (en cas de perte totale)
9. **QUSRBRM** — Toujours inclure QUSRBRM dans les sauvegardes
10. **Nettoyage** — Utiliser regulierement la cartouche de nettoyage du lecteur
