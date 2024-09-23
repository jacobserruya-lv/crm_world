import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLevel0 from '@salesforce/apex/Experience_Store_Hierarchy_Ctrl.getManagementZoneLevel';
import getLevel1 from '@salesforce/apex/Experience_Store_Hierarchy_Ctrl.getManagementZoneSubLevel1';
import getLevel2 from '@salesforce/apex/Experience_Store_Hierarchy_Ctrl.getManagementZoneSubLevel2';
import getLevel3 from '@salesforce/apex/Experience_Store_Hierarchy_Ctrl.getManagementZoneSubLevel3';
import getLevel4 from '@salesforce/apex/Experience_Store_Hierarchy_Ctrl.getStoreLevel';
import getSelectedStores from '@salesforce/apex/Experience_Store_Hierarchy_Ctrl.getSelectedStores';
import hasEditPermissions from '@salesforce/apex/Experience_Store_Hierarchy_Ctrl.hasEditPermissions';
import updateSelectedStores from '@salesforce/apex/Ex_new_brand_experience_modal_Controller.updateSelectedStores'
import { loadStyle} from 'lightning/platformResourceLoader';
//import LVFont from '@salesforce/resourceUrl/LVFont';
import CssLvClub from '@salesforce/resourceUrl/CssLvClub';
import storeHierarchyTitleLbl from '@salesforce/label/c.E_E_store_hierarchy_storeHierarchy';
import selectAllLbl from '@salesforce/label/c.E_E_store_hierarchy_SelectAll';
import clearAllLbl from '@salesforce/label/c.E_E_store_hierarchy_ClearAll';
import updateLbl from '@salesforce/label/c.E_E_store_hierarchy_Update';
import cancelLbl from '@salesforce/label/c.E_E_store_hierarchy_Cancel';
import noneSelectedLbl from '@salesforce/label/c.E_E_store_hierarchy_NoneSelected';
import optionsSelectedLbl from '@salesforce/label/c.E_E_store_hierarchy_OptionsSelected';
import managementZoneLevelLbl from '@salesforce/label/c.E_E_store_Management_Zone_Level';
import managementZoneSubLevel1Lbl from '@salesforce/label/c.E_E_store_Management_Zone_Sub_Level1';
import managementZoneSubLevel2Lbl from '@salesforce/label/c.E_E_store_Management_Zone_Sub_Level2';
import managementZoneSubLevel3Lbl from '@salesforce/label/c.E_E_store_Management_Zone_Sub_Level3';
import storeLbl from '@salesforce/label/c.E_E_store_hierarchy_store';
import requireStoreLbl from '@salesforce/label/c.E_E_store_hierarchy_RequireStoreMessage';

export default class ex_store_hierarchy extends LightningElement {

    labels={
        storeHierarchyTitle : storeHierarchyTitleLbl,
        selectAll: selectAllLbl,
        clearAll:clearAllLbl,
        update:updateLbl,
        cancel:cancelLbl,
        noneSelected: noneSelectedLbl,
        optionsSelected: optionsSelectedLbl,
        managementZoneLevel:managementZoneLevelLbl,
        managementZoneSubLevel1:managementZoneSubLevel1Lbl,
        managementZoneSubLevel2:managementZoneSubLevel2Lbl,
        managementZoneSubLevel3:managementZoneSubLevel3Lbl,
        store:storeLbl,
        requireStoreMessage:requireStoreLbl
    };
    @api fromRecordPage = false;
    @api recordId;

    picklistZoneLevel = [];
    picklistZoneLevel1 = [];
    picklistZoneLevel2 = [];
    picklistZoneLevel3 = [];
    picklistZoneLevel4 = [];

    selectedItems0 = [];   
    selectedItems1 = [];
    selectedItems2 = [];
    selectedItems3 = [];
    selectedItems4 = [];

    // selectedLevelNames = [];
    // selectedLevelNames1 = [];
    // selectedLevelNames2 = [];
    // selectedLevelNames3 = [];
    // selectedLevelNames4 = [];
 
