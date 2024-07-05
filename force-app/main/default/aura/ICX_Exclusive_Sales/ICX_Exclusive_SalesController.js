({
	doInit : function(component, event, helper) {
		var action = component.get("c.getExculisveSales");
        action.setParams({
            'recordId' : component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                var result = response.getReturnValue();
                component.set('v.exclusiveSales',result);
                component.set('v.size',result.length);
                
            }

        });
        $A.enqueueAction(action);
        
        
        
	},
    itemsChange: function(component, event, helper) {
        if(component.get('v.size')> 0) {
        
            var  exculsiveSalesName = component.get('v.size') == 1 ? '  ' + component.get('v.exclusiveSales')[0].Offer_Code__c : '  ' + component.get('v.size') + ' Exclusive Experiences';
            var cmpEvent = $A.get('e.c:ICX_ExclusiveSaleInAccountPannel');
            cmpEvent.setParams({"recordId" : component.get('v.recordId'),"exculsiveSalesName": exculsiveSalesName}); 
            cmpEvent.fire();
        }
    },
    copyHardcoreText : function(component, event, helper) {
		var recordId =  event.target.id;
            var exclusiveSale = component.get('v.exclusiveSales').find(element => element.Id === recordId);
        var hiddenInput = document.createElement("input");
        hiddenInput.setAttribute("value", exclusiveSale.Mylv_Url_Short__c);
        document.body.appendChild(hiddenInput);
        hiddenInput.select();
        document.execCommand("copy");
        document.body.removeChild(hiddenInput); 
        /*var orignalLabel = event.getSource().get("v.label");
        event.getSource().set("v.iconName" , 'utility:check');
        event.getSource().set("v.label" , 'copied');*/
    }    
})