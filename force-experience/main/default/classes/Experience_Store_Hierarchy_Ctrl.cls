/*@author Keman WU. updated by Nechama Wollach
* @date creation 11/04/2024
* @description Generate XML request body
*/
public class Experience_Store_Hierarchy_Ctrl {

  public static final String SYSTEM_ADMIN_PROFILE = 'System Administrator';
  public static final String ADMIN_CORPORATE_PROFILE = 'System Admin_Corporate';
  public static final String LV_CLUB_PROFILE = 'LV_Club';
  public static final String EX_PCR_PERMISSION_SET = 'Events_Experiences_PCR';


    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getManagementZoneLevel() {
      return [
        SELECT MANAGEMENT_ZONE_LEVEL__c,MANAGEMENT_ZONE_LEVEL_TECH__c 
        FROM Store__c 
        WHERE Status__c IN  ('Open','Opening Soon') 
        AND StoreType__c IN ('Store','CSC','POP UP - OON') 
        AND MANAGEMENT_ZONE_LEVEL__c != null 
        GROUP BY MANAGEMENT_ZONE_LEVEL__c,MANAGEMENT_ZONE_LEVEL_TECH__c];      
    }

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getManagementZoneSubLevel1(List<String> selectedManagementZoneLevel) {
      system.debug('selectedManagementZoneLevel'+selectedManagementZoneLevel);
      return [
        SELECT MGMT_ZONE_SUB_LEVEL1__c,MGMT_ZONE_SUB_LEVEL1_TECH__c 
        FROM Store__c 
        WHERE Status__c IN  ('Open','Opening Soon') 
        AND StoreType__c IN ('Store','CSC','POP UP - OON') 
        AND MGMT_ZONE_SUB_LEVEL1__c != null 
        AND MANAGEMENT_ZONE_LEVEL_TECH__c  IN :selectedManagementZoneLevel 
        GROUP BY MGMT_ZONE_SUB_LEVEL1__c,MGMT_ZONE_SUB_LEVEL1_TECH__c];
    }
  
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getManagementZoneSubLevel2(List<String> selectedManagementZoneSubLevel1) {
      system.debug('selectedManagementZoneSubLevel1:' +selectedManagementZoneSubLevel1);
      return [
        SELECT MGMT_ZONE_SUB_LEVEL2__c,MGMT_ZONE_SUB_LEVEL2_TECH__c 
        FROM Store__c 
        WHERE Status__c IN  ('Open','Opening Soon') 
        AND StoreType__c IN ('Store','CSC','POP UP - OON') 
        AND MGMT_ZONE_SUB_LEVEL2__c != null 
        AND MGMT_ZONE_SUB_LEVEL1_TECH__c  IN :selectedManagementZoneSubLevel1 
        GROUP BY MGMT_ZONE_SUB_LEVEL2__c,MGMT_ZONE_SUB_LEVEL2_TECH__c];
    }
  
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getManagementZoneSubLevel3(List<String> selectedManagementZoneSubLevel2) {
     return [
        SELECT MGMT_ZONE_SUB_LEVEL3__c, MGMT_ZONE_SUB_LEVEL3_TECH__c 
        FROM Store__c 
        WHERE Status__c IN  ('Open','Opening Soon') 
        AND StoreType__c IN ('Store','CSC','POP UP - OON') 
        AND MGMT_ZONE_SUB_LEVEL3__c != null
        AND MGMT_ZONE_SUB_LEVEL2_TECH__c  IN :selectedManagementZoneSubLevel2 
        GROUP BY MGMT_ZONE_SUB_LEVEL3__c,MGMT_ZONE_SUB_LEVEL3_TECH__c];
      
    }
  
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getStoreLevel(List<String> selectedManagementZoneSubLevel3) {
     return [
        SELECT RetailStoreId__c,Name 
        FROM Store__c 
        WHERE Status__c IN  ('Open','Opening Soon') 
        AND StoreType__c IN ('Store','CSC','POP UP - OON') 
        AND RetailStoreId__c != null
        AND MGMT_ZONE_SUB_LEVEL3_TECH__c  IN :selectedManagementZoneSubLevel3 
        GROUP BY RetailStoreId__c,Name];       
      
    }
    @AuraEnabled(cacheable=true)
    public static List<SelctedStoreHierarchy> getSelectedStores(String currEvent) {
      System.debug('**currEvent '+currEvent);
      List<selctedStoreHierarchy> selectedStoreHierarchyList = new List<selctedStoreHierarchy>();
      for (Brand_Experience_Store_Hierarchy__c currStoreHierarchy : [SELECT Store__r.MANAGEMENT_ZONE_LEVEL__c, Store__r.MANAGEMENT_ZONE_LEVEL_TECH__c, Store__r.MGMT_ZONE_SUB_LEVEL1__c, Store__r.MGMT_ZONE_SUB_LEVEL1_TECH__c, Store__r.MGMT_ZONE_SUB_LEVEL2__c, Store__r.MGMT_ZONE_SUB_LEVEL2_TECH__c, Store__r.MGMT_ZONE_SUB_LEVEL3__c, Store__r.MGMT_ZONE_SUB_LEVEL3_TECH__c, Store__r.RetailStoreId__c, Store__r.Name FROM Brand_Experience_Store_Hierarchy__c WHERE Brand_Experience__c =:currEvent]) {
        SelctedStoreHierarchy newStoreHirerchy = new SelctedStoreHierarchy(currStoreHierarchy.Store__r.MANAGEMENT_ZONE_LEVEL__c, currStoreHierarchy.Store__r.MANAGEMENT_ZONE_LEVEL_TECH__c, currStoreHierarchy.Store__r.MGMT_ZONE_SUB_LEVEL1__c, currStoreHierarchy.Store__r.MGMT_ZONE_SUB_LEVEL1_TECH__c, currStoreHierarchy.Store__r.MGMT_ZONE_SUB_LEVEL2__c, currStoreHierarchy.Store__r.MGMT_ZONE_SUB_LEVEL2_TECH__c, currStoreHierarchy.Store__r.MGMT_ZONE_SUB_LEVEL3__c, currStoreHierarchy.Store__r.MGMT_ZONE_SUB_LEVEL3_TECH__c, currStoreHierarchy.Store__r.RetailStoreId__c, currStoreHierarchy.Store__r.Name);
        selectedStoreHierarchyList.add(newStoreHirerchy);
      } 
      return selectedStoreHierarchyList;
    }

