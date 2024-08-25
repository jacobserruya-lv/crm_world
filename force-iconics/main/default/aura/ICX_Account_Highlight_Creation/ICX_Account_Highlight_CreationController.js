({
    doInit: function(component, event, helper) {
        //var editComponent = component.find("edit2");

       // var buttonComponent = component.find("buttonComponent");
       // buttonComponent.set("v.parent", editComponent);
        
		/*var modalBody, modalFooter;
        
        
		$A.createComponents([
			["c:ICX_Account_Highlight_Edit_Buttons",{}]
			],
			function(components, status){
				if(status==="SUCCESS"){
					modalFooter = components[0];
					modalFooter.set("v.parent", editComponent);
				}
			}
		)*/
    },

    handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        //component.find("overlayLib").notifyClose();
        console.log("Cancel");
        helper.closeTab(component, event);
    },
    handleOK : function(component, event, helper) {
        try {

            helper.showSpinner(component);

            var edit2 = component.find("edit2");
            edit2.save(function(result, err) {
                //    edit2.save( $A.getCallback(function(result,error){
                console.log("callback for aura:method was executed");
                console.log("result: " + result);
                console.log("err: " + err);
                if (!$A.util.isEmpty(result)) {
                    helper.openNewRecordAndCloseExistingTab(component, result);
                }
                helper.hideSpinner(component);
            });
        } catch (e) {
            console.log("err: " + e);
            helper.hideSpinner(component);
        }

        //if(!$A.util.isEmpty(component.get("v.parent"))){
		//	component.get("v.parent").save();
		//}
    }
})