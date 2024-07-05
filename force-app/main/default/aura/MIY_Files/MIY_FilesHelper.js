({
	getFiles: function (component) {
		var action = component.get("c.getRelatedFiles");
		action.setParams({recordId: component.get("v.recordId")});
		action.setCallback(this,function(result){
			if(result.getState() ==="SUCCESS" ){
				var filesData = {};
				filesData.headers = [
                    {label: $A.get('$Label.c.MIY_OrderPage_Files_Header_Name'), type: "File", sortable: true},
					{label: $A.get('$Label.c.MIY_OrderPage_Files_Header_Type'), type: "String", sortable: true},
                    {label: $A.get('$Label.c.MIY_OrderPage_Files_Header_Date'), type: "Date", sortable: true},
                    {label: "", type: "Icon", sortable: false}
                ];
				filesData.rows = [];
				result.getReturnValue().forEach(function(fileW){
					filesData.rows.push(this.createRow(fileW));
				}, this);
				component.set("v.filesData", filesData);
			}
		});
		$A.enqueueAction(action);
	},

	createRow : function(file){
        var row = [];
        row.push({label: file.file.Title, id: file.file.Id});
		row.push({label: file.file.FileType});
        row.push({date: file.file.CreatedDate});
		if(!$A.util.isEmpty(file.relatedMail)){
			if(file.relatedMail.Incoming)
				row.push({label: $A.get('$Label.c.MIY_OrderPage_Files_Incoming'), iconName:'utility:undo'});
			else
				row.push({label: $A.get('$Label.c.MIY_OrderPage_Files_Outgoing'), iconName:'utility:redo'});
		}
		else{
			row.push({});
		}
        return row;
    },
})