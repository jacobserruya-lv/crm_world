import { LightningElement, api, wire, track } from 'lwc'; 
import fetchRecords from '@salesforce/apex/ICX_OnlineAppointmentController.fetchRecords'; 
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateAppointment from '@salesforce/apex/ICX_OnlineAppointmentController.updateAppointment';
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe, MessageContext } from "lightning/messageService";
import PING_PONG_CHANNEL from '@salesforce/messageChannel/CareServiceAppointment__c';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class ICX_AppointementRelatedList extends NavigationMixin( LightningElement ) { 
    @api channelName;
    @api objectName; 
    @api parentObjectName;
    @api fieldName; 
    @api fieldValue; 
    @api parentFieldAPIName; 
    @api recordId; 
    @api strTitle; 
    @api filterType; 
    @api operator; 
  
    @api relationshipApiName;
    @track field1;
    @track field2;
    @track field3;
    @track field4;
    @track listRecords;
    @track titleWithCount = 'Online Appointment (0)';
    @track countBool = false;
    wiredResult

    subscription = null;
    @wire(MessageContext)
    messageContext;
   
    //TIMEZONE
    @track timeZone;
    @track timestamp;

    connectedCallback() {
        //TIMEZONE
        // const timeZone = TIME_ZONE;
        this.timeZone = TIME_ZONE;

        // alert(timeZone);
        this.subscribeToMessageChannel();
        /* var listFields = this.fieldsList.split( ',' );
        console.log( 'Fields are ' + listFields );
        this.field1 = 'Owner.Name';
        this.field2 = 'Status__c';
        this.field3 = 'StartDateTime';
        this.field4 = 'AppointmentType__c';
        console.log( 'Field 1 is ' + this.field1 );
        console.log( 'Field 2 is ' + this.field2 );
        console.log( 'Field 3 is ' + this.field3 );
        console.log( 'Field 4 is ' + this.field4 );*/
        // this.fieldsList =  'Owner.Name,Status__c,StartDateTime,Appointment_Type_Icon__c,Attendance__c,Tech_TimestampStartDateTime__c';
        this.fieldsList =  'Owner.Name,Status__c,StartDateTime,Appointment_Type_Icon__c,Attendance__c';
    }
        
    get vals() {
        return this.recordId + '-' + this.objectName + '-' +  
               this.parentFieldAPIName + '-' + this.fieldName + '-' +  
               this.fieldValue + '-' + this.filterType + '-' + this.operator + '-' + this.fieldsList;
    }
     
    @wire(fetchRecords, { listValues: '$vals' }) 
        eventData (result) {
        // Hold on to the provisioned value so we can refresh it later.
        this.wiredResult = result; // track the provisioned value
        const { data, error } = result;
        
        if ( data ) {
            this.listRecords = data.listRecords;
                
            if ( data.recordCount > 0 ) {
                this.countBool = true;
                this.titleWithCount = this.strTitle + ' (' + data.recordCount + ')';                 
            } 
        }
    }

    navigateToRelatedList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.parentObjectName,
                relationshipApiName: this.relationshipApiName,
                actionName: 'view'
            }
        });
    }

    handleClick(event) {
        var clickedButtonLabel = event.target.label;
        var selectedItem = event.target.dataset.id;
       
        console.log('clickedButtonLabel '+clickedButtonLabel);
        console.log('selectedItem'+selectedItem);
             
       updateAppointment ({
            eventId: selectedItem,
            straAttendance : clickedButtonLabel
        })
        .then(() => {
            refreshApex(this.wiredResult).then(() => {
                console.log( 'REFRESH' );
            });
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or reloading record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
  
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            PING_PONG_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        console.log( 'subscribe message'+message.careId );
        if (message.careId == this.recordId){            
            refreshApex(this.wiredResult).then(() => {
                console.log( 'REFRESH subscribe' );
            });
            
        }
    }
}