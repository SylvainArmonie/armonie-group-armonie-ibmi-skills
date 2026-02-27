---
name: rpg3-expert
description: Expert RPG III (RPG/400) sur IBM i en format colonnes. Genere du code RPG III avec specifications positionnelles (H/F/E/I/C/O), indicateurs, conditions IFxx, boucles DOWxx/DOUxx/DO, acces fichiers (READ, CHAIN, SETLL, WRITE, UPDAT, DELET), sous-programmes (EXSR/BEGSR/ENDSR), appels externes (CALL/PARM), ecrans 5250 (EXFMT/DSPF), sous-fichiers, KLIST/KFLD, tableaux, CAT, GOTO/TAG, REDPE, COMP, verrouillage N. Base sur la documentation officielle IBM RPG/400 Help. Use when user asks to write RPG III code, understand legacy RPG/400 programs, convert RPG III to RPG ILE, create DSPF screens for RPG III, explain column-based RPG syntax, or troubleshoot RPG III compilation errors. Trigger phrases - RPG III, RPG/400, RPG 3, GAP, programme RPG colonnes, format fixe RPG, indicateurs RPG, SETON LR, CRTRPGPGM, code RPG ancien, legacy RPG, programme GAP, migrer RPG III, convertir RPG III. Do NOT use for RPG ILE full free (use rpg-ile-expert instead), SQLRPGLE, or modern RPG with ctl-opt and dcl-s.
---

# RPG III (RPG/400) Expert - IBM i Development

Skill de reference pour le developpement et la maintenance de programmes RPG III (RPG/400) sur IBM i.
Enrichi avec la documentation officielle IBM RPG/400 Help (Copyright IBM Corporation 1992, 2006).

## Instructions

### Etape 1 : Identifier le type de besoin

Analyser la demande et classifier :

| Type de besoin | Reference a lire EN PREMIER | Exemple de script |
|----------------|----------------------------|-------------------|
| Syntaxe RPG III, specifications, structure programme | `references/syntaxe-specifications.md` | `scripts/syntaxrpg3.rpg` |
| Acces fichiers, CRUD base de donnees | `references/acces-fichiers.md` | `scripts/rpg3.rpg` |
| Ecrans 5250, DSPF, sous-fichiers en RPG III | `references/ecrans-dspf.md` | `scripts/psoldat.rpg`, `scripts/esoldat.dspf` |
| Sous-programmes, appels externes, CALL/PARM | `references/sous-programmes.md` | `scripts/arm400.rpg` |
| Calculs, conditions, boucles, tableaux, CAT, GOTO | `references/syntaxe-specifications.md` | `scripts/rimpots.rpg`, `scripts/tableau.rpg` |
| Comprendre/analyser un programme RPG III existant | `references/syntaxe-specifications.md` + `references/acces-fichiers.md` | — |
| Migrer RPG III vers RPG ILE | `references/migration-ile.md` | — |

### Etape 2 : Lire les references AVANT de coder

CRITICAL: Toujours lire le guide de reference correspondant AVANT de generer du code RPG III.
Si le besoin couvre plusieurs domaines (ex: ecran + fichiers + calculs), lire TOUS les guides concernes.

Fichiers de reference disponibles :
- `references/syntaxe-specifications.md` — Specifications H/F/E/L/I/C/O, indicateurs, conditions, boucles, arithmetique, tableaux, data structures, CAT (concatenation), GOTO/TAG, LEAVE/ITER, COMP, MOVE/MOVEL avec padding
- `references/acces-fichiers.md` — SETLL, SETGT, READ, READE, READP, REDPE, READC, CHAIN, WRITE, UPDAT, DELET, KLIST/KFLD, option N (no-lock), indicateur EQ sur SETLL, constantes figuratives
- `references/ecrans-dspf.md` — DSPF pour RPG III, EXFMT, WORKSTN, CF/CA, couleurs, formats multiples, sous-fichiers
- `references/sous-programmes.md` — EXSR, BEGSR/ENDSR, *PSSR, *INZSR, CALL, PARM, PLIST, RETRN, FREE, CAS/ENDCS, EXFMT, groupement des references programme
- `references/migration-ile.md` — Guide de migration RPG III vers RPG ILE full free

