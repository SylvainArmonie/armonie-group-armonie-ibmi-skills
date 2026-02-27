# Algorithmes et Patterns Avancés en RPG ILE

Guide des techniques algorithmiques avancées en RPG full free.

## Tableaux dynamiques avec dim(*auto)

Les tableaux à dimension automatique s'agrandissent dynamiquement.

```rpgle
**FREE
// Déclaration d'un tableau auto-extensible (max 100 éléments)
dcl-ds clients likerec(fclient) dim(*auto:100);

// Ajout d'éléments avec *next
clients(*next) = nouveauClient;  // Ajoute à la fin

// Nombre d'éléments actuels
dcl-s nbElements int(10);
nbElements = %elem(clients);

// Parcours du tableau
for-each client in clients;
    dsply client.nom;
endfor;
```

### Pattern : Agrégation par catégorie

Stocker le meilleur élément de chaque catégorie dans un tableau :

```rpgle
**FREE
ctl-opt actgrp(*new) alwnull(*no) extbinint(*yes);

dcl-f fichier rename(fichier:ffichier);
dcl-ds curRecord likerec(ffichier);
dcl-ds resultats likerec(ffichier) dim(*auto:50);

// Lecture et agrégation
read fichier curRecord;
dow not %eof;
    agregerParCategorie(curRecord);
    read fichier curRecord;
enddo;

// Affichage trié
afficherResultats();
*inlr = *on;

// ============================================
// Procédure : agregerParCategorie
// Garde le meilleur élément par catégorie
// ============================================
dcl-proc agregerParCategorie;
    dcl-pi *n;
        p_record likerec(ffichier) const;
    end-pi;
    
    dcl-s l_index zoned(3:0) inz(0);
    
    // Recherche si la catégorie existe déjà
    l_index = %lookup(p_record.categorie : resultats(*).categorie);
    
    select;
        // Catégorie existe ET nouveau record meilleur
        when l_index > 0 and resultats(l_index).score < p_record.score;
            resultats(l_index) = p_record;
        
        // Catégorie n'existe pas encore
        when l_index = 0;
            resultats(*next) = p_record;
    endsl;
end-proc;

// ============================================
// Procédure : afficherResultats
// Tri et affichage des résultats
// ============================================
dcl-proc afficherResultats;
    // Tri alphabétique par catégorie
    sorta resultats(*).categorie;
    
    // Affichage avec for-each
    for-each curRecord in resultats;
        dsply curRecord.categorie;
        dsply curRecord.libelle;
        dsply %editc(curRecord.score:'X');
    endfor;
end-proc;
```

## Recherche dans les tableaux

### %LOOKUP - Recherche simple

```rpgle
dcl-s codes char(10) dim(100);
dcl-s position int(10);

// Recherche exacte
position = %lookup('ABC123' : codes);
// Retourne 0 si non trouvé, sinon la position (1-based)

// Recherche dans tableau de structures
position = %lookup(valeurRecherchee : tableau(*).champ);
```

### %LOOKUP avec plage

```rpgle
// Rechercher à partir de la position 5
position = %lookup('ABC' : codes : 5);

// Rechercher entre positions 5 et 20
position = %lookup('ABC' : codes : 5 : 15);
```

## Tri de tableaux

### SORTA - Tri simple

```rpgle
// Tri d'un tableau simple
dcl-s noms char(50) dim(100);
sorta noms;  // Tri alphabétique ascendant

// Tri descendant
sorta(d) noms;

// Tri d'un tableau de structures par un champ
dcl-ds produits dim(100) qualified;
    ref     char(10);
    prix    packed(9:2);
    libelle char(50);
end-ds;

sorta produits(*).libelle;      // Tri par libellé
sorta(d) produits(*).prix;      // Tri par prix décroissant
```

### Tri multi-critères (pattern)

```rpgle
// Pour un tri multi-critères, utiliser une clé composée
dcl-ds elements dim(100) qualified;
    categorie char(20);
    date      date;
    nom       char(50);
    cleTriComposee char(78);  // categorie + date + nom
end-ds;

// Construire la clé de tri
for i = 1 to %elem(elements);
    elements(i).cleTriComposee = elements(i).categorie 
                                + %char(elements(i).date:*iso)
                                + elements(i).nom;
endfor;

// Trier par la clé composée
sorta elements(*).cleTriComposee;
```

## Manipulation de chaînes avancée

### %SCANRPL - Rechercher et remplacer

