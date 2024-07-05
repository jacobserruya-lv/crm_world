({
	doInit : function(component, event, helper) {
        helper.getContentFile(component);
	},
     
    openEditModal: function(component, event, helper) {
        var modalBody;
    	$A.createComponents([
        	["c:FileContentEdit",{
                'recordId' : component.get("v.recordId"),
            	'fileContent' : component.get("v.fileContent"),
                 refreshChildComponent: component.getReference("c.doInit")
            }]
    	],
    	function(components, status){
        	if (status === "SUCCESS") {
            	modalBody = components[0];
            	component.find('overlayLib').showCustomModal({
                    header: "Edit File",
               		body: modalBody
           		})
        	}
    	});
    }

})