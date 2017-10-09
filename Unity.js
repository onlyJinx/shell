

var bodyE,child,fDiv,oUl,fUl;
window.onload=function(){
	bodyE = document.getElementsByTagName('body')[0];                                                                                            //获取body
	fDiv = document.getElementsByTagName('div')[0];                                                                                                    //获取第一个DIV,用于 插入悬浮窗（文件管理窗口）
                     addMF();                                                                                                                                                                           //在状态栏添加一个“filemanager”入口
	child = document.createElement('div');                                                                                                                         //创建遮罩层，也是用于承载整个文件管理窗口的
	var fra = document.createElement('div');                                                                                                                      //创建件管理窗口
	document.getElementById("filema").onclick=function(){                                                                                           //为filemanager添加监听事件，整个JS的入口
                                addEE();
                                bodyE.className="ng-scope overflow1";
                                oUl = document.getElementById('gul');
                                ajaxHttp(0,null,oUl);
                                ajaxHttp(2,null,document.getElementById('freeSp'));
	};
	function addEE(){                                                                                                                                                              //从服务器获取文件列表
		fDiv.style.zIndex = '-10';
		child.id = 'download';
		child.style.overflowX = 'auto';
		child.className='overlay';
		fra.innerHTML='<div class="modal-dialog text-center"><div class="modal-content"><div  class="modal-header ng-scope"><button class="close" onclick="remove()">×</button><h3 id="freeSp"></h3></div><form class="modal-body ng-pristine ng-valid ng-scope"><fieldset><ul id="gul" style="padding:10px;"></ul></fieldset><div class="modal-footer"><button type="button" class="btn btn-default ng-binding" onclick="remove()">Cancel</button><button type="button" class="btn btn-default ng-binding btn-primary" onclick="clearAll()">ClearAll</button></div></form></div></div>';
		child.appendChild(fra);
		bodyE.appendChild(child);
	}
	

};

function remove(){
	fDiv.style.zIndex = '1000';
	bodyE.className="ng-scope";
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
/*
function getData(){                                                                                                                                                                               //向服务器请求文件列表
            var xmlHttp = new XMLHttpRequest();
            xmlHttp.open('get','change.jsp',true);
            xmlHttp.onreadystatechange=function (){
                                if(xmlHttp.readyState==4){
                                    //oUl.innerHTML = xmlHttp.responseText;
                                if(xmlHttp.responseText.indexOf('<h3>')==2){
                                    oUl.innerHTML = xmlHttp.responseText;
                                }else{
                                    getData();
                                    //alert(xmlHttp.responseText);
                                };
                                }
            };
            xmlHttp.send();
}
*/

function deleFile(pa,a){
   ajaxHttp(1,pa,'',false);                                                                                                                                                                                   //向服务器发起删除请求
   a.parentNode.parentNode.parentNode.removeChild(a.parentNode.parentNode);                                                                 //删除TR标签
   ajaxHttp(2,null,document.getElementById('freeSp'));                                                                                                                   //重新获取可用内存i
   if(oUl.getElementsByTagName('tr').length===0){
      oUl.innerHTML = '<h4>There is no file can be deleted</h4>';
   }
}

function clearAll(){                                                                                                                                                                                
        ajaxHttp(1,0,'',false);                                                                                                                                                                                //向服务器发起删除请求
        ajaxHttp(2,null,document.getElementById('freeSp'));                                                                                                              //重新获取可用内存
        oUl.innerHTML = '<h4>AllFile Deleted</h4>';                                                                                                                         //清空整个ul列表
}

/**
 * meth参数：
 * 0--获取文件列表；
 * 1--删除文件，path传递一个具体文件夹路劲或传递数字“0”，代表全部删除
 * 2--获取可用内存
 * */

function ajaxHttp(meth,path,innerObj,sync){
        if(sync===undefined){
                sync = true;
        }
	var meth = '?meth='+meth;
        var path = '&delfil='+path;
        path = encodeURI(encodeURI(path));                                                                                                                                        //两次编码（服务器要一次解码），处理中文乱码问题
        var xmlH = new XMLHttpRequest();
        xmlH.open('GET','this.jsp'+meth+path,sync);                                                                                                                            //同步处理，防止查询可用内存是文件还未被删除导致获取的数据有误
        xmlH.onreadystatechange=function(){
                  if(xmlH.readyState===4){
                      if(innerObj===undefined){
                          return;
                      }else{
                          innerObj.innerHTML = xmlH.responseText;
                      }
                  }
        };
         xmlH.send();        
 }
 




