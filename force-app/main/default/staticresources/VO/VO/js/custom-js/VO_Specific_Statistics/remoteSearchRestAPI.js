
function remoteSearchRestAPI(SESSION_ID) {

    var AJAX_SETUP_OBJECT = {
        method: 'GET',
        contentType: 'application/json',
        cache: false,
        processData: false,
        beforeSend: function (xhr) {
            xhr.setRequestHeader('Authorization', 'Bearer ' + SESSION_ID);
        },

        error:   console.error.bind(console, 'Excel Downloader::AJAX::error'),
        success: console.log.bind(console, 'Excel Downloader::AJAX::success'),
    };
    function $ajax(url, done) {
        AJAX_SETUP_OBJECT.url = url;
        $.ajax(AJAX_SETUP_OBJECT).done(done);
    }
	

	function string2Date(strDate) {
        var aa = strDate.split('-');
        return aa[2] + '-' + aa[0] + '-' + aa[1];
    }
	
	function searchRemoteRest()
    {
        var _surveryType = document.querySelector('[id$=":surveyTypeValuesSelect"]').value;
        var maxRecordsPerSerach = parseInt($('#maxRecordsPerSerach').text().trim());
		var _surveysArr = [];
		var _startTime   = + new Date();

        if(gettingFieldNameAndValue())
        {

            var _fromDate    = string2Date($('.fromDate input').val()),
				_toDate      = string2Date($('.toDate input').val()),
				_fieldName   = fieldName  || '',
				_fieldValue  = fieldValue || '';
			
			var resp = queryCreatorRemote(_surveryType,_fieldName,_fieldValue,_fromDate,_toDate,maxRecordsPerSerach);
			$ajax('/services/data/v37.0/query/?q=' + encodeURIComponent(resp), next);//REST API CALL
			
			function next(response) {
								Array.prototype.push.apply(_surveysArr, response.records);
								if (response.done || _surveysArr.length === 500)
								{
									doneQuery(_surveysArr,maxRecordsPerSerach,response.done);
								}
									
								else {
									$ajax(response.nextRecordsUrl, next); //response.nextRecordsUrl get from SF; act as db.curser 
								}
							}
		}
		else
        {
            unblockUI();
            console.log('You have to choose shop !');
        }
		unblockUI();
		console.log('Total time for call : ' + moment.duration(+new Date() - _startTime).humanize());
    };
	
	function doneQuery(surveysArr,maxRecordsPerSerach,isDone)
	{
		for(var i=0;i<surveysArr.length;i++)
		{
			surveysArr[i] = {survey:surveysArr[i],
							 answerTableList:null};
		}
		surveysArrJSON = JSON.stringify(surveysArr);
		smartTable.getSearchResult(surveysArrJSON,maxRecordsPerSerach);
		$('#haveMoreThenLimit').hide();
		if(!isDone)
		{
			$('#haveMoreThenLimit').show();
		}
		  
        updatechartDataByJsonData();
        
		//exportExcelCustomizeToSupportFieldNameAndValue(fieldName,fieldValue,surveryType,fromDate,toDate)
		console.log('FINISH')
	}
	
	



	function clickOnSearchRemoteRest()
    {
		blockUI();
		//reset all errror msg
        $('#from').removeClass('error');
        $('#to').removeClass('error');
        $('#caName input').removeClass('error');
        $('.errorSearchMsgBlock').hide();
        $('.dateErrorMsg').hide();
        $('.dateSixMonthMsg').hide();
        $('.caWithoutStoreMsg').hide(); 
        $('.caLessThen4lettersMsg').hide();

        if(checkValidDate())
        {
            searchRemoteRest();
        }
        else
        {
            $('#to').addClass('error');
            $('#from').addClass('error');
			unblockUI();

        }
    }
	$('.searchClickRest').click(clickOnSearchRemoteRest);
	
	//window.clickOnSearchRemoteRest = clickOnSearchRemoteRest;
}


	function headerTableRemoterRest()
    {
        var surveryType = document.querySelector('[id$=":surveyTypeValuesSelect"]').value;


        VO_Specific_Statistics_Testing_CTRL.initHeaderWrapperListQRemoteAction(surveryType,function(result, event)
            {
                if (event.status)
                {
                    FirstHeaderHtmlText = '';
                    SecondHeaderHtmlText = '';
                    var recommendedQuestionListObj =[];
                    for(var i=0;i<result.length ;i++ )
                    {
                        FirstHeaderHtmlText += '<th data-toggle="tooltip" data-origin-ans="'+ result[i].origanSFansNum +'" title="'+result[i].title+'" data-id="'+i+'" class="sortable ansHeaderClass">'+result[i].shortname+'</th>';

                        if(result[i].origanSFansNum == 3){
                            //CR 17
                            recommendedQuestion = {
                                id:'idName',
                                num:i,
                                OptionsList:[
                                        {name:'detractor',vals:['00','01','02','03','04','05','06']},
                                        {name:'passive'  ,vals:['07','08']          },
                                        {name:'promoter' ,vals:['09','10']         }
                                        ],
                                zeroToTen:true};
                            SecondHeaderHtmlText += addPickListToString(recommendedQuestion.id,
                                                                        recommendedQuestion.OptionsList,
                                                                        recommendedQuestion.zeroToTen,
                                                                        recommendedQuestion.num);
                            recommendedQuestionListObj.push(recommendedQuestion);

                        }
                        else if(result[i].origanSFansNum == 2)
                        {//MY:add class colorColumn in order to now who we should color :)
                            SecondHeaderHtmlText += '<th class="ansHeaderClass colorColumn"><input id="ansNum'+i+'" class="form-control input-xs ansFilter" type="text" value="" /></th>';
                        }
                        else
                        {
                           SecondHeaderHtmlText += '<th class="ansHeaderClass"><input id="ansNum'+i+'" class="form-control input-xs ansFilter" type="text" value="" /></th>';
                        }
                    }
                    $( ".ansHeaderClass" ).remove();
                    $('.beforeAnswerHeaderFirst').after(FirstHeaderHtmlText);
                    $('.beforeAnswerHeaderSecond').after(SecondHeaderHtmlText);
                    $('.dropdown').selectpicker();

					addHandlersToAddPickListToString(recommendedQuestionListObj);
					$('.searchClickRest').click();
                }
				else
				{
					unblockUI();
				}
            }, {escape:true});

    }


    function addHandlersToAddPickListToString(recommendedQuestionListObj)
    {
        for(var x=0 ; x <recommendedQuestionListObj.length ; x++ )
        {
            $('#'+ recommendedQuestionListObj[x].id +' li').click(function(event ){
                $(event.target).parent().parent().parent().find('button').html($(event.target).html()+' <span class="caret"></span>')
            })
            smartTable.addListerForRecommendation(recommendedQuestionListObj[x]);
        }
    }

    /*
        generate a picklist and return it as a string.
        id - the id of the ul.
        pickListsValuesArray - array of values that will be in the picklists
        numtoTen -boolean ; if true-> we will add values from 0 to 10 to the picklist
    */
    function addPickListToString(id, pickListsValuesArray, numtoTen, index)
    {
        ans  = '<th class="ansHeaderClass colorColumn">';
        ans +=   '<div class="dropdown">';
        ans +=       '<button aria-expanded="false" aria-haspopup="true" class="btn btn-xs btn-default';
        ans +=        '" data-toggle="dropdown" type="button">';
        ans +=         'All';
        ans +=         '<span class="caret"></span>';
        ans +=        '</button>';
        ans +=         '<ul class="dropdown-menu" id="' + id + '" style="z-index:100000">';
                                            
        ans +=            '<li data-id="all"><a >All</a></li>';

        for(x = 0; x < pickListsValuesArray.length; x++){
            ans +=        '<li data-id="'+pickListsValuesArray[x].name +'"><a>' + pickListsValuesArray[x].name + '</a></li>';
        }

        if(numtoTen){
            for(var num = 0 ; num <= 10; num++)
                ans +=     '<li data-id="'+num +'"><a>' + num + '</a></li>';
        }
                                            
        ans +=         '</ul>';
        ans +=   '</div>';
        ans += '</th>';
        return ans;
    }



            
	// MY 07.1.2016 Remote action impl
    var fieldName   = '';
    var fieldValue  = '';

    // ret Bool  - true -if ca have store and ,and the user enter minimum of 4 letters
    //           - false -othewise        
    function gettingFieldNameAndValue()
    {
        var noStoreOrCALessThen4Letter = false;
        $('.inputSearchPanel select').each(function(index ){
            if(/[a-zA-Z0-9]/.test($(this).val()))
            {
                if($(this).val()!="__" || $(this).val()!='' || $(this).val()!="__" )
                {
                    fieldName = index;
                    fieldValue = $(this).val();
                }
            }
        })
        if(fieldName == 0 )
            {fieldName='';fieldValue='';}
        else if(fieldName == 1 )
            fieldName='MANAGEMENT_ZONE_LEVEL__c';
        else if(fieldName == 2 )
            fieldName='MGMT_ZONE_SUB_LEVEL1__c';
        else if(fieldName == 3 )
            fieldName='MGMT_ZONE_SUB_LEVEL2__c';
        else if(fieldName == 4 )
            fieldName='MGMT_ZONE_SUB_LEVEL3__c';
        else if(fieldName == 5 )
            fieldName='StoreID__c';
        else
            console.log('There is a bug in the fieldName fieldValue');
        if($('.CAName__c input').val())
        {
            if(fieldName !== 'StoreID__c')
            {   
                $('.errorSearchMsgBlock').show();
                $('.caWithoutStoreMsg').show();
                noStoreOrCALessThen4Letter = true;
            }
            
            if($('.CAName__c input').val().length >=3)
            {
                fieldName  = 'StoreID__c;CAName__c' ;
                fieldValue = fieldValue + ';' + $('.CAName__c input').val();
            }
            else
            {
                $('.errorSearchMsgBlock').show();
                $('.caLessThen4lettersMsg').show();
                noStoreOrCALessThen4Letter = true;  
            }

        }
        if(noStoreOrCALessThen4Letter) {
            $('#caName input').addClass('error');
            return false;
        }
        console.log('fieldName: ' + fieldName +  ' fieldValue: ' + fieldValue);
        return true;
    }
	
    function checkValidDate()
    {
        var dFromArr = $('#from').val().split('-');
        var dToArr = $('#to').val().split('-');
        var dFrom = new Date(dFromArr[2], dFromArr[0], dFromArr[1]);
        var dTo = new Date(dToArr[2], dToArr[0], dToArr[1]);

        if((dTo instanceof Date) &&  (dFrom instanceof Date) && dFrom<dTo &&(dFrom.setMonth(dFrom.getMonth() + 12) >= dTo))
        {

            return true;
        }
        else
        {
            var dFrom = new Date(dFromArr[2], dFromArr[0], dFromArr[1]);
            $('.errorSearchMsgBlock').show();
            if(dFrom < dTo && (dFrom.setMonth(dFrom.getMonth() + 12) <= dTo)  )
            {
                $('.dateSixMonthMsg').show();
            }
            else
            {
                $('.dateErrorMsg').show();
            }
            unblockUI();
            console.log('more then 12 month or invalid date');
            return false;
        }
    }