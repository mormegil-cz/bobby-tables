ColdFusion
==========

V ColdFusion existuje značka `cfqueryparam`, která by se měla používat u všech inline dotazů.

    <cfquery name="queryTest">
    SELECT FirstName, LastName, Phone
    FROM   tblUser
    WHERE  Status =
      <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#form.status#">
    </cfquery>


Uložené procedury lze vyvolat pomocí značek `cfstoredproc` a `cfprocparam`.

Novější verze ColdFusion poskytují sadu funkcí pro spouštění dotazů, které
mají mírně odlišnou syntaxi, ale stále umožňují parametrizované dotazy.


    <cfscript>
      var myQuery = new Query(sql="
        SELECT FirstName, LastName, Phone
        FROM   tblUser
        WHERE  Status = :status
      ");
      myQuery.addParam(
        name      = "status",
        value     = form.status,
        cfsqltype = "cf_sql_varchar"
      );
      var rawQuery = myQuery.execute().getResult();
    </cfscript>

