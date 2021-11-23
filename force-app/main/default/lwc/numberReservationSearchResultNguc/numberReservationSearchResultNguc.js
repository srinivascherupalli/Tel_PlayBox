import { LightningElement, api, track } from 'lwc';
import doNumbersExist from '@salesforce/apex/AddNewNumbersMACDController.doNumbersExist';
import numberStatusSync from '@salesforce/apex/AddNewNumbersMACDController.numberStatusSync';
import MACD_Add_select_number_val_msg from '@salesforce/label/c.MACD_Add_select_number_val_msg';
import MACD_Remove_select_number_val_msg from '@salesforce/label/c.MACD_Remove_select_number_val_msg';
import MACD_Add_select_reserved_number_val_msg from '@salesforce/label/c.MACD_Add_select_reserved_number_val_msg';
import MACD_Remove_select_reserved_number_val_msg from '@salesforce/label/c.MACD_Remove_select_reserved_number_val_msg';
import MACD_Add_select_reserved_number_error_msg from '@salesforce/label/c.MACD_Add_select_reserved_number_error_msg';
import MACD_Remove_select_reserved_number_error_msg from '@salesforce/label/c.MACD_Remove_select_reserved_number_error_msg';

const columns = [
    {
        label: 'Available Number(s)',
        fieldName: 'numberList',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
];

const reserveColumns = [

    {
        label: 'Available Number(s)',
        fieldName: 'PhoneNumber',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Status',
        fieldName: 'Status',
        sortable: true,
    }
];

export default class NumberReservationSearchResultNguc extends LightningElement {
    columns = columns;
    reserveColumns = reserveColumns;
    hideRowCheckbox = false;

    @api
    subscriptionId;
    @track
    loadingSpinner = false;

    @track
    reservedNumbers = [];

    @api
    searchNumberResult = [];

    @api
    totalSearchedNumbers;

    @api
    subscriptionRecords;
    @api
    searchType;
    visible = false;
    type;
    message;

    get isNumberAvailable() {
        return (this.searchNumberResult != null && this.searchNumberResult.length > 0);
    }

    get isNumberReserved() {
        return this.numberReserved();
    }
    renderedCallback() {
        console.log('searchNumberResult  =====>', this.searchNumberResult);
        console.log('subscriptionRecords  =====>', this.subscriptionRecords);
    }
    numberReserved() {
        //console.log(this.reservedNumbers.length);
        return (this.reservedNumbers != null && this.reservedNumbers.length > 0);
    }
    @api
    getAssignedNumbersList() {
        let servicesNumbers = [];
        for (let index = 0; index < this.reservedNumbers.length; index++) {
            if (this.reservedNumbers[index].Status == 'Assigned') {
                let element = this.reservedNumbers[index].PhoneNumber;
                servicesNumbers.push(element);
            }
        }
        return servicesNumbers;
    }

    @api
    reservedNumbersList() {
        let servicesNumbers = [];
        for (let index = 0; index < this.reservedNumbers.length; index++) {
            if (this.reservedNumbers[index].PhoneNumber) {
                let element = this.reservedNumbers[index].PhoneNumber;
                servicesNumbers.push(element);
            }
        }
        doNumbersExist({
            listSelSearchNum: servicesNumbers,
            subscriptions: JSON.stringify(this.subscriptionRecords)
        })
            .then((result) => {
                this.loadingSpinner = false;
                this.reservedNumbers = result;
                return this.reservedNumbers;
            })
            .catch(error => {
                this.loadingSpinner = false;
            });
    }

    @api
    getSelectedReservedNumbers() {
        let reserveEle = this.template.querySelector('[data-id="reservedNumbers"]');
        let reservedNumbers = reserveEle.selectedRowData();
        return reservedNumbers;
    }

    handleReserveNumber(event) {
        this.loadingSpinner = true;
        let subscriptionList= [];
        let selectedSearchRows;
        if(event.target.label == 'Reserve Selected'){
            selectedSearchRows = this.template.querySelector('[data-id="searchNumbers"]').selectedRowData();
        }else{
            selectedSearchRows = this.searchNumberResult;
        }
        
        if (selectedSearchRows.length > 0) {
            // array[] of String(numb) Type to be sent to apex 
            let reservedNumbersSelected = [];
            for (let index = 0; index < selectedSearchRows.length; index++) {
                let element = selectedSearchRows[index].numberList;
                reservedNumbersSelected.push(element);
            }
            // ## call to if number exist or not  - 
            doNumbersExist({
                listSelSearchNum: reservedNumbersSelected,
                subscriptions: JSON.stringify(subscriptionList)
            })
                .then((result) => {
                    this.loadingSpinner = false;
                    let exsistingReservedNumbers = [];
                    for (let index = 0; index < this.reservedNumbers.length; index++) {
                        exsistingReservedNumbers.push(this.reservedNumbers[index]);
                    }
                    // populating reservtn pool
                    for (let i = 0; i < result.length; i++) {
                        exsistingReservedNumbers.push(result[i]);
                    }
                    console.log('after exsistingReservedNumbers', JSON.stringify(exsistingReservedNumbers));
                    //remove reservation no from search table
                    // @@ removing reserved numbers from search table 
                    let exsistingSearchNumbers = [];
                    let filteredSearchNumbers = [];
                    for (let index = 0; index < this.searchNumberResult.length; index++) {
                        exsistingSearchNumbers.push(this.searchNumberResult[index]);
                    }
                    for (let index = 0; index < exsistingSearchNumbers.length; index++) {
                        let flag = false;
                        for (let i = 0; i < reservedNumbersSelected.length; i++) {
                            if (exsistingSearchNumbers[index].numberList == reservedNumbersSelected[i]) {
                                flag = true;
                            }
                        }
                        if (flag == false) {
                            filteredSearchNumbers.push(exsistingSearchNumbers[index]);
                        }
                    }
                    const custEvent = new CustomEvent(
                        'fillsearchnumbers', {
                        detail: JSON.stringify(filteredSearchNumbers)
                    });
                    this.dispatchEvent(custEvent);
                    this.reservedNumbers = exsistingReservedNumbers;
                    console.log('reservedNumbersSelected-->' + reservedNumbersSelected);
                    this.calloutToUNMS('Reserve', reservedNumbersSelected);

                    if (this.reservedNumbers.length > 0) {
                        this.sendNumberReservedFlag();
                    }
                })
                .catch(error => {
                    console.log('exception', error);
                    this.loadingSpinner = false;
                    this.showToastEvent('error', MACD_Add_select_number_val_msg);
                });
        } else {
            this.loadingSpinner = false;
            this.showToastEvent('error', MACD_Add_select_number_val_msg);
        }

    }

    handleRemoveResPoolNumb(event) {
        this.loadingSpinner = true;
        let selectedResRows;
        if(event.target.label == 'Remove Selected'){
            selectedResRows = this.template.querySelector('[data-id="reservedNumbers"]').selectedRowData();
        }else{
            selectedResRows = this.reservedNumbers;
        }
        if (selectedResRows.length > 0) {
            let removeNumbersSelected = [];
            for (let index = 0; index < selectedResRows.length; index++) {
                removeNumbersSelected.push(selectedResRows[index].PhoneNumber);
            }
            let newResPool = [];
            let exsistingSearchNumbers = [];
            for (let index = 0; index < this.searchNumberResult.length; index++) {
                exsistingSearchNumbers.push(this.searchNumberResult[index]);
            }
            for (let index = 0; index < this.reservedNumbers.length; index++) {
                let flag = false;
                for (let i = 0; i < selectedResRows.length; i++) {
                    if (this.reservedNumbers[index].PhoneNumber == selectedResRows[i].PhoneNumber) {
                        flag = true;
                        let restoreSearchRow = {
                            "isSelectedNew": false,
                            "numberList": selectedResRows[i].PhoneNumber
                        };
                        exsistingSearchNumbers.push(restoreSearchRow);
                    }
                }
                if (flag == false) {
                    newResPool.push(this.reservedNumbers[index]);

                }
            }
            console.log('removeNumbersSelected-->' + removeNumbersSelected);
            this.calloutToUNMS('Remove', removeNumbersSelected);
            this.reservedNumbers = [];
            this.reservedNumbers = newResPool;
            this.searchNumberResult = exsistingSearchNumbers;
        } else {
            this.showToastEvent('error', MACD_Remove_select_number_val_msg);
            this.loadingSpinner = false;
        }
    }

    sendNumberReservedFlag() {
        const custEvent = new CustomEvent(
            'callnumberreserved', {
            detail: {
                isnumberreserved: this.numberReserved(),
            }
        });

        this.dispatchEvent(custEvent);
    }
    showToastEvent(type, message) {
        console.log('tostcall', message);
        this.type = type;
        this.message = message;
        this.visible = true;
        let delay = 5000
        setTimeout(() => {
            this.visible = false;
        }, delay);
    }
    closeModel() {
        this.visible = false;
        this.type = '';
        this.message = '';
    }

    calloutToUNMS(actionType, servicesNumbers) {
        this.loadingSpinner = true;
        console.log('servicesNumbers-->' + servicesNumbers);
        if (servicesNumbers.length > 0) {

            numberStatusSync({
                numberList: servicesNumbers,
                requestType: actionType
            })
                .then((result) => {
                    let status = result;
                    console.log('status --> ' + status);
                    if (status == "Success") {
                        this.loadingSpinner = false;
                        if(actionType == 'Reserve'){
                            this.showToastEvent('success', MACD_Add_select_reserved_number_val_msg);
                        }else{
                            this.showToastEvent('success', MACD_Remove_select_reserved_number_val_msg);
                        }
                        
                    } else {
                        this.loadingSpinner = false;
                        if (status == null || status == "" || status == undefined) {
                            if(actionType == 'Reserve'){
                                status = MACD_Add_select_reserved_number_error_msg;
                            }else{
                                status = MACD_Remove_select_reserved_number_error_msg;
                            }
                        }
                        this.showToastEvent('error', status);
                    }
                })
                .catch(error => {
                    this.loadingSpinner = false;
                    console.log(error);
                    this.showToastEvent('error', MACD_Add_select_number_val_msg);
                });
        } else {
            this.loadingSpinner = false;
            this.showToastEvent('error', MACD_Add_select_number_val_msg);
        }
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