/**
   *  Description of the purpose of the method.
   *  @name SiteContact
   *  @description               : This LWC is used to display the Site and Contact details in datatable
   *  @param fulfillmentId       : FulfilmentlineItem Id.
   *  @return 				 	         : - 
   *  @Jira Story Ref            : EDGE-120711
   *  @createdBy  				       : Purushottama Sahu, Orlando
**/
import { LightningElement, api, wire, track } from "lwc";
import getSiteContactList from "@salesforce/apex/SiteContactDetails.getSiteContacts";
import { NavigationMixin } from "lightning/navigation";

const columns = [
  {label : 'Site', fieldName : 'SiteId', type: 'url', typeAttributes : { label: {fieldName : 'SiteName'},target : '_blank'}},
  {label : 'Technical Contact', fieldName : 'ContactId', type: 'url', typeAttributes : { label: {fieldName : 'ContactName'},target : '_blank'}},
  {label : 'Site Contact (After Hours)', fieldName : 'SiteContactAfterHoursId', type: 'url', typeAttributes : { label: {fieldName : 'SiteContactAfterHoursName'},target : '_blank'}},
  {label : 'Site Contact (Business Hours)', fieldName : 'SiteContactBusinessHoursId', type: 'url', typeAttributes : { label: {fieldName : 'SiteContactBusinessHoursName'},target : '_blank'}},
  {label : 'Project Contact', fieldName : 'ProjectContactId', type: 'url', typeAttributes : { label: {fieldName : 'ProjectContactName'},target : '_blank'}}];

export default class SiteContactListView extends NavigationMixin(
  LightningElement
) {
  @track data = [];
  @track error;
  @track columns = columns;
  @api recordId;
  @track cssDisplay = "";
  @track tableDisplay = "";
  @track recordPageUrl;
  @wire(getSiteContactList, { fulfillmentId: "$recordId" })
  async wiredContacts({ error, data }) {
    if (data !== undefined && data != null & data !== '') {
      this.tableDisplay = "";
      this.data = await this.parseJsonData(data);
      console.log('SiteContactListView data: ', JSON.stringify(data));
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
  @track activeSections = ["TaskContacts"];
  @track activeSectionsMessage = "";

  handleSectionToggle(event) {
    const openSections = event.detail.openSections;
    if (openSections.length === 0) {
      this.activeSectionsMessage = "All sections are closed";
    } else {
      this.activeSectionsMessage = "Open sections: " + openSections.join(", ");
    }
  }

  async parseJsonData(jsonData) {
    var parseData = [];
    var outerIndex;
    for (outerIndex in jsonData) {
      var myObject = {};
      for (var key in jsonData[outerIndex]) {
        var val = jsonData[outerIndex][key];
        if (key.indexOf("Id") > -1 && key !== "referenceId") {
          await this.navigateToRecordView(val, "view");
          myObject[key] = this.recordPageUrl;
        } else
        {
          myObject[key] = val;
        }
      }
      parseData.push(myObject);
    }
    return parseData;
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