### Etape 3 : Appliquer les regles critiques RPG III

Regles OBLIGATOIRES dans tout code RPG III genere :

1. **Format colonnes strict** — RPG III est positionnel. La specification (H/F/E/I/C/O) est en colonne 6. Ne JAMAIS utiliser le format libre.
2. **Ordre des specifications** — Toujours respecter : H, F, E, L, I, C, O
3. **Position 6 = type de specification** — H, F, E, L, I, C ou O. Un `*` en position 7 indique un commentaire.
4. **Indicateurs obligatoires** — RPG III utilise des indicateurs (01-99, LR, *INxx) pour le controle de flux. Pas de variables booleennes.
5. **Terminer avec SETON LR** — Toujours terminer le programme en activant l'indicateur LR (Last Record).
6. **Noms limites a 6 caracteres** — Les noms de variables et fichiers sont limites a 6-8 caracteres maximum selon le contexte.
7. **Fichiers declares en F** — Chaque fichier utilise doit etre declare dans une specification F avec type d'acces (I/O/U/C), format (E/F), cle (K), et device (DISK/WORKSTN/PRINTER).
8. **Commenter avec * en colonne 7** — Les commentaires commencent par `*` en colonne 7, ou par `*` apres la specification C pour les commentaires en ligne.
9. **Compilation avec CRTRPGPGM** — Pas CRTBNDRPG (qui est pour ILE).
10. **EXFMT pour ecrans** — Utiliser EXFMT (Write+Read) pour les fichiers WORKSTN, pas de WRITE/READ separes sauf besoin specifique.
11. **Pas de dcl-s, dcl-f, ctl-opt** — Ce sont des syntaxes ILE. En RPG III, tout est declaré via les specifications positionnelles.
12. **Tableaux via spec E** — Les tableaux sont declares en specification E, pas via `dcl-s dim()`.
13. **Donnees de compilation apres `**`** — Les donnees de tables/tableaux charges a la compilation sont placees apres `**` en fin de source.
14. **Position 53 = N pour no-lock** — Sur READ, READE, READP, REDPE, CHAIN : N en position 53 lit sans verrouiller. Indispensable quand on ne fait pas de UPDAT apres.
15. **Position 53 = P pour padding** — Sur MOVE, MOVEL, CAT : P en position 53 padde le resultat avec des blancs ou zeros.
16. **Sous-programmes speciaux** — *PSSR pour la gestion d'erreurs programme, *INZSR pour l'initialisation automatique.

### Etape 4 : Structure des colonnes en specification C (Traitement)

```
Positions :  7-8   = Indicateur de controle (niveau L1-L9, LR, SR)
             9-17  = Indicateurs de condition (N01-N99)
             18-27 = Factor 1
             28-32 = Code operation (ADD, SUB, IFEQ, READ, etc.)
             33-42 = Factor 2
             43-48 = Zone resultat
             49-51 = Longueur zone resultat
             52    = Decimales
             53    = H (half-adjust), P (padding), N (no-lock)
             54-55 = Indicateur Hi/NR (positif, non trouve)
             56-57 = Indicateur Lo/ER (negatif, erreur)
             58-59 = Indicateur Eq/EOF/BOF (egal, fin/debut fichier)
             60-74 = Commentaires
```

### Etape 5 : Valider avant de fournir le code

Checklist de qualite :

