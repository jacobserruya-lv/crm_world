global class IC_BatchPurgeClient implements Database.Batchable<sObject>{
  //Id batchJobId = Database.executeBatch(new IC_batchPurgeClient(), 2000);
  public String query;
   
  
 global database.querylocator start(Database.BatchableContext CD){
     query = 'SELECT Id FROM Account limit 50000';
          
     for (AccoutMassPurge__c setWhereQuery : [select WhereClause1__c,WhereClause2__c,WhereClause3__c from AccoutMassPurge__c limit 1 ]){
         
         if (setWhereQuery.WhereClause1__c <> null){
          	query = 'SELECT Id FROM Account where '+ setWhereQuery.WhereClause1__c +' '+ setWhereQuery.WhereClause2__c +' '+ setWhereQuery.WhereClause3__c +' ';
         }
      }
     
      system.debug('The query is : ' + query);
      return Database.getQueryLocator(query); 
 }

  global void execute(Database.BatchableContext CD, List<sObject> scope){
    try{
        	integer CountPeakSeasonPurge = 0;    
        List<Account> lstClientToUpdate = new List<Account>();
           Map<ID,Account> mapClientInScope = new Map<ID,Account>();
           List<ID> lstClientScopeIDs = new List<ID>();
           
           Set<Id> surveyCltIds = new Set<Id>();
           Set<Id> caseCltIds = new Set<Id>();
           Set<Id> prgCltIds = new Set<Id>();
           Set<Id> oppCltIds = new Set<Id>();
           Set<Id> csCltIds = new Set<Id>();
      
            for(sObject o:scope){
              Account acc = (Account)o;
              mapClientInScope.put(acc.ID,acc); 
                lstClientScopeIDs.add(acc.ID); 
            }
            system.debug('Start Client Scope  : ' + mapClientInScope.size());
           
        for (VO_Survey__c surveyCltId : [SELECT ClientDreamID__c FROM VO_Survey__c where ClientDreamID__c IN : lstClientScopeIDs])
          {
                if (lstClientScopeIDs.contains(surveyCltId.ClientDreamID__c)){
                    lstClientScopeIDs.remove(lstClientScopeIDs.indexOf(surveyCltId.ClientDreamID__c));
                    mapClientInScope.remove(surveyCltId.ClientDreamID__c);
                }
            }           
        system.debug(' Client in Scope Without surveys Open : ' + mapClientInScope.size());
    
        for (Case caseCltId : [SELECT AccountId FROM Case where AccountId IN : lstClientScopeIDs])
          {
              if (lstClientScopeIDs.contains(caseCltId.AccountId)){
                    lstClientScopeIDs.remove(lstClientScopeIDs.indexOf(caseCltId.AccountId));
                    mapClientInScope.remove(caseCltId.AccountId);
                }
          }
            
          system.debug(' Client in Scope Without Case : ' + lstClientScopeIDs.size());
            
         for (Program__c prgCltId : [SELECT AccountId__c FROM Program__c where AccountId__c IN : lstClientScopeIDs]) 
          {
              if (lstClientScopeIDs.contains(prgCltId.AccountId__c)){
                    lstClientScopeIDs.remove(lstClientScopeIDs.indexOf(prgCltId.AccountId__c));
                    mapClientInScope.remove(prgCltId.AccountId__c);
                }
          }
        system.debug(' Client in Scope Without program : ' + lstClientScopeIDs.size());
            
               
      for (Opportunity oppCltId : [SELECT AccountId FROM Opportunity where AccountId IN : lstClientScopeIDs] )
          {
              if (lstClientScopeIDs.contains(oppCltId.AccountId)){
                    lstClientScopeIDs.remove(lstClientScopeIDs.indexOf(oppCltId.AccountId));
                    mapClientInScope.remove(oppCltId.AccountId);
                }
          }
        system.debug(' Client in Scope Without opp : ' + lstClientScopeIDs.size());
        
       for (CareService__c csCltId : [SELECT Client__c FROM CareService__c where Client__c IN : lstClientScopeIDs]) 
          {
              if (lstClientScopeIDs.contains(csCltId.Client__c)){
                    lstClientScopeIDs.remove(lstClientScopeIDs.indexOf(csCltId.Client__c));
                    mapClientInScope.remove(csCltId.Client__c);
                }
          }
        for (Calling_Campaign__c callCampaignCltId : [SELECT Client__c FROM Calling_Campaign__c where client__c IN : lstClientScopeIDs]) 
          {
              if (lstClientScopeIDs.contains(callCampaignCltId.Client__c)){
                    lstClientScopeIDs.remove(lstClientScopeIDs.indexOf(callCampaignCltId.Client__c));
                    mapClientInScope.remove(callCampaignCltId.Client__c);
                }
          }
        system.debug(' Client in Scope Without Calling Campaign : ' + lstClientScopeIDs.size());
         account thisAcc;

        system.debug('End Client Scope  : ' + mapClientInScope.size());
        
        //Option de la valeur a mettre dans le Champs PeackSeasonPurge__c, valeur 0 par default
        string optionChoseForRequest = '0'; 
        for (AccoutMassPurge__c optionChose : [select RequestOption__c from AccoutMassPurge__c limit 1 ]){
          if(optionChose.RequestOption__c <> ''){
              optionChoseForRequest = optionChose.RequestOption__c;
          }
        }
            
            for (ID thisId : lstClientScopeIDs ){
                thisAcc = mapClientInScope.get(thisID);
                thisAcc.PeakSeasonPurge__c = optionChoseForRequest;
                lstClientToUpdate.add(thisAcc);
                CountPeakSeasonPurge = CountPeakSeasonPurge + 1 ;
                
            }
        	system.debug(' Nombre de client flagguer : ' + CountPeakSeasonPurge);
            update lstClientToUpdate;
           
    
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }          
    
}

    global void finish(Database.BatchableContext DC){            
        
            System.debug(' Fin ! ');
        
  }
}