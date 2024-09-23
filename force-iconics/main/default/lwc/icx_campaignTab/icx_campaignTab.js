import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getCampaignsList from '@salesforce/apex/ICX_CampaignListViewController.getCampaignsList';
import getCampaignMembersList from '@salesforce/apex/ICX_CampaignListViewController.getCampaignMembersList';
import isManagerUser from '@salesforce/apex/ICX_CampaignListViewController.isManagerUser';
//import getCampaignNameList from '@salesforce/apex/ICX_CampaignListViewController.getCampaignNameList';

export default class Icx_campaignTab extends NavigationMixin(LightningElement) {

    pageSize = 10;
    @track campaignPageIndex = 0;
    @track campaignMemberPageIndex = 0;

    @track campaignDataTable = [];
    @track isLoadingMoreCampaignRecords = false;
    @track showMoreCampaignData = true;
    @track campaignNameSearch;
    @track isCampaignLoading = false;

    @track memberDataList = [];
    @track isLoadingMoreMemberRecords = false;
    @track showMoreMemberData = true;
    @track memberNameSearch;
    @track isMemberLoading = false;

    @track isManager = false;

    @track campaignFilters = {};
    @track memberFilters = {};

    @track campaignFilterDefinitions = [
        { field: 'Status__c', label: 'Status', options: ['New', 'Ongoing', 'Completed', 'Cancelled'], isPicklist: true },
        { field: 'Priority__c', label: 'Priority', options: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'], isPicklist: true }
    ];

    @track mamberFilterDefinitions = [
        { field: 'Campaign__r.Name', label: 'Campaign Name', isInput: true },
        { field: 'Campaign__r.Status__c', label: 'Status', options: ['New', 'Pending', 'Completed', 'Cancelled'], isPicklist: true },
        { field: 'Campaign__r.Priority__c', label: 'Priority', options: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'], isPicklist: true },
        { field: 'Contacted__c', label: 'Contacted', options: ['Yes', 'No'], isPicklist: true },
        { field: 'ClientContactability__c', label: 'Client contactability', options: ['Opt in', 'Opt out'], isPicklist: true }
    ];


    connectedCallback() {
        console.log('start icx_campaignTab');
        this.campaignDataTable.headers = [
            { type: "text", label: "Campaign Name" },
            { type: "text", label: "Campaign Status" },
            { type: "text", label: "Start Date & End Date" },
            { type: "text", label: "Priority" },
            { type: "text", label: "Targeted Client" },
            { type: "text", label: "Contacted clients" },
            { type: "text", label: "Interested" },
            { type: "text", label: "Not interested" }
        ];

        this.memberDataList.headers = [
            { type: "text", label: "Campaign Name" },
            { type: "text", label: "Campaign Status" },
            { type: "text", label: "Start Date & End Date" },
            { type: "text", label: "Priority" },
            { type: "text", label: "Client Name" },
            { type: "text", label: "CA" },
            { type: "text", label: "Contacted" },
            { type: "text", label: "Client Segmentation" },
            { type: "text", label: "Client Contactability" },
            { type: "text", label: "Contact Channel" },
            { type: "text", label: "Client Interest" },
        ];

        /*getCampaignNameList({})
        .then(data => {
            if(data !== null){
                this.mamberFilterDefinitions.push({field: 'Campaign__r.Name', label: 'Campaign Name', options: data});
                console.log('mamberFilterDefinitions:' +JSON.stringify(this.mamberFilterDefinitions));
            }
        })
        .catch(e=>{
            console.log('Error occured in getCampaignNameList: ' + JSON.stringify(e));
        })*/

        this.fetchCampaignList();
        this.fetchMemberList();
    }

    fetchCampaignList() {
        if (this.showMoreCampaignData && !this.isLoadingMoreCampaignRecords) {
            this.isLoadingMoreCampaignRecords = true;
            this.isCampaignLoading = true;
            getCampaignsList({ pageSize: this.pageSize, pageIndex: this.campaignPageIndex, nameSearchekey: this.campaignNameSearch, filters: this.campaignFilters })
                .then(data => {
                    const tableData = this.handleCampaignData(data);
                    console.log('TableData: ' + JSON.stringify(tableData));
                    if (!this.campaignDataTable.rows || this.campaignDataTable.rows === null) {
                        this.campaignDataTable.rows = tableData;
                    } else {
                        for (let i = 0; i < tableData.length; i++) {
                            this.campaignDataTable.rows.push(tableData[i]);
                        }
                    }
                    if (data.length < this.pageSize) {
                        this.showMoreCampaignData = false;
                    }
                })
                .catch(e => {
                    console.log('Error occured in getCampaignList: ' + JSON.stringify(e));
                })
                .finally(() => {
                    this.isCampaignLoading = false;
                    this.isLoadingMoreCampaignRecords = false;
                    this.campaignPageIndex = parseInt(this.campaignPageIndex) + parseInt(this.pageSize);
                })

        }
    }

    fetchMemberList() {
        if (this.showMoreMemberData && !this.isLoadingMoreMemberRecords) {
            this.isLoadingMoreMemberRecords = true;
            this.isMemberLoading = true;
            getCampaignMembersList({ pageSize: this.pageSize, pageIndex: this.campaignMemberPageIndex, nameSearchekey: this.memberNameSearch, filters: this.memberFilters, campaignId: null })
                .then(data => {
                    const tableData = this.handleMemberData(data);
                    if (!this.memberDataList.rows || this.memberDataList.rows === null) {
                        this.memberDataList.rows = tableData;
                    } else {
                        for (let i = 0; i < tableData.length; i++) {
                            this.memberDataList.rows.push(tableData[i]);
                        }
                    }

                    if (data.length < this.pageSize) {
                        this.showMoreMemberData = false;
                    }
                })
                .catch(e => {
                    console.log('Error occured during getCampaignMembersList: ' + JSON.stringify(e));
                })
                .finally(() => {
                    this.isMemberLoading = false;
                    this.isLoadingMoreMemberRecords = false;
                    this.campaignMemberPageIndex = parseInt(this.campaignMemberPageIndex) + parseInt(this.pageSize);
                })
        }
    }

    @wire(isManagerUser, {})
    wiredManagerUser({ error, data }) {
        if (data) {
            this.isManager = data;
        } else if (error) {
            console.log('there is an error: ' + error);
        }
    }

    createNewCampaign() {
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Campaign__c",
                actionName: "new",
            },
        });
    }

    handleCampaignData(data) {
        const newData = data.map(campaign => {
            return campaign = [
                { value: campaign.Name, isLinkType: true, id: campaign.Id },
                { value: campaign.Status, type: "text" },
                { value: [{ value: campaign.StartDate }, { value: campaign.EndDate }], type: "text", isListType: true },
                { value: campaign.Priority, type: "text" },
                { value: campaign.TargetClients, type: "text" },
                { value: campaign.ContactedClients, type: "text" },
                { value: campaign.Interested, type: "text" },
                { value: campaign.NotInterested, type: "text" }
            ]
        });
        return newData;
    }

    handleMemberData(data) {
        const newData = data.map(member => {
            return member = [
                { value: member.Name, isLinkType: true, id: member.Id },
                { value: member.Status, type: "text" },
                { value: [{ value: member.StartDate }, { value: member.EndDate }], type: "text", isListType: true },
                { value: member.Priority, type: "text" },
                { value: member.ClientName, type: "text" },
                { value: member.CA, type: "text" },
                { value: member.Contacted, type: "text" },
                { value: member.ClientSegmentation, type: "text" },
                { value: member.ClientContactability, type: "text" },
                { value: member.ContactChannel, type: "text" },
                { value: member.ClientInterest, type: "text" }
            ]
        });
        return newData;
    }

    handleFetchMoreData(event) {
        const tableType = event.detail;
        if (tableType === 'campaignList') {
            this.fetchCampaignList();
        } else if (tableType === 'memberList') {
            this.fetchMemberList();
        }
    }

    handleSearchCampaign(event) {
        const tableType = event.detail.tableType;
        if (tableType === 'campaignList') {
            this.campaignNameSearch = event.detail.key;
            if (this.campaignNameSearch !== null) {
                this.initialData('campaignList');

            }
        } else if (tableType === 'memberList') {
            this.memberNameSearch = event.detail.key;
            if (this.memberNameSearch !== null) {
                this.initialData('memberList');
            }
        }
    }

    handleApplyFilter(event) {
        const tableType = event.detail.tableType;
        if (tableType === 'campaignList') {
            this.campaignFilters = event.detail.key;
            this.campaignNameSearch = null;
            this.initialData('campaignList');
        } else if (tableType === 'memberList') {
            this.memberFilters = event.detail.key;
            this.memberNameSearch = null;
            this.initialData('memberList');
        }
    }

    initialData(tableType) {
        if (tableType === 'campaignList') {
            this.campaignDataTable.rows = null;
            this.campaignPageIndex = 0;
            this.showMoreCampaignData = true;
            this.isLoadingMoreCampaignRecords = false;
            this.fetchCampaignList();
        } else if (tableType === 'memberList') {
            this.memberDataList.rows = null;
            this.campaignMemberPageIndex = 0;
            this.showMoreMemberData = true;
            this.isLoadingMoreMemberRecords = false;
            this.fetchMemberList();
        }
    }
}