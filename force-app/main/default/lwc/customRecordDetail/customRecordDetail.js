import { LightningElement, api,wire ,track} from 'lwc';
import updateSObject from "@salesforce/apex/CustomRecordDetailController.updateSObject";
import getporofcontact from "@salesforce/apex/getPORs.getporofcontact";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CustomRecordDetail extends LightningElement {
    // The record page provides recordId and objectApiName
    @api recordId;
    @api objectApiName;
    @api mode;
    @api labelName;
    @track sobjectRecord = {};
    @track showspinner;
    @track error;
   debugger;
   
    @track activeSections = ["RecordSection"];
    @track activeSectionsMessage = "";

	@wire(getporofcontact, { contactId: '$recordId' })
    wiredProperty(value) {
		console.log('(value.data1'+value);
		console.log('(value.data JSON1'+JSON.stringify(value));
        if(value.data) {
		this.mode='view';
			console.log('(value.data 2',value.data);
			console.log('(value.data Mode',this.mode);
			console.log('(value.data JSON2'+JSON.stringify(value.data));
           /* if(value.data.fields.Status__c.value === 'SOW Configuration' || value.data.fields.Status__c.value === 'Rejected'){
                this.isButtonVisible=true;
                this.isButtonDisabled=false;
            }
			*/
        }
		else{
			this.mode='readonly';
			console.log('(value.data Mode2',this.mode);
		}
    }
	
    handleLoad(event) {   
        if (!this.loadedForm) {    
     let fields = Object.values(event.detail.records)[0].fields;
            console.log('Json:',JSON.parse(JSON.stringify(fields)));
            const recordId = Object.keys(event.detail.records)[0];
            this.sobjectRecord = {
                Id: recordId,
                ...Object.keys(fields)
                    .filter((field) => !!this.template.querySelector(`[field-name=${field}]`))
                    .reduce((total, field) => {
                        total[field] = fields[field].value;
                        return total;
                    }, {})
            };
            this.loadedForm = true;
        }
    }
    handleSubmit(event){
        this.showspinner=true;
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        for (var key in fields) {
            if (fields.hasOwnProperty(key)) {
                  this.sobjectRecord[key] = fields[key];
            }
         } 
         updateSObject({objectRec: this.sobjectRecord }).then(
            result =>{
                setTimeout(() => {
                    let start = new Date();
                    let y = 0;
                    while(new Date()-start<3000) {
                        y = y + 1;
                    }
                    this.showspinner=false;
                eval("$A.get('e.force:refreshView').fire();");
                })
                
            }).catch(error => {
                this.showspinner=false;
                    console.log('Error:',error);
                    this.error = (error.body.message).split("FIELD_CUSTOM_VALIDATION_EXCEPTION").pop().replace(",", "").replace(": []", "");
                    const evt = new ShowToastEvent({
                        message: this.error,
                        variant: "error",
                        mode:"dismissable"
                    });
                    this.dispatchEvent(evt);
                });
				

     }

     handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        if (openSections.length === 0) {
          this.activeSectionsMessage = "All sections are closed";
        } else {
          this.activeSectionsMessage = "Open sections: " + openSections.join(", ");
        }
      }
}