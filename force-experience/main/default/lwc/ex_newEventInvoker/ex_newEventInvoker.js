import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class Ex_newEventInvoker extends LightningElement {
    
    openModal = false;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        debugger
        if (this.pageRef) {
            console.log('Page Reference:', this.pageRef);
            this.openModal = this.pageRef.state.c__openModal || false;
            // if (this.pageRef.state.c__openModal==true) {
            // }
        }
    }

    // closeModal() {
    //     this.openModal = false;
    // }

    // get modalClass() {
    //     return this.openModal ? 'modal showModal' : 'modal';
    // }
}
