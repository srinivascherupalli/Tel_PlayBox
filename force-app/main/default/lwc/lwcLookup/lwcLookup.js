import { LightningElement, track, wire, api } from "lwc";  
 import findRecords from "@salesforce/apex/LwcLookupController.findRecords"; 
  
 export default class LwcLookup extends LightningElement {  
  @api recordsList;  
  @track searchKey = "";  
  @api selectedValue;  
  @api selectedRecordId;  
  @api objectApiName;  
  @api iconName;  
  @api lookupLabel;  
  @track message;  
  @api makeReadonly = false;
  @api filterString;
  @api helpText;
  @api searchFields;
  // DIGI-8926 -- to hide label  set to false to display label  by default
  @api labelhide = false; 
  
  /**Added as part of INC000097265553 by Sonalisa Verma
  Show complete name in list option if search field is not displayed **/
  @api hideSearchFields = false;
    
  onLeave(event) {  
   setTimeout(() => {  
    this.searchKey = "";  
    this.recordsList = null;  
   }, 300);  
  }  
    
  onRecordSelection(event) {  
    this.selectedRecordId = event.target.dataset.key;
    this.selectedValue = event.target.dataset.name;
    /*Added as part of INC000097265553 by Sonalisa Verma
    Sending all searched field values based on record Id selected */
    let record = (this.recordsList!=null && this.recordsList.length !== 0) ? this.recordsList.find(item => item.Id === this.selectedRecordId) : null;
    console.log(this.selectedRecord);
    const passEventr = new CustomEvent('recordselection', {
      detail: {
        selectedRecordId: this.selectedRecordId,
        selectedValue: this.selectedValue,
        selectedRecord: record
      }
    });
   this.dispatchEvent(passEventr);  
   this.searchKey = "";  
   this.onSeletedRecordUpdate();  
  }  
   
  handleKeyChange(event) { 
   const searchKey = event.target.value;  
   this.searchKey = searchKey;  
   this.getLookupResult();  
  }  
  handleFocus(event){
    this.getLookupResult();
  }
  @api clearRecordsList(){
    this.recordsList = null;
    console.log('Parent Component');
    console.log(this.searchKey);
  }
   removeRecordOnLookup(event) {
     this.searchKey = "";
     this.selectedValue = null;
     this.selectedRecordId = null;
     this.recordsList = '';
     const passEventr = new CustomEvent('recordselection', {
       /*Added as part of INC000097265553 by Sonalisa Verma
        Sending null as selectedRecord if selection is removed */
       detail: { selectedRecordId: undefined, selectedValue: undefined, selectedRecord: null }
     });
     this.dispatchEvent(passEventr);
     this.onSeletedRecordUpdate();
   }
 getLookupResult() {  
    findRecords({ searchKey: this.searchKey, objectName : this.objectApiName,filterString:this.filterString ,searchFields:this.searchFields})  
     .then((result) => {  
      if (result.length===0) {  
        this.recordsList = [];  
        this.message = "No Records Found";  
       } else {  
      if(this.searchFields!=null){
        var searchFieldsArr = this.searchFields.split(',');
        for (var outerIndex in result) {
          var searchFieldValue='';
          for(var field in searchFieldsArr){
          if(result[outerIndex][searchFieldsArr[field]] != null )
          searchFieldValue=searchFieldValue +' '+ result[outerIndex][searchFieldsArr[field]];
        }
           result[outerIndex].searchFieldValue=searchFieldValue;
        }
      }
      this.recordsList = result;  
        this.message = "";  
       }  
       this.error = undefined;  
     })  
     .catch((error) => {  
       console.log('getLookupResult: ',error);
      this.error = error;  
      this.recordsList = undefined;  
     });
   }  
   onSeletedRecordUpdate(){ 
   }  
  }