import { api, LightningElement, track } from 'lwc';
import getSolutions from '@salesforce/apex/InflightSolutionController.getSolutions';
import getSolutionsOnSerach from '@salesforce/apex/InflightSolutionController.getSolutionsOnSerach';
import getSubscriptions from '@salesforce/apex/InflightSolutionController.getSubscriptions';
import checkQueuedJobStatus from '@salesforce/apex/InflightBasketUtility.checkQueuedJobStatus';
import checkPONR from '@salesforce/apex/PONROrderItemHandler.syncExecute';
import onAmend from '@salesforce/apex/InflightSolutionController.onAmend';
import getJobStatus from '@salesforce/apex/InflightSolutionController.getJobStatus';
import getTargetMainConfigurationId from '@salesforce/apex/InflightSolutionController.getTargetMainConfigurationId';
import postInflightBasketProcessing from '@salesforce/apex/InflightSolutionController.postInflightBasketProcessing';
import updateBasketAndOpty from '@salesforce/apex/InflightSolutionController.updateBasketAndOpty';
import dmCategoryCheck from '@salesforce/apex/InflightSolutionController.checkForDMCategory';
import getOrderNumber from '@salesforce/apex/InflightSolutionController.getOrderNumber';
import getOrderDetails from '@salesforce/apex/InflightSolutionController.getOrderDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
 
export default class InflightSolutionLWCComponent extends NavigationMixin(LightningElement) {
 
