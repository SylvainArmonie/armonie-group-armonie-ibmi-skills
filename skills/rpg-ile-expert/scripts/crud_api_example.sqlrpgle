**FREE
// ============================================================================
// Programme : CRUDAPI
// Description : Exemple complet de CRUD sur une API REST depuis IBM i
// Auteur : Skill rpg-ile-expert
// ============================================================================

ctl-opt dftactgrp(*no) actgrp(*caller);
ctl-opt option(*srcstmt:*nodebugio);

// ----------------------------------------------------------------------------
// Déclarations globales
// ----------------------------------------------------------------------------
dcl-s gUrl       varchar(500);
dcl-s gBody      varchar(5000);
dcl-s gHeaders   varchar(500);
dcl-s gHttpCode  dec(3);

// Structure pour un produit
dcl-ds dsProduct qualified;
    id          char(10);
    title       char(100);
    price       zoned(7:2);
    category    char(50);
    description varchar(500);
end-ds;

// ----------------------------------------------------------------------------
// Programme principal
// ----------------------------------------------------------------------------
dsply '=== Début du programme CRUD API ===';

// 1. GET - Récupérer tous les produits
getAllProducts();

// 2. GET - Récupérer un produit par ID
getProductById('1');

// 3. POST - Créer un nouveau produit
createProduct('Produit Test':49.99:'Test Category':'Description test');

// 4. PUT - Modifier un produit
updateProduct('1':'Produit Modifié':59.99);

// 5. DELETE - Supprimer un produit
deleteProduct('1');

dsply '=== Fin du programme CRUD API ===';

*inlr = *on;

// ============================================================================
// Procédure : getAllProducts
// Description : Récupère tous les produits de l'API
// ============================================================================
dcl-proc getAllProducts;
    dcl-s wId       char(10);
    dcl-s wTitle    char(100);
    dcl-s wPrice    zoned(7:2);
    dcl-s wCategory char(50);
    dcl-s wCount    int(10) inz(0);

    dsply '--- GET ALL PRODUCTS ---';
    
    exec sql set option commit = *none;
    
    exec sql
        declare curProducts cursor for
        select id, title, price, category
        from JSON_TABLE(
            QSYS2.HTTP_GET(
                'https://fakestoreapi.com/products',
                ''
            ),
            '$[*]' COLUMNS (
                id       CHAR(10)     PATH '$.id',
                title    CHAR(100)    PATH '$.title',
                price    DEC(7,2)     PATH '$.price',
                category CHAR(50)     PATH '$.category'
            )
        );
    
    exec sql open curProducts;
    
    dou sqlcode <> 0;
        exec sql fetch curProducts into :wId, :wTitle, :wPrice, :wCategory;
        
        if sqlcode = 0;
            wCount += 1;
            // Afficher les 3 premiers pour la démo
            if wCount <= 3;
                dsply ('ID: ' + %trim(wId) + ' - ' + %subst(wTitle:1:30));
            endif;
        endif;
    enddo;
    
    exec sql close curProducts;
    
    dsply ('Total produits récupérés: ' + %char(wCount));
end-proc;

// ============================================================================
// Procédure : getProductById
// Description : Récupère un produit par son ID
// ============================================================================
dcl-proc getProductById;
    dcl-pi *n;
        pId char(10) const;
    end-pi;
    
    dcl-s wUrl varchar(500);
    
    dsply ('--- GET PRODUCT BY ID: ' + %trim(pId) + ' ---');
    
    wUrl = 'https://fakestoreapi.com/products/' + %trim(pId);
    
    exec sql set option commit = *none;
    
    exec sql
        select id, title, price, category, description
        into :dsProduct.id, :dsProduct.title, :dsProduct.price,
             :dsProduct.category, :dsProduct.description
        from JSON_TABLE(
            QSYS2.HTTP_GET(:wUrl, ''),
            '$' COLUMNS (
                id          CHAR(10)     PATH '$.id',
                title       CHAR(100)    PATH '$.title',
                price       DEC(7,2)     PATH '$.price',
                category    CHAR(50)     PATH '$.category',
                description VARCHAR(500) PATH '$.description'
            )
        );
    
    if sqlcode = 0;
        dsply ('Titre: ' + %subst(dsProduct.title:1:40));
        dsply ('Prix: ' + %char(dsProduct.price));
        dsply ('Catégorie: ' + %trim(dsProduct.category));
    else;
        dsply ('Erreur: ' + %char(sqlcode));
    endif;
