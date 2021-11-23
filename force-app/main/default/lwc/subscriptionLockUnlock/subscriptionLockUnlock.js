import { LightningElement, api, track } from "lwc";
import getSubscriptions from "@salesforce/apex/SubscriptionLockUnlockController.getSubscriptions";
import submitSubscriptions from "@salesforce/apex/SubscriptionLockUnlockController.submitSubscriptions";
import No_Subscriptions_For_Lock_UnlocK from '@salesforce/label/c.No_Subscriptions_For_Lock_UnlocK';
const columns = [
  {
    label: "Subscription Name",
    fieldName: 'linkName', type: 'url', 
    typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}
  },
  {
    label: "Subscription Number",
    fieldName: "csordtelcoa__Subscription_Number__c",
    type: "text"
  },
  {
    label: "Status",
    fieldName: "csord__Status__c",
    type: "text"
  },
  {
    label: "Created Date",
    fieldName: "CreatedDate",
    type: "date"
  }
];
export default class SubscriptionLockUnlockController extends LightningElement {
    label = {
        No_Subscriptions_For_Lock_UnlocK
    };
  @api accountId;
  @api status;
  @track columns = columns;
  @track error;
  @track openModal = false
  @track disableNextButton = true;
  @track isDisableSubmitButton = true;
  @track selectedSubscriptions;
  @track selectedSubmittedSubscriptions;
  @track subscriptionList={};
  @track showMessageWhenNoSubscriptionFound;
  @track selectedRowsCount=0;
  @track subscriptionFilterValue;
  @track data;
 /*Fetch subscription list on load of component */ 
connectedCallback(){
      this.getSubscriptionList();
   }
/**********************************************************************************************************
 EDGE       -140733
Method      -getSubscriptionList
Description -get subscription list as per Lock/Unlock subscription functionlity.
Author      -Dheeraj Bhatt
************************************************************************************************************/
getSubscriptionList(){
    getSubscriptions({ accountId: this.accountId, status: this.status })
    .then(result => {
      var records =result;
      records.forEach(function(record){
          record.linkName = '/'+record.Id;
      });
        this.subscriptionList = records;
        this.showMessageWhenNoSubscriptionFound=false;
        this.data=result;
        if(this.subscriptionList.length == 0){
            this.showMessageWhenNoSubscriptionFound=true;
        } 
       })
      .catch(error => {});
  }
/*Select subscription for lock/unlock ans enable/disable next button  */
onRowselectionEvent(event) {
    const selectedRows = event.detail.selectedRows;
    this.selectedSubscriptions = selectedRows;
    if (this.selectedSubscriptions.length > 0) {
      this.disableNextButton = false;
      this.selectedRowsCount=this.selectedSubscriptions.length;
    } else {
      this.disableNextButton = true;
      this.selectedRowsCount=0;
    }
  }
/*Navigate to account on click of back button */
navigateBackToAccount() {
  var url=window.location.origin+'/'+this.accountId;
  window.open(url,'_self');
  }
/*Open model popup on click of next button*/
  next(event) {
    this.openModal = true;
  }
/*Close popup on click on close icon  */
  closeModal() {
    this.openModal = false;
    this.isDisableSubmitButton = true;
  }
/*Confirm subscription before submitting for Lock/Unlock  */
  onRowselectionEventOnPopUpScreen(event) {
    const selectedRows = event.detail.selectedRows;
    this.selectedSubmittedSubscriptions = selectedRows;
    if (this.selectedSubmittedSubscriptions.length > 0) {
      this.isDisableSubmitButton = false;
    } else {
      this.isDisableSubmitButton = true;
    }
  }
/**************************************************************************************************************
EDGE        -140733
Method      -submit
Description -Change subscription status to Active or  Pending Port Out on selection of Lock/Unlock Subscription
Author      -Dheeraj Bhatt
***************************************************************************************************************/
submit() {
    submitSubscriptions({
      subscriptionList: this.selectedSubmittedSubscriptions,
      status: this.status
    })
      .then(() => {
        this.openModal = false;
        this.isDisableSubmitButton=true;
        this.subscriptionList=[];
        this.getSubscriptionList();
      })
      .catch(error => {});
  }
/*Refesh subscriptrionlist on change of Lock/Unlock option on Port out action type */
  @api refreshSubscriptionList() {
  this.subscriptionList=[];
  this.getSubscriptionList();
}
/*Serach Subsription on datatable as per serach keyword */
onSubscriptionFilterValueChange(evt){
  this.queryTerm = evt.target.value;
  var data = this.data;
  var term = evt.target.value;
  var results = data;
  var regex;
  regex = new RegExp(term, "i");
 results = data.filter(row => regex.test(row.Name)  || regex.test(row.csordtelcoa__Subscription_Number__c) 
                        || regex.test(row.csord__Status__c) || regex.test(row.createdDate));

this.subscriptionList=results;
if (this.subscriptionList.length == 0) {
  this.showMessageWhenNoSubscriptionFound=true;
}
if (this.subscriptionList.length != 0) {
  this.showMessageWhenNoSubscriptionFound=false;
}
}
  
}