({
    doInit: function(component, event, helper) {
        console.groupCollapsed('SO_OpportunityColorEdit.doInit');

        helper.getOpportunity(component);
        console.groupEnd()
    },

    save: function(cmp, event, helper) {
        // console.groupCollapsed('SO_OpportunityColorEdit.save');

        //console.log('save');
        helper.saveOpportunity(cmp, event);

        var myEvent = cmp.getEvent("editEvent");
        myEvent.setParams({
            "action": "save"
            //channel: "ColorPicker"
        });
        myEvent.fire();

       // $A.get('e.force:refreshView').fire();
       //  console.groupEnd();
    },

    cancel : function (cmp, event, helper) {
        var myEvent = cmp.getEvent("editEvent");
        myEvent.setParams({
            "action": "cancel"
            //channel: "ColorPicker"
        });
        myEvent.fire();
    },

    colorChanged: function(comp, event, helper) {
        console.groupCollapsed('SO_OpportunityColorEdit.colorChanged');
        console.log("colorChanged Panel");

        var opp = comp.get("v.opp");
       	var typeColor = event.getParam("type");
        //var color = event.getParam("color");
        var colorName = ($A.util.isEmpty(event.getParam("color")) === false ? event.getParam("color").Name : '');
        //console.log('color Edit', color);

        if (typeColor == 'EXTERIOR1') {
            opp.SPO_ExteriorMaterial1__c = event.getParam("material");
            opp.SPO_ExteriorMaterialColor1__c = colorName;
            //opp.SPO_ExteriorMaterial1localcomment__c
        } else if (typeColor == "EXTERIOR2") {
            opp.SPO_ExteriorMaterial2__c = event.getParam("material");
            opp.SPO_ExteriorMaterialColor2__c = colorName;
            //opp.SPO_ExteriorMaterial2localcomment__c
        } else if (typeColor == "EXTERIOR3") {
            opp.SPO_ExteriorMaterial3__c = event.getParam("material");
            opp.SPO_ExteriorMaterialColor3__c = colorName;
            //opp.SPO_ExteriorMaterial3localcomment__c
        } else if (typeColor == "INTERIOR1") {
            opp.SPO_LiningInteriorMaterial1__c = event.getParam("material");
            opp.SPO_LiningInteriorColor1__c = colorName;
        } else if (typeColor == "INTERIOR2") {
            opp.SPO_LiningInteriorMaterial2__c = event.getParam("material");
            opp.SPO_LiningInteriorColor2__c = colorName;
        }
        if(colorName != ''){
            helper.createColorSelectedComponent(comp, event);
        }else{
            if(typeColor == 'EXTERIOR1' || typeColor == "INTERIOR1")
                helper.emptyColor(comp, 1);
            else if(typeColor == 'EXTERIOR2' || typeColor == "INTERIOR2")
                helper.emptyColor(comp, 2);
            else if(typeColor == 'EXTERIOR3')
                helper.emptyColor(component, 3);
        }
        //helper.createColorSelectedComponent(comp, event);
        console.groupEnd();
    },

    changeOtherComment: function(comp, event) {
        console.groupCollapsed('SO_OpportunityColorEdit.changeOtherComment');
        console.log('otherCommentChanged');
        var opp = comp.get("v.opp");
        var otherMaterialComment = event.getParam("otherMaterialComment");
        console.log('otherMaterialComment', otherMaterialComment);

        // TODO check also if material = 'Other (free text)'
        var typeColor = event.getParam("type");
        console.log("typeColor", typeColor);

        if (otherMaterialComment == undefined) {
            if (typeColor == 'EXTERIOR1') {
                opp.SPO_ExtMaterialColor1localcomment__c = event.getParam("comment");
            } else if (typeColor == "EXTERIOR2") {
                opp.SPO_ExtMaterialColor2localcomment__c = event.getParam("comment");
            } else if (typeColor == "EXTERIOR3") {
                opp.SPO_ExtMaterialColor3localcomment__c = event.getParam("comment");
            } else if (typeColor == "INTERIOR1") {
                opp.SPO_LiningColor1LocalComment__c = event.getParam("comment");
            } else if (typeColor == "INTERIOR2") {
                opp.SPO_LiningColor2LocalComment__c = event.getParam("comment");
            }
        } else {
            if (typeColor == 'EXTERIOR1') {
                opp.SPO_ExteriorMaterial1localcomment__c = otherMaterialComment;
            } else if (typeColor == "EXTERIOR2") {
                opp.SPO_ExteriorMaterial2localcomment__c = otherMaterialComment;
            } else if (typeColor == "EXTERIOR3") {
                opp.SPO_ExteriorMaterial3localcomment__c = otherMaterialComment;
            } else if (typeColor == "INTERIOR1") {
                opp.SPO_LiningMaterial1LocalComment__c = otherMaterialComment;
            } else if (typeColor == "INTERIOR2") {
                opp.SPO_LiningMaterial2LocalComment__c = otherMaterialComment;
            }
        }
        console.log('opp.SPO_LiningMaterial1LocalComment__c', opp.SPO_LiningMaterial1LocalComment__c);
        console.log('opp.SPO_LiningColor1LocalComment__c', opp.SPO_LiningColor1LocalComment__c);
        console.groupEnd();
    },

    resetExtColor1: function(component, event, helper) {
        if(component.get("v.colorTileListSizeExterior1") > 1){
            var opp = component.get("v.opp");
            opp.SPO_ExteriorMaterial1__c = "";
            helper.resetColor(component);
            helper.emptyColor(component, 1);
        }
    },
    resetExtColor2: function(component, event, helper) {
        if(component.get("v.colorTileListSizeExterior2") > 1){
            var opp = component.get("v.opp");
            opp.SPO_ExteriorMaterial2__c = "";
            helper.resetColor(component);
            helper.emptyColor(component, 2);
        }
    },
    /*resetExtColor3: function(component, event, helper) {
        if(component.get("v.colorTileListSizeExterior3") > 1){
            var opp = component.get("v.opp");
            opp.SPO_ExteriorMaterial3__c = "";
            helper.resetColor(component);
            helper.emptyColor(component, 3);
        }
    },*/
    resetIntColor1: function(component, event, helper) {
        if(component.get("v.colorTileListSizeInterior1") > 1){
            var opp = component.get("v.opp");
            opp.SPO_LiningInteriorMaterial1__c = "";
            helper.resetColor(component);
            helper.emptyColor(component, 1);
        }
    },
    resetIntColor2: function(component, event, helper) {
        if(component.get("v.colorTileListSizeInterior2") > 1){
            var opp = component.get("v.opp");
            opp.SPO_LiningInteriorMaterial2__c = "";
            helper.resetColor(component);
            helper.emptyColor(component, 2);
        }
    },

    creationTypeChanged: function(component, event, helper) {
        console.groupCollapsed('SO_OpportunityColorEdit.creationTypeChanged');
        var creationType = component.get("v.creationType");
        var opp = component.get("v.opp");
        if (creationType == 'Hardsided') {
            if ($A.util.isEmpty(opp.SPO_ExteriorMaterial2__c) == false) {
                opp.SPO_ExteriorMaterial2__c = "";
                helper.resetColor(component);
                helper.emptyColor(component, 2);
            }

        } else if (creationType == 'Soft') {
            console.log('opp.SPO_LiningInteriorMaterial2__c=' + opp.SPO_LiningInteriorMaterial2__c);
            if ($A.util.isEmpty(opp.SPO_LiningInteriorMaterial2__c) == false) {
                opp.SPO_LiningInteriorMaterial2__c = "";
                helper.resetColor(component);
                helper.emptyColor(component, 2);
            }
        }
        console.groupEnd();
    },

    /*handleActiveTab: function (cmp, event, helper) {
        var tab = event.getSource();
        switch (tab.get('v.id')) {
            case 'intColor2Tab' :
                helper.injectComponent('', tab);
                break;
            case 'cases' :
                helper.injectComponent('c:myCaseComponent', tab);
                break;
        }
    },*/

    updateSizeColorTileList: function (cmp, event, helper) {
        console.groupCollapsed('SO_OpportunityColorEdit.updateSizeColorTileList');
        var colorTileListSize = event.getParam("colorTileListSize");
        console.log('colorTileListSize ',colorTileListSize);
        console.log('type ', event.getParam('type'));
        //cmp.set('v.colorTileListSize', colorTileListSize);
        if(event.getParam('type') == 'EXTERIOR1'){
            cmp.set("v.colorTileListSizeExterior1", colorTileListSize);
        }else if (event.getParam('type') == 'EXTERIOR2'){
            cmp.set("v.colorTileListSizeExterior2", colorTileListSize);
        }else if (event.getParam('type') == 'EXTERIOR3'){
            cmp.set("v.colorTileListSizeExterior3", colorTileListSize);
        }else if (event.getParam('type') == 'INTERIOR1'){
            cmp.set("v.colorTileListSizeInterior1", colorTileListSize);
        }else if (event.getParam('type') == 'INTERIOR2'){
            cmp.set("v.colorTileListSizeInterior2", colorTileListSize);
        }
        console.groupEnd();
    },

    display : function(component, event, helper) {
        $A.util.removeClass(component.find("divLiningWarning"), 'slds-hide');
       
    },
    
    displayOut : function(component, event, helper) {
        $A.util.addClass(component.find("divLiningWarning"), 'slds-hide');
    }
})