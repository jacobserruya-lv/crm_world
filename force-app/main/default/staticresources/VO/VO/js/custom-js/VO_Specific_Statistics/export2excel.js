/*
 * Oct 2016 / Xavier Templet / Integration of New Relic custom attributes 
 * Oct 2016 / Xavier Templet / Use Max records per search Excel in custom settings
 */

function export2excel(SESSION_ID) {

    var AJAX_SETUP_OBJECT = {
        method: 'GET',
        contentType: 'application/json',
        cache: false,
        processData: false,
        beforeSend: function (xhr,b) {
            xhr.setRequestHeader('Authorization', 'Bearer ' + SESSION_ID);
			console.log(b.url);
        },

        error: function() {
        	console.error.bind(console, 'Excel Downloader::AJAX::error');
			newrelic.addPageAction('Export2xlFail', {execTime: (((new Date).getTime())-startTimeMs)});
        },
        always: console.log.bind(console, 'Excel Downloader::AJAX::always'),
    };
    
    function $ajax(url, done) {
        AJAX_SETUP_OBJECT.url = url;

        $.ajax(AJAX_SETUP_OBJECT).done(done);
    }

    function string2Date(strDate) {
        var aa = strDate.split('-');
        return aa[2] + '-' + aa[0] + '-' + aa[1];
    }

    var runNumber = 0,//How many times the user click on Expoer as Excel.
        // lastDownloadLink = '',
        $downloadLink = $('<a/>').prop('type', 'application/vnd.ms-excel').css('display', 'none').appendTo(document.body);

    // Constants (Should be defined in Custom Settings)
    var RECORDS_LIMIT = 30000,
        REMOTING_CALL_DELAY = 500,
        DEFAULT_EXCEL_EXPORT_NAME = 'Specific_Statistics';

    function _cb() {
        unblockUI();
    }

    function mainDownloadRemoteCaller() {
        ++runNumber;

        //gettingFieldNameAndValue(); - export to excel will do that same search as the last time the user click on search.

        // parameters
        var _fromDate    = string2Date($('.fromDate input').val()),
            _toDate      = string2Date($('.toDate input').val()),
            _fieldName   = fieldName  || '',
            _fieldValue  = fieldValue || '';

        var _lastSurveyName = '',
            _chunks = [], //table with all the survey results
			_totalRowsCount = 0,
            _header = '',//store the header of the questions in html table format
            _startTime   = + new Date(),
            _surveryType = document.querySelector('[id$=":surveyTypeValuesSelect"]').value;

        blockUI();

		//Call the remoteAction that return headers for the questions in html format 
        VO_Specific_Statistics_CTRL.initHeaderWrapperListQRemoteAction(
            _surveryType,
            function (result, event) {
                if (!event.status) {
                    console.error(event);
                    _cb(result, event);
                    return;
                }
                result.SurveyType__c = document.querySelector('[id$=":surveyTypeValuesSelect"]').value;

                var $html = $('<div/>');
                var startTimeMs = (new Date).getTime();   
                UTILS.dustRender('tmpl_ExcelExport_Header',
								 result, 
                                 $html,
                                 function (){
                                                _header = $html[0].innerHTML; //set the headers in the var.
												run(); //call the function that handle the surveys part.
											});

            },
            { escape: false }
        );

        // Constant from Custom Settings
        VO_Specific_Statistics_CTRL.getVOConfig(
        		'Max records per search Excel',
                function (result, event) {
                    if (!event.status) {
                        console.error(event);
                        return;
                    }
                    maxrecords = result;
                },
                { escape: false }
        );

		//the function that handle 
        function run() {
            setTimeout(
                function () {
                    var resp;
                    var queryCreatorRemote = function(currSurvayType,_fieldFilter,_valueOf,fromDatedate,toDatedate,maxResult)
                    {
                        //var maxResultForTable = parseInt($('#maxRecordsPerSerach').text().trim());
                        
                        var d2 = jQuery.Deferred();
                        var ans = '';
                        ans += ' SELECT Id, SurveyType__c, Comment_History__c,SurveyComment__c, Status__c,'; 
                        ans += ' StoreID__c, Type__c,Assign_To__c,STOREDELIVERY__c,Device_Type__c, STOREORDER__c,';
                        ans += ' AnswerDate__c, ClientNameText__c, DreamIDText__c, SegmentationText__c,';
                        ans += ' Channel__c,RootCause__c, TransactionProductCategoryCode__c,Store__r.MANAGEMENT_ZONE_LEVEL_TECH__c,';
                        ans += ' Action_delegated_to_CA__c, Follow_up_by__c, StoreNameText__c,ClientDreamID__c, Store__r.MGMT_ZONE_SUB_LEVEL1_TECH__c, Store__r.MGMT_ZONE_SUB_LEVEL2_TECH__c, Store__r.MGMT_ZONE_SUB_LEVEL3_TECH__c,';
                        ans +=  queryCreatorAddOnesForAnsForRemote(currSurvayType);


                        ans += ' FROM VO_Survey__c';
                        ans += ' WHERE ';
                        ans += ' AnswerDate__c >='+ fromDatedate;
                        ans += ' AND AnswerDate__c <=' + toDatedate ;
                        ans += ' AND SurveyType__c=\'' + currSurvayType + '\'';

                        var isAdmin;
                        VO_Specific_Statistics_CTRL.isAdmin(function(result, event){
                            if (event.status){
                                isAdmin = result;
                            }
                        });

                        var hasStores;
                        VO_Specific_Statistics_CTRL.hasStores(function(result, event){
                            if (event.status){
                                hasStores = result;
                            }
                        });


                        var createQuery = function (){
                            var d = jQuery.Deferred();

                            setTimeout(function(){

                                if(!isBlank(_fieldFilter) && !isBlank(_valueOf))
                                {
                                    if (!isAdmin && !_fieldFilter.includes('StoreID__c') && hasStores){
                                        _fieldFilter = _fieldFilter.includes(';') ? 'StoreID__c;' + _fieldFilter.substring(_fieldFilter.indexOf(';') + 1, _fieldFilter.length) : 'StoreID__c';
                                        _valueOf = _valueOf.includes(';') ? '--NOSTORE--;' + _valueOf.substring(_valueOf.indexOf(';') + 1, _valueOf.length) : '--NOSTORE--';
                                    }

                                    if(_fieldFilter.split(';').length == 2 && _valueOf.split(';').length == 2 ) //when we have CA field too
                                    {
                                        ans += ' AND '+_fieldFilter.split(';')[0] +' IN (\''+ _valueOf.split(';')[0].split(',').join('\',\'') + '\')';
                                        ans += ' AND '+_fieldFilter.split(';')[1] +' LIKE \'%'+ _valueOf.split(';')[1] + '%\' ';
                                    }
                                    else
                                    {
                                        ans += ' AND ' + _fieldFilter +' IN (\'' + _valueOf.toString().split(',').join('\',\'') + '\')';
                                    }
                                }
                                ans += ' ORDER BY AnswerDate__c DESC';
                                
                                if (maxResult != null && maxResult !=0)
                                    ans += ' LIMIT ' + (maxResult + 1);//MY:20.01.2016: due to adding more then EFAULT_n_RESUALTS_PER_SEARCH records massage.

                                d.resolve();
                            }, REMOTING_CALL_DELAY);

                            return d.promise();
                        }
                        
                        createQuery().then(function(){
                            resp = ans;
                            console.log(ans);
                            d2.resolve();
                        });

                        return d2.promise();
                    }
					queryCreatorRemote(_surveryType,_fieldName,_fieldValue,_fromDate,_toDate, maxrecords).then(function(){
					
                        $ajax('/services/data/v37.0/query/?q=' + encodeURIComponent(resp), next);//REST API CALL`

                        function next(response) {
                            Array.prototype.push.apply(_chunks, response.records);

                            if (response.done)
                                render();
                            else {

                                $ajax(response.nextRecordsUrl, next); //response.nextRecordsUrl get from SF; act as db.curser 
                            }
                        }
                        newrelic.setCustomAttribute('otherDetails', _fieldName + ' ' + _fieldValue + ' ' + _surveryType + ' ' + _fromDate + ' ' + _toDate + ' ' + maxrecords);
						newrelic.addPageAction('Export2xlRequest', {execTime: (((new Date).getTime())-startTimeMs)});
                    });
                },
                REMOTING_CALL_DELAY
            );
        }

		//After getting all the result this funciton get all the resuilt and redner them to the excel file with Dust.js
        function render() {
            var $htmlFilters    = $('<div/>'),
                $htmlResultBody = $('<div/>');

            _totalRowsCount = _chunks.length;

            // BEGIN RMOU
            var opts = $('[id$=UserStores_InputFieldId_div]').find('li').filter('.selected');
            var stores = [];
            $.each(opts, function(index, item){
                if ($(item).find('span').get(0).innerHTML != '--ALL--'){
                    stores.push($(item).find('span').get(0).innerHTML);
                }
            });

            // END RMOU

            UTILS.dustRender(
                'tmpl_ExcelExport_FilterKeys',//template name;we will render the filter table first
                {
                    fromDate: $('.fromDate input').val(),
                    toDate:   $('.toDate input').val(),
                    amountOfsuerveyExported: _totalRowsCount,

                    lvl1Value: $('[id$="level1pl"] ~ * .filter-option').text(),
                    lvl2Value: $('[id$="level2pl"] ~ * .filter-option').text(),
                    lvl3Value: $('[id$="level3pl"] ~ * .filter-option').text(),
                    lvl4Value: $('[id$="level4pl"] ~ * .filter-option').text(),
                    store:     stores.join(),
                },
                $htmlFilters,
                function () {
                    UTILS.dustRender(
                        'tmpl_ExcelExport',//template name; we will render the survey table
                        addSortedAnswerArrayResult(_chunks),
                        $htmlResultBody,
                        function () { delete _chunks, saveToDisk($htmlFilters[0].innerHTML, $htmlResultBody[0].innerHTML); }
                    );
                }
            );
        }
		// get the filter table and the results table and make them an excel file.
        function saveToDisk(htmlFilters, htmlResultBody) {
            window.URL.revokeObjectURL($downloadLink.prop('href'));

            var bb = new Blob(
                [ '<meta charset="UTF-8" />', htmlFilters, '<table border="1"><thead>', _header, '</thead><tbody>', htmlResultBody, '</tbody></table>' ],
                { type: 'application/vnd.ms-excel' }
            );
			
			if(window.navigator.msSaveOrOpenBlob)
			{
				window.navigator.msSaveOrOpenBlob(bb, DEFAULT_EXCEL_EXPORT_NAME + ' ' + moment().format('YYYY-MM-DD_hh-mm') + '.xls');

			}
			else{
				$downloadLink.
					prop({
						download: (DEFAULT_EXCEL_EXPORT_NAME + ' ' + moment().format('YYYY-MM-DD_hh-mm') + '.xls'),
						href: window.URL.createObjectURL(bb)
					}).
					get(0).
					click();
			}

            console.log(
                'mainDownloadRemoteCaller(#'+runNumber+'): finished. total time: %s. total rows count: %i, total size: %i(b)',
                moment.duration(+new Date() - _startTime).humanize(),
                _totalRowsCount,
                bb.size
            );

            _cb($downloadLink);

            // cleanup after minute
            setTimeout(
                function () { window.URL.revokeObjectURL($downloadLink); },
                60 * 1000
            );
        }

        function addSortedAnswerArrayResult(dataChunks) {
            var surveyTypeIndex = ($('[id$="surveyTypeValuesSelect"]')[0].selectedIndex) || 0;
            var ansArray = $('#answerOrderBySurveyType > span:nth-child(' + (surveyTypeIndex + 1) + ')').
                html().
                split(';').
                map(function (k) { return 'Q' + (k < 10 ? ('0'+k) : k) + 'Answer__c'; }); // normalise answers columns

            return dataChunks.map(function (d) {
                d.AnswerDate__c = moment(d.AnswerDate__c).format('YYYY-MM-DD');

                d.answerTableList = ansArray.map(function (headName) { return d[headName] || ''; });
                return d;
            });
        }

    }
	//Attach button to the main function.
    $('#postExcelLinkId').click(mainDownloadRemoteCaller);

}

