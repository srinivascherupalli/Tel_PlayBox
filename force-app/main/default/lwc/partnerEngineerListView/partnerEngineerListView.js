/**
   *  Description of the purpose of the method.
   *  @name PartnerEngineerListView
   *  @description               : This LWC is used to display the Engineering Users
   *  @param                     : Functional Contact Role Record Id.
   *  @return 				 	         : - 
   *  @Jira Story Ref            : EDGE-128108
   *  @createdBy  				       : Purushottama Sahu, Alexandria
**/
import { LightningElement, api, wire, track } from "lwc";
import getPartnerEngineersList from "@salesforce/apex/PartnerAdminRoleDetails.getPartnerEngineers";
import { NavigationMixin } from "lightning/navigation";

const columns = [
    { label: "User ", fieldName: "assignee", type: "text" },
    { label: "PS Subscription ID", fieldName: "subscriptionName", type: "text" },
    { label: "TenancyID", fieldName: "tenancy", type: "text" },
    { label: "Start Date", fieldName: "startDate", type: "text" }
  ];
export default class PartnerEngineerListView extends NavigationMixin(
  LightningElement
) {
  @track data = [];
  @track error;
  @track columns = columns;
  @api recordId;
  @track cssDisplay = "";
  @track tableDisplay = "";
  @track recordPageUrl;
 
  @track activeSections = ["RelatedListofUsers"];
  @track activeSectionsMessage = "";

  @wire(getPartnerEngineersList, { recordId: "$recordId" })
  async wiredContacts({ error, data }) {
    console.log('data',data);
    if (data !== undefined && data != null & data !== '') {
      this.tableDisplay = "";
      this.data = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.data = undefined;
      this.tableDisplay = "hidemodel";
    }else{
      this.data = undefined;
      this.tableDisplay = "hidemodel";
    }
    this.cssDisplay = "hidemodel";
  }
  handleSectionToggle(event) {
    const openSections = event.detail.openSections;
    if (openSections.length === 0) {
      this.activeSectionsMessage = "All sections are closed";
    } else {
      this.activeSectionsMessage = "Open sections: " + openSections.join(", ");
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