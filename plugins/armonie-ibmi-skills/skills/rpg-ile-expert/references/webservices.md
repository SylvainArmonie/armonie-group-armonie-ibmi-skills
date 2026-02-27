# Consommation de Webservices REST sur IBM i

Guide complet pour consommer des APIs REST depuis l'IBM i en utilisant SQL (QSYS2.HTTP_*) et RPG ILE.

## Méthodes disponibles

| Fonction SQL | Méthode HTTP | Usage |
|--------------|--------------|-------|
| `QSYS2.HTTP_GET` | GET | Récupérer des données |
| `QSYS2.HTTP_POST` | POST | Créer des données |
| `QSYS2.HTTP_PUT` | PUT | Modifier des données |
| `QSYS2.HTTP_DELETE` | DELETE | Supprimer des données |
| `QSYS2.HTTP_GET_VERBOSE` | GET | GET avec headers de réponse |

## Structure JSON_TABLE

```sql
SELECT colonnes
FROM JSON_TABLE(
    QSYS2.HTTP_xxx('url', 'options'),
    'chemin_json' COLUMNS (
        colonne TYPE PATH '$.chemin'
    )
);
```

### Chemins JSON

- `'$'` : Objet JSON unique (racine)
- `'$[*]'` : Tableau JSON (parcours de tous les éléments)
- `'$.propriete'` : Accès à une propriété
- `'$.objet.sous_propriete'` : Accès imbriqué

## HTTP_GET - Récupération de données

### Syntaxe de base (sans authentification)

```sql
SELECT *
FROM JSON_TABLE(
    QSYS2.HTTP_GET(
        'https://api.example.com/endpoint',
        ''  -- Pas de headers
    ),
    '$[*]' COLUMNS (
        id       CHAR(10)      PATH '$.id',
        name     CHAR(100)     PATH '$.name',
        price    DECIMAL(10,2) PATH '$.price'
    )
);
```

### Avec Bearer Token

```sql
SELECT *
FROM JSON_TABLE(
    QSYS2.HTTP_GET(
        'https://api.example.com/endpoint',
        '{"header":"Authorization,Bearer VOTRE_TOKEN_ICI"}'
    ),
    '$[*]' COLUMNS (
        id    CHAR(10)  PATH '$.id',
        name  CHAR(100) PATH '$.name'
    )
);
```

### Objet JSON unique (non tableau)

```sql
SELECT *
FROM JSON_TABLE(
    QSYS2.HTTP_GET(
        'https://api.example.com/user/123',
        '{"header":"Authorization,Bearer TOKEN"}'
    ),
    '$' COLUMNS (  -- '$' pour objet unique, pas '$[*]'
        code          CHAR(10)       PATH '$.tiers.code',
        raison_sociale CHAR(50)      PATH '$.tiers.raison_sociale',
        capital       DECIMAL(15,2)  PATH '$.tiers.capital_euro'
    )
);
```

## HTTP_POST - Création de données

```sql
SELECT *
FROM JSON_TABLE(
    QSYS2.HTTP_POST(
        'https://api.example.com/endpoint',
        '{"name":"Nouveau","price":29.99,"status":"active"}',  -- Corps JSON
        '{"header":"Content-Type,application/json;charset=utf-8;"}'
    ),
    '$' COLUMNS (
        id     CHAR(10)      PATH '$.id',
        name   CHAR(100)     PATH '$.name',
        status CHAR(20)      PATH '$.status'
    )
);
```

**Les 3 paramètres de HTTP_POST :**
1. URL de l'API
2. Corps de la requête (données JSON)
3. Headers HTTP (Content-Type obligatoire)

## HTTP_PUT - Mise à jour de données

```sql
SELECT *
FROM JSON_TABLE(
    QSYS2.HTTP_PUT(
        'https://api.example.com/endpoint/1',  -- ID dans l'URL
        '{"name":"Modifié","price":35.99}',
        '{"header":"Content-Type,application/json;charset=utf-8;"}'
    ),
    '$' COLUMNS (
        id    CHAR(10)      PATH '$.id',
        name  CHAR(100)     PATH '$.name',
        price DECIMAL(10,2) PATH '$.price'
    )
);
```

## HTTP_DELETE - Suppression de données

```sql
SELECT *
FROM JSON_TABLE(
    QSYS2.HTTP_DELETE(
        'https://api.example.com/endpoint/1',
        ''  -- Généralement pas de body pour DELETE
    ),
    '$' COLUMNS (
        id   CHAR(10) PATH '$.id',
        name CHAR(100) PATH '$.name'
    )
);
```

## HTTP_GET_VERBOSE - Récupérer les headers de réponse

Utile pour vérifier le code HTTP et les métadonnées de réponse.

```sql
WITH reponse AS (
    SELECT
        response_message    AS msg,
        response_http_header AS hdr
    FROM TABLE(
        QSYS2.HTTP_GET_VERBOSE(
            'https://api.example.com/products',
            '{"verboseResponseHeaderFormat":"json"}'
        )
    )
)
SELECT
    p.id,
    p.title,
    h.http_status_code
FROM reponse
CROSS JOIN JSON_TABLE(hdr, 'lax $'
    COLUMNS (http_status_code DEC(3) PATH '$.HTTP_STATUS_CODE')
) AS h
CROSS JOIN JSON_TABLE(msg, 'lax $[*]'
    COLUMNS (
        id    DEC(10,0)    PATH '$.id',
        title VARCHAR(100) PATH '$.title'
    )
) AS p;
```

