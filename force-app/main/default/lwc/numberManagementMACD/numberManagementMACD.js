import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import hasPortOutPermission from '@salesforce/customPermission/NgUc_Port_Out_Permission';
export default class NumberManagementMACD extends LightningElement {  

    isModalOpen = false;

    @api 
    actionType = 'AddNewNumbers';

    @api
    subscriptionID;

    @api
    basketId;

    @api
    accountId;

    //DIGI-35918
    @api
    contactId;

    @api
    openModal() {
      this.isModalOpen = true;
    }
  
    @api
    closeModal() {
      
      this.isModalOpen = false;
    }
    connectedCallback(){
      console.log('hasPortOutPermission-'+hasPortOutPermission);
    }
    get actionTypeOptions() {
        
      if(hasPortOutPermission){
        return [
          { label: 'Add New Numbers', value: 'AddNewNumbers' },
          { label: 'Remove Numbers', value: 'RemoveNumbers' },
          { label: 'Lock Numbers', value: 'LockNumbers' },
          { label: 'Port Out Numbers', value: 'PortOutNumbers' },
        ];
      }else{
        return [
          { label: 'Add New Numbers', value: 'AddNewNumbers' },
          { label: 'Remove Numbers', value: 'RemoveNumbers' },
        ];

      }
      
        // { label: 'Lock Numbers', value: 'LockNumbers' },
        
    }

    

    get isAddNewNumber(){
        return this.actionType == 'AddNewNumbers';
    }
    get isRemoveNumbers(){
      return this.actionType == 'RemoveNumbers';
  }
  get isLockNumbers(){
    return (this.actionType == 'LockNumbers'  && hasPortOutPermission) ;
}

  get isPortNumbers(){
    return (this.actionType == 'PortOutNumbers' && hasPortOutPermission);
}
    handleActionTypeSelected(event) {
        this.actionType = event.target.value;
     }
      
}