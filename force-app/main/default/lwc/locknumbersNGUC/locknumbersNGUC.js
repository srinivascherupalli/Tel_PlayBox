import {
    LightningElement,
    track,
    api
} from 'lwc';
import fetchNumbersList from '@salesforce/apex/locknumberNGUCController.fetchNumbers';
import fetchNumberFromCSV from '@salesforce/apex/locknumberNGUCController.fetchNumberFromCSV';
import confirmlocknumber from '@salesforce/apex/locknumberNGUCController.lockNumbers';
import MACD_Remove_all_remove_msg from '@salesforce/label/c.MACD_Remove_all_remove_msg';
import MACD_Remove_csv_note_msg from '@salesforce/label/c.MACD_Remove_csv_note_msg';
import MACD_Remove_csv_fromat_msg from '@salesforce/label/c.MACD_Remove_csv_fromat_msg';
import MACD_Remove_csv_validation_msg from '@salesforce/label/c.MACD_Remove_csv_validation_msg';
import MACD_Remove_info_msg from '@salesforce/label/c.MACD_Remove_info_msg';
import MACD_Remove_no_record_msg from '@salesforce/label/c.MACD_Remove_no_record_msg';
import MACD_Remove_onscreen_text_msg from '@salesforce/label/c.MACD_Remove_onscreen_text_msg';
import MACD_Remove_order_success_msg from '@salesforce/label/c.MACD_Remove_order_success_msg';
import MACD_lock_picklist_msg from '@salesforce/label/c.MACD_lock_picklist_msg';
import MACD_Lock_selected_list_msg from '@salesforce/label/c.MACD_Lock_selected_list_msg';
import MACD_lock_ui_header_msg from '@salesforce/label/c.MACD_lock_ui_header_msg';
import MACD_Remove_csv_upload_success_msg from '@salesforce/label/c.MACD_Remove_csv_upload_success_msg';
import MACD_Lock_confirm_msg from '@salesforce/label/c.MACD_Lock_confirm_msg';
import MACD_Remove_no_contigiuos_number_msg from '@salesforce/label/c.MACD_Remove_no_contigiuos_number_msg';

import MACD_Ineligible_Row_Select_Warning from '@salesforce/label/c.MACD_Ineligible_Row_Select_Warning';


export default class LocknumbersNGUC extends LightningElement {
    numberString = '';
    columns = [{
            label: 'Phone Number',
            fieldName: 'phoneNumber',
            sortable: true
        },
        {
            label: 'Status',
            fieldName: 'status'
        },
        {
            label: 'Service Id',
            fieldName: 'cfsId'
        },
        {
            label: 'Eligibilty',
            fieldName: 'eligibilityStatus',
            sortable: true
        },
        {
            label: 'Range',
            fieldName: 'numberRange',
            sortable: true
        }
    ];
    data;
    removedColumns = [{
            label: 'Phone Number',
            fieldName: 'phoneNumber'
        },
        {
            label: 'Status',
            fieldName: 'status'
        },
        {
            label: 'Service Id',
            fieldName: 'cfsId'
        },
        {
            label: 'Eligibilty',
            fieldName: 'eligibilityStatus'
        },
        {
            label: 'Range',
            fieldName: 'numberRange'
        }
    ];
    visible = false;
    noDataAvailable = false;
    removedData = [];


    isUploadCSV = false;
    isOnScreeRetrival = false;
    retrivalMethod = '';
    fileName = '';
    type;
    message;
    UploadFile = 'Upload CSV File';
    hideSelection = false;
    isLastPage = false;
    selection = [];
    hasPageChanged;
    @api subscriptionid;
    initialLoad = true;
    totalRecordCount;
    pageRecordCount;
    isData;
    selectedRanges = [];
    deselectedRanges = [];
    isRemovedAllClicked = false;
    showToast = false;
    showSpinner = false;
    disableRemove = true;
    disableCreate = true;
    disableSubmit = true;
    isLastPage = false;
    @api accountid;
    orderRecordId;
    filesUploaded = [];
    file;
    totalPages;
    fileContents;
    fileReader;
    pageNumber = 1;
    pageSize = 25;
    records;
    pageNumberRemove = 1;
    totalPagesRemove;
    totalRecordCountRemove;
    pageRecordCountRemove;
    sortBy;
    selectionRemoval = [];
    sortDirection = 'asc';
    removeRecords = [];
    oderRecordURL;
    ineligibleStatus = false; // DIGI-4259 change
    isPreHash75FeatureAvailable = false;

