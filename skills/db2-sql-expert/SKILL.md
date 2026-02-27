---
name: db2-sql-expert
description: Expert DB2 for i SQL. Procedures stockees, fonctions UDF/UDTF/pipelined, triggers, indexation avancee (EVI, MTI, index parfait, IOA), Visual Explain, plan cache, QAQQINI, services QSYS2, MQT, RCAC, CTE, OLAP, generation JSON/XML, IFS via SQL, REST API. Use when user asks to write SQL for IBM i, optimize queries, create procedures/functions/triggers, manage indexes, analyze Visual Explain, generate JSON/XML, read/write IFS, use QSYS2 services, troubleshoot SQL errors. Triggers - requete SQL, DB2 for i, QSYS2, MQT, RCAC, procedure stockee, CALL, FUNCTION, RETURNS TABLE, IFS SQL, Visual Explain, EVI, MTI, CTE, OLAP, ROW_NUMBER, SYSTABLES, trigger, PIPE, JSON_TABLE, JSON_OBJECT, LISTAGG, XMLTABLE, QAQQINI, OPTIMIZE FOR, SYSIXADV. Do NOT use for RPG (use rpg-ile-expert), RPG III (use rpg3-expert), or CL-only admin (use ibmi-admin-expert).
---

# DB2 for i SQL Expert - IBM i

Skill de reference pour l'ecriture de requetes SQL optimisees sur DB2 for i.
Base sur :
- Les travaux de Sylvain Aktepe (IBM Champion 2025), Armonie Group / NOTOS
- Le Redbook IBM SG24-8326 "SQL Procedures, Triggers, and Functions on IBM DB2 for i"
- Les enseignements de Birgitta Hauser (IBM Champion, "Reine du SQL DB2 for i") : vues SQL, logique metier en base, generation JSON/XML, acces IFS, UDTF, modernisation
- Les articles de Christian Griere (expert IBM France, specialiste indexation DB2 for i) : index parfait, EVI, MTI, Visual Explain, plan cache, QAQQINI, optimisation IO

## Philosophie

Chaque requete SQL generee DOIT :
1. **Etre expliquee** — Commenter POURQUOI on fait ce choix, pas juste CE QU'ON fait
2. **Etre optimisee** — Privilegier les acces index, eviter les full table scan (approche Christian Griere)
3. **Etre pedagogique** — Accessible aux debutants tout en etant rigoureuse pour les experts
4. **Deplacer la logique metier en base** — Vues, procedures, fonctions, triggers (approche Birgitta Hauser)

## Instructions

### Etape 1 : Identifier le type de besoin

Analyser la demande et classifier :

| Type de besoin | Section de reference |
|----------------|---------------------|
| SELECT, JOIN, sous-requetes, filtres | Fondamentaux SQL |
| Optimisation, index, performance | Indexation & Performance (Griere) |
| Services SQL IBM i (QSYS2) | Services SQL IBM i |
| Lecture/ecriture IFS via SQL | Services IFS |
| MQT (tables materialisees) | MQT |
| RCAC (controle acces lignes/colonnes) | RCAC |
| CTE, fonctions analytiques, OLAP | Fonctions avancees |
| Procedures stockees | Procedures (Redbook Ch.4/Ch.8) |
| Fonctions SQL (UDF/UDTF/Pipelined) | Fonctions (Redbook Ch.6) |
| Triggers SQL | Triggers (Redbook Ch.5) |
| Generation JSON/XML | JSON/XML (Hauser) |
| Visual Explain et diagnostic plan | Visual Explain (Griere) |
| Administration systeme via SQL | Administration SQL |
| Erreurs et diagnostic SQL | Troubleshooting |

### Etape 2 : Appliquer les regles critiques

Regles OBLIGATOIRES dans tout SQL genere :

**Ecriture SQL (fondamentaux) :**
1. **Commenter chaque bloc** — Expliquer le POURQUOI de chaque decision
2. **Qualifier les tables** — `SCHEMA.TABLE` (ex: `QSYS2.SYSTABLES`, `SQLFOR.EMPLOYE`)
3. **Nommer les colonnes** — Jamais `SELECT *` en production (sauf exploration)
4. **Utiliser des alias** — `AS` pour les colonnes calculees et les tables dans les JOIN
5. **DECIMAL pour les moyennes** — `DECIMAL(AVG(col), 7, 2)` pour eviter les troncatures
6. **Preferer JOIN a sous-requete** — Quand les deux sont possibles, JOIN est souvent plus performant
7. **Tester NULL explicitement** — `IS NULL` / `IS NOT NULL`, jamais `= NULL`
8. **ORDER BY explicite** — Ne jamais supposer un ordre de retour
9. **FETCH FIRST n ROWS ONLY** — Standard DB2 pour les top-N
10. **FOR READ ONLY** — Sur les SELECT de consultation pour permettre l'optimisation
11. **OPTIMIZE FOR n ROWS** — Quand on sait combien de lignes on attend
12. **CTE plutot que sous-requetes imbriquees** — Plus lisible et souvent plus performant
13. **Eviter LIKE '%valeur'** — Le % en debut empeche l'utilisation de l'index
14. **Eviter les derivations dans WHERE** — `SUBSTR(col, 1, 5) = x` empeche l'optimiseur. Creer un index derive si necessaire

**Environnement (Griere) :**
15. **Objectif d'optimisation correct** — `*ALLIO` (OPTIMIZE FOR ALL ROWS) pour batch, `*FIRSTIO` (OPTIMIZE FOR n ROWS) pour interactif
16. **CLOSQLCSR(*ENDJOB)** — Garder les ODP ouverts pour les invocations futures
17. **ALWCPYDTA(*OPTIMIZE)** — Permettre a l'optimiseur de creer des copies temporaires
18. **Verifier les statistiques** — `DSPSYSVAL QDBFSTCCOL` doit etre actif

**Modernisation (Hauser) :**
19. **Logique metier dans la base** — Vues, contraintes, triggers, procedures. Pas dans les programmes
20. **Vues SQL pour masquer la complexite** — Une vue complexe + un SELECT simple = reutilisable par tous les langages
21. **CREATE OR REPLACE** — Toujours utiliser pour faciliter le deploiement

### Etape 3 : Structurer la reponse

Pour chaque requete SQL fournie :

```
-- ============================================================
-- OBJECTIF : [Description claire de ce que fait la requete]
-- POURQUOI : [Justification des choix techniques]
-- PREREQUIS : [Tables, index, autorisations necessaires]
-- SOURCE   : [Redbook SG24-8326 / Birgitta Hauser / Christian Griere si applicable]
-- ============================================================

-- [Le code SQL commente ligne par ligne]
```

---

## SECTION 1 : Procedures stockees (Redbook SG24-8326 Ch.2/4/8)

### Structure d'une procedure SQL PSM

```sql
CREATE OR REPLACE PROCEDURE schema.nom_procedure (
    IN  p_param1  VARCHAR(50),         -- Parametre d'entree
    OUT p_result  INTEGER,             -- Parametre de sortie
    INOUT p_bidir VARCHAR(100)         -- Parametre bidirectionnel
)
LANGUAGE SQL
SPECIFIC nom_specifique                -- Nom unique pour identification
MODIFIES SQL DATA                     -- Peut INSERT/UPDATE/DELETE
COMMIT ON RETURN YES                  -- Commit automatique si succes
SET OPTION DBGVIEW = *SOURCE,          -- Permettre le debug
           DFTRDBCOL = MONSCHEMA       -- Schema par defaut
BEGIN
    -- Corps de la procedure
    DECLARE v_local VARCHAR(256);
    DECLARE v_sqlcode INTEGER DEFAULT 0;

    -- Handler pour gestion d'erreur
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        SET v_sqlcode = SQLCODE;

    -- Logique metier ici
    SET p_result = 0;
END;
```

### Gestion d'erreur avancee (Redbook 2.6)

```sql
-- HANDLER types:
-- CONTINUE  : continue apres l'erreur
-- EXIT      : sort du bloc BEGIN/END
-- UNDO      : rollback + sort (dans BEGIN ATOMIC)

DECLARE EXIT HANDLER FOR SQLSTATE '23505'  -- Doublon cle primaire
BEGIN
    SET p_erreur = 'Doublon detecte sur cle primaire';
    SIGNAL SQLSTATE '70001'
        SET MESSAGE_TEXT = 'Erreur applicative : doublon';
END;

-- GET DIAGNOSTICS pour details de l'erreur
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1
        v_sqlstate = RETURNED_SQLSTATE,
        v_sqlcode  = DB2_RETURNED_SQLCODE,
        v_message  = MESSAGE_TEXT;
END;
```

