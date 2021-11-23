/**
   *  Description of the purpose of the method.
   *  @name PortalEngineerListView
   *  @description               : This LWC is used to View Telstra Collaboration Services selected in Enrichment and in current basket to display list of Telstra Collaborations(NGUC services) related to Unified Communication Tenancies in Fulfilment Task detailed view 
   *  @param                     : Fulfilment Task Record Id.
   *  @return 				 	         : - 
   *  @Jira Story Ref            : EDGE-137134
   *  @createdBy  				       : Purushottam Sahu, Alexandria
**/
import { LightningElement, api, wire, track } from "lwc";
import getPartnerEngineersList from "@salesforce/apex/PartnerAdminRoleDetails.getPartnerFCRTenancies";
import { NavigationMixin } from "lightning/navigation";
import {getRecord} from 'lightning/uiRecordApi';
import Offer_FIELD from '@salesforce/schema/FulfillmentLineItem__c.subscription__r.ConfigSpecID__c';
import { loadStyle } from 'lightning/platformResourceLoader';
import myResource from '@salesforce/resourceUrl/relatedListLWCStyle';
const columns = [
    { label: "Adaptive Collaboration Services ", fieldName: "name", type: "text" },
    { label: "Adaptive Collaboration Subscription", fieldName: "subscriptionName", type: "text" },
    { label: "Adaptive Collaboration Tenancy Subscription", fieldName: "tenancySubscriptionName", type: "text" },
    { label: "Tenancy Networks Service ID", fieldName: "tenancy", type: "text" }
  ];
export default class partnerFCRTenancyonFLI extends NavigationMixin(
  LightningElement
) {
  @track data = [];
  @track error;
  @track columns = columns;
  @api recordId;
 
  @track activeSections = ["FCRTenancy"];
  @track activeSectionsMessage = "";
  @track isVisible=false;

  renderedCallback() {
    Promise.all([
        loadStyle(this, myResource)
    ]).catch(error => {
         console.log(error);   
    });
  }

  @wire(getPartnerEngineersList, { recordId: "$recordId" })
  async wiredContacts({ error, data }) {
    if (data !== undefined && data != null && data !== '') {
      this.data = data;
      this.error = undefined;
    } else{
      this.error = error;
      this.data = undefined;
    }
  }
    /*returns the of FLI Offer Name*/
    @wire(getRecord, { recordId: '$recordId', fields: [Offer_FIELD] })
    wiredProperty(value) {
        if(value.data) {
            if(value.data.fields.subscription__r.value.fields.ConfigSpecID__c.value === 'DMCAT_Offer_000936'){
                this.isVisible=true;
            } 
        }
    }

  handleSectionToggle(event) {
    const openSections = event.detail.openSections;
    if (openSections.length === 0) {
      this.activeSectionsMessage = "All sections are closed";
    } else {
      this.activeSectionsMessage = "Open sections: " + openSections.join(", ");
    }
  }
 
}