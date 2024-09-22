import { api, track, LightningElement, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import isManagerUser from '@salesforce/apex/ICX_CampaignListViewController.isManagerUser';
import getCAList from '@salesforce/apex/ICX_CampaignClientCAListViewController.getCAList';
import getClientList from '@salesforce/apex/ICX_CampaignListViewController.getCampaignMembersList';

const clientTableHeader = [
    {type: "text", label: "Member Status"},
    {type: "text", label: "Client Name"},
    {type: "text", label: "CA"},
    {type: "text", label: "Contacted"},
    {type: "text", label: "Client Segmentation"},
    {type: "text", label: "Client Contactability"},
    {type: "text", label: "Contact Channel"},
    {type: "text", label: "Client Interest"}
];

const caTableHeader = [
    {type: "text", label: "CA"},
    {type: "text", label: "Targeted Clients"},
    {type: "text", label: "Contacted Clients"},
    {type: "text", label: "% Achievement for CA"},
    {type: "text", label: "Interested"},
    {type: "text", label: "Not Interested"}
];

export default class Icx_campaignClientCAList extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isManager;
    @track caDataTable=[];
    @track clientDataTable = [];
    @track isCAListLoading = false;
    @track pageSize = 10;
    @track pageIndex = 0;
    @track isLoadingMoreRecords = false;
    @track showMoreClientData = true;
    @track isClientLoading = false;

    async connectedCallback(){   
        this.isCAListLoading = true;

        await isManagerUser({})
        .then(res => {
            if(res !== null){
                this.isManager = res;
            }
        })
        .catch(error => {
            console.log('there is an error: '+ error);
        })
        .finally(()=> {
            if(this.isManager){
                this.clientDataTable.headers = clientTableHeader;
            }else{
                this.clientDataTable.headers = this.handleSliceData(clientTableHeader, 2);
            }

            
        })

        this.caDataTable.headers = caTableHeader;

        this.fetchClientData();
        
    }

    fetchClientData(){
        if(this.showMoreClientData && !this.isLoadingMoreRecords){
            this.isLoadingMoreRecords = true;
            this.isClientLoading = true;
        getClientList({pageSize: this.pageSize, pageIndex: this.pageIndex,nameSearchekey: null, filters: null, campaignId: this.recordId})
        .then(data => {
            const tableData = this.handleClientData(data);
            if(!this.clientDataTable.rows || this.clientDataTable.rows === null){
                this.clientDataTable.rows = tableData;
            }else{
                for(let i = 0; i < tableData.length; i++ ){
                    this.clientDataTable.rows.push(tableData[i]);
                }
            }
            if(!this.clientDataTable.idList){
                this.clientDataTable.idList = data.map(member => member.Id);

            }else{
                for(let i = 0; i < data.length; i++){
                    this.clientDataTable.idList.push(data[i].Id);
                }
            }

            if(data.length < this.pageSize){
                this.showMoreClientData = false;
            }
        })
        .catch(e =>{
                console.log('Error occured in getClientList: ' + JSON.stringify(e));
        })
        .finally(() => {
            this.isClientLoading = false;
            this.isLoadingMoreRecords = false;
            this.pageIndex = parseInt(this.pageIndex) + parseInt(this.pageSize); 
        })

        } 
    }

    @wire(getCAList, {CampaignId: '$recordId'})
    wiredCAList({error, data}){
        if(data){
            this.caDataTable.rows = this.handleCAData(data);
        }else if(error){
            console.log('There is an error'+ JSON.stringify(error));
        }

        this.isCAListLoading = false;
    }

    handleCAData(data){
        const newData = data.map(ca => {
            return ca = [
                {value: ca.CA, type: "text"}, 
                {value: ca.TargetedClients, type: "text"}, 
                {value: ca.ContactedClients, type: "text"}, 
                {value: ca.AchievementRate, type: "text"}, 
                {value: ca.Interested, type: "text"}, 
                {value: ca.NotInterested, type: "text"}
            ]
        });
        return newData;
    }

    handleClientData(data){
        const newData = data.map(member => {
            let memberData = [
            {value: member.Status, type: "text"},
            {value: member.ClientName, type: "text"},
            {value: member.CA, type: "text"},
            {value: member.Contacted, type: "text"},
            {value: member.ClientSegmentation, type: "text"},
            {value: member.ClientContactability, type: "text"},
            {value: member.ContactChannel, type: "text"},
            {value: member.ClientInterest, type: "text"}
            ];
            if(!this.isManager){
                memberData = this.handleSliceData(memberData, 2);
            }
            return memberData;
        });
        return newData;
    }

    handleFetchMoreData(event){
        const tableType = event.detail;
        if(tableType === 'clientList'){
            this.fetchClientData();
        }
    }

    navigateToCampaignMemberRecord(event) {
        let memberId = this.clientDataTable.idList[event.detail];
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: memberId,
                objectApiName: "CampaignMember__c",
                actionName: "view"
            }
        });

    }

    handleSliceData(data, offset){
        return data?.slice(0, offset).concat(data.slice(offset+1));
    }
}