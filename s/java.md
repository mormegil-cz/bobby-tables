Java
====

JDBC
----

[JDBC API](http://download.oracle.com/javase/tutorial/jdbc/index.html)
obsahuje třídu nazvanou
[`PreparedStatement`](http://download.oracle.com/javase/6/docs/api/java/sql/PreparedStatement.html),
která programátorovi umožňuje bezpečně vkládat uživatel zadaná
data do SQL příkazu. Umístění každé vstupní hodnoty v dotazu
označuje otazníček. Poté se k bezpečnému vložení hodnoty používají
rozličné metody `set*()`.

    String name = //uživatelský vstup
    int age = //uživatelský vstup
    Connection connection = DriverManager.getConnection(...);
    PreparedStatement statement = connection.prepareStatement(
            "SELECT * FROM people WHERE lastName = ? AND age > ?" );
    statement.setString(1, name); //lastName je VARCHAR
    statement.setInt(2, age); //age je INT
    ResultSet rs = statement.executeQuery();
    while (rs.next()){
        //...
    }


Jakmile je vytvořen objekt `PreparedStatement`, lze ho opakovaně použít
pro více příkazů (například při použití stejného příkazu pro aktualizaci
více řádků tabulky). Tyto objekty však **nejsou thread-safe**, kvůli
tomu, že se nastavování parametrů a provádění příkazů provádí mnoha
voláními metod. Proto byste měli objekty `PreparedStatement` definovat
jen na úrovni metod (nikoli na úrovni tříd), abyste se vyhli problémům
s paralelismem.

    List<Person>; people = //uživatelský vstup
    Connection connection = DriverManager.getConnection(...);
    connection.setAutoCommit(false);
    try {
        PreparedStatement statement = connection.prepareStatement(
                "UPDATE people SET lastName = ?, age = ? WHERE id = ?");
        for (Person person : people){
            statement.setString(1, person.getLastName());
            statement.setInt(2, person.getAge());
            statement.setInt(3, person.getId());
            statement.execute();
        }
        connection.commit();
    } catch (SQLException e) {
        connection.rollback();
    }

Více informací o `PreparedStatement` se nachází v
[tutoriálu JDBC od Oraclu](http://download.oracle.com/javase/tutorial/jdbc/basics/prepared.html).

Hibernate
---------

[Hibernate](http://www.hibernate.org/) používá pro bezpečné vkládání
dat do příkazu pojmenované parametry. Pojmenovaný parametr sestává
z dvojtečky následované jedinečným jménem parametru.

    String name = //uživatelský vstup
    int age = //uživatelský vstup
    Session session = //...
    Query query = session.createQuery("from People where lastName = :name and age > :age");
    query.setString("name", name);
    query.setInteger("age", age);
    Iterator people = query.iterate();

I Hibernate podporuje poziční parametry jako `PreparedStatement`,
ale preferují se pojmenované parametrym protože výsledný příkaz
je s nimi o něco lépe čitelný.

Více informací o pojmenovaných parametrech najdete v 
[příručce Hibernate](http://docs.jboss.org/hibernate/stable/core/reference/en/html/objectstate.html#objectstate-querying-executing-parameters).

MyBatis
-------

[MyBatis](http://www.mybatis.org/) je databázový framework, který
programátora odstiňuje od spousty JDBC kódu, čímž mu/jí umožňuje
soustředit se na psaní SQL. SQL příkazy se typicky ukládají
do XML souborů.

V pozadí MyBatis automaticky vytváří instance `PreparedStatement`.
Programátor se nemusí o nic dalšího starat.

Pro představu je zde příklad volání jednoduchého dotazu pomocí
MyBatis. Vstupní data se předávají do instance `PeopleMapper`
a poté se vloží do dotazu `selectPeopleByNameAndAge`.

XML dokument s mapováním
========================

    <?xml version="1.0" encoding="UTF-8" ?>
    <!DOCTYPE mapper
    PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.bobbytables.mybatis.PeopleMapper">
    <select id="selectPeopleByNameAndAge" resultType="list">
        <!-- lastName a age jsou automaticky ošetřeny --->
        SELECT * FROM people WHERE lastName = #{lastName} AND age > #{age}
    </select>
    </mapper>

Mapující třída
==============

    public interface PeopleMapper {
        List<Person> selectPeopleByNameAndAge(@Param("lastName") String name, @Param("age") int age);
    }

Provedení dotazu
================

    String name = //uživatelský vstup
    int age = //uživatelský vstup
    SqlSessionFactory sqlMapper = //...
    SqlSession session = sqlMapper.openSession();
    try {
        PeopleMapper mapper = session.getMapper(PeopleMapper.class);
        List<Person> people = mapper.selectPeopleByNameAndAge(name, age); //data se automaticky ošetří
        for (Person person : people) {
            //...
        }
    } finally {
        session.close();
    }
