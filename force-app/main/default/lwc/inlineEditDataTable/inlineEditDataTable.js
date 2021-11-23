import { LightningElement, api, track } from 'lwc';
import get_Table_details from '@salesforce/apex/inlineEditDataTableController.initiateDataTable';
import uploadFile from '@salesforce/apex/inlineEditDataTableController.uploadFile';
import FileSizeMessage from '@salesforce/label/c.FileSizeMessage';
import UploadFileSuccessMessage from '@salesforce/label/c.UploadFileSuccessMessage';

export default class InlineEditDataTable extends LightningElement {

    @api tableData = [];
    @api tableName = '';
    @track totalrows;
    @track isSelectAll = false;
    @track isSelectPageAll = false;
    @api filterstring;
    csvdataTable = [];
    selectedrecordcount = 0;
    dataTableInfo = [];
    isLoading;
    isdatanotpresent = true;
    totalselectedrows = [];
    tableColumns = [];
    isEditModeOn = false;
    dataCache = [];
    tableDataOriginal = [];
    modifiedRecords = [];
    updatedTableData;
    selectedRow = [];
    mapOfIdObject;
    paginationWrapper = [];
    tableInformation = [];
    onChangeEvent = false;
    searchText = '';
    sorticonname = '';
    sortyBY = '';
    //Start of EDGE-207158 by Abhishek(Osaka)
    MAX_FILE_SIZE = 1000000;
    @track fileName = '';
    filesUploaded = [];
    file;
    fileContents;

    //End of EDGE-207158 by Abhishek(Osaka)

    //START: Added for EDGE-215103
    @track isTermStatusExpiring = false;
    @track isTermStatusExpired = false;
    //END for EDGE-215103
    //Start EDGE-213740
    @track istransitionMROScreen = false;
    //End EDGE-213740

    @api setData(value) {//dpg-4072

        console.log('Inside setData');
        console.log(value);
        this.setAttributes(value);

    }

    setAttributes(value) {
        this.tableData = value;
        this.csvdataTable = this.tableData;
        this.totalrows = this.tableData.length;
        var tempMapOfIdObject = new Map();
        if (this.tableData != undefined && this.tableData.length > 0) {
            for (var i = 0; i < this.tableData.length; i++) {
                tempMapOfIdObject.set(this.tableData[i].Id, this.tableData[i]);



            }

            this.mapOfIdObject = tempMapOfIdObject;
            this.setupTable();
        } else {
            this.setupTable();
        }
    }
    renderedCallback() {

    }
    connectedCallback() {
        //Added by Dheeraj (isEmpty) check
        if (!this.isEmpty(this.tableName)) {
            this.isLoading = true;
            get_Table_details({ tname: this.tableName })
                .then(result => {
                    this.sorticonname = 'utility:arrowdown';
                    this.csvdataTable = this.tableData;
                    console.log('this.tableData', JSON.stringify(this.tableData));
                    this.totalrows = this.tableData.length;
                    var records = result;
                    console.log('result', result);
                    this.dataTableInfo = records;
                    this.tableColumns = records.columndetail;
                    var cloneTableColumnsData = this.tableColumns;
                    this.tableColumns = cloneTableColumnsData;
                    this.tableInformation = records.dataTableConfig;
                    console.log(this.tableInformation);
                    var tempMapOfIdObject = new Map();
                    if (this.tableData.length > 0 && this.tableData != undefined) {
                        for (var i = 0; i < this.tableData.length; i++) {
                            tempMapOfIdObject.set(this.tableData[i].Id, this.tableData[i]);
                        }
                        this.isdatanotpresent = false;
                        this.mapOfIdObject = tempMapOfIdObject;
                        this.setupTable();
                    } else {
                        this.setupTable();
                    }

                })
                .catch(error => {
                    console.log('Inside Catch' + error);
                });
        }
    }
    updatedatawithlookupvalue(event) {
        var colIndex = event.target.getAttribute('data-id');
        var rowIndex = event.target.name;
        var value = event.detail.selectedRecordId;
        this.updateTable(rowIndex, colIndex, value);
    }
    resetPageNumber(event) {
        var value = event.target.value;
        this.paginationWrapper.pageSize = value;
        this.tableInformation.Page_Size__c = parseInt(value);
        this.pagination(this.updatedTableData);
    }
    /*Enable edit mode on click edit icon */
    editField(event) {
        var rowIndex = event.target.name,
            colIndex = event.target.getAttribute('data-id');
        var data = this.tableData;
        data[rowIndex].fields[colIndex].viewMode = false;
        //   data[rowIndex].fields[colIndex].tdClassName = 'slds-cell-edit slds-is-edited';
        this.tableData = data;
        this.isEditModeOn = true;
    }
    /* On change of cell value update the datatable */
    onInputChange(event) {
        this.onChangeEvent = true;
        var value = event.target.value,
            rowIndex = event.target.name,
            colIndex = event.target.getAttribute('data-id');
        var data = this.tableData;
        data[rowIndex].fields[colIndex].viewMode = true;
        this.updateTable(rowIndex, colIndex, value);

    }
    onCheckBoxValueChange(event) {
        var value = event.target.checked,
            rowIndex = event.target.name,
            colIndex = event.target.getAttribute('data-id');
        var data = this.tableData;
        data[rowIndex].fields[colIndex].viewMode = true;
        this.updateTable(rowIndex, colIndex, value);
    }
    //EDGE-172362 Kalashree Borgaonkar. Move DML onBlur for text fields
    nowcommit(event) {
        var value = event.target.value;
        var rowIndex = event.target.name;
        var colIndex = event.target.getAttribute('data-id');
        this.updateTable(rowIndex, colIndex, value);
    }

