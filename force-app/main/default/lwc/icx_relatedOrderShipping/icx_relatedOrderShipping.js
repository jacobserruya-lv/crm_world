import { LightningElement,api,wire,track } from 'lwc';
import getOrderShipping from "@salesforce/apex/ICX_RelatedOrderShipping.getOrderShipping";
import imagesResource from "@salesforce/resourceUrl/iconics";
import OrderShippingOBJ from '@salesforce/schema/OrderShipping__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from "lightning/navigation";
import {  dateFormat2 } from "c/utils";



export default class Icx_relatedOrderShipping extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;
    @api OrderShippingFieldName;


    @api OrderShippingDisplayField;
    @track  OrderShippingDisplayFieldList;


    tableData=[];
    @track orderShipping;
    @track orderShippingMap;
    @track orderShippingOBJ;
    @track isLoading = true;


    @wire(getObjectInfo, { objectApiName: OrderShippingOBJ })
    wiredOrderShippingOBJ({ data, error }) {
        if (data) 
        {
            this.orderShippingOBJ = data;
            console.log('nao ordershipping field' , this.orderShippingOBJ.fields);
        }
        else if(error)
        {
            console.error('error while getting order shipping field label ', error);
        }
    }

    @wire(getOrderShipping, { recordId: "$recordId",objectApiName:"$objectApiName",OrderShippingFieldName:"$OrderShippingFieldName",OrderShippingFieldToDisplay:"$OrderShippingDisplayField"})
    wiredOrderShipping({ error, data }) {
      if (data) {
        

            this.orderShipping =data;
            
            
        }
        else if(error)
        {
            console.error('Error while trying to get order shipping : ', error);
        }
        
        this.isLoading = false;

    }

    connectedCallback()
    {

        this.tableData.title = {
            type: "text",
            label: "Shipping Group",
            iconSrc: imagesResource + `/images/client360/ordersIcon.svg`,
            isWithIcon: true,
            isHeader: true,
            titleClass: "title-bold",
            hasLength: false,
              };
    }
    renderedCallback()
    {
        if(this.orderShipping && !this.orderShippingMap)
        {

            
            this.OrderShippingDisplayFieldList = this.OrderShippingDisplayField.split(',');

            this.orderShippingMap=[];
            for(let i=0; i<this.OrderShippingDisplayFieldList.length;i++)
            {
                
                console.log('nao OrderShippingDisplayFieldList[i] ', this.OrderShippingDisplayFieldList[i]);
                this.orderShippingMap.push({
                    apiName:this.OrderShippingDisplayFieldList[i], 
                    label:this.getLabel(this.OrderShippingDisplayFieldList[i]),
                    value:this.getValue(this.OrderShippingDisplayFieldList[i]),
                    isLink:this.getIsLink(this.OrderShippingDisplayFieldList[i].toLowerCase()),
                    redirectID:this.getredirectID(this.OrderShippingDisplayFieldList[i].toLowerCase()), 
                    redirectObject:this.getredirectObject(this.OrderShippingDisplayFieldList[i].toLowerCase())})
                }
                
        }

        let tableData = this.template.querySelectorAll("[data-apiname]").forEach(el => {
            if (el.dataset.link && this.orderShippingMap[el.dataset.link].isLink) {
                el.className = el.className.replace('slds-hide', '');
            }
            if (el.dataset.text && !this.orderShippingMap[el.dataset.text].isLink) {
                el.className = el.className.replace('slds-hide', '');
            }

        })

    }

    getLabel(fieldName)
    {
        let fielNameLowerCase = fieldName.toLowerCase();
        if(fielNameLowerCase=='createdby.name' || fielNameLowerCase=='createdbyid')
        {
            return this.orderShippingOBJ.fields['CreatedById'].label;
        }
        else if(fielNameLowerCase=='order__r.name' || fielNameLowerCase=='order__c')
        {
            return this.orderShippingOBJ.fields['Order__c'].label;

        }
        return this.orderShippingOBJ.fields[fieldName].label;
    }

  
    getValue(fieldName)
    {
        let value = this.orderShipping[fieldName];
        let fielNameLowerCase = fieldName.toLowerCase();
        if(fielNameLowerCase=='statusdate__c')
        {
            return  dateFormat2( value.split("T")[0].split('-')[0],value.split("T")[0].split('-')[1],value.split("T")[0].split('-')[2])

        }
        else if(fielNameLowerCase=='createdby.name' || fielNameLowerCase=='createdbyid')
        {
            return this.orderShipping.CreatedBy.Name;
        }
        else if(fielNameLowerCase=='order__r.name' || fielNameLowerCase=='order__c')
        {
            return this.orderShipping.Order__r.Name;
        }
        return value

    }

    getIsLink(fieldName)
    {
        if(fieldName=='shippingnumber__c'|| fieldName=='id' || fieldName=='createdbyid'||fieldName=='order__c'||fieldName=='createdby.name'||fieldName=='order__r.name')
        {
            return true;
        }
        return false;
    }

    getredirectID(fieldName)
    {
        if(fieldName=='shippingnumber__c' || fieldName=='id')
        {
            return this.orderShipping.Id;
        }
        else if(fieldName=='createdby.name' || fieldName=='createdbyid')
        {
            return this.orderShipping.CreatedById;
        }
        else if(fieldName=='order__r.name' || fieldName=='order__c')
        {
            return this.orderShipping.Order__c;
        }
        return null;

    }
    getredirectObject(fieldName)
    {
        if(fieldName=='shippingnumber__c' || fieldName=='id')
        {
            return 'OrderShipping__c'
        }
        else if(fieldName=='createdby.name' || fieldName=='createdbyid')
        {
            return 'User';
        }
        else if(fieldName=='order__r.name' || fieldName=='order__c')
        {
            return 'Order__c';
        }
        return null;
    }


    redirectToObject(event)
    {
        let redirectRecordId = this.orderShippingMap[event.currentTarget.dataset.redirect].redirectID;
        let objectName = this.orderShippingMap[event.currentTarget.dataset.redirect].redirectObject;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: redirectRecordId,
                objectApiName: objectName,
                actionName: 'view'
            },
        });
    }
    
}