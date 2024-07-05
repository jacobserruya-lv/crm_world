/**
 * @description       : 
 * @author            : peyo basso
 * @group             : 
 * @last modified on  : 31-05-2022
 * @last modified by  : PEYO BASSO
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   31-05-2022   peyo basso   Initial Version  
**/
public with sharing class Tr_ExclusiveCampaignOrder_Handler {

    public static void handleTrigger(List<Exclusive_Campaign_Order__c> newList, Map<Id, Exclusive_Campaign_Order__c> newMap,  System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT{
              //  checkSerialNumberExists(newList[0]);
            }
            when BEFORE_UPDATE{
              //  checkSerialNumberExists(newList[0]);
            }
            
        }
    }
 
 static public Boolean checkIfUserHasAssignedPermissionSet(id userid, String permissionSetName) {
    List<PermissionSetAssignment> psas = [ select Id from PermissionSetAssignment where PermissionSetId IN ( select Id from PermissionSet where Name = :permissionSetName) and AssigneeId =:userid];
    return psas.size() > 0;
}
 
 @AuraEnabled(Cacheable=true)
 public static List <Quota__c> getArtyStats() {
     Id CurrentUserId=UserInfo.getUserId();
     List<User> Userinfos= [select id,username,tolabel(MANAGEMENT_ZONE_LEVEL__c),country__c,	tolabel(MGMT_ZONE_SUB_LEVEL1__c),tolabel(DefaultStore__c) from user where id=:CurrentUserId limit 1];
     string ManagementZonelevel=Userinfos[0].DefaultStore__c;
     string Country=Userinfos[0].country__c;
     string Zone=Userinfos[0].MANAGEMENT_ZONE_LEVEL__c;


     System.debug('ManagementZonelevel*****' +ManagementZonelevel);
     System.debug('Country*****' +Country);
     System.debug('Zone*****' +Zone);


     Boolean hasPermission =checkIfUserHasAssignedPermissionSet(CurrentUserId,'ArtyCappucines_Corporate');
     List<Quota__c> contList =new List<Quota__c>();
     if(hasPermission){
        contList = [ SELECT id,Zone_LVL__c,Name,Store__c,Store__r.Name,	Exclusive_Campaign_Product__c,Exclusive_Campaign_Product__r.Name,toLabel(MANAGEMENT_ZONE_LEVEL__c), Reserved__c,Serial_Number__c
        FROM Quota__c 
         ];
     }else{
        if(country!=null && (country.contains('CHINA')||country.contains('KOREA'))){
         contList = [ SELECT id,Name,Zone_LVL__c,	TECH_ZONE__c ,Exclusive_Campaign_Product__c,Status__c,Store__r.Name,Store__r.StoreCountry__c,Store_Country__c,Exclusive_Campaign_Product__r.Name,toLabel(MANAGEMENT_ZONE_LEVEL__c), Reserved__c,Serial_Number__c
                                FROM Quota__c where Status__c='Available' and TECH_ZONE__c =:country  /*and Store__r.Name=:ManagementZonelevel*/
                                 ];
                                 System.debug('ManagementZonelevel*****' +ManagementZonelevel);

                                }
                            else{
                                if(Zone=='ASIA NORTH' ){
                                 
                                contList = [ SELECT id,TECH_ZONE__c ,Zone_LVL__c,Name,Status__c,	Exclusive_Campaign_Product__c,Store__r.Name,Store_Country__c,Exclusive_Campaign_Product__r.Name,toLabel(MANAGEMENT_ZONE_LEVEL__c), Reserved__c,Serial_Number__c
                                FROM Quota__c where Status__c='Available' and tolabel(MANAGEMENT_ZONE_LEVEL__c)=:Zone and TECH_ZONE__c ='13'
                                 ];
                                }else{
                                    contList = [ SELECT id,Name,Status__c,Zone_LVL__c,	Exclusive_Campaign_Product__c,Store__r.Name,Store_Country__c,Exclusive_Campaign_Product__r.Name,toLabel(MANAGEMENT_ZONE_LEVEL__c), Reserved__c,Serial_Number__c
                                    FROM Quota__c where Status__c='Available' and tolabel(MANAGEMENT_ZONE_LEVEL__c)=:Zone
                                     ];  
                                }

                            }
                        }
     return contList;
 }  

 @AuraEnabled(Cacheable=true)
 public static integer getproductsAvailable() {
    Id CurrentUserId=UserInfo.getUserId();
    List<User> Userinfos= [select id,username,tolabel(MANAGEMENT_ZONE_LEVEL__c),country__c,	tolabel(MGMT_ZONE_SUB_LEVEL1__c),tolabel(DefaultStore__c) from user where id=:CurrentUserId limit 1];
    string ManagementZonelevel=Userinfos[0].DefaultStore__c;
    string Country=Userinfos[0].country__c;
    string Zone=Userinfos[0].MANAGEMENT_ZONE_LEVEL__c;

   integer NbproductsAvailables=0;

    System.debug('ManagementZonelevel*****' +ManagementZonelevel);
    System.debug('Country*****' +Country);
    System.debug('Zone*****' +Zone);


    Boolean hasPermission =checkIfUserHasAssignedPermissionSet(CurrentUserId,'ArtyCappucines_Corporate');
    List<Quota__c> contList =new List<Quota__c>();
    if(hasPermission){
       contList = [ SELECT id,Name,Store__c,Store__r.Name,	Exclusive_Campaign_Product__c,Exclusive_Campaign_Product__r.Name,toLabel(MANAGEMENT_ZONE_LEVEL__c), Reserved__c,Serial_Number__c
       FROM Quota__c 
        ];
           NbproductsAvailables=contList.size();

    }else{
       if(country!=null && (country.contains('CHINA')||country.contains('KOREA'))){
        contList = [ SELECT id,Name,TECH_ZONE__c ,Zone_LVL__c,	Exclusive_Campaign_Product__c,Status__c,Store__r.Name,Store__r.StoreCountry__c,Store_Country__c,Exclusive_Campaign_Product__r.Name,toLabel(MANAGEMENT_ZONE_LEVEL__c), Reserved__c,Serial_Number__c
                               FROM Quota__c where Status__c='Available' and TECH_ZONE__c =:country  /*and Store__r.Name=:ManagementZonelevel*/
                                ];
                                System.debug('ManagementZonelevel*****' +ManagementZonelevel);
  NbproductsAvailables=contList.size();

                               }
                           else{
                               if(Zone=='ASIA NORTH' ){
                                
                               contList = [ SELECT id,Zone_LVL__c,Name,Status__c,TECH_ZONE__c ,	Exclusive_Campaign_Product__c,Store__r.Name,Store_Country__c,Exclusive_Campaign_Product__r.Name,toLabel(MANAGEMENT_ZONE_LEVEL__c), Reserved__c,Serial_Number__c
                               FROM Quota__c where Status__c='Available' and tolabel(MANAGEMENT_ZONE_LEVEL__c)=:Zone and TECH_ZONE__c ='13'
                                ];
                                   NbproductsAvailables=contList.size();

                               }else{
                                   contList = [ SELECT id,Zone_LVL__c,Name,Status__c,	Exclusive_Campaign_Product__c,Store__r.Name,Store_Country__c,Exclusive_Campaign_Product__r.Name,toLabel(MANAGEMENT_ZONE_LEVEL__c), Reserved__c,Serial_Number__c
                                   FROM Quota__c where Status__c='Available' and tolabel(MANAGEMENT_ZONE_LEVEL__c)=:Zone
                                    ];  
                                       NbproductsAvailables=contList.size();

                               }

                           }
                       }
    return NbproductsAvailables;

} 

 @AuraEnabled(Cacheable=true)
 public static integer getproductsAll() {
    Id CurrentUserId=UserInfo.getUserId();
    List<User> Userinfos= [select id,username,tolabel(MANAGEMENT_ZONE_LEVEL__c),country__c,	tolabel(MGMT_ZONE_SUB_LEVEL1__c),tolabel(DefaultStore__c) from user where id=:CurrentUserId limit 1];
    string ManagementZonelevel=Userinfos[0].DefaultStore__c;
    string Country=Userinfos[0].country__c;
    string Zone=Userinfos[0].MANAGEMENT_ZONE_LEVEL__c;

   integer Nbproducts=0;

    System.debug('ManagementZonelevel*****' +ManagementZonelevel);
    System.debug('Country*****' +Country);
    System.debug('Zone*****' +Zone);


    Boolean hasPermission =checkIfUserHasAssignedPermissionSet(CurrentUserId,'ArtyCappucines_Corporate');
    List<Quota__c> contList =new List<Quota__c>();
    if(hasPermission){
       contList = [ SELECT id,Name,Zone_LVL__c,Store__c,Store__r.Name,	Exclusive_Campaign_Product__c,Exclusive_Campaign_Product__r.Name,toLabel(MANAGEMENT_ZONE_LEVEL__c), Reserved__c,Serial_Number__c
       FROM Quota__c 
        ];
           Nbproducts=contList.size();

    }else{
       if(country!=null && (country.contains('CHINA')||country.contains('KOREA'))){
        contList = [ SELECT id,Name,TECH_ZONE__c ,Zone_LVL__c,	Exclusive_Campaign_Product__c,Status__c,Store__r.Name,Store__r.StoreCountry__c,Store_Country__c,Exclusive_Campaign_Product__r.Name,toLabel(MANAGEMENT_ZONE_LEVEL__c), Reserved__c,Serial_Number__c
                               FROM Quota__c where TECH_ZONE__c =:country  /*and Store__r.Name=:ManagementZonelevel*/
                                ];
                                System.debug('ManagementZonelevel*****' +ManagementZonelevel);
  Nbproducts=contList.size();

                               }
                           else{
                               if(Zone=='ASIA NORTH' ){
                                
                               contList = [ SELECT id,Name,TECH_ZONE__c,Zone_LVL__c,Status__c,	Exclusive_Campaign_Product__c,Store__r.Name,Store_Country__c,Exclusive_Campaign_Product__r.Name,toLabel(MANAGEMENT_ZONE_LEVEL__c), Reserved__c,Serial_Number__c
                               FROM Quota__c where tolabel(MANAGEMENT_ZONE_LEVEL__c)=:Zone  and TECH_ZONE__c ='13' ];
  Nbproducts=contList.size();

                               }else{
                                   contList = [ SELECT id,Name,Zone_LVL__c,Status__c,	Exclusive_Campaign_Product__c,Store__r.Name,Store_Country__c,Exclusive_Campaign_Product__r.Name,toLabel(MANAGEMENT_ZONE_LEVEL__c), Reserved__c,Serial_Number__c
                                   FROM Quota__c where  tolabel(MANAGEMENT_ZONE_LEVEL__c)=:Zone
                                    ];  
  Nbproducts=contList.size();

                               }

                           }
                       }
    return Nbproducts;
 } 
}