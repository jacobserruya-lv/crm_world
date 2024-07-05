import { api, LightningElement } from 'lwc';
import getAllCollections from '@salesforce/apex/WRDB_CreateAsset_Controller.getAllCollections';
import UserId from '@salesforce/user/Id';

export default class WrdbCollectionInfo extends LightningElement {
    selectedCollectionValue = '';
    collectionName = '';
    isCollectionNameTaken = false;
    isCollectionOwner = false;
    existCollectionId = '';
    checkCollectionNameTimeout = null;
    allCollections = [];

    get yourCollections() {
        return this.allCollections?.
            filter(c => c.ownerId === UserId).
            map(collection => ({
            label: collection.name,
            value: collection._id
        }));
    }

    @api 
    refetch() {
        getAllCollections()
        .then(data => {
            if (data) {
                const { records } = JSON.parse(data);
                this.allCollections = records.map(c => ({ ...c, isYourCollection: c.ownerId === UserId})) || [];
                console.log(this.allCollections);
            }
        })
        .catch(e => {
            console.log(e);
        });
    }

    connectedCallback() {
        if (this.allCollections.length < 1) {
            this.refetch();
        }
    }

    handleCollectionSelect(event) {
        this.selectedCollectionValue = event.detail.value;
        this.collectionName = this.allCollections.find(c => c.id === this.selectedCollectionValue)?.name || this.collectionName;
        this.validateCollectionName();
    }

    handleCollectionNameChange(event) {
        this.collectionName = event.target.value;
        this.selectedCollectionValue = '';
        this.validateCollectionName();
    }

    validateCollectionName() {
        clearTimeout(this.searchTimeout);
        this.isCollectionNameTaken = false;
        this.isCollectionOwner = false;
        this.existCollectionId = '';

        const validationMessageElement = this.template.querySelector('.collection-input-warning');
        if (validationMessageElement) {
            validationMessageElement.innerHTML = '';
        }

        this.checkCollectionNameTimeout = setTimeout(() => {
            if (this.collectionName) {
                const existCollection = this.allCollections.find(({ name }) =>  name.toLowerCase() === this.collectionName.toLowerCase());
                this.isCollectionNameTaken = !!existCollection;
                this.isCollectionOwner = this.isCollectionNameTaken && existCollection.ownerId === UserId;
                this.existCollectionId = existCollection?._id;

                if (this.isCollectionNameTaken && this.isCollectionOwner) {
                    this.selectedCollectionValue = this.existCollectionId;
                    validationMessageElement.innerHTML = "You have already created this collection, it will be edit."
                    validationMessageElement.style.color = "#ffc107";
                } else if (this.isCollectionNameTaken) {
                    validationMessageElement.innerHTML = "This collection has already created by another user, you cannot edit it."
                    validationMessageElement.style.color = "#dc3545";
                }
            }
            this.dispatchCollectionInfo();
        }, 500);

    }

    dispatchCollectionInfo() {
        this.dispatchEvent(new CustomEvent('collectionnamechanged', {
            detail: {
                collectionName: this.collectionName,
                isCollectionNameTaken: this.isCollectionNameTaken,
                isCollectionOwner: this.isCollectionOwner,
                existCollectionId: this.existCollectionId
            }
        }));
    }
}