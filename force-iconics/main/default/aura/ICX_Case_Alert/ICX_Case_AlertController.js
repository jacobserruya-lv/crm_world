({
    onInit: function (component, event, helper) {
        console.log('onInit Case Alert');
        helper.getCaseData(component);
    },
    onRender: function (component, evt) {
        var descElem = component.find("icx-case-alert__desc").getElement();
        var rowHeight = 10;//16; // for readability

        if (descElem.clientHeight > (3 * rowHeight)) {
            component.set('v.longDesc', true);
        }
    },
    handleShowModal: function(component, evt, helper) {
        var content = component.find('modal-content').getElement();
        component.find('overlayLib').showCustomModal({
            header: "Request Details",
            body: content,
            showCloseButton: true,
        })
    },
    toggleDescPin: function(component, evt, helper) {
        var descElem = component.find('icx-case-alert__desc').getElement();

        if (!descElem.style.maxHeight) {
            descElem.style.maxHeight = (descElem.scrollHeight + 'px');
            component.set('v.descPinned', true);
        } else {
            descElem.style.maxHeight = "";
            component.set('v.descPinned', false);
        }
    },

    goToRecord : function(component, event, helper) {
        var whichOne = event.getSource().getLocalId();
        console.log("whichOne", whichOne);
        
        var recordId;
        if (whichOne === 'goToParentCase') {
            var caseData = component.get("v.caseData");
            recordId = caseData.ParentId;
        } else if (whichOne === 'goToParentRecord') {
            recordId = component.get("v.parentRecordId");
        } else if (whichOne === 'goToLastReplyEmail') {
            recordId = component.get("v.lastReplyEmail").Id;
        }
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },

    goToParentRecord : function(component) {
        //var caseData = component.get("v.caseData");
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.parentRecordId")
        });
        navEvt.fire();
    },
    
	handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        console.log("eventParams.changeType", eventParams.changeType);
        if(eventParams.changeType === "CHANGED") {
            // get the fields that changed for this record
            var changedFields = eventParams.changedFields;
            console.log('Fields that are changed: ' + JSON.stringify(changedFields));
            component.find('recordData').reloadRecord(true);

            // record is changed, so refresh the component (or other component logic)
            //helper.handleOK(component);
        } else if(eventParams.changeType === "LOADED") {
            console.log("eventParams.changeType === LOADED");

            helper.getSourceEmail(component);
            helper.getParentRecord(component);
            helper.getLastReplyEmail(component);

            var caseData = component.get("v.caseData");
            if (caseData.Status != 'Closed') {
                helper.addTimer(component);
            }

            var description = component.get("v.caseData.Description");
            console.log("description", description);

            component.set("v.richDescription", description);

            // record is loaded in the cache
            /*var p = helper.findCallDetail2(component);
            p.then(function (response) {
                console.log("createPhone success", response);
                helper.createPhone(component);
            }).catch(function (err) {
                console.log("err", err);
            })*/
        } else if(eventParams.changeType === "REMOVED") {
            console.log("REMOVED", eventParams);
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            console.log("ERROR", eventParams);
            // there’s an error while loading, saving or deleting the record
        }
    },

    /*handleLoadingEmail: function(component, event, helper) {
        var eventParams = event.getParams();
        console.log("handleLoadingEmail eventParams.changeType", eventParams.changeType);
        if(eventParams.changeType === "CHANGED") {
            // get the fields that changed for this record
            var changedFields = eventParams.changedFields;
            console.log('handleLoadingEmail Fields that are changed: ' + JSON.stringify(changedFields));
        } else if(eventParams.changeType === "LOADED") {
            console.log("handleLoadingEmail eventParams.changeType === LOADED");
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            console.log("ERROR handleLoadingEmail", JSON.stringify(eventParams));
            // there’s an error while loading, saving or deleting the record
        }
    },*/
    
    handleInfoMouseEnter : function(component, event, helper) {
        var caseData = component.get("v.caseData");
        if (!$A.util.isEmpty(caseData)) {
            console.log("origin/sourceId", caseData.Origin, caseData.SourceId);
            //if (component.get("v.caseData.Origin") != 'Email' && not(empty(component.get("v.emailMessage")))) {
            //if ((caseData.Origin === 'Email' && !$A.util.isEmpty(caseData.SourceId)) 
            //    || caseData.Origin === 'Web' || caseData.Origin === 'chatbot' || caseData.Origin === 'Phone') {
            var popover = component.find("popupInfo");
            $A.util.removeClass(popover,'slds-hide');
            //}
        }
    },
    
    //make a mouse leave handler here
    handleInfoMouseLeave : function(component, event, helper) {
        var popover = component.find("popupInfo");
        $A.util.addClass(popover,'slds-hide');
    },

    // Page refreshed
    isRefreshed : function(component, event, helper) {
        helper.getCaseData(component);
    }
})