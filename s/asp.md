ASP
===

Staré ASP používá poziční náhrady.

    objCmd.CommandType = adCmdText;
    objCmd.CommandText = "UPDATE members SET photo = ? WHERE memberID = ?";
    objCmd.Parameters.Append(objCmd.CreateParameter("filename", adVarChar, adParamInput, 510, fileName));
    objCmd.Parameters.Append(objCmd.CreateParameter("memberID", adInteger, adParamInput, 4, memberid ));
    objCmd.Execute(adExecuteNoRecords);


Novější ASP (ASP.Net?) zvládá pojmenované náhrady.

    objCmd.CommandType = adCmdText;
    objCmd.CommandText = "UPDATE members SET photo = @filename WHERE memberID = @memberID";
    objCmd.Parameters.Append(objCmd.CreateParameter("@memberID", adInteger, adParamInput, 4, memberid ));
    objCmd.Parameters.Append(objCmd.CreateParameter("@filename", adVarChar, adParamInput, 510, fileName));
    objCmd.Execute(adExecuteNoRecords);
    gblDelobjParams(objCmd);

Chybí
-----

Přidat povídání
