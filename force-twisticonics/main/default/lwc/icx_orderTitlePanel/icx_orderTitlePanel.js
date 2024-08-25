import { api, LightningElement, track, wire } from 'lwc';

export default class icx_OrderTitlePanel extends LightningElement {
    
    @api 
    get ordershipping(){return this._orderShipping;}
    set ordershipping(orderShipping){this._orderShipping = orderShipping;}

    @track _orderShipping;

    get showStatus() {
        return (this.status != null);
    }

    get status() {
        return this._orderShipping.statusIconics;
    }

    get showLeadtime() {
        // console.log('JGU-isLeadtime() : ' + this.leadtime);
        return (this.leadtime != null);
    }

    // get leadtime() {
    //     if (this._orderShipping?.initial_leadtime) {
    //         if(this._orderShipping.initial_leadtime.min > 0 && this._orderShipping.initial_leadtime.max > 0) {
    //             return this._orderShipping.initial_leadtime.min + ' to ' + this._orderShipping.initial_leadtime.max + ' days';
    //         }
    //         else if(this._orderShipping.initial_leadtime.min == 0 && this._orderShipping.initial_leadtime.max == 0) {
    //             return 'Ready to be prepared';
    //         }
    //     }
    //     return null;
    // }

    //naomi fix for leadtime label 07/2023
    get leadtime() {
        if (this._orderShipping?.leadtime) {
            if(this._orderShipping.leadtime.min > 0 && this._orderShipping.leadtime.max > 0) {
                return this._orderShipping.leadtime.min + ' to ' + this._orderShipping.leadtime.max + ' days';
            }
            else if(this._orderShipping.leadtime.min == 0 && this._orderShipping.leadtime.max == 0) {
                return 'Ready to be prepared';
            }
        }
        return null;
    }

    get showRevisedLeadtime() {
        // console.log('JGU-isRevisedLeadtime() : ' + this.revisedLeadtime);
        return (this.revisedLeadtime != null);
    }

    get revisedLeadtime() {
        if (this._orderShipping?.revised_leadtime) {
            if(this._orderShipping.revised_leadtime.min > 0 && this._orderShipping.revised_leadtime.max > 0) {
                return this._orderShipping.revised_leadtime.min + ' to ' + this._orderShipping.revised_leadtime.max + ' days';
            }
        }
        return null;
    }

    get showInitalETA() {
        return (this.initalETA != null);

    }
    get showRevisedETA() {
        return (this.revisedETA != null);

    }

    get initalETA() {
        let initialEtaMin = this._orderShipping?.shipment?.initial_estimated_delivery_date_min;
        let initialEtaMax = this._orderShipping?.shipment?.initial_estimated_delivery_date_max;

        if (initialEtaMin && initialEtaMax) {
            if (initialEtaMin == initialEtaMax) {
                return initialEtaMin;
            }
            else {
                return initialEtaMin + ' to ' + initialEtaMax ;
            }
        }
        else if (initialEtaMin) {
            return initialEtaMin;
        }
        else if (initialEtaMax) {
            return initialEtaMax ;
        }
        // else if (this._orderShipping?.eta) {
        //     return this._orderShipping.eta.min==this._orderShipping.eta.max ? this._orderShipping.eta.max: this._orderShipping.eta.min + ' to ' + this._orderShipping.eta.max ;
        // }
        else {
            return null;
        }
    }

    get revisedETA() {
        let revisedEtaMin = this._orderShipping?.shipment?.estimated_delivery_date_min;
        let revisedEtaMax = this._orderShipping?.shipment?.estimated_delivery_date_max;

        if (revisedEtaMin && revisedEtaMax) {
            if (revisedEtaMin == revisedEtaMax) {
                return revisedEtaMin;
            }
            else {
                return revisedEtaMin + ' to ' + revisedEtaMax ;
            }
        }
        else if (revisedEtaMin) {
            return revisedEtaMin;
        }
        else if (revisedEtaMax) {
            return revisedEtaMax ;
        }
        // else if (this._orderShipping?.revised_eta) {
        //         return this._orderShipping.revised_eta.min ==this._orderShipping.revised_eta.max ? this._orderShipping.revised_eta.max : this._orderShipping.revised_eta.min  + ' to ' + this._orderShipping.revised_eta.max ;
        // }
        else {
            return null;
        }
    }
}