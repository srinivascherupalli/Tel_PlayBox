import { LightningElement, api, wire } from 'lwc';
import getPreChatDetails from '@salesforce/apex/PreChatDetailsController.getPreChatData';

export default class PreChatDetails extends LightningElement {
    @api recordId;

    firstName='';
    lastName='';
    email='';
    phone='';
    company='';


    @wire(getPreChatDetails, { currentRecordId: '$recordId' })
    parsePreChatDetails(value) {
        const { data, error } = value;
        if (data) {
            this.preChatDetailsHandler(data);
            console.log(JSON.stringify(data));
        } else if (error) {
            console.error(JSON.stringify(error));
        }
    }

    preChatDetailsHandler(data) {
        this.firstName = data.PreChat_FirstName__c;
        this.phone = data.PreChat_Phone_Number__c;
        this.email = data.PreChat_Email__c;
        this.lastName = data.PreChat_LastName__c;
        this.company = data.Company_Name__c;
    }
}