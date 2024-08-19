 /*
	This file are responsible to present in the store picklist only the stores that fit to the survey type
 */


/*
	take the picked survey type and call filterSfSelectFixer.
 */
  function filterStores(){
		var surveyTypeValue = document.querySelector('[id$=":surveyTypeValuesSelect"]').value;
		
		if(surveyTypeValue.indexOf('CSC Click') >=0 )
		{
			surveyType = 'Store_CSC';
		}
		else if(surveyTypeValue.indexOf('WEB Click') >=0 || surveyTypeValue.indexOf('Endless') >=0 )
		{
			surveyType = 'ALL';
		}
		else if(surveyTypeValue.indexOf('CSC Sales') >=0)
		{
			surveyType = 'CSC';
		}
		else if(surveyTypeValue.indexOf('Web Sales') >=0)
		{
			surveyType = 'WEB';
		}
		else{
			surveyType = 'Store';
		}

		filterSfSelectFixer('.store-fixer', storeByType[surveyType]);
	}   
	
	
	//fixerSelector the id of the element of the stores
	//valuesArray which stores can be represent to this user in the store picklist (by his surveytype)
	function filterSfSelectFixer(fixerSelector, valuesArray){
		var $fixerSelector = $(fixerSelector);
		var $options = $fixerSelector.find('select').first().find('option').hide();

		var $ul = $fixerSelector.find('.dropdown-menu.inner').first();
		$ul.find('li[data-original-index]').hide();
		$options.each(function(index, value){
			if(valuesArray)
			{
				if (valuesArray.indexOf(this.value) >= 0)
				{
					$ul.find('li[data-original-index=\'' + index + '\']').show();    
				}
			}
		});
		if(valuesArray.indexOf($('[id$=DefaultStore_InputFieldId] option:selected').attr('value')) === -1
			)
		{
			$fixerSelector.
				find('button').attr('title', '').
				find('span.filter-option').text('--None--');
			$('[id$=DefaultStore_InputFieldId]').val('');

		}
		if (!$('[id$=DefaultStore_InputFieldId] option:selected').html() === $fixerSelector.
			find('button').attr('title'))
		{z
			console.log ('***REALLY ?***');
			console.log ($('[id$=DefaultStore_InputFieldId] option:selected').html() + ' | ' + $fixerSelector.find('button').attr('title'));
		}
		$('[id$=DefaultStore_InputFieldId]').selectpicker(); 
	}    
	/*
	Async function that reun with timeout because SF do some rendering every unset time and we need to keep the design and logic 

	 */
	function setStoreParams_Async(runCounter){
		runCounter = runCounter?runCounter+1: 1;

		var lvl4Elems = $('[id$=level4pl] option').length;
		var storesElems  = $('[id$=DefaultStore_InputFieldId]').siblings('div.btn-group:first').find('li').length;
		if(runCounter > 1 && lvl4Elems>1 && storesElems>1 ){
			filterStores();
		}else if(runCounter<10){
			setTimeout(
			(function(runCounter){
				return function(){
					setStoreParams_Async(runCounter);
				}
			}(runCounter)),150);
		}else{
			console.error('Unable To Parse Country derivation');
		}
	}


	$(document).ready(function(){
		if($('[id$="DefaultStore_InputFieldId"]').val() == '__'  || $('[id$=level4pl]').val()!=''){
			setStoreParams_Async();
		}
	});