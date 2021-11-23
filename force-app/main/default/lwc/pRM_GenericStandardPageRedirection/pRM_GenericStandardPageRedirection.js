/*
Modified By : Team Hawaii
Date : 22 Sept 2020
Jira No: 9639
Description: Generic component to open standard object page on click of button
*/

import { LightningElement,api,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class NavToNewRecordWithDefaults extends NavigationMixin(LightningElement) {

    //Design property variable to store record type label
    @api recordTypeName = '';
    //Design property variable to store button label
    @api buttonLable = '';
    //Design property variable to store object api name
    @api objectName = '';
    //Design property variable to store default field values
    @api jsonString = '';
    //Design property variable to store action name (new,home,list)
    @api actionName = '';
    //local variable to store record id 
    recordTypeId = '';
    //variable to store error
    @track error;

    //get button label
    get fetchbuttonLabel(){
        return this.buttonLable != '' ? this.buttonLable : 'Generic Button';
    }

    //   getObjectInfo - get record type detail associated with an object
    @wire(getObjectInfo, {objectApiName: '$objectName'})
    getObjectdata({error,data}){
        if(data){
            if(this.recordTypeName != '' && data.recordTypeInfos != undefined && Object.keys(data.recordTypeInfos).length !== 0){
                //get record type id from record type name
                this.recordTypeId = this.getRecordTypeId(data.recordTypeInfos) != undefined ? this.getRecordTypeId(data.recordTypeInfos) : '';
            }else if(this.recordTypeName == '' && data.defaultRecordTypeId != undefined){
                //get default record type id
                this.recordTypeId = data.defaultRecordTypeId;
            }
        }else if(error){
            //set error variable if there is any error
            this.error = error;
            this.recordTypeId = undefined;
        }
    }

    //method to get record type id based on record type name
    getRecordTypeId(recordTypeInfoList){
        //get first record which match with record type name
        return Object.keys(recordTypeInfoList).find(rti => recordTypeInfoList[rti].name === this.recordTypeName);
    }


    //event fired on click of button to open standard record creation page
    navigateToDefinedAction = (event) => {
        event.preventDefault();
        let defaultValues = this.jsonString != '' ?
            encodeDefaultFieldValues(
                JSON.parse(this.jsonString)
            ) : '';
        
        //if action is new record creation
        if(this.actionName == 'new'){
            //check if record type is not blank
            //create record of defined record type
            if(this.recordTypeId != '' && this.recordTypeId != undefined){
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: this.objectName,
                        actionName: this.actionName
                    },
                    state: {
                        defaultFieldValues:  defaultValues,
                        recordTypeId: this.recordTypeId 
                    }
                });
            //if no record type is created on object
            }else{
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: this.objectName,
                        actionName: this.actionName
                    },
                    state: {
                        defaultFieldValues:  defaultValues,
                    }
                });
            }
        //if action is other than 'new'
        }else{
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: this.objectName,
                    actionName: this.actionName
                },
            })
        }
    }
}