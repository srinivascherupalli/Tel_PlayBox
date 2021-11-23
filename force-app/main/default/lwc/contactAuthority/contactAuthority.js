/**********************************************************************************************************
Sprint        	- SFO Sprint: 20.16 - P2OB-10453, 21.02 - P2OB-12086.
Component   	- contactAuthority
Descriptionc	- Displays all the permissions which drives Authority of Contact. 
Author      	- Amar Chakka. 


Last Modified      : 
No.       Developer Name        Date            Story Description 
1       Chhaveel Thakur         09/03/2021      21.05 - P2OB-13440 & P2OB-13696 - Reorder the Permissions and Add few more fields
2       Chhaveel Thakur         09/03/2021      21.06 - P2OB-14144 & P2OB-14131 - Reorder the Permissions and Add few more fields
3       Chhaveel Thakur         09/03/2021      21.11 - P2OB-4057  - Added error modal popup 
4       Sri                     04/10/2021      21.14 - P2OB-4062  - Added Invoice_notifications__c field under billing 

************************************************************************************************************/
import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import permissionSaveSuccessMsg from '@salesforce/label/c.contactAuthoritySuccessMsg';
import createIncidentsHT from '@salesforce/label/c.Create_IncidentsHT';
import createRequestsHT from '@salesforce/label/c.Create_RequestsHT';
import orderTrackingHT from '@salesforce/label/c.Order_TrackingHT';
import requestsTrackingHT from '@salesforce/label/c.Requests_TrackingHT';
import monitorNetworkServicesHT from '@salesforce/label/c.Monitor_network_and_servicesHT';
import monitorMobileDataUsageHT from '@salesforce/label/c.Monitor_mobile_data_usageHT';
import telstraConnectStoreHT from '@salesforce/label/c.Telstra_Connect_Store_HT';
import billingHT from '@salesforce/label/c.BillingHT';
import downgradeText_HT from '@salesforce/label/c.downgradeText_HT';
import UpgradeText_HT from '@salesforce/label/c.UpgradeText_HT';
import userManagementHT from '@salesforce/label/c.User_ManagementHT';

import { getPicklistValues } from 'lightning/uiObjectInfoApi'; //to get all the picklist values for the mentioend field 
import { getObjectInfo } from 'lightning/uiObjectInfoApi'; //to get the object info like recordtype..
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import Invoice_notifications from '@salesforce/schema/Contact.Invoice_notifications__c';

const fieldsConAuthority = [
    'Contact.Report_Service_Incidents__c',
    'Contact.Create_Requests__c',
    'Contact.Order_Tracking__c',
    'Contact.Requests_Tracking__c',
    'Contact.Monitor_Network_and_Services__c',
    'Contact.Monitor_Mobile_Data_Usage__c',
    'Contact.Order_Services__c',
    'Contact.Raise_Billing_Disputes__c',
    'Contact.Authorised_Billing_Accounts__c',
    'Contact.Telstra_Connect_Admin__c',
    'Contact.Special_Requirements__c',
    'Contact.Sales_Contact_Status__c',
    'Contact.Telstra_Connect_Opt_Out__c',
    'Contact.Invoice_notifications__c',
    'Contact.RecordTypeId',
    
];

export default class ContactAuthority extends NavigationMixin(LightningElement) {
    debugger;
    //To refer Custom Label in Component Template. 
    label = {
        permissionSaveSuccessMsg,
        createIncidentsHT,
        createRequestsHT,
        orderTrackingHT,
        requestsTrackingHT,
        monitorNetworkServicesHT,
        monitorMobileDataUsageHT,
        telstraConnectStoreHT,
        billingHT,
        userManagementHT,
        UpgradeText_HT,
        downgradeText_HT
    };

