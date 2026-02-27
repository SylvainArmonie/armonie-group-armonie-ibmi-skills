**free


// AGRION en V7.4   et batlle dev en V7.5
// RPG BATTLE DEV 2024 - Manche 2 - Epreuve 3 - Du 13 au 15 Novembre 2024

// Contexte :
//  Le fichier base de données TEAMLIB/IBAN contient une liste d'IBAN

// Objectif :
//  Calculer les clés des IBAN fournis
//  Ne traiter que les IBAN Français, Grecs, Italiens, Monégasques

// Consignes :
//  1. Utiliser uniquement des instructions RPG natives (pas de SQL, pas d'appel
//  2. Les déclarations ne doivent pas être modifiées
//  3. Les lignes déjà présentes dans le code ne doivent pas êtres supprimées

// Règles de calcul :
//  Cf https://fr.wikipedia.org/wiki/International_Bank_Account_Number

// Exemple :
// FR{00}42559100000800166893177 où {00} est la clé à calculer
// doit afficher : DSPLY FR7642559100000800166893177

// Critères d'évaluation :
//  1. Le résultat doit être celui demandé
//  2. Le programme doit s'appeler E3 dans votre bibliothèque TEAMx

// -----------------------------------------------------------------------------
// Votre profil IBM i : TEAMXX
// -----------------------------------------------------------------------------

ctl-opt actgrp(*new) alwnull(*no);

dcl-f iban rename(iban:fiban);


// Parcours des IBAN et calcul des clés
read iban ;
dow not %eof ;
   if %Left(valeur:2) IN %list('FR':'GR':'IT':'MC') ;
      dsply calculer_cle(valeur);
   endif ;
   read iban ;
enddo ;

return ;


// Calculer la clé
dcl-proc calculer_cle ;
  dcl-pi *n char(27) ;
    p_iban char(27) value ;
  end-pi ;

  // Clé
  dcl-s l_cle      packed(2:0)  inz ;
  // Parcours de l'IBAN
  dcl-s l_pos      uns(3) inz ;
  // Pour constitution IBAN numérique
  dcl-s  l_iban      like(p_iban) inz ;
  dcl-s  l_iban_char varchar(54)  inz ;
  // Lettres à remplacer
  dcl-s LETTRES char(26) const inz('ABCDEFGHIJKLMNOPQRSTUVWXYZ');


  // Suppression des caractères indésirables
  p_iban = %scanrpl(' ' : '' : %scanrpl('-' : '' :p_iban ) );
  // Déplacement des 4 caractères de gauche à droite. On force la clé à 00 au ca
  l_iban = %concat(*none :
                   %right(p_iban : 27-4) :
                   %left(p_iban : 2 ) :
                   '00' ) ;

  // Remplacement des lettres par des chiffres : parcour de l'IBAN
  for l_pos = 1 to 27 ;
     select %subst(l_iban:l_pos:1);
       when-in %range('0':'9') ;
          l_iban_char += %subst(l_iban:l_pos:1) ;
       when-in %range('A':'Z') ;
          l_iban_char += %char(%scan(%subst(l_iban:l_pos:1) : LETTRES) + 9) ;
     endsl ;
  endfor ;

  // Calcul clé
  l_cle = 98 - %rem(%dec(%trim(l_iban_char):54:0) : 97) ;

  // On insère la clé en position 3 et 4
  return %concat(*none :
                 %left(p_iban:2) :
                 %editc(l_cle:'X') :
                 %subst(p_iban:5)) ;
end-proc ;
