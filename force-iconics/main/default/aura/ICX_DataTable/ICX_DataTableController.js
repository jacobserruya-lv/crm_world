({  
    sort: function(component, event, helper){
        var index = parseInt(event.currentTarget.dataset.index);
        /*var headers = component.get("v.tableData.headers");
        var header = headers[index];*/
        helper.sort(component, index);
    },
    

	openModal: function(component, event, helper){
		var modal;
		$A.createComponent("c:ICX_DataTable", 
			{tableData:component.get("v.tableData")},
			function(content, status){
				if(status==="SUCCESS"){
					modal = content;
					component.find("overlayLib").showCustomModal({
						header: "View All",
                        body: modal,
						showCloseButton: true,
						cssClass: "myModal"
					});
				}
		});
    }
})