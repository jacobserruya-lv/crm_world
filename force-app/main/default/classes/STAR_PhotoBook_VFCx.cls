/** * File Name: STAR_PhotoBook_VFCx
* Description : Controler STAR_PhotoBook
* @author : UNKNOWN
* Modification Log =============================================================== 
	BTOU 13/06/2016 photo book enhancements - exclude Template Programs 
    RMOU 05/09/2016 PIPA Law enhancements
* */
public class STAR_PhotoBook_VFCx {
    
    public boolean showresult {get;set;}
    public String ClientName {get;set;}
    public String EventName {get;set;}
    Public String EventNameFromEvent= System.currentPagereference().getParameters().get('eventname');
    public string invitingZone {get;set;}
    public string invitationStatus {get;set;}
    public string country {get;set;}
    public string store{get;set;}
    public List<SelectOption> zoneOptions 
    {
       get
       {
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult zone = Program__c.Inviting_Zone__c.getDescribe();
            List<Schema.PicklistEntry> zoneVals = zone.getPicklistValues();
    		options.add(new SelectOption('', '--None--'));
            for( Schema.PicklistEntry f : zoneVals)
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            return options;
       }
    }
    public List<SelectOption> statusOptions 
    {
       get
       {
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult status = Program__c.status__c.getDescribe();
            List<Schema.PicklistEntry> statusVals = status.getPicklistValues();
    		options.add(new SelectOption('', '--None--'));
            for( Schema.PicklistEntry f : statusVals)
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            return options;
       }
    }
    
    STAR_CustomIterable obj;
    
    public list<STAR_ProgramWrapper> prgWrapperObj {get;set;}
    
    public STAR_PhotoBook_VFCx () {       
       
        ClientName  = '';
        EventName= EventNameFromEvent;
        
        if(!String.isBlank(EventNameFromEvent)){
                save();
        }
        
        obj = new STAR_CustomIterable(query());
    }
    
    public Pagereference save(){
        initlistprogram();
        return null;
    }
    
    // displays the selected items
     public PageReference Print() {
        
         return obj.printImplFromCustomIterator();
     }

     public void print2(){
        Cache.Session.put('local.STARPartition.printImplFromCustomIterator3idList', '/apex/STAR_MultiClientViewPdf?listid=' + obj.printImplFromCustomIterator2());
     }
    
    public void initlistprogram(){
        
        String strMsg = 'Please enter an Event Name';
       
       if(EventName == '' || EventName == null)
       {
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,strMsg);
          ApexPages.addMessage(msg);
        
       }else{
                  
          obj = new STAR_CustomIterable(query()); 
          obj.setPageSize = 10;
          showresult = true;
          next();
                  
        }
    }
    
    //Return the final query 
    public string query()
    {   
        string q1 = 'Select Name, AccountId__c, AccountId__r.HistoricalSpendEUR__pc, AccountId__r.Segmentation__pc,'
                  + 'AccountId__r.DREAMID__c, EventId__r.Name, EventId__r.Start_Date__c, AccountId__r.isPersonAccount'
                  + ' From Program__c'; 
        string q2 = ' WHERE ';
        string qn = ' Order by EventId__r.Name ASC ';
        string query = q1 + q2;
        string qPipa='';
        string q5 = '';
        String q6='';
             // -- Begin MTO: photo book enhancements - new search criteria --//        
            // ClientName (Not Empty) AND EventName (Not Empty) --> //Test Passed\\
           /* if(!String.isBlank(ClientName ) && !String.isBlank(EventName))
            {
                string q3 = ' AccountId__r.Name like \'%'+ClientName +'%\' AND EventId__r.Name like \'%'+EventName +'%\' ';
                query = query + q3; 
                system.debug('### YAK query_CE = '+ query);
               
             // ClientName (IS EMPTY) AND EventName (not empty) --> //Test Passed\\
            }else if (String.isBlank(ClientName) && !String.isBlank(EventName))
            {
                string q4 = '  EventId__r.Name like \'%'+EventName +'%\' ';
                query = query + q4; 
                system.debug('### YAK query_E = '+ query);
                                           
            }
             
            else
                {
                    query = q1;
                    system.debug('### YAK query_ALL = '+ query);
                    
                }*/
            if(!String.isBlank(EventName))
            {
                string q3 = ' EventId__r.Name like \'%'+EventName +'%\'';
                query = query + q3; 
            }
        	if(!String.isBlank(ClientName ))
            {
               string q4 = ' AND AccountId__r.Name like \'%'+ClientName +'%\'';
               query = query + q4;  
            }
            if(!String.isblank(invitingZone))
            {
                q5 = ' AND Inviting_Zone__c like \'%' + invitingZone + '%\'';
                query += q5;
            }
            if(!String.isblank(invitationStatus))
            {
                q5 = ' AND Status__c like \'%' + invitationStatus + '%\'';
                query += q5;  
            }
            if(!String.isBlank(country))
            {
                q5 = ' AND AccountId__r.PrimaryCountry__pc like \'%' + country + '%\'';
                query += q5;            
            }
            if(!String.isblank(store))
            {
                q5 = ' AND AccountId__r.AttachedStore__pc like \'%' + store + '%\'';
                query += q5;
            }
            // -- End MTO ---//               
            List<String> listPIPACodes = IC_Factory.getListPIPACountryCodesToHide(IC_UTILS.getUserCountry());
            if(!IC_Factory.isAdmin())
            {
                qPipa = 'AND AccountId__r.AttachedStoreCountry__pc NOT IN (\'' + String.join(listPIPACodes, '\',\'') + '\') '; 
                system.debug('### qPipa =' +qPipa) ;          
            }
            
        // -- Begin BTO: photo book enhancements - exclude Template Programs  --// 
        	q6=' AND AccountId__c!=null '; 
            query += q6;
         // -- End BTO ---//        
        
            query = query + qPipa + qn;

            query = query.replace ('WHERE  AND', 'WHERE');
            system.debug('### queryFinal =' +query) ;
            system.debug('### ClientName EventName listPIPACodes= '+ ClientName +' ' + EventName + ' ' + listPIPACodes); 
            
        return query;
    }
    
    public Boolean hasNext {
        get {
            return obj.hasNext();
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            return obj.hasPrevious();
        }
        set;
    }
    
    public void next() {
        prgWrapperObj = obj.next();
    }
    
    public void previous() {
        prgWrapperObj = obj.previous();
    }
}