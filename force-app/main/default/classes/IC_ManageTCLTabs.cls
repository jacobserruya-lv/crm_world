public class IC_ManageTCLTabs{

    
   public static PageReference RedirectToTCLPage(){
  
       return  new PageReference('/apex/IC_TargetedClientLists_New?action=target') ;
    }
   
    public static PageReference RedirectToDesactivateTCLPage(){
  
       return  new PageReference('/apex/IC_DeactivateLists?action=target#!/activate') ;
    }
  
   public static PageReference RedirectToMassReassignTCLPage(){
  
       return  new PageReference('/apex/IC_MassTransferClients?action=reassign') ;
    }
}