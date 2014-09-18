C\#
===

Z wiki stránky [ASP.NET Security Hacks--Avoiding SQL Injection](http://en.csharp-online.net/ASP.NET_Security_Hacks%E2%80%94Avoiding_SQL_Injection) na [C# Online](http://en.csharp-online.net/):


    SqlCommand userInfoQuery = new SqlCommand(
        "SELECT id, name, email FROM users WHERE id = @UserName",
        someSqlConnection);

    SqlParameter userNameParam = userInfoQuery.Parameters.Add("@UserName",
        SqlDbType.VarChar, 25 /* maximální délka pole */ );

    // userName je nějaká řetězcová proměnná obsahující uživatelský vstup
    userNameParam.Value = userName;

Nebo jednodušeji:


    String username = "joe.bloggs";
    SqlCommand sqlQuery = new SqlCommand("SELECT user_id, first_name,last_name FROM users WHERE username = ?username",  sqlConnection);
    sqlQuery.Parameters.AddWithValue("?username", username);
