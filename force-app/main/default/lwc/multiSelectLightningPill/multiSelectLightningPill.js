/*
Name :            multiSelectLightningPill (Re-Usable Component)
Author :          Abhishek Mallick
Team :            Osaka
Created Date :    26th February 2020
Description  :    This is a re-usable component to display dropdown list and lightning pill.
*/
import { LightningElement, track,api } from 'lwc';

export default class multiSelectLightningPill extends LightningElement {

@track options=[];
@track error;
@track dropdown = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
@track dataList = [];
@track dropdownList = 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta';
@track selectedValue = 'Select an Option';
@track selectedListOfValues='';
@api values = [];





connectedCallback(){
    
        this.dataList = this.values;
        console.log('datalist1==>' + JSON.stringify(this.dataList));
        for (let i = 0; i < this.dataList.length; i++) {
        this.options = [...this.options, { value: this.dataList[i].value, label: this.dataList[i].label,isChecked:false,class:this.dropdownList }];
        }

        //this.options = this.values
        console.log('optionslist==>' + JSON.stringify(this.options));
}

selectedEvent(event){
    const selectedEvent = new CustomEvent("selectedvaluechange", {
        detail: this.selectedListOfValues
      });
  
      // Dispatches the event.
      this.dispatchEvent(selectedEvent);
}


openDropdown(){
    this.dropdown =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';  
}

closeDropDown(){
   this.dropdown =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
}

selectOption(event){

var isCheck = event.currentTarget.dataset.id;
var label = event.currentTarget.dataset.name;
var selectedListData=[];
var selectedOption='';
var allOptions = this.options;
var count=0;

for(let i=0;i<allOptions.length;i++){ 
    if(allOptions[i].label===label)
    { 
        if(isCheck==='true')
        { 
            allOptions[i].isChecked = false;
            allOptions[i].class = this.dropdownList;
         }
        else
        { 
            allOptions[i].isChecked = true; 
            allOptions[i].class = 'slds-media slds-listbox__option slds-listbox__option_plain slds-media_small slds-media_center slds-is-selected';
        }
    } 
    if(allOptions[i].isChecked)
    { 
        selectedListData.push(allOptions[i].label); 
        count++; 
    } 

}
    if(count === 1){
        selectedOption = count+' Option Selected';
    }
    else if(count>1){
        selectedOption = count+' Options Selected';
    }
    
    this.options = allOptions;
    this.selectedValue = selectedOption;
    this.selectedListOfValues = selectedListData;
    this.selectedEvent(event);
}
	
removeRecord(event){

    var value = event.detail.name;
    var removedOptions = this.options;
    var count = 0;
    var selectedListData=[];
    for(let i=0; i < removedOptions.length; i++){

        if(removedOptions[i].label === value){
        removedOptions[i].isChecked = false;
        removedOptions[i].class = this.dropdownList;
        }

        if(removedOptions[i].isChecked){
        selectedListData.push(removedOptions[i].label); 
        count++;
        }   
    }

     var selectedOption;
        if(count === 1){
        selectedOption = count+'  Option Selected';
        }
            else if(count>1){
            selectedOption = count+' Options Selected';
            }
                else if(count === 0){
                selectedOption = 'Select an Option';
                selectedListData = "";
                }
    this.selectedListOfValues = selectedListData;
    this.selectedValue = selectedOption;
    this.options = removedOptions;
    this.selectedEvent(event);            
    }

}