### Result sets (Redbook 4.7)

```sql
-- Procedure retournant un result set
CREATE OR REPLACE PROCEDURE schema.get_employes_dept (
    IN p_dept VARCHAR(3)
)
LANGUAGE SQL
RESULT SETS 1                           -- Nombre max de result sets
BEGIN
    DECLARE c1 CURSOR WITH RETURN FOR   -- WITH RETURN = result set
        SELECT empno, firstnme, lastname, salary
        FROM employee
        WHERE workdept = p_dept
        ORDER BY lastname
        FOR READ ONLY;

    OPEN c1;                            -- Ouvrir le curseur, le caller le fermera
END;
```

### Consommation des result sets dans une procedure appelante (Redbook 4.7.2)

```sql
CREATE OR REPLACE PROCEDURE schema.consommer_results ()
LANGUAGE SQL
BEGIN
    DECLARE v_empno CHAR(6);
    DECLARE v_nom   VARCHAR(15);
    DECLARE v_loc   RESULT_SET_LOCATOR VARYING;
    DECLARE v_fin   INTEGER DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fin = 1;

    -- Appeler la procedure qui retourne un result set
    CALL schema.get_employes_dept('A00');
    ASSOCIATE LOCATORS (v_loc) WITH PROCEDURE schema.get_employes_dept;
    ALLOCATE c_result CURSOR FOR RESULT SET v_loc;

    FETCH c_result INTO v_empno, v_nom;
    WHILE v_fin = 0 DO
        -- Traiter chaque ligne
        FETCH c_result INTO v_empno, v_nom;
    END WHILE;
    CLOSE c_result;
END;
```

### Procedures reutilisables avec variables globales (Redbook Ch.8)

```sql
-- Variables globales pour partager des donnees entre procedures
CREATE OR REPLACE VARIABLE gv_sql_string CLOB(2M);
CREATE OR REPLACE VARIABLE gv_row_change_timestamp TIMESTAMP;

-- Vue flexible avec variable globale (technique Redbook Ch.8)
CREATE OR REPLACE VIEW dept_change AS
    SELECT * FROM department
    WHERE when_changed = gv_row_change_timestamp;
-- Assigner la variable AVANT d'interroger la vue
```

### Transaction management (Redbook 3.4)

```sql
-- Niveaux d'isolation :
-- *NONE    (No Commit) - Pas de verrouillage
-- *CHG     (Uncommitted Read) - Lit les donnees non commitees
-- *CS      (Cursor Stability) - Verrouille la ligne courante
-- *ALL     (Read Stability) - Verrouille les lignes lues
-- *RR      (Repeatable Read) - Verrouillage maximal

-- SAVEPOINT pour rollback partiel
SAVEPOINT sp1 ON ROLLBACK RETAIN CURSORS;
INSERT INTO commandes VALUES (...);
-- Si erreur sur la deuxieme operation :
ROLLBACK TO SAVEPOINT sp1;
-- Sinon :
COMMIT;
```

---

## SECTION 2 : Fonctions UDF et UDTF (Redbook SG24-8326 Ch.6)

### Fonction scalaire simple

```sql
CREATE OR REPLACE FUNCTION schema.total_salary (
    salary     DECIMAL(9, 2),
    bonus      DECIMAL(9, 2),
    commission DECIMAL(9, 2)
)
RETURNS DECIMAL(9, 2)
LANGUAGE SQL
SPECIFIC totsal01
DETERMINISTIC                    -- Meme entree = meme sortie (permet cache)
CONTAINS SQL                     -- Ne lit/modifie pas de donnees
NOT FENCED                       -- Meme thread = meilleure performance
NO EXTERNAL ACTION               -- Pas d'effet de bord externe
RETURN COALESCE(salary, 0) + COALESCE(bonus, 0) + COALESCE(commission, 0);
```

### Proprietes critiques des UDF (Redbook 6.5)

| Propriete | Valeur recommandee | Impact |
|-----------|-------------------|--------|
| DETERMINISTIC | Oui si possible | Permet le cache des resultats par SQE |
| NOT FENCED | Oui si possible | Meme thread, meilleure performance |
| NO EXTERNAL ACTION | Oui si aucun effet externe | Permet optimisations |
| READS SQL DATA | Si SELECT uniquement | Empeche modification |
| MODIFIES SQL DATA | Si INSERT/UPDATE/DELETE | Necessaire pour audit trail |
| RETURNS NULL ON NULL INPUT | Si le null en entree = null en sortie | Evite l'appel inutile |

### UDF Inlining (Redbook 6.9) — Performance critique

Une UDF peut etre "inlinee" (integree directement dans la requete appelante) si :
- Elle contient UNIQUEMENT un RETURN (pas de SET, pas de SELECT INTO)
- Elle est DETERMINISTIC
- Elle ne specifie pas ATOMIC
- Verifier avec : `SELECT inline FROM QSYS2.SYSFUNCS WHERE routine_schema = 'MON_SCHEMA'`

```sql
-- INLINE-capable (BIEN) :
CREATE OR REPLACE FUNCTION schema.discount (totalSales DECIMAL(11,2))
RETURNS DECIMAL(11,2)
LANGUAGE SQL
DETERMINISTIC
NOT FENCED
RETURN (CASE WHEN totalSales > 2000 THEN totalSales * 0.95 ELSE totalSales END);

-- NON INLINE (utilise SET) :
-- Eviter cette forme quand l'inlining est souhaite
```

### UDTF — User-Defined Table Function (Redbook 6.10)

```sql
-- UDTF simple : employes par projet
CREATE OR REPLACE FUNCTION schema.emp_by_project (
    p_project VARCHAR(6)
)
RETURNS TABLE (
    empno     CHAR(6),
    firstname CHAR(20),
    lastname  CHAR(20),
    birthdate DATE
)
LANGUAGE SQL
SPECIFIC empbyprj
NOT FENCED
DETERMINISTIC
READS SQL DATA
RETURN
    SELECT e.empno, e.firstnme, e.lastname, e.birthdate
    FROM employee e
    WHERE e.empno IN (
        SELECT empno FROM empprojact WHERE projno = p_project
    );

-- Utilisation :
-- SELECT * FROM TABLE(schema.emp_by_project('OP1010')) AS x;
```

### UDTF avec OLAP (Redbook 6.10.4)

```sql
CREATE OR REPLACE FUNCTION schema.salary_rank()
RETURNS TABLE (
    position   INTEGER,
    empno      CHAR(6),
    firstname  CHAR(20),
    lastname   CHAR(20),
    salary     DECIMAL(13,2),
    rank       INTEGER,
    dense_rank INTEGER
)
SPECIFIC sal_rank
LANGUAGE SQL
READS SQL DATA
NOT FENCED
DETERMINISTIC
BEGIN
    RETURN
        SELECT
            ROW_NUMBER()  OVER(ORDER BY salary DESC) AS position,
            empno, firstnme, lastname, salary,
            RANK()        OVER(ORDER BY salary DESC) AS rank,
            DENSE_RANK()  OVER(ORDER BY salary DESC) AS dense_rank
        FROM employee
        ORDER BY salary DESC
        FETCH FIRST 10 ROWS ONLY;
END;
```

### Pipelined Table Function (Redbook 6.11)

Retourne les resultats ligne par ligne avec PIPE, sans table temporaire :

```sql
CREATE OR REPLACE FUNCTION schema.transform()
RETURNS TABLE (employee_name CHAR(20), unique_nbr INT)
LANGUAGE SQL
BEGIN
    DECLARE v_name VARCHAR(15);
    DECLARE v_num  INTEGER DEFAULT 1;
    DECLARE v_end  INTEGER DEFAULT 0;
    DECLARE c1 CURSOR FOR SELECT lastname FROM employee ORDER BY 1;
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET v_end = 1;

    OPEN c1;
    myloop: LOOP
        FETCH c1 INTO v_name;
        IF v_end = 1 THEN LEAVE myloop; END IF;
        PIPE (v_name, v_num);           -- Retourne UNE ligne a la fois
        SET v_num = v_num + 1;
    END LOOP;
    CLOSE c1;
    RETURN;                             -- Signal fin de donnees
END;
-- Utilisation : SELECT * FROM TABLE(schema.transform()) x;
```

