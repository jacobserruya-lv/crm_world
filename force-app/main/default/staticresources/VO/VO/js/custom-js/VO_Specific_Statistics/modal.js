/* 
return true if channel selected and he not "No action " and if we have rootcause -check if any value are selected
otherwise -false
 */
function validtionPickList()
{
   return !($('.Chanel :selected').attr('value') =="" || $('.Chanel :selected').attr('value') == "No action"
				|| ( $('.rootCause').size()>0 && ($('.rootCause :selected').attr('value') =="" || $('.rootCause :selected').size() == 0)
					))
}

/*
called once the user click on the save survey in the popup
 */

function saveModalJS()
{
	var strComment = $('#newComment').val();
	var strChanel = $('.Chanel :selected').attr('value');
	var strRoot = $('.rootCause :selected').attr('value');
	var checkedCA = $('input.CACheckBox').is(':checked');
	var recordId = $('#surveyModalId').text().trim();
	
	$('.errorMsg').hide();//IN CASE HE CLICK CLOSE->DIDNT SUCCESS AND THEN CLICK SAVE
	$('.errorMsgBlock').hide();
	$('.errorMsgBannedWord').hide();
	if(!bannedWordHandler.containBannedWords(strComment))
	{

		if(strChanel === "No action")
		{
			updateStatus($('#surveyModalId').text().trim(),"No action");
		}
		updateRootChannelCommentHistory(recordId,newRootChoose(), strChanel, strComment);
		
		clickSaveModal(strComment, strChanel, strRoot, checkedCA,newRootChoose());
	}
	else
	{
		$('.errorMsgBlock').show();
		$('.errorMsgBannedWord').show();
		console.log('CONTAIN BANNED WORD -NO UPDATE FOR YOU!');
	}
}

/*
called once the user click on the close survey in the popup
 */

function closeModalJS()
{
	var strComment = $('#newComment').val();
	var strChanel = $('.Chanel :selected').attr('value');
	var strRoot = $('.rootCause :selected').attr('value');
	var checkedCA = $('input.CACheckBox').is(':checked');
	var recordId = $('#surveyModalId').text().trim();
	
	var validtionPickListResult = validtionPickList();
	var containBannedWordsResult  = bannedWordHandler.containBannedWords(strComment)
	
	$('.errorMsg').hide();//IN CASE HE CLICK CLOSE->DIDNT SUCCESS AND THEN CLICK SAVE
	$('.errorMsgBlock').hide();
	$('.errorMsgBannedWord').hide();
	
	if(!validtionPickListResult){
		$('.errorMsg').show();

	}

	if(containBannedWordsResult)
	{
		$('.errorMsgBannedWord').show();
		console.log('CONTAIN BANNED WORD -NO UPDATE FOR YOU!');
	}
		
	if(!containBannedWordsResult && validtionPickListResult)
	{
		updateStatus(recordId,'Closed');
		clickCloseCaseModal(strComment, strChanel, strRoot, checkedCA,newRootChoose());
		updateRootChannelCommentHistory(recordId,newRootChoose(), strChanel, strComment);
	}
	else
	{
		$('.errorMsgBlock').show();
	}
}

/*
get Survey record in the local survey list 
 */
function getSurveyById(id)
{
	return jlinq.from(data)
		.starts("Id", id)
		.select()[0]
}

/*
	handel for when user open a modal
 */
function modalClick(id){
	console.log(id);
	blockUI();
	initModal(id);
}

/*
set the modal by magnificPopup module
 */

function addModalEvent()
{
	  $.magnificPopup.open
	  ({
		  items: {
			src: '#open_product',
			type: 'inline'
		  },

		  showCloseBtn : false,

		  callbacks:
		  {
			open: function()
			{

				sfSelecerFixerInner();
				channelHandler();
				setBootStrapMulty();
				
				$('button.close').click(function(){
					updateStatus($('#surveyModalId').text().trim(),'Pending');
					$.magnificPopup.close();
				});
			}
		  }
		});
	//});
}

/*
get id:survey id
	root,channel,CommentHistroy :the current value of them
res:
	update the table by those changes
 */

function updateRootChannelCommentHistory(id,root, Channel, CommentHistroy)
{
	var recordToUpdate = smartTable.jsonData.filter(function(v) {
							return v.survey.Id === id; // filter out appropriate one
							})[0];
	var oldComment = $('[data-id="'+id+'"] .Comment_HistoryTable').text();
	var oldCommentToolTip = $('[data-id="'+id+'"] .Comment_HistoryTable').attr('title');
	
	$('[data-id="'+id+'"] .ChannelTable').text(Channel);
	$('[data-id="'+id+'"] .ChannelTable').attr('title',Channel);
	
	$('[data-id="'+id+'"] .Root_CauseTable').text(root);
	$('[data-id="'+id+'"] .Root_CauseTable').attr('title',root);
	
	//For test -- no one are work!:( = how to br in atrr?"/
	var newLine = '&#13;';
	var newLine2 = '&#x0a';
	var newLine3 = '\x0A';
	var userName = $('.userName').html();
	var newComment = '';
	var newTooltipComment = '';
	
	var todaydate = getTodayDate();
	if(!smartTable.isBlank(CommentHistroy))
	{
		newComment = todaydate + ' ' + userName + ' ' + CommentHistroy ;
		newTooltipComment = todaydate + ' ' + userName + '\n ' + CommentHistroy + '\n ' ;
	}
	
	if(!smartTable.isBlank(oldComment))
	{
		$('[data-id="'+id+'"] .Comment_HistoryTable').attr('title',newTooltipComment  + oldCommentToolTip);
		$('[data-id="'+id+'"] .Comment_HistoryTable').html( todaydate + ' ' + userName + '  ' + CommentHistroy +  ' ...');
		recordToUpdate.survey.Comment_History__c = newComment + '\n\n' + CommentHistroy;
	}
	else
	{
		$('[data-id="'+id+'"] .Comment_HistoryTable').attr('title',newTooltipComment + ' ');
		$('[data-id="'+id+'"] .Comment_HistoryTable').html( todaydate + ' ' + userName + '  ' + CommentHistroy +  ' ...');
		recordToUpdate.survey.Comment_History__c = newComment;

	}
	//update in local Data
	recordToUpdate.survey.Channel__c = Channel;
	
	recordToUpdate.survey.RootCause__c = root;
	
}

