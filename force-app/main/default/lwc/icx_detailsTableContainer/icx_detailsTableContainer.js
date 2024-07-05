import { api, LightningElement } from 'lwc';
import {getGuidId} from 'c/utils';

export default class Icx_detailsTableContainer extends LightningElement {
    @api title;
    @api subtitles;

    renderedCallback() {
        console.log('detailsTableCntainer', this.title, this.subtitles)
    }

    get getGuidId()
    {
        return getGuidId();
    }
}