## Intégration en RPG Full Free (SQLRPGLE)

### Structure de base

```rpgle
**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

// Variables pour les données
dcl-s id        zoned(10);
dcl-s name      char(100);
dcl-s price     zoned(7:2);
dcl-s status    char(20);

// Désactiver les transactions
exec sql set option commit = *none;

// Déclarer le curseur
exec sql
    declare c1 cursor for
    select id, name, price, status
    from JSON_TABLE(
        QSYS2.HTTP_GET('https://api.example.com/products', ''),
        '$[*]' COLUMNS (
            id     DEC(10,0)   PATH '$.id',
            name   CHAR(100)   PATH '$.name',
            price  DEC(7,2)    PATH '$.price',
            status CHAR(20)    PATH '$.status'
        )
    );

// Ouvrir le curseur
exec sql open c1;

// Boucle de lecture
dou sqlcode <> 0;
    exec sql fetch c1 into :id, :name, :price, :status;
    
    if sqlcode = 0;
        // Traitement des données
        dsply name;
        dsply %char(price);
    endif;
enddo;

// Fermer le curseur
exec sql close c1;

*inlr = *on;
```

### HTTP POST en RPG avec variables

```rpgle
**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-s url       varchar(500);
dcl-s jsonBody  varchar(2000);
dcl-s headers   varchar(500);
dcl-s newId     char(10);
dcl-s newName   char(100);

// Construire les données
url = 'https://api.example.com/products';
jsonBody = '{"name":"Produit RPG","price":99.99,"status":"active"}';
headers = '{"header":"Content-Type,application/json;charset=utf-8;"}';

// Désactiver commit
exec sql set option commit = *none;

// Exécuter le POST et récupérer le résultat
exec sql
    select id, name
    into :newId, :newName
    from JSON_TABLE(
        QSYS2.HTTP_POST(:url, :jsonBody, :headers),
        '$' COLUMNS (
            id   CHAR(10)  PATH '$.id',
            name CHAR(100) PATH '$.name'
        )
    );

if sqlcode = 0;
    dsply ('Créé: ' + %trim(newName) + ' ID=' + %trim(newId));
else;
    dsply ('Erreur SQL: ' + %char(sqlcode));
endif;

*inlr = *on;
```

### Gestion des erreurs HTTP

```rpgle
**FREE
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-s httpCode  dec(3);
dcl-s msgBody   varchar(5000);
dcl-s errMsg    char(200);

exec sql set option commit = *none;

// Appel avec récupération du code HTTP
exec sql
    select h.http_status_code, r.response_message
    into :httpCode, :msgBody
    from TABLE(
        QSYS2.HTTP_GET_VERBOSE(
            'https://api.example.com/products',
            '{"verboseResponseHeaderFormat":"json"}'
        )
    ) as r
    cross join JSON_TABLE(r.response_http_header, 'lax $'
        COLUMNS (http_status_code DEC(3) PATH '$.HTTP_STATUS_CODE')
    ) as h;

select;
    when httpCode >= 200 and httpCode < 300;
        dsply 'Succès';
        // Traiter msgBody...
    when httpCode >= 400 and httpCode < 500;
        dsply ('Erreur client: ' + %char(httpCode));
    when httpCode >= 500;
        dsply ('Erreur serveur: ' + %char(httpCode));
    other;
        dsply ('Code HTTP: ' + %char(httpCode));
endsl;

*inlr = *on;
```

## Types de données recommandés

### Pour affichage écran 5250

Les types VARCHAR et INT ne s'affichent pas sur écran 5250. Utiliser :

| Au lieu de | Utiliser |
|------------|----------|
| VARCHAR | CHAR |
| INT | DECIMAL(10,0) ou ZONED |
| BIGINT | DECIMAL(19,0) |

### Correspondance JSON vers SQL

| Type JSON | Type SQL recommandé |
|-----------|---------------------|
| string | CHAR(n) ou VARCHAR(n) |
| number (entier) | DECIMAL(p,0) |
| number (décimal) | DECIMAL(p,s) |
| boolean | CHAR(5) ('true'/'false') |
| null | Toléré par défaut |

## Headers HTTP courants

```sql
-- Authentification Bearer
'{"header":"Authorization,Bearer TOKEN_HERE"}'

-- Content-Type JSON
'{"header":"Content-Type,application/json;charset=utf-8;"}'

-- Headers multiples
'{"header":"Authorization,Bearer TOKEN;Content-Type,application/json"}'

-- Basic Auth (base64)
'{"header":"Authorization,Basic dXNlcjpwYXNz"}'
```

## Bonnes pratiques

1. **Toujours utiliser `set option commit = *none`** pour les appels HTTP
2. **Vérifier le code HTTP** avec HTTP_GET_VERBOSE pour les API critiques
3. **Utiliser des variables RPG** pour construire URL et body dynamiquement
4. **Préférer CHAR à VARCHAR** pour compatibilité écran 5250
5. **Gérer les erreurs SQL** avec `sqlcode` après chaque opération
6. **Documenter les API** consommées (URL, authentification, structure JSON)

## Exemple complet : CRUD sur une API

Voir le fichier `scripts/crud_api_example.sqlrpgle` pour un exemple complet de programme RPG effectuant toutes les opérations CRUD sur une API REST.
