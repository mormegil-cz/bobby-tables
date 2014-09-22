Python
======

Při použití [Python DB API](http://wiki.python.org/moin/DatabaseProgramming/) nedělejte následující:

    # Takhle to NEDĚLEJTE.
    cmd = "update people set name='%s' where id='%s'" % (name, id)
    curs.execute(cmd)

Místo toho použijte:

    cmd = "update people set name=%s where id=%s"
    curs.execute(cmd, (name, id))

Uvědomte si, že syntaxe náhrad závisí na databázi, kterou používáte.

    'qmark'         Otazníky,
                    např. '...WHERE name=?'
    'numeric'       Číslované, poziční,
                    např. '...WHERE name=:1'
    'named'         Pojmenované,
                    např. '...WHERE name=:name'
    'format'        Formátovací příkazy z ANSI C,
                    např. '...WHERE name=%s'
    'pyformat'      Rozšířené formátovací příkazy Pythonu,
                    např. '...WHERE name=%(name)s'

Hodnoty pro nejběžnější databáze jsou:

    >>> import MySQLdb; print MySQLdb.paramstyle
    format
    >>> import psycopg2; print psycopg2.paramstyle
    pyformat
    >>> import sqlite3; print sqlite3.paramstyle
    qmark

Takže pokud běžíte na MySQL nebo PostgreSQL, používejte `%s` (i pro čísla a další
neřetězcové hodnoty!) a pokud běžíte na SQLite, používejte `?`.


Chybí
-----

-   Přidat povídání.
