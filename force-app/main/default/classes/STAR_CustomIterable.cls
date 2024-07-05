/** * File Name: STAR_CustomIterable
* Description : STAR Photobook related
* @author : UNKNOWN
* Modification Log =============================================================== 
    RMOU 05/09/2016 PIPA Law enhancements
* */

global class STAR_CustomIterable implements Iterator<list<STAR_ProgramWrapper>>{ 

   //public Date StartDateEvent {get;set;}
   list<Program__c> prgs {get; set;} 
   list<STAR_ProgramWrapper> prgWrapperList {get; set;} 
   list<STAR_ProgramWrapper> prgWrapperListRequested {get; set;} 
   STAR_ProgramWrapper prgInnerObj;
   Integer i {get; set;} 
   
   public Integer setPageSize {get; set;} 

   public STAR_CustomIterable(string sQuery){ 
      //StartDateEvent = dateParam;
      prgs = Database.Query(sQuery);
      prgWrapperList = new list<STAR_ProgramWrapper>(); 
      prgWrapperListRequested = new list<STAR_ProgramWrapper>();     
      for(Program__c p : prgs) {
            prgInnerObj = new STAR_ProgramWrapper(false, p);
            prgWrapperList.add(prgInnerObj);
      } 
       setPageSize = 2;
       i = 0; 
   }   

    global Pagereference printImplFromCustomIterator(){
        
        list<String> idList = new list<String>();
          for (STAR_ProgramWrapper prgIn : prgWrapperList) {
            if (prgIn.isSelected)
            {
                idList.add(prgIn.prg.AccountId__c);
            }
                                 
           }
          system.debug('#### Size idList1 =' +idList.size() );
                 String JSONString = JSON.serialize(idList);
                 PageReference pageRef =  new PageReference('/apex/STAR_MultiClientViewPdf');
                 pageRef.getParameters().put('listid',JSONString);
                 pageRef.setRedirect(true);
                 return PageRef;
       }
    global String printImplFromCustomIterator2()
    {
      list<String> idList = new list<String>();
      for (STAR_ProgramWrapper prgIn : prgWrapperList) {
        if (prgIn.isSelected)
        {
          idList.add(prgIn.prg.AccountId__c);
        }
                               
      }
      system.debug('#### Size idList2 =' +idList.size() );
      String JSONString = JSON.serialize(idList);
      return JSONString;
    }
    
   global boolean hasNext(){ 
       if(i >= prgWrapperList.size()) {
           return false; 
       } else {
           return true; 
       }
   } 
   
   global boolean hasPrevious(){ 
       system.debug('I am in hasPrevious' + i);
       if(i <= setPageSize) {
           return false; 
       } else {
           return true; 
       }
   }   

   global list<STAR_ProgramWrapper> next(){       
       system.debug('i value is ' + i);
       prgWrapperListRequested = new list<STAR_ProgramWrapper>(); 
       integer startNumber;
       integer size = prgWrapperList.size();
       if(hasNext())
       {  
           if(size <= (i + setPageSize))
           {
               startNumber = i;
               i = size;
           }
           else
           {
               i = (i + setPageSize);
               startNumber = (i - setPageSize);
           }
           
           system.debug('i value is =====' + i);
           system.debug('i value is 2==== ' + (i - setPageSize));
           
           for(integer start = startNumber; start < i; start++)
           {
               prgWrapperListRequested.add(prgWrapperList[start]);
           }
       } 
       return prgWrapperListRequested;
   } 
   
   global list<STAR_ProgramWrapper> previous(){      
       prgWrapperListRequested = new list<STAR_ProgramWrapper>(); 
       system.debug('i value is previous before =====' + i);
       integer size = prgWrapperList.size(); 
       if(i == size)
       {
           if(math.mod(size, setPageSize) > 0)
           {    
               i = size - math.mod(size, setPageSize);
           }
           else
           {
               i = (size - setPageSize);
           } 
       }
       else
       {
           i = (i - setPageSize);
       }
       
       system.debug('i value is previous =====' + i);
       system.debug('i value is 2previous ==== ' + (i - setPageSize));
       
       for(integer start = (i - setPageSize); start < i; ++start)
       {
           prgWrapperListRequested.add(prgWrapperList[start]);
       } 
       return prgWrapperListRequested;
   }   
}