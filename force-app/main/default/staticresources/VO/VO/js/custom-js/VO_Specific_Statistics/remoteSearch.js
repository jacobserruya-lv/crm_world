    

/*
Called when one click on the search
*/
function clickOnSearchRemote()
{
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

        searchRemote();

    }
    else
    {
        $('#to').addClass('error');
        $('#from').addClass('error');

    }
}
    /*
        update the headers of of the questions in table console 
        */
        function headerTableRemote()
        {
            var surveryType = document.querySelector('[id$=":surveyTypeValuesSelect"]').value;


            VO_Specific_Statistics_CTRL.initHeaderWrapperListQRemoteAction(surveryType,function(result, event)
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

                 smartTable.ansFilter = {};
                 addHandlersToAddPickListToString(recommendedQuestionListObj);
                 clickOnSearchRemote();
                 console.log('FINISH') 


             }
         }, {escape:true});

        }

/*
    add event to the picklist of the recommendedQuestion
    */
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


/*
    after input validtion the real search are happning here
    we create the remoate action and draw the chart
    */
    function searchRemote()
    {

        var fromDate    = $('.fromDate input').val();
        var toDate      = $('.toDate input').val();
        var surveryType = document.querySelector('[id$=":surveyTypeValuesSelect"]').value;
        var maxRecordsPerSerach = parseInt($('#maxRecordsPerSerach').html());

        if(gettingFieldNameAndValue())
        {
            var startTimeMs = (new Date).getTime();   
            newrelic.setCustomAttribute('otherDetails', fieldName + ' ' + fieldValue + ' ' + surveryType + ' ' + fromDate + ' ' + toDate);
            
            blockUIKPI();
            VO_Specific_Statistics_CTRL.mainSearchRemote(fromDate,toDate,surveryType,fieldName,fieldValue,function(result, event)
            {
                if (event.status)
                {
                    varTitle = $('<textarea />').html(result).text();
                    var data = varTitle;
                    smartTable.addListerForSortingAndFilters();

                    smartTable.getSearchResult(data,maxRecordsPerSerach);
                    $('#haveMoreThenLimit').hide();
                    if(smartTable.moreThenResultLimit)
                    {
                        $('#haveMoreThenLimit').show();
                    }
                    console.log(smartTable.jsonData.length);

                    KPIsearchRemote(fromDate,toDate,surveryType,fieldName,fieldValue);

                    exportExcelCustomizeToSupportFieldNameAndValue(fieldName,fieldValue,surveryType,fromDate,toDate)
                    newrelic.addPageAction('VOsearch', {execTime: (((new Date).getTime())-startTimeMs)});
                }
                else{
                    unblockUIKPI();
                }

                unblockUI();
            }, {escape:true});
        }
        else
        {
            unblockUI();
            console.log('You have to choose shop !');
        }
    }

    function blockUIKPI(){
        console.log('block');

        console.log($('[id$=chartToFade]'));
        $('[id$=chartToFade]').fadeTo('fast', '0.2');
    }

    function unblockUIKPI(){
        console.log('unblock');

        $('[id$=chartToFade]').fadeTo('fast', '1.0');
    }

    function KPIsearchRemote(fromDate,toDate,surveryType,fieldName,fieldValue){        
        // querying the chart data separately with only a few fields to allow no limit
        VO_Specific_Statistics_CTRL.KPISearchRemote(fromDate, toDate, surveryType, fieldName, fieldValue, null, function(result, event){

            if (event.status){
                var tmp = $('<textarea />').html(result).text();
                var data = tmp;
                initJsonDataKPI(data);
                updatechartDataByJsonData();

                var tmpParse = JSON.parse(data);

                console.log(tmpParse['hasMore']);


                /****** To fix and use if more that 50k results required *****/

                // if (tmpParse['hasMore'] == 'true'){
                //     console.log('hasMore');
                //     VO_Specific_Statistics_CTRL.KPISearchRemote(fromDate, toDate, surveryType, fieldName, fieldValue, tmpParse['lastId'], function(result, event){
                //         console.log(result);
                //         if (event.status){
                //             var tmp = $('<textarea />').html(result).text();
                //             var data = tmp;
                //             initJsonDataKPI(data);
                //             updatechartDataByJsonData();
                //         }
                //     }, {escape:true});
                // }
            }
            
            unblockUIKPI();

        }, {escape:true});
    }


    // ret Bool  - true -if ca have store and ,and the user enter minimum of 4 letters
    //              also update the fieldName var and value
    //           - false -othewise    
    //      
    function gettingFieldNameAndValue()
    {
        var noStoreOrCALessThen4Letter = false;
        $('.inputSearchPanel select').each(function(index ){
            if(/[a-zA-Z0-9]/.test($(this).val()))
            {
                if($(this).val() != null && ($(this).val()!="__" || $(this).val()!='' || $(this).val()!="__" ))
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