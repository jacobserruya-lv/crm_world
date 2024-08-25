({
    doInit : function(component, event, helper) {
        helper.getVisualforceHost(component, event);
    },

    copyScript : function(component, event, helper) {
		var scriptText = component.get("v.message");
        
        // https://stackoverflow.com/questions/400212/how-do-i-copy-to-the-clipboard-in-javascript
        var textArea = document.createElement("textarea");
        textArea.value = scriptText;
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();

        /* Copy the text inside the text field */
        document.execCommand("copy");

        try {
            var successful = document.execCommand('copy');
            var msg = successful ? 'successful' : 'unsuccessful';
            console.log('Fallback: Copying text command was ' + msg);
        } catch (err) {
            console.error('Fallback: Oops, unable to copy', err);
        }

        document.body.removeChild(textArea);

	},

    sendToVF : function(component, event, helper) {
        console.log("sendToVFItem");
        
        // TODO if 2 lines => KO. How to get dynamic iframe height in Lightning? Ok for Visualforce but KO for Lightning OR send a message from the Visualforce to Lightning 
        /*var iframe = component.find('vfFrame').getElement();
        console.log("iframe.scrollHeight", iframe.scrollHeight);
        console.log("iframe.clientHeight", iframe.clientHeight);
        console.log("iframe.scrollTop", iframe.scrollTop);
        console.log("iframe.offsetHeight", iframe.offsetHeight);
        
        var iframe2 = component.find('vfFrame');
        console.log("iframeee", iframe2);
        console.log("iframe2", iframe2.scrollHeight);
        console.log("scroll", document.scrollingElement.scrollHeight);*/
       // div.scrollTop === (div.scrollHeight - div.offsetHeight

        
       // iframe.style.height = iframe.contentWindow.document.body.scrollHeight + 'px';
        //iframe.style.height = iframe.contentWindow.scrollHeight + 'px';

        //iframe.style.height = iframe.contentWindow.document.body.scrollHeight + 'px';

    	
       /* var vfOrigin = "https://" + component.get("v.vfHost");
        var vfWindow = component.find("vfFrame").getElement().contentWindow;

        var message = {
            language : component.get("v.language"),
            customLabel : 'ICX_CaseFromTaskModalTitle'//component.get("v.message")
        };
        vfWindow.postMessage(message, vfOrigin);*/
    },

	/*onLanguageChanged : function(component, event, helper) {
        console.log("onLanguageChanged");
    	
       // helper.changeIframeUrl(component, event);
    },*/
})