    onBlurChange(event) {
        if (!this.onChangeEvent) {
            var value = event.target.value,
                rowIndex = event.target.name,
                colIndex = event.target.getAttribute('data-id');
            var data = this.tableData;
            data[rowIndex].fields[colIndex].viewMode = true;
        }

    }
    /* Close edit mode */
    /*  closeEditMode(){
        var dataCache = this.dataCache;
        var originalData = this.tableDataOriginal;
        this.records= JSON.parse(JSON.stringify(dataCache));
        this.tableData=JSON.parse(JSON.stringify(originalData));
        this.isEditModeOn=false;
        this.error='';
        this.pagination();
    } */
    /*Send Changed row data to PArent component*/
    saveRecords() {
        this.isLoading = true;
        this.isEditModeOn = false;
        const saveEvent = new CustomEvent('datatablesaveevent', {
            detail: {
                recordsString: JSON.stringify(this.modifiedRecords),
            }
        });
        this.dispatchEvent(saveEvent);
        this.isLoading = false;

    }
    @api
    setupTable() {
        var cols = this.tableColumns,
            data = this.tableData;
        this.setupColumns(cols);
        if (data != undefined && data.length > 0) {
            this.tableDataOriginal = data;
            this.setupData(data);
        }
        this.isLoading = false;
    }
    /*Setting Up dataTable Columns */
    setupColumns(cols) {
        var tempCols = [];
        try {
            if (cols) {
                cols.forEach(function (col) {
                    col.thClassName = "slds-truncate";
                    col.thClassName += col.sortable === true ? " slds-is-sortable" : "";
                    col.thClassName += col.resizable === true ? " slds-is-resizable" : "";
                    col.style = col.width ? "width:" + col.width + "px;" : "";
                    col.style += col.minWidth ? "min-width:" + col.minWidth + "px;" : "";
                    col.style += col.maxWidth ? "max-width:" + col.maxWidth + "px;" : "";
                    if (col.sortable === true) {
                        col.sortBy = col.fieldName;
                        if (col.type === "link" && col.attributes && typeof col.attributes.label === "object")
                            col.sortBy = col.attributes.label.fieldName;
                    }
                    col.ishidden = col.Hide_Column;
                    tempCols.push(col);
                });
                this.tableColumns = JSON.parse(JSON.stringify(tempCols));
            }
        }
        catch (err) {
            console.log('error in setupColumns==' + err);
        }
    }
    /*Set DataTable data for making it dynamic  inline  editable table */
    setupData(data) {
        debugger;
        var tableData = [],
            cols = this.tableColumns;
        try {
            this.dataCache = JSON.parse(JSON.stringify(data));
            if (data) {
                data.forEach(function (value, index) {
                    var row = {}, fields = [];
                    cols.forEach(function (col) {
                        //set data values
                        var field = {};
                        field.name = col.fieldName;
                        field.ishidden = col.Hide_Column;
                        field.value = value[col.fieldName] != undefined ? value[col.fieldName] : '';
                        field.type = col.type ? col.type : "text";
                        if (field.type === "text") {
                            field.isViewSpecialType = true;
                            field.fieldTextType = true;

                        }
                        if (field.type === "picklist") {
                            field.isPickListType = true;
                            field.isEditSpecialType = true;
                            field.selectOptions = col.selectOptions;
                        }
                        if (field.type === "date") {
                            field.isViewSpecialType = true;
                            field.fieldDateType = true;
                        }
                        if (field.type === "Lookup") {
                            field.isViewSpecialType = true;
                            field.isEditSpecialType = true;
                            field.fieldLookupType = true;
                            field.objectName = col.Reference_Object;
                            field.fieldName = col.Reference_Field;
                            field.isEditLookupType = true;
                        }
                        if (field.type === "checkbox") {
                            field.isViewSpecialType = true;
                            field.fieldcheckboxType = true;
                            field.isEditSpecialType = true;
                            field.isEditCheckBoxType = true;
                        }
                        if (field.type === "icon") {
                            field.isViewSpecialType = true;
                            field.fieldIconType = true;
                        }

                        if (field.type === "currency") {
                            field.isViewSpecialType = true;
                            field.fieldNumberType = true;
                            if (col.attributes) {
                                field.formatter = col.attributes.formatter;
                                field.style = col.attributes.formatter;
                                field.minimumFractionDigits = col.attributes.minimumFractionDigits ? col.attributes.minimumFractionDigits : 0;
                                field.maximumFractionDigits = col.attributes.maximumFractionDigits ? col.attributes.maximumFractionDigits : 2;
                                field.currencyCode = col.attributes.currencyCode ? col.attributes.currencyCode : "AUD";
                            }
                        }
                        if (field.type === "link") {
                            field.isViewSpecialType = true;
                            field.fieldLinkType = true;
                            if (col.attributes) {
                                if (typeof col.attributes.label === "object")
                                    field.label = value[col.attributes.label.fieldName];
                                else field.label = col.attributes.label;

                                if (typeof col.attributes.title === "object")
                                    field.title = value[col.attributes.title.fieldName];
                                else field.title = col.attributes.title;

                                if (col.attributes.actionName) {
                                    field.type = "link-action";
                                    field.actionName = col.attributes.actionName;
                                }
                                field.target = col.attributes.target;
                            }
                        }

                        //START: Added for EDGE-215103
                        if (field.name.toLowerCase() === 'termstatus' && field.value === 'Expiring Soon') {
                            field.isTermStatusExpiring = true;
                        }
                        if (field.name.toLowerCase() === 'termstatus' && field.value === 'Expired' && value.isgreyedout == true) {
                            field.isTermStatusExpired = true;
                            row.isTermStatusExpired = true;
                        }
                        //END for EDGE-215103
                        //Start EDGE-213740
                        if (value.transitionMROScreen === 'TRUE') {
                            field.istransitionMROScreen = true;
                        }
                        //End EDGE-213740
                        field.editable = col.editable ? col.editable : false;
                        field.tdClassName = field.editable === true ? 'slds-cell-edit' : 'slds-cell-wrap';
                        field.viewMode = true;
                        fields.push(field);
                    });
                    row.id = value.Id;
                    //EDGE-196002. Added condition for conditionally changing color to grey
                    if (value.isgreyedout != undefined && value.isgreyedout == true) {
                        row.isgrey = 'disabled';
                    }
                    else {
                        row.isgrey = '';
                    }
                    row.isSelected = false;
                    row.fields = fields;
                    tableData.push(row);
                });
                this.tableData = tableData;
                this.updatedTableData = this.tableData;
                //this.tableDataOriginal = this.tableData;
                this.pagination(this.tableData);
                this.isLoading = false;;
            }
        }
        catch (err) {
            console.log('error==' + err);
        }
    }
    /* Update datatAble on change of cell value */
    updateTable(rowIndex, colIndex, value) {
        try {
            //Update Displayed Data
            var data = this.tableData;
            data[rowIndex].fields[colIndex].value = value;
            data[rowIndex].fields[colIndex].viewMode = true;
            this.tableData = data;
            for (var j = 0; j < this.updatedTableData.length; j++) {
                if (this.updatedTableData[j].id == this.tableData[rowIndex].id) {
                    this.updatedTableData[j].fields = this.tableData[rowIndex].fields;
                }
            }
            //Update Displayed Data Cache
            /*  var updatedData = this.updatedTableData;
              updatedData[rowIndex].fields[colIndex].value = value;
              updatedData[rowIndex].fields[colIndex].viewMode = true;
              this.updatedTableData = updatedData; */

            //Update modified records which will be used to update corresponding salesforce records
            var records = [];// this.modifiedRecords;
            var recIndex = records.findIndex(rec => rec.id === data[rowIndex].id);
            if (recIndex !== -1) {
                records[recIndex]["" + data[rowIndex].fields[colIndex].name] = value;
            } else {
                var tempRecords = {};
                tempRecords["id"] = data[rowIndex].id;
                for (var i = 0; i < data[rowIndex].fields.length; i++) {
                    tempRecords["" + data[rowIndex].fields[i].name] = data[rowIndex].fields[i].value;
                }
                records.push(tempRecords);

            }
            for (var i = 0; i < records.length; i++) {
                this.mapOfIdObject.set(records[i].id, records[i]);
            }
            var dataCache = [];
            this.modifiedRecords = records;
            for (let value of this.mapOfIdObject.values()) {
                dataCache.push(value);
            }
            this.dataCache = dataCache
            this.saveRecords();
            this.getSelectedRowData();
        }
        catch (err) {
            console.log('err==' + err);
        }
    }
    /*On row selection on click of checkBox */
    selectCheckbox(event) {
        var id = event.target.name;
        var value = event.target.checked;
        var tempTableData = [];
        for (var i = 0; i < this.tableData.length; i++) {
            if (id == this.tableData[i].id) {
                this.tableData[i].isSelected = value;
            }

            tempTableData.push(this.tableData[i]);
        }
        this.tableData = tempTableData;
        this.getSelectedRowData();
    }
    /* Select all rows on click of Select All checkbox at column level*/
    selectAllCheckbox(event) {
        var value = event.target.checked;
        this.isSelectPageAll = value;
        /*if(this.isSelectPageAll==true){
            this.isSelectAll = true;
        }
        else{
            this.isSelectAll = false;
        }*/
        var tempTableData = [];
        if (this.updatedTableData != undefined) {
            for (var i = 0; i < this.updatedTableData.length; i++) {
                for (var j = 0; j < this.tableData.length; j++) {
                    if (this.updatedTableData[i].id == this.tableData[j].id) {
                        //START- Modified for DIGI-9322
                        if (this.updatedTableData[i].isTermStatusExpired === true) {
                            this.updatedTableData[i].isSelected = false;
                            this.tableData[j].isSelected = false;
                        }
                        else {
                            this.updatedTableData[i].isSelected = value;
                            this.tableData[j].isSelected = value;
                        }
                        //END for DIGI-9322    
                    }
                }

            }
            this.getSelectedRowData();
        }

    }
    selectAllrecords(event) {
        console.log('---selectAllrecords---');
        var value = event.target.checked;
        this.isSelectAll = value;
        this.isSelectPageAll = value;
        var tempTableData = [];
        if (this.updatedTableData != undefined) {
            for (var i = 0; i < this.updatedTableData.length; i++) {
                //START: Modified for DIGI-9322
                if (this.updatedTableData[i].isTermStatusExpired === true) {
                    this.updatedTableData[i].isSelected = false;
                }
                else {
                    this.updatedTableData[i].isSelected = value;
                }
                //END for DIGI-9322
            }
            this.getSelectedRowData();
            this.pagination(this.updatedTableData);
        }
    }
    /*Pass selected row data to parent component through custom event   */
    getSelectedRowData() {
        var tempSelectedRow = [];

        for (var i = 0; i < this.updatedTableData.length; i++) {
            if (this.updatedTableData[i].isSelected) {
                tempSelectedRow.push(this.mapOfIdObject.get(this.updatedTableData[i].id));
            }
        }
        this.selectedRow = tempSelectedRow;
        console.log('selectedRow:==' + JSON.stringify(this.selectedRow));
        if (this.selectedRow.length == this.totalrows) {
            this.isSelectAll = true;
            this.isSelectPageAll = true;
        }
        else {
            this.isSelectAll = false;
            this.isSelectPageAll = false;
        }
        const rowSelectionEvent = new CustomEvent('selectedrowevent', {
            detail: {
                selectedRow: JSON.stringify(this.selectedRow),

            }
        });
        this.dispatchEvent(rowSelectionEvent);
    }

