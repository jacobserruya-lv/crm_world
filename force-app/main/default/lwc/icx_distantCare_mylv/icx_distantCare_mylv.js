import { LightningElement, api, wire, track } from 'lwc';
import getAccountByEmail from '@salesforce/apex/ICX_ProductSearchLookup_LC.getAccountByEmail';
import {FlowNavigationNextEvent } from 'lightning/flowSupport';


export default class Icx_distantCare_mylv extends LightningElement {
    @api accountId;
    @api email;
    //if the client is not a MyLV client look for another client with the same email that is a MyLV client
    @track message;
    @wire(getAccountByEmail, {accountId:'$accountId', email:'$email'})
        wiredLVClient({error, data}){
            if(data){
                console.log(data);
                if(data.id == null){
                    console.log('there is no MY LV user');
                    this.handleNext();

                }
                else if(data.id == this.accountId)
                    this.handleNext();
                else if(data.id != this.accountId){
                    this.message = "Do you want to attach the care request to the client "+data.name+" ?";
                    this.MyLVAccount = data.id;
                }
                
            }
            if(error){
                console.log(error);
            }
    }
    handleOnClick(event)
    {
        console.log('account'+this.accountId);
        
        if(event.target.name == 'confirm')
        {
            this.accountId = this.MyLVAccount;
        }
        this.handleNext();
    }
    handleNext(){
        console.log('i am on next step');
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
    
}