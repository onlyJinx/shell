<%@page import="org.apache.taglibs.standard.*"%>
<%@page language="java" import="java.util.*,java.text.SimpleDateFormat,java.io.*" pageEncoding="UTF-8"%>
<%
    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    String tim = df.format(new Date());
    String resp = null;
    out.println("<h3>Current Time  :  "+tim+"</h3><br>");
    if(start().length==0){
        out.println("<p>not found files!<p>");
    }else{
        for(String se : start()){
        resp = se.replace("\\", "/");                                                                                                                       //避开转义字符---反斜杠
        out.println("<a style='float:left;' href='"+resp+"'>"+resp+" </a><a style='float:right;margin-right:50px;' href='javascript:void(0);' onclick='singledel(\"1\",\""+resp+"\")'>Delete</a><br>");
    }
    }
    
%>
<%!
    String path = "C:\\Users\\RUO\\Desktop\\css";
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
