/**
   *  Description of the purpose of the method.
   *  @name SOWItemDetails
   *  @description               : This LWC is used to display related list of SOW Items.
   *  @param                     : Functional Contact Role Record Id.
   *  @return 				 	         : - 
   *  @Jira Story Ref            : EDGE-129805
   *  @createdBy  				       : Sri Ramya E, Alexandria
**/
import { LightningElement, api, wire, track } from "lwc";
import getSOWItems from "@salesforce/apex/SOWItemDetails.getSOWItems";
import { loadStyle } from 'lightning/platformResourceLoader';
import myResource from '@salesforce/resourceUrl/relatedListLWCStyle';

const columns = [
    { label: "Item ", fieldName: "Name", type: "text" },
    { label: "Description", fieldName: "Description__c", type: "text", wrapText: true},
    { label: "Deliverable", fieldName: "Comment__c", type: "text", wrapText: true}
  ];
export default class sOWItemDetails extends LightningElement  
 {
  @track data = [];
  @track error;
  @track columns = columns;
  @api recordId;
 
  @track activeSections = ["SOW Items"];
  @track activeSectionsMessage = "";

  renderedCallback() {
    Promise.all([
        loadStyle(this, myResource)
    ]).catch(error => {
         console.log(error);   
    });
  }

  @wire(getSOWItems, { recordId: "$recordId" })
  async wiredContacts({ error, data }) {
    if (data !== undefined && data != null && data !== '') {
      this.data = data;
      this.error = undefined;
    } else {
      this.error = error;
      this.data = undefined;
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