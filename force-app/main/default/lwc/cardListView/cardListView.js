/*******************************************************************
Created By          :   Garg / Ashish
Created Date        :   
Desc                :   This is used to Lead and Opportunity data on partner community as card list view

Date            Version             Modified By             Desc
7-August-2019        1              Ashish garg                        
2-April-2020         2              Ritika Jaiswal          P2OB:5611 - Component to capture decline reason when lead is declined by Partner                
***********************************************************************/

import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import labelSharedOn from '@salesforce/label/c.Shared_On_LWC';
import labelSharedBy from '@salesforce/label/c.Shared_By_LWC';
import labelSubmittedBy from '@salesforce/label/c.Submitted_By_LWC';

import getObjectData from '@salesforce/apex/PRMLeadsOprtntyController.getObjectData';
import getApprovedOppData from '@salesforce/apex/PRMLeadsOprtntyController.getApprovedOppData';
import getDeclinedOppData from '@salesforce/apex/PRMLeadsOprtntyController.getDeclinedOppData';
import getAcceptedLeadData from '@salesforce/apex/PRMLeadsOprtntyController.getAcceptedLeadData';
import getDeclinedLeadData from '@salesforce/apex/PRMLeadsOprtntyController.getDeclinedLeadData';

import leadView from './leadView.html';
import oppView from './opportunityView.html';

export default class CardListView extends NavigationMixin(LightningElement) {
    label = {
        labelSharedOn,
        labelSharedBy,
        labelSubmittedBy
    };

    @track record = [];
    @track error;
    @track isLoaded = true;

    @api objectName;
    @api headerLabel;
    @api declinedLead;
    @api approvalId;


    //it will get data from apex controller as per object select by admin
    @wire(getObjectData, { objectName: '$objectName' })
    wiredData({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
        } else if (error) {
            this.record = [];
            this.error = error;
        }
    }

    //this method will run to check if there is not data then show message in cards for no data
    get hasRecord() {
        return (this.record === undefined || this.record.length == 0);
    }

    render() {
        return this.objectName === 'Lead' ? leadView : oppView;
    }

    // Navigate to view Record Page

    recordView(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.dataset.id,
                "actionName": "view"
            }
        });
    }

    handleAccept(event) {
        this.isLoaded = false;
        event.preventDefault();
        const workItemId = event.target.dataset.id;
        getApprovedOppData({ workItemId })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Opportunity Accepted Successfully',
                        variant: 'success'
                    })
                );
                this.record = result;
                this.isLoaded = true;
            })
            .catch(error => {
                this.error = error;
                this.isLoaded = true;
            });
    }

    handleDecline(event) {
        this.isLoaded = false;
        event.preventDefault();
        const workItemId = event.target.dataset.id;
        getDeclinedOppData({ workItemId })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Opportunity Declined Successfully',
                        variant: 'success'
                    })
                );
                this.record = result;
                this.isLoaded = true;
            })
            .catch(error => {
                this.error = error;
                this.isLoaded = true;
            });
    }

    // P2OB:5611 - Handling of acceptance of lead : Apex action call to update ApprovalProcess as Approved
    handleAcceptLead(event) {
        this.isLoaded = false;
        event.preventDefault();
        const workItemId = event.target.dataset.id;
        getAcceptedLeadData({ workItemId })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Lead Accepted Successfully',
                        variant: 'success'
                    })
                );
                this.record = result;
                this.isLoaded = true;
            })
            .catch(error => { 
                //P2OB:5611 - Error handling when a lead-record cannot be updated as 'accepted'               
                this.error = error;
                this.isLoaded = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Applicator Error',
                        message: 'Lead could not be accepted',
                        variant: 'error'
                    })
                );
            });
    }
    
    // P2OB:5611 - Handling of acceptance of lead : Apex action call to call child component 'declineLeadWithReason'
    handleDeclineLead(event) {
        event.preventDefault();
        //P2OB:5611 - Saving the ApprovalProcessrequest-id and lead-record-id
        this.approvalId = event.target.dataset.id; 
        this.declinedLead = event.target.dataset.recordId;
        //P2OB:5611 - Call to method of child-component for capturing the decline reasons
        this.template.querySelector('c-decline-lead-with-reason').openModal();       
    }

    //P2OB:5611 - Handling of event fired from child-component 'declineLeadWithReason' 
    handledeclinedevent(event){
        const workItemId = this.approvalId ;
        var leaddatastr = JSON.stringify(event.detail);
        //P2OB:5611 - Apex action for saving the decline-reasons to lead-record, and updating the approvalProcess
        getDeclinedLeadData({ workItemId : workItemId , leadItemData : leaddatastr})
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Lead Declined Successfully',
                        variant: 'success'
                    })
                );
                this.record = result;
                this.isLoaded = true;
            })
            .catch(error => {
                //P2OB:5611 - Error handling when a lead-record cannot be updated as 'declined'
                this.error = error;
                this.isLoaded = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Applicator Error',
                        message: 'Lead could not be declined',
                        variant: 'error'
                    })
                );
            });
    }

}