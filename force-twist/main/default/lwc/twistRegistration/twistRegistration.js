import { LightningElement } from 'lwc';

export default class TwistRegistration extends LightningElement {

    registrationButtonLabel = 'Register'; // JSI
    isRegistrationButtonDisabled = false;

    clickOnRegistrationButton(event) {
        this.isRegistrationButtonDisabled = true;
        console.log('Trigger register action...'); // JSI: call Apex method instead
    }

}