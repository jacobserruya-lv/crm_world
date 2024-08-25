global class CT_CreateClientListBatch implements Database.Batchable<sObject>, Database.Stateful {
    List<CLI_CliList__c> clListToInsert = new List<CLI_CliList__c>();
    List<CLI_CliList__c> clListForMembers = new List<CLI_CliList__c>();
    Map<Id, List<Id>> membersByCaId = new Map<Id, List<Id>>();
    String type;

    public CT_CreateClientListBatch(List<CLI_CliList__c> clList, Map<Id, List<Id>> membersByCaId) {
        this.membersByCaId = membersByCaId;
        this.clListToInsert = clList;
        this.type = clListToInsert[0].Type__c;
    }

    global List<CLI_CliList__c> start(Database.BatchableContext BC) {
        return clListToInsert;
    }

    global void execute(Database.BatchableContext BC, List<CLI_CliList__c> clList) {
        if (type == 'exclusive') {
            String name = clList[0].Name;
            String offerCode = clList[0].Offer_Code__c;
            String typology = clList[0].Typology__c;
            Date expirationDate = clList[0].ExpirationDate__c;

            List<CLI_CliList__c> existClList = [
                SELECT Id, Name, Active__c, ExpirationDate__c, Description__c, Is_visible_by_CA__c, Typology__c,
                       Type__c, Offer_Code__c, Show_In_Icon__c, TECH_LaunchAddMembersBatch__c, 
                       TECH_CreatedFromTCLScreen__c, OwnerId, IsMasterClientList__c
                FROM CLI_CliList__c
                WHERE IsMasterClientList__c = FALSE
                 AND OwnerId IN :membersByCaId.keySet()
                 AND Name = :name 
                 AND Typology__c = :typology
                 AND Offer_Code__c = :offerCode
                 AND ExpirationDate__c = :expirationDate
            ];

            System.debug('existClList: ' + existClList.size());

            if (existClList.size() > 0) {
                List<CLI_CliList__c> clToUpdate = new List<CLI_CliList__c>();
                List<CLI_CliList__c> tempCl = clList.clone();
                Map<String, CLI_CliList__c> existClMap = new Map<String, CLI_CliList__c>();

                for (CLI_CliList__c cl : existClList) {
                    existClMap.put(cl.OwnerId, cl);
                }

                for (CLI_CliList__c cl : tempCl) {
                    CLI_CliList__c existCl = existClMap.get(cl.OwnerId);

                    if (existCl != null) {
                        System.debug('existCl: ' + existCl);
                        existCl.Show_In_Icon__c = cl.Show_In_Icon__c;
                        clToUpdate.add(existCl);
                        clList.remove(clList.indexOf(cl));
                    }
                }

                if (clList.size() > 0) {
                    insert clList;
                }

                if (clToUpdate.size() > 0) {
                    update clToUpdate;
                    clList.addAll(clToUpdate);
                }

                clListForMembers.addAll(clList);
                System.debug('exclusive clListForMembers:' + clListForMembers.size());
                return;
            }
        }
        
        insert clList;
        clListForMembers.addAll(clList);
        System.debug('clListForMembers:' + clListForMembers.size());
    }  

    global void finish(Database.BatchableContext BC) {
        List<CLM_CliListMember__c> membersList = new List<CLM_CliListMember__c>();
        
        for(CLI_CliList__c cl : clListForMembers) {
            List<Id> idsByCa = membersByCaId.get(cl.OwnerId);

            for (Id memberId : idsByCa) {
                membersList.add(
                    new CLM_CliListMember__c(
                        ClientList__c = cl.Id,
                        Client__c = memberId,
                        TECH_UniqueKey__c = type == 'exclusive' ? memberId + '-' + cl.OwnerId + '-' + cl.Typology__c + '-' + cl.Offer_Code__c + '-' + cl.ExpirationDate__c : null
                    )
                );
            }
        }

        CT_CreateClientMembersBatch CMBatch = new CT_CreateClientMembersBatch(membersList, new List<String>(), type);
        Id jobId = Database.executeBatch(CMBatch, 200);

        Parent_Child_job_id__c PCJ = new Parent_Child_job_id__c(
            Parent_Job_Id__c = BC.getJobId(),
            Job_Id__c = jobId
        );
        insert PCJ;
    }
}