    deselectedRowsWithRanges = [];

    label = {
        MACD_Remove_all_remove_msg,
        MACD_Remove_csv_fromat_msg,
        MACD_Remove_csv_note_msg,
        MACD_Remove_csv_upload_success_msg,
        MACD_Remove_csv_validation_msg,
        MACD_Remove_info_msg,
        MACD_Remove_no_record_msg,
        MACD_Remove_onscreen_text_msg,
        MACD_Remove_order_success_msg,
        MACD_lock_picklist_msg,
        MACD_Lock_selected_list_msg,
        MACD_lock_ui_header_msg,
        MACD_Lock_confirm_msg,

        MACD_Remove_no_contigiuos_number_msg,
        MACD_Ineligible_Row_Select_Warning

    };
    disableNext = false;
    get options() {
        return [{
                label: 'Bulk CSV upload',
                value: 'bulkUpload'
            },
            {
                label: 'On-screen retrieval',
                value: 'onScreen'
            },
        ];
    }
    onRetrievalChange(event) {
        this.retrivalMethod = event.detail.value;
        if (this.retrivalMethod == 'bulkUpload') {
            this.isUploadCSV = true;
            this.isOnScreeRetrival = false;
            this.disableNext = true;
        }
        if (this.retrivalMethod == 'onScreen') {
            this.isUploadCSV = false;
            this.disableNext = false;

        }


    }
    handleNext() {
        if (this.retrivalMethod == 'bulkUpload') {
            this.isUploadCSV = true;
            this.isOnScreeRetrival = false;
            this.saveToFile();
        }
        if (this.retrivalMethod == 'onScreen') {
            this.isOnScreeRetrival = true;
            this.hideSelection = true;
            this.isUploadCSV = false;

        }
    }
    storeNumberString(event) {
        this.numberString = event.detail.value;
    }
    handleSearchNumber() {
        this.ineligibleStatus = false; // DIGI-4259 change
        this.showSpinner = true;
        fetchNumbersList({
                searchKey: this.numberString,
                subscriptionIdList: this.subscriptionid
            }).then(result => {
                let numberData = JSON.parse(JSON.stringify(result));
                if (numberData.length > 0) {

                    this.isPreHash75FeatureAvailable = numberData[0].isPreHash75FeatureAvailable;

                    for (var i = numberData.length - 1; i >= 0; i--) {
                        numberData[i].cfsId = numberData[i].cfsId === 'null' ? '' : numberData[i].cfsId;
                        for (var j = 0; j < this.removedData.length; j++) {
                            if (numberData[i] && (numberData[i].numberId === this.removedData[j].numberId)) {
                                numberData.splice(i, 1);
                            }
                        }
                        this.ineligibleStatus = numberData[i].eligibilityStatus === 'Ineligible' ? true : this.ineligibleStatus; // DIGI-4259 change
                    }

                    this.data = numberData;
                    this.hideSelection = true;
                    this.showSpinner = false;
                    if (this.data.length > 0) {
                        this.isData = true;
                    }
                } else {
                    this.showSpinner = false;
                    this.data = [];
                    this.showToastEvent('error', MACD_Remove_no_contigiuos_number_msg);
                }
            })

            .catch(error => {
                this.showSpinner = false;
                this.showToastEvent('error', MACD_Remove_no_contigiuos_number_msg);

            });

    }
    handleFilesChange(event) {
        this.filesUploaded = [];
        this.showToast = false;
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.uploadHelper();
        }

    }
    uploadHelper() {

        this.file = this.filesUploaded[0];
        this.fileReader = new FileReader();
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            var lines = this.fileContents.split('\n');
            if (lines.length > 1501) {
                this.showToast = true;
                this.showSpinner = false;
            }

        });
        this.fileReader.readAsText(this.file);
        this.showToastEvent('success', MACD_Remove_csv_upload_success_msg);
        this.disableNext = false;


    }

    saveToFile() {
        if (this.showToast) {
            this.showToastEvent('error', MACD_Remove_csv_validation_msg);
        } else {
            this.fetchNumberRecords();
        }
    }
    handleNextButton() {
        this.totalPages = Math.ceil(this.records.length / Number(this.pageSize));
        this.pageNumber = this.pageNumber >= this.totalPages ? this.totalPages : this.pageNumber + 1;
        this.processRecords();

    }
    handlePrev() {
        this.totalPages = Math.ceil(this.records.length / Number(this.pageSize));
        this.pageNumber = this.pageNumber > 1 ? this.pageNumber - 1 : 1;


        this.processRecords();

    }
    handleNextButtonRemove() {
        this.totalPagesRemove = Math.ceil(this.removeRecords.length / Number(this.pageSize));
        this.pageNumberRemove = this.pageNumberRemove >= this.totalPagesRemove ? this.totalPagesRemove : this.pageNumberRemove + 1;
        this.processRecordsRemove();

    }
    handlePrevRemove() {
        this.totalPagesRemove = Math.ceil(this.removeRecords.length / Number(this.pageSize));
        this.pageNumberRemove = this.pageNumberRemove > 1 ? this.pageNumberRemove - 1 : 1;
        this.processRecordsRemove();

    }
    handleSortdata(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            return isReverse * ((x > y) - (y > x));
        });

        this.data = parseData;

    }
    processRecords() {
        var uiRecords = [];
        var allRecords = this.records;
        this.totalRecordCount = this.records.length;
        var startLoop = ((this.pageNumber - 1) * Number(this.pageSize));
        var endLoop = (this.pageNumber * Number(this.pageSize) >= this.totalRecordCount) ? this.totalRecordCount : this.pageNumber * Number(this.pageSize);
        if (allRecords.length > 0) {
            for (var i = startLoop; i < endLoop; i++) {
                allRecords[i].numberId = !allRecords[i].numberId.includes('-') ? allRecords[i].numberId + "-" + this.pageNumber : allRecords[i].numberId;



                    if (this.deselectedRanges.includes(allRecords[i].numberRange)) {
                        let index = this.selection.indexOf(allRecords[i].numberId);
                        if (this.selection.indexOf(allRecords[i].numberId) > -1) {
                            this.selection.splice(index, 1);
                        }

                }
                if (this.selectedRanges.includes(allRecords[i].numberRange)) {
                    this.selection.push(allRecords[i].numberId);
                }



                uiRecords.push(JSON.parse(JSON.stringify(allRecords[i])));
            }
            this.data = JSON.parse(JSON.stringify(uiRecords));
            this.pageRecordCount = this.data.length;
        }
        this.selection = [...new Set(this.selection)];

        this.template.querySelector(
            '[data-id="datarow"]'
        ).selectedRows = this.selection;




    }
    processRecordsRemove() {
        var uiRecords = [];
        var allRecords = this.removeRecords;
        this.totalRecordCountRemove = this.removeRecords.length;
        var startLoop = ((this.pageNumberRemove - 1) * Number(this.pageSize));
        var endLoop = (this.pageNumberRemove * Number(this.pageSize) >= this.totalRecordCountRemove) ? this.totalRecordCountRemove : this.pageNumberRemove * Number(this.pageSize);
        if (allRecords.length > 0) {
            for (var i = startLoop; i < endLoop; i++) {
                uiRecords.push(JSON.parse(JSON.stringify(allRecords[i])));
            }
            this.removedData = JSON.parse(JSON.stringify(uiRecords));


            this.pageRecordCountRemove = this.removedData.length;
        }

    }

    handleRowAction(event) {
        if ((!this.hasPageChanged || this.initialLoad)) {
            this.initialLoad = false;

            this.deselectedRanges = [];

            let selectedRows = event.detail.selectedRows;
            let allSelectedRows = this.selection;
            let removeSelected = this.selectionRemoval;
            let currentPageNumber = this.pageNumber;
            let currentPagSelectedRows = [];
            let selectedRowsId = [];

            let difference = [];
            let alldeselectedRowsWithRanges = this.deselectedRowsWithRanges;
            if (this.isPreHash75FeatureAvailable) {
                for (let j = allSelectedRows.length - 1; j >= 0; j--) {
                    let pageNumber = parseInt((allSelectedRows[j].split("-")[1]), 10);
                    if (pageNumber && pageNumber === currentPageNumber)
                        currentPagSelectedRows.push(allSelectedRows[j]);
                }
                if (currentPagSelectedRows.length > selectedRows.length) {
                    for (let j = selectedRows.length - 1; j >= 0; j--) {
                        selectedRowsId.push(selectedRows[j].numberId);
                    }
                    difference = currentPagSelectedRows.filter(x => !selectedRowsId.includes(x));
                    for (let j = this.data.length - 1; j >= 0; j--) {
                        if (difference.includes(this.data[j].numberId) && this.data[j].numberRange != '-' && this.data[j].isPreHash75FeatureAvailable) {
                            let index = this.selectedRanges.indexOf(this.data[j].numberRange);
                            if (index > -1) {
                                this.selectedRanges.splice(index, 1);
                            }

                            this.deselectedRanges.push(this.data[j].numberRange);
                        }
                    }
                }
            }
            

            if (this.isUploadCSV) {
                for (let j = allSelectedRows.length - 1; j >= 0; j--) {
                    let pageNumber = parseInt((allSelectedRows[j].split("-")[1]), 10);
                    if (pageNumber && pageNumber === currentPageNumber)
                        allSelectedRows.splice(j, 1);
                }
                for (let e = alldeselectedRowsWithRanges.length - 1; e >= 0; e--) {
                    let pageNumber = parseInt((alldeselectedRowsWithRanges[e].numberId.split("-")[1]), 10);
                    if (pageNumber && pageNumber === currentPageNumber)
                        alldeselectedRowsWithRanges.splice(e, 1);
                }
            }

            if (!this.isUploadCSV) {
                this.selection = [];
                allSelectedRows = [];
            }
            for (let k = 0; k < selectedRows.length; k++) {
                if (selectedRows[k].eligibilityStatus != 'Ineligible' && !this.deselectedRanges.includes(selectedRows[k].numberRange)) {

                    if (selectedRows[k].numberRange != '-' && selectedRows[k].isPreHash75FeatureAvailable) {
                        for (let i = 0; i < this.data.length; i++) {
                            if ((this.data[i].numberRange == selectedRows[k].numberRange)) {
                                this.selectedRanges.push(selectedRows[k].numberRange);
                                allSelectedRows.push(this.data[i].numberId);
                                alldeselectedRowsWithRanges.push(this.data[i]);


                            }
                        }
                    }
                    allSelectedRows.push(selectedRows[k].numberId);
                    removeSelected.push(selectedRows[k]);
                }

            }
            for (let k = 0; k < alldeselectedRowsWithRanges.length; k++) {
                if (this.deselectedRanges.includes(alldeselectedRowsWithRanges[k].numberRange)) {
                    let index = allSelectedRows.indexOf(alldeselectedRowsWithRanges[k].numberId);
                    if (index > -1) {
                        allSelectedRows.splice(index, 1);
                    }
                }

            }
            //Setting new value in selection attribute
            this.selection.push(...allSelectedRows);
            this.selection = [...new Set(this.selection)];

            this.deselectedRowsWithRanges.push(...alldeselectedRowsWithRanges);
            this.deselectedRowsWithRanges = [...new Set(this.deselectedRowsWithRanges)];

            this.selectionRemoval.push(...removeSelected);
            this.selectionRemoval = [...new Set(this.selectionRemoval)];
            this.selectedRanges = [...new Set(this.selectedRanges)];
            this.disableRemove = this.selection.length > 0 ? false : true;





        } else this.hasPageChanged = false;
    }
    lockNumbers(event) {

        if (this.selection.length <= 0) {
            return;
        }

        this.data = this.data.filter(val => !this.selection.includes(val.numberId));
        if (!this.isUploadCSV) {
            this.noDataAvailable = this.data.length <= 0 ? true : false;
            this.removedData = [...new Set(this.selectionRemoval)];
            this.disableCreate = false;
        } else {
            for (let i = this.records.length - 1; i >= 0; i--) {
                for (let j = 0; j < this.selection.length; j++) {

                    if ((((this.selection[j].includes('-') && this.selection[j].split('-')[0] == this.records[i].numberId) ||
                            this.selection[j] == this.records[i].numberId) && this.records[i].numberRange == '-') || this.selectedRanges.includes(this.records[i].numberRange)) {
                        this.removeRecords.push(this.records[i]);

                        this.records.splice(i, 1);
                        break;

                    }
                }
                //
            }

            this.selectedRanges = [];
            this.deselectedRanges = [];
            this.selection = [];
            this.deselectedRowsWithRanges = [];
            this.disableRemove = this.selection.length > 0 ? false : true;

            this.removeRecords = [...new Set(this.removeRecords)];
            this.disableCreate = false;
            this.pageNumber = 1;
            this.pageNumberRemove = 1;

            if(this.records.length > 0){
                this.processRecords();
            }
            else{
                this.noDataAvailable = true ;
            }
           

            this.processRecordsRemove();

        }



        this.showToastEvent('success', MACD_Remove_selected_remove_msg);




    }
    lockAllNumbers() {

        if (this.records.length <= 0) {
            return;
        }
        this.selectedRanges = [];
        this.deselectedRanges = [];
        this.selection = [];
        this.deselectedRowsWithRanges = [];
        this.disableRemove = this.selection.length > 0 ? false : true;

        this.pageNumber = 1;
        this.pageNumberRemove = 1;
        this.isRemovedAllClicked = true;
        for (let i = this.records.length - 1; i >= 0; i--) {
            if (this.records[i].eligibilityStatus != 'Ineligible') {
                this.removeRecords.push(this.records[i]);
                this.records.splice(i, 1);

            }
        }
        this.removeRecords = [...new Set(this.removeRecords)];
        this.noDataAvailable = this.records.length <= 0 ? true : false;
        this.processRecords();
        this.processRecordsRemove();

        this.disableCreate = this.removeRecords.length > 0 ? false : true;



    }

    fetchNumberRecords() {
        this.showSpinner = true;
        fetchNumberFromCSV({
                subscriptionIdList: this.subscriptionid,
                csvJson: JSON.stringify(this.fileContents)
            })
            .then(result => {


                let numberData = result != '' ? JSON.parse(JSON.stringify(result)) : [];
                if (numberData.length > 0) {


                    this.records = JSON.parse(JSON.stringify(result));
                    var uiRecords = [];
                    this.isPreHash75FeatureAvailable = this.records[0].isPreHash75FeatureAvailable;
                    for (var i = 0; i < Number(this.pageSize); i++) {
                        if (numberData.length >= i + 1) {
                            numberData[i].numberId = numberData[i].numberId + "-" + this.pageNumber;
                            numberData[i].cfsId = numberData[i].cfsId === 'null' ? '' : numberData[i].cfsId;
                            uiRecords.push(JSON.parse(JSON.stringify(numberData[i])));
                        }
                    }
                    // DIGI-4259 change starts here
                    let inEligibleRecords = this.records.filter(function(rec) {
                        return rec.eligibilityStatus == 'Ineligible'; });
                    if(inEligibleRecords != undefined && inEligibleRecords.length > 0){
                        this.ineligibleStatus = true;
                    }
                    // DIGI-4259 change ends here
                    this.data = JSON.parse(JSON.stringify(uiRecords));
                    this.totalPages = Math.ceil(result.length / Number(this.pageSize));
                    this.showSpinner = false;
                    this.totalRecordCount = numberData.length;
                    this.pageRecordCount = this.data.length;
                    if (this.data.length > 0) {
                        this.isData = true;
                        this.hideSelection = true;
                    }


                } else {
                    this.showSpinner = false;
                    this.showToastEvent('error', MACD_Remove_no_contigiuos_number_msg);

                }

            })
            .catch(error => {
                this.showSpinner = false;
                this.showToastEvent('error', MACD_Remove_no_contigiuos_number_msg);

            });
    }
    confirmlocknumber() {

        if (this.disableSubmit === true) {
            this.showSpinner = true;

            let selectedNumberString = this.isUploadCSV ? JSON.stringify(this.removeRecords) : JSON.stringify(this.removedData);

            confirmlocknumber({
                    selectedNumberString: selectedNumberString,
                    accountId: this.accountid,
                    subscriptionIdList: this.subscriptionid,
                    csvJson: JSON.stringify(this.fileContents)
                })
                .then(result => {
                    this.oderRecordURL = result;
                    this.orderRecordId = result != null && result.split('/').length > 0 ? result.split('/')[result.split('/').length - 1] : '';
                    this.showSpinner = false;
                    this.disableSubmit = false;
                    this.showToastEvent('success', MACD_Lock_confirm_msg);
                    window.location.href = '/'+this.accountid;

                })

                .catch(error => {
                    this.showToastEvent('error', error.message);

                });
        }

    }
    showToastEvent(type, message) {
        this.type = type;
        this.message = message;
        this.visible = true;
        let delay = 2000
        setTimeout(() => {
            this.visible = false;
        }, delay);
    }
    closeModel() {
        this.visible = false;
        this.type = '';
        this.message = '';
    }
    get getIconName() {
        return 'utility:' + this.type;
    }
    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }

    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }
}