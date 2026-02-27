**free
// Carte H
ctl-opt dftactgrp(*no) actgrp(*caller) datfmt(*iso) timfmt(*iso) ;


// Carte F
dcl-f ECRAN1   WORKSTN; // fichier Ecran

dcl-f CLIENT USAGE(*INPUT)  keyed;  // ficher physique PF avec clé

dcl-f FICHIERPF USAGE(*INPUT:*DELETE:*UPDATE:*OUTPUT) keyed;  // ficher physique PF avec clé

dcl-f FICHIERPF2 USAGE(*INPUT:*DELETE:*UPDATE:*OUTPUT);  // ficher physique PF sans clé

dcl-f FICHIERLF USAGE(*INPUT:*DELETE:*UPDATE:*OUTPUT) keyed;  // ficher physique LF avec clé

dcl-f FICHIERPF3 disk USAGE(*UPDATE : *DELETE : *OUTPUT : *INPUT) keyed
prefix(FICPF_);   // Prefix pour ajouter un préfixe aux champs du fichier


dcl-f PRTF1 printer;   // Fichier PRTF
dcl-f PRTF1 printer oflind(INDPage);   // fichier PRTF  débordement personnalisé


//Carte D

// Variable scalaire
// Numérique
Dcl-S zoned        Zoned(4:0); // format ZONED  Chaque chiffre est stocké dans un octet
Dcl-S packed       Packed(5);  // format Packed Deux chiffres décimaux sont stockés par octet
Dcl-S packed2      Packed(5) INZ(100);  // ici on itialise la variable packed2 à 100
Dcl-s resultat     Packed(10:2);  // ici on a deux décimal apres la virgule : exemple 12.10
Dcl-S zoned        Zoned(10:2); // ici on a deux décimal apres la virgule : exemple 12.10

Dcl-S Integer      Int(10); // Représente un entier signé sur 4 octets avec une plage de -214
Dcl-S Bin          Bindec(9); // un nombre entier signé stocké sur 4 octets (32 bits).
Dcl-s BigInt       Bigint(63);


// char
// Déclaration d'une variable de type caractère fixe sur 8 positions
Dcl-S phrase       Char(8);

// Déclaration d'une variable de type chaîne variable jusqu\Zà 255 caractères
Dcl-S phrase2      Varchar(255);

// Déclaration d\Zune variable contenant un espace (initialisée avec *BLANKS)
Dcl-S SpaceVal     Char(1) inz(*BLANKS);

// Déclaration d\Zune variable contenant un espace (initialisée avec Sylvain)
Dcl-S nom          Char(7) inz('Sylvain');

// Déclaration d\Zun tableau nommé `tabldd` composé de 10 éléments
// Chaque élément est une chaîne de 1 caractère (CHAR(1))
// Le mot-clé DIM(10) indique qu\Zil y a 10 cases dans le tableau
dcl-s tabldd char(1) dim(10);

// date
Dcl-S DATE0        Date(*ISO);
Dcl-S date_mdy     Date(*MDY);

// constante
Dcl-C CON_1 CONST(1);
Dcl-C CON_2 CONST('test');



// DS
Dcl-DS InputDs;
  UserSpace      Char(20)   Pos(1);
  SpaceName      Char(10)   Pos(1);
  SpaceLib       Char(10)   Pos(11);
  InpFileLib     Char(20)   Pos(29);
  InpFFilNam     Char(10)   Pos(29);
  InpFFilLib     Char(10)   Pos(39);
  InpRcdFmt      Char(10)   Pos(49);
End-DS;

// dtaara
DCL-DS data_struct;
  mydtaara CHAR(100) DTAARA;
END-DS;

// Prototype
DCL-PR myPgm EXTPGM('MYPGM1');
  name CHAR(10) CONST options(*nopass);
END-PR;

DCL-PI *n;
  name CHAR(10) CONST;
END-PI;

callp myPGM('sylvain');


// Remplissage
SpaceName = 'ESPCLIENT';
SpaceLib = 'LIB1';
InpFFilNam = 'ARTICLE';
InpFFillib = 'LIBDATA';
InpRcdFmt = 'FMT01';

// Affichage du tout
dsply UserSpace;      // ESPCLIENTLIB1
dsply InpFileLib;     // ARTICLELIBDATA
dsply InpRcdFmt;      // FMT01



phrase = 'toto';

zoned = 8 + 47 ;



Setll *loval FICHIERPF;

Read FICHIERPF;
Write FICHIERFM;
Update FICHIERFM;

Chain key FICHIERPF;

// il n' a plus de klist kfld
Chain (key:key2:key3) FICHIERPF;

Exfmt ecranfm1;

// SI
If packed2 = 8;
  phrase = 'test';
endif;


// SI avec des si et sinon...
if packed2 = 7 or packed = 9;
  phrase = 'test2';
elseif packed = 10;
  phrase = 'bob';
else;
  phrase = 'roger';
endif;


// Tant que pas
Dow Not %eof();
  packed2 = 1;
enddo;

// Tant que 1=1...
dow 1=1;
  phrase = 'toto';
enddo;

Dou zoned = 8;
  zoned += 1;
enddo;

exsr main;

// do until
dou *in03=*on;
  leave;
enddo;

// Selon
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

resultat = Addition(25.50 : 14.25);  // Appel de la procédure

dsply ('Le résultat est : ' + %char(resultat));  // resultat = 39.75

initialisation_sous_fichier();

*inlr = *on;  // Fin du programme


//  sous routine
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

// sous p
dcl-proc Addition;

  dcl-pi *n packed(10:2);  // Signature de la procédure (type de retour)
    num1 packed(10:2) value;  // Premier paramètre en entrée
    num2 packed(10:2) value;  // Deuxième paramètre en entrée
  end-pi;
  dcl-s toto zoned(5:0);

  return num1 + num2;  // Calcul de la somme et retour du résultat
end-proc;


dcl-proc initialisation_sous_fichier;
  rang = *zero;      // initialisat° du compteur d'enregistrement.
  last_rang = *zero; // initialisat° du dernier rrn d'enregistrement.
  *in31 = *on;       // Activat° de l'indic de vidage de SFL  (Associé au mot clé SFLCR)
  write SF1CTL;      // Vidage du sous-fichier
  *in31 = *off;      // Désactivat° de l'indic de vidage de SFL (Associé au mot clé SFLCLR)
  *in32 = *off;      // Désactivat° de l'indic de vidage de SFL (Associé au mot clé SFLDSP)
  *in90 = *off;      // Désactivat° de l'indic de vidage de SFL (Associé au mot clé SFLend)
end-proc ;

