import { LightningElement, track, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getSIMnumber from '@salesforce/apex/PortOutReversalController.getSIMnumber';
import isNumberValid from '@salesforce/apex/PortOutReversalController.isNumberValid';
import createNumberRecord from '@salesforce/apex/PortOutReversalController.createNumberRecord';
import SIMExpiredMessage from '@salesforce/label/c.SIMExpiredMessage';
import PortOutReversalValidNumberError from '@salesforce/label/c.PortOutReversalValidNumberError';
import PortOutReversalNumberNotFound from '@salesforce/label/c.PortOutReversalNumberNotFound';
import PortOutReversalNumberStatus from '@salesforce/label/c.PortOutReversalNumberStatus';
/** as part of EDGE-166187 starts  **/
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import SIM_Type__c from '@salesforce/schema/Number__c.SIM_Type__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Number_Object from '@salesforce/schema/Number__c';
/** as part of EDGE-166187 Ends  **/
import SimAvailabilityType__c from '@salesforce/schema/Number__c.SimAvailabilityType__c'; //EDGE-170886

export default class ValidateNumberComponent extends LightningElement {
    label = {
        SIMExpiredMessage,
        PortOutReversalValidNumberError,
        PortOutReversalNumberNotFound,
        PortOutReversalNumberStatus
    };
    @track enteredNumber;
    @track radioValue = '';
    @api simSerialNumber;
    @track isdisabled = false;
    @track error;
    @api pcid;
    @api imsi;
    @track toasttitle;
    @track toastmsg;
    @track loadspinner = false;
    @track toastvariant;
    @track daysLeft=0;
    @track isExistingChecked = false;
    @track isInactiveChecked = false;
    /** as part of EDGE-166187 starts  **/    
    @api solutionnameval;
    @track simvalues = [];
    @track inactiveSIM;
    @track existingsimvalue;
    @track simoption;
    @track SimAvailabilityvalue;
    
    connectedCallback(){
        if(this.solutionnameval == "Adaptive Mobility"){
            this.isAdaptiveMobility = true;
        }
    }

    @wire(getObjectInfo, { objectApiName: Number_Object })
    numberInfo;

    @wire(getPicklistValues,
        {
            recordTypeId: '$numberInfo.data.defaultRecordTypeId' ,
            fieldApiName: SIM_Type__c
        }
    )    
    simTypeValues;
    /** as part of EDGE-166187 Ends  **/
    @wire(getPicklistValues,
        {
            recordTypeId: '$numberInfo.data.defaultRecordTypeId' ,
            fieldApiName: SimAvailabilityType__c
        }
    )    
    simAvailabilityValues;

    get options() {
        return [
            { label: 'Use existing deactivated SIM', value: 'existingSIM' },
            { label: 'Use new inactive SIM', value: 'inactiveSIM' },
        ];
    }
    
    /**********************************************************************************************************
    EDGE        - 142347
    Method      - handleClear 
    Description - handleClear
    Author      - Kalashree Borgaonkar
    ************************************************************************************************************/
    handleClear() {
        console.log('in clear');
        this.enteredNumber = '';
        this.simSerialNumber = '';
        this.isExistingChecked =false;
        this.isInactiveChecked =false;
        this.isdisabled = false;
        this.existingsimvalue = null; 
        this.SimAvailabilityvalue = null;
    }
    /**********************************************************************************************************
    EDGE        - 142347
    Method      - handleEntereNumberChange
    Description - handleEntereNumberChange
    Author      - Kalashree Borgaonkar
    ************************************************************************************************************/
    handleEntereNumberChange(event) {
        this.enteredNumber = event.target.value;
        console.log('this.enteredNumber', this.enteredNumber);
    }
    /**********************************************************************************************************
    EDGE        - 166187
    Method      - handlechange
    Description - handlechange
    Author      - Veena Putta
    ************************************************************************************************************/
    handlechange(event){
        this.existingsimvalue = event.target.value;
        console.log('this.existingsimvalue', this.existingsimvalue);
    }
    /**********************************************************************************************************
    EDGE        - 142347
    Method      - handleSimNumberChange
    Description - handleSimNumberChange
    Author      - Kalashree Borgaonkar
    ************************************************************************************************************/
    handleSimNumberChange(event) {
        this.simSerialNumber = event.target.value;
        console.log('this.simSerialNumber', this.simSerialNumber);
    }
    /**********************************************************************************************************
    EDGE        - 142347, EDGE-164617. 
    Method      - onradioButtonClick
    Description - onradioButtonClick
    Author      - Kalashree Borgaonkar
    Update      - Check for SIM expiry
    ************************************************************************************************************/
    onradioButtonClick(event) {
        this.isInactiveChecked = false;
        this.isExistingChecked = false;
        var temSimVal = []; //as part of EDGE-166187

        console.log('get radiovalue', event.target.value);
        console.log(this.enteredNumber);
        
        // EDGE-166187,added boolean values and SIM Type picklist values
        //const selectedOption = event.target.value;
       // this[event.target.name] = event.target.value;       
        this.SimAvailabilityvalue = event.target.value;
        
        if (this.SimAvailabilityvalue == 'Existing Active SIM') { 
            this.isInactiveChecked = false;

            temSimVal.push({ label: 'SIM card', value: 'SIM card' });
            this.simvalues = temSimVal;

            //EDGE-165480. Check for number validity
            if (!(this.enteredNumber.startsWith('04') || this.enteredNumber.startsWith('614'))) {
                this.setToastvalues('Error', PortOutReversalValidNumberError, 'error');
                return;
            }
            if (this.enteredNumber.length < 10 || this.enteredNumber.length > 11) {
                this.setToastvalues('Error', PortOutReversalValidNumberError, 'error');
                return;
            }
            getSIMnumber({
                selectedNumber: this.enteredNumber
            })
                .then(result => {
                    console.log('result data:', result);
                    if(result.numberDetail!=null){
                        this.simSerialNumber = result.numberDetail.Sim_Serial_Number__c;
                        this.imsi=result.numberDetail.IMSI__c;
                    }
                    this.daysLeft= result.daysLeft;
                    console.log('this.daysLeft: ',this.daysLeft);
                    if(result.daysLeft>0){
                        this.setToastvalues('Info', result.validationMessage, 'info');
                    }
                    else{
                        this.setToastvalues('Error', result.validationMessage, 'error'); 
                    }
                    console.log('result simSerialNumber:', this.simSerialNumber);
                })
                .catch(error => {
                    console.log('error data:', error);
                    this.error = error;
                })
           this.isExistingChecked = true;
          // this.isInactiveChecked = false;
            this.isdisabled = true;
            this.loadspinner = false;
            this.simoption = this.SimAvailabilityvalue;
        }
        else if(this.SimAvailabilityvalue == 'Existing Blank SIM'){
            this.isExistingChecked = false;
            this.isInactiveChecked = true;

            temSimVal.push(
                { label: 'eSim', value: 'eSIM' },
                { label: 'SIM card', value: 'SIM card' }
            );
            this.simvalues = temSimVal;
            this.isdisabled = false;
            this.loadspinner = false;
            this.simSerialNumber = '';
            this.simoption = this.SimAvailabilityvalue;
        }
        else { 
            temSimVal.push(
                { label: 'eSim', value: 'eSIM' },
                { label: 'SIM card', value: 'SIM card' }
            );
            this.simvalues = temSimVal;                
            this.simoption = this.SimAvailabilityvalue;
            this.simSerialNumber = '';
            this.isdisabled = true;
            this.loadspinner = false;
             //this.isInactiveChecked = true;
            // this.isExistingChecked = false;
        }
    }
    /**********************************************************************************************************
    EDGE        - 142347
    Method      - handleValidateAndSave
    Description - handle validate and save
    Author      - Kalashree Borgaonkar
    ************************************************************************************************************/
    handleValidateAndSave() {
        console.log('@V@ this.SimAvailabilityvalue ', this.SimAvailabilityvalue);
        //EDGE - 142347 Added condition to check fro blank string
        if (this.enteredNumber == null || this.enteredNumber == undefined || this.enteredNumber =='') {
            this.setToastvalues('Error', 'Mobile number is mandatory', 'error');
            return;
        }
        if (!(this.enteredNumber.startsWith('04') || this.enteredNumber.startsWith('614'))) {
            this.setToastvalues('Error', PortOutReversalValidNumberError, 'error');
            return;
        }
        if (this.enteredNumber.length < 10 || this.enteredNumber.length > 11) {
            this.setToastvalues('Error', PortOutReversalValidNumberError, 'error');
            return;
        }
         
        //SIMSerial validation is not application for New SIM - EDGE-170886
        if(this.SimAvailabilityvalue != 'New SIM') {
            if ((this.simSerialNumber == null) || (this.simSerialNumber != null && (this.simSerialNumber.length != 13))) {
                    //show toast - Invalid SIM Serial Number
                    this.setToastvalues('Error', 'Invalid SIM Serial Number', 'error');
                    return;
            }
         } 

        if(this.isAdaptiveMobility){
                if (this.existingsimvalue == '--Select--' || this.existingsimvalue =='' || this.existingsimvalue == null ) {
                    this.setToastvalues('Error', 'SIM Type is mandatory', 'error');
                    return;
                }
        }
        if(!this.isAdaptiveMobility){
            this.existingsimvalue = 'SIM card';
        }       
       

         //EDGE-164617. check if SIM is expired
         console.log('this.daysLeft:::: ',this.daysLeft);
         console.log('@V@ this.isExistingChecked', this.isExistingChecked);
        if (this.daysLeft <=0 && (this.isExistingChecked == true)) {
            console.log();
            this.setToastvalues('Error', SIMExpiredMessage, 'error');
            return;
        }
        this.loadspinner = true;

        //as part of EDGE-166187
        console.log('this.simoption' ,this.simoption);            
        createNumberRecord({
            selectedNumber: this.enteredNumber,
            pcid: this.pcid,
            sim: this.simSerialNumber,
            imsi: this.imsi,
            simType: this.existingsimvalue,
            simAvailability: this.simoption, 
            neworExistingSIM: this.SimAvailabilityvalue
        })

            .then(result => {
                console.log('result on create: ', result);
                if(result.includes('InfoMsg')){
                    this.setToastvalues('Info', result.replace("InfoMsg",""), 'info');
                    const refreshEvent = new CustomEvent("refreshcreatenumber");
                    this.dispatchEvent(refreshEvent);
                }else if(result.includes('ErrorMsg')){
                    this.setToastvalues('Error', result.replace("ErrorMsg",""), 'error');
                    return;
                }
                else{
                    this.setToastvalues('Success', result.replace("SuccessMsg",""), 'success');
                    const refreshEvent = new CustomEvent("refreshcreatenumber");
                    this.dispatchEvent(refreshEvent);
                } 
            })
            .catch(error => {
                console.log('error data:', error);
                this.error = error;
            })
        this.loadspinner = false;
        

    }
    /**********************************************************************************************************
    EDGE        - 142347
    Method      - setToastvalues
    Description - set toast values
    Author      - Kalashree Borgaonkar
    ************************************************************************************************************/
    setToastvalues(toasttitle, toastmsg, toastvariant) {
        this.toasttitle = toasttitle;
        this.toastmsg = toastmsg;
        this.toastvariant = toastvariant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }

}