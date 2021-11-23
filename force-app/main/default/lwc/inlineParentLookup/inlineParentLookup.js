import { LightningElement, api } from 'lwc';  
export default class LwcLookupDemo extends LightningElement {  
  @api selectedRecordId;  
  @api selectedRecordName;
  @api objectApiname; 
  @api lokupLabel;
  @api icon; 




  @api isReadonly; 
  @api filterstring;
  hasRendered=false; 
  renderedCallback(){
    let lookup= this.template.querySelector('c-inline-look-Up');
    lookup.searchRecordById();
   
  }


  recordselection(event){  
  this.selectedRecordName = event.detail.selectedValue;  
  this.selectedRecordId = event.detail.selectedRecordId;
  this.seletedRecordUpdateParent();  
  }  
  seletedRecordUpdateParent(){  
    const passEventr = new CustomEvent('recordselectiononparent', {  
      detail: { selectedRecordId: this.selectedRecordId,
        selectedRecordName:this.selectedRecordName }  
     });  
     this.dispatchEvent(passEventr);  
   }  
}