    selectedObject = false;    
    searchTerm = '';
    searchTerm1 = '';
    searchTerm2 = '';
    searchTerm3 = '';
    searchTerm4 = '';
    showDropdown = false;
    showDropdown1 = false;
    showDropdown2 = false;
    showDropdown3 = false;
    showDropdown4 = false;
    itemcounts = this.labels.noneSelected;
    itemcounts1 = this.labels.noneSelected;
    itemcounts2 = this.labels.noneSelected; 
    itemcounts3 = this.labels.noneSelected;
    itemcounts4 = this.labels.noneSelected;    
    showselectall = false;
    showselectall1 = false;
    showselectall2 = false;
    showselectall3 = false;
    showselectall4 = false;
    isLevel0Disabled=false;
    isLevel1Disabled = true;
    isLevel2Disabled = true;  
    isLevel3Disabled = true;
    isLevel4Disabled = true;  
    updateMode = false;
    isSaving = false;
    selectedStores= [];
    selectedItemsOrigin = [];   
    selectedItems1Origin = [];
    selectedItems2Origin = [];
    selectedItems3Origin = [];
    selectedItems4Origin = [];


    connectedCallback(){
        // Promise.all([
        //     loadStyle(this, CssLvClub + "/CssLvClub.css"),
        //    // loadStyle(this, LVFont + "/LVFont.css")    
        //   ])
        getLevel0 ()
        .then((result) => {
            result.map((zone) => {
            this.picklistZoneLevel = [
                ...this.picklistZoneLevel,
                {
                Name: zone.MANAGEMENT_ZONE_LEVEL_TECH__c,
                Id: zone.MANAGEMENT_ZONE_LEVEL__c
                }
            ];
            });
        })
        .catch((error) => {
            console.log('managementZoneLevel eror',error);
        }); 
      
       if (this.fromRecordPage) {
            this.getSelectedStoresFromDB();
       } 
    //    loadStyle(this, CssLvClub + "/CssLvClub.css").catch((error) => {
    //         console.log(error.body.message);
    //    });
    }

    get isCreationModal(){
        return !this.fromRecordPage;
    }
    getSelectedStoresFromDB(){
        getSelectedStores({currEvent:this.recordId})
        .then((result) => {
            for (let index = 0; index < result.length; index++) {
                const element = result[index];
                this.pushIfNotExists(this.selectedItemsOrigin, element, 'zoneLevelName', 'zoneLevel');
                this.pushIfNotExists(this.selectedItems1Origin, element, 'zoneSubLevel1Name', 'zoneSubLevel1');
                this.pushIfNotExists(this.selectedItems2Origin, element, 'zoneSubLevel2Name', 'zoneSubLevel2');
                this.pushIfNotExists(this.selectedItems3Origin, element, 'zoneSubLevel3Name', 'zoneSubLevel3');
                this.selectedItems4Origin.push({Name:element.retailStoreName, Id:element.retailStoreId});
           
                // this.selectedLevelNames = this.selectedItemsOrigin.map(level => level.Name);
                // this.selectedLevelNames1 = this.selectedItems1Origin.map(level => level.Name);
                // this.selectedLevelNames2 = this.selectedItems2Origin.map(level => level.Name);
                // this.selectedLevelNames3 = this.selectedItems3Origin.map(level => level.Name);
                // this.selectedLevelNames4 = this.selectedItems4Origin.map(level => level.Name)

            }
            this.populateListWithOrigin();
            this.checkEditPermisions();
        })
        .catch((error) => {
            console.log('getSelectedStores error',JSON.stringify(error));
        });
        
    }
    checkEditPermisions(){
        hasEditPermissions()
            .then(result => {
                this.isLevel0Disabled = this.isLevel1Disabled = this.isLevel2Disabled= this.isLevel3Disabled=this.isLevel4Disabled=!result;
            })
            .catch(error => {
                console.error('Error retrieving permissions:', error);
            });
    }
    pushIfNotExists(array, element, nameProperty, idProperty) {
        if (array.find(x => x.Id === element[idProperty]) === undefined || array.length === 0) {
            array.push({ Name: element[nameProperty], Id: element[idProperty] });
        }
    }

