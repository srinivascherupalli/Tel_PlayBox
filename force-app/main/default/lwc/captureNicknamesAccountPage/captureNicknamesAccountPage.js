/*
---------------------------------------------------------------------
Name        : captureNicknamesAccountPage Js
Description : Helper Component 
Author      : Adityen Krishnan
Story       : DIGI-8027(Sprint 21.14)
======================================================================
No.  Developer				Story(Sprint)			Description
1.					
----------------------------------------------------------------------
*/
import {LightningElement, track, wire, api} from 'lwc';
import fetchSubs from '@salesforce/apex/CaptureNicknamesAccountController.getSubscriptionsRecords';
import modal from "@salesforce/resourceUrl/custommodalcss";
import { loadStyle } from "lightning/platformResourceLoader";
import { updateRecord, getRecord,getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import porDomains from "@salesforce/apex/getPORs.getPORDomainsList";
import strUserId from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import ALLOWED_PROFILES from '@salesforce/label/c.CaptureNicknameAllowedProfiles';
import uploadFile from '@salesforce/apex/CaptureNicknamesAccountController.uploadFile';
import FileSizeMessage from '@salesforce/label/c.FileSizeMessage';
import UploadFileSuccessMessage from '@salesforce/label/c.UploadFileSuccessMessage';
//import updateContacts from '@salesforce/apex/CaptureNicknamesAccountController.updateContacts';


const columns = [
  {label: 'Subscription Name', fieldName: 'Name', type: 'text', sortable:true,cellAttributes: {alignment: 'left'}},
  {
    label: 'Subscription Number',
    fieldName: 'csordtelcoa__Subscription_Number__c',
    type: 'text',
    cellAttributes: {alignment: 'left'}, sortable:true
  },
  {
    label: 'Solution Name',
    fieldName: 'cssdm__solution_association__r.Name',
    type: 'text',
    cellAttributes: {alignment: 'left'}, sortable:true
  },
  {
    label: 'Billing Account',
    fieldName: 'Billing_Account__r.Billing_Account_Number__c',
    type: 'text',
    cellAttributes: {alignment: 'left'}, sortable:true
  },
  {label: 'Service ID', fieldName: 'serviceMSISDN__c', type: 'text' , cellAttributes: {alignment: 'left'}, sortable:true},
  {label: 'Nickname', fieldName: 'Nickname__c', type: 'text',
  cellAttributes: {alignment: 'left'}, editable: true, sortable:true}
];
export default class captureNicknamesAccountPage extends LightningElement {
  @api recordId;
  @track error;
  @track wireResult;
  @track columns = columns;
  @track subs; //records available for data table
  @track showTable = false; //Used to render table after we get the data from apex controller
  @track recordsToDisplay = []; //Records to be displayed on the page
  @track rowNumberOffset; //Row number
  @track isDisplayNoRecords = false;
  @track isLoading = true;
  @track sortBy;
  @track sortDirection;
  userId = strUserId;
  saveDraftValues = [];
  @track profileName;
  wiredResult;
  MAX_FILE_SIZE = 1000000;
    @track fileName = '';
    filesUploaded = [];
    file;
    fileContents;
  debugger;
  label = {
    ALLOWED_PROFILES
  };

  connectedCallback() {
    loadStyle(this, modal);
  }
//Fetch Profile on LOAD
  @wire(getRecord, {recordId: strUserId, fields: [PROFILE_NAME_FIELD]})
  wireuser({error, data}) {
    if (error) {
      this.error = error ;
    } else if (data) {
      this.profileName = data.fields.Profile.value.fields.Name.value;
      console.log('DATA PROFILE <><> :'+JSON.stringify(data));
      let allowedProfiles = this.label.ALLOWED_PROFILES.split(',');
      console.log('PROFILE NAME <><><> :'+this.profileName +'  <><><> '+allowedProfiles);
      if (!allowedProfiles.includes(this.profileName)) {
        this.dispatchEvent(
            new ShowToastEvent({
              title: 'error',
              message: 'This profile doesn’t have permission to capture nickname',
              variant: 'error'
            })
        );
        eval("$A.get('e.force:closeQuickAction').fire();");
      }else
      {
        porDomains({ accountId: this.recordId }).then(data => {
          if (data) {
            console.log('Data:',data);
            if (Object.keys(data)[0]==='true') {
              var domainList= data[Object.keys(data)[0]];
              if(domainList.length==0){  
              this.dispatchEvent(              
                new ShowToastEvent({
                     title: 'error',
                     message: 'This partner doesn\'t have POR with customer to capture nickname',
                     variant: 'error'
                 })
               );
               eval("$A.get('e.force:closeQuickAction').fire();");
              }else
              if(!domainList.includes("Mobile")){
                this.dispatchEvent(              
                  new ShowToastEvent({
                       title: 'error',
                       message: 'This partner doesn\'t have mobile domain POR with customer to capture nickname',
                       variant: 'error'
                   })
                 );
                 eval("$A.get('e.force:closeQuickAction').fire();");
              }        
            }
          }   
          }
        )
      }
    }
  }

  @wire (fetchSubs, {accountId: '$recordId'})
  wiredsubs(value) {
    this.wiredResult=value;
    const { data, error } = value
    if (data) {
      this.data = data;
      console.log('Records<><><><>: '+JSON.stringify(data));
      if(data.length != 0) {
        this.isDisplayNoRecords=false;
       this.subs=data;
       this.processDataFetched(data);
       this.isLoading =false;
      }
    } else {
      this.isDisplayNoRecords=true;
      this.error = error;
      this.isLoading =false;
    }

  }
  

  //Capture the event fired from the paginator component
  handlePaginatorChange (event) {
    this.recordsToDisplay = event.detail;
    
    console.log('INSIDE recordsToDisplay handlePaginatorChange'+ this.recordsToDisplay);
    if(this.recordsToDisplay.length > 0)
    {
      this.isDisplayNoRecords=false;
      this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
    }
    else
    {
      this.isDisplayNoRecords=true;
    }
  }
  _flatten = (nodeValue, flattenedRow, nodeName) => {
    let rowKeys = Object.keys(nodeValue);
    rowKeys.forEach((key) => {
      let finalKey = nodeName + '.'+ key;
      flattenedRow[finalKey] = nodeValue[key];
    })
  }

  // This function is used to refresh the table once data updated
    refresh() {
    var promiseReturn = refreshApex(this.wiredResult);
    this.saveDraftValues = [];
  }

// Handle save commented to test with apex
  handleSave(event) {
    this.saveDraftValues = event.detail.draftValues;
    var checkBool = true;
    var regPattern = /^[a-zA-Z0-9- ']*$/;
    for (var i = 0; i < this.saveDraftValues.length; i++) {
      var isValid = this.saveDraftValues[i].Nickname__c.match(regPattern);
      if (isValid === null) {
        const evt = new ShowToastEvent({
          message: 'Please remove special characters from nickname(s); valid characters are a-z A-Z 0-9 - \'',
          variant: 'error',
        });
        this.dispatchEvent(evt);
        checkBool = false;
        break;
      }
    }
    if ( checkBool == true ) {
    const recordInputs = this.saveDraftValues.slice().map(draft => {
      const fields = Object.assign({}, draft);
      return {fields};
    });

    // Updating the records using the UiRecordAPi
      this.isLoading = true;
    const promises = recordInputs.map(recordInput => updateRecord(recordInput));
    Promise.all(promises).then(async res => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Records Updated Successfully!!',
                variant: 'success'
            })
        );
        this.saveDraftValues = [];
        this.isLoading = false;
        //return refreshApex(this.wiredResult);
        await refreshApex(this.wiredResult);
        this.template.querySelector('c-generic-paginator').setRecordsToDisplay();
    }).catch(error => {
      this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            message: 'An Error Occured!!',
            variant: 'error'
          })
      );
    }).finally(() => {
     this.saveDraftValues = [];
     this.isLoading =false;
    });
  }
  }
 
  processDataFetched(data){
    let recs = [];
    for (let i = 0; i < data.length; i++) {
      let sub = {};
      let rowKeys = Object.keys(data[i]);
      sub.rowNumber = '' + (i + 1);
      //iterate
      rowKeys.forEach((rowKey) => {
        //get the value of each key of a single row.
        const singleNodeValue = data[i][rowKey];
        //check if the value is a node(object) or a string
        if(singleNodeValue.constructor === Object){
          //if it's an object flatten it
          this._flatten(singleNodeValue, sub, rowKey)
        }else{
          //if it’s a normal string push it to the flattenedRow array
          sub[rowKey] = singleNodeValue;
        }
      });
      recs.push (sub);
    }
    this.subs = [...recs];
    this.showTable = true;
  }

  doSorting(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
  }

  sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.recordsToDisplay));
    // Return the value stored in the field
    let keyValue = (a) => {
      return a[fieldname];
    };
    // cheking reverse direction
    let isReverse = direction === 'asc' ? 1: -1;
    // sorting data
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : ''; // handling null values
      y = keyValue(y) ? keyValue(y) : '';
      // sorting values based on direction
      return isReverse * ((x > y) - (y > x));
    });
    this.subs = parseData;
    this.recordsToDisplay = parseData;
  }
  generateCsvFile() {
    // get the Records list from 'data' attribute 
    var stockData = this.subs;
    var tabledata = [];
    for (var i = 0; i < stockData.length; i++) {
        tabledata.push(stockData[i]);
    }
    var columns1 = this.columns;
    this.downloadCsv(tabledata, columns1);
}
@api
downloadCsv(objectRecords, columns1) {
    // call the helper function which "return" the CSV data as a String   
    var csv = this.convertArrayOfObjectsToCSV(objectRecords, columns1);
    if (csv == null) { return; }

    // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
    var hiddenElement = document.createElement('a');
    hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
    //  hiddenElement.target = '_self'; //Commented '_self' and added '_blank' to fix download csv issue in LEX - Dheeraj
    hiddenElement.target = '_blank';
    hiddenElement.download =  'Account Data.csv';//'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
    document.body.appendChild(hiddenElement); // Required for FireFox browser
    hiddenElement.click(); // using click() js function to download csv file
}

