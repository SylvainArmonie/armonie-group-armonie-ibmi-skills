**free
CTL-OPT option(*SRCSTMT) DFTACTGRP(*NO)
                  BNDDIR('RACEDIR':'QC2LE');

DCL-F RACEDILE  WORKSTN SFILE(SFL1:RRN1)
                                  SFILE(SFL2:RRN2) infds(info);

DCL-F RACETP1   disk keyed alias;  // types de courses
DCL-F RACECOMP  DISK USAGE(*UPDATE : *OUTPUT) KEYED PREFIX(COMP_);
DCL-F RCSUPLOG  DISK USAGE(*OUTPUT);
DCL-F RACEP     disk USAGE(*INPUT) RENAME(RACEFMT:RFMT);
DCL-F RACEL1    disk USAGE(*UPDATE : *DELETE : *OUTPUT)
                          infds(FichierDS) recno(rang_race) keyed usropn;

       // https://www.ibm.com/docs/fr/i/7.5.0?topic=subroutine-using-file-error-infsr

DCL-S sflpag       packed(2:0) INZ(14); // Nombre de ligne à affi cher par page .. .
DCL-C SflMax        CONST(9999);  // Nombre de ligne maximum du sous-fichier

DCL-S decodage           char(10) INZ(' ');
DCL-S Lstrrn             packed(4:0) INZ(0);     // Dernier rrn écrit avant pagination ...
DCL-s chk                int(10) INZ(0);
DCL-S i                  packed(4:0) INZ(0);
DCL-S j                  packed(4:0) INZ(0);
DCL-S pos                packed(4:0) INZ(0);
DCL-S cpt_page           packed(4:0) INZ(0);
DCL-S rang_race          packed(5:0) INZ(0);
DCL-S norang_sfl         packed(4:0) INZ(0);
DCL-S autorisation_modif ind INZ(*off);
DCL-S Utilisateur_en_cours char(10) INZ(*USER);
DCL-S Selection_CAT_en_cours ind INZ(*OFF);

          // Zones pour codage-décodage
          // Attention, vérifier CURSUS001R (y'a une blague :D)
DCL-C Code1 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
DCL-C Code2 '&"è(-_çà)=!:;,*ù$£@§/.?#[]';

DCL-S Sortie_tpchoix IND INZ(*OFF);

DCL-PR printf int(10) Extproc('printf');    // Machin qui permet de faire du DSPLY "long";
   format pointer Value Options(*String);
END-PR;

DCL-PR Looser ind; // Fonction qui renvoie un indicateur
   EP3RACE      packed(4:0);
END-PR;

DCL-PR Winner ind;  // Fonction qui renvoie un indicateur
   EP3RACE      packed(4:0);
END-PR;

DCL-PR Vismois2 char(9); // Fonction qui renvoie une char de 9
   datemois date;
END-PR;

DCL-PR Diffjours int(5); // Fontion qui renvoir un integer de 5
   EDTRACE date;
END-PR;

DCL-PR DTMOIS  date;    // Fontion qui renvoir un integer de 5
   EDTRACE date;
END-PR;
           // Programme externe d'impression
           // On lui passe un paramètre de 4 de long en numérique
           // (facultatif)
DCL-PR Programme_Impression extpgm('RACEPRINT');
   *N packed(4:0) options(*NOPASS);
END-PR;

          // Renommage des indicateurs pour faire plus Bô ...
          // Cette technique n'a pas besoin du mot clé INDARA dans le DSPF
DCL-S pIndicators Pointer Inz(%Addr(*In));
DCL-DS DspInd Based(pIndicators);
   Sortie               Ind Pos(3);
   Aide                 Ind Pos(4);
   Creation             Ind Pos(6);
   Impression           Ind Pos(7);
   Annuler              Ind Pos(12);
   Confirmer            Ind Pos(23);
   Sfl_Clr              Ind Pos(31);
   Sfl_Dsp              Ind Pos(32);
   Roll                 Ind Pos(39);
   Z_Typ_Change         Ind Pos(42);
   erreur_saisie_norace Ind Pos(57);
   imprimure            Ind Pos(58);
   Name_Change          Ind Pos(62);
   Sfl_End              Ind Pos(90);
