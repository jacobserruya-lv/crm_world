import { LightningElement, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import Papa from "@salesforce/resourceUrl/PapaParse";
import getAssetInfoSettings from '@salesforce/apex/WRDB_CreateAsset_Controller.getAssetInfoSettings';
import getProductsBySkus from '@salesforce/apex/WRDB_CreateAsset_Controller.getProductsBySkus';
import { showMessage } from 'c/wrdbAssetUtils';

export default class WrdbAssetInfo extends LightningElement {
    @wire(getAssetInfoSettings)
    assetInfoSettings;

    csvFiles = [];
    assetsInfo = {};

    renderedCallback() {
        loadScript(this, Papa)
        .then((res) => console.log('Loaded papa'))
        .catch(error => console.log(error));
    }

    async productsBySKUs(skus = []) {
        try {
            return await getProductsBySkus({skus});
        } catch (error) {
            console.log(error);
        }
    }

    handleAssetInfoTemplateDownload() {
        const csvContent = this.assetInfoSettings.data?.map(({ Label }) => Label) || [];
        const downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvContent);
        downloadElement.target = '_self';
        downloadElement.download = 'AssetInfoTemplate.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
      }

    async handleUploadInformationCsv(event) {
        this.csvFiles = Array.from(event.target.files);
        const [ infoFile ] = this.csvFiles;
        const csvContent = await this.readCsvContent(infoFile);
        const [ titles, ...csvRows ] = this.papaCsvParse(csvContent);
        const requiredFields = this.assetInfoSettings.data.filter(a => !!a.IsRequired__c);
        const missingFields = requiredFields.map(field => {
            const labelIndex = titles.indexOf(field.Label);
            if (labelIndex < 0) {
                return field.Label;
            }

            return null;
        }).filter(Boolean);

        if (missingFields.length) {
            showMessage(this, `Info file missing required fields ${[missingFields]}`);
            return;
        }

        //check for duplicates names
        const nameIndex = titles.indexOf('name');
        let names = {};
        csvRows.forEach(row => {
            if (names[row[nameIndex]]) {
                showMessage(this, `Duplicate name: ${[row[nameIndex]]}`);
                return;
            }
            names[row[nameIndex]] = true;
        })

        const assetsInfo = csvRows.map(row => {
            return !!row.toString() && titles.reduce((prev, current, index) => ({
                ...prev,
                ...(row[index]) && { [current]: this.assetCsvFieldByType(current, row[index]) }
            }), {});
        })
        .filter(Boolean);

        const skus =  [...new Set((assetsInfo).flatMap((asset) => asset.skus))];
        const products = await this.productsBySKUs(skus);
        this.assetsInfo = assetsInfo.map(asset => ({
            ...asset,
            products: products.filter(p => asset['skus']?.includes(p.SKU__c)).map(({ Name, SKU__c, Image1Url__c }) => ({
                name: Name,
                sku: SKU__c,
                contentUrl: Image1Url__c || `https://www.louisvuitton.com/images/is/image/lv/1/PP_VP_L/louisvuitton--${SKU__c}_PM2_Front%20view.jpg`
            }))
        })).reduce((prev, current) => ({
            ...prev,
            [current.name]: current
        }), {});
        console.log(this.assetsInfo);
        this.dispatchAssetInfo();
    }

    async readCsvContent(file) {
        return new Promise((resolve, reject) => {
            try {
                const reader = new FileReader();
                reader.onload = function (e) {
                   const text = e.target.result;
                   resolve(text);
                };
                reader.readAsText(file);
            } catch(e) {
                reject(e);
            }
        });
    }

    papaCsvParse(csvContent) {
        const parsedCsv = window.Papa.parse(csvContent);
        return parsedCsv.data.filter(row => !!row.toString()).map(row => row.map(field => field.replace(/\s/g, "")));
    }

    assetCsvFieldByType(field, value) {
        const { Enum__c, Type__c } = this.assetInfoSettings?.data?.find(d => d.Label === field);
        if (Enum__c && !Enum__c.replace(/\s/g, "").split(',').includes(value)) {
            showMessage(this, `${field} ${value} is not valid Enum array: ${[Enum__c]}`);
            this.csvFiles = [];
            throw "Error";
        }
        return Type__c === "Array" ? value.split(',') : value;
    }

    dispatchAssetInfo() {
        this.dispatchEvent(new CustomEvent('assetinfochange', {
            detail: {
                assetsInfo: this.assetsInfo
            }
        }));
    }
}