    /*Records pagination as per page size */
    pagination(data) {
        if (data != null && data != undefined) {
            this.createPaginationWrapper();
            this.paginationWrapper.items = data;
            this.paginationWrapper.totalRecords = this.paginationWrapper.items.length;//this.tableData.length;
            this.paginationWrapper.totalPages = Math.ceil(this.paginationWrapper.totalRecords / this.paginationWrapper.pageSize);
            this.tableData = this.paginationWrapper.items.slice(0, this.paginationWrapper.pageSize);
            var offset = (this.paginationWrapper.currentPage - 1) * this.paginationWrapper.pageSize;
            this.paginationWrapper.startingRecord = offset + 1;
            var currentRecordEnd = this.paginationWrapper.pageSize * this.paginationWrapper.currentPage;
            this.paginationWrapper.endingRecord = this.paginationWrapper.totalRecords >= currentRecordEnd ? currentRecordEnd : this.paginationWrapper.totalRecords;
            this.showOrHideButton();
        }
    }
    /* Show previous page records on datatable on click of previous Button*/
    previous() {
        if (this.paginationWrapper.currentPage > 1) {
            this.paginationWrapper.currentPage = this.paginationWrapper.currentPage - 1;
            this.displayRecordPerPage(this.paginationWrapper.currentPage);
            this.getcheckboxvalue();
        }

    }
    /* Show first page records on datatable on click of first Button*/
    first() {
        this.displayRecordPerPage(this.paginationWrapper.firstPage);
        this.paginationWrapper.currentPage = this.paginationWrapper.firstPage;
        this.showOrHideButton();
        this.getcheckboxvalue();
    }
    /* Show next page records on datatable on click of next Button*/
    next() {
        if ((this.paginationWrapper.currentPage < this.paginationWrapper.totalPages) && this.paginationWrapper.currentPage !== this.paginationWrapper.totalPages) {
            this.paginationWrapper.currentPage = this.paginationWrapper.currentPage + 1;
            this.displayRecordPerPage(this.paginationWrapper.currentPage);
            this.getcheckboxvalue();
        }
    }
    /* Show last page records on datatable on click of last Button*/
    last() {
        this.displayRecordPerPage(this.paginationWrapper.totalPages);
        this.paginationWrapper.currentPage = this.paginationWrapper.totalPages;
        this.showOrHideButton();
        this.getcheckboxvalue();
    }
    /*get value of select all for individual page*/
    getcheckboxvalue() {
        var flag = false;
        for (var record of this.tableData) {
            if (record.isSelected == false) {
                flag = true;
                break;
            }
        }
        if (flag == true) {
            this.isSelectPageAll = false;
            console.log('flag: isSelectPageAll', this.isSelectPageAll)
        }

        else {
            this.isSelectPageAll = true;
            console.log('flag: isSelectPageAll', this.isSelectPageAll)
        }
    }

