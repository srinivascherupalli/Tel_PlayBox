import { LightningElement,api,wire,track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getRecord,getFieldValue  } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import exportUnmatchedSites from '@salesforce/apex/BulkUploadSiteDataController.exportUnmatchedSites';
import getProcessedRecords from '@salesforce/apex/BulkUploadSiteDataController.getProcessedRecords';
import callSearchAddressBatch from '@salesforce/apex/BulkUploadSiteDataController.manualBatchCall'; 
import deleteSiteRecord from '@salesforce/apex/BulkUploadSiteDataController.deleteSiteRecord';
import addSiteRecord from '@salesforce/apex/BulkUploadSiteDataController.addSiteRecord';
import getCountOfFailedRecord from '@salesforce/apex/BulkUploadSiteDataController.getCountOfFailedRecord';
import logException from '@salesforce/apex/BulkUploadSiteDataController.logException';


const siteColumns = [
                        { label: 'Site Name', fieldName: 'siteName',type:'text' },
                        { label: 'Site Address from file', fieldName: 'address',type:'text' },
                        { label: 'Adbor ID from file', fieldName: 'adborId', type: 'text' },
                        { label: 'Status', fieldName: 'status', type: 'text' },
                        { label: 'Select Address', fieldName: 'newAddress', type: 'text' },
                        { label: 'Action', fieldName: 'action', type: 'text' }
                        
                    ];

const siteExportColumns = [

                        { label: 'Site Name', fieldName: 'siteName', type:'text' },
                        { label: 'Full Address', fieldName: 'address',type:'text' },
                        { label: 'Adbor Id', fieldName: 'adborId', type: 'text' },
    
                    ];

    
const fields = [NAME_FIELD];  

const status = ['New','Failed'];

export default class SiteDataTable extends NavigationMixin(LightningElement) {
    siteColumns = siteColumns;
    siteExportColumns = siteExportColumns;
    isLoaded = true;
    @api results;
    @api accRecordId;
    @api batchProcessId;
    dataToExport;
    openDeleteModal;
    progress = 5000;
    offset=0;
    Prevoffset=0;
    @api pageSize;
    recordToDelete;
    openDeleteAllModal;
    loaderCSS = '';
    @track failedRecordCount = 0;
    showFailedRecordMessage = false;
    @api totalCount;
    currentPage = 1;
    totalPage = 1;
    disableFirst = false;
    disableLast = false;
    fireCountQuery = true;

    
    @wire(getRecord, { recordId: '$accRecordId', fields })
    account;

    get name() {
        return getFieldValue(this.account.data, NAME_FIELD);
    }

