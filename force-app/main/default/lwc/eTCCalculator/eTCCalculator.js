import { api, LightningElement } from 'lwc';
import grtServiceDetails from '@salesforce/apex/ETCCalculatorController.grtServiceDetails';
import getDataForCMP from '@salesforce/apex/ETCCalculatorController.getDataForCMP';
import getETCChargesForAM from '@salesforce/apex/SolutionActionHelper.getETCChargesForAM';
import getETCChargesForCMPDevice from '@salesforce/apex/ETCCalculatorController.getETCChargesForCMPDevice';
import getLabels from '@salesforce/apex/ETCCalculatorController.getLabels';
import getETCChargesForNGUC from '@salesforce/apex/SolutionActionHelper.getETCChargesForNGUC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ETCCalculator extends LightningElement {
    @api recordId;
    serviceName;
    //nickName;
    contractTerm;
    activationDate;
    etcNotesData;
    disconnectionDate = new Date();
    dateSelected = false;
    etcCharges;
    etcTerm;
    remainingTerm;
    macdeviceConfigID;
    deviceConfigID;
    dmCatCheck;
    marketableOffer;
    loaded=true;
    ProdConfigId
    inputMap = new Map();
    inputMap2 = {
        'ProdConfigId' : '',
        'DisconnectionDate' : '',
        'ContractTerm' : '',
        'etc_Term' : '',
        'MarketableOffer__c' : '',
        'deviceConfigID' : '',
        'macdeviceConfigID' : ''
    }
    connectedCallback(){
        console.log('record id is ',this.recordId);

        getLabels()
        .then(result => {
            this.etcNotesData = result
        })

        if(this.recordId !== undefined && this.recordId !== ''){
            grtServiceDetails({
                subscriptionId : this.recordId
            })
            .then(result => {
                console.log('result ',result);
                    if(result['Result'] === 'success'){
                       this.serviceName = result['csord__Subscription__c']['Name'];
                       //this.nickName=result['csord__Subscription__c']['Nickname__c'];
                       console.log('activation date ',result['csord__Subscription__c']['Initial_Activation_DateTime__c']);
                       var actDate = new Date(result['csord__Subscription__c']['Initial_Activation_DateTime__c']);
                      // console.log('activation date nw ',actDate.format('dd-mm-yyyy'));
                      if(actDate !== null && actDate !== undefined && this.checkConditiond(result)){
                        this.activationDate =  actDate.getDate()+'-'+(actDate.getMonth()+1)+'-'+actDate.getFullYear();
                        this.etcTerm = result['csord__Subscription__c']['Contract_Term__c'];
                        this.contractTerm = result['csord__Subscription__c']['Contract_Term__c'];
                        this.ProdConfigId = result['csord__Subscription__c']['csordtelcoa__Product_Configuration__c'];
                        this.marketableOffer = result['csord__Subscription__c']['MarketableOffer__r']['Offer_ID__c'];
                        this.macdeviceConfigID = result['csord__Subscription__c']['csordtelcoa__Product_Configuration__c'];
                        this.deviceConfigID = result['csord__Subscription__c']['csordtelcoa__Product_Configuration__c'];
                        this.dmCatCheck = result['dm_cat_check'];
                      }
                    }else if(result['Active Error'] === 'ETC Charges are available only for active subscriptions'){
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message:result['Active Error'],
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                        let delay = 4000;
                        setTimeout(() => {
                            window.location.reload();
                        }, delay );
                    }
                    else if(result['Result'] === 'Error with no service'){
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message:result['message'],
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                        let delay = 4000;
                        setTimeout(() => {
                            window.location.reload();
                        }, delay );
                        
                    }else if(result['Result'] === 'ETC Charges are available only for active subscriptions'){
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message:result['message'],
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                        let delay = 4000;
                        setTimeout(() => {
                            window.location.reload();
                        }, delay );
                    }else if(result['Result'] === 'Error'){
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message:result['message'],
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                        let delay = 4000;
                        setTimeout(() => {
                            window.location.reload();
                        }, delay );
                    }else if(result['Result'] === 'Marketable Offer Error'){
                        console.log('inside marketable offer error');
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message:result['message'],
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                        let delay = 4000;
                        setTimeout(() => {
                            window.location.reload();
                        }, delay );
                    }
            })
            .catch(error => {
                console.log('error ',error);
            })
        }
    }
    onCalculate(event){
       if(this.dateSelected){
        console.log('inside oncalculate');
        console.log('loaded ',this.loaded);
        this.loaded = false;
        var inputmapvalue = JSON.parse(JSON.stringify(this.inputMap));
        console.log('input map value ',this.inputMap2);
       /* getETCChargesForAM({
            inputMap : this.inputMap2
        })
        .then(result => {
            console.log('loaded ',this.loaded);
            console.log('calling get etc charges ',result);
            if(result['ETCcharges'] !== 'Error' && result['ETCcharges'] !== '0.00'){
                this.etcCharges = '$'+result['ETCcharges']+'.00';
            }else if(result['ETCcharges'] === '0.00'){
                this.etcCharges = '$'+result['ETCcharges'];
            }else{
                this.etcCharges = result['ETCcharges'];
            }
            this.remainingTerm = result['RemainingTerm'];
            this.loaded = true;
        })
        .catch(error => {
            console.log('error in calling get etc charges ',error);
        })
       }else{
        const evt = new ShowToastEvent({
            title: 'Error',
            message:'Please enter disconnection date',
            variant: 'error',
        });
        this.dispatchEvent(evt);
       }*/
       this.checkDeviceType(this.inputMap2);
       
      }
    }
    handleDisconnectedDateChange(event){
        console.log('date value is * ',event.target.value);
        if(event.target.value === null || event.target.value === undefined ){
            this.dateSelected = false;
        }else{
            var dateVal = event.target.value;
            this.dateSelected = true;
            console.log('date format ',typeof(dateVal));
            var day = parseInt(dateVal.split('-')[2],10);
            var month = parseInt(dateVal.split('-')[1],10);
            var year = parseInt(dateVal.split('-')[0],10);
            var selectedDate = new Date();
            selectedDate.setFullYear(year, month, day);
            var currentDate = new Date();
            console.log('selected date ',dateVal);
            console.log('cuurent date ',currentDate);
            if(selectedDate.getFullYear() >= currentDate.getFullYear()){
                 console.log('selectedDate day ',selectedDate.getDate());
                 console.log('currentDate day ',currentDate.getDate());
                 console.log('selectedDate month ',selectedDate.getMonth());
                 console.log('currentDate month ',currentDate.getMonth()+1);
                 console.log('check equal ',selectedDate.getMonth() === (currentDate.getMonth()+1));
                  if(selectedDate.getDate() < currentDate.getDate() && selectedDate.getMonth() === (currentDate.getMonth()+1) && selectedDate.getFullYear() === currentDate.getFullYear()){
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message:'Please enter valid date',
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    this.dateSelected = false;
                      this.disconnectionDate = undefined;
              }else{
                this.disconnectionDate = dateVal;
                this.inputMap.set('ProdConfigId',this.ProdConfigId);
                this.inputMap.set('DisconnectionDate',dateVal);
                this.inputMap.set('ContractTerm',this.contractTerm);
                console.log('map after setting values ',this.inputMap);
                this.inputMap2['ProdConfigId'] = this.ProdConfigId;
                this.inputMap2['DisconnectionDate'] = dateVal;
                this.inputMap2['ContractTerm'] = this.contractTerm;
                this.inputMap2['etc_Term'] = this.etcTerm;
                this.inputMap2['deviceConfigID'] = this.deviceConfigID;
                this.inputMap2['macdeviceConfigID'] = this.macdeviceConfigID;
                console.log('map after setting values ',this.inputMap2);
              }
            
               
            }else{
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message:'Please enter valid date',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.dateSelected = false;
                this.disconnectionDate = undefined;
            }
        }
        
    }
    checkDeviceType(subscriptionRecord){
        console.log('inside checkDeviceType');
        console.log('MarketableOffer__c ',this.marketableOffer);
        if(this.dmCatCheck === 'AM'){
            this.callChargesForAM();
        }
        else if(this.dmCatCheck === 'CMP'){
            this.callChargesForCMP();
        }
        else if(this.dmCatCheck === 'NGUC'){
            this.callChargesForNGUC();
        }
    }
    callChargesForAM(){
        console.log('calling etc charges for AM');
        getETCChargesForAM({
            inputMap : this.inputMap2
        })
        .then(result => {
            console.log('loaded ',this.loaded);
            console.log('calling get etc charges ',result);
            if(result['ETCcharges'] !== 'Error' && result['ETCcharges'] !== '0.00' && result['ETCcharges'] !== '0.0' &&  !result['ETCcharges'].includes('.0')){
                this.etcCharges = '$'+result['ETCcharges']+'.00';
            }else if(result['ETCcharges'] === '0.00' || result['ETCcharges'] === '0.0' || result['ETCcharges'].includes('.0')){
                this.etcCharges = '$'+result['ETCcharges'];
            }else{
                this.etcCharges = result['ETCcharges'];
            }
            this.remainingTerm = result['RemainingTerm'];
            this.loaded = true;
        })
        .catch(error => {
            console.log('error in calling get etc charges ',error);
        })
    }
    callChargesForCMP(){
        console.log('inside callChargesForCMP');
        let cmpInputMap = {};
       // cmpInputMap['ProdConfigId'] = this.ProdConfigId;
        cmpInputMap['DisconnectionDate'] = this.inputMap2['DisconnectionDate'];
        cmpInputMap['ContractTerm'] = this.contractTerm;
        cmpInputMap['etc_Term'] = this.etcTerm;
        getDataForCMP({
            subscriptionId : this.recordId
        })
        .then(result => {
            console.log('cmp ',result);
            if(result['InitailActivationDate'] !== undefined && result['InitailActivationDate'] !== '' && result['ProdConfigId'] !== undefined && result['ProdConfigId'] !== ''){
                cmpInputMap['InitailActivationDate'] = result['InitailActivationDate'];
                cmpInputMap['subscriptionId'] =  this.recordId;
                cmpInputMap['ProdConfigId'] = result['ProdConfigId'];
                console.log('cmpInputMap ',cmpInputMap);
                this.callETCChargesForCMP(cmpInputMap);
            }
            
        })
    }
    callChargesForNGUC(){
        console.log('inside nguc');
        getETCChargesForNGUC({
            inputMap : this.inputMap2
        })
        .then(result => {
            console.log('loaded ',this.loaded);
            console.log('calling get etc charges ',result);
            if(result['ETCcharges'] !== 'Error' && result['ETCcharges'] !== '0.00' && result['ETCcharges'] !== '0.0' &&  !result['ETCcharges'].includes('.0')){
                this.etcCharges = '$'+result['ETCcharges']+'.00';
            }else if(result['ETCcharges'] === '0.00' || result['ETCcharges'] === '0.0' || result['ETCcharges'].includes('.0')){
                this.etcCharges = '$'+result['ETCcharges'];
            }else{
                this.etcCharges = result['ETCcharges'];
            }
            this.remainingTerm = result['RemainingTerm'];
            this.loaded = true;
        })
        .catch(error => {
            console.log('error in calling get etc charges ',error);
        })
    }

    checkConditiond(result){
        let condition;
        if(result['csord__Subscription__c'] !== undefined && result['csord__Subscription__c'] !== null){
           if(result['csord__Subscription__c']['Contract_Term__c'] !== undefined && result['csord__Subscription__c']['Contract_Term__c'] !== null &&  result['csord__Subscription__c']['csordtelcoa__Product_Configuration__c'] !== null &&  result['csord__Subscription__c']['csordtelcoa__Product_Configuration__c'] !== undefined && result['csord__Subscription__c']['MarketableOffer__r'] !== null && result['csord__Subscription__c']['MarketableOffer__r'] !== undefined){
            condition = true;
           }else{
               console.log('check condition inside else');
            condition = false;
           }
        }else{
            console.log('condition are false');
            condition = false;
        }
        return condition;
    }


    callETCChargesForCMP(cmpInputMap){
        getETCChargesForCMPDevice({
            inputMap : cmpInputMap
        })
        .then(result => {
            console.log('loaded ',this.loaded);
            console.log('calling get etc charges ',result);
            if(result['ETCcharges'] !== 'Error' && result['ETCcharges'] !== '0.00' && result['ETCcharges'] !== '0.0' &&  !result['ETCcharges'].includes('.0') && !result['ETCcharges'].includes('.')){
                this.etcCharges = '$'+result['ETCcharges']+'.00';
            }else if(result['ETCcharges'] === '0.00'  || result['ETCcharges'] === '0.0' || result['ETCcharges'].includes('.0')){
                this.etcCharges = '$'+result['ETCcharges'];
            }else{
                this.etcCharges = '$'+result['ETCcharges'];
            }
            this.remainingTerm = result['RemainingTerm'];
            this.loaded = true;
        })
        .catch(error => {
            console.log('error in calling get etc charges ',error);
        })
    }
}