**Avantages des pipelined functions :**
- Pas de table temporaire en memoire/disque
- Le consommateur recoit les lignes au fur et a mesure
- Ideal pour gros volumes, ETL, transformation de donnees
- Peut combiner donnees de sources multiples (API, fichiers IFS, autres systemes)

---

## SECTION 3 : Triggers SQL (Redbook SG24-8326 Ch.5)

### Structure d'un trigger

```sql
CREATE OR REPLACE TRIGGER schema.audit_salary
    AFTER UPDATE OF salary ON schema.employee    -- Quand ? Sur quoi ?
    REFERENCING NEW ROW AS new OLD ROW AS old    -- Acces aux valeurs avant/apres
    FOR EACH ROW MODE DB2ROW                     -- Par ligne (pas par instruction)
    WHEN (new.salary <> old.salary)              -- Condition optionnelle
BEGIN
    INSERT INTO schema.salary_audit (
        empno, old_salary, new_salary, changed_by, changed_at
    ) VALUES (
        new.empno, old.salary, new.salary, CURRENT USER, CURRENT TIMESTAMP
    );
END;
```

### Types de triggers

| Timing | Evenement | Usage typique |
|--------|-----------|---------------|
| BEFORE INSERT | Validation, valeurs par defaut calculees |
| BEFORE UPDATE | Validation, empechement de modifications interdites |
| AFTER INSERT | Audit trail, mise a jour de tables liees |
| AFTER UPDATE | Audit trail, notification, propagation |
| AFTER DELETE | Archivage, audit trail |
| INSTEAD OF | Sur vues : redirige vers la bonne table |

### Trigger self-referencing (Redbook 5.5.8)

```sql
-- Regle metier : le manager recoit 10% du bonus de l'employe
CREATE OR REPLACE TRIGGER schema.manager_comm
    AFTER UPDATE OF comm ON schema.employee
    REFERENCING NEW ROW AS new OLD ROW AS old
    FOR EACH ROW MODE DB2ROW
    WHEN (new.comm <> old.comm AND new.job <> 'MANAGER')
BEGIN
    DECLARE v_mgrcomm  DECIMAL(9,2);
    DECLARE v_mgrempno CHAR(6);

    IF new.comm > old.comm THEN
        SET v_mgrcomm = (new.comm - old.comm) / 10;
        SET v_mgrempno = (
            SELECT mgrno FROM dept
            WHERE deptno = (SELECT workdept FROM employee WHERE empno = new.empno)
        );
        IF v_mgrempno IS NOT NULL THEN
            UPDATE employee SET comm = comm + v_mgrcomm
            WHERE empno = v_mgrempno;
        END IF;
    END IF;
END;
```

### Trigger avec SIGNAL pour validation (Redbook 5.5.7)

```sql
CREATE OR REPLACE TRIGGER schema.check_salary_increase
    BEFORE UPDATE OF salary ON schema.employee
    REFERENCING NEW ROW AS new OLD ROW AS old
    FOR EACH ROW MODE DB2ROW
BEGIN
    -- Augmentation max 20%
    IF new.salary > old.salary * 1.20 THEN
        SIGNAL SQLSTATE '75001'
            SET MESSAGE_TEXT = 'Augmentation superieure a 20% interdite';
    END IF;
END;
```

### Catalogues triggers utiles

```sql
-- Voir tous les triggers d'un schema
SELECT trigger_name, event_manipulation, event_object_table,
       action_timing, action_orientation
FROM QSYS2.SYSTRIGGERS
WHERE trigger_schema = 'MONSCHEMA';

-- Voir les dependances d'un trigger
SELECT trigger_name, object_name, object_type
FROM QSYS2.SYSTRIGDEP
WHERE trigger_schema = 'MONSCHEMA';
```

---

## SECTION 4 : Indexation avancee (Christian Griere)

### Philosophie Griere : "Toutes les exploitations IBM i souffrent d'un manque d'index"

Causes historiques :
- L'AS/400 n'avait pas la puissance hardware pour supporter beaucoup de logiques
- Les developpeurs RPG faisaient le SELECT/OMIT avec du code, pas des index
- Reflexe de limiter les index encore present dans les equipes de developpement

**Aujourd'hui** : la puissance d'une partition IBM i est limitee par ses IOs, JAMAIS par sa capacite de traitement.

### Les trois types d'index sur IBM i

1. **Index binaires** — Les classiques (fichier logique / CREATE INDEX). Arbre B+.
2. **Index EVI (Encoded Vector Index)** — Specifiques IBM i, brevetes. Pour colonnes a faible cardinalite (statut, type, categorie). Se cumulent parfaitement en technique bitmap.
3. **Index texte** — OmniFind Text Search. Fonctions CONTAINS et SCORE.

### Strategie d'indexation (Griere)

**Ordre des cles dans un index :**
1. Predicats d'egalite (=) en premier — ils reduisent le plus vite le nombre de lignes
2. Predicats de selection + predicats de jointure
3. Colonnes les plus selectives en premier
4. Colonnes du ORDER BY en dernier (pour eviter un tri)

**Index parfait :**
Un index est "parfait" quand il couvre tous les predicats de selection ET de jointure de la requete.

```sql
-- Requete :
SELECT nom, prenom FROM client WHERE codsoc = 'SOC1' AND nodoc = '12345';

-- Index parfait :
CREATE INDEX idx_client_soc_doc ON client (codsoc, nodoc);
-- Les deux colonnes du WHERE dans l'ordre de selectivite
```

**Index Only Access (IOA) :**
L'index contient TOUTES les colonnes necessaires a la requete. Aucun acces a la table.

```sql
-- Pour la requete : SELECT nom FROM client WHERE codsoc = 'SOC1'
-- IOA = inclure 'nom' dans l'index :
CREATE INDEX idx_client_ioa ON client (codsoc) INCLUDE (nom);
-- ou avec les colonnes dans la cle :
CREATE INDEX idx_client_ioa2 ON client (codsoc, nom);
```

### MTI — Maintained Temporary Index (Griere)

Les MTI sont crees automatiquement par SQE quand l'optimiseur detecte un manque d'index.
- Memes caracteristiques qu'un index permanent
- **Faiblesse : disparaissent a l'IPL** — proscrire les IPL frequents !
- Preuve que l'indexation est insuffisante si beaucoup de MTI existent

```sql
-- Voir les MTI en cours
SELECT * FROM QSYS2.SYSIXADV
WHERE TIMES_ADVISED > 10                   -- Suggere plus de 10 fois
ORDER BY TIMES_ADVISED DESC;

-- Creer automatiquement les index recommandes (> 500 suggestions)
CALL SYSTOOLS.ACT_ON_INDEX_ADVICE('MON_SCHEMA', NULL, NULL, 500, NULL);

-- Analyser les index MTI existants pour les rendre permanents
SELECT MTI_CREATED, MTI_USED, MTI_KEY_COLUMNS_ADVISED,
       TABLE_SCHEMA, TABLE_NAME
FROM QSYS2.SYSIXADV
WHERE MTI_CREATED = 'YES'
ORDER BY MTI_USED DESC;
```

### Index EVI (Encoded Vector Index) — Griere

Quand les utiliser :
- Colonnes a **faible cardinalite** (statut, type, pays, categorie)
- Requetes avec **plusieurs predicats sur differentes colonnes** (star join)
- L'optimiseur peut combiner plusieurs EVI en technique bitmap

```sql
-- Creer un EVI
CREATE ENCODED VECTOR INDEX evi_client_statut
    ON client (statut);

CREATE ENCODED VECTOR INDEX evi_client_pays
    ON client (pays);

-- DB2 combinera les deux EVI pour :
-- SELECT * FROM client WHERE statut = 'A' AND pays = 'FR';
```

**Surveillance des EVI (Griere) :**
- Verifier regulierement la zone d'overflow des EVI a code 4 octets
- Un EVI peut etre recree automatiquement par DB2 si overflow plein (bloquant temporairement)

### Index derives et index epars (sparse)

```sql
-- Index derive (sur expression) — depuis IBM i 6.1
CREATE INDEX idx_year_sales ON orders (YEAR(order_date));
-- Utilise par : WHERE YEAR(order_date) = 2024

-- Index sparse (avec WHERE) — remplace SELECT/OMIT des logiques DDS
CREATE INDEX idx_active_clients ON client (nom)
    WHERE statut = 'A';
-- Maintenu uniquement pour les lignes actives — plus petit, plus rapide
```

