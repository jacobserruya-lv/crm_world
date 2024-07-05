import { LightningElement,track, wire, api } from 'lwc';
import getrecordsListSize from "@salesforce/apex/ICX_Client360_SF.getrecordsListSize";
import imagesResource from "@salesforce/resourceUrl/iconics";
import getStylingLink from '@salesforce/apex/ICX_Client360_SF.getStylingLinkAzure';
import getStyling from '@salesforce/apex/ICX_Client360_SF.getStylingSF';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

export default class Icx_stylingTable extends NavigationMixin(LightningElement) {
    @track tableData = [];
    @track tableData2 = [];
    @track recordsListlength;
    @api recordId;
    @track selectedStyleId;
    @track styleLink;
    objectName = 'Task';
    condition = 'WHERE LookId_IW__c != null AND IsWardrobing__c = true AND AccountId =  : accountId';
    
    pageSize = 4;
    @track pageIndex = 0;
    @track isMoreStyleRecords = true;
    isLoadingMoreStyleRecords = false;
    percentOnScroll = 80;

    connectedCallback(){
        this.recordsListlength = 0;

        getrecordsListSize({accountId:this.recordId ,objectName:this.objectName,condition:this.condition})
        .then(res =>  {
            this.recordsListlength = res;
            this.tableData2.title.length = this.recordsListlength;
        });

        this.tableData2.title = {
            type: 'text',
            label: 'Styling',
            iconSrc: imagesResource + `/images/client360/wardrobingIcon.svg`,
            isWithIcon: true,
            isHeader: true,
            hasLength: true,
            titleClass: 'title-bold '
        };

        this.tableData.headers = [
            { type: "text", label: "Name"},
            { type: "text", label: "Send by"},
            { type: "text", label: "Date"},
            { type: "text", label: "Link"},
            { type: "text", label: "Nature" }
        ];

        this.getStylingRecords();

    }


    getStylingRecords(){
        if(this.isMoreStyleRecords && !this.isLoadingMoreStyleRecords){
            this.isLoadingMoreStyleRecords = true;
            getStyling({accountId:this.recordId , pageSize:this.pageSize, pageIndex:this.pageIndex})
            .then(data => {
                console.log('result on getStyling', JSON.stringify(data));

                const newResults = this.handleStylingData(data);
                if(!this.tableData.rows){
                    if(newResults.length>0)
                        {
                            this.tableData.rows=newResults;
                        }
                }else{
                    for(let i = 0; i < newResults.length; i++ ){
                        this.tableData.rows.push(newResults[i]);
                    }
                }

                if(!this.tableData.idList){
                    this.tableData.idList = data.map(order => order.Id);

                }else{
                    for(let i = 0; i < data.length; i++){
                        this.tableData.idList.push(data[i].Id);
                    }
                }

                if(data.length < this.pageSize){
                    this.isMoreStyleRecords = false;
                }
            })
            .catch(error => {
                console.log('there is an error occured during getStyle: ' + error);
            })
            .finally(()=>{
                this.isLoadingMoreStyleRecords = false;
                this.pageIndex =parseInt(this.pageIndex) + parseInt(this.pageSize);       
                console.log('pageIndex new bis', this.pageIndex);
            })
        }
    }

    async handleLinkNavigation(event){
       
        this.selectedStyleId = event.detail; 
        try{
            const result = await getStylingLink({ wardrobingId: this.selectedStyleId, accountId: this.recordId });
            console.log( JSON.stringify(result));
            this.styleLink = result?.sharingUrl;
            if (this.styleLink) {
                this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: {
                        url: this.styleLink,
                    },
                });
            }else{
                const errorToast = new ShowToastEvent({
                    title: "Error",
                    message: result?.message ? result.message : 'An error occured',
                    varint: "error"
                });
                dispatchEvent(errorToast);
            }
        }catch(error){
            console.log('There is an error occrued during getStyleLink: ' + error);
            const errorToast = new ShowToastEvent({
                title: "Error",
                message: result?.message ? result.message : 'An error occured',
                varint: "error"
            });
            dispatchEvent(errorToast);
            
        } finally{
            this.styleLink = undefined;
        }
    }

    handleStylingData(data){
        const newData = data.map(style => {
            return style = [
                {value: style.name, type: "text"},
                {value: style.ownerName, type: "text"},
                {value: style.createdDate, type: "text"},
                {value: "Link to the look", type: "text", isLinkType: true, id: style.id},
                {value: style.nature, type: "text"},
            ]
        });

        return newData;
    }

    checkScroll(e) {
        console.log('checkscroll event ',JSON.stringify(e))
        const elementScrolled = this.template.querySelector(`[data-id="stylingTableContainer"]`);
        console.log('stylingTableContainer: ' + JSON.stringify(elementScrolled));
        const heightScrolled = elementScrolled.scrollHeight;
        const totalHeightOfElement = elementScrolled.clientHeight;
        console.log('stylingTableContainer heightScrolled: ' + heightScrolled);
        console.log('stylingTableContainer totalHeightOfElement: ' + totalHeightOfElement);

        const heightToCallApi = (this.percentOnScroll / 100) * totalHeightOfElement;
      
        if(heightScrolled >= heightToCallApi && this.isMoreStyleRecords)
        {  
           this.getStylingRecords();
        }


}
}