---
name: rpg2-cycle-expert
description: Expert RPG II et cycle logique GAP (programme a cycle implicite). Explique les 16 etapes du cycle logique RPG, les indicateurs (1P, LR, L1-L9, OF, OA-OV, MR, M1-M9, 01-99), les specifications positionnelles (H/F/E/L/I/C/O), fichiers primaires/secondaires, ruptures de controle, concordances, depassement de capacite. Lit et explique du code RPG II cycle a un debutant avec analogies pedagogiques. Use when user asks about cycle logique RPG, programme GAP, cycle GAP, RPG II cycle, programme a cycle implicite, comprendre le cycle RPG, lire un programme cycle, fichier primaire IP, indicateur 1P LR, rupture L1 L2, sortie total T, sortie detail D, sortie en-tete H, depassement capacite OF, concordance MR, 16 etapes cycle. Do NOT use for RPG III procedural (use rpg3-expert), RPG ILE (use rpg-ile-expert), or SQL.
---

# RPG II - Expert Cycle Logique GAP

Skill specialise dans la comprehension et l'explication du **cycle logique RPG** (aussi appele **cycle GAP** ou **programme a cycle implicite**). Ce skill est concu pour la pedagogie : expliquer le cycle a des debutants, lire du code RPG II utilisant le cycle, et decrypter chaque etape du traitement automatique.

## Contexte historique

Le cycle logique est l'heritage direct des **machines tabulatrices** (tab machines) d'IBM. Ces machines lisaient des cartes perforees une par une, effectuaient des calculs et imprimaient des resultats dans un cycle repetitif. Quand IBM a cree le langage RPG (Report Program Generator) dans les annees 1960, ils ont reproduit ce fonctionnement : le programme tourne en boucle automatiquement sur chaque enregistrement d'un fichier, sans que le programmeur n'ecrive de boucle explicite.

**RPG II** (fin des annees 1960, System/3, System/34, System/36) est la version qui a popularise ce cycle. En France, on appelle souvent ces programmes des **programmes GAP** (Generateur Automatique de Programmes) ou **programmes a cycle**.

## Instructions

### Etape 1 : Identifier le type de demande

| Type de demande | Reference a lire EN PREMIER |
|-----------------|---------------------------|
| Comprendre le cycle logique (les 16 etapes) | `references/cycle-logique-detaille.md` |
| Comprendre les indicateurs du cycle | `references/indicateurs-cycle.md` |
| Lire/expliquer un programme RPG II cycle | `references/lecture-code-cycle.md` puis les 2 autres |
| Comprendre les specifications (H/F/E/I/C/O) | `references/specifications-rpg2.md` |
| Ecrire un programme simple avec le cycle | Lire TOUTES les references |

### Etape 2 : Lire les references AVANT de repondre

**CRITICAL** : Toujours lire le(s) guide(s) de reference correspondant(s) AVANT de repondre. Le cycle logique est un concept complexe qui necessite precision. Ne jamais repondre de memoire sur les etapes du cycle.

Fichiers de reference disponibles :
- `references/cycle-logique-detaille.md` — Les 16 etapes du cycle, schema de fonctionnement, premier et dernier passage
- `references/indicateurs-cycle.md` — Tous les indicateurs : 1P, LR, L1-L9, OF/OA-OV, MR/M1-M9, indicateurs d'entree 01-99, indicateurs de champ
- `references/lecture-code-cycle.md` — Methodologie pour lire et expliquer du code cycle a un debutant, avec exemples annotes
- `references/specifications-rpg2.md` — Les specifications positionnelles H, F, E, L, I, C, O et leur role dans le cycle

Scripts d'exemple :
- `scripts/bongap1.rpg` — Programme cycle simple : lecture fichier primaire, en-tetes, detail (bonbons)
- `scripts/bongap2.rpg` — Programme cycle avec rupture L1, calcul totaux, prix moyen par marque

### Etape 3 : Principes pedagogiques obligatoires

Quand on explique le cycle logique a un debutant :

1. **Toujours commencer par l'analogie** — Le cycle est comme une chaine de montage automatique : les pieces (enregistrements) arrivent une par une, passent par des postes de travail (etapes), et le resultat sort automatiquement. Le programmeur ne dit PAS "lis le prochain enregistrement" — la machine le fait toute seule.

