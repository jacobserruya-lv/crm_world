({
    onInit: function (component, event, helper) {
        console.log('onInit Escalation flow');
        var getStoreType = component.get('c.getStoreType');
        $A.enqueueAction(getStoreType);
    },
    getStoreType: function(component, event, helper)
    {
        var OriginOfEscalation = component.get('v.origineOfEscalation');

        console.log(OriginOfEscalation);

        if(OriginOfEscalation=='Digital')
        {

            component.set('v.storeType',"Status__c = 'Open' AND (StoreType__c ='WEB' OR StoreType__c ='CSC')");
        }
        else //retail
        {

            component.set('v.storeType',"Status__c = 'Open' AND StoreType__c ='Store'");


        }
        console.log(component.get('v.sstoreType'));


    },
    
})