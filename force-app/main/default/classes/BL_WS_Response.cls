/**
 * 
 * @author Aliza Reishtein
 * @since March 2020
 * @description The structure to be returned to the caller of the Custom Rest Webservice
 * @group balink Webservices General
 * 
 */
public class BL_WS_Response {
    public Object  records {get; set;}
    public Object  record {get; set;}
    public Integer totalSize {get; set;}
    public Boolean done {get; set;}
    public String  queryId {get; set;}
    public Integer pageSize {get; set;}
    public Integer hits {get; set;}
    public Integer currentPage {get; set;}

    /**
     * 
     * @param totalSize the total size of the list
     * @param records the records themselves
     * @param done 
     * @param pageSize the page size for pagination calls
     * @param currentPage the current page for pagination calls
     * @description constructor which takes all parameter explicitly
     */
    public BL_WS_Response(Integer totalSize, Object records, Boolean done, Integer pageSize, Integer currentPage) {
        this.records = records;
        this.record = record;
        this.totalSize = totalSize;
        this.done = done;
        this.pageSize = pageSize;
        this.currentPage = currentPage;
    }

    /**
     * 
     * @param records either one object or a list
     * @description constructor that takes either one object or a list and handles them differently
     */
    public BL_WS_Response(Object records) {
        if (records instanceof List<Object>){
            this.records = records;
            this.totalSize = ((list<Object>)records).size();
            this.hits = ((list<Object>)records).size();
            this.done = true;
        } else if(records instanceof Map<String,Object> ){
            Map<String,Object> queryObj = (Map<String,Object>) records;
            if(queryObj.containsKey('isEasyQuery')){
                this.records = queryObj.get('records');
                this.totalSize = (Integer) queryObj.get('totalSize');
                this.done = true;
                this.pageSize = (Integer) queryObj.get('pageSize');
                this.hits = (Integer) queryObj.get('hits');
                this.currentPage = (Integer) queryObj.get('currentPage');
                this.queryId = (String) queryObj.get('queryId');
            } else {
                this.record = records;//assigning the one record to the records member
            }
        }
        // else if(records instanceof BL_EasyQuery){
        //     BL_EasyQuery queryObj = (BL_EasyQuery) records;
        //     this.records = queryObj.isMapped ? (Object) queryObj.getMappedObjects() : (Object) queryObj.getSObjects();
        //     this.totalSize = queryObj.getTotalSize();
        //     this.done = true;
        //     this.pageSize = queryObj.getPageSize();
        //     this.currentPage = queryObj.getPageIndex();
        //     this.queryId = queryObj.getQueryId();
        // }
        else {
            this.record = records;//assigning the one record to the records member
        }
    }

    /**
     * 
     * @param totalSize total size of the list
     * @param records the records themselves
     * @param done 
     * @param nextUrl the nexturl to set explicitly
     * @description constructor used with pagination when nextUrl set explicitly
     */
    public BL_WS_Response(Integer totalSize, Object records, Boolean done, String queryId) {
        this.records = records;
        this.totalSize = totalSize;
        this.done = done;
        this.queryId = queryId;
    }
}