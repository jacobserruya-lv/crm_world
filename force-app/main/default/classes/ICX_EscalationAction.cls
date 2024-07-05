/**
    * @description       : invocable method for the flow Escalation Flow
    * @author            : Naomi Baroghel
    * @last modified on  : 22-03-2022
    * @last modified by  : Naomi Baroghel
    * Modifications Log 
    * Ver   Date         Author                               Modification
    * 1.0   27-02-2022  Naomi Baroghel                        Initial Version
    * 2.0   22-03-2022  Naomi Baroghel                        Better Version
   **/

   public class ICX_EscalationAction {
   @InvocableMethod
      public static void getEscalationTeamByCountry(List<String> CaseId) {
         Map<String, String> mapCountryEscalationTeam = new Map<String, String> ();
         Map<Id, String> mapCaseEscalationTeam = new Map<Id, String> ();
         Map<String, Id> mapEscalationTeamNameId = new Map<String, Id>();
         Map<Id, String> mapCaseEscalationTeamId = new Map<Id, String>();

         Set<String> caseCountry = new Set<String> ();
         List<String> predefinedCaseTeamName = new List<String>();
         List<Case> currentCases = [SELECT Id,Country__c,TECH_Country__c FROM Case WHERE Id IN:  CaseId];

         for(Case caseRecord : currentCases){
            system.debug(caseRecord.TECH_Country__c);
            caseCountry.add(caseRecord.TECH_Country__c);
         }

       
         for(CountryMapping__mdt countryMap : [SELECT Iso3Code__c, EscalationTeam__c FROM CountryMapping__mdt WHERE Iso3Code__c IN:  caseCountry AND HasOtherValue__c=False]){
            mapCountryEscalationTeam.put(countryMap.Iso3Code__c ,countryMap.EscalationTeam__c);
         }
         for(Case caseRecord : currentCases){
            mapCaseEscalationTeam.put(caseRecord.Id,mapCountryEscalationTeam.get(caseRecord.TECH_Country__c));             
         }
         
   
         
         if(!mapCaseEscalationTeam.values().isEmpty()) {

            for(CaseTeamTemplate predefinedCaseTeamSelected : [SELECT Id,Name FROM CaseTeamTemplate WHERE Name IN:  mapCaseEscalationTeam.values()])
   
            {
               mapEscalationTeamNameId.put(predefinedCaseTeamSelected.Name,predefinedCaseTeamSelected.Id);
            }
   
            for(Id caseRecord : mapCaseEscalationTeam.keySet())
            {
               mapCaseEscalationTeamId.put(caseRecord,mapEscalationTeamNameId.get(mapCaseEscalationTeam.get(caseRecord)));
            }
         }
         if(!mapCaseEscalationTeamId.values().isEmpty()) {


            CreateCaseTeamTemplateRecord(mapCaseEscalationTeamId);
            notificationForEscalationCaseTeamMembers(mapCaseEscalationTeamId);
         }
      }
      
      public static void CreateCaseTeamTemplateRecord(Map<Id, String> mapCaseEscalationTeamId)
      {

      
         List<CaseTeamTemplateRecord> CaseTeamTemplateRecordList = new List<CaseTeamTemplateRecord> ();

         for(Id caseRecord : mapCaseEscalationTeamId.keySet())
         {
            if(mapCaseEscalationTeamId.get(caseRecord)!=null)
            {

            CaseTeamTemplateRecordList.add(new CaseTeamTemplateRecord(ParentId=caseRecord,TeamTemplateId=mapCaseEscalationTeamId.get(caseRecord)));
            }
         }

         insert CaseTeamTemplateRecordList;  
      }

      public static void notificationForEscalationCaseTeamMembers(Map<Id, String> mapCaseEscalationTeamId)
      {


         Map<String,Set<String>> mapEscalationMember = new  Map<String,Set<String>>();
         Map<Id,String> mapCaseNumber = new  Map<Id,String>();


         for(CaseTeamTemplateMember caseTeamTemplateMember : [Select MemberId,TeamTemplateId FROM CaseTeamTemplateMember WHERE TeamTemplateId IN: mapCaseEscalationTeamId.values()])
         {

            if(!mapEscalationMember.containsKey(caseTeamTemplateMember.TeamTemplateId)){
               mapEscalationMember.put(caseTeamTemplateMember.TeamTemplateId, new Set<String>());

            }
            mapEscalationMember.get(caseTeamTemplateMember.TeamTemplateId).add(caseTeamTemplateMember.MemberId);

         }


         CustomNotificationType notificationType =  [ SELECT Id, DeveloperName   FROM CustomNotificationType  WHERE DeveloperName = 'Notification_for_Escalation_Assignment'];
         Messaging.CustomNotification notification = new Messaging.CustomNotification();

         for(Case currentCase : [SELECT Id,CaseNumber FROM Case WHERE Id IN:  mapCaseEscalationTeamId.keySet()])
         {
            mapCaseNumber.put(currentCase.Id,currentCase.CaseNumber);
         }

         for(id caseRecord : mapCaseEscalationTeamId.keySet()){

            notification.setTitle('New Escalation Assigned to you');
            notification.setBody( 'The user ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() +' assigned to your team this request escalated '+ mapCaseNumber.get(caseRecord) + '.');

            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(caseRecord);


            Set<String> recepientIds = mapEscalationMember.get(mapCaseEscalationTeamId.get(caseRecord));
            try {
               notification.send(recepientIds);
            } catch (Exception e) {}
         }
   }
  
   }