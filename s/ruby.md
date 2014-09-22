Ruby
====

V Ruby on Rails pomocí [ActiveRecord](http://guides.rubyonrails.org/active_record_querying.html):

    Person.find :all, :conditions => ['id = ? or name = ?', id, name]

nebo

    Person.find_by_sql ['SELECT * from persons WHERE name = ?', name]


Pomocí [Ruby/DBI](http://ruby-dbi.rubyforge.org/): obdobně jako v [Perlu](./perl.html).

Chybí
-----

-   Přidat povídání.
