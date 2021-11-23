/**
 * Built by team Hawaii for P2OB-11847 (Sprint 21.02)
 * Updated filer functionality for Sprint 21.03
 */

import { LightningElement, track, api } from 'lwc';
import getListViewQuery from '@salesforce/apex/PRM_GenericListViewController.getListViewQuery';
import { reduceErrors } from 'c/ldsUtils';
import URL_PATH from '@salesforce/label/c.Community_base_path';
import noRecFound from '@salesforce/label/c.PRM_No_Records_Found';
//JSON for values to search
var filterOption = new Object();
export default class PrmGenericListView extends LightningElement {
    //Records to display
    @track recordsList=[];
    //SObject Name for ListView
    @api sobjectName;
    //ListView Name
    @api listViewName;
    //Fields to show in Data Table
    @api fieldsToShow;
    //API To Label Name Map
    //labelApiMap = [];
    //Sort by
    @track sortBy;
    //Sort Direction
    @track sortDirection;
    //Data table columns
    columns = [];
    //List View Label
    listLabel;
    //Filtered Data
    @track filteredData = [];
    //Show SearchBox
    @api showSearch;
    //Limit number of records
    @api numOfRecords = 5;
    //initial records
    @track initialRec = [];
    //Show Load More Button
    showLoadMore = false;
    referenceFields = [];
    //Error msg if no records found
    noRecords;
    //ShowError
    showMsg = false;
    //Filter Fields List
    @track filterFields = [];
    //Display Filters
    displayCard = false;
    //Show Spinner
    showSpinner = false;
    //Show Filter icon
    @api showFilter;
    //Picklist Values
    @track picklistValues=[];
    //Values to show initially
    @track picklistValuesInit=[];
    //ShowMore Picklist Button
    showMore = true;
    //Field Details map
    @track fieldDetailsMap=[];
    //Selected Picklist Array
    @track selectedArray = []
    

    connectedCallback() {
        this.getListViewResult();
    }

   handleResults(event){
    this.filteredData = event.detail.filteredData;
    this.prepareTable(this.numOfRecords);
   }