end-ds;

        // Description de la DS nommée dans le mot clé INFDS dans le DCL-F du
        // fichier écran
DCL-DS info;    // Vision "hexa" de la saisie clavier
   cfkey char(1) pos(369);
END-DS;

DCL-DS ODBF;
   ODBF1 char(27) inz('OVRDBF FILE(RACEL1) TOFILE(');
   ODBF3 char(8) inz('/RACEL1)');
END-DS;

        // API système qui sert à déclencher une commande de l'OS  (en CL)
DCL-S commande char(80);
DCL-PR QCMDEXC Extpgm;
   *n char(1000) Const options(*Varsize);
   *n packed(15:5) Const;
END-PR;

DCL-C F_SIX CONST(X'36');   // Vision hexadecimale de la touche F6

       // Description des options du sous-fichier:
DCL-C Selection      CONST('1');
DCL-C Afficher       CONST('5');
DCL-C Kill           CONST('4');
DCL-C Modification   CONST('2');
DCL-C Opt_imprimer   CONST('8');
DCL-C commentaire    CONST('9');

       // Les Dataara ...
DCL-S Autorisation char(1) dtaara('AUTOR');

       // Description de la lda. Celle-ci contiend le mot de passe autorisant les modifs
DCL-DS *N dtaara(*AUTO);
   Code_lda char(10);
END-DS;

       // DS des descriptions d'enregistrements lors de la log des suppressions option(4)
DCL-DS enreg_lu      likerec(RACEFMT);
DCL-DS enreg_sup_log likerec(rcsuplogF);

       // DS qui vont servir à l'affichage (FMT5) avec SORTA
DCL-DS DS7               likerec(RFMT);
DCL-DS DS8 dim(*auto:9999) likerec(RFMT);


/COPY RACES/QSRCRACE,FichierDS

       // ******************************************************************
       // **************** MAIN *******************************************
       // ******************************************************************

        // Ici, exsr "fantôme" de l'INZSR ... Cette sous-routine nommée *INZSR
        // est appellée automatique AVANT la première instruction.

Exsr Clear_Subfile;   // Vidage du sous-fichier

SETLL *LOVAL RACEFMT;

Build_Subfile_1();   // Remplissage du sous-fichier