    populateListWithOrigin(){
        this.selectedItems0=this.selectedItemsOrigin;
        this.selectedItems1=this.selectedItems1Origin;
        this.selectedItems2=this.selectedItems2Origin;
        this.selectedItems3=this.selectedItems3Origin;
        this.selectedItems4=this.selectedItems4Origin;

        this.itemcounts = this.calculateItemCounts(this.selectedItems0);
        this.itemcounts1 = this.calculateItemCounts(this.selectedItems1);
        this.itemcounts2 = this.calculateItemCounts(this.selectedItems2);
        this.itemcounts3 = this.calculateItemCounts(this.selectedItems3);
        this.itemcounts4 = this.calculateItemCounts(this.selectedItems4);
    }
    calculateItemCounts(items) {
        return items.length > 0 ? `${items.length} ${this.labels.optionsSelected}` : this.labels.noneSelected;
    }

    @wire(getLevel1, {selectedManagementZoneLevel: "$selectedLevelNames" })
    wiredLevel1(result) {
        if (result.data) { 
            this.picklistZoneLevel1 = [];
            result.data.map((zone) => {
                this.picklistZoneLevel1.push(
                {
                    Name: zone.MGMT_ZONE_SUB_LEVEL1_TECH__c,
                    Id: zone.MGMT_ZONE_SUB_LEVEL1__c
                });
            });
                    
        let oldSelectedLevelNames1 = this.selectedLevelNames1;
        this.selectedItems1 = [];
        for(var myItem of this.picklistZoneLevel1){ 
            if(oldSelectedLevelNames1.includes(myItem.Name))
            this.selectedItems1.push(myItem);
            }
        this.itemcounts1 = this.selectedItems1.length > 0 ? `${this.selectedItems1.length} ` + this.labels.optionsSelected : this.labels.noneSelected;

            }
            if(result.error){
                console.log('managementZoneLevel 1 error',error);
            }

            // define if input level 1 is disabled
            if (!this.fromRecordPage) {
                if(this.selectedItems0.length > 0){
                    this.isLevel1Disabled = false;
                }else{
                    this.isLevel1Disabled = true; 
                }
            }        
        }

    @wire(getLevel2, {selectedManagementZoneSubLevel1: "$selectedLevelNames1" })
    wiredLevel2(result) {

        if (result.data) { 
            this.picklistZoneLevel2 = [];
            result.data.map((zone) => {
                this.picklistZoneLevel2.push(
                {
                    Name: zone.MGMT_ZONE_SUB_LEVEL2_TECH__c,
                    Id: zone.MGMT_ZONE_SUB_LEVEL2__c
                });
                
            
            });        
            let oldSelectedLevelNames2 = this.selectedLevelNames2;
            this.selectedItems2 = [];
            for(var myItem of this.picklistZoneLevel2){ 
                if(oldSelectedLevelNames2.includes(myItem.Name))
                this.selectedItems2.push(myItem);
                }
            this.itemcounts2 = this.selectedItems2.length > 0 ? `${this.selectedItems2.length} ` + this.labels.optionsSelected : this.labels.noneSelected;
            }
            if(result.error){
                console.log('managementZoneLevel 2 error',error);
            }

            // define if input level 2 is disabled
            if (!this.fromRecordPage) {
                if(this.selectedItems1.length > 0){
                    this.isLevel2Disabled = false;
                }else{
                    this.isLevel2Disabled = true; 
                }
            }       
        }
     
