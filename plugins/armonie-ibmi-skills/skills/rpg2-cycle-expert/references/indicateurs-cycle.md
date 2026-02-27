# Indicateurs du Cycle Logique RPG II

## Table des matieres
1. [Vue d'ensemble des indicateurs](#vue-densemble)
2. [Indicateur 1P (First Page)](#indicateur-1p)
3. [Indicateur LR (Last Record)](#indicateur-lr)
4. [Indicateurs d'entree (01-99)](#indicateurs-dentree)
5. [Indicateurs de rupture (L1-L9)](#indicateurs-de-rupture)
6. [Indicateurs de depassement (OF, OA-OG, OV)](#indicateurs-de-depassement)
7. [Indicateurs de concordance (MR, M1-M9)](#indicateurs-de-concordance)
8. [Indicateurs de champ](#indicateurs-de-champ)
9. [Indicateurs de commande (KA-KY)](#indicateurs-de-commande)
10. [Indicateurs externes (U1-U8)](#indicateurs-externes)
11. [Indicateurs de resultat (HI/LO/EQ)](#indicateurs-de-resultat)
12. [Resume par etape du cycle](#resume-par-etape)

---

## Vue d'ensemble des indicateurs

Les indicateurs sont des **variables booleennes** (ON/OFF) qui controlent le flux du programme. En RPG II, il n'y a PAS de variables booleennes nommees — tout passe par des indicateurs numeriques.

Le cycle logique gere automatiquement certains indicateurs. Le programmeur peut aussi les manipuler manuellement avec SETON/SETOF.

### Familles d'indicateurs

| Famille | Identifiants | Gere par le cycle ? | Role |
|---------|-------------|--------------------:|------|
| First Page | 1P | OUI | Premiere page/premier passage |
| Last Record | LR | OUI (ou manuel) | Dernier enregistrement / fin programme |
| Entree | 01-99 | OUI | Identification du type d'enregistrement |
| Rupture | L1-L9 | OUI | Changement de groupe (control break) |
| Depassement | OF, OA-OG, OV | OUI | Depassement de capacite page |
| Concordance | MR, M1-M9 | OUI | Correspondance entre fichiers |
| Commande | KA-KY | Systeme (ecran) | Touche de fonction pressee |
| Externes | U1-U8 | Non (jobstream) | Passes par l'environnement |
| Champ | 01-99 | OUI (sur champ) | Etat d'un champ (positif, zero, negatif, blanc) |
| Resultat | HI, LO, EQ | Semi-auto | Resultat d'une operation (COMP, CHAIN, READ...) |

---

## Indicateur 1P (First Page)

### Quand est-il active ?
- A l'**etape 1** du cycle (debut du programme), automatiquement

### Quand est-il desactive ?
- A l'**etape 3** du cycle (premier passage uniquement)
- **Il ne sera PLUS JAMAIS reactive**

### Ou l'utilise-t-on ?
- Dans les specifications **O** (sortie) pour conditionner les en-tetes de premiere page
- On peut utiliser **N1P** (1P inverse) dans le programme pour des traitements "tout sauf le premier passage"

### Exemple typique :
```
OQPRINT  H  1 1   1P         ← Imprime l'en-tete au premier passage
O       OR        OF         ← OU au depassement de page
O                  50 'TITRE DU RAPPORT'
O        H        1P
O       OR        OF
O                  50 '========================'
```

### Analogie :
C'est comme le generique d'ouverture d'un film — il ne passe qu'une seule fois, au debut.

---

## Indicateur LR (Last Record)

### Quand est-il active ?
- A l'**etape 6** du cycle, quand la fin de fichier est atteinte (plus d'enregistrements a lire)
- OU manuellement par le programmeur avec `SETON LR` (si fichier non primaire)

### Quand est-il desactive ?
- **JAMAIS** — une fois LR active, il reste actif. LR ne peut PAS etre remis a OFF.

### Effet de LR :
1. Active TOUS les indicateurs de rupture L1-L9
2. Force le dernier traitement total (etape 11)
3. Force la derniere sortie total (etape 12)
4. Termine le programme apres l'etape 12

### Ou l'utilise-t-on ?
```
CLR                ADD  TOTCA     TOTGEN  10 2  ← Calcul total final (etape 11)
OLISTE   T        LR                           ← Sortie total finale (etape 12)
O                  TOTGEN  100                  ← Grand total
```

### Double role :
- **Signal de fin** : "plus d'enregistrements, arrete-toi"
- **Declencheur** : "mais d'abord, fais les derniers totaux"

---

## Indicateurs d'entree (01-99)

### Quand sont-ils actives ?
- A l'**etape 7** du cycle, apres la lecture d'un enregistrement
- Le systeme identifie le format de l'enregistrement et active l'indicateur associe

### Quand sont-ils desactives ?
- A l'**etape 3** du cycle (avant la prochaine lecture)

### Regle fondamentale :
- **Un seul** indicateur d'entree est actif a la fois (celui du format lu)

### Definition dans les specifications I :
```
IBONBON      33          ← indicateur 33 pour les enregistrements BONBON
ICOMMAND     34          ← indicateur 34 pour les enregistrements COMMAND
ICLIENT      35          ← indicateur 35 pour les enregistrements CLIENT
```

La position exacte depend du format :
- **NS** : Normal Sequence (sequence normale)
- Colonnes 19-20 de la specification I : numero de l'indicateur

### Utilisation dans les calculs (C) :
```
C   33                ADD  PRIX      TOTAL   10 2  ← seulement si enregistrement BONBON
C   34                EXSR TRTCMD                   ← seulement si enregistrement COMMAND
```

### Utilisation dans les sorties (O) :
```
O        D        33                          ← detail imprime si indicateur 33 actif
O                  NOM     50
```

---

## Indicateurs de rupture (L1-L9)

### Concept de rupture (control break)

Une **rupture de controle** se produit quand la valeur d'un champ cle change d'un enregistrement au suivant. Cela signifie qu'on change de "groupe".

**Prerequis** : Le fichier DOIT etre trie par le(s) champ(s) de rupture.

### Hierarchie des niveaux

| Niveau | Usage typique | Exemple |
|--------|--------------|---------|
| L1 | Rupture mineure (le plus fin) | Client |
| L2 | | Departement |
| L3 | | Region |
| ... | | |
| L9 | Rupture majeure (le plus haut) | Pays |

### Regle de cascade :
Si L3 est active → L2 et L1 sont AUSSI actives automatiquement.
Si L9 est active → L8, L7, L6, L5, L4, L3, L2, L1 sont TOUS actives.

### Quand sont-ils actives ?
- A l'**etape 8-9** du cycle, quand une rupture est detectee
- A l'**etape 6**, quand LR est active (tous les Lx sont actives)

### Quand sont-ils desactives ?
- A l'**etape 3** du cycle (avant la prochaine lecture)

### Definition dans les specifications I :
```
IFBONBON     33
I                                    MARQUE L1    ← rupture L1 sur le champ MARQUE
```

Le champ de rupture est indique dans les specifications d'entree avec L1-L9 associe au champ.

### Utilisation en traitement total (colonnes 7-8 des specs C) :
```
CL1                MOVE *ZERO     TOTP    62     ← RAZ du total a la rupture L1
CL1                MOVE *ZERO     QTE     60     ← RAZ de la quantite
```

**ATTENTION** : L1-L9 en colonnes 7-8 = **traitement TOTAL** (etape 11). C'est different de L1-L9 en colonnes 9-17 (condition de traitement detail).

### Utilisation en sortie total :
```
O        T        L1                             ← sortie total a la rupture L1
O                  50 '| TOTAL :'
O                  TOTP  4
```

### Le piege classique :
Pendant le traitement total (etape 11), les zones de traitement contiennent encore les **anciennes** valeurs (dernier enregistrement du groupe precedent). Le transfert des nouvelles donnees (etape 15) n'a PAS encore eu lieu.

C'est VOULU : on a besoin des anciennes valeurs pour calculer et imprimer les totaux de l'ancien groupe !

---

## Indicateurs de depassement (OF, OA-OG, OV)

### Quand sont-ils actives ?
- A l'**etape 13** du cycle, quand le compteur de lignes depasse la capacite de la page

### Quand sont-ils desactives ?
- A l'**etape 14**, apres les sorties de depassement

### Declaration :
Dans la specification F du fichier imprimante :
```
FQPRINT  O   F     132     OF     PRINTER
```
- **OF** en colonnes 33-34 : indicateur de depassement pour ce fichier
- On peut utiliser OA, OB, OC, OD, OE, OF, OG ou OV
- Chaque fichier imprimante peut avoir son propre indicateur

### Utilisation typique :
```
OQPRINT  H  1 1   1P         ← en-tete au debut
O       OR        OF         ← OU au saut de page
O                  50 'TITRE'
```

Le `OR OF` signifie : "cette ligne H est aussi imprimee quand OF est actif" → saut de page avec re-impression des en-tetes.

---

## Indicateurs de concordance (MR, M1-M9)

### Concept de concordance (matching records)

La concordance sert a **apparier** les enregistrements de deux fichiers ou plus sur un champ commun (ex: numero de client present dans les deux fichiers).

### Quand est-il active ?
- Automatiquement par le cycle quand un enregistrement du fichier primaire correspond a un enregistrement du fichier secondaire (meme valeur de champ de concordance)

### Utilisation :
```
FCLIENTS IP  E           K   DISK        ← fichier primaire
FCOMMAND IS  E           K   DISK        ← fichier secondaire
I*
ICLIENTFM    33
I            NUMCLI                 M1    ← champ de concordance M1
ICOMMANDFM   34
I            NUMCLI                 M1    ← meme champ de concordance M1
```

Si un client a des commandes correspondantes, MR (ou M1) est active.

---

## Indicateurs de commande (KA-KY)

Utilises avec les fichiers WORKSTN (ecran 5250). Chaque indicateur correspond a une touche de fonction :

| Indicateur | Touche |
|------------|--------|
| KA | F1 (CMD1) |
| KB | F2 (CMD2) |
| KC | F3 (CMD3) |
| ... | ... |
| KY | F24 (CMD24) |

Note : Il n'y a PAS de KO (pour eviter la confusion avec le zero).

---

## Indicateurs externes (U1-U8)

Passes au programme par le jobstream (script de lancement). Ils permettent de parametrer le comportement du programme depuis l'exterieur.

---

## Indicateurs de resultat (HI/LO/EQ)

Places dans les specifications C pour capturer le resultat d'une operation :

| Position | Nom | Signification |
|----------|-----|---------------|
| 54-55 | HI / NR | Positif / Non trouve (CHAIN) |
| 56-57 | LO / ER | Negatif / Erreur |
| 58-59 | EQ / EOF | Egal / Fin de fichier (READ) |

**Exemples** :
```
C           NUMCLI    CHAINCLIENTS              56     ← 56 = non trouve
C                     READ FICHIER                  90 ← 90 = fin de fichier
C           VALA      COMP VALB                 515253 ← 51=hi, 52=lo, 53=eq
```

---

## Resume par etape du cycle

| Etape | Indicateurs actives | Indicateurs desactives |
|-------|--------------------|-----------------------|
| ① | **1P** active | — |
| ② | (sorties H/D selon indicateurs actifs) | — |
| ③ | — | **1P** (1er passage), **entree** (01-99), **rupture** (L1-L9) |
| ④ | (lecture) | — |
| ⑤⑥ | **LR** si fin fichier + tous **L1-L9** | — |
| ⑦ | **indicateur d'entree** du format lu | — |
| ⑧⑨ | **L1-L9** si rupture (avec cascade) | — |
| ⑩ | (test premiere rupture) | — |
| ⑪ | (calculs total avec Lx actifs) | — |
| ⑫ | (sorties total avec Lx actifs) | — |
| ⑬ | **OF/OA-OV** si depassement | — |
| ⑭ | (sorties depassement) | **OF/OA-OV** apres sortie |
| ⑮ | (transfert donnees) | — |
| ⑯ | (calculs detail) | — |