    @api recordId;
    @track record;
    @track error;
    @api createIncidentL = 'Services Requests/Changes';
    @api createRequestL = 'Incidents';
    @api orderTrackingL = 'Orders';
    @api requestsTrackingL = 'View other services';
    @api monitorNetworkServicesL = 'Monitoring internet and networks servers';
    @api monitorMobileDataUsageL = 'Mobility services';
    @api telstraConnectStoreL = 'View and order product and service Telstra Connect store';
    @api billingL = 'View and download invoices';
    @api userManagementL = 'Create and edit users';
    @api createIncidentLM = 'Services Requests/Changes';
    @api createRequestLM = 'Incidents';
    @api orderTrackingLM = 'Orders';
    @api requestsTrackingLM = 'View other services';
    @api monitorNetworkServicesLM = 'Monitoring internet and networks servers';
    @api monitorMobileDataUsageLM = 'Mobility services';
    @api telstraConnectStoreLM = 'View and order product and service Telstra Connect store';
    @api billingLM = 'View and download invoices';
    @api userManagementLM = 'Create and edit users';
    @api specialRequirementsL = 'Special Requirements';
    @api telstraConnectOptOutL = 'Telstra Connect - Opt Out';
    @track contactAuthority;  // variable to store Contact record with all the fields mentioned in fieldsConAuthority
    @track CreateIncidentsOnL; // Variable to store Create Incident value on Load.
    @track CreaterequestsOnL; // Variable to store Create Request value on Load.
    @track orderTrackingOnL; // Variable to store Order Tracking value on Load.
    @track requestTrackingOnL; // Variable to store Request Tracking value on Load.
    @track mntNtwSrvcsOnL; // Variable to store Monitor Network and Services value on Load.
    @track mntMobDataUsgOnL; // Variable to store Monitor Mobile Data Usage value on Load.
    @track orderServicesOnL; // Variable to store Order Services value on Load.
    @track raiseBillingDisputeOnL; // Variable to store Billing value on Load.
    @track telstraConnectAdminOnL; // Variable to store Telstra Connect Admin value on Load.
    @track onloadtelstraConnectAdminVal; // Variable to stor the onload value of Telstra Connect Admin field
    @track specialRqmntsOnL; // Variable to store Special Requirements value on Load.
    @track isLoaded = false;  // To Control Spinner
    @track areDetailsVisible = false; // Track Toggle Changes. 
    @track areDetailsVisible = false; // Track Toggle Changes. 

    //START:Created as a part of story P2OB-13440 & P2OB-13696
    @track digitalEligibilityOnL; // Variable to store the digital eligibility value on load
    @track telstraConnectOptOutOnL; // Variable to store the telstra Connect opt out value on load
    @track toogleFieldValueCI;  // To Capture Toggle Change
    @track toogleFieldValueUM; // To Capture Toggle Change
    @track toogleFieldValueOT; // To Capture Toggle Change
    @track toogleFieldValueRq; // To Capture Toggle Change
    @track toogleFieldValueMNS; // To Capture Toggle Change
    @track toogleFieldValueMMDU; // To Capture Toggle Change
    @track toogleFieldValueTCS; // To Capture Toggle Change
    @track toogleFieldValueB; // To Capture Toggle Change
    @track toogleFieldValueCR; // To Capture Toggle Change
    @track showFooter = false;  // To Control Footer of the Template. 
    @track openModalNow = false; // to show the Modal popup
    @track openUpgradeModal = false; // To show the upgrade Modal Popup
    @track invNotifications ; // To show the downgrade Modal Popup
    @track defaultoptions ; // To show the downgrade Modal Popup
    @track selinvNotifications =[] ; // To show the downgrade Modal Popup

    /*eslint-disable no-console */


    @track showErrorMsg = false;  // To show Error Message
    @api errorMsgVal;  // To save the error message val
    @track conObjInfo; // To Capture Invoice_notifications__c field all picklistvalues
    @track Invoice_notificationsValues; // To Capture Invoice_notifications__c field all picklistvalues
    @track currentRecordTypeId; // To Capture Invoice_notifications__c field all picklistvalues
    @track optionsInv;
    @track conDefaaultRT;