### Trouver les index inutilises (Griere)

```sql
-- Les index qui n'ont JAMAIS ete utilises (2 compteurs a 0)
-- mais dont la table EST utilisee (au moins un index utilise)
SELECT DISTINCT
    a.TABLE_SCHEMA  AS "Schema",
    a.TABLE_NAME    AS "Table",
    a.INDEX_NAME    AS "Index",
    a.COLUMN_NAMES  AS "Cles",
    a.QUERY_STATISTICS_COUNT AS "Nb util. stats",
    a.QUERY_USE_COUNT        AS "Nb util. plan"
FROM QSYS2.SYSIXSTAT a
WHERE a.QUERY_STATISTICS_COUNT = 0
  AND a.QUERY_USE_COUNT = 0
  AND a.IS_UNIQUE = 'D'              -- Pas les index UNIQUE (contrainte)
  AND EXISTS (                        -- La table doit etre utilisee
      SELECT 1 FROM QSYS2.SYSIXSTAT b
      WHERE b.TABLE_SCHEMA = a.TABLE_SCHEMA
        AND b.TABLE_NAME = a.TABLE_NAME
        AND (b.QUERY_STATISTICS_COUNT > 0 OR b.QUERY_USE_COUNT > 0)
  )
ORDER BY a.TABLE_SCHEMA, a.TABLE_NAME;
```

### Visual Explain — Erreurs courantes (Griere)

**3 erreurs d'interpretation a eviter :**

1. **Comparer des temps avec des objectifs differents** — Un plan *FIRSTIO (OPTIMIZE FOR 30 ROWS) affiche 15ms, un plan *ALLIO affiche 1200ms. Le premier n'est PAS plus rapide : il montre le temps pour 30 lignes seulement.

2. **Test d'index vs Scannage d'index** — Le "Test d'index" (probe) est un acces direct dans l'arbre. Le "Scannage d'index" est une lecture sequentielle des postes. DB2 peut enchainer les deux.

3. **MTI jamais cree si un index est deja utilise** — Si la requete utilise deja un index (meme mauvais), DB2 ne creera PAS de MTI. Il faut analyser manuellement.

### QAQQINI — Parametres de performance (Griere)

```sql
-- Modifier temporairement un parametre d'optimisation
CALL QSYS2.OVERRIDE_QAQQINI(1, 'REOPTIMIZE_ACCESS_PLAN', '*YES');
-- Force la reoptimisation a chaque execution (utile pour les tests)

-- Interdire la creation de MTI (pour tests de performance stables)
CALL QSYS2.OVERRIDE_QAQQINI(1, 'ALLOW_TEMPORARY_INDEXES', '*NO');

-- Reinitialiser
CALL QSYS2.OVERRIDE_QAQQINI(1, '', '');
```

---

## SECTION 5 : Vues SQL et modernisation (Birgitta Hauser)

### Philosophie Hauser : "Plus on met de logique metier dans la base, moins on a a faire dans les programmes"

Les vues SQL sont l'outil #1 de modernisation :
- Masquent la complexite des jointures et calculs
- Reutilisables par TOUS les langages (RPG, PHP, Python, Node.js)
- Le moteur SQE optimise automatiquement (statistiques, index advisors)

```sql
-- Vue complexe cachant la logique metier
CREATE OR REPLACE VIEW schema.v_employe_complet AS
    SELECT
        e.empno,
        RTRIM(e.lastname) || ', ' || RTRIM(e.firstnme) AS nom_complet,
        e.salary,
        COALESCE(e.bonus, 0) + COALESCE(e.comm, 0)     AS primes_totales,
        e.salary + COALESCE(e.bonus, 0) + COALESCE(e.comm, 0) AS remuneration_totale,
        d.deptname,
        d.mgrno AS manager_empno
    FROM employee e
    INNER JOIN dept d ON e.workdept = d.deptno;

-- Utilisation simple par tous les langages :
-- SELECT * FROM schema.v_employe_complet WHERE deptname LIKE 'SOFT%';
```

### Generation JSON depuis SQL (Hauser — IBM i 7.3+)

```sql
-- JSON_OBJECT : genere un objet JSON par ligne
SELECT JSON_OBJECT(
    'empno'  : empno,
    'nom'    : RTRIM(lastname),
    'prenom' : RTRIM(firstnme),
    'salaire': salary
) AS json_employe
FROM employee
WHERE workdept = 'A00';

-- JSON_ARRAY : genere un tableau JSON
SELECT JSON_ARRAY(
    SELECT JSON_OBJECT(
        'empno' : empno,
        'nom'   : RTRIM(lastname)
    )
    FROM employee
    WHERE workdept = 'A00'
) AS json_array_dept;

-- Lecture JSON avec JSON_TABLE (IBM i 7.4+)
SELECT jt.*
FROM JSON_TABLE(
    '{"employes": [{"nom": "Dupont", "age": 35}, {"nom": "Martin", "age": 42}]}',
    '$.employes[*]'
    COLUMNS (
        nom VARCHAR(50) PATH '$.nom',
        age INTEGER     PATH '$.age'
    )
) AS jt;
```

### Ecriture IFS avec SQL (Hauser — GitHub)

```sql
-- Ecrire du JSON dans l'IFS
-- Methode 1 : via SYSTOOLS
CALL SYSTOOLS.IFS_WRITE_UTF8(
    PATH_NAME => '/home/myuser/export.json',
    LINE      => CAST('{"data": "valeur"}' AS CLOB(1M) CCSID 1208),
    OVERWRITE => 'REPLACE',
    END_OF_LINE => 'NONE'
);

-- Methode 2 : via QSYS2 (IBM i 7.4+)
SELECT * FROM TABLE(QSYS2.IFS_WRITE(
    PATH_NAME => '/home/myuser/data.csv',
    LINE      => 'NOM;PRENOM;SALAIRE',
    OVERWRITE => 'REPLACE'
));
```

### Generation XML depuis SQL (Hauser)

```sql
-- XML natif DB2
SELECT XMLELEMENT(
    NAME "employe",
    XMLELEMENT(NAME "nom", RTRIM(lastname)),
    XMLELEMENT(NAME "prenom", RTRIM(firstnme)),
    XMLELEMENT(NAME "salaire", salary)
) AS xml_employe
FROM employee
WHERE workdept = 'A00';

-- XMLAGG pour agreger en un seul document
SELECT XMLELEMENT(
    NAME "departement",
    XMLAGG(
        XMLELEMENT(NAME "employe",
            XMLELEMENT(NAME "nom", RTRIM(lastname)),
            XMLELEMENT(NAME "salaire", salary)
        )
    )
) AS xml_dept
FROM employee
WHERE workdept = 'A00';
```

### SQL Dynamic Compound Statement (Hauser)

Scripts SQL autonomes sans creer de procedure :

```sql
-- Modifier des profils utilisateurs via SQL dynamique
BEGIN
    DECLARE v_cmd VARCHAR(256);
    FOR v_user AS c1 CURSOR FOR
        SELECT authorization_name
        FROM QSYS2.USER_INFO
        WHERE authorization_name LIKE 'LAB%'
    DO
        SET v_cmd = 'CHGUSRPRF USRPRF(' || authorization_name || ') LMTDEVSSN(*YES)';
        CALL QCMDEXC(v_cmd);
    END FOR;
END;
```

### Deployer du SQL comme REST API (Hauser — IBM i 7.4)

Avec le HTTP Web Administration GUI, on peut deployer des SELECT, des procedures
et des fonctions comme des endpoints REST. DB2 for i agit comme fournisseur RESTful.

---

## SECTION 6 : Services SQL IBM i (QSYS2)

### Services essentiels

```sql
-- Jobs actifs
SELECT * FROM TABLE(QSYS2.ACTIVE_JOB_INFO()) x
WHERE JOB_TYPE = 'INT'
ORDER BY ELAPSED_CPU_PERCENTAGE DESC
FETCH FIRST 20 ROWS ONLY;

-- PTF installes
SELECT * FROM QSYS2.PTF_INFO
WHERE PTF_PRODUCT_ID = '5770SS1'
ORDER BY PTF_IDENTIFIER DESC;

-- Niveau Technology Refresh
SELECT * FROM QSYS2.GROUP_PTF_INFO
WHERE PTF_GROUP_DESCRIPTION LIKE '%Technology%';

-- Verifier la devise des PTF
SELECT ptf_group_currency, ptf_group_id, ptf_group_title,
       ptf_group_level_installed, ptf_group_level_available
FROM SYSTOOLS.GROUP_PTF_CURRENCY
WHERE ptf_group_currency <> 'INSTALLED LEVEL IS CURRENT';

-- Informations systeme
SELECT * FROM QSYS2.SYSTEM_STATUS_INFO;

-- Espaces disque
SELECT * FROM QSYS2.ASP_INFO;

-- Travaux par sous-systeme
SELECT * FROM TABLE(QSYS2.ACTIVE_JOB_INFO(SUBSYSTEM_LIST_FILTER => 'QINTER'));
```

