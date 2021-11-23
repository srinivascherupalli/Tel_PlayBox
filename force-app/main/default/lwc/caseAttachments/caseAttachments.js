import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import getRelatedFiles from '@salesforce/apex/FileUploadController.getRelatedFiles';
import getFilesFromMetadata from '@salesforce/apex/FileUploadController.getFilesFromMetadata';
import UpdateMetadata from '@salesforce/apex/csFileUploadMetadataHandler.UpdateMetadata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import FORM_FACTOR from '@salesforce/client/formFactor'

var uploadedFileIds = [];

export default class FileUploadView extends NavigationMixin(LightningElement) {
    @api label;
    @api formats = '.xlss,.jpg,.png,.pdf';
    @track upfiles;
    @track isDialogVisible = false;
    @track displayFiles = false;
    @api FileIds;  

    recordId;

    connectedCallback(){

        if(uploadedFileIds[0] != undefined){         
            getFilesFromMetadata()
            .then(result => {
                this.upfiles = result;


                if(result != ''){
                    const attributeChangeEvent = new FlowAttributeChangeEvent('FileIds', uploadedFileIds);
                    this.dispatchEvent(attributeChangeEvent);
                    this.displayFiles = true; 
                }
                else{
                    uploadedFileIds = [];
                }
            })


        }
    }

    get desktopDevice (){
        switch(FORM_FACTOR) {
            case 'Large':
            return true;
            case 'Medium':
            return false;
            case 'Small':
            return false;
            default:
        }
    }

    // get acceptedFormats() {
    //     return this.formats.split(',');
    // }

    handleActionFinished(event) {

        this.displayFiles = true;  
        const uploadedFiles = event.detail.files;

        for(let i = 0; i < uploadedFiles.length; i++) {            
            uploadedFileIds.push(uploadedFiles[i].documentId);
        }

        UpdateMetadata({ fileIdList: uploadedFileIds})

        getRelatedFiles({ fileIdList: uploadedFileIds})
        .then(result => {            
            this.upfiles = result;
        })

        const attributeChangeEvent = new FlowAttributeChangeEvent('FileIds', uploadedFileIds);
        this.dispatchEvent(attributeChangeEvent);
    }  

    filePreview(event) {
        // Naviagation Service to the show preview
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId: event.currentTarget.dataset.id
            }
        })
    }

    handleDelete(event) {
        if (event.target) {
            if (event.target.name === 'openConfirmation') {
                //it can be set dynamically based on your logic
                this.originalMessage = event.currentTarget.dataset.id;
                //shows the component
                this.isDialogVisible = true;
            } else if (event.target.name === 'confirmModal') {
                if (event.detail !== 1) {
                    if (event.detail.status === 'confirm') {
                        //delete content document
                        let contentDocumentId = event.detail.originalMessage;
                        deleteRecord(contentDocumentId)
                            .then(() => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message: 'File deleted',
                                        variant: 'success'
                                    })
                                );
                                this.dispatchEvent(new CustomEvent('filedelete', {}));

                                const deleteFileIndex = uploadedFileIds.indexOf(contentDocumentId);
                                
                                uploadedFileIds.splice(deleteFileIndex,1);

                                getRelatedFiles({ fileIdList: uploadedFileIds})
                                .then(result => {                                
                                    this.upfiles = result;
                                });

                                UpdateMetadata({ fileIdList: uploadedFileIds});

                                //sending empty id list if all attachements deleted by user
                                if(uploadedFileIds[0] == undefined){                                    
                                    this.displayFiles = false;
                                    var emptyArray;                                    
                                    const attributeChangeEvent = new FlowAttributeChangeEvent('FileIds', emptyArray);
                                    this.dispatchEvent(attributeChangeEvent);                                    
                                }else{
                                    const attributeChangeEvent = new FlowAttributeChangeEvent('FileIds', uploadedFileIds);
                                    this.dispatchEvent(attributeChangeEvent);

                                }                                
                            })
                            .catch(error => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error deleting file',
                                        message: error.body.message,
                                        variant: 'error'
                                    })
                                );
                            });
                    }
                }

                //hides the component
                this.isDialogVisible = false;
            }
        }
    }
}