    @wire(getLevel3, {selectedManagementZoneSubLevel2: "$selectedLevelNames2" })
    wiredLevel3(result) {  

        if (result.data) { 
            this.picklistZoneLevel3 = [];
            result.data.map((zone) => {
                this.picklistZoneLevel3.push(
                {
                    Name: zone.MGMT_ZONE_SUB_LEVEL3_TECH__c,
                    Id: zone.MGMT_ZONE_SUB_LEVEL3__c
                });
            });
                    
        let oldSelectedLevelNames3 = this.selectedLevelNames3;
        this.selectedItems3 = [];
        for(var myItem of this.picklistZoneLevel3){ 
            if(oldSelectedLevelNames3.includes(myItem.Name))
            this.selectedItems3.push(myItem);
            }
        this.itemcounts3 = this.selectedItems3.length > 0 ? `${this.selectedItems3.length} ` + this.labels.optionsSelected : this.labels.noneSelected;

            }
            if(result.error){
                console.log('managementZoneLevel 3 error',error);
            }

            // define if input level 3 is disabled
            if (!this.fromRecordPage) {
                if(this.selectedItems2.length > 0){
                    this.isLevel3Disabled = false;
                }else{
                    this.isLevel3Disabled = true; 
                }
            }
    }

    @wire(getLevel4, {selectedManagementZoneSubLevel3: "$selectedLevelNames3" })
    wiredLevel4(result) { 

      if (result.data) { 
          this.picklistZoneLevel4 = [];
          result.data.map((zone) => {
              this.picklistZoneLevel4.push(
                {
                  Name: zone.Name,
                  Id: zone.RetailStoreId__c
                });
            });          
        let oldSelectedLevelNames4 = this.selectedLevelNames4;
        this.selectedItems4 = [];
        for(var myItem of this.picklistZoneLevel4){ 
            if(oldSelectedLevelNames4.includes(myItem.Name))
            this.selectedItems4.push(myItem);
          }
        this.itemcounts4 = this.selectedItems4.length > 0 ? `${this.selectedItems4.length} `+ this.labels.optionsSelected : this.labels.noneSelected;
  
          }
          if(result.error){
              console.log('managementZoneLevel 4 error',error);
          }
  
          // define if input level 4 is disabled
          if (!this.fromRecordPage) {
            if(this.selectedItems3.length > 0){
                this.isLevel4Disabled = false;
            }else{
                this.isLevel4Disabled = true; 
            }
          }
    }

    get selectedLevelNames(){
        return this.selectedItems0.map(level => level.Name);
    }
    get selectedLevelNames1(){
        return this.selectedItems1.map(level => level.Name);
    }
    get selectedLevelNames2(){
        return this.selectedItems2.map(level => level.Name);
    }
    get selectedLevelNames3(){
        return this.selectedItems3.map(level => level.Name);
    }
    get selectedLevelNames4(){
        return this.selectedItems4.map(level => level.Name);
    }

    //this function is used to show the dropdown list
    get zoneLevels() {    
       if (this.picklistZoneLevel) { 
                // this.selectedLevelNames = this.selectedItems0.map(level => level.Name);
                 return this.picklistZoneLevel.map(level => {
                    //below logic is used to show check mark (✓) in dropdown checklist
                    const isChecked = this.selectedLevelNames.includes(level.Name);
                    return {
                        ...level,
                        isChecked
                    };

                }).filter(level =>
                    level.Name.toLowerCase().includes(this.searchTerm.toLowerCase())
                ).slice(0, 100);
                
            } else {
                return [];
            }  
    }

   
    get zoneLevels1() {
        if (this.picklistZoneLevel1) {
                // this.selectedLevelNames1 = this.selectedItems1.map(level => level.Name);                
                return this.picklistZoneLevel1.map(level => {

                    //below logic is used to show check mark (✓) in dropdown checklist
                    const isChecked = this.selectedLevelNames1.includes(level.Name);
                    return {
                        ...level,
                        isChecked
                    };

                }).filter(level =>
                    level.Name.toLowerCase().includes(this.searchTerm1.toLowerCase())
                ).slice(0, 100);
            } 
            else {
                return [];
            }            
    
    }