### Health Center (Redbook 9.1)

```sql
-- Vue d'ensemble base de donnees
CALL QSYS2.HEALTH_DATABASE_OVERVIEW('MONSCHEMA');

-- Activite sur les objets
CALL QSYS2.HEALTH_ACTIVITY('MONSCHEMA');

-- Limites environnementales (top jobs)
CALL QSYS2.HEALTH_ENVIRONMENTAL_LIMITS();
```

### Plan cache (Redbook 9.3 / Griere)

```sql
-- Dumper les top 20 requetes les plus lentes
CALL QSYS2.DUMP_PLAN_CACHE_TOPN('SNAPSHOTS', 'TOP20', 20);

-- Extraire les requetes d'un utilisateur (Redbook 9.2)
CALL QSYS2.EXTRACT_STATEMENTS('SNAPSHOTS', 'MYDUMP',
    ADDITIONAL_SELECT_COLUMNS =>
        'DEC(QQI6)/1000000.0 AS Total_time_sec, QVC102 AS Current_User',
    ADDITIONAL_PREDICATES =>
        ' AND QQI6 > 1000000 AND QVC102 = ''MONUSER'' ',
    ORDER_BY => ' ORDER BY QQI6 DESC ');
```

### Lecture IFS

```sql
-- Lire un fichier CSV
SELECT *
FROM TABLE(QSYS2.IFS_READ_UTF8(
    PATH_NAME => '/home/myuser/data.csv'
)) AS t;

-- 10 plus gros fichiers dans /home
SELECT path_name, object_type,
       DECIMAL(data_size / 1048576.0, 10, 2) AS taille_mo,
       create_timestamp
FROM TABLE(QSYS2.IFS_OBJECT_STATISTICS(
    START_PATH_NAME    => '/home',
    SUBTREE_DIRECTORIES => 'YES',
    OBJECT_TYPE_LIST    => '*STMF'
)) AS t
ORDER BY data_size DESC
FETCH FIRST 10 ROWS ONLY
FOR READ ONLY
OPTIMIZE FOR 10 ROWS;
```

---

## SECTION 7 : Catalogues systeme essentiels

```sql
-- Tables d'un schema
SELECT table_name, table_type, row_count, data_size
FROM QSYS2.SYSTABLESTAT
WHERE table_schema = 'MONSCHEMA'
ORDER BY data_size DESC;

-- Colonnes d'une table
SELECT column_name, data_type, length, numeric_scale, is_nullable, column_default
FROM QSYS2.SYSCOLUMNS
WHERE table_schema = 'MONSCHEMA' AND table_name = 'MATABLE'
ORDER BY ordinal_position;

-- Procedures stockees
SELECT routine_name, specific_name, routine_type, sql_data_access
FROM QSYS2.SYSROUTINES
WHERE routine_schema = 'MONSCHEMA' AND routine_type = 'PROCEDURE';

-- Fonctions (UDF + UDTF) avec info INLINE
SELECT routine_name, specific_name, function_type, is_deterministic,
       fenced, inline, secure
FROM QSYS2.SYSFUNCS
WHERE routine_schema = 'MONSCHEMA';

-- Triggers
SELECT trigger_name, event_manipulation, event_object_table, action_timing
FROM QSYS2.SYSTRIGGERS
WHERE trigger_schema = 'MONSCHEMA';

-- Regenerer le DDL d'un objet
CALL QSYS2.GENERATE_SQL('NOM_OBJET', 'MONSCHEMA', 'TABLE', REPLACE_OPTION => '0');
```

---

## SECTION 8 : Troubleshooting et reference SQLCODE DB2 for i

### Comprendre les SQLCODE sur IBM i

Un SQLCODE est un code retour envoye par DB2 for i apres chaque instruction SQL :
- **SQLCODE = 0** : succes
- **SQLCODE > 0** : succes avec avertissement (warning)
- **SQLCODE < 0** : erreur, l'instruction a echoue
- **SQLCODE = 100** : aucune ligne trouvee (NOT FOUND)

Pour afficher le detail d'un SQLCODE sur IBM i :
```
DSPMSGD MSGID(SQL0204) MSGF(QSQLMSG)
```
La regle IBM : prendre la valeur absolue du SQLCODE et la prefixer par SQL (ou SQ si >= 10000).
Ex: SQLCODE -204 → message SQL0204, SQLCODE -30000 → message SQ30000.

### Reference complete des SQLCODE DB2 for i

#### Succes et avertissements (SQLCODE >= 0)

| SQLCODE | MsgID | Description | Contexte / Action |
|---------|-------|-------------|-------------------|
| 0 | — | Succes | L'instruction SQL s'est executee sans erreur |
| +100 | SQL0100 | Aucune ligne trouvee | FETCH sans resultat, UPDATE/DELETE sans correspondance, SELECT retourne table vide. En RPG : SQLCOD = 100 signifie fin des donnees |
| +304 | SQL0304 | Conversion avec troncature | Valeur tronquee lors de l'assignation a une variable hote |
| +466 | SQL0466 | Resultset non retourne | Procedure appelee par fonction/trigger — result sets ignores |
| +551 | SQL0551 | Pas d'autorite (warning) | Autorite sur objet non suffisante mais instruction continue |

#### Erreurs de syntaxe et structure SQL (SQLCODE -100 a -199)

| SQLCODE | MsgID | Description | Cause probable | Solution |
|---------|-------|-------------|----------------|----------|
| -84 | SQL0084 | Instruction non preparable | PREPARE/EXECUTE IMMEDIATE sur une instruction non preparable | Verifier la source SQL |
| -101 | SQL0101 | Instruction trop longue | Taille max depassee | Decomposer en instructions plus petites |
| -104 | SQL0104 | Jeton inattendu | Erreur de syntaxe, mot-cle mal place, virgule manquante | Verifier la syntaxe exacte, rechercher le jeton indique dans le message |
| -105 | SQL0105 | Chaine invalide | Format de chaine incorrect (apostrophes, guillemets) | Verifier le format des litteraux |
| -111 | SQL0111 | Fonction colonne invalide | SUM, AVG, MAX etc. sans nom de colonne | Ajouter un nom de colonne dans l'operande |
| -112 | SQL0112 | Operande d'agreg. invalide | Expression non valide pour fonction d'agregation | Verifier le type de donnees de l'expression |
| -117 | SQL0117 | Nb colonnes <> nb valeurs | INSERT — nb colonnes != nb valeurs | Aligner la clause VALUES sur les colonnes |
| -119 | SQL0119 | HAVING sans GROUP BY | Colonne du HAVING absente du GROUP BY | Ajouter la colonne au GROUP BY |
| -121 | SQL0121 | Colonne en double | Meme colonne dans INSERT ou UPDATE deux fois | Retirer le doublon |
| -130 | SQL0130 | Predicat ESCAPE invalide | ESCAPE doit etre un seul caractere | Verifier la clause ESCAPE du LIKE |
| -131 | SQL0131 | LIKE incompatible | LIKE sur colonne non caractere ou pattern incorrect | Verifier les types de donnees |
| -138 | SQL0138 | Argument SUBSTR invalide | Position ou longueur negative/zero | Verifier les parametres de SUBSTR |
| -150 | SQL0150 | Procedure/vue/trigger en erreur | Le corps SQL contient une erreur de syntaxe | Corriger la syntaxe dans le corps du CREATE |
| -171 | SQL0171 | Type de donnees invalide | Type utilise n'existe pas ou n'est pas supporte | Utiliser un type DB2 for i valide |
| -172 | SQL0172 | Nom de fonction invalide | Fonction non trouvee ou nb arguments incorrect | Verifier le nom et le SET PATH |
| -180 | SQL0180 | Syntaxe datetime invalide | Format date/heure incorrect (ex: 2024-13-45) | Verifier le format de la date/heure |
| -181 | SQL0181 | Valeur datetime hors plage | Mois > 12, jour > 31, heure > 24 | Corriger les valeurs |
| -182 | SQL0182 | Expression datetime invalide | Arithmetique date invalide (ex: date + chaine) | Utiliser TIMESTAMPDIFF, +N DAYS, etc. |
| -183 | SQL0183 | Date/heure invalide | La valeur n'est pas une date ou heure valide | Verifier la donnee source |
| -187 | SQL0187 | Utilisation datetime invalide | Contexte non autorise pour date/heure | Revoir l'expression |
| -188 | SQL0188 | Clause SET non valide | Expression SET incorrecte dans ALTER ou UPDATE | Verifier la syntaxe |
| -190 | SQL0190 | Colonne non modifiable | La colonne est generee ou identity | Ne pas essayer de modifier une colonne GENERATED |
| -199 | SQL0199 | Mot-cle invalide | Mot-cle non reconnu ou reserve utilise comme identifiant | Mettre l'identifiant entre guillemets |