    /* Show Records on DataTable as pagination */
    displayRecordPerPage(currentPage) {
        this.paginationWrapper.startingRecord = ((currentPage - 1) * this.paginationWrapper.pageSize);
        this.paginationWrapper.endingRecord = (this.paginationWrapper.pageSize * currentPage);

        this.paginationWrapper.endingRecord = (this.paginationWrapper.endingRecord > this.paginationWrapper.totalRecords)
            ? this.paginationWrapper.totalRecords : this.paginationWrapper.endingRecord;

        this.tableData = this.paginationWrapper.items.slice(this.paginationWrapper.startingRecord, this.paginationWrapper.endingRecord);
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
    /* Diable edit mode on  removal of focus from edit cell*/
    onBlur(event) {
        if (!this.onChangeEvent) {
            var value = event.target.value,
                rowIndex = event.target.name,
                colIndex = event.target.getAttribute('data-id');
            var data = this.tableData;
            data[rowIndex].fields[colIndex].viewMode = true;
        }

    }
    /*Pagination wrapper to store the attributes required for pagination */
    createPaginationWrapper() {
        var paginationWrapper = [];
        paginationWrapper.pageSize = this.tableInformation.Page_Size__c;
        paginationWrapper.records;
        paginationWrapper.deferPagination = this.tableInformation.Defer_Pagination__c;
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
    /*Show custom toast message on success or Error scenerio */
    @api
    showToastMessage(toasttitle, toastmsg, toastvariant) {
        let customToast = this.template.querySelector('c-lwc-custom-toast');
        customToast.title = toasttitle;
        customToast.message = toastmsg;
        customToast.variant = toastvariant;
        customToast.mode = 'dismissible';
        customToast.duration = '4000';
        customToast.autoClose = true;
        customToast.autoCloseErrorWarning = true;
        customToast.showCustomNotice();
    }
    handleSearch(evt) {
        var searchText = evt.target.value;

        if (evt.keyCode == 13 && searchText != undefined && searchText != '') {
            searchText = searchText.toLowerCase();
            var data = this.updatedTableData;
            var results = [];
            this.isLoading = true;
            for (var i = 0; i < data.length; i++) {
                //console.log(data);
                var searchMatched = false;
                for (var j = 0; j < data[i].fields.length; j++) {
                    if (data[i].fields[j].type != 'checkbox' && data[i].fields[j].type != 'currency'
                        && data[i].fields[j].value != null && data[i].fields[j].value != undefined) {
                        var compareval = data[i].fields[j].value.toLowerCase();
                        if (compareval.includes(searchText)) {
                            searchMatched = true;
                            break;
                        }
                    }
                }
                if (searchMatched) {
                    results.push(data[i]);
                }
            }
            var regex;
            this.tableData = results;
            this.isLoading = false;
        } else if (searchText == null || searchText == '') {
            this.tableData = this.updatedTableData;
        }

        this.pagination(this.tableData);
    }
    // Abinash : Below code is for Download DataTable data in a csv file 
    //START FOR CSV

    generateCsvFile() {
        // get the Records list from 'data' attribute 
        var stockData = this.csvdataTable;
        var tabledata = [];
        for (var i = 0; i < stockData.length; i++) {
            tabledata.push(stockData[i]);
        }
        var columns = this.tableColumns;
        this.downloadCsv(tabledata, columns);
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
        hiddenElement.download = this.tableInformation.Display_Label__c + '.csv';//'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
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

    sortTable(event) {
        this.sortyBY = event.currentTarget.dataset.headername;
        var sortDirection = '';
        var changeIcon = '';
        if (this.sorticonname == 'utility:arrowup') {
            sortDirection = 'desc';
            changeIcon = 'utility:arrowdown';
        }
        else if (this.sorticonname == 'utility:arrowdown') {
            sortDirection = 'asc';
            changeIcon = 'utility:arrowup';
        }
        this.sortData(this.sortyBY, sortDirection);
        this.sorticonname = changeIcon;


    }
    sortData(sortBy, direction) {
        var reverse = direction !== "asc",
            data = this.dataCache;
        if (!data) return;

        var data = Object.assign([], data.sort(this.sortDataBy(sortBy, reverse ? -1 : 1)));
        this.setupData(data);
    }

    sortDataBy(field, reverse, primer) {
        var key = primer
            ? function (x) { return primer(x[field]) }
            : function (x) { return x[field] };

        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        }
    }

    //Start of EDGE-207158 by Abhishek(Osaka) Introducing Upload button to Bulk Update Nicknames
    uploadFile(event) {
        //this.isLoading = true;
        var fileSizeError = FileSizeMessage;
        console.log('Table Information' + this.tableInformation.DeveloperName);
        console.log('Inside uploadFile');
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.file = this.filesUploaded[0];
            if (this.file.size > this.MAX_FILE_SIZE) {
                console.log('File Size is to long');
                this.showToastMessage('Error', fileSizeError, 'error');
            }
            else {
                this.fileReader = new FileReader();
                this.fileReader.onloadend = (() => {
                    this.fileContents = this.fileReader.result;
                    this.saveToFile();
                });
                this.fileReader.readAsText(this.file);
            }
        }
    }

    saveToFile() {
        var metaDataName = this.tableInformation.DeveloperName;
        this.isLoading = true;
        console.log(JSON.stringify(this.fileContents));
        uploadFile({ base64Data: JSON.stringify(this.fileContents), metaDataRecName: metaDataName })
            .then(result => {
                if (result == UploadFileSuccessMessage) {
                    window.console.log('result ====> ' + result);
                    this.showToastMessage('Success', result, 'success');
                    this.isLoading = false;
                    window.location.reload();
                }
                else {
                    window.console.log('else result ====> ' + result);
                    this.showToastMessage('Error', result, 'error');
                    this.isLoading = false;
                }

            })
            .catch(error => {
                window.console.log(error);
                this.showToastMessage('Error', error, 'error');
                this.isLoading = false;

            });
    }

    //End of EDGE-207158 by Abhishek(Osaka) Introducing Upload button to Bulk Update Nicknames
    // Added by Dheeraj
    isEmpty(str) {
        return (!str || 0 === str.length || str === null || str === '' || str === 'undefined');
    }

}