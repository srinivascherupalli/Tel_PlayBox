/*
*@Created Date : 25-2-2021
*@Created By : Kamlesh Kumar
*@Breif : EDGE - 199074. 
*@Vf Page : SubmitBasketStatusPage
*@Lightning App : c:SubmitBasketStatusApp
*@Bug Fixes : EDGE-213033, Reported by SonarQube report to remove null from return type CheckAsyncJobDetails class method. Checking length of result in LWC
*Note : For predicting the salesforce apex job is completed or not we are using combination of(batchstatus + isBatchCompleted)
*batchstatus = Salesforce Apex job, isBatchCompleted = 'Coming from sync job id custom field which is getting updated in try/catch block of batch apex'
*/
import { LightningElement,track,api } from 'lwc';
import getJobId from '@salesforce/apex/CheckAsyncJobDetails.getJobId';
import toCheckSyncJobCompletion from '@salesforce/apex/CheckAsyncJobDetails.toCheckSyncJobCompletion';
import fetchBasketDetails from '@salesforce/apex/CheckAsyncJobDetails.fetchBasketDetails';
import fetchSyncControlMessage from '@salesforce/apex/CheckAsyncJobDetails.fetchSyncControlMessage';
export default class SubmitBasketStatusLWC extends LightningElement {
    
    @api asyncStatus = 'Processing';
    @api progressBarTitle = '';
    @api statusTitle = 'Status';
    @api timeTableTitle = 'Timetable'
    @api progressTitle = 'Progress';
    @api isStatusCompleted = false;
    @api isStatusInprogress = false;
    @api isStatusError = false;
    @api progress = 500;
    @api timeTable = [];
    @api closeWindow = false;
    @api closeWindowandRedirect = false;
    @api basketId;
    @api basketName;
    @api lastSuccessState;
    
    @track jobStatus = 'Processing';
    @track batchIdList = [];
    @track batchIdList = [];
    @track batchId;
    @track batchName;
    @track batchStatus;
    @track currentBatchSizecompleted = '0/0';
    @track opportunityStage;
    @track basketStage;
    @track ofReversalInserted;
    @track basketSyncstatus;
    @track lastSuccessStage;
    @track exceptionMessage = 'ok';
    @track oliCreationDone = false;
    @track isBatchCompleted;
    @track isBatchError;
    
