/**
   *  Description of the purpose of the method.
   *  @name uploadSiteData
   *  @description                       : This LWC is used to upload the site Data for Site creation
   *  @return 				 	         : - 
   *  @Jira Story Ref                    : DIGI-37554
   *  @CreatedBy                         : Nitin kumar,Ajith Kumar
   *  @ModifiedBy  				         : Ajith Kumar
**/
import { LightningElement,api, track,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSitesCount from '@salesforce/apex/BulkUploadSiteDataController.getSitesCount';
import parseCSVandUpload from '@salesforce/apex/BulkUploadSiteDataController.parseCSVandUpload';
import getProcessedRecords from '@salesforce/apex/BulkUploadSiteDataController.getProcessedRecords';
import deleteDocument from '@salesforce/apex/BulkUploadSiteDataController.deleteDocument';
import bulkSiteTemplate from '@salesforce/resourceUrl/Bulk_Site_Template';

export default class UploadSiteData extends NavigationMixin(LightningElement) {
    @api accRecordId;
    openDataTable = false;
    templateLink;
    csvData;
    progress = 5000; 
    offset=0;
    pageSize = 25;
    batchProcessId = '';
    loading = false;
    showNextButton = true;
    recordsToReview=0;
    documentId;

//DIGI-37554 Added connected callback to get the sitecount on loading the component
    connectedCallback(){
        this.getSitesCountRecords();
    }
    
    handleFilesChange(event){
        this.loading = true;
        this.showNextButton = true;
        if(event.detail.files[0].documentId){
            this.documentId=event.detail.files[0].documentId;
            parseCSVandUpload({ contentDocumentId: event.detail.files[0].documentId, accountId : this.accRecordId })
            .then(result => {
                if(result['isCSVValid'] == 'true'){
                    if(result['recordSize'] != '0' ){
                        this.batchProcessId =  result['batchId'];
                        this.totalCount = parseInt(result['recordSize']) + this.recordsToReview;
                        if(this.totalCount > 25){
                            this.pageSize = 25;
                        }
                        else{
                            this.pageSize = this.totalCount;
                        }
                        this.loading = false;
                        this.openDataTable = true;
                        this._interval = setInterval(() => {  
                            this.getProcessedData();
                            if(this.csvData){
                                clearInterval(this._interval); 
                            }
                            this.progress = this.progress + 5000;  
                            if ( this.progress === 600000 ) {  
                                clearInterval(this._interval);  
                            }  
                        }, this.progress);
                    }
                    else{
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: 'Invalid CSV, there is no records in the file.',
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                        this.deleteDocumentRecords();
                        this.showModal();
                    }
                }
                else{
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Invalid CSV, Please check the file again.',
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    this.deleteDocumentRecords();
                    this.showModal();
                }
                
            })
            .catch(error => {
                if (typeof error.body.message === 'string') {
                    this.error = error.body.message;
                }
                const evt = new ShowToastEvent({
                    title: 'Error Occurred while parsing the file.',
                    message: this.error,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.deleteDocumentRecords();
                this.showModal();
                
            });
        }
       
    }

    deleteDocumentRecords(){
        deleteDocument({contentDocumentId:this.documentId})
    }

    showModal(){
        this.loading = false;
        if(this.recordsToReview != 0) {
            this.showNextButton = false;
        }
    }

    getProcessedData(){
        getProcessedRecords({ accountId : this.accRecordId, offset: this.offset, pageSize : this.pageSize, firstTime : true})
        .then(result => {
            if(result['SiteDataWrapper'] != 'false'){
                this.openDataTable = true;
                let tempData =  JSON.parse(result['SiteDataWrapper']);
                tempData.find(attr=>{
                    attr['actionDelete'] = false;
                    attr['actionAdd'] = true; 
                    attr['actionCombo'] = true;
                    if(attr.status === 'Site Created' ) {
                        attr['actionDelete'] = true;
                        attr['Color'] = 'slds-text-align_left custom-background-created custom_width';
                    }
                    else if(attr.status === 'Match Found' ) {
                        if(attr['selectedAddress'] != ''){
                            attr['actionAdd'] = false;
                        }
                        attr['actionCombo'] = false;
                        attr['Color'] = 'slds-text-align_left custom-background-found custom_width';
                    
                    }
                    else{
                        attr['Color'] = 'slds-text-align_left custom-background-notfound custom_width';
                    } 
                    
                });
                this.csvData = tempData;
                this.template.querySelector('c-site-data-table').showdata(this.csvData);
            }
            
        })
        .catch(error => {
            this.error = error;
        });
    }
    

    handlerNextButtonClick(){
        if(this.recordsToReview < this.pageSize) {
            this.pageSize   =  this.recordsToReview;
        }
        this.getProcessedData();
    }

    
    handlerBackButtonClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.accRecordId,
                objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }
//DIGI-37554 changing this method from wired to imperative to avoid cache issue
   getSitesCountRecords(){
    getSitesCount({accountId : this.accRecordId})
    .then(result => {
            if(result){
                if(result['totalCount'] != 0 ){
                    this.showNextButton = false;
                    this.recordsToReview =  result['totalCount'];
                    this.pageSize = this.recordsToReview < 25 ?  this.recordsToReview : 25;
                    this.totalCount = this.recordsToReview;
                }
            }
        })
        .catch(error => {
            if(error){
                this.loaded=false;
                this.error=error;
                this.templateLink = null;
                this.dispatchEvent(              
                    new ShowToastEvent({
                        message: 'Error occured while retrieving the template.',
                        variant: 'error'
                    })
                )
            }
        });                
    }

    getTemplateLink(){
        if(bulkSiteTemplate){
            window.location.href= bulkSiteTemplate;
        }
        else{
            this.loaded=false;
            this.dispatchEvent(              
                new ShowToastEvent({
                    message: 'Error occured while retrieving the template.',
                    variant: 'error'
                })
            )
        }
        
    }

    
}