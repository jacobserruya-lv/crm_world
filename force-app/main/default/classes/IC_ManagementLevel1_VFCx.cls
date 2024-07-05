public class IC_ManagementLevel1_VFCx{

    public String idReport_AllIconAction_ManagementLvl1 {get; set; }
    public String idReport_Appointments_ManagementLvl1 {get; set; }
    public String idReport_Outreachs_ManagementLvl1 {get; set; }
    
    public String ManagementLevel1Name {get; set;}   
    public String idManagementLevel1 {get; set;}
    
    public IC_ManagementLevel1_VFCx(ApexPages.StandardController controller) {
    
    idManagementLevel1 = ApexPages.currentPage().getParameters().get('Id');
    List<ManagementLevel1__c> mylist = [Select Id, Name from ManagementLevel1__c where id =:idManagementLevel1];
    String name = mylist.get(0).name;    
    ManagementLevel1Name = string.escapeSingleQuotes(name);
    
    idReport_AllIconAction_ManagementLvl1 =System.Label.IC_idReport_AllIconAction_MGMLvl1;
    idReport_Appointments_ManagementLvl1  =System.Label.IC_idReport_Appointments_MGMLvl1;
    idReport_Outreachs_ManagementLvl1 =System.Label.IC_idReport_Outreaches_MGMLvl1;
    }


  
}