({
    onInit: function (component, event, helper) { 
        helper.getSettings(component);        
        helper.initEvents();
    },
    onClientEvent: function (component, event, helper) {
        component.set("v.recordId", "");
        console.log('### onClientEvent');
        console.log('### event from ClientEvent:'+JSON.stringify(event));
        let eventData = event.getParams();

        if(eventData) {
            let event = JSON.stringify(eventData);
            console.log('### Params from ClientEvent:'+event);
            if (eventData.type === 'UserAction' && eventData.category === 'status'){
                if(eventData.data !== undefined){
                    console.log('+++ Change CTI status: ', eventData.data.id);
                    console.log('+++ Attributes value:',{
                        clientelingId: component.get("v.clientelingId"),    
                        monitoringId: component.get("v.monitoringId"),
                    });
                    console.log('+++ CLIENTELING: ', eventData.data.id == component.get("v.clientelingId"));
                    component.set("v.clienteling", eventData.data.id == component.get("v.clientelingId"));
                    console.log('+++ MONITORING: ', eventData.data.id == component.get("v.monitoringId"));
                    component.set("v.monitoring", eventData.data.id == component.get("v.monitoringId"));
                }
            }
            else if (eventData.type === 'Interaction'){
                // check if current tab is Active
                if(document.hidden){
                    console.log('+++ The current Tab is not active => EXIT');
                    let isNotActive = helper.checkCurentTab();
                    console.log('+++ Check Tab Func => ', isNotActive);
                     if(!isNotActive){
                        return;
                    }
                    console.log('+++', window.parent.location.href);
                }
                // show recordId
                let isBlindTransfer = eventData.category == 'blindTransfer';
                let isCallback = eventData.data.callbackNumbers != null;
                let isCase = eventData.data.isEmail === true && eventData.category == 'connect';
                let isConnected = eventData.data.isConnected === true && eventData.data.isDisconnected === false;
                let isOutbound = eventData.data.direction != null && eventData.data.direction == 'Outbound';
				let isPhone = eventData.data.phone != null;
                let interactionId = eventData.data.id; 

                if((isPhone || isCallback) && isConnected){
                    helper.getTask(component, interactionId, isOutbound); // is Outbound to exclude bind transfer       
                } 
                else if(isBlindTransfer){
                    let conversationId = eventData.data;
                    helper.updateCaseOwner(component, conversationId);
                }
                else if(isCase && isConnected){
                    let caseId = eventData.data.attributes.sf_urlpop;
                    let conversationId = eventData.data.attributes['Call.ConversationId'];
                    let participantId = eventData.data.attributes['Salesforce.ParticipantId'];
                    console.log('+++ caseId', caseId);
                    console.log('+++ conversationId', conversationId);  
                    console.log('+++ particippantId', participantId);
                    helper.updateCase(component, caseId, conversationId, participantId);
                }
            }
        }
    },
})