#### Erreurs d'objet et de reference (SQLCODE -200 a -299)

| SQLCODE | MsgID | Description | Cause probable | Solution |
|---------|-------|-------------|----------------|----------|
| -203 | SQL0203 | Reference ambigue | Colonne presente dans plusieurs tables du JOIN | Qualifier avec schema.table.colonne ou alias |
| -204 | SQL0204 | Objet non trouve | Table, vue, procedure, schema inexistant ou pas dans la library list | Verifier CURRENT SCHEMA, library list, orthographe |
| -205 | SQL0205 | Colonne absente du GROUP BY | Colonne du SELECT absente du GROUP BY | Ajouter au GROUP BY ou utiliser un agregat |
| -206 | SQL0206 | Colonne non trouvee | Nom de colonne inexistant dans la table | Verifier les noms, alias dans les JOIN, clause FROM |
| -208 | SQL0208 | ORDER BY invalide | Colonne ORDER BY absente du SELECT DISTINCT | Ajouter la colonne au SELECT ou retirer ORDER BY |
| -219 | SQL0219 | Table requise non trouvee | Table reference par contrainte/trigger absente | Creer la table ou corriger le nom |
| -220 | SQL0220 | Clause UNION incompatible | Les SELECT du UNION ont des colonnes incompatibles | Aligner les types et le nombre de colonnes |
| -243 | SQL0243 | Sensibilite du curseur | Curseur SENSITIVE ne peut etre supporte | Utiliser INSENSITIVE ou retirer la clause |
| -270 | SQL0270 | Fonction non supportee | Fonctionnalite non disponible dans ce contexte/niveau OS | Verifier le niveau IBM i et PTF |

#### Erreurs de variables et donnees (SQLCODE -300 a -399)

| SQLCODE | MsgID | Description | Cause probable | Solution |
|---------|-------|-------------|----------------|----------|
| -301 | SQL0301 | Type incompatible | Variable hote et colonne de types differents | Aligner les types (ex: DECIMAL vers DECIMAL) |
| -302 | SQL0302 | Longueur/type incompatible | Variable hote trop petite ou type incorrect | Verifier longueur/precision de la variable hote |
| -303 | SQL0303 | Variable non attribuable | Assignation impossible entre les types | Verifier les conversions implicites |
| -304 | SQL0304 | Valeur hors plage | Debordement a l'assignation (ex: 99999 dans DEC(3,0)) | Augmenter la taille de la variable hote |
| -305 | SQL0305 | Indicateur NULL manquant | SELECT/FETCH retourne NULL mais pas d'indicateur null | Ajouter un indicateur null a la variable hote |
| -312 | SQL0312 | Variable hote non declaree | Variable utilisee mais non declaree dans le programme | Verifier DECLARE / DCL dans le source RPG |
| -313 | SQL0313 | Nb variables <> nb parametres | OPEN/EXECUTE : nb de ? ne correspond pas aux variables | Aligner le nombre de variables au nombre de marqueurs |
| -332 | SQL0332 | Conversion CCSID impossible | Conflit d'encodage entre source et cible | Verifier CCSID des colonnes et du job |
| -338 | SQL0338 | Clause ON invalide | Predicat de jointure non valide | Corriger la clause ON du JOIN |

#### Erreurs d'objet SQL (SQLCODE -400 a -499)

| SQLCODE | MsgID | Description | Cause probable | Solution |
|---------|-------|-------------|----------------|----------|
| -400 | SQL0400 | Routine appelee en erreur | Erreur dans le corps d'un programme/procedure externe | Verifier le programme externe appele |
| -407 | SQL0407 | NULL non autorise | INSERT/UPDATE d'un NULL sur colonne NOT NULL | Renseigner une valeur ou autoriser les NULL |
| -412 | SQL0412 | Clause SELECT variable | SELECT dans sous-requete contient des colonnes variables | Fixer les colonnes du SELECT |
| -413 | SQL0413 | Debordement arithmetique | Resultat de calcul trop grand pour le type | Augmenter la precision ou utiliser DECIMAL plus large |
| -420 | SQL0420 | Conversion caractere impossible | Chaine non convertible en nombre (ex: 'ABC' vers INT) | Verifier les donnees ou utiliser CAST explicite |
| -421 | SQL0421 | Operandes incompatibles | Types differents dans UNION, CASE, VALUES | Harmoniser les types avec CAST |
| -423 | SQL0423 | Locator invalide | Locator LOB/CLOB non valide ou expire | Verifier le locator et sa portee |
| -426 | SQL0426 | Commit dynamique invalide | COMMIT/ROLLBACK dans un contexte non autorise | Retirer le COMMIT du trigger/fonction |
| -427 | SQL0427 | INSERT/UPDATE dans trigger | Trigger BEFORE essaie de modifier d'autres tables | Utiliser un trigger AFTER pour les modifications |
| -430 | SQL0430 | Routine externe en erreur | Programme externe a retourne une erreur | Verifier le programme/service program externe |
| -438 | SQL0438 | Erreur applicative SIGNAL | SIGNAL SQLSTATE ou RAISE_ERROR dans procedure/trigger/fonction | Lire le MESSAGE_TEXT — c'est une erreur applicative volontaire |
| -440 | SQL0440 | Routine non trouvee | Procedure/fonction appelee non trouvee | Verifier le nom, le schema, et SET PATH |
| -443 | SQL0443 | Erreur dans UDF externe | Fonction SQL externe a retourne une erreur | Verifier le programme externe et les parametres |
| -444 | SQL0444 | Programme externe non trouve | Programme externe reference dans la routine introuvable | Verifier l'external name et la library |
| -462 | SQL0462 | Warning dans routine | Procedure/fonction a retourne un SQLSTATE warning | Voir le MESSAGE_TEXT pour details |

#### Erreurs de curseur (SQLCODE -500 a -599)

