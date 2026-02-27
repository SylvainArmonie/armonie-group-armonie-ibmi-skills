---
name: rpg-ile-expert
description: Expert RPG ILE et developpement IBM i AS400. Genere du code RPG full free moderne, SQLRPGLE, consommation de webservices REST, SQL embarque, ecrans 5250 et sous-fichiers. Use when user asks to write RPG code, create DSPF PF LF files, call REST APIs from IBM i, build subfile screens, manipulate JSON, write SQL embedded in RPG, design 5250 interfaces, or troubleshoot RPG compilation errors. Trigger phrases - programme RPG, code RPG, ecran 5250, sous-fichier, SFL, webservice IBM i, SQLRPGLE, appel API REST, fichier PF, fichier LF, DSPF, pagination SFL, full free RPG. Do NOT use for general SQL queries without RPG context, PHP or Java development on IBM i, or IBM i system administration.
---

# RPG ILE Expert - IBM i Development

Skill de reference pour le developpement RPG ILE moderne sur IBM i.
Base sur les travaux de Jean-Christophe Borg (Formateur expert Notos) et Sylvain Aktepe (IBM Champion 2025).

## Instructions

### Etape 1 : Identifier le type de besoin

Analyser la demande et classifier :

| Type de besoin | Reference a lire EN PREMIER | Exemple de script |
|----------------|----------------------------|-------------------|
| Appeler une API REST | `references/webservices.md` | `scripts/crud_api_example.sqlrpgle` |
| Requetes SQL embarquees | `references/sql-embedded.md` | — |
| Tableaux, tri, recherche, agregation | `references/algorithmes.md` | `scripts/agregation_par_categorie.rpgle` |
| Syntaxe RPG moderne / full free | `references/rpg-full-free.md` | `scripts/asyntaxfre.rpgle` |
| Ecrans 5250 et sous-fichiers (SFL) | `references/ecrans-sfl.md` | `scripts/jcborg-example/` |
| Creer PF / LF / DSPF | `references/fichiers-dds.md` | `scripts/jcborg-example/` |
| Validation IBAN | `references/algorithmes.md` | `scripts/calcul_cle_iban.rpgle` |

### Etape 2 : Lire les references AVANT de coder

CRITICAL: Toujours lire le guide de reference correspondant AVANT de generer du code.
Si le besoin couvre plusieurs domaines (ex: ecran SFL + module externe), lire TOUS les guides concernes.

Fichiers de reference disponibles :
- `references/rpg-full-free.md` — Syntaxe RPG full free, dcl-f, dcl-s, dcl-ds, prototypes, BIF
- `references/sql-embedded.md` — Curseurs, EXEC SQL, fetch, insert/update/delete
- `references/webservices.md` — QSYS2.HTTP_GET/POST, JSON_TABLE, parsing JSON
- `references/algorithmes.md` — dim(*auto), %list, sorta, %lookup, agregation, IBAN
- `references/ecrans-sfl.md` — DSPF, SFL, SFLCTL, pagination, READC, fenetres, system(), QCMDEXC
- `references/fichiers-dds.md` — PF, LF, DDS DSPF, compilation

### Etape 3 : Appliquer les regles critiques

Regles OBLIGATOIRES dans tout code genere :

1. **`**FREE` en premiere ligne** — Jamais de format fixe ou /free
2. **`ctl-opt` obligatoire** — Au minimum `dftactgrp(*no) actgrp(*caller)`
3. **Nommage explicite** — `compteurLignes` plutot que `i`, `wNomClient` plutot que `w1`
4. **`const` sur les parametres non modifies** — Systematiquement
5. **Pas d'indicateurs numeriques** — Utiliser `ind` avec noms explicites via renommage pointeur
6. **Commenter en francais** — `// Calcul du montant TTC`
7. **Terminer avec `*inlr = *on`** — Pour liberer les ressources
8. **SQL : verifier SQLSTATE/SQLCODE** — Apres chaque operation SQL
9. **`dcl-ds` pour `likeds()`** — JAMAIS `dcl-s` avec `likeds` (erreur RNF3438)
10. **`setll` uniquement sur fichier `keyed`** — Sinon close/open pour repositionner
11. **SFLDSP en logique positive** — `32 SFLDSP` dans le DSPF, PAS `N32 SFLDSP`
12. **Pas d'accents dans les DDS** — Uniquement ASCII dans les constantes DSPF
13. **CA/CF uniquement au niveau format avec INDARA** — Pas au niveau fichier (CPD7597)
14. **`system('?...')` pour commandes interactives** — QCMDEXC ne supporte pas le prompting `?`
15. **Tester `SflEnd` avant ROLLUP** — Eviter pagination infinie
16. **Variable `pageStart` pour SRRN** — Ne pas coder `SRRN = 1` en dur

