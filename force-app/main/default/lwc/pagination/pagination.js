import { LightningElement, api } from 'lwc';

export default class Pagination extends LightningElement {
    currentPage = 1;
    totalRecords;
    recordSize = 4; 
    totalPage = 0;
    get records(){
        return this.visibleRecords;
    }


    @api 
    set records(data){
        if(data){
            this.totalRecords = data;
            this.totalPage = Math.ceil(data.length / this.recordSize);
            this.updateRecords();

        }
    }
    get disablePreviousButton(){
       return this.currentPage <= 1 ? 'slds-hide' : ''

    }
    get disableNextButton(){
        return  this.currentPage >= this.totalPage ? 'slds-hide' : ''

    }
    hanldePreviousPage(){
        if(this.currentPage > 1){
            this.currentPage = this.currentPage - 1;
            this.updateRecords();

        }

    }
    hanldeNextPage(){
        if(this.currentPage < this.totalPage){
            this.currentPage = this.currentPage + 1;
            this.updateRecords();

        }


    }
    updateRecords(){
        const start = (this.currentPage - 1 ) * this.recordSize;
        const end = this.recordSize*this.currentPage;
        this.visibleRecords = this.totalRecords.slice(start,end);

        this.dispatchEvent(new CustomEvent('update', {
            detail:{
                records:this.visibleRecords
            }

        }))
      

    }

}