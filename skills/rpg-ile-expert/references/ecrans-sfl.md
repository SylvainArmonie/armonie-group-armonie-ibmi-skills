# Écrans 5250, Sous-fichiers et DSPF en RPG ILE

Guide complet pour la gestion des écrans interactifs et sous-fichiers sur IBM i.

## Architecture Écran-Programme

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Fichier DSPF   │────▶│  Programme RPG  │────▶│  Fichiers Data  │
│  (Écran 5250)   │◀────│                 │◀────│  (PF/LF)        │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Déclaration du fichier écran (WORKSTN)

```rpgle
**FREE
ctl-opt option(*srcstmt) dftactgrp(*no) bnddir('MONDIR':'QC2LE');

// Fichier écran avec sous-fichiers
dcl-f MONECRAN workstn sfile(SFL1:RRN1)
                       sfile(SFL2:RRN2)
                       infds(infoEcran);

dcl-s rrn1 packed(4:0) inz(0);
dcl-s rrn2 packed(4:0) inz(0);
```

## Renommage des indicateurs

```rpgle
dcl-s pIndicators pointer inz(%addr(*in));

dcl-ds DspInd based(pIndicators);
    Sortie              ind pos(3);   // F3
    Aide                ind pos(4);   // F4
    Creation            ind pos(6);   // F6
    Impression          ind pos(7);   // F7
    Annuler             ind pos(12);  // F12
    Confirmer           ind pos(23);  // F23
    Sfl_Clr             ind pos(31);  // Clear sous-fichier
    Sfl_Dsp             ind pos(32);  // Afficher sous-fichier
    Roll                ind pos(39);  // Page suivante
    Sfl_End             ind pos(90);  // Fin sous-fichier
    Erreur_Saisie       ind pos(57);  // Erreur personnalisée
end-ds;

if Sortie;        // Au lieu de if *in03;
    leave;
endif;
```

## INFDS - Information sur l'écran

```rpgle
dcl-ds infoEcran;
    toucheFonction char(1) pos(369);
end-ds;

dcl-c F_SIX const(x'36');

if toucheFonction = F_SIX;
    procedureCreation();
endif;
```

## RÈGLES CRITIQUES DSPF/SFL

### Cohérence indicateurs DSPF ↔ RPG (LOGIQUE POSITIVE)

**CRITIQUE** : Utiliser la logique POSITIVE pour SFLDSP.

Le RPG met `indSflDsp = *on` pour afficher → le DSPF doit utiliser `32` (positif).

```
CORRECT :  A  32                SFLDSP      ← 32 ON = afficher
ERREUR  :  A N32                SFLDSP      ← 32 OFF = afficher (incohérent avec RPG)
```

Convention recommandée :
```dds
     A  32                                  SFLDSP
     A N31                                  SFLDSPCTL
     A  31                                  SFLCLR
     A  90                                  SFLEND(*MORE)
```

### Touches de fonction avec INDARA

Avec `INDARA`, les touches CA03, CA12 etc. doivent être déclarées
**uniquement au niveau format**, jamais au niveau fichier → sinon CPD7597.

### Pas d'accents dans les constantes DDS

Les accents (è, é, à, ç) causent des erreurs CCSID. Utiliser uniquement ASCII.

```dds
     A* ERREUR :  'Bibliothèque introuvable !'  → CPD7482
     A* CORRECT : 'Bibliotheque introuvable !'
```

## Sous-fichier : Chargement par page (PATTERN COMPLET)

### Variables nécessaires

```rpgle
dcl-c SFL_PAGE 14;
dcl-s lstRrn    packed(4:0) inz(0);  // Dernier RRN chargé
dcl-s pageStart packed(4:0) inz(1);  // Premier RRN de la page courante
```

### Boucle principale avec pagination correcte

