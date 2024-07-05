public with sharing class BL_ICON_Utils {
    
    public static String buildMultiChoiceFilterFromObjectList (List<Map<String,Object>> filters , String attributeName){
    	List<String> stringFilters = new List<String>();
		for(Map<String,Object>  obj: filters){
			stringFilters.add((String)obj.get(attributeName));
		}
        	
        return buildMultiChoiceFilterFromList(stringFilters);// in  ( 'nat1','nat2','nat3' )
    }
    public static String buildMultiChoiceFilterFromList (List<String> filters ){
    	String queryFilter = '';
    	
    	 queryFilter += ' in ( ' ;
        	
        			for(String filt: filters){
        				queryFilter += '\'' + filt + '\',';
        			}
        	queryFilter = queryFilter.removeEnd(',');
        	queryFilter+= ' )';
        return queryFilter;// in  ( 'nat1','nat2','nat3' )
	}
	
	public static List<Object> slice(List<Object> input, Integer ge, Integer l){
		List<Object> output = input.clone();
		for (Integer i = 0; i < ge; i++) output.remove(0);
		Integer elements = l - ge;
		while (output.size() > elements) output.remove(elements);
		return output;
	}

	public static List<Map<String, Object>> getAggregateResultAsMap(List<AggregateResult> aggrs)
    {
        String js = Json.serialize(aggrs); // AggregateResult as Map
        List<Map<String, Object>> result = new List<Map<String, Object>>(); // result Object
        Object resultObject = Json.deserializeUntyped(js); // deserialized without type
        for (Object o : (List<Object>) resultObject)
        {
            result.add((Map<String, Object>) o);
        }
        return result;
    }
}