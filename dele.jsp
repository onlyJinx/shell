

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.io.*,java.util.*"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
	<style>
		th,td{font-size:30px;}
	</style>
    </head>
    <body>
        <table border="1" align="center">
            <tr><th align="center">FileLists</th></tr>
        <% 
            count = 0;
            al.clear();
            Dele(files);
            int size = al.size();
            String[] arr = (String[])al.toArray(new String[size]);
            System.out.println(size);
            for(String s : arr){
          %>
          <tr><td align="center"><%= s.substring(s.lastIndexOf("/")+1) %></td></tr>
          <%
            }
        %>
        </table>
        <%! 
            int count = 0;
            List al = new ArrayList();
            File files = new File("/web_home/downloads");
            void Dele(File file){
                File[] files = file.listFiles();
                if(files!=null){
                    for(File f : files){
                        if(f.isDirectory()){
                            Dele(f);
                            f.delete();
                        }else if(f.isFile()){
                            f.delete();
                            al.add(f.toString());
                            count++;
                        }
                    }
                }
             }
        %>
        
    <center><h1 >total delete file <%= count%></h1></center>
    </body>
</html>