convertArrayOfObjectsToCSV(objectRecords, columns1) {
    var csvStringResult, counter, columnDivider, lineDivider;
    var keys = [];
    var header = [];
    // check if "objectRecords" parameter is null, then return from function
    if (objectRecords == null || !objectRecords.length) {
        return null;
    }
    // store ,[comma] in columnDivider variabel for sparate CSV values and 
    // for start next line use '\n' [new line] in lineDivider varaible  
    columnDivider = ',';
    lineDivider = '\n';
    var headercolumns = this.columns;
    for (var i = 0; i < headercolumns.length > 0; i++) {
        header.push(headercolumns[i].label);// this labels use in CSV file header  
        keys.push(headercolumns[i].fieldName);// in the keys valirable store fields API Names as a key
    }

    csvStringResult = '';
    csvStringResult += header.join(columnDivider);
    csvStringResult += lineDivider;

    for (var i = 0; i < objectRecords.length; i++) {
        counter = 0;

        for (var sTempkey in keys) {
            var skey = keys[sTempkey];
            // add , [comma] after every String value,. [except first]
            if (counter > 0) {
                csvStringResult += columnDivider;
            }
            let value = '';
            if (objectRecords[i][skey] != undefined) {
                value = objectRecords[i][skey];
            }
            csvStringResult += '"' + value + '"';

            counter++;

        } // inner for loop close 
        //csvStringResult += lineDivider;
        csvStringResult += columnDivider +"  " +lineDivider;
    }// outer main for loop close 

    // return the CSV formate String 
    return csvStringResult;
}// END for CSV

