({
	myAction : function(component, event, helper) {
		
	},
    init: function(component, event, helper) {
       document.title = "LV Online Appointments";

       var meta = document.createElement("meta");
       var meta2 = document.createElement("meta");
       var meta3 = document.createElement("meta");
       var meta4 = document.createElement("meta");
    //    var meta5 = document.createElement("link");
    //    var meta6 = document.createElement("link");
    //    var meta7 = document.createElement("link");
    //    var meta8 = document.createElement("link");
       meta.setAttribute("name", "viewport");
       meta2.setAttribute("name", "apple-mobile-web-app-capable");
       meta3.setAttribute("name", "apple-mobile-web-app-status-bar-style");
       meta4.setAttribute("name", "apple-mobile-web-app-title");
    //    meta5.setAttribute("rel", "manifest");
    //    meta6.setAttribute("rel", "apple-touch-icon");
    //    meta7.setAttribute("rel", "mask-icon");
    //    meta8.setAttribute("rel", "preload");
       meta.setAttribute("content", "width=device-width, initial-scale=1");
       meta2.setAttribute("content", "yes");
       meta3.setAttribute("content", "black");
       meta4.setAttribute("content", "vuejs-with-salesforce");
    //    meta5.setAttribute("href", "./static/manifest.json");
    //    meta6.setAttribute("href", "/static/img/icons/apple-touch-icon-152x152.png");
    //    meta7.setAttribute("href", "/static/img/icons/safari-pinned-tab.svg");
    //    meta8.setAttribute("href", "/app.js");
    //    meta8.setAttribute("as", "script");
       document.getElementsByTagName('head')[0].appendChild(meta);
       document.getElementsByTagName('head')[0].appendChild(meta2);
       document.getElementsByTagName('head')[0].appendChild(meta3);
       document.getElementsByTagName('head')[0].appendChild(meta4);
    //    document.getElementsByTagName('head')[0].appendChild(meta5);
    //    document.getElementsByTagName('head')[0].appendChild(meta6);
    //    document.getElementsByTagName('head')[0].appendChild(meta7);

    }
})