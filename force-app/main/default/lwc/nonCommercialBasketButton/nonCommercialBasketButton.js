import {LightningElement,track,api,wire} from 'lwc';
import getBasket from "@salesforce/apex/NonCommercialOrder.getBasket";
import CreateNonCommercialBasket from "@salesforce/apex/NonCommercialOrder.CreateNonCommercialBasket";
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class NonCommercialBasketButton  extends NavigationMixin(LightningElement) {
	@api recordId;
    @track showSpinner = true;
	@track basketId;
	renderedCallback(){
        console.log('Inside rendered Callback');
	}
	createBasket(event){
		console.log('createBasket');
		this.showSpinner = true;
        CreateNonCommercialBasket({accountId: this.recordId})
            .then(result => {
				console.log('record id'+ result);
                this.basketId = result;
                if(this.basketId!=null){
                    this.handleNavigateToBasket(event);
                }
            });
			
	}
	closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
	handleNavigateToBasket(event) {//Navigate to Opportunity detail page once the record is created
        console.log('insideNavigation');
        this.showSpinner=false;
		this.closeQuickAction();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.basketId,
                objectApiName: 'cscfga__Product_Basket__c',
                actionName: 'view'
            },
        });              
    }
	// initialize component
	connectedCallback() {
		console.log('connectedCallback');
		this.createBasket(event);
		//this.createBasket = 5;
	}
	
	
	
}