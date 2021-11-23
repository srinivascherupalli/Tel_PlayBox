import { LightningElement,api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class MyComp extends LightningElement {

    @api recordId;
    @api title;
    @api objectName;
    @api fieldAPIName;
    @api showOtherFieldValue;
    
    @wire(getRecord, { recordId: '$recordId', optionalFields: '$fieldAPIName'})
    objectName;

    get detailsArrayObj(){

        var detailsJson;
        var src1 = {};

        //Fetch json value from Object input by design attribute
        if(this.fieldAPIName == 'Case.cusdl_Detail__c'){
            src1 =  getFieldValue(this.objectName.data,this.fieldAPIName);
        }
        else{
            this.showOtherFieldValue = true;
            return false ;            
        }  

        if(src1 != undefined && src1 != null){
            var src1json = JSON.parse(src1);
        }
        //Handling JSON field with key,value to iterate on screen
        if(src1json != undefined && src1json != null){
            detailsJson = Object.entries(src1json).map(([question, answer]) => ({ question, answer }));
            return detailsJson;
        }
        return false;       
    }    

    // showing other field details on screen to make reusable component
    get otherFieldDetails(){
        return getFieldValue(this.objectName.data,this.fieldAPIName);
    }

}