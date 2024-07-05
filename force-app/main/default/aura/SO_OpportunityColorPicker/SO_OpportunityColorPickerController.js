({
    doInit: function (component, event, helper) {
        console.groupCollapsed('SO_OpportunityColorPicker.doInit');
        var type = component.get('v.type');
        if (type.indexOf('INTERIOR') > -1) {
            helper.fetchMaterialPicklistValues(component, 'SPO_CreationType__c', 'SPO_LiningInteriorMaterial1__c');
            helper.fetchPicklistValues(component, 'SPO_LiningInteriorMaterial1__c', 'SPO_LiningInteriorColor1__c');
            helper.initInteriorMaterial(component);
        } else {
            helper.fetchMaterialPicklistValues(component, 'SPO_CreationType__c', 'SPO_ExteriorMaterial1__c');
            helper.fetchPicklistValues(component, 'SPO_ExteriorMaterial1__c', 'SPO_ExteriorMaterialColor1__c');
        }
        console.groupEnd();
    },

    onColorSelected: function (component, event, helper) {
        console.groupCollapsed('SO_OpportunityColorPicker.onColorSelected');

        var selectedItem = event.currentTarget; // Get the target object
        var index = selectedItem.dataset.index; // Get its value i.e. the index

        var colorSelected = component.get('v.colorList')[index];
        console.log('colorSelected2', colorSelected);
        // use for CSS (color selected style)
        component.set('v.currentColor', colorSelected);

        helper.fireColorSelected(component);
        helper.toggleOtherComment(component, event);

        /*var divList = component.find("main").find({instancesOf: "c:SO_ColorPickerTile"});
        divList.forEach(function(cmp) {
            var div = cmp.find("tileDiv");
            if (cmp.get("v.color") === colorSelected) {
				$A.util.addClass(div, "select");
                component.set("v.selectedColorPickerTile", cmp);
            } else {
	            $A.util.removeClass(div, "select");
            }
        });

        component.set("v.color", colorSelected);
        helper.fireColorSelected(component);*/

        console.groupEnd();
    },

    /*colorChanged: function(comp, event, helper) {      
        helper.toggleOtherComment(comp, event, helper);
    },*/

    otherCommentChanged: function (comp, event, helper) {
        console.groupCollapsed('SO_OpportunityColorPicker.otherCommentChanged');

        helper.fireOtherCommentEvent(comp, event, helper);
        /*var opp = component.get("v.opp");
    console.log('Obj opp = ' + JSON.stringify(opp));
        comp.set("v.opp", opp);
        console.log('SPO_ExtMaterialColor1localcomment__c', opp.SPO_ExtMaterialColor1localcomment__c);
        console.log('fin othercomment changed');*/

        console.groupEnd();
    },
    otherMaterialCommentChanged: function (comp, event, helper) {
        console.groupCollapsed('SO_OpportunityColorPicker.otherMaterialCommentChanged');

        helper.fireOtherMaterialCommentEvent(comp, event, helper);
        console.groupEnd();
    },

    /*doAction : function(component, event, helper) {
        helper.fetchMaterialPicklistValues(component, 'SPO_CreationType__c', 'SPO_LiningInteriorMaterial1__c');
        helper.fetchPicklistValues(component, 'SPO_LiningInteriorMaterial1__c', 'SPO_LiningInteriorColor1__c');
    },*/

    // http://www.sfdcmonkey.com/2017/02/18/dependent-picklist-fields-lightning-component/
    // function call on change tha controller field  
    onControllerFieldChange: function (component, event, helper) {
        console.groupCollapsed('SO_OpportunityColorPicker.onControllerFieldChange');

        //helper.setMaterialOpp(component);
        helper.toggleOtherComment(component, event, helper);

        // get the selected value
        var controllerValueKey = event.getSource().get('v.value');
        //console.log('controllerValueKey=' + controllerValueKey);

        //var selectedComponent = event.getSource().getLocalId();
        //console.log('selectedComponent=' + selectedComponent);

        // check if selected value is not equal to None then call the helper function.
        // if controller field value is none then make dependent field value is none and disable field
//        if (controllerValueKey != '--- None ---') {
        var ListOfDependentFields;
        if (controllerValueKey != '') {

            // get dependent values for controller field by using map[key].  
            // for i.e "India" is controllerValueKey so in the map give key Name for get map values like 
            // map['India'] = its return all dependent picklist values.
            var Map = component.get('v.depnedentFieldMap');
            console.log('>>> Map: ' + Map);
            ListOfDependentFields = Map[controllerValueKey];
            console.log('>>> ListOfDependentFields: ' + ListOfDependentFields);
            //console.log('ListOfDependentFields', ListOfDependentFields);
        }
        helper.fetchDepValues(component, ListOfDependentFields);

        // empty material, color if no Material chosen (possible to save with no color)
        /*var colorList = component.get("v.colorList");
        if (colorList == undefined || colorList.length == 0) {
            component.set("v.material", '');
            component.set("v.color", '');
        }*/
        helper.fireMaterial(component);
        console.groupEnd();
    },
});