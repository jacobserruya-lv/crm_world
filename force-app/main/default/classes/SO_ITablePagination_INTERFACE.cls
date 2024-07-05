public interface SO_ITablePagination_INTERFACE {
	
	
	 /**
     *  @description        Returns columns in format: name=>params(title!!istemplate(true/false)!!width||header class), where width is optional
    */
	Map<String, String> retColumns(string tableId);

	 /**
     *  @description        Returns current record set to display in the table
    */
	List<Map<String, Object>> retQueryResult(String tableId, Integer lim, Integer offset, String sortColumn, String sortOrder);
	
	/**
     *  @description        Returns total records count
    */
	Integer retTotalCount(string tableId);

	/**
     *  @description        Sends current position within table
    */
	void getCurrentPosition(String tableId, Integer totalPages, Integer currentPage, Integer totalRows, Integer currentRow, Integer rowFrom, Integer rowTo);

	/**
     *  @description        Returns template for given column
    */
	String retTemplate(String tableId, String field, Object target);

 }