    @track steps = [
        { Name: 'PONR Check', Id: 'PONR Check' },{ Name: 'Sync Validations', Id: 'Sync Validations'}];
connectedCallback() {
    this.batchName = 'syncJobId';
    this.lastSuccessStage = this.lastSuccessState;
    this.batchIdList.push(this.basketId);
    let  messageMap = new Map();
    let delayInFundTransaction = 0;
    let delayInSubmitBasketTransaction = 0;
    fetchSyncControlMessage({
    })
   .then(result => {
      if(result) {
          for(let key in result) {
            messageMap[key] = result[key].Value__c;
          }
      }
   })
   .catch(error => {
       //EDGE-213033
       if(error.body.message) {
          this.jobStatus = 'Failed';
          this.exceptionMessage = 'error';
      }
}); 

    

this._interval = setInterval(() => {  
    this.progress = this.progress + 10000;  
    if(this.lastSuccessStage != '') {
    /*
    *Fund Reversal is reached
    */
   if(this.lastSuccessStage === 'Fund Reversal') {
    this.DisplayTimetableOnLastSuccessState('submitJobId',true,messageMap['ProcessingOrderUpdateSubmission'],this.lastSuccessStage);
  }
  /*
    *Opportunity Closure is reached
    */
   else if(this.lastSuccessStage === 'Opportunity Closure') {
    this.DisplayTimetableOnLastSuccessState('fundJobId',true,messageMap['ProcessingFundReversal'],this.lastSuccessStage);
  }
  /*
    *OLIs Creation Completed is reached
    */
  else if(this.lastSuccessStage === 'OLIs Creation') { 
    this.oliCreationDone = true;
    this.DisplayTimetableOnLastSuccessState('syncJobId',true,messageMap['ProcessingOpportunityClosure'],this.lastSuccessStage);
   }
}
    /*
    *Fetch the async job batch id depending on batchName as paramter
    */
    if(this.batchName){
        getJobId({
            name:this.batchName,
            basketId: this.basketId
        })
       .then(result => {
           if(result) {
            for(let key in result) {
                if(key === this.batchName){
                   this.batchId = result[key].id;
                   this.isBatchCompleted = result[key].isCompleted;
                   this.isBatchError = result[key].error;
                }

            }
           }
       })
       .catch(error => {
           if(error.body.message) {
             this.jobStatus = 'Failed';
             this.exceptionMessage = 'error';
           }
    });
        }
        
          /*
        *Fetch the apex job status,JobItemsProcessed,TotalJobItems from toCheckSyncJobCompletion method of CheckAsyncJobDetails class
        */
        if(this.batchId) {
           this.batchIdList.push(this.batchId);
            toCheckSyncJobCompletion({
                jobId: this.batchIdList
            })
           .then(result => {
              if(result) {
                  for(let key in result) {
                      if(key === this.batchId){
                         this.batchStatus = result[key].Status;
                         this.currentBatchSizecompleted = result[key].JobItemsProcessed +'/'+result[key].TotalJobItems;
                      }

                  }

              }
           })
           .catch(error => {
               if(error.body.message) {
                 this.jobStatus = 'Failed';
                 this.exceptionMessage = 'error';
               }
        }); 
        
        /*
        *Fetch csbb__Synchronised_With_Opportunity__c,cscfga__Opportunity__r.Id,cscfga__Opportunity__r.StageName,OF_Reversal_Inserted__c,csordtelcoa__Basket_Stage__c
        */
        fetchBasketDetails({
            basketId:this.batchIdList

        })
       .then(result => {
        if(result) {
            for(let key in result) {
                if(key === this.basketId){
                   this.basketSyncstatus = result[key].csbb__Synchronised_With_Opportunity__c;
                   this.ofReversalInserted = result[key].OF_Reversal_Inserted__c;
                   this.basketStage = result[key].csordtelcoa__Basket_Stage__c;
                   this.opportunityStage = result[key].cscfga__Opportunity__r.StageName;
                }

            }

        }    
       })
       .catch(error => {
           if(error.body.message) {
             this.jobStatus = 'Failed';
             this.exceptionMessage = 'error';
           }
    });

        }
     
    //Checking for exception message on apex class
    if(this.exceptionMessage === 'error') {
        this.jobStatus = 'Failed'
        this.isStatusError = true;
        this.isStatusInprogress = false;
        this.progressBarTitle = 'There was a technical exception, please contact your admin and quote the basket number : ' +this.basketName+ ' for analysing the issue.';
        this.closeWindow = true;
        clearInterval(this._interval);
    }
    
    //Adding check for sync batch
    if(this.batchName === 'syncJobId' && this.exceptionMessage === 'ok'){
        this.lastSuccessStage = '';
    if((this.batchStatus === 'Preparing' || this.batchStatus === 'Holding' || this.batchStatus === 'Queued' || this.batchStatus === 'Processing' || typeof this.batchStatus === 'undefined') && (typeof this.basketSyncstatus === 'undefined' || this.basketSyncstatus === false) && this.oliCreationDone === false )  {
        this.jobStatus = 'Processing';
        this.progressBarTitle = messageMap['ProcessingOliCreation'];
    }

    else if ((this.batchStatus === 'Failed' ) || (this.batchStatus === 'Completed' && this.basketSyncstatus != 'undefined' && this.isBatchCompleted === true && (this.basketSyncstatus === false || this.isBatchError === true))) {  
        this.DisplayTimetableOnRunningBatch('Failed',true,false,messageMap['FailedOliCreation'],true,true);
    }
    
    else if ((this.batchStatus === 'Failed') || (this.batchStatus === 'Completed' && this.isBatchCompleted === true  && this.opportunityStage && this.basketSyncstatus && this.oliCreationDone === true && (this.opportunityStage != 'Closed Won' || this.isBatchError === true))) {  
        this.DisplayTimetableOnRunningBatch('Failed',true,false,messageMap['FailedOpportunityClosure'],true,true);  
    }

    else if(this.batchName === 'syncJobId' && this.batchStatus === 'Completed' && this.basketSyncstatus === true && this.oliCreationDone === false)  {
        this.oliCreationDone = true;
        this.CreateTimetable('OLIs Creation',false); 
        this.DisplayTimetableOnRunningBatch('Processing',false,true,messageMap['ProcessingOpportunityClosure'],false,false);
    }

    else if(this.batchName === 'syncJobId' && this.oliCreationDone === true && this.batchStatus === 'Completed' && this.basketSyncstatus === true &&  this.opportunityStage === 'Closed Won' && this.isBatchCompleted === true && this.isBatchError === false) {
        this.batchName = 'fundJobId'; 
        this.CreateTimetable('Opportunity Closure',false);
        this.DisplayTimetableOnRunningBatch('Processing',false,true,messageMap['ProcessingFundReversal'],false,false);
    }
}
//End - sync batch check

//Adding check for fund batch job
if(this.batchName === 'fundJobId' && this.exceptionMessage === 'ok'){
    this.lastSuccessStage = '';
    if(this.batchStatus === 'Processing') {
        this.jobStatus = 'Processing';
    }
    
    //Removing ofReversalInserted === false from failed criteria because there is a delay in ofReversalInserted field update in Apex side due to which ofReversalInserted = false coming on LWC
    else if ((this.batchStatus === 'Failed' ) || (this.batchStatus === 'Completed' && this.isBatchCompleted === true && (this.ofReversalInserted === false || this.isBatchError === true))) {  
        delayInFundTransaction++;
        if(delayInFundTransaction === 10) {
          this.DisplayTimetableOnRunningBatch('Failed',true,false,messageMap['FailedFundReversal'],true,true);
        }
          
    }
    
    else if (this.batchStatus === 'Completed' && this.isBatchCompleted === true && this.ofReversalInserted === true && this.isBatchError === false) {  
        this.batchName = 'submitJobId';
        this.CreateTimetable('Fund Reversal',false);
        this.DisplayTimetableOnRunningBatch('Processing',false,true,messageMap['ProcessingOrderUpdateSubmission'],false,false); 
    }
}
//End of fund batch job

//Adding check for submit batch job
if(this.batchName === 'submitJobId' && this.exceptionMessage === 'ok'){
    this.lastSuccessStage = '';
    if(this.batchStatus === 'Processing') {
        this.jobStatus = 'Processing';
    }
    
    //Removing this.basketStage != 'Submitted' from failed criteria because there is a delay in ofReversalInserted field update in Apex side due to which ofReversalInserted = false coming on LWC
    else if ((this.batchStatus === 'Failed' ) || (this.batchStatus === 'Completed' && this.isBatchCompleted === true && (this.basketStage != 'Submitted' || this.isBatchError === true))) {  
        delayInSubmitBasketTransaction++;
        if(delayInSubmitBasketTransaction === 10) {
            this.DisplayTimetableOnRunningBatch('Failed',true,false,messageMap['FailedOrderSubmission'],true,true);
        }
          
    }
    
    
    else if (this.batchStatus === 'Completed' && this.isBatchCompleted === true && this.basketStage === 'Submitted' && this.isBatchError === false) {
        this.CreateTimetable('Order Update And Basket Submission',false);  
        this.isStatusCompleted = true;
        this.DisplayTimetableOnRunningBatch('Completed',false,false,messageMap['BasketSubmittedSuccessfully'],false,true);  
        if(this.opportunityStage === 'Closed Won') {
            this.closeWindowandRedirect = true;
        }
        else{
            this.closeWindowandRedirect = false;
        }
    }
}
//End of submit batch job
}, this.progress)

}

/*
*@Breif : Method to display timeTable values in timeTable and display on UI based on last success state
*/
DisplayTimetableOnLastSuccessState(batchName,statusInProgress,message,successState,insertTimetable,closeWindow) {

    this.batchName = batchName;
    this.isStatusInprogress = statusInProgress;
    this.progressBarTitle = message;
    this.CreateTimetable(successState,true);

}

/*
*@Brief : Method to display value based on batch running
*/
DisplayTimetableOnRunningBatch(jobStatus,isStatusError,isStatusInprogress,progressBarTitle,closeWindow,stopIteration) {
     
    this.jobStatus = jobStatus;
    this.isStatusError = isStatusError;
    this.isStatusInprogress = isStatusInprogress;
    this.progressBarTitle  = progressBarTitle;
    this.closeWindow = closeWindow;
    if(stopIteration) {
        clearInterval(this._interval);
    }
}


/*
*@Breif : Method created to push timeTable values in timeTable and display on UI
*/
CreateTimetable(timetableId,pushBeforeLastSuccessStage) {

    for(let key in this.timeTable){
        if(this.timeTable[key].Id === timetableId){
           this.steps.push({ Name:this.timeTable[key].Name, Id: this.timeTable[key].Id });
           break;
        }
        else if(pushBeforeLastSuccessStage) {
            this.steps.push({ Name:this.timeTable[key].Name, Id: this.timeTable[key].Id });
        }
        
     } 

}

}