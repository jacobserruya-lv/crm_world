public class SO_BreadcrumbParameter{



	//--------------------------- Public fields --------------
	public String	state{get;Set;}
	public String	iconClass{get;Set;}
	public Integer	arrowNumber{get;Set;}
	public String	title{get;Set;}
	public String	description{get;Set;}
	public String	url{get;Set;}
	public String	name{get;Set;}


	public SO_BreadcrumbParameter(String c_name, String c_state,	
		String c_iconClass, Integer c_arrowNumber, 
		String c_title, String c_description, 
		String c_url){
			this.name = c_name == null ? String.valueOf(c_arrowNumber) : c_name;
			this.state = c_state == null ? 'common' : c_state;
			this.iconClass = c_iconClass;
			this.arrowNumber = c_arrowNumber;
			this.title = c_title;
			this.description = c_description;
			this.url = c_url == null ? 'javascript:void(0)' : c_url;
	}

 }