### Etape 4 : Valider avant de fournir le code

Checklist de qualite :

- [ ] `**FREE` en premiere ligne
- [ ] `ctl-opt` avec les options appropriees
- [ ] `dcl-ds` (pas `dcl-s`) pour tout `likeds()` ou `likerec()`
- [ ] `setll` utilise UNIQUEMENT sur fichiers `keyed` — sinon close/open
- [ ] Variables declarees avec types appropries
- [ ] Gestion d'erreurs SQL (verification SQLSTATE apres chaque EXEC SQL)
- [ ] `*inlr = *on` en fin de programme
- [ ] Code commente, SANS accents dans les DDS
- [ ] Pour les SFL : SFLDSP en logique POSITIVE (`32` pas `N32`), `pageStart` pour SRRN, test `SflEnd` avant ROLLUP
- [ ] Pour les SFL : touches CA au niveau format uniquement si INDARA
- [ ] Pour commandes interactives : `system('?...')` au lieu de QCMDEXC
- [ ] Pour modules externes : BNDDIR cree avec module AVANT CRTBNDRPG
- [ ] Pour webservices : gestion du code HTTP retour, parsing JSON robuste

## Exemples

### Exemple 1 : Creer un programme qui appelle une API REST

Utilisateur dit : "Je veux appeler une API REST qui retourne des produits en JSON"

Actions :
1. Lire `references/webservices.md` pour les patterns HTTP_GET et JSON_TABLE
2. Consulter `scripts/crud_api_example.sqlrpgle` pour un exemple complet
3. Generer un programme SQLRPGLE avec appel QSYS2.HTTP_GET, parsing JSON, gestion erreurs
4. Fournir les instructions de compilation : `CRTSQLRPGI OBJ(MABIB/MONPGM) SRCFILE(MABIB/QSOURCES) COMMIT(*NONE) DBGVIEW(*SOURCE)`

Resultat : Programme SQLRPGLE compilable qui consomme l'API et traite la reponse JSON.

### Exemple 2 : Creer un ecran avec sous-fichier pagine

Utilisateur dit : "Je veux un ecran de gestion d'objets avec sous-fichier"

