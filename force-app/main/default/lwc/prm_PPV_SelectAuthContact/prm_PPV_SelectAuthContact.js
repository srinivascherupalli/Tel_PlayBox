/*
* P2OB - 11853 : LWC Component to display details of Auth-Rep-Contacts for PPV
* Created By   : Team Hawaii : Ritika Jaiswal
*/

import { LightningElement, track, wire , api} from 'lwc';
import retrieveContactData from '@salesforce/apex/PRM_PPV_controller.retrieveContactData';


export default class Prm_PPV_SelectAuthContact extends LightningElement {
   
   @track columns = [

        { label: 'Name', fieldName: 'Name' , type: 'text'},

        { label: 'Number', fieldName: 'MobilePhone' ,type: 'text'},
        { label: 'Type', fieldName: 'Authority__c' ,type: 'text'},
    ];
   @track currentContactName;

   @track NoContactsFound;

   @api accountId;
   @api contactName_Selected;
   @api contactNumber_Selected;
   @api contactAuth_Selected;

   handleChangeContactName(event){
      this.currentContactName = event.target.value;      
    }
 
    handleContactSelection(event){
       const selectedRows = event.detail.selectedRows; 
       for ( let i = 0; i < selectedRows.length; i++ ){     
            this.contactName_Selected = selectedRows[i].Name;
            this.contactNumber_Selected = selectedRows[i].MobilePhone;
            this.contactAuth_Selected = selectedRows[i].Authority__c;
       }
       console.log('selected contact',this.selectedRows );
    }
    
    connectedCallback() {
        this.currentContactName = '';


    }

    

    @track records;
    @track dataNotFound;
    @wire (retrieveContactData,{keySearch:'$currentContactName',accountInput:'$accountId'})
    wireRecord({data,error}){
        if(data){           
            this.records = data;

            this.NoContactsFound = false;

            this.error = undefined;
            this.dataNotFound = '';
            if(this.records == ''){
                this.dataNotFound = 'No contact found with given name';
            }

            if(this.records.length <= 0){
                console.log('no contacts found');
                this.NoContactsFound = true;
                //this.data=undefined;
            }
 

           }
    }
}