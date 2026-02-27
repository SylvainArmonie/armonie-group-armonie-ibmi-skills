# RPG Full Free - Guide de syntaxe moderne

## Déclaration du format Full Free

```rpgle
**free
```

Doit être sur la première ligne du fichier source (minuscule accepté).

## Carte H - Options de contrôle (ctl-opt)

```rpgle
**free
// Carte H
ctl-opt dftactgrp(*no) actgrp(*caller) datfmt(*iso) timfmt(*iso);
```

### Options courantes

| Option | Description |
|--------|-------------|
| `dftactgrp(*no)` | Désactive le groupe d'activation par défaut (requis pour SQL et ILE) |
| `actgrp(*caller)` | Utilise le groupe d'activation de l'appelant |
| `option(*srcstmt)` | Numéros de ligne source dans les messages |
| `option(*nodebugio)` | Exclut I/O du debug |
| `datfmt(*iso)` | Format date ISO (AAAA-MM-JJ) |
| `timfmt(*iso)` | Format heure ISO (HH.MM.SS) |

## Carte F - Déclaration de fichiers (dcl-f)

### Fichier écran (WORKSTN)

```rpgle
dcl-f ECRAN1   WORKSTN;  // fichier Ecran
```

### Fichiers physiques (PF) et logiques (LF)

```rpgle
// Fichier physique PF en lecture seule avec clé
dcl-f CLIENT USAGE(*INPUT) keyed;

// Fichier physique PF avec toutes les opérations et clé
dcl-f FICHIERPF USAGE(*INPUT:*DELETE:*UPDATE:*OUTPUT) keyed;

// Fichier physique PF sans clé
dcl-f FICHIERPF2 USAGE(*INPUT:*DELETE:*UPDATE:*OUTPUT);

// Fichier logique LF avec clé
dcl-f FICHIERLF USAGE(*INPUT:*DELETE:*UPDATE:*OUTPUT) keyed;

// Fichier PF avec prefix pour renommer les champs
dcl-f FICHIERPF3 disk USAGE(*UPDATE:*DELETE:*OUTPUT:*INPUT) keyed
  prefix(FICPF_);  // Ajoute un préfixe aux champs du fichier
```

### Fichier imprimante (PRTF)

```rpgle
dcl-f PRTF1 printer;                       // Fichier PRTF simple
dcl-f PRTF1 printer oflind(INDPage);       // Fichier PRTF avec débordement personnalisé
```

### Récapitulatif USAGE

| USAGE | Description |
|-------|-------------|
| `*INPUT` | Lecture |
| `*OUTPUT` | Écriture (Write) |
| `*UPDATE` | Mise à jour (Update) |
| `*DELETE` | Suppression (Delete) |

## Carte D - Déclaration de variables

### Variables numériques

```rpgle
// Zoned : chaque chiffre stocké dans un octet
Dcl-S wZoned       Zoned(4:0);
Dcl-S wZoned2      Zoned(10:2);   // avec 2 décimales : ex 12.10

// Packed : deux chiffres décimaux par octet (plus compact)
Dcl-S wPacked      Packed(5);
Dcl-S wPacked2     Packed(5) INZ(100);   // initialisé à 100
Dcl-S wResultat    Packed(10:2);          // avec 2 décimales

// Entiers
Dcl-S wInteger     Int(10);      // entier signé sur 4 octets (-2147483648 à 2147483647)
Dcl-S wBin         Bindec(9);    // entier signé sur 4 octets (32 bits)
Dcl-S wBigInt      Bigint(63);   // entier sur 8 octets

// Virgule flottante
Dcl-S wFloat       Float(8);
```

### Variables caractères

```rpgle
// Caractère fixe (toujours 8 positions)
Dcl-S wPhrase      Char(8);

// Chaîne variable (jusqu'à 255 caractères)
Dcl-S wPhrase2     Varchar(255);

// Initialisée avec des blancs
Dcl-S wSpaceVal    Char(1) inz(*BLANKS);

// Initialisée avec une valeur
Dcl-S wNom         Char(7) inz('Sylvain');

// Tableau de caractères (10 éléments de 1 caractère)
dcl-s wTableau     char(1) dim(10);
```

### Variables date

```rpgle
Dcl-S wDateIso     Date(*ISO);     // Format ISO : AAAA-MM-JJ
Dcl-S wDateMdy     Date(*MDY);     // Format MDY : MM/JJ/AA
```

### Constantes

```rpgle
Dcl-C CON_1 CONST(1);
Dcl-C CON_2 CONST('test');
Dcl-C MAX_LIGNES 100;
Dcl-C URL_API 'https://api.example.com';
Dcl-C TVA 0.20;
```

