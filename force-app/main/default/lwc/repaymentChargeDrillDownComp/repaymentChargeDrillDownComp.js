import { LightningElement, track, api, wire } from 'lwc';
import getRepaymentResponseDetails from "@salesforce/apex/RepaymentSummaryHandler.getRepaymentResponseDetails";

export default class RepaymentChargeDrillDownComp extends LightningElement {

    @track records =[];
    @api columns;
    @track error;
    @api chargeId;
    @api statementNumber;
    @api accountNumber ;
    @track loadSpinner =false;
   
    @track selectedRows = [];
    
    
    paginationWrapper = [];
    
    @api tableData = [];
    @api error;
    @api previousSelectedRows;
    @api selection = [];
    @api oldSelectedRows; // to maintain chargeIdentifiers of selected records  across all pages
    @api oldSelectedData; // to maintain data of selected records across all pages

    paginationMapInt = new Map();
    dataToSendMapInt = new Map();

    columns = [
      {
        label: "Telstra Reference",
        fieldName: "orderNumber",
        type: "text",
        hideDefaultActions : "true"
      },
      {
        label: "Device Id",
        fieldName: "uniqueId",
        type: "text",
        hideDefaultActions : "true"
      },
      {
        label: "Purchase Date",
        fieldName: "purchaseDate",
        type: "text",
        hideDefaultActions : "true"
      },
      {
          label: "Quantity",
          fieldName: "quantity",
          type: "text",
          hideDefaultActions : "true"
        },
        {
          label: "Unit price (Ex GST)",
          fieldName: "unitPrice",
          type: "currency",
          hideDefaultActions : "true"
        },
      {
        label: "Repayment Number",
        fieldName: "installment",
        type: "currency",
        hideDefaultActions : "true"
      },
      {
        label: "Charged so far (Ex GST)",
        fieldName: "chargedSoFar",
        type: "currency",
        hideDefaultActions : "true"
      },
      {
        label: "Charged this invoice (Ex GST)",
        fieldName: "chargedThisInvoice",
        type: "currency",
        hideDefaultActions : "true"
      }
    ]
   
     connectedCallback() {
      
      this.setDataTableRows();
      this.loadSpinner = true;

      this.selection = [];
      
      
    }
    setDataTableRows()
    {
        getRepaymentResponseDetails({ chargeId: this.chargeId, statementNumber :this.statementNumber, accountNumber : this.accountNumber,handlerName:'RepaymentDetailsHandler'
        })
        .then((result) => {
         console.log('response rec',result);
          this.tableData = JSON.parse(result);
          
          this.error = undefined;
          this.loadSpinner = false;
          //this.records = this.tableData;
          console.log("inside recurring:", this.oldSelectedRows);
          if(this.oldSelectedRows != null && this.oldSelectedRows.get(this.chargeId) != undefined){
            console.log("selectedRowsMapfromParent",this.oldSelectedRows.get(this.chargeId)); 
            this.paginationMapInt = new Map(this.oldSelectedRows.get(this.chargeId));
          }
          if(this.oldSelectedData != null && this.oldSelectedData.get(this.chargeId) != undefined){
            console.log("selectedDataMapfromParent",this.oldSelectedData.get(this.chargeId)); 
            this.dataToSendMapInt = new Map(this.oldSelectedData.get(this.chargeId));
          }

          this.pagination(this.tableData);
          this.displayRecordPerPage(this.paginationWrapper.currentPage);
        })
        .catch((error) => {
            this.error = error;
            this.records = undefined;
            this.loadSpinner = false;
        });
       
    }

