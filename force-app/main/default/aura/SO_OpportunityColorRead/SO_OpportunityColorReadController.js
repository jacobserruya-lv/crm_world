({
    doInit: function(component, event, helper) {        
        helper.getOpportunity(component);
        helper.setUser(component);
        helper.getJSONList(component);
    },

    handleMenuSelect : function (cmp, event, helper) {
        var selectedMenuItemValue = event.getParam('value');

        var myEvent = cmp.getEvent('editEvent');
        if (selectedMenuItemValue == 'editExterior') {
            myEvent.setParams({
                'action': 'editExterior',
                //channel: "ColorPicker"
            });
            myEvent.fire();

            // problem: component called is not in the current component in an App
            /*
             var evt = $A.get("e.force:navigateToComponent");
            console.log('evt', evt);
            evt.setParams({
                componentDef : "c:SO_OpportunityColorEdit",
                componentAttributes: {
                    opp : cmp.get("v.opp")
                }
            });
            evt.fire();*/
        } else if (selectedMenuItemValue == 'editInterior') {
            myEvent.setParams({
                'action': 'editInterior',
                //channel: "ColorPicker"
            });
            myEvent.fire();
        } else {
            // console.log('Inside else :');
            cmp.set('v.disabled',false);
            cmp.set('v.showAction',true);
            cmp.set('v.showMenu',false);
            /*var myEvent = cmp.getEvent("editEvent");
            myEvent.setParams({
                "action": "editMaterial"
            });
            myEvent.fire();*/
        }
    },
    
    refreshColor: function(component, event, helper) {        
        helper.getColorMap(component);
    },

    editMetalicPart : function(component){
        // console.groupCollapsed(component.getType() + '.editMetalicPart');
        // console.log('edit Mmetalic Part controller launched :>>>><');

        component.set('v.disabled',false);
        // console.groupEnd();
    },
    
    save : function(cmp){
        // console.groupCollapsed(cmp.getType() + '.save');

        var opp = cmp.get('v.opp');
        // console.log('save opp', opp);
        // console.log("save acc", cmp.get("v.account"));

        var action = cmp.get('c.saveColor');
        action.setParams({
            'opportunity' : opp,
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS'){
                cmp.set('v.showAction', false);
                cmp.set('v.showMenu', true);
                cmp.set('v.disabled',true);

                $A.get('e.force:refreshView').fire();
            } else {
                console.error('error');
            }
        });

        $A.enqueueAction(action);
        // console.groupEnd();
    },
    cancelAction : function(cmp){
        
        cmp.set('v.showAction', false);
        cmp.set('v.showMenu', true);
        cmp.set('v.disabled',true);
        
        $A.get('e.force:refreshView').fire();
        
    },

});