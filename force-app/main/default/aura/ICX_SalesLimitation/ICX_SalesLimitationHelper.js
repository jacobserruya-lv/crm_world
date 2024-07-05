({
    setupDataTable: function (component) {
         component.set('v.columns', [
            {label: 'Dream Id Client', fieldName: 'dreamId', type: 'text'},
            {label: 'SKU', fieldName: 'SKU', type: 'text'},
            {label: 'Purchased Date', fieldName: 'purchasedDate', type: 'date'},
            {label: 'Product Name', fieldName: 'productName', type: 'text'},
            {label: 'Transaction Id', fieldName: 'transactionId', type: 'text'},
            {label: 'Quantity', fieldName: 'quantity', type: 'text'},
            {label: 'Category', fieldName: 'category', type: 'text'},
            {label: 'Store Code', fieldName: 'storeCode', type: 'text'},
            {label: 'Status', fieldName: 'status', type: 'text'}
        ]);
    },
 
    getData: function (component,event, helper) {
        return this.callAction(component)
            .then(
                $A.getCallback(imageRecords => {
                    component.set('v.allData', imageRecords);
                    component.set('v.filteredData', imageRecords);
                    //helper.filterByLastWeek(component, event, helper);

                    this.preparePagination(component, imageRecords);
                })
            )
            .catch(
                $A.getCallback(errors => {
                    if (errors && errors.length > 0) {
                        $A.get("e.force:showToast")
                            .setParams({
                                message: errors[0].message != null ? errors[0].message : errors[0],
                                type: "error"
                            })
                            .fire();
                    }
                })
            );
    },
 
    callAction: function (component) {
        var arr =[];
        //component.set("v.isLoading", true);
        var record = component.get("v.recordId");
        return new Promise(
            $A.getCallback((resolve, reject) => {
                const action = component.get("c.getRelatedAccounts");
                action.setParams({'recordId' : record});
                action.setCallback(this, response => {
                    component.set("v.isLoading", false);
                    const state = response.getState();
                    if (state === "SUCCESS") {
                        arr = response.getReturnValue();
                        if(arr.length>0){
                          arr.sort((a, b) => (a.purchasedDate < b.purchasedDate) ? 1 : -1)
   
                        }
                        return resolve(arr);
                    } else if (state === "ERROR") {
                        return reject(response.getError());
                    }
                    return null;
                });
                $A.enqueueAction(action);
            })
        );
    },
 
    preparePagination: function (component, imagesRecords) {
        let countTotalPage = Math.ceil(imagesRecords.length/component.get("v.pageSize"));
        let totalPage = countTotalPage > 0 ? countTotalPage : 1;
        component.set("v.totalPages", totalPage);
        component.set("v.currentPageNumber", 1);
        this.setPageDataAsPerPagination(component);
    },
 
    setPageDataAsPerPagination: function(component) {
        let data = [];
        let pageNumber = component.get("v.currentPageNumber");
        let pageSize = component.get("v.pageSize");
        let filteredData = component.get('v.filteredData');
        let x = (pageNumber - 1) * pageSize;
        for (; x < (pageNumber) * pageSize; x++){
            if (filteredData[x]) {
                data.push(filteredData[x]);
            }
        }
        component.set("v.tableData", data);
    },

    //NI-932: export the data from "Client Sales and Ongoing Order" on Alias to a csv file
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        var csvStringResult, counter, columnDivider, lineDivider, columnLabels = [], columnFiledNames = [];

        component.get('v.columns').forEach(element => {
            columnLabels.push(element.label);
            columnFiledNames.push(element.fieldName);
        })
        
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }

        columnDivider = ',';
        lineDivider =  '\n';

        csvStringResult = '';
        csvStringResult += columnLabels.join(columnDivider);
        csvStringResult += lineDivider;

        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
             for(var sTempkey in columnFiledNames) {
                var skey = columnFiledNames[sTempkey];
                  if(counter > 0){
                      csvStringResult += columnDivider;
                   }
                   objectRecords[i][skey] != undefined ? csvStringResult += '"'+ objectRecords[i][skey]+'"' : false;
               counter++;
            } 
             csvStringResult += lineDivider;
          }
        return csvStringResult;        
    },
 
    searchRecordsBySearchPhrase : function (component) {
   /*      var data = component.get("v.allData"),
            term = component.get("v.searchPhrase"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            results = data.filter(row=>regex.test(row.name) || regex.test(row.age.toString()));
            component.set("v.filteredData", results);
            this.preparePagination(component, results);


            
        } catch(e) {
            // invalid regex, use full list
        }
        
        let searchPhrase = component.get("v.searchPhrase");
        if (!$A.util.isEmpty(searchPhrase)) {
            let allData = component.get("v.allData");
            let filteredData = allData.filter(record => record.title.includes(searchPhrase));
            component.set("v.filteredData", filteredData);
            this.preparePagination(component, filteredData);
        }*/
    },
        
     /* filterByLastWeek: function(component, event, helper) { 
        var Today=  new Date();
        var CurrentDate = Today.toISOString().slice(0,10);  
        var LastWeek = new Date(Today.getFullYear(), Today.getMonth(), Today.getDate() - 7).toISOString().slice(0,10);
        var data =  component.get('v.allData');
        var fil=  data.filter(d => {var time = d.purchasedDate;
                                 return (CurrentDate > time && time >= LastWeek);
                                });
          
        this.filterLeatherGoods(component, event,fil);
        
    
    },
	filterLeatherGoods: function(component, event, fil) { 
        let map = new Map(); 
        fil.forEach(element => element.category == "Leather Goods" ? 
        (!map.has(element.transactionId) ?
            map.set(element.transactionId,element.quantity):
            map.set(element.transactionId , map.get(element.transactionId)+element.quantity)
        ):console.log(map))

        if(map.size>0 ){
			console.log([...map.entries()].reduce((a, e ) => e[1] > a[1] ? e : a));
			console.log("Max:", Math.max(...map.values()));
            var maxLeaterGoods = Math.max(...map.values());
            if (maxLeaterGoods >= 3){
                var message = component.find('message')
                component.set('v.message','The client purchased more than 3 leather goods or small leather goods per transaction');
                $A.util.removeClass(message, 'slds-hide');
                $A.util.addClass(message, 'slds-show');
            }
        }
		console.log(fil);
    
    */

})