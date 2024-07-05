public class IC_Zone_VFCx{

    public String id_Report_AllIconAction_Zone {get; set; }
    public String id_Report_Appoitments_Zone {get; set; }
    public String id_Report_Outreachs_Zone {get; set; }
    public String ZoneName {get; set;}   
    public String idZone {get; set;} 
    
    public IC_Zone_VFCx(ApexPages.StandardController controller) {
    
    idZone = ApexPages.currentPage().getParameters().get('Id');
    List<Zone__c> mylist = [Select Id, Name from  Zone__c where id =:idZone ];
    String name = mylist.get(0).name;    
    ZoneName = string.escapeSingleQuotes(name);
    
    id_Report_AllIconAction_Zone =System.Label.IC_IdReport_AllIconAction_Zone;
    id_Report_Appoitments_Zone =System.Label.IC_idReport_Appoitements_Zone;
    id_Report_Outreachs_Zone =System.Label.IC_IdReport_Outreaches_Zone;
    
    }


  
}