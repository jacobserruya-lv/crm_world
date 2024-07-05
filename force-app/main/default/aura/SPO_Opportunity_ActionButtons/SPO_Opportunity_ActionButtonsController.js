({
    doInit : function(component, event, helper) {
        helper.getOpportunity(component);
        helper.getUser(component);
        //helper.initUnitRetailPriceRMS(component);
     //   helper.getLastFirmOrder(component);
    },
    
    confirmQuotation: function(cmp, event, helper) {
        console.log('confirmQuotation');
        // TODO for the problem to update Path when changing stage by Lightning component: check if the refresh is automatically done with force:recordData lightning component

        helper.updateOpp(cmp, 'Quotation accepted');
    },
    
    requestQuotation: function(cmp, event, helper) {
        helper.updateOpp(cmp, 'Quotation in progress');
    },
    
    addDeposit: function(cmp, event, helper) {
        helper.openModal(cmp);

        var opp = cmp.get("v.opp");
        console.log("SPO Deposit amount" + opp.SPO_DepositAmount__c);
        console.log("SPO Total amount" + opp.SPO_TotalAmount__c);
        if (opp.SPO_DisplayOrder__c) 
        {
            helper.updateOpp(cmp, 'Deposit sent');
        } 
        else 
        {
            cmp.find("deposit").set("v.errors", []);
            if(opp.SPO_DepositAmount__c < opp.SPO_TotalAmount__c/2){    
                cmp.find("deposit").set("v.errors", [{message:"Deposit amount must be 50% of Total Amount"}]);
                return;
            }
            var CaCodevalidity = helper.isValid(cmp, "caCode");
            if (CaCodevalidity) {
                helper.updateOpp(cmp, 'Deposit sent');
            } else {
                console.log("CA Code invalid");
            }
        }
    },

    /*createOrderInERP: function(cmp, event, helper) {
        helper.createOrderInERP(cmp);
    },

    sendToReferential: function(cmp, event, helper) {
        helper.sendToReferential(cmp);
    },*/

    openModal : function (cmp, event, helper) {
        var user = cmp.get("v.currentUser");
        var opp = cmp.get("v.opp");

        // init default deposit amount
        if (user.Profile.Name != 'SPO_Production' && opp.StageName == 'Quotation accepted') {
			opp.SPO_DepositAmount__c = opp.SPO_TotalAmount__c/2;
            cmp.set("v.opp", opp);
        }

        helper.openModal(cmp);
    },
    modalCancel : function (cmp, event, helper) {
        helper.closeModal(cmp);
    },
    isRefreshed : function(component,helper,event){
        helper.fireRefresh(component, event);
    },
    openPDF : function(component, event, helper) {
        console.log('******** CMP '+component);
        var opp = component.get("v.opp");
        console.log('******** opp ',opp);
        window.open('/apex/PDFPage?id='+opp.Id, '_blank')
        
	},
    updateFirmOrder : function(component,event,helper){
        var receivedInStoreBtn = event.getSource().get("v.label");
        console.log("Received in Store btn :" + receivedInStoreBtn);
        
        var opp = component.get("v.opp");
        if(receivedInStoreBtn == "Received in Store"){
            helper.updateFirmOrderStatus(component,event,opp);
        } else if(receivedInStoreBtn == "Close Order") {
            helper.updateOpp(component, 'Closed Won');
        }

        var closeOrderLabel = $A.get("$Label.c.LV_SO_Close_Order");
        console.log("Close Order label :" + closeOrderLabel)
        component.find("closeorder").set("v.label",closeOrderLabel);

        /*var closeOrderBtn = event.getSource().get("v.label");
        if(closeOrderBtn == "Close Order"){
            var opp = component.get("v.opp");
            helper.updateOpp(component, 'Closed Won');
        }*/
    },
    openPDFProduction : function(component, event, helper) {
        console.log('******** CMP '+component);
        var opp = component.get("v.opp");
        console.log('******** opp ',opp);
        window.open('/apex/SPO_PDFPageProduction?id='+opp.Id, '_blank')
        
    }, 
})