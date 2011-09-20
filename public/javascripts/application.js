function focus(n)
{
  var e = document.getElementById(n);
  if (e != null) {
    e.select();
  	e.focus();
  }
}

function populate_login(link) {
	document.getElementsByName("login")[0].value=link.innerHTML;
	document.getElementsByName("password")[0].value=link.innerHTML+"123";
}

function fixPNGs(id, img) {
	if(navigator.appVersion.toLowerCase().indexOf("msie 6") > 0) {
		var images = new Array();
		images = document.getElementsByTagName("img");
		var numImages = images.length;
		for(var i=0; i<numImages; i++)
		{
			if(images[i].src.toLowerCase().indexOf(".png")==-1 ) { continue; }
			if(images[i].width==0 || images[i].height==0) { continue; }
			images[i].style.cssText="width:"+images[i].width+"px;height:"+images[i].height+"px;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+images[i].src+"', sizingMethod=scale);";
			images[i].src="images/s.gif";
		}
	}
}