Dou Sortie; // Tant que F3 et F12 ne sont pas activées
   Write Bas1;            // Afficher le format de bas d'écran

        //  dsply rrn1; // pour le débug ...

   rrn1 = 1;         // On force l'affichage de la première page

   Exfmt CTL1;           // Afficher le format de contrôle

   Select;

           // Si la zone "afficher à partir de" est saisit, on l'utilise pour
           // se positionner sur le fichier principal, on initialise le
           // sous-fichier, puis on le recharge.
      When Z_NORACE <> 0;
         SETLL Z_NORACE RACEFMT;
         exsr clear_Subfile;
         Build_Subfile_1();
         Clear Z_NORACE;

           // Traiter la demande de filtre d'affichage  --> pas encore au point, en cours de dev ...
      When Z_TYP_Change;
         Selection_CAT_en_cours = *ON;
         SETLL *LOVAL RACEFMT;
         exsr clear_Subfile;        // Vidage du sous-fichier
         Build_Subfile_2();        // Remplissage du sous-fichier
              //  Clear Z_TYP;            // RAZ du champ de repositionnement

           // Détection de la pagination.
           // On continu le chargement de la page suivante.
      When Roll;
              //  IF Selection_CAT_en_cours;
               //    Build_Subfile_2();        // Remplissage du sous-fichier
              //  ELSE;
         Build_Subfile_1();
              //  ENDIF;

             //  Touche F6. On appelle la procedure de création, puis on recharge
            // le sous-fichier à partir du début (cléf : *LOVAL)
      When Cfkey = F_SIX;
         Creaturae();
         SETLL *LOVAL RACEFMT;
         exsr clear_Subfile;
         Build_Subfile_1();

             // Touche F7 : L'impression n'est lancée que si le travail
             // n'est pas en cours d'arrêt. Après l'appel du programme,
             // on envoi un message 'RAC0002' (dont la définition est dans le
             // fichier de messages RACEMSG), dans l'historique du travail
      When Impression;
         If NOT %SHTDN;
            Programme_Impression();
            LIGNEMSG = 'Impression lancé';
            Imprimure = *ON;
         ENDIF;

             // Touche F21, on affiche une fenêtre de choix d'une bibliothèque
             // pour effectuer un OVRDBF "à la volée" via l'API système QCMDEXC
             // A la suite de ça, on refait un remplissage du sous-fichier
      When *IN21;
         EXFMT FMTOVRDBF;
         commande = odbf1 + %TRIM(ebib) + odbf3;
         CLOSE RACEL1;
         CALLP QCMDEXC(commande:%LEN(commande));
         OPEN RACEL1;

         SETLL *LOVAL RACEFMT;
         exsr clear_Subfile;
         Build_Subfile_2();

                  // test rsfl !!!!!!  *******************************
         RSFL();
                  // test rsfl !!!!!!   *****************************

           // Dans les autres cas (à priori, ENTREE), on appelle la procédure
           // de lecture du sous-fichier, puis on refait un remplissage à
           // partir du début (clef *LOVAL)
      Other;
         TRT_READC();
         SETLL *LOVAL RACEFMT;
         exsr clear_Subfile;
         Build_Subfile_1();
   Endsl;
Enddo;

*Inlr = *On;
Close RACEL1;

         // on-exit procedure_sortie();

       // ******************************************************************
       // Sous-routine d'initialisation globale du programme.
       // Cette routine n'est jamais appellée. Elle s'exécute dès le lancement.
       // Ici, on va ouvrir manuellement RACEL1, car il se peut que l'on
       // modifie sa bibliothèque via un OVRDBF, il faudra alors le fermer
       // pour le ré-ouvrir, et ce, manuellement.
       // ******************************************************************
begsr *inzsr;

   in *lock *dtaara;

   If  NOT %OPEN(RACEL1);
      OPEN RACEL1;
   ENDIF;

ENDSR;

       //*******************************************************************
       // Subfile_Clear - Clear the subfile
       //*******************************************************************
Begsr Clear_Subfile;
   Rrn1 = *Zero;         // Effacer le numéro d'enregistrement de sous-fichier.
   Lstrrn = *Zero;       // Effacer le numéro d'enregistrement de sous-fichier enregistré
   Sfl_Clr = *On;        // Activer l'indicateur de vidage de sous-fichier.
   Write     CTL1;       // Vidage du sous-fichier.
   Sfl_Clr  = *Off;      // Désactiver l'indicateur de vidage de sous-fichier
   Sfl_Dsp  = *Off;      // Désactiver le Non-Affichage du dsp
   Sfl_End = *Off;       // Désactiver l'indicateur de fin de sous-fichier.(à suivre .../ Fi

Endsr;

       //*******************************************************************
       // Utilisée par le on-exit
       //*******************************************************************
dcl-proc procedure_sortie;
   SND-MSG 'terminé!';
END-PROC;

       // ******************************************************************
       // Traitement du READC
       // Le READC (READ Change) va lire les enregistrements MODIFIES du
       // sous-fichier. Pour chaque ligne où il y a une modification, on
       // regardera le code de l'option saisie (OPT étant la seule zone
       // modifiable du sous-fichier)
       // La lecture du READC se fera dans une boucle, tant qu'on a pas
       // atteint la fin de lecture des modifs.
       // OPT est comparé à une constante (décrit en DCL-C) puis, on appelle
       // la procédure concernée.
       // Pour la modification, on passera par un écran de saisie d'un
       // mot de passe. Ce dernier sera comparé (dans la procédure ok_modif)
       // au mot de passe saisit dans la LDA.
       // ******************************************************************
