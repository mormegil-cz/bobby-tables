PL/SQL
======

V příkladech předpokládáme následující tabulkovou strukturu:

    CREATE TABLE users (
        username VARCHAR2(8) UNIQUE,
        accessed_at DATE,
        superuser NUMBER(1,0)
    );

    INSERT INTO users VALUES ('janihur',  sysdate,      0);
    INSERT INTO users VALUES ('petdance', sysdate - 12, 1);
    INSERT INTO users VALUES ('albundy',  sysdate - 3,  0);
    INSERT INTO users VALUES ('donduck',  sysdate - 18, 0);

Pokud je to možné, vždy preferujte statické SQL
-----------------------------------------------

Ve statickém SQL vůbec SQL injection nehrozí.

    CREATE OR REPLACE FUNCTION user_access (
        p_uname IN VARCHAR2
    ) RETURN date AS
        v_accessed_at date;
    BEGIN
        SELECT accessed_at INTO v_accessed_at FROM users WHERE username = p_uname;
        RETURN v_accessed_at;
    END;
    /


    SELECT user_access('janihur')
      AS "POSLEDNÍ PŘIHLÁŠENÍ JANIHURA" FROM DUAL;

    POSLEDNÍ PŘIHLÁŠENÍ JANIHURA
    -------------------
    2011-08-03 17:11:24

    SELECT user_access('whocares'' or superuser = 1 or username = ''whocares') 
      AS "POSLEDNÍ PŘIHLÁŠENÍ SUPERUSERA" FROM DUAL;

    POSLEDNÍ PŘIHLÁŠENÍ SUPERUSERA
    -------------------


Když potřebujete dynamické SQL, tak se pokud možno vyhněte spojování řetězců
----------------------------------------------------------------------------

Spojování řetězců otvírá možnost SQL injection:

    CREATE OR REPLACE FUNCTION user_access (
        p_uname IN VARCHAR2
    ) RETURN date AS
        v_accessed_at date;
        v_query constant varchar2(32767) := 
          'SELECT accessed_at FROM users WHERE username = ''' || p_uname || '''';
    BEGIN
        EXECUTE IMMEDIATE v_query INTO v_accessed_at;
        RETURN v_accessed_at;
    END;
    /


    SELECT user_access('janihur')
      AS "POSLEDNÍ PŘIHLÁŠENÍ JANIHURA" FROM DUAL;

    POSLEDNÍ PŘIHLÁŠENÍ JANIHURA
    -------------------
    2011-08-03 17:11:24

    SELECT user_access('whocares'' or superuser = 1 or username = ''whocares') 
      AS "POSLEDNÍ PŘIHLÁŠENÍ SUPERUSERA" FROM DUAL;

    POSLEDNÍ PŘIHLÁŠENÍ SUPERUSERA
    -------------------
    2011-07-22 17:11:24

Místo toho používejte vázací proměnné:


    CREATE OR REPLACE FUNCTION user_access (
        p_uname IN VARCHAR2
    ) RETURN date AS
        v_accessed_at date;
        v_query constant varchar2(32767) := 
          'SELECT accessed_at FROM users WHERE username = :a';
    BEGIN
        EXECUTE IMMEDIATE v_query INTO v_accessed_at USING p_uname;
        RETURN v_accessed_at;
    END;
    /


    SELECT user_access('janihur')
      AS "POSLEDNÍ PŘIHLÁŠENÍ JANIHURA" FROM DUAL;

    POSLEDNÍ PŘIHLÁŠENÍ JANIHURA
    -------------------
    2011-08-03 17:11:24

    SELECT user_access('whocares'' or superuser = 1 or username = ''whocares') 
      AS "POSLEDNÍ PŘIHLÁŠENÍ SUPERUSERA" FROM DUAL;

    POSLEDNÍ PŘIHLÁŠENÍ SUPERUSERA
    -------------------

Injection pomocí implicitní konverze datových typů
--------------------------------------------------

K pozměnění SQL příkazů lze zneužít i NLS parametry session (`NLS_DATE_FORMAT`, `NLS_TIMESTAMP_FORMAT`, `NLS_TIMESTAMP_TZ_FORMAT`, `NLS_NUMERIC_CHARACTER`).

V následujícím příkladu dochází ke konverzi datových typů, když se `p_since` implicitně zkonvertujte na řetězec, aby se dal připojit. Všimněte si, jak hodnota `NLS_DATE_FORMAT` ovlivňuje text dotazu ve funkci `users_since()`!

    ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

    CREATE OR REPLACE TYPE userlist_t AS TABLE OF VARCHAR2(8);
    /

    CREATE OR REPLACE FUNCTION users_since(
        p_since IN DATE
    ) RETURN userlist_t PIPELINED AS
        v_users userlist_t;
        v_query constant varchar2(32767) := 
          'SELECT username FROM users WHERE superuser = 0 and accessed_at > ''' || p_since || ''' order by accessed_at desc';
    BEGIN
        DBMS_OUTPUT.PUT_LINE('v_query = ' || v_query);
        EXECUTE IMMEDIATE v_query BULK COLLECT INTO v_users;

        FOR i IN v_users.FIRST .. v_users.LAST LOOP
          PIPE ROW(v_users(i));
        END LOOP;

        RETURN;
    END;
    /


    ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD"PŘEKVAPENÍ!"';
    SELECT COLUMN_VALUE AS "BĚŽNÍ" FROM TABLE(users_since(sysdate - 30));

    v_query = SELECT username FROM users WHERE superuser = 0 and accessed_at >
    '2011-07-04PŘEKVAPENÍ!' order by accessed_at desc

    BĚŽNÍ
    --------
    janihur
    albundy
    donduck

    ALTER SESSION SET NLS_DATE_FORMAT = '"'' or superuser = 1 or username = ''whocares"';
    SELECT COLUMN_VALUE AS "SUPERUŽIVATELÉ" FROM TABLE(users_since(sysdate - 30));

    v_query = SELECT username FROM users WHERE superuser = 0 and accessed_at > ''
    or superuser = 1 or username = 'whocares' order by accessed_at desc

    SUPERUŽIVATELÉ
    --------
    petdance

Nápravou je explicitní uvedení formátu: `to_char(p_since, 'YYYY-MM-DD')`.

    ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

    CREATE OR REPLACE TYPE userlist_t AS TABLE OF VARCHAR2(8);
    /

    CREATE OR REPLACE FUNCTION users_since(
        p_since IN DATE
    ) RETURN userlist_t PIPELINED AS
        v_users userlist_t;
        v_query constant varchar2(32767) := 
          'SELECT username FROM users WHERE superuser = 0 and accessed_at > ''' || to_char(p_since, 'YYYY-MM-DD') || ''' order by accessed_at desc';
    BEGIN
        DBMS_OUTPUT.PUT_LINE('v_query = ' || v_query);
        EXECUTE IMMEDIATE v_query BULK COLLECT INTO v_users;

        FOR i IN v_users.FIRST .. v_users.LAST LOOP
          PIPE ROW(v_users(i));
        END LOOP;

        RETURN;
    END;
    /

Teď se hodnota NLS parametru `NLS_DATE_FORMAT` v dotazu ignoruje:

    ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD"PŘEKVAPENÍ!"';
    SELECT COLUMN_VALUE AS "BĚŽNÍ" FROM TABLE(users_since(sysdate - 30));

    v_query = SELECT username FROM users WHERE superuser = 0 and accessed_at >
    '2011-07-04' order by accessed_at desc

    BĚŽNÍ
    --------
    janihur
    albundy
    donduck
