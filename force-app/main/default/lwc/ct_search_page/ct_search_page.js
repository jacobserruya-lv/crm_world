import { LightningElement, track } from 'lwc';

export default class Ct_search_page extends LightningElement {
    @track
    contacts = [
        {
            Id: 1,
            Name: 'Amy Taylored',
            Title: 'VP of Engineering',
        },
        {
            Id: 2,
            Name: 'Michael Jones',
            Title: 'VP of Sales',
        },
        {
            Id: 3,
            Name: 'Jennifer Wu',
            Title: 'CEO',
        },
    ];
}