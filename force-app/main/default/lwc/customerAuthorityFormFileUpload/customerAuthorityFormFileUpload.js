import { LightningElement, track, api } from 'lwc';
import saveFile from '@salesforce/apex/CaFormFileUploadController.saveFile';
import getActiveCustomerAuthorityForm from '@salesforce/apex/CaFormFileUploadController.getActiveCustomerAuthorityForm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CAFnotUploaded from '@salesforce/label/c.CAFnotUploaded';
import CAFsaved  from '@salesforce/label/c.CAFsaved';
const columns = [
    {
        label: "File ID",
        fieldName: 'linkName', type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    {
        label: "Customer Authorisation Date ",
        fieldName: "Customer_Authorised_date__c",
        type: "date",
        typeAttributes:{
            year: "numeric",
            month: "long",
            day: "2-digit"
        }
    },
    {
        label: "File Uploaded on",
        fieldName: "CreatedDate",
        type: "date",
        typeAttributes:{
            year: "numeric",
            month: "long",
            day: "2-digit"
        }
    },
    {
        label: "Status",
        fieldName: "CA_status__c",
        type: "text"
    },
    {
        label: "Expiry Date",
        fieldName: "CA_Expiry_Date__c",
        type: "date",
        typeAttributes:{
            year: "numeric",
            month: "long",
            day: "2-digit"
        }
    }
];
export default class CaFormFileUploadController extends LightningElement {
    label = {
        CAFnotUploaded,CAFsaved,
    };
    @api basketid ;
    @api isRegenerateCAForm=false;//EDGE-150285-Dheeraj Bhatt-Ability to regenerate CA form for port out reversal order.
    @track customerAuthorityFormList
    @track customerAuthorisedDate;
    @track todaydate;
    @track columns = columns;
    @track fileName = '';
    @track isLoaded;
    @track toasttitle;
    @track toastmsg
    @track toastvariant;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    contentType;
    MAX_FILE_SIZE = 1500000;
    connectedCallback() {
        this.getTodayDate();
        this.getCustomerAuthorityFormList();
    }
/**********************************************************************************************************
EDGE       -142351
Method      -getCustomerAuthorityFormList
Description -fetch active customer authority form on load
Author      -Dheeraj Bhatt
************************************************************************************************************/
    getCustomerAuthorityFormList() {
        getActiveCustomerAuthorityForm({ basketId: this.basketid })
            .then(result => {
                var records = result;
                records.forEach(function (record) {
                    record.linkName = '/' + record.Id;
                });
                this.customerAuthorityFormList = records;
                this.isLoaded = false;
            })
            .catch(error => { });
    }
/**********************************************************************************************************
EDGE       -142351
Method     -getTodayDate
Description-Restrict user from selecting past date
Author     -Dheeraj Bhatt
************************************************************************************************************/
    getTodayDate() {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();
        if (dd < 10) {
            dd = '0' + dd;
        }
        if (mm < 10) {
            mm = '0' + mm;
        }
        var todayFormattedDate = yyyy + '-' + mm + '-' + dd;
        this.todayDate = todayFormattedDate;
        console.log('todayDate: ',this.todayDate);
    }
    // get CA form date
    getcustomerAuthorisedDate(event) {
        this.customerAuthorisedDate = event.target.value;
    }
    //get file name on upload of Customer authority form
    getFileName(event) {
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
        }
    }
/**********************************************************************************************************
EDGE       -142351
Method     -saveUploadFile
Description-validation check before sending file for upload
Author     -Dheeraj Bhatt
************************************************************************************************************/
    saveUploadFile() {
        if (this.customerAuthorisedDate == null) {
            this.setToastvalues('Error', 'Please select customer Authorised Date', 'error');
            return;
        }
        //EDGE-165481,EDGE-171843. Kalashree Borgaonkar. Fix for validation on CA date
        else if(this.customerAuthorisedDate<this.todayDate){
            this.setToastvalues('Error','Past date cannot be selected.', 'error');
            return;
        }
        
        else if (this.fileName =='' || this.filesUploaded.length == 0) {
            this.setToastvalues('Error',CAFnotUploaded, 'error');
            return;
        }
        else if (this.filesUploaded[0].size > this.MAX_FILE_SIZE) {
            window.console.log('File Size is to long');
            this.setToastvalues('Error', 'File Size is too large', 'error');
            return;
        }
        else {
            this.isLoaded = true;
            this.uploadHelper();
        }
    }
/**********************************************************************************************************
EDGE       -142351
Method     -uploadHelper
Description-read upload file
Author     -Dheeraj Bhatt
************************************************************************************************************/
    uploadHelper() {
        this.file = this.filesUploaded[0];
        this.fileReader = new FileReader();
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);
            this.contentType = this.file.type;
            this.showLoadingSpinner = true;
            this.saveToFile();
        });
        this.fileReader.readAsDataURL(this.file);
    }
/**********************************************************************************************************
EDGE       -142351
Method     -saveToFile
Descriptionc-call apex method to save the upload file to newly created active CA form
Author     -Dheeraj Bhatt
************************************************************************************************************/
    saveToFile() {
        saveFile({ cafDate: this.customerAuthorisedDate, basketId: this.basketid, fileName: this.file.name, base64Data: encodeURIComponent(this.fileContents), contentType: this.contentType,isRegenerateCAForm:this.isRegenerateCAForm })
            .then(result => {
                this.fileName='';
                this.filesUploaded=null;
                this.customerAuthorisedDate=null;
                this.getCustomerAuthorityFormList();
                this.setToastvalues('Success',CAFsaved, 'success');
            })
            .catch(error => {
                this.isLoaded = false;
                this.setToastvalues('Error', 'Error while uploading Customer Authority Form', 'error');
            });
    }
    //show toast message
    setToastvalues(toasttitle, toastmsg, toastvariant) {
        if(this.isRegenerateCAForm==false){
        const toastEvent = new CustomEvent('toast', {
            detail: {
                toasttitle: toasttitle,
                toastmsg:toastmsg,
                toastvariant:toastvariant,
            }  
            });
        this.dispatchEvent(toastEvent);
    }
        //EDGE-150285-Dheeraj Bhatt-Ability to regenerate CA form for port out reversal order.
        else{
        this.toasttitle = toasttitle;
        this.toastmsg = toastmsg;
        this.toastvariant = toastvariant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice(); 
        }
    }
}