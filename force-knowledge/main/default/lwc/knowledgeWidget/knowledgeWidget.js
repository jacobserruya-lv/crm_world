import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import knowledgeRecordTypes from '@salesforce/apex/KnowledgeWidgetController.knowledgeRecordTypes';
import knowledgeArticles from '@salesforce/apex/KnowledgeWidgetController.knowledgeArticles';

export default class knowledgeWidgetLWC extends NavigationMixin(LightningElement) {
    @track article;
    @track articleList = [];

    @track selectedAritcle = {};

    @track recordType = 'All';
    @track recordTypeList = [];

    @track value = '';

    @track showClientService;

    @api displayCard;

    get componentClass() {
        return (this.displayCard ? 'slds-page-header' : 'slds-var-m-around_medium');
    }

    get options() {
        return [      		
			{ label: 'Australia', value: 'Australia' },
			{ label: 'Brazil', value: 'Brazil' },
			{ label: 'Canada', value: 'Canada' },
			{ label: 'China', value: 'China' },
			{ label: 'Europe', value: 'Europe' },
			{ label: 'Hong Kong Macao/Taiwan', value: 'Hong_Kong_Macao_Taiwan' },				
			{ label: 'India', value: 'India' },
			{ label: 'Indonesia', value: 'Indonesia' },
			{ label: 'Japan', value: 'Japan' },
			{ label: 'Korea', value: 'Korea' },
			{ label: 'Mexico', value: 'Mexico' },
			{ label: 'Middle East', value: 'Middle_East' },
			{ label: 'Singapore', value: 'Singapore' },
			{ label: 'Thailand', value: 'Thailand' },
			{ label: 'USA', value: 'USA' },	
			{ label: 'Vietnam', value: 'Vietnam' },		
            { label: 'Worldwide', value: 'Worldwide' },				
		
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
    }  

    @wire(knowledgeRecordTypes)
    wiredRecordTypes({error, data}) {
        if (data) {

            let tempRecordType = []
            tempRecordType.push({'value':'All' , 'label':'All'});

            data.forEach(element => {
                 tempRecordType.push({'value':element , 'label':element});
            });
            this.recordTypeList = tempRecordType;
        }
        if (error) {
            this.error = error;
        }
    };

    @wire(knowledgeArticles, {searchText : '$article', recordTypeDeveloperName : '$recordType', selectedClientService : '$value'})
    wiredArticles({error, data}) {
        if (data) {
            this.articleList = [];
            for (let article of data) {
                let myArticle = {};
                myArticle.data = article;

                // Get article url
                this.KnowledgePageRef = {
                    type: "standard__recordPage",
                    attributes: {
                        "recordId": article.Id,
                        "objectApiName": "Knowledge__kav",
                        "actionName": "view"
                    }
                };

                this[NavigationMixin.GenerateUrl](this.KnowledgePageRef)
                    .then(articleUrl => {
                        myArticle.url = articleUrl;
                        this.articleList.push(myArticle);
                    });
            }
            this.error = undefined;
        }

        if (error) {
            this.error = error;
            this.articleList = undefined;
        }
    }

    changeHandler(event) {
        this.article = event.target.value;
        this.selectedAritcle = {};
        console.log('article', this.article);

    }

    handleCible(event) {
        this.recordType = event.target.value;
        if(this.recordType == 'Internal'){
            this.showClientService = true;
        } else {
            this.showClientService = false;
        }
        console.log('recordType', this.recordType);
        console.log('showClientService', this.showClientService);
    }

    redirectToArticle(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.dataset.info,
                objectApiName: 'Knowledge__kav',
                actionName: 'view'
            }
        });
    }

    // onmouseover
    showData(event){
        var recordId = event.currentTarget.dataset.info;
        this.selectedAritcle = this.articleList.find(element => element.data.Id == recordId );
      }
}