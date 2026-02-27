# Methodologie de Lecture de Code RPG II Cycle

## Table des matieres
1. [Methode d'analyse systematique](#methode-danalyse)
2. [Grille de lecture des specifications](#grille-de-lecture)
3. [Simulation manuelle du cycle](#simulation-manuelle)
4. [Exemple 1 : bongap1.rpg (cycle simple)](#exemple-1)
5. [Exemple 2 : bongap2.rpg (cycle avec rupture)](#exemple-2)
6. [Pieges courants](#pieges-courants)
7. [Questions pedagogiques types](#questions-types)

---

## Methode d'analyse systematique

Pour lire un programme RPG II utilisant le cycle, suivre cet ordre :

### Passe 1 : Identifier les fichiers (spec F)

Chercher dans les specifications F :
- **IP** = Input Primary → fichier lu automatiquement par le cycle
- **IS** = Input Secondary → fichier secondaire (lu apres le primaire ou en concordance)
- **IF** = Input Full procedural → fichier lu manuellement (hors cycle)
- **O PRINTER** = fichier d'impression
- **OF** ou **OA-OV** = indicateur de depassement de capacite
- **E** = fichier decrit en externe (externally described)
- **K** = acces par cle

**Question a se poser** : "Quel fichier est lu par le cycle ? Quel fichier est pour la sortie ?"

### Passe 2 : Examiner les tableaux (spec E)

Si des specifications E existent :
- Nom du tableau, nombre d'elements, taille de chaque element
- Les donnees sont apres `**` en fin de source

### Passe 3 : Analyser les entrees (spec I)

Pour chaque format d'enregistrement :
- **Indicateur d'entree** (colonnes 19-20) : quel numero ?
- **Indicateurs de rupture** : quels champs ont L1, L2... ?
- **Champs de concordance** : quels champs ont M1, M2... ?
- **Renommage de champs** (ex: COULEUR → COLOR)

**Question a se poser** : "Quand un enregistrement est lu, quel indicateur s'allume ? Sur quel champ y a-t-il des ruptures ?"

### Passe 4 : Decoder les calculs (spec C)

Pour chaque ligne de calcul :
- **Colonnes 7-8 (L1-L9, LR, SR)** : traitement total ou sous-programme
  - Vide = traitement DETAIL (etape 16)
  - L1-L9/LR = traitement TOTAL (etape 11)
  - SR = sous-programme
- **Colonnes 9-17 (indicateurs de condition)** : dans quelle condition ?
- **Colonnes 18-27 (Factor 1)**, **28-32 (Operation)**, **33-42 (Factor 2)**, **43-48 (Resultat)**

### Passe 5 : Decoder les sorties (spec O)

Pour chaque bloc de sortie :
- **Type de sortie** (colonne 15 sur la ligne de controle) :
  - **H** = Header (en-tete) → s'execute a l'etape 2
  - **D** = Detail → s'execute a l'etape 2
  - **T** = Total → s'execute a l'etape 12
  - **E** = Exception (EXCEPT) → s'execute manuellement
- **Indicateurs de condition** : 1P, OF, 33, L1, LR, etc.
- **OR** : condition alternative (OU)
- **Champs et constantes** a imprimer

### Passe 6 : Lire les donnees de compilation

Apres `**` en fin de source : valeurs des tableaux.

---

## Grille de lecture des specifications

### Specification F (Fichier) — Structure colonnes

```
Col 6      : F (type specification)
Col 7-14   : Nom du fichier (8 car max)
Col 15     : Type de fichier (I=input, O=output, U=update, C=combined)
Col 16     : Designation du fichier
             P = Primary (cycle)
             S = Secondary (cycle)
             R = Record address
             T = Table
             F = Full procedural (hors cycle)
             (vide) = sortie
Col 17     : Fin de fichier (E = End of file processing)
Col 18     : Sequence (A=ascending, D=descending)
Col 19     : Type de format
             E = Externally described
             F = Fixed format (program-described)
Col 24-27  : Taille enregistrement (si F)
Col 33-34  : Indicateur de depassement (OF, OA-OV)
Col 40-46  : Device (DISK, PRINTER, WORKSTN, etc.)
Col 31     : K = acces par cle
```

### Specification I (Entree) — Ligne de controle d'enregistrement

```
Col 6      : I (type specification)
Col 7-14   : Nom du format d'enregistrement (si fichier externe)
Col 15-16  : Sequence (NS = Normal Sequence)
Col 19-20  : Indicateur d'entree (01-99)
```

### Specification I (Entree) — Ligne de definition de champ

```
Col 6      : I (type specification)
Col 43-48  : Nom du champ source (dans le fichier)
Col 53-58  : Nom du champ resultat (renommage dans le programme)
Col 59-60  : Indicateur de rupture (L1-L9)
Col 61-62  : Indicateur de concordance (M1-M9)
Col 63-64  : Indicateur de champ (01-99)
```

### Specification C (Calcul)

```
Col 6      : C (type specification)
Col 7-8    : Indicateur de niveau (L1-L9, LR, SR)
              → L1-L9/LR = traitement TOTAL
              → SR = sous-programme
              → vide = traitement DETAIL
Col 9-11   : Indicateur condition 1 (Nxx = inverse)
Col 12-14  : Indicateur condition 2
Col 15-17  : Indicateur condition 3
Col 18-27  : Factor 1
Col 28-32  : Code operation (ADD, SUB, MULT, DIV, MOVE, etc.)
Col 33-42  : Factor 2
Col 43-48  : Zone resultat
Col 49-51  : Longueur resultat
Col 52     : Decimales
Col 53     : H=half-adjust, P=padding, N=no-lock
Col 54-55  : Indicateur HI/NR (positif/non trouve)
Col 56-57  : Indicateur LO/ER (negatif/erreur)
Col 58-59  : Indicateur EQ/EOF (egal/fin fichier)
```

### Specification O (Sortie) — Ligne de controle

```
Col 6      : O (type specification)
Col 7-14   : Nom du fichier
Col 15     : Type de sortie : H, D, T, E
Col 16-18  : Saut avant impression (lignes ou canal)
Col 19-20  : Saut apres impression
Col 23-31  : Indicateurs de condition (numero indicateur ou 1P, OF, L1, LR)
             OR : condition alternative
```

### Specification O (Sortie) — Ligne de champ

```
Col 6      : O (type specification)
Col 32-37  : Nom du champ a imprimer
Col 38-39  : Edit code (1-4, A-D, J-M, Z, etc.)
Col 40-43  : Position de fin du champ (ou +n pour relatif)
Col 45-70  : Constante entre quotes
```

---

## Simulation manuelle du cycle

Pour bien comprendre un programme, simuler son execution avec des donnees fictives :

### Methode :

1. **Inventer 5-10 enregistrements** de donnees avec les champs du fichier
2. **Tracer un tableau** avec les colonnes : N° tour, Enregistrement lu, Indicateurs actifs, Calculs executes, Sorties produites
3. **Derouler le cycle** etape par etape pour chaque enregistrement

### Exemple de tableau de simulation :

| Tour | Enregistrement | Indic. entree | Rupture | Calcul detail | Calcul total | Sortie |
|------|---------------|---------------|---------|---------------|-------------|--------|
| 0 | (debut) | 1P | — | — | — | H: en-tete (1P) |
| 1 | Haribo, Fraise, 2.50 | 33 | L1 (1ere!) | ADD PRIX→TOTP | (saute) | D: detail |
| 2 | Haribo, Citron, 1.80 | 33 | — | ADD PRIX→TOTP | — | D: detail |
| 3 | Tagada, Framboise, 3.00 | 33 | L1 | ADD PRIX→TOTP | RAZ, TOTAL L1 | T: total, D: detail |
| ... | ... | ... | ... | ... | ... | ... |
| fin | (plus de records) | LR | L1+LR | — | TOTAL final | T: total LR |

---

## Exemple 1 : bongap1.rpg — Programme cycle simple

### Code source :
```
     FBONBONL1IP  E           K        DISK
     FQPRINT  O   F     132     OF     PRINTER
     E                    TBB     1   2 80
     IFBONBON     33
     I              COULEUR                         COLOR
     OQPRINT  H  1 1   1P
     O       OR        OF
     O                         TBB,1
     O        H        1P
     O       OR        OF
     O                         TBB,2
     O        H        1P
     O       OR        OF
     O                         TBB,1
     O        D        33
     O                                      '|'
     O                         NUMBER  +  1
     ... (suite des champs)
** TBB
|-------|---------------------|---------------------|--------|
| CLE   | MARQUE              | NOM                 | PRIX   |
```

### Analyse detaillee :

**Spec F** :
- `BONBONL1` : fichier en entree, **IP** (Input Primary) → lu par le cycle !
- `E` : fichier decrit en externe (les champs viennent du DDS/DDL)
- `K` : acces par cle
- `QPRINT` : fichier impression, sortie (O), format fixe 132 colonnes, **OF** = indicateur de depassement

**Spec E** :
- `TBB` : tableau de 1 ensemble de 2 elements, chaque element fait 80 caracteres
- Les donnees sont apres `**` en fin de source (les lignes de bordure du tableau)

**Spec I** :
- `FBONBON 33` : format BONBON, indicateur d'entree **33**
- `COULEUR → COLOR` : le champ COULEUR est renomme COLOR dans le programme

**Spec C** :
- AUCUNE ! Pas de calculs. Le programme ne fait que lire et imprimer.

**Spec O** :
- 3 lignes **H** (en-tete) conditionnees par **1P** (premiere page) **OR OF** (depassement)
  - Impriment TBB,1 (bordure), TBB,2 (en-tete colonnes), TBB,1 (bordure)
- 1 ligne **D** (detail) conditionnee par **33** (enregistrement BONBON lu)
  - Imprime les champs NUMBER, MARQUE, NOM, PRIX avec des separateurs `|`

### Deroulement du cycle :

1. **Premier tour** : 1P actif → impression des 3 lignes H (bordure, en-tete, bordure)
2. **Chaque enregistrement BONBON** : indicateur 33 actif → impression de la ligne D
3. **Depassement de page** : OF actif → re-impression des 3 lignes H
4. **Fin de fichier** : LR → programme termine (pas de sortie T definie)

C'est un programme de **listing simple** : en-tete + lignes de detail pour chaque bonbon.

---

## Exemple 2 : bongap2.rpg — Programme avec rupture

### Code source (abrege) :
```
     FBONBONL2IP  E           K        DISK
     FQPRINT  O   F     132     OF     PRINTER
     E                    TBB     1   2 80
     IFBONBON     33
     I                                              MARQUEL1
     I              COULEUR                         COLOR
     C   L1                MOVE *ZERO     TOTP    62
     C   L1                MOVE *ZERO     QTE     60
     C   L1                MOVE *ZERO     RST     62
     C   L1                MOVE *ZERO     PMOY    62
     C                     ADD  PRIX      TOTP
     C                     ADD  1         QTE
     C           TOTP      DIV  QTE       PMOY
     C                     ADD  RST       PMOY
     O        D        33       (detail des bonbons)
     O        T        L1       (total par marque)
     O                  50 '| TOTAL :'
     O                  TOTP  4
     O                  '  NB ART:'
     O                  QTE   1
     O                  '  PRIX MOYEN :'
     O                  PMOY  4
** TBB
|-------|---------------------|---------------------|--------|
| CLE   | MARQUE              | NOM                 | PRIX   |
```

### Analyse detaillee :

**Spec I** :
- `MARQUE L1` : **rupture L1 sur le champ MARQUE** — quand la marque change, une rupture est declenchee

**Spec C — Traitement TOTAL (L1 en col 7-8)** :
```
C   L1                MOVE *ZERO     TOTP    62  ← RAZ total prix a la rupture
C   L1                MOVE *ZERO     QTE     60  ← RAZ quantite
C   L1                MOVE *ZERO     RST     62  ← RAZ reste
C   L1                MOVE *ZERO     PMOY    62  ← RAZ prix moyen
```
Ces lignes s'executent a l'**etape 11** (traitement total) quand L1 est actif.
ATTENTION : elles remettent a zero les compteurs POUR LE NOUVEAU GROUPE.
L'ordre est important : les sorties totaux (etape 12) utilisent les valeurs AVANT la RAZ.

**CORRECTION** : En fait, dans ce programme, les lignes L1 en spec C sont **en debut de programme** et servent a reinitialiser les compteurs APRES la sortie total. L'ordre exact depend du placement :
- Si le traitement total RAZ est APRES que les valeurs aient ete imprimees (etape 12), c'est correct
- En realite, l'etape 11 s'execute AVANT l'etape 12, donc les valeurs sont remises a zero AVANT l'impression total

**PIEGE** : Dans ce programme specifique, la RAZ se fait a l'etape 11, PUIS la sortie total a l'etape 12 imprime les valeurs DEJA remises a zero. C'est un **bug potentiel** si les totaux sont importants. La bonne pratique serait de faire la RAZ dans le traitement detail apres la rupture, ou de stocker les totaux dans des variables temporaires.

**Spec C — Traitement DETAIL (pas de Lx en col 7-8)** :
```
C                     ADD  PRIX      TOTP         ← accumule le prix
C                     ADD  1         QTE          ← compte les articles
C           TOTP      DIV  QTE       PMOY         ← calcule le prix moyen
C                     ADD  RST       PMOY         ← ajoute le reste de la division
```
Ces lignes s'executent a l'**etape 16** (traitement detail) pour chaque enregistrement.

**Spec O** :
- `D 33` : detail pour chaque bonbon (comme bongap1)
- `T L1` : total par marque — imprime les totaux quand la marque change

### Deroulement avec des donnees fictives :

Supposons les enregistrements (fichier trie par MARQUE) :
```
Haribo  | Fraise    | 2.50
Haribo  | Citron    | 1.80
Tagada  | Framboise | 3.00
Tagada  | Menthe    | 2.20
```

| Tour | Enreg. | Rupture | Detail | Total | Sortie |
|------|--------|---------|--------|-------|--------|
| 0 | (debut) | — | — | — | H: en-tetes (1P) |
| 1 | Haribo/Fraise/2.50 | L1 (1ere!) | TOTP=2.50, QTE=1 | (sautee) | D: Haribo Fraise 2.50 |
| 2 | Haribo/Citron/1.80 | — | TOTP=4.30, QTE=2 | — | D: Haribo Citron 1.80 |
| 3 | Tagada/Framboise/3.00 | L1 | TOTP=3.00, QTE=1 | T: Total Haribo | D: Tagada Framboise 3.00 |
| 4 | Tagada/Menthe/2.20 | — | TOTP=5.20, QTE=2 | — | D: Tagada Menthe 2.20 |
| fin | (EOF) | L1+LR | — | T: Total Tagada | (fin programme) |

---

## Pieges courants

### 1. Confondre colonnes 7-8 et colonnes 9-17
- **Col 7-8** : L1-L9/LR = traitement **TOTAL** (etape 11). Marque le MOMENT d'execution.
- **Col 9-17** : indicateurs de **condition** = DANS QUELLE CONDITION executer. S'applique au traitement detail (etape 16).

```
CL1                ADD  X         Y            ← TOTAL : s'execute a la rupture L1
C   L1             ADD  X         Y            ← DETAIL : s'execute si L1 est actif (condition)
```

### 2. Oublier que le transfert est a l'etape 15
Les zones de traitement pendant le traitement total contiennent les ANCIENNES valeurs.

### 3. Oublier que la premiere rupture saute le total
Au premier enregistrement, la rupture est detectee (premier groupe) mais les etapes 11-12 sont sautees car il n'y a pas de groupe precedent.

### 4. Ne pas comprendre l'ordre total → detail
Le traitement total (etape 11) s'execute AVANT le traitement detail (etape 16). C'est contre-intuitif mais logique : on ferme l'ancien groupe avant d'ouvrir le nouveau.

### 5. Confondre H, D et T
- **H et D** : etape 2 (AVANT la lecture)
- **T** : etape 12 (APRES le traitement total)

### 6. Pas de READ dans le code
Normal ! Le fichier IP est lu automatiquement par le cycle. Si vous voyez un READ, c'est soit un fichier IF (full procedural), soit un programme hybride.

---

## Questions pedagogiques types

Pour verifier la comprehension d'un eleve :

1. "Dans ce programme, quel fichier est lu par le cycle ? Comment le sais-tu ?"
   → Reponse : le fichier avec **IP** dans la spec F

2. "Pourquoi n'y a-t-il pas de READ dans le code ?"
   → Reponse : le cycle lit automatiquement le fichier primaire (IP)

3. "A quelle etape du cycle s'execute cette ligne de calcul ?"
   → Si Lx en col 7-8 : etape 11 (total). Sinon : etape 16 (detail).

4. "Quand l'en-tete H est-elle imprimee ?"
   → Etape 2, conditionnee par 1P (1er passage) ou OF (saut de page)

5. "Pourquoi la sortie T L1 imprime les bonnes valeurs de total ?"
   → Parce que le transfert (etape 15) n'a pas encore eu lieu : les zones de traitement contiennent encore les valeurs de l'ancien groupe

6. "Que se passe-t-il au dernier enregistrement ?"
   → LR est active, ce qui active aussi tous les L1-L9. Le traitement total et la sortie total finaux s'executent, puis le programme s'arrete.

7. "Pourquoi les indicateurs d'entree sont-ils remis a zero avant la lecture ?"
   → Pour qu'un seul indicateur soit actif a la fois (celui de l'enregistrement qui va etre lu)
