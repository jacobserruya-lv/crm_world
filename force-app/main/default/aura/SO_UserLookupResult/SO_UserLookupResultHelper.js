({
	itemSelected : function(component, event, helper) {
        var target = event.target;   
        var SelIndex = helper.getIndexFrmParent(target,helper,"data-selectedIndex");  

        if(SelIndex){
            var serverResult = component.get("v.server_result");
            var selItem = serverResult[SelIndex];
            if(selItem.val){
                component.set("v.selItem",selItem);
                component.set("v.selEmail", selItem.val);
                component.set("v.last_ServerResult",serverResult);
                component.set("v.user", selItem.obj);
                
                /*var caSelectedEvt = $A.get("e.c:SO_CASelected");
                caSelectedEvt.setParams({
                    "caName":selItem.val
                });
                caSelectedEvt.fire();*/
            } 

            if(selItem.text){
                component.set("v.selName",selItem.text);
            }
            component.set("v.server_result",null); 
            //console.log("this is selItem in itemSelected :" + JSON.stringify(selItem));
            //console.log("this is selItem.val in itemSelected :" + selItem.val);
        } 
	}, 
    serverCall : function(component, event, helper) {  
        var target = event.target;  
        var searchText = target.value; 
        var last_SearchText = component.get("v.last_SearchText");
        //Escape button pressed 
        //if (event.keyCode == 27 || !searchText.trim()) { 
        //    helper.clearSelection(component, event, helper);
        //}else if(searchText.trim() != last_SearchText  && /\s+$/.test(searchText) ){ 
        if(searchText.trim() != last_SearchText){ 
            //Save server call, if last text not changed
            //Search only when space character entered
         
            var objectName = component.get("v.objectName");
            var field_API_text = component.get("v.field_API_text");
            var field_API_val = component.get("v.field_API_val");
            var field_API_search = component.get("v.field_API_search");
            var limit = component.get("v.limit");
            
            var action = component.get('c.searchDB');
            action.setStorable();
            console.log('storeCode:', component.get('v.storeCode'));
            action.setParams({
                objectName : objectName,
                fld_API_Text : field_API_text,
                fld_API_Val : field_API_val,
                lim : limit, 
                fld_API_Search : field_API_search,
                searchText : searchText,
                filter : 'AND IsActive=true ' +
                    'AND (NOT Profile.Name LIKE \'%identity%\') ' +
                    'AND DefaultStore__c = \'' + component.get('v.storeCode') + '\'',
            });
    
            action.setCallback(this,function(a){
                this.handleResponse(a,component,helper);
            });
            
            component.set("v.last_SearchText",searchText.trim());
            //console.log('Server call made');
            $A.enqueueAction(action); 
        }else if(searchText && last_SearchText && searchText.trim() == last_SearchText.trim()){ 
            component.set("v.server_result",component.get("v.last_ServerResult"));
            //console.log('Server call saved');
        }         
	},
    handleResponse : function (res,component) {
        if (res.getState() === 'SUCCESS') {
            var retObj = JSON.parse(res.getReturnValue());
            //console.log("Response from server :" + JSON.stringify(retObj));
            //var caEmail;
            //for(var ca in retObj){
                //console.log("This is ca in responseStr " + retObj[ca].val);
                //caEmail = retObj[ca].val
            //}
            //console.log("CA Email " + caEmail);

            if(retObj.length <= 0){
                var noResult = JSON.parse('[{"text":"No Results Found"}]');
                component.set("v.server_result",noResult); 
            	component.set("v.last_ServerResult",noResult);
            }else{
                component.set("v.server_result",retObj); 
            	component.set("v.last_ServerResult",retObj);
                component.set("v.user",retObj.obj); 
            }  
        }else if (res.getState() === 'ERROR'){
            var errors = res.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log(errors[0].message);
                }
            } 
        }
    },
    getIndexFrmParent : function(target,helper,attributeToFind){
        //User can click on any child element, so traverse till intended parent found
        var SelIndex = target.getAttribute(attributeToFind);
        while(!SelIndex){
            target = target.parentNode ;
			SelIndex = helper.getIndexFrmParent(target,helper,attributeToFind);           
        }
        return SelIndex;
    },
    clearSelection: function(component, event, helper){
        component.set("v.selItem", null);
        component.set("v.server_result", null);
        component.set("v.user", null);
    },
})