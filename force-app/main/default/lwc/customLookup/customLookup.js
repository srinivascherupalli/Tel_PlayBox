import { LightningElement, track, api } from 'lwc';
//import PRMSTATICRESOURCE from '@salesforce/resourceUrl/PRMStaticResource';
import PRMSTATICRESOURCE from '@salesforce/resourceUrl/pcIcons';
// Import custom labels
import distributionModelDisabledMessage from '@salesforce/label/c.PRM_Distribution_Model_Configuration';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import distributorSettingDetails from '@salesforce/apex/PRMSharePartnerOpportunity.fetchDistributorSettingDetails';
import findRecords from '@salesforce/apex/PRMSharePartnerOpportunity.findRecords';
import opportunityDetails from '@salesforce/apex/PRMSharePartnerOpportunity.fetchOpportunityDetails';
import partnerDetails from '@salesforce/apex/PRMSharePartnerOpportunity.fetchPartnerDetails';
import updateMethod from '@salesforce/apex/PRMSharePartnerOpportunity.updateOpportunity';

export default class customLookup extends LightningElement {
    @track records;
    @track error;
    @track selectedRecord;
    @api index;
    @api relationshipfield;
    @api iconname = "standard:account";
    @api objectName = 'Account';
    @api searchfield = 'Name';
    @track opportunityRecord;
    @track userRecord;
    @track userType;
    @api recordId;
    @track isLoaded = false;
    @track isDistributorModelEnabled;
    @track distributorModel;
    @track errorMessage
    @track disabledMessage;
    warningIconUrl = PRMSTATICRESOURCE +'/pcIcons/Alert_Small.png';
    helpTextMessage;
    errorBanner;
    // Expose the labels to use in the template.
    label = {distributionModelDisabledMessage};
    //@wire(distributorSettingDetails) isDistributorModelEnabled;
    
    constructor() {
        super();
        this.isDistributorModelEnabled = false;
    }

