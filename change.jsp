<%@page import="org.apache.taglibs.standard.*"%>
<%@page language="java" import="java.util.*,java.text.SimpleDateFormat,java.io.*" pageEncoding="UTF-8"%>
<%
    String resp = null;
    out.println("<h3>freespace : "+Roots()+" MB</h3><br>");
    if(start().length==0){
        out.println("<p>not found files!<p>");
    }else{
	out.println("<table border=\"1\">");
        for(String se : start()){
        //resp = se.replace("\\", "/");                                                                                                                       //避开转义字符---反斜杠
	out.println("<tr><td class=\"mytdcss\"><a style='float:left;' href='"+se.replace("/web_home","")+"'>"+se.replace("/web_home/downloads/","")+" </a></td><td class=\"mytdcss\"><a href='javascript:void(0);' onclick='singledel(\"1\",\""+se+"\")'>Delete</a></td></tr>");
    	}
	out.println("</table>");
    }
    
%>
<%!
    String path = "/web_home/downloads";
    File files = new File(path);
    String[] ss;
    ArrayList<String> arr = new ArrayList();
    public void parseFile(File file){
        File[] f = file.listFiles();
        if(f!=null){                                                                                                                                                    //防止空指针错误
            for(File ff : f){
                if(ff.isDirectory()){
                    parseFile(ff);
                }else if(ff.isFile()){
                    arr.add(ff.toString());
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
	public long Roots(){
		File sto = new File("/");
		return sto.getFreeSpace()/(long)1024/(long)1024;
	}
%>