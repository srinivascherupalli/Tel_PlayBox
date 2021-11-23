/**
   *  Description of the purpose of the method.
   *  @name PrmMACDPOR
   *  @description               : This LWC is to Create or Modify Partner of Record and POR Domain in PRM.
   *  @param                     : Partner of Record Record Id.
   *  @return 				 	 : - 
   *  @Jira Story Ref            : EDGE-210146
   *  @createdBy  				 : Purushottama Sahu, Alexandria
   * 
   *  ** Change Log **
   *  Sl. No.   Developer Name      Date            Story           Description
   *  1.        Pooja               12/05/2021      EDGE-202803     UI Domain View - Multi POR in TPC view # 1
   *  2.        Ajith Kumar         22/06/2021      EDGE-216822     Removed validation for file upload 
**/
import { LightningElement ,wire,api,track} from "lwc";
import {getRecord,getRecordNotifyChange} from 'lightning/uiRecordApi';
import UsrId from '@salesforce/user/Id';
import PartnerAccountId from '@salesforce/schema/User.AccountId';
import PartnerContactId from '@salesforce/schema/User.ContactId';
import PartnerAccountName from '@salesforce/schema/User.Account.Name';
import PartnerContactName from '@salesforce/schema/User.Contact.Name';
import Email_FIELD from '@salesforce/schema/Contact.Email';
import createPOR from '@salesforce/apex/PRM_MACDPORCtrl.createPOR';
import getPORRecord from '@salesforce/apex/PRM_MACDPORCtrl.getPORRecord';
import PORDomainValidation from '@salesforce/apex/PRM_MACDPORCtrl.PORDomainValidation';
import updatePOR from '@salesforce/apex/PRM_MACDPORCtrl.updatePOR';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchProductDomainData from '@salesforce/apex/PRM_MACDPORCtrl.fetchProductDomainData'; //Added:EDGE-202803

export default class PrmMACDPOR extends NavigationMixin(LightningElement) {
    @api recordId;
    @api actionName;
    @track accountName;  
    @track accountRecordId;  
    @track contactId;
	@track contactName;
    @track resConList;
    @track contactfilterStr='Authority__c= \'Full Authority\' AND Contact_Status__c=\'Active\' AND accountid=\' \'';
    @track accountfilterStr='Recordtype.Name= \'Enterprise\'';
    @track isAccReadOnly=false;
    @track partnerAccountName;
    @track partnerContactName;
    @track partnerAccountId;
    @track partnerContactId;
    @track documentId;
    @track disableButton=true;
    @track domain = null;
    @track selectedDomais = null;
    @track cancelDomain;
    @track duration;
    @track accountFields='CIDN__c';
    @track showToastMessage=false;
    @track message;
    @track msgType;
    @track isLoaded=false;
    @track isDataLoaded =false;
    @track optionsDomain = [];  //Modified:EDGE-202803
    SUCESS_MESSAGE = 'Partner of Record agreement has been successfully submitted for review';
    validation_MSG = 'A Partner of Record agreement existes for the selected domains(s) and agreement status is ';
    PORData;
    durationValue ='';
    acceptedFormats=['.pdf', '.PDF'];
    inflightStatusList = ['Initiated','Pending Approval ','Partner Review','Customer Review'];
    optionsDuration=[
        { label: '12 Months', value: '12' },
        { label: '24 Months', value: '24' },
    ];
    

    @wire(getRecord, {recordId: UsrId, fields: [PartnerAccountId,PartnerContactId,PartnerAccountName,PartnerContactName]}) 
    wireuser({error,data}) {
        if (error) {
            this.error = error; 
        } else if (data) {
           if (data.fields.AccountId.value != null) {
               this.partnerAccountId= data.fields.AccountId.value;
               this.partnerAccountName= data.fields.Account.value.fields.Name.value;
           }
           if (data.fields.ContactId.value != null) {
            this.partnerContactId= data.fields.ContactId.value;
            this.partnerContactName= data.fields.Contact.value.fields.Name.value;
       }
       }
    }
    @wire(getRecord, {recordId: '$contactId', fields: [Email_FIELD]}) 
    wireemail({error,data}) {
        this.showToastMessage=false;
        if (data) {
            if (data.fields.Email.value == null) {
                this.showToastMessage=true;
                this.message='Selected contact requires email address';
                this.msgType='error';
                this.showToast();
            }
        }
        this.enableSaveButton();
    }

    @api
    get isModifyFlow(){
        if(this.actionName ==='Modify'){
            return true;
        }return false;
    }
    