### Indicateurs

```rpgle
dcl-s wTrouve      ind inz(*off);     // Booléen
```

## Structures de données (DS)

### DS simple avec positions

```rpgle
Dcl-DS InputDs;
  UserSpace      Char(20)   Pos(1);
  SpaceName      Char(10)   Pos(1);
  SpaceLib       Char(10)   Pos(11);
  InpFileLib     Char(20)   Pos(29);
  InpFFilNam     Char(10)   Pos(29);
  InpFFilLib     Char(10)   Pos(39);
  InpRcdFmt      Char(10)   Pos(49);
End-DS;

// Remplissage
SpaceName = 'ESPCLIENT';
SpaceLib = 'LIB1';
InpFFilNam = 'ARTICLE';
InpFFilLib = 'LIBDATA';
InpRcdFmt = 'FMT01';

// Utilisation : les champs se superposent grâce aux positions
dsply UserSpace;     // ESPCLIENTLIB1
dsply InpFileLib;    // ARTICLELIBDATA
```

### DS qualified

```rpgle
dcl-ds client qualified;
    id        int(10);
    nom       char(50);
    email     char(100);
    actif     ind;
end-ds;

// Utilisation avec le qualificateur
client.id = 123;
client.nom = 'DUPONT';
```

### DS avec DTAARA (Data Area)

```rpgle
DCL-DS data_struct;
  mydtaara CHAR(100) DTAARA;
END-DS;
```

### DS tableau

```rpgle
dcl-ds produits dim(50) qualified;
    ref       char(20);
    libelle   char(100);
    prix      packed(9:2);
end-ds;

// Utilisation
produits(1).ref = 'PRD001';
produits(1).prix = 29.99;
```

## Prototypes et interfaces (DCL-PR / DCL-PI)

### Appel de programme externe

```rpgle
// Prototype : déclare le programme externe à appeler
DCL-PR myPgm EXTPGM('MYPGM1');
  name CHAR(10) CONST options(*nopass);
END-PR;

// Appel
callp myPGM('sylvain');
```

### Interface du programme courant

```rpgle
// Interface : déclare les paramètres reçus par CE programme
DCL-PI *n;
  name CHAR(10) CONST;
END-PI;
```

## Opérations sur fichiers

### Positionnement et lecture

```rpgle
Setll *loval FICHIERPF;      // Se positionner au début du fichier

Read FICHIERPF;               // Lire l'enregistrement suivant
```

### Écriture et mise à jour

```rpgle
Write FICHIERFM;              // Écrire un enregistrement (format du fichier)
Update FICHIERFM;             // Mettre à jour l'enregistrement courant
```

### Accès direct par clé (Chain)

```rpgle
// Accès par clé simple
Chain key FICHIERPF;

// Accès par clé composite (plus de klist/kfld en full free)
Chain (key1:key2:key3) FICHIERPF;
```

### Affichage écran

```rpgle
Exfmt ecranfm1;              // Afficher et attendre saisie utilisateur
```

## Structures de contrôle

### IF / ELSEIF / ELSE

```rpgle
// SI simple
If wPacked2 = 8;
  wPhrase = 'test';
endif;

// SI avec conditions multiples
if wPacked2 = 7 or wPacked = 9;
  wPhrase = 'test2';
elseif wPacked = 10;
  wPhrase = 'bob';
else;
  wPhrase = 'roger';
endif;
```

### SELECT / WHEN (Selon)

```rpgle
Select;
When S_OPT = '1';
  exsr OPTION1;
When S_OPT = '2';
  exsr OPTION2;
When S_OPT = '4';
  exsr OPTION4;
When S_OPT = '5';
  exsr OPTION5;
Other;
  exsr main;
Endsl;
```

### Boucles

```rpgle
// DOW - Tant que (condition vraie → on boucle)
Dow Not %eof();
  Read FICHIERPF;
enddo;

// DOW infini
dow 1=1;
  wPhrase = 'toto';
  leave;  // Sortie de boucle
enddo;

// DOU - Jusqu'à (condition vraie → on sort)
Dou wZoned = 8;
  wZoned += 1;
enddo;

// DOU avec indicateur
dou *in03=*on;
  Exfmt ecranfm1;
enddo;

// FOR
for i = 1 to 10;
  dsply %char(i);
endfor;

// LEAVE = sort de la boucle
// ITER  = passe à l'itération suivante
```

## Sous-routines (BEGSR / ENDSR)

