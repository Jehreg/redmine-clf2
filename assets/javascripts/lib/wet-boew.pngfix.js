/* Web Experience Toolkit (WET) / Boîte à outils de l'expérience Web (BOEW)
Terms and conditions of use: http://tbs-sct.ircan.gc.ca/projects/gcwwwtemplates/wiki/Terms
Conditions régissant l'utilisation : http://tbs-sct.ircan.gc.ca/projects/gcwwwtemplates/wiki/Conditions
*/
/**
*    PNGFix - To allow for IE 5.5 + to show proper transparency for png's
*    Note :: Increased the fix to encompass all page png's
**/
var PngFix = {
		
	pnglocation : Utils.getSupportPath()+"/pngfix/inv.gif" ,
	
	isOlderIE: (/MSIE ((5\.5)|6)/.test(navigator.userAgent) && navigator.platform == "Win32"),

	init : function() {
		// Replace gif with png
	       	$('img.pngfix').each(function() {
	       	jQuery(this).attr('src',jQuery(this).attr('src').substring(0,jQuery(this).attr('src').lastIndexOf('.')) + '.png');
	       });	 
	   },
	helpIe : function() { $('img.pngfix').each(function() { PngFix.fixPng(this); }); },	   		
	fixPng : function(png) {
   		// get src
   		var src = png.src;
   		// replace by blank image
   		png.onload = function() { };
   		png.src = this.pnglocation;
   		// set filter (display original image)
   		png.runtimeStyle.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + src + "',sizingMethod='scale')";
 	}
};

/**
* Requested Background Image Cache fix
*  Defect - Défaut #1073 [http://tbs-sct.ircan.gc.ca/issues/1073?lang=eng]
*/
var ieOptimzier = {
	optimize: function() {
		try { document.execCommand("BackgroundImageCache",false,true); } catch(err) {}
	}
};

/**
 *  Absolute position fix - ie 6
 ***************************************/
 /*
 var ie6CSSTweak = {
    tweakgap : function(){
		$('#cn-right-col-gap').css('right',0).css('margin-right',$('#cn-right-col-gap').offset().left - $('#cn-right-col').offset().left);
    },
    tweakheight : function(){
		$('#cn-foot').css('height',$('#cn-foot-inner').height()).css('padding-bottom',$('#cn-body-inner-3col').css('border-width')).css('position','relative');
		$("#cn-left-col-gap, #cn-centre-col-gap, #cn-right-col-gap").css('height',($('#cn-foot').offset().top - $('#cn-left-col-gap').offset().top));
	}
 }*/
 
 
 
var overFlowFix = {
	
	maxLeftWidth: 0,
	maxCentreWidth: 0,
	maxRightWidth: 0,
	
	stabilize: function() {
		
		// Figure out the maxWidths for each of the columns
		if ($('#cn-body-inner-1col').length > 0) this.maxCentreWidth = $('#cn-centre-col').width();
		else this.maxCentreWidth = $('#cn-centre-col-gap').width() - ($('#cn-centre-col-inner').outerWidth() - $('#cn-centre-col-inner').width());
		if ($('#cn-left-col').length > 0) this.maxLeftWidth = $('#cn-left-col-gap').width();
		if ($('#cn-right-col').length > 0) this.maxRightWidth = $('#cn-right-col-gap').width();
		
		// Fix left column if it has been stretched
		if ( this.maxLeftWidth > 0 && $('#cn-left-col').outerWidth() > this.maxLeftWidth) {
			this.adjust($('#cn-left-col'), this.maxLeftWidth);
			$('#cn-left-col').css('overflow-x','visible');
		}		
		// Fix centre column if it has been stretched
		if ($('#cn-centre-col-inner').outerWidth() > $('#cn-centre-col-gap').width()) {
			this.adjust($('#cn-centre-col-inner'), this.maxCentreWidth);
			$('#cn-centre-col').css('overflow-x','visible');
		}
		// Fix right column if it has been stretched
		if (this.maxRightWidth > 0 && $('#cn-right-col').outerWidth() > this.maxRightWidth) {
			this.adjust($('#cn-right-col'), this.maxRightWidth);
			$('#cn-right-col').css('overflow-x','visible');
		}
	},
	adjust: function(container, maxWidth) {
		var fixesNeeded = false;
		var actualHeight = 0;
		
		// Allow each top-level element that is wider than maxWidth to overflow the container
		container.children().each(function() {
			if ($(this).innerWidth() > maxWidth) {
				if (!overFlowFix.adjust($(this), maxWidth)) {
					actualHeight = (Math.round((($(this).outerHeight(true))/16)*Math.pow(10,1))/Math.pow(10,1));
					$(this).css('position', 'absolute').wrap('<div style="width: ' + (maxWidth - 8) + 'px; height: ' + actualHeight + 'em;"></div>');
				}
				fixesNeeded = true;
			}
		});
		return fixesNeeded;
	}
}
/**
 *  PngFix Runtime
 **/

$("document").ready(function(){   
	
	PngFix.init(); 	
	
	if(PngFix.isOlderIE) {
	  PngFix.helpIe();
	  overFlowFix.stabilize();
	  ieOptimzier.optimize();
	  
	  /*ie6CSSTweak.tweakheight();
	  ie6CSSTweak.tweakgap();*/
	}
});