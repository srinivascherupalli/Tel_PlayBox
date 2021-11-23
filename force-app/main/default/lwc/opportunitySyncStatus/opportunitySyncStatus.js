/*
 *@Created Date : 15-12-2020
 *@Created By : Kamlesh Kumar
 *@Breif : EDGE - 189844 . This files gets the data from VF - OpporutnitySyncStatusPage and Pass the data to child LWC(statusTimetable)
 *@Bug Fixes : EDGE-213033, Reported by SonarQube report to remove null from return type CheckAsyncJobDetails class method. Checking length of result in LWC
 */
 import { LightningElement, track, api } from "lwc";
 import getJobId from '@salesforce/apex/CheckAsyncJobDetails.getJobId';
 import toCheckSyncJobCompletion from '@salesforce/apex/CheckAsyncJobDetails.toCheckSyncJobCompletion';
 import fetchBasketDetails from '@salesforce/apex/CheckAsyncJobDetails.fetchBasketDetails';
 
 export default class OpportunitySyncStatus extends LightningElement {
   @api asyncStatus = '';
   @api progressBarTitle = '';
   @api erroMessage = '';
   @api successMessgae = '';
   @api statusTitle = 'Status';
   @api timeTableTitle = 'Timetable';
   @api progressTitle = 'Progress';
   @api isStatusCompleted = false;
   @api isStatusInprogress = false;
   @api isStatusError = false;
   @api progress = 500;
   @api labelData = [];
   @api closeWindow = false;
   @api closeWindowandRedirect = false;
   @api basketId;
   @api basketName;
   @api basketSyncStatus;
   @api jobId;
 
   @track jobStatus = 'Processing';
   @track jobName;
   @track jobidList = [];
   @track batchStatus;
   @track basketIdList = [];
   @track currentBatchSizeCompleted = "0/0";
   @track exceptionMessage = 'ok';
   @track steps = [{ Name: "Validation Completed", Id: "Validation Completed" }];
 
   connectedCallback() {
     this.jobName = "noInFlightBatch";
     this.basketIdList.push(this.basketId);
     this._interval = setInterval(() => {
       this.progress = this.progress + 500;
       /*
        *Fetch the async job batch id depending on jobName as paramter
        */
       if (this.jobName) {
         getJobId({
           name: this.jobName,
           basketId: this.basketId
         })
           .then((result) => {
               for(let key in result) {
                 if(key === this.jobName){
                    this.jobId = result[key].id;
                 }
             }
             
           })
           .catch((error) => {
             //EDGE-213033
             if(error.body.message) {
               this.exceptionMessage = 'error';
               this.jobStatus = "Failed";
             }
           });
       }
       if (this.jobId) {
         /*
          *@Created By : Kamlesh Kumar
          *@Breif : Fetch the apex job status from toCheckSyncJobCompletion method ofCheckAsyncJobDetails class
          */
         this.jobidList.push(this.jobId);
         toCheckSyncJobCompletion({
             jobId: this.jobidList
         })
           .then((result) => {
             if(result) {
                 for(let key in result) {
                     if(key === this.jobId){
                         this.asyncStatus = result[key].Status;
                         this.currentBatchSizeCompleted = result[key].JobItemsProcessed +'/'+result[key].TotalJobItems;
                     }
 
                 }
 
             }
           })
           .catch((error) => {
             //EDGE-213033
             if(error.body.message) {
               this.exceptionMessage = 'error';
               this.jobStatus = "Failed";
             }
           });
       }
       
       //Checking for exception message on apex class
       if(this.exceptionMessage === 'error') {
         this.isStatusError = true;
         this.isStatusInprogress = false;
         this.progressBarTitle = 'There was a technical exception, please contact your admin and quote the basket number : ' +this.basketName+ ' for analysing the issue.';
         this.closeWindow = true;
         clearInterval(this._interval);
       }
       if (this.asyncStatus === "Completed") {
         /*
          *@Created By : Kamlesh Kumar
          *@Breif : Fetch the basket sync status from fetchBasketSyncOppStatus method ofCheckAsyncJobDetails class
          *@Modifed : Instead of calling fetchBasketSyncOppStatus, new method fetchBasketDetails is getting called
          */
         fetchBasketDetails({
             basketId:this.basketIdList
 
         })
        .then(result => {
         if(result) {
             for(let key in result) {
                 if(key === this.basketId){
                    this.basketSyncStatus = result[key].csbb__Synchronised_With_Opportunity__c;
                 }
             }
         }
            
        })
        .catch(error => {
            //EDGE-213033
             if(error.body.message) {
               this.exceptionMessage = 'error';
               this.jobStatus = "Failed";
             }
     });
       }
       
       //Added one more criteria for finding failed status as we have exception handling done on prodUtilityForModular class
       if ((this.asyncStatus === "Failed" ||(this.asyncStatus === "Completed" && this.basketSyncStatus === false)) && this.exceptionMessage === 'ok') {
         this.jobStatus = "Failed";
         this.isStatusError = true;
         this.progressBarTitle = this.erroMessage;
         this.closeWindow = true;
         clearInterval(this._interval);
       } 
       else if (this.asyncStatus === "Completed" && this.basketSyncStatus === true && this.exceptionMessage === 'ok') {
         this.jobStatus = "Completed";
         this.isStatusCompleted = true;
         this.isStatusInprogress = false;
         this.progressBarTitle = 'Completed';
         for(let key in this.labelData){
           if(this.labelData[key].Id === 'OLIs Created'){
              this.steps.push({Name: this.labelData[key].Name,Id: this.labelData[key].Id});
              break;
           }
        }
         this.closeWindowandRedirect = true;
         clearInterval(this._interval);
       } 
       else if (this.asyncStatus === "Processing" && this.exceptionMessage === 'ok') {
         this.jobStatus = "Processing";
         this.isStatusInprogress = true;
       } 
       else if (this.asyncStatus === "Preparing" && this.exceptionMessage === 'ok') {
         this.jobStatus = "Preparing";
         this.isStatusInprogress = true;
       } 
     }, this.progress);
   }
 }