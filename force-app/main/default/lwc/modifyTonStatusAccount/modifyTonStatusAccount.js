import { LightningElement, api, track } from 'lwc';
import getSubscriptionsRecordsByAccountId from '@salesforce/apex/ModifyTonStatusAccountController.getSubscriptionsRecordsByAccountId';
import isTonStatusUpdated from '@salesforce/apex/ModifyTonStatusAccountController.updateTonStatus'
import mapJSONToObjects from '@salesforce/apex/DP_PREInterfaceClass.mapJSONToObjects';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
export default class TonStatusAccountLWC extends LightningElement {
    
    showDataTable=false;
    @track isLoaded = false;
    @track toasttitle;
    @track toastmsg
    @track toastvariant;
    @api accountId;
    @api currProfileName;
    @api subscriptionRecords;
    @api tableName = 'SubscriptionTONAccount';
    @track tonBarringStatusAccounts = [];
    selectedTonStatusRecList = [];
    mapOfIdObject;
    @api saveButtonDisbale = false;

   //When the page load, this gets called
    connectedCallback(){
        //alert('connectedCallback');
        this.saveButtonDisbale = true;
        this.setDataTable();
        //console.log('currProfileName :: ' + this.currProfileName);
    }
    // this retriving the data from Apex method getSubscriptionsRecordsByAccountId from Class ModifyTonStatusAccountController and set the data Table
    setDataTable(){
        console.log('--->  Inside callingFromconnectedCallback');
        getSubscriptionsRecordsByAccountId({accountId : this.accountId}) // returns list of subscriptions
        .then(result => {
        if(result !== undefined && 0 < result.length && null !== result){
            this.subscriptionRecords = result;
            this.showDataTable = true; // set to show the data Table
            let subscriptionMap = new Map();
            result.forEach(function(subscription) {
                subscriptionMap.set(subscription.Id, subscription);
                console.log('subscription.id : ' + subscription.Id);
                console.log('subscription : ' + JSON.stringify(subscription) );
            })
            this.mapOfIdObject =  subscriptionMap;
        }
        }).catch(error => {
            console.log('Error in getResult--> ',error);
        });
    }

    // this method calls when we click on back to order buttom
    backToAccount(){
        var url='';
        url=JSON.stringify(window.location.href);
        console.log('url-->'+url);
        if(url.includes('partners.enterprise.telstra.com.au')){
            window.location.href = '/' + this.accountId;
        }
        else if(url.includes('/partners/')){
            window.location.href = '/partners/' + this.accountId;
        }
        else{
            window.location.href = '/' + this.accountId;
        }
	}

    // this method calls once we click on the Save button
    saveRecords(){
        this.tonBarringStatusAccounts = [];
        for(var stausRec of this.mapOfIdObject.values()){
            if(stausRec.tonBarringStatus !== undefined){
                console.log('====== Records to be Saved : '+JSON.stringify(stausRec));
                this.tonBarringStatusAccounts.push(stausRec);
            }
        }
        if(this.tonBarringStatusAccounts.length > 0){
            console.log('########### Passing data : ' + JSON.stringify(this.tonBarringStatusAccounts));
            this.isLoaded = true;
            isTonStatusUpdated({subscriptions : JSON.stringify(this.tonBarringStatusAccounts)})
            .then(result=>{
                console.log('Results : ' + result);
                if(result !== undefined ){
                    if('Success' === result){
                        this.setToastvalues('Success', 'TON Status saved successfully', 'success');
                        this.isLoaded = false;
                        this.tonBarringStatusAccounts.clear();
                        this.mapOfIdObject.clear();
                        return;  
                    }else{
                        this.setToastvalues('Error', result, 'error');
                        this.isLoaded = false;
                        return;  
                    }
                }
            }) .catch(error =>{
                console.log('Exception in saveRecords-->', error);
            }); 
        }
    }

    //Method for Toast Messages
    setToastvalues(toasttitle, toastmsg, toastvariant){
        this.toasttitle = toasttitle;
        this.toastmsg = toastmsg;
        this.toastvariant = toastvariant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }

    updatedata(event){
        this.saveButtonDisbale = false;
        var recData = event.detail;
        var inlineUpdateTonStatus = JSON.parse(recData.recordsString);
        this.selectedTonStatusRecList.push(inlineUpdateTonStatus[0]);
        let subscriptionMap = new Map();
        var subTonRec = JSON.parse(JSON.stringify(this.selectedTonStatusRecList));
        for(var i = 0; i < subTonRec.length; i++){
            subscriptionMap.set(subTonRec[i].id, subTonRec[i]);
            this.mapOfIdObject = subscriptionMap;
        }
    }


        /*
            Object.keys(stausRec).forEach(function (key) {
                let val = stausRec[key];
                console.log('key : ' + key + ' -->> Value : ' +val);
            });
            */


       

}