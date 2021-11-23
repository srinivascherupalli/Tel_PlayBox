import { LightningElement, track, api, wire } from "lwc";
import getInvoiceDetails from "@salesforce/apex/UsageSummaryHandler.getInvoiceDetails";
import Invoice_Charge_Error from "@salesforce/label/c.Invoice_Charge_Error";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import DATE_FIELD from "@salesforce/schema/Invoice_Line_Item__c.Date_Calculated__c";
import QUANTITY_FIELD from "@salesforce/schema/Invoice_Line_Item__c.Quantity__c";
import ID_FIELD from "@salesforce/schema/Invoice_Line_Item__c.Id";

const FIELDS = [
  "Invoice_Line_Item__c.Charge_Id__c",
  "Invoice_Line_Item__c.Invoice_Line_Number__c",
  "Invoice_Line_Item__c.Invoice_Transaction_ID__c",
  "Invoice_Line_Item__c.Invoice__r.Name",
  "Invoice_Line_Item__c.Billing_AccountNumber__c" // Changed Field as part of bug DIGI-10297
];

export default class InvoiceFeaturePackDetails extends LightningElement {
  @api recordId;
  @track orderNumber;
  @track serviceId;
  @track unitRate;
  @track dateCalculated;
  @track quantity;
  @track recordId;
  @track LineItemRecord;
  @track recordLoadError;
  @track errorMessage;
  @track hasErrorMessage = false;
  @track onceRun = false;
  @track activeSection = "A";
  @track rightChevron = "slds-hide";
  @track downChevron = "slds-show";
  buttonClicked; //defaulted to false

  label = {
    Invoice_Charge_Error
  };

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredGetRecord({ error, data }) {
    if (data) {
      this.LineItemRecord = data;
      if (this.onceRun == false) {
        this.getInvoiceDetail();
      }
    } else if (error) {
      console.log("error -->", error);
    }
  }

  getInvoiceDetail() {
    var Obj = new Object();
    Obj.accountNumber = this.LineItemRecord.fields.Billing_AccountNumber__c.value; // Added Changed Field as part of bug DIGI-10297
    Obj.chargeId = this.LineItemRecord.fields.Charge_Id__c.value;
    // adding else to fill the attribute, so that it can be in request body DIGI-10297
    if (this.LineItemRecord.fields.Invoice__r != null) {
      // corrected the check DIGI-10297 v2
      Obj.statementNumber = this.LineItemRecord.fields.Invoice__r.displayValue; // change it to DIGI-10297 v2
    } else {
      Obj.statementNumber = null;
    }

    var requestJSON = JSON.stringify(Obj);
    console.log("requestJSON ", requestJSON);

    getInvoiceDetails({
      request: requestJSON,
      handlerName: "FeaturePackHandler"
    })
      .then((result) => {
        {
          var responseObject = result;
          var statusCode = Object.keys(responseObject);
          console.log("responseObject ", responseObject);
          console.log("statusCode ", statusCode);

          if (responseObject != null && statusCode.length != 0) {
            var responsebody = Object.values(responseObject);
            var response = JSON.parse(responsebody[0]);
            console.log("response ", response);
            if (statusCode[0].startsWith(2)) {
              for (var ili of response.featurePackDetails) {
                for (var details of ili.invoiceLineAttributes) {
                  if (this.LineItemRecord.fields.Invoice_Transaction_ID__c.value == details.invoiceTransactionId) {
                    this.dateCalculated = ili.date;
                    this.quantity = ili.quantity;

                    this.orderNumber = ili.orderNumber;
                    this.serviceId = ili.subscriptionIdentifier;
                    this.unitRate = ili.unitRate;
                  }
                }
                this.updateInvoiceLine();
              }
            } else {
              this.hasErrorMessage = true;
              this.onceRun = true;
              this.errorMessage = this.label.Invoice_Charge_Error;
            }
          } else {
            this.hasErrorMessage = true;
            this.onceRun = true;
            this.errorMessage = this.label.Invoice_Charge_Error;
          }
        }
      })
      .catch((error) => {
        this.error = error;
        this.hasErrorMessage = true;
        this.onceRun = true;
        this.errorMessage = error;
        console.log("error==", error);
      });
  }

  updateInvoiceLine() {
    var fields = {};
    if (this.dateCalculated) {
      fields[DATE_FIELD.fieldApiName] = this.getFormattedDate(this.dateCalculated);
    }
    if (this.quantity) {
      fields[QUANTITY_FIELD.fieldApiName] = this.quantity;
    }
    fields[ID_FIELD.fieldApiName] = this.recordId;

    var recordInput = { fields };
    updateRecord(recordInput)
      .then(() => {
        this.onceRun = true;
        console.log("success");
      })
      .catch((error) => {
        this.onceRun = true;
        console.log(error);
      });
  }

  getFormattedDate(strDate) {
    var formattedDt = Date.parse(strDate);
    return new Date(formattedDt).toISOString();
  }

  accordionToggleSection(event) {
    if (this.activeSection == "A") {
      this.activeSection = "B";
    } else {
      this.activeSection = "A";
    }
  }

  sectionOrderDetails() {
    this.buttonClicked = !this.buttonClicked; //set to true if false, false if true.
    this.rightChevron = this.buttonClicked ? "slds-hide" : "slds-show";
    this.downChevron = this.buttonClicked ? "slds-show" : "slds-hide";
  }
}