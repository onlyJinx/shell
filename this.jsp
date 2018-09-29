
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.io.*,java.net.*,java.util.*" %>

<%  
        String spath = request.getParameter("delfil");
        spath = java.net.URLDecoder.decode(spath, "UTF-8");
        int meth = Integer.parseInt(request.getParameter("meth"));
        if(meth==1){
                if(spath.equals("0")){
                     clearAll(new File("/web_home/downloads"));
                }else{
                    File path = new File(spath);
                    singleDelete(path);
                }
                
        }else if(meth==0){
                if(start().length != 0){
                        out.println("<table border=\"1\">");
                        for(String se : start()){
                                se = se.replace("\\", "/");                                                                                                                       //避开转义字符---反斜杠
                                //out.println("<tr><td class=\"private_td\"><a href='"+se.replace("/web_home","")+"'>"+se.replace("/web_home/downloads/","")+" </a></td><td style=\"white-space:nowrap;\" class=\"private_td\"><a href='javascript:void(0);' onclick='ajaxHttp(\"1\",\""+se+"\")'>Delete</a></td></tr>");
                                out.println("<tr><td class=\"private_td\"><a href='"+se.replace("/web_home","")+"'>"+se.replace("/web_home/downloads/","")+" </a></td><td style=\"white-space:nowrap;\" class=\"private_td\"><a href='javascript:void(0);' onclick='deleFile(\""+se+"\",this)'>Delete</a></td></tr>");
                        }
                        out.println("</table>");
                }else{
                        out.println("<h4>NotFound File</h4>");
                }
        }else{
            out.println("<h3>FREESPACE : "+Roots()+" MB</h3>");
        };
        
        
%>

<% //查询文件列表%>
<%!
    //String path = "/web_home/downloads";
    File files = new File("/web_home/downloads");
    String[] ss;
    ArrayList<String> arr = new ArrayList();
    public void parseFile(File file){
        File[] f = file.listFiles();
        if(f!=null){                                                                                                                                                    //防止空指针错误
            for(File ff : f){
                if(ff.isDirectory()){
                    parseFile(ff);
                }else{
                    if(ff.getName().substring(ff.getName().lastIndexOf(".") + 1).equals("mht") | ff.getName().substring(ff.getName().lastIndexOf(".") + 1).equals("chm") | ff.getName().substring(ff.getName().lastIndexOf(".") + 1).equals("url") | ff.getName().substring(ff.getName().lastIndexOf(".") + 1).equals("html") | ff.getName().substring(ff.getName().lastIndexOf(".") + 1).equals("txt")){
                            ff.delete();
                    }else{
                            arr.add(ff.toString());
                    }
                }
            }
        }else{
            return;
        }
    }

    public String[] start(){
        arr.clear();                                                                                                                                                  //重置arraylist列表，避免无限打印
        parseFile(files);
        ss = arr.toArray(new String[arr.size()]);
        return ss;
    }
    

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


<% //全部清理%>
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
<% //查可用储存空间 %>
<%!
	public long Roots(){
		File sto = new File("/web_home/downloads");
		return sto.getFreeSpace()/(long)1024/(long)1024;
	}
%>