    get zoneLevels2() {

        if (this.picklistZoneLevel2) {
            // this.selectedLevelNames2 = this.selectedItems2.map(level => level.Name);         
            return this.picklistZoneLevel2.map(level => {

                //below logic is used to show check mark (✓) in dropdown checklist
                const isChecked = this.selectedLevelNames2.includes(level.Name);
                return {
                    ...level,
                    isChecked
                };

            }).filter(level =>
                level.Name.toLowerCase().includes(this.searchTerm2.toLowerCase())
            ).slice(0, 100);
            } 
            else {
                return [];
            }          
    }

    get zoneLevels3() {

        if (this.picklistZoneLevel3) {
            // this.selectedLevelNames3 = this.selectedItems3.map(level => level.Name);          
            return this.picklistZoneLevel3.map(level => {
                //below logic is used to show check mark (✓) in dropdown checklist
                const isChecked = this.selectedLevelNames3.includes(level.Name);
                return {
                    ...level,
                    isChecked
                };

            }).filter(level =>
                level.Name.toLowerCase().includes(this.searchTerm3.toLowerCase())
            ).slice(0, 500);
        } 
        else {
            return [];
        }          
    }


    get zoneLevels4() {

        if (this.picklistZoneLevel4) {
            // this.selectedLevelNames4 = this.selectedItems4.map(level => level.Name);                              
            return this.picklistZoneLevel4.map(level => {
                //below logic is used to show check mark (✓) in dropdown checklist
                const isChecked = this.selectedLevelNames4.includes(level.Name);
                return {
                    ...level,
                    isChecked
                };

            }).filter(level =>
                level.Name.toLowerCase().includes(this.searchTerm4.toLowerCase())
            ).slice(0, 800);
        } 
            else {
                return [];
            }          
    }
    //this function is used to filter/search the dropdown list based on user input
    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.showDropdown = true;
        this.mouse = false;
        this.focus = false;
        this.blurred = false; 
    }

    handleSearch1(event) {
        this.searchTerm1 = event.target.value;
        this.showDropdown1 = true;
        this.mouse = false;
        this.focus = false;
        this.blurred = false;        
    }
    handleSearch2(event) {
        this.searchTerm2 = event.target.value;
        this.showDropdown2 = true;
        this.mouse = false;
        this.focus = false;
        this.blurred = false;        
    }
    handleSearch3(event) {
        this.searchTerm3 = event.target.value;
        this.showDropdown3 = true;
        this.mouse = false;
        this.focus = false;
        this.blurred = false;
        
    }
    handleSearch4(event) {
        this.searchTerm4 = event.target.value;
        this.showDropdown4 = true;
        this.mouse = false;
        this.focus = false;
        this.blurred = false;
        
    }
    //this function is used when user check/uncheck/selects (✓) an item in dropdown picklist
    handleSelection(event) {   
        const selectedLevelId = event.target.value;
        const isChecked = event.target.checked;        
        console.log(JSON.stringify(this.picklistZoneLevel));
            //below logic is used to show check mark (✓) in dropdown checklist
            if (isChecked) {                
                const selectedLevel = this.picklistZoneLevel.find(level => level.Id === selectedLevelId);
                if (selectedLevel) {
                    this.selectedItems0 = [...this.selectedItems0, selectedLevel];
                }
            } else {
                this.selectedItems0 = this.selectedItems0.filter(level => level.Id !== selectedLevelId);
                this.updateMode=true;
            }
            console.log('selecteditems',JSON.stringify(this.selectedItems0));
            // this.selectedLevelNames = this.selectedItems0.map(level => level.Name);

        
        this.itemcounts = this.selectedItems0.length > 0 ? `${this.selectedItems0.length} ` + this.labels.optionsSelected : this.labels.noneSelected;

        if (this.itemcounts == this.labels.noneSelected) {
            this.selectedObject = false;
        } else {
            this.selectedObject = true;
        } 
    
    }

    handleSelection1(event) {      
        const selectedLevelId = event.target.value;
        const isChecked = event.target.checked;        

            //below logic is used to show check mark (✓) in dropdown checklist
            if (isChecked) {
                const selectedLevel = this.picklistZoneLevel1.find(level => level.Id === selectedLevelId);
                if (selectedLevel) {
                    this.selectedItems1 = [...this.selectedItems1, selectedLevel];                  
                }
              
            } else {
                this.selectedItems1 = this.selectedItems1.filter(level => level.Id !== selectedLevelId);
                this.updateMode=true;
            }
        
        this.itemcounts1 = this.selectedItems1.length > 0 ? `${this.selectedItems1.length} ` + this.labels.optionsSelected : this.labels.noneSelected;

        if (this.itemcounts1 == this.labels.noneSelected) {
            this.selectedObject = false;
        } else {
            this.selectedObject = true;
        }      
    }

    handleSelection2(event) {      
        const selectedLevelId = event.target.value;
        const isChecked = event.target.checked;        

            //below logic is used to show check mark (✓) in dropdown checklist
            if (isChecked) {
                const selectedLevel = this.picklistZoneLevel2.find(level => level.Id === selectedLevelId);
                if (selectedLevel) {
                    this.selectedItems2 = [...this.selectedItems2, selectedLevel];                  
                }
              
            } else {
                this.selectedItems2 = this.selectedItems2.filter(level => level.Id !== selectedLevelId);
                this.updateMode=true;
            }
        
        this.itemcounts2 = this.selectedItems2.length > 0 ? `${this.selectedItems2.length} ` + this.labels.optionsSelected : this.labels.noneSelected;

        if (this.itemcounts2 == this.labels.noneSelected) {
            this.selectedObject = false;
        } else {
            this.selectedObject = true;
        }     
    }

    handleSelection3(event) {      
        const selectedLevelId = event.target.value;
        const isChecked = event.target.checked;        
            //below logic is used to show check mark (✓) in dropdown checklist
            if (isChecked) {
                const selectedLevel = this.picklistZoneLevel3.find(level => level.Id === selectedLevelId);
                if (selectedLevel) {
                    this.selectedItems3 = [...this.selectedItems3, selectedLevel];                  
                }
              
            } else {
                this.selectedItems3 = this.selectedItems3.filter(level => level.Id !== selectedLevelId);
                this.updateMode=true;
            }
        
        this.itemcounts3 = this.selectedItems3.length > 0 ? `${this.selectedItems3.length} ` + this.labels.optionsSelected : this.labels.noneSelected;

        if (this.itemcounts3 == this.labels.noneSelected) {
            this.selectedObject = false;
        } else {
            this.selectedObject = true;
        } 
          
    }
    handleSelection4(event) {  
        this.updateMode = true;    
        const selectedLevelId = event.target.value;
        const isChecked = event.target.checked;        
            //below logic is used to show check mark (✓) in dropdown checklist
            if (isChecked) {
                const selectedLevel = this.picklistZoneLevel4.find(level => level.Id === selectedLevelId);
                if (selectedLevel) {
                    this.selectedItems4 = [...this.selectedItems4, selectedLevel];
                }
            } else {
                this.selectedItems4 = this.selectedItems4.filter(level => level.Id !== selectedLevelId);
                this.updateMode=true;
            }
        
        this.itemcounts4 = this.selectedItems4.length > 0 ? `${this.selectedItems4.length} ` + this.labels.optionsSelected : this.labels.noneSelected;
        if (this.itemcounts4 == this.labels.noneSelected) {
            this.selectedObject = false;
        } else {
            this.selectedObject = true;
        }  
        this.dispatchEvent(new CustomEvent('storeselected', {
            detail: this.selectedItems4.length>0
        }));
    }

    //custom function used to close/open dropdown picklist
    clickhandler(event) {
        this.mouse = false;
        this.showDropdown = true;       
        this.showselectall = true;
      
    }
    clickhandler1(event) {    
   
        this.mouse = false;
        this.showDropdown1 = true;        
        this.showselectall1 = true;       
    }

    clickhandler2(event) {       
        this.mouse = false;
        this.showDropdown2 = true;
        this.showselectall2 = true;       
    }
    clickhandler3(event) {   
        this.mouse = false;
        this.showDropdown3 = true;       
        this.showselectall3 = true;       
    }
    clickhandler4(event) {       
        this.mouse = false;
        this.showDropdown4 = true;       
        this.showselectall4 = true;       
    }
    //custom function used to close/open dropdown picklist
    mousehandler(event) {
        this.mouse = true;
        this.dropdownclose();
        this.showselectall = false;
    }

    mousehandler1(event) {
        this.mouse = true;
        this.dropdownclose1();
        this.showselectall1 = false;
    }

    mousehandler2(event) {
        this.mouse = true;
        this.dropdownclose2();
        this.showselectall2 = false;
    }

    mousehandler3(event) {
        this.mouse = true;
        this.dropdownclose3();
        this.showselectall3 = false;
    }
    mousehandler4(event) {
        this.mouse = true;
        this.dropdownclose4();
        this.showselectall4 = false;
    }
    //custom function used to close/open dropdown picklist
    blurhandler(event) {
        this.blurred = true;
        this.dropdownclose();
    }

    blurhandler1(event) {
        this.blurred = true;
        this.dropdownclose1();
    }
    blurhandler2(event) {
        this.blurred = true;
        this.dropdownclose2();
    }
    blurhandler3(event) {
        this.blurred = true;
        this.dropdownclose3();
    }

    blurhandler4(event) {
        this.blurred = true;
        this.dropdownclose4();
    }

    //custom function used to close/open dropdown picklist
    focuhandler(event) {
        this.focus = true;
    }
    //custom function used to close/open dropdown picklist
    dropdownclose() {
        if (this.mouse == true && this.blurred == true && this.focus == true) {
            this.searchTerm = '';
            this.showDropdown = false;
            this.clickHandle = false;
        }
    }
    dropdownclose1() {
        if (this.mouse == true && this.blurred == true && this.focus == true) {
            this.searchTerm1 = '';
            this.showDropdown1 = false;
            this.clickHandle1 = false;
        }
    }
    dropdownclose2() {
        if (this.mouse == true && this.blurred == true && this.focus == true) {
            this.searchTerm2 = '';
            this.showDropdown2 = false;
            this.clickHandle2 = false;
        }
    }
    dropdownclose3() {
        if (this.mouse == true && this.blurred == true && this.focus == true) {
            this.searchTerm3 = '';
            this.showDropdown3 = false;
            this.clickHandle3 = false;
        }
    }
    dropdownclose4() {
        if (this.mouse == true && this.blurred == true && this.focus == true) {
            this.searchTerm4 = '';
            this.showDropdown4 = false;
            this.clickHandle4 = false;
        }
    }

    initializeSelections(startIndex) {
        debugger
        for (let i = startIndex; i <= 4; i++) {
            this[`selectedItems${i}`] = [];
            this[`itemcounts${i}`] = this.labels.noneSelected;
        }
    }

    handleclearall(event) {
        event.preventDefault();
        this.showDropdown = false;
        this.initializeSelections(0);
        this.searchTerm = '';        
        this.selectedObject = false;
        this.updateMode=true;
        if (!this.fromRecordPage) {
            this.isLevel1Disabled = true;
            this.isLevel2Disabled = true; 
            this.isLevel3Disabled = true; 
            this.isLevel4Disabled = true;  
        }
    }

    handleclearall1(event) {
        event.preventDefault();
        this.showDropdown1 = false;       
        this.initializeSelections(1);
        this.searchTerm1 = '';        
        this.selectedObject = false;
        this.updateMode=true;
        if (!this.fromRecordPage) {
            this.isLevel2Disabled = true; 
            this.isLevel3Disabled = true; 
            this.isLevel4Disabled = true;
        }
    }

    handleclearall2(event) {
        event.preventDefault();
        this.showDropdown2 = false;       
        this.initializeSelections(2);
        this.searchTerm2 = '';        
        this.selectedObject = false;
        this.updateMode=true;
        if (!this.fromRecordPage) {
            this.isLevel3Disabled = true; 
            this.isLevel4Disabled = true;
        }
    }

    handleclearall3(event) {
        event.preventDefault();
        this.showDropdown3 = false;       
        this.initializeSelections(3);
        this.searchTerm3 = '';        
        this.selectedObject = false;
        this.updateMode=true;
        if (!this.fromRecordPage) {
            this.isLevel4Disabled = true;
        }        
    }
    handleclearall4(event) {
        event.preventDefault();
        this.showDropdown4 = false;       
        this.initializeSelections(4);
        this.searchTerm4 = '';        
        this.selectedObject = false;
        this.updateMode = true;
        this.dispatchEvent(new CustomEvent('storeselected', {
            detail: this.selectedItems4.length>0
        }));
    }

    //this function is used to select/check (✓) all of the items in dropdown picklist
    selectall(event) {
        event.preventDefault();
        this.selectedItems0 = this.picklistZoneLevel;
        this.itemcounts = `${this.selectedItems0.length} ${this.labels.optionsSelected}`; 
        this.selectedObject = true;
    }
    selectall1(event) {
        event.preventDefault();
        this.selectedItems1 = this.picklistZoneLevel1;
        this.itemcounts1 = `${this.selectedItems1.length} ${this.labels.optionsSelected}`;
        this.selectedObject = true;
    }
    selectall2(event) {
        event.preventDefault();
        this.selectedItems2 = this.picklistZoneLevel2;
        this.itemcounts2 = `${this.selectedItems2.length} ${this.labels.optionsSelected}`;
        this.selectedObject = true;
    }
    selectall3(event) {
        event.preventDefault();
        this.selectedItems3 = this.picklistZoneLevel3;
        this.itemcounts3 = `${this.selectedItems3.length} ${this.labels.optionsSelected}`;
        this.selectedObject = true;
    }
    selectall4(event) {
        event.preventDefault();
        this.selectedItems4 = this.picklistZoneLevel4;
        this.itemcounts4 = `${this.selectedItems4.length} ${this.labels.optionsSelected}`;
        this.selectedObject = true;
        this.updateMode=true;
        this.dispatchEvent(new CustomEvent('storeselected', {
            detail: this.selectedItems4.length>0
        }));
    }

    handleSave(event){
        this.isSaving = true;
        this.selectedStores = this.selectedItems4.map(x=>x.Id);
        if (this.selectedStores.length==0) {
            this.requireSelectStore();
            this.isSaving = false; 
            return;
        }
        updateSelectedStores({storeCodesList:this.selectedStores, recordId:this.recordId})
        .then()
        .catch(error => {
            console.error('Error: updateSelectedStores', error);
        })
        .finally(() => {
            this.isSaving = false;
            this.updateMode = false;
        })
    }
    handleCancel(event){
        this.isSaving = true;
       setTimeout(() => {
            this.populateListWithOrigin();
            this.isSaving = false;
        }, 500);
        this.updateMode = false;
    }
    requireSelectStore(){
        const toastEvent = new ShowToastEvent({
            title: 'Error',
            message:this.labels.requireStoreMessage,
        });
        this.dispatchEvent(toastEvent);
    }

    get showSaveCancel(){
        return this.fromRecordPage&&this.updateMode;
    }
    // --for parent use--
    @api get selectedStoreItems() {
        return this.selectedItems4;
    }
}