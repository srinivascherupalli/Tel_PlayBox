/*
Added by team Hawaii for P2OB-5311
Date : 25th Nov 2020
*/
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import prmFeedbackSubmitted from '@salesforce/label/c.prmFeedbackSubmitted';
import prmFeedbackTeamMsg from '@salesforce/label/c.prmFeedbackTeamMsg';
import thankYouHeaderMsg from '@salesforce/label/c.thankYouHeaderMsg';

export default class PrmThankYouCmp extends NavigationMixin(LightningElement) {

    //Store all labels in a collection variable to expose to DOM
    labels = {
        prmFeedbackSubmitted,
        prmFeedbackTeamMsg,
        thankYouHeaderMsg
    };

    //Case fields from parent
    @api caseId;
    @api caseNumber;

    viewRecord() {
        // Navigate to Case Detail page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.caseId,
                "objectApiName": "Case",
                "actionName": "view"
            },
        });
        const closemodal = new CustomEvent('closemodal', {});
        this.dispatchEvent(closemodal);
    }

}