Dcl-Proc TRT_READC;
   Readc Sfl1;
   Dow Not %eof;
      Select;

         When OPT = Commentaire;
            Commenter();

         When OPT = Afficher;
            Ostendere();

         When OPT = Kill;
            Occidere();

         When OPT = Modification;

            clear codoto;
            exfmt fmtcodoto;
            autorisation_modif =  ok_modif(codoto);
            if autorisation_modif;
               Recencere();
            ENDIF;

         When OPT = Opt_imprimer;
            Imprimere();

         When OPT = 'A'; // en attente de specs, le client ne sachant pas ce qu'il veut ...
            TRT_A();
      Endsl;
      Readc Sfl1;
   ENDDO;
End-Proc;

Dcl-Proc TRT_A;
      // à coder ...
END-PROC;

       // ******************************************************************
       // Traitement de l'option 8=Imprimer.
       // On appelle le programme d'impression avec le numero de course à imprimer
       // ******************************************************************
Dcl-Proc Imprimere;

   Programme_impression(ENORACE);

END-PROC;
       // ******************************************************************
       // Traitement de l'option 2=Modification  (Le n° de la course n'est pas modifiable)
       // ******************************************************************
Dcl-Proc Recencere;
             // Les zones du sous-fichier sont transférées dans le format écran FMT2
   E2NORACE   =   ENORACE;
   E2NMRACE   =   ENMRACE;
   E2GRRACE   =   EGRRACE;
   E2DSRACE   =   EDSRACE;
   E2T1RACE   =   ET1RACE;
   DoW 0<1;
      EXFMT FMT2 ;
      select;
         when Sortie;
            leave;
         when Annuler;
            leave;
         other;
                    // L'indicateur ci-dessous est associé au mot clef CHANGE(62)
                    // déclaré dans l'écran
            if Name_Change and confirmer;
               CHAIN E2NORACE RACEL1;
               if %found(RACEL1);
                  NMRACE =   E2NMRACE;
                  GRRACE =   E2GRRACE;
                  IF E2DSRACE <> ' ';
                     DSRACE =   %DEC(E2DSRACE:3:0);
                  ELSE;
                     DSRACE = 0;
                  ENDIF;
                  T1RACE =   E2T1RACE;
                  update(e) RACEFMT
                          %fields (NMRACE:GRRACE:DSRACE:T1RACE);
                  if %error;
                     SND-MSG 'Erreur de mise à jour'; // Envoi du message dans l'histo
                  ENDIF;
               ENDIF;
               leave;
            endif;
      ENDSL;
   enddo;
   OPt = ' ';        // Remise à blanc de l'option saisie
   Update Sfl1;      // dans le sous-fichier
End-Proc;
       // ******************************************************************
       // Traitement de l'option 9=commentaires
       // ******************************************************************
Dcl-Proc Commenter;
   CHAIN ENORACE RACECOMP;
   E9NORACE = ENORACE;
   IF %FOUND;
      E9COMM = COMP_COMMENT;
      EXFMT FMT9 ;
      IF *IN59; // change sur zone commentaire
         COMP_COMMENT = E9COMM;
         UPDATE RACECOMFMT;
      ENDIF;
   ELSE;
      CLEAR E9COMM;
      EXFMT FMT9 ;
      IF *IN59; // change sur zone commentaire
         COMP_NORACE  = E9NORACE;
         COMP_COMMENT = E9COMM;
         WRITE RACECOMFMT;
      ENDIF;
   ENDIF;
   OPt = ' ';        // Remise à blanc de l'option saisie
   Update Sfl1;      // dans le sous-fichier
End-Proc;

       // ******************************************************************
       // Traitement de l'option 5=Afficher
       // On récupère certaines informations et on en fabrique.
       // E5DTRACE2 = la daite d'aujourd'hui + 1 jour, 1 mois, 1 an.
       // E5NMRACE = On remplace le texte "Semi" par "Half".
       // E5COMM = On récupère les 20 premiers caractères du commentaire
       // On alimente une DS que l'on trie pour afficher les 5 premières
       // courses
       // ******************************************************************