/*
function queryCreatorRemote(currSurvayType,_fieldFilter,_valueOf,fromDatedate,toDatedate,maxResult)
{
    var REMOTING_CALL_DELAY = 500;
	//var maxResultForTable = parseInt($('#maxRecordsPerSerach').text().trim());
	
	var ans = '';
	ans += ' SELECT Id, SurveyType__c, Comment_History__c,SurveyComment__c, Status__c,'; 
	ans += ' StoreID__c, Type__c,Assign_To__c,STOREDELIVERY__c,Device_Type__c, STOREORDER__c,';
	ans += ' AnswerDate__c, ClientNameText__c, DreamIDText__c, SegmentationText__c,';
	ans += ' Channel__c,RootCause__c, TransactionProductCategoryCode__c,';
	ans += ' Action_delegated_to_CA__c, Follow_up_by__c, StoreNameText__c,ClientDreamID__c,';
	ans +=  queryCreatorAddOnesForAnsForRemote(currSurvayType);


	ans += ' FROM VO_Survey__c';
	ans += ' WHERE ';
	ans += ' AnswerDate__c >='+	fromDatedate;
	ans += ' AND AnswerDate__c <=' + toDatedate ;
	ans += ' AND SurveyType__c=\'' + currSurvayType + '\'';

    var isAdmin;
    VO_Specific_Statistics_CTRL.isAdmin(function(result, event){
        if (event.status){
            isAdmin = result;
            console.log('admin');
        }
    });

    var hasStores;
    VO_Specific_Statistics_CTRL.hasStores(function(result, event){
        if (event.status){
            hasStores = result;
            console.log('store');
        }
    });


    var createQuery = function (){
        var d = jQuery.Deferred();

        setTimeout(function(){
            console.log ('isAdmin : ' + isAdmin);
            console.log ('hasStores : ' + hasStores);

        	if(!isBlank(_fieldFilter) && !isBlank(_valueOf))
        	{
        		if(_fieldFilter.split(';').length == 2 && _valueOf.split(';').length == 2 ) //when we have CA field too
        		{
        			ans += ' AND '+_fieldFilter.split(';')[0] +'=\''+ _valueOf.split(';')[0] + '\'';
        			ans += ' AND '+_fieldFilter.split(';')[1] +' LIKE \'%'+ _valueOf.split(';')[1] + '%\' ';
        		}
        		else
        		{
        			ans += ' AND ' + _fieldFilter +'=\'' + _valueOf + '\'';
        		}
        	}
        	ans += ' ORDER BY AnswerDate__c DESC';
        	
        	if (maxResult != null && maxResult !=0)
        		ans += ' LIMIT ' + (maxResult + 1);//MY:20.01.2016: due to adding more then EFAULT_n_RESUALTS_PER_SEARCH records massage.

            d.resolve();
        }, REMOTING_CALL_DELAY);

        return d.promise();
    }
    
    createQuery().then(function(){
        console.log('returning');
        console.log(ans);
        return ans;
    });

    console.log('ici ?');
}
*/


function queryCreatorAddOnesForAnsForRemote(surveyType)
{
	return addSortedAnswerArrayResult();
}

function initAnswerToRepresentList(surveyType)
{
		var indexchoose = $('[id$="surveyTypeValuesSelect"] option:selected').index(); //the number of the choose surveyType
		var ansArray = $($('#answerOrderBySurveyType span')[indexchoose]).html().split(';')
		return ansArray;
}

function addSortedAnswerArrayResult()
{
		var surveyTypeIndex = ($('[id$="surveyTypeValuesSelect"]')[0].selectedIndex) || 0;
		var ansArray = $('#answerOrderBySurveyType > span:nth-child(' + (surveyTypeIndex + 1) + ')').
			html().
			split(';').
			map(function (k) { return 'Q' + (k < 10 ? ('0'+k) : k) + 'Answer__c'; }); // normalise answers columns
		return ansArray;
}

function isBlank(str) {
	return (!str || /^\s*$/.test(str));
}