    rowSelection (event){

        var selectedRows = event.detail.selectedRows;
        var selectedRowArray = new Array();
        var dataToSendArray = new Array();
        var paginationMap = this.paginationMapInt;
        var dataToSendMap = this.dataToSendMapInt;
        //paginationMap = this.paginationMapInt;
        if(selectedRows != undefined && selectedRows.length >0){
            for(var i=0;i<selectedRows.length;i++){
                var data = selectedRows[i]; 
                if(data.chargeIdentifier != null){
                    selectedRowArray.push(data.chargeIdentifier);
                    dataToSendArray.push(data);
                }
            }
        }
        paginationMap.set(this.paginationWrapper.currentPage , selectedRowArray); //maintaining list of unique chargeidentifier  per page
        dataToSendMap.set(this.paginationWrapper.currentPage , dataToSendArray); // maintaining list of selected data per page
        this.paginationMapInt =  paginationMap;
        this.dataToSendMapInt =  dataToSendMap;
  
        console.log(this.paginationMapInt);
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
            
        }
        this.showOrHideButton();
    }
    /* Show previous page records on datatable on click of previous Button*/
    previous() {
     
        this.selection = [];
        if (this.paginationWrapper.currentPage > 1) {
            this.paginationWrapper.currentPage = this.paginationWrapper.currentPage - 1;
            this.displayRecordPerPage(this.paginationWrapper.currentPage);
            
        }
        
    }
    /* Show first page records on datatable on click of first Button*/
    first() {
        this.selection = [];
        this.displayRecordPerPage(this.paginationWrapper.firstPage);
        this.paginationWrapper.currentPage = this.paginationWrapper.firstPage;
        this.showOrHideButton();
    }
    /* Show next page records on datatable on click of next Button*/
    next() {
     
     this.selection = [];
        if ((this.paginationWrapper.currentPage < this.paginationWrapper.totalPages) && this.paginationWrapper.currentPage !== this.paginationWrapper.totalPages) {
            this.paginationWrapper.currentPage = this.paginationWrapper.currentPage + 1;
            console.log(this.paginationWrapper.currentPage);
            this.displayRecordPerPage(this.paginationWrapper.currentPage);
         
        }
    }
    /* Show last page records on datatable on click of last Button*/
    last() {
     
     this.selection = [];
        this.displayRecordPerPage(this.paginationWrapper.totalPages);
        this.paginationWrapper.currentPage = this.paginationWrapper.totalPages;
        this.showOrHideButton();
        
    }

    /* Show Records on DataTable as pagination */
    displayRecordPerPage(currentPage) {
        
        var getSelectedRows = this.paginationMapInt.get(currentPage);
        console.log("previously selected rows===>"+getSelectedRows);
        if(getSelectedRows!= null && getSelectedRows != undefined){
            this.selection = getSelectedRows;
        }
        this.paginationWrapper.startingRecord = ((currentPage - 1) * this.paginationWrapper.pageSize);
        this.paginationWrapper.endingRecord = (this.paginationWrapper.pageSize * currentPage);

        this.paginationWrapper.endingRecord = (this.paginationWrapper.endingRecord > this.paginationWrapper.totalRecords)
            ? this.paginationWrapper.totalRecords : this.paginationWrapper.endingRecord;

        this.tableData = this.paginationWrapper.items.slice(this.paginationWrapper.startingRecord, this.paginationWrapper.endingRecord);
        this.records = this.tableData;
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
        paginationWrapper.pageSize = 7;
        paginationWrapper.records;
        paginationWrapper.currentPage = 1;
        paginationWrapper.items = this.tableData;
        paginationWrapper.startingRecord;
        paginationWrapper.endingRecord;
        paginationWrapper.totalRecords;
        paginationWrapper.totalPages = 1;
        paginationWrapper.firstPage = 1;
        paginationWrapper.disableFirstButton;
        paginationWrapper.disableNextButton;
        paginationWrapper.disablePreviousButton;
        paginationWrapper.disableLastButton;
        this.paginationWrapper = paginationWrapper;
    }
    
    @api
    selectedRowData(){
       
      var returnData = new Array();
        var paginationMapToSend = new Map();
        var dataMapToSend= new Map();
        if(this.oldSelectedRows != null){
            paginationMapToSend = this.oldSelectedRows;
        }
        if(this.oldSelectedData != null){
            dataMapToSend = this.oldSelectedData;
        }
        paginationMapToSend.set(this.chargeId, this.paginationMapInt);
        dataMapToSend.set(this.chargeId, this.dataToSendMapInt);
        

    //    var paginationMapToSend = this.paginationMapInt;

        for(let value of this.dataToSendMapInt.values()){
            returnData = returnData.concat(value);
        }
        returnData = returnData.concat(paginationMapToSend);
        returnData = returnData.concat(dataMapToSend);

        //console.log("return Obj===>", paginationMapToSend);
        console.log("return data===>",returnData);
        return returnData;
    }
}