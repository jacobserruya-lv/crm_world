// class VO_Batch_SurveyScoring
// Recalcul du scoring des enqu?tes
// Author : Bernard Wach
// Version initiale : 05/10/2015
// Oct 2016 / Xavier Templet / replace formula fields by apex calculations

global without sharing class VO_BatchSurveyScoring implements Database.Batchable<sObject> {
  
WebService static string startBatch(ID scoreCalcId, integer maxRecords) {
  System.debug('++++++++ ' + maxRecords + ' ' + scoreCalcId);
  VO_BatchSurveyScoring cl = new VO_BatchSurveyScoring(scoreCalcId);
  Integer n = maxRecords == null ? 200 : maxRecords;
    Id batchInstanceId = Database.executeBatch(cl, n);
    return (batchInstanceId != null ? 'OK' : 'KO');   
}

private final string query;
  
// Constructor
global VO_BatchSurveyScoring (ID scoreCalcId) {
  if (scoreCalcId == null) return;
  VO_SurveyScoring__c scoreCalc = [select Id, SurveyType__c, StartDate__c, EndDate__c, ScoringDate__c from VO_SurveyScoring__c where Id = :scoreCalcId limit 1];
  String deb = scoreCalc.StartDate__c.year() + '-' + (scoreCalc.StartDate__c.month() < 10 ? '0' : '') + scoreCalc.StartDate__c.month() + '-' + (scoreCalc.StartDate__c.day() < 10 ? '0' : '') + scoreCalc.StartDate__c.day() ;
  String fin = scoreCalc.EndDate__c.year() + '-' + (scoreCalc.EndDate__c.month() < 10 ? '0' : '') + scoreCalc.EndDate__c.month() + '-' + (scoreCalc.EndDate__c.day() < 10 ? '0' : '') + scoreCalc.EndDate__c.day() ;
  //query = 'select Id, SurveyType__c, Type__c, Scoring__c, TechCSCScoringFormula__c, TechWebScoringFormula__c, TechSalesScoringFormula__c, TechAfterSalesScoringFormula__c, Tech_Sales_Delighted_Scoring__c, Tech_Sales_RA_Scoring__c, Q03Answer__c from VO_Survey__c '
  query = 'Select id, SurveyType__c, Type__c, Scoring__c, Q02Answer__c, Q03Answer__c, Q04Answer__c, Q05Answer__c, Q06Answer__c, Q07Answer__c, Q08Answer__c, Q09Answer__c, Q10Answer__c, Q11Answer__c, Q12Answer__c, Q13Answer__c, Q14Answer__c, Q15Answer__c, Q16Answer__c, Q17Answer__c, Q18Answer__c, Q19Answer__c, Q20Answer__c, Q21Answer__c, Q22Answer__c, Q23Answer__c, Q24Answer__c, Q25Answer__c, Q26Answer__c, Q27Answer__c, Q28Answer__c, Q29Answer__c, Q30Answer__c, Q31Answer__c, Q32Answer__c, Q33Answer__c, Q34Answer__c, Q35Answer__c, Q36Answer__c, Q37Answer__c, Q38Answer__c, Q39Answer__c, Q40Answer__c, Q41Answer__c, Q42Answer__c, Q43Answer__c, Q44Answer__c, Q45Answer__c, Q46Answer__c, Q47Answer__c, Q48Answer__c, Q49Answer__c, Q50Answer__c from VO_survey__c '
        + 'where SurveyType__c = \'' + scoreCalc.SurveyType__c + '\' '
      + 'and AnswerDate__c >= ' + deb + ' and AnswerDate__c <= ' + fin;
  scoreCalc.ScoringDate__c = System.Now();
  update scoreCalc;
}

global Database.querylocator start(Database.BatchableContext BC){
  return Database.getQueryLocator(query);
}

global void finish(Database.BatchableContext info){
  try {
    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      TotalJobItems, CreatedBy.Email
      FROM AsyncApexJob WHERE Id = :info.getJobId()];
    
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    string[] toAddresses = new string[] {a.CreatedBy.Email}; 
    mail.setToAddresses(toAddresses); 
    mail.setSubject('End of score calculation');
    mail.setPlainTextBody ('The score calculation is finished : ' + a.NumberOfErrors + ' errors.');
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }
  catch (Exception e) {}
}

global void execute(Database.BatchableContext info, List<sObject> scope){
  List<VO_Survey__c> ls = new List<VO_Survey__c>();
  for (sObject s : scope) {
    VO_Survey__c su = (VO_Survey__c)s;
        string MyTechScoring = '';
      if (su.SurveyType__c == VO_Utils.VOICE_CSC_SALES) {
            MyTechScoring =VO_Survey.getMyTechCSCScoring(su); 
      }
      else if (su.SurveyType__c == VO_Utils.VOICE_SALES) {
            MyTechScoring = VO_Survey.getMyTechSalesDelightedScoring(su)? System.Label.VO_DelightedClient: VO_Survey.getMyTechSalesRAScoring(su)? System.label.VO_Recovery_Act: (su.Q03Answer__c != null && su.Q03Answer__c.length()<= 2 && su.Q03Answer__c.isNumeric() && Integer.valueof(su.Q03Answer__c) > 8)? System.Label.VO_Promoter: System.Label.VO_Neutral;
      }
      else if (su.SurveyType__c == VO_Utils.VOICE_WEB_SALES) {
            MyTechScoring =VO_Survey.getMyTechWebScoring(su); 
      }
      else if (su.SurveyType__c == VO_Utils.VOICE_AFTER_SALES) {
            MyTechScoring =VO_Survey.getMyTechAfterSalesScoring(su); 
      }
      // Click and Collect + Endless Offer
      else if(su.SurveyType__c == VO_Utils.VOICE_CC_CSC_SALES)
      {
          MyTechScoring = VO_Survey.getMyTechClickAndCollectCSCScoring(su);
      }
      else if(su.SurveyType__c == VO_Utils.VOICE_CC_WEB_SALES)
      {
          MyTechScoring = VO_Survey.getMyTechClickAndCollectWebScoring(su);
      }
      else if(su.SurveyType__c == VO_Utils.VOICE_EO_SALES)
      {
        // TO DO WHEN AVAILABLE
      }


       if (su.Scoring__c != MyTechScoring) {
              su.Scoring__c = MyTechScoring;
              su.Type__c = MyTechScoring;
              ls.add(su);
       }
  }
  if (!ls.isEmpty()) update ls;
}
}