    //Below will be used for navigation
    @wire(CurrentPageReference) pageRef;

    //Method which retrives Field Values on Load. 
    @wire(getRecord, { recordId: '$recordId', fields: fieldsConAuthority })
    wiredProperty({ error, data }) {
        if (error) {
            this.error = error;
            console.log('Error Onload' + this.error);
        } else if (data) {
            this.contactAuthority = data;
            this.toogleFieldValueCI = this.contactAuthority.fields.Report_Service_Incidents__c.value;
            this.toogleFieldValueCR = this.contactAuthority.fields.Create_Requests__c.value;
            this.toogleFieldValueOT = this.contactAuthority.fields.Order_Tracking__c.value;
            this.toogleFieldValueRq = this.contactAuthority.fields.Requests_Tracking__c.value;
            this.toogleFieldValueMNS = this.contactAuthority.fields.Monitor_Network_and_Services__c.value;
            this.toogleFieldValueMMDU = this.contactAuthority.fields.Monitor_Mobile_Data_Usage__c.value;
            this.toogleFieldValueTCS = this.contactAuthority.fields.Order_Services__c.value;
            this.toogleFieldValueB = this.contactAuthority.fields.Raise_Billing_Disputes__c.value;
            this.toogleFieldValueUM = this.contactAuthority.fields.Telstra_Connect_Admin__c.value;
            this.onloadtelstraConnectAdminVal = this.contactAuthority.fields.Telstra_Connect_Admin__c.value;
            this.specialRqmntsOnL = this.contactAuthority.fields.Special_Requirements__c.value;
            this.telstraConnectOptOutOnL = this.contactAuthority.fields.Telstra_Connect_Opt_Out__c.value;
            this.digitalEligibilityOnL = this.contactAuthority.fields.Sales_Contact_Status__c.value;
            this.invNotifications = this.contactAuthority.fields.Invoice_notifications__c.value;
            this.currentRecordTypeId = this.contactAuthority.fields.RecordTypeId.value;
            if(this.invNotifications){
                this.selinvNotifications = this.invNotifications.split(';');
                this.defaultoptions = this.selinvNotifications ;
            }
            
        }
    }

    //Handle On Change Event    
    handleChange(event) {
        this.areDetailsVisible = event.target.checked;
    }
    // Handle Onload
    handleOnLoad(event) {
        var record = event.detail.records;
        var fields = record[this.recordId].fields;
        const contactName = fields.LastName.value;
        this.isLoaded = false;
    }

