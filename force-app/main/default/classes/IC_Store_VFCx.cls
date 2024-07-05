public class IC_Store_VFCx {
 
   public String idReport_AllIconAction_Store{get; set; }
   public String idReport_Appointments_Store{get; set; }
   public String idReport_Outreachs_Store{get; set; }
   
   public String idReport_AllIconAction_LW_Store{get; set; }
   public String idReport_Appointments_LW_Store{get; set; }
   public String idReport_Outreachs_LW_Store{get; set; }
   
   public String StoreName {get; set;}   
   public String idStore {get; set;} 
    
    public IC_Store_VFCx(ApexPages.StandardController controller) 
    {
        idStore= ApexPages.currentPage().getParameters().get('Id');
        List<Store__c> mylist = [Select Id, Name from  Store__c where id =:idStore];
        String name = mylist.get(0).name;    
        StoreName = string.escapeSingleQuotes(name);
        
        idReport_AllIconAction_Store =System.Label.IC_IdReport_AllIconAction_Store;
        idReport_Appointments_Store =System.Label.IC_IdReport_Appointments_Store;
        idReport_Outreachs_Store =System.Label.IC_IdReport_Outreaches_Store;
        
        idReport_AllIconAction_LW_Store =System.Label.IC_idReport_AllIconAction_Store_LW;
        idReport_Appointments_LW_Store =System.Label.IC_idReport_Appointments_Store_LW;
        idReport_Outreachs_LW_Store =System.Label.IC_idReport_Outreaches_Store_LW;
    }

}