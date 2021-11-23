import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

export default class DynamicPicklistGenerator extends LightningElement {
    @track value;
    @track options;
    @api selObject = '';
    @api selPicklistField;
    @api selPicklistFieldLabel;
    @api recTypeId = '';
    @api currentPicklistValue;
    @api selValue;
    
    connectedCallback(){
        if(this.currentPicklistValue != undefined && this.currentPicklistValue != ''){
            this.selValue = this.currentPicklistValue;
            this.value = this.currentPicklistValue;
        }
        console.log('this.currentPicklistValue*****'+this.currentPicklistValue);
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: '$selObject' , recordTypeId: '$recTypeId' }) 
    IndustryPicklistValues({error, data}) {
        if(data) {
            console.log('this.selPicklistField*****'+this.selPicklistField);
            var pickName = this.selPicklistField;
            var pickVal = data.picklistFieldValues[pickName].values;
            console.log('pickVal*****'+pickVal);
            this.options = pickVal;
            
        }
        else if(error) {
            console.log('error =====> '+JSON.stringify(error));
        }
    }
    // bugfix for add me to button click DIGI-20987 21.13
    handleChange(event) {
        this.selValue = event.target.value;
        const evt = new CustomEvent('valuechange',{
            detail: { selRole : this.selValue}
        });
        this.dispatchEvent(evt);
    }
}