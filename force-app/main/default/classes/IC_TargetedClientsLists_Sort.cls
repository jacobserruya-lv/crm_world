global class IC_TargetedClientsLists_Sort implements Comparable{
    // -------------------------------
    // SORT FUNCTIONALITY
    // -------------------------------
  
	// Which field should be considered for sorting
	public enum SortField {
		Name, Segmentation, HistoricalSpendUSD, LastTrans, OwnerName
	}
	  
	// Sorting direction ASCENDING or DESCENDING
	public enum SortDirection {
		ASCENDING, DESCENDING
	}

	// default sorting would be ascending
	public static SortDirection SORT_DIR = SortDirection.ASCENDING;

	// default sorting would be on name
	public static SortField SORT_FIELD = SortField.Name;
	
	public string Id;
	public string Name;
	public string Segmentation;
	public decimal HistoricalSpendUSD;
	public date LastTrans;
	public string OwnerName;
	
	public IC_TargetedClientsLists_Sort(string Id, string Name, string Segmentation, decimal HistoricalSpendUSD, Date LastTrans, string OwnerName) {
		this.Id = Id;
		this.Name = Name;
		this.Segmentation = (Segmentation!=null?Segmentation:'');
		this.HistoricalSpendUSD = (HistoricalSpendUSD!=null?HistoricalSpendUSD:0);
		this.LastTrans = (LastTrans!=null?LastTrans:date.newInstance(1900,1,1));
		this.OwnerName = OwnerName;
	}		    
    
    //Comparable.compareTo() implementation
    global Integer compareTo(Object other) {
   		if(SORT_FIELD == SortField.Name) {
     		return compareToName(other);
   		}
   		else if(SORT_FIELD == SortField.Segmentation) {
     		return compareToSegmentation(other);
   		}
   		else if(SORT_FIELD == SortField.HistoricalSpendUSD) {
     		return compareToHistoricalSpendUSD(other);
   		}  
   		else if(SORT_FIELD == SortField.LastTrans) {
     		return compareToLastTrans(other);
   		}
   		else if(SORT_FIELD == SortField.OwnerName) {
     		return compareToOwnerName(other);
   		}   		
   	   	// this shouldn't be the case
   		return 0;
 	}
 	
	// Compares NAME field
 	integer compareToName(Object other){
		string otherName = other!=null?((IC_TargetedClientsLists_Sort)other).Name:'';  
		if(SORT_DIR == SortDirection.ASCENDING)    
			return this.Name.compareTo(otherName);  
  		else
   			return otherName.compareTo(this.Name);
   	}
   	
	// Compares SEGMENTATION field
 	integer compareToSegmentation(Object other){
		string otherSegmentation = other!=null?((IC_TargetedClientsLists_Sort)other).Segmentation:'';  
		if(SORT_DIR == SortDirection.ASCENDING)    
			return this.Segmentation.compareTo(otherSegmentation);  
  		else
   			return otherSegmentation.compareTo(this.Segmentation);
   	} 
   	
	// Compares HISTORICAL SPEND USD field
 	integer compareToHistoricalSpendUSD(Object other){
		decimal otherHistoricalSpendUSD = other!=null?((IC_TargetedClientsLists_Sort)other).HistoricalSpendUSD:0;  
		if(SORT_DIR == SortDirection.ASCENDING)    
			return Integer.valueOf(this.HistoricalSpendUSD - otherHistoricalSpendUSD);
  		else
			return Integer.valueOf(otherHistoricalSpendUSD - this.HistoricalSpendUSD);
   	}   	  	
   	
   	// Compares LAST PURCHASED DATE field
	integer compareToLastTrans(Object other) {
		Date otherLastTrans = other!=null?((IC_TargetedClientsLists_Sort)other).LastTrans:date.newInstance(1900,1,1);  
		if (SORT_DIR == SortDirection.ASCENDING) 
			return otherLastTrans.daysBetween(this.LastTrans);
		else
			return this.LastTrans.daysBetween(otherLastTrans);  
	}  
	
	// Compares OWNER NAME field
 	integer compareToOwnerName(Object other){
		string otherOwnerName = other!=null?((IC_TargetedClientsLists_Sort)other).OwnerName:'';  
		if(SORT_DIR == SortDirection.ASCENDING)    
			return this.OwnerName.compareTo(otherOwnerName);  
  		else
   			return otherOwnerName.compareTo(this.OwnerName);
   	}	 	
}