```rpgle
dcl-s texte varchar(100);
dcl-s resultat varchar(100);

texte = 'Bonjour-le monde';

// Remplacer un caractère
resultat = %scanrpl('-' : ' ' : texte);  // 'Bonjour le monde'

// Supprimer un caractère (remplacer par vide)
resultat = %scanrpl('-' : '' : texte);   // 'Bonjourle monde'

// Chaînage de remplacements
resultat = %scanrpl(' ' : '' : %scanrpl('-' : '' : texte));
```

### %CONCAT - Concaténation

```rpgle
dcl-s partie1 char(10);
dcl-s partie2 char(10);
dcl-s resultat char(30);

partie1 = 'ABC';
partie2 = 'DEF';

// Concaténation simple
resultat = %concat(*none : partie1 : partie2);  // 'ABCDEF'

// Avec séparateur
resultat = %concat('-' : partie1 : partie2);    // 'ABC-DEF'

// Multiple parties
resultat = %concat(*none : 'A' : 'B' : 'C' : 'D');  // 'ABCD'
```

### %LEFT, %RIGHT - Extraction

```rpgle
dcl-s texte char(20);
dcl-s gauche char(5);
dcl-s droite char(5);

texte = 'ABCDEFGHIJ';

gauche = %left(texte : 5);   // 'ABCDE'
droite = %right(texte : 5);  // 'FGHIJ'

// Combinaison pour réorganiser
// Déplacer les 4 premiers caractères à la fin
dcl-s reorganise char(20);
reorganise = %concat(*none : %right(texte : 16) : %left(texte : 4));
```

### %RANGE et %LIST - Tests d'appartenance

```rpgle
dcl-s code char(2);
dcl-s valide ind;

code = 'FR';

// Test avec liste de valeurs
if code IN %list('FR' : 'GR' : 'IT' : 'MC');
    dsply 'Code pays valide';
endif;

// Test avec plage
dcl-s lettre char(1);
lettre = 'M';

if lettre IN %range('A' : 'Z');
    dsply 'Lettre majuscule';
endif;

// Combinaison avec SELECT
select %subst(iban : pos : 1);
    when-in %range('0' : '9');
        // C'est un chiffre
    when-in %range('A' : 'Z');
        // C'est une lettre majuscule
    other;
        // Autre caractère
endsl;
```

## Algorithme : Calcul de clé IBAN

Exemple complet de calcul algorithmique complexe :

```rpgle
**FREE
ctl-opt actgrp(*new) alwnull(*no);

dcl-f iban rename(iban:fiban);

// Parcours des IBAN
read iban;
dow not %eof;
    // Ne traiter que certains pays
    if %left(valeur : 2) IN %list('FR' : 'GR' : 'IT' : 'MC');
        dsply calculerCleIban(valeur);
    endif;
    read iban;
enddo;

*inlr = *on;

// ============================================
// Fonction : calculerCleIban
// Calcule la clé de contrôle d'un IBAN
// Règle : 98 - (IBAN numérique MOD 97)
// ============================================
dcl-proc calculerCleIban;
    dcl-pi *n char(27);
        p_iban char(27) value;
    end-pi;
    
    dcl-s l_cle        packed(2:0) inz;
    dcl-s l_pos        uns(3) inz;
    dcl-s l_iban       like(p_iban) inz;
    dcl-s l_ibanNum    varchar(54) inz;
    dcl-c LETTRES      'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    
    // 1. Nettoyer l'IBAN (supprimer espaces et tirets)
    p_iban = %scanrpl(' ' : '' : %scanrpl('-' : '' : p_iban));
    
    // 2. Déplacer les 4 premiers caractères à la fin
    //    et forcer la clé à 00
    l_iban = %concat(*none :
                     %right(p_iban : 27 - 4) :  // BBAN (sans les 4 premiers)
                     %left(p_iban : 2) :         // Code pays
                     '00');                       // Clé à 00
    
    // 3. Convertir les lettres en chiffres (A=10, B=11, ..., Z=35)
    for l_pos = 1 to 27;
        select %subst(l_iban : l_pos : 1);
            when-in %range('0' : '9');
                // Garder le chiffre tel quel
                l_ibanNum += %subst(l_iban : l_pos : 1);
            when-in %range('A' : 'Z');
                // Convertir lettre en nombre (A=10, B=11, etc.)
                l_ibanNum += %char(%scan(%subst(l_iban : l_pos : 1) : LETTRES) + 9);
        endsl;
    endfor;
    
    // 4. Calculer la clé : 98 - (nombre MOD 97)
    l_cle = 98 - %rem(%dec(%trim(l_ibanNum) : 54 : 0) : 97);
    
    // 5. Reconstruire l'IBAN avec la clé calculée
    return %concat(*none :
                   %left(p_iban : 2) :           // Code pays
                   %editc(l_cle : 'X') :         // Clé formatée sur 2 chiffres
                   %subst(p_iban : 5));          // Reste de l'IBAN
end-proc;
```