```rpgle
exsr main;     // Appel de la sous-routine

BEGSR MAIN;
  READC EXPD_SFL;
  DOW NOT %EOF();
    select;
    When S_OPT = '1';
      exsr OPTION1;
    When S_OPT = '2';
      exsr OPTION2;
    When S_OPT = '4';
      exsr OPTION4;
    When S_OPT = '5';
      exsr OPTION5;
    Other;
      exsr VALIDATE;
    Endsl;
    READC EXPD_SFL;
  ENDDO;
  MODE='1';
ENDSR;
```

> **Note** : Les sous-routines sont tolérées mais les **procédures (dcl-proc)** sont préférées en RPG moderne car elles offrent un meilleur encapsulation et des variables locales.

## Procédures (dcl-proc)

### Fonction avec retour de valeur

```rpgle
resultat = Addition(25.50 : 14.25);  // Appel → resultat = 39.75
dsply ('Le résultat est : ' + %char(resultat));

dcl-proc Addition;
  dcl-pi *n packed(10:2);        // Type de retour
    num1 packed(10:2) value;     // Paramètre 1 en entrée
    num2 packed(10:2) value;     // Paramètre 2 en entrée
  end-pi;
  dcl-s wTotal zoned(10:2);     // Variable locale

  return num1 + num2;
end-proc;
```

### Procédure d'initialisation sous-fichier

```rpgle
initialisation_sous_fichier();   // Appel

dcl-proc initialisation_sous_fichier;
  rang = *zero;       // Initialisation du compteur d'enregistrement
  last_rang = *zero;  // Initialisation du dernier RRN
  *in31 = *on;        // Activation indicateur vidage SFL (SFLCLR)
  write SF1CTL;       // Vidage du sous-fichier
  *in31 = *off;       // Désactivation indicateur vidage SFL (SFLCLR)
  *in32 = *off;       // Désactivation indicateur affichage SFL (SFLDSP)
  *in90 = *off;       // Désactivation indicateur fin SFL (SFLEND)
end-proc;
```

### Procédure exportée

```rpgle
dcl-proc maFonction export;
  dcl-pi *n char(10);
    param1 char(10) const;
  end-pi;
  // ...
end-proc;
```

## Fonctions intégrées (BIF)

### Chaînes

```rpgle
result = %trim(texte);           // Supprime espaces des deux côtés
result = %triml(texte);          // Espaces à gauche
result = %trimr(texte);          // Espaces à droite
result = %upper(texte);          // Majuscules
result = %lower(texte);          // Minuscules
result = %subst(texte:1:10);     // Sous-chaîne (position:longueur)
result = %replace('new':'old':texte); // Remplacement
result = %scanrpl('old':'new':texte); // Scan et remplacement (7.4+)
result = %concat(' ':val1:val2:val3); // Concaténation avec séparateur (7.4+)

longueur = %len(%trim(texte));   // Longueur
position = %scan('mot':texte);   // Recherche position
```

### Numériques

```rpgle
texte = %char(num);              // Numérique vers chaîne
num = %dec(texte:9:2);           // Chaîne vers numérique
num = %abs(num);                 // Valeur absolue
num = %int(num);                 // Partie entière
reste = %rem(dividende:diviseur); // Reste de la division
```

### Dates

```rpgle
aujourdhui = %date();            // Date du jour
demain = aujourdhui + %days(1);  // Ajouter jours
dateTexte = %char(aujourdhui:*iso); // Format ISO en texte
```

### Tableaux et recherche

```rpgle
position = %lookup(valeur:tableau);  // Recherche dans tableau
// Retourne l'index ou 0 si non trouvé
```

### BIF modernes (IBM i 7.4+)

```rpgle
dcl-s codes char(10) dim(*auto:100);
codes = %list('A':'B':'C');       // Initialisation par liste
sorta codes;                      // Tri du tableau

// for-each
for-each element in codes;
  dsply element;
endfor;

// select/when-in
select;
when-in valeur in %range('A':'Z');
  // ...
endsl;
```

## Indicateurs et fin de programme

```rpgle
*inlr = *on;    // Fin normale du programme (libère les ressources)
return;          // Sort de la procédure/programme
```

## Bonnes pratiques

1. **Toujours `**free` en première ligne** — Plus de colonnes fixes
2. **Préfixer les variables de travail** — `w` pour work : `wNomClient`, `wMontant`
3. **Utiliser `const`** — Pour les paramètres non modifiés
4. **Préférer `qualified`** — Pour les structures de données
5. **Préférer `dcl-proc` aux sous-routines** — Meilleure encapsulation
6. **Éviter les indicateurs numériques** — Utiliser `ind` avec noms explicites
7. **Commenter en français** — `// Calcul du montant TTC`
8. **Initialiser les variables** — Utiliser `inz()`, `inz(*blanks)`, `inz(*zero)`
9. **Terminer avec `*inlr = *on`** — Toujours libérer les ressources
