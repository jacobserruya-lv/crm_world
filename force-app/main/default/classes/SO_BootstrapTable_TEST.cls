@isTest
private class SO_BootstrapTable_TEST {
	
	@isTest static void test_method_one() {
		System.currentPageReference().getParameters().put('page_number', '4');
		test_paginator testPaginator = new test_paginator();
		SO_BootstrapTable_CTRL bootstrap = new SO_BootstrapTable_CTRL();
		bootstrap.paginator = testPaginator;
		bootstrap.showIt = false;
		bootstrap.table_id = '1234';
		bootstrap.list_size =1;
		bootstrap.paging_buttons_max_count =20;
		bootstrap.getInit();
		bootstrap.Refresh();
		bootstrap.Beginning();
		bootstrap.Next();
		bootstrap.Previous();
		bootstrap.End();
		bootstrap.Page();
		bootstrap.getDisableNext();

		bootstrap.sort_column = 'DESC';
		bootstrap.columns = new Map<String, Map<String, String>>{'testMap'=>new Map<String, String>{'test'=>'testValue'}};
		System.currentPageReference().getParameters().put('column', 'DESC');
		bootstrap.Sort();
		bootstrap.sort_order = 'DESC';
		bootstrap.Sort();

		System.currentPageReference().getParameters().put('column', 'DES');
		bootstrap.Sort();

		bootstrap.getDisableNextPageButtons();
		bootstrap.paging_buttons = new List<String>{'1'};
		bootstrap.getDisableNextPageButtons();
		bootstrap.getDisablePreviousPageButtons();
		bootstrap.getDisablePrevious();
		bootstrap.getCurrentPage();
		bootstrap.getTotalColumns();
		bootstrap.getDisablePrevious();
		bootstrap.list_size = 0;
		bootstrap.total_size = 25;
		bootstrap.getDisableNext();
	}
	@isTest static void testNoPeginator() {
		System.currentPageReference().getParameters().put('page_number', '4');
		
		SO_BootstrapTable_CTRL bootstrap = new SO_BootstrapTable_CTRL();
		bootstrap.showIt = false;
		bootstrap.getInit();
		bootstrap.Refresh();
		bootstrap.Beginning();
		bootstrap.Next();
		bootstrap.Previous();
		bootstrap.End();
		bootstrap.Page();
		bootstrap.getDisableNext();
	}
	
	class test_paginator  implements SO_ITablePagination_INTERFACE { 
		public test_paginator(){}
		public Map<String, String> retColumns(string tableId){
			return new Map<String, String> {'Name' => 'Name'};
		}
		public List<Map<String, Object>> retQueryResult(String tableId, Integer lim, Integer offset, String sortColumn, String sortOrder){
			return new List<Map<String, Object>>{new map<String, Object>{'test' =>new Account(Name='Test')}};
		}
		public Integer retTotalCount(string tableId){
			return 1;
		}
		public void getCurrentPosition(String tableId, Integer totalPages, Integer currentPage, Integer totalRows, Integer currentRow, Integer rowFrom, Integer rowTo){

		}
		public String retTemplate(String tableId, String field, Object target){
			return 'Test';
		}
	}
	
}