Dcl-Proc Ostendere;
   E5NORACE  = ENORACE;
   E5DTRACE  =   EDTRACE;
   E5NBJOURS = DiffJours(EDTRACE);
   LIBMOIS   = VisMois2(E5DTRACE);
   E5DTRACE2 = EDTRACE + %DAYS(1) + %MONTHS(1) + %YEARS(1);
   E5DTRACEM = DTMOIS(EDTRACE);  // EDTRACE + 1 mois ...
   E5TPRACE  =   ETPRACE;
   E5NMRACE = %SCANRPL('Semi' : 'Half-M' : ENMRACE);
   E5GRRACE  =   EGRRACE;
   E5AVRACE = EAVRACE;
   E5FORME  = EFORME;
   E5VAINQ  = EVAINQUEUR;

   CHAIN(N) ENORACE RACECOMP;
   E9NORACE = ENORACE;
   IF %FOUND;
      E5COMM = COMP_COMMENT;
      E5COMM =  %LEFT(COMP_COMMENT:20);
   ENDIF;

   j = 1;
   SETLL 1 RACEP;
   read RACEP DS7;
   eval-corr DS8(j) = DS7;
   dow not %eof;
      j += 1;
      read RACEP DS7;
      eval-corr DS8(j) = DS7;
   ENDDO;

            //       SORTA(D) DS8 %FIELDS(T1RACE:NORACE);
            // l'exemple ci-dessus est si plusieurs norace pour le même T1race ...

   SORTA(D) DS8 %FIELDS(T1RACE);

   TOP5N1 = DS8(1).NORACE;
   TOP5N2 = DS8(2).NORACE;
   TOP5N3 = DS8(3).NORACE;
   TOP5N4 = DS8(4).NORACE;
   TOP5N5 = DS8(5).NORACE;
   TOP5T1 = DS8(1).T1RACE;
   TOP5T2 = DS8(2).T1RACE;
   TOP5T3 = DS8(3).T1RACE;
   TOP5T4 = DS8(4).T1RACE;
   TOP5T5 = DS8(5).T1RACE;

   EXFMT FMT5 ;

   OPt = ' ';        // Remise à blanc de l'option saisie
   Update Sfl1;      // dans le sous-fichier
End-Proc;

       // ******************************************************************
       // Traitement de l'option 4=Supprimer
       // ******************************************************************
Dcl-Proc Occidere;
   E4NORACE   =   ENORACE;
   E4DTRACE   =   EDTRACE;
   E4TPRACE   =   ETPRACE;
   E4NMRACE   =   ENMRACE;
   DoW not Sortie or not Annuler;
      EXFMT FMT4 ;
      select;
         when Sortie;
            leave;
         when Annuler;
            leave;
         when Confirmer;
            CHAIN E4NORACE RACEL1 enreg_lu;
            if %found(RACEL1);

               eval-corr enreg_sup_log = enreg_lu;
               enreg_sup_log.util = utilisateur_en_cours;

               enreg_sup_log.dtsup = %date();
                    //     MOVE UDATE enreg_sup_log.dtsup

               enreg_sup_log.tmsup = %time();
               write(e) rcsuplogf enreg_sup_log;
               IF %ERROR;
                  IF %STATUS = 1211;
                     SND-MSG 'Erreur write sur fichier non ouvert';
                  ELSE;
                     SND-MSG 'Erreur écriture Log';
                  ENDIF;
               ENDIF;

               delete RACEFMT;
               SND-MSG %MSG('RAC0003' : 'RACEMSG' : 'Test');
            ENDIF;
            leave;
      ENDSL;
   enddo;
   OPt = ' ';        // Remise à blanc de l'option saisie
   Update Sfl1;      // dans le sous-fichier
