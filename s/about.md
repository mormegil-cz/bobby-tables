# O Bobbym Tablesovi a SQL injection

# Proč Bobbyho škola přišla o údaje o studentech?

Škola patrně ukládá jména studentů do tabulky nazvané _Students_. Když nastoupí nový student, škola do této tabulky vloží jeho jméno. Kód, který to dělá, může vypadat nějak takhle:

    $sql = "INSERT INTO Students (Name) VALUES ('" . $studentName . "');";
    execute_sql($sql);

První řádka připraví řetězec obsahující SQL příkaz `INSERT`. Obsah proměnné `$studentName` je vlepen do tohoto SQL příkazu. Na druhém řádku se výsledný SQL příkaz pošle do databáze. Problémem tohoto kódu je, že data zvenku, v tomto případě obsah proměnné `$studentName`, se stanou součástí SQL příkazu.

Nejprve se podívejme, jak bude SQL příkaz vypadat v případě, že vkládáme studenta jménem Jan:

    INSERT INTO Students (Name) VALUES ('Jan');

Dělá přesně to, co chceme: vloží Jana do tabulky _Students_.

Nyní budeme chtít vložit Bobbyho Tablese tím, že `$studentName` nastavíme na `Robert'); DROP TABLE Students;--`. SQL příkaz bude vypadat takto:

    INSERT INTO Students (Name) VALUES ('Robert'); DROP TABLE Students;--');

Tím se Robert vloží do tabulky _Students_. Jenže za příkazem `INSERT` teď následuje příkaz `DROP TABLE`, který smaže celou tabulku _Students_. Jauvajs!


# Jak se nenechat nachytat Bobbym Tablesem

Existuje jediný způsob, jak se vyhnout útokům tohoto typu.

* Nevyrábějte SQL příkazy, které obsahují data zvenčí.
* Používejte parametrizované SQL dotazy.

To je vše. Nezkoušejte escapovat neplatné znaky. Nezkoušejte si to ošetřit sami. Naučte se používat parametrizované příkazy. Vždycky, úplně pokaždé.

V onom komiksu je jedna věc zásadně špatně. Řešením není sami „ošetřovat databázové vstupy“. To je náchylné k chybám.
