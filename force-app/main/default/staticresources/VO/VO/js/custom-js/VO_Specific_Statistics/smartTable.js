	/*
		SmartTable;
		Created By :  Menashe Yamin 22/10/2015
	*/

	var smartTable = {};
	(function() {
		//inital fields
		this.jsonData = {}; //data the come from the server.
		this.dataAfterChanges = {}; //currect data that we saw in the table
		this.currPage = 1; //in whitch page are we
		this.firstPage = 1;//
		this.NumOfPages = 1; //how many pages there is
		this.NumOfResualts =10;//How many resualts in page;
		this.moreThenResultLimit = false; ;
		
		//vars that save the client choose for filter and sorting
		this.filterDataObj={SortField:'','TypePickList':'','Comments':'',
						'StatusPickList':'New Pending','Name':'','dreamId':'','segmPickList':'',
						'ChannelPickList':'','rootCause':'','commentHistory':'','TransactionProductCategoryCode':'',
						'statusWasChange':'no','RecommendationPickList':'','RecommendationPickListNumber':'','AssignTo':'',
						'StoreName':'','StoreID':'','DeliveryStore':'','StoreOrder':''};
		
		this.ansFilter = {}; //special var for the all the answers filtering

		
		//methods:
		
		/*The function that called when the server return his answer.
		 listResult- the server resualt
		*/

		this.getSearchResult = function (listResult,maxRecordsPerSerach)
		{
			this.moreThenResultLimit =false;
			if(listResult == '')
			{
				this.jsonData=[];
			}
			else
			{
				this.jsonData = JSON.parse(listResult);
				if(this.jsonData.length > maxRecordsPerSerach)
				{  
					this.moreThenResultLimit = true;
					this.jsonData.pop();
				}
				this.addSortedAnswerArrayResult(this.jsonData);
				
			}

			this.initGlobalParam();

			this.initSearchTable(this.jsonData);
		}
		/*
			2016/01/05: MY 
			MAKEING THE SORTING ANSWER ARRAY IN THE CLIENT TO SAVE TIME 
		*/
		this.addSortedAnswerArrayResult = function(data)
		{
			var indexchoose = $('[id$="surveyTypeValuesSelect"] option:selected').index(); //the number of the choose surveyType
			var ansArray = $($('#answerOrderBySurveyType span')[indexchoose]).html().split(';')



			for(var surveyNum = 0;surveyNum < data.length;surveyNum++)
			{
				data[surveyNum].answerTableList = [];
				for(var i=0;i<ansArray.length;i++)
				{
					if(ansArray[i]<10)
					{
						if(data[surveyNum].survey['Q0'+ansArray[i]+'Answer__c'])
						{
							data[surveyNum].answerTableList.push(data[surveyNum].survey['Q0'+ansArray[i]+'Answer__c']);
						}
						else
						{
							data[surveyNum].answerTableList.push('');
						}
					}
					else
					{
						if(data[surveyNum].survey['Q'+ansArray[i]+'Answer__c'])
						{
							data[surveyNum].answerTableList.push(data[surveyNum].survey['Q'+ansArray[i]+'Answer__c']);				
						}
						else
						{
							data[surveyNum].answerTableList.push('');
						}
					}
				}
			}
		}
		
		this.initSearchTable = function (data)
		{
			this.dataAfterChanges = this.filterAndSorting(this.jsonData);
			this.initSearchUI(this.dataAfterChanges);
		}
		
		//Init all the UI table and pagination
		this.initSearchUI = function  (data)
		{
			this.initNumPagaAndCurrPage(data);
			this.paginationCreator(this.NumOfPages);
			this.updateTableByPage();
		}
		
		
		/*
			after new search
		*/
		this.initGlobalParam = function ()
		{
			this.currPage = 1;
			this.firstPage = 1;
			this.NumOfPages = 1;

			this.NumOfResualts = parseInt($('.numOfResultsInPage a').html().split('<')[0].trim());
			// this.filterDataObj = {SortField:'','TypePickList':'','Comments':'',
			// 					'StatusPickList':'New Pending','Name':'','dreamId':'','segmPickList':'',
			// 					'ChannelPickList':'','rootCause':'','commentHistory':'', 'TransactionProductCategoryCode':'' ,
			// 					'statusWasChange':'no','RecommendationPickList':'','RecommendationPickListNumber':''};
			// this.ansFilter = {};


		}
		
		/*
		get-jsonData after all the change
		output- remove the old map and create the new table with the new data
		*/
		
		//SearchTable section 
		this.refreshTable = function refreshTable(jsonData)
		{
			$('.leftTable').html('');
			$('.rightTable').html('');
			UTILS.dustRender('tmpl_TableLeftPart',jsonData,$('.leftTable'));
			UTILS.dustRender('tmpl_TableRightPart',jsonData,$('.rightTable'));
			this.paintCells();
		}
		
		this.paintCells = function (){
			var colorColumn = []
			//MY:the headers that we need to paint.
			$('.colorColumn').each(function(index ){
			   colorColumn.push($(this).index())
			})

			for(var i=0 ;i<colorColumn.length;i++ )
			{
				$('.rightTable td:nth-child('+(colorColumn[i]+1)+')')
				.each(function(){
					if(!isNaN($(this).html()))
					{
						var num = $(this).html();
						if(num < 7)
						{
							$(this).addClass('cell-background-red');
						}
						if(num == 7 || num == 8)
						{
							$(this).addClass('cell-background-orange');
						}
						if(num == 9 || num == 10)
						{
							$(this).addClass('cell-background-green');
						}

					}
				});
			}
	}
		
		this.isBlank = function(str)
		{
			return (!str || /^\s*$/.test(str));
		}
		
		//P.C. data=arry of object
		//      sortOrderArray = array of string with the first order order
		// sortOrderByStatusArray array of string with the inner order
		//    sort(function(o1,o2){
		//      if (sort_o1_before_o2)    return -1;
		//      else if(sort_o1_after_o2) return  1;
		//      else                      return  0;
		//    });
		this.sortBySpicealOrderTypeAndStatusField = function(data,sortOrderByTypeArray,sortOrderByStatusArray)
		{
			return data.sort(function(obj1, obj2) 
					{
						var rating1=0,rating2=0;
						for(var i=0;i<sortOrderByTypeArray.length ; i++)
						{
							if(obj1.survey.Type__c === sortOrderByTypeArray[i])
							{
								rating1 = i*10;
							}
							if(obj2.survey.Type__c === sortOrderByTypeArray[i])
							{
								rating2 = i*10;
							}
						}
						for(var i=0;i<sortOrderByStatusArray.length ; i++)
						{
							if(obj1.survey.Status__c === sortOrderByStatusArray[i])
							{
								rating1 += i;
							}
							if(obj2.survey.Status__c === sortOrderByStatusArray[i])
							{
								rating2 += i;
							}

						}
						if(rating1 - rating2 == 0)
						{//most recent date
							d1 = new Date(obj1.survey.CreatedDate)
							d2 = new Date(obj2.survey.CreatedDate)
							return d2-d1;

						}
						else
						{
							return rating1 - rating2;
						}
					});
		}
		this.filterAndSorting = function (data)
		{
			var sortOrderByTypeArray = ['Recovery Act','Delighted Client','Promoter','Neutral'];
			var sortOrderByStatusArray = ['New','Pending','Closed','No action'];
			//array that discrabe the order that will survey will see .first arr[0] after [1] ans so on
			//the big If It's because the client want that in the first time you just see those filters:Status = (Pending || New) -need to refact but not have time :(
			//New demand: VO UAT 54: need to sort first by Type and then inner sorting on type by the order of the arrays in top
		
				if(this.filterDataObj.StatusPickList === 'New Pending')
				{
				  res = jlinq.from(data)
					.contains("survey.Status__c", "Pending")
					.or()
					.contains("survey.Status__c", "New").select();
				  res = jlinq.from(res)	
				  	.contains("survey.StoreNameText__c", this.filterDataObj.StoreName)
				  	.contains("survey.StoreID__c", this.filterDataObj.StoreID)
					.contains("survey.Type__c", this.filterDataObj.TypePickList)
					.contains("survey.STOREDELIVERY__c", this.filterDataObj.DeliveryStore)
					.contains("survey.Assign_To__c", this.filterDataObj.AssignTo)
					.contains("survey.SurveyComment__c", this.filterDataObj.Comments)
					.contains("survey.ClientNameText__c", this.filterDataObj.Name)
					.contains("survey.DreamIDText__c", this.filterDataObj.dreamId).select();
					if(this.filterDataObj.segmPickList.length === 0) // 'All' is entered
					{
						res = jlinq.from(res).contains("survey.SegmentationText__c", this.filterDataObj.segmPickList).select();
					}
					else
					{
						res = jlinq.from(res).equals("survey.SegmentationText__c", this.filterDataObj.segmPickList).select();
					}
					res = jlinq.from(res)
					.contains("survey.Channel__c", this.filterDataObj.ChannelPickList)
					.contains("survey.Comment_History__c",this.filterDataObj.commentHistory)
					.contains("survey.TransactionProductCategoryCode__c",this.filterDataObj.TransactionProductCategoryCode)
					.contains("survey.RootCause__c",this.filterDataObj.rootCause);
						
				}
				else
				{
				  res = jlinq.from(data)
				  	.contains("survey.StoreNameText__c", this.filterDataObj.StoreName)
				  	.contains("survey.StoreID__c", this.filterDataObj.StoreID)
					.contains("survey.Type__c", this.filterDataObj.TypePickList)
					.contains("survey.STOREDELIVERY__c", this.filterDataObj.DeliveryStore)
					.contains("survey.Assign_To__c", this.filterDataObj.AssignTo)
					.contains("survey.SurveyComment__c", this.filterDataObj.Comments)
					.contains("survey.Status__c", this.filterDataObj.StatusPickList)
					.contains("survey.ClientNameText__c", this.filterDataObj.Name)
					.contains("survey.DreamIDText__c", this.filterDataObj.dreamId).select();
					if(this.filterDataObj.segmPickList.length === 0)// 'All' is entered
					{
						res = jlinq.from(res).contains("survey.SegmentationText__c", this.filterDataObj.segmPickList).select();
					}
					else
					{
						res = jlinq.from(res).equals("survey.SegmentationText__c", this.filterDataObj.segmPickList).select();
					}
					res = jlinq.from(res)
					.contains("survey.Channel__c", this.filterDataObj.ChannelPickList)
					.contains("survey.Comment_History__c",this.filterDataObj.commentHistory)
					.contains("survey.TransactionProductCategoryCode__c",this.filterDataObj.TransactionProductCategoryCode)
					.contains("survey.RootCause__c",this.filterDataObj.rootCause)
				}

					//filter by ans
					for (var k in this.ansFilter)
					{
						if (this.ansFilter.hasOwnProperty(k)) 
						{
							num = k.split('ansNum')[1];
							if(!Array.isArray(this.ansFilter[k]))
								res=res.contains('answerTableList.'+num,this.ansFilter[k]);
							else
							{
								for(var i=0 ;i < this.ansFilter[k].length;i++)
								{
									if(i == 0)
									{
										res=res.contains('answerTableList.'+num,this.ansFilter[k][i]);
									}
									else
									{
										res=res.or(this.ansFilter[k][i]);
									}
								}
							}
						}
					}
					
									
					
					if(this.filterDataObj.SortField !=='')
					{
						if(isNaN(this.filterDataObj.SortField))
						{
							res = res.sort(this.filterDataObj.SortField).select();
							
						}
						else
						{
							if(this.filterDataObj.SortField[0] === '-')
							{
								res = this.sortAns(this.filterDataObj.SortField.split('-')[1],true,res.select());
							}
							else
							{
								res = this.sortAns(this.filterDataObj.SortField,false,res.select());
							}
						}
					}
					else
					{	res = res.select();
						res = this.sortBySpicealOrderTypeAndStatusField(res,sortOrderByTypeArray,sortOrderByStatusArray);
					}
					
					return res;
		}
		this.sortAns = function (ansNum,topToDown,data)
		{
			if(topToDown)
			{
				//data.sort(function(a, b) {return b.answerTableList[ansNum]- a.answerTableList[ansNum]}); //10 to down
				data.sort(function(a, b) {return b.answerTableList[ansNum].localeCompare(a.answerTableList[ansNum])}); //10 to down

			}
			else
			{
				//data.sort(function(a, b) {return a.answerTableList[ansNum] - b.answerTableList[ansNum]}); //1 to 10
						data.sort(function(a, b) {return a.answerTableList[ansNum].localeCompare(b.answerTableList[ansNum])});
			}
			return data;
		}
		
		//pagination section
		this.initNumOfPages = function  (data)
		{
			return Math.ceil(data.length/this.NumOfResualts);
		}
		
		this.initNumPagaAndCurrPage = function (data)
		{
			this.NumOfPages = this.initNumOfPages(this.dataAfterChanges)
			this.currPage = 1;
		}
		
		this.paginationCreator = function(amountOfPages)
		{
			firstHTML ='<a aria-label="toStart" href="#"><span class="fa fa-step-backward"></span></a>' ;
			prevHTML = '<a aria-label="Previous" href="#"><span class="fa fa-caret-left"></span></a>' ;
			nextHTML = '<a aria-label="Next" href="#"><span class="fa fa-caret-right"></span></a>';
			lastHTML = '<a aria-label="toEnd" href="#"><span class="fa fa-step-forward"></span></a>';
			$('.pageintionClass').bootpag({
				total: amountOfPages,
				page: 1,
				maxVisible: 5,
				leaps: true,
				firstLastUse: true,
				first: firstHTML,
				last: lastHTML,
				next: nextHTML,
				prev: prevHTML,
				wrapClass: 'pagination',
				activeClass: 'active',
				disabledClass: 'disabled',
				nextClass: 'next',
				prevClass: 'prev',
				lastClass: 'last',
				firstClass: 'first'
			}).on("page", function(event, num){
				smartTable.currPage = num;
				smartTable.updateTableByPage();

				console.log('page num' +num);
			   // $(".content4").html("Page " + num); // or some ajax content loading...
			});
		}
		
		this.updateTableByPage = function ()
		{
			//data = filterAndSorting(jsonData);
			data = this.dataAfterChanges;
			this.refreshTable(data.slice((this.currPage-1)*this.NumOfResualts,this.NumOfResualts*this.currPage));
			//addModalEvent();
			this.updateTextnumResultsAndWhichResults();
		}
		
		
		//update the text about how much answer we have and where are we 
		this.updateTextnumResultsAndWhichResults = function ()
		{
			var stratFrom = (this.currPage-1)*this.NumOfResualts;
			var endFrom ; 
			if(this.NumOfPages == this.currPage) 
			{
				endFrom = this.dataAfterChanges.length;  
			}
			else
			{
				endFrom= this.currPage *this.NumOfResualts;
			}
			$('#numResultsAndWhichResults').html('Displaying ' + stratFrom+ '-'+endFrom +' of ' + this.dataAfterChanges.length + ' results')
		}
		
		//Listner Adding
		
		//start filter and sorting  ; CR No. 09 & CR No. 10
		//
		this.addListerForSortingAndFilters = function ()
		{
			// Begin RMOU : Reinitialize the filter fields
			/*$(".table-header-filter").each(function(i,obj){
				$(this).find(".dropdown").each(function(i,obj){
					$(this).find('.dropdown-toggle').html('All <span class="caret"></span>');
				});
				$(this).find(".input-xs").each(function(i,obj){
					$(this).val('');
				});
			});*/
			// End RMOU

			// check all/uncheck
			$("#checkAll").unbind('change');
			$("#checkAll").prop('checked', false);
			$("#checkAll").change(function () {
				$("input:checkbox").prop('checked', $(this).prop("checked"));
			});

			/*Results per page*/
			$(".dropdown-menu.numOfResultsInPage li a").unbind('click');	
			$(".dropdown-menu.numOfResultsInPage li a").click(function(){
				var selText = $(this).text().trim();
				smartTable.NumOfResualts = parseInt(selText);
				console.log(selText);
				$(this).parents('.dropdown').find('.dropdown-toggle').html(selText+' <span class="caret"></span>');
				if(smartTable.jsonData !== undefined)
					smartTable.initSearchUI(smartTable.dataAfterChanges);

			});

										/*status filter*/
			$(".dropdown-menu#statusFilterUl li").unbind('click');
			// Begin RMOU : Reset to New & Pending
			//$(".dropdown-menu#statusFilterUl li").parents('.dropdown').find('.dropdown-toggle').html('New & Pending <span class="caret"></span>');
			// End RMOU
			$(".dropdown-menu#statusFilterUl li").click(function(){
			  var selText = $(this).text();
			  var pickListValue = $(this).attr('data-id');
			  console.log('picklistvalue ' + pickListValue);
			  if(pickListValue === 'all')
			  {
				 smartTable.filterDataObj.StatusPickList = '';

			  }
			  else
			  {
				smartTable.filterDataObj.StatusPickList = $(this).attr('data-id');//the value from the pickList

			  }
			  smartTable.filterDataObj.statusWasChange = 'yes';
			  
			  $(this).parents('.dropdown').find('.dropdown-toggle').html(selText+' <span class="caret"></span>');
			  if(smartTable.jsonData !== undefined)
				smartTable.initSearchTable(smartTable.jsonData);
			});
			/*segment filter*/
			$(".dropdown-menu#segmentFilterUl li").unbind('click');
			$(".dropdown-menu#segmentFilterUl li").click(function(){
			  var selText = $(this).text();
			  var pickListValue = $(this).attr('data-id');
			  if(pickListValue === 'all')
			  {
				 smartTable.filterDataObj.segmPickList = '';

			  }
			  else
			  {
				smartTable.filterDataObj.segmPickList = $(this).attr('data-id');//the value from the pickList

			  }
			  
			  $(this).parents('.dropdown').find('.dropdown-toggle').html(selText+' <span class="caret"></span>');
			  if(smartTable.jsonData !== undefined)
				smartTable.initSearchTable(smartTable.jsonData);
			});
			
			
		/*type filter*/
			$(".dropdown-menu#typeFilterUl li ").unbind('click');
			$(".dropdown-menu#typeFilterUl li ").click(function()
			{
			  var selText = $(this).text();
			  var pickListValue = $(this).attr('data-id');
			  if(pickListValue === 'all')
			  {
				 smartTable.filterDataObj.TypePickList = '';
			  }
			  else
			  {
				smartTable.filterDataObj.TypePickList = $(this).attr('data-id');//the value from the pickList

			  }
			  $(this).parents('.dropdown').find('.dropdown-toggle').html(selText+' <span class="caret"></span>');
			  if(smartTable.jsonData !== undefined)
				smartTable.initSearchTable(smartTable.jsonData);
			});
			
			//channelPickList
			$(".dropdown-menu#channelFilterUl li ").unbind('click');
			$(".dropdown-menu#channelFilterUl li ").click(function()
			{
			  var selText = $(this).text();
			  var pickListValue = $(this).attr('data-id');
			  if(pickListValue === 'all')
			  {
				 smartTable.filterDataObj.ChannelPickList = '';
			  }
			  else
			  {
				smartTable.filterDataObj.ChannelPickList = $(this).attr('data-id');//the value from the pickList

			  }
			  $(this).parents('.dropdown').find('.dropdown-toggle').html(selText+' <span class="caret"></span>');
			  if(smartTable.jsonData !== undefined)
				smartTable.initSearchTable(smartTable.jsonData);
			});
			
			$("#rootCauseFilter").unbind('keyup');
			$('#rootCauseFilter').keyup(function(){

			  smartTable.filterDataObj.rootCause = $('#rootCauseFilter').val();
			  smartTable.initSearchTable(smartTable.jsonData);
			})
			
			$("#commentHistoryFilter").unbind('keyup');
			$('#commentHistoryFilter').keyup(function(){

			  smartTable.filterDataObj.commentHistory = $('#commentHistoryFilter').val();
			  smartTable.initSearchTable(smartTable.jsonData);
			})
				
			//Need to be in the incomplate!
			$("#nameFilter").unbind('keyup');
			$('#nameFilter').keyup(function(){

			  smartTable.filterDataObj.Name = $('#nameFilter').val();
			  smartTable.initSearchTable(smartTable.jsonData);		  
			});

			//LEL : Store Name Filter 
			$("#StoreNameFilter").unbind('keyup');
			$('#StoreNameFilter').keyup(function(){

			  smartTable.filterDataObj.StoreName = $('#StoreNameFilter').val();
			  smartTable.initSearchTable(smartTable.jsonData);
			});
			//LEL : Store Code Filter 
			$("#StoreCodeFilter").unbind('keyup');
			$('#StoreCodeFilter').keyup(function(){
				
			  smartTable.filterDataObj.StoreID = $('#StoreCodeFilter').val();
			  smartTable.initSearchTable(smartTable.jsonData);
			});

			//LEL : DeliveryStore Filter 
			$("#DeliveryStoreFilter").unbind('keyup');
			$('#DeliveryStoreFilter').keyup(function(){

			  smartTable.filterDataObj.DeliveryStore = $('#DeliveryStoreFilter').val();
			  smartTable.initSearchTable(smartTable.jsonData);
			});

			//LEL : StoreOrder Filter
			$("#StoreOrderFilter").unbind('keyup');
			$('#StoreOrderFilter').keyup(function(){

			  smartTable.filterDataObj.StoreOrder = $('#StoreOrderFilter').val();
			  smartTable.initSearchTable(smartTable.jsonData);
			});

			//LEL : AssignTo Filter
			$("#AssignToFilter").unbind('keyup');
			$('#AssignToFilter').keyup(function(){

			  smartTable.filterDataObj.AssignTo = $('#AssignToFilter').val();
			  smartTable.initSearchTable(smartTable.jsonData);
			});

			$(".ansFilter").unbind('keyup');
			$('.ansFilter').keyup(function(){
				smartTable.ansFilter[$(this).attr('id')] = $(this).val();
				console.log($(this).attr('id'));
				smartTable.initSearchTable(smartTable.jsonData);
			});


			//Need to be in the incomplate!
			$("#dreamIdFilter").unbind('keyup');
			$('#dreamIdFilter').keyup(function(){

			  var num = $('#dreamIdFilter').val();
			  if(!isNaN(num)){
				smartTable.filterDataObj.dreamId = parseInt(num);
			  }
			  else
			   {
				 console.log('Dearm Id should be only a number!');
			   }

			  smartTable.initSearchTable(smartTable.jsonData);
			});

			$("#commentsFilter").unbind('keyup');
			$('#commentsFilter').keyup(function(){

			  smartTable.filterDataObj.Comments = $('#commentsFilter').val();
			  smartTable.initSearchTable(smartTable.jsonData);
			})
			
			$('#TransactionProductCategoryCodeFilter').unbind('keyup');
			$('#TransactionProductCategoryCodeFilter').keyup(function(){
				
				smartTable.filterDataObj.TransactionProductCategoryCode = $('#TransactionProductCategoryCodeFilter').val();
				smartTable.initSearchTable(smartTable.jsonData);
				
			});
		
			//Need to be in the incomplate!
			$(".sortable").unbind('click');
			$('.sortable').click(function(){
				
				var dataid = $(this).attr('data-id');
				var fieldClicked ='';
				if(isNaN(dataid))
				{
					fieldClicked = 'survey.'+$(this).attr('data-id');
				}
				else
				{//sort by ans
					fieldClicked = dataid;
				}
				if(smartTable.filterDataObj.SortField == fieldClicked)
				{
					if(smartTable.filterDataObj.SortField[0] === '-')
						smartTable.filterDataObj.SortField = smartTable.filterDataObj.SortField.split("-")[1];
					else
					{
						smartTable.filterDataObj.SortField = '-'+smartTable.filterDataObj.SortField;
					}
				}

				else
				{
					smartTable.filterDataObj.SortField = fieldClicked;
				}

				smartTable.initSearchTable(smartTable.jsonData);

			})
		};

		//MY : 04/02/2016 VOICE 2 : Recommendation header
		/*
		id - the id of the ul.
		pickListsValuesArray - array of values that will be in the picklists
		numtoTen -boolean ; if true-> we will add values from 0 to 10 to the picklist
		index - place in the list
		*/
		this.addListerForRecommendation = function(recommendedQuestionObj)
		{
			$('#'+recommendedQuestionObj.id+' li').click(function(event ){
				var pickedValue = $(event.target).html();
				if(pickedValue === 'All')
				{
					pickedValue = '';
				}
				else if(!isNaN(pickedValue) && pickedValue < 2)
				{
					pickedValue = '0' + pickedValue;
				}

				else if(isNaN(pickedValue))
				{
					for(var x = 0;x<recommendedQuestionObj.OptionsList.length;x++)
					{
						if(pickedValue === recommendedQuestionObj.OptionsList[x].name)
						{
							pickedValue = recommendedQuestionObj.OptionsList[x].vals;
						}
					}
				}
				smartTable.ansFilter['ansNum' +recommendedQuestionObj.num] = pickedValue;
				if(smartTable.jsonData !== undefined)
					smartTable.initSearchTable(smartTable.jsonData);
					
			})
		}
			
		
	}).apply(smartTable);




