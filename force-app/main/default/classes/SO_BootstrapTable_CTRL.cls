public without sharing class SO_BootstrapTable_CTRL{ 


	public static Integer MAX_PAGE_SIZE = 5;//20
	//Component parameters
	public Integer paging_buttons_max_count {get;Set;}		//sets the maximum number of page buttons
	public Integer list_size {get;Set;}		//sets the page size or number of rows
	public String table_id {get;Set;}		//the unique id of the table
	public SO_ITablePagination_INTERFACE paginator {get;Set;}
	

	
	//---------------------- public fields --------------------
	//Public fields to build table
	public Integer total_size {get;Set;}						//used to show user the total size of the list
	public Integer total_pages_count {get;Set;}					//used to show user the total pages amount
	public Integer current_page{get;Set;}						//used to show user the current page
	public String  sort_order {get;Set;}						//tracks current sort order	
	public String  sort_column {get;Set;}						//tracks name of current sorted column
	public Map<String, Map<String, String>> columns{get;Set;}	//keeps the columns (name/parameters(title|width)) to display on the table
	public List<String> paging_buttons{get;Set;}				//current set of buttons
	public Map<Integer, List<Object>> table_rows{get;Set;}		//keeps the current page rows with their values on each column
	public List<String> column_names{get;set;}					//keeps names of columns in right order
	public Boolean showIt{get;Set;}

	//---------------------- private fields --------------------		
	private Integer counter;			//keeps track of the offset
	public Boolean initialized { get; set; }
	
	
	//---------------------- CTOR --------------------
	public SO_BootstrapTable_CTRL(){
	
		initialized = false;
		counter = 0;
       
		//System.debug('SO_BootstrapTable_CTRL.counter >> ' + counter);
		//getInit();
	}

	//---------------------- public methods --------------------
	public String getInit(){

		//System.debug('this.initialized 1 >> ' + this.initialized);
		//System.debug('SO_BootstrapTable_CTRL - getInit - before column_names: ' + this.column_names);
		if (!this.initialized) {
			//System.debug('init >> 2');
			if (this.list_size == null) {
				this.list_size = MAX_PAGE_SIZE;
			}
			this.total_size  = this.paginator == null ? 0 : this.paginator.retTotalCount(this.table_id);

			this.column_names = new List<String>();

			Map<String, String> cols = this.paginator == null ? new Map<String, String>() : this.paginator.retColumns(this.table_id);
			this.columns = new Map<String, Map<String, String>>();
			for(String col : cols.keySet()) 
			{
				if (cols.get(col) == null)
				{
					columns.put(col, null);
					continue;
				}
				/*
					m.put('title', pars[0]);
					m.put('width', 'auto');
					m.put('header-class', '');
					m.put('not-mapped', '');
				*/
				Map<String, String> m = new Map<String, String>();
				m.put('title', '');				//TITLE
				m.put('width', 'auto');			//WIDTH of the column
				m.put('header-class', '');		//CLASS of the header TH
				m.put('sort-by', col);		//sorted field for this column. Use false to avoid sorting on this column
				List<String> pars = cols.get(col).split('!!');
				Integer index = 0;
				for(String par : pars){
					if (index == 0){
						m.put('title', par);
					}
					else{
						String[] keyValue = par.split('=');
						m.put(keyValue[0], keyValue[1]);
					}
					index++;
				}
				this.columns.put(col, m);
			}
			//System.debug('COLUMNS=' + this.columns);
			this.sort_order = '';
			this.sort_column = '';
			this.table_id = this.table_id == null  ? 'table' : this.table_id;
			this.current_page = 1;
			//System.debug('counter 2 >> ' + counter);
			this.counter = 0;
			if (math.mod(this.total_size, this.list_size) > 0) {
				this.total_pages_count = this.total_size / this.list_size + 1;
			}
			else {
				 this.total_pages_count =  this.total_size / this.list_size;
			}
			if (showIt) {
				//System.debug('init >> 3');
				setupPage();
				//System.debug('init >> 4');
			}
		}
		//System.debug('SO_BootstrapTable_CTRL - getInit - after column_names: ' + this.column_names);
		//System.debug('this.initialized 2 >> ' + this.initialized);
		this.initialized = true;

		return null;
	}

	public PageReference Refresh(){		//refreshes table
		//System.debug('SO_BootstrapTable_CTRL - Refresh:');
   		this.initialized = false;
   		getInit();
   		this.initialized = true;
		//setupPage();
		return null;
	}

	public PageReference Beginning() {	//user clicked beginning
		this.counter = 0;
		this.current_page = 1;
		setupPage();
		return null;
   }

   public PageReference Previous() {	//user clicked previous button
		this.counter -= this.list_size;
		this.current_page--;
		setupPage();
		return null;
   }

   public PageReference Next() {		//user clicked next button
		this.counter += this.list_size;
		this.current_page++;
		setupPage();
		return null;
   }

   public PageReference End() {			//user clicked end
		this.counter = this.total_size - Math.mod(this.total_size, this.list_size);
		if (this.counter == this.total_size)
			this.counter = this.total_size - this.list_size;
		this.current_page = this.total_pages_count;
		setupPage();
		return null;
   }
	
   
    
   public PageReference Page() {			//user clicked page number
		String pageN = ApexPages.currentPage().getParameters().get('page_number');
		//System.debug('page number >> ' + pageN);
        
        //page_number = String.isNotBlank(pageN) ? Integer.valueOf(pageN) : 0;
        
		if (pageN == '...') {
			this.current_page = Integer.valueOf(this.paging_buttons[this.paging_buttons.size() - 1]) + 1;	
		} 
		else if (pageN == '....') {
			this.current_page = Integer.valueOf(this.paging_buttons[0]) - 1;	
		} 
		else {
			this.current_page = Integer.valueOf(pageN);
		}
		//this.counter = (this.current_page - 1)  * this.list_size;
		this.counter = (this.current_page - 1)  * this.list_size;
        //System.debug('page , counter >> ' + this.counter);
		setupPage();
		return null;
   }

   public Boolean getDisablePrevious() { 
		//this will disable the previous and beginning buttons
		if (this.counter > 0) {
			return false; 
		}
		else {
			return true;
		}
   }

    
   public Boolean getDisableNext() { //this will disable the next and end buttons
		if (this.counter + this.list_size < this.total_size) {
			return false; 
		}
		else {
			return true;
		}
   }

    public PageReference Sort() {			//user clicked column header to make sorting
		String column = ApexPages.currentPage().getParameters().get('column').escapeHtml4();
		if (column == this.sort_column){
			if (this.sort_order == 'DESC'){
				this.sort_order = '';
				this.sort_column = '';
			} else {
				if (this.sort_order == '') {
					this.sort_order = 'ASC';
				}
				else {
					this.sort_order = 'DESC';
				}
				this.sort_column = column;
			}
		}
		else{
			this.sort_column = column;
			this.sort_order = 'ASC';
		}
		setupPage();
		return null;
   }

    public Boolean getDisableNextPageButtons() { //this will disable the next (...) button
		if (this.paging_buttons == null || this.paging_buttons.size() == 0) {
			return true;
		}
		Integer nextPage = Integer.valueOf(this.paging_buttons[this.paging_buttons.size() - 1]) + 1;
		if ((nextPage)  * this.list_size < this.total_size) {
			return false; 
		}
		else {
			return true;
		}
   }

   public Boolean getDisablePreviousPageButtons() { //this will disable the previous (....) button
		//System.debug('DISABLE='+this.paging_buttons);
		if (this.paging_buttons == null || this.paging_buttons.size() == 0) {
			return true;
		}

		Integer nextPage = Integer.valueOf(this.paging_buttons[0]) - 1;
		if (nextPage >= 1) {
			return false; 
		}
		else {
			return true;
		}
   }

   public String getCurrentPage(){
		return this.current_page + '';
   }

    public String getTotalColumns(){
		return this.columns.keySet().size() + '';
   }

  

   //---------------------- private fields --------------------
   //Setups the table rows && page buttons
   private void setupPage(){
   		//System.debug('SO_BootstrapTable_CTRL - setupPage:');
   		if(null == this.table_rows) {
			this.table_rows = new Map<Integer, List<Object>>();
		}
		else {
			this.table_rows.clear();	
		}

		//System.debug('SO_BootstrapTable_CTRL - before column_names: ' + column_names);
		this.column_names = new List<String>();

		if (this.total_size == 0 || this.paginator == null) {
			return;
		}
		
		//Pagination
		Integer startPage = (Math.round(Math.floor(this.counter / (this.list_size * this.paging_buttons_max_count))) * this.list_size * this.paging_buttons_max_count) / this.list_size + 1;
		Integer pages = this.total_pages_count - startPage + 1;
		if (pages > this.paging_buttons_max_count) {
			pages =  this.paging_buttons_max_count;
		}

		if (pages < 0) {
			pages = 0;	
		}

		if (startPage >= 2 && pages == 0){
			startPage--;
			pages = 1;
		}
		this.paging_buttons = new List<String>(); 
		for(Integer i = 0; i < pages; i++){
			this.paging_buttons.add((startPage + i) + '');	
		}

		//Rows
		Map<String, String> attr = this.columns.get(this.sort_column);
		String sortColumn =  attr == null || attr.get('sort-by') == 'false' ? '' : attr.get('sort-by');
		//System.debug('setupPage , counter >> ' + this.counter);
				//System.debug('this.counter 2 '+this.counter);
					//System.debug('this.list_size <= this.total_size ? this.list_size : this.total_size '+(this.list_size <= this.total_size ? this.list_size : this.total_size));
		List<Map<String, Object>> result = this.paginator.retQueryResult(table_id, 
											this.list_size <= this.total_size ? this.list_size : this.total_size
										   ,this.counter
										   ,sortColumn
										   ,this.sort_order);
		//System.debug('RESULT IS::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: '+result);
		Integer  i = 0;
		for(Map<String, Object> item : result) {

			List<Object> obj = new List<Object>();
			for(String column : this.columns.keySet()) {

				if (this.columns.get(column) == null) {
					continue;
				}

				String template = this.paginator.retTemplate(table_id, column, item);
				if (template == null) {
					Object value = item.get(column);
					obj.add(value);
				}
				else {
					for(String c : this.columns.keySet()){
						//try{
							Object origValue = item.get(c);
							//System.debug('c >>' + c + ' item.get(c) >> ' + origValue + ' template >> ' + template);
							String value = (null != origValue) ? String.valueOf(origValue) : '';
							template = template.replace('['+c+']', value);
						//}
						//catch(Exception ex) {
						//}
					}
					obj.add(template);	
				}
				
			}
			this.table_rows.put(i, obj);
			i++;
		} 

		//this.column_names = new List<String>();
		for(String column : this.columns.keySet()){
			if (this.columns.get(column) == null) {
				 continue;
			}
			this.column_names.add(column);	
		}

		//System.debug('SO_BootstrapTable_CTRL - after column_names: ' + column_names);

		//Poisition
		Integer start_row = (this.current_page - 1) * this.list_size + 1;
		Integer end_row = this.current_page * this.list_size;
		if (end_row > this.total_size) {
			end_row = this.total_size;
		}
		this.paginator.getCurrentPosition(this.table_id, 
										  this.total_pages_count, 
										  this.current_page, this.total_size, 
										  this.counter + 1, start_row, end_row);
		
		//System.debug('total_size:::: '+total_size);
   }
}