uploadFile(event) {
  //this.isLoading = true;
  var fileSizeError = FileSizeMessage;
  
  console.log('Inside uploadFile');
  if (event.target.files.length > 0) {
      this.filesUploaded = event.target.files;
      this.fileName = event.target.files[0].name;
      this.file = this.filesUploaded[0];
      if (this.file.size > this.MAX_FILE_SIZE) {
          console.log('File Size is to long');
          //this.showToastMessage('Error', fileSizeError, 'error');
          this.dispatchEvent(    
          new ShowToastEvent({
            title: 'error',
            message: 'fileSizeError',
            variant: 'error'
        })
          );
      }
      if (this.file > 1) {
        console.log('File Size is to long');
        //this.showToastMessage('Error', fileSizeError, 'error');
        this.dispatchEvent(    
        new ShowToastEvent({
          title: 'error',
          message: 'fileSizeError',
          variant: 'error'
      })
        );
    }
      else {
          this.fileReader = new FileReader();
          this.fileReader.onloadend = (() => {
              this.fileContents = this.fileReader.result;
              this.saveToFile();
          });
          this.fileReader.readAsText(this.file);
      }
  }
}

saveToFile() {
  var metaDataName = 'SubscriptionNicknameOrder';
  this.isLoading = true;
  console.log(JSON.stringify(this.fileContents));
  uploadFile({ base64Data: JSON.stringify(this.fileContents), metaDataRecName: metaDataName })
      .then(result => {
          if (result == UploadFileSuccessMessage) {
              window.console.log('result ====> ' + result);
              //this.showToastMessage('Success', result, 'success');
              this.dispatchEvent(    
              new ShowToastEvent({
                title: 'Success',
                message: 'The record has been updated successfully',
                variant: 'success'
            })
              );
              this.isLoading = false;
              window.location.reload();
          }
          else {
              window.console.log('else result ====> ' + result);
              //this.showToastMessage('Error', result, 'error');
              this.dispatchEvent(    
              new ShowToastEvent({
                title: 'error',
                message: 'Upload failed due to validation errors in the file',
                variant: 'error'
            })
              );
              this.isLoading = false;
          }

      })
      .catch(error => {
          window.console.log(error);
          //this.showToastMessage('Error', error, 'error');
          this.dispatchEvent(    
          new ShowToastEvent({
            title: 'error',
            message: 'Upload failed due to validation errors in the file',
            variant: 'error'
        })
          );
          this.isLoading = false;

      });
}
}