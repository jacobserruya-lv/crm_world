

/*
	milisecDelay - int for the interval 
 */
function inisfSelectFixer(milisecDelay)
{
	sfSelectFixer(100);
	$('.sfSelectFixer').click(function(){
		sfSelectFixer(100);
	});
	$('button.close').click(function(){
		$.magnificPopup.close();
	});
}

  $('#from').blur(function(){
	  if(smartTable.isBlank($(this).val()))
	  {
	   $('#from').addClass('error');
		 
	  }
	  else
	  {
		 $('#from').removeClass('error'); 
	  }
  });
  
  $('#to').blur(function(){
	  if(smartTable.isBlank($(this).val()))
	  {
		$('#to').addClass('error');
	  }
	  else
	  {

		$('#to').removeClass('error');
	  }

  });

/*
return:
	true  - if the date are valid
	false - otherwise
 */
function checkValidDate()
{
	var dFromArr = $('#from').val().split('-');
	var dToArr = $('#to').val().split('-');
	var dFrom = new Date(dFromArr[2], dFromArr[0], dFromArr[1]);
	var dTo = new Date(dToArr[2], dToArr[0], dToArr[1]);

	if((dTo instanceof Date) &&  (dFrom instanceof Date) && (dFrom.setMonth(dFrom.getMonth() + 12) >= dTo))
	{

		return true;
	}
	else
	{
		unblockUI();
		console.log('more then 12 month or invalid date');
		return false;
	}
}

/*
if admin - can see all
otherise find all the inputs with the readonlClass and put them disable
 */
function readOnlyIfNotAdmins(milSecDelay)
{
	setTimeout(function(){
		if(!IsAdmin)
			$('.readonlClass button').addClass('disabled');
	 },milSecDelay)
}
/*
if admin - can see all
otherise find all the inputs with the readonlClass and put them disable
 */

function readOnlyIfNotAdminsInner()
{     
	if(!IsAdmin){
		$('.readonlClass button').addClass('disabled');
	}
}

/*
fix the SF inputs - again SF generate and broke the design so we need to do it with timeout
 */
function sfSelectFixer (milSecDelay)
{   
	setTimeout(function(){
		sfSelecerFixerInner();
	 },milSecDelay)
}

/*
fix the SF inputs - again SF generate and broke the design so we need to do it with timeout
 */
function sfSelecerFixerInner()
{
	$('.sfSelectFixer select').addClass('selectpicker').attr('data-width','100%');
	$('.selectpicker').selectpicker();
	readOnlyIfNotAdminsInner();
}


/*
fix the SF inputs - again SF generate and broke the design so we need to do it with timeout
 */
$('.sfSelectFixer').click(function(){
		sfSelectFixer(100);
	}
);

/*
init the datepicker for the To and Form  and set the format
 */
function initDataPickers()
{
	$('.datepicker').datepicker({
		format: 'mm-dd-yyyy'
	});
}

/*
call the action function 
 */
function clearFormJS()
{
	clearForm();
}
/*
the old search...
 */
function search()
{
	if(checkValidDate())
	{
		mainSearch($('#from').val(), $('#to').val());
	}
}