    //Handle All Toggle Changes. 
    handleToggleChange(event) {
        this.toogleFieldValueCI = event.target.checked;
        this.showFooter = true;
    }
    handleToggleChangeCreateRequest(event) {
        this.toogleFieldValueCR = event.target.checked;
        //SFO, Sprint 21.02. P2OB-12086.
        // If Create Request is Checked Then Request Tracking should be checked. 
        if (this.toogleFieldValueCR) {
            this.template.querySelector('[data-id="toggleFieldRT"]').checked = true;
            this.toogleFieldValueRq = true;
        }
        this.showFooter = true;

    }
    handleToggleChangeTelstraConnectOptOut(event) {
        this.toggleFieldValueTCOO = event.target.checked;
        this.showFooter = true;
    }
    handleToggleChangeOrderTracking(event) {
        this.toogleFieldValueOT = event.target.checked;
        this.showFooter = true;
    }
    handleToggleChangeRequestsTracking(event) {
        this.toogleFieldValueRq = event.target.checked;

        //SFO, Sprint 21.02. P2OB-12086.
        // If RequestTracking is Checked Then Create Request should be checked else if Request Tracking is unchecked then Create Request should be unchecked. 

        /*if(this.toogleFieldValueRq){
            this.template.querySelector('[data-id="toggleFieldCR"]').checked = true;
            this.toogleFieldValueCR = true;
        }*/
        if (!this.toogleFieldValueRq) {
            this.toogleFieldValueCR = false;
        }

        this.showFooter = true;
    }
    handleToggleChangeMntNetwrkSrvs(event) {
        this.toogleFieldValueMNS = event.target.checked;
        this.showFooter = true;
    }
    handleToggleChangeMntMobileDataUsage(event) {
        this.toogleFieldValueMMDU = event.target.checked;
        this.showFooter = true;
    }
    handleToggleChangeTelstraConnectStore(event) {
        this.toogleFieldValueTCS = event.target.checked;
        this.showFooter = true;
    }
    handleToggleChangeBilling(event) {
        this.toogleFieldValueB = event.target.checked;
        this.showFooter = true;
        this.debugger;
        if(this.toogleFieldValueB && ! this.selinvNotifications.includes('Invoice arrival notification')){
            this.selinvNotifications.push('Invoice arrival notification');
            this.defaultoptions = this.selinvNotifications;
        }
        else if(! this.toogleFieldValueB && this.selinvNotifications.includes('Invoice arrival notification')){
            this.selinvNotifications = this.selinvNotifications.filter(function removeInvArvNotf(pickListVal){
                if(pickListVal != 'Invoice arrival notification')
                {
                    return pickListVal;
                }
            })
            this.defaultoptions = this.selinvNotifications;
        }
        
    }
    handleToggleChangeUserManagement(event) {
        this.toogleFieldValueUM = event.target.checked;
        this.showFooter = true;
    }
    handleToggleChangeSpecialRequirement(event) {
        this.toogleFieldValueSReq = event.target.value;
        this.showFooter = true;
    }

    @wire(getPicklistValues, {
        recordTypeId: '$currentRecordTypeId',
        fieldApiName: Invoice_notifications
      })
      Invoice_notificationsValues;
  
      get options() {
          return this.Invoice_notificationsValues.data.values;
      }
      /*
      get defaultoptions(){
          return this.selinvNotifications;
      }
      */
  
      handleinvoicenotificationsChange(e) {
          this.selinvNotifications = e.detail.value;
          this.showFooter = true;
      }
  
