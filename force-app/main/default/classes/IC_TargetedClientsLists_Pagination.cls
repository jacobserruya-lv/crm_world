public class IC_TargetedClientsLists_Pagination {
    // -------------------------------
    // PAGINATION FUNCTIONALITY
    // -------------------------------    
	
    // Members
    public boolean bHasNext{get;set;}
    public boolean bHasPrevious{get;set;}
    public integer iNumberToDisplay{get;set;}
    public list<Account> lDisplayedlist{get;set;}
    public integer iPageNumber{get;set;}
    public boolean iSelectAll{get;set;}
    public integer iTotalPage{get;set;}
    public list<Account> lDatalist;

    // ---------------------------------
    // CONSTRUCTOR
    // ---------------------------------    
    public IC_TargetedClientsLists_Pagination(list<Account> lList, integer iSize){
        lDatalist = new list<Account>();        
        lDatalist.addAll(lList);
        
        lDisplayedlist = new list<Account>();
        iNumberToDisplay = iSize;
        
        iPageNumber = 1;
        iSelectAll = true;
        if(!lDatalist.isEmpty()){
            iTotalPage = lDatalist.size()/iNumberToDisplay;
            if(math.mod(lDatalist.size(), iNumberToDisplay) != 0) iTotalPage++;             
            if(lDatalist.size() > (iPageNumber*iNumberToDisplay )) bHasNext = true;
        }
        else{
            bHasNext = false;
            iTotalPage = 1;
        }
                
        bHasPrevious = false;
        
        for(integer i=0; i<iNumberToDisplay; i++){            
            if(i<lDatalist.size()){                
                lDisplayedlist.add(lDatalist[i]);
            }
            else break;         
        }
    }
    
     // ---------------------------------
    // processCheckChange() method
    // ---------------------------------
    public void processCheckChange(list<Account> lList){
    	for (SObject oObject:lList){
    		Account oAccount = (Account) oObject;
    			oAccount.TECH_Selected__pc = (iSelectAll?false:true);
    		}
        iSelectAll = (iSelectAll?false:true);
    }
 
 
    // ---------------------------------
    // getNext() method
    // ---------------------------------
    public void getNext(integer iCurrentPageNum){
        bHasNext = (iCurrentPageNum < iTotalPage?true:false);
              
        if(bHasNext){
            iPageNumber = iCurrentPageNum + 1;
            bHasPrevious = true;
            lDisplayedlist = new list<Account>();

            for(integer i=((iPageNumber - 1)*iNumberToDisplay); i<(iPageNumber*iNumberToDisplay); i++){
                if(lDatalist.size() > i){
                    lDisplayedlist.add(lDatalist[i]);
                }
                else break;
            }
        }       

        if(lDatalist.size() > (iPageNumber*iNumberToDisplay)){               
            bHasNext = true;             
        }
        else bHasNext = false;
        
    }
    
    // ---------------------------------
    // getLast() method
    // ---------------------------------    
    public void getLast(){
        if(!lDatalist.isEmpty()){
            iPageNumber = iTotalPage;
            bHasNext = false;
            lDisplayedlist = new list<Account>();
            
            for(integer i=((iPageNumber-1)*iNumberToDisplay); i<(iPageNumber*iNumberToDisplay);i++){
                if(lDatalist.size() > i){
                    lDisplayedlist.add(lDatalist[i]);
                }
                else break;
            }
        }       

        if(iPageNumber == 1){                
            bHasPrevious = false;                
        }
        else bHasPrevious = true;
                
    }
    
    // ---------------------------------
    // getFirst() method
    // ---------------------------------    
    public void getFirst(){
        if(!lDatalist.isEmpty()){
            iPageNumber = 1;
            bHasPrevious = false;
            lDisplayedlist = new list<Account>();
            
            for(integer i=0; i<iNumberToDisplay; i++){
                if(lDatalist.size() > i){
                    lDisplayedlist.add(lDatalist[i]);
                }
                else break;
            }
        } 
              
        if(iPageNumber == iTotalPage){                
            bHasNext = false;                
        }
        else bHasNext = true;        
    }
    
    // ---------------------------------
    // getPrevious() method
    // ---------------------------------        
    public void getPrevious(Integer iCurrentPageNum){
        bHasPrevious = (iCurrentPageNum > 1?true:false);        
        
        if(bHasPrevious){
            iPageNumber = iCurrentPageNum-1;
            bHasNext = true; 
            lDisplayedlist = new list<Account>();
            
            for(integer i=((iPageNumber-1)*iNumberToDisplay); i<(iPageNumber*iNumberToDisplay); i++){
                if(lDatalist.size() > i){
                    lDisplayedlist.add(lDatalist[i]);
                }
                else break;
            }
        }

        if(iPageNumber == 1){                
            bHasPrevious = false;                
        }
        else bHasPrevious = true;
    }   
}