- [ ] Specification en colonne 6 (F, E, I, C, O)
- [ ] Commentaires avec `*` en colonne 7
- [ ] Ordre H, F, E, L, I, C, O respecte
- [ ] Fichiers declares en spec F avec bon type d'acces et device
- [ ] Indicateur LR active en fin de programme (SETON LR)
- [ ] Indicateurs de fin de fichier utilises (ex: 90 sur READ col 58-59)
- [ ] Indicateur non-trouve sur CHAIN (col 54-55, PAS 58-59)
- [ ] Variables definies avec longueur et decimales dans la zone resultat
- [ ] KLIST/KFLD pour les cles composees (ordre des KFLD = ordre des cles dans le fichier)
- [ ] Donnees `**` en fin de source pour les tableaux a la compilation
- [ ] Noms respectant la limite de 6-8 caracteres
- [ ] Pas de syntaxe ILE (dcl-s, ctl-opt, **FREE, etc.)
- [ ] Option N en position 53 pour les lectures sans besoin de UPDAT
- [ ] Sous-programme *PSSR defini pour la gestion d'erreurs

## Exemples

### Exemple 1 : Hello World en RPG III

Utilisateur dit : "Fais-moi un Hello World en RPG III"

Actions :
1. Lire `references/syntaxe-specifications.md` pour MOVEL, MOVE, DSPLY, SETON
2. Generer un programme simple avec affichage console

Resultat :
```
     C                     MOVEL'Hello'    HELLO  13
     C                     MOVE 'World !'  HELLO
     C           HELLO     DSPLY
     C                     SETON                     LR
```

Compilation : `CRTRPGPGM PGM(MABIB/MONPGM) SRCFILE(MABIB/QRPGSRC)`

### Exemple 2 : Lire tous les enregistrements d'un fichier

Utilisateur dit : "Je veux lire tout le fichier CLIENT et afficher les prenoms"

Actions :
1. Lire `references/acces-fichiers.md` pour SETLL, READ, DOWEQ
2. Consulter `scripts/rpg3.rpg` pour l'exemple complet
3. Generer un programme avec boucle de lecture et indicateur de fin de fichier

Resultat : Programme RPG III compilable avec boucle DOWEQ et indicateur 90.

### Exemple 3 : Programme CRUD avec ecran 5250

Utilisateur dit : "Je veux un ecran de gestion avec creation, modification et suppression"

Actions :
1. Lire `references/ecrans-dspf.md` pour la structure DSPF et les formats
2. Lire `references/acces-fichiers.md` pour CHAIN, WRITE, UPDAT, DELET
3. Consulter `scripts/psoldat.rpg` et `scripts/esoldat.dspf` pour un exemple complet
4. Generer dans cet ORDRE :
   - Le DSPF avec formats multiples (FMT1 saisie ID, FMT2 modification, FMT3 creation)
   - Le programme RPG III avec gestion des touches de fonction (*INKC, *INKF, *INKL, etc.)
5. Fournir les commandes de compilation : CRTDSPF puis CRTRPGPGM

Resultat : Application 5250 complete avec CRUD et messages utilisateur.

### Exemple 4 : Sous-fichier en RPG III

Utilisateur dit : "Je veux un ecran avec une liste paginee (sous-fichier)"

Actions :
1. Lire `references/ecrans-dspf.md` section sous-fichiers RPG III
2. Consulter `scripts/arm400.rpg` pour l'exemple complet
3. Generer le DSPF avec SFL/SFLCTL et le programme RPG III avec READC, WRITE SFL
4. Indicateurs : 30=SFLCLR, 31=SFLDSP, 32=SFLDSPCTL, 33=SFLEND

### Exemple 5 : Concatenation avec CAT

Utilisateur dit : "Je veux concatener un nom et un prenom"

Actions :
1. Lire `references/syntaxe-specifications.md` section CAT
2. Generer le code avec CAT et nombre de blancs

Resultat :
```
     C           NOM       CAT  PRENOM:1 NOMCPT 30P
```

### Exemple 6 : Verifier l'existence d'une cle sans CHAIN

Utilisateur dit : "Je veux juste verifier si un client existe, sans lire le record"

Actions :
1. Lire `references/acces-fichiers.md` section SETLL avec indicateur EQ
2. Generer le code avec SETLL et indicateur en col 58-59

Resultat :
```
     C           NUMCLI    SETLLCLIENT                    55
     C           *IN55     IFEQ '1'
     C           'EXISTE'  DSPLY
     C                     ENDIF
```

## Troubleshooting

