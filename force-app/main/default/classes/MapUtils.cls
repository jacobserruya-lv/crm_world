public with sharing class MapUtils {
    
    public static Map<String,Object> getMapByKeys(Map<String,Object> m, Set<String> keyset) {
        if (m == null || keyset == null) {
            return null;
        }
        Map<String,Object> result = new Map<String,Object>();
        for (String key : keyset) {
            if (m.containsKey(key)) {
                result.put(key, m.get(key));
            }
        }
        return result;
    }

}