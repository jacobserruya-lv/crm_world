({
	doInit : function (component, event, helper){
		helper.initSessionID(component);

		var opp = component.get("v.opp");
		if (opp && opp.Id){
			var category = component.get("v.category");

			var files = helper.getFiles(component, category, opp);
			component.set("v.filesList", files);
		}
	},

	handleFilesChange : function(component, event, helper) {
		var files = event.getSource().get("v.files");// this is the old code of Romain
        //var files = event.getSource().get("v.fileIds");
		console.log("files in SO_OppSPAAttachmentCtrl " + files);

		helper.saveFiles(component, files);
	},
    
    deleteFile : function(component, event, helper){
       	//var globalId = component.getGlobalId();
       	/* var target = event.target;
        console.log("----Target");
        console.log(target);
        var index = target.getAttribute("data-index");
        console.log("------Index Controller:");
        console.log(index);*/
        
        var index = event.target.dataset.index;
        console.log(index);   
        
        helper.deleteFile(component, index);
    },

    // function not possible as the opportunity is inserted at the end of the process and the file must be related to the opportunity
     /* openSingleFile: function(cmp, event) {
        var target = event.target;
        var index = target.getAttribute("data-index");
        console.log("index", index);
        
        var file = cmp.get("v.files")[index];
        console.log("cmp.get(v.files)", cmp.get("v.files"));

        if (file.contentDocumentId) {
            $A.get('e.lightning:openFiles').fire({
                recordIds: [file.contentDocumentId]
            });
        }
    }*/
})