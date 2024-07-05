({
    // send selected color tile to SO_OpportunityColorEdit component
    fireColorSelected: function(component) {
        console.groupCollapsed('SO_OpportunityColorPicker.h.fireColorSelected');

        console.log('fireColorSelected');
        
        var currentColor = component.get("v.currentColor");
        console.log('fierinf color: ', currentColor);
        
        //if ($A.util.isEmpty(currentColor) === false)  {
            var myEvent = component.getEvent("colorTileChange");
            //var myEvent = $A.get("e.c:SO_ColorPickerTileEvent");
            myEvent.setParams({
                //                "color": currentColor.Name,
                "color": currentColor,
                "colorUrl": ($A.util.isEmpty(currentColor) === false && currentColor.SPO_StaticResourceName__c != '' ? '/resource/SPO_' + currentColor.SPO_StaticResourceName__c : ''),
                "colorBackground": ($A.util.isEmpty(currentColor) === false ? currentColor.SPO_CodeCouleur__c : ''),
                "type": component.get("v.type"),
                "material": component.get("v.material")
                //channel: "ColorPicker"
            });
            myEvent.fire();
        //}

        console.groupEnd();
    },
    
    // send material to SO_OpportunityColorEdit component
    fireMaterial: function(component) {
        console.groupCollapsed('SO_OpportunityColorPicker.h.fireMaterial');

        console.log('fire material');
        // var material = component.get("v.material");

        //if ($A.util.isEmpty(material)) {
            component.set("v.currentColor", null);
            console.log("my color ",component.get("v.currentColor"));
            this.fireColorSelected(component);
        //}
        console.groupEnd();
    },
    
    // show/hide otherColorDiv
    toggleOtherComment: function(comp, event) {
        console.groupCollapsed('SO_OpportunityColorPicker.h.toggleOtherComment');

        var otherColorDiv = comp.find("otherColorDiv");
        
        if(comp.get("v.material") === 'Other (free text)') {
            $A.util.removeClass(otherColorDiv, "slds-hide");
        } else {
            console.log('comp.get("v.currentColor") ', comp.get("v.currentColor") );
            if (comp.get("v.currentColor.Name") === 'OTHER') {
                $A.util.removeClass(otherColorDiv, "slds-hide");
            } else {
                $A.util.addClass(otherColorDiv, "slds-hide");
            }
        }
        console.groupEnd();
    },
    
    fireOtherCommentEvent : function(component) {
        console.groupCollapsed('SO_OpportunityColorPicker.h.fireOtherCommentEvent');

        var myEvent = component.getEvent("otherCommentEvent");
        //console.log('myEvent', myEvent);
        //var myEvent = $A.get("e.c:SO_ColorPickerTileEvent");
        myEvent.setParams({
            "comment": component.get("v.otherColorComment"),
            "type": component.get("v.type")
            //channel: "ColorPicker"
        });
        myEvent.fire();
        console.groupEnd();
    },
    
    fireOtherMaterialCommentEvent : function(component) {
        console.groupCollapsed('SO_OpportunityColorPicker.h.fireOtherMaterialCommentEvent');

        console.log('fireOtherCommentEvent');
        var myEvent = component.getEvent("otherCommentEvent");
        console.log('myEvent', myEvent);
        //var myEvent = $A.get("e.c:SO_ColorPickerTileEvent");
        myEvent.setParams({
            "otherMaterialComment": component.get("v.otherMaterialComment"),
            "type": component.get("v.type")
            //channel: "ColorPicker"
        });
        myEvent.fire();
        console.groupEnd();
    },
    
    // http://www.sfdcmonkey.com/2017/02/18/dependent-picklist-fields-lightning-component/
    fetchPicklistValues: function(component, controllerField, dependentField) {
        console.groupCollapsed('SO_OpportunityColorPicker.h.fetchPicklistValues, controllerField, dependentField', controllerField, dependentField);
        // call the server side function  
        var action = component.get("c.getDependentOptionsImpl");
        // pass paramerters [object name , contrller field name ,dependent field name] -
        // to server side function 
        
        console.log('action', action);
        action.setParams({
            'objApiName': 'opportunity',//component.get("v.objInfo"),
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField
        });
        //set callback   
        action.setCallback(this, function(response) {
            console.groupCollapsed('SO_OpportunityColorPicker.c.getDependentOptionsImpl');

            if (response.getState() == "SUCCESS") {
                console.log('response', response);
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                
                // once set #StoreResponse to depnedentFieldMap attribute 
                // if (controllerField == 'SPO_LiningInteriorMaterial1__c') {
                console.log('StoreResponse', StoreResponse);
                component.set("v.depnedentFieldMap", StoreResponse);
                //}
                // component.set(attributeMap, StoreResponse);
                
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on ui field. 
                
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for ui:inputSelect  
                /*if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: "--- None ---"
                    });
                }*/
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push({
                        class: "optionClass",
                        label: listOfkeys[i],
                        value: listOfkeys[i].toUpperCase()
                    });
                }
                // set the ControllerField variable values to country(controller picklist field)
                //                component.find('color').set("v.options", ControllerField);
                
                // init color tiles if material is already defined
                var material = component.get("v.material");
                console.log('material', material);
                //console.log('material=' + material);
                if (material !== '') {
                    var Map = component.get("v.depnedentFieldMap");
                    //console.log('Map=' + Map);
                    var ListOfDependentFields = Map[material];
                    //console.log('ListOfDependentFields=' + ListOfDependentFields);
                    this.fetchDepValues(component, ListOfDependentFields);                    
                }
            }
            console.groupEnd();
        });
        action.setStorable();
        $A.enqueueAction(action);
        console.groupEnd();
    },
    
    // http://www.sfdcmonkey.com/2017/02/18/dependent-picklist-fields-lightning-component/
    fetchDepValues: function(component, ListOfDependentFields) {
        console.groupCollapsed('SO_OpportunityColorPicker.h.fetchDepValues');
        // create a empty array var for store dependent picklist values for controller field)  
        var dependentFields = [];
        //console.log('fetchDepValues > ListOfDependentFields', ListOfDependentFields);
        if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
            /*dependentFields.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });*/
            
            for (var i = 0; i < ListOfDependentFields.length; i++) {
                dependentFields.push({
                    class: "optionClass",
                    label: ListOfDependentFields[i],
                    value: ListOfDependentFields[i]
                });
            }
        }
        //console.log('fetchDepValues > dependentFields=' + dependentFields);
        // set the dependentFields variable values to State(dependent picklist field) on ui:inputselect    
        //        component.find('color').set("v.options", dependentFields);
        //component.set("v.colorList", ListOfDependentFields);
        
        //console.log('getPictoColorList.ListOfDependentFields=' + ListOfDependentFields);
        // get picto from SPO_Colors__c object
        var action = component.get("c.getPictoColorList");
        action.setParams({
            'colorListNames': ListOfDependentFields
        });
        action.setCallback(this, function(response) {
            console.groupCollapsed('SO_OpportunityColorPicker.c.getPictoColorList');

            if (response.getState() == "SUCCESS") {
                var StoreResponse = response.getReturnValue();

                //console.log('StoreResponse', StoreResponse);

                // Add OTHER tile
                if (StoreResponse.length > 0 || (ListOfDependentFields != undefined && ListOfDependentFields[0] == "Other (free text)")) {
                    StoreResponse.push({
                        "Name": "OTHER"
                    });
                }
                //console.log('StoreResponse', StoreResponse);
                component.set("v.colorList", StoreResponse);
                var tileListSize;
                if(StoreResponse.length == 2 && (StoreResponse[0].Name == "OTHER" || StoreResponse[1].Name == "OTHER")) {
                    tileListSize = 1;
                    component.set("v.colorList", []);
                    if(StoreResponse[0].Name == "OTHER")
                        component.set("v.currentColor",StoreResponse[1]);
                    else
                        component.set("v.currentColor",StoreResponse[0]);
                    this.fireColorSelected(component);


                }else {
                    // get SPO_Colors__c of current color
                    tileListSize = StoreResponse.length;
                    this.setCurrentSPOColor(component, StoreResponse);
                }

                console.log('before fire ', tileListSize);
                var myEvent = component.getEvent("colorTileListSize");
                myEvent.setParams({
                    "colorTileListSize": tileListSize,
                    "type" : component.get('v.type')
                });
                myEvent.fire();

            } else {
                console.log('result KO'); 
            }
            console.groupEnd();
        });
        action.setStorable();
        $A.enqueueAction(action);
        console.groupEnd();
    },
    
    // get SPO_Colors__c of current color
    setCurrentSPOColor: function(component, StoreResponse) {
        console.groupCollapsed('SO_OpportunityColorPicker.h.setCurrentSPOColor');

        var currentColor = component.get("v.color");
        console.log('currentColor', currentColor);
        console.log('StoreResponse[currentColor]', StoreResponse[currentColor]);
        if (currentColor !== '') {
            for (var singlekey in StoreResponse) {
                if (StoreResponse[singlekey].Name === currentColor) {
                    console.log('StoreResponse[singlekey]', StoreResponse[singlekey]);
                    component.set("v.currentColor", StoreResponse[singlekey]);
                    this.fireColorSelected(component);
                    
                    //this.showColorSelected(component, currentColor);
                }
            }
        }
        console.groupEnd();
    },
    
    // http://www.sfdcmonkey.com/2017/02/18/dependent-picklist-fields-lightning-component/
    fetchMaterialPicklistValues: function(component, controllerField, dependentField) {
        console.groupCollapsed('SO_OpportunityColorPicker.h.fetchMaterialPicklistValues');
        
        // call the server side function  
        var action = component.get("c.getDependentOptions");
        // pass paramerters [object name , contrller field name ,dependent field name] -
        // to server side function 
        var creationType = component.get("v.opportunity").SPO_CreationType__c;
        var isExo = component.get("v.opportunity").SPO_Exo__c;
        var type = component.get("v.type");

        if (!creationType){
            creationType = 'Soft';
        }
        action.setParams({
            'objApiName': 'opportunity',
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField,
            'contrFieldValue': creationType
        });
        //set callback
        action.setCallback(this, function(response) {
            console.groupCollapsed('SO_OpportunityColorPicker.c.getDependentOptions');
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                var ControllerField = []; // for store controller picklist value to set on ui field. 
                
                //no empty value
                /*ControllerField.push({
                    class: "optionClass",
                    label: "--Material--",
                    value: ""
                    //disabled: true
                });*/
                
                // play a for loop on Return map 
                for (var singlekey in StoreResponse) {
                    //no "other" material for outdise - MIY-779
                    if(type.indexOf("INTERIOR") == -1 && StoreResponse[singlekey] == 'Other (free text)') {
                        continue;
                    }else{
                        if(dependentField == "SPO_ExteriorMaterial1__c"){
                            if (isExo == "Yes" && StoreResponse[singlekey].includes("(Exo)")){
                                ControllerField.push({
                                    class: "optionClass",
                                    label: StoreResponse[singlekey],
                                    value: StoreResponse[singlekey]
                                });
                            }else if (isExo == "No" && !StoreResponse[singlekey].includes("(Exo)")){
                                ControllerField.push({
                                    class: "optionClass",
                                    label: StoreResponse[singlekey],
                                    value: StoreResponse[singlekey]
                                });
                            }else if(isExo == ""){
                                ControllerField.push({
                                    class: "optionClass",
                                    label: StoreResponse[singlekey],
                                    value: StoreResponse[singlekey]
                                });
                            }
                        }else{
                            ControllerField.push({
                                class: "optionClass",
                                label: StoreResponse[singlekey],
                                value: StoreResponse[singlekey]
                            });
                        }
                    }
                    
                }
                
                // set the ControllerField variable values to country(controller picklist field)
                //component.find('material').set("v.options", ControllerField);
                var mat = component.find('material');
                console.log('mat', mat);
                mat.set("v.options", ControllerField);
                
                /*var material = component.get("v.material");
                if ($A.util.isUndefined(material)) {
                    component.set("v.material", ControllerField[0]);
                }*/

                console.log('end');
            }
            console.groupEnd();
        });
        action.setStorable();
        $A.enqueueAction(action);
        console.groupEnd();
    },

    initInteriorMaterial : function(component){
        var material = component.get("v.material");
        var isExo = component.get("v.opportunity").SPO_Exo__c;
        if (!material && (isExo == "No" || isExo == "")){
            component.set("v.material", "Microfibre");
        }else if (!material && isExo == "Yes"){
            component.set("v.material", "Chevre");
        }
    }
})