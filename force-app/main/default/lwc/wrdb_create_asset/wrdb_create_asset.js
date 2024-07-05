import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getManagementZoneLevel from '@salesforce/apex/WRDB_CreateAsset_Controller.getManagementZoneLevel';
import getManagementCountryLevel from '@salesforce/apex/WRDB_CreateAsset_Controller.getManagementCountryLevel';
import getManagementStoreLevel from '@salesforce/apex/WRDB_CreateAsset_Controller.getManagementStoreLevel';
import createAsset from '@salesforce/apex/WRDB_CreateAsset_Controller.createAsset';
import createAzureCustomAssetByUrl from '@salesforce/apex/WRDB_CreateAsset_Controller.createAzureCustomAssetByUrl';
import createAzureCollection from '@salesforce/apex/WRDB_CreateAsset_Controller.createAzureCollection';
import { getFileDimensions, removeEmpty, showMessage } from 'c/wrdbAssetUtils';
import { deleteFileFromAkamaiNS, uploadFileToAkamaiNS } from 'c/wrdbNetStorageServices';

export default class wrdb_create_asset extends NavigationMixin(LightningElement) {
    @wire(getManagementZoneLevel)
    managementZoneLevel({data, error}) {
        if (data) {
            this.zoneOptions = data.map(zone => ({
                label: zone.MANAGEMENT_ZONE_LEVEL_TECH__c,
                value: zone.MANAGEMENT_ZONE_LEVEL__c
            }));
        } else if (error) {
            this.error = error;
        }
    };

    @wire(getManagementCountryLevel, {
        selectedZone: "$selectedZone"
    })
    managementCountryLevel({data, error}) {
        if (data) {
            this.countryOptions = data.map(country => ({
                label: country.StoreCountry__c,
                value: country.StoreCountry__c
            }));
        } else if (error) {
            this.error = error;
        }
    };

    @wire(getManagementStoreLevel, {
        selectedCountry: "$selectedCountry"
    })
    managementStoreLevel({data, error}) {
        if (data) {
            this.storeOptions = data.map(store => ({
                label: store.Name,
                value: store.RetailStoreId__c
            }));
        } else if (error) {
            this.error = error;
        }
    };

    collectionName = '';
    isCollectionNameTaken = false;
    isCollectionOwner = false;
    existCollectionId = '';

    zoneOptions = [];
    countryOptions = [];
    storeOptions = [];

    selectedZone;
    selectedCountry;
    selectedStore;

    disabledZone = false;
    disabledCountry = true;
    disabledStore = true;

    isFileUpload = false;
    isLoading = false;
    uploadedFiles = [];
    assetsInfo = {};
    failedToUpload = [];
    filesAddress = [];
    error;
    assetData = {
        zone: null,
        country: null,
        store: null,
        scope: "icon"
    };
    csvFiles = [];

    get scope() {
        return this.collectionName ? "collection" : "icon";
    }
    get acceptedFormats() {
        return ['.jpg', '.png', '.jpeg', '.mp4', '.gif'];
    }

    get isFieldsAreNotFilled() {
        return !(this.assetData.scope && this.uploadedFiles.length) || (this.isCollection && !this.collectionName);
    }

    get isFileUploadFinish() {
        return !this.isFileUpload && !!this.uploadedFiles;
    }

    get isValidFilesNames() {
        return Object.keys(this.assetsInfo).every(name => this.uploadedFiles.find(f => f.name.replace(/\s/g, "") === name));
    }

    refreshCollections() {
        this.template.querySelector('c-wrdb-collection-info')?.refetch();
    }

    handleZoneChange(event) {
        this.selectedZone = event.target.value;
        this.assetData.zone = this.zoneOptions.find(({label, value}) => value === this.selectedZone)?.label;
        this.disabledCountry = false;
        this.selectedCountry = null;
        this.disabledStore = true;
    }

    handleCountryChange(event) {
        this.selectedCountry = event.target.value;
        this.assetData.country = this.countryOptions.find(({label, value}) => value === this.selectedCountry)?.label;
        this.disabledStore = false;
        this.selectedStore = null;
    }

    handleStoreChange(event) {
        this.selectedStore = event.target.value;
        this.assetData.store = this.selectedStore;
    }

    handleScopeChange(event) {
        this.assetData.scope = event.target.value;
    }

    handleUploadFinished(event) {
        this.uploadedFiles = Array.from(event.target.files);
    }

    handleAssetInfoChange(event) {
        this.assetsInfo = event.detail.assetsInfo;
    }

    handleCollectionNameChange(event) {
        this.collectionName = event.detail.collectionName,
        this.isCollectionNameTaken = event.detail.isCollectionNameTaken,
        this.isCollectionOwner = event.detail.isCollectionOwner,
        this.existCollectionId = event.detail.existCollectionId
    }

