Delphi
======

Pro použití předpřipraveného dotazu použijte něco jako:

    query.SQL.Text := 'update people set name=:Name where id=:ID';
    query.Prepare;
    query.ParamByName( 'Name' ).AsString := name;
    query.ParamByName( 'ID' ).AsInteger := id;
    query.ExecSQL;
