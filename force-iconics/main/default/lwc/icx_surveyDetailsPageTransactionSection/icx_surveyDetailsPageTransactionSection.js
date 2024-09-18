import { api, LightningElement, wire } from 'lwc';
import getTransacProduct from '@salesforce/apex/ICX_SurveyForm.getTransactionProduct';


export default class Icx_surveyDetailsPageTransactionSection extends LightningElement {

    @api transactionId;
    @api clientDreamId;
    dataReformated;
    imageSource;
    isLoading = true;



    connectedCallback() {
        if (this.transactionId) this.getTransaction(this.transactionId);
    }


    getTransaction() {
        return getTransacProduct({ transactionId: this.transactionId, dreamIdClient: this.clientDreamId })
            .then(result => {
                console.log({ result })
                this.imageSource = result.imageUrl;
                console.log('imageSource: ', this.imageSource)
                this.formateData(result);
            })
            .catch(error => {
                console.error(error);
            })
    }

    formateData(data) {
        this.dataReformated = [
            { label: 'Product Name', value: data.productName },
            { label: 'Product SKU', value: data.productSku },
            { label: 'Transaction Date', value: data.purchaseDate },
            { label: 'Transaction CA', value: data.CAName },
        ]

        this.isLoading = false;
    }
}