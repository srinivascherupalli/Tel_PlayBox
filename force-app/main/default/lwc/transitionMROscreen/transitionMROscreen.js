import { LightningElement , api , track , wire} from 'lwc';

import getMRODetails from '@salesforce/apex/CompUtilityReplicatorManager.getMRODetails';
import enablePaymentTypes from '@salesforce/apex/CompUtilityReplicatorManager.enablePaymentTypes';
import transitionLabel from '@salesforce/label/c.csvFileLabel';

export default class TransitionMROscreen extends LightningElement {

    @api tableName = 'Transition_MRO_Screen';
    @api noPayment = 'This number has no Payment Types';
    @api MROCount;
    @api mapkeyvaluestore;
    @track paymentList;
    @track newMROValue = [];
    @track blankTable = [];
    accordianSection = '';
    @api activeSections;
    @track items = []; //this will hold key, value pair
    //@track value = ''; //initialize combo box value
    @track basketRecordId;
    @track searchValue;
    @track tableColumns=[];
    checkFlag = false;
    searchFlag = false;
    transitionRecords;
    value = "All Payment Types";//dpg-4072

    label = {
      transitionLabel,
  };

  handleSelect(event) {//dpg-4072
    this.value = event.target.value;
  }
 connectedCallback() {
 console.log('values',this.mapkeyvaluestore);
  if (this.mapkeyvaluestore.length > 0)
  
        {
          this.activeSections=this.mapkeyvaluestore[0].serviceStr;
          this.currenRecordId = this.mapkeyvaluestore[0].record;
          //console.log('this.mapkeyvaluestore[0].serviceStr', this.mapkeyvaluestore[0].serviceStr);
          //console.log('currenRecordId', this.mapkeyvaluestore[0].record);
          
        }
}

    expendAll(event) {
      
      var tempSelectedRow = [];
      this.activeSections =[];
        for (var i = 0; i < this.mapkeyvaluestore.length; i++) {
                tempSelectedRow.push(this.mapkeyvaluestore[i].serviceStr);
               }
               console.log('mapkeyvaluestore**' , this.mapkeyvaluestore);
               console.log('my daya',tempSelectedRow);
               console.log('recordId', this.recordId);
        this.activeSections = tempSelectedRow;
      
    }
    collapseAll(event) {
      this.activeSections=[];
}


/* EDGE-173837 changes by Jayghosh Mishra from Osaka Team-------START--------- */ 
 handleChange(event){
   
  
  const sVal = event.target.value;
  debugger;
  this.searchValue = sVal;
  //event.preventDefault();
  this.checkFlag = false;
  if(event.which == 13 ){
    event.preventDefault();
  }
  
  if(sVal.length > 0 ){
	  this.searchFlag = true;
	  for (var i = 0; i < this.mapkeyvaluestore.length; i++) {
		  this.basketRecordId = this.mapkeyvaluestore[0].record;
	  }
	  
	   getMRODetails({ basketId: this.basketRecordId, searchFinalVal : this.searchValue})
         .then(result => {
          this.checkFlag = true;
          //START: Modified for EDGE-224107
         //this.newMROValue = result;
         this.newMROValue = JSON.parse(result);
         //END for EDGE-224107
        console.log('mapkeyvaluestore::'+result);
        // console.log('Final Result after search !!', JSON.stringify(result));
         
            //this.blankTable = result;
           // console.log('NULL RESULTS ', result);
        
         
       })
  .catch(error => {
      this.error = '';
  });
  
  
  
  }else{
    //console.log('inside else @@@');
    this.searchFlag = false;

    for (var i = 0; i < this.mapkeyvaluestore.length; i++) {
		  this.basketRecordId = this.mapkeyvaluestore[0].record;
	  }
    
   getMRODetails({ basketId: this.basketRecordId, searchFinalVal : this.searchValue })
         .then(result => {
          this.newMROValue = [];
          //START: Modified for EDGE-224107
          //this.mapkeyvaluestore = result;
          this.mapkeyvaluestore = JSON.parse(result);
          //END for EDGE-224107
          console.log('mapkeyvaluestore::'+result);
         // console.log('Final Result after search !!', JSON.stringify(result));
          
       })
  .catch(error => {
      this.error = '';
  });
}
 
  }
  @wire(enablePaymentTypes) 
  paymentList;
  
