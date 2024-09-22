import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class Icx_campaignDynamicTable extends NavigationMixin(LightningElement) {
 @api tableData;
 @api showSearchBar;
 @api tableType;
 @api showMoreData;
 @api nameSearch;
 @api isLoading;
 @api searchholder;
 @track openfilter = false;
 @api filterDefinitions;
 @track selectedFilters = {};
 @track campaignName;
 
 percentOnScroll = 70;

 handleNameChange(event){
   this.nameSearch = event.target.value;
   const newEvent = new CustomEvent('namesearch', {
      detail:  {key: this.nameSearch, tableType: this.tableType}
   });
   this.dispatchEvent(newEvent);
 }

 checkScroll(e) {
    const elementScrolled = this.template.querySelector(`[data-id="campaignTable"]`);
    const heightScrolled = elementScrolled.scrollHeight;
    const totalHeightOfElement = elementScrolled.clientHeight;
    const heightToCallApi = (this.percentOnScroll / 100) * totalHeightOfElement;
  
    if(heightScrolled >= heightToCallApi && this.showMoreData)
    {  
      const evt = new CustomEvent('fetchmoredata', {
         detail: this.tableType
     });
     this.dispatchEvent(evt);
    }
   }  

  handleNavigation(event){
      this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
              recordId: event.detail,
              actionName: 'view',
          },
      });
  }

  handleOpenFilter(event){
    this.openfilter = !this.openfilter;
  }

  handleApplyFilters(){
    this.openfilter = false;
    const newEvent = new CustomEvent('applyfilter', {
      detail:{
        key: {
          ...this.selectedFilters, 
          campaignName: this.campaignName
        },
        tableType: this.tableType
      }
   });
   this.dispatchEvent(newEvent);
  }

  handleCleanFilters(){
    this.openfilter = false;
    this.selectedFilters = {};
    const newEvent = new CustomEvent('applyfilter', {
      detail:{
        key: {

        },
        tableType: this.tableType
      }
   });
   this.dispatchEvent(newEvent);
  }

  get formatFilterDefiniations(){
    return this.filterDefinitions?.map(filter =>{
      return {...filter, newoptions: filter.options?.map(option => ({
        label: option,
        value: option
      })),
      history: this.selectedFilters[filter.field] || []}
    });
  }

  get disableClearFilter(){
    return this.selectedFilters === null ? true : false;
  }

  handlePicklistFilterChange(event){
    const {name, value} = event.target;
    this.selectedFilters = {...this.selectedFilters, [name]: value}
  }

  handleInputFilterChange(event){
    this.campaignName = event.target.value;
  }

  handleClose(){
    this.openfilter = false;
  }

  handleNavigateToRecordPage(event){
    const evt = new CustomEvent('recorddetails', {
      detail: event.detail
  });
  this.dispatchEvent(evt);
  }
  
}