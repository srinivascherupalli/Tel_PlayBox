/****************************************************************
Description -Show data in tree grid form  
Author       -Dheeraj Bhatt
EDGE         -203929
*****************************************************************/
import { api,track,LightningElement } from 'lwc';
import TransitionAssignNumbersToTable from '@salesforce/label/c.TransitionAssignNumbersToTable';//EDGE-213744:Label to store CSV file Name
export default class LwcTreeGrid extends LightningElement {
    @api gridColumns;
    @api tableData;
    @api gridExpandedRows;
    @api gridLoadingState=false;
    @track updatedTableData=[];
    @track selectedRows=[];
    @track selectedrecords = 0;
    @track mapOfIdObject;
    @track gridData;
    @api childName;
    @track totalrows;
    @api paginationWrapper = [];
    isdatanotpresent = true;
    pageSizevalue = '10';
    get options() {
        return [
                 { label: '10', value: '10' },
                 { label: '25', value: '25' },
                 { label: '50', value: '50' },
                 { label: '100', value: '100' },
                 { label: '200', value: '200' }
               ];
    }
    handleChange(event) {
        this.pageSizevalue = event.detail.value;
        this.paginationWrapper.pageSize = this.pageSizevalue;
        this.pagination(this.updatedTableData);
     }
    
