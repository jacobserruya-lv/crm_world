({  
    sort: function(component, event, helper){
        var index = parseInt(event.currentTarget.dataset.index);
        helper.sort(component, index);
    },
    

	openModal: function(component, event, helper){
		var modal;
		$A.createComponent("c:MIY_DataTable",
			{tableData:component.get("v.tableData")},
			function(content, status){
				if(status==="SUCCESS"){
					modal = content;
					component.find("overlayLib").showCustomModal({
						header: $A.get('$Label.c.MIY_OrderPage_Data_Table_View_All_modal_header'),
                        body: modal,
						showCloseButton: true,
						cssClass: "myModal"
					});
				}
		});
    }
})