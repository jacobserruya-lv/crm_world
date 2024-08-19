            
/*
    the object that store all the date for the KPI section 
 */
            var chartData = {   'New':0, 'Pending':0, 'closed':0, 'no action':0,
                                'KPIPC':0, 'PMNew':0,'PMpending':0,
                                'KPIDC':0, 'DCnew':0, 'DCpending':0,
                                'KPIRA':0,'RAnew':0, 'RApending':0, 'RApending7d':0,
                                'PM':0,'DC':0,'RA':0    
                            };

            var jsonDataKPI = {};

/*
function that update the UI screen by the chartData objecr
 */
            function updateKPIandChart()
            {
                var surveryType = document.querySelector('[id$=":surveyTypeValuesSelect"]').value;
                if(VoiceAfterSalesName == surveryType)
                {
                    $('#KPIPROMOTER').show();$('#KPIDELIGHTED').hide();
                    
                }
                else
                {
                    $('#KPIPROMOTER').hide();$('#KPIDELIGHTED').show();
                }
                // Check if gtools is defined
                if ("gtools" in window){
                    gtools.chartTotalData('chartSurveyId1',[['Title','Title'],['New',parseInt(chartData['New'])],['Pending',parseInt(chartData['Pending'])],['Closed',parseInt(chartData['closed'])],['No Action',parseInt(chartData['no action'])]]);
                }

                $('.KPItotal').html();
                $('.KPInew').html(chartData['New']);;
                $('.KPIpending').html(chartData['Pending']);
                $('.KPIclosed').html(chartData['closed']);
                $('.KPInoAction').html(chartData['no action']);
            
                $('.KPIDC').html(chartData['KPIDC']);
                $('.DCnew').html(chartData['DCnew']);
                $('.DCpending').html(chartData['DCpending']);

                $('.KPIPC').html(chartData['KPIPC']);
                $('.PMNew').html(chartData['PMNew']);
                $('.PMpending').html(chartData['PMpending']);

                $('.KPIRA').html(chartData['KPIRA']);
                $('.RAnew').html(chartData['RAnew']);
                $('.RApending').html(chartData['RApending']);
                $('.RApending7d').html(chartData['RApending7d']);
            
            }

/*
Update the chartData object with the data from the jsonDataKPI.
 */
            function updatechartDataByJsonData()
            {   
                /*chartData = { 'New':0, 'Pending':0, 'closed':0, 'no action':0,
                                'KPIPC':0, 'PMNew':0,'PMpending':0,
                                'KPIDC':0, 'DCnew':0, 'DCpending':0,
                                'KPIRA':0,'RAnew':0, 'RApending':0, 'RApending7d':0,
                                'PM':0,'DC':0,'RA':0
                            };*/

                console.log('jsonDataKPI : ');
                console.log(jsonDataKPI);
                chartData = jsonDataKPI;


                /**** These calculations have been moved to server side controller *****/
                            
                /*for(var i = 0;i < jsonDataKPI.length;i++)
                {
                    if(jsonDataKPI[i].survey.Type__c == 'Recovery Act')
                    {
                        chartData['RA']  ++;
                    }
                    if(jsonDataKPI[i].survey.Type__c == 'Delighted Client')
                    {
                        chartData['DC']  ++;
                    }
                    
                    if(jsonDataKPI[i].survey.Type__c == 'Promoter')
                    {
                        chartData['PM']  ++;
                    }
                    
                    if(jsonDataKPI[i].survey.Status__c =='No action')
                    {
                        chartData['no action'] ++;
                    }
                    if(jsonDataKPI[i].survey.Status__c =='Closed')
                    {
                        chartData['closed'] ++;
                    }
                    if(jsonDataKPI[i].survey.Status__c =='New')
                    {
                        chartData['New'] ++;
                        if(jsonDataKPI[i].survey.Type__c == 'Recovery Act')
                        {
                            chartData['RAnew'] ++;
                        }
                        if(jsonDataKPI[i].survey.Type__c == 'Delighted Client')
                        {
                            chartData['DCnew'] ++;
                        }
                        if(jsonDataKPI[i].survey.Type__c == 'Promoter')
                        {
                            chartData['PMNew'] ++;
                        }
                    }
                    if(jsonDataKPI[i].survey.Status__c =='Pending')
                    {
                        chartData['Pending'] ++;
                        if(jsonDataKPI[i].survey.Type__c == 'Recovery Act')
                        {
                            chartData['RApending'] ++;
                            if(moment(jsonDataKPI[i].survey.AnswerDate__c, "YYYY-MM-DD")< moment().add(-7,'d'))
                            {
                                chartData['RApending7d'] ++;
                            }
                        }
                        if(jsonDataKPI[i].survey.Type__c == 'Delighted Client')
                        {
                            chartData['DCpending'] ++;
                           
                        }
                        if(jsonDataKPI[i].survey.Type__c == 'Promoter')
                        {
                            chartData['PMpending'] ++;
                        }
                    }
                }*/

               var total = parseInt(chartData['New']) + parseInt(chartData['Pending']) + parseInt(chartData['closed']) + parseInt(chartData['no action']);
               $('.KPItotal').html(total);
                //var total = parseInt($('.KPItotal').html());
                /*chartData['KPIPC'] = Math.floor(100*((chartData['PM'])/total));
                chartData['KPIDC'] = Math.floor(100*((chartData['DC'])/total));
                chartData['KPIRA'] = Math.floor(100*((chartData['RA']) /total));*/
                updateKPIandChart();
            }

    function initJsonDataKPI (listResults){
        console.log('listResults :');
        console.log(listResults);
        if(listResults == '')
        {
            jsonDataKPI=[];
        }
        else
        {
            jsonDataKPI = JSON.parse(listResults);
            
        }
    }