2. **Insister sur ce qui est IMPLICITE** — Le cycle automatise :
   - Ouverture des fichiers (pas de OPEN)
   - Lecture sequentielle (pas de READ pour le fichier primaire)
   - Detection fin de fichier (LR s'active tout seul)
   - Fermeture des fichiers (pas de CLOSE)
   - Gestion des sauts de page (OF)
   - Detection des ruptures (L1-L9)

3. **Toujours situer dans le schema des 16 etapes** — Quand on explique une ligne de code, dire a quelle etape du cycle elle s'execute. Exemples :
   - "Cette ligne `O D 33` s'execute a l'etape 2 (sorties detail)"
   - "Ce calcul avec `L1` en colonnes 7-8 s'execute a l'etape 11 (traitement total)"
   - "Cette sortie `T LR` s'execute a l'etape 12 (sortie total)"

4. **Utiliser le vocabulaire correct** :
   - **Fichier primaire (IP)** = le fichier principal lu par le cycle
   - **Fichier secondaire (IS)** = fichier lu apres le primaire ou en concordance
   - **Fichier full procedural (IF)** = fichier lu manuellement (pas par le cycle)
   - **Traitement detail** = calculs executes pour chaque enregistrement (etape 16)
   - **Traitement total** = calculs executes lors d'une rupture (etape 11)
   - **Sortie en-tete (H)** = lignes d'en-tete imprimees (etape 2)
   - **Sortie detail (D)** = lignes de detail imprimees (etape 2)
   - **Sortie total (T)** = lignes de total imprimees (etape 12)
   - **Rupture de controle** = changement de groupe detecte sur un champ cle
   - **Zone entree/sortie** vs **zone de traitement** = deux zones memoire differentes !

5. **Rappeler le point crucial de l'etape 15** — Les donnees lues a l'etape 4 ne sont transferees dans les zones de traitement qu'a l'etape 15. Pendant le traitement total (etape 11), les zones contiennent encore les valeurs du DERNIER enregistrement du groupe precedent. C'est le piege classique du cycle !

### Etape 4 : Comment lire un programme RPG II cycle

Methode systematique pour analyser un programme cycle :

```
1. SPECIFICATIONS F (Fichiers)
   → Reperer : IP (primaire cycle), IS (secondaire), IF (full procedural)
   → Reperer : O PRINTER (fichier impression), OF (indicateur depassement)
   → Reperer : E (fichier decrit en externe)

2. SPECIFICATIONS E (Extensions)
   → Tableaux charges a la compilation (donnees apres **)

3. SPECIFICATIONS I (Entree)
   → Indicateurs d'entree (colonnes 19-20) : quel indicateur pour quel format ?
   → Indicateurs de rupture : L1, L2... sur quels champs ?
   → Renommage de champs (COULEUR → COLOR par exemple)

4. SPECIFICATIONS C (Calculs)
   → Colonnes 7-8 : L1-L9/LR = traitement TOTAL (etape 11)
   → Colonnes 7-8 : vides/SR = traitement DETAIL (etape 16)
   → Colonnes 9-17 : indicateurs de condition

5. SPECIFICATIONS O (Sorties)
   → H = en-tete (etape 2, conditionne par 1P, OF, etc.)
   → D = detail (etape 2, conditionne par indicateurs d'entree)
   → T = total (etape 12, conditionne par L1-L9, LR)

6. DONNEES ** (fin de source)
   → Valeurs des tableaux charges a la compilation
```

### Etape 5 : Schema simplifie du cycle (a donner aux debutants)

```
┌─────────────────────────────────────────────────┐
│                  DEBUT DU PROGRAMME              │
│              ① Mise en fonction 1P               │
└──────────────────────┬──────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────┐
│  ② SORTIES EN-TETE (H) ET DETAIL (D)            │◄──────┐
│     (conditionnees par indicateurs actifs)        │       │
└──────────────────────┬───────────────────────────┘       │
                       ▼                                    │
┌──────────────────────────────────────────────────┐       │
│  ③ Mise hors fonction indicateurs (1P, entree,   │       │
│     rupture L1-L9)                                │       │
└──────────────────────┬───────────────────────────┘       │
                       ▼                                    │
┌──────────────────────────────────────────────────┐       │
│  ④ LECTURE d'un enregistrement                    │       │
│     (dans la zone entree/sortie)                  │       │
└──────────────────────┬───────────────────────────┘       │
                       ▼                                    │
┌──────────────────────────────────────────────────┐       │
│  ⑤⑥ Fin de fichier ? → OUI → LR = ON            │       │
└──────────────────────┬───────────────────────────┘       │
                       ▼                                    │
┌──────────────────────────────────────────────────┐       │
│  ⑦ Mise en fonction indicateur d'entree           │       │
└──────────────────────┬───────────────────────────┘       │
                       ▼                                    │
┌──────────────────────────────────────────────────┐       │
│  ⑧⑨ Rupture de controle ? → OUI → L1-L9 = ON   │       │
└──────────────────────┬───────────────────────────┘       │
                       ▼                                    │
┌──────────────────────────────────────────────────┐       │
│  ⑩ Premiere rupture ? → OUI → sauter total       │       │
└──────────────────────┬───────────────────────────┘       │
                       ▼                                    │
┌──────────────────────────────────────────────────┐       │
│  ⑪ TRAITEMENT TOTAL (C avec L1-L9/LR col 7-8)   │       │
│  ⑫ SORTIE TOTAL (O avec T et L1-L9/LR)          │       │
└──────────────────────┬───────────────────────────┘       │
                       ▼                                    │
┌──────────────────────────────────────────────────┐       │
│  LR en fonction ? → OUI → FIN DU PROGRAMME       │       │
└──────────────────────┬───────────────────────────┘       │
                       ▼                                    │
┌──────────────────────────────────────────────────┐       │
│  ⑬⑭ Depassement capacite ? → sorties OF          │       │
└──────────────────────┬───────────────────────────┘       │
                       ▼                                    │
┌──────────────────────────────────────────────────┐       │
│  ⑮ TRANSFERT zone entree/sortie → zone traitement│       │
└──────────────────────┬───────────────────────────┘       │
                       ▼                                    │
┌──────────────────────────────────────────────────┐       │
│  ⑯ TRAITEMENT DETAIL (C sans L1-L9 col 7-8)     │       │
└──────────────────────┬───────────────────────────┘       │
                       │                                    │
                       └────────────────────────────────────┘
                            (retour a l'etape 2)
```

### Etape 6 : Differences cles avec RPG III procedural

| Aspect | RPG II Cycle (GAP) | RPG III Procedural |
|--------|--------------------|--------------------|
| Lecture fichier | **Implicite** (cycle lit automatiquement) | **Explicite** (READ, CHAIN) |
| Boucle principale | **Implicite** (cycle boucle automatiquement) | **Explicite** (DOWEQ, DOU) |
| Ouverture/fermeture | **Implicite** | Implicite ou explicite (OPEN/CLOSE) |
| Fin programme | **LR active automatiquement** a fin de fichier | LR active manuellement (SETON LR) |
| Ruptures | **Gerees par le cycle** (L1-L9 automatiques) | A programmer manuellement |
| Sorties | **H/D/T conditionnees par indicateurs** | WRITE explicite ou EXCEPT |
| Complexite lecture | Difficile (il faut connaitre le cycle) | Plus lineaire, plus lisible |

## Exemples d'utilisation

### Exemple 1 : Expliquer le cycle a un debutant

Utilisateur : "C'est quoi le cycle logique en RPG ?"

Actions :
1. Lire `references/cycle-logique-detaille.md`
2. Commencer par l'analogie de la chaine de montage
3. Presenter le schema simplifie des 16 etapes
4. Montrer un exemple concret avec `scripts/bongap1.rpg`

### Exemple 2 : Lire un programme GAP

Utilisateur : "Explique-moi ce programme RPG II"

Actions :
1. Lire `references/lecture-code-cycle.md`
2. Appliquer la methode d'analyse systematique (F → E → I → C → O)
3. Pour chaque bloc, expliquer a quelle etape du cycle il s'execute
4. Simuler un passage du cycle avec des donnees fictives

### Exemple 3 : Comprendre les ruptures

Utilisateur : "Comment marchent les ruptures L1, L2 dans le cycle ?"

Actions :
1. Lire `references/indicateurs-cycle.md` section ruptures
2. Lire `references/cycle-logique-detaille.md` etapes 8-12
3. Montrer avec `scripts/bongap2.rpg` comment L1 est utilise
4. Expliquer le piege de l'etape 15 (zone entree/sortie vs zone traitement)

## Troubleshooting pedagogique

### "Je ne comprends pas pourquoi le READ n'est pas dans le code"
→ C'est normal ! Le cycle lit automatiquement. Le fichier est declare IP (Input Primary), donc le cycle prend en charge la lecture. C'est l'etape 4 du cycle.

### "Pourquoi les calculs totaux s'executent AVANT les calculs detail ?"
→ C'est l'ordre du cycle ! Etapes 11-12 (total) PUIS etapes 15-16 (detail). Quand une rupture est detectee, il faut d'abord imprimer les totaux de l'ANCIEN groupe avant de commencer le nouveau.

### "Pourquoi les donnees ne sont pas a jour pendant le traitement total ?"
→ C'est l'etape 15 ! Les donnees lues a l'etape 4 ne sont transferees dans les zones de traitement qu'a l'etape 15, APRES le traitement total. Donc pendant le traitement total (etape 11), on travaille encore avec les donnees de l'ancien groupe.

### "C'est quoi la difference entre H, D et T dans les sorties ?"
→ H (Header/en-tete) et D (Detail) sont imprimes a l'etape 2. T (Total) est imprime a l'etape 12. H sert aux titres de colonnes/pages, D aux lignes de donnees, T aux sous-totaux et totaux.

## Prerequis

- Connaissance basique de l'IBM i (AS/400)
- Comprehension du concept d'enregistrement et de fichier
- Le programme RPG II cycle se compile avec `CRTRPGPGM` (comme RPG III)
- Source dans un fichier QRPGSRC en membre type RPG