| SQLCODE | MsgID | Description | Cause probable | Solution |
|---------|-------|-------------|----------------|----------|
| -501 | SQL0501 | Curseur non ouvert | FETCH/CLOSE sur un curseur pas encore ouvert | Verifier l'ordre : DECLARE → OPEN → FETCH → CLOSE |
| -502 | SQL0502 | Curseur deja ouvert | OPEN sur un curseur deja ouvert | Ajouter un CLOSE avant le OPEN ou verifier la logique |
| -503 | SQL0503 | Colonne non dans FOR UPDATE | UPDATE WHERE CURRENT OF sur colonne non listee | Ajouter la colonne dans FOR UPDATE OF |
| -504 | SQL0504 | Curseur non declare | Utilisation d'un curseur non declare | Ajouter DECLARE CURSOR |
| -507 | SQL0507 | Curseur non ouvert pour UPDATE | UPDATE/DELETE CURRENT OF sur curseur ferme | Ouvrir le curseur avant de faire l'operation |
| -508 | SQL0508 | Curseur non updatable | UPDATE WHERE CURRENT OF sur un curseur FOR READ ONLY | Retirer FOR READ ONLY ou utiliser un UPDATE standard |
| -509 | SQL0509 | Table curseur <> table update | Table du UPDATE != table du curseur | Aligner les tables |
| -510 | SQL0510 | Table non modifiable | La table/vue ne supporte pas INSERT/UPDATE/DELETE | Verifier les droits et la definition de la vue |
| -518 | SQL0518 | EXECUTE sans PREPARE | EXECUTE d'un statement non prepare | Ajouter un PREPARE avant |
| -530 | SQL0530 | FK violation INSERT/UPDATE | Valeur FK non trouvee dans la table parent | Verifier la valeur FK dans la table parent |
| -531 | SQL0531 | FK violation UPDATE parent | UPDATE PK avec des enfants dependants | Verifier les contraintes referentielles |
| -532 | SQL0532 | FK violation DELETE | DELETE d'un parent avec des enfants | Ajouter ON DELETE CASCADE ou supprimer les enfants d'abord |
| -539 | SQL0539 | FK sans PK parent | FK reference une table sans cle primaire | Ajouter une PK a la table parent |
| -540 | SQL0540 | Index/PK manquant | PK non definie avant reference | Creer la PK/index unique avant la FK |
| -542 | SQL0542 | PK avec colonnes NULL | Colonne nullable dans la cle primaire | Definir la colonne NOT NULL |
| -543 | SQL0543 | DELETE regle referentielle | DELETE viole une regle de contrainte | Verifier ON DELETE RESTRICT/NO ACTION |
| -544 | SQL0544 | INSERT/UPDATE CHECK violee | Contrainte CHECK violee | Verifier la condition de la contrainte |
| -545 | SQL0545 | CHECK constraint violee | INSERT/UPDATE viole une CHECK constraint | Verifier la valeur inseree/modifiee |
| -551 | SQL0551 | Pas d'autorite | Pas le droit sur l'objet (SELECT, INSERT, EXECUTE, etc.) | GRANT les droits necessaires a l'utilisateur |
| -552 | SQL0552 | Pas d'autorite pour action | Pas les droits admin (CREATE, DROP, GRANT) | Verifier les autorites speciales |
| -557 | SQL0557 | Fonctionnalite non autorisee | Fonctionnalite restreinte pour cet utilisateur | Contacter l'administrateur |
| -577 | SQL0577 | Trigger non autorise | Trigger modifier des donnees non autorise | Verifier les autorites du trigger |
| -580 | SQL0580 | Resultat CASE incompatible | Types incompatibles dans les clauses WHEN/THEN | Harmoniser les types avec CAST |
| -581 | SQL0581 | Datatypes CASE incompatibles | CASE/DECODE avec types resultat incompatibles | Ajouter des CAST explicites |
| -582 | SQL0582 | Expressions CASE invalides | CASE WHEN avec predicats non valides | Verifier la syntaxe de chaque WHEN |
| -583 | SQL0583 | Variables hotes dupliquees | Meme variable utilisee dans IN et OUT | Utiliser des variables differentes |
| -585 | SQL0585 | Schema vide | Le schema specifie est vide ou n'existe pas | Creer le schema ou verifier le nom |

#### Erreurs d'index et DDL (SQLCODE -600 a -699)

| SQLCODE | MsgID | Description | Cause probable | Solution |
|---------|-------|-------------|----------------|----------|
| -601 | SQL0601 | Objet existant | Table, index ou vue existe deja | Utiliser CREATE OR REPLACE ou verifier le nom |
| -602 | SQL0602 | Trop de colonnes dans INDEX | Index depasse le max de colonnes | Reduire le nombre de cles |
| -603 | SQL0603 | Index UNIQUE impossible | Doublons existants dans les colonnes | Supprimer les doublons ou renoncer a UNIQUE |
| -604 | SQL0604 | Type de donnees invalide | Definition de colonne avec attributs invalides | Verifier les parametres du type (longueur, precision) |
| -612 | SQL0612 | Colonne en double dans DDL | Meme nom de colonne deux fois dans CREATE TABLE | Renommer les colonnes en double |
| -613 | SQL0613 | PK trop grande | Cle primaire depasse la taille maximum | Reduire le nombre/taille des colonnes PK |
| -624 | SQL0624 | PK deja definie | Table a deja une cle primaire | Ne creer qu'une seule PK par table |
| -625 | SQL0625 | View WITH CHECK violation | INSERT/UPDATE viole la condition de la vue WITH CHECK | Verifier les donnees par rapport a la condition de la vue |
| -630 | SQL0630 | FK a cle non unique | FK reference une colonne non unique | S'assurer que la cible a un index unique/PK |
| -631 | SQL0631 | FK colonnes incompatibles | Types FK et PK parent ne correspondent pas | Aligner les types entre FK et PK |
| -638 | SQL0638 | Table sans colonnes | CREATE TABLE sans definition de colonnes | Ajouter au moins une colonne |
| -668 | SQL0668 | Operation non permise sur table | Table en etat restreint (check pending, etc.) | CHGPF ou SET INTEGRITY pour retablir l'etat |
| -672 | SQL0672 | DROP colonne impossible | Colonne non supprimable (PK, contrainte) | Supprimer d'abord les contraintes dependantes |
| -680 | SQL0680 | Trop de colonnes dans TABLE | Table depasse 750 colonnes | Reduire le nombre de colonnes |
| -687 | SQL0687 | Types incompatibles | Comparaison entre types incompatibles | Ajouter un CAST explicite |

#### Erreurs de trigger et routine (SQLCODE -700 a -799)

| SQLCODE | MsgID | Description | Cause probable | Solution |
|---------|-------|-------------|----------------|----------|
| -723 | SQL0723 | Trigger en erreur | Le trigger a provoque une erreur SQL | Lire le SQLCODE dans le message (erreur imbriquee) |
| -724 | SQL0724 | Trigger recursif detecte | Cascade de triggers > profondeur max (200) | Revoir la logique des triggers, eviter les cascades |
| -727 | SQL0727 | Erreur implicite | Erreur dans objet dependant (trigger, vue, procedure) | Verifier l'objet reference dans le message |
| -746 | SQL0746 | Routine imbriquee trop profond | Appels de routines > profondeur max | Reduire la profondeur d'appel |
| -751 | SQL0751 | Instruction non permise | COMMIT/ROLLBACK/CONNECT dans trigger ou UDF | Retirer l'instruction non autorisee |
| -770 | SQL0770 | LOB en erreur | Operation sur LOB invalide | Verifier les operations LOB et les tailles |
| -798 | SQL0798 | INSERT nb colonnes | Nb de valeurs != nb de colonnes cibles | Corriger la clause VALUES |

#### Erreurs de donnees et integrite (SQLCODE -800 a -899)

| SQLCODE | MsgID | Description | Cause probable | Solution |
|---------|-------|-------------|----------------|----------|
| -803 | SQL0803 | Doublon cle primaire/unique | INSERT/UPDATE viole contrainte PK ou UNIQUE | Verifier les doublons avant INSERT ou utiliser MERGE |
| -805 | SQL0805 | Programme plan non trouve | Package ou programme non lie au plan (plus RPG/COBOL) | Rebinder le programme — CRTSQLRPGI |
| -811 | SQL0811 | SELECT retourne multi-lignes | Sous-requete scalaire ou SELECT INTO retourne > 1 ligne | Utiliser IN, FETCH FIRST 1, ou un curseur |
| -818 | SQL0818 | Timestamp mismatch | DBRM et LOAD MODULE ont des timestamps differents | Recompiler et rebinder le programme |
| -840 | SQL0840 | Nombre trop grand | Nombre a trop de chiffres pour la colonne | Augmenter la precision ou verifier les donnees |
| -845 | SQL0845 | Code datetime incompatible | Expression datetime incompatible avec la cible | Verifier le format et le type |

#### Erreurs systeme, autorisations et deadlock (SQLCODE -900 a -999)

