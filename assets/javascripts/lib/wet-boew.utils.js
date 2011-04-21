/* Web Experience Toolkit (WET) / Boîte à outils de l'expérience Web (BOEW)
Terms and conditions of use: http://tbs-sct.ircan.gc.ca/projects/gcwwwtemplates/wiki/Terms
Conditions régissant l'utilisation : http://tbs-sct.ircan.gc.ca/projects/gcwwwtemplates/wiki/Conditions
*/

//parseUri 1.2.2
// (c) Steven Levithan <stevenlevithan.com>
// MIT License

function parseUri(str)
{
    var o = parseUri.options,
        m = o.parser[o.strictMode ? "strict" : "loose"].exec(str),
        uri =
        {
        },
        i = 14;

    while (i--) uri[o.key[i]] = unescape(m[i]) || "";

    uri[o.q.name] =
    {
    };
    uri[o.key[12]].replace(o.q.parser, function ($0, $1, $2)
    {
        if ($1) uri[o.q.name][$1] = $2;
    });

    return uri;
};

parseUri.options =
{
    strictMode: false,
    key: ["source", "protocol", "authority", "userInfo", "user", "password", "host", "port", "relative", "path", "directory", "file", "query", "anchor"],
    q: {
        name: "queryKey",
        parser: /(?:^|&)([^&=]*)=?([^&]*)/g
    },
    parser: {
        strict: /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/,
        loose: /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/
    }
};

/** 
 * 
 * 
 * **/

var Utils =
{
    getLibraryPath: function ()
    {
        return PE.liblocation + "lib";
    },
    getSupportPath: function ()
    {
        return PE.liblocation + "support";
    },
    getPluginsPath: function ()
    {
        return PE.liblocation + "plugins";
    },
    loadParamsFromScriptID: function (name)
    {
        var parameters = parseUri(jQuery("script[id='wet-boew_plugin_" + name + "']").attr('src')).queryKey;
        return parameters;
    },
    // Defect #864 - Workaround suggested - Dave Schindler 
    addCSSSupportFile: function (pathtofile)
    {
        var $link = jQuery('<link rel="stylesheet" href="' + pathtofile + '" type="text/css" media="screen" />').appendTo('head');
        // See http://www.subchild.com/2010/05/20/cross-browser-problem-with-dynamic-css-loading-with-jquery-1-4-solved/
        $link.attr(
        {
            href: pathtofile,
            rel: 'stylesheet',
            type: 'text/css',
            media: 'screen'
        });

    },
    addIECSSSupportFile: function(pathtofile, version)
    {
	    var condition="";
	    if (version == null){
		    condition="IE";
	    }else if(version <= 6){
		    condition="lte IE 6";
	    }else if (version > 6){
		    condition = "IE " + version;
	    }
	    
	    if (condition != ""){
		    document.write('<!--[if ' + condition + ']><link rel="stylesheet" href="' + pathtofile + '" type="text/css" media="screen" /><![endif]-->');
	    }
    },
    addKeyboardBindingToPlugin: function (objec, keyboardaction, keyboardsequence, func)
    {
        objec.focus(function ()
        {
            objec.bind(keyboardaction, keyboardsequence, func);
        });
    },
    getPageLanguage: function ()
    {
        //return jQuery("meta[name='dc.language']").attr('content');
        return PE.language;
    },
    /**
     * Preloader function for jQuery [http://engineeredweb.com/blog/09/12/preloading-images-jquery-and-javascript]
    */
    preLoadImages: function() {
        for(var i = 0; i<arguments.length; i++)
        {
          jQuery("<img>").attr("src", arguments[i]);
        }
      },
     
     hasFlash : function() {
 
     	var pv = Utils.playerVersion().match(/\d+/g);
     	var rv = String([arguments[0], arguments[1], arguments[2]]).match(/\d+/g) || String(Utils.pluginOptions.version).match(/\d+/g);
     	for(var i = 0; i < 3; i++) {
     		pv[i] = parseInt(pv[i] || 0);
     		rv[i] = parseInt(rv[i] || 0);
     		// player is less than required
     		if(pv[i] < rv[i]) return false;
     		// player is greater than required
     		if(pv[i] > rv[i]) return true;
     	}
     	// major version, minor version and revision match exactly
     	return true;
     },
     
     /** Baseline Options incase none were set for flash player settings **/
     pluginOptions : {
     	expressInstall: false,
     	update: true,
     	version: '8.0.0' // Default base line for GoC
     },
     
     playerVersion : function() {
     	// ie
     		try {
     			try {
				// avoid fp6 minor version lookup issues
				// see: http://blog.deconcept.com/2006/01/11/getvariable-setvariable-crash-internet-explorer-flash-6/
				var axo = new ActiveXObject('ShockwaveFlash.ShockwaveFlash.6');
				try { axo.AllowScriptAccess = 'always';	} 
				catch(e) { return '6,0,0'; }				
     			} catch(e) {}
     				return new ActiveXObject('ShockwaveFlash.ShockwaveFlash').GetVariable('$version').replace(/\D+/g, ',').match(/^,?(.+),?$/)[1];
     			// other browsers
     			} catch(e) {
     				try {
     					if(navigator.mimeTypes["application/x-shockwave-flash"].enabledPlugin){
     						return (navigator.plugins["Shockwave Flash 2.0"] || navigator.plugins["Shockwave Flash"]).description.replace(/\D+/g, ",").match(/^,?(.+),?$/)[1];
     				    }
     			 } catch(e) {}		
     		 }
     	return '0,0,0';
     }

};