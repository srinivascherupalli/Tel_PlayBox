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
import getPartnerRolesList from "@salesforce/apex/PartnerAdminRoleDetails.getPartnerRoles";
import { NavigationMixin } from "lightning/navigation";
import { loadStyle } from 'lightning/platformResourceLoader';
import myResource from '@salesforce/resourceUrl/partnerAdminRoleLWC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TCPortalURL from '@salesforce/label/c.TCPortalURL';

const columnsTCPS_OpsUser = [
  { label: "ACCOUNT NAME", fieldName: "accountId", 
    type: "url",
    tooltip: "accountName",
    //maxColumnWidth: 100,
    typeAttributes: {
    label: { fieldName: "accountName" },
    tooltip: { fieldName: "accountName" },
    target: "_blank",
  },
  cellAttributes: { class: 'urlText' }
},
  {
    label: "FULFILMENT TASK",
    fieldName: "fulfillmentTaskId",
    type: "url",
    tooltip: "fulfillmentTaskName",
    typeAttributes: {
      label: { fieldName: "fulfillmentTaskName" },
      tooltip: { fieldName: "fulfillmentTaskName" },
      target: "_blank",
      
    },
    cellAttributes: { class: 'urlText' }
  },
  { label: "CREATED DATE",initialWidth: 100, fieldName: "startDate", type: "text" },
  {
    label: "TASK STATUS",
    fieldName: "fulfillmentTaskStatus",
    type: "text",
  },
  {
    label: "CURRENT ASSIGNEE",
    fieldName: "FLIassignee",
    type: "text",
  },
  { label: "ASSIGNED DATE",initialWidth: 100, fieldName: "Assigneddate", type: "text" },

  {
    type: "button",
    label: "ACTIONS",
    typeAttributes: {
      name: "add_users",
      title: "Add users",
     // iconName: 'utility:adduser',
      variant:"base",
      label: "Add Users",
      value: { fieldName: "fulfillmentTaskId" }
    },
    cellAttributes: { class: 'buttonText' }
  },
  {
    //fieldName: "viewUsers",
    type: "button",
    //initialWidth: 100,
    typeAttributes: {
     // iconName: 'utility:groups',
      name: "view_users",
      title: "View Users",
      label: "View Users",
      variant:"base"
    },
    cellAttributes: { class: 'buttonText'}
  },

  {
    //fieldName: "viewUsers",
    type: "button",
    //initialWidth: 150,
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
  typeAttributes: {
  label: 'View Details',
  tooltip: { fieldName: "name" },
  target: "_blank",
},
cellAttributes: { class: 'urlText'}
},
];

const columnsTCPS_Eng_User = [
  { label: "ACCOUNT NAME", fieldName: "accountId", 
    type: "url",
    tooltip: "accountName",
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

  },
  {
    label: "CURRENT ASSIGNEE",
    fieldName: "FLIassignee",
    type: "text",
  },
  { label: "ASSIGNED DATE",initialWidth: 100, fieldName: "Assigneddate", type: "text" },

  {

    type: "button",
    label: "ACTIONS",
    typeAttributes: {
      name: "view_users",
      title: "View Users",
      variant:"base",
      //iconName: 'utility:groups',
      label:"View Users"
    },
    cellAttributes: { class: 'buttonText'}
  },
   

  {
    //fieldName: "viewUsers",
    type: "button",
    //initialWidth: 150,
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
    target: "_blank",
  },
  cellAttributes: { class: 'urlText'}
},
];

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
    target: "_blank",
  },
  cellAttributes: { class: 'urlText'}},
];

export default class PartnerAdminRolelistView extends NavigationMixin(
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
    @track buttonDisplay = false;
    //@api showCustomToast = false;
    @track Offer='';
    @track OfferDescription='';
    @track offerLabel='';
    @track showCustomToast=false;

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
 
     
  
    @wire(getPartnerRolesList, { componentType: "$componentType"})
    async wiredFunctionalContactRoles({ error, data }) {
           if (data) { 
      
        console.log('this.componentType'+this.componentType);

        if(this.componentType=='MDM Operations User'){
          this.columns = columnsMDM;
          this.buttonDisplay=false;
          this.Offer='Telstra Mobile Device Management';
          this.OfferDescription='View and manage Professional Services associated with Telstra Mobile Device Management';
          this.offerLabel='Operation User View';
        } // DIGI-19737 B2B-1762 - Offer Name Change start here
       else if(this.componentType == 'Telstra Collaboration Operations User'){
           this.columns = columnsTCPS_OpsUser;
           this.buttonDisplay=true;
           this.Offer='Adaptive Collaboration';
           this.OfferDescription='View and manage Professional Services associated with Adaptive Collaboration';
           this.offerLabel='Operation User View';
        }
       else if(this.componentType == 'Engineering User'){
          this.columns = columnsTCPS_Eng_User;
          this.buttonDisplay=true;
          this.Offer='Adaptive Collaboration';
          this.OfferDescription='View and manage Professional Services associated with Adaptive Collaboration';
          this.offerLabel='Engineering User view';
      } // DIGI-19737 B2B-1762 - Offer Name Change end here
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
      console.log('row'+row.referenceId);   
      console.log('row fulfillmentTaskId'+row.fulfillmentTaskId); 
      console.log('row fulfiRec'+row.fulfiRec);         
      this.selectedFCR=row.referenceId;  
      this.selectedFli=row.fulfiRec; 
      console.log('rowtenancy'+row.tenancy);    
      console.log('this.selectedFCR'+this.selectedFCR);     
      switch (actionName) {
        case "add_users":{          
            if(typeof row.tenancy  === 'undefined')            
            {
              console.log('rowterow.tenancy'+row.tenancy );
              this.dispatchEvent(    
                new ShowToastEvent({
                    title: 'No Tenancy available',
                    message: 'try again soon. If you continue to have problems, please raise a Case.',
                    variant: 'error'
                })
              )
            }
            else{
              this.showaddUsers = true;
            }
            console.log('visible'+visible); 
            //this.showRowDetails(event, row);
          //break;
        }
        case "Reassign_Task":{
          this.showReassignTask=true;
          console.log('showReassignTask'+showReassignTask); 
        }
        case "view_users":
            {
              this.showviewUsers = true;
            console.log('showviewUsers'+showviewUsers); 
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
    this.showaddUsers = false; 
    this.showviewUsers = false;
    this.showReassignTask = false;  
  }
  handle_No_userscase(){
    this.Modelclosefunc();
    console.log('show custom toast');
  

    this.dispatchEvent(              
   new ShowToastEvent({
          title: 'No more Engineering users',
          message: 'Please speak to your Admin if you need to add someone else.',
          variant: 'warning'
      })
    )
    

   

  }

  handle_savefcr(){
    console.log('success toast');
    this.dispatchEvent(              
      new ShowToastEvent({
          title: 'User added successfully',
          message: 'It can take up to 15 minutes for access to be enabled.',
          variant: 'success'
      })
    )
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


  handleerror(){
    console.log('success toast');
    this.dispatchEvent(              
      new ShowToastEvent({
          title: 'Unable to add user',
          message: 'Try again. If you continue to have problems, please raise a Case.',
          variant: 'error'
      })
    )
  }

  handleClick(event) {
    console.log('handleClick');
      this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
            url: TCPortalURL
        }
    });
}


}