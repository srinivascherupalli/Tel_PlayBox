/*
Added by Team Hawaii for P2OB-5311
Date: 23rd Nov 2020
*/
import { LightningElement, track, wire, api } from 'lwc';
import userId from '@salesforce/user/Id';
import { getRecord, createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import prmFeedbackLabel from '@salesforce/label/c.prmFeedbackCmpLabel';
import rateYourExperience from '@salesforce/label/c.rateYourExperience';
import provideASuggestion from '@salesforce/label/c.provideASuggestion';
import tellExperience from '@salesforce/label/c.Tell_Your_Experience';
import raiseACase from '@salesforce/label/c.raiseACase';
import tpcImageBaseUrl from '@salesforce/label/c.TPC_Feedback_Static_Resource_Base_URL';
import CASE_OBJECT from '@salesforce/schema/Case';
import FEEDBACK_FIELD from '@salesforce/schema/Case.Feedback_Type__c';
import URL_FIELD from '@salesforce/schema/Case.TPC_URL__c';
import MODULE_FIELD from '@salesforce/schema/Case.Functionality_Module__c';
import DESC_FIELD from '@salesforce/schema/Case.Description';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import PRIORITY_FIELD from '@salesforce/schema/Case.Priority';
import RECORD_TYPE from '@salesforce/schema/Case.RecordTypeId';
import STATUS_TYPE from '@salesforce/schema/Case.Status';
import ACCOUNT_ID from '@salesforce/schema/Case.AccountId';
import RELATED_TO from '@salesforce/schema/Case.Feedback_Related_to__c';
import WORK_REQUIRED from '@salesforce/schema/Case.Work_Required_PRM__c';
import CATEGORY_PRM from '@salesforce/schema/Case.Category_PRM__c';
import SUPPORT_TYPE from '@salesforce/schema/Case.Support_Type_PRM__c';
import REQUESTER from '@salesforce/schema/Case.Requestor__c';

import { reduceErrors } from 'c/ldsUtils';

export default class PrmFeedbackComponent extends LightningElement {

    //is on first screen
    isFirstScreen = true;

    //Show spinner
    @track isLoading = false;

    //Username of logged-in User
    UserName = '';

    //User id to populate requester field
    UserId;

    //Text from Label
    textForFeedback;

    //Show Modal Pop Up Window
    isShowModal = false;

    //Show thank you component
    showThankYouComponent = false;

    //Track which option is clicked
    isFirstCardClicked = false;
    isSecondCardClicked = false;
    isThirdCardClicked = false;
    isEmoticonClicked = false;

    //Positive/Neutral or Negative
    selectedFeedback;

    //User Greeting on first screen
    userGreeting;

    //Account id
    @api accountId;

    //Option Images
    headerImage = tpcImageBaseUrl + "headerBanner.png";
    experienceImage = tpcImageBaseUrl + "rateYourExperience.png";
    suggestionImage = tpcImageBaseUrl + "suggestions.png";
    caseImage = tpcImageBaseUrl + "raiseACase.png";
    buttonIcon = tpcImageBaseUrl + "buttonIcon1.png";

    //Emoticon Images
    happyUnactivated = tpcImageBaseUrl + "happyUnactivated.png";
    neutralUnactivated = tpcImageBaseUrl + "neutralUnactivated.png";
    badUnactivated = tpcImageBaseUrl + "badUnactivated.png";
    happyActivated = tpcImageBaseUrl + "happyActivated.png";
    neutralActivated = tpcImageBaseUrl + "neutralActivated.png";
    badActivated = tpcImageBaseUrl + "badActivated.png";
    iconGood = tpcImageBaseUrl + "goodCheck.png";
    iconBad = tpcImageBaseUrl + "badCheck.png";
    iconNeutral = tpcImageBaseUrl + "neutralCheck.png";

    //Show Submit, Back and Close Button
    showSubmitButton = false;
    showBackButton = false;
    showCloseButton = true;

    //Check which button was clicked
    clickedtargetid;

    //Case fields
    caseId = '';
    caseNum;
    feedbackRelatedTo;
    @track caseInfo;

    //Store all labels in a collection variable to expose to DOM
    labels = {
        rateYourExperience,
        provideASuggestion,
        raiseACase,
        tellExperience
    };

    //Object variable to toggle emoticon images
    @track emoticons = {
        showGoodActivated: false,
        showNeutralActivated: false,
        showBadActivated: false
    }

    //Get logged in user name
    @wire(getRecord, { recordId: userId, fields: ['User.FirstName', 'User.LastName', 'User.Id'] })
    userData({ error, data }) {
        if (data) {
            let objCurrentData = data.fields;
            this.UserName = objCurrentData.FirstName.value + ' ' + objCurrentData.LastName.value;
            this.UserId = objCurrentData.Id.value;

        }

        else if (error) {
            console.log('error ====> ' + JSON.stringify(error))
        }
    }

    //Get case record type
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseInfo;

    get RecordTypeId() {
        // Returns a map of record type Ids 
        const rtis = this.caseInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Channel Care for Partners');
    }

    //Handle emoticon click
    handleEmoticonClick(event) {
        let clickedIcon = event.currentTarget.dataset.id;
        this.selectedFeedback = event.currentTarget.dataset.value;

        this.isEmoticonClicked = true;
        this.showSubmitButton = true;

        if (clickedIcon == "happyUnactivated") {
            this.emoticons.showGoodActivated = true;
            this.emoticons.showNeutralActivated = false;
            this.emoticons.showBadActivated = false;
        }

        if (clickedIcon == "neutralUnactivated") {
            this.emoticons.showGoodActivated = false;
            this.emoticons.showNeutralActivated = true;
            this.emoticons.showBadActivated = false;
        }

        if (clickedIcon == "badUnactivated") {
            this.emoticons.showGoodActivated = false;
            this.emoticons.showNeutralActivated = false;
            this.emoticons.showBadActivated = true;
        }
    }

    //Check which card was clicked
    handleCardClick(event) {

        this.isFirstScreen = false;
        this.clickedtargetid = event.currentTarget.dataset.id;

        if (this.clickedtargetid == "rateYourExperience") {
            this.feedbackRelatedTo = "Experience Feedback";
            this.isFirstCardClicked = true;
            this.isSecondCardClicked = false;
            this.isThirdCardClicked = false;
            this.showBackButton = true;
            this.showCloseButton = false;
        }

        if (this.clickedtargetid == "provideASuggestion") {
            this.feedbackRelatedTo = "Suggestion Feedback";
            this.isSecondCardClicked = true;
            this.isFirstCardClicked = false;
            this.isThirdCardClicked = false;
            this.showSubmitButton = true;
            this.showBackButton = true;
            this.showCloseButton = false;
        }

        if (this.clickedtargetid == "raiseACase") {
            const invokeflow = new CustomEvent('invokeflow', {
                detail: {},
            })
            // Fire the custom event to be handled by enclosing Aura Componenrt
            this.dispatchEvent(invokeflow);
        }
    }

    ////Handle back button
    handleBack() {
        this.isFirstScreen = true;
        this.showCloseButton = true;
        this.isEmoticonClicked = false;
        this.isFirstCardClicked = false;
        this.isSecondCardClicked = false;
        this.showSubmitButton = false;
        this.showBackButton = false;
    }

    //Show Thank you component
    showThankYouCmp() {
        this.headerImage = tpcImageBaseUrl + "thankYou.png";
        this.isLoading = false;
        this.showCloseButton = true;
        this.showThankYouComponent = true;
        this.isFirstCardClicked = false;
        this.isSecondCardClicked = false;
        this.isEmoticonClicked = false;
        this.showBackButton = false;
        this.showSubmitButton = false;
    }

    //Handle onclick of submit button
    handleSubmit() {
        this.isLoading = true;
        //Call child method
        this.template.querySelector("c-prm-feedback-child-cmp").fetchCaseDetails();
    }

    getValues(event) {
        let data = event.detail;

        //If error is blank, submit data to create a case at the backend
        if (data.errMsg == '') {
            const fields = {};
            fields[RECORD_TYPE.fieldApiName] = this.RecordTypeId;
            fields[STATUS_TYPE.fieldApiName] = 'Closed';
            fields[URL_FIELD.fieldApiName] = data.ipUrl;
            fields[MODULE_FIELD.fieldApiName] = data.ipModule;
            fields[REQUESTER.fieldApiName] = this.UserId;
            fields[DESC_FIELD.fieldApiName] = data.ipDesc;
            fields[PRIORITY_FIELD.fieldApiName] = 'Low';
            if(this.clickedtargetid == "rateYourExperience"){
                fields[SUBJECT_FIELD.fieldApiName] = 'Rate your experience - ' + data.ipModule;
                fields[FEEDBACK_FIELD.fieldApiName] = this.selectedFeedback;
            }else{
                fields[SUBJECT_FIELD.fieldApiName] = 'Provide a Suggestion / Idea - ' + data.ipModule;
            }
            fields[ACCOUNT_ID.fieldApiName] = this.accountId;
            fields[RELATED_TO.fieldApiName] = this.feedbackRelatedTo;
            fields[WORK_REQUIRED.fieldApiName] = 'TPC Feedback';
            fields[CATEGORY_PRM.fieldApiName] = 'Other support';
            fields[SUPPORT_TYPE.fieldApiName] = 'TPC Support';

            const recordInput = { apiName: CASE_OBJECT.objectApiName, fields };

            createRecord(recordInput)
                .then(caseCreated => {
                    this.caseId = caseCreated.id;
                    this.caseNum = caseCreated.fields.CaseNumber.value;
                    //Show thank you screen component
                    this.showThankYouCmp();
                    //Send record id to child to upload file
                    this.template.querySelector("c-prm-feedback-child-cmp").uploadFile(this.caseId);
                })
                .catch(error => {
                    this.isLoading = false;
                    this.errors = reduceErrors(error); // code to execute if the promise is rejected
                    console.log('errors are ->' + JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
        } else {
            //Logic to execute if error message is not blank
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'One or more required fields missing.',
                    message: data.errMsg,
                    variant: 'error',
                }),
            );

        }

    }

    //Show Modal on button click
    showModal() {
        this.isShowModal = true;
        this.userGreeting = 'Hi ' + this.UserName + ','
        this.textForFeedback = prmFeedbackLabel;
    }

    //Handle Close button
    @api closeModal() {
        this.isShowModal = false;
        this.showThankYouComponent = false;
        this.showBackButton = false;
        this.headerImage = tpcImageBaseUrl + "headerBanner.png";
        this.isFirstScreen = true;
        this.showCloseButton = true;
        this.isFirstCardClicked = false;
        this.isSecondCardClicked = false;
        this.isThirdCardClicked = false;
    }
}