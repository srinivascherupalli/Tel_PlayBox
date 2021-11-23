import { LightningElement,track,api, wire } from 'lwc';
import myResource from '@salesforce/resourceUrl/relatedListLWCStyle';
import { loadStyle } from 'lightning/platformResourceLoader';
import updatePartner from "@salesforce/apex/searchSubscriptions.updatePartner";
import PARTNER_CODE from '@salesforce/schema/Account.Partner_Code__c';
import {getRecord} from 'lightning/uiRecordApi';
const columns = [
    {label : 'Account Name', fieldName : 'AccountName', type: 'text',sortable: true},
    {label : 'CIDN', fieldName : 'CIDN', type: 'text'},
    {label : 'Subscription Name', fieldName : 'SubscriptionName', type: 'text',sortable: true},
    {label : 'Product Name', fieldName : 'ProductName', type: 'text'},
    {label : 'Offer Name', fieldName : 'offerName', type: 'text'},
    {label : 'Status', fieldName : 'Status', type: 'text'},
    {label : 'Created Date', fieldName : 'CreatedDate', type: 'text'},
    {label : 'Last updated', fieldName : 'LastDate', type: 'text'},
    {label : 'Partner Name', fieldName : 'PartnerName', type: 'text'},
    {label : 'Partner Code', fieldName : 'PartnerCode', type: 'text'}
    ];
export default class ManageCommissionsPartnerResult extends LightningElement {
    @api recordata=[]; 
    @track data = [];
    @track columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    @track accountName;  
    @track accountRecordId;
    @track partnerfilterStr='recordtype.name=\'Partner\'';
    @track disableUpdateBtn = true;
    @track selectedRows=[];
    _selectedRecords=[];
    @track isLoaded = false;
    @track partnerLabel="Change partner to : ";
    @track partnerCode="";
    @track emptytable;

    renderedCallback() {
        Promise.all([
            loadStyle(this, myResource)
        ]).catch(error => {
             console.log(error);   
        });
    }
    connectedCallback(){
        if (this.recordata !== undefined && this.recordata != null && this.recordata !== '' && this.recordata.length >0) {
            this.parseSubscriptionData(this.recordata);
        } else {
            this.error = undefined;
            this.data = undefined;
            this.emptytable=true;
          }
    }
    @wire(getRecord, { recordId: '$accountRecordId', fields: [PARTNER_CODE] })
    wiredProperty(value) {
        if(value.data) {
            this.partnerLabel = "Change partner to : " + value.data.fields.Partner_Code__c.value;
            this.partnerCode=value.data.fields.Partner_Code__c.value;
        }
    }
  parseSubscriptionData(data){
    let subscriptionList = [];
    data.forEach(subscription => {
        let subscriptionRecord = {};
        subscriptionRecord.Id = subscription.Id;
        subscriptionRecord.AccountName = subscription.csord__Account__r.Name;
        subscriptionRecord.CIDN = subscription.csord__Account__r.CIDN__c;
        if(subscription.PartnerAccount__r != null ){
        subscriptionRecord.PartnerName = subscription.PartnerAccount__r.Name;
        subscriptionRecord.PartnerCode = subscription.PartnerAccount__r.Mobile_Code__c;
        }
        subscriptionRecord.SubscriptionName = subscription.Name;
        if(subscription.MarketableOffer__r != null ){
        subscriptionRecord.offerName = subscription.MarketableOffer__r.Name;
        subscriptionRecord.ProductName = subscription.MarketableOffer__r.Product_Family__c;
        }
        subscriptionRecord.Status = subscription.csord__Status__c;
        subscriptionRecord.CreatedDate = subscription.CreatedDate;
        subscriptionRecord.LastDate = subscription.LastModifiedDate;
        subscriptionRecord.csordtelcoa__Subscription_Number__c= subscription.csordtelcoa__Subscription_Number__c;
        subscriptionList.push(subscriptionRecord);
    });
    this.data = subscriptionList;
    this.error = undefined;
  }
  onAccountSelection(event){ 
    this.accountName = event.detail.selectedValue;  
    this.accountRecordId = event.detail.selectedRecordId;
    if(this.selectedRows!=null && this.selectedRows!=undefined && this.selectedRows.length>0 && this.accountRecordId != null && this.accountRecordId !=undefined)
    this.disableUpdateBtn=false;
    else
    {
    this.partnerLabel="Change partner to : "
    this.disableUpdateBtn=true;
    this.partnerCode="";
    }
  }
  getSelectedSubscription(event){
     this.selectedRows = event.detail.selectedRows;
     if(this.selectedRows.length>0 && this.accountRecordId != null && this.accountRecordId !=undefined)
    this.disableUpdateBtn=false;
    else
    this.disableUpdateBtn=true; 
  }
  handleUpdatePartner(){
    this.isLoaded = true;
    this._selectedRecords=[];
    for ( let i = 0; i < this.selectedRows.length; i++ ){             
            if ( !this._selectedRecords.includes(this.selectedRows[i].Id) )
            this._selectedRecords =[...this._selectedRecords,this.selectedRows[i].Id];     
   }
  updatePartner({
    subList : this._selectedRecords,
    accountId  : this.accountRecordId
    }).then(result => {
    this.isLoaded = false;
    if(result != 'Success'){
        this.setToastvalues('Error', result, 'error'); 
    }
    else{  
        this.setToastvalues("Reassignment successfully completed!", "Active solutions have been updated to "+ this.accountName +" "+ this.partnerCode, 'success'); 
        setTimeout(function(){ 
        this.createRefreshEvent();
        }.bind(this), 2000);
    }
})
.catch(error => {
    this.isLoaded = false;
    this.setToastvalues('Error', error.body.message, 'error'); 
    this.error = error.body.message;
})
  }
  setToastvalues(toasttitle, toastmsg, toastvariant) {
    this.toasttitle = toasttitle;
    this.toastmsg = toastmsg;
    this.toastvariant = toastvariant;
    this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
}

  createRefreshEvent(){
    // Creates the event with the data.
    const selectedEvent = new CustomEvent("callrefreshvaluechange");
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
    }
   // Used to sort the 'Age' column
   sortBy(field, reverse, primer) {
    const key = primer
        ? function(x) {
              return primer(x[field]);
          }
        : function(x) {
              return x[field];
          };

    return function(a, b) {
        a = key(a);
        b = key(b);
        return reverse * ((a > b) - (b > a));
    };
    }
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}