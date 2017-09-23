
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.io.*,java.net.*" %>

<%  
        String spath = request.getParameter("delfil");
        spath = java.net.URLDecoder.decode(spath, "UTF-8");
        int meth = Integer.parseInt(request.getParameter("meth"));
        File path = new File(spath);
        if(meth==1){
            singleDelete(path);
        }else{
            clearAll(path);
        };
        
        
%>

<%!
        boolean tt;
        public void singleDelete(File fileName){
                if(!fileName.exists()){
                    return;
                };
                if(fileName.isFile()){
                    tt = fileName.delete();
                    if(tt){
                        return;
                    }
                }else{
                    System.out.print(fileName.toString());
                    return;
                    }
        };
%>

<%!
        public void clearAll(File file){
                File[] files = file.listFiles();
                if(files!=null){
                     for(File f : files){
                        if(f.isFile()){
                            f.delete();
                        }else if(f.isDirectory()){
                            clearAll(f);
                            f.delete();
                        }
                    }
                }
        }
%>
