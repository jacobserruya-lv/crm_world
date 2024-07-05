({
    initEvents: function(){
        const SF_TABS = "SF_Tabs";
        const SF_LAST_TAB = "SF_LastTab";
        let tabId = Math.random();
        try{
            // store the tabId
            window.sessionStorage.tabId = tabId;
            console.log('+++ Session Storage : Current tabId', sessionStorage.tabId);
            // add TabId to local Storage
            let tabs = [];
            let sfTabs = window.localStorage.getItem(SF_TABS);
            console.log('+++ Local Storage - GET ITEM : SF_TABS', sfTabs);
            if(sfTabs !== undefined && sfTabs !== null){
                tabs = JSON.parse(sfTabs);
            }
            tabs.push(tabId);
            console.log('+++ Local Storage - SET ITEM : SF_TABS', JSON.stringify(tabs));
            window.localStorage.setItem(SF_TABS, JSON.stringify(tabs)); 
            console.log('+++ Local Storage - SET ITEM  : SF_LAST_TAB',tabId);
            window.localStorage.setItem(SF_LAST_TAB, tabId);  
            console.log('+++ Local Storage - GET ITEM : SF_TABS', window.localStorage.getItem(SF_TABS));
            // before close: remove tabId from Tabs list in LocalSTorage
            window.addEventListener("beforeunload", function(e){
                e.preventDefault();
                let tabs = [];
                let tabId = window.sessionStorage.tabId;
                let sfTabs = window.localStorage.getItem(SF_TABS);
                console.log('+++ Local Storage - GET ITEM SF_TABS', sfTabs);
                
                if(sfTabs !== undefined && sfTabs !== null){
                    tabs = JSON.parse(sfTabs);
                    // remove the value
                    let filterdTabs = tabs.filter(e => e != tabId); // not the same type so do not use ===
                    // store update array
                    console.log('+++ Local Storage - SET ITEM  SF_TABS', JSON.stringify(filterdTabs));
                    window.localStorage.setItem(SF_TABS, JSON.stringify(filterdTabs)); 
                    // remove tabId from lastTabId
                    
                    if(tabId == window.localStorage.getItem(SF_LAST_TAB)){
                        console.log('+++ Local Storage - GET ITEM: SF_LAST_TAB ', tabId);
                        console.log('+++ Local Storage : SF_LAST_TAB  === tabId');

                        if(filterdTabs.length > 0){
                            console.log('+++ Local Storage - SET ITEM : SF_LAST_TAB ', filterdTabs[0]);
                            window.localStorage.setItem(SF_LAST_TAB, filterdTabs[0]);
                        }
                        else{
                            console.log('+++ Local Storage - REMOVE ITEM : SF_LAST_TAB');
                            window.localStorage.removeItem(SF_LAST_TAB);
                        }   
                    }
                }
                e.returnValue = '';
            }, true); 
            
            document.addEventListener("visibilitychange", function() {
                if (document.visibilityState === 'visible') {
                    console.log('+++  Local Storage - Event Visibility Change && visibilitystate  === visible');
                 
                    let tabId = window.sessionStorage.tabId;
                    if(tabId !== null){
                        console.log('+++  Local Storage - SET ITEM : SF_LAST_TAB', tabId);
                        window.localStorage.setItem(SF_LAST_TAB, tabId); 
                    }
                }
            });
        }catch(e){
            console.error('ERROR', e);
        }   
    }, 
    sleep: function (milliseconds) {
        const date = Date.now();
        let currentDate = null;
        do {
            currentDate = Date.now();
        } while (currentDate - date < milliseconds);
    },
    openTab: function(component, recordId, setHighlight){
        console.log('+++ OpenTab()');
        if(recordId == null) return;

        let workspaceAPI = component.find("workspace"); 
        workspaceAPI.getAllTabInfo().then(function(tabs) {
            let tabId;
            console.log('+++ All Tabs '+ JSON.stringify(tabs));
            if(tabs != null){     
                for (let i = 0; i < tabs.length; i++) {
                    let currentTab = tabs[i].tabId;
                    let tabRecordId = tabs[i].recordId;
                    console.log('+++ TabId: '+ currentTab);
                    console.log('+++ RecordId: '+ tabRecordId);

                    if(tabRecordId == recordId){
                        tabId = currentTab;
                        console.log('+++ Tab with same RecordId found');
                        break;
                    }
                }
            }
            workspaceAPI.openTab({
                recordId: recordId,
                focus: true 
            });
            // Notify the CA that a new email is available
            if(tabId != undefined && setHighlight !== false){
                workspaceAPI.setTabHighlighted({
                    tabId: tabId,
                    highlighted: true,
                    options: {
                        pulse: true,
                        state: "warning"
                    }
                })
                .catch(function(error) {
                    console.log('+++ hightlight Error: '+error);
                });
            }
        })
        .catch(function(error) {
            console.log('+++ Worspace API error: '+error);
        });
 
    },
    checkCurentTab: function(){
        const SF_TABS = "SF_Tabs";
        const SF_LAST_TAB = "SF_LastTab";

        let tabId = window.sessionStorage.tabId;
        let lastTab = window.localStorage.getItem(SF_LAST_TAB);
        console.log("+++ TabId: ", tabId);
        console.log("+++ lastTabId: ", lastTab);
        if(lastTab !== undefined && lastTab !== null){
            console.log("+++ TabId == lastTab : ", tabId == lastTab);

            if(tabId == lastTab){
                return true;
            }
        }
        else{
            let sfTabs = window.localStorage.getItem(SF_TABS);
            if(sfTabs !== undefined && sfTabs !== null){
                let tabs = tabs = JSON.parse(sfTabs);
                console.log("+++ TabId == tabs[0] : ",tabId == tabs[0]);
                if(tabId == tabs[0]){
                    return true;
                }
            }
        }
        return false;
    },
    getTask: function (component, interactionId, isOutbound) {
        let action = component.get("c.getTaskId");
        let nbRetry = component.get("v.nbRetry");
        let clienteling = component.get("v.clienteling");
        let monitoring = component.get("v.monitoring");
        let isMonitoring = monitoring ? 1 : 0;
        let isClienteling = (clienteling && isOutbound) ? 1 : 0;
        let recordId = null;
        let taskParam = {
            "interactionId": interactionId,
            "isClienteling": isClienteling,
            "isMonitoring": isMonitoring
        };
        console.log('+++ getTask interactionId: ', interactionId, ' With Params: ', taskParam);
        
        action.setParams(taskParam);
        action.setCallback(this, function(response){
            let state = response.getState();
            console.log('### STATE '+ state);
            if (state === "SUCCESS") {
                console.log('### SUCCESS');
                recordId = response.getReturnValue();
                component.set("v.recordId", recordId);
                console.log('### Task ID : '+recordId);
                
                if(recordId == null && nbRetry > 0){
                    nbRetry--;
                    this.sleep(1500);
                    console.log('### RETRY ');
                    console.log('### nbRetry left : '+ nbRetry);
                    $A.enqueueAction(action);
                }
                
                if(recordId != null && ! isMonitoring){ 
                    this.openTab(component, recordId, false);
               	}
            }
            else if(state == "ERROR"){
                let errors = response.getError();                       
               	console.error('+++ ERROR '+errors[0].message);   
            }
        });   
        this.sleep(1500);
        $A.enqueueAction(action);
    },
    updateCase: function(component, caseId, conversationId, participantId) {
        console.log('+++ Call Controller Update Case');
        let record = null;
        let action = component.get("c.updateCase");
        action.setParams({
            "caseId": caseId,
            "conversationId": conversationId,
            "participantId": participantId,
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                record = response.getReturnValue();
                console.log('+++ SUCCESS update Case: ', record);
                if(record != null){
                    component.set("v.recordId", record.Id);
                    this.openTab(component, record.Id, record.Origin === 'Email');
                }  
            }
            else if(state == "ERROR"){
                let errors = response.getError();                       
                console.error('+++ ERROR '+errors[0].message); 
            }
        });   
        $A.enqueueAction(action);
    },
    updateCaseOwner: function (component, conversationId) {
        console.log('+++ Call Controller Update Case Owner');
        let action = component.get("c.setCaseOwnerToInitialQueue");
        action.setParams({
            "conversationId": conversationId
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                let caseId = response.getReturnValue();
                console.log('+++ SUCCESS update Case OwnerId', caseId);
            }
            else if(state == "ERROR"){
                let errors = response.getError();                       
                console.error('+++ ERROR '+errors[0].message); 
            }   
        });   
        $A.enqueueAction(action);
    },
    getSettings: function (component) {
        console.log('+++ Get custom settings');
        let action = component.get("c.getSettings");
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                let settings = response.getReturnValue(); 
                console.log('+++ SUCCESS Get Settings', settings);

                let clientelingId = settings.clientelingStatusId;
                let monitoringId = settings.monitoringStatusId;
                let nbRetry = settings.retryLimit;            
                (clientelingId != null) ? component.set("v.clientelingId", clientelingId) : '';    
                (monitoringId != null) ? component.set("v.monitoringId", monitoringId) : '';
                (nbRetry != null) ? component.set("v.nbRetry", nbRetry) : ''; 
                
                console.log('+++ Attributes value:',{
                    clientelingId: component.get("v.clientelingId"),    
                    monitoringId: component.get("v.monitoringId"),
                    nbRetry: component.get("v.nbRetry")
                });
            }
            else if(state == "ERROR"){
                let errors = response.getError();                       
                console.error('+++ ERROR '+errors[0].message); 
            }  
         
        });   
        $A.enqueueAction(action);
    },
})