/**
   *  Description of the purpose of the method.
   *  @name partnerDetails
   *  @description               : This LWC is used to display the partner details on Mobility Managed Services Subscription page
   *  @param subscriptionId      : Subscription Id.
   *  @return 				 	 : - 
   *  @Jira Story Ref            : EDGE-125950
   *  @createdBy  				 : Sri Ramya, Orlando
**/

import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
//import { getRecord } from 'lightning/uiRecordApi';
//import { getRecord,getFieldValue  } from 'lightning/uiRecordApi';
//import PARTNER_ACCOUNT from '@salesforce/schema/csord__Subscription__c.csord__Order__r.csordtelcoa__Opportunity__r.PartnerAccount.Name';
//import PARTNER_USER from '@salesforce/schema/csord__Subscription__c.csord__Order__r.csordtelcoa__Opportunity__r.Owner.Name';
import getPartnerDetails from "@salesforce/apex/AccountSubscriptionDetails.getPartnerDetails";
//import { NavigationMixin } from "lightning/navigation";
/* const FIELDS = [
     PARTNER_ACCOUNT,
     PARTNER_USER
];
 */

/*
export default class PartnerDetails extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    csord__Subscription__c;

    get partnerAccount(){
        return getFieldValue(this.csord__Subscription__c.data, PARTNER_ACCOUNT);
    }
    get partnerUser(){
        return getFieldValue(this.csord__Subscription__c.data, PARTNER_USER);
    }

    navigateToRecordView(Id, Action) {
        return this[NavigationMixin.GenerateUrl]({
          type: "standard__recordPage",
          attributes: {
            recordId: '$recordId',
            actionName: Action
          }
        }).then(url => {
          this.recordPageUrl = url;
        });
      }
} */

export default class partnerDetails extends NavigationMixin(
  LightningElement
) {
 @api recordId;
 @track PartnerName = "";
 @track OwnerName = "";
 @track PartnerURL = "";
 @track OwnerURL = "";
 @track recordPageUrl;
 @track show = false;
//   @wire(getPartnerDetails, { subscriptionId: "$recordId", childRelationships: "csord__Subscription__c.csord__Order__c" })
//  csord__Subscription__c;
 @wire(getPartnerDetails, { subscriptionId: "$recordId"})
  async wiredContacts({ error, data }) {
  if (data !== undefined && data != null & data !== '') {
    var serializeObj = JSON.parse(data);
    if(serializeObj.partnerAccountId !== undefined &&  serializeObj.partnerAccountId != null & serializeObj.partnerAccountId !== ''){
      this.show = true;
      await this.navigateToRecordView(serializeObj.partnerAccountId, "view");
      this.PartnerURL = this.recordPageUrl;
      this.PartnerName =  serializeObj.partnerAccountName;
      await this.navigateToRecordView(serializeObj.opportunityOwnerId, "view");
      this.OwnerURL = this.recordPageUrl;
      this.OwnerName =  serializeObj.opportunityOwnerName;
    }
  }
 }
 navigateToRecordView(Id, Action) {
  return this[NavigationMixin.GenerateUrl]({
    type: "standard__recordPage",
    attributes: {
      recordId: Id,
      actionName: Action
    }
  }).then(url => {
    this.recordPageUrl = url;
  });
}
}