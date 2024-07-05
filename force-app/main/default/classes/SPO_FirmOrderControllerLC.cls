/*** Class Name : SPO_FirmOrderController
*   Description: Class handles the transactions related to firm order on order main page
*   Params: oppId => opportunity id used to search for firm order related to it

*   =====================
*   History:
*   First version
***/

global with sharing class SPO_FirmOrderControllerLC {

    @AuraEnabled
    public static User getUser() {
        return [SELECT Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }

    @AuraEnabled
    public static List<SPO_FirmOrder__c> getFirmOrderList(Id oppId) {
        return [SELECT Id,SPO_FirmOrderStatus__c,IsInferiorVmaxDate__c FROM SPO_FirmOrder__c WHERE SPO_BriefName__c = :oppId];
    }

    @AuraEnabled
    public static List<SPO_FirmOrder__c> updateFirmOrderDB(Id oppId){
        System.debug('$$$$ Opportunity sent from Orders brief SPO :' + oppId);

        List<SPO_FirmOrder__c> firmOrderToUpdate = [SELECT Id, Name, SPO_BriefName__c, SPO_BriefNumber__c, SPO_FirmOrderStatus__c, SPO_OrderNumber__c, SPO_FirmOrderNumber__c 
                                                    FROM SPO_FirmOrder__c Where SPO_BriefName__c =:oppId];
        System.debug('$$$ FO to UPDATE'+firmOrderToUpdate);
        
        set<id> firmOrderId = new set<id>();
        if(firmOrderToUpdate.size() > 0){
            for(SPO_FirmOrder__c firmOrder: firmOrderToUpdate){
            System.debug('$$$$ SPO firm order to update in updateFirmOrder method :' + firmOrder);
            System.debug('$$$$ SPO firm order status BEFORE update :' + firmOrder.SPO_FirmOrderStatus__c);// changer condition en distribution in progress & etl status = sen to my PR
                //if(firmOrder.SPO_FirmOrderStatus__c == 'Received in Store' && !firmOrder.SPO_FirmOrderStatus__c.contains('Cancel')){// Dont update the status if it is already 'Received in Store'
                if(firmOrder.SPO_FirmOrderStatus__c == 'Distribution in progress' || firmOrder.SPO_FirmOrderStatus__c == 'Sent to MyPR'){
                    System.debug('$$$$ BEFORE update in IF :' + firmOrder.SPO_FirmOrderStatus__c);
                    firmOrder.SPO_FirmOrderStatus__c = 'Received in Store'; 
                    System.debug('$$$$ AFTER update in IF :' + firmOrder.SPO_FirmOrderStatus__c);
                    firmOrderId.add(firmOrder.Id);//Add opp Id to use in below SOQL below to return opp to lightning componet to update Opp
                }
            
            
            }   
        }
        
        update firmOrderToUpdate;
        
        System.debug('UPDATE DONE');

        return firmOrderToUpdate;
    }

    @AuraEnabled
    public static List<SPO_FirmOrder__c> cancelFirmOrderDB(Id oppId, String who, String stopBriefR, String stopBriefC) {
        System.debug('$$$$ Opportunity sent from Orders brief SPO to cancel:' + oppId);
        System.debug('+++ Who=' + who);
        List<SPO_FirmOrder__c> firmOrderToUpdate = [
                SELECT Id, Name, SPO_BriefName__c, SPO_BriefNumber__c, SPO_TechETLStatus__c, SPO_FirmOrderStatus__c,
                        SPO_OrderNumber__c, SPO_FirmOrderNumber__c
                FROM SPO_FirmOrder__c
                WHERE SPO_BriefName__c =:oppId
        ];
        System.debug('$$$$ FO to update :' + firmOrderToUpdate);

        set<id> firmOrderId = new set<id>();
        if (firmOrderToUpdate.size() > 0) {
            for (SPO_FirmOrder__c firmOrder : firmOrderToUpdate) {
                //System.debug('$$$$ SPO firm order to update in updateFirmOrder method :' + firmOrder);
                System.debug('$$$$ SPO firm order status BEFORE update :' + firmOrder.SPO_FirmOrderStatus__c);
                if (firmOrder.SPO_FirmOrderStatus__c == 'Creation in progress' &&
                        (firmOrder.SPO_TechETLStatus__c == null || firmOrder.SPO_TechETLStatus__c == 'V')) {
                    System.debug('$$$$ DANS le if :' + firmOrder);
                    // Dont update the status if it is already 'Received in Store'
                    firmOrder.SPO_FirmOrderStatus__c = 'Cancelled by store';
                    firmOrder.Cancellation_Reason__c = stopBriefR;
                    firmOrder.Cancellation_Comment__c = stopBriefC;
                    System.debug('$$$$ SPO firm order status AFTEER update :' + firmOrder.SPO_FirmOrderStatus__c);
                    //firmOrderId.add(firmOrder.Id);//Add opp Id to use in below SOQL below to return opp to lightning componet to update Opp
                }
            }
        }
        update firmOrderToUpdate;

        //Display firm order status updated
        for (SPO_FirmOrder__c firmOrder : firmOrderToUpdate) {
            System.debug('$$$$ AFTER Status updated:' + firmOrder.id + firmOrder.SPO_FirmOrderStatus__c);
        }

        Opportunity parentOpptyToUpdate = [SELECT Id, StageName, SPO_Date_Cancelled_by_store__c, TECH_Nb_FO_not_cancelled__c, TECH_Nb_FO__c, TECH_Nb_FO_Creation_in_Progress__c FROM Opportunity Where Id =:oppId Limit 1];

        System.debug(' $$$ Nombre de firm order au statut autre que Cancelled By P or By Store: ' +
                parentOpptyToUpdate.TECH_Nb_FO_not_cancelled__c);

        if (parentOpptyToUpdate.TECH_Nb_FO_not_cancelled__c == 0) {
            System.debug(' $$$ Tous les firm orders sont cancel -> on cancel order too');
            parentOpptyToUpdate.StageName = 'Cancelled by store';
            parentOpptyToUpdate.SPO_Date_Cancelled_by_store__c = system.today();
            parentOpptyToUpdate.SPO_StopBriefReason__c = stopBriefR;
            parentOpptyToUpdate.SPO_StopBriefComment__c = stopBriefC;
            update parentOpptyToUpdate;
        }

        return firmOrderToUpdate;
    }

    @AuraEnabled
    public static String getSORJson() {
        return SPO_OpportunityActionButtonController.getSORJson();
    }

}