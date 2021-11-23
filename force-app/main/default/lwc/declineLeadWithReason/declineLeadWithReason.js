/*******************************************************************
Created By          :   Team Hawaii : Ritika Jaiswal
Created Date        :   2-April-2020
Desc                :   This is used to capture decline reason when lead is declined by Partner.Child component embedded in Paremt-Component 'CardListView'
Jira                :   P2OB-5611
Date            Version             Modified By             Desc
2-April-2020         1              Ritika Jaiswal          P2OB:5611 - Component to capture decline reason when lead is declined by Partner                
***********************************************************************/

import { LightningElement, api, track } from 'lwc';

export default class DeclineLeadWithReason extends LightningElement {
    
    @api isdecline = false;
    @api approvalRecord;
    @api leadRecord; 

    @track value = '';
    @track disableArea = true;
    @track disableSave = true;
    @track requiredArea = false;
    @track textAreaInput;

    //P2OB:5611 - List of picklist values shown to Partner user for reason of Decline-action
    get options() {
        return [
            { label: 'Coverage', value: 'Partner Coverage' },
            { label: 'Capability', value: 'Partner Capability' },
            { label: 'Other Reason', value: 'Other' },
        ];
    }

    //P2OB:5611 - Handle change of picklist selected-value 
    handleChange(event) {
        //P2OB:5611 - On selection of picklist, different text-area and decline-button are enabled/disabled
        console.log('picklist changed:',event.detail.value);
        this.value = event.detail.value;
        if(this.value === "Other"){
            console.log('other picklist selected:',event.detail.value);
            this.disableArea = false;
            this.disableSave = true; 
            this.requiredArea = true;               
        }
        else{
            this.disableSave = false;
            this.disableArea = true;
            this.requiredArea = false;            
            this.textAreaInput = "";
            //P2OB:5611 - Clearing the values of input components
            this.template.querySelectorAll('lightning-textarea').forEach(each => {
                each.value = '';
            });
            this.template.querySelectorAll('lightning-combobox').forEach(each => {
                each.value = null;
            });
            
       }
    }

    //P2OB:5611 - Conditionally disabling the text-area and 'Decline' button 
    handleTextArea(event){
        this.textAreaInput = event.detail.value;
        if(this.value === "Other" && this.textAreaInput !== ""){
            this.disableSave = false;
        }else if(this.value === "Other" && this.textAreaInput === ""){
            this.disableSave = true;
        }
    }

    //P2OB:5611 - Method to open the modal window by calling from Parent-component
    @api
    openModal() {
        this.isdecline = true;
    }

    //P2OB:5611 - Close the modal window  on the click of cancel button
    @api
    cancelModal() {        
        this.isdecline = false;
    }
 
    //P2OB:5611 - Method to send the decline-details to Parent-component
    @api
    declineModal() {     
        //P2OB:5611 - Close the modal window   
        this.isdecline = false;
        //P2OB:5611 - Save details entered by User
        const leadDetails = {leadrec: this.leadRecord, selected:this.value, textEntered:this.textAreaInput};
        //P2OB:5611 - Event to send the details to parent-component
        const selectEvent = new CustomEvent('declinedevent', {
            detail: leadDetails
        });
       this.dispatchEvent(selectEvent);
    }
}