import { LightningElement, api, wire, track } from "lwc";
import getFCRList from "@salesforce/apex/FetchFCRContactController.fetchContact";
import { refreshApex } from '@salesforce/apex';
import createPortalEnggUsers from "@salesforce/apex/FetchFCRContactController.createPortalEngg";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const columns = [
    {label: 'Last Name', fieldName: 'LastName', type: 'text'},
    {label: 'First Name', fieldName: 'FirstName', type: 'text'},
    {label: 'P Number', fieldName: 'P_Number__c', type: 'text'},
    {label: 'Email', fieldName: 'Email', type: 'Email'}
  ];

export default class fetchFCRContactListLWC extends LightningElement   {
  @track data;
  @track error;
  @track columns = columns;
  @api recordId;
  @track cssDisplay = "";
  @track tableDisplay = false;
  @track recordPageUrl;
  @track visible = true; 
  @api fcrId;
  @track selectedRows=[];
  @track showspinner=true;
  @track selRowStr;


  wiredResult;

  @wire(getFCRList, { fcrId: '$fcrId'})
  /*async*/ wiredFCRRoles (value) {
    this.wiredResult=value;
    const { data, error } = value
     if (data) {        
      this.data = data;
      this.tableDisplay=true;
        console.log('Data:',data);
        if(typeof data === undefined || data === null || data === '' || ( data != null && data.length === 0)){
          console.log('Insider:',data);
          this.dispatchEvent(new CustomEvent('nousersavailable'));
        }
    } else if (error) {
      console.log("error", error);
    }

    this.showspinner=false
  }

  Modalclosefunc(){
    this.visible = false;
  }
  
handleSave(){
  console.log('handleSave');
      this.showspinner=true;
      var el = this.template.querySelector('lightning-datatable');
      var selRowStr = null;
      var selected = el.getSelectedRows();
      for (let i = 0; i < selected.length; i++){
        if(selRowStr == null) selRowStr = selected[i].Id;
        else selRowStr = selRowStr + ',' + selected[i].Id;
    }

    console.log('selRowStr'+selRowStr);

    if(selRowStr == null){

      this.dispatchEvent(              
        new ShowToastEvent({
               title: 'Add User',
               message: 'Please select at least a user.',
               variant: 'error'
           })
         )
         this.showspinner=false;

    }
    else{
        selRowStr=this.fcrId+'#'+selRowStr;
        this.selRowStr=selRowStr;
      // alert("You selected: " + selRowStr);
        //event.preventDefault();
        
      createPortalEnggUsers({ userids: selRowStr })
            .then(result => {
              console.log('result'+result[0]);
              if(result[0] ==='Users are added successfully'){
                console.log('showtoast'+result[0]);            
                this.dispatchEvent(new CustomEvent('savefcr'));            
                this.closemodelPopup();
                console.log('refreshApex'); 
                this.showspinner=false; 
                return refreshApex(this.wiredResult);
               
              }
              else{
                this.dispatchEvent(new CustomEvent('handleerror'));
                this.closemodelPopup();
                this.showspinner=false;
              }
            })
            .catch(error => {
                console.log('error'+error)
            });
      }              
}

closemodelPopup(){
  console.log('closemodelPopup');
  this.dispatchEvent(new CustomEvent('closepopup'));
}

}