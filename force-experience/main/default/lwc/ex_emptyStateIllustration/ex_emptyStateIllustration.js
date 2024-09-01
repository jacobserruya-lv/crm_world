import { LightningElement } from 'lwc';
import Title from '@salesforce/label/c.E_E_store_hierarchy_NoResultTitle';
import Message from '@salesforce/label/c.E_E_store_hierarchy_NoResultMessage';

export default class Ex_emptyStateIllustration extends LightningElement {
    label={
        Title,
        Message
    }
}