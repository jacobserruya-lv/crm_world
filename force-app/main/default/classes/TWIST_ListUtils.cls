public with sharing class TWIST_ListUtils {

    /**
    * @description Given a list of maps where each map's element has a common "key" key,
    * returns the element whose "key" value is "value"

    * @param {List,<Object>} listToFilter
    * @param {String} key
    * @param {Object} value

    * @returns {Map<String,Object>}
    */
    public static Map<String,Object> filterByMapKeyValues(List<Object> listToFilter, String key, Object value) {
        try {
            for (Integer i=0; i<listToFilter.size(); i++) {
                Map<String,Object> listElement = (Map<String,Object>) listToFilter.get(i);
                if (listElement.get(key) == value) {
                    System.debug('> found!');
                    return listElement;
                }
            }
        }
        catch(Exception e) {
            System.debug('> Error in method TWIST_ListUtils.filterByMapKeyValues(): ' + e.getMessage());
        }
        return new Map<String,Object>();
    }
    
}