    //START:Created as a part of story P2OB-13440 & P2OB-13696
    handleModalSubmit(event) {
        this.openModalNow = false;
        this.openDowngradeModal = false;
        this.openUpgradeModal = false;
        this.isLoaded = true;
        event.preventDefault();
        const fields = event.detail.fields;

        if (this.toogleFieldValueUM == true && this.onloadtelstraConnectAdminVal == false) {
            if (this.toogleFieldValueCI == false || this.toogleFieldValueCR == false || this.toogleFieldValueOT == false || this.toogleFieldValueMNS == false || this.toogleFieldValueMMDU == false || this.toogleFieldValueRq == false || this.toogleFieldValueTCS == false || this.toogleFieldValueB == false) {
                fields.Report_Service_Incidents__c = this.toogleFieldValueUM;
                fields.Create_Requests__c = this.toogleFieldValueUM;
                fields.Order_Tracking__c = this.toogleFieldValueUM;
                fields.Requests_Tracking__c = this.toogleFieldValueUM;
                fields.Monitor_Network_and_Services__c = this.toogleFieldValueUM;
                fields.Monitor_Mobile_Data_Usage__c = this.toogleFieldValueUM;
                fields.Order_Services__c = this.toogleFieldValueUM;
                fields.Raise_Billing_Disputes__c = this.toogleFieldValueUM;
                fields.Telstra_Connect_Admin__c = this.toogleFieldValueUM;
                fields.Special_Requirements__c = this.toogleFieldValueSReq;
                fields.Telstra_Connect_Opt_Out__c = this.toggleFieldValueTCOO;
                let selval = '';
                for(const selinv of this.selinvNotifications){
                    selval += selinv+ ';';
                }
                selval = selval.substr(0, selval.length-1);
                fields.Invoice_notifications__c = selval;

            }
        }

        if (this.onloadtelstraConnectAdminVal == true && this.toogleFieldValueUM == true) {
            if (this.toogleFieldValueCI == false || this.toogleFieldValueCR == false || this.toogleFieldValueOT == false || this.toogleFieldValueMNS == false || this.toogleFieldValueMMDU == false || this.toogleFieldValueRq == false || this.toogleFieldValueTCS == false || this.toogleFieldValueB == false) {
                fields.Report_Service_Incidents__c = this.toogleFieldValueCI;
                fields.Create_Requests__c = this.toogleFieldValueCR;
                fields.Order_Tracking__c = this.toogleFieldValueOT;
                fields.Requests_Tracking__c = this.toogleFieldValueRq;
                fields.Monitor_Network_and_Services__c = this.toogleFieldValueMNS;
                fields.Monitor_Mobile_Data_Usage__c = this.toogleFieldValueMMDU;
                fields.Order_Services__c = this.toogleFieldValueTCS;
                fields.Raise_Billing_Disputes__c = this.toogleFieldValueB;
                fields.Telstra_Connect_Admin__c = false;
                fields.Special_Requirements__c = this.toogleFieldValueSReq;
                fields.Telstra_Connect_Opt_Out__c = this.toggleFieldValueTCOO;
                let selval = '';
                for(const selinv of this.selinvNotifications){
                    selval += selinv+ ';';
                }
                selval = selval.substr(0, selval.length-1);
                fields.Invoice_notifications__c = selval;
            }
        }
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        eval("$A.get('e.force:refreshView').fire();");
    }
    //END:Created as a part of story P2OB-13440 & P2OB-13696

