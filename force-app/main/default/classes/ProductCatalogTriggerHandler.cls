public with sharing class ProductCatalogTriggerHandler {
    public static void handleAfterUpdate(List<ProductCatalogue__c> newPCList, Map<Id, ProductCatalogue__c> newPCMap, List<ProductCatalogue__c> oldPCList, Map<Id, ProductCatalogue__c> oldPCMap) {
        
        updateHardsidedFirmOrders(newPCList,oldPCMap);
    }
 public static void updateHardsidedFirmOrders(List<ProductCatalogue__c> newPCList,Map<Id,ProductCatalogue__c> oldPCMap){
        
        List <SPO_FirmOrder__c> listFO = [SELECT Id,SPO_TechETLStatus__c,Creation_Status__c,ProductCatalogue__c,IsInferiorVmaxDate__c FROM SPO_FirmOrder__c WHERE ProductCatalogue__c IN:newPCList AND TECH_Product_Hard_Workflow__c =: true AND Creation_Status__c=:'Technical Data to Define' ];
        List <SPO_FirmOrder__c> listFOUpdated = new List <SPO_FirmOrder__c> ();
            
            for(ProductCatalogue__c pc : newPCList){
               //will update all orders with in technical data to defined if this has been modified in one order
                if (pc.Technical_Data_Defined__c == true && pc.Technical_Data_Defined__c != oldPCMap.get(pc.Id).Technical_Data_Defined__c){
                    
                    for(SPO_FirmOrder__c fo : listFO ){
                        if(fo.IsInferiorVmaxDate__c == true) { //MIY-1721
                            fo.SPO_TechETLStatus__c = 'V'; 
                        } else { 
                            fo.SPO_TechETLStatus__c = 'A';
                        }
						fo.Creation_Status__c = 'Ready to be Sent';
                        fo.SPO_FirmOrderStatus__c = 'Creation in progress';
                        listFOUpdated.add(fo);
                    }
                    
                }
                update listFOUpdated;
           
            }
            

    }         
}