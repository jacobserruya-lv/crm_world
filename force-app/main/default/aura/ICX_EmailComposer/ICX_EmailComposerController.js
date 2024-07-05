({
    onInit: function (component, event, helper) {
        helper.getAllFromList(component);
        helper.getDefaultReplyEmail(component);
        //helper.getEmailTemplateList(component);
        helper.getEmailTypeList(component); 
    },
    
    doneRendering: function (component, event, helper) {
       	helper.fireAccountUpdate(component); 
    },

    sendMail: function(component, event, helper) {
        helper.toggleShowHide(component,'slds-hide','slds-show', true);
        //event.preventDefault(); // Prevent to send multiple emails if the user clicks several times on the Send Email button
        helper.sendHelper(component, event, helper);
		 component.set("v.selectedEmailTemplateName", null);												   
    },
    
	handleQuickTextEvent : function(component, event, helper) {
        var recordId = event.getParam("recordId");
        var quickText = event.getParam("quickText");
        var quickTextFormatted = event.getParam("quickTextFormatted");
        console.log("handleQuickTextEvent > recordId", recordId, "quickTextEvent", quickText);
        
        if (component.get("v.recordId") === recordId) {
            var bodyEmail = component.get("v.bodytext");
            if (!$A.util.isEmpty(quickTextFormatted)) {// && !$A.util.isEmpty(quickText.Message)) {
                var res = quickTextFormatted;//.replace(/(?:\r\n|\r|\n)/g, '<p/>');//<br/>');
                console.log("res", res);
                console.log("body",component.find("body"));
                //component.find("body").insertTextAtCursor(res);
                component.set("v.bodytext", ($A.util.isEmpty(bodyEmail) ? '' : bodyEmail) + res);
            }
        }
    },
    showText : function(component, event, helper) {
        var selectedItem = event.currentTarget; // Get the target object
        var dataIndex = selectedItem.dataset.index; // Get its value i.e. the index
        console.log("dataIndex", dataIndex);
        
        if (dataIndex === 'ccLink') {
            var ccDiv = component.find('ccDiv');
        	$A.util.removeClass(ccDiv, 'slds-hide');

            var ccLink = component.find('ccLink');
        	$A.util.addClass(ccLink, 'slds-hide');
        } else if (dataIndex === 'bccLink') {
            var bccDiv = component.find('bccDiv');
        	$A.util.removeClass(bccDiv, 'slds-hide');

            var bccLink = component.find('bccLink');
        	$A.util.addClass(bccLink, 'slds-hide');
        }
    },

    preview : function(component, event, helper) {
        helper.preview(component, event, helper);
        /*console.log("preview bodyText", component.get("v.bodytext"));
        var promise = helper.previewer(component, event);
        promise.then($A.getCallback(function(result) {
            console.log('preview result', result);
            helper.handleShowPreviewModal(component, result);
        }))
        .catch($A.getCallback(function(err) {
            console.log('catch: ' + err);
        }))*/
    },
	fromSearchKeyChange : function(component,event,helper) {
        helper.getSearchFromList(component,event);
    }, 

    templateSearchKeyChange : function(component,event,helper) {
       helper.getEmailTemplateList(component,event);
    }, 

    FromAddressChanged : function(component, event, helper){     
        var selectedFromAddress = event.currentTarget.dataset.value;
        console.log("selectedFromAddress", selectedFromAddress);
        component.set("v.selectedValue", selectedFromAddress);
        component.set("v.fromList", null);
    },														

    emailTemplateChanged : function(component, event, helper) {
        var selectedEmailTemplateId = event.currentTarget.dataset.value;
        console.log("selectedEmailTemplateId", selectedEmailTemplateId);
        
        component.set("v.signatureText", null);
        
       // var emailTemplateId = component.get("v.emailTemplateId");
        var emailTemplateList = component.get("v.templateRecordList");
        var selectedResult = emailTemplateList.filter(result => result.Id === selectedEmailTemplateId);
        console.log("selectedResult", selectedResult);
        if (selectedResult.length > 0) {
            var emailTemplate = selectedResult[0];
            component.set("v.emailTemplate", emailTemplate);
            component.set("v.subject", emailTemplate.Subject);
            component.set("v.selectedEmailTemplateName", emailTemplate.Name);
            component.set("v.templateList", null);
            helper.getSignature(component);
            // TODO: call Apex to get signature OR REGEX
            /*var regex = /(?<=\\<div id\\=\\"icx_signature\\"\\>)(.*)(?=\\<\\/div\\>)/;
            var signature = emailTemplate.HtmlValue.match(regex);
            if (signature.length > 0) {
                console.log('signature', signature[0]);
		        component.set("v.signatureText", signature[0]);
            }*/
        } else {
            component.set("v.emailTemplate", null);
            //component.set("v.subject", emailTemplate.Subject);
        }
    },


	handleFlowFooterEvent : function (component, event, helper) {
		console.log("handleFlowFooterEvent", JSON.stringify(event));
        console.log("event.recordId", event.getParam("recordId"));
        console.log("event.Action", event.getParam("action"));

        if (component.get("v.recordId") === event.getParam("recordId")) {
            if (event.getParam("action") === 'Preview') {
                helper.preview(component, event, helper);
            } else if (event.getParam("action") === 'No Response Required') {
                console.log('No response required');
                helper.navigateAction(component, event, "NEXT");

            } else if (event.getParam("action") === 'NEXT') {
                //helper.preview(component, event, helper);

                // TODO Promise to send the email and then go to the next screen (see exemple in helper preview() method)
                var promise = helper.sendHelper(component, event, helper);
                promise.then(function(result) {
                     helper.navigateAction(component, event);
                })
                .catch(function(err) {
                    console.error('catch: ' + err);
                    helper.toggleShowHide(component,'slds-show','slds-hide', false);
                    var toastEvent = $A.get("e.force:showToast");
                if (!$A.util.isEmpty(toastEvent)) {
                    toastEvent.setParams({
                        "title": 'ERROR',
                        "message":  ('There was an error, please try again : ' + err),
                        "type": 'ERROR',
                    });
                    toastEvent.fire();
                }
              })
    
            } else {
                helper.navigateAction(component, event);
                /*var navigate = component.get('v.navigateFlow');
                console.log("navigate email composer", navigate);
                if (!$A.util.isEmpty(navigate)) {
                    var footerAction = event.getParam("action");
                    console.log("handleFlowFooterEvent>action", footerAction);
                
                    if (!$A.util.isEmpty(footerAction)) {
                        //  navigate(footerAction);
                    } else {
                        navigate("NEXT");
                    }
                }*/
            }
            
            // }
        }
    },
    emailTypeChanged : function(component, event, helper) {
        console.log('### Email type selected: ', event.getParam("value"));
        component.set("v.emailTypeSelected", event.getParam("value"));
    }
})