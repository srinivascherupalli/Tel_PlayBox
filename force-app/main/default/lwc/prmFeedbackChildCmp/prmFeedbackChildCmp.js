import { LightningElement, wire, track, api } from 'lwc';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
import MODULE_FIELD from '@salesforce/schema/Case.Functionality_Module__c';
import uploadFile from '@salesforce/apex/PRMFloatingFeedbackController.uploadFile';
import CASE_OBJECT from '@salesforce/schema/Case';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const fields = [MODULE_FIELD];
const columns = [
    {label: 'Title', fieldName: 'Title'}
];

export default class PrmFeedbackChildCmp extends LightningElement {
    @track selectedOption; 
    @track options;
    @api oldparentId;
    @track errorMessage;
    @api recordId;
    @track columns = columns;
    @track data;
    @track fileName = '';
    @track UploadFile = 'Upload File';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    @track currentURL = window.location.href;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 5000000;

    connectedCallback(){
        this.populateCurrentURL();
    }

    renderedCallback(){
        this.populateCurrentURL();
    }

    /* get current url to be populated for case creation */
    populateCurrentURL(){
        var inp = this.template.querySelectorAll("lightning-input");
        inp.forEach(function(element){
            if(element.name=="inputUrl"){
                console.log('pop curr url*****'+this.currentURL);
                element.value = this.currentURL;
            }
        },this);
    }

    /* get picklist values */
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: MODULE_FIELD })
    setPicklistOptions({error, data}) {
        if (data) {
            this.options = data.values;
            if (this.selectedOption) {
                let optionIsValid = this.options.some(function(item) {
                    return item.value === this.selectedOption;
                }, this);

                if (!optionIsValid) {
                    this.selectedOption = data.defaultValue;
                }
            } else {
                this.selectedOption = data.defaultValue;
            }
        } else if (error) {
            console.log(error);
        }
    }

    handleChange(event) {
        console.log('event.detail.value*****'+event.detail.value);
        this.selectedOption = event.detail.value;
    }

    /* send current input values from child component to a parent component */
    @api fetchCaseDetails(event) {
        var inp = this.template.querySelectorAll("lightning-input");
        var inputUrl;
        var inputFile;
        inp.forEach(function(element){
            if(element.name=="inputUrl"){
                console.log('url VALUE*****'+element.value);
                inputUrl = element.value;
            }else if(element.name=="inputFile"){
                console.log('file VALUE*****'+element.value);
                inputFile = element.value;
            }
        },this);
        this.errorMessage = '';
        console.log('inputUrl*****'+inputUrl);
        console.log('inputFile*****'+inputFile);
        /* if inputurl or inputFile is missing send error */
        if((inputUrl == undefined || inputUrl == '' || inputUrl == ' ')
        && (inputFile == undefined || inputFile == '' || inputFile == ' ')){
            this.errorMessage = 'Please enter either url or upload file';
        }
        var cmb = this.template.querySelector("lightning-combobox").value;
        console.log('modue VALUE*****'+cmb);
        /* if functionality / module is missing send error */
        if(cmb == undefined || cmb == '' || cmb == ' '){
            this.errorMessage = 'Please select Functionality/Module';
        }
        var txtArea = this.template.querySelector("lightning-textarea").value;
        console.log('desc VALUE*****'+txtArea);
        /* if txtArea is missing send error */
        if(txtArea == undefined || txtArea == '' || txtArea == ' '){
            this.errorMessage = 'Please enter description';
        }
        console.log('this.errorMessage*****'+this.errorMessage);
        //const cDetail = new caseDet(this.inputUrl, this.inputFile, this.cmb, this.textArea);
        var caseDet = {"ipUrl" : inputUrl,"ipPath" : inputFile,"ipModule" : cmb,"ipDesc" : txtArea, "errMsg" : this.errorMessage};
        console.log('caseDet*****'+caseDet);
        console.log('caseDet*****'+JSON.stringify(caseDet));

        const searchEvent = new CustomEvent('submitvalues', {detail: caseDet});
        this.dispatchEvent(searchEvent);
    }

    @api uploadFile(parentId){
        console.log('parentId********'+parentId);
        this.handleSave(parentId);
    }

    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
        }
    }

    handleSave(parentId) {
        console.log('handleSave called********');
        if(this.filesUploaded.length > 0) {
            this.uploadHelper(parentId);
        }
        else {
            this.fileName = 'Please select file to upload!!';
        }
    }

    /* read file and send to apex class */
    uploadHelper(parentId) {
        console.log('uploadHelper called********');
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
            window.console.log('File Size is to long');
            return ;
        }
        this.showLoadingSpinner = true;
        // create a FileReader object 
        this.fileReader= new FileReader();
        // set onload function of FileReader object  
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);
            
            // call the uploadProcess method 
            this.saveToFile(parentId);
        });
    
        this.fileReader.readAsDataURL(this.file);
    }

    // Calling apex class to insert the file
    saveToFile(parentId) {
        console.log('saveToFile called********');
        console.log('this.parentId********'+parentId);
        console.log('this.file.name********'+this.file.name);
        uploadFile({ idParent: parentId, strFileName: this.file.name, base64Data: encodeURIComponent(this.fileContents)})
        .then(result => {
            window.console.log('result ====> ' +result);
            // refreshing the datatable
            //this.getRelatedFiles();

            this.fileName = this.fileName + ' - Uploaded Successfully';
            this.UploadFile = 'File Uploaded Successfully';
            this.isTrue = true;
            this.showLoadingSpinner = false;

            // Showing Success message after file insert
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: this.file.name + ' - Uploaded Successfully!!!',
                    variant: 'success',
                }),
            );

        })
        .catch(error => {
            // Showing errors if any while inserting the files
            window.console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while uploading File',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }
}