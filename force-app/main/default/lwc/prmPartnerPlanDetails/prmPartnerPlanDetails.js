/*
Created By : Team Hawaii
Created Date : 06 November 2020
Jira No : P2OB-10459
Description : Component to show partner plan details on TPC and Detail Page
*/

import { LightningElement, api, track, wire} from 'lwc';
import getRowData from '@salesforce/apex/PRMPartnerPlanDetailsContr.getRowData';
import { reduceErrors } from 'c/ldsUtils';
import { updateRecord, getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import linkBaseUrl from '@salesforce/label/c.TPC_and_PRM_Base_URL';
import ID_FIELD from '@salesforce/schema/Partner_Plan__c.Id';
import imageBaseUrl from '@salesforce/label/c.Partner_Plan_Static_Resource_Base_Url';
import UserType_User from '@salesforce/schema/User.UserType';
import Id from '@salesforce/user/Id';
const fields1 = [UserType_User];

export default class PrmPartnerPlanDetails extends LightningElement {

//Data to be shown
@track recordToShow=[];
//Image to be shown
@track imageToShow;
//Link to navigate to for sales activity (Should be attribute?)
@track salesActivityLink;
//Record id
@api recordId;
//API Names of rows to be displayed
@api rowLabels;
//Allow Card view
@api allowCardView;
//Show Sales activity link
@api showSalesLink;
//Table or Card View Section Heading
@api tableHeading;
//Show Editable or View Format of Rich Text
@track showEditableArea = false;
//Icon API Name 
@api iconName;
//Columns to be displayed
columns = [
    { label: 'Quarter', fieldName:'rowLabel', type: 'text'},
    { label: 'Target', fieldName:'rowValue', type: 'currency' }
];
//Show edit icon on fields
@api showEditIcon;
//Button Text
@api linkLabel;
//Sales Link
@api linkURL="n/Sales_Insights";
//Help Text
@api helpText;
//Image link
@api imageLink="partnerplan1.jpeg";
//Id of Login User
userId = Id;
error = '';



connectedCallback(){
    
    this.getPartnerPlanData();
    
}

//wire adapter to get a user's data(UserType field value).
@wire(getRecord, { recordId: '$userId', fields: fields1 })
wireuser({
    error,
    data
}){
    if (error) {
       this.error = error ; 
    } else if (data) {
        let baseUrl = JSON.parse(imageBaseUrl);
        this.imageToShow = baseUrl[data.fields.UserType.value] + this.imageLink;
        let baseUrlForLink = JSON.parse(linkBaseUrl);
        this.salesActivityLink = baseUrlForLink[data.fields.UserType.value] + this.linkURL;
    }
}

//Shoow rich text area in edit mode
showEditArea(){
    this.showEditableArea = true;
}

//Handle Cancel button if edit icon is clicked
handleCancel(){
    this.showEditableArea = false;
}

//Handle Field Updates
handleSave(){
    const fields = {};

    fields[ID_FIELD.fieldApiName] = this.recordId;
    for(let i=0; i<this.recordToShow.length; i++){
        let tempVar = this.recordToShow[i].fieldApi;
        let tempVar1 = "lightning-input-rich-text[data-id="+ tempVar +"]";
        fields[this.recordToShow[i].fieldApi] = this.template.querySelector(tempVar1).value;
        
    }
    const recordInput = { fields };

    //Update the record with new field values.
    updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record updated successfully.',
                            variant: 'success'
                        })
                    );
                    this.showEditableArea = false;
                    this.getPartnerPlanData();
                })
                .catch(error => {
                    this.errors = reduceErrors(error); // code to execute if the promise is rejected
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
}

//Call the server to get Object data
getPartnerPlanData(){
    getRowData({rowLabels : this.rowLabels, recId : this.recordId, isCardView : this.allowCardView }).then(result =>{
        if(result){
            
            for(let i=0; i<result.length;i++){
                if(result[i].fieldApi == 'Financial_Year__c'){
                    if(!this.allowCardView){
                        this.tableHeading = result[i].rowValue + ' ' + this.tableHeading;
                    }
                    result.splice(i,1);
                    break;
                }
                
            }
            
            if(this.rowLabels.includes('Annuity')){
                this.columns = [
                    { label: 'Type', fieldName:'rowLabel', type: 'text', wrapText: true},
                    { label: 'Target', fieldName:'rowValue', type: 'currency' }
                ];
            }
            this.recordToShow = result;
        }
}).catch(error => {
    this.errors = reduceErrors(error); // code to execute if the promise is rejected
});

}

}