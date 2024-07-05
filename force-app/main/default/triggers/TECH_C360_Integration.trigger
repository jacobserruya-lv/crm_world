/***************************************************************************************************
* @File Name          : C360_Tech_Event__e.apxt
* @Description        : This Trigger was created for the C360 Event Flow (From SF TO C360)
* @Author             : Imad.alsidchikh@vo2-consultant.com
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 07-05-2022  
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       07-05-2022         Imad.alsidchikh@vo2-consultant.com     Initial Version
*****************************************************************************************************/
trigger TECH_C360_Integration on C360_Tech_Event__e (after insert) {
    List<TECH_IntegrationManager__c> techIntRecordToUpdate = new List<TECH_IntegrationManager__c>();
    map<String, C360_Tech_Event__e> mapEvent = new map<String, C360_Tech_Event__e>();
    Set<Id> RecordsId = new Set<Id>();
    try{
        For(C360_Tech_Event__e evtRecord : Trigger.new){
            RecordsId.add(evtRecord.Tech_Integration_Id__c);
            mapEvent.put(evtRecord.Tech_Integration_Id__c,evtRecord);
        }
        List<TECH_IntegrationManager__c> techIntRecord = [SELECT Id,Done__c,EventUuid__c ,ReplayId__c,StartTime__c from TECH_IntegrationManager__c where Id IN : RecordsId]; 
        for(TECH_IntegrationManager__c te :techIntRecord){
            C360_Tech_Event__e tes= mapEvent.get(te.Id);
            te.Done__c = true;
            te.Error__c = false;
            te.EventUuid__c = tes.EventUuid;
            te.ReplayId__c = tes.ReplayId;
            te.Duration__c = Decimal.valueOf(system.now().getTime() - te.StartTime__c.getTime()) / 1000;
            te.Gouverneurs_limites_Event__c = TR_C360_IntegrationManager_Utils.getCurrentOrgLimits();
            techIntRecordToUpdate.add(te);   
        }   
        Update(techIntRecordToUpdate);
    }catch(Exception e) {
        Map<String, String> logParams = new Map<String, String>{
            'apex_class'=>'TECH_C360_Integration',
                'apex_Method'=>'eventTriggerAfterInsert', 
                'apex_Limits' => TR_C360_IntegrationManager_Utils.getCurrentOrgLimits(),
                'application'=>TR_Constants.APPEVENT,
                'logLevel'=>'ERROR',
                'hasError'=>'true',
                'error_Message'=>e.getStackTraceString() + '\n\n' + e.getMessage() + '\n\nlineNumber:' + e.getLineNumber(),
                'Object_Type'=>'C360_Tech_Event__e',
                'logType'=>'Outgoing_flow'};
                    database.insert(TR_C360_Utils.CreateLog(logParams));
    }
}