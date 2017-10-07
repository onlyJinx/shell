<%-- 
    Document   : testjsp1
    Created on : 2017-10-7, 0:06:04
    Author     : RUO
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <%
            String passwd = request.getParameter("passwd");
            //if(passwd.equals("12345")){
            if(passwd==null)
                    %><jsp:forward page="login.html"/><%
            if("12345".equals(passwd)){%>
                     <jsp:forward page="index.html"/>
    <%
            }else{
                    out.println("<center><h1 style='color:red;font-size:100px;'>草泥马，密码错了！</h1></center>");
            }
    %>
    
    <body>
    </body>
</html>
