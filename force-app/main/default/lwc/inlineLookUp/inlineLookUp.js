import { LightningElement, track, wire, api } from "lwc";  
 import findRecords from "@salesforce/apex/InlineLookUpController.findRecords";
 import find_Record_On_Load from "@salesforce/apex/InlineLookUpController.findRecordOnLoad";  
 export default class LwcLookup extends LightningElement {  
  @track recordsList;  
  @track searchKey = "";  
  @api selectedValue;  
  @api selectedRecordId;  
  @api objectApiName;  
  @api iconName;  
  @api lookupLabel;  
  @track message;  

  @api isReadonly;  
  @api filterstring;
  connectedCallback(){
   this.searchRecordById();
  }
 @api searchRecordById(){
    if(!this.isEmpty(this.selectedRecordId)){
      find_Record_On_Load({ objectName : this.objectApiName,recordId: this.selectedRecordId})  
    .then((result) => {  
     if (result!=null && result.length!=0) { 

         this.selectedRecordId=result.Id;
         this.selectedValue=result.Name;
      } 
    })  
    .catch((error) => {  
     this.error = error; 
     console.log('error=='+error); 
     
    });  
  }

    else{
       this.selectedValue='';
    }
  }

  onLeave(event) {  
   setTimeout(() => {  
    this.searchKey = "";  
    this.recordsList = null;  
   }, 300);  
  }  
    
  onRecordSelection(event) {  
   this.selectedRecordId = event.target.dataset.key;  
   this.selectedValue = event.target.dataset.name;  
   this.searchKey = "";  
   this.onSeletedRecordUpdate();  
  }  
   
  handleKeyChange(event) {  
   const searchKey = event.target.value;  
   this.searchKey = searchKey;  
   this.getLookupResult();  
  }  
   
  removeRecordOnLookup(event) {  
   this.searchKey = "";  
   this.selectedValue = null;  
   this.selectedRecordId = null;  
   this.recordsList = null;  
   this.onSeletedRecordUpdate();  
 }  
 getLookupResult() {  



    findRecords({ searchKey: this.searchKey, objectName : this.objectApiName ,filter:this.filterstring})  



     .then((result) => {  
      if (result.length===0) {  
        this.recordsList = [];  
        this.message = "No Records Found";  
       } else {  
        this.recordsList = result;  
        this.message = "";  
       }  
       this.error = undefined;  
     })  
     .catch((error) => {  
      this.error = error;  
      this.recordsList = undefined;  
     });  
   }  
    
   onSeletedRecordUpdate(){  
    const passEventr = new CustomEvent('recordselection', {  
      detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }  
     });  
     this.dispatchEvent(passEventr);  
   }  

   isEmpty(str) {
    return (
        !str ||
        0 === str.length ||
        str === null ||
        str === "" ||
        str === undefined
    );
}


  }