/*
* This js file goal is to give the user the ability to create google-chart easy
*and to create a wrapper to google-chart libaray
*There are 4 function that are public in the global scope but we use only :chartTotalData
*
* chartTotalData 
* 		idName- the name of the id we want the chart will be in
* 		userdata -  contain the data we want to show in the chart
* 					it's an double array that the outer array contain the data we want
* 					and the inner are tuple of label and the number of this lable.
* 					the first inner tuple have two labels and he don't disapper so you need to start from the second.
* 					example:
* 											[
									           	['Sales', 'Total of Survey'],
												['New', 241],
												['Pending', 729]
								            ]
* 					
* 		
* Created By : Menashe Yamin 2015
*
* */

        google.load("visualization", "1", { packages: ["corechart"] });//must have
        google.setOnLoadCallback(function() {
            var gtools = window.gtools = (function () {
	            //private
	            //google.load("visualization", "1", { packages: ["corechart"] });
	            var defaultOptions = {
                            legend: 'none',
                            pieSliceText: 'none',
                            chartArea: { top: "10", width: "100", height: "100" },
							'width':100,
							'height':100,
                            pieHole: 0.7,
                            backgroundColor: "transparent"
                        };
	            var totalOptions = jQuery.extend(true, {}, defaultOptions);
                totalOptions.slices = { 0: { color: '#ffa834' }, 1: { color: '#3d8af7' }, 2: { color: '#72bb53' }, 3: { color: '#777777' } };


	            var detailsOptions = jQuery.extend(true, {}, defaultOptions);
	            detailsOptions.slices = { 0: { color: '#ffa834' }, 1: { color: '#3d8af7' }, 2: { color: '#72bb53' }, 3: { color: '#777777' } };

	            var data = google.visualization.arrayToDataTable([
														            ['Sales', 'Total of Survey'],
														            ['New', 241],
														            ['Pending', 729]
													             ]);
	            //public
	            return {
		            chartTotal:function(idName){
			            var chart = new google.visualization.PieChart(document.getElementById(idName));
			            chart.draw(data,totalOptions);
		            },
		            chartTotalData:function(idName,userdata){
			            var data = google.visualization.arrayToDataTable(userdata);
			            var chart = new google.visualization.PieChart(document.getElementById(idName));
			            chart.draw(data,totalOptions);
		            },

		            chartDetail:function(idName){
			            var chart = new google.visualization.PieChart(document.getElementById(idName));
			            chart.draw(data,detailsOptions);
		            },
		            chartDetailData:function(idName,userdata){
			            var data = google.visualization.arrayToDataTable(userdata);
			            var chart = new google.visualization.PieChart(document.getElementById(idName));
			            chart.draw(data,detailsOptions);
		            }
	            }


            }());
       });
//usage example:

/*
gtools.chartDetailData('saleschart',[['hello','hello'],['menash',100],['niv',40],['nurit',79]]);
gtools.chartTotalData('saleschart2',[['hello','hello'],['menash',40],['niv',70],['nurit',100]]);
*/