import { LightningElement, track, wire } from 'lwc';
import getEvents from '@salesforce/apex/ex_Event_ListView_Controller.getStoreHierarchiesEvents';
import hasPCRPermissionSet from '@salesforce/apex/ex_Event_ListView_Controller.hasPCRPermissionSet';
import { refreshApex } from "@salesforce/apex";
import titleLbl from '@salesforce/label/c.E_E_store_hierarchy_title';
import searchPlaceholderLbl from '@salesforce/label/c.E_E_store_hierarchy_SearchPlaceholder';
import allLbl from '@salesforce/label/c.E_E_store_hierarchy_all';
import newLbl from '@salesforce/label/c.E_E_store_hierarchy_New';
import itemsLbl from '@salesforce/label/c.E_E_store_hierarchy_items';
import sortedByLbl from '@salesforce/label/c.E_E_store_hierarchy_SortedBy';
import eventNameLbl from '@salesforce/label/c.E_E_store_hierarchy_EventName';
import eventTypeLbl from '@salesforce/label/c.E_E_store_hierarchy_EventType';
import subTypeLbl from '@salesforce/label/c.E_E_store_hierarchy_SubType';
import activationsNumberLbl from '@salesforce/label/c.E_E_store_hierarchy_ActivationsNumber';
import startDateLbl from '@salesforce/label/c.E_E_store_hierarchy_StartDate';
import endDateLbl from '@salesforce/label/c.E_E_store_hierarchy_EndDate';
import statusLbl from '@salesforce/label/c.E_E_store_hierarchy_Status';
export default class Ex_event_listView extends LightningElement {


    labels = {
        title:titleLbl,
        all: allLbl,
        new: newLbl,
        items: itemsLbl,
        sortedBy:sortedByLbl,
        eventName:eventNameLbl,
        eventType: eventTypeLbl,
        subType:subTypeLbl,
        searchPlaceholder: searchPlaceholderLbl,
        activationsNumber: activationsNumberLbl,
        startDate: startDateLbl,
        endDate: endDateLbl,
        status:statusLbl
    };

    columns = [
        { label: this.labels.eventName, fieldName: 'eventLink', sortable: true, type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }},
        { label: this.labels.eventType, fieldName: 'Type__c', sortable: true,},
        // initialWidth: 220
        { label: this.labels.subType, fieldName: 'Sub_Type__c', sortable: true, initialWidth: 220},
        { label: this.labels.activationsNumber, fieldName: 'Size_Of_Variations__c', sortable: true, initialWidth: 220},
        { label: this.labels.startDate, fieldName: 'Experience_StartDate__c', type: 'date', sortable: true, initialWidth: 220},
        { label: this.labels.endDate, fieldName: 'Experience_EndDate__c', type: 'date', sortable: true, initialWidth: 220},
        { label: this.labels.status, fieldName: 'Status__c', sortable: true, initialWidth: 220},
    ];
    events = [];
    wiredEventResult;
    filteredEvents = [];
    sortBy;
    sortByFieldLabel='';
    sortDirection = 'asc';
    searchTerm = '';  
    isloading = false;
    isModalOpen=false;

    @wire(getEvents)
    wiredEvents(result) {
        this.wiredEventResult = result;
            if (result.data){
                console.log(result.data);
                this.events=result.data.map(res =>{ return {...res, eventLink: `/lightning/r/Brand_Experience__c/${res.Id}/view`}});
                this.filteredEvents=this.events;
            }  
            else if (result.error) {
                console.error('Error fetching events', result.error);
            }
    }
    @wire(hasPCRPermissionSet)
    displayNewButton(result){
        const {data, error} = result;
        if(data){
            this.displayNewBtn = data;
        }else if(error){
            console.log('error get user permission',error);
        }
    }

    handleSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortByFieldLabel = this.columns.find(x=>x.fieldName===this.sortBy).label;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.filteredEvents));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.filteredEvents = parseData;
    }
    handleSearchChange(event){
        this.isloading=true;
        this.searchTerm = event.target.value;
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.filterData();
        }, 300);
    }

    filterData() {
        const lowerSearchTerm = this.searchTerm.toLowerCase().trim();
        this.filteredEvents = this.events.filter(item =>
            Object.values(item).some(value =>
                typeof value === 'string' && value.toLowerCase().includes(lowerSearchTerm)
            )
        );
        this.isloading = false;
    }
    handleClearSearch(){
        this.isloading=true;
        setTimeout(() => {
            this.searchTerm = '';
            this.filteredEvents=this.events;
        }, 600);
        this.isloading=false;
    }
    openModal(){
        this.isModalOpen = true;
    }
    closeModal() {
        this.refreshDate();
        this.isModalOpen = false;
    } 
    refreshDate(){
        refreshApex(this.wiredEventResult);
    }
    get noVisibleEvents(){
        return this.filteredEvents==0;
    }
    get eventNumbers(){
        if (this.filteredEvents) {
            return this.filteredEvents.length
        }
        return null;
    }
}
