import { LightningElement, track, wire, api } from 'lwc';
import saveWishMovie from '@salesforce/apex/MovieWishListController.createWishMovie';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class ContactWish extends LightningElement {
    @track inputWish;
    @api recordId;


    setInputWish(event){
        this.inputWish = event.target.value;
    }
    
    handleRegisterWish(){
    saveWishMovie({
        name: this.inputWish,
        ContactId: this.recordId
    })
    .then(response => {
            if(response === 'success'){   
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Movie added to Wish List',
                        variant: 'success'
                    })
                )}else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Movie not added to Wish List : ',
                            variant: 'error'
                        })
                    )}}).catch(error => {
                        console.log('Error: ' + JSON.stringify(error));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Movie not added to Wish List : ',
                                variant: 'error'
                    }))
    })
} 
}
