import { LightningElement,api,wire,track } from 'lwc';
import { getRecord,getFieldValue,getRecords } from 'lightning/uiRecordApi';
import { getRelatedListCount,getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { NavigationMixin } from "lightning/navigation";
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from "@salesforce/schema/Campaign__c.Name";
import DESCRIPTION_FIELD from "@salesforce/schema/Campaign__c.Description__c";
import TOOLKITCOMMENTS_FIELD from "@salesforce/schema/Campaign__c.ToolkitComments__c";
import STATUS_FIELD from "@salesforce/schema/Campaign__c.Status__c";
import STATUSCAMPAIGNMEMBER_FIELD from "@salesforce/schema/CampaignMember__c.Status__c";
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import ContentDocumentId_FIELD from '@salesforce/schema/ContentDocumentLink.ContentDocumentId';
import getContentVersion from '@salesforce/apex/ICX_CampaignGeneralInformationController.getContentVersion';



export default class Icx_campaignGeneralInformationDetails extends NavigationMixin(LightningElement) {
    @api campaignId;

    @track allMemberList;
    @track allMemberContactableList;
    @track allMemberContactedList;
    @track allMemberInterestedList;

    @track contentDocumentListId;
    @track contentVersionList;

    managerProfileList = ['ICONiCS_SA_Manager', 'System Administrator', 'System Admin_Corporate'];

    imageExtensions = ['png','jpg','gif','jpeg'];
    supportedIconExtensions = ['ai','attachment','audio','box_notes','csv','eps','excel','exe',
                        'flash','folder','gdoc','gdocs','gform','gpres','gsheet','html','image','keynote','library_folder',
                        'link','mp4','overlay','pack','pages','pdf','ppt','psd','quip_doc','quip_sheet','quip_slide',
                        'rtf','slide','stypi','txt','unknown','video','visio','webex','word','xml','zip'];

    // wire function 
    @wire(getRecord, {
		recordId: USER_ID,
		fields: [PROFILE_NAME_FIELD]
	})
	user;


    @wire(getRecord, {
		recordId: "$campaignId",
		fields: [NAME_FIELD,DESCRIPTION_FIELD,TOOLKITCOMMENTS_FIELD,STATUS_FIELD]
	})
	campaign;


    //related wire


    @wire(getRelatedListRecords, {
        parentRecordId: "$getRelatedRecordId",
        relatedListId: 'Campaign_Members__r',
        fields: ['Id','CampaignMember__c.Status__c'],
        where: "$wireWhereClauseAllMember" 
      })
      wireallMemberList({ error, data }) {
        if (data) {
    
          this.allMemberList = data.records;
        }
        else if (error) {
            console.error(' this.allMemberList error', JSON.stringify(error));

      }
    }

    @wire(getRelatedListRecords, {
        parentRecordId: "$getRelatedRecordId",
        relatedListId: 'Campaign_Members__r',
        fields: ['Id'],
        where: "$wireWhereClauseAllContactableMember"
      })
      wireallMemberContactableList({ error, data }) {
        if (data) {
    
          this.allMemberContactableList = data.records;
        }
        else if (error) {
            console.error(' this.allMemberContactableList error', JSON.stringify(error));

      }
    }

    @wire(getRelatedListRecords, {
        parentRecordId: "$getRelatedRecordId",
        relatedListId: 'Campaign_Members__r',
        fields: ['Id'],
        where: "$wireWhereClauseAllContactedMember"
      })
      wireallMemberContactedList({ error, data }) {
        if (data) {
    
          this.allMemberContactedList = data.records;
        }
        else if (error) {
            console.error(' this.allMemberContactedList error', JSON.stringify(error));
      }
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$getRelatedRecordId',
        relatedListId: 'Campaign_Members__r',
        fields: ['Id'],
        where: "$wireWhereClauseAllInterestedMember"
      })
      wireallMemberInterestedList({ error, data }) {
        if (data) {
    
          this.allMemberInterestedList = data.records;
        }
        else if (error) {
            console.error(' this.allMemberInterestedList error', JSON.stringify(error));
      }
    }



    //toolkit


    @wire(getRelatedListRecords, {
        parentRecordId: "$campaignId",
        relatedListId: 'ContentDocumentLinks',
        fields:['ContentDocumentLink.ContentDocumentId'],
        // fields: [ContentDocumentLinkId_FIELD,ContentDocumentId_FIELD],
      })
      wiretoolkitList({ error, data }) {
        if (data) {
    
        console.log('  contentDocumentListId data.records', JSON.stringify(data.records));
        // this.contentDocumentListId =  getFieldValue(data.records[0], ContentDocumentId_FIELD);

        this.contentDocumentListId = data.records.map((contentdocumentlink)=> getFieldValue(contentdocumentlink, ContentDocumentId_FIELD));

        console.log('  this.contentDocumentListId', this.contentDocumentListId);

        getContentVersion({
            ContentDocumentId : this.contentDocumentListId
        })
        .then(result => {    
            // let parsedData = JSON.parse(result);
            // let stringifiedData = JSON.stringify(parsedData);
            console.log('  this.contentVersionList result', result);

            this.contentVersionList = result;
            let baseUrl = this.getBaseUrl();
            this.contentVersionList.forEach(file => {
                file.downloadUrl = baseUrl+'sfc/servlet.shepherd/document/download/'+file.ContentDocumentId;
                file.fileUrl     = baseUrl+'sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+file.Id;
                file.CREATED_BY  = file.ContentDocument.CreatedBy.Name;
                file.Size        = this.formatBytes(file.ContentDocument.ContentSize, 2);

                let fileType = file.ContentDocument.FileType.toLowerCase();
                if(this.imageExtensions.includes(fileType)){
                    file.icon = 'doctype:image';
                }else{
                    if(this.supportedIconExtensions.includes(fileType)){
                        file.icon = 'doctype:' + fileType;
                    }
                    else
                    file.icon ='doctype:unknown';
                }
                })
            // this.contentVersionList = finalData;
            console.log('  this.contentVersionList', this.contentVersionList);

            })
        .catch(error => {
            console.error('**** error **** \n ',error)
        })


        }
        else if (error) {
            console.error('  this.contentDocumentListId error', JSON.stringify(error));
      }
    }




    // get function 

    get getRelatedRecordId()
    {
        const isUserManager = this.getIsUserManager();
        if(!isUserManager)
        {
            return USER_ID;
        }
        else
        {
            return this.campaignId;

        }


    }
    get wireWhereClauseAllMember()
    {
        const isUserManager = this.getIsUserManager();

        if(!isUserManager && this.campaignId)
        {
            return "{ Campaign__c : { eq: "+ this.campaignId+ " }}";
        }
        else if(isUserManager)
        {
            return "";
        }
        else
        {
            return "{ Campaign__c : { eq: "+ null+ " }}";
        }
    }

    get wireWhereClauseAllContactableMember()
    {
        const isUserManager = this.getIsUserManager();

        if(!isUserManager && this.campaignId)
        {
            return "{and:[{ClientContactability__c : { eq: 'Opt in'}},{ Campaign__c : { eq: "+ this.campaignId+ " }}]}";
        }
        else if(isUserManager)
        {
            return "{ ClientContactability__c : { eq: 'Opt in'}}";
        }
        else
        {
            return "{ ClientContactability__c : { eq: "+null+" }}";
        }
    }

    get wireWhereClauseAllContactedMember()
    {
        const isUserManager = this.getIsUserManager();

        if(!isUserManager && this.campaignId)
        {
            return "{and:[{Contacted__c : { eq: 'Yes'}},{ Campaign__c : { eq: "+ this.campaignId+ " }}]}";
        }
        else if(isUserManager)
        {
            return "{ Contacted__c : { eq: 'Yes'}}";
        }
        else
        {
            return "{ Contacted__c : { eq: "+null+" }}";
        }
    }

    get wireWhereClauseAllInterestedMember()
    {
        const isUserManager = this.getIsUserManager();

        if(!isUserManager && this.campaignId)
        {
            return "{and:[{Interested__c : { eq: 'Yes'}},{ Campaign__c : { eq: "+ this.campaignId+ " }}]}";
        }
        else if(isUserManager)
        {
            return "{ Interested__c : { eq: 'Yes'}}";
        }
        else
        {
            return "{ Interested__c : { eq: "+null+" }}";
        }
    }


    get isUserManager()
    {

        return this.getIsUserManager();

    }

    getIsUserManager()
    {
        console.log('  profile name', getFieldValue(this.user.data, PROFILE_NAME_FIELD));
        return this.managerProfileList.includes(getFieldValue(this.user.data, PROFILE_NAME_FIELD));
    }


    //campaign info
    
    get name() {
    console.log('  this.campaign.data', this.campaign.data);
    return getFieldValue(this.campaign.data, NAME_FIELD) ? getFieldValue(this.campaign.data, NAME_FIELD) : "N/A";
    }

    get description() {
    console.log('  this.campaign.data', this.campaign.data);
    return getFieldValue(this.campaign.data, DESCRIPTION_FIELD) ? getFieldValue(this.campaign.data, DESCRIPTION_FIELD) : "N/A";

    }

    get toolkitComments() {
    console.log('  this.campaign.data', this.campaign.data);
    return getFieldValue(this.campaign.data, TOOLKITCOMMENTS_FIELD) ? getFieldValue(this.campaign.data, TOOLKITCOMMENTS_FIELD) : "N/A";

    }


    get status() {
        const isUserManager = this.getIsUserManager();

        if(!isUserManager)
        {
            if(this.allMemberList)
            {
                const allMemberSize = this.getAllMemberCount();
                console.log('  allMemberSize', allMemberSize)

                let NbMemberNew=0;
                let NbMemberOnGoing=0;
                let NbMemberCancelled=0;

                let CAStatus = 'N/A';
                
                for (let i = 0; i < allMemberSize; i++) {
                    let status = getFieldValue(this.allMemberList[i], STATUSCAMPAIGNMEMBER_FIELD) ;               

                    if(status =='New')
                    {
                        NbMemberNew+=1;
                    }
                    else if(status=='Pending' || status == 'Completed')
                    {
                        NbMemberOnGoing+=1 ;
                    }
                    else if(status =='Cancelled')
                    {
                        NbMemberCancelled+=1;
    
                    }
                }

                if(NbMemberNew==allMemberSize)
                {
                    CAStatus = 'New';
                }
                else if(NbMemberOnGoing>0)
                {
                    CAStatus='On Going';
                }
                else if(NbMemberCancelled==allMemberSize)
                {
                    CAStatus ='Cancelled';
                }
                                
                return CAStatus;

            }
            else{

                return "N/A";
            }
        }
        else
        {
            return getFieldValue(this.campaign.data, STATUS_FIELD) ? getFieldValue(this.campaign.data, STATUS_FIELD) : "N/A";
        }

    }
 

    get allMemberCount()
    {
      return this.getAllMemberCount();
    }
    get allMemberContactableCount()
    {
          return this.allMemberContactableList?  this.allMemberContactableList.length + " (" + (this.getAllMemberCount()!="N/A" ? this.getPourcent(this.allMemberContactableList.length,this.getAllMemberCount()):"NA")+"%)" :"N/A";

    }
    get allMemberContactedCount()
    {
          return this.allMemberContactedList?  this.allMemberContactedList.length + " (" + (this.getAllMemberCount()!="N/A" ? this.getPourcent(this.allMemberContactedList.length,this.getAllMemberCount()):"NA")+"%)" :"N/A";

    }
    get allMemberInterestedCount()
    {
          return this.allMemberInterestedList?  this.allMemberInterestedList.length + " (" + (this.getAllMemberCount()!="N/A" ? this.getPourcent(this.allMemberInterestedList.length,this.getAllMemberCount()):"NA")+"%)" :"N/A";
    }

    getAllMemberCount()
    {
      return this.allMemberList?  this.allMemberList.length:"N/A";

    }

    //handle function
    handleNavigateToCampaign()
    {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
              recordId: this.campaignId,
              objectApiName: "Campaign__c", 
              actionName: "view",
            },
          });
    }

    //   help function 

    getPourcent(restrictedListCount, allListCount)
    {
        if(allListCount>0)
        {

            return restrictedListCount/allListCount*100;
        }
        else
        {
            return 0;
        }
    }

    getBaseUrl(){
        return 'https://'+location.host+'/';
    }
    formatBytes(bytes,decimals) {
        if(bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

}