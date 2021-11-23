/**
 *  Description of the purpose of the method.
   *  @name PortalEngineerListView
   *  @description               : This LWC is used  to display the Telstra Collaboration and Engineering User Functional Contact Roles
   *  @param fulfillmentId       : ComponentType - Telstra Collaboration Operations User,Engineering User.
   *  @return 				 	         : - 
   *  @Jira Story Ref            : EDGE-128108
   *  @createdBy  				       : Purushottama Sahu, Alexandria -  26/02/2020
 **/
import { LightningElement, api, wire, track } from "lwc";
import getPartnerRolesList from "@salesforce/apex/PartnerAdminRoleDetails.getPartnerEngineerRolesPSMDM";
import { NavigationMixin } from "lightning/navigation";
import { loadStyle } from 'lightning/platformResourceLoader';
import myResource from '@salesforce/resourceUrl/partnerAdminRoleLWC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const columnsMDM = [
  { label: "ACCOUNT NAME", fieldName: "accountId", 
    type: "url",
    tooltip: "accountName",
   // initialWidth: 150,
    typeAttributes: {
    label: { fieldName: "accountName" },
    tooltip: { fieldName: "accountName" },
    target: "_blank",
  },
  cellAttributes: { class: 'urlText'}
  
},
  {
    label: "FULFILMENT TASK",
    fieldName: "fulfillmentTaskId",
    type: "url",
    tooltip: "fulfillmentTaskName",
   // initialWidth: 150,
    typeAttributes: {
      label: { fieldName: "fulfillmentTaskName" },
      tooltip: { fieldName: "fulfillmentTaskName" },
      target: "_blank",      
    },
    cellAttributes: { class: 'urlText'}
  },
  { label: "CREATED DATE",initialWidth: 100, fieldName: "startDate", type: "text" },

  {
    label: "TASK STATUS",
    fieldName: "fulfillmentTaskStatus",
    type: "text",
   // initialWidth: 100,
  },
  {
    label: "CURRENT ASSIGNEE",
    fieldName: "FLIassignee",
    type: "text",
   // initialWidth: 100,
  },
  { label: "ASSIGNED DATE",initialWidth: 100, fieldName: "Assigneddate", type: "text" },

  {
    //fieldName: "viewUsers",
    type: "button",
    //initialWidth: 150,
    label: "ACTIONS",
    typeAttributes: {
      name: "Reassign_Task",
      title: "Reassign",
      variant:"base",
      label:"Reassign",
      disabled: { fieldName: "disableReassign"}
    },
    cellAttributes: { class: 'buttonText'}
  },
  { fieldName: "fulfillmentTaskId", 
  type: "url",
 // initialWidth: 150, 
  typeAttributes: {
  label: 'View Details',
  tooltip: { fieldName: "name" },
 // target: "_blank",
},
cellAttributes: { class: 'urlText'}
},


];

export default class PartnerEngineerRolelisViewPSMDM extends NavigationMixin(
    LightningElement
  ) {
    @track data = [];
    @track columns;//= columns;
    @track error;
    @track cssDisplay = true;
    @track emptytable = false;
    @track tableDisplay = false;
    @api componentType;
    @api OfferName;
    @track SelectedFCR='';
    @track selectedFli=''; 
    @track Offer='';
    @track OfferDescription='';
    @track offerLabel='';
  

    @track showaddUsers = false; 
    @track showviewUsers = false;
    @track showReassignTask = false;

    renderedCallback() {
      Promise.all([
          loadStyle(this, myResource)
      ]).catch(error => {
           // eslint-disable-next-line no-console
           console.log(error);   
      });
  }
 
     
  
    @wire(getPartnerRolesList)
    async wiredFunctionalContactRoles({ error, data }) {
      if (data) { 
        console.log('this.componentType'+this.componentType);
          this.columns = columnsMDM;
          this.Offer='Telstra Mobile Device Management';
          this.OfferDescription='View and manage Professional Services associated with Telstra Mobile Device Management';
          this.offerLabel='Engineering User view';
          this.data = await this.parseJsonData(data);
          this.tableDisplay = true;
          console.log('Data:',data);
        console.log(JSON.stringify(data, null, "\t"));
      } else if (error) {
        console.log("error", error);
        this.error = error;
      }
      if(typeof data === undefined || data === null || data === '' || ( data != null && data.length === 0)){
        this.emptytable = true;
      }
      this.cssDisplay = false;
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
  
    handleRowAction(event) {
      const actionName = event.detail.action.name;
      const row = event.detail.row;
      console.log('actionName'+actionName); 
      this.selectedFCR=row.referenceId;  
      this.selectedFli=row.fulfiRec; 
      switch (actionName) {        
        case "Reassign_Task":{
          this.showReassignTask=true;
        }
        case "view_users":{
              this.showviewUsers = true;
            }
        default:
      }
    }
    showRowDetails(event, row) {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: row.referenceId,
          actionName: "view"
        }
      });
  }

  Modelclosefunc(){
    console.log('Model Close');
    this.showviewUsers = false;
    this.showReassignTask = false;  
  }

  handle_toast_Ownerupdated(){
    console.log('success toast');
    this.dispatchEvent(              
      new ShowToastEvent({
          message: 'User reassigned successfully',
          variant: 'success'
      })
    )
  }

 
}