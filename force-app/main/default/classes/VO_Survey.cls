/*
* Manage survey creation and updates
* Update the account Id and the store Id depending on the Dream Id and the RMS store code
* Created by BW
* Creation date : 01/10/2015
* Oct 2016 / Xavier Templet / replace formula fields by apex calculations
*/

/*April 2017: BALINK add Class updateTypeDate
Update Type and Last Date voice on related client*/

/* July 2023: updateTypeDate(); function code commented by ouramdane.a
These fields are not used*/

public with sharing class VO_Survey {
    public static void UpdateClientAndStoreId(List<VO_Survey__c> surveyList) {
        List<String> StoreRMSIdList = new List<String>();
        Map<String, Store__c> StoreMap = new Map<String, Store__c>(); 
        List<String> DreamIdList = new List<String>();
        Map<String, Account> accMap = new Map<String, Account>();
        Map<String, String> MergedDreamIdMap = new Map<String, String>();
        List<String> PPList = new List<String>();
        Map<String, PPR_PurchProduct__c> PPIdPPMap = new Map<String, PPR_PurchProduct__c>();
        Map<String, List<PPR_PurchProduct__c>> PPIdPPListMap = new Map<String, List<PPR_PurchProduct__c>>(); 
        List<ID> clientIds = new List<ID>();

        // Search for salutation translations
        List<Schema.PicklistEntry> picklistValues = Account.Salutation.getDescribe().getPicklistValues();
        Map<String, String> salutationMap = new Map<String, String>();
        for (Schema.PicklistEntry pe: picklistValues) salutationMap.put(pe.getValue(), pe.getLabel()); 
        
        // Search for external Ids in the survey
        for (VO_Survey__c su : surveyList) {
            //if (su.AnswerDate__c == null) su.AnswerDate__c = Date.today();
            if (!String.isBlank(su.StoreID__c)) StoreRMSIdList.add(su.StoreID__c);
            if (!String.isBlank(su.DreamIDText__c)) DreamIdList.add(su.DreamIDText__c);
            if (!String.isEmpty(su.IDTransaction__c)) PPList.add(su.IDTransaction__c); 
            // BW - 1 -> 01
            Integer nbQuestions = Integer.valueOf(getVOConfig('NUM OF Q'));
            for (Integer i=1; i<=nbQuestions; i++) {
                String fld = 'Q' + (i < 10 ? '0' : '') + String.valueOf(i) + 'Answer__c';
                String s = (String)su.get(fld);
                if (!String.isEmpty(s) && s.isNumeric() && s.length() == 1) su.put(fld, '0' + s);
            }
        }

        // Client search        
        if (!DreamIdList.isEmpty()) {
            // Search DreamIds in Merged clients
            for (MergedClients__c mc : [select MasterClient__c, Absorbed_DreamId__c from MergedClients__c where Absorbed_DreamId__c in :DreamIdList]) {
                DreamIdList.add(mc.MasterClient__c);
                MergedDreamIdMap.put(mc.MasterClient__c, mc.Absorbed_DreamId__c);               
            }
            for (Account acc : [select Id, DREAMID__c, Salutation, FirstName, LastName, Segmentation__pc 
                                from Account 
                                where DREAMID__c in :DreamIdList]) {
                if (MergedDreamIdMap.get(acc.DREAMID__c) == null) {
                    accMap.put(acc.DREAMID__c, acc);
                    clientIds.add(acc.Id);
                }
                else
                {
                    accMap.put(MergedDreamIdMap.get(acc.DREAMID__c), acc);
                    clientIds.add(acc.Id);
                }                   
            }
        }
        system.debug(clientIds);

        // Search transaction
        if (!PPList.isEmpty()) {
            for (PPR_PurchProduct__c pp : [select TransactionRMSId__c, client__c, DreamIDSA__c, StoreRetailCode__c,SA_Formula__c, SA__c, RMSCAId__c,PurchasedDate__c, WWEmployeeNumber__c
                                            from PPR_PurchProduct__c 
                                            where Client__c in :clientIds])
            //SA_Formula__c - name of the ca
            //RMSCAId__c  - id of the ca
            {
                if (!String.isBlank(pp.TransactionRMSId__c) && pp.Client__c != null && !String.isBlank(pp.StoreRetailCode__c)) {
                    String key = pp.TransactionRMSId__c + pp.Client__c + pp.StoreRetailCode__c;
                    PPIdPPMap.put(key, pp);

                    if(!PPIdPPListMap.containsKey(key))
                        PPIdPPListMap.put(key,new List<PPR_PurchProduct__c>());
                    PPIdPPListMap.get(key).add(pp);
                }

            }
        }
            
        // Store search
        if (!StoreRMSIdList.isEmpty()) {
            for (Store__c st : [select Id, RetailStoreId__c, Name, MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL3__c from Store__c where RetailStoreId__c in :StoreRMSIdList]) {
                StoreMap.put(st.RetailStoreId__c, st);
            }
        }

        // Update Lookup fields     
        for (VO_Survey__c su : surveyList) 
        {
            if (!String.isBlank(su.StoreID__c)) {
                Store__c st = StoreMap.get(su.StoreID__c);
                if (st != null) {
                    su.Store__c = st.Id;
                    su.StoreNameText__c = st.Name;
                    su.MANAGEMENT_ZONE_LEVEL__c = st.MANAGEMENT_ZONE_LEVEL__c;
                    su.MGMT_ZONE_SUB_LEVEL1__c = st.MGMT_ZONE_SUB_LEVEL1__c;
                    su.MGMT_ZONE_SUB_LEVEL2__c = st.MGMT_ZONE_SUB_LEVEL2__c;
                    su.MGMT_ZONE_SUB_LEVEL3__c = st.MGMT_ZONE_SUB_LEVEL3__c;
                }
            }
            if (!String.isBlank(su.DreamIDText__c)) {
                Account acc = accMap.get(su.DreamIDText__c);
                if (acc != null) {
                    su.ClientDreamID__c = acc.Id;
                    su.SegmentationText__c = 'New Client';
                    if (!String.isBlank(acc.Segmentation__pc)) su.SegmentationText__c = acc.Segmentation__pc;

                    String s = salutationMap.get(acc.Salutation);
                    System.debug('----------------' + s);
                    if (s == null) s = '';
                    s += ' ' + acc.LastName + ' ' + acc.FirstName;
                    su.ClientNameText__c = s;
                }               
            }
            su.CAName__c = '';
            su.TECH_CAIds__c='';
            if (!String.isBlank(su.IDTransaction__c) && su.ClientDreamID__c != null && !String.isBlank(su.StoreID__c)) 
            {
                system.debug('enter 1');
                String key = su.IDTransaction__c + su.ClientDreamID__c + su.StoreID__c;
                su.PurchaseProductKey__c = key;
                PPR_PurchProduct__c pp = PPIdPPMap.get(key);

                if(PPIdPPListMap.containsKey(key))
                {
                    for(PPR_PurchProduct__c ppNew : PPIdPPListMap.get(key))
                    {
                        if(ppNew.SA_Formula__c != null)
                        {
                          su.CAName__c += ppNew.SA_Formula__c+ ' ' + '('+ ppNew.RMSCAId__c + ')(' + ppNew.WWEmployeeNumber__c + ')' +';';
                          //to get Ca Ids on Survey
                            if(ppNew.SA__c!=null)  
                             su.TECH_CAIds__c += ppNew.SA__c +';';
                        }

                    }

                    // RMOU : removing duplicates
                    Set<String> s = new Set<String>();
                    s.addAll(su.CAName__c.split(';'));
                    su.CAName__c = String.join(new List<String> (s), ';');

                    for(PPR_PurchProduct__c ppNew : PPIdPPListMap.get(key))
                    {
                        if(pp.PurchasedDate__c!=null)
                        {
                           su.TransactionPurchasedDate__c = pp.PurchasedDate__c;
                           break;
                        }
                    }


                }
                //if (pp != null) su.CAName__c = pp.DreamIDSA__c;    
            }
        }               
    } 
    
        public static void updateGlobalScore(List<VO_Survey__c> surveyList){
        Map<String, Decimal> scorestoUpdate = new Map<String, Decimal>();
        List<String> feedbacksIds = new List<String>();

        for(VO_Survey__c survey: surveyList){
            if(survey.GlobalScore__c == null) {
                feedbacksIds.add(survey.FeedbackID__c);
            }
        }
        List<due__Diduenjoy_Feedback__c> feedbacks = [SELECT id, due__InternalId__c FROM due__Diduenjoy_Feedback__c WHERE due__InternalId__c IN: feedbacksIds]; 
        List<due__Diduenjoy_Answer__c> answers = [SELECT id, due__Diduenjoy_Feedback__c, due__Diduenjoy_Feedback__r.Name, due__Diduenjoy_Feedback__r.due__InternalId__c, due__Step__c, due__Position__c, due__Question_Type__c, due__Score__c 
                                                  FROM due__Diduenjoy_Answer__c 
                                                  WHERE (
                                                    (due__Diduenjoy_Feedback__r.Name like 'CSC Post Contact%' and due__Step__c = 1 AND due__Position__c = 0) 
                                                    or (due__Diduenjoy_Feedback__r.Name like 'Retail Post Purchase%' and due__Step__c = 0 AND due__Position__c = 0) 
                                                    or (due__Diduenjoy_Feedback__r.Name like 'Online Post Delivery%' and due__Step__c = 1 AND due__Position__c = 0) 
                                                    or (due__Diduenjoy_Feedback__r.Name like 'Retail Care Service%' and due__Step__c = 0 AND due__Position__c = 0)) 
                                                    AND due__Question_Type__c = 'rating' AND  due__Diduenjoy_Feedback__r.due__InternalId__c 
                                                    IN: feedbacksIds]; 

        for(due__Diduenjoy_Answer__c answer: answers){
            scorestoUpdate.put(answer.due__Diduenjoy_Feedback__r.due__InternalId__c, answer.due__Score__c);
        }
        for(VO_Survey__c survey: surveyList){
           survey.GlobalScore__c = scorestoUpdate.get(survey.FeedbackID__c);
        }
    }
    
    private static String getVOConfig(String csName) {
        return VO_Config__c.getValues(csName).Value__c;
    } 
    
    public static void updateScoring(List<VO_Survey__c> surveyList)
    {
        List<VO_Survey__c> surveyToUpdate = new List<VO_Survey__c>();
        //List<VO_survey__c> surveys = [Select id, SurveyType__c, TechCSCScoringFormula__c, TechWebScoringFormula__c, TechSalesScoringFormula__c, TechAfterSalesScoringFormula__c, Tech_Sales_Scoring_Formula__c, Tech_Sales_Delighted_Scoring__c, Tech_Sales_RA_Scoring__c, Q20Answer__c, Q04Answer__c, Q03Answer__c from VO_survey__c where id in:surveyList];
        List<VO_survey__c> surveys = [Select id, SurveyType__c, Assign_To__c, Q02Answer__c, Q03Answer__c, Q04Answer__c, Q05Answer__c, Q06Answer__c, Q07Answer__c, Q08Answer__c, Q09Answer__c, Q10Answer__c, Q11Answer__c, Q12Answer__c, Q13Answer__c, Q14Answer__c, Q15Answer__c, Q16Answer__c, Q17Answer__c, Q18Answer__c, Q19Answer__c, Q20Answer__c, Q21Answer__c, Q22Answer__c, Q23Answer__c, Q24Answer__c, Q25Answer__c, Q26Answer__c, Q27Answer__c, Q28Answer__c, Q29Answer__c, Q30Answer__c, Q31Answer__c, Q32Answer__c, Q33Answer__c, Q34Answer__c, Q35Answer__c, Q36Answer__c, Q37Answer__c, Q38Answer__c, Q39Answer__c, Q40Answer__c, Q41Answer__c, Q42Answer__c, Q43Answer__c, Q44Answer__c, Q45Answer__c, Q46Answer__c, Q47Answer__c, Q48Answer__c, Q49Answer__c, Q50Answer__c from VO_survey__c where id in:surveyList];
        for (VO_Survey__c su : surveys) 
        {
          string MyTechScoring = '';
            if (su.SurveyType__c == VO_Utils.VOICE_CSC_SALES) {
                MyTechScoring = getMyTechCSCScoring(su);
                su.SurveyComment__c = su.Q20Answer__c;
            }
            else if (su.SurveyType__c == VO_Utils.VOICE_WEB_SALES ) {
                MyTechScoring = getMyTechWebScoring(su);
                su.SurveyComment__c = su.Q20Answer__c; 
            }
            else if (su.SurveyType__c == VO_Utils.VOICE_SALES) {
                MyTechScoring = getMyTechSalesDelightedScoring(su)? System.Label.VO_DelightedClient: getMyTechSalesRAScoring(su)? System.label.VO_Recovery_Act: (su.Q03Answer__c != null && su.Q03Answer__c.length()<= 2 && su.Q03Answer__c.isNumeric() && Integer.valueof(su.Q03Answer__c) > 8)? System.Label.VO_Promoter: System.Label.VO_Neutral;
                su.SurveyComment__c = su.Q04Answer__c;
            }
            else if (su.SurveyType__c == VO_Utils.VOICE_AFTER_SALES) {
                MyTechScoring = getMyTechAfterSalesScoring(su);
                su.SurveyComment__c = su.Q04Answer__c;  
            }
            // Click and Collect 
            else if (su.SurveyType__c == VO_Utils.VOICE_CC_CSC_SALES) // for CSC
            {
                MyTechScoring = getMyTechClickAndCollectCSCScoring(su);
                su.SurveyComment__c = su.Q04Answer__c; // to be confirmed
            }
            else if (su.SurveyType__c == VO_Utils.VOICE_CC_WEB_SALES) // for Web
            {
                MyTechScoring = getMyTechClickAndCollectWebScoring(su);
                su.SurveyComment__c = su.Q04Answer__c; // to be confirmed
            }

            su.Type__c = MyTechScoring;
            su.InitialScoring__c = MyTechScoring;
            su.Scoring__c = MyTechScoring;

            surveyToUpdate.add(su);
        }
        update surveyToUpdate;
    }
    
     /* *
      *  click and collect and Endless Offer: evaluating the Assigned to value
      * */
    public static void updateAssignedTo(List<VO_Survey__c> surveys)
    {
        for(VO_Survey__c su : surveys)
        {
            if (su.SurveyType__c == VO_Utils.VOICE_CC_CSC_SALES || su.SurveyType__c == VO_Utils.VOICE_CC_WEB_SALES || su.SurveyType__c == VO_Utils.VOICE_EO_SALES) 
            {
                su.Assign_To__c = su.TECH_AssignedToFormula__c; 
            }
        }

    }
   
    
    public static String getMyTechCSCScoring(VO_Survey__c survey) {
    String myScoringResult = '';
       
        if((
            (survey.Q02Answer__c != null && survey.Q02Answer__c.length()<= 2 && survey.Q02Answer__c.isNumeric() && (Integer.valueOf(survey.Q02Answer__c) < 7)) 
            || (survey.Q03Answer__c != null && survey.Q03Answer__c.length()<= 2 && survey.Q03Answer__c.isNumeric() && (Integer.valueOf(survey.Q03Answer__c) < 7)))
          && (
            (survey.Q05Answer__c != null && survey.Q05Answer__c.length()<= 2 && survey.Q05Answer__c.isNumeric() && (Integer.valueOf(survey.Q05Answer__c) < 7)) 
            || (survey.Q06Answer__c != null && survey.Q06Answer__c.length()<= 2 && survey.Q06Answer__c.isNumeric() && (Integer.valueOf(survey.Q06Answer__c) < 7))
            || (survey.Q07Answer__c != null && survey.Q07Answer__c.length()<= 2 && survey.Q07Answer__c.isNumeric() && (Integer.valueOf(survey.Q07Answer__c) < 7))
            || (survey.Q08Answer__c != null && survey.Q08Answer__c.length()<= 2 && survey.Q08Answer__c.isNumeric() && (Integer.valueOf(survey.Q08Answer__c) < 7))
            || (survey.Q09Answer__c != null && survey.Q09Answer__c.length()<= 2 && survey.Q09Answer__c.isNumeric() && (Integer.valueOf(survey.Q09Answer__c) < 7))
            || (survey.Q10Answer__c != null && survey.Q10Answer__c.length()<= 2 && survey.Q10Answer__c.isNumeric() && (Integer.valueOf(survey.Q10Answer__c) < 7))
            || (survey.Q11Answer__c != null && survey.Q11Answer__c.length()<= 2 && survey.Q11Answer__c.isNumeric() && (Integer.valueOf(survey.Q11Answer__c) < 7))
            || (survey.Q12Answer__c != null && survey.Q12Answer__c.length()<= 2 && survey.Q12Answer__c.isNumeric() && (Integer.valueOf(survey.Q12Answer__c) < 7))
      || (survey.Q13Answer__c != null && survey.Q13Answer__c =='No')
            || (survey.Q14Answer__c != null && survey.Q14Answer__c =='No')
            || (survey.Q15Answer__c != null && survey.Q15Answer__c.length()<= 2 && survey.Q15Answer__c.isNumeric() && (Integer.valueOf(survey.Q15Answer__c) < 7))
            || (survey.Q16Answer__c != null && survey.Q16Answer__c.length()<= 2 && survey.Q16Answer__c.isNumeric() && (Integer.valueOf(survey.Q16Answer__c) < 7))
            || (survey.Q17Answer__c != null && survey.Q17Answer__c.length()<= 2 && survey.Q17Answer__c.isNumeric() && (Integer.valueOf(survey.Q17Answer__c) < 7))
            || (survey.Q18Answer__c != null && survey.Q18Answer__c.length()<= 2 && survey.Q18Answer__c.isNumeric() && (Integer.valueOf(survey.Q18Answer__c) < 7))
            || (survey.Q19Answer__c != null && survey.Q19Answer__c.length()<= 2 && survey.Q19Answer__c.isNumeric() && (Integer.valueOf(survey.Q19Answer__c) < 7)))
          ) myScoringResult = 'Recovery Act';

        else if (
      survey.Q03Answer__c != null && survey.Q03Answer__c =='10' 
            && survey.Q02Answer__c != null && survey.Q02Answer__c =='10'
      && survey.Q05Answer__c != null && (survey.Q05Answer__c =='09' || survey.Q05Answer__c =='10')
      && survey.Q06Answer__c != null && (survey.Q06Answer__c =='09' || survey.Q06Answer__c =='10')
      && survey.Q07Answer__c != null && (survey.Q07Answer__c =='09' || survey.Q07Answer__c =='10')
      && survey.Q08Answer__c != null && (survey.Q08Answer__c =='09' || survey.Q08Answer__c =='10')
      && survey.Q09Answer__c != null && (survey.Q09Answer__c =='09' || survey.Q09Answer__c =='10')
      && survey.Q10Answer__c != null && (survey.Q10Answer__c =='09' || survey.Q10Answer__c =='10')
      && survey.Q11Answer__c != null && (survey.Q11Answer__c =='09' || survey.Q11Answer__c =='10')
      && survey.Q12Answer__c != null && (survey.Q12Answer__c =='09' || survey.Q12Answer__c =='10')
      && survey.Q13Answer__c != null && survey.Q13Answer__c =='Yes'
      && survey.Q14Answer__c != null && survey.Q14Answer__c =='Yes'
      && survey.Q15Answer__c != null && (survey.Q15Answer__c =='09' || survey.Q15Answer__c =='10')
      && survey.Q16Answer__c != null && (survey.Q16Answer__c =='09' || survey.Q16Answer__c =='10')
      && survey.Q17Answer__c != null && (survey.Q17Answer__c =='09' || survey.Q17Answer__c =='10')
      && survey.Q18Answer__c != null && (survey.Q18Answer__c =='N/A' || survey.Q18Answer__c =='09' || survey.Q18Answer__c =='10')
      && survey.Q19Answer__c != null && (survey.Q19Answer__c =='N/A' || survey.Q19Answer__c =='09' || survey.Q19Answer__c =='10')
        ) myScoringResult = 'Delighted Client';

        else if (
      survey.Q03Answer__c != null && (survey.Q03Answer__c =='09'|| survey.Q03Answer__c =='10')
        ) myScoringResult = 'Promoter';
        
        else myScoringResult = 'Neutral';
        
    return myScoringResult;
    } 


    public static String getMyTechWebScoring(VO_Survey__c survey) {
    String myScoringResult = '';
        
        if((
            (survey.Q02Answer__c != null && survey.Q02Answer__c.length()<= 2 && survey.Q02Answer__c.isNumeric() && (Integer.valueOf(survey.Q02Answer__c) < 7)) 
            || (survey.Q03Answer__c != null && survey.Q03Answer__c.length()<= 2 && survey.Q03Answer__c.isNumeric() && (Integer.valueOf(survey.Q03Answer__c) < 7)))
          && (
            (survey.Q05Answer__c != null && survey.Q05Answer__c.length()<= 2 && survey.Q05Answer__c.isNumeric() && (Integer.valueOf(survey.Q05Answer__c) < 7)) 
            || (survey.Q06Answer__c != null && survey.Q06Answer__c.length()<= 2 && survey.Q06Answer__c.isNumeric() && (Integer.valueOf(survey.Q06Answer__c) < 7))
            || (survey.Q07Answer__c != null && survey.Q07Answer__c.length()<= 2 && survey.Q07Answer__c.isNumeric() && (Integer.valueOf(survey.Q07Answer__c) < 7))
            || (survey.Q08Answer__c != null && survey.Q08Answer__c.length()<= 2 && survey.Q08Answer__c.isNumeric() && (Integer.valueOf(survey.Q08Answer__c) < 7))
            || (survey.Q09Answer__c != null && survey.Q09Answer__c.length()<= 2 && survey.Q09Answer__c.isNumeric() && (Integer.valueOf(survey.Q09Answer__c) < 7))
            || (survey.Q10Answer__c != null && survey.Q10Answer__c.length()<= 2 && survey.Q10Answer__c.isNumeric() && (Integer.valueOf(survey.Q10Answer__c) < 7))
            || (survey.Q11Answer__c != null && survey.Q11Answer__c.length()<= 2 && survey.Q11Answer__c.isNumeric() && (Integer.valueOf(survey.Q11Answer__c) < 7))
            || (survey.Q12Answer__c != null && survey.Q12Answer__c.length()<= 2 && survey.Q12Answer__c.isNumeric() && (Integer.valueOf(survey.Q12Answer__c) < 7))
      || (survey.Q13Answer__c != null && survey.Q13Answer__c =='No')
            || (survey.Q14Answer__c != null && survey.Q14Answer__c =='No')
            || (survey.Q15Answer__c != null && survey.Q15Answer__c.length()<= 2 && survey.Q15Answer__c.isNumeric() && (Integer.valueOf(survey.Q15Answer__c) < 7))
            || (survey.Q16Answer__c != null && survey.Q16Answer__c.length()<= 2 && survey.Q16Answer__c.isNumeric() && (Integer.valueOf(survey.Q16Answer__c) < 7))
            || (survey.Q17Answer__c != null && survey.Q17Answer__c.length()<= 2 && survey.Q17Answer__c.isNumeric() && (Integer.valueOf(survey.Q17Answer__c) < 7))
            || (survey.Q18Answer__c != null && survey.Q18Answer__c.length()<= 2 && survey.Q18Answer__c.isNumeric() && (Integer.valueOf(survey.Q18Answer__c) < 7))
            || (survey.Q19Answer__c != null && survey.Q19Answer__c.length()<= 2 && survey.Q19Answer__c.isNumeric() && (Integer.valueOf(survey.Q19Answer__c) < 7)))
          ) myScoringResult = 'Recovery Act';

        else if (
      survey.Q03Answer__c != null && survey.Q03Answer__c =='10' 
            && survey.Q02Answer__c != null && survey.Q02Answer__c =='10'
      && survey.Q05Answer__c != null && (survey.Q05Answer__c =='09' || survey.Q05Answer__c =='10')
      && survey.Q06Answer__c != null && (survey.Q06Answer__c =='09' || survey.Q06Answer__c =='10')
      && survey.Q07Answer__c != null && (survey.Q07Answer__c =='09' || survey.Q07Answer__c =='10')
      && survey.Q08Answer__c != null && (survey.Q08Answer__c =='09' || survey.Q08Answer__c =='10')
      && survey.Q09Answer__c != null && (survey.Q09Answer__c =='09' || survey.Q09Answer__c =='10')
      && survey.Q10Answer__c != null && (survey.Q10Answer__c =='09' || survey.Q10Answer__c =='10')
      && survey.Q11Answer__c != null && (survey.Q11Answer__c =='09' || survey.Q11Answer__c =='10')
      && survey.Q12Answer__c != null && (survey.Q12Answer__c =='09' || survey.Q12Answer__c =='10')
      && survey.Q13Answer__c != null && survey.Q13Answer__c =='Yes'
      && survey.Q14Answer__c != null && survey.Q14Answer__c =='Yes'
      && survey.Q15Answer__c != null && (survey.Q15Answer__c =='09' || survey.Q15Answer__c =='10')
      && survey.Q16Answer__c != null && (survey.Q16Answer__c =='09' || survey.Q16Answer__c =='10')
      && survey.Q17Answer__c != null && (survey.Q17Answer__c =='09' || survey.Q17Answer__c =='10')
      && survey.Q18Answer__c != null && (survey.Q18Answer__c =='N/A' || survey.Q18Answer__c =='09' || survey.Q18Answer__c =='10')
      && survey.Q19Answer__c != null && (survey.Q19Answer__c =='N/A' || survey.Q19Answer__c =='09' || survey.Q19Answer__c =='10')
        ) myScoringResult = 'Delighted Client';

        else if (
      survey.Q03Answer__c != null && (survey.Q03Answer__c =='09'|| survey.Q03Answer__c =='10')
        ) myScoringResult = 'Promoter';
        
        else myScoringResult = 'Neutral';
        
    return myScoringResult;
    }
    
    public static String getMyTechAfterSalesScoring(VO_Survey__c survey) {
    String myScoringResult = '';
        
        if((
            (survey.Q02Answer__c != null && survey.Q02Answer__c.length()<= 2 && survey.Q02Answer__c.isNumeric() && (Integer.valueOf(survey.Q02Answer__c) < 7)) 
            || (survey.Q03Answer__c != null && survey.Q03Answer__c.length()<= 2 && survey.Q03Answer__c.isNumeric() && (Integer.valueOf(survey.Q03Answer__c) < 7)))
          && (
            (survey.Q07Answer__c != null && survey.Q07Answer__c.length()<= 2 && survey.Q07Answer__c.isNumeric() && (Integer.valueOf(survey.Q07Answer__c) < 7)) 
            || (survey.Q08Answer__c != null && survey.Q08Answer__c.length()<= 2 && survey.Q08Answer__c.isNumeric() && (Integer.valueOf(survey.Q08Answer__c) < 7))
            || (survey.Q09Answer__c != null && survey.Q09Answer__c.length()<= 2 && survey.Q09Answer__c.isNumeric() && (Integer.valueOf(survey.Q09Answer__c) < 7))
            || (survey.Q10Answer__c != null && survey.Q10Answer__c.length()<= 2 && survey.Q10Answer__c.isNumeric() && (Integer.valueOf(survey.Q10Answer__c) < 7))
            || (survey.Q11Answer__c != null && survey.Q11Answer__c.length()<= 2 && survey.Q11Answer__c.isNumeric() && (Integer.valueOf(survey.Q11Answer__c) < 7))
            || (survey.Q12Answer__c != null && survey.Q12Answer__c.length()<= 2 && survey.Q12Answer__c.isNumeric() && (Integer.valueOf(survey.Q12Answer__c) < 7))
            || (survey.Q13Answer__c != null && survey.Q13Answer__c.length()<= 2 && survey.Q13Answer__c.isNumeric() && (Integer.valueOf(survey.Q13Answer__c) < 7))
            || (survey.Q14Answer__c != null && survey.Q14Answer__c.length()<= 2 && survey.Q14Answer__c.isNumeric() && (Integer.valueOf(survey.Q14Answer__c) < 7))
            || (survey.Q15Answer__c != null && survey.Q15Answer__c.length()<= 2 && survey.Q15Answer__c.isNumeric() && (Integer.valueOf(survey.Q15Answer__c) < 7))
            || (survey.Q16Answer__c != null && survey.Q16Answer__c.length()<= 2 && survey.Q16Answer__c.isNumeric() && (Integer.valueOf(survey.Q16Answer__c) < 7)))
           ) myScoringResult = 'Recovery Act';
        
        else if (
            (survey.Q03Answer__c != null && survey.Q03Answer__c.length()<= 2 && survey.Q03Answer__c.isNumeric() && (Integer.valueOf(survey.Q03Answer__c) > 8)) 
           ) myScoringResult = 'Promoter';
        
        else myScoringResult = 'Neutral';
        
      return myScoringResult;
    }
    
    public static Boolean getMyTechSalesDelightedScoring(VO_Survey__c survey) {
    Boolean myScoringResult = false;
        String Q19_40 ='';
        
        if(survey.Q19Answer__c != null && survey.Q19Answer__c != '' && survey.Q19Answer__c != null) Q19_40 = survey.Q19Answer__c;
        else if (survey.Q40Answer__c != null && survey.Q40Answer__c != '' && survey.Q40Answer__c != null) Q19_40 = survey.Q40Answer__c;

        if (
            survey.Q02Answer__c != null && survey.Q02Answer__c =='10'
      && survey.Q10Answer__c != null && (survey.Q10Answer__c =='N/A' || survey.Q10Answer__c =='09' || survey.Q10Answer__c =='10')
      && survey.Q11Answer__c != null && (survey.Q11Answer__c =='N/A' || survey.Q11Answer__c =='09' || survey.Q11Answer__c =='10')
      && survey.Q14Answer__c != null && (survey.Q14Answer__c =='N/A' || survey.Q14Answer__c =='09' || survey.Q14Answer__c =='10')
      && survey.Q15Answer__c != null && (survey.Q15Answer__c =='N/A' || survey.Q15Answer__c =='09' || survey.Q15Answer__c =='10')
      && survey.Q16Answer__c != null && (survey.Q16Answer__c =='N/A' || survey.Q16Answer__c =='09' || survey.Q16Answer__c =='10')
      && survey.Q17Answer__c != null && (survey.Q17Answer__c =='N/A' || survey.Q17Answer__c =='09' || survey.Q17Answer__c =='10')
      && survey.Q18Answer__c != null && (survey.Q18Answer__c =='N/A' || survey.Q18Answer__c =='09' || survey.Q18Answer__c =='10')
      && (Q19_40 =='N/A' || Q19_40 =='09' || Q19_40 =='10')
      && survey.Q41Answer__c != null && (survey.Q41Answer__c =='N/A' || survey.Q41Answer__c =='09' || survey.Q41Answer__c =='10')
      && survey.Q22Answer__c != null && (survey.Q22Answer__c =='N/A' || survey.Q22Answer__c =='09' || survey.Q22Answer__c =='10')
      && survey.Q23Answer__c != null && (survey.Q23Answer__c =='N/A' || survey.Q23Answer__c =='09' || survey.Q23Answer__c =='10')
      && survey.Q28Answer__c != null && (survey.Q28Answer__c =='N/A' || survey.Q28Answer__c =='09' || survey.Q28Answer__c =='10')
        ) myScoringResult = true;

      return myScoringResult;
    }        
    
    public static Boolean getMyTechSalesRAScoring(VO_Survey__c survey) {
    Boolean myScoringResult = false;
        String Q19_40 ='';
        
        if(survey.Q19Answer__c != null && survey.Q19Answer__c != '' && survey.Q19Answer__c != null) Q19_40 = survey.Q19Answer__c;
        else if (survey.Q40Answer__c != null && survey.Q40Answer__c != '' && survey.Q40Answer__c != null) Q19_40 = survey.Q40Answer__c;

        if((
            (survey.Q02Answer__c != null && survey.Q02Answer__c.length()<= 2 && survey.Q02Answer__c.isNumeric() && (Integer.valueOf(survey.Q02Answer__c) < 7)) 
            || (survey.Q03Answer__c != null && survey.Q03Answer__c.length()<= 2 && survey.Q03Answer__c.isNumeric() && (Integer.valueOf(survey.Q03Answer__c) < 7)))
          && (
            (survey.Q10Answer__c != null && survey.Q10Answer__c.length()<= 2 && survey.Q10Answer__c.isNumeric() && (Integer.valueOf(survey.Q10Answer__c) < 7)) 
            || (survey.Q11Answer__c != null && survey.Q11Answer__c.length()<= 2 && survey.Q11Answer__c.isNumeric() && (Integer.valueOf(survey.Q11Answer__c) < 7))
            || (survey.Q14Answer__c != null && survey.Q14Answer__c.length()<= 2 && survey.Q14Answer__c.isNumeric() && (Integer.valueOf(survey.Q14Answer__c) < 7))
            || (survey.Q15Answer__c != null && survey.Q15Answer__c.length()<= 2 && survey.Q15Answer__c.isNumeric() && (Integer.valueOf(survey.Q15Answer__c) < 7))
            || (survey.Q16Answer__c != null && survey.Q16Answer__c.length()<= 2 && survey.Q16Answer__c.isNumeric() && (Integer.valueOf(survey.Q16Answer__c) < 7))
            || (survey.Q17Answer__c != null && survey.Q17Answer__c.length()<= 2 && survey.Q17Answer__c.isNumeric() && (Integer.valueOf(survey.Q17Answer__c) < 7))
            || (survey.Q18Answer__c != null && survey.Q18Answer__c.length()<= 2 && survey.Q18Answer__c.isNumeric() && (Integer.valueOf(survey.Q18Answer__c) < 7))
            || (Q19_40.length()<= 2 && Q19_40.isNumeric() && (Integer.valueOf(Q19_40) < 7))
            || (survey.Q41Answer__c != null && survey.Q41Answer__c.length()<= 2 && survey.Q41Answer__c.isNumeric() && (Integer.valueOf(survey.Q41Answer__c) < 7))
            || (survey.Q22Answer__c != null && survey.Q22Answer__c.length()<= 2 && survey.Q22Answer__c.isNumeric() && (Integer.valueOf(survey.Q22Answer__c) < 7))
            || (survey.Q24Answer__c != null && survey.Q24Answer__c.length()<= 2 && survey.Q24Answer__c.isNumeric() && (Integer.valueOf(survey.Q24Answer__c) < 7))
            || (survey.Q26Answer__c != null && survey.Q26Answer__c.length()<= 2 && survey.Q26Answer__c.isNumeric() && (Integer.valueOf(survey.Q26Answer__c) < 7))
            || (survey.Q28Answer__c != null && survey.Q28Answer__c.length()<= 2 && survey.Q28Answer__c.isNumeric() && (Integer.valueOf(survey.Q28Answer__c) < 7)))
          ) myScoringResult = true;
        
        return myScoringResult;
    }        
    
    /**
     * Click and Collect CSC scoring
     * */
    public static String getMyTechClickAndCollectCSCScoring(VO_Survey__c survey)
    {
        string scoring= '';
        if(((survey.Q02Answer__c != null && survey.Q02Answer__c.isNumeric() && (Integer.valueOf(survey.Q02Answer__c) <= 6))|| (survey.Q03Answer__c != null && survey.Q03Answer__c.isNumeric() && (Integer.valueOf(survey.Q03Answer__c) <= 6)))
           &&
           (survey.Q11Answer__c != null && survey.Q11Answer__c.isNumeric() && (Integer.valueOf(survey.Q11Answer__c) <= 6))
            ||
           (survey.Q12Answer__c != null && survey.Q12Answer__c.isNumeric() && (Integer.valueOf(survey.Q12Answer__c) <= 6))
            ||
           (survey.Q13Answer__c != null && survey.Q13Answer__c.isNumeric() && (Integer.valueOf(survey.Q13Answer__c) <= 6))
            ||
           (survey.Q14Answer__c != null && survey.Q14Answer__c.isNumeric() && (Integer.valueOf(survey.Q14Answer__c) <= 6))
           ||
           (survey.Q17Answer__c != null && survey.Q17Answer__c.isNumeric() && (Integer.valueOf(survey.Q17Answer__c) <= 6))
           ||
           (survey.Q23Answer__c != null && survey.Q23Answer__c.isNumeric() && (Integer.valueOf(survey.Q23Answer__c) <= 6))
           ||
           (survey.Q24Answer__c != null && survey.Q24Answer__c.isNumeric() && (Integer.valueOf(survey.Q24Answer__c) <= 6))
           ||
           (survey.Q26Answer__c != null && survey.Q26Answer__c.isNumeric() && (Integer.valueOf(survey.Q26Answer__c) <= 6))
           ||
           (survey.Q27Answer__c != null && survey.Q27Answer__c.isNumeric() && (Integer.valueOf(survey.Q27Answer__c) <= 6))
           ||
           (survey.Q28Answer__c != null && survey.Q28Answer__c.isNumeric() && (Integer.valueOf(survey.Q28Answer__c) <= 6))
           ||
           (survey.Q34Answer__c != null && survey.Q34Answer__c.isNumeric() && (Integer.valueOf(survey.Q34Answer__c) <= 6)))
           
        {
            scoring = System.label.VO_Recovery_Act;
        }
        else if ((survey.Q02Answer__c != null && survey.Q02Answer__c.isNumeric() && (Integer.valueOf(survey.Q02Answer__c) == 10))
                &&
               (survey.Q11Answer__c != null && (survey.Q11Answer__c.isNumeric() && Integer.valueOf(survey.Q11Answer__c) >= 9 || survey.Q11Answer__c == 'N/A'))
                &&
               (survey.Q12Answer__c != null && (survey.Q12Answer__c.isNumeric() && Integer.valueOf(survey.Q12Answer__c) >= 9 || survey.Q12Answer__c == 'N/A'))
                &&
               (survey.Q13Answer__c != null && (survey.Q13Answer__c.isNumeric() && Integer.valueOf(survey.Q13Answer__c) >= 9 || survey.Q13Answer__c == 'N/A'))
                &&
               (survey.Q14Answer__c != null && (survey.Q14Answer__c.isNumeric() && Integer.valueOf(survey.Q14Answer__c) >= 9 || survey.Q14Answer__c == 'N/A'))
                &&
               (survey.Q17Answer__c != null && (survey.Q17Answer__c.isNumeric() && Integer.valueOf(survey.Q17Answer__c) >= 9 || survey.Q17Answer__c == 'N/A'))
                &&
               (survey.Q23Answer__c != null && (survey.Q23Answer__c.isNumeric() && Integer.valueOf(survey.Q23Answer__c) >= 9 || survey.Q23Answer__c == 'N/A'))
                &&
               (survey.Q24Answer__c != null && (survey.Q24Answer__c.isNumeric() && Integer.valueOf(survey.Q24Answer__c) >= 9 || survey.Q24Answer__c == 'N/A'))
                &&
               (survey.Q26Answer__c != null && (survey.Q26Answer__c.isNumeric() && Integer.valueOf(survey.Q26Answer__c) >= 9 || survey.Q26Answer__c == 'N/A'))
                &&
               (survey.Q27Answer__c != null && (survey.Q27Answer__c.isNumeric() && Integer.valueOf(survey.Q27Answer__c) >= 9 || survey.Q27Answer__c == 'N/A'))
                &&
               (survey.Q28Answer__c != null && (survey.Q28Answer__c.isNumeric() && Integer.valueOf(survey.Q28Answer__c) >= 9 || survey.Q28Answer__c == 'N/A'))
                &&
               (survey.Q34Answer__c != null && (survey.Q34Answer__c.isNumeric() && Integer.valueOf(survey.Q34Answer__c) >= 9 || survey.Q34Answer__c == 'N/A')))
        {
            scoring = System.label.VO_DelightedClient;
        }
        else if((survey.Q03Answer__c != null && survey.Q03Answer__c.isNumeric() && (Integer.valueOf(survey.Q03Answer__c) >= 9))
        )
        {
            scoring = System.label.VO_Promoter;  
        }
        else
        {
            scoring = System.label.VO_Neutral;
        }
        
        return scoring;
    }
    
     /**
     * Click and Collect WEB scoring
     * */
    public static String getMyTechClickAndCollectWebScoring(VO_Survey__c survey)
    {
        string scoring= '';
        if(((survey.Q02Answer__c != null && survey.Q02Answer__c.isNumeric() && (Integer.valueOf(survey.Q02Answer__c) <= 6))|| (survey.Q03Answer__c != null && survey.Q03Answer__c.isNumeric() && (Integer.valueOf(survey.Q03Answer__c) <= 6)))
           &&
           (survey.Q10Answer__c != null && survey.Q10Answer__c.isNumeric() && (Integer.valueOf(survey.Q10Answer__c) <= 6))
            ||
           (survey.Q12Answer__c != null && survey.Q12Answer__c.isNumeric() && (Integer.valueOf(survey.Q12Answer__c) <= 6))
            ||
           (survey.Q13Answer__c != null && survey.Q13Answer__c.isNumeric() && (Integer.valueOf(survey.Q13Answer__c) <= 6))
            ||
           (survey.Q14Answer__c != null && survey.Q14Answer__c.isNumeric() && (Integer.valueOf(survey.Q14Answer__c) <= 6))
           ||
           (survey.Q17Answer__c != null && survey.Q17Answer__c.isNumeric() && (Integer.valueOf(survey.Q17Answer__c) <= 6))
           ||
           (survey.Q23Answer__c != null && survey.Q23Answer__c.isNumeric() && (Integer.valueOf(survey.Q23Answer__c) <= 6))
           ||
           (survey.Q24Answer__c != null && survey.Q24Answer__c.isNumeric() && (Integer.valueOf(survey.Q24Answer__c) <= 6))
           ||
           (survey.Q26Answer__c != null && survey.Q26Answer__c.isNumeric() && (Integer.valueOf(survey.Q26Answer__c) <= 6))
           ||
           (survey.Q27Answer__c != null && survey.Q27Answer__c.isNumeric() && (Integer.valueOf(survey.Q27Answer__c) <= 6))
           ||
           (survey.Q28Answer__c != null && survey.Q28Answer__c.isNumeric() && (Integer.valueOf(survey.Q28Answer__c) <= 6))
           ||
           (survey.Q34Answer__c != null && survey.Q34Answer__c.isNumeric() && (Integer.valueOf(survey.Q34Answer__c) <= 6)))
           
        {
            scoring = System.label.VO_Recovery_Act;
        }
        else if ((survey.Q02Answer__c != null && survey.Q02Answer__c.isNumeric() && (Integer.valueOf(survey.Q02Answer__c) == 10))
                &&
               (survey.Q10Answer__c != null && (survey.Q10Answer__c.isNumeric() && Integer.valueOf(survey.Q10Answer__c) >= 9 || survey.Q10Answer__c == 'N/A'))
                &&
               (survey.Q12Answer__c != null && (survey.Q12Answer__c.isNumeric() && Integer.valueOf(survey.Q12Answer__c) >= 9 || survey.Q12Answer__c == 'N/A'))
                &&
               (survey.Q13Answer__c != null && (survey.Q13Answer__c.isNumeric() && Integer.valueOf(survey.Q13Answer__c) >= 9 || survey.Q13Answer__c == 'N/A'))
                &&
               (survey.Q14Answer__c != null && (survey.Q14Answer__c.isNumeric() && Integer.valueOf(survey.Q14Answer__c) >= 9 || survey.Q14Answer__c == 'N/A'))
                &&
               (survey.Q17Answer__c != null && (survey.Q17Answer__c.isNumeric() && Integer.valueOf(survey.Q17Answer__c) >= 9 || survey.Q17Answer__c == 'N/A'))
                &&
               (survey.Q23Answer__c != null && (survey.Q23Answer__c.isNumeric() && Integer.valueOf(survey.Q23Answer__c) >= 9 || survey.Q23Answer__c == 'N/A'))
                &&
               (survey.Q24Answer__c != null && (survey.Q24Answer__c.isNumeric() && Integer.valueOf(survey.Q24Answer__c) >= 9 || survey.Q24Answer__c == 'N/A'))
                &&
               (survey.Q26Answer__c != null && (survey.Q26Answer__c.isNumeric() && Integer.valueOf(survey.Q26Answer__c) >= 9 || survey.Q26Answer__c == 'N/A'))
                &&
               (survey.Q27Answer__c != null && (survey.Q27Answer__c.isNumeric() && Integer.valueOf(survey.Q27Answer__c) >= 9 || survey.Q27Answer__c == 'N/A'))
                &&
               (survey.Q28Answer__c != null && (survey.Q28Answer__c.isNumeric() && Integer.valueOf(survey.Q28Answer__c) >= 9 || survey.Q28Answer__c == 'N/A'))
                &&
               (survey.Q34Answer__c != null && (survey.Q34Answer__c.isNumeric() && Integer.valueOf(survey.Q34Answer__c) >= 9 || survey.Q34Answer__c == 'N/A')))
        {
            scoring = System.label.VO_DelightedClient;
        }
        else if((survey.Q03Answer__c != null && survey.Q03Answer__c.isNumeric() && (Integer.valueOf(survey.Q03Answer__c) >= 9))
        )
        {
            scoring = System.label.VO_Promoter;  
        }
        else
        {
            scoring = System.label.VO_Neutral;
        }
        
        return scoring;
    }
    public static void updateTechStoreDelivery(List<VO_Survey__c> surveys) {
        
        Map<String,String> mapstore = new  Map<String, String>();
        List<String> storecodeList = new List<String>();
        for(VO_Survey__c su : surveys) {
            if (String.isnotBlank(su.STOREDELIVERY__c)) {
                storecodeList.add(su.STOREDELIVERY__c );
            }
        }

        for(Store__c  str : [select ShortName__c ,RetailStoreId__c from Store__c  where RetailStoreId__c = : storecodeList]){
            mapstore.put(str.RetailStoreId__c ,str.ShortName__c);
        }

        for(VO_Survey__c su : surveys) {
           su.TECHStore_Delivery_del__c = '';
           if (String.isnotBlank(su.STOREDELIVERY__c) && mapstore.containskey(su.STOREDELIVERY__c)){
            su.TECHStore_Delivery_del__c = mapstore.get(su.STOREDELIVERY__c);
           }    
        }   
    }

    public static void updateTypeDate(List<VO_Survey__c> surveyList) {
        /*Map<String,Account> clientToUpdate = new Map<String,Account>();
        List<VO_Survey__c> surveys = [Select id,Type__c, AnswerDate__c,ClientDreamID__c, ClientDreamID__r.LastVoiceDate__pc,
                          ClientDreamID__r.LastVoiceType__pc from VO_Survey__c where id in: surveyList];
        for(VO_Survey__c survey : surveys)  {
            Account client = new Account(Id=survey.ClientDreamID__c);
            if( clientToUpdate.get(survey.ClientDreamID__c) != null ){
                if( survey.AnswerDate__c > clientToUpdate.get(survey.ClientDreamID__c).LastVoiceDate__pc ){
                  client.LastVoiceType__pc=survey.Type__c;
                    client.LastVoiceDate__pc = survey.AnswerDate__c;
                    clientToUpdate.put(survey.ClientDreamID__c,client); 
                }
            }
            else if( survey.ClientDreamID__c != null 
                  && (survey.AnswerDate__c > survey.ClientDreamID__r.LastVoiceDate__pc  || survey.ClientDreamID__r.LastVoiceDate__pc == null )){
            client.LastVoiceDate__pc = survey.AnswerDate__c;
            client.LastVoiceType__pc=survey.Type__c;
              clientToUpdate.put(survey.ClientDreamID__c,client);
             }
            
        }
        if(clientToUpdate.size()>0)
            update clientToUpdate.values();*/
    }


    public static void sendPushVO(List<VO_Survey__c> surveys){
         List<VO_Survey__c> surveyList = [Select id,Type__c, TECH_CAIds__c,ClientDreamID__c, OwnerId,ClientName__c from VO_Survey__c where id in: surveys];
         
        List<Push_Notification_Item__c>pushList=new List<Push_Notification_Item__c>();
        Set<String> ownerIds = new Set<String>();
        Map<String,Set<String>> voCaIdsMap =new Map<String,Set<String>> ();

        if(Test.isRunningTest()){
            if(IM_Notifications__c.getInstance('en_US')==null){
                IM_Notifications__c IMN =  new IM_Notifications__c(Name='en_US',Client_List__c='A new client List was assigned to you : {0}',
                Exceptional_Purchase__c='The client {0} has a new Exceptional Purchase Product : {1} $',Survey__c='A new Survey was created by: {0}',Clients_Reassigned__c='Clients have been reassigned to you {0}');
                insert IMN;
            }
        }
        
        for(VO_Survey__c vosur:surveyList){
            List<String> voCaIdsList = vosur.TECH_CAIds__c != null && vosur.TECH_CAIds__c != ''? vosur.TECH_CAIds__c.split(';') : null;
            Set<String> voCaIds = new Set<String>();
            if (voCaIdsList != null && voCaIdsList.size() > 0){
                voCaIds.addAll(voCaIdsList);
            }
            if(voCaIds.size() > 0){
                voCaIdsMap.put(vosur.Id,voCaIds);
                ownerIds.addAll(voCaIds);
            }
        }

        Map<Id,User> userMap = new Map<ID, User>([SELECT Id, LanguageLocaleKey,(Select Id,Manager__c, Manager__r.LanguageLocaleKey From TeamMembers__r) From User Where Id IN : ownerIds]);
        
        for(VO_Survey__c vosur:surveyList){
            if(voCaIdsMap.get(vosur.Id)!=null){
                for(String ownerId : voCaIdsMap.get(vosur.Id)){
                    if (vosur.Type__c == 'Recovery Act'){
                        if (userMap.get(ownerId).TeamMembers__r != null && userMap.get(ownerId).TeamMembers__r.size()>0){
                            for (TeamMember__c tm : userMap.get(ownerId).TeamMembers__r){
                            pushList.add(createPNInstance(vosur,tm.Manager__c,tm.Manager__r.LanguageLocaleKey,false));
                            }
                        } 
                    } else{
                        pushList.add(createPNInstance(vosur,ownerId,userMap.get(ownerId).LanguageLocaleKey,false));
                    }
                }
            
            }
        }

        if(pushList.size()>0){
            insert pushList;
        }

    }
    public static Push_Notification_Item__c createPNInstance(VO_Survey__c vosur,String ownerId, String lang,Boolean isRecoveryAct){
        String placeholder = '';
        if(isRecoveryAct){
            placeholder= ((IM_Notifications__c.getInstance(lang))!=null?
                        IM_Notifications__c.getInstance(lang).SurveyManager__c:
                        IM_Notifications__c.getInstance('en_US').SurveyManager__c);
        } else{
            placeholder= ((IM_Notifications__c.getInstance(lang))!=null?
                        IM_Notifications__c.getInstance(lang).Survey__c:
                        IM_Notifications__c.getInstance('en_US').Survey__c);
        }
        
        
        List<String> fillers = new String[]{vosur.ClientName__c};

        Push_Notification_Item__c pushObj= new Push_Notification_Item__c();
        pushObj.Body__c=String.format(placeholder, fillers);
        pushObj.Type__c = 'Voice';
        pushObj.ObjectId__c = vosur.Id;
        pushObj.UserRecipient__c = (Id)ownerId;


        return pushObj;

    }
    
    public static void updateOwnerName(List<VO_Survey__c> surveyList){
        Map<String,String> namesWW = new Map<String,String>();
        Set<String> wwNumbers = new Set<String>();
        
        for(VO_Survey__c v : surveyList){
            if(String.isNotEmpty(v.AdvisorWWId__c)){
                wwNumbers.add(v.AdvisorWWId__c);
            }
            
        }
        List<User> users = [SELECT Id, Name, WWEmployeeNumber__c FROM User WHERE WWEmployeeNumber__c IN:  wwNumbers];

        for(User u : users){
            namesWW.put(u.WWEmployeeNumber__c, u.Name);
        }

        for(VO_Survey__c v : surveyList){
            if(String.isNotEmpty(v.AdvisorWWId__c) && namesWW.containsKey(v.AdvisorWWId__c)){
                v.CAName__c = namesWW.get(v.AdvisorWWId__c);
            }
           
        }
    }
}