| SQLCODE | MsgID | Description | Cause probable | Solution |
|---------|-------|-------------|----------------|----------|
| -901 | SQL0901 | Erreur systeme SQL | Erreur interne DB2 for i | Verifier le job log, PTF manquants. Peut impliquer un defaut systeme |
| -904 | SQL0904 | Ressource non disponible | Table, tablespace ou index non disponible | Verifier l'etat de l'objet (WRKOBJLCK, DSPFD) |
| -905 | SQL0905 | Limite ressource atteinte | Requete depasse le temps/ressources max autorisees | Optimiser la requete, indexer, verifier QAQQINI |
| -906 | SQL0906 | SQL non autorise en ce moment | Instruction non autorisee dans le contexte actuel | Verifier le niveau de COMMIT et l'environnement |
| -910 | SQL0910 | Objet en cours modification | Table en cours de reconstruction/reorg | Attendre la fin de l'operation |
| -911 | SQL0911 | Deadlock avec timeout | Conflit de verrouillage, DB2 a choisi un victim | Reessayer la transaction, commiter plus souvent |
| -912 | SQL0912 | Deadlock avec attente max | Attente verrou depasse le seuil | Commiter plus frequemment, reduire les contentions |
| -913 | SQL0913 | Deadlock avec rollback | Conflit de verrou, rollback automatique | Adapter la frequence des COMMIT, revoir les acces |
| -922 | SQL0922 | Echec autorisation connexion | Profil non autorise ou plan non lie | Verifier les droits utilisateur |
| -923 | SQL0923 | Echec connexion | Connexion DB echouee | Verifier le reseau et la configuration de connexion |
| -924 | SQL0924 | Erreur interne connexion | Erreur interne DB2 sur la connexion | Contacter l'equipe systeme |
| -950 | SQL0950 | Version non supportee | Instruction non supportee sur cette version IBM i | Verifier le niveau OS et Technology Refresh |
| -952 | SQL0952 | Traitement interrompu | Requete annulee (timeout, force end, ENDJOB) | Verifier pourquoi le job a ete interrompu |

#### Erreurs specifiques IBM i (SQLCODE -7000 et plus)

| SQLCODE | MsgID | Description | Cause probable | Solution |
|---------|-------|-------------|----------------|----------|
| -7001 | SQL7001 | Type de fichier non valide | Fichier logique (LF) utilise la ou un PF est requis | Specifier le fichier physique |
| -7002 | SQL7002 | Nb de colonnes depasse | Trop de colonnes pour l'operation | Reduire le SELECT ou l'operation |
| -7006 | SQL7006 | Conversion host variable | Conversion impossible de la variable hote | Verifier le type dans le programme RPG |
| -7007 | SQL7007 | Objet non journalise | Table sans journal et COMMIT(*CHG ou plus) | STRJRNPF pour journaliser, ou mettre COMMIT(*NONE) |
| -7008 | SQL7008 | Journal requis pour l'operation | INSERT/UPDATE/DELETE sur table non journalisee | STRJRNPF ou creer la table dans un schema SQL (auto-journalise) |
| -7010 | SQL7010 | Fichier en lecture seule | Tentative de modification sur un fichier en lecture | Verifier les droits et l'etat du fichier |
| -7011 | SQL7011 | Fichier systeme protege | Operation non permise sur un objet systeme | Ne pas modifier les fichiers QSYS/QSYS2 directement |
| -7012 | SQL7012 | Curseur non SCROLL | FETCH PRIOR/FIRST sur curseur non SCROLL | Declarer le curseur SCROLL |
| -7024 | SQL7024 | Membre non trouve | Membre de fichier specifie non trouve | Verifier le nom du membre |
| -7025 | SQL7025 | Format enregistrement | Incompatibilite format d'enregistrement | Recompiler le programme utilisant le fichier |
| -7030 | SQL7030 | Fichier en cours d'utilisation | Fichier verrouille par un autre job | WRKOBJLCK pour identifier le job bloquant |
| -7040 | SQL7040 | Membre verrouille | Membre de fichier en cours d'utilisation exclusive | Attendre ou liberer le verrou |
| -7047 | SQL7047 | DRDA operation echouee | Operation distribuee non supportee | Verifier la configuration DRDA |
| -7053 | SQL7053 | Nb max membres | Nombre max de membres atteint pour le fichier | Archiver et supprimer des membres anciens |

#### Erreurs distribuees DRDA (SQLCODE -30000 et plus)

| SQLCODE | MsgID | Description | Cause probable | Solution |
|---------|-------|-------------|----------------|----------|
| -30000 | SQ30000 | Erreur protocole DRDA | Erreur de communication distribuee | Verifier la configuration DRDA et reseau |
| -30040 | SQ30040 | Incompatibilite DRDA | Version du protocole non supportee | Mettre a jour le driver ou le serveur |
| -30050 | SQ30050 | Commande DRDA non supportee | Instruction non supportee sur le serveur distant | Verifier la compatibilite des features |
| -30053 | SQ30053 | Package non lie | Le package n'existe pas sur le serveur distant | Executer le BIND necessaire |
| -30060 | SQ30060 | Autorisation refusee | Pas d'autorite sur le serveur distant | Verifier les droits sur la BD distante |
| -30070 | SQ30070 | Commande non supportee | Commande distribuee non supportee par le serveur | Simplifier la requete ou la faire localement |
| -30080 | SQ30080 | Erreur de communication | Perte de connexion reseau | Verifier le reseau et reconnecter |
| -30082 | SQ30082 | Echec authentification | Mot de passe ou profil invalide sur le serveur distant | Verifier les credentials |

### Astuce : Recuperer le SQLCODE dans un programme RPG

```sql
-- Dans un handler de procedure stockee :
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1
        v_sqlcode  = DB2_RETURNED_SQLCODE,
        v_sqlstate = RETURNED_SQLSTATE,
        v_message  = MESSAGE_TEXT;
    -- Traiter ou logger l'erreur
END;
```

```
// En RPG ILE avec SQL embarque :
EXEC SQL SELECT empno INTO :wEmpno FROM employee WHERE empno = :wSearch;
IF SQLCOD = 100;
    // Pas de ligne trouvee
ELSEIF SQLCOD < 0;
    // Erreur — logger SQLCOD
ENDIF;
```

### Schema et naming convention (Redbook 3.1)

- **SQL naming** (`.`) : defaut = schema du user (`SET SCHEMA monschema;`)
- **System naming** (`/`) : defaut = library list (`*LIBL`)
- Pour les procedures/triggers, utiliser `SET OPTION DFTRDBCOL = MONSCHEMA`
- `SET PATH` controle la resolution des UDF : `SET PATH = MYUDFS, SYSTEM PATH`

### Verifications rapides

```sql
-- Schema courant
VALUES CURRENT SCHEMA;

-- Path courant (resolution UDF)
VALUES CURRENT PATH;

-- User courant
VALUES CURRENT USER;

-- Version IBM i
SELECT * FROM SYSIBMADM.ENV_SYS_INFO;
```

---

## Prerequis IBM i

- IBM i 7.3 ou superieur (7.2 pour procedures/triggers/fonctions basiques)
- IBM i 7.4+ recommande pour JSON_TABLE, LISTAGG, IFS_WRITE, REST APIs
- `ADDLIBLE LIB(SYSTOOLS)` pour certaines fonctions utilitaires
- Verifier les PTF (Technology Refresh) pour les services QSYS2 les plus recents
- Pour debug : option DBGVIEW = *SOURCE dans SET OPTION

## Checklist qualite

Avant de fournir du SQL, verifier :

- [ ] Tables qualifiees avec schema
- [ ] Colonnes nommees explicitement (pas de SELECT * en production)
- [ ] Alias sur les colonnes calculees
- [ ] JOIN prefere aux sous-requetes quand possible
- [ ] NULL gere correctement (IS NULL, pas = NULL)
- [ ] DECIMAL() sur les fonctions d'agregation numeriques
- [ ] Commentaires expliquant le POURQUOI
- [ ] FOR READ ONLY sur les consultations
- [ ] Index recommandes mentionnes si pertinent
- [ ] Pas de LIKE '%...' sauf si necessaire (expliquer l'impact)
- [ ] Proprietes UDF optimales (DETERMINISTIC, NOT FENCED, INLINE si possible)
- [ ] Trigger avec gestion d'erreur (HANDLER ou SIGNAL)
- [ ] Objectif d'optimisation adapte (*FIRSTIO vs *ALLIO)
- [ ] Pas de derivation dans les predicats (ou index derive cree)

## Sources et references

- IBM Redbook SG24-8326 "SQL Procedures, Triggers, and Functions on IBM DB2 for i" (2016)
- Birgitta Hauser — IBM Champion, consultante independante, co-auteur Redbooks IBM
  - GitHub : github.com/BirgittaHauser (Write-to-IFS-with-SQL, Generate-XML-and-JSON)
  - Conferences COMMON, articles IT Jungle, IBM DeveloperWorks
- Christian Griere — Expert IBM France, specialiste performance DB2 for i
  - Articles LinkedIn : sous-indexation, sur-indexation, EVI, LPG, Visual Explain, plan cache
  - Presentation COMMON Romandie "Les bases de l'optimisation SQL"
- IBM Knowledge Center — DB2 for i SQL Reference
- IBM Indexing and Statistics Strategies whitepaper
- Scott Forstie — DB2 for i Business Architect, IBM i Services
