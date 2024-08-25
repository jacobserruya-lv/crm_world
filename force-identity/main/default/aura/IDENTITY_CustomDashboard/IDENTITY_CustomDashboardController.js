({	
	ctr : function(cmp, event, helper) {

        // Verification Code Emails Amount - Bar Chart
        var temp1 = [];
        var action1 = cmp.get("c.getVerificationCodeEmailsAmount"); // call Apex Ctrl function
        action1.setCallback(this, function(response){        	    	    
            if(response.getState() === 'SUCCESS' && response.getReturnValue()){
                temp1 = response.getReturnValue();
                console.log('response from Apex controler - Verification Code Emails Amount');
                console.log(temp1);
                helper.createBarChart(cmp, temp1, 'VerificationCodeEmailsAmount'); 
            }            
        });  
        $A.enqueueAction(action1);

        // Email Mobile Users - Doughnut Chart
        var temp2 = [];
        var action2 = cmp.get("c.getEmailMobileUsers"); // call Apex Ctrl function
        action2.setCallback(this, function(response){        	    	    
            if(response.getState() === 'SUCCESS' && response.getReturnValue()){
                temp2 = response.getReturnValue();
                console.log('response from Apex controler - Email Mobile Users');
                console.log(temp2);
                helper.createDoughnutChart(cmp, temp2, 'EmailMobileUsers'); 
            }            
        });  
        $A.enqueueAction(action2);

        // Reset Password - Bar Chart
        var temp3 = [];
        var action3 = cmp.get("c.getResetPasswordAmount"); // call Apex Ctrl function
        action3.setCallback(this, function(response){        	    	    
            if(response.getState() === 'SUCCESS' && response.getReturnValue()){
                temp3 = response.getReturnValue();
                console.log('response from Apex controler - Reset Password');
                console.log(temp3);
                helper.createBarChart(cmp, temp3, 'ResetPassword'); 
            }            
        });  
        $A.enqueueAction(action3);
    }    
})