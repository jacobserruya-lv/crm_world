public class IC_ManagementLevel2_VFCx{

    public String idReport_AllIconAction_ManagementLvl2 {get; set; }
    public String idReport_Appointments_ManagementLvl2 {get; set; }
    public String idReport_Outreachs_ManagementLvl2 {get; set; }
    public String ManagementLevel2Name {get; set;}   
    public String idManagementLevel2 {get; set;}
    
    public IC_ManagementLevel2_VFCx(ApexPages.StandardController controller) {
    
    idManagementLevel2 = ApexPages.currentPage().getParameters().get('Id');
    List<ManagementLevel2__c> mylist = [Select Id, Name from ManagementLevel2__c where id =:idManagementLevel2];
    String name = mylist.get(0).name;    
    ManagementLevel2Name = string.escapeSingleQuotes(name);
    
    idReport_AllIconAction_ManagementLvl2 =System.Label.IC_idReport_AllIconAction_MGMLvl2;
    idReport_Appointments_ManagementLvl2  =System.Label.IC_idReport_Appointments_MGMLvl2;
    idReport_Outreachs_ManagementLvl2 =System.Label.IC_idReport_Outreaches_MGMLvl2;
    }
  
}