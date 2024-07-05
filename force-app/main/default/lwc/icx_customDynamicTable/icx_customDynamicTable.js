import { api, LightningElement,wire } from 'lwc';



export default class Icx_dynamicTable extends LightningElement {
    @api tableData;
    @api isWithSubtitles;
    @api myRowClass;
    @api clickFunction;
    @api isProductRow;
    @api searchResult;
    
    
 
    
    handleClickRow(event){
        // console.log('nao into onclick',event.currentTarget.dataset.index)
        if(this.isProductRow)
        {
            
            this.dispatchEvent(new CustomEvent('productdetails',{detail : event.currentTarget.dataset.index}));
            
        }
        if(this.searchResult)
        {
            this.dispatchEvent(new CustomEvent('searchdetails',{detail : event.currentTarget.dataset.index}));
            
        }
    }
    
    
    
    
}