    getInvalidAssetsInfoNames() {
        const invalidNames = Object.keys(this.assetsInfo).filter(
            name => this.uploadedFiles.findIndex(f => {
                const fileName = f.name.substring(
                    0, f.name.lastIndexOf('.')
                    ).replace(/\s/g, "");  
                    return fileName === name;
            }) < 0
        );

        return invalidNames;
    }

    async handleClick(event) {
        if (this.isFieldsAreNotFilled) {
            return showMessage(this, 'Please fill in all the required fields');
        }

        const invalidNames = this.getInvalidAssetsInfoNames();
        if (invalidNames.length) {
            return showMessage(this, `Invalid csv assets names: ${[invalidNames]}`);
        }

        this.isLoading = true;
        this.assetData = removeEmpty(this.assetData);

        try {
            const urlsForAzure = (
                await this.uploadFilesToAkamai(this.uploadedFiles)
            ).filter(Boolean);

            if (urlsForAzure.length === 0) {
                this.isLoading = false;
                return showMessage(this, 'We could not upload any of the files, please try again');
            } else if (urlsForAzure.length !== this.uploadedFiles.length) {
                showMessage(this, 'There was a problem with some of the files, please try to upload them later:');
            }

            const azureResult = this.collectionName ? 
                await this.createCollectionAssets(urlsForAzure) : 
                await createAzureCustomAssetByUrl({ 
                    body: JSON.stringify({
                        ...this.assetData,
                        assets: urlsForAzure
                    })
                });
            const records = JSON.parse(azureResult).records;
            const assets = records.map(asset => ({
                ...asset,
                id: asset._id,
                skus: asset.skus?.toString()
            }));
    
            await createAsset({ assets });
            showMessage(this, 'The Asset has been created successfully', 'Success', 'success');
            this.isLoading = false;
            this.navigateToAssetView();                                                                                                                                                                                                                                                                                           
        } catch (error) {
            this.error = error;
            const jsonError = error?.body?.message && JSON.parse(error.body.message);
            const errorMsg = jsonError?.message ?? 'Failed to create asset: ' + error?.body?.message;
            showMessage(this, errorMsg);
            this.updateFailedToUpload(this.uploadedFiles.map(f => f.name), errorMsg);
            const deletedAssets = await this.deleteFilesFromAkamaiNS(this.filesAddress);
            console.log(deletedAssets);
            this.isLoading = false;
        }
    }

    async uploadFilesToAkamai(files) {
        return await Promise.all(files.map(async (file) => {
            return new Promise(async(resolve, reject) => {
                try {
                    const { accessUrl, fileAddress } = await uploadFileToAkamaiNS(file);
                    this.filesAddress.push(fileAddress);
                    this.removeFromFailedToUpload([file.name.sub]);
                    const { width, height } = await getFileDimensions(accessUrl);
                    const fileName = file.name.substring(
                        0, file.name.lastIndexOf('.')
                    );     
                    const { name, skus, ...assetInfo } = this.assetsInfo[fileName.replace(/\s/g, "")] || {};
                    return resolve({ accessUrl, width, height, ...assetInfo });
                } catch (error) {
                    this.updateFailedToUpload([file.name], error);
                    return reject(error);
                }
            })
            .catch(err => {
                if (err) {
                    this.updateFailedToUpload([file.name], err);
                    console.log(err);
                }
            });
        }));
    }

    async deleteFilesFromAkamaiNS(filesAddress) {
        return await Promise.all(filesAddress.map(async (fileAddress) => {
            return new Promise(async(resolve, reject) => {
                const akamaiResponse = await deleteFileFromAkamaiNS(fileAddress)
                console.log(akamaiResponse);
                if (akamaiResponse.ok) {
                    return resolve({ deleted: true });
                } else {
                    return resolve({ deleted: false });
                }
            })
            .catch(err => {
                console.log(err);
            });
        }));
    }

    async createCollectionAssets(urlsForAzure) {
        const azureRequestBody = JSON.stringify({
            ...(!this.isCollectionNameTaken && { name: this.collectionName }),
            looks: urlsForAzure
        });
        const azureCreatedCollectionResult = await createAzureCollection({ body: azureRequestBody, id: this.isCollectionNameTaken ? this.existCollectionId : '' });
        this.refreshCollections();
        console.log({azureCreatedCollectionResult});
        const { looks } = JSON.parse(azureCreatedCollectionResult).records[0];
        return JSON.stringify(looks);
    }

    updateFailedToUpload(fileNames = [], msg = '') {
        const updatedArray = [
            ...this.failedToUpload,
            ...fileNames.map(name => ({ 
                name,
                msg
            }))
        ];
        const arraySetByName = updatedArray.reduce((prev, current) => ({ ...prev, [current.name]: current }), {});
        this.failedToUpload = Object.values(arraySetByName);
    }

    removeFromFailedToUpload(fileNames = []) {
        this.failedToUpload = [...this.failedToUpload.filter(f => fileNames.indexOf(f.name) < 0)];
    }

    navigateToAssetView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'WRDB_Asset__c',
                actionName: 'list'
            }
        });
    }
}