({
    getOpportunity : function(component) {
        
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
                    //  this.getColorMap(component);
                    this.createTab(component);
                }
            });
            $A.enqueueAction(action);
        } else {
            this.createTab(component);
        }
    },
    
    saveOpportunity: function(comp, event) {
        console.log('saveOpportunity');
        var opp = comp.get("v.opp");
        
        this.resetColor(comp);
        
        console.log("opp.SPO_ExteriorMaterial3__c", opp.SPO_ExteriorMaterial3__c);
        console.log("opp.SPO_ExteriorMaterialColor3__c", opp.SPO_ExteriorMaterialColor3__c);
        console.log("otherColorComment", opp.SPO_LiningColor1LocalComment__c);
        console.log("otherMaterialComment", opp.SPO_LiningMaterial1LocalComment__c);
        
        var action = comp.get("c.saveColor");
        action.setParams({
            "opportunity": comp.get("v.opp")
        });
        action.setCallback(this, function(a) {
            // comp.set("v.opp", a.getReturnValue());
            /* if (a.getState() == "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Color updated"
                });
                toastEvent.fire();
            }*/
        });
        $A.enqueueAction(action);
    },

    resetColor: function(component) {
        var opp = component.get("v.opp");
        
        if ($A.util.isEmpty(opp.SPO_ExteriorMaterial1__c)) {
            opp.SPO_ExteriorMaterialColor1__c = '';
            opp.SPO_ExtMaterialColor1localcomment__c = '';
        }
        
        if ($A.util.isEmpty(opp.SPO_ExteriorMaterial2__c)) {
            opp.SPO_ExteriorMaterialColor2__c = '';
            opp.SPO_ExtMaterialColor2localcomment__c = '';
        }
        
        /*if ($A.util.isEmpty(opp.SPO_ExteriorMaterial3__c)) {
            opp.SPO_ExteriorMaterialColor3__c = '';
            opp.SPO_ExtMaterialColor3localcomment__c = '';
        }*/
        
        if ($A.util.isEmpty(opp.SPO_LiningInteriorMaterial1__c)) {
            opp.SPO_LiningInteriorColor1__c = '';
            opp.SPO_LiningColor1LocalComment__c = '';
            //opp.SPO_LiningMaterial1LocalComment__c = '';
        }
        if ($A.util.isEmpty(opp.SPO_LiningInteriorMaterial2__c)) {
            opp.SPO_LiningInteriorColor2__c = '';
            opp.SPO_LiningColor2LocalComment__c = '';
            //opp.SPO_LiningMaterial2LocalComment__c = '';
        }
        
        if (opp.SPO_ExteriorMaterialColor1__c != 'OTHER') {
            //opp.SPO_ExteriorMaterial1localcomment__c = '';
            opp.SPO_ExtMaterialColor1localcomment__c = '';
        }
        if (opp.SPO_ExteriorMaterialColor2__c != 'OTHER') {
            //opp.SPO_ExteriorMaterial2localcomment__c = '';
            opp.SPO_ExtMaterialColor2localcomment__c = '';
        }
        if (opp.SPO_ExteriorMaterialColor3__c != 'OTHER') {
            //opp.SPO_ExteriorMaterial3localcomment__c = '';
            opp.SPO_ExtMaterialColor3localcomment__c = '';
        }
    }, 

    // init color tab
    createTab: function(component) {
        console.groupCollapsed('SO_OpportunityColorEdit.h.createTab');
        var opp = component.get("v.opp");
        console.log('createTab > opp', opp);
        console.log('createTab > opp.SPO_CreationType__c', opp.SPO_CreationType__c);
        
        // if (opp.SPO_CreationType__c) { // if not empty
            var type = component.get("v.type");
            console.log('createTab > type', type);
            
            if (type == 'EXTERIOR') {
                // workaround as we can't init this component on a inactive lightning:tab (possible with onactive but data is reset)
                if (component.find("extColor1") === undefined) {
                    $A.createComponent(
                        "c:SO_OpportunityColorPicker",
                        {
                            "aura:id": "extColor1",
                            "opportunity": opp,
                            "material": opp.SPO_ExteriorMaterial1__c,
                            "color": (opp.SPO_ExteriorMaterialColor1__c != null ? opp.SPO_ExteriorMaterialColor1__c.toUpperCase() : ''),
                            "otherColorComment": opp.SPO_ExtMaterialColor1localcomment__c,
                            "otherMaterialComment": opp.SPO_ExteriorMaterial1localcomment__c,
                            "type": "EXTERIOR1"
                        },
                        function(newComp, status, errorMessage){
                            if (status === "SUCCESS") {
                                //   var content = component.find("extColor1Tab");
                                //   console.log('content extColor1Tab', content);
                                //   content.set("v.body", newComp);
                                component.set("v.colorPickerExterior1", newComp);
                                
                            }
                            else {
                                console.log('failed! : ', errorMessage);
                            }
                        }
                    );
                    $A.createComponent(
                        "c:SO_OpportunityColorPicker",
                        {
                            "aura:id": "extColor2",
                            "opportunity": opp,
                            "material": opp.SPO_ExteriorMaterial2__c,
                            "color": (opp.SPO_ExteriorMaterialColor2__c != null ? opp.SPO_ExteriorMaterialColor2__c.toUpperCase() : ''),
                            "otherColorComment": opp.SPO_ExtMaterialColor2localcomment__c,
                            "otherMaterialComment": opp.SPO_ExteriorMaterial2localcomment__c,
                            "type": "EXTERIOR2"
                        },
                        function(newComp) {
                            component.set("v.colorPickerExterior2", newComp);
                            /*var content = component.find("extColor2Tab");
                            console.log('content extColor12Tab', content);
                            content.set("v.body", newComp);*/
                        }
                    );
                    /*$A.createComponent(
                        "c:SO_OpportunityColorPicker",
                        {
                            "aura:id": "extColor3",
                            "opportunity": opp,
                            "material": opp.SPO_ExteriorMaterial3__c,
                            "color":  (opp.SPO_ExteriorMaterialColor3__c != null ? opp.SPO_ExteriorMaterialColor3__c.toUpperCase() : ''),
                            "otherColorComment": opp.SPO_ExtMaterialColor3localcomment__c,
                            "otherMaterialComment": opp.SPO_ExteriorMaterial3localcomment__c,
                            "type": "EXTERIOR3"
                        },
                        function(newComp) {
                            component.set("v.colorPickerExterior3", newComp);
                            //var content = component.find("extColor3Tab");
                            //console.log('content extColor3Tab', content);
                            //content.set("v.body", newComp);
                        }
                    );*/
                }
            } else if (type == 'INTERIOR'){
                console.log('create interior colors');
                $A.createComponent(
                    "c:SO_OpportunityColorPicker",
                    {
                        "aura:id": "intColor1",
                        "opportunity": opp,
                        "material": opp.SPO_LiningInteriorMaterial1__c,
                        "color": (opp.SPO_LiningInteriorColor1__c != null ? opp.SPO_LiningInteriorColor1__c.toUpperCase() : ''),
                        "otherColorComment": opp.SPO_LiningColor1LocalComment__c,
                        "otherMaterialComment": opp.SPO_LiningMaterial1LocalComment__c,
                        "type": "INTERIOR1"
                    },
                    function(newComp) {
                        component.set("v.colorPickerInterior1", newComp);
                        /*var content = component.find("intColor1Tab");
                        console.log('content intColor1Tab', content);
                        content.set("v.body", newComp);*/
                    }
                );
                
                $A.createComponent(
                    "c:SO_OpportunityColorPicker",
                    {
                        "aura:id": "intColor2",
                        "opportunity": opp,
                        "material": opp.SPO_LiningInteriorMaterial2__c,
                        "color": (opp.SPO_LiningInteriorColor2__c != null ? opp.SPO_LiningInteriorColor2__c.toUpperCase() : ''),
                        "otherColorComment": opp.SPO_LiningColor2LocalComment__c,
                        "otherMaterialComment": opp.SPO_LiningMaterial2LocalComment__c,
                        "type": "INTERIOR2"
                    },
                    function(newComp) {
                        component.set("v.colorPickerInterior2", newComp);
                        //var content = component.find("intColor2Tab");
                        //console.log('content intColor2Tab', content);
                        //content.set("v.body", newComp);
                    }
                );
                
            }

            else {
                console.log('create interior colors');
                //$A.createComponent(
            }
        // }            
        console.groupEnd();
    },

    /*
    *injectComponent: function (name, target) {
        $A.createComponent(
            "c:SO_OpportunityColorPicker", 
            {
                "aura:id": "intColor2",
                "opportunity": opp,
                "material": opp.SPO_LiningInteriorMaterial2__c,
                "color": (opp.SPO_LiningInteriorColor2__c != null ? opp.SPO_LiningInteriorColor2__c.toUpperCase() : ''),
                "otherColorComment": opp.SPO_LiningColor2LocalComment__c,
                "otherMaterialComment": opp.SPO_LiningMaterial2LocalComment__c,
                "type": "INTERIOR2"
            }, 
            function (contentComponent, status, error) {
                if (status === "SUCCESS") {
                    target.set('v.body', contentComponent);
                } else {
                    throw new Error(error);
                }
            });
    },*/

    emptyColor : function(comp, colorNumber) {
        console.groupCollapsed('SO_OpportunityColorEdit.h.emptyColor');

        var content;
        
        var editType = comp.get("v.type");
        console.log('emptyColor > editType', editType);
        console.log('emptyColor > colorNumber', colorNumber);
        if (editType == 'EXTERIOR') {
            content = comp.find("selectedColor" + colorNumber);
        } else {
            content = comp.find("selectedInteriorColor" + colorNumber);
        }
        console.log('emptyColor > content', content);
        //var content = comp.find("selectedColor" + colorNumber);
        content.set("v.body", '');
        console.groupEnd();
    },
    
    createColorSelectedComponent : function(comp, event) {
        console.groupCollapsed('SO_OpportunityColorEdit.h.createColorSelectedComponent');

        var color = event.getParam("color");
        
        // create component or not (if material is set to null)
        if  ($A.util.isEmpty(color) === false) {
            
            //        var labelColor = (event.getParam("color") == "OTHER" ? event.getParam("material") + " " + event.getParam("color") : event.getParam("color"));
            var labelColor = (color.Name == "OTHER" ? event.getParam("material") + " " + color.Name : color.Name);
            
            /*        var labelColor;
        if (event.getParam("color") == "OTHER") {
            labelColor = event.getParam("material") + " > " + event.getParam("color");
        } else {
            labelColor = event.getParam("color");
        }*/
            // console.log('labelColor=' + labelColor);
            
            var colorNumber;
            var typeColor = event.getParam("type");
            if (typeColor == 'EXTERIOR1' || typeColor == 'INTERIOR1') {
                colorNumber = "1";
            } else if (typeColor == "EXTERIOR2" || typeColor == 'INTERIOR2') {
                colorNumber = "2";
            } else {
                colorNumber = "3";
            }
            
            $A.createComponents([
                ["c:SO_ColorPickerTile",{
                    "tileSize": "20",
                    "color": color.Name,
                    "colorUrl": (color.SPO_StaticResourceName__c != '' ? '/resource/SPO_' + color.SPO_StaticResourceName__c : ''),
                    "colorBackground": color.SPO_CodeCouleur__c,
                    "readOnly": "true"
                    //  "material" : event.getParam("material")
                }],
                ["ui:outputText",{
                    "value" : colorNumber + ": " + labelColor,
                    "class": "colorLabelSelected"
                }]
                /* TODO to add comments
            ["c:SO_OpportunityColorReadLabel", {
                "colorNumber": colorNumber,
                "material": event.getParam("material"),
                "color": event.getParam("color"),
                "commentMaterial": opp.SPO_ExteriorMaterial1localcomment__c, // to change
                "commentColor": opp.SPO_ExtMaterialColor1localcomment__c  // to change
            }]*/
        ],
                            function(newComps) {
                                var content;
                                
                                var editType = comp.get("v.type");
                                if (editType == 'EXTERIOR') {
                                    content = comp.find("selectedColor" + colorNumber);
                                } else {
                                    content = comp.find("selectedInteriorColor" + colorNumber);
                                }
                                //var content = comp.find("selectedColor" + colorNumber);
                                content.set("v.body", newComps[0]);
                                content.get("v.body").push(newComps[1]);
                            });
            
        }
        console.groupEnd();
    },
    
    // show/hide otherColorDiv
    toggleOtherComment: function(comp, event, helper) {        
        
        if (event.getParam("type") === comp.get("v.type")) {
            var otherColorDiv = comp.find("otherColorDiv");
            
            if (event.getParam("color") === 'OTHER') {
                $A.util.removeClass(otherColorDiv, "slds-hide");
            } else {
                $A.util.addClass(otherColorDiv, "slds-hide");
            }
        }
    },
    
})