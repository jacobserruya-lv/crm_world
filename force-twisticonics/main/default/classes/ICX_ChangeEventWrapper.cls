public class ICX_ChangeEventWrapper {
    
    public ICX_ChangeEventWrapper(EventBus.ChangeEventHeader header, SObject event){
        this.header = header;
        this.event  = event;
        //ChangeEvent ce;
        //System.debug('event'+event);
        //System.debug('event.ChangeEventHeader:'+event.ChangeEventHeader);
    }
    
  public EventBus.ChangeEventHeader header;
    SObject event;
    
    private Map<String,Object> changedFieldsValues;
    
    public Object getChangedFieldsValues(String fieldName) {
        if (changedFieldsValues == null) {
            changedFieldsValues = new Map<String,Object>();
            for(String changedFied: header.changedFields) {
                changedFieldsValues.put(changedFied, event.get(changedFied));
            }
        }
        return changedFieldsValues.get(fieldName);
    } 
}