import { LightningElement, api, track} from 'lwc';
import Twist_UI from '@salesforce/resourceUrl/Twist_UI';
import apexTranslateLabels from '@salesforce/apex/TWIST_i18nTranslations.translateLabelsList';
import { lwcNameToCamelCase } from 'c/twistUtils';

export default class TwistModalStayToContinue extends LightningElement {
    @api showModal;
    @api language;
    @track customLabels = {};
    
    twistCloseIcon = Twist_UI + '/close-image.png';
    
    constructor() {
        super();
        this.showModal = false;
    }
    
    handleOnClick(event) {
        this.dispatchEvent(new CustomEvent('clickaction', { detail: event.target.dataset.id }));
    }
    
    connectedCallback() {
        this.init();
    }

    renderedCallback() {
        this.dispatchEvent(new CustomEvent('childlwcrendered', { detail: lwcNameToCamelCase(this.template.host.localName) }));
    }
    
    init() {
        apexTranslateLabels({
            labels: [
                'Twist_TitleModalStayToContinue',
                'Twist_ContinueButtonStayToContinue',
                'Twist_FirstTextStayToContinue',
                'Twist_SecondTextStayToContinue',
                'Twist_LeaveButtonStayToContinue'
            ],
            language: this.language
        })
        .then(result => {
            this.customLabels = result;
        })
        .catch(error => {
            console.error('error', error);
        });
    }
    
}
