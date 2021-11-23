/*
 *@Created Date : 29/10/2021
 *@Created By   : Nitin Kumar
 *@Breif        : DIGI-24328 This LWC is used show sync status with basket and refresh the opportunity once it is in sycn
 */
import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getJobId from '@salesforce/apex/CheckAsyncJobDetails.getJobId';
import toCheckSyncJobCompletion from '@salesforce/apex/CheckAsyncJobDetails.toCheckSyncJobCompletion';
import fetchPrimaryBasketDetails from '@salesforce/apex/CheckAsyncJobDetails.fetchPrimaryBasketDetails';
import handleException from '@salesforce/apex/CheckAsyncJobDetails.handleException';
export default class AutoRefreshOpprutunityPostSync extends NavigationMixin(LightningElement) {
    jobName;
    primaryBasket;
    @api recordId; 
    @api progress = 5000;
    jobidList = [];
    asyncStatus;
    message = '';
    jobId = '';

    connectedCallback() {
        this.jobName = "noInFlightBatch";
        fetchPrimaryBasketDetails({ opptyId : this.recordId})
        .then(result => {
            this.primaryBasket = result;
            this.error = undefined;
            if((this.primaryBasket.RecordType != null && this.primaryBasket.RecordType != undefined) &&  this.primaryBasket.RecordType.Name == 'Inflight Change'){
                this.jobName = "syncJobId";
            }
            
            /*
            *Fetch the async job batch id depending on jobName as paramter
            */
            
            if (this.jobName) {
                getJobId({
                    name: this.jobName,
                    basketId: this.primaryBasket.Id
                })
                .then((result1) => {
                    for(let key in result1) {
                        if(key === this.jobName){
                            this.jobId = result1[key].id;
                        }

                    }
                    // if Job Id is not blank check for it's status
                    if (this.jobId) {
                        this.jobidList.push(this.jobId);
                        toCheckSyncJobCompletion({
                            jobId: this.jobidList
                        })
                        .then((jobResult) => {
                            if(jobResult) {
                                for(let key1 in jobResult) {
                                    if(key1 === this.jobId){
                                        this.asyncStatus = jobResult[key1].Status;
                                    }
                                }
                            }
                            // make the second call only if this.asyncStatus != Completed/Failed 
                            this.secondCall();
                        })
                        .catch((error) => {
                            handleException({
                                methodName : 'AutoRefreshOpprutunityPostSync',
                                exceptiongetMessage : error,
                                codeMessage : '400'
                            })
                        });
                    }
                    
                })
                .catch((error) => {
                    handleException({
                        methodName : 'AutoRefreshOpprutunityPostSync',
                        exceptiongetMessage : error,
                        codeMessage : '400'
                    })
                });
            }
        })
        .catch(error => {
            handleException({
                methodName : 'AutoRefreshOpprutunityPostSync',
                exceptiongetMessage : error,
                codeMessage : '400'
            })
        });
    }

    secondCall(){
        if(this.asyncStatus != 'Completed' && this.asyncStatus != 'Failed'){
            this.message = 'Product Basket is yet to be sync with this opportunity.';
            // keep making calls until Job get finished
            this._interval = setInterval(() => {
                this.progress = this.progress + 10000;
                toCheckSyncJobCompletion({
                    jobId: this.jobidList
                })
                .then((jobResult2) => {
                    if(jobResult2) {
                        for(let key2 in jobResult2) {
                            if(key2 === this.jobId){
                                this.asyncStatus = jobResult2[key2].Status;
                            }
                        }
        
                    }
                    if(this.asyncStatus === 'Completed' || this.asyncStatus === 'Failed'){
                        clearInterval(this._interval);
                        // once job is completed or failed refresh the opportunity page
                        this.navigateToOpportunity();
                    }
                })
                .catch(error => {
                    handleException({
                        methodName : 'AutoRefreshOpprutunityPostSync',
                        exceptiongetMessage : error,
                        codeMessage : '400'
                    })
                });
                
            },this.progress);
        }
    }

    navigateToOpportunity(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId : this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            },
        });
    }
}