### Erreur de compilation "specification hors sequence"
**Cause** : Les specifications ne sont pas dans l'ordre H, F, E, L, I, C, O.
**Solution** : Reorganiser le source dans le bon ordre.

### Indicateur LR non active - programme reste en memoire
**Cause** : Pas de `SETON LR` en fin de programme.
**Solution** : Ajouter `C SETON LR` avant la fin du source.

### READ ne lit pas le bon enregistrement
**Cause** : Pas de SETLL avant le premier READ.
**Solution** : Utiliser `SETLL *LOVAL fichier` pour positionner au debut du fichier.

### UPDAT echoue avec "MAJ ou SUPP sans READ ou CHAIN prealable"
**Cause** : Un UPDAT ou DELET est execute sans avoir fait un READ ou CHAIN avant, OU la lecture a ete faite avec N (no-lock) en position 53.
**Solution** : Toujours lire l'enregistrement (READ ou CHAIN) **sans N en position 53** avant de le modifier (UPDAT) ou le supprimer (DELET). Le verrouillage est necessaire.

### Variable tronquee apres MOVE
**Cause** : La zone resultat est plus petite que le facteur 2.
**Solution** : MOVE aligne a droite (tronque a gauche), MOVEL aligne a gauche (tronque a droite). Ajuster la longueur de la zone resultat. Utiliser **P en position 53** pour padder avec des blancs/zeros.

### Tableau non charge - valeurs a zero
**Cause** : Donnees `**` manquantes en fin de source pour les tableaux charges a la compilation.
**Solution** : Ajouter les lignes `**` suivies des donnees du tableau apres la derniere ligne de code.

### CHAIN avec indicateur non-trouve en mauvaise position
**Cause** : Indicateur de non-trouve place en col 58-59 au lieu de col 54-55.
**Solution** : Pour CHAIN, l'indicateur **non-trouve** va en **col 54-55** (NR). Les col 58-59 doivent etre vides. Pour READ/READE, l'indicateur EOF va bien en col 58-59.

### READE retourne EOF alors que des records existent
**Cause** : Cle packed avec format interne different. Si le fichier utilise X'123C' (packed +123) et que l'argument est 123, le RPG utilise X'123F'.
**Solution** : S'assurer que l'argument de recherche correspond exactement au format interne de la cle. Verifier le type de cle dans le DDS.

### REDPE echoue juste apres SETGT
**Cause** : SETGT positionne apres la cle specifiee. Le record precedent n'a jamais la meme cle que le record courant apres SETGT.
**Solution** : Utiliser CHAIN, SETLL, READ, READP ou READE (avec Factor 1) pour positionner avant un REDPE.

### CALL echoue avec "programme non trouve"
**Cause** : Le nom du programme contient des blancs, des minuscules ou des guillemets inattendus.
**Solution** : Verifier que le litterral dans CALL ne contient pas de blancs autour du `/`. Les minuscules ne sont PAS converties en majuscules. Les guillemets font partie du nom.

### CAT produit des blancs inattendus
**Cause** : Les blancs de fin de Factor 1 sont inclus dans le resultat quand le nombre de blancs n'est pas specifie.
**Solution** : Toujours specifier le nombre de blancs apres `:` (ex: `CAT FLD:1`) pour controler les espaces. Utiliser P en position 53 pour padder le resultat.

### Fichier positionne en fin apres SETLL/SETGT echoue
**Cause** : Quand SETLL ou SETGT ne trouve aucun record correspondant, le fichier est positionne en fin de fichier.
**Solution** : Verifier l'indicateur NR (col 54-55) apres SETLL/SETGT avant de faire un READ.

## Prerequis IBM i

- Compilateur RPG III : commande `CRTRPGPGM`
- Fichier source QRPGSRC avec RCDLEN(80) minimum
- PDM (STRPDM) ou SEU (STRSEU) pour editer les sources
- Pour les ecrans : CRTDSPF pour compiler les Display Files
- Utilitaire DSPPGMREF pour verifier les references de programmes appeles (CALL)
