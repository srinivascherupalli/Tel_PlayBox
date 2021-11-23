/*******************************************************************
 * Team : Hawaii
 * Jira No : P2OB-9098
 * Description : This is LWC component for dynamic filter functionality on Knowledge articles
 * Date : 5th September 2020
 ***********************************************************************/
import {LightningElement,wire,api,track} from 'lwc';
import getFilterMetadata from '@salesforce/apex/prmArticleDetail.getFilterMetadata';
// variable to store from date value
var fromDateVariable;
//variable to store api name of city field
var cityFieldApiName;
//object to store filter condition key and values
var filterOption = new Object();
export default class PrmKnowledgeFilterComponent extends LightningElement {
    //Category label pass as input from parent component 
    //Parent component gets its value from pub sub event of prmKArticleAccord component
    @api titleString='';
    //list to store custom metdata records
    @track filterMetadata;
    //variable to identify type of field is date/datetime
    dateFieldType = false;
    //variable to identify type of field is radio
    radioFieldType = false;
    //variable to conditionally display error message on from date field
    @track showFromDateError = false;
    //variable to conditionally display error message on to date field
    @track showToDateError = false;
    //variable to store error message on from date field
    @track fromDateError = '';
    //variable to store error message on to date field
    @track toDateError = '';
    //list of articles on which filter will be apply
    @api allArticles;
    //conditionally display city field
    @track obj = {
        showCity:false
    };
    @track error;
    //method to get data from custom metadata 
    @wire(getFilterMetadata, {categoryName : '$titleString'})
    valueFromServer({ error, data }) {
        if (data) {
            if( data.length >  0){
                this.filterMetadata = [];
                for(var i=0;i < data.length;i++){
                    //creatr new object instance
                    var filterObject = new Object();
                    filterObject.data = data[i];
                    //check if field is of type date/datetime
                    if(filterObject.data.fieldType == 'Date' || filterObject.data.fieldType == 'DateTime'){
                        filterObject.dateFieldType = true;
                        filterObject.filterLabel = data[i].filterBy;
                    //check if field is of type radio
                    }else if(filterObject.data.fieldType == 'Radio'){
                        //check if field has dependent field present
                        if(data[i].dependentField != ''){
                            filterObject.dependentDataList = JSON.parse(data[i].dependentField);
                        }
                        if(data[i].fieldValues != ''){
                            var optionObjectList = [];
                            var optionList =  data[i].fieldValues.split(';');
                            for(var j=0;j < optionList.length;j++){
                                var option = optionList[j];
                                optionObjectList.push(JSON.parse(option));
                            }
                            filterObject.optionValues = optionObjectList;
                        }
                        //set true to if field type is radio
                        filterObject.radioFieldType = true;
                        filterObject.filterLabel = data[i].filterBy;
                    //check field type is text 
                    }else if(filterObject.data.fieldType == 'Text'){
                        filterObject.textFieldType = true;
                        filterObject.filterLabel = data[i].filterBy;
                    }
                    //Add to list of filtermetadata
                    this.filterMetadata.push(filterObject);
                }
            }
        //set error,if there is error while server calling
        } else if (error) {
            this.error = error;
            this.filterMetadata = [];
        }
    }
    //on change event on from date field
    fromDateUpdate(event){
        //set from date field value in variable
        let fromDate = event.detail.value;
        //get to date element from dom
        var input2 = this.template.querySelector(".input2");
        //if from date is not null
        if(fromDate != null){
            //set values of variable
            this.fromDateError = '';
            this.showFromDateError = false;
            this.toDateError = '';
            input2.value = '';
            this.showToDateError = false;
            //set value of variable to use in to date change event
            fromDateVariable = fromDate;
            //create new key filterOption object and set from date variable value 
            filterOption[event.currentTarget.dataset.fieldname] = new Object();
            filterOption[event.currentTarget.dataset.fieldname].fromDate = fromDate;
            console.log('::filterOption'+JSON.stringify(filterOption));
        }
        //if from date is changed to null
        if(fromDate  == null){
            //set default values of variable
            this.fromDateError = '';
            this.showFromDateError = false;
            this.toDateError = '';
            this.showToDateError = false;
            input2.value = '';
            fromDateVariable=undefined;
            //set undefined
            filterOption[event.currentTarget.dataset.fieldname] = undefined;
            console.log('::filterOption'+JSON.stringify(filterOption));
            //Call filter record method to get original data
            this.getFilterRecord();
        }
    }
    //on change event on to date field
    toDateUpdate(event){
        //set from date fiel value in variable
        let toDate = event.detail.value;
        //check if object  filteroption has already key present
        if(filterOption[event.currentTarget.dataset.fieldname] == undefined){
            filterOption[event.currentTarget.dataset.fieldname] = new Object();
            filterOption[event.currentTarget.dataset.fieldname].fromDate = fromDateVariable != undefined ? fromDateVariable : undefined;
        }
        //set from date variable value from global variable
        let fromDate = fromDateVariable != undefined ? fromDateVariable : undefined;
        //check if there is no error is present on from date field and from date field is not undefined
        if(this.showFromDateError == false && fromDate != undefined){
            //Show error if from date is greater than to date
            if(fromDate >= toDate && toDate  != null){
                this.showToDateError = true;
                this.toDateError = 'To date should be greater than From date';
                //set todate key value as undefined in object
                filterOption[event.currentTarget.dataset.fieldname].toDate  = undefined;
                console.log('::filterOption'+JSON.stringify(filterOption));
            //show error if from date is present but to date is null
            }else if(toDate  == null){
                this.showToDateError = true;
                this.toDateError = 'Please select To date';
                //set todate key value as undefined in object
                filterOption[event.currentTarget.dataset.fieldname].toDate  = undefined;
                console.log('::filterOption'+JSON.stringify(filterOption));
            }else if(toDate > fromDate){
                //set default variables value
                this.toDateError = '';
                this.fromDateError = '';
                this.showToDateError = false;
                this.showToDateError =false;
                //call filter function as all validations for filter functions are passed
                if(filterOption[event.currentTarget.dataset.fieldname]  == undefined){
                    filterOption[event.currentTarget.dataset.fieldname] = new Object();
                }
                filterOption[event.currentTarget.dataset.fieldname].toDate = toDate;
                console.log('::filterOption'+JSON.stringify(filterOption));
                //get filter records 
                this.getFilterRecord();
            }
        //show error if from date is not selected and to date is selected
        }else if(this.showFromDateError == false && fromDate == undefined){
            this.showFromDateError = true;
            this.fromDateError = 'Please select From date';
            filterOption[event.currentTarget.dataset.fieldname]= undefined;
            //get filter records
            this.getFilterRecord();
        }
    }
    //common method to get filter records
    getFilterRecord(){
        this.knowledgeArticleList = this.filterRecords(this.allArticles,filterOption);
        this.dispatchEvent(new CustomEvent('filteredrecord',{
            detail: this.knowledgeArticleList
        }));
    }
    //on change event on radio group button
    handleChangeGroup(event) {
        //get dependent field value
        const eventTypeValue = event.currentTarget.dataset.evtype;
        //value selected as radio
        const selectedOption = event.detail.value;
        //show city field if condition match
        if(selectedOption.includes(eventTypeValue)){
            this.obj.showCity = true;
        //hide city field if condition does not match
        }else if(!selectedOption.includes(eventTypeValue)){
            if(cityFieldApiName != undefined){
                //remove city from filter object if type is online
                filterOption[cityFieldApiName] = undefined;
            }
            this.obj.showCity = false;
        }
        //Set values in filteroption object
        filterOption[event.currentTarget.dataset.fieldname] = new Object();
        filterOption[event.currentTarget.dataset.fieldname].filterValue = selectedOption;
        console.log('::filterOption'+JSON.stringify(filterOption));
        //get filter record based on conditions
        this.getFilterRecord();
    }
    //On change event on city change
    searchArticleBasedOnCity(event){
        //Added field to store api name of city field
        cityFieldApiName = event.currentTarget.dataset.fieldname;
        //get city name
        let cityName = event.detail.value;
        //if city name is not blank set filteroption object variables
        if(cityName != ''){
            filterOption[event.currentTarget.dataset.fieldname] = new Object();
            filterOption[event.currentTarget.dataset.fieldname].filterValue = cityName;
        //if city name is blank remove filter option object key for city
        }else{
            filterOption[event.currentTarget.dataset.fieldname] = undefined;
        }
        console.log('::filterOption'+JSON.stringify(filterOption));
        //get filter records
        this.getFilterRecord();
    }
    //common filter records method to filter records based on article and filter combination
    filterRecords(array,filters){
        //initialize fiterdata variable
        let filtereData = [];
        for(var i=0;i < array.length; i++){
            let isMatch = false;
            for(var j=0; j < this.filterMetadata.length;j++){
                //get key values of filters
                const filterKeys = Object.keys(filters);
                //check if key is exist in metadata records
                if(filterKeys.includes(this.filterMetadata[j].data.fieldApiName)){
                    //get the type of field
                    let fieldType = this.filterMetadata[j].data.fieldType;
                    //if field type is DateTime/Date
                    if(fieldType != undefined && fieldType == 'DateTime' && filterOption[this.filterMetadata[j].data.fieldApiName] != undefined){
                        //filter the records based on the value of variable from date,to date and formatted date
                        let fromDate = new Date(filters[this.filterMetadata[j].data.fieldApiName]['fromDate']).toISOString();
                        let formattedDate = array[i]['sobjectRecord'][this.filterMetadata[j].data.fieldApiName];
                        let toDate = new Date(filters[this.filterMetadata[j].data.fieldApiName]['toDate']).toISOString();
                        //condition for filtering
                        if(formattedDate >= fromDate && formattedDate <= toDate){
                            isMatch = true;
                        }else{
                            isMatch = false;
                            break;
                        }
                    // check if field type is radio
                    }else if(fieldType != undefined && fieldType == 'Radio' && filterOption[this.filterMetadata[j].data.fieldApiName].filterValue != undefined){
                        //match the value of key with field FieldVisibility of custom metadata 
                        if(this.filterMetadata[j].dependentDataList != undefined && array[i]['sobjectRecord'][this.filterMetadata[j].data.fieldApiName].includes(this.filterMetadata[j].dependentDataList.FieldVisibility) &&  filterOption[this.filterMetadata[j].data.fieldApiName].filterValue.includes(this.filterMetadata[j].dependentDataList.FieldVisibility)){
                            isMatch = true;
                            if(this.filterMetadata[j].dependentDataList != undefined && filterOption[this.filterMetadata[j].dependentDataList.FieldAPIName] != undefined && filterOption[this.filterMetadata[j].dependentDataList.FieldAPIName].filterValue != undefined){
                                if((array[i]['sobjectRecord'][this.filterMetadata[j].dependentDataList.FieldAPIName]).toUpperCase() == (filterOption[this.filterMetadata[j].dependentDataList.FieldAPIName].filterValue).toUpperCase()){
                                    isMatch = true;
                                }else{
                                    isMatch = false;
                                    break;
                                }
                           }
                        }else if((array[i]['sobjectRecord'][this.filterMetadata[j].data.fieldApiName]) == filterOption[this.filterMetadata[j].data.fieldApiName].filterValue){
                            isMatch = true;
                        }else{
                            isMatch = false;
                            break;
                        }
                    //check if filter type is Text
                    }else if(fieldType != undefined && fieldType == 'Text' && filterOption[this.filterMetadata[j].data.fieldApiName].filterValue != undefined){
                        if(array[i]['sobjectRecord'][this.filterMetadata[j].data.fieldApiName] == filterOption[this.filterMetadata[j].data.fieldApiName].filterValue){
                            isMatch = true;
                        }else{
                            isMatch = false;
                            break;
                        }
                    // if no criteria match show record
                    }else{
                        isMatch = true;
                    }
                }
            }
            //if is match is true,push article to list 
            if(isMatch){
                filtereData.push(array[i]);
            }
        }
        //return list of filtered articles
        return filtereData;
    }
}