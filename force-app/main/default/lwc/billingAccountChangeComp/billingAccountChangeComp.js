import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";

import getAllSubs from '@salesforce/apex/billingAccountChangeComp.getRelatedSubs';
import getBillingStatus from '@salesforce/apex/billingAccountChangeComp.getBillingAccStatus';
import handleException from '@salesforce/apex/CheckAsyncJobDetails.handleException';//EDGE-224341

export default class billingAccountChangeComp extends LightningElement {
    @api accountid;
    @api contactid;
    @api subids = [];

    @track finalSubids = [];
    @track status = [];
    @api reason;
    @api billingaccid;
    @api requestorcontact;
    @api filterstring;  
    clickedButtonLabel;
    @track msg;

    connectedCallback(){
        //EDGE-224341 - Added a method to get the billing status values
        getBillingStatus()
        .then(result =>{
            this.status = result;
            this.filterstring = 'Status__c IN (' + this.status + ') AND Account__c = \''+this.accountid+'\'';
        })
        .catch(error => {
            if(error.body.message) {
                this.handleExcption('getBillingAccStatus',error.body.message,'');
            }
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Please try again and in case the issue persist please contact your admin',
                variant: 'error'
            });
            this.dispatchEvent(event);
        });
        
    }


    //210200 - Added a wire method to receive the related subscriptions for BAN cardinality single offers
    @wire(getAllSubs, {
        subIds: '$subids'
    })
    subList({
        error,
        data
    }) {
        if (data) {
            this.finalSubids = data;

            const finalSelectedIds = data;
            const finalSelectedEvent = new CustomEvent("finalSelectedEvnt", {
                detail: {
                    finalSelectedIds
                }
            });
            this.dispatchEvent(finalSelectedEvent);

        } else if (error) {
            if(error.body.message) {
                this.handleExcption('getRelatedSubs',error.body.message,'');
            }
            this.error = error;
            this.data = undefined;
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Please try again and in case the issue persist please contact your admin',
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
    }


    //EDGE-224341 -  Added this method to handle the exceptions
    handlerecordselection(event) {
        const textVal = event.detail;
        this.billingaccid = textVal.selectedRecordId;
        const billval = textVal.selectedRecordId;
        const billingaccEvent = new CustomEvent("billingaccEvnt", {

            detail: {
                billval
            }

          });
          this.dispatchEvent(billingaccEvent);
    }

    handleExcption(methodName,exceptiongetMessage,codeMessage) {
        handleException({
            methodName:methodName,
            exceptiongetMessage: exceptiongetMessage,
            codeMessage:codeMessage
        })
    }
}