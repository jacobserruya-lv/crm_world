public with sharing class DependentPicklistBitset {
    public Map<String,Integer> AlphaNumCharCodes {get;set;}
    public Map<String, Integer> Base64CharCodes { get; set; }
    public DependentPicklistBitset() { LoadCharCodes(); }

    public class TPicklistEntry{
        public string active {get;set;}
        public string defaultValue {get;set;}
        public string label {get;set;}
        public string value {get;set;}
        public string validFor {get;set;}

        public TPicklistEntry(){}
    }

    //Method loads the char codes
    private void LoadCharCodes(){
		String base64CharOrder = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
		Base64CharCodes = new Map<String, Integer>();

		Integer i = 0;
		for(String charKey : base64CharOrder.split('')) {
			Base64CharCodes.put(charKey, i);
			i++;
		}

		/* Saved for legacy purposes - incorrect results
        AlphaNumCharCodes = new Map<String,Integer>{
            'A'=>65,'B'=>66,'C'=>67,'D'=>68,'E'=>69,'F'=>70,'G'=>71,'H'=>72,'I'=>73,'J'=>74,
            'K'=>75,'L'=>76,'M'=>77,'N'=>78,'O'=>79,'P'=>80,'Q'=>81,'R'=>82,'S'=>83,'T'=>84,
            'U'=>85,'V'=> 86,'W'=>87,'X'=>88,'Y'=>89,'Z'=>90,'/' => 191,'\\' => 220
        };
        Base64CharCodes = new Map<String, Integer>();
        //lower case
        Set<String> pUpperCase = AlphaNumCharCodes.keySet();
        for(String pKey : pUpperCase){
            //the difference between upper case and lower case is 32
            AlphaNumCharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey)+32);
            //Base 64 alpha starts from 0 (The ascii charcodes started from 65)
            Base64CharCodes.put(pKey,AlphaNumCharCodes.get(pKey) - 65);
            Base64CharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey) - (65) + 26);
        }
        //numerics
        for (Integer i=0; i<=9; i++){
            AlphaNumCharCodes.put(string.valueOf(i),i+48);
            //base 64 numeric starts from 52
            Base64CharCodes.put(string.valueOf(i), i + 52);
        }
		 */
    }

	// Build a map of parents and their valid children (faster version)
	public static Map<String,List<String>> GetDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName){
		Map<String,List<String>> objResults = new Map<String,List<String>>();
		// This list will hold the children during the build, and will be copied to the final map at the end
		List<List<String>> workingList = new List<List<String>>();
		
		//get the string to sobject global map
		Map<String, Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
		List<String> counts = new List<String>();
		if (!objGlobalMap.containsKey(pObjName)){
			return objResults;
		}
		//get the type being dealt with
		Schema.SObjectType pType = objGlobalMap.get(pObjName);
		Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
		//verify field names
		if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) {
			return objResults;
		}
		//get the control values
		List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
		//get the dependent values
		List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
		
		//iterate through the values and get the ones valid for the controlling field name
		DependentPicklistBitset objBitSet = new DependentPicklistBitset();
		
		//set up the results
		for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){
			//get the pointer to the entry
			// Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
			//get the label
			// String pControllingLabel = ctrl_entry.getLabel();
			//create the entry with the label
			// objResults.put(pControllingLabel,new List());
			workingList.add(new List<String>());
		}
		
		//check the dependent values
		for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){
			//get the pointer to the dependent index
			Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
			//get the valid for
			String pEntryStructure = JSON.serialize(dep_entry);
			TPicklistEntry objDepPLE = (TPicklistEntry)JSON.deserialize(pEntryStructure, TPicklistEntry.class);
			//if valid for is empty, skip
			if (objDepPLE.validFor==null || objDepPLE.validFor==''){
				continue;
			}
		
			List<Integer> valids = objBitSet.validFor(objDepPLE.validFor);
			for(Integer v : valids) {
				// As a safety valve, make sure we didn’t get an index out of range
				if (v < workingList.size()) { 
					if(pDependentFieldName == 'DefaultStore__c' /*&& !Ctrl_ProductCatalog.DIGITAL_STORE_CODES.contains(objDepPLE.value)*/) {
						workingList[v].add(objDepPLE.label + ' - ' + objDepPLE.value);
					}
					else {
						workingList[v].add(objDepPLE.label);
					}
				}
			}
			//workingList[]
		}
		
		// Now populate the map
		for(Integer pControllingIndex = 0; pControllingIndex < ctrl_ple.size(); pControllingIndex++) {
			String pControllingLabel = ctrl_ple[pControllingIndex].getLabel();
			List<String> tempList = new List<String>();
			
			//add empty option
			//if(pDependentFieldName == 'MGMT_ZONE_SUB_LEVEL1__c' || pDependentFieldName == 'MGMT_ZONE_SUB_LEVEL2__c') {
				//tempList.add('');
			//}
			tempList.addAll(workingList[pControllingIndex]);
			workingList[pControllingIndex] = tempList;
			objResults.put(pControllingLabel, workingList[pControllingIndex]);
		}
		return objResults;
	}


    
    public List<Integer> validFor(String pValidFor) {
		// Target list
		List<Integer> ret = new List<Integer>();
		
		// Start at offset 0
		Integer target = 0;
		
		// Process each character in order
		for(Integer i=0; i < pValidFor.length();i++){
			//get current character value
			Integer cur = (Base64CharCodes.get((pValidFor.Substring(i, i+1))));
			
			// 6 bits per character, starting at bit position 5
			for (Integer j = 0; j < 6; j++) {
				// Is the current bit set?
				if ((cur & 32) == 32) {
					// Yes, this index is valid
					ret.add(target);
				}
				// Shift the next bit into position
				cur <<= 1;
				
				// Move to the next target index
				target++;
			}
		}
		
		return ret;
	}

}