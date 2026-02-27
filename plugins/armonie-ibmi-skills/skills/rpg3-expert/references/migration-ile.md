# Migration RPG III → RPG ILE (RPG IV Free)

## Table des matières
1. [Vue d'ensemble](#vue-ensemble)
2. [Table de correspondance des instructions](#correspondances)
3. [Spécifications → Déclarations libres](#specifications)
4. [Indicateurs → Variables booléennes](#indicateurs)
5. [Opérations de calcul](#operations)
6. [Accès fichiers](#acces-fichiers)
7. [Conditions et boucles](#conditions-boucles)
8. [Exemples de conversion complète](#exemples)

---

## 1. Vue d'ensemble

| Aspect | RPG III (RPG/400) | RPG ILE (RPG IV Free) |
|--------|-------------------|----------------------|
| Format | Colonnes fixes (pos 6-80) | Format libre (**FREE) |
| Compilation | CRTRPGPGM | CRTRPGMOD + CRTPGM ou CRTBNDRPG |
| Source | QRPGSRC RCDLEN(80) | QRPGLESRC RCDLEN(112) |
| Variables | Définies en spec C (result + length) | dcl-s, dcl-ds |
| Fichiers | Spec F colonnes | dcl-f |
| Contrôle | Spec H colonnes | ctl-opt |
| Fin programme | SETON LR | *inlr = *on |
| Noms | 6 caractères max | Jusqu'à 4096 caractères |
| Sous-programmes | EXSR/BEGSR/ENDSR | dcl-proc (procédures) |
| Commentaires | * en col 7 | // en début de ligne |

---

## 2. Table de correspondance des instructions

### Instructions de base

| RPG III | RPG ILE Free | Notes |
|---------|-------------|-------|
| `SETON LR` | `*inlr = *on;` | Fin de programme |
| `SETON 99` | `*in99 = *on;` | Activer indicateur |
| `SETOF 99` | `*in99 = *off;` | Désactiver indicateur |
| `DSPLY` | `dsply` | Identique |
| `MOVE 'val' VAR` | `var = 'val';` | Affectation directe |
| `MOVEL'val' VAR` | `var = 'val';` | Affectation directe |
| `Z-ADD5 VAR` | `var = 5;` | Affectation numérique |
| `Z-SUB5 VAR` | `var = -5;` | Négation |
| `CLEAR VAR` | `clear var;` | Remise à zéro |

### Arithmétique

| RPG III | RPG ILE Free |
|---------|-------------|
| `ADD 1 X` | `x += 1;` ou `x = x + 1;` |
| `A ADD B X` | `x = a + b;` |
| `SUB 1 X` | `x -= 1;` ou `x = x - 1;` |
| `A SUB B X` | `x = a - b;` |
| `A MULT B X` | `x = a * b;` |
| `A DIV B X` | `x = a / b;` ou `x = %div(a:b);` |
| `MVR RESTE` | `reste = %rem(a:b);` |
| `COMP A 62` (Hi/Lo/Eq) | `if a > b; ... ` |

### Accès fichiers

| RPG III | RPG ILE Free |
|---------|-------------|
| `SETLL clé fichier` | `setll clé fichier;` |
| `SETGT clé fichier` | `setgt clé fichier;` |
| `READ fichier 90` | `read fichier;` + `if %eof;` |
| `READE clé fichier 90` | `reade clé fichier;` + `if %eof;` |
| `READP fichier 90` | `readp fichier;` + `if %eof;` |
| `READPE clé fich 90` | `readpe clé fichier;` + `if %eof;` |
| `READC sfl 90` | `readc sfl;` + `if %eof;` |
| `CHAIN clé fichier 90` | `chain clé fichier;` + `if %found;` |
| `WRITE format` | `write format;` |
| `UPDAT format` | `update format;` |
| `DELET format` | `delete format;` |

### Gestion écran

| RPG III | RPG ILE Free |
|---------|-------------|
| `EXFMT FMT1` | `exfmt FMT1;` |
| `WRITE FMT1` | `write FMT1;` |
| `READ FMT1` | `read FMT1;` |

---

## 3. Spécifications → Déclarations libres

### Spec H → ctl-opt

**RPG III** :
```
     H                            1
```
(Debug activé, position 15)

**RPG ILE** :
```
**FREE
ctl-opt debug(*yes) option(*srcstmt:*nodebugio)
        dftactgrp(*no) actgrp(*new);
```

### Spec F → dcl-f

**RPG III** :
```
     FCLIENT  IF  E           K        DISK
     FCLIENT  UF  E           K        DISK                    A
     FECRAN   CF  E                    WORKSTN
     FECRANSFLCF  E                    WORKSTN
     F                                        KSFL1  SFL1CTL
     FIMPR     O  E                    PRINTER
```

**RPG ILE** :
```
dcl-f CLIENT disk(*ext) keyed usage(*input);
dcl-f CLIENT disk(*ext) keyed usage(*update:*output);
dcl-f ECRAN workstn(*ext) usage(*input:*output);
dcl-f ECRANSFL workstn(*ext) usage(*input:*output)
      sfile(SFL1:rrn);
dcl-f IMPR printer(*ext) usage(*output);
```

### Spec I (Data Structure) → dcl-ds

**RPG III** :
```
     IDARINV       DS
     I                                    1    4 AA
     I                                    5    6 MM
     I                                    7    8 JJ
```

**RPG ILE** :
```
dcl-ds darinv;
  aa char(4) pos(1);
  mm char(2) pos(5);
  jj char(2) pos(7);
end-ds;
```

### Spec E (Tableaux) → dcl-s avec dim

**RPG III** :
```
     E                    TVA    10   4 2
     E                    MSG  1  5  70
```

**RPG ILE** :
```
dcl-s TVA packed(4:2) dim(10);
dcl-s MSG char(70) dim(5) ctdata;
```

### Variables (définies en spec C) → dcl-s

**RPG III** (variable définie dans le Result avec longueur) :
```
     C                     Z-ADD0        TOTAL  72
     C                     MOVEL'Hello'  HELLO 13
     C                     Z-ADD0        RRN    40
```

**RPG ILE** :
```
dcl-s total packed(7:2) inz(0);
dcl-s hello char(13) inz('Hello');
dcl-s rrn packed(4:0) inz(0);
```

---

## 4. Indicateurs → Variables booléennes

### Indicateurs de fichier

**RPG III** :
```
     C                     READ CLIENT                   90
     C           *IN90     DOWEQ'0'
```

**RPG ILE** :
```
read CLIENT;
dow not %eof(CLIENT);
```

### Indicateurs de recherche

**RPG III** :
```
     C           NUMCLI    CHAINCLIENT                   90
     C           *IN90     IFEQ '0'
```

**RPG ILE** :
```
chain NUMCLI CLIENT;
if %found(CLIENT);
```

### Indicateurs de touches

**RPG III** :
```
     C           *INKC     IFEQ '1'
     C* F3 pressée
```

**RPG ILE** (avec INDARA) :
```
// Dans le DDS : ajouter INDARA au niveau fichier
// En RPG :
dcl-ds indicators len(99) qualified;
  exit ind pos(3);    // F3
  create ind pos(6);  // F6
  back ind pos(12);   // F12
end-ds;

if indicators.exit;
  // F3 pressée
endif;
```

Ou plus simplement :
```
if *in03;
  // F3 pressée
endif;
```

### Indicateurs de sous-fichier

**RPG III** :
```
     C                     SETON                     33
     C                     WRITESFL1CTL
     C                     SETOF                     33
```

**RPG ILE** :
```
*in33 = *on;   // SFLCLR
write SFL1CTL;
*in33 = *off;
```

---

## 5. Opérations de calcul

### Conditions

**RPG III** :
```
     C           10        IFEQ STOCK
     C           'OK'      DSPLY
     C                     ENDIF
```

**RPG ILE** :
```
if stock = 10;
  dsply 'OK';
endif;
```

### SELEC/WHxx → select/when

**RPG III** :
```
     C                     SELEC
     C           OPT       WHEQ 'C'
     C                     ADD  1        I
     C           OPT       WHEQ 'M'
     C                     ADD  2        I
     C                     ENDSL
```

**RPG ILE** :
```
select;
  when opt = 'C';
    i += 1;
  when opt = 'M';
    i += 2;
endsl;
```

### Boucles

**RPG III** (DOWEQ) :
```
     C           *IN90     DOWEQ'0'
     C                     READ CLIENT                   90
     C                     ENDDO
```

**RPG ILE** :
```
dow not %eof(CLIENT);
  read CLIENT;
enddo;
```

**RPG III** (DO comptée) :
```
     C                     DO   8
     C                     ADD  1        X
     C                     ENDDO
```

**RPG ILE** :
```
for i = 1 to 8;
  x += 1;
endfor;
```

### ANDxx / ORxx

**RPG III** :
```
     C           *INKC     IFGT '1'
     C           *IN99     ANDEQ'0'
     C                     Z-ADD0        J
     C                     ENDIF
```

**RPG ILE** :
```
if *in03 and not *in99;
  j = 0;
endif;
```

---

## 6. Accès fichiers

### Lecture complète

**RPG III** :
```
     FCLIENT  IF  E           K        DISK
     C           *LOVAL    SETLLCLIENT
     C                     READ CLIENT                   90
     C           *IN90     DOWEQ'0'
     C           PRECLI    DSPLY
     C                     READ CLIENT                   90
     C                     ENDDO
     C                     SETON                     LR
```

**RPG ILE** :
```
**FREE
ctl-opt dftactgrp(*no);
dcl-f CLIENT disk(*ext) keyed usage(*input);

setll *loval CLIENT;
read CLIENT;
dow not %eof(CLIENT);
  dsply PRECLI;
  read CLIENT;
enddo;

*inlr = *on;
```

### CHAIN + UPDAT

**RPG III** :
```
     FCLIENT  UF  E           K        DISK
     C           00004     CHAINCLIENT                   90
     C           *IN90     IFEQ '0'
     C                     MOVEL'Jean'   PRECLI
     C                     UPDATCLIENTF
     C                     ENDIF
     C                     SETON                     LR
```

**RPG ILE** :
```
**FREE
dcl-f CLIENT disk(*ext) keyed usage(*update);

chain 4 CLIENT;
if %found(CLIENT);
  PRECLI = 'Jean';
  update CLIENTF;
endif;

*inlr = *on;
```

### KLIST/KFLD → %KDS ou paramètres directs

**RPG III** :
```
     C           CLECOM    KLIST
     C                     KFLD                     COUCHS
     C                     KFLD                     TAICHS
     C           CLECOM    CHAINCHAUS                    90
```

**RPG ILE** :
```
dcl-ds clecom likerec(CHAUSF:*key);

clecom.COUCHS = 'Bleu';
clecom.TAICHS = 40;
chain %kds(clecom) CHAUS;
if %found(CHAUS);
  // trouvé
endif;
```

---

## 7. Exemples de conversion complète

### Hello World

**RPG III** :
```
     C                     MOVEL'Hello'  HELLO 13
     C                     MOVE 'World !'HELLO
     C           HELLO     DSPLY
     C                     SETON                     LR
```

**RPG ILE** :
```
**FREE
dcl-s hello char(13);

hello = 'Hello World !';
dsply hello;

*inlr = *on;
```

### Sous-programmes → Procédures

**RPG III** :
```
     C                     EXSR CALCUL
     C* ...
     C           CALCUL    BEGSR
     C           A         ADD  B        RESULT
     C                     ENDSR
```

**RPG ILE** :
```
**FREE
result = calcul(a : b);

dcl-proc calcul;
  dcl-pi *n packed(7:2);
    pA packed(7:2) const;
    pB packed(7:2) const;
  end-pi;
  return pA + pB;
end-proc;
```

---

## Points d'attention lors de la migration

1. **MOVE/MOVEL** : Attention aux conversions implicites de type. En ILE, utiliser `%char()`, `%dec()`, `%int()` pour les conversions explicites
2. **Indicateurs** : Remplacer systématiquement par `%eof`, `%found`, `%error` ou variables ind
3. **SETON/SETOF** : Remplacer par affectation directe `*inXX = *on/*off`
4. **Noms 6 car** : Profiter des noms longs en ILE pour plus de lisibilité
5. **KLIST** : Remplacer par `%kds()` ou paramètres directs dans chain/setll
6. **CAS/ENDCS** : Remplacer par `select/when` avec appels de procédures
7. **Compilation** : CRTRPGPGM → CRTBNDRPG (ou CRTRPGMOD + CRTPGM)
