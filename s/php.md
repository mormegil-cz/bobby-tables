# PHP

PHP je o něco neorganizovanější než
[zpracování parametrů v Perlu](./perl.html).  Standardní
[rozšíření pro MySQL][mysql] nepodporuje parametrizaci, přestože
[rozšíření PostgreSQL][pg] ano:

    $result = pg_query_params( $dbh, 'SELECT * FROM users WHERE email = $1', array($email) );

Povšimněte si, že příkaz musí být v jednoduchých uvozovkách, nebo
se musí `$` oescapovat, aby se PHP nepokoušelo zpracovat ho jako
proměnnou. (Ve skutečnosti v tomto případě PHP nebude `$1` chápat
jako proměnnou a nahrazovat ho, ale kvůli štábní kultuře dávejte
jakékoli řetězce obsahující znaky dolaru, které chcete jako znaky
dolaru zachovat, do jednoduchých uvozovek.)

**Jenže** byste pravděpodobně měli spíše používat abstrakční vrstvu.
Rozšíření [ODBC][odbc] a [PDO][pdo] obě podporují parametrizaci
a několik databází:

[mysql]: http://php.net/manual/en/book.mysql.php
[pg]: http://www.php.net/manual/en/book.pgsql.php
[odbc]: http://php.net/manual/en/book.uodbc.php
[pdo]: http://www.php.net/manual/en/book.pdo.php

## Použití mysqli

Rozšíření MySQL Improved podporuje vázané parametry.

    $stmt = $db->prepare('update people set name = ? where id = ?');
    $stmt->bind_param('si',$name,$id);
    $stmt->execute();

## Použití ADODB

ADODB umožňuje postup, jak příkaz kompletně připravit, navázat i provést jediným voláním.

    $dbConnection = NewADOConnection($connectionString);
    $sqlResult = $dbConnection->Execute(
        'SELECT user_id,first_name,last_name FROM users WHERE username=? AND password=?',
        array($_REQUEST['username'], sha1($_REQUEST['password'])
    );

## Použití ODBC vrstvy

    $stmt = odbc_prepare( $conn, 'SELECT * FROM users WHERE email = ?' );
    $success = odbc_execute( $stmt, array($email) );

Nebo:

    $res = odbc_exec($conn, 'SELECT * FROM users WHERE email = ?', array($email));
    $sth = $dbh->prepare('SELECT * FROM users WHERE email = :email');
    $sth->execute(array(':email' => $email));

## Použití PDO vrstvy

Takhle se parametry vážou složitějším způsobem.

    $dbh = new PDO('mysql:dbname=testdb;host=127.0.0.1', $user, $password);
    $stmt = $dbh->prepare('INSERT INTO REGISTRY (name, value) VALUES (:name, :value)');
    $stmt->bindParam(':name', $name);
    $stmt->bindParam(':value', $value);

    // vložit jeden řádek
    $name = 'one';
    $value = 1;
    $stmt->execute();

A kratší způsob, jak věci předávat.

    $dbh = new PDO('mysql:dbname=testdb;host=127.0.0.1', $user, $password);
    $stmt = $dbh->prepare('UPDATE people SET name = :new_name WHERE id = :id');
    $stmt->execute( array('new_name' => $name, 'id' => $id) );

Tady je výborný [průvodce migrací na PDO pro vývojáře na MySQL](http://wiki.hashphp.org/PDO_Tutorial_for_MySQL_Developers).

# Aplikace a frameworky

## CakePHP

Při použití MVC frameworku [CakePHP][cakephp] bude většina
vaší databázové komunikace abstrahována díky Model API.
Přesto je někdy potřeba provádět ruční dotazy, což lze dělat
pomocí [Model::query][cake-model-query]. Aby tato metoda používala
připravené příkazy, stačí za řetězcem s SQL dotazem předat dodatečný
parametr typu pole. Existují dvě varianty:

    // Nepojmenované náhrady: Předejte pole obsahující jeden prvek pro každý ?
    $this->MyModel->query(
        'SELECT name FROM users WHERE id = ? AND status = ?',
        array($id, $status)
    );

    // Pojmenované náhrady: Předejte asociativní pole
    $this->MyModel->query(
        'SELECT name FROM users WHERE id = :id AND status = :status',
        array('id' => $id, 'status' => $status)
    );

Dokumentace tohoto chování je v [CakePHP Cookbook][cake-cookbook].
(Popsáno je u metody `fetchAll()`, ale `query()` uvnitř používá
`fetchAll()`.)

[cakephp]: http://cakephp.org/
[cake-model-query]: http://api.cakephp.org/class/model#method-Modelquery
[cake-cookbook]: http://book.cakephp.org/2.0/en/models/retrieving-your-data.html#prepared-statements

## WordPress

Pokud váš web/blog/aplikace běží na [WordPress][WP], můžete
použít metodu `prepare` třídy `$wpdb`, které podporuje syntaxi
podobnou `sprintf()` a `vsprintf()`.

    global $wpdb;
    $wpdb->query(
        $wpdb->prepare( 'SELECT name FROM people WHERE id = %d OR email = %s',
            $person_id, $person_email
        )
    );

Pro příkazy INSERT, UPDATE a DELETE můžete využít šikovné pomocné
metody této třídy, které umožňují specifikovat formát odesílaných
hodnot.

    global $wpdb;
    $wpdb->insert( 'people',
            array(
                'person_id' => '123',
                'person_email' => 'bobby@tables.com'
            ),
        array( '%d', '%s' )
    );

Další podrobnosti jsou ve [WordPress Codex][codex].

[WP]: http://wordpress.org/
[codex]: http://codex.wordpress.org/Class_Reference/wpdb
