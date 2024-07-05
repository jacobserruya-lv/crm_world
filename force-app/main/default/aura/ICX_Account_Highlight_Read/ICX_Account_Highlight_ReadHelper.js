({
    /*getAccount : function(component, event) {
        
        // change recordId to get Account Id from Case
        var caseService = component.find("caseService");
        caseService.findAccount(component.get("v.recordId"), $A.getCallback(function(error, data) {
            component.set("v.recordId", data);
            console.log('getAccount', data);
            component.find('recordDataAccount').reloadRecord(true);
            //component.set("v.accountId", data);
        }));
	}*/

    editAccount: function(component, event){
		if(component.get("v.editModalOpened")) return;
		component.set("v.editModalOpened", true);
		var modalBody, modalFooter;
		$A.createComponents([
			["c:ICX_Account_Highlight_Edit2",{
                recordId : component.get("v.recordId"),
                taskRecordId : component.get("v.relatedRecordId")
            }],
			["c:ICX_Account_Highlight_Edit_Buttons",{}]
			],
			function(components, status){
				if(status==="SUCCESS"){
					modalBody = components[0];
					modalFooter = components[1];
					modalFooter.set("v.parent", modalBody);
					component.find("overlayLib").showCustomModal({
						header: "Edit Account",
						body : modalBody,
						footer: modalFooter,
						cssClass: "slds-modal_large",
						showCloseButton: true,
						closeCallback: function() {
						   component.set("v.editModalOpened", false);
					   }
					})
				}
			}
		)
	},

    searchAccount: function(component, event){
		if(component.get("v.editModalOpened")) return;
		component.set("v.editModalOpened", true);
		var modalBody, modalFooter;
		$A.createComponents([
			["c:ICX_Flow_Account",{
                recordId : component.get("v.relatedRecordId"),
                accountNotVerified : true,
                isModal : true
            }],
			["c:ICX_Account_Highlight_Edit_Buttons",{}]
			],
			function(components, status){
				if(status==="SUCCESS"){
					modalBody = components[0];
					modalFooter = components[1];
					modalFooter.set("v.parent", modalBody);
					component.find("overlayLib").showCustomModal({
						header: "Search Account",
						body : modalBody,
						footer: modalFooter,
						cssClass: "slds-modal_large",
						showCloseButton: true,
						closeCallback: function() {
						   component.set("v.editModalOpened", false);
					   }
					})
				}
			}
		)
	},
    
    identityUser: function(component, event, helper){
        var imgUrl = $A.get('$Resource.iconics') + '/images/MyLV.png';
        component.set("v.iconMyLvUrl",imgUrl);
        var action = component.get("c.IsIdentityUser");
        action.setParams({
          recordId : component.get('v.recordId')
        });
        action.setCallback(this, function(response) { 
          var state = response.getState();
          if(state === "SUCCESS") {
           	var result = response.getReturnValue();
            var str='';
              if(!$A.util.isUndefinedOrNull(result)){
                  component.set("v.isUserIdentity",result.IsActive);
                  if(!$A.util.isUndefinedOrNull(result.TECH_Email__c)){
                      if(!(result.TECH_Email__c.includes($A.get("$Label.c.ICX_Identity_Username_Suffix")) && result.TECH_Email__c.includes(result.TECH_MobilePhone__c))){
                          str += result.TECH_Email__c +' ' ;   
                      }
                  }
                  if(!$A.util.isUndefinedOrNull(result.TECH_MobilePhone__c)){
                     str += result.TECH_MobilePhone__c+ ' '  ;
                  }
                  if(result.IsActive== true){
                     str += '| Active ' ;
                  }else{
                     str += '| Inactive ' ;
                  }
                  if(!$A.util.isUndefinedOrNull(result.LastLoginDate)){
                     str += 'Last Login: '+$A.localizationService.formatDate(result.LastLoginDate, "MMM yyyy");
                  }  
                  
              }else{
                    str = 'No MyLv Account';
              }
               component.set("v.titleMyLv",str);
            
          }else if(state === "ERROR") {
            var errors = response.getError();
            console.error(errors);
          }
        }); 
        $A.enqueueAction(action);
        
    },

    getUserInfo : function(component, event) {
        var cuUserId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.getUserInfo");
        action.setParams({
            userId : cuUserId
        });

        action.setCallback( this, function(response){
            if(response.getState() === 'SUCCESS') {
                var currentUser = response.getReturnValue();
               component.set("v.currentUser", currentUser);
                
                if (!$A.util.isEmpty(currentUser) && currentUser.Profile.Name.indexOf('ICONiCS') >= 0 ) {
                    component.set("v.isCurrentUserIconics", true);
                    component.set("v.isCurrentUserIcon", false);
                }else if( !$A.util.isEmpty(currentUser) && (currentUser.Profile.Name.indexOf('ICON_Corporate') >= 0||currentUser.Profile.Name.indexOf('ICON_SA Manager') >= 0 ||currentUser.Profile.Name.indexOf('ICON_SAManager')>= 0)) {
                    component.set("v.isCurrentUserIconics", false);
                    component.set("v.isCurrentUserIcon", true);
                    
                }else if(!$A.util.isEmpty(currentUser) && currentUser.Profile.Name.indexOf('Admin') >= 0){
                    component.set("v.isCurrentUserIconics", true);
                    component.set("v.isCurrentUserIcon", true);
                    
                }else{
                    component.set("v.isCurrentUserIconics", false);
                    component.set("v.isCurrentUserIcon", false);

                }

            }
        });
        $A.enqueueAction(action);
    },
    countriesExcluded: function(component, event, helper){

        
        var action = component.get("c.countriesExcludedRMS");
       
        action.setCallback( this, function(response){
            if(response.getState() === 'SUCCESS') {
                var responseValue = response.getReturnValue();
                if(!$A.util.isEmpty(responseValue)){

                   component.set("v.excludedCountries", responseValue.Excluded_Countries__c);
                }
            }
        });
        $A.enqueueAction(action);

    }, 


    displayRMSButton: function(component, event, helper){
        var excludedCountries = component.get("v.excludedCountries");
        var account = component.get("v.simpleAccount");
        var isIconUser = component.get("v.isCurrentUserIcon");
        var isUserIdentity = component.get("v.isUserIdentity");
        var sObject = component.get("v.sObjectName");

        var storeType = (account != null && account.Store__pr  != null ? account.Store__pr.StoreType__c : '');

        var includeCountry = !$A.util.isEmpty(excludedCountries) ? excludedCountries.includes(account.HomeAddressCountryCode__pc) : false;

        debugger ;

        var RMSLayout = component.find('RMSLayout');

        if(account == null || sObject != 'Account' || !isIconUser || !isUserIdentity) {
            $A.util.addClass(RMSLayout, 'slds-hide');
        }else if(sObject == 'Account' && account!=null && ( includeCountry || account.RMSId__pc != null || account.TypologyCode__pc != '7' || storeType == 'WEB' )){
            $A.util.addClass(RMSLayout, 'slds-hide');
        }else{
            $A.util.removeClass(RMSLayout, 'slds-hide');
        }
    },
    sendToRMS: function(component, event) {

        var simpleAccount = component.get("v.simpleAccount");
        var userStore = component.get("v.currentUser").DefaultStore__c;

        if( simpleAccount != null && simpleAccount.RMSID__pc == null && (!$A.util.isEmpty(simpleAccount.AttachedStore__pc) || !$A.util.isEmpty(userStore))){

            var action = component.get("c.sendClientToRMS");
            action.setParams({
                acc : simpleAccount,
                userStoreCode : userStore
            });
            action.setCallback( this, function(response){
                var  state = response.getState();
                var RMSLayout = component.find('RMSLayout');
                $A.util.addClass(RMSLayout, 'slds-hide');

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": 'Info',
                    "message": (state === "SUCCESS" ? 'MYCC/XTORE/RMS Sending...' : response.getError()[0].message),
                    "type": 'info'
                });
                toastEvent.fire();
            });
            $A.enqueueAction(action);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": 'Info',
                "message": 'Missing attached store, please Reassign Client on ICON desktop before',
                "type": 'info'
            });
            toastEvent.fire();
        }

       
    },
    
    getIndicators : function(component, event) {
        
        var pendingAnswersList=[];
        var pendingCareServiceList=[];
        var complaintsResolved = [];
        var complaintsPending = [];
       
        var speakerIconIndicator=[];
        var bellIconIndicator=[];

        var accountId = component.get("v.recordId");

        console.log('accoundID');
        console.log(accountId);
        var caseService = component.find("caseService");
        caseService.findIndicators(accountId, $A.getCallback(function(error, response) {

                //Open case


                for (var key in response.openMessagingList) {
                    let messagingItem = response.openMessagingList[key];

                   // pendingAnswersList.push(messagingItem);
                  //  messagingItem.Duration = new Date(b.record.CreatedDate) - new Date(a.record.CreatedDate);
                    

                   //icon bell indicator
                   if (messagingItem.age<=2)
                    {
                        
                        bellIconIndicator.push(messagingItem);
                        
                    }

                }
                for (var key in response.liveChatTranscriptList) {
                    let liveChatTranscriptItem = response.liveChatTranscriptList[key];

                   // pendingAnswersList.push(liveChatTranscriptItem);
                    

                   //icon bell indicator
                   if (liveChatTranscriptItem.age<=2)
                    {
                        
                        bellIconIndicator.push(liveChatTranscriptItem);
                        
                    }

                }

                // Task 
                for (var key in response.taskList) {
                    let taskItem = response.taskList[key];

                   // pendingAnswersList.push(taskItem);
                  // console.log(taskItem.record.RecordType.DeveloperName);

                   //icon bell indicator
                   if (taskItem.age<=2 && taskItem.record.RecordType.DeveloperName==='CSC_Call' && taskItem.record.CallType==='Inbound')
                    {
                      //  console.log('TaskItemIN:');
                      //  console.log(taskItem);

                        bellIconIndicator.push(taskItem);
                        
                    }

                    // Task Complaints;
                    // For JIRA NI-1789 : DON'T REMOVE COMMENT
                   // TECH_IsWhatIdCase__c = false and IsClosed = true and Nature__c = 'Complaints'                                
                  if(taskItem.record.Nature__c === 'Complaints' && taskItem.record.IsClosed === true && taskItem.record.TECH_IsWhatIdCase__c === false )
                   {
                        complaintsResolved.push(taskItem);
                   }
                }


                for (var key in response.openCaseList) {
                    let openCase = response.openCaseList[key];
                 //   console.log(openCase);

                 if (openCase.record.Resolution__c === 'Request to Store'  || openCase.record.RecordType.DeveloperName === 'Operation_Exception' ||  openCase.record.RecordType.DeveloperName === 'Call_Case' ||  openCase.record.RecordType.DeveloperName === 'Web_Email_Case'  || openCase.record.RecordType.DeveloperName === 'Product_On_Demand_with_sku')//||  openCase.record.RecordType.DeveloperName === 'Chat_Messaging'
                 {

                
                        if (openCase.record.Status=='New' || openCase.record.Status=='Awaiting') {
                            pendingAnswersList.push(openCase);
                    
                            //icon speaker indicator
                            if (openCase.age<=2){
                                speakerIconIndicator.push(openCase);
                            }
                        }
                    }

                    //icon bell indicator
                    if (openCase.record.RecordType.DeveloperName === 'Call_Case' ||  openCase.record.RecordType.DeveloperName === 'Web_Email_Case' || openCase.record.RecordType.DeveloperName === 'Chat_Messaging') 
                    {
                        if(openCase.age<=2)
                        {
                            bellIconIndicator.push(openCase);
                        }
                    }

                }

                if(speakerIconIndicator.length>0)
                {
                    component.set("v.showSpeaker", true);

                }

                if(bellIconIndicator.length>=3)
                {
                    component.set("v.showBell", true); 

                }

                // Sort by date
                pendingAnswersList.sort(function(a,b){
                    // Turn your strings into dates, and then subtract them
                    // to get a value that is either negative, positive, or zero.
                    return new Date(b.record.CreatedDate) - new Date(a.record.CreatedDate);
                  });

                //component.set("v.pendingAnswersList", pendingAnswersList);

                response.pendingAnswersList=pendingAnswersList;

                //care service

               
                // Workaround : get care duration
                for (var key in response.careList) {
                let careItem = response.careList[key];

                
                var oneDay = 24*60*60*1000; // hours*minutes*seconds*milliseconds
                var today = new Date();
                var secondDate = new Date(careItem.CreatedDate);

                var diffDays = Math.round(Math.abs((today.getTime() - secondDate.getTime())/(oneDay)));


                careItem.Duration = diffDays;
                careItem.label = (careItem.SKU__c === undefined ? careItem.Product_Sku_unknown__c : careItem.SKU__c + ' - ' + careItem.Product_Name__c);


               
                if(careItem.ICONiCS_Status_Detail__c!='Cancelled' && careItem.ICONiCS_Status_Detail__c!='Delivered to Client' || careItem.ICONiCS_Status_Detail__c!='Product stocked')
                {
                    pendingCareServiceList.push(careItem);
                    console.log('careItem  :');
                    console.log(careItem);
                    console.log(careItem.age);
                }

            }
             // Sort by date
             pendingCareServiceList.sort(function(a,b){
                // Turn your strings into dates, and then subtract them
                // to get a value that is either negative, positive, or zero.
                return new Date(b.CreatedDate) - new Date(a.CreatedDate);
              });
                  
                  response.pendingCareServiceList =pendingCareServiceList;

                //complaint
                for (var key in response.complaintList) {
                    let complaint = response.complaintList[key];
                 
                    if(complaint.record.Status=="Closed"  || complaint.record.Status=="Successful" || complaint.record.Status=="Cancelled" || complaint.record.Status=="My Product on Demand (with sku) created")
                    {
                        complaintsResolved.push(complaint);
                    }
                    else if(complaint.record.Status=="New" || complaint.record.Status=="Awaiting")
                    {
                        complaintsPending.push(complaint);
                        console.log('complaint AGE :');
                        console.log(complaint.age);
                    
                    }
                 
                }

                console.log(complaintsPending);

                response.pendingComplaintsList=complaintsPending;
                response.resolvedComplaintsList=complaintsResolved;

               
                
                component.set("v.indicatorList", response);
                console.log("for indicator list");
                console.log(component.get("v.indicatorList"));

                
                

        }));

    },
    showIcons : function(component, event) {
    }
            
    
        

})