    connectedCallback(){

        if(this.actionName =='Modify'){
            this.isAccReadOnly = true;

            getPORRecord({recordId:this.recordId})
            .then(result=>{
                debugger;
                
                this.PORData = result;
                this.optionsDuration.unshift({ label: 'Current Date ('+this.getFormatteDate(this.PORData.End_Date__c) +')', value: 'NoChange' });
                this.durationValue = 'NoChange';
                this.duration = this.durationValue;
                this.isDataLoaded = true;
                this.accountRecordId = this.PORData.Customer__c;
                this.accountName = this.PORData.Customer__r.Name;

                
                this.onAccountSelection();
            })
            .catch(error=>{
                this.message = 'POR Record is unavailable at the moment';
                this.msgType = 'error';
                this.showToastMessage =true;
                this.showToast();
            });
            this.enableSaveButton();
        }
        this.getProductDomainView(); //Added:EDGE-202803
    }

    getFormatteDate = (str) =>{
        let dateArr = str.split("-");
        return dateArr[2]+'/'+dateArr[1]+'/'+dateArr[0];
    }
    
    onAccountSelection(event){ 
        this.accountName = this.accountName ? this.accountName : event.detail.selectedValue ;  
        this.accountRecordId = this.accountRecordId ? this.accountRecordId : event.detail.selectedRecordId;
        //this.accountRecordId = event.detail.selectedRecordId;
        this.contactId=null;
        this.contactName =null;
        this.disableButton=true;
        if(this.accountRecordId != undefined)
        {
        this.contactfilterStr ='Authority__c= \'Full Authority\' AND Contact_Status__c=\'Active\' AND accountid=\''+this.accountRecordId+'\''; 
        this.PORValidation(this.domain);
        }else{
            this.resConList='';
            this.contactfilterStr='Authority__c= \'Full Authority\' AND Contact_Status__c=\'Active\' AND accountid=\' \'';
        }
        this.enableSaveButton();
    }

    onContactSelection(event){
        this.showToastMessage=false;
        this.contactId=event.detail.selectedRecordId;
        this.contactName = event.detail.selectedValue;
        this.disableButton=true;
        //this.enableSaveButton();
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.documentId=uploadedFiles[0].documentId;
        this.enableSaveButton();
    }
   
    durationChange(event){
        this.disableButton=true;
        this.duration=event.detail.value;
        this.enableSaveButton();
    }
    //Removed:EDGE-216822 Removed validation for file upload 
    enableSaveButton(){
        if(this.accountRecordId != null && this.contactId != null && this.domain!=null && Object.keys(this.domain).length >0 
           && this.duration != null && !this.showToastMessage){
            this.disableButton=false;
        }
    }