end-proc;

// ============================================================================
// Procédure : createProduct
// Description : Crée un nouveau produit via POST
// ============================================================================
dcl-proc createProduct;
    dcl-pi *n;
        pTitle       char(100) const;
        pPrice       zoned(7:2) const;
        pCategory    char(50) const;
        pDescription char(200) const;
    end-pi;
    
    dcl-s wBody    varchar(1000);
    dcl-s wNewId   char(10);
    dcl-s wNewTitle char(100);
    
    dsply '--- CREATE PRODUCT (POST) ---';
    
    // Construire le body JSON
    wBody = '{"title":"' + %trim(pTitle) + '",'
          + '"price":' + %char(pPrice) + ','
          + '"category":"' + %trim(pCategory) + '",'
          + '"description":"' + %trim(pDescription) + '"}';
    
    exec sql set option commit = *none;
    
    exec sql
        select id, title
        into :wNewId, :wNewTitle
        from JSON_TABLE(
            QSYS2.HTTP_POST(
                'https://fakestoreapi.com/products',
                :wBody,
                '{"header":"Content-Type,application/json;charset=utf-8;"}'
            ),
            '$' COLUMNS (
                id    CHAR(10)  PATH '$.id',
                title CHAR(100) PATH '$.title'
            )
        );
    
    if sqlcode = 0;
        dsply ('Produit créé - ID: ' + %trim(wNewId));
        dsply ('Titre: ' + %subst(wNewTitle:1:40));
    else;
        dsply ('Erreur création: ' + %char(sqlcode));
    endif;
end-proc;

// ============================================================================
// Procédure : updateProduct
// Description : Met à jour un produit via PUT
// ============================================================================
dcl-proc updateProduct;
    dcl-pi *n;
        pId    char(10) const;
        pTitle char(100) const;
        pPrice zoned(7:2) const;
    end-pi;
    
    dcl-s wUrl   varchar(500);
    dcl-s wBody  varchar(1000);
    dcl-s wUpdId char(10);
    dcl-s wUpdTitle char(100);
    
    dsply ('--- UPDATE PRODUCT (PUT) ID: ' + %trim(pId) + ' ---');
    
    wUrl = 'https://fakestoreapi.com/products/' + %trim(pId);
    wBody = '{"title":"' + %trim(pTitle) + '",'
          + '"price":' + %char(pPrice) + '}';
    
    exec sql set option commit = *none;
    
    exec sql
        select id, title
        into :wUpdId, :wUpdTitle
        from JSON_TABLE(
            QSYS2.HTTP_PUT(
                :wUrl,
                :wBody,
                '{"header":"Content-Type,application/json;charset=utf-8;"}'
            ),
            '$' COLUMNS (
                id    CHAR(10)  PATH '$.id',
                title CHAR(100) PATH '$.title'
            )
        );
    
    if sqlcode = 0;
        dsply ('Produit modifié - ID: ' + %trim(wUpdId));
        dsply ('Nouveau titre: ' + %subst(wUpdTitle:1:40));
    else;
        dsply ('Erreur modification: ' + %char(sqlcode));
    endif;
end-proc;

// ============================================================================
// Procédure : deleteProduct
// Description : Supprime un produit via DELETE
// ============================================================================
dcl-proc deleteProduct;
    dcl-pi *n;
        pId char(10) const;
    end-pi;
    
    dcl-s wUrl   varchar(500);
    dcl-s wDelId char(10);
    
    dsply ('--- DELETE PRODUCT ID: ' + %trim(pId) + ' ---');
    
    wUrl = 'https://fakestoreapi.com/products/' + %trim(pId);
    
    exec sql set option commit = *none;
    
    exec sql
        select id
        into :wDelId
        from JSON_TABLE(
            QSYS2.HTTP_DELETE(:wUrl, ''),
            '$' COLUMNS (
                id CHAR(10) PATH '$.id'
            )
        );
    
    if sqlcode = 0;
        dsply ('Produit supprimé - ID: ' + %trim(wDelId));
    elseif sqlcode = 100;
        dsply 'Suppression effectuée (pas de retour)';
    else;
        dsply ('Erreur suppression: ' + %char(sqlcode));
    endif;
end-proc;