### Décomposition de l'algorithme IBAN

| Étape | Opération | Exemple |
|-------|-----------|---------|
| 1 | Nettoyer | `FR00 4255-9100` → `FR0042559100...` |
| 2 | Réorganiser | `FR0042559100...` → `42559100...FR00` |
| 3 | Convertir lettres | `...FR00` → `...151800` (F=15, R=27) |
| 4 | Modulo 97 | `98 - (nombre % 97)` = clé |
| 5 | Insérer clé | `FR` + `76` + `42559100...` |

## Opérateurs de calcul

### %REM - Reste de division (Modulo)

```rpgle
dcl-s dividende packed(15:0);
dcl-s diviseur   packed(3:0);
dcl-s reste      packed(15:0);

dividende = 12345678901234;
diviseur = 97;

reste = %rem(dividende : diviseur);  // Calcul modulo
```

### %DEC - Conversion en décimal

```rpgle
dcl-s texteNum varchar(54);
dcl-s nombre   packed(54:0);

texteNum = '123456789012345678901234567890';

// Convertir chaîne en nombre décimal
nombre = %dec(%trim(texteNum) : 54 : 0);
```

### %EDITC - Formatage numérique

```rpgle
dcl-s nombre packed(5:0);
dcl-s texte  char(10);

nombre = 42;

// Format 'X' : zéros de tête préservés
texte = %editc(nombre : 'X');  // '00042'

// Format '1' : séparateurs de milliers
nombre = 12345;
texte = %editc(nombre : '1');  // '12,345'
```

## Patterns de conception courants

### Pattern : Accumulation conditionnelle

```rpgle
dcl-ds totaux dim(*auto:20) qualified;
    categorie char(20);
    somme     packed(15:2) inz(0);
    compteur  int(10) inz(0);
end-ds;

dcl-proc accumuler;
    dcl-pi *n;
        p_cat    char(20) const;
        p_valeur packed(11:2) const;
    end-pi;
    
    dcl-s idx int(10);
    idx = %lookup(p_cat : totaux(*).categorie);
    
    if idx = 0;
        // Nouvelle catégorie
        totaux(*next).categorie = p_cat;
        idx = %elem(totaux);
    endif;
    
    totaux(idx).somme += p_valeur;
    totaux(idx).compteur += 1;
end-proc;
```

### Pattern : Validation avec codes retour

```rpgle
dcl-proc validerDonnees;
    dcl-pi *n int(10);  // 0=OK, >0=erreur
        p_data likerec(fdata) const;
    end-pi;
    
    // Validation champ par champ
    if %trim(p_data.code) = '';
        return 1;  // Code obligatoire
    endif;
    
    if p_data.montant < 0;
        return 2;  // Montant négatif
    endif;
    
    if not (p_data.type IN %list('A' : 'B' : 'C'));
        return 3;  // Type invalide
    endif;
    
    return 0;  // Tout est OK
end-proc;
```

### Pattern : Traitement par lots

```rpgle
dcl-c TAILLE_LOT 100;
dcl-ds lot likerec(ffichier) dim(TAILLE_LOT);
dcl-s nbDansLot int(10) inz(0);

read fichier curRecord;
dow not %eof;
    nbDansLot += 1;
    lot(nbDansLot) = curRecord;
    
    // Traiter le lot quand il est plein
    if nbDansLot >= TAILLE_LOT;
        traiterLot(lot : nbDansLot);
        nbDansLot = 0;
    endif;
    
    read fichier curRecord;
enddo;

// Traiter le dernier lot partiel
if nbDansLot > 0;
    traiterLot(lot : nbDansLot);
endif;
```

## Bonnes pratiques algorithmes

1. **Utiliser des noms explicites** - `l_index` plutôt que `i`
2. **Décomposer en procédures** - Une fonction = une responsabilité
3. **Documenter les algorithmes complexes** - Expliquer la logique
4. **Valider les entrées** - Vérifier les paramètres en début de procédure
5. **Utiliser les BIF modernes** - `%scanrpl`, `%concat`, `%list`, `%range`
6. **Préférer dim(*auto)** - Pour les tableaux de taille variable
7. **Éviter les effets de bord** - Utiliser `const` pour les paramètres non modifiés