End-Proc;
       // ******************************************************************
       // Traitement du F6=Création
       // On gère le F4 avec sfl de choix
       // ******************************************************************
Dcl-Proc Creaturae;
   clear E6NORACE;
   clear E6DTRACE;
   clear E6TPRACE;
   clear E6NMRACE;
   clear E6GRRACE;
   clear E6DSRACE;
   clear E6T1RACE;
   clear E6P3RACE;
   DOW 1 = 1;
      EXFMT FMT6 ;
      select;
         when Annuler;
            Leave;
         when Sortie;
            Leave;
         when aide;
            IF FLD = 'E6TPRACE' ;
               TRT_CHOIXTPRACE();
            ENDIF;
         when Confirmer;
            SETLL E6NORACE RACEL1;
            If %EQUAL;
               erreur_saisie_norace = *ON;
            ELSE;
               SETLL E6TPRACE RACETP1;
               IF %EQUAL (RACETP1);
                  NORACE   =   E6NORACE;            // N° de course
                  DTRACE   =   E6DTRACE;            // Date de la course
                  TPRACE   =   E6TPRACE;            //Type de course
                  NMRACE   =   E6NMRACE;            // Nom
                  GRRACE   =   E6GRRACE;            // Genre
                  DSRACE   =   E6DSRACE;            // Distance
                  T1RACE   =   E6T1RACE;            // Temps
                  P3RACE   =   E6P3RACE;            // Position relative
                  write(e) racefmt;
                  IF %ERROR;
                     SND-MSG 'Erreur écriture';
                  ENDIF;
                  Leave;
               ELSE;
                  *IN55 = *ON;   // Affichage ERRMSG dans l'écran
               ENDIF;
            ENDIF;
      ENDSL;
   ENDDO;
End-Proc;

        // ******************************************************************
       // Débranchement vers un prog de choix de tprace.
       // Gestion d'un sous-fichier statique (remplissage complet en "one shoot")
       // ******************************************************************
Dcl-Proc trt_choixtprace;
   rrn2 = *zero;
   *in51 = *on;
   write Sf2ctl;
   *in51 = *off;
   *in62 = *on;

            // B- Lecture de la base de données
   Setll *loval form;  // On se positionne en début de fichier (valeur de clef la plus basse)
   Read form;

          // B- Tant que non fin de fichier
   Dow (Not %eof) And (Rrn2 <= Sflmax); // TQ Non Fin de Fichier et limite de 9999 lignes

      Rrn2 += 1;  // Incrémentation du compteur de ligne
            // les zones du PF ayant le même nom que celle du SFL, le "move" de celles-ci
            // est implicite et ça se passe ici !  Néanmoins, pour des fins de démo, on utilise un a
      libelle = libelle_du_type_de_course;
      Write Sfl2;       // Ecriture du format de sous-fichier
      Read form;    // Lecture enregistrement suivant
      if %eof;
         *in92 = *On;
      ENDIF;

   Enddo;

          // C -Cas particulier (aucun enregistrement)
   If Rrn2 = *Zero;  // Si aucun enregistement à charger
      *In92 = *On;    // Indicateur de "Fin"
      *In62 = *Off;    // Indicateur denon affichage
   Endif;

   DOU Sortie_tpchoix;

          // rrn2 = 1;

      Exfmt Sf2ctl;       // Affiche le format de contrôle du SFL
      if Annuler;
         Leave;
      ENDIF;
      Readc Sfl2;           // Lecture de toutes les lignes du SFL
      Dow Not %eof;         // Tant que toutes les lignes modifiés n'ont pas été traitées
         Select;
            When ZOPT = Selection;  // Option 1 saisie
               E6TPRACE = TYPE;
               zopt = ' ';
               update sfl2;
               Sortie_tpchoix = *on;
               Leave;
         Endsl;
      Enddo;

   ENDDO;

End-Proc;

       // ******************************************************************
       // Build_Subfile - Build the list
       // ******************************************************************
