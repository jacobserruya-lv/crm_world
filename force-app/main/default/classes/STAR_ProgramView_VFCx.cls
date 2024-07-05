/** * File Name: STAR_ProgramView_VFCx
* Description :  controller
* @author : UNKNOWN
* Modification Log =============================================================== 
* 	MTO 23/06/2016 Removing End_Date__c field from query
* */

public without sharing class STAR_ProgramView_VFCx {

  public Program__c program {get;set;}
  
  public String IdProgram {get; set;}
    
  //public String getMyFormattedDate(){ return VisitTo.format(); }
  
  public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
  
  /**
     *  Translate the locale to a culture name
     *  @see https://github.com/jquery/globalize
     *  @return (String)
    **/
    public static String getLocale(){
        //-- @TODO: use a custom setting for the ballback instead of a separate file.
        String localization = UserInfo.getLocale();
        //localization = 'cucamonga';
        localization = localization.replace( '_', '-' );
        return( localization );
    }
    
    /**
     *  Translate the locale to a culture name
     *  @see https://github.com/jquery/globalize
     *  @return (String)
    **/
    public static String getLang(){
        String lang = UserInfo.getLanguage();
        lang = lang.replace( '_', '-' );
        return( lang );
    }
    
  
  public STAR_ProgramView_VFCx ()
  {
   
              
   Idprogram= ApexPages.currentPage().getParameters().get('Id');
   
   program = [Select Id, Name, Status__c, Car_required__c,AccountId__c, AccountId__r.Name,EventId__c, EventId__r.Name, Flight_paid__c, LV_Host__c,Reason__c,Visit_from__c,Visit_to__c
   From Program__c 
   where Id=: Idprogram]; 
  
 }
 
 public List<Gift__c> getGiftProg()
 {               
     String programId = program.Id;
     String queryGiftProg = 'select id, ProgramId__c, name, Gift_Detail__c, RecoveryAct__c, Gift_Name__c, Welcome_Package__c from Gift__c where ProgramId__c=:programId ';
     List<Gift__c> giftLists =  Database.query(queryGiftProg );        
     return  giftLists ;
                
 }
 
  public List<Experience__c> getExperienceProg()
 {               
      String programId = program.Id;
     // MTO Removing End_Date__c field from query
      //String queryExperienceProg = 'select id, name, End_Date__c,Start_Date__c, Details_on_experience__c, Experience_Name__c, ProgramId__c, Recovery_act__c from Experience__c where ProgramId__c=:programId ';
      String queryExperienceProg = 'select id, name,Start_Date__c, Details_on_experience__c, Experience_Name__c, ProgramId__c, Recovery_act__c from Experience__c where ProgramId__c=:programId ';
      List<Experience__c> experienceLists =  Database.query(queryExperienceProg );        
      return  experienceLists ;
 }
    
  public List<Hotel__c> getHotelProg()
 {               
      String programId = program.Id;
      String queryHotelProg = 'select id, name, HotelName__c, Book_requirement__c, Comment__c, From__c, Location__c, Paid_by__c, ProgramId__c, Status__c, To__c  from Hotel__c where ProgramId__c=:programId ';
      List<Hotel__c> hotelLists =  Database.query(queryHotelProg );        
      return  hotelLists ;
                
 }
 
  public List<Restaurant__c> getRestaurantProg()
 {               
      String programId = program.Id;
      String queryRestaurantProg = 'select id, name, Restaurant_Name__c, Booking_Date_Time__c, Comment__c, Lunch_dinner__c, ProgramId__c, Status__c  from Restaurant__c where ProgramId__c=:programId ';
      List<Restaurant__c> restaurantLists =  Database.query(queryRestaurantProg );        
      return  restaurantLists ;
                
 }
 
   public List<Transport__c> getTransportProg()
 {               
      String programId = program.Id;
      String queryTransportProg = 'select id, name, Comment__c, ProgramId__c, Type__c from Transport__c where ProgramId__c=:programId ';
      List<Transport__c> transportLists =  Database.query(queryTransportProg );        
      return  transportLists ;
                
 }


 }