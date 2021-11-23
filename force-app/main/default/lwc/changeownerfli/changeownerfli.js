import { LightningElement, api, wire, track } from "lwc";
import getEngineeringUsers from "@salesforce/apex/FetchFCRContactController.getEngineeringUsers";
import ReassignTask from "@salesforce/apex/FetchFCRContactController.ReassignTask";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const columns = [
    {label: 'Last Name', fieldName: 'LastName', type: 'text'},
    {label: 'First Name', fieldName: 'FirstName', type: 'text'},
    {label: 'P Number', fieldName: 'P_Number__c', type: 'text'},
    {label: 'Email', fieldName: 'Email', type: 'Email'}
  ];

export default class Changeownerfli extends LightningElement {
    @track data;
  @track error;
  @track columns = columns;
  @api recordId;
  @track cssDisplay = "";
  @track tableDisplay = false;
  @track hasdata = true;
  @track recordPageUrl;
  @track visible = true; 
  @api fcrId;
  @track selectedRows=[];
  @track selRowStr;
  @api fliid;
  @api source;
  @track showpopup = false;
  wiredResult;
  @track showspinner = false;


  @wire(getEngineeringUsers, { recid: '$fliid'})
  async wiredFCRRoles (value) {
    this.wiredResult=value;
    const { data, error } = value
     if (data) {        
      this.data = data;      
      this.showspinner=false;
      this.tableDisplay=true;
      this.hasdata = true;
        console.log('Data:',data);
        if(typeof data === undefined || data === null || data === '' || ( data != null && data.length === 0)){
          console.log('Insider:',data);
          this.hasdata = false;
        }
        
    } else if (error) {
      console.log("error", error);
    }

    this.showspinner=false;
  }

handleSave(){
  this.showspinner=true;
  console.log('this.showspinner'+this.showspinner);
  console.log('handleSave');
      var el = this.template.querySelector('lightning-datatable');
      var selRowStr = null;
      var selected = el.getSelectedRows();
      for (let i = 0; i < selected.length; i++){
        if(selRowStr == null) selRowStr = selected[i].Id;
        else selRowStr = selRowStr + ',' + selected[i].Id;
    }

    console.log('selRowStr'+this.fcrId);
    console.log('selRowStr'+this.source);

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
        selRowStr=this.fliid+'#'+selRowStr;
        this.selRowStr=selRowStr;
      // alert("You selected: " + selRowStr);
        //event.preventDefault();
        console.log('selRowStr'+selRowStr);
        ReassignTask({ userids: selRowStr,fcrid:this.fcrId,source: this.source})
            .then(result => {              
              console.log('result'+result[0]);
              if(result[0] ==='Owner updated successfully'){
                console.log('showtoast'+result[0]);            
                this.dispatchEvent(new CustomEvent('ownerupdated'));            
                this.closemodelPopup();
                
              }
              else{
                this.dispatchEvent(new CustomEvent('handleerror'));
                this.closemodelPopup();
              }
              this.showspinner=false;
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