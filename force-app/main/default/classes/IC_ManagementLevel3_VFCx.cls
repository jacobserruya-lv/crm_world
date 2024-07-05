public class IC_ManagementLevel3_VFCx{

    public String idReport_AllIconAction_ManagementLvl3 {get; set; }
    public String idReport_Appointments_ManagementLvl3 {get; set; }
    public String idReport_Outreachs_ManagementLvl3 {get; set; }
    public String ManagementLevel3Name {get; set;}   
    public String idManagementLevel3 {get; set;}
    
    public IC_ManagementLevel3_VFCx(ApexPages.StandardController controller) {
    
    idManagementLevel3 = ApexPages.currentPage().getParameters().get('Id');
    List<ManagementLevel3__c> mylist = [Select Id, Name from ManagementLevel3__c where id =:idManagementLevel3];
    String name = mylist.get(0).name;    
    ManagementLevel3Name = string.escapeSingleQuotes(name);
    
    idReport_AllIconAction_ManagementLvl3 =System.Label.IC_idReport_AllIconAction_MGMLvl3;
    idReport_Appointments_ManagementLvl3  =System.Label.IC_idReport_Appointments_MGMLvl3;
    idReport_Outreachs_ManagementLvl3 =System.Label.IC_idReport_Outreaches_MGMLvl3;
    }
  
}