    connectedCallback(){
        var tempMapOfIdObject = new Map();
        this.totalrows = this.tableData.length;
            
        if( this.tableData != null && this.tableData.length > 0){
            var resultData= JSON.parse(JSON.stringify(this.tableData));
            if(!this.isEmpty(this.childName)){
                for (var i=0; i<resultData.length; i++ ) {
                    tempMapOfIdObject.set(resultData[i].Id, resultData[i]);
                    if(resultData[ i ][ this.childName ] != null && resultData[ i ][ this.childName ].length >0){
                        resultData[ i ]._children = resultData[ i ][ this.childName ];
                    }                
                }
            }
            console.log(resultData);
            this.mapOfIdObject = tempMapOfIdObject;
            this.gridData=resultData;
            this.updatedTableData = resultData;
            this.pagination(this.gridData);
        }
    }
    /*Records pagination as per page size */
    pagination(data) {
        if (data != null && data != undefined) {
            console.log('this.paginationWrapper');            
            this.createPaginationWrapper();            
            this.paginationWrapper.items = data;
            this.paginationWrapper.totalRecords = this.paginationWrapper.items.length;//this.tableData.length;
            this.paginationWrapper.totalPages = Math.ceil(this.paginationWrapper.totalRecords / this.paginationWrapper.pageSize);
            this.gridData = this.paginationWrapper.items.slice(0, this.paginationWrapper.pageSize);
            var offset = (this.paginationWrapper.currentPage - 1) * this.paginationWrapper.pageSize;
            this.paginationWrapper.startingRecord = offset + 1;
            var currentRecordEnd = this.paginationWrapper.pageSize * this.paginationWrapper.currentPage;
            this.paginationWrapper.endingRecord = this.paginationWrapper.totalRecords >= currentRecordEnd ? currentRecordEnd : this.paginationWrapper.totalRecords;
            console.log(this.paginationWrapper);
            this.showOrHideButton();
        }
    }
    /* Show Records on DataTable as pagination */
    displayRecordPerPage(currentPage) {
        this.paginationWrapper.startingRecord = ((currentPage - 1) * this.paginationWrapper.pageSize);
        this.paginationWrapper.endingRecord = (this.paginationWrapper.pageSize * currentPage);

        this.paginationWrapper.endingRecord = (this.paginationWrapper.endingRecord > this.paginationWrapper.totalRecords)
            ? this.paginationWrapper.totalRecords : this.paginationWrapper.endingRecord;

        this.gridData = this.paginationWrapper.items.slice(this.paginationWrapper.startingRecord, this.paginationWrapper.endingRecord);
        this.paginationWrapper.startingRecord = this.paginationWrapper.startingRecord + 1;
        this.showOrHideButton();
    }
    /* Disable/Enable Pagination Button */
    showOrHideButton() {
        this.paginationWrapper.disableFirstButton = true;
        this.paginationWrapper.disableNextButton = true;
        this.paginationWrapper.disablePreviousButton = true;
        this.paginationWrapper.disableLastButton = true;
        if (this.paginationWrapper.currentPage != this.paginationWrapper.firstPage) {
            this.paginationWrapper.disableFirstButton = false;
            this.paginationWrapper.disablePreviousButton = false;
        }
        if (this.paginationWrapper.currentPage != this.paginationWrapper.totalPages) {
            this.paginationWrapper.disableLastButton = false;
            this.paginationWrapper.disableNextButton = false;
        }
    }
    /*Pagination wrapper to store the attributes required for pagination */
    createPaginationWrapper() {
        var paginationWrapper = [];
        paginationWrapper.pageSize = this.pageSizevalue;//this.tableInformation.Page_Size__c;
        paginationWrapper.records;
        paginationWrapper.deferPagination = false;//this.tableInformation.Defer_Pagination__c;
        paginationWrapper.currentPage = 1;
        paginationWrapper.items;
        paginationWrapper.startingRecord;
        paginationWrapper.endingRecord;
        paginationWrapper.totalRecords;
        paginationWrapper.totalPages;
        paginationWrapper.firstPage = 1;
        paginationWrapper.disableFirstButton;
        paginationWrapper.disableNextButton;
        paginationWrapper.disablePreviousButton;
        paginationWrapper.disableLastButton;
        this.paginationWrapper = paginationWrapper;
    }
    /* Show previous page records on datatable on click of previous Button*/
    previous() {
        if (this.paginationWrapper.currentPage > 1) {
            this.paginationWrapper.currentPage = this.paginationWrapper.currentPage - 1;
            this.displayRecordPerPage(this.paginationWrapper.currentPage);
            //this.getcheckboxvalue();
        }
        
    }
    /* Show first page records on datatable on click of first Button*/
    first() {
        this.displayRecordPerPage(this.paginationWrapper.firstPage);
        this.paginationWrapper.currentPage = this.paginationWrapper.firstPage;
        this.showOrHideButton();
        //this.getcheckboxvalue();
    }
    /* Show next page records on datatable on click of next Button*/
    next() {
        if ((this.paginationWrapper.currentPage < this.paginationWrapper.totalPages) && this.paginationWrapper.currentPage !== this.paginationWrapper.totalPages) {
            this.paginationWrapper.currentPage = this.paginationWrapper.currentPage + 1;
            this.displayRecordPerPage(this.paginationWrapper.currentPage);
            //this.getcheckboxvalue();
        }
    }
    /* Show last page records on datatable on click of last Button*/
    last() {
        this.displayRecordPerPage(this.paginationWrapper.totalPages);
        this.paginationWrapper.currentPage = this.paginationWrapper.totalPages;
        this.showOrHideButton();
        //this.getcheckboxvalue();
    }
/*get value of select all for individual page*/ 
getcheckboxvalue() {
    var flag=false;
    for(var record of this.tableData){
        if (record.isSelected == false) { 
            flag = true;
            break;

        }

    }
    if(flag==true){ 
        this.isSelectPageAll = false;
        console.log('flag: isSelectPageAll',this.isSelectPageAll)
    }


    else{
        this.isSelectPageAll = true;
        console.log('flag: isSelectPageAll',this.isSelectPageAll)
    }  
}
    onrowselectionEvent(event){
        const selectedRows = event.detail.selectedRows;
        const rowSelectionEvent = new CustomEvent('selectedrowevent', {
            detail: {
                selectedRow: JSON.stringify(selectedRows),

            }
        });
        console.log(JSON.stringify(selectedRows));
        console.log(selectedRows.length)
        this.selectedrecords = selectedRows.length;
        this.dispatchEvent(rowSelectionEvent);

    }
    handleRowToggle(event){
        const rowName = event.detail.name;
        console.log(JSON.stringify(rowName));
        const hasChildrenContent = event.detail.hasChildrenContent;
        console.log('hasChildrenContent>>>'+hasChildrenContent);
        const isExpanded = event.detail.isExpanded;
        const row = event.detail.row;
        if (hasChildrenContent === false) {
            this.gridLoadingState = true;
            this.retrieveUpdatedData(rowName).then(newData => {
                this.gridData = newData;
                this.gridLoadingState = false;
            });
        }

    }
    retrieveUpdatedData(rowName) {
        return new Promise(resolve => {
            window.setTimeout(() => {
                const updatedData = this.addChildrenToRow(
                    this.gridData,
                    rowName,
                    this.childrenData[rowName]
                );

                resolve(updatedData);
            }, 2000);
        });
    }
    addChildrenToRow(data, rowName, children) {
        const newData = data.map(row => {
            let hasChildrenContent = false;
            if (
                row.hasOwnProperty('_children') &&
                Array.isArray(row._children) &&
                row._children.length > 0
            ) {
                hasChildrenContent = true;
            }
            if (row.name === rowName) {
                row._children = children;
             } else if (hasChildrenContent) {
                this.addChildrenToRow(row._children, rowName, children);
            }

            return row;
        });

        return newData;
    } 
@api refreshSelectedRowData(selectedRowsId){
    console.log('selectedRowsId=='+selectedRowsId);
this.selectedRows=selectedRowsId
}
isEmpty(str) {
    return (!str || 0 === str.length || str === null || str === '' || str=== 'undefined');
}

handleSearch(evt) {
    var searchText = evt.target.value;
    console.log('searchText>>>'+searchText);
    console.log(this.gridColumns);
    console.log(JSON.stringify(this.gridColumns));
    if (evt.keyCode == 13 && !this.isEmpty(searchText)){
        searchText = searchText;   
        var data = this.updatedTableData;
        //console.log(JSON.stringify(data));
        var resultData = [];

        for (var i = 0; i < data.length; i++) {
            var searchMatched = false;
           
            for(var l=0; l<this.gridColumns.length ; l++){   
                var objvalue = data[i][this.gridColumns[l].fieldName];
                if (objvalue != undefined && objvalue.includes(searchText)) { 
                    searchMatched = true;
                }
            }
        
            if(data[i].serviceAddOnList.length > 0){
                var childdata = data[i]._children;
                for (var j = 0; j < childdata.length; j++) { 
                    for(var k=0; k<this.gridColumns.length ; k++){   
                        var objvalue = childdata[j][this.gridColumns[k].fieldName];
                        if (objvalue != undefined && objvalue.includes(searchText)) { 
                            searchMatched = true;
                        }
                    }
                }
            }
            console.log('searchMatched>>>'+searchMatched);
            
            if (searchMatched) {
               resultData.push(data[i]);
            }
        }
        console.log(JSON.stringify(resultData));
        this.gridData = resultData;
    } else if (this.isEmpty(searchText)) {
        this.gridData = this.updatedTableData;
    }

    //this.pagination(this.tableData);
}
//START of EDGE-213744 Download CSV By Aishwarya
generateCsvFile() {
    // get the Records list from 'data' attribute 
    var stockData = this.tableData;
    var csvtabledata = [];
    console.log(stockData);
    for (var i = 0; i < stockData.length; i++) {
        csvtabledata.push(stockData[i]);
       if(stockData[ i ][ this.childName ] != null && stockData[ i ][ this.childName ].length >0){
            for (var j = 0; j < stockData[ i ][ this.childName ].length; j++) {
            csvtabledata.push(stockData[ i ][ this.childName ][j]);
            }
        }
    }
    var columns = this.gridColumns;
    console.log(JSON.stringify(csvtabledata));
    this.downloadCsv(csvtabledata, columns);
}
@api
downloadCsv(objectRecords, columns) {
    // call the helper function which "return" the CSV data as a String   
    var csv = this.convertArrayOfObjectsToCSV(objectRecords, columns);
    if (csv == null) { return; }

    // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
    var hiddenElement = document.createElement('a');
    hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
  //  hiddenElement.target = '_self'; //Commented '_self' and added '_blank' to fix download csv issue in LEX - Dheeraj
    hiddenElement.target = '_blank'; 
    hiddenElement.download = TransitionAssignNumbersToTable + '.csv';//'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
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
   /* var headercolumns = this.gridColumns;
    for (var i = 0; i < headercolumns.length > 0; i++) {
        header.push(headercolumns[i].label);// this labels use in CSV file header  
        keys.push(headercolumns[i].fieldName);// in the keys valirable store fields API Names as a key
    }*/
    keys = ['accountName','basketName','planName','Name','AddOnName__c','simSerialNumber','assignedNumber'];
    header = ['Account Name','Basket Id','Mobile Plan','Add-On','Add-On Details','SIM Serial','Number Assigned'];
    csvStringResult = '';
    csvStringResult += header.join(columnDivider);
    csvStringResult += lineDivider;
    console.log(objectRecords.length);
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
         console.log("Data to download ", csvStringResult);
        csvStringResult += lineDivider;
    }// outer main for loop close 

    // return the CSV formate String 
    return csvStringResult;
}// END of EDGE-213744 Download CSV By Aishwarya
}