public with sharing class ICX_CampaignClientCAListViewController {
    
    @AuraEnabled (cacheable=true)
    public static List<Map<String, String>> getCAList(Id CampaignId){
        List<Map<String, String>> caList = new List<Map<String, String>>();
        Map<String, Integer> caTargetClientNumberMap = new Map<String, Integer>();
        Map<String, Integer> caContactNumberMap = new Map<String, Integer>();
        Map<String, Integer> caInterestedNumberMap = new Map<String, Integer>();
        Map<String, Integer> caNotInterestedNumberMap = new Map<String, Integer>();
        
        List<AggregateResult> aggregatetargetList = [SELECT Count(Id), AssignedCA__r.Name 
                                                  FROM CampaignMember__c 
                                                  WHERE Campaign__c =:CampaignId 
                                                  GROUP BY AssignedCA__r.Name];
        List<AggregateResult> aggregateContactList = [SELECT Count(Id), AssignedCA__r.Name 
                                                  FROM CampaignMember__c 
                                                  WHERE Campaign__c =:CampaignId AND Contacted__c = 'Yes'
                                                  GROUP BY AssignedCA__r.Name];
        List<AggregateResult> aggregateInterestedList = [SELECT Count(Id), AssignedCA__r.Name
                                                  FROM CampaignMember__c 
                                                  WHERE Campaign__c =:CampaignId AND Interested__c = 'Yes' AND Contacted__c = 'Yes'
                                                  GROUP BY AssignedCA__r.Name];
        List<AggregateResult> aggregateNotInterestedList = [SELECT Count(Id), AssignedCA__r.Name
                                                  FROM CampaignMember__c 
                                                  WHERE Campaign__c =:CampaignId AND Interested__c = 'No' AND Contacted__c = 'Yes'
                                                  GROUP BY AssignedCA__r.Name];

        if(!aggregatetargetList.isEmpty()){
            for(AggregateResult res: aggregatetargetList){
                caTargetClientNumberMap.put((String)res.get('Name'), (Integer)res.get('expr0'));
            }
            for(AggregateResult res : aggregateContactList){
                caContactNumberMap.put((String)res.get('Name'), (Integer)res.get('expr0'));
            }
            for(AggregateResult res : aggregateInterestedList){
                caInterestedNumberMap.put((String)res.get('Name'), (Integer)res.get('expr0'));
            }
            for(AggregateResult res : aggregateNotInterestedList){
                caNotInterestedNumberMap.put((String)res.get('Name'), (Integer)res.get('expr0'));
            }

            for(String name: caTargetClientNumberMap.keySet()){
                Decimal targetClient = caTargetClientNumberMap.get(name);
                Decimal contactedClient = (caContactNumberMap.get(name)!= null)? caContactNumberMap.get(name): 0;
                Decimal InterestedClient = (caInterestedNumberMap.get(name)!= null)? caInterestedNumberMap.get(name): 0;
                Decimal NotInterestedClient = (caNotInterestedNumberMap.get(name)!= null)? caNotInterestedNumberMap.get(name): 0;
                Decimal AchievementRate = (contactedClient/targetClient)*100;
                String AchievementRateString = String.valueOf(AchievementRate.setscale(2)) + '%';

                Map<String, String> resMap = new Map<String, String>{
                    'CA' => name,
                    'TargetedClients' => String.valueOf(targetClient),
                    'ContactedClients' => String.valueOf(contactedClient),
                    'AchievementRate' => AchievementRateString,
                    'Interested' => String.valueOf(InterestedClient),
                    'NotInterested' => String.valueOf(NotInterestedClient)
                };
                caList.add(resMap);

            }
        }

        return caList;
    }
    
    @AuraEnabled (cacheable=true)
    public static Boolean matchExistMember(Id AccountId, Id CampaignId){
        List<CampaignMember__c> cmList = [SELECT Id, Member__c FROM CampaignMember__c 
                                          WHERE Member__c =: AccountId AND Campaign__c =: CampaignId];
        if(cmList.size()>0){
            return true;
        }
        
        return false;
    }
    
}