  get paymentOptions() { 	
    console.log('payment options called');	
	  var returnOptions = [];     
	  if(this.paymentList.data){         
			this.paymentList.data.forEach(ele =>
			{
				returnOptions.push({label:ele.Label , value:ele.Label});
			});      
		}     
	 // console.log('returnOptions ##',JSON.stringify(returnOptions)); 
		return returnOptions;
   }
   /* EDGE-173837 -------END--------- */
  

 /* EDGE-179834 -------START--------- */
downloadCsvFile(event) {
    const columns = [
    {label: 'Service Number',fieldName: 'serviceNumber'}, 
    {label: 'Payment Type',fieldName: 'paymentType'}, 
    {label: 'MICA Bill Literal	',fieldName: 'billLiteral'}, 
    {label: 'Remaining Amount',fieldName: 'reminingAmount'}, 
    {label: 'Charge Option',fieldName: 'chargeOption'},
    {label: 'Remaining Term (Months)',fieldName: 'reminingTerm'},//Start EDGE-213740
    {label: 'Term End Date',fieldName: 'productEndDate'},
    {label: 'Term Status',fieldName: 'termStatus'},//End EDGE-213740
                   ];
                   this.tableColumns=columns;
                  var tabledata=[];
        var tableRecords=this.mapkeyvaluestore;
        for (var i = 0; i < tableRecords.length; i++) {

          if (tableRecords[i].mrowrapperList != undefined)
          {
              for (var j=0;j<tableRecords[i].mrowrapperList.length;j++)
              {
                
                tabledata.push(JSON.parse(JSON.stringify(tableRecords[i].mrowrapperList[j])));
              }
            }
            if (tableRecords[i].arowrapperList != undefined)//DPG-4072 START
          {
              for (var j=0;j<tableRecords[i].arowrapperList.length;j++)
              {
                
                tabledata.push(JSON.parse(JSON.stringify(tableRecords[i].arowrapperList[j])));
              }
            }//DPG-4072 END
        }
        console.log('data5', tabledata);
        this.downloadCsv(tabledata,columns);
  //this.template.querySelector("c-inline-edit-data-table").downloadCsv(columns, tabledata);
}



downloadCsv(objectRecords, columns) {
  // call the helper function which "return" the CSV data as a String   
  var csv = this.convertArrayOfObjectsToCSV(objectRecords, columns);
  if (csv == null) { return; }

  // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####   
  var currentdate = new Date(); 
  console.log('currentdate',currentdate);
  var fileDate =  String(currentdate.getDate()).padStart(2,'0') + String((currentdate.getMonth()+1)).padStart(2,'0') + String(currentdate.getFullYear());
  console.log('fileDate',fileDate);
  var hiddenElement = document.createElement('a');
  hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
  hiddenElement.target = '_self'; // 
  hiddenElement.download = this.label.transitionLabel+fileDate+'.csv';//'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
  document.body.appendChild(hiddenElement); // Required for FireFox browser
  hiddenElement.click(); // using click() js function to download csv file
}

convertArrayOfObjectsToCSV(objectRecords, columns) {
  var csvStringResult, counter, columnDivider, lineDivider;
  var keys = [];
  var header = [];
  // check if "objectRecords" parameter is null, then return from function
  if (objectRecords == null || !objectRecords.length) {
      return null;
  }
  // store ,[comma] in columnDivider variabel for sparate CSV values and 
  // for start next line use '\n' [new line] in lineDivider varaible  
  columnDivider = ',';
  lineDivider = '\n';
  var headercolumns = this.tableColumns;
  for (var i = 0; i < headercolumns.length > 0; i++) {
      header.push(headercolumns[i].label);// this labels use in CSV file header  
      keys.push(headercolumns[i].fieldName);// in the keys valirable store fields API Names as a key
  }
 
  csvStringResult = '';
  csvStringResult += header.join(columnDivider);
  csvStringResult += lineDivider;

  for (var i = 0; i < objectRecords.length; i++) {
      counter = 0;

      for (var sTempkey in keys) {
          var skey = keys[sTempkey];
          // add , [comma] after every String value,. [except first]
          if (counter > 0) {
              csvStringResult += columnDivider;
          }
          let value = '';
          if (objectRecords[i][skey] != undefined) {
              value = objectRecords[i][skey];
          }
          csvStringResult += '"' + value + '"';

          counter++;

      } // inner for loop close 
      csvStringResult += lineDivider;
  }// outer main for loop close 

  // return the CSV formate String 
  return csvStringResult;
}// END for CSV

 /* EDGE-179834 -------END--------- */


}