    @api
    showdata(csvData) {
        this.isLoaded = false;
        this.loaderCSS = '';
        let tempData = JSON.parse(JSON.stringify(csvData));
        tempData.forEach((attr) => {
            attr['actionDelete'] = false;
            attr['actionAdd'] = true; 
            attr['actionCombo'] = true;
            if(attr.status === 'Site Created' ) {
                attr['actionDelete'] = true;
                attr['Color'] = 'slds-text-align_left custom-background-created custom_width';
            }
            else if(attr.status === 'Match Found') {
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
        
        if(this.failedRecordCount === 0) {
            this.showFailedRecordMessage = false;
        }
        
        this.results = tempData;
        if(this.offset == 0){
            this.disableFirst = true;
            this.currentPage = 1;
            if(this.totalCount > 25){
                this.disableLast = false;
            }    
            else{
                this.totalPage = 1;
                this.disableLast = true; 
            }
                    
        }
        if(this.totalCount < 25){
            this.disableFirst = true;
            this.disableLast = true;
        }
    }

    connectedCallback(){
        this.totalPage = Math.ceil(this.totalCount/this.pageSize);
        if(this.results){
            this.isLoaded = false;
            this.showdata(this.results);
            this.getFailedRecords();
        }
        else{
            this.isLoaded = true;
            this.loaderCSS = 'spins';
        }           
    }

    

    handleChange(event){
        let myconsData = [];
        let consData = JSON.parse(JSON.stringify(this.results))
        consData.forEach((rec) => {
            if(rec.corelationId === event.target.dataset.key){
                rec['selectedAddress'] = event.target.value;
                rec['actionAdd'] = false;
            }
            myconsData.push(rec);

        });
        this.results = myconsData;
       
    }

    exportSites(){
        const status=['Not Found','Failed'];
        exportUnmatchedSites({accountId : this.accRecordId,status : status})
            .then(result => {
                if(result){
                    this.dataToExport = result;
                    this.downloadCSVFile(this.dataToExport);
                }
                else{
                    this.dispatchEvent(              
                        new ShowToastEvent({
                            message: 'No records found to export.',
                            variant: 'error'
                        })
                    )
                }
                
                
            })
            .catch(error => {
                if (typeof error.body.message === 'string') {
                    this.error = error.body.message;
                }
                const evt = new ShowToastEvent({
                    title: 'Error occured during exporting data, please contact to Administrator.',
                    message: this.error,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                logException({methodName : 'exportUnmatchedSites', errorMessage : error.body.message ,businessDescription : 'Exception occured while exporting csv data.'})
                .then(result => {
                    console.log('Error logged successfully.');
                })
                
            });
    }


    
    
    async handleAddSite(event){
        
        let selectedRecord;
        this.results.find(attr=>{
            if(attr.corelationId === event.target.dataset.key){
               selectedRecord = attr;
            }
            
        });

        if(selectedRecord.selectedAddress){
            await addSiteRecord({ corelationId : selectedRecord.corelationId , accRecordId : this.accRecordId, selectedAddress : selectedRecord.selectedAddress})
            .then(result => {
                this.isLoaded = true;
                if(result['isSuccess'] == 'true'){
                    this.totalCount = this.totalCount -1;
                    this.isLoaded = false;
                    let myconsData = [];
                    let consData = JSON.parse(JSON.stringify(this.results))
                    consData.forEach((rec) => {
                        if(rec.corelationId === selectedRecord.corelationId){
                            rec['status'] = 'Site Created';
                            rec['Color'] = 'slds-text-align_left custom-background-created custom_width';
                            rec['actionCombo'] = true;
                            rec['actionAdd'] = true;
                            rec['actionDelete']=true;
                        }
                        myconsData.push(rec);

                    });
                    this.results = myconsData;
                    
                    const evt = new ShowToastEvent({
                        title: 'Site has been added successfully.',
                        message: this.error,
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                }else{
                    const evt = new ShowToastEvent({
                        title: 'Error occurred while adding site with selected address, please contact Adminitrator.',
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    this.isLoaded = false;
                }
                
            })
            .catch(error => {
                this.error = error;
            });
        }else{
            const evt = new ShowToastEvent({
                title: 'Please select an address to create site record.',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
        }

        
    }


    handleDelete(event){
        this.openDeleteModal = true;
        this.results.forEach((rec) => {
            if(rec.corelationId === event.target.dataset.key){
                this.recordToDelete = rec;
            }
        });
    }

    showDeleteAllModal(){
        this.openDeleteAllModal = true;
    }

    hideDeleteModal(){
        this.openDeleteModal = false;
        this.openDeleteAllModal = false;
        this.recordToDelete = null;
    }

    deleteConfirm(){
        this.isLoaded = true;
        deleteSiteRecord({ corelationId : this.recordToDelete.corelationId,accRecordId : null})
            .then(result => {
                if(result['isSuccess'] == 'Success'){
                    if(this.recordToDelete.status == 'Failed' && this.failedRecordCount > 0)
                        this.failedRecordCount = this.failedRecordCount - 1;
                        
                    let tempResult = this.results.filter(attr => attr.corelationId != this.recordToDelete.corelationId);
                    this.showdata(tempResult);
                    this.totalCount = this.totalCount - 1;
                    const evt = new ShowToastEvent({
                        title: 'Site has been deleted successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    this.hideDeleteModal();
                }
                else{
                    this.isLoaded = false;
                    const evt = new ShowToastEvent({
                        title: 'Issue occurred while deleting site data.',
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    this.error = error;
                } 
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleDeleteAll(){
        this.isLoaded = true;
        this.openDeleteAllModal = false;
        deleteSiteRecord({corelationId : null, accRecordId : this.accRecordId})
        .then(result => {
            if(result['isSuccess'] == 'Success'){
                this.results = '';
                const evt = new ShowToastEvent({
                    title: 'All sites deleted successfully.',
                    message: this.error,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId : this.accRecordId,
                        objectApiName: 'Account',
                        actionName: 'view'
                    },
                });
            }
            else if(result['isSuccess'] == 'No Records'){
                this.isLoaded = false;
                const evt = new ShowToastEvent({
                    title: 'There are no sites to delete.',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
            else{
                this.isLoaded = false;
                const evt = new ShowToastEvent({
                    title: 'Issue occurred while deleting site data.',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.error = error;
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    
    navigateToAccount(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId : this.accRecordId,
                objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }

    // this method validates the data and creates the csv file to download
    downloadCSVFile(data) {        
        let columnHeader = ["Site Name", "Site Address","Adbor ID"];  // This array holds the Column headers to be displayd
        let jsonKeys = ["Field_1__c", "Field_2__c", "Field_4__c"]; // This array holds the keys in the json data  
        var jsonRecordsData = data;  
        let csvIterativeData;  
        let csvSeperator;  
        let newLineCharacter;  
        csvSeperator = ",";  
        newLineCharacter = "\n";  
        csvIterativeData = "";  
        csvIterativeData += columnHeader.join(csvSeperator);  
        csvIterativeData += newLineCharacter;  
        for (let i = 0; i < jsonRecordsData.length; i++) {  
        let counter = 0;  
        for (let iteratorObj in jsonKeys) {  
            let dataKey = jsonKeys[iteratorObj];  
            if (counter > 0) {  csvIterativeData += csvSeperator;  }  
            if (  jsonRecordsData[i][dataKey] !== null &&  
            jsonRecordsData[i][dataKey] !== undefined  
            ) {  csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';  
            } else {  csvIterativeData += '""';  
            }  
            counter++;  
        }  
        csvIterativeData += newLineCharacter;  
        }  
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvIterativeData);
        downloadElement.target = '_self';
        downloadElement.download = 'Exported Data.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click(); 
    }

    revalidateAddresses(){
        this.currentPage = 1;
        this.totalPage = Math.ceil(this.totalCount/this.pageSize) > 1 ? Math.ceil(this.totalCount/this.pageSize) : 1;
        this.isLoaded = true;
        this.loaderCSS = 'spins';
        let tempData = this.results;
        this.results = null;
        this.showFailedRecordMessage = false;
        this.fireCountQuery = true;
        this.getFailedRecords();
        callSearchAddressBatch({ accountId : this.accRecordId, batchProcessId : this.batchProcessId}).then(result =>{
            if(result['isSuccess'] == 'true') {
                this.results = null;
                this.batchProcessId = result['batchId'];
                this._interval = setInterval(() => { 
                    this.pageSize = 25;
                    this.offset = 0;  
                    this.Prevoffset = 0;
                    this.firstTime = true;
                    this.getRecords();
                    if(this.results){
                        clearInterval(this._interval); 
                    }
                    this.progress = this.progress + 5000; 
                    if ( this.progress === 600000 ) {  
                        clearInterval(this._interval);  
                    }  
                }, this.progress);
            

            } else{
                this.results = tempData;
                if(result['batchSubmitted'] == 'false'){
                    const evt = new ShowToastEvent({
                        title: 'There is no records to process or there is a pending Job.',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.showdata(this.results);
                }
            }
        }).catch(error => {
            this.results = tempData;
            this.error = error;
            
        });
    }

    handleFirst() {
        if(this.fireCountQuery) {
            this.getFailedRecords();
        }
        this.offset = 0;
        this.currentPage = 1;
        this.totalPage = Math.ceil(this.totalCount/this.pageSize);
        this.Prevoffset = 0;
        if(this.totalCount < 25){
            this.pageSize = this.totalCount;
        }
        else{
            this.pageSize = 25;
        }
        this.getRecords();
        
    }

    handlePrevious() {
        //this.totalPage = Math.ceil(this.totalCount/this.pageSize);
        if(this.currentPage > 1){
            this.currentPage = this.currentPage - 1;
            this.totalPage = Math.ceil(this.totalCount/this.pageSize);
        }
        this.offset = this.currentPage * this.pageSize - this.pageSize;
        if(this.fireCountQuery) {
            this.getFailedRecords();
        }
        this.getRecords();
        if(this.offset - this.pageSize >= 0)
        {
            this.disableLast = false;
            this.Prevoffset=this.offset;
        }
        
    }

    handleNext() {
        if(this.totalPage <= Math.ceil(this.totalCount/this.pageSize)){
            if(this.currentPage < this.totalPage)
                this.currentPage = this.currentPage + 1;
        }
        this.totalPage = Math.ceil(this.totalCount/this.pageSize);
        
        if(this.fireCountQuery) {
            this.getFailedRecords();
        }
        this.Prevoffset = this.offset;
        this.offset = this.currentPage*this.pageSize - this.pageSize;
        this.disableFirst = false;
        if(this.offset > 2000){
            this.offset = 2000;
        }
        if((this.offset == 2000 || (this.offset + this.pageSize >=  this.totalCount)) && this.offset != 0){
            this.disableLast = true;
            this.disableFirst = false;
        }
        this.getRecords();
        
    }

    handleLast() {
        this.currentPage = Math.ceil(this.totalCount/this.pageSize);
        this.totalPage = Math.ceil(this.totalCount/this.pageSize);
        if(this.fireCountQuery) {
            this.getFailedRecords();
        }
        
        this.offset = (this.totalCount % this.pageSize == 0) ? ((this.totalCount / this.pageSize) - 1) * this.pageSize  : (Math.floor(this.totalCount / this.pageSize)*this.pageSize);
        if(this.offset > 2000){
            this.offset = 2000;
        }
        if((this.offset == 2000 || (this.offset + this.pageSize >=  this.totalCount)) && this.offset != 0){
            this.disableLast = true;
            this.disableFirst = false;
        }
        this.Prevoffset=this.offset;
        this.getRecords();
    }

    getRecords(){
        getProcessedRecords({ accountId : this.accRecordId , offset: this.offset, pageSize : this.pageSize, firstTime : false})
        .then(result => {
            if(result['SiteDataWrapper'] != 'false'){
                let fetchedRecords =   JSON.parse(result['SiteDataWrapper']);
                this.showdata(fetchedRecords);
            }            
        })
        .catch(error => {
            this.error = error;
        });
    }
    
    /*@wire(getCountOfFailedRecord,{accountId : '$accRecordId', listOfStatus : status, groupByField : 'Field_3__c'})
    getFailedRecordCount({error,data}){
        if(data){
            let aggResult = [];
            aggResult = JSON.parse(JSON.stringify(data));
            aggResult.forEach(agg =>{
                if(agg.Field_3__c === 'New' && agg.cnt == 0) {
                    this.fireCountQuery = false; 
                } else if(agg.Field_3__c === 'New' && agg.cnt != 0) {
                    this.fireCountQuery = true; 
                } else if(agg.Field_3__c === 'Failed' && agg.cnt != 0) {
                    this.showFailedRecordMessage = true;
                    this.failedRecordCount = agg.cnt;
                }
            });
        }
    }*/

    getFailedRecords() {
        this.showFailedRecordMessage = false;
        this.failedRecordCount = 0;
        getCountOfFailedRecord({accountId : this.accRecordId , listOfStatus : this.status, groupByField : 'Field_3__c'})
        .then(result => {
            if(result) {
                let aggResult = [];
                this.aggResult = JSON.parse(JSON.stringify(result));
                this.aggResult.forEach(agg => {
                    if(agg.Field_3__c === 'New' && agg.cnt == 0) {
                        this.fireCountQuery = false; 
                    } else if(agg.Field_3__c === 'New' && agg.cnt != 0) {
                        this.fireCountQuery = true; 
                    } else if(agg.Field_3__c === 'Failed' && agg.cnt != 0) {
                        this.showFailedRecordMessage = true;
                        this.failedRecordCount = agg.cnt;
                    }
                    
                });
            }         
        })
        .catch(error => {
            this.error = error;
        });
    }
}