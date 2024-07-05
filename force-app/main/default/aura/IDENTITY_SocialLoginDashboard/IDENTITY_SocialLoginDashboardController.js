({	
	ctr : function(cmp, event, helper) {

        // Social Login History - Line Chart
        var temp = [];
        var action = cmp.get("c.getLoginHistoryByOrigin"); // call Apex Ctrl function
        action.setParams({
            queryTime : "last_six_months"
        });
        action.setCallback(this, function(response){        	    	    
            if(response.getState() === 'SUCCESS' && response.getReturnValue()){
                temp = response.getReturnValue();
                console.log('response from Apex controler - Social Login History (last 6 months)');
                console.log(temp);
                helper.createLineChart(cmp, temp, 'SocialLoginHistory'); 
            }            
        });  
        $A.enqueueAction(action);


        // Social Login History Current Month - Pie Chart
        var temp2 = [];
        var action2 = cmp.get("c.getLoginHistoryByOrigin"); // call Apex Ctrl function
        action2.setParams({
            queryTime : "current_month"
        });
        action2.setCallback(this, function(response){        	    	    
            if(response.getState() === 'SUCCESS' && response.getReturnValue()){
                temp2 = response.getReturnValue();
                console.log('response from Apex controler - Social Login History (current month)');
                console.log(temp2);
                helper.createDoughnutChart(cmp, temp2, 'SocialLoginHistory2'); 
            }            
        });  
        $A.enqueueAction(action2);
    }    
})