    connectedCallback(){
        console.log('Opportunity Id in connectedcallback method*****'+this.recordId);
        distributorSettingDetails({})
        .then(result => {
            this.distributorModel = result;
            this.isDistributorModelEnabled = result.isEnabled__c;
            this.helpTextMessage = this.distributorModel.Error_Message_08__c;
            if(!result.isEnabled__c){
                this.disabledMessage = this.distributorModel.Error_Message_07__c;
            }
            this.error = undefined;
            console.log('result.isEnabled__c*****'+result.isEnabled__c);
            if(result.isEnabled__c == undefined){
                this.disabledMessage = this.label.distributionModelDisabledMessage;
                console.log('***disabledMessageWill Be set****');
            }
            console.log('SUCCESS***disabledMessage***'+this.disabledMessage);
        })
        .catch(error => {
            this.error = error;
            this.isDistributorModelEnabled = false;
            this.distributorModel = undefined;
            this.disabledMessage = this.distributionModelDisabledMessage;
            console.log('FAIL***disabledMessage***'+this.disabledMessage);
        });

        partnerDetails({})
        .then(result => {
            this.userRecord = result;
            this.error = undefined;
            if(this.userRecord.Contact.Account.Partner_Type__c == 'Nominate'){
                this.errorMessage = this.distributorModel.Error_Message_01__c;
            }
            console.log(' this.userType '+this.userType);
        })
        .catch(error => {
            this.error = error;
            this.userRecord = undefined;
            console.log(' error '+error);
        });

        opportunityDetails({
            opportunityId : this.recordId
        })
        .then(result => {
            this.opportunityRecord = result;
            this.error = undefined;
            console.log(' this.opportunityRecord.Partner_Opportunity_Verification__c***** '+this.opportunityRecord.Partner_Opportunity_Verification__c);
            console.log(' this.opportunityRecord.SubmittoPartnerStatus__c***** '+this.opportunityRecord.SubmittoPartnerStatus__c);
            console.log(' this.opportunityRecord.DCHOwner__c***** '+this.opportunityRecord.DCHOwner__c);
            console.log(' this.opportunityRecord.Owner.ContactId***** '+this.opportunityRecord.Owner.ContactId);
            console.log(' this.opportunityRecord.Owner.Contact.Account.Partner_Type__c***** '+this.opportunityRecord.Owner.Contact.Account.Partner_Type__c);
            if(this.opportunityRecord.IsClosed){
                this.errorMessage = this.distributorModel.Error_Message_10__c;
                console.log('*****opp is closed*****');
            }else if((this.opportunityRecord.Partner_Opportunity_Verification__c != 'Approved'
            && this.opportunityRecord.Partner_Opportunity_Verification__c != 'Not Applicable'
            && this.opportunityRecord.Partner_Opportunity_Verification__c != '')
            && this.opportunityRecord.SubmittoPartnerStatus__c == undefined){
                this.errorMessage = this.distributorModel.Error_Message_04__c;
                console.log('*****11111');
            }else if((this.opportunityRecord.CreatedBy.ContactId != undefined
                && this.opportunityRecord.CreatedBy.Contact.Account.Partner_Type__c == 'Nominate')
                || this.opportunityRecord.Owner.Contact.Account.Partner_Type__c == 'Nominate'){
                if(this.userRecord.Contact.Account.Partner_Type__c == 'Nominate'){
                    this.errorMessage = this.distributorModel.Error_Message_01__c;
                }else{
                    this.errorMessage = this.distributorModel.Error_Message_09__c;
                }
            }else if(this.opportunityRecord.SubmittoPartnerStatus__c == 'Submitted'){
                if(this.opportunityRecord.DCHOwner__c != undefined
                && this.opportunityRecord.DCHOwner__c != 'undefined'
                && (this.opportunityRecord.DCHOwner__r.ContactId == null
                || this.opportunityRecord.DCHOwner__r.ContactId == 'undefined'
                || this.opportunityRecord.DCHOwner__r.ContactId == undefined)){
                    console.log('this.opportunityRecord.PartnerAccountId*****'+this.opportunityRecord.PartnerAccountId);
                    console.log('this.userRecord.Contact.AccountId*****'+this.userRecord.Contact.AccountId);
                    if(this.opportunityRecord.PartnerAccountId 
                        == this.userRecord.Contact.AccountId){
                        this.errorMessage = this.distributorModel.Error_Message_02__c;
                        console.log('*****22222');
                    }else{
                        this.errorMessage = this.distributorModel.Error_Message_09__c;
                        console.log('*****33333');
                    }
                }else if(this.opportunityRecord.DCHOwner__c != undefined
                    && (this.opportunityRecord.DCHOwner__r.ContactId != null
                    || this.opportunityRecord.DCHOwner__r.ContactId != 'undefined'
                    || this.opportunityRecord.DCHOwner__r.ContactId != undefined)){
                        if(this.opportunityRecord.DCHOwner__r.Contact.AccountId
                        == this.userRecord.Contact.AccountId){
                            this.errorMessage = this.distributorModel.Error_Message_06__c;
                            if(this.opportunityRecord.PartnerAccounId 
                                != this.opportunityRecord.Associated_Distributor__c
                                && this.userRecord.Contact.Account.Partner_Type__c != 'Distributor'){
                                this.errorMessage = this.errorMessage.replace("{!partner}",this.opportunityRecord.Associated_Distributor__r.Name);
                                console.log('*****shared with distributor***');
                            }else{
                                this.errorMessage = this.errorMessage.replace("{!partner}",this.opportunityRecord.PartnerAccount.Name);
                                console.log('*****shared with partner');
                            }
                        }else{
                            this.errorMessage = this.distributorModel.Error_Message_02__c;
                            console.log('*****55555');
                        }
                }else if(this.opportunityRecord.DCHOwner__c == undefined){
                    if(this.opportunityRecord.Owner.Contact.AccountId == this.userRecord.Contact.AccountId){
                        this.errorMessage = this.distributorModel.Error_Message_06__c;
                        this.errorMessage = this.errorMessage.replace("{!partner}",this.opportunityRecord.Associated_Distributor__r.Name);
                        console.log('*****new');
                    }else{
                        this.errorMessage = this.distributorModel.Error_Message_02__c;
                        console.log('*****new 55555');
                    }
                }else{
                    console.log('DID NOT MATCH ANYTHING*********');
                }
            }else if(this.opportunityRecord.SubmittoPartnerStatus__c == 'Approved'
            && this.opportunityRecord.DCHOwner__c != undefined
            && this.opportunityRecord.DCHOwner__c != 'undefined'
            && this.opportunityRecord.DCHOwner__r.ContactId != null
            && this.opportunityRecord.DCHOwner__r.ContactId != 'undefined'
            && this.opportunityRecord.DCHOwner__r.ContactId != undefined){
                if(this.opportunityRecord.DCHOwner__r.Contact.AccountId == this.userRecord.Contact.AccountId){
                    this.errorMessage = this.distributorModel.Error_Message_05__c;
                    console.log('*****66666');
                }else{
                    this.errorMessage = this.distributorModel.Error_Message_03__c;
                    console.log('*****77777');
                } 
            }
            console.log('this.errorMessage*********'+this.errorMessage);
            if(this.errorMessage != undefined && this.errorMessage != ''){
                this.errorBanner = 'We had a problem';
            }
        })
        .catch(error => {
            this.error = error;
            this.opportunityRecord = undefined;
            console.log(' error '+error);
        });
    }