```rpgle
dou Sortie;
    rrn1 = pageStart;             // Positionner sur la page courante
    write BAS1;
    exfmt CTL1;

    select;
        when Sortie;
            leave;
        when Roll;
            if not Sfl_End;       // CRITIQUE : ne pas paginer si fin atteinte
                pageStart = lstRrn + 1;
                Build_Subfile();
            endif;
        other;
            TRT_READC();
            exsr Clear_Subfile;
            pageStart = 1;        // Revenir en haut
            Build_Subfile();
    endsl;
enddo;
```

### Procédure de vidage

```rpgle
begsr Clear_Subfile;
    rrn1 = *zero;
    lstRrn = *zero;
    Sfl_Clr = *on;
    write CTL1;
    Sfl_Clr = *off;
    Sfl_Dsp = *off;
    Sfl_End = *off;
endsr;
```

### Procédure de chargement

```rpgle
dcl-proc Build_Subfile;
    rrn1 = lstRrn;

    for i = 1 to SFL_PAGE;
        read(n) FICHIER;
        if %eof;
            Sfl_End = *on;
            leave;
        else;
            rrn1 += 1;
            ENORACE = NORACE;
            EDTRACE = DTRACE;
            ENMRACE = NMRACE;
            write SFL1;
        endif;
    endfor;

    if rrn1 > *zero;
        Sfl_Dsp = *on;    // Afficher seulement si enregistrements
    endif;

    lstRrn = rrn1;
end-proc;
```

## Fichier non-keyed : repositionnement sans SETLL

**CRITIQUE** : `setll *loval` nécessite un fichier **keyed**. Pour un fichier
sans clé (ex: sortie DSPOBJD, OUTFILE), fermer/rouvrir :

```rpgle
// ERREUR : setll sur fichier non-keyed → RNF7055
setll *loval OBJFMT;

// CORRECT : close/open pour revenir au début
dcl-proc repositionnerFichier;
    if %open(OBJLSTP);
        close OBJLSTP;
    endif;
    open OBJLSTP;
end-proc;
```

## READC - Lecture des modifications

```rpgle
dcl-proc TRT_READC;
    readc SFL1;
    dow not %eof;
        select;
            when OPT = '2';
                Modifier();
            when OPT = '4';
                Supprimer();
            when OPT = '5';
                Afficher();
        endsl;
        OPT = *blanks;
        update SFL1;
        readc SFL1;
    enddo;
end-proc;
```

## Appel de commande système

### QCMDEXC (commandes non-interactives)

```rpgle
dcl-pr QCMDEXC extpgm;
    *n char(1000) const options(*varsize);
    *n packed(15:5) const;
end-pr;

dcl-s commande char(1000);
commande = 'DLTOBJ OBJ(MABIB/MONOBJ) OBJTYPE(*FILE)';
callp QCMDEXC(commande : %len(%trim(commande)));
```

### system() C (commandes interactives avec prompting ?)

**CRITIQUE** : `QCMDEXC` ne supporte PAS le prompting `?`.
Utiliser la fonction C `system()` avec préfixe `?` pour les commandes
nécessitant une saisie (CRTDUPOBJ, RNMOBJ, CHGOBJD, etc.) :

```rpgle
// Prototype : nécessite bnddir('QC2LE') dans ctl-opt
dcl-pr system int(10) extproc('system');
    *n pointer value options(*string);
end-pr;

// Affiche l'écran de prompt pré-rempli
commande = '?CRTDUPOBJ OBJ(' + %trim(nom) + ') ' +
           'FROMLIB(' + %trim(bib) + ') ' +
           'OBJTYPE(' + %trim(typ) + ')';
monitor;
    system(%trim(commande));
on-error *all;
endmon;
```

| Méthode | Usage | Exemple |
|---------|-------|---------|
| `QCMDEXC` | Commandes directes sans saisie | DLTOBJ, DSPOBJD, OVRDBF |
| `system('?...')` | Commandes avec écran de prompt | CRTDUPOBJ, RNMOBJ, CHGOBJD |

## Retour de structure depuis un module

**CRITIQUE** : `likeds()` est interdit sur `dcl-s`, utiliser `dcl-ds` :

