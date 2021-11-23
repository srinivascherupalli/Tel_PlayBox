//EDGE-151597 MACD Button for PRM users
import {LightningElement,track,api,wire} from 'lwc';
import checkActivePOR from "@salesforce/apex/PRMPartnerPORCheck.checkActivePOR";
import { NavigationMixin } from 'lightning/navigation';
import myResource from '@salesforce/resourceUrl/partnerSOWItemsLWC';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class PrmPartnerPORCheck extends NavigationMixin(LightningElement) {
    @api recordId;
    @api isInactivePOR=false;
    @track resultStr;
    @track showSpinner = false;
    @track opportunityId;
    @track showFields = false;

    renderedCallback(){
        console.log('Inside rendered Callback');
	}
	checkActivePORs() {//function to check if there is an active POR between the Customer and Partner
        this.showSpinner = true;
        checkActivePOR({accountId: this.recordId})
            .then(result => {
                this.data = result;
                if(result){//redirect to MACD Page if there is an active POR
                    var url=JSON.stringify(window.location.href);
                    console.log('url'+url);
                    if(url.includes('partners.enterprise.telstra.com.au')){
                        var urlWithParameters = 'c__MACPage?accountID='+ this.recordId+'&isActivePOR=Active';
                        window.open( location.protocol + '//' + location.host + '/' + urlWithParameters, '_self');
                    }
                    else{
                        var urlWithParameters = 'c__MACPage?accountID='+ this.recordId+'&isActivePOR=Active';
                        window.open( location.protocol + '//' + location.host + '/partners/' + urlWithParameters, '_self');
                    }
                }
                else{
                    this.isInactivePOR = true;
                    this.showSpinner = false;
                }
                console.log('data is -->', this.data);

            })
            .catch(error => {
                console.log('error is -->', this.error);
            });
    }

    connectedCallback() {
        console.log('inside connectedCallback');
        this.checkActivePORs();
    }
    handleError(event) {
        this.showSpinner = false;
    }
    handleSuccess(event) {
        //this.showSpinner = true;
        console.log('onsuccess event recordEditForm',event.detail.id);
        this.opportunityId = event.detail.id;
        this.handleNavigateToOppPage(event);
    }
    handleSubmit(event) {
        this.showSpinner = true;
        console.log('onsubmit event recordEditForm'+ JSON. stringify(event.detail.fields));
    }    
    
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleNavigateToOppPage(event) {//Navigate to Opportunity detail page once the record is created
        console.log('insideNavigation');
        this.closeQuickAction();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.opportunityId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            },
        });              
    }
}