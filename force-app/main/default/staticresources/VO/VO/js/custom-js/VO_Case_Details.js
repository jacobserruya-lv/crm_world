
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
		clickSaveModal(strComment, strChanel, strRoot, checkedCA,newRootChoose());
		var status = 'Pending';
		if(strChanel === "No action")
		{
			status = "No action";
		}
		upDateTableTab(recordId,status,strChanel,strComment, strRoot, newRootChoose());
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
		
		clickCloseCaseModal(strComment, strChanel, strRoot, checkedCA,newRootChoose());
		upDateTableTab(recordId,'Closed',strChanel,strComment, strRoot, newRootChoose());
	}
	else
	{
		$('.errorMsgBlock').show();
	}
	
}


/*
change the amount depend on the currency
 */
function updateSpen()
{
	var selected = $('select.HistTurnOver option:selected').val();
	var newSpend= $('.HSspend [data-id='+selected+']').text();
	$('#histTurnoverValue').text(newSpend);
}

/*
event when user change currency
 */
(function initHistTurnover()
{
	var def=$('#userCurrency').text();
	$("select.HistTurnOver").val(def);
	$('select.HistTurnOver option[value='+def+']').attr('select','selected');
	updateSpen();
	$('select').change(function(){
		updateSpen();

	})
	
})();

//=============== 		data between tabs.    =====================

/*
the obj we send between tabs
 */
function createUpdateTableInTabObj (id, status, root,comment,channel)
{
	return {id:id,status:status ,root:root, comment:comment, channel:channel}
}
/*
setter to thise obj
 */
function setObjectInWebStorage(obj)
{
localStorage.setItem(obj.id, JSON.stringify(obj));
}

function upDateTableTab(recordId,status,strChanel,strComment, strRoot, newRootChoose)
{
	setObjectInWebStorage(createUpdateTableInTabObj(recordId,status,newRootChoose,strComment,strChanel))
}

/*
set the modal by magnificPopup module
 */
function openModal()
{
	 $.magnificPopup.open({
	  items: {
		src: '#open_product',
		type: 'inline'
	  },

	  showCloseBtn : false,

	  callbacks:
	  {
		open: function()
		{
				$('button.close').click(function(){
					$.magnificPopup.close();
				});
		}
	  }
	});  
}

/*
like the name said...
 */
function channelHandler()
{
	channelNotNoAction();
	$('.selectpicker').change(function(event){

		channelNotNoAction(event);event.preventDefault();
	});
}

/*
once the user click on channel no action the save button will disappear 
 */

function channelNotNoAction()
{
	if($('.Chanel :selected').attr('value') ==='No action')
	{
		$('.save').hide();
	}
	else
	{
		$('.save').show();
	}
}

$(document).ready(function()
{
	UTILS.compileDustTemplates();
	setBootStrapMulty();
});

/*
Needed in order to suppot webStorage in IE
 */
function addSupportToWebStorage ()
{
	!localStorage && (l = location, p = l.pathname.replace(/(^..)(:)/, "$1$$"), (l.href = l.protocol + "//127.0.0.1" + p));
}
addSupportToWebStorage();


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
	if($('#oldValuesRoot').html()!== undefined)
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

