import Twist_UI from "@salesforce/resourceUrl/Twist_UI";
import { LightningElement, track , api} from 'lwc';
import { isMobileDevice } from 'c/twistUtils';

export default class DateInputFormat extends LightningElement {
    @track formattedDate;

    @api dateField;
    @api customLabels;
    @api calendarDateFormat;

    @api setErrorMessage(message) {
        try {
            const fieldElement = this.template.querySelector(".birthdate-overlay");
            fieldElement.setCustomValidity(message);
            fieldElement.reportValidity();
            
        }
        catch (error) {
            console.log(error)
        }
    }

    @api getDateFieldElement() {
        return this.template.querySelector("[data-id]");
    }
    
    chevronLV = Twist_UI + "/Chevrons.svg";
    
    handleBirthdayDateChange(event) {
        let formattedDate;
        let eventToDispatch;
        try {
            const selectedDate = event.target.value;
            if (selectedDate === undefined || !selectedDate) {
                formattedDate = "";
                this.setErrorMessage("");
                eventToDispatch = new Event('resetfieldbirthday');
            }
            else {
                const dateParts = String(selectedDate).split('-');
                formattedDate = this.calendarDateFormat
                    .replace('day', dateParts[2])
                    .replace('month', dateParts[1])
                    .replace('year', dateParts[0]);
                eventToDispatch = new CustomEvent('getfieldbirthday', { detail: { targetId: event.target.dataset.id, value: selectedDate }});
            }
            this.formattedDate = formattedDate;
            this.dispatchEvent(eventToDispatch);
        }
        catch (e) {
            console.error('Error in dateInputFormat component: ' + e);
        }
    }

    handlerFormBirthdayKeyDown(event){
        event.preventDefault();
    }

    get containerClassName() {
        return isMobileDevice() ? "mobile" : "desktop";
    }

    get lightningInputVariant() {
        return isMobileDevice() ? "" : "label-hidden";
    }

}