    //Call apex controller to get record details
    getListViewResult() {
        getListViewQuery({ listViewName: this.listViewName, sObjectName: this.sobjectName, fieldsToShow: this.fieldsToShow }).then(result => {
            if (result) {
                this.recordsList = result.recordList;
                this.filteredData = result.recordList;
                if(this.recordsList.length == 0){
                    this.noRecords = noRecFound;
                    this.showMsg = true;
                    this.showLoadMore = false;
                }
                this.lazyLoading();
                this.listLabel = result.listViewLabel;
            }
            this.fieldDetailsMap = result.fieldDetailsMap;
            
            let fieldList = this.fieldsToShow.split(',');
            for(let i=0;i<fieldList.length;i++){
                let fDetails = this.fieldDetailsMap[fieldList[i]];
                if(fDetails !== null && fDetails !== undefined){
                    if(fDetails.fieldName=='Name'){
                        this.filterFields = [...this.filterFields,{fieldApi: fDetails.fieldName ,label: fDetails.fieldLabel, type:'text',picklist:false,value:''}];
                        this.columns = [...this.columns ,{label: fDetails.fieldLabel , fieldName: 'URL', sortable: true, type: 'url',
                        typeAttributes: { label: { fieldName: fDetails.fieldName
                        } ,
                        target:'_blank'}
                    }];
                    }else if(fDetails.fieldName.includes('CaseNumber') || (fDetails.fieldName.includes('Subject') && this.sobjectName==='Case')){
                        this.filterFields = [...this.filterFields,{fieldApi: fDetails.fieldName ,label: fDetails.fieldLabel, type:'text',picklist:false, value:''}];
                        this.columns = [...this.columns ,{label: fDetails.fieldLabel , fieldName: fDetails.fieldName+'URL', sortable: true, type: 'url', 
                        typeAttributes: { label: { fieldName: fDetails.fieldName
                                        } ,
                                        target:'_blank'}
                        }];
                    }
                    else if(fDetails.fieldType=='REFERENCE'){
                        this.filterFields = [...this.filterFields,{fieldApi: fDetails.fieldName ,label: fDetails.fieldLabel.replace('ID','Name'), type:'text',picklist:false, value:''}];
                        this.referenceFields.push(fDetails);
                        this.columns = [...this.columns ,{label: fDetails.fieldLabel.replace('ID','Name') , fieldName: fDetails.fieldName +'URLRef', sortable: true, type: 'url', 
                        typeAttributes: { label: { fieldName: fDetails.fieldName
                                        } ,
                                        target:'_blank'}
                        }];
                    }
                    else if (fDetails.fieldType == 'DATE'){
                        this.filterFields = [...this.filterFields,{fieldApi: fDetails.fieldName ,label: fDetails.fieldLabel, type:fDetails.fieldType.toLowerCase(),picklist:false, value:''}];
                        this.columns = [...this.columns ,{label: fDetails.fieldLabel, fieldName: fDetails.fieldName, sortable: true, type: fDetails.fieldType.toLowerCase(), typeAttributes: {
                            day: "numeric",
                            month: "numeric",
                            year: "numeric"
                        }}];
                   
                    }
                    else if (fDetails.fieldType == 'DATETIME'){
                        this.filterFields = [...this.filterFields,{fieldApi: fDetails.fieldName ,label:fDetails.fieldLabel, type:fDetails.fieldType.toLowerCase(),picklist:false,value:''}];
                        this.columns = [...this.columns ,{label: fDetails.fieldLabel, fieldName: fDetails.fieldName, sortable: true, type: fDetails.fieldType.toLowerCase(), typeAttributes: {
                            day: "numeric",
                            month: "numeric",
                            year: "numeric",
                            hour: "2-digit",
                            minute: "2-digit",
                            second: "2-digit",
                            hour12: true
                        }}];
                   
                    }
                    else{
                        if(fDetails.fieldType=='PICKLIST'){
                            this.picklistValues = fDetails.picklistValues;
                            for(let i=0;i<=5;i++){
                                this.picklistValuesInit = [...this.picklistValuesInit,{checked:false,value:this.picklistValues[i]}];
                            }
                            this.filterFields = [...this.filterFields,{fieldApi: fDetails.fieldName ,label: fDetails.fieldLabel, type:'checkbox', picklist:true,value:''}];
                        }else{
                            this.filterFields = [...this.filterFields,{fieldApi: fDetails.fieldName ,label:fDetails.fieldLabel, type:fDetails.fieldType.toLowerCase(),value:''}];
                        }
                        this.columns = [...this.columns ,{label: fDetails.fieldLabel, fieldName: fDetails.fieldName, sortable: true, type: fDetails.fieldType.toLowerCase()}];
                    }
                }
            }

            for (let i = 0; i < this.recordsList.length; i++) {
                let row = this.recordsList[i];
                row['URL'] = URL_PATH + this.sobjectName.toLowerCase() +'/' + row['Id'] + '/view';
                if(this.sobjectName == 'Case' && this.fieldsToShow.indexOf('Subject') > 0){
					row['SubjectURL'] = URL_PATH + this.sobjectName.toLowerCase() +'/' + row['Id'] + '/view';
				}
				if(this.sobjectName == 'Case' && this.fieldsToShow.indexOf('CaseNumber') >= 0){
					row['CaseNumberURL'] = URL_PATH + this.sobjectName.toLowerCase() +'/' + row['Id'] + '/view';
				}
                for(let j =0;j<this.referenceFields.length;j++){
                    let rf = this.referenceFields[j].fieldName.endsWith('Id') ? this.referenceFields[j].fieldName.replace('Id','').trim(): this.referenceFields[j].fieldName.replace('__c','__r').trim();
                    if(row[rf] != undefined){
                        row[this.referenceFields[j].fieldName] = row[rf]['Name'];
                        if(this.referenceFields[j].referenceToField.toLowerCase() == 'user'){
                            row[this.referenceFields[j].fieldName +'URLRef'] =  URL_PATH + 'profile' +'/' + row[rf]['Id'];
                           
                        }else{
                            row[this.referenceFields[j].fieldName +'URLRef'] =  URL_PATH + this.referenceFields[j].referenceToField.toLowerCase() +'/' + row[rf]['Id'] + '/view';   
                        }
                    }
                }
            }
        
        }).catch(error => {
            this.errors = reduceErrors(error); // code to execute if the promise is rejected
            console.log('inside errors ->' + this.errors);
        });
    }

