({
    getOpportunity : function(component) {

        if ($A.util.isEmpty(component.get("v.opp"))) {
            var recId =  component.get("v.recordId");

            if (recId) {
                var action = component.get("c.findById");
                action.setParams({
                    "oppId": recId
                });
                action.setCallback(this, function(a) {
                    var state = a.getState();
                    if (state === "SUCCESS") {
                        var result = a.getReturnValue();
                        component.set("v.opp", result);
                        component.set("v.isMTO", result.SPO_OrderType__c == "MTO on Catalog (Hardsided)");

                        this.showColorPanel(component);
                        //this.getColorMap(component);
                        //this.createTab(component, result);
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    
    showColorPanel: function(component) {
        var opp = component.get("v.opp");
        if (opp.SPO_ProductCategory__c === "Leather goods") {
            //var toggleText = component.find("showColor");
            //$A.util.removeClass(toggleText, 'toggle');
            
            this.onModeChanged(component);
        }
    },
    
    onModeChanged: function(component) {
        var readDiv = component.find("readDiv");
        var editInteriorDiv = component.find("editInteriorDiv");
        var editExteriorDiv = component.find("editExteriorDiv");
        //var editMaterialDiv = component.find("editMaterial");
        
        var mode = component.get("v.mode");
        var type = component.get("v.type");

        console.log("mode", mode);
        if (mode === "edit") {
            $A.util.addClass(readDiv, 'toggle');
            
            if (type === "editInterior") {
                $A.util.removeClass(editInteriorDiv, 'toggle');
                $A.util.addClass(editExteriorDiv, 'toggle');
            } else if (type === "editExterior") {
                $A.util.removeClass(editExteriorDiv, 'toggle');
                $A.util.addClass(editInteriorDiv, 'toggle');                
            } 
            // else if (type === "editMaterial") {
            //     $A.util.removeClass(editMaterialDiv, 'toggle');
            //     //$A.util.addClass(editMaterialDiv, 'toggle');                
            // }
//            $A.util.removeClass(editDiv, 'toggle');            
        } else {
            $A.util.addClass(editInteriorDiv, 'toggle');            
            $A.util.addClass(editExteriorDiv, 'toggle');
            //$A.util.addClass(editMaterialDiv, 'toggle');              
            $A.util.removeClass(readDiv, 'toggle');            
        }
    }
})