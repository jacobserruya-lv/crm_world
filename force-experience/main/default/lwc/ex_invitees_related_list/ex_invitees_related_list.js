import { LightningElement, api, track, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import initComponentConfig from '@salesforce/apex/ex_invitees_related_list_CTRL.initComponentConfig';
import status from '@salesforce/label/c.E_E_store_hierarchy_Status';
import clientName from '@salesforce/label/c.E_E_client';
import preferredCa from '@salesforce/label/c.E_E_preferredCa';
import AssignedCa from '@salesforce/label/c.E_E_AssignedCa';
import guests from '@salesforce/label/c.E_E_guests';
import appointmentStart from '@salesforce/label/c.E_E_appointment_start';
import appointmentEnd from '@salesforce/label/c.E_E_appointment_end';
import invitees from '@salesforce/label/c.E_E_invitees';
import viewAll from '@salesforce/label/c.E_E_viewAll';
import viewLess from '@salesforce/label/c.E_E_viewLess';

const COLUMNS = [
    {label: 'Id', fieldName: 'recordLink', type: 'url', typeAttributes: {label: {fieldName: 'Id'}, target: '_self'}, hideDefaultActions: true },
    {label: clientName, fieldName: 'clientLink', type: 'url', typeAttributes: {label: {fieldName: 'clientName'}, target: '_self'}, hideDefaultActions: true },
    {label: status, fieldName: 'Status__c', type: 'text', hideDefaultActions: true },
    {label: preferredCa, fieldName: 'preferredCaLink', type: 'url', typeAttributes: {label: {fieldName: 'preferredCa'}, target: '_self'}, hideDefaultActions: true },
    {label: AssignedCa, fieldName: 'AssignedCaLink', type: 'url', typeAttributes: {label: {fieldName: 'AssignedCa'}, target: '_self'}, hideDefaultActions: true },
    {label: guests, fieldName: 'GuestNumber__c', type: 'text', hideDefaultActions: true },
    {label: appointmentStart, fieldName: 'Appointment_Start__c', type: 'date', typeAttributes: {year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit',  hour12: true}, hideDefaultActions: true, initialWidth: 160 },
    {label: appointmentEnd, fieldName: 'Appointment_End__c', type: 'date', typeAttributes: {year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit',  hour12: true}, hideDefaultActions: true, initialWidth: 160 }
]

export default class Ex_invitees_related_list extends NavigationMixin(LightningElement) {

    @api recordId;//variationId


    cols=COLUMNS;
    allRecords;
    firstRecords;
    numberOfRecords;
    wiredInviteesResult;
    isViewAll = false;
    //to force refreshAPex retrive new data and not get from cache
    _cacheBust = Math.random();


    labels = {
        invitees: invitees,
        viewAll: viewAll,
        viewLess: viewLess
    }
    get records(){
        if(this.isViewAll)
            return this.allRecords;
        return this.firstRecords;
    }
    connectedCallback(){
        this._cacheBust = Math.random();
        refreshApex(this.wiredInviteesResult);
    }
    @wire (initComponentConfig, {variationId: '$recordId', cacheBust: '$_cacheBust'})
    wiredInvitees(result){
        const {data, error} = result;
        this.wiredInviteesResult = result;

        if(data){
            this.allRecords = data.invitees?.map(invitee => {
                                return { ... invitee,
                                            recordLink: `/${invitee.Id}`,
                                            clientLink: `/${invitee.Client__c}`,
                                            clientName: invitee.Client__r?.Name,
                                            preferredCa: invitee.Client__r?.Owner?.Name,
                                            AssignedCa: invitee.Assigned_CA__r?.Name,
                                            preferredCaLink: `/${invitee.Client__r?.OwnerId}`,
                                            AssignedCaLink: `/${invitee.Assigned_CA__c}`

                                        }
                                });
            this.numberOfRecords = data.invitees?.length;
            this.firstRecords = this.allRecords.slice(0,50);
        } else if(error){
            console.log('error get data',error);
        }
    }
    openNewModal() {
        const encodedValues = encodeDefaultFieldValues({
            Brand_Experience_Variation__c: this.recordId,
            NominationSource__c: 'Desktop'
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Brand_Experience_Variation_Member__c',
                actionName: 'new' 
            },
            state: {
                defaultFieldValues: encodedValues
            }
        });
    }
    toggleView() {
        this.isViewAll = !this.isViewAll;
    }
}