    @AuraEnabled
    public static Boolean hasEditPermissions(){
      try {
          User runningUser = EX_Store_Hierarchy_Utils.getUserHierarchies();
          List<string> userPermissionSet =  EX_Store_Hierarchy_Utils.getUserPermissionSet();
          if(runningUser.Profile.Name == SYSTEM_ADMIN_PROFILE || runningUser.Profile.Name == ADMIN_CORPORATE_PROFILE || runningUser.Profile.Name == LV_CLUB_PROFILE || userPermissionSet.contains(EX_PCR_PERMISSION_SET)){
              return true;
          }
          else{
              return false;
          }
      } catch (Exception e) {
          throw new AuraHandledException(e.getMessage());
      }
  }





    public class SelctedStoreHierarchy {
      @AuraEnabled public String zoneLevel { get; set; }
      @AuraEnabled public String zoneLevelName { get; set; }
      @AuraEnabled public String zoneSubLevel1 { get; set; }
      @AuraEnabled public String zoneSubLevel1Name { get; set; }
      @AuraEnabled public String zoneSubLevel2 { get; set; }
      @AuraEnabled public String zoneSubLevel2Name { get; set; }
      @AuraEnabled public String zoneSubLevel3{ get; set; }
      @AuraEnabled public String zoneSubLevel3Name{ get; set; }
      @AuraEnabled public String retailStoreId { get; set; }
      @AuraEnabled public String retailStoreName { get; set; }


      public SelctedStoreHierarchy(String zoneLevel, String zoneLevelName, String zoneSubLevel1, String zoneSubLevel1Name, String zoneSubLevel2, String zoneSubLevel2Name, String zoneSubLevel3, String zoneSubLevel3Name, String retailStoreId, String retailStoreName) {

        this.zoneLevel = zoneLevel;
        this.zoneLevelName = zoneLevelName;
        this.zoneSubLevel1 = zoneSubLevel1;
        this.zoneSubLevel1Name = zoneSubLevel1Name;
        this.zoneSubLevel2 = zoneSubLevel2;
        this.zoneSubLevel2Name = zoneSubLevel2Name;
        this.zoneSubLevel3 = zoneSubLevel3;
        this.zoneSubLevel3Name = zoneSubLevel3Name;
        this.retailStoreId = retailStoreId;
        this.retailStoreName = retailStoreName;

      }
  }

}