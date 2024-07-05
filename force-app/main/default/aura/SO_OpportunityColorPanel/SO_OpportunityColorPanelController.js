({
    doInit: function(component, event, helper) {
        // hide div
        //var showColorPanel = component.find("showColor");
        //$A.util.addClass(showColorPanel, 'toggle');

        var readDiv = component.find("readDiv");
        $A.util.addClass(readDiv, 'toggle');

        var editInteriorDiv = component.find("editInteriorDiv");
        $A.util.addClass(editInteriorDiv, 'toggle');

        var editExteriorDiv = component.find("editExteriorDiv");
        $A.util.addClass(editExteriorDiv, 'toggle');

        // var editMaterialDiv = component.find("editMaterialDiv");
        // $A.util.addClass(editMaterialDiv, 'toggle');

        helper.getOpportunity(component);
    },
    
    onEditEvent: function(component, event, helper) {
        var action = event.getParam("action");
        console.log("$$$$ Action :" + JSON.stringify(action));
        if (action == "cancel") {
            component.set("v.mode", "read");
            /*// hide Edit mode
            var editCard = cmp.find("edit");
            $A.util.addClass(editCard, "slds-hide");

            // show Read mode
            var readCard = cmp.find("read");
            $A.util.removeClass(readCard, "slds-hide");*/
        } else if (action == 'editExterior') {
            component.set("v.mode", "edit");
            component.set("v.type", "editExterior");
        } else if (action == 'editInterior') {
            console.log('edit interior');
            component.set("v.mode", "edit");
            component.set("v.type", "editInterior");
        // } else if(action='editMaterial'){
        //     console.log('edit Meterial');
        //     component.set("v.mode", "edit");
        //     component.set("v.type", "editMaterial");
        // 
        }
        else if (action == 'save') {
            console.log('save');
            component.set("v.mode", "read");

            // refresh all related components
            $A.get('e.force:refreshView').fire();
            //helper.getOpportunity(component);
            
            /*var opp = component.get("v.opp");
            var myEvent = $A.get("e.ltng:selectSObject");
            myEvent.setParams({"recordId": opp.Id});//, channel: "Opportunity"});
            myEvent.fire();*/
        }
        helper.onModeChanged(component);
    }
})