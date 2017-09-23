var bodyE = null;
var child = null;
var fDiv = null;
var oUl = null;
var fUl = null;
window.onload=function(){
	bodyE = document.getElementsByTagName('body')[0];                                                                                            //获取body
	fDiv = document.getElementsByTagName('div')[0];                                                                                                    //获取第一个DIV,用于 插入悬浮窗（文件管理窗口）
                     addMF();                                                                                                                                                                            //在状态栏添加一个“filemanager”入口
	child = document.createElement('div');                                                                                                                         //创建遮罩层，也是用于承载整个文件管理窗口的
                     child.onclick=function(){
                         remove();
                     };
	var fra = document.createElement('div');                                                                                                                      //创建件管理窗口
	document.getElementById("filema").onclick=function(){                                                                                           //为filemanager添加监听事件，整个JS的入口
                                addEE();
                                oUl = document.getElementById('gul');
                                getData();
	};
	function addEE(){                                                                                                                                                              //从服务器获取文件列表
		fDiv.style.zIndex = '-10';
		child.id = 'download';
		child.className='overlay';
		fra.innerHTML='<div class="modal-dialog"><div class="modal-content"><div class="modal-header ng-scope"><button class="close" onclick="remove()">×</button><h4 class="ng-binding">File Lists</h4></div><form class="modal-body ng-pristine ng-valid ng-scope"><fieldset><ul id="gul"><!--<li><h4 class="ng-binding">00000000000</h4></li>--></ul><br><br></fieldset><div class="modal-footer"><button type="button" class="btn btn-default ng-binding" onclick="remove()">Cancel</button><button type="button" class="btn btn-default ng-binding btn-primary" onclick="clearAll()">ClearAll</button></div></form></div></div>';
		child.appendChild(fra);
		bodyE.appendChild(child);
	}
	

}

function remove(){
	fDiv.style.zIndex = '1000';
	bodyE.removeChild(child);
}

function addMF(){                                                                                                                                                                                 //在状态栏添加一个“filemanager”入口
    fUl = fDiv.getElementsByTagName('ul')[0];
    var par = fUl.parentNode;
    var newul =  document.createElement('ul');
    newul.className = 'nav navbar-nav';
    newul.id = 'filema';
    newul.innerHTML = '<li><a href="#" dropdown-toggle>FilesManager <span class=""></span></a></li>';
    par.appendChild(newul);
}

function getData(){                                                                                                                                                                               //向服务器请求文件列表
            var xmlHttp = new XMLHttpRequest();
            xmlHttp.open('get','change.jsp',true);
            xmlHttp.onreadystatechange=function (){
                                if(xmlHttp.readyState==4){
                                    oUl.innerHTML = xmlHttp.responseText;
                                }
            };
            xmlHttp.send();
}

function clearAll(){                                                                                                                                                                                
        singledel(0,'C:/Users/RUO/Desktop/css');
}

function singledel(meth,path){                                                                                                                                                           //meth参数：0--全部清除；1--删除一个文件，path传递一个具体文件夹路劲
  var meth = '?meth='+meth;                                                                                                                                                              //3--向服务器请求文件列表（等合并两个JSP后再实现）   
  var path = '&delfil='+path;
  path = encodeURI(encodeURI(path));                                                                                                                                              //两次编码（服务器要一次解码），处理中文乱码问题
  var xmlH = new XMLHttpRequest();
  xmlH.open('GET','this.jsp'+meth+path,true);
  xmlH.onreadystatechange=function(){
            if(xmlH.readyState==4){
                     //alert(xmlH.responseText);
                    getData();                                                                                                                                                                          //刷新客户端文件列表（后期改用为parent.removeChild(node),减少客户端/服务器工作量）
            }
  };
   xmlH.send();
 }
 



