PostgreSQL
==========

Všechny [procedurální jazyky](http://www.postgresql.org/docs/current/static/xplang.html) PostgreSQL, které umožňují psát funkce a procedury uvnitř databáze, umožňují provádění libovolných SQL příkazů.

PL/pgSQL
--------

Nejbezpečnějším způsobem, jak provádět SQL uvnitř příkazu PL/pgSQL, je jednoduše takhle:

    CREATE OR REPLACE FUNCTION user_access (p_uname TEXT)
      RETURNS timestamp LANGUAGE plpgsql AS
    $func$
    BEGIN
        RETURN accessed_at FROM users WHERE username = p_uname;
    END
    $func$;

V takovém jednoduchém příkladu na tom vlastně budete líp s čistě SQL funkcí:

    CREATE OR REPLACE FUNCTION user_access (p_uname TEXT)
      RETURNS timestamp LANGUAGE sql AS
    $func$
        SELECT accessed_at FROM users WHERE username = $1
    $func$;

Někdy ale potřebujete dělat složitější věci. Třeba dynamicky přidáváte `WHERE` klauzule podle vstupu. V takovém případě skončíte u PL/pgSQL příkazu [`EXECUTE`](http://www.postgresql.org/docs/current/interactive/plpgsql-statements.html#PLPGSQL-STATEMENTS-EXECUTING-DYN). Tady je příklad, který je zranitelný SQL injection:

    CREATE OR REPLACE FUNCTION get_users(p_column TEXT, p_value TEXT)
      RETURNS SETOF users LANGUAGE plpgsql AS
    $func$
    DECLARE
        query TEXT := 'SELECT * FROM users';
    BEGIN
        IF p_column IS NOT NULL THEN
            query := query || ' WHERE ' || p_column
                  || $_$ = '$_$ || p_value || $_$'$_$;
        END IF;
        RETURN QUERY EXECUTE query;
    END
    $func$;

Oba parametry `p_column` i `p_value` jsou zranitelné. Jedním způsobem, jak se tomuto problému vyhnout, je použít funkci `quote_ident()` k uvození SQL identifikátorů (v tomto případě `p_column`) a `quote_literal()` k uvození literálů:

    CREATE OR REPLACE FUNCTION get_users(p_column TEXT, p_value TEXT)
      RETURNS SETOF users LANGUAGE plpgsql AS
    $func$
    DECLARE
        query TEXT := 'SELECT * FROM users';
    BEGIN
        IF p_column IS NOT NULL THEN
            query := query || ' WHERE ' || quote_ident(p_column)
                  || ' = ' || quote_literal(p_value);
        END IF;
        RETURN QUERY EXECUTE query;
    END;
    $func$;

Také se to o něco snadněji čte!
Ještě lepší je u hodnot využívat klauzuli `USING` v příkazu [`EXECUTE`](http://www.postgresql.org/docs/current/interactive/plpgsql-statements.html#PLPGSQL-STATEMENTS-EXECUTING-DYN) (dostupná od v8.4):

    CREATE OR REPLACE FUNCTION get_users(p_column TEXT, p_value TEXT)
      RETURNS SETOF users LANGUAGE plpgsql AS
    $func$
    DECLARE
        query TEXT := 'SELECT * FROM users';
    BEGIN
        IF p_column IS NOT NULL THEN
            query := query || ' WHERE ' || quote_ident(p_column) || ' = $1';
        END IF;
        RETURN QUERY EXECUTE query
        USING p_value;
    END;
    $func$;

V této podobě kromě ochrany proti SQLi získáte i lepší výkon bez režie převádění hodnot na text a zpět.


PL/Perl
-------

Chybí

PL/Python
---------

Chybí

### PL/Tcl

Chybí
