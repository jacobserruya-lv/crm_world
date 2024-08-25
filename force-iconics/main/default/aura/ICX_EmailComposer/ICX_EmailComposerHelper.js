({
    sendHelper: function(component,event,helper) {
        //event.preventDefault(); // Prevent to send multiple emails if the user clicks several times on the Send Email button
        //helper.toggleShowHide(component,'slds-hide','slds-show', true);

        return new Promise(function(resolve, reject) { 
        
            helper.toggleShowHide(component,'slds-hide','slds-show', true);
            var instance = helper.buildEmailInstance(component, event, helper);
            if (instance!=false){
                // call the server side controller method 	
                var action = component.get("c.sendMailMethod");
                action.setParams({ 
                    'instance':JSON.stringify(instance)
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        helper.toggleShowHide(component,'slds-show','slds-hide', false);

                        var res = response.getReturnValue();
                        if (!$A.util.isEmpty(res) && res === true) {
                            helper.closeMessage(component,event,helper);
                            $A.get('e.force:refreshView').fire();
                            //console.log('event fired');
                           // window.location.reload()
                        }
                        resolve(response.getReturnValue());
                    }
                    if (state === "ERROR") {
                        helper.toggleShowHide(component,'slds-show','slds-hide', false);
                        console.error("Error: " + response.getError()[0].message);
                        reject(new Error(response.getError()));
                    }

                    var toastEvent = $A.get("e.force:showToast");
                    if (!$A.util.isEmpty(toastEvent)) {
                        toastEvent.setParams({
                            "title": state,
                            "message": (state === "SUCCESS" ? 'The Email has been sent successfully.' : response.getError()[0].message),
                            "type": state,
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action);
                //$A.get('e.force:refreshView').fire();

            } else {
                helper.toggleShowHide(component,'slds-show','slds-hide', false);
            }
     });
    },
    
    closeMessage: function(component, event, helper) {
      //  component.find("email").set('v.selection',[]);
        component.find("Cc").set('v.selection',[]);
        component.find("Bcc").set('v.selection',[]);
        component.set("v.subject", null);
        component.set("v.bodytext", null);
    },

    toggleShowHide : function(component,remove,add,disabled) {
        console.log("toggleShowHide>disabled", disabled);
        let button = component.find("sendButton"); 
        button.set("v.disabled",disabled);

        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, remove)
        $A.util.addClass(spinner, add);
    },

    buildListMails:function(selection){
        let selectedEmails =[];
        selection.forEach(element => {
                selectedEmails.push(element.subtitle);
        });
        return selectedEmails;
    },

     getSearchFromList: function(component,event) {
        var items = [];        
        var searchKey = component.find('fromSearchKey').get('v.value');
        console.log('From searchKey:'+searchKey);
        console.log('From searchKey length :'+searchKey.length);
        
        if(searchKey.length > 1){
        var action = component.get("c.searchFromEmail");
        action.setParams({
            "searchKey": searchKey  
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
            	var val = response.getReturnValue();
                for (var i = 0; i < val.length; i++) {
                	var item = {
                    	"label": val[i].label,
                        "value": val[i].email
                    };
                    items.push(item);
                }     
                          
                component.set("v.fromList", items);
                console.log('fromList length :'+items.length);
            }
        });
        $A.enqueueAction(action);
        }else{
            component.set("v.fromList", null);
        }
    },
            
       getAllFromList: function(component) {
        var items = [];
        var action = component.get("c.allFromEmailOptions");
        action.setCallback(this, function(response) {
          var state = response.getState();
            if (state === "SUCCESS") {
              var val = response.getReturnValue();               
                component.set("v.fromValues", val);
                
            }
        });
        $A.enqueueAction(action);
    },

    getEmailTemplateList : function(component,event){
        var items = [];     
        var searchKey = component.find('templateSearchKey').get('v.value');
        console.log('Template searchKey:'+searchKey);
        console.log('Template searchKey length :'+searchKey.length);
        
        if(searchKey.length > 1){
        var action = component.get("c.findTemplates");
        action.setParams({
            "searchKey": searchKey,
            "folderDeveloperName": component.get("v.templateFolder")
  
        });
        action.setCallback(this, function(response) {
           
            var state = response.getState();
            if(state === "SUCCESS"){
                var val = response.getReturnValue();
                component.set("v.templateRecordList", val);
                for (var i = 0; i < val.length; i++) {
                	var item = {
                    	"label": val[i].Name,
                        "value": val[i].Id
                    };
                    items.push(item);
                }
                component.set("v.templateList", items);
                console.log('templateList length :'+items.length);
             
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error Message: " + errors[0].message);
                    }
                }
                else{
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
    }else{
        component.set("v.templateList", null);
    }
    },

	getDefaultReplyEmail : function(component) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getDefaultReplyEmail");
        action.setParams({
            'recordId': recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();      
                // console.log("getDefaultReplyEmail>result", JSON.stringify(result));

                if (!$A.util.isEmpty(result)) {
                    if (!$A.util.isEmpty(result.emailTemplate)) {
                        component.set("v.selectedEmailTemplateName", result.emailTemplate.Name);
                        component.set("v.emailTemplate", result.emailTemplate);
                        component.set("v.subject", result.emailTemplate.Subject);

                        // Signature part
                        var body = result.body;
                        console.log("body=", body);
                        if (!$A.util.isEmpty(body)) {
                            component.set("v.signatureText", body.trimStart()); //trimStart for lightning email template naomi 10/2023
                        }
                    }
                    if (!$A.util.isEmpty(result.fromAddress)) {
                        component.set("v.selectedValue", result.fromAddress);
                    }
                    console.log('@@ defaultSearchId: ', result.defaultRecordId);
                    if (!$A.util.isEmpty(result.toAddress)) {
                        component.set("v.toAddress", result.toAddress);
                        component.set("v.defaultSearchId", result.defaultRecordId);
                        component.find("email").set("v.defaultSearchCriteria", result.toAddress);
                        // component.find("email").set("v.defaultSearchId", result.defaultSearchId);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
            
    getEmailTypeList: function(component){
        component.set("v.emailTypeOptions", [
            {label:'Email', value:'email'},
            {label:'Remote Consent', value:'remoteConsent'},
            // {label:'Clienteling', value:'Clienteling'},
        ]);
        this.getRemoteContentAccess(component);      
    },
    
    buildEmailInstance:function(component, event, helper){

        var from = component.get("v.fromValues");
        console.log("from", JSON.stringify(from));
        var fromAddresse;
        var getFrom = from.filter(element => element.email == component.get("v.selectedValue"))[0];
        console.log("getFrom", getFrom);
        if(getFrom.id.startsWith('0D2')){
            fromAddresse = getFrom.id;
        }else{
            fromAddresse = getFrom.name;
        }
        var attachementList = component.find("attachFiles").get("v.allFiles");
        var attachments = []; 
        attachementList.forEach(element => {attachments.push(element.documentId);});
        var ToAddresses = helper.buildListMails(component.find("email").get("v.selection"));
        var CcAddresses = helper.buildListMails(component.find("Cc").get("v.selection"));
        var BccAddresses = helper.buildListMails(component.find("Bcc").get("v.selection"));
        var getbody = component.get("v.bodytext");
        var message = component.find('message');
       
        if ($A.util.isEmpty(ToAddresses) ||$A.util.isEmpty(getbody) ) {
            if($A.util.isEmpty(getbody))
                component.set('v.message','To send this email, add a body content.');
            else
                component.set('v.message','Please select Email');
            $A.util.removeClass(message, 'slds-hide');
            $A.util.addClass(message, 'slds-show');
            return false;
        }
        else if(helper.validateEmail(ToAddresses) == false  || helper.validateEmail(CcAddresses) == false ||helper.validateEmail(BccAddresses) == false){
            component.set('v.message','Please insert valid Email');
            $A.util.removeClass(message, 'slds-hide');
            $A.util.addClass(message, 'slds-show');
            return false;
        }

        //getbody = getbody.replace(/<p><br><\/p>/g, "<br/>"); // replace <p><br><\/p> created by the rich text by one <br/> as the email sent is different in the client's mailbox
        //getbody = getbody.replace(/<\/p[^>]*>/g, "<br/>");  // remove </p> created by the rich text by one <br/> as the email sent is different in the client's mailbox
        //getbody = getbody.replace(/<p[^>]*>/g, ""); // remove <p> created by the rich text as the email sent is different in the client's mailbox
        var instance = {
            emailSubject: component.get("v.subject"),
            emailBody: getbody,
			emailSignature : component.get("v.signatureText"),
            emailFromAddress: fromAddresse,
            emailToAddresses: ToAddresses,
            emailCcAddresses: CcAddresses,
            emailBccAddresses: BccAddresses,
            emailattachments: attachments,
			requestRecordId: component.get("v.recordId"),
			emailTemplate : component.get("v.emailTemplate"),
            isRemoteConsent : component.get("v.emailTypeSelected") == 'remoteConsent'
        }

        //console.log('instance'+ JSON.stringify(instance));
        return  instance;
    },
    validateEmail:function(emailAddresses){
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/; 
        for(var i=0 ; i<emailAddresses.length;i++){
            if(!regExpEmailformat.test(emailAddresses[i])){
                return false;
            }
        }
        return true;
    },

    preview : function(component, event, helper) {
        //console.log("preview bodyText", component.get("v.bodytext"));
        var promise = helper.previewer(component, event);
        promise.then($A.getCallback(function(result) {
            console.log('preview result', result);
            helper.handleShowPreviewModal(component, result);
        }))
        .catch($A.getCallback(function(err) {
            console.log('catch: ' + err);
        }))
    },

    previewer : function(component, event, helper) {
        return new Promise(function (resolve, reject) {
            var bodytext = component.get("v.bodytext");
            var emailTemplate = component.get("v.emailTemplate");
    
            console.log('emailTemplateId', emailTemplate);
            console.log('emailBody', bodytext);
            console.log('recordId',  component.get("v.recordId"));
            console.log('signature', component.get("v.signatureText"));
            var action = component.get("c.previewEmail");
            action.setParams({
                'emailTemplateId' : (!$A.util.isEmpty(emailTemplate) ? emailTemplate.Id : null),
                'emailBody' : bodytext,
                'recordId' : component.get("v.recordId"),
                'signature' : component.get("v.signatureText")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var res = response.getReturnValue();
                    console.log("res", res);

                    //lightning email template naomi 10/2023
                    if(res.includes('<td width="100%" align="center">'))
                    {
                        console.log('found html body');
                        res = res.replace('<td width="100%" align="center">','<td width="100%" align="center" style="justify-content:center;display:flex;">');
                        console.log('found html body is true : ' + res.includes('<td width="100%" align="center">'));
                    }
              
                    resolve(res);                    
                } else if (state === "ERROR") {
                    console.log("err");
                    reject(response.error[0].message);
                }
            });
            $A.enqueueAction(action);
		});
    },

    handleShowPreviewModal: function(component, bodyEmail) {
        var modalBody;
        var modalFooter;
        //$A.createComponent("c:ICX_EmailComposerPreview", {
        //    "bodyEmail": bodyEmail
        //},

        
        /*var jsonResult = [];
        var emailMessage = ["aura:unescapedHtml", {
            "value": bodyEmail
        }];
        jsonResult.push(emailMessage);
        var sendEmailButton = ["lightning:button", {
            "label" : 'Send Email',
            "onclick" : component.getReference("c.sendMail"),
            "class" : ""
        }];
        jsonResult.push(sendEmailButton);
        
        $A.createComponents(jsonResult, function(components, status, errorMessage) {
            if (status === "SUCCESS") {
                   modalBody = components[0];
                   modalFooter = components[1];
                   component.find('overlayPreviewEmail').showCustomModal({
                       header: "Email Preview",
                       body: modalBody,
                       footer: modalFooter,
                       showCloseButton: true,
                       cssClass: "slds-modal_medium",
                       closeCallback: function() {
                       }
                   })
            }
        });*/

        $A.createComponent("aura:unescapedHtml", {
            "value": bodyEmail
        },
		function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayPreviewEmail').showCustomModal({
                       header: "Email Preview",
                       body: modalBody,
                     //  footer: sendEmailButton,
                       showCloseButton: true,
                       cssClass: "slds-modal_medium",
                       closeCallback: function() {
                       }
                   })
               }
           }
		);
    },

   /* getEmailTemplateList: function (component) {
        var items = [];
        var action = component.get("c.getEmailTemplateList");
        action.setParams({
            'folderDeveloperName' : component.get("v.templateFolder")
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
            	var val = response.getReturnValue();
                console.log('val', val);
                component.set("v.templateRecordList", val);

                // Can't add null value (error in Debug Lighntinh Component mode)
                items.push({
                    "label": "-- NONE --",
                    "value": "NONE"
                });

                for (var i = 0; i < val.length; i++) {
                	var item = {
                    	"label": val[i].Name,
                        "value": val[i].Id
                    };
                    items.push(item);
                }
                component.set("v.templateList", items);
            }
        });
        $A.enqueueAction(action);
    },*/

    getSignature: function (component) {
        var action = component.get("c.getSignature");
        action.setParams({
            template : component.get("v.emailTemplate"),
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
            	var signature = response.getReturnValue();
                console.log('signature', signature);
                component.set("v.signatureText", signature.trimStart()); //trimStart for lightning email template naomi 10/2023
            }
        });
        $A.enqueueAction(action);
    },

	navigateAction : function (component, event, forceAction) {
        var navigate = component.get('v.navigateFlow');
        console.log("navigate email composer", navigate);
        if (!$A.util.isEmpty(navigate)) {
            if (!$A.util.isEmpty(forceAction)) {
                console.log("handleFlowFooterEvent>forceAction", forceAction);
                navigate(forceAction);
            } else {
                var footerAction = event.getParam("action");
                console.log("handleFlowFooterEvent>action", footerAction);

                if (!$A.util.isEmpty(footerAction)) {
                    navigate(footerAction);
                } else {
                    navigate("NEXT");
                }
            }
        }
    },
    getRemoteContentAccess: function(component) {
        if(component.get("v.sObjectName") == 'Account'){
            var action = component.get("c.remoteConsentAccess");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var val = response.getReturnValue();
                    console.log('@ Remote Consent Access: ', val);
                    component.set("v.remoteConsentAccess", val);
                }
            });
            $A.enqueueAction(action); 
        }
    },
    fireAccountUpdate: function(component){
        if (!component.get("v.isDoneRendering")) {
           	component.set("v.isDoneRendering", true);  
            let accountId = component.get("v.accountId");
            console.log('@@@ AccountId: ', accountId);
            
            if (accountId != null) {
                console.log('Publish on Account Selected Channel: ', accountId);
                let payload = {recordId: accountId, currentRecordId: component.get("v.recordId")};
                component.find("ICX_AccountSelected").publish(payload);
            }           
       }
    }      
           
})