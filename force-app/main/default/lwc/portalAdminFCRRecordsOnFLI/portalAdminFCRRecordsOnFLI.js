/**
   *  Description of the purpose of the method.
   *  @name PortalAdminFCRRecords
   *  @description               : This LWC is used to display list of FCR records with Portal Admin records assigned to Fulfillment Line Item.
   *  @param                     : Functional Contact Role Record Id.
   *  @return 				 	         : - 
   *  @Jira Story Ref            : EDGE-129805
   *  @createdBy  				       : Sri Ramya E, Alexandria
**/
import { LightningElement, api, wire, track } from "lwc";
import getPartnerAdmins from "@salesforce/apex/PartnerAdminRoleDetails.getPartnerAdmins";
import { NavigationMixin } from "lightning/navigation";
import { loadStyle } from 'lightning/platformResourceLoader';
import myResource from '@salesforce/resourceUrl/relatedListLWCStyle';
const columns = [ 
    { label: "Operations User", fieldName: "assignee", type: "text" },
    { label: "Tenancy ID", fieldName: "subscriptionName", type: "text" }
  ];
export default class portalAdminFCRRecordsOnFLI extends NavigationMixin(
  LightningElement
) {
  @track data = [];
  @track error;
  @track columns = columns;
  @api recordId;
 
  @track activeSections = ["RelatedListofSitesandContacts"];
  @track activeSectionsMessage = "";

  renderedCallback() {
    Promise.all([
        loadStyle(this, myResource)
    ]).catch(error => {
         console.log(error);   
    });
  }

  @wire(getPartnerAdmins, { recordId: "$recordId" })
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