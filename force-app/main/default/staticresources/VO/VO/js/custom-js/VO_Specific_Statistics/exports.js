

/*
Old function.
called when one was clicking on the exxport to excel
 */
function setParamForExcel(lvl1, lvl2, lvl3, lvl4, storeName, ca, fromDate, toDate, surveyType)
{
	$("a.postExcel").unbind();
	$("a.postExcel").click(function(e) 
	{
		$("#exports").html('');
		e.stopPropagation();
		e.preventDefault();
		var href = this.href;
		var complexObj = {lvl1:lvl1, lvl2: lvl2,
						   lvl3:lvl3,lvl4:lvl4,storeName:storeName,ca:ca,fromDate:fromDate,toDate:toDate
							,surveyType:surveyType};
		var inputs;
		var url = href;
		for(var key in complexObj)
		{
			inputs += '<input type="hidden" name="' + key + '" value="' + complexObj[key] + '" />';
		}
		$("#exports").append('<form action="'+url+'" method="post" id="posterExcel">'+inputs+'</form>');
		$("#posterExcel").submit();
		$("#posterExcel").hide();
	});
}

/*

called when one was clicking on the exxport to Pdf.
sent to the pdf page the ids of the survey that should be called
 */

	$("a.postPdf").unbind();
	$("a.postPdf").click(function(e) 
	{
		
		$("#exports").html('');
		var checkedIdArray = []
		$('input:checkbox[data-id]:checked').each(function () {
			   checkedIdArray.push($(this).attr('data-id'));
			   console.log((this.checked));
		});
	/*VOICE 2: CR 18 
			MY:21.01.2016
			all those ones that checked in the checkbox for the pfd should change status to pending
    */
		if(checkedIdArray.length >  0)
		{
			VO_Specific_Statistics_CTRL.changeSurveyStatusAfterexportToPDF(checkedIdArray,function(result, event){
			
				if (event.status)
				{
					for(var x = 0;x<result.length;x++)
					{
						updateStatus(result[x],'Pending');
					}
				}
			})
		

			e.stopPropagation();
			e.preventDefault();
			var href = this.href;
			// var complexObj = {lvl1:lvl1, lvl2: lvl2,
			//                    lvl3:lvl3,lvl4:lvl4,storeName:storeName,ca:ca,fromDate:fromDate,toDate:toDate
			//                     ,surveyType:surveyType};
			var inputs;
			var url = href;
			inputs += '<input type="hidden" name="size" value="' + checkedIdArray.length + '" />';
			for(var key in checkedIdArray)
			{
				inputs += '<input type="hidden" name="' + key + '" value="' + checkedIdArray[key] + '" />';
			}
			$("#exports").append('<form action="'+url+'" method="post" id="posterPDF" target="_blank">'+inputs+'</form>');
			$("#posterPDF").submit();
			$("#posterPDF").hide();
		}
		else
		{
			alert(checkCustomLable);
			e.preventDefault();
		}
	});
	

	/*
	Old function...not in user
	 */
	function exportExcelCustomizeToSupportFieldNameAndValue(fieldName , fieldValueCode, surveryType, fromDate, toDate )
    {
        if(fieldName =='CAName__c')
            setParamForExcel('', '', '' , '', '', fieldValueCode, fromDate,toDate, surveryType);
        else if(fieldName =='StoreID__c')
            setParamForExcel('', '', '', '', fieldValueCode, '', fromDate,toDate, surveryType);
        
        else if(fieldName =='MGMT_ZONE_SUB_LEVEL3__c')
            setParamForExcel('', '', '', fieldValueCode, '', '', fromDate,toDate, surveryType);
        
        else if(fieldName =='MGMT_ZONE_SUB_LEVEL2__c')
            setParamForExcel('', '', fieldValueCode, '', '', '', fromDate,toDate, surveryType);
        
        else if(fieldName =='MGMT_ZONE_SUB_LEVEL1__c')
            setParamForExcel('', fieldValueCode, '' , '', '', '', fromDate,toDate, surveryType);
        
        else if(fieldName =='MANAGEMENT_ZONE_LEVEL__c')
            setParamForExcel(fieldValueCode, '', '' , '', '', '', fromDate,toDate, surveryType);
        else 
            setParamForExcel('', '', '' , '', '', '', fromDate,toDate, surveryType);
        

    }
	