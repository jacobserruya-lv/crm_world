/*	 * @author Keman WU
* @date creation 27/05/2022
* @description Trigger Handler of ShipmentTrackingTrigger 
*/
public class ShipmentTracking_TriggerHandler {   
    
    public static void beforeInsert(List<ShipmentTracking__c> newShipmentTrackingList, Map<id, ShipmentTracking__c> newShipmentTrackingMap) {
        Map<Id,String> mapAccountUser = new Map<Id,String>();
        Map<Id,String> mapCareAccount = new Map<Id,String>();
        set<Id> setCareId = new Set<Id> ();
        for(ShipmentTracking__c myRecord : newShipmentTrackingList){           
            setCareId.add(myRecord.CareService__c);           
        }

        for(CareService__c care :[select id,Client__c from CareService__c where Id in:setCareId]){
            mapCareAccount.put(care.Id,care.Client__c);
        }
        for(User u :[select Id, AccountId from User where AccountId IN :mapCareAccount.values() and IsActive = true]){
            mapAccountUser.put(u.AccountId, u.Id);
        }
        //Change ShipmentTracking Owner
        for(ShipmentTracking__c myRecord : newShipmentTrackingList){        
            if(mapAccountUser.get(mapCareAccount.get(myRecord.CareService__c)) != null){   
           myRecord.OwnerId = mapAccountUser.get(mapCareAccount.get(myRecord.CareService__c));
           system.debug('owner user '+myRecord.OwnerId );
            }
        }
       
    
    }
}