    handleOnchange(event){
        /* Call the Salesforce Apex class method to find the Records */
        findRecords({
            searchKey : event.detail, 
            objectName : this.objectName,
            partnerType : this.userRecord.Contact.Account.Partner_Type__c,
            partnerAccount : this.userRecord.Contact.AccountId
        })
        .then(result => {
            this.records = result;
            for(let i=0; i < this.records.length; i++){
                const rec = this.records[i];
                this.records[i].Name = rec[this.searchfield];
            }
            this.error = undefined;
            //console.log(' records ', this.records);
        })
        .catch(error => {
            this.error = error;
            this.records = undefined;
        });
    }

    handleSelect(event){
        const selectedRecordId = event.detail;
        /* eslint-disable no-console*/
        this.selectedRecord = this.records.find( record => record.Id === selectedRecordId);
        /* fire the event with the value of RecordId for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            'selectedrec',
            {
                //detail : selectedRecordId
                detail : { recordId : selectedRecordId, index : this.index, relationshipfield : this.relationshipfield}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    handleRemove(event){
        event.preventDefault();
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            'selectedrec',
            {
                detail : { recordId : undefined, index : this.index, relationshipfield : this.relationshipfield}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    handleShare(){
        console.log('Share called*********'+this.selectedRecord);
        this.isLoaded = !this.isLoaded;
        const shareClickEvent = new CustomEvent('shareClick', {
            detail: 'success'
        });
        // Fire the custom event
        this.dispatchEvent(shareClickEvent);

        updateMethod({
            accountJson : JSON.stringify(this.selectedRecord), 
            opportunityJson : JSON.stringify(this.opportunityRecord),
            partnerType : this.userRecord.Contact.Account.Partner_Type__c
        })
        .then(result => {
            this.error = undefined;
            console.log(' records ', result);
            if(result == 'Success'){
                console.log('inside success***');
                const shareEvent = new CustomEvent('partnerShare', {
                    detail: 'success'
                });
                // Fire the custom event
                this.dispatchEvent(shareEvent);

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Opportunity shared successfully',
                        variant: 'success'
                    })
                );
            }else{
                console.log('inside error***');
                const closeClickEvent = new CustomEvent('shareClick', {
                    detail: 'success'
                });
                // Fire the custom event
                this.dispatchEvent(closeClickEvent);

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'error'
                    })
                );
            }
        })
        .catch(error => {
            this.error = error;
        });
        this.isLoaded = !this.isLoaded;
    }

    handleCancel(){
        console.log('Cancel called*********');
    }
}