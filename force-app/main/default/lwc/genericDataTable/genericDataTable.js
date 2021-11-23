import {  LightningElement, track, api } from 'lwc';

export default class GenericDataTable extends LightningElement {
    @api pageSize;
    @api records;
    @api columns;
    @api hideRowCheckbox;
    @api paginationByButton;
    @track currentPage = 1;
    @track items;
    @track startingRecord;
    @track endingRecord;
    @track totalRecords;
    @track totalPages;
    @track firstPage = 1;
    @track disableFirstButton;
    @track disableNextButton;
    @track disablePreviousButton;
    @track disableLastButton;
    @track hasRendered = true;
    @api isPartnerUser = false;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    @api 
    get recordsData(){
        return this.recordsData;
    }
    set recordsData(val){
       this.records = val;
       this.pagination();
    }
    connectedCallback() {       
        this.pagination();
        // console.log('generix table -records - '+ JSON.stringify(this.records));
        // console.log('generix table - columns-'+ JSON.stringify(this.columns));
        // console.log('generix table - hideRowCheckbox-'+this.hideRowCheckbox);
        

    }
    renderedCallback() {
        // console.log('generix table - columns-'+ JSON.stringify(this.columns));    
        if (this.hasRendered && !this.isPartnerUser) {
            this.template.querySelector('.table').classList.remove('table');
            this.hasRendered = false;
            
        }
    }
    /*----------------------------------------------------------------------
    EDGE        -150172
    Method      -pagination
    Description -Datatable pagination as per pageSize
    Author      -Dheeraj Bhatt
    -----------------------------------------------------------------------*/
    pagination() {
        if (this.records != null) {
            this.items = this.records;
            this.totalRecords = this.records.length;
            this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
            this.records = this.items.slice(0, this.pageSize);
            var offset = (this.currentPage - 1) * this.pageSize;
            this.startingRecord = offset + 1;
            var currentRecordEnd = this.pageSize * this.currentPage;
            this.endingRecord = this.totalRecords >= currentRecordEnd ? currentRecordEnd : this.totalRecords;
            this.showOrHideButton();
        }
    }
    /*----------------------------------------------------------------------
    EDGE        -150172
    Method      -previous
    Description -show previous page record on click of previous Button
    Author      -Dheeraj Bhatt
    -----------------------------------------------------------------------*/
    previous() {
        if (this.currentPage > 1) {
            this.currentPage = this.currentPage - 1;
            this.displayRecordPerPage(this.currentPage);
        }
    }
    /*----------------------------------------------------------------------
    EDGE        -150172
    Method      -first
    Description -show first page record on click of first Button
    Author      -Dheeraj Bhatt
    -----------------------------------------------------------------------*/
    first() {
        this.displayRecordPerPage(this.firstPage);
        this.currentPage = this.firstPage;
        this.showOrHideButton();
    }
    /*----------------------------------------------------------------------
    EDGE        -150172
    Method      -next
    Description -show next page record on click of next Button
    Author      -Dheeraj Bhatt
    -----------------------------------------------------------------------*/
    next() {
        if ((this.currentPage < this.totalPages) && this.currentPage !== this.totalPages) {
            this.currentPage = this.currentPage + 1;
            this.displayRecordPerPage(this.currentPage);
        }
    }
    /*----------------------------------------------------------------------
    EDGE        -150172
    Method      -last
    Description -show last page record on click of last Button
    Author      -Dheeraj Bhatt
    -----------------------------------------------------------------------*/
    last() {
        this.displayRecordPerPage(this.totalPages);
        this.currentPage = this.totalPages;
        this.showOrHideButton();
    }
    /*----------------------------------------------------------------------
    EDGE        -150172
    Method      -displayRecordPerPage
    Description -Show records as per currentPage
    Author      -Dheeraj Bhatt
    -----------------------------------------------------------------------*/

    displayRecordPerPage(currentPage) {
        this.startingRecord = ((currentPage - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * currentPage);

        this.endingRecord = (this.endingRecord > this.totalRecords)
            ? this.totalRecords : this.endingRecord;

        this.records = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
        this.showOrHideButton();
    }
    /*----------------------------------------------------------------------
    EDGE        -150172
    Method      -showOrHideButton
    Description -disable Button as per records present in datatble and current page
    Author      -Dheeraj Bhatt
    -----------------------------------------------------------------------*/
    showOrHideButton() {
        this.disableFirstButton = true;
        this.disableNextButton = true;
        this.disablePreviousButton = true;
        this.disableLastButton = true;
        if (this.currentPage != this.firstPage) {
            this.disableFirstButton = false;
            this.disablePreviousButton = false;
        }
        if (this.currentPage != this.totalPages) {
            this.disableLastButton = false;
            this.disableNextButton = false;
        }
    }
    
    @api
    selectedRowData(){
        let el = this.template.querySelector('lightning-datatable');
        console.log(el);
        let selectedRecords = el.getSelectedRows();
        return selectedRecords;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };
    
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.records];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.records = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}