    handleSave(event){
        this.isLoaded=true;
        var porDetails = {
            porRecordId:this.recordId,
            partnerAccountId:this.partnerAccountId, 
            partnerContactId:this.partnerContactId, 
            accountRecordId:this.accountRecordId,
            contactId:this.contactId,
            domain:this.domain,
            duration:this.duration,
            documentId:this.documentId,
            cancelDomain:this.cancelDomain
        };

        

        if(this.actionName !=='Modify'){
                        createPOR({
                            porDetails  : JSON.stringify(porDetails)
                        })
                        .then(result => {
                            if(result === 'Initiated' || result === 'Pending Approval' || result === 'Partner Review' || result === 'Customer Review'){
                                this.showToastMessage=true;
                                this.message=this.validation_MSG +result;
                                this.msgType='error';
                                this.showToast();
                                this.isLoaded=false;
                            }else{
                            this.showToastMessage=true;
                            this.message=this.SUCESS_MESSAGE;
                            this.msgType='success';
                            this.showToast();
                            
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: result,
                                    actionName: 'view'
                                }
                            
                            });
                        }
                        })
                        .catch(error => {
                            this.isLoaded=false;
                            this.showToastMessage=true;
                            this.message='There was a problem submitting the Partner of Record Agreement. | Try again in a few minutes or raise a Case if this problem continues';
                            this.msgType='error';
                            this.showToast();
                            this.error = error;
                        })
                    }else{
                        updatePOR({
                            porDetails  : JSON.stringify(porDetails)
                        })
                        .then(result => {
                            if(this.statusCheck(result)){
                                this.showToastMessage=true;
                                this.message=this.validation_MSG +result;
                                this.msgType='error';
                                this.showToast();
                                this.isLoaded=false;
                            }else{
                                this.showToastMessage=true;
                                this.message=this.SUCESS_MESSAGE;
                                this.msgType='success';
                                this.showToast();
                                eval("$A.get('e.force:closeQuickAction').fire();");
                                window.location.reload().then(resp=>{
                                });
                            }
                            
                        })
                        .catch(error => {
                            this.isLoaded=false;
                            this.showToastMessage=true;
                            this.message=error.body.message;
                            this.msgType='error';
                            this.showToast();
                        })
                    }
    }

    showToast() {
        var message = this.message;
        var msgType = this.msgType;
        var msgTitle = msgType.split(' ')
                        .map(w => w[0].toUpperCase() + w.substr(1).toLowerCase())
                        .join(' ');
        const event = new ShowToastEvent({
                        title: msgTitle,
                        message: message,
                        variant: msgType,
                        mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    statusCheck(result){
        for (const str of result.split(';')) {
            if(this.inflightStatusList.includes(str)){
                return true;
                break;
            }
        }
    }

    //Added:EDGE-202803 => Used to Fetch Product Domain Name from Object Marketable Offers and Product Category
    getProductDomainView() {
        fetchProductDomainData().then(data=> {
            let selectedDomainArray = [];
            if(this.isDataLoaded) {
                if(this.PORData.Partner_of_Record_Domain__r){
                    this.PORData.Partner_of_Record_Domain__r.forEach(element => {
                        selectedDomainArray.push(element.Domain_Name__c);
                        if(this.domain==null){
                            this.domain = element.Domain_Name__c;
                        } else { 
                            this.domain += ';'+element.Domain_Name__c    
                        }
                    });
                }
            }
            for(let key in data) {
                if (data.hasOwnProperty(key)) { 
                    if(selectedDomainArray != null && selectedDomainArray.includes(key)) {
                        this.optionsDomain.push({key: key, value: data[key],check: true});
                    } else {
                        this.optionsDomain.push({key: key, value: data[key],check: false});
                    }
                }
            }
        }).catch(error=>{
            console.log('error while fetchning Product Domain'+JSON.stringify(error));
            this.message = 'Error while displaying Product Domain';
            this.msgType = 'error';
            this.showToastMessage =true;
            this.showToast();
        });
    }   //End of getProductDomainView()

    //Modified:EDGE-202803
    domainChange(event) {
        this.disableButton=true;
        const domainName = event.target.value;
        const isSelected = event.target.checked;
        for (let index = 0; index < this.optionsDomain.length; index++) {
            if(domainName === this.optionsDomain[index].key) {
                this.optionsDomain[index].check = isSelected;
            } 
        }
        if(isSelected) {
            this.PORValidation(domainName);
            /*if(this.domain == null) {
                this.domain = domainName;
            } else {
                this.domain += ';' + domainName;
            }*/


        } else if(!isSelected && this.domain != null){
            var res = this.domain.split(";");
            this.domain = null;
            for(let i=0; i < res.length; i++) {
                if(res[i] !== domainName) {
                    if(this.domain == null) {
                        this.domain = res[i];
                    } else {
                        this.domain += ';' + res[i];
                    }
                }
            }
        }
        if(this.isDataLoaded){
            this.cancelDomain = null;
            if(this.PORData.Partner_of_Record_Domain__r){
                this.PORData.Partner_of_Record_Domain__r.forEach(element => {
                    if(!this.domain.includes(element.Domain_Name__c)) {
                        if(this.cancelDomain == null){
                            this.cancelDomain = element.Domain_Name__c;
                        } else {
                            this.cancelDomain = this.cancelDomain +';'+element.Domain_Name__c;
                        }
                    }
                });
            }
        }
        this.showToastMessage=false;
	    this.enableSaveButton();
    }   //End of domainChange()
    PORValidation(domainName)
    {

        PORDomainValidation({accountRecordId:this.accountRecordId,partnerAccountId:this.partnerAccountId,selecteddomain:JSON.stringify(domainName),porRecordId:this.recordId})
            .then(result=>{
                if (result) {

                    this.showToastMessage=true;
                    this.message=this.validation_MSG +result;
                    this.msgType='error';
                    for (let index = 0; index < this.optionsDomain.length; index++) {
                        if(domainName === this.optionsDomain[index].key) {
                            this.optionsDomain[index].check = false;
                        } 
                    }
                    this.showToast();
                    if(this.domain !=null && (this.domain.includes(';' + domainName) || this.domain.includes(domainName)) ) {

                        this.domain = (this.domain).replace(';' + domainName,'""').replace(domainName,'""');

                    }
                    return;
                }
                else{

                    if(domainName != 'null' && domainName != null){

                    if(this.domain === null || this.domain === "") {
                        this.domain = domainName;
                    } else { if(!this.domain.includes(domainName)){
                        this.domain += ';' + domainName;
                    }
                }

                }
                    this.enableSaveButton();   
                }
                

		})
    }
}