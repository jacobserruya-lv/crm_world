import { api, LightningElement, track } from 'lwc';
import imagesResource from '@salesforce/resourceUrl/iconics';


export default class StarsRating extends LightningElement {

    @api score;
    @api totalStars;
    @api size;
    @api imgSrc = imagesResource + `/images/client360/Survey/yellowStar.svg`;
    @track stars = new Array();

    connectedCallback() {

        for (let i = 0; i < this.totalStars; ++i) {
            if (i < Math.round(this.score)) {
                this.stars.push(
                    {
                        index: i,
                        imgSrc: this.imgSrc,
                    }
                );
            } else {
                this.stars.push(
                    {
                        index: i,
                        imgSrc: this.imgSrc,
                        style: 'opacity: 20%',
                    }
                );
            }
        }
    }

}