```rpgle
dcl-ds dsCouleur qualified template;
    indRouge ind;
    indRose  ind;
end-ds;

dcl-pr getCouleurObjet likeds(dsCouleur);
    pAttribut char(10) const;
end-pr;

// CORRECT : dcl-ds
dcl-ds wCouleur likeds(dsCouleur);
wCouleur = getCouleurObjet(monAttribut);

// ERREUR : dcl-s avec likeds → RNF3438
// dcl-s wCouleur likeds(dsCouleur);   ← INTERDIT !
```

## Data Area (DTAARA)

```rpgle
dcl-s Autorisation char(1) dtaara('AUTOR');
in *lock *dtaara;    // Lecture avec lock
in Autorisation;     // Lecture sans lock
```

## Fenêtres (WINDOW)

```dds
A          R FMTFENETRE
A                                      WINDOW(*DFT 4 13)
A                                      CA03(03)
A                                      CA12(12)
A                                      WDWBORDER((*COLOR WHT) (*CHAR '<->!-
A                                      !<->'))
A                                      WDWTITLE((*TEXT 'Mon titre') (*C-
A                                      OLOR WHT))
A            ZONE1         10A  B  2  1
```

## Indicateurs DSPF courants

| Indicateur | Mot-clé DSPF | Logique | Usage |
|------------|--------------|---------|-------|
| 31 | SFLCLR | `31` positif | Vider le sous-fichier |
| 32 | SFLDSP | `32` positif | Afficher le sous-fichier |
| N31 | SFLDSPCTL | `N31` négatif | Afficher contrôle (sauf pendant clear) |
| N90 | ROLLUP | `N90` négatif | Pagination (sauf si fin) |
| 90 | SFLEND | `90` positif | Fin du sous-fichier |
| 67 | SFLNXTCHG | `67` positif | Forcer relecture ligne |

## Structure complète d'un programme SFL

```rpgle
**FREE
ctl-opt option(*srcstmt) dftactgrp(*no);

dcl-f ECRAN workstn sfile(SFL1:rrn1) infds(info);
dcl-f DONNEES disk keyed;

dcl-s rrn1      packed(4:0);
dcl-s lstRrn    packed(4:0);
dcl-s pageStart packed(4:0) inz(1);
dcl-c SFL_PAGE 14;

dcl-s pInd pointer inz(%addr(*in));
dcl-ds Ind based(pInd);
    Sortie ind pos(3);
    Retour ind pos(12);
    Roll   ind pos(39);
    SflClr ind pos(31);
    SflDsp ind pos(32);
    SflEnd ind pos(90);
end-ds;

exsr Clear_Subfile;
setll *loval DONNEES;
Build_Subfile();

dou Sortie;
    rrn1 = pageStart;
    exfmt CTL1;

    select;
        when Sortie;
            leave;
        when Roll;
            if not SflEnd;
                pageStart = lstRrn + 1;
                Build_Subfile();
            endif;
        when not Sortie;
            TRT_READC();
            exsr Clear_Subfile;
            setll *loval DONNEES;
            pageStart = 1;
            Build_Subfile();
    endsl;
enddo;

*inlr = *on;

begsr Clear_Subfile;
    rrn1 = *zero;
    lstRrn = *zero;
    SflClr = *on;
    write CTL1;
    SflClr = *off;
    SflDsp = *off;
    SflEnd = *off;
endsr;

dcl-proc Build_Subfile;
    rrn1 = lstRrn;
    for i = 1 to SFL_PAGE;
        read(n) DONNEES;
        if %eof;
            SflEnd = *on;
            leave;
        endif;
        rrn1 += 1;
        // ... remplir zones SFL ...
        write SFL1;
    endfor;
    if rrn1 > *zero;
        SflDsp = *on;
    endif;
    lstRrn = rrn1;
end-proc;

dcl-proc TRT_READC;
    readc SFL1;
    dow not %eof;
        // ... traiter option ...
        OPT = *blanks;
        update SFL1;
        readc SFL1;
    enddo;
end-proc;
```
