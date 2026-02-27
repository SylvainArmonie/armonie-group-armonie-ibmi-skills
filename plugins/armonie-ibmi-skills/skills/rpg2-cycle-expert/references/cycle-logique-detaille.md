# Le Cycle Logique RPG - Les 16 Etapes Detaillees

## Table des matieres
1. [Qu'est-ce que le cycle logique ?](#quest-ce-que-le-cycle-logique)
2. [Analogie pedagogique](#analogie-pedagogique)
3. [Les 16 etapes en detail](#les-16-etapes-en-detail)
4. [Le premier passage](#le-premier-passage)
5. [Le dernier passage](#le-dernier-passage)
6. [Les deux zones memoire](#les-deux-zones-memoire)
7. [Resume de l'ordre d'execution](#resume-ordre)

---

## Qu'est-ce que le cycle logique ?

Le **cycle logique** (aussi appele **cycle programme**, **cycle GAP**, ou **programme a cycle implicite**) est le mecanisme central du langage RPG dans ses premieres versions (RPG, RPG II, et partiellement RPG III/400).

C'est une **boucle automatique** generee par le compilateur RPG. Le programmeur n'ecrit PAS de boucle — le compilateur l'ajoute automatiquement. Cette boucle :

1. **Lit** un enregistrement du fichier principal (lecture implicite)
2. **Execute** les calculs definis par le programmeur
3. **Produit** les sorties (impression, ecriture fichier)
4. **Recommence** au point 1

Le cycle s'arrete quand tous les enregistrements ont ete lus (indicateur LR = Last Record active).

### Ce que le cycle automatise (le programmeur n'a PAS a ecrire) :
- `OPEN` : ouverture des fichiers → automatique au demarrage
- `READ` : lecture du fichier primaire → automatique a chaque tour de cycle
- `CLOSE` : fermeture des fichiers → automatique a la fin
- Detection fin de fichier → LR s'active automatiquement
- Gestion des ruptures (control breaks) → L1-L9 s'activent automatiquement
- Gestion du depassement de page → OF s'active automatiquement
- `WRITE` des sorties → automatique selon les conditions H/D/T

### Origine historique

Le cycle reproduit le fonctionnement des **machines tabulatrices** (tab machines) IBM :
- Une carte perforee entre dans la machine
- La machine effectue les operations (comptage, totalisation)
- La machine imprime une ligne sur le rapport
- La carte suivante entre

Le RPG a ete concu pour que les techniciens de machines tabulatrices puissent facilement passer a la programmation. Le cycle etait leur univers familier.

---

## Analogie pedagogique

### L'usine de tri postal

Imaginez une **usine de tri postal** automatisee :

1. Un **tapis roulant** (le cycle) amene les lettres une par une
2. Un **capteur** lit le code postal de chaque lettre (lecture enregistrement)
3. Si le code postal change (ex: on passe du 75 au 13), c'est une **rupture** : on ferme le sac du 75 et on commence un nouveau sac pour le 13
4. Chaque lettre est **dirigee** vers le bon casier (traitement detail)
5. Quand le tapis est vide, on ferme le dernier sac et on arrete la machine (LR)

Le programmeur RPG ne dit pas "fais tourner le tapis" — le tapis tourne tout seul. Il definit seulement :
- **Quoi lire** (specifications F et I)
- **Quoi calculer** (specifications C)
- **Quoi imprimer** (specifications O)

---

## Les 16 etapes en detail

Le cycle est decompose en 16 etapes, numerotees de 1 a 16. Ces etapes se repetent pour CHAQUE enregistrement lu.

### Etape 1 — Debut du programme : Mise en fonction de 1P

**Quand** : Une seule fois, au tout debut du programme.

**Ce qui se passe** :
- Le systeme active l'indicateur **1P** (First Page / 1re Page)
- Les fichiers sont ouverts implicitement
- Les parametres passes au programme sont resolus
- Les tableaux et data areas sont initialises

**1P** ne sera JAMAIS reactive dans tout le programme. Il sert a conditionner les premieres sorties (titres de page, en-tetes de colonnes).

**Analogie** : C'est comme allumer la machine le matin. La lumiere "PREMIER DEMARRAGE" s'allume, et ne se rallumera plus de la journee.

---

### Etape 2 — Sorties en-tete (H) et detail (D)

**Quand** : A chaque tour de cycle, AVANT la lecture du prochain enregistrement.

**Ce qui se passe** :
- Le systeme parcourt toutes les specifications de sortie (O)
- Pour les lignes de type **H** (Header/en-tete) et **D** (Detail) :
  - Si les indicateurs de condition sont actifs → la sortie est produite
  - Peut etre : impression, ecriture fichier, affichage ecran

**Premier passage** : Les lignes conditionnees par **1P** sont imprimees (typiquement les titres et en-tetes de colonnes du rapport).

**Passages suivants** : Les lignes de detail conditionnees par les indicateurs d'entree sont imprimees.

**Exemple** :
```
OQPRINT  H  1 1   1P        ← en-tete imprimee au 1er passage (1P actif)
O       OR        OF        ← OU si depassement de page (OF actif)
O                  TBB,1    ← imprime l'element 1 du tableau TBB
O        D        33        ← detail imprimee si indicateur 33 actif
O                  NOMCLI 50 ← imprime le nom du client en position 50
```

---

### Etape 3 — Mise hors fonction des indicateurs

**Quand** : Juste avant de lire le prochain enregistrement.

**Ce qui se passe** :
- Les indicateurs suivants sont remis a OFF :
  - **1P** (uniquement au premier passage — il ne sera PLUS JAMAIS reactif)
  - Les **indicateurs d'entree** (01-99 associes aux formats d'enregistrement)
  - Les **indicateurs de rupture** (L1-L9) s'ils etaient actifs

**Pourquoi** : On nettoie les indicateurs AVANT de lire le prochain enregistrement pour repartir sur une base propre.

---

### Etape 4 — Lecture d'un enregistrement

**Quand** : A chaque tour de cycle.

**Ce qui se passe** :
- Le systeme lit le prochain enregistrement du **fichier primaire** (IP)
- Ou, si le fichier primaire est epuise, du **fichier secondaire** (IS) suivant
- L'enregistrement est place dans la **zone entree/sortie** (PAS dans les zones de traitement !)
- Il n'y a PAS d'instruction READ dans le source — la lecture est implicite

**POINT CRUCIAL** : Les zones de traitement du programme ne sont PAS encore modifiees ! Les anciennes valeurs sont toujours presentes. C'est une notion fondamentale pour comprendre les ruptures.

**Analogie** : La lettre est posee sur le tapis, mais elle n'a pas encore ete ouverte. On peut voir l'enveloppe (zone entree/sortie) mais pas le contenu (zone de traitement).

---

### Etape 5 — Test de fin de fichier

**Quand** : Apres la tentative de lecture.

**Ce qui se passe** :
- Si aucun enregistrement n'a pu etre lu → fin de fichier detectee
- Dans le cas de fichiers multiples sans concordance :
  - Fin du fichier primaire → on passe au 1er fichier secondaire
  - Fin du 1er secondaire → on passe au suivant
  - Etc.

---

### Etape 6 — Mise en fonction de LR

**Quand** : Si la fin de fichier est atteinte (tous les fichiers lus).

**Ce qui se passe** :
- L'indicateur **LR** (Last Record) est active
- TOUS les indicateurs de rupture L1 a L9 sont egalement actives
- Le programme continuera jusqu'aux etapes 11-12 pour les derniers totaux
- Puis il s'arretera au test "LR en fonction ?" apres l'etape 12

**LR a un double role** :
1. Il signale la fin du programme
2. Il force le dernier traitement et sortie total (les derniers sous-totaux)

---

### Etape 7 — Mise en fonction de l'indicateur d'entree

**Quand** : Apres lecture reussie d'un enregistrement.

**Ce qui se passe** :
- Le systeme identifie le format de l'enregistrement lu
- L'indicateur associe a ce format dans les specifications I est active
- Il y a **un et un seul** indicateur d'entree actif a la fois

**Exemple** : Si 3 fichiers sont declares :
```
IFICHIER1    33    ← indicateur 33 pour les enregistrements de FICHIER1
IFICHIER2    34    ← indicateur 34 pour les enregistrements de FICHIER2
IFICHIER3    35    ← indicateur 35 pour les enregistrements de FICHIER3
```

Quand un enregistrement de FICHIER1 est lu, 33 est actif. Les calculs et sorties conditionnes par 33 s'executeront.

---

### Etape 8 — Test de rupture de controle

**Quand** : Si des indicateurs de rupture (L1-L9) sont definis sur des champs.

**Ce qui se passe** :
- Le systeme compare la valeur du champ de rupture dans le NOUVEL enregistrement avec celle de l'ANCIEN enregistrement
- Si la valeur a change → rupture detectee

**Cascade des ruptures** :
- Si L2 est detecte, alors L1 est AUSSI active automatiquement
- Si L5 est detecte, alors L4, L3, L2, L1 sont TOUS actives
- **Regle** : Si un niveau superieur rompt, tous les niveaux inferieurs rompent aussi

**Exemple** : Fichier de commandes trie par departement puis client
```
I                    NODEPT  L2    ← rupture majeure sur departement
I                    NOCLI   L1    ← rupture mineure sur client
```
Quand le departement change, L2 ET L1 sont actives.

---

### Etape 9 — Mise en fonction des indicateurs de rupture

(Integree a l'etape 8 — les indicateurs sont actives immediatement lors de la detection.)

---

### Etape 10 — Test de premiere rupture

**Quand** : Si une rupture a ete detectee a l'etape 8.

**Ce qui se passe** :
- Le systeme verifie s'il s'agit de la **premiere rupture** du programme
- Si c'est la premiere rupture → on saute les etapes 11 et 12 (pas de traitement/sortie total)
- Pourquoi ? Parce qu'il n'y a pas encore de totaux a imprimer pour un groupe precedent qui n'existe pas

**Analogie** : Le premier sac postal qu'on ouvre n'a pas de sac precedent a fermer. On commence directement a trier.

---

### Etape 11 — Traitement total

**Quand** : Lors d'une rupture (sauf la premiere) ou a la fin du fichier (LR).

**Ce qui se passe** :
- Le systeme execute les instructions C qui ont un indicateur **L1-L9 ou LR en colonnes 7-8**
- Seules les instructions conditionnees par les indicateurs de rupture ACTIFS sont executees

**POINT CRUCIAL** : A cette etape, les zones de traitement contiennent encore les valeurs du **DERNIER enregistrement de l'ancien groupe**. Le nouvel enregistrement est dans la zone entree/sortie mais n'a PAS encore ete transfere.

**Exemple** :
```
CL1                ADD  TOTCLI    TOTDEP  10 2   ← s'execute si L1 est actif
CL2                ADD  TOTDEP    TOTGEN  10 2   ← s'execute si L2 est actif
CLR                ADD  TOTGEN    GRANDT  10 2   ← s'execute si LR est actif
```

---

### Etape 12 — Sorties total

**Quand** : Apres le traitement total.

**Ce qui se passe** :
- Le systeme produit les sorties de type **T** (Total) conditionnees par les indicateurs L1-L9 ou LR actifs

**Exemple** :
```
OLISTE   T        L1           ← sortie total si rupture L1
O                  TOTCLI  50  ← imprime le total client
O        T        L2           ← sortie total si rupture L2
O                  TOTDEP  50  ← imprime le total departement
O        T        LR           ← sortie total en fin de fichier
O                  GRANDT  50  ← imprime le grand total
```

Apres cette etape : **Test LR** — Si LR est actif → FIN DU PROGRAMME. Sinon → continuer.

---

### Etape 13 — Test de depassement de capacite

**Quand** : Apres les sorties total, si LR n'est pas actif.

**Ce qui se passe** :
- Le systeme verifie si le compteur de lignes imprimees depasse la capacite de la page
- Si oui ET qu'un indicateur de depassement (OF, OA-OG, OV) est declare → cet indicateur est active

**Exemple** : Declaration du fichier impression avec OF :
```
FQPRINT  O   F     132     OF     PRINTER
```

---

### Etape 14 — Sorties conditionnees par depassement

**Quand** : Si un indicateur de depassement est actif.

**Ce qui se passe** :
- Les sorties H/D/T conditionnees par OF (ou OA-OG, OV) sont produites
- Typiquement : saut de page + re-impression des en-tetes
- Le compteur de lignes est reinitialise
- L'indicateur de depassement est remis a OFF

---

### Etape 15 — Transfert zone entree/sortie → zone de traitement

**Quand** : Apres le depassement de capacite.

**Ce qui se passe** :
- Les donnees de l'enregistrement lu a l'etape 4 sont ENFIN copiees dans les zones de traitement du programme
- A partir de maintenant, les variables du programme contiennent les valeurs du NOUVEL enregistrement

**C'est l'etape la plus importante a comprendre pour les ruptures !**

Avant etape 15 (pendant le traitement total) :
- Zone entree/sortie = nouvel enregistrement (qui a provoque la rupture)
- Zone de traitement = ancien enregistrement (dernier du groupe precedent)

Apres etape 15 (pendant le traitement detail) :
- Zone entree/sortie = nouvel enregistrement
- Zone de traitement = nouvel enregistrement (transfere)

---

### Etape 16 — Traitement detail

**Quand** : Apres le transfert des donnees.

**Ce qui se passe** :
- Le systeme execute TOUTES les instructions C qui n'ont PAS d'indicateur L1-L9 ou LR en colonnes 7-8
- C'est le traitement "normal" — les calculs sur chaque enregistrement
- Les sous-programmes appeles par EXSR sont executes
- Les boucles, conditions, et autres operations sont traitees

**Apres l'etape 16** : Le cycle retourne a l'etape 2 (sorties H/D) → puis etape 3 (remise a zero indicateurs) → etape 4 (lecture suivante) → etc.

---

## Le premier passage (cycle initial)

Le tout premier tour de cycle est special :

1. **Etape 1** : 1P est active. Les fichiers sont ouverts.
2. **Etape 2** : Les sorties conditionnees par 1P sont produites (en-tetes du rapport)
3. **Etapes 3-4** : 1P est desactive. Premier enregistrement lu.
4. **Etapes 5-7** : Fin de fichier testee, indicateur d'entree active.
5. **Etapes 8-10** : Si rupture → c'est forcement la PREMIERE → pas de total.
6. **Etapes 11-12** : SAUTEES (premiere rupture)
7. **Etape 15** : Donnees transferees dans les zones de traitement.
8. **Etape 16** : Premier traitement detail.

---

## Le dernier passage (cycle final)

Le dernier tour de cycle :

1. **Etape 4** : Tentative de lecture → echec (plus d'enregistrements)
2. **Etape 5-6** : LR est active. L1-L9 sont TOUS actives.
3. **Etapes 11-12** : Dernier traitement total et dernier sortie total (sous-totaux finaux, grand total)
4. **Test LR** : LR est actif → le programme s'arrete
5. Les fichiers sont fermes implicitement

---

## Les deux zones memoire

C'est le concept le plus delicat du cycle logique :

### Zone entree/sortie (I/O area)
- Buffer ou l'enregistrement est place lors de la lecture (etape 4)
- Utilisee pour la detection des ruptures (etape 8)
- Les donnees y restent jusqu'au prochain READ

### Zone de traitement (Processing area)
- Zone ou les variables du programme sont stockees
- Alimentee par le transfert de l'etape 15
- C'est cette zone que les calculs (C) et sorties (O) utilisent

### Pourquoi deux zones ?
Pour permettre au traitement total de fonctionner correctement :
- La rupture est detectee en comparant l'ancienne valeur (zone traitement) avec la nouvelle (zone entree/sortie)
- Le traitement total s'execute avec les ANCIENNES valeurs (zone traitement)
- ENSUITE seulement, le transfert a lieu et les nouvelles valeurs deviennent disponibles

---

## Resume de l'ordre d'execution

```
DEBUT → ① 1P ON
  ↓
② Sorties H et D
  ↓
③ RAZ indicateurs (1P, entree, rupture)
  ↓
④ READ (zone entree/sortie)
  ↓
⑤⑥ Fin fichier ? → LR ON
  ↓
⑦ Indicateur entree ON
  ↓
⑧⑨ Rupture ? → L1-L9 ON
  ↓
⑩ 1ere rupture ? → sauter total
  ↓
⑪ Calculs TOTAL (C avec Lx col 7-8)
⑫ Sorties TOTAL (O type T avec Lx)
  ↓
LR ON ? → FIN
  ↓
⑬⑭ Depassement ? → sorties OF
  ↓
⑮ TRANSFERT → zones de traitement MAJ
  ↓
⑯ Calculs DETAIL (C sans Lx col 7-8)
  ↓
→ retour ②
```