Actions :
1. Lire `references/ecrans-sfl.md` pour les patterns SFL/SFLCTL et les regles critiques
2. Lire `references/fichiers-dds.md` pour la creation du DSPF
3. Consulter `scripts/jcborg-example/` pour l'exemple complet
4. Generer dans cet ORDRE :
   - Le DSPF avec SFL (`32 SFLDSP` logique positive, touches CA au niveau format, pas d'accents)
   - Le programme RPG avec pagination (`pageStart` variable, test `SflEnd` avant ROLLUP)
   - Le module externe si couleurs/fonctions partagees (`dcl-ds` pour retour `likeds`)
5. Fournir les commandes de compilation dans l'ordre : CRTDSPF, CRTRPGMOD (module), CRTBNDDIR, ADDBNDDIRE, CRTBNDRPG
6. Pour les options interactives (CRTDUPOBJ, RNMOBJ, CHGOBJD) : utiliser `system('?...')` pas QCMDEXC

Resultat : Application 5250 complete avec liste paginee, couleurs, et actions sur les enregistrements.

### Exemple 3 : Algorithme de traitement de donnees

Utilisateur dit : "Je dois trier et agreger des donnees par categorie"

Actions :
1. Lire `references/algorithmes.md` pour dim(*auto), sorta, agregation
2. Consulter `scripts/agregation_par_categorie.rpgle` pour l'exemple
3. Generer un programme RPG utilisant tableaux dynamiques, tri sorta, agregation
4. Fournir le code avec `CRTBNDRPG` et `DBGVIEW(*SOURCE)`

Resultat : Programme RPG performant avec traitement des donnees en memoire.

## Troubleshooting

### RNF3438/RNF3601 - likeds sur dcl-s
**Cause** : `dcl-s wVar likeds(maDS)` — `likeds` est interdit sur `dcl-s`.
**Solution** : Utiliser `dcl-ds wVar likeds(maDS)`. Regle : `dcl-s` = variable simple, `dcl-ds` = structure.

### RNF7055 - setll sur fichier non-keyed
**Cause** : `setll *loval MONFMT` sur un fichier sans mot-cle `keyed` (ex: sortie DSPOBJD, OUTFILE).
**Solution** : Fermer et rouvrir le fichier (`close` puis `open`). Voir `references/ecrans-sfl.md` section "Fichier non-keyed".

### RNF7023 - Mot-cle non admis
**Cause** : BIF ou syntaxe non supportee par la version IBM i.
**Solution** : Verifier version avec `DSPDTAARA DTAARA(QSS1MRI)`. `%list`, `%range`, `for-each` necessitent IBM i 7.4+.

### CPD7597 - Doublon touche fonction DSPF
**Cause** : CA03/CA12 declare au niveau fichier ET format avec `INDARA`.
**Solution** : Avec `INDARA`, declarer les touches UNIQUEMENT au niveau format (record level).

### CPD7482/CPD7484 - Caracteres invalides DDS
**Cause** : Accents (e, e, a, c) dans les constantes DSPF.
**Solution** : Pas d'accents dans les DDS. Ecrire `Bibliotheque` pas `Bibliothèque`.

### SFL vide malgre donnees chargees
**Cause** : `N32 SFLDSP` (logique negative) alors que RPG met `*in32 = *on` (logique positive).
**Solution** : Utiliser `32 SFLDSP` (logique POSITIVE). Convention : `32`=SFLDSP, `N31`=SFLDSPCTL, `31`=SFLCLR, `90`=SFLEND.

### Pagination infinie (ROLLUP sans fin)
**Cause 1** : `SRRN = 1` code en dur avant chaque `exfmt`.
**Cause 2** : Pas de test `SflEnd` avant ROLLUP.
**Solution** : Variable `pageStart` + `if not SflEnd` avant pagination. Voir `references/ecrans-sfl.md`.

### Erreur de liage - Module externe non trouve
**Cause** : `CRTBNDRPG` avec `bnddir('MONDIR')` mais BNDDIR inexistant ou module absent.
**Solution** : Ordre : 1. `CRTRPGMOD` 2. `CRTBNDDIR` 3. `ADDBNDDIRE` 4. `CRTBNDRPG`

### Commande interactive silencieuse (QCMDEXC)
**Cause** : `QCMDEXC` ne supporte pas le prefixe `?` pour le prompting. Commandes CRTDUPOBJ, RNMOBJ, CHGOBJD echouent silencieusement.
**Solution** : Utiliser `system()` C (bnddir QC2LE) avec prefixe `?`. Voir `references/ecrans-sfl.md`.

### SQL0204 - QSYS2.HTTP_GET non trouve
**Cause** : Fonctions HTTP QSYS2 non disponibles.
**Solution** : Verifier PTF installees. Contacter admin IBM i.

### SQL0501 - Curseur non ouvert
**Cause** : FETCH sur curseur non ouvert ou deja ferme.
**Solution** : Verifier sequence DECLARE, OPEN, FETCH, CLOSE. Voir `references/sql-embedded.md`.

## Prerequis IBM i

- IBM i 7.3 ou superieur (verifier avec `DSPDTAARA DTAARA(QSS1MRI)`)
- IBM i 7.4+ recommande pour BIF modernes (%list, %range, select/when-in)
- Fonctionnalites QSYS2.HTTP_* activees pour les webservices
- Compilateurs : CRTSQLRPGI pour SQLRPGLE, CRTRPGMOD + CRTPGM ou CRTBNDRPG pour RPG pur

## Performance Notes

- CRITICAL: Toujours lire les references AVANT de generer du code
- Qualite et conformite aux standards IBM i > rapidite de reponse
- Ne pas sauter les etapes de validation (checklist ci-dessus)
- Pour les programmes complexes (SFL + module + API), proceder etape par etape
- Verifier chaque piege connu (dcl-ds vs dcl-s, setll keyed, N32 vs 32, accents, QCMDEXC vs system)
