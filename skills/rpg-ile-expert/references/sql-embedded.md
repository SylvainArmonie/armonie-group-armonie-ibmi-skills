# SQL Embarqué en RPG (SQLRPGLE)

Guide pour l'intégration de SQL dans les programmes RPG ILE.

## Configuration de base

```rpgle
**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

// Options SQL
exec sql set option commit = *none,
                    datfmt = *iso,
                    closqlcsr = *endmod;
```

### Options SQL courantes

| Option | Valeur | Description |
|--------|--------|-------------|
| `commit` | `*none` | Pas de commit automatique |
| `datfmt` | `*iso` | Format date ISO |
| `closqlcsr` | `*endmod` | Ferme curseurs en fin de module |
| `naming` | `*sql` ou `*sys` | Notation des schémas |

## Variables hôtes

Les variables RPG utilisées dans SQL doivent être préfixées par `:`.

```rpgle
dcl-s clientId    int(10);
dcl-s clientNom   char(50);
dcl-s clientEmail varchar(100);

// Utilisation dans SQL
exec sql
    select nom, email
    into :clientNom, :clientEmail
    from clients
    where id = :clientId;
```

## Requêtes SELECT

### SELECT INTO (une seule ligne)

```rpgle
dcl-s nom    char(50);
dcl-s solde  packed(11:2);

exec sql
    select nom, solde
    into :nom, :solde
    from comptes
    where numero = '12345';

if sqlcode = 0;
    dsply ('Client: ' + %trim(nom));
elseif sqlcode = 100;
    dsply 'Aucun enregistrement trouvé';
else;
    dsply ('Erreur SQL: ' + %char(sqlcode));
endif;
```

### Curseur (plusieurs lignes)

```rpgle
dcl-s id      int(10);
dcl-s nom     char(50);
dcl-s montant packed(9:2);

// 1. Déclarer le curseur
exec sql
    declare curClients cursor for
    select id, nom, montant
    from clients
    where statut = 'A'
    order by nom;

// 2. Ouvrir le curseur
exec sql open curClients;

// 3. Boucle de lecture
dou sqlcode <> 0;
    exec sql
        fetch curClients
        into :id, :nom, :montant;
    
    if sqlcode = 0;
        // Traitement de la ligne
        dsply %trim(nom);
    endif;
enddo;

// 4. Fermer le curseur
exec sql close curClients;
```

### Curseur avec structure

```rpgle
dcl-ds dsClient qualified;
    id      int(10);
    nom     char(50);
    email   char(100);
    solde   packed(11:2);
end-ds;

exec sql
    declare curCli cursor for
    select id, nom, email, solde
    from clients;

exec sql open curCli;

dou sqlcode <> 0;
    exec sql fetch curCli into :dsClient;
    
    if sqlcode = 0;
        dsply dsClient.nom;
    endif;
enddo;

exec sql close curCli;
```

### Curseur avec FOR LOOP (moderne)

```rpgle
// Pas besoin de déclarer/ouvrir/fermer
exec sql
    declare curFor cursor for
    select id, nom from clients where actif = 'O';

exec sql open curFor;

dcl-s wId  int(10);
dcl-s wNom char(50);

dow 1 = 1;
    exec sql fetch curFor into :wId, :wNom;
    if sqlcode <> 0;
        leave;
    endif;
    dsply wNom;
enddo;

exec sql close curFor;
```

## INSERT, UPDATE, DELETE

### INSERT

```rpgle
dcl-s nouveauNom   char(50);
dcl-s nouveauEmail char(100);

nouveauNom = 'DUPONT';
nouveauEmail = 'dupont@example.com';

exec sql
    insert into clients (nom, email, date_creation)
    values (:nouveauNom, :nouveauEmail, current_date);

if sqlcode = 0;
    dsply 'Client créé';
else;
    dsply ('Erreur: ' + %char(sqlcode));
endif;
```

### INSERT avec récupération de l'ID

```rpgle
dcl-s newId int(10);

exec sql
    select id into :newId
    from final table (
        insert into clients (nom, email)
        values ('MARTIN', 'martin@example.com')
    );

dsply ('Nouvel ID: ' + %char(newId));
```

### UPDATE

```rpgle
dcl-s clientId    int(10);
dcl-s nouveauSolde packed(11:2);

clientId = 123;
nouveauSolde = 1500.00;

exec sql
    update clients
    set solde = :nouveauSolde,
        date_maj = current_timestamp
    where id = :clientId;

dsply ('Lignes modifiées: ' + %char(sqlerrd(3)));
```

### DELETE

```rpgle
dcl-s dateLimit date;

dateLimit = %date() - %years(2);

exec sql
    delete from archives
    where date_archive < :dateLimit;

dsply ('Lignes supprimées: ' + %char(sqlerrd(3)));
```

## Gestion des erreurs SQL

### Variable SQLCODE

| Valeur | Signification |
|--------|---------------|
| 0 | Succès |
| 100 | Aucune donnée trouvée / Fin de curseur |
| < 0 | Erreur |
| > 0 (sauf 100) | Avertissement |

### Variable SQLSTATE

Code à 5 caractères plus précis que SQLCODE.

| Préfixe | Signification |
|---------|---------------|
| 00 | Succès |
| 01 | Avertissement |
| 02 | Pas de données |
| 21+ | Erreur |

### Exemple de gestion d'erreurs

```rpgle
dcl-s msgErreur char(200);

exec sql
    update clients set solde = 0 where id = :id;

select;
    when sqlcode = 0;
        dsply 'Mise à jour réussie';
    when sqlcode = 100;
        dsply 'Client non trouvé';
    when sqlcode < 0;
        exec sql
            get diagnostics condition 1
            :msgErreur = message_text;
        dsply msgErreur;
endsl;
```

## SQL Dynamique

### EXECUTE IMMEDIATE

```rpgle
dcl-s sqlStmt varchar(1000);

sqlStmt = 'DELETE FROM temp_data WHERE session_id = ''' 
        + %trim(sessionId) + '''';

exec sql execute immediate :sqlStmt;
```

### PREPARE et EXECUTE

```rpgle
dcl-s sqlStmt varchar(1000);
dcl-s paramVal char(10);

sqlStmt = 'UPDATE clients SET statut = ? WHERE code = ?';

exec sql prepare stmtUpd from :sqlStmt;

paramVal = 'ACTIF';
exec sql execute stmtUpd using :paramVal, :codeClient;
```

## Bonnes pratiques

1. **Toujours vérifier SQLCODE** après chaque opération SQL
2. **Utiliser `commit = *none`** pour les opérations non transactionnelles
3. **Fermer les curseurs** explicitement avec `close`
4. **Utiliser des variables hôtes** plutôt que la concaténation SQL
5. **Préférer les curseurs** aux SELECT INTO pour les résultats multiples
6. **Utiliser GET DIAGNOSTICS** pour des messages d'erreur détaillés
7. **Indexer les colonnes** utilisées dans WHERE et JOIN

## Intégration avec les webservices

Voir `references/webservices.md` pour l'utilisation de `QSYS2.HTTP_*` et `JSON_TABLE` en combinaison avec SQL embarqué.
