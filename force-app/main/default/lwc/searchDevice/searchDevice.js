import { LightningElement, track, api } from 'lwc';
import getSearchedDevice from "@salesforce/apex/searchDeviceController.getSearchedDevice";
import Replacement_Order_In_Progress  from '@salesforce/label/c.Replacement_Order_In_Progress';
const columns = [
  {
    label: "Related Device ID's",
    fieldName: 'linkName2', type: 'url',
    typeAttributes: { label: { fieldName: 'deviceId' }, target: '_blank' }
  },
  {
    label: "Type",
    fieldName: "type",
    type: "text"
  },
  {
    label: "Replaced on",
    fieldName: "replacedOn",
    type: "Date"
  },
  {
    label: "Account Name",
    fieldName: 'linkName', type: 'url',
    typeAttributes: { label: { fieldName: 'accountName' }, target: '_blank' }
  }
];
export default class searchDeviceController extends LightningElement {
  label = {
    Replacement_Order_In_Progress,
};
  @track deviceId = '';
  @track asset;
  @track columns = columns;
  @track currentDevice;
  @track originalDevice;
  @track isReplacedDevicePresent = false;
  @track isDevicePresent = false;
  @track deviceNotFound = false;
  @track noReplaceDeviceFound = false;
  @api   isPartnerUser;
  @track paginationByButton = true;
  @track hasRendered = true;
  @track isLoaded;
  @track orginalDeviceUrl;
  @track currentDeviceUrl;
  @track isReplacementInProgress=false;
  connectedCallback() {
    if (this.isPartnerUser) {
      this.paginationByButton = false;//pagination Ui as per logged in user

    }
  }
  /*----------------------------------------------------------------------
EDGE        -150172
Method      -renderedCallback
Description -Remove css for CRM user
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------*/
  renderedCallback() {
    if (!this.isPartnerUser && this.hasRendered) {
      this.template.querySelector('.clearBtn').classList.remove('clearBtn');
      this.template.querySelector('.searchBtn').classList.remove('searchBtn');
      this.template.querySelector('.box').classList.remove('box');
      this.hasRendered = false;
    }

  }
  /*----------------------------------------------------------------------
  EDGE        -150172
  Method      -onDeviceValueChange
  Description -reset the attribute on deviceId change
  Author      -Dheeraj Bhatt
  -----------------------------------------------------------------------*/
  onDeviceValueChange(event) {
    this.deviceId = event.target.value;
    this.isDevicePresent = false;
    this.isReplacedDevicePresent = false;
    this.deviceNotFound = false;
    this.noReplaceDeviceFound = false;
  }
  /*-----------------------------------------------------------------------------------------------------
EDGE        -150172
Method      -search
Description -Calling apex method on click of search button to search the device in salesforce by deviceId
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
  search() {
    let validValue=this.template.querySelector('.validValue'); 
    if(this.deviceId==''){
      validValue.setCustomValidity("Please enter device id.");
      validValue.reportValidity();
    }
    else {
      this.isLoaded=true;
      this.resetParameter();
      validValue.setCustomValidity('');
      validValue.reportValidity(); 
      var url = '/';
      if (this.isPartnerUser) {
        url = '/partners/';//navigation as per logged in user
      }
      getSearchedDevice({ deviceId: this.deviceId })
        .then(result => {
          var records = result;
          this.asset=[];
          records.forEach(function (record) {
            record.linkName = url + record.accountId;//making account name clickable for redirecting to account
            record.linkName2 = url + record.assetId;
          });
        if (records.length > 0) {
            this.isDevicePresent = true;
            var j=1;
            for (var i = 0; i < records.length; i++) {
              if(j < records.length){
                records[i].replacedOn = records[j].createdDate;
                j++;
              } 
             this.asset.push(records[i]);
              if (records[i].isOriginal) {
                this.originalDevice = records[i].deviceId;// set the original device which customer had purchased
                this.orginalDeviceUrl= url +records[i].assetId;
              }
              else if (!records[i].isOriginal && this.isReplacedDevicePresent == false) {
                this.isReplacedDevicePresent = true;
                if( records[records.length - 1].deviceId == '' || records[records.length - 1].deviceId ==null){
                  this.currentDevice =Replacement_Order_In_Progress;
                  this.isReplacementInProgress=true;
                 }
                 else{
                this.currentDevice = records[records.length - 1].deviceId;//set the latest device which customer is using 
                this.currentDeviceUrl= url + records[records.length - 1].assetId;
                 }
              } 
            }
          if (!this.isReplacedDevicePresent) {
            this.noReplaceDeviceFound = true;//check if any replaced device is present
            this.currentDevice=this.originalDevice;
            this.currentDeviceUrl=this.orginalDeviceUrl;
          }
          if(this.isReplacementInProgress){
            this.asset.splice(records.length - 1,1);
          }
          this.isLoaded=false;
        }
          else {
            this.deviceNotFound = true;
            this.isLoaded=false;// if no device found against deviceId
          }
          
        })
        .catch(() => { 
          this.isLoaded=false;
        });
    }
  }
  /*----------------------------------------------------------------------
  EDGE        -150172
  Method      -clear
  Description -clear all the attribute on click of clear button 
  Author      -Dheeraj Bhatt
  -----------------------------------------------------------------------*/
  clear() {
    this.deviceId = '';
    this.resetParameter();
  }
  resetParameter(){
    this.isDevicePresent = false;
    this.isReplacedDevicePresent = false;
    this.deviceNotFound = false;
    this.noReplaceDeviceFound = false;
    this.orginalDeviceUrl='';
    this.currentDeviceUrl='';
    this.isReplacementInProgress=false;
    this.originalDevice='';
    this.currentDevice='';
    this.asset=[];
  }
  /*----------------------------------------------------------------------
  EDGE        -150172
  Method      -closeModal
  Description -close Modal on click of close icon on Modal
  Author      -Dheeraj Bhatt
  -----------------------------------------------------------------------*/
  closeModal() {
    const closeModal = new CustomEvent('close');
    this.dispatchEvent(closeModal);
  }

}