/*
like the name..
 */
function getTodayDate()
{
	var d = new Date();
	var curr_date = d.getDate();
	var curr_month = d.getMonth()+1;
	var curr_year = d.getFullYear();
	if(curr_date < 10)
		curr_date = '0' + curr_date;
	return curr_year+ '-' + curr_month + '-' + curr_date;
}

/*
update the status in the local survey
 */
function updateStatus(id,newStatus)
{
	var result = smartTable.jsonData.filter(function(v) {
	return v.survey.Id === id; // filter out appropriate one
	})[0];
	if(result && $('#ifOnlyReadUser').html().trim() != 'true' )
	{
		if(result.survey.Status__c == 'New' )
		{
			result.survey.Status__c = newStatus;
			updateStatusView(id,newStatus);
		}
		if( (result.survey.Status__c == 'Pending' || result.survey.Status__c ==  'No action') && newStatus == 'Closed')
		{
			result.survey.Status__c = newStatus;
			updateStatusView(id,newStatus);
		}
		//NEW change 4.11.2015
		if( (result.survey.Status__c == 'Pending' || result.survey.Status__c == 'New') && newStatus ==  'No action')
		{
			result.survey.Status__c = newStatus;
			updateStatusView(id,newStatus);
		}
	}

	updatechartDataByJsonData();
}

/*
update the icon of the status by id and the new status
 */
function updateStatusView(id,newStatus)
{
	
	var pendingStr = '<span class=" fa fa-clock-o" style="color:#3d8af7"></span>';
	var newStr     = '<span class="fa fa-exclamation-circle" style="color:#ffa834"></span>';
	var ClosedStr  = '<span class="fa fa-check-circle" style="color:#72bb53"></span>';
	var NoActionStr = '<span class="fa fa-archive"></span>';
	
	statusToSymboleMap = {'Pending':pendingStr,"New":newStr, "Closed":ClosedStr,"No action":NoActionStr};
	
	$('[data-id="'+id+'"].statusSymbole').html(statusToSymboleMap[newStatus]);
}

/*
when one click on the eye
 */
function openCaseDetailPage()
{
	unblockUI(); 
	window.open($('.eyeLinkCaseDetail').text().trim(),'_blank');
}   

/*
like the name said...
 */


function channelNotNoAction()
{
	if($('.Chanel :selected').attr('value') ==='No action')
		$('.CloseButt').hide();
	else
		$('.CloseButt').show();
}
//like the name...
function channelHandler()
{
	channelNotNoAction();
	$('.Chanel .selectpicker').change(function(event){
		channelNotNoAction(event);
	});
}


function createSelectObj(value,ischoose)
{
	return {
		value:value,
		selected:ischoose
	}
}

/*
generate bootstrap multy picklist from SF multypicklist 
 */
function setBootStrapMulty()
{
	var allValues =[];
	if($('#oldValuesRoot').html() !== undefined)
	{
		var choosenList = $('#oldValuesRoot').html().trim();
		var choosen = choosenList.split(';');
		$('.multiSelectPicklistRow option').each(function(index){
			var beenChoose = false;
			for(var index in choosen)
			{
				if(choosen[index] == $(this).text())
				{
					beenChoose = true;
					
				}
			}
			allValues.push(createSelectObj($(this).text(),beenChoose));

		})
		$('.rootCause').html('');
		UTILS.dustRender('tmpl_RootMulty',allValues,$('.rootCause'));
		$('.selectpicker').selectpicker();
	}
}

/*

 return the rootChoose that the user pick as string with ; as delimiter
 */

function newRootChoose()
{
	var NewSelected='';
	$('.selectpicker[multiple] option:selected').each(function(index)
	{
		NewSelected+= $(this).html() +';'
	})
	return NewSelected ;
}
				
// MY 07.1.2016 Remote action impl
// two vars that represent the most inner pick in the search container value the user choose and his value
    var fieldName   = '';
    var fieldValue  = '';

/*
checkValidDate..
 */
    function checkValidDate()
    {
        var dFromArr = $('#from').val().split('-');
        var dToArr = $('#to').val().split('-');
        var dFrom = new Date(dFromArr[2], dFromArr[0], dFromArr[1]);
        var dTo = new Date(dToArr[2], dToArr[0], dToArr[1]);

        if((dTo instanceof Date) &&  (dFrom instanceof Date) && dFrom <= dTo &&(dFrom.setMonth(dFrom.getMonth() + 12) >= dTo))
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

	