    @track genericError = false;
    @track solutionColums='';
    @track solutionData=[];
    @api recordId;
    @api requestorRemoved;
    @api tesltraCaseNumber;
    @api isAssuranceServiceAgentProdile;
    @track searchVal;
    @track disableAmendButton = true;
    @track subscriptionData = '';
    @track subscriptionColumn = '';
    @track showModal = false;
    @track solutionCount = 0;
    @track selectedRowCount = 0;
    @track visible = false;
    @track amendResult;
    @track showAmendMessage = false;
    @track cannotCheckPONR = false;
    @track isLoading = false;
    @track isBasketLoadingSingle = false;
    @track isBasketLoadingMultiple = false;
    @track showAmendError = false;
    @track showCaseRequestorError = false;
    @track showCaseNumberError = false;
    @track continueInflightBasketCreation;
    @track ponrApiError = false;
    @track amendTypeNotSelected = false;
    @api caseRequestorRecord;
    @api amendType;
    @api amendRejected = false;
    @track dmcaterror = false;
    @track amendRejectedError = false
    selectedSolutionsForAmend = [];
    solutionListToCheckPONR = [];
    orderNumber;
    orderRecord;
    solutionMap = new Map();
    batchFailedError = false;
    connectedCallback(){
 
        console.log('amemd=ed rejected ',this.amendRejected);
        getOrderDetails({
            orderId : this.recordId
        })
        .then(result => {
            console.log('order detail ',result);
            this.orderRecord = result;
            console.log('job id ',this.orderRecord);
            var status;
            this.isLoading = true;
            console.log(' JOB id CHECK ',this.orderRecord[0]['Push_Heroku_Configurations_Job_Id__c']);
         var state = this.callBatchClass(this.orderRecord[0]['Push_Heroku_Configurations_Job_Id__c']);
         if(state === 'Sucess'){
             this.isLoading = false;
         }
        })
        .catch(error => {
            console.log('error in getiing order details');
        })

        getOrderNumber({
            orderId : this.recordId
        })
        .then(result => {
            console.log('order number is ',result);
            this.orderNumber = result;
        })
        .catch(error =>{
            console.log('error in getting order number');
        })
        
        this.isLoading = true;
        this.selectedSolutionsForAmend = [];
        console.log('Component loading');
        console.log('this.caseRequestorRecord ',this.caseRequestorRecord);
        console.log('disableAmendButton ',this.disableAmendButton);
        this.serachVal = '';
        console.log('order Id '+this.recordId);
        this.solutionColums =  [
            {
                type:  'showSub',
                fieldName: 'Name',
                label: 'Name',
                initialWidth: 780,
                typeAttributes:
                {
                    attrA: { fieldName: 'Id' },
                    attrB: { fieldName: 'Name' },
                }

            },
            {
                type: 'text',
                fieldName: 'amendAllowed',
                label: 'Amendment Allowed',
                initialWidth: 780,
            },
        ];

        this.subscriptionColumn = [
            { label: 'Name', fieldName: 'recordurl', type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                },
                target: '_blank'
            }
         },
            { label: 'Subscription Number', fieldName: 'csordtelcoa__Subscription_Number__c', type: 'text' },
            { label: 'Status', fieldName: 'csord__Status__c', type: 'text' },
            { label: 'Service Id', fieldName: 'customerFacingServiceId__c', type: 'text' },
            { label: 'Amendment Allowed', fieldName: 'amendAllowed', type: 'text' },
            { label: 'Estimated PONR Date', fieldName: 'estiatedPONRDate', type: 'text' }
        ];

        getSolutions({
            orderId : this.recordId
        })
        .then(result => {
            console.log('result',result);
            this.solutionData = result;
            this.solutionCount = result.length;
            this.solutionListToCheckPONR = result;
            this.isLoading = false;
            for(let i=0;i<result.length;i++){
                this.solutionMap.set(result[i]['Id'],result[i]['amendAllowed']);
            }
        })
        .catch(error => {
            console.log('error in fetching details');
            this.isLoading = false;
        })
       
    }

    renderCallback(){
        console.log('inside render callback ');
        this.selectedRows = this.template.querySelector('c-show-sub-cell-button-helper').getSelectedRows();
        if(this.selectedRows.lrngth > this.solutionData.length){
            alert('error');
        }
    }
 
    handleSelectedRow(event){
        console.log('executing');
        console.log('selected row is ',event.detail.selectedRows);
        event.detail.selectedRows = '';
    }

    handleSearch(event){
        console.log('calling handle search');
        this.searchVal = event.target.value;
        var serahVal = event.target.value;
        console.log('searched key word is '+this.searchVal);
        getSolutionsOnSerach({
            searchKey : serahVal,
            orderId : this.recordId
        })
        .then(result => {
            console.log('reuslt for searh ', result);
            if(result!==undefined){
                this.solutionData = result['Solution list'];
                this.solutionCount = result['Solution list'].length; 
            }else{
                result = undefined;
            }
        })
        .catch(error => {
            console.log('error is searching ',error);
        })
    }

    showpoponsub(event){
        console.log(' showSubPopup event.rowId -->', event.detail.rowId);
        console.log(' showSubPopup event.attrA -->', event.detail.solId);
        var solId = event.detail.solId;
        console.log('Search val is '+this.searchVal);
        var srchkey;
        if(this.searchVal!==undefined || this.searchVal!==''){
            srchkey = this.searchVal;
        }else{
            srchkey = '';
        }
       console.log('solutionMap ',this.solutionMap);
       console.log('this.solutionMap.get(solutionId) ',this.solutionMap.get(solId));
        getSubscriptions({
            solutionId : solId,
            serachKey :srchkey,
            orderId : this.recordId,
            amendRejected : this.amendRejected,
            amendAllowed : this.solutionMap.get(solId)
        })
        .then(result =>{
            this.subscriptionData = result;
            console.log('subscriptions ',result);
            this.showModal = true;
            
        })
        .catch(error => {
            console.log('error is getting subscription ',error);
        })
    }

    closeModal(event){
        this.showModal = false;
    }

    handleRowSelection(event){
       // alert('selected row '+this.template.querySelector('c-show-sub-cell-button-helper').selectedRows);
        this.selectedSolutionsForAmend = [];
        this.listOfSolutionIds = [];
       if( this.template.querySelector('c-show-sub-cell-button-helper').getSelectedRows()!== undefined){
        this.selectedRows = this.template.querySelector('c-show-sub-cell-button-helper').getSelectedRows();
        console.log('this.selectedRows -->', this.selectedRows);
        console.log('Selected Rows Length -->', this.selectedRows.length);
        this.selectedRowCount =  this.selectedRows.length;
        var rowsSelected =  this.selectedRows;
        
       
 

        for(var i=0;i<rowsSelected.length;i++){
            if(rowsSelected[i].amendAllowed!=='Yes' && !this.amendRejected){
                console.log('wrong soln selection event');
                const evt = new ShowToastEvent({
                    title: 'Toast Error',
                    message: 'Some unexpected error',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                    let delay = 4000;
                    this.genericError = true;
                    this.visible = true;
                    setTimeout(() => {
                        console.log('inside time out');
                        this.visible = false;
                        this.genericError = false;
                    }, delay );
                    this.template.querySelector('c-show-sub-cell-button-helper').selectedRows = undefined;
            }
            if(rowsSelected[i].amendAllowed==='Yes' || this.amendRejected){
                    console.log('inside yes amend');
                    var rowElement = rowsSelected[i];
                    console.log('row element ',rowElement);
                    this.selectedSolutionsForAmend.push(rowElement);
                    console.log('selectedSolutionsForAmend ',this.selectedSolutionsForAmend);
 
                    dmCategoryCheck({
                        solutionId : rowsSelected[i].Id
                    }).
                    then( result => {
                        console.log('dm category ',result);
                        if(!result && !this.amendRejected){
                                let delay = 4000;
                                this.genericError = true;
                                this.dmcaterror = true;
                                console.log('dmcaterror ',this.dmcaterror);
                                setTimeout(() => {
                                    console.log('inside time out')
                                    this.dmcaterror = false;
                                    this.genericError = false;
                                }, delay );
                                this.template.querySelector('c-show-sub-cell-button-helper').selectedRows = undefined;
                        }
                    })
                    .catch( error => {
                        console.log('dm category ',error);
                    })
            }
            
        }
    }
    }
 
    handlePONR(event){     
        console.log('case requestor ',this.caseRequestorRecord);
        console.log('amend tyep ---> ',this.amendType);
        console.log('telstra case number ---> ',this.tesltraCaseNumber);
        console.log('soution list ',this.solutionListToCheckPONR);
        var solnList = this.solutionListToCheckPONR;
        let noSolutionCount = 0;
        var fieldsMissing = false;
      /*  if(this.requestorRemoved){
            console.log('case reuester not selected');
            this.showCaseRequestorError = true;
            let delay = 4000;
            fieldsMissing = true;
            setTimeout(() => {
                console.log('inside time out')
                this.showCaseRequestorError = false;
            }, delay );
        }else if(this.tesltraCaseNumber === '' && this.isAssuranceServiceAgentProdile){
            console.log('case number blank');
            this.showCaseNumberError = true;
            let delay = 4000;
            fieldsMissing = true;
            setTimeout(() => {
                console.log('inside time out')
                this.showCaseNumberError = false;
            }, delay );
        }else if(this.amendType === '' || this.amendType===undefined){
            console.log('amend type not selected');
            this.amendTypeNotSelected = true;
            let delay = 4000;
            fieldsMissing = true;
            setTimeout(() => {
                console.log('inside time out')
                this.amendTypeNotSelected = false;
            }, delay );
        }*/
 
        for(let i=0;i<solnList.length;i++){
            console.log('amend allowed '+solnList[i]['amendAllowed']);
            if(solnList[i]['amendAllowed'] === 'Yes' || this.amendRejected){
               break;
            }else{
                noSolutionCount++;
            }
        }
        if(noSolutionCount === solnList.length && !this.amendRejected){
                this.genericError = true;
                this.cannotCheckPONR = true;
        }
       if(!this.cannotCheckPONR){
           console.log('job id ',this.orderRecord);
           var state;
           this.isLoading = true;
           console.log(' JOB id CHECK ',this.orderRecord[0]['Push_Heroku_Configurations_Job_Id__c']);
         if(this.orderRecord[0]['Push_Heroku_Configurations_Job_Id__c'] !== undefined){
            state = this.callBatchClass(this.orderRecord[0]['Push_Heroku_Configurations_Job_Id__c']);
            if(state === 'Sucess'){
                this.isLoading = true;
            }
         }

       
           console.log('ponr can be checked ');
        if(this.orderRecord.Push_Heroku_Configurations_Job_Id__c === undefined || state === 'Sucess'){
            checkPONR({
                OrderId : this.orderNumber
            })
            .then(result => {
                this.isLoading = false;
            console.log('result after calling ponr ',result);
            this.disableAmendButton = false;
            this.connectedCallback();
            this.isLoading = false;
        })
        .catch(error => {
            console.log('error in calling ponr ',error);
                this.disableAmendButton = false;
                this.isLoading = false;
                this.genericError = true;
                this.ponrApiError = true;
                let delay = 4000;
                                    console.log('ponrApiError ',this.ponrApiError);
                                    setTimeout(() => {
                                        console.log('inside time out')
                                        this.ponrApiError = false;
                                        this.genericError = false;
                                    }, delay );
            })
           }else{
            let delay = 4000;
            setTimeout(() => {
                console.log('inside time out')
                this.cannotCheckPONR = false;
                this.genericError = false;
            }, delay );
           }
        }
        this.template.querySelector('c-show-sub-cell-button-helper').selectedRows = undefined;
    }

    handleAmend(event){
        console.log('requestor removed '+this.requestorRemoved);
        console.log('teslstra case number '+this.tesltraCaseNumber);
        console.log('inside handle ammend');
        console.log('order id '+this.recordId);
        console.log('selected solutions ',this.selectedSolutionsForAmend);
        var solutionList = this.selectedSolutionsForAmend;
        console.log('solutionList '+solutionList.length);
       // this.template.querySelector('c-show-sub-cell-button-helper').maxRowSelection=0;
        //this.template.querySelector('c-show-sub-cell-button-helper').maxRowSelection=solutionList.length;
       // var solutionList = this.selectedSolutionsForAmend;
       let solutionIds = [];
       var amendRejectedSelection = true;
       console.log('amendRejectedSelection 2',amendRejectedSelection);
       console.log('amendRejected ',this.amendRejected);
       if(solutionList.length !== this.solutionCount && this.amendRejected){
           console.log('inside amend rejected checking ');
        amendRejectedSelection = false;
       // this.amendRejectedError = true;
        let delay = 4000;
        this.genericError = true;
        this.amendRejectedError = true;
        setTimeout(() => {
            console.log('inside time out');
            this.amendRejectedError = false;
            this.genericError = false;
        }, delay );
       // alert('please select all the solutions');
       }
        for(var i=0;i<solutionList.length;i++){
            console.log('Inside the solution id loop');
            solutionIds.push(this.selectedSolutionsForAmend[i]['Id']);
        }
        console.log('solution id set ',solutionIds);
        console.log('amendRejectedSelection 2',amendRejectedSelection);
        if(solutionList.length !== 0 && !this.requestorRemoved && (this.tesltraCaseNumber!=='' || !this.isAssuranceServiceAgentProdile ) && amendRejectedSelection){
            if(solutionList.length > 1)
            {
                this.isBasketLoadingSingle = false;
                this.isBasketLoadingMultiple = true;
            }
            else if(solutionList.length == 1){
                this.isBasketLoadingMultiple = false;
                this.isBasketLoadingSingle = true;
            }
            onAmend({
                orderId : this.recordId,
                solutionIdSet : solutionIds,
                teslStraCaseNumber : this.tesltraCaseNumber,
                amendType : this.amendType
            })
            .then(result => {
                if(result.includes('error')){
                    this.isBasketLoadingSingle = false;
                    this.isBasketLoadingMultiple = false;
                    var errorMessage = result.split("=");
                    console.log('amended ',result);
                    this.amendResult = errorMessage[1];
                    if(result!=='' && result!==null){
                        this.genericError = true;
                        this.showAmendMessage = true;
                        this.continueInflightBasketCreation = false;
                        let delay = 4000;
                        setTimeout(() => {
                            this.showAmendMessage = false;
                            this.genericError = false;
                        }, delay);
                    }
                }
                else{
                    console.log('basket created successfully and the result is ' , result);
                    var resultObj = JSON.parse(result);
                    console.log(Object.keys(resultObj)[0]);
                    console.log(Object.keys(resultObj)[0]);
                    this.continueInflightBasketCreation = true;
                    var basketId = Object.keys(resultObj)[0];
                    var data = resultObj[Object.keys(resultObj)[0]];
                    console.log('basket id is ', basketId);
                    console.log('data is ', data);
                    var refreshIntervalId = setInterval(function () {
                        getJobStatus({
                            'targetBasketid': basketId
                        })
                        .then(result2 => {
                            console.log('Return Result is ', result2);
                            if (result2 == 'SUCCESS') {
                                console.log('Return Result is aaaa  ', result2);
                                clearInterval(refreshIntervalId);
                                getTargetMainConfigurationId({
                                    'basketId': basketId,
                                    'data': JSON.stringify(data)
                                })
                               .then(result3 => {
                                    console.log('getTargetMainConfigurationId Result is ', result3);
                                    if(result3 !== '')
                                    {
                                        postInflightBasketProcessing({
                                            'data': JSON.stringify(data),
                                            'replacedMainConfigurationId': result3
                                        })
                                        .then(result4 => {
                                            console.log('postInflightBasketProcessing Result is ', result4);
                                            if(result4 != '' && result4 == 'SUCCESS'){
                                                updateBasketAndOpty({
                                                    'basketId': basketId,
                                                    'amendType': this.amendType,
                                                    'caseId': this.tesltraCaseNumber
                                                }).then(result5 => {
                                                    if(result5 == "SUCCESS"){
                                                        this.isBasketLoadingSingle = false;
                                                        this.isBasketLoadingMultiple = false;
                                                        var url = window.location.href ;
                                                        var urlToRedirect ='';
                                                        if(url.indexOf('partner') != -1) {
                                                            urlToRedirect = "/partners/s/product-basket/" + basketId;
                                                            }//DIGI-23334 Starts
                                                        else if(url.includes('partners.enterprise.telstra.com.au')){
                                                            urlToRedirect = "/s/product-basket/" + basketId;
                                                            }//DIGI-23334 Ends
                                                        else {
                                                            urlToRedirect = "/" + basketId;
                                                            }
 
                                                        console.log('URL', urlToRedirect);
                                                        
                                                        window.location.href = urlToRedirect;
                                                        
                                                        // this[NavigationMixin.Navigate]({
                                                        //     type: 'standard__recordPage',
                                                        //     attributes: {
                                                        //         recordId: basketId,
                                                        //         objectApiName: 'cscfga__Product_Basket__c',
                                                        //         actionName: 'view'
                                                        //     }
                                                        // });
                                                    }
                                                    else{
                                                        this.isBasketLoadingSingle = false;
                                                        this.isBasketLoadingMultiple = false;
                                                        console.log('there is some error updaing basket or opty');
                                                        this.amendResult = 'Error Updaing Basket or Opportunity';
                                                        this.showAmendMessage = true;
                                                        this.continueInflightBasketCreation = false;
                                                        let delay = 4000;
                                                        setTimeout(() => {
                                                            this.showAmendMessage = false;
                                                        }, delay);
                                                    }
                                                })
                                                
                                            }
                                            else{
                                                this.isBasketLoadingSingle = false;
                                                this.isBasketLoadingMultiple = false;
                                                console.log('There is some error Pushing to Heroku');
                                                this.amendResult = 'Error Pushing to Heroku';
                                                this.showAmendMessage = true;
                                                this.continueInflightBasketCreation = false;
                                                let delay = 4000;
                                                setTimeout(() => {
                                                    this.showAmendMessage = false;
                                                }, delay);
                                            }
                                        })
                                    }
                                    else
                                    {
                                        this.isBasketLoadingSingle = false;
                                        this.isBasketLoadingMultiple = false;
                                        console.log('Not able to fetch targetMainConfigurationId');
                                        this.amendResult = 'Error fetching main Configuration Id';
                                        this.genericError = true;
                                        this.showAmendMessage = true;
                                        this.continueInflightBasketCreation = false;
                                        let delay = 4000;
                                        setTimeout(() => {
                                            this.showAmendMessage = false;
                                            this.genericError = false;
                                        }, delay);
                                    }
                                })
                            }
                            else if (result2 == 'Error') {
                                this.isBasketLoadingSingle = false;
                                this.isBasketLoadingMultiple = false;
                                console.log('There is some error fetching job Status');
                                this.amendResult = 'There is some error fetching job Status';
                                this.showAmendMessage = true;
                                this.continueInflightBasketCreation = false;
                                let delay = 4000;
                                setTimeout(() => {
                                    this.showAmendMessage = false;
                                }, delay);
                            }
                        })
                        
                    }.bind(this), 5000);
                }
            })
            .catch(error=>{
                this.isBasketLoadingSingle = false;
                this.isBasketLoadingMultiple = false;
                console.log('error in amend ',error);
            })
        }else{
          
          if(!this.amendRejected){
            this.isBasketLoadingSingle = false;
            this.isBasketLoadingMultiple = false;
            if(this.requestorRemoved){
                console.log('case reuester not selected');
                this.genericError = true;
                this.showCaseRequestorError = true;
                let delay = 4000;
                setTimeout(() => {
                    console.log('inside time out')
                    this.showCaseRequestorError = false;
                    this.genericError = false;
               }, delay );
           }
           else if(this.tesltraCaseNumber === '' && this.isAssuranceServiceAgentProdile){
               console.log('case number blank');
                this.genericError = true;
                this.showCaseNumberError = true;
                let delay = 4000;
                setTimeout(() => {
                    console.log('inside time out')
                    this.showCaseNumberError = false;
                    this.genericError = false;
                }, delay );
            }
            else if(this.amendType === ''){
             console.log('amend type not selected');
             this.genericError = true;
             this.amendTypeNotSelected = true;
             let delay = 4000;
             setTimeout(() => {
                 console.log('inside time out')
                 this.amendTypeNotSelected = false;
                 this.genericError = false;
             }, delay );
         }else  if(solutionList.length == 0){
             this.genericError = true;
             this.showAmendError = true;
             let delay = 4000;
             setTimeout(() => {
                 console.log('inside time out')
                 this.showAmendError = false;
                 this.genericError = false;
               }, delay );
           }
        }
    }
}


    callBatchClass(jobId){
        console.log('inside reccursive method '+jobId);
        var result;
        this.isLoading = true;
       if(jobId!== undefined){
        checkQueuedJobStatus({
            jobID : jobId
        })
        .then(result => {
            console.log('job result ',result);
            status = result;
            if(result === 'Processing'){
                console.log('batch processing');
                this.callBatchClass(jobId);
            }else if(result === 'Completed'){
                console.log(' batch successs');
                result = 'Success';
                this.isLoading = false;
            }else if(result === 'Aborted' || result === 'Failed'){
                console.log('error in batch');
                result = 'Error';
                this.isLoading = false;
                let delay = 4000;
                this.genericError = true;
                this.batchFailedError = true;
                setTimeout(() => {
                    console.log('inside time out');
                    this.batchFailedError = false;
                    this.genericError = false;

                      // Generate a URL to a User record page
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view',
            },
        }).then(url => {
            this.recordPageUrl = url;
        });

                }, delay );

            }
        })
        .catch(error => {
            console.log('error in getting job result ',error);
        })
       }else{
           this.isLoading = false;
       }
        return result;
    }
}