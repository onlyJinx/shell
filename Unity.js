var bodyE = null;
var child = null;
var fDiv = null;
var oUl = null;
var oBu = null;
window.onload=function(){
	bodyE = document.getElementsByTagName('body')[0];
	fDiv = document.getElementsByTagName('div')[0];
	child = document.createElement('div');
	var fra = document.createElement('div');
	oUl = document.getElementById('gul');
	
	var oBu = document.getElementsByTagName('button')[1];
    oBu.onclick = function(){
       getData();
    };
	document.getElementsByTagName("a")[0].onclick=function(){
		addEE();
	};
	
	// function addDown(){
		// var oDiv = fDiv.getElementsByTagName('ul')[0].parentNode;
		// var cUl = document.createElement('ul');
		// cUl.className = 'nav navbar-nav';
		// cUl.innerHTML = "<li class=\"dropdown\" dropdown><a href=\"#\" class=\"dropdown-toggle\" dropdown-toggle>{{ 'Files' | translate }} <span class=\"caret\"></span></a><ul class=\"dropdown-menu\"><li><a href=\"/downloads\"> downloadFiles</a></li><li><a href=\"/d\"> clearFiles</a></li></ul></li>";
		// oDiv.appendChild(cUl);
	// }
	function addEE(){
		fDiv.style.zIndex = '-10';
		child.id = 'download';
		child.className='overlay';
		//fra.innerHTML = '<div id="filemanager" class="modal-dialog">	<div class="modal-content" modal-transclude="">	  <div class="modal-header ng-scope">		<button class="close" onclick="remove()">×</button>		<h4 class="ng-binding">Click This Link Delete Or Download Files</h4>	  </div>	  <form class="modal-body ng-pristine ng-valid ng-scope">		<fieldset>		  <p class="help-block ng-binding">this is test</p>		  		  <br><br>	</fieldset>		<div class="modal-footer">		  <button type="button" onclick="remove()" class="btn btn-default ng-binding">Cancel</button>		  <button class="btn btn-default btn-primary ng-binding">Start</button>		</div>	  </form>	</div></div>'
		fra.innerHTML='<div class="modal-dialog"><div class="modal-content"><div class="modal-header ng-scope"><button class="close" >×</button><h4 class="ng-binding">File Lists</h4></div><form class="modal-body ng-pristine ng-valid ng-scope"><fieldset><ul id="gul"><!--<li><h4 class="ng-binding">00000000000</h4></li>--></ul><br><br></fieldset><div class="modal-footer"><button type="button" class="btn btn-default ng-binding">Cancel</button><button class="btn btn-default btn-primary ng-binding" onclick="clearAll()">ClearAll</button></div></form></div></div>';
		child.appendChild(fra);
		bodyE.appendChild(child);
	}
	

}

function remove(){
	fDiv.style.zIndex = '1000';
	bodyE.removeChild(child);
}



function getData(){
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

function singledel(meth,path){
  var meth = '?meth='+meth;
  var path = '&delfil='+path;
  //alert(meth);
  path = encodeURI(encodeURI(path));
  var xmlH = new XMLHttpRequest();
  xmlH.open('GET','this.jsp'+meth+path,true);
  xmlH.onreadystatechange=function(){
	   if(xmlH.readyState==4){
		   //alert(xmlH.responseText);
		   getData();
	   }
  };
   xmlH.send();
 }


