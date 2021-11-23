import { LightningElement ,wire,api,track} from "lwc";



import getServiceNum from "@salesforce/apex/NotificationPreferenceCtrl.getServiceNumbers";

import {getRecord} from 'lightning/uiRecordApi';

import Order_Account_ID from '@salesforce/schema/csord__Order__c.csord__Account__c';
import Order_Account_NAME from '@salesforce/schema/csord__Order__c.csord__Account__r.Name';
import Account_NAME from '@salesforce/schema/Account.Name';
import Order_NAME from '@salesforce/schema/csord__Order__c.Name';
import Contact_NAME from '@salesforce/schema/Contact.Name';
import Contact_Account_ID from '@salesforce/schema/Contact.Account.Id';
import Contact_Account_NAME from '@salesforce/schema/Contact.Account.Name';


import { CurrentPageReference } from 'lightning/navigation';



export default class NotificationPreferenceSearch
extends LightningElement {
    @api recordId;
    @api objectName;
    @track accountName;  
    @track accountRecordId;  
    @track orderRecordId;
    @track orderNumber;
    @track contactId;
    @track contactName;
    @track serviceNumber;
    @track type;
    @track pickListVal;
    @track records;
    @track myVar = '';
    @track disableContact;
    @track enableCon = true;
    @track clearVal = false;
    @track fieldreadonly = false;
    @track validate = false;
    @track selectRecordName;
    @track serNum;
    @track searchData;
    @track recordsList;
    @track errorMsg;
    @track message;
    @track searchKey;
    @track orderfilterStr;


    @track resList;

    @track contactfilterStr='Contact_Status__c=\'Active\' AND accountid=\' \'';
    @track isAccReadOnly=false;
    @track isOrderReadOnly=false;



    @wire(CurrentPageReference)
    wiredPageReference(currentPageReference) {
    this.recordId=currentPageReference.state.c__recordId;
    this.objectName=currentPageReference.state.c__objectName;
    this.setFieldsFormatted();
    this.validate = false;
    }

    connectedCallback(){
        this.setFieldsFormatted();
    }
    setFieldsFormatted(){

        var baseurl = window.location.href;
        this.fieldreadonly = true;
        if(this.objectName== 'csord__Order__c')
        {
        this.fieldsFormatted =[Order_NAME,Order_Account_ID,Order_Account_NAME];
        if (baseurl.includes('partners.enterprise.telstra.com.au') || (baseurl.includes('/partners/s'))) { 
        this.isAccReadOnly=true;
        this.isOrderReadOnly=true;
        }
        }
        else if(this.objectName== 'Account')
        {
             this.fieldsFormatted =[Account_NAME];
             if (baseurl.includes('partners.enterprise.telstra.com.au') || (baseurl.includes('/partners/s'))) { 
             this.isAccReadOnly=true;
             }
        }

             else if(this.objectName== 'Contact')
             this.fieldsFormatted =[Contact_NAME,Contact_Account_ID,Contact_Account_NAME];
    }
    @wire(getRecord, { recordId: '$recordId', fields: '$fieldsFormatted' })
    wiredProperty(value) {
        if(value.data) {
            if(this.objectName== 'csord__Order__c')
            {
                this.orderRecordId=value.data.id;
                this.orderNumber= value.data.fields.Name.value;
                this.accountRecordId=value.data.fields.csord__Account__c.value;
                this.accountName=value.data.fields.csord__Account__r.value.fields.Name.value;
            }
        else if(this.objectName== 'Account')
           {
            this.accountRecordId=value.data.id;
            this.accountName=value.data.fields.Name.value;
           } else if(this.objectName== 'Contact')
                {
                    this.accountName = value.data.fields.Account.value.fields.Name.value;  
                    this.accountRecordId =value.data.fields.Account.value.fields.Id.value;
                    this.contactId=value.data.id;
                    this.contactName =value.data.fields.Name.value;
                }
        if(this.accountRecordId != undefined)
        {
        this.orderfilterStr='csord__Account__c=\''+this.accountRecordId+'\'';



        this.contactfilterStr ='Contact_Status__c=\'Active\' AND accountid=\''+this.accountRecordId+'\''; 
        }
        }
    }
    mouse(event){
        this.recordsList = '';
    }



    onAccountSelection(event){ 
        this.accountName = event.detail.selectedValue;  
        this.accountRecordId = event.detail.selectedRecordId;
        this.orderNumber='';
        this.orderRecordId='';
        this.contactId='';
        this.contactName ='';
        if(this.accountRecordId != undefined)
        {
        this.orderfilterStr='csord__Account__c=\''+event.detail.selectedRecordId+'\'';



        this.contactfilterStr ='Contact_Status__c=\'Active\' AND accountid=\''+event.detail.selectedRecordId+'\''; 
        }else{
            this.orderfilterStr=undefined; 
            this.contactfilterStr='Contact_Status__c=\'Active\' AND accountid=\' \'';



            }
        if(this.accountRecordId != undefined || this.accountRecordId != ''){
            this.fieldreadonly = false;
            this.validate = false;
        }  else{
            this.fieldreadonly = true;
        } 
    }
    onOrderSelection(event){ 
        this.orderNumber = event.detail.selectedValue;  
        this.orderRecordId = event.detail.selectedRecordId;
        this.recordId=event.detail.selectedRecordId;
        this.fieldsFormatted =[Order_NAME,Order_Account_ID,Order_Account_NAME];
        this.objectName= 'csord__Order__c';
        if(this.orderRecordId != undefined){
            this.fieldreadonly = false;
            this.validate = false;
        } 
    }
    onContactSelection(event){
        this.contactName = event.detail.selectedValue;  
        this.contactId = event.detail.selectedRecordId; 
    }
    handleSearch(event){
        if(this.pickListVal == undefined){
            this.pickListVal = 'All';
        }
      //  this.serviceNumber = this.template.querySelector('lightning-input').value;
        var inp=this.template.querySelectorAll("lightning-input");

        inp.forEach(function(element){
            if(element.name=="serviceNumber")
                this.serviceNumber=element.value;
        },this);
        console.log(this.serviceNumber+'@@@@@@@@@@@');
        if((this.accountRecordId == undefined || this.accountRecordId == '')&& 
           (this.serviceNumber == undefined || this.serviceNumber == '') && 
           (this.orderRecordId == undefined || this.orderRecordId == '')) {
            this.validate = true;
        }else{
        this.createSearchEvent();
        }
    }
    createSearchEvent(){
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("callsearchvaluechange", {
                            detail: { 
                                    accountId : this.accountRecordId,
                                    contactId : this.contactId,
                                    orderId : this.orderRecordId,
                                    type : this.pickListVal,
                                    serviceNum : this.serviceNumber
                                    }
      });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    changeHandler(event){
        this.pickListVal = event.target.value;
    }
    handleClear(event){

        var baseurl = window.location.href;
        if (baseurl.includes('partners.enterprise.telstra.com.au') || (baseurl.includes('/partners/s'))) { 
       eval("$A.get('e.force:refreshView').fire();")
        }
       else{

    this.accountRecordId=null;
    this.accountName=null;
    this.orderNumber=null;
    this.orderRecordId=null;
    this.contactId=null;
    this.contactName =null;
    this.pickListVal='All';
    this.selectRecordName=null;
    this.serviceNumber = '';
    this.searchKey = null;
    this.recordsList = null; 
    this.orderfilterStr=null; 
    this.fieldreadonly = true;
    this.resList =null;
    this.contactfilterStr='Contact_Status__c=\'Active\' AND accountid=\' \'';
    this.template.querySelector('[data-accid]').value = '';
    this.template.querySelector('[data-type]').value = 'All';
    this.createSearchEvent();
     var divs = this.template.querySelectorAll('c-lwc-lookup');
     [].forEach.call(divs, (e)=>{
         e.clearRecordsList();
       });
      }

    }

    handleKeyChange(event){


        this.searchKey = event.target.value;
        if(this.searchKey != ''){
            this.validate = false;
        }



       if( this.searchKey == undefined || this.searchKey == ''){
           this.serviceNumber = '';
       }
        this.handleService();
    }
    handleServiceChange(event){
        this.searchKey = event.target.value;
        this.handleService();
    }
    mouseout(event){
        setTimeout(() => {  
            this.searchKey = "";  
            this.recordsList = null;
           }, 300);  

    }
    async handleService(){



        getServiceNum ({searchKey : this.searchKey})
        .then(result => {
        if (result.length===0) {  
            this.recordsList = [];  
            this.message = "No Records Found";  
           } else {  
            this.recordsList = result; 
            this.message = "";  
           }  
           this.error = undefined;  




         })  
         .catch((error) => {  
          this.errorMsg = error;  
          this.recordsList = undefined;  
         });
         

         

    }
    onRecordSelection(event){
        this.serviceNumber = event.target.dataset.name; 
        this.searchKey = ""; 
    }



}