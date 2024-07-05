public class SO_Table_Wrapper {

	public SObject record {get; private set;}
	public Map<String, String> fieldNameToLinkFormat {get; private set;}
	public Map<String, String> fieldNameToFieldIdName {get; private set;}
	public String mapValues {get; private set;}
	public String selectActionLink {get; private set;}
	public String createdDate {get; private set;}

	public SO_Table_Wrapper(SObject record, Map<String, String> fieldNameToLinkFormat, Map<String, String> fieldNameToFieldIdName, String selectActionLink){
		this.record = record;
		this.fieldNameToLinkFormat = fieldNameToLinkFormat;
		this.fieldNameToFieldIdName = fieldNameToFieldIdName;
		this.mapValues = String.join(new List<String>(fieldNameToLinkFormat.keySet()), ' ');
        if(null != record.get('CreatedDate')) {
            this.createdDate = ((DateTime)record.get('CreatedDate')).date().format(); 
        }
		setPageLink(selectActionLink);
	}

	private void setPageLink(String pageLink) {
		if(String.isNotBlank(pageLink)) {
			String prefix = pageLink.contains('?') ? '&id=' : '?id=';
			this.selectActionLink = pageLink + prefix + record.Id; 
		}
	}
}