    showMorePicklistVals(){
        for(let i=0;i<this.picklistValues.length;i++){
            this.picklistValuesInit = [...this.picklistValuesInit,{checked:false,value:this.picklistValues[i]}];
        }
        this.showMore= false;
    }
    // The method onsort event handler
    updateColumnSorting(event) {
        
        this.sortBy = event.detail.fieldName;
        
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
   }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.filteredData));
        // Return the value stored in the field
        let keyValue = (a) => {
            let urlField = fieldname;
            if(fieldname == 'URL'){
                return a['Name'];
            }
            if(fieldname.endsWith('URL')){
                urlField = urlField.replace('URL','');
                if(urlField == 'Name' || urlField == 'CaseNumber' || urlField == 'Subject'){
                    return a[urlField];
                }
            }else if(fieldname.endsWith('URLRef')){
                urlField = urlField.replace('URLRef','');
                urlField = urlField.endsWith('Id') ? urlField.replace('Id','').trim(): urlField.replace('__c','__r').trim();
                
                if(a[urlField] != undefined && a[urlField]['Name'] != undefined){
                    return a[urlField]['Name'];
                }
            }
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x).toLowerCase() : ''; // handling null values
        y = keyValue(y) ? keyValue(y).toLowerCase() : '';
        // sorting values based on direction
        return isReverse * ((x > y) - (y > x));
        });
        this.filteredData = parseData;
        this.prepareTable(this.numOfRecords);
        }
    
    //Load More values in data table 
    lazyLoading(){
        let lastIndex;
        if(this.initialRec.length != null){
            lastIndex = this.initialRec.length;
        }
        if(this.initialRec.length == 0 || this.initialRec == null){
            lastIndex = 0;
            this.showLoadMore = false;
        }
        let loadMore = lastIndex + this.numOfRecords;
        if(loadMore >= this.filteredData.length){
            loadMore = this.filteredData.length;
            this.showLoadMore = false;
        }
        this.numOfRecords = loadMore;
        for(let i=lastIndex; i<loadMore; i++){
            this.initialRec = [...this.initialRec, this.filteredData[i]];
        }
        if(this.filteredData.length > this.initialRec.length){
            this.showLoadMore = true;
        }
        
    }
    
    //Table to view after sorting/searching
    prepareTable(maxRecs){
        this.showLoadMore = true;
        this.initialRec = [];
        if(maxRecs >= this.filteredData.length){
            maxRecs = this.filteredData.length;
            this.showLoadMore = false;
        }
        for(let i=0; i<maxRecs; i++){
            this.initialRec = [...this.initialRec, this.filteredData[i]];
        }
    }

    //Show Card when Filter Icon is clicked
    handleFilter(){
        this.displayCard = true;
    }

    clearFilters(){
        //clear filters content on UI
        this.template.querySelectorAll('lightning-input[data-id="reset"]').forEach(element => {
            if(element.type === 'checkbox' || element.type === 'checkbox-button'){
                element.checked = false;
            }else{
                element.value = null;
            }        
        });
        //Clear the filterOption Map
        for(let i=0;i<this.filterFields.length;i++){
            this.filterFields[i].value = '';
        }
        for(let i=0; i<this.picklistValuesInit.length;i++){
                this.picklistValuesInit[i].checked = false;
            
        }
        this.selectedArray=[];
        filterOption={};
        this.showMsg = false;
        this.filteredData = this.recordsList;
        this.prepareTable(this.numOfRecords);
    }

    //Populate filterOption map
    handleChange(event){

        filterOption[event.currentTarget.dataset.fieldname] = event.detail.value;
        if(filterOption[event.currentTarget.dataset.fieldname] == '' || 
        filterOption[event.currentTarget.dataset.fieldname] == undefined || filterOption[event.currentTarget.dataset.fieldname] == null){
            
            delete filterOption[event.currentTarget.dataset.fieldname];
            
        }
        for(let i=0;i<this.filterFields.length;i++){
            if(this.filterFields[i].fieldApi == event.currentTarget.dataset.fieldname){
                this.filterFields[i].value = event.detail.value;
                break;
            }
        }
    }

    //Populate filterOption map in case of picklist
    handlePicklistChange(event){
        if(event.target.checked){
            if(filterOption[event.currentTarget.dataset.fieldname] != undefined && 
                filterOption[event.currentTarget.dataset.fieldname] != null){
                let currValue = event.currentTarget.value;
                this.selectedArray = [...this.selectedArray, currValue];
                filterOption[event.currentTarget.dataset.fieldname] = this.selectedArray;
                for(let i=0; i<this.picklistValuesInit.length;i++){
                    if(this.picklistValuesInit[i].value==event.currentTarget.value){
                        this.picklistValuesInit[i].checked = true;
                        break;
                    }
                }
               
            }else{
                let currValue = event.currentTarget.value;
                this.selectedArray = [...this.selectedArray, currValue];
                filterOption[event.currentTarget.dataset.fieldname] = this.selectedArray;
                for(let i=0; i<this.picklistValuesInit.length;i++){
                    if(this.picklistValuesInit[i].value==event.currentTarget.value){
                        this.picklistValuesInit[i].checked = true;
                        break;
                    }
                }
                
            }
        }else{
            let index = this.selectedArray.indexOf(event.currentTarget.value);
            if (index > -1) {
                this.selectedArray.splice(index, 1);
                filterOption[event.currentTarget.dataset.fieldname] = this.selectedArray;
                for(let i=0; i<this.picklistValuesInit.length;i++){
                    if(this.picklistValuesInit[i].value==event.currentTarget.value){
                        this.picklistValuesInit[i].checked = false;
                        break;
                    }
                }
            }
        }
        if(filterOption[event.currentTarget.dataset.fieldname] == '' || 
        filterOption[event.currentTarget.dataset.fieldname] == undefined || filterOption[event.currentTarget.dataset.fieldname] == null){
            
            delete filterOption[event.currentTarget.dataset.fieldname];
        }
    }

    //Search data in rows as per values in filterOption
    applyFilters(event){
      this.displayCard = false;
      let results = [];
      for(let i=0;i<this.recordsList.length;i++){
        let row=this.recordsList[i];
        let matchFound = false;
        for(let key in filterOption){
            
            if(this.fieldDetailsMap[key] != undefined && this.fieldDetailsMap[key].fieldType=='PICKLIST' && filterOption[key] != '' && filterOption[key] != undefined && filterOption[key] != null){
                
                if(filterOption[key].includes(row[key])){
                    matchFound = true;
                }else{
                    matchFound = false;
                    break;
                }
               
            }
            else if(this.fieldDetailsMap[key] != undefined && (this.fieldDetailsMap[key].fieldType=='DATE' || this.fieldDetailsMap[key].fieldType=='DATETIME' && filterOption[key] != '' && filterOption[key] != undefined && filterOption[key] != null)){
                //Match time format for search
                if(new Date(row[key]).getTime() == new Date(filterOption[key]).getTime()){
                    matchFound = true;
                 }else{
                    matchFound = false;
                    break;
                }
            }
            else if(filterOption[key] != '' && filterOption[key] != undefined && filterOption[key] != null){
                //Make case insensitive for search
                let rowIn = row[key].toLowerCase();
                let filterIn = filterOption[key].toLowerCase();
                if(rowIn.includes(filterIn)){
                    matchFound = true;
                }else{
                    matchFound = false;
                    break;
                }
            }
       }
       if(matchFound){
            results.push(row);
       }
      }
      if(results.length > 0){
        if(this.showMsg){
            this.showMsg = false;
        }
        this.filteredData = results;
        this.prepareTable(this.numOfRecords);
      }
      if(results.length == 0){
          if(Object.keys(filterOption).length === 0){
            
            if(this.showMsg){
                this.showMsg = false;
            }
            this.filteredData = this.recordsList;
            this.prepareTable(this.numOfRecords);
          }
        else{
            this.showMsg = true;
            this.noRecords = noRecFound;
            this.filteredData = [];
            this.prepareTable(this.numOfRecords);
        }
      }
    }

    //Handle close icon in filter options
    handleClose(){
        this.displayCard = false;
    }
}