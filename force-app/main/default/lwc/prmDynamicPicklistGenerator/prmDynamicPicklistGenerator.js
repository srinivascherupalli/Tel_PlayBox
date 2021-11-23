import { LightningElement, track, wire, api } from 'lwc';
//import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECTfield from '@salesforce/schema/Case.soc_Request_Type__c';

export default class PrmDynamicPicklistGenerator extends LightningElement {
    @track value;
    @track options;
    @api selObject;
    @api selPicklistField;
    @api recTypeId;
    @api currentPicklistValue;
    @api selValue;
    @api selrequiredcheckbox;
    apiFieldName;

    connectedCallback(){
        console.log('***cmp loading');
        if(this.currentPicklistValue != undefined && this.currentPicklistValue != ''){
            this.selValue = this.currentPicklistValue;
            this.value = this.currentPicklistValue;
            
        }
    }

    @wire(getObjectInfo, { objectApiName: '$selObject' })
    getObjectData({ error, data }) {
        if (data) {
            if (this.currentPicklistValue == null)
                this.currentPicklistValue = data.defaultRecordTypeId;
            this.apiFieldName = this.selObject + '.' + this.selPicklistField;
            this.fieldLabel = data.fields[this.selPicklistField].label;
            
        } else if (error) {
            // Handle error
            console.log('==============Error  ');
            console.log(error);
        }
    }
    
    @wire(getPicklistValues, { recordTypeId:'$currentPicklistValue', fieldApiName: '$apiFieldName' }) 
    IndustryPicklistValues({error, data}) {
        //console.log('fieldApiName==>'+fieldApiName);
        console.log('***cmp'+JSON.stringify(data));
        console.log('Recordtype ID==>'+this.currentPicklistValue);
        if(data) {
            var pickVal = data.values;
            let opts = pickVal.map(a => a.value);
            this.options = pickVal;
            
        }
        else if(error) {
            console.log('error =====> '+JSON.stringify(error));
        }
    }
    get options() {
        return this.options;
    }
    handleChange(event) {
        this.value = event.target.value;
        this.selValue = event.target.value;
    }
}