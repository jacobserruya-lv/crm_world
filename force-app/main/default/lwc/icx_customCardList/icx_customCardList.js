import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Icx_customCardList extends NavigationMixin(LightningElement)  {
    @api listData;
    @api isNotWithPicture;
    @api editRecord;
    @api deleteRecord;
    @api redText;

    handleNavigation(event){

            this.dispatchEvent(new CustomEvent('detailsrecord',{detail : event.detail}));
    }

    handleCardEdit (e) {

        console.log('event in the card list', e.detail);
        const evt = new CustomEvent('cardeditselected', {
            // detail contains only primitives
            detail: e.detail
            // Fire the event from c-tile
        });
            this.dispatchEvent(evt);
            
    }

    handleDeleteCard(evt)
    {
        console.log('Delete record',evt.detail);
         this.dispatchEvent(new CustomEvent('carddeleteselected',{detail:evt.detail}));
    }
  


    // handleListView (e) {
    //     const evt = new CustomEvent('viewrecordlist', {
    //         // detail contains only primitives
    //         detail: e.detail.actionName
    //         // Fire the event from c-tile
    //     });
    //         this.dispatchEvent(evt);
            
    // }


    navigateToViewAccountPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
              //recordId: sfRecordId,
              objectApiName: 'Calling_Campaign__r',
              actionName: 'view'
            },
        });
    }

    get viewMoreDisplay()
    {
        return this.listData.length;
    }
}