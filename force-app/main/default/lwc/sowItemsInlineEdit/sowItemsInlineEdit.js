/**
 *  Description of the purpose of the method.
   *  @name PortalEngineerListView
   *  @description               : This LWC is used  to display the Statement of Work Items inline edit view and save and submit for Approval
   *  @param SOW ID              : Statement of Work ID
   *  @return 				 	 : - 
   *  @Jira Story Ref            : EDGE-136071
   *  @createdBy  				 : Purushottama Sahu, Alexandria -  20/03/2020
 **/
import { LightningElement, api, wire, track } from "lwc";
import getSowItemList from "@salesforce/apex/SOWApprovalRequestService.fetchsows";
import getDeliverables from "@salesforce/apex/SOWApprovalRequestService.getDeliverables";
import submitAndProcessApprovalRequest from "@salesforce/apex/SOWApprovalRequestService.submitAndProcessApprovalRequest";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getRecord,updateRecord} from 'lightning/uiRecordApi';
import Status_FIELD from '@salesforce/schema/SOW__c.Status__c';
import myResource from '@salesforce/resourceUrl/partnerSOWItemsLWC';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class SowItemsInlineEdit extends LightningElement {
    @api recordId; // got from parent component 
    @track error;
    @track errorMsg = [];
    @track data;
    @track selectedRows=[];
    @track selectedRecordId;
    @track showviewUsers = false;
    @track sentforAprroval=false;
    @track isButtonVisible=false;
    @track isButtonDisabled=true;
    @track isLoaded = true;

    renderedCallback() {
        Promise.all([
            loadStyle(this, myResource)
        ]).catch(error => {
             // eslint-disable-next-line no-console
             console.log(error);   
        });        
    }

   /* updateCSSStyle{
       let styl =  document.getElementsByClassName('slds-dl_horizontal myDlClass');
       styl.style = width: 20%;
    }*/
   /*returns the list of SOW Items*/
   @wire(getSowItemList,{ recordId: "$recordId" })
    contact;
    
    
     /*returns the of SOW Status*/
    @wire(getRecord, { recordId: '$recordId', fields: [Status_FIELD] })
    wiredProperty(value) {
        if(value.data) {
            if(value.data.fields.Status__c.value === 'SOW Configuration' || value.data.fields.Status__c.value === 'Rejected'){
                this.isButtonVisible=true;
                this.isButtonDisabled=false;
            }
        }
    }

     /*This method will call when we click save button*/
    handleSave(event) {
        this.isLoaded = false;
        this.errorMsg = [];
        const recordForms = this.template.querySelectorAll(
            'lightning-record-edit-form'
        );

        if (recordForms) {
            recordForms.forEach(field => {
                field.submit();
        });
     }     
     this.showMessages();
    }
    showMessages() {
        try{
        /* Delaying the toast message for 1 sec so that we will get the actual error count from server */
        new Promise((resolve,reject)=> {
            setTimeout(() => {
                let start = new Date();
                let y = 0;
                while(new Date()-start<1500) {
                    y = y + 1;
                }
                resolve(y);
            }, 1500);
        }).then(
            ()=>{
                if(this.errorMsg.length > 0){
                    const event1 = new ShowToastEvent({
                        "title": "Error",
                        "message": this.errorMsg.toString(),
                        "variant":"error"
                    });
                    this.dispatchEvent(event1);
                    console.log('spinner at error toast');
                    this.isLoaded = true;
                    }else{
                            if(this.sentforAprroval===true){
                                submitAndProcessApprovalRequest({sowId: this.recordId})
                                .then(result => {
                                                this.isLoaded = true;
                                                if(result.Result === 'Success'){
                                                    this.isButtonVisible=false;
                                                    this.isButtonDisabled=true;                                                    
                                                }
                                                const event1 = new ShowToastEvent({
                                                                                    "title": result.Result,
                                                                                    "message": result.Reason,
                                                                                    "variant":result.Result
                                                                                 });
                                                this.dispatchEvent(event1);
                                                })
                        this.sentforAprroval=false;
                        console.log('beforeRefresh');
                        setTimeout(function(){ eval("$A.get('e.force:refreshView').fire();"); }, 3000);                        
                        //window.location.reload();
                        //eval("$A.get('e.force:refreshView').fire();");
                    }else{
                        console.log('spinner at save success toast');
                        this.isLoaded = true;
                        const event1 = new ShowToastEvent({
                            "title": "Success",
                            "message": "Services for inclusion saved successfully",
                            "variant":"success"
                        });
                       this.dispatchEvent(event1);
                    }
                }
            }
        );
    }//try
    catch(error){
        console.log('showMessagesErrorMsg::'+error)
    }
    }

    /*This method will call when we click save and submit button*/
    handleSaveAndSubmit(event){
        try{
            this.isLoaded = false;
            this.sentforAprroval=true;
            this.handleSave(event);
        }
        catch(error){
            console.log('handleSaveAndSubmitErrorMsg::'+error)
        }        
    }

  /*This method will call when we submit record edit form button in handlesave() -Success Case*/
    handleSuccess(event){
        const payload = event.detail;
    }

/*This method will call when we submit record edit form button in handlesave() - Error Case*/
    handleError(event){
        const payload = event.detail.detail;
        if(this.errorMsg != null && this.errorMsg.length === 0)
        {
        this.errorMsg=[payload];
        }
        else
        {
        if(this.errorMsg.indexOf(payload) === -1){
            this.errorMsg.push(payload);
            }
        }
    }
 
    handleLoad(event){
    }
       
/*This method will call when we click the handle Deliverables*/
    onfocus(event){
        this.isLoaded = false;
        this.selectedRecordId = event.target.accessKey;
        /* Returns the list of Deliverables related to clauses */
        getDeliverables({recordId: event.target.accessKey})
        .then(result => {
        this.data=result;
        })
        this.showviewUsers = true;
        this.isLoaded = true;
    }
  
    /* This method for close the  Deliverables Pop up Button*/
    closemodelPopup(){
    this.showviewUsers = false;
    }
   
    /*This method will call when we select the Deliverables from Pop up and update the SOW ITEMS Comments*/
    getSelectedName(event) {
        this.isLoaded = false;
        const recordForms = this.template.querySelectorAll(
            'lightning-record-edit-form'
        );
        let comment=event.currentTarget.id;
        this.showviewUsers = false;
        let record = {
            fields: {
                Id: this.selectedRecordId,
                Comment__c: comment.slice(0, comment.lastIndexOf("-"))
            },
        };
        if (recordForms) {
            recordForms.forEach(field => {
                if(field.recordId == this.selectedRecordId){
                field.submit();
                }
        });
        }
        /*update the SOW ITEMS Comments*/
        updateRecord(record)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Deliverables saved successfully',
                    variant: 'success',
                }),
            );
                this.isLoaded = true;
                console.log('this.selectedRecordId: ', this.selectedRecordId);
            if (recordForms) {
                recordForms.forEach(field => {
                    if(field.recordId != this.selectedRecordId){
                    field.submit();
                    }
            });
         }
            eval("$A.get('e.force:refreshView').fire();");
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error on data save',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            this.isLoaded = true;
        });
    }
}