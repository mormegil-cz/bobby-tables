Perl
====

Perlová knihovna [DBI](http://search.cpan.org/dist/DBI), dostupná na [CPANu](http://search.cpan.org), podporuje parametrizovaná SQL volání.  Metody `do` i `prepare` podporují u většiny databázových ovladačů parametry (nazývané _placeholders_). Například:


    $sth = $dbh->prepare("SELECT * FROM users WHERE email = ?");
    foreach my $email (@emails) {
        $sth->execute($email);
        $row = $sth->fetchrow_hashref;
        [...]
    }

Nemůžete však parametrizovat identifikátory (názvy tabulek a sloupcí),
takže k tomu musíte použít metodu `quote_identifier()`:

    # Zajistit, že zamýšlený název tabulky je bezpečný:
    my $quoted_table_name = $dbh->quote_identifier($table_name);

    # Předpokládejme, že @cols obsahuje seznam názvů sloupců, které chceme načíst:
    my $cols = join ',', map { $dbh->quote_identifier($_) } @cols;

    my $sth = $dbh->prepare("SELECT $cols FROM $quoted_table_name ...");

Také se můžete vyhnout nutnosti psát SQL ručně díky [DBIx::Class](http://p3rl.org/DBIx::Class), [SQL::Abstract](http://p3rl.org/SQL::Abstract) apod., které můžou programově generovat SQL za vás.

Co je režim nakažení?
---------------------

Režim nakažení (_Taint_) je speciální sada bezpečnostních kontrol, které Perl provádí nad každým vstupem dat do vašeho programu z externích zdrojů. Vstupní data jsou označená jako nakažená (nedůvěryhodná) a nelze je používat v příkazech, které by vám umožnily si ublížit. Podrobnější rozpis, co všechno režim nakažení kontroluje, najdete na [manuálové stránce perlsec](http://perldoc.perl.org/perlsec.html).

Pro vyvolání režimu nakažení:

    # Z příkazové řádky
    perl -T program.pl

    # Navrchu vašeho skriptu
    #!/usr/bin/perl -T

Pokud váš skript narazí na některou z kontrol nakažení, vaše aplikace skončí na fatální chybu. Kvůli testování dává `-t` varování místo fatálních chyb. `-t` není náhrada za `-T`.

Chybí
-----

Vysvětlit podporu režimu nakažení v DBI, jak na vstupech, tak výstupech.
