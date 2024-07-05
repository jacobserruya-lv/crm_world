import { LightningElement, wire, track ,api} from 'lwc';
import getArtyStats from '@salesforce/apex/Tr_ExclusiveCampaignOrder_Handler.getArtyStats';
import getproductsAvailable from '@salesforce/apex/Tr_ExclusiveCampaignOrder_Handler.getproductsAvailable';
import getproductsAll from '@salesforce/apex/Tr_ExclusiveCampaignOrder_Handler.getproductsAll';



const columns = [ { label: 'Product Name', fieldName:'Exclusive_Campaign_Product__r.Name',        type: 'text'},
                  { label: 'Serial Number', fieldName: 'Name',        type: 'text'},
                  { label: 'Zone', fieldName: 'Zone_LVL__c',        type: 'text'}
                ];

export default class Tr_ArtyCappucines extends LightningElement {

    @track data = [];
    @track columns = columns;
    @track sortBy;
    @track sortDirection;
    @track nbproducts= [];
    @track nbproductsavailable= [];
    @track dataavailable=false;

   // wiredRecords;
    records;
 
    @wire(getArtyStats)
    wiredContact(result) {
        this.wiredRecords = result; // track the provisioned value
        console.log(' this.wiredRecords***'+ this.wiredRecords);
        const { data, error } = result;
        console.log(' this.data first try***'+ this.data);
        console.log(' this.error first try***'+ JSON.stringify(this.error));

        if(data) {
            this.records = JSON.parse(JSON.stringify(data));
            console.log(' this.records***'+ this.records);
            let preparedAssets = [];

            this.records.forEach(asset => {
                let preparedAsset = {};
                preparedAsset.productName = asset.Exclusive_Campaign_Product__r.Name;
                preparedAsset.serialnumber = asset.Name;
                preparedAsset.zone = asset.Zone_LVL__c;

                if(asset.Store__c!=null){
                preparedAsset.store = asset.Store__r.Name!=null?asset.Store__r.Name:'';
            }else{
                preparedAsset.store ='';
            }

                preparedAssets.push(preparedAsset);
              //  window.console.log(preparedAssets)

            });
            this.records=preparedAssets;
            console.log(' this.data final test***'+  this.records);

            window.console.log( this.records)

           // this.error = undefined;
        } else if(error) {
            this.error = error;
            this.records = undefined;
        }
    }   
    @wire(getproductsAll)
    wiredproduct({ error, data }){
        if(data){
            this.nbproducts= JSON.parse(JSON.stringify(data));
            this.dataavailable=true;
            console.log('nbproducts  ***'+ this.nbproducts)


        }
        else if(error){
            this.dataavailable=false;
            this.error=error;
            console.log('error  ***'+this.error)
    
        }

    }
    @wire(getproductsAvailable)
    wiredproductAll({ error, data }){
        if(data){
            this.nbproductsavailable  = JSON.parse(JSON.stringify(data));
            console.log('nbproductsavailable  ***'+ this.nbproductsavailable)


        }

    }

 






}