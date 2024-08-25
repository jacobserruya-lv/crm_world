({
	doInit : function(component, event, helper) {
        helper.getVisualforceHost(component, event);
        helper.handleDownload(component, event);
	},

    sendToVF : function(component, event, helper) {
        console.log("sendToVFItem");
    	
        var vfOrigin = "https://" + component.get("v.vfHost");
       // console.log("component.find(vfFrame).getElement()", component.find("vfFrame").getElement());
        var vfWindow = component.find("vfFrame").getElement().contentWindow;

        var base64 = component.get("v.base64");
        console.log("base64", base64);
        /* component.find("navigationService").navigate({ 
                    type: "standard__webPage", 
                    attributes: { 
                        url: 'data:application/pdf;base64,' + documentList[i].binaryDocList[j] 
                    } 
                });*/
        //window.location.href = 'data:application/pdf;base64,' + documentList[i].binaryDocList[j];
        var message = {
            base64 : base64,
            fileName : component.get("v.fileName")
        };
        vfWindow.postMessage(message, vfOrigin);
    },
    
    /*handleDownload : function(component, event, helper) {
        console.log("handleDownload");
        var data = component.get("v.base64");
        var blob = new Blob([data], {type: "application/pdf"});
        var url = window.URL.createObjectURL(blob);
        var oURL = component.find("oURL");
        oURL.set("v.value", url);
        oURL.set("v.label", url);    	
    },*/
})