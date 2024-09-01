import { LightningElement, api, track, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import initComponentConfig from '@salesforce/apex/ex_variation_related_list_CTRL.initComponentConfig';
import inStoreEventActivations from '@salesforce/label/c.E_E_store_hierarchy_inStoreEventActivations';
import eventName from '@salesforce/label/c.E_E_store_hierarchy_EventName';
import startDate from '@salesforce/label/c.E_E_store_hierarchy_StartDate';
import endDate from '@salesforce/label/c.E_E_store_hierarchy_EndDate';
import store from '@salesforce/label/c.E_E_store_hierarchy_store';
import country from '@salesforce/label/c.E_E_store_hierarchy_country';
import zone from '@salesforce/label/c.E_E_store_hierarchy_zone';
import targetInvitees from '@salesforce/label/c.E_E_store_hierarchy_targetInvitees';
import targetSales from '@salesforce/label/c.E_E_store_hierarchy_targetSales';
import format from '@salesforce/label/c.E_E_store_hierarchy_format';
import status from '@salesforce/label/c.E_E_store_hierarchy_Status';
import address from '@salesforce/label/c.E_E_store_hierarchy_address';
import nominated from '@salesforce/label/c.E_E_store_hierarchy_nominated';


const IN_STORE_COLUMNS = [
    {label: eventName, fieldName: 'recordLink', type: 'url', typeAttributes: {label: {fieldName: 'Name'}, target: '_self'}, hideDefaultActions: true, initialWidth: 150 },
    {label: startDate, fieldName: 'StartDateTime__c', type: 'date', typeAttributes: {year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit',  hour12: true}, hideDefaultActions: true, initialWidth: 160 },
    {label: endDate, fieldName: 'EndDateTime__c', type: 'date', typeAttributes: {year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit',  hour12: true}, hideDefaultActions: true, initialWidth: 160 },
    {label: store, fieldName: 'storeName', type: 'text', hideDefaultActions: true, initialWidth: 200 },
    {label: country, fieldName: 'storeCountry', type: 'text', hideDefaultActions: true, initialWidth: 80 },
    {label: zone, fieldName: 'storeZone', type: 'text', hideDefaultActions: true, initialWidth: 80 },
    {label: targetInvitees, fieldName: 'Nb_Target_Clients__c', type: 'text', hideDefaultActions: true, initialWidth: 100 },
    {label: targetSales, fieldName: 'Target_Sales__c', type: 'text', hideDefaultActions: true, initialWidth: 100 },
    {label: format, fieldName: 'inStoreEventFormat__c', type: 'text', hideDefaultActions: true, initialWidth: 100 },
    {label: status, fieldName: 'Status__c', type: 'text', hideDefaultActions: true, initialWidth: 100 }

]

const OUT_STORE_COLUMNS = [
    {label: eventName, fieldName: 'recordLink', type: 'url', typeAttributes: {label: {fieldName: 'Name'}, target: '_self'}, hideDefaultActions: true},
    {label: startDate, fieldName: 'StartDateTime__c', type: 'date', typeAttributes: {year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit',  hour12: true}, hideDefaultActions: true },
    {label: endDate, fieldName: 'EndDateTime__c', type: 'date', typeAttributes: {year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit',  hour12: true}, hideDefaultActions: true },
    {label: address, fieldName: 'formatedAddress__c', type: 'text', hideDefaultActions: true, initialWidth: 300},
    {label: nominated, fieldName: 'Nb_Nominated_Clients__c', type: 'text', hideDefaultActions: true },
    {label: status, fieldName: 'Status__c', type: 'text', hideDefaultActions: true }

]
export default class Ex_experience_variation_related_list extends NavigationMixin(LightningElement) {

    @api recordId;//experienceId

    @track isOpenModal = false;
    @track variationRecordTypeId;

    variations;
    numberOfRecords;
    wiredVariationsResult;

    get cols (){
        if (this.experienceRT == 'Experience')
            return IN_STORE_COLUMNS;
        else
            return OUT_STORE_COLUMNS;
    }

    labels = {
        inStoreEventActivations: inStoreEventActivations,
        eventName: eventName,
        startDate: startDate,
        endDate: endDate,
        store: store,
        country: country,
        zone: zone,
        targetInvitees: targetInvitees,
        targetSales: targetSales,
        format: format, 
        status: status
    }

    @wire (initComponentConfig, {experienceId: '$recordId'})
    wiredVariations(result){
        this.wiredVariationsResult = result;
        const {data, error} = result;
        if(data){
            this.variations = data.variations?.map(variation => {
                                return { ... variation,
                                            recordLink: `/${variation.Id}`,
                                            storeName: variation.Store__r?.Name,
                                            storeCountry: variation.Store__r?.StoreCountry__c,
                                            storeZone: variation.Store__r?.Zone__r.Name	
                                        }
                                });
            this.numberOfRecords = data.variations?.length;
            this.displayNewBtn = data.displayNewBtn;
            this.variationRecordTypeId = data.variationRTId;
            this.variationRTName = data.variationRTName;
            this.experienceRT = data.experienceRTName;
        }else if(error){
            console.log('error get data',error);
        }
    }
    refreshList(){
        console.log('on refresh data');
        refreshApex(this.wiredVariationsResult);
    }
    openModal(){
        this.isOpenModal = true;
    }
    closeModal(){
        this.isOpenModal = false;
        this.refreshList();
    }

}