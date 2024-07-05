/**
    About
    -----
    Description: Batch to Create Client List Members for Lists created on Targeted Client list page
    Create date: July 2016

    Details
    -------
    On Targeted Client List page we create only Lists and we populate a field with all client Ids to add the list
    This batch will run once an hour to create these list members. 
    This improve performance of Targted Client List page

    Update History
    --------------
    July 2016 / Created by Balink
    
    Issues / TODOs
    --------------
    
    
*/
global class IC_BatchCreateListMembers implements Database.Batchable<sObject>{
    global database.querylocator start(Database.BatchableContext CD){
        string query  = 'SELECT Id, TECH_TempAccountIds__c, Typology__c, Offer_Code__c FROM CLI_CliList__c WHERE TECH_LaunchAddMembersBatch__c = true';
        return Database.getQueryLocator(query);   
    } 
    
    global void execute(Database.BatchableContext CD, list<CLI_CliList__c> cliLists){
        map<string, set<string>> listToMemberMap = new map<string, set<string>>();
        list<CLM_CliListMember__c> memberList = new list<CLM_CliListMember__c>();
        list<Exclusive_Experience__c> xxprList = new list<Exclusive_Experience__c>();

        // Extracting the CLM query from the query locator to prevent INVALID QUERY LOCATOR errors
        List<CLM_CliListMember__c> clientListMembers = [SELECT id, Client__c, ClientList__c FROM CLM_CliListMember__c WHERE ClientList__c IN :cliLists];

        
        // Extracting all the DreamIDs from Account that will be inserted as Exclusive Experience records
        list<string> clientIdsTotal = new List<String>();
        Map<String, String> pcIdDreamIdMap = new Map<String, String>();
        Map<String, String> pcIdAccIdMap = new Map<String, String>();
        for(CLI_CliList__c cliList : cliLists){
            if(cliList.TECH_TempAccountIds__c != null && cliList.Typology__c != null && cliList.Offer_Code__c != null){
                list<string> clientIdsTemp = cliList.TECH_TempAccountIds__c.split('!');
                clientIdsTotal.addall(clientIdsTemp);
            }
        }
        if(clientIdsTotal.size()>0){
            // remove blank and null values to prevent long query
            set<string> clientIdsSet = new set<string>(clientIdsTotal);
            clientIdsSet.remove('');
            clientIdsSet.remove(null);
            List<Account> accForXXPRList = [SELECT Id, PersonContactId, DREAMID__c FROM Account WHERE PersonContactId IN :clientIdsSet];            
            if(accForXXPRList.size()>0){
                for(Account accForXXPR : accForXXPRList){
                    pcIdDreamIdMap.put(accForXXPR.PersonContactId, accForXXPR.DREAMID__c);
                    pcIdAccIdMap.put(accForXXPR.PersonContactId, accForXXPR.Id);
                }
            }
        }
        

        try{
            for(CLI_CliList__c cliList : cliLists){
                set<string> membersId = new set<string>();
                for(CLM_CliListMember__c cliMem : clientListMembers){
                    if (cliMem.ClientList__c == cliList.id){
                         membersId.add(cliMem.Client__c);
                    }
                }                
                listToMemberMap.put(cliList.Id, membersId);
            }
            
            for(CLI_CliList__c cliList : cliLists){
                //the new client list is not splitted with ! and has his own batch for creating members
                if(cliList.TECH_TempAccountIds__c != null && cliList.TECH_TempAccountIds__c.contains('!')){
                    list<string> clientIds = cliList.TECH_TempAccountIds__c.split('!'); 
                    for(string clientId : clientIds){
                        set<string> existingMembers = listToMemberMap.get(cliList.id);
                        if(String.isNotBlank(clientId) && !existingMembers.contains(clientId)){
                            existingMembers.add(clientId);
                            memberList.add(new CLM_CliListMember__c(ClientList__c = cliList.id, Client__c = clientId));
                            if(pcIdAccIdMap.get(clientId) != null && pcIdDreamIdMap.get(clientId) != null && cliList.Typology__c != null && cliList.Offer_Code__c != null){
                                xxprList.add(new Exclusive_Experience__c(
                                Account_Id__c = pcIdAccIdMap.get(clientId),
                                Dream_Id__c = pcIdDreamIdMap.get(clientId),
                                Typology__c = cliList.Typology__c,
                                Offer_Code__c = cliList.Offer_Code__c
                                ));    
                            }                            
                        }
                    } 
                }  
                cliList.TECH_TempAccountIds__c = '';
                cliList.TECH_DoNotLaunchWorkflow__c = false;
                cliList.TECH_LaunchAddMembersBatch__c = false;
                cliList.Active__c = true;
            }
            
            update cliLists;
            insert memberList;
            if(xxprList.size()>0){
                Database.insert(xxprList, false);
            }
        }
        catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext CD){}

}