Dcl-Proc Build_Subfile_1;

   Rrn1 = Lstrrn;  // Le "relative record number" reçoit la valeur du dernier
                               // numéro relatif sauvegardé

   FOR i=1 to Sflpag;
      READ(N) RACEFMT;    // la lecture pour remplir le sfl se fait en nolock
      if %eof;
         Sfl_End=*on;
         leave;
      ELSE;
         Remp_SFL();
      ENDIF;
   ENDFOR;

   If Rrn1 = *Zero;      // Si aucun enregistrement détecté dans le sous-fichier
      Sfl_Dsp = *on;            //   Activer l'indicateur masquant le sous-fichier
   Endif;

   Lstrrn = Rrn1;  // Sauvegarder le dernier enregistrement cha      rgé
                                   // pour faciliter le chargement de la page suivante
END-PROC;

       // ******************************************************************
       // Build_Subfile - Build the list
       // ******************************************************************
Dcl-Proc Build_Subfile_2;

   Rrn1 = Lstrrn;  // Le "relative record number" reçoit la valeur du dernier
                               // numéro relatif sauvegardé

   cpt_page = 0;
   DOW 1=1;
      READ(N) RACEFMT;    // la lecture pour remplir le sfl se fait en nolock
      if %eof;
         Sfl_End=*on;
         leave;
      ELSE;
         If Z_TYP = TPRACE;
            Remp_SFL();
            cpt_page += 1;
         endif;
         if cpt_page = 14;
            leave;
         ENDIF;
      endif;
   ENDDO;

   If Rrn1 = *Zero;      // Si aucun enregistrement détecté dans le sous-fichier
      Sfl_Dsp = *on;            //   Activer l'indicateur masquant le sous-fichier
   Endif;
   Lstrrn = Rrn1;  // Sauvegarder le dernier enregistrement cha      rgé
                                   // pour faciliter le chargement de la page suivante

End-Proc;
       // ******************************************************************
       // Coeur du remplissage du sous-fichier
       // ******************************************************************
Dcl-Proc Remp_SFL;

   Rrn1 += 1;    // Incrémenter le numéro de ligne de sous-fichier
   ENORACE   =    NORACE;
   EDTRACE   =    DTRACE;
   ETPRACE   =    TPRACE;
   ENMRACE   =    NMRACE;
   EGRRACE   =    GRRACE;
   EDSRACE   =    %EDITC(DSRACE : 'Z');
   ET1RACE   =    T1RACE;
   EP3RACE   =    P3RACE;
   EAVRACE   =    AVRACE;
   EFORME    =    FORME;
   EVAINQUEUR =   VAINQUEUR;
   *IN70=Looser(EP3RACE);
   *IN71=Winner(EP3RACE);
   Write Sfl1;         // Charger en mémoire le format de sous-fichier

End-Proc;

       // ******************************************************************
       // Fonctions  (interne, les autres étant sous forme de modules, voir le BNDDIR)
       // ******************************************************************
Dcl-proc ok_modif;
   Dcl-pi *n ind;         // On renvoi un indicateur
      p_codoto char(10);
   END-PI;

   Monitor;
      decodage = *blank;
      decodage = %xlate(Code2:Code1:code_lda);
      if decodage = p_codoto;
         return *ON;
      else;
         return *OFF;
      ENDIF;
   On-Error *all;
      SND-MSG 'Erreur de xlate!';
      return *OFF;
   EndMon;
END-PROC;

       // ******************************************************************
Dcl-proc RSFL; // démo pour accès direct à une ligne du sfl
       // ******************************************************************
   norang_sfl = 1;
   chain norang_sfl sfl1;
   DOW norang_sfl < 10;
      if %found() and norang_sfl = 7;
         SND-MSG 'found';
         enmrace = 'PremièreLigne';
         Update Sfl1;      // dans le sous-fichier
      else;
         SND-MSG 'not found';
      ENDIF;
      norang_sfl += 1;
      chain norang_sfl sfl1;
   ENDDO;
END-PROC;