    handleSubmit(event) {
        if (this.toogleFieldValueUM == true && this.onloadtelstraConnectAdminVal == false) {
            if (this.toogleFieldValueCI == false || this.toogleFieldValueCR == false || this.toogleFieldValueOT == false || this.toogleFieldValueMNS == false || this.toogleFieldValueMMDU == false || this.toogleFieldValueRq == false || this.toogleFieldValueTCS == false || this.toogleFieldValueB == false) {
                event.preventDefault();
                this.openModalNow = true;
                this.openUpgradeModal = true;
            } else {
                this.isLoaded = true;
                console.log('onsubmit event recordEditForm' + event.detail.fields);
                event.preventDefault();
                const fields = event.detail.fields;
                fields.Report_Service_Incidents__c = this.toogleFieldValueCI;
                fields.Create_Requests__c = this.toogleFieldValueCR;
                fields.Order_Tracking__c = this.toogleFieldValueOT;
                fields.Requests_Tracking__c = this.toogleFieldValueRq;
                fields.Monitor_Network_and_Services__c = this.toogleFieldValueMNS;
                fields.Monitor_Mobile_Data_Usage__c = this.toogleFieldValueMMDU;
                fields.Order_Services__c = this.toogleFieldValueTCS;
                fields.Raise_Billing_Disputes__c = this.toogleFieldValueB;
                fields.Telstra_Connect_Admin__c = this.toogleFieldValueUM;
                fields.Special_Requirements__c = this.toogleFieldValueSReq;
                fields.Telstra_Connect_Opt_Out__c = this.toggleFieldValueTCOO;
                let selval = '';
                for(const selinv of this.selinvNotifications){
                    selval += selinv+ ';';
                }
                selval = selval.substr(0, selval.length-1);
                fields.Invoice_notifications__c = selval;
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
        } else if (this.onloadtelstraConnectAdminVal == true && this.toogleFieldValueUM == true) {
            if (this.toogleFieldValueCI == false || this.toogleFieldValueCR == false || this.toogleFieldValueOT == false || this.toogleFieldValueMNS == false || this.toogleFieldValueMMDU == false || this.toogleFieldValueRq == false || this.toogleFieldValueTCS == false || this.toogleFieldValueB == false) {
                event.preventDefault();
                this.openModalNow = true;
                this.openDowngradeModal = true;
            } else {
                this.isLoaded = true;
                event.preventDefault();
                const fields = event.detail.fields;
                fields.Report_Service_Incidents__c = this.toogleFieldValueCI;
                fields.Create_Requests__c = this.toogleFieldValueCR;
                fields.Order_Tracking__c = this.toogleFieldValueOT;
                fields.Requests_Tracking__c = this.toogleFieldValueRq;
                fields.Monitor_Network_and_Services__c = this.toogleFieldValueMNS;
                fields.Monitor_Mobile_Data_Usage__c = this.toogleFieldValueMMDU;
                fields.Order_Services__c = this.toogleFieldValueTCS;
                fields.Raise_Billing_Disputes__c = this.toogleFieldValueB;
                fields.Telstra_Connect_Admin__c = this.toogleFieldValueUM;
                fields.Special_Requirements__c = this.toogleFieldValueSReq;
                fields.Telstra_Connect_Opt_Out__c = this.toggleFieldValueTCOO;
                let selval = '';
                for(const selinv of this.selinvNotifications){
                    selval += selinv+ ';';
                }
                selval = selval.substr(0, selval.length-1);
                fields.Invoice_notifications__c = selval;
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
        } else {
            this.isLoaded = true;
            console.log('onsubmit event recordEditForm' + event.detail.fields);
            event.preventDefault();
            const fields = event.detail.fields;
            fields.Report_Service_Incidents__c = this.toogleFieldValueCI;
            fields.Create_Requests__c = this.toogleFieldValueCR;
            fields.Order_Tracking__c = this.toogleFieldValueOT;
            fields.Requests_Tracking__c = this.toogleFieldValueRq;
            fields.Monitor_Network_and_Services__c = this.toogleFieldValueMNS;
            fields.Monitor_Mobile_Data_Usage__c = this.toogleFieldValueMMDU;
            fields.Order_Services__c = this.toogleFieldValueTCS;
            fields.Raise_Billing_Disputes__c = this.toogleFieldValueB;
            fields.Telstra_Connect_Admin__c = this.toogleFieldValueUM;
            fields.Special_Requirements__c = this.toogleFieldValueSReq;
            fields.Telstra_Connect_Opt_Out__c = this.toggleFieldValueTCOO;
            let selval = '';
            for(const selinv of this.selinvNotifications){
                selval += selinv+ ';';
            }
            selval = selval.substr(0, selval.length-1);
            fields.Invoice_notifications__c = selval;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
        this.showFooter = false;
    }

    //Handle On Error. 
    handleError(event) {
        this.showErrorMsg = true;
        this.errorMsgVal = JSON.stringify(event.detail);
        var errmsg = JSON.stringify(event.detail);
        var detailval = errmsg.indexOf("detail");
        var outputval = errmsg.indexOf("output");
        if (detailval > 0 && outputval > 0) {
            detailval = detailval + 9;
            outputval = outputval - 3;
            var errmsg1 = errmsg.substring(detailval, outputval);
        } else {
            var errmsg1 = JSON.stringify(event.detail.message);
        }
        this.errorMsgVal = errmsg1;

        this.isLoaded = false;
    }
    navigateToContactHome() {
        this[NavigationMixin.Navigate]({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": this.recordId,
                "objectApiName": "Contact",
                "actionName": "view"
            }
        });
    }

    //Handle On Click of Cancel Button 
    handleCancle(event) {
        getRecordNotifyChange([{ recordId: this.recordId }]);
    }

    // Handle On Success. 
    handleSuccess(event) {
        this.isLoaded = false;
        this.showFooter = false;
        const updatedRecord = event.detail.id;
        const toastEvent = new ShowToastEvent({
            title: permissionSaveSuccessMsg,
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
    }
}