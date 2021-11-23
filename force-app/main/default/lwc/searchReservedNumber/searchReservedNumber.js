//DIGI-23871 Rashmi reserve limit increase to 1000 for Contiguous
import { LightningElement, track, api } from 'lwc';
import searchInitialdata from '@salesforce/apex/NumberReservationController.SearchInitialdata';
import searchNumbers from '@salesforce/apex/NumberReservationController.searchNumbers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import errorMsg from '@salesforce/label/c.Reserve_number_quantity_validation';
import Reserve_number_quantity_required from '@salesforce/label/c.Reserve_number_quantity_required';
import ContiguousQuantityValidation from '@salesforce/label/c.ContiguousQuantityValidation';
import MaxQuantityRequired from '@salesforce/label/c.MaxQuantityRequired';
import MACD_Add_pattern_help_msg from '@salesforce/label/c.MACD_Add_pattern_help_msg';
import AddressStatusConfirmed from '@salesforce/label/c.AddressStatusConfirmed';
import checkForPartnerUser from '@salesforce/apex/NumberReservationController.checkForPartnerUser';

export default class SearchReservedNumber extends LightningElement {

    searchKey = '';

    @api
    selectedTab;

    @track
    numberReserve = {};

    @track
    searchNumberResult;

    @track
    responseMessage;

    @track
    loadingSpinner = false;
    visible = false;
    type;
    message;
    label = {
        MACD_Add_pattern_help_msg
    };

    filterString = 'Address_ID__c!=null AND Address_Status__c=\'' + AddressStatusConfirmed;
    searchFields = 'Street_calc__c, cscrm__Zip_Postal_Code__c, cscrm__City__c, Address_ID__c,ESA_Code__c';

    connectedCallback() {
        this.loadingSpinner = true;
        searchInitialdata({ tabType: this.selectedTab })
            .then((result) => {
                this.numberReserve = result;
                if (this.selectedTab == 'Fixed') {
                    this.numberReserve.searchTypeList = [];
                    this.numberReserve.searchTypeList.push({ 'label': 'Non-Contiguous', 'value': 'Non-Contiguous' });
                    this.numberReserve.searchTypeList.push({ 'label': 'Contiguous', 'value': 'Contiguous' });
                }
                this.numberReserve.reqPattern = "";
                //console.log(this.numberReserve);
            })
            .catch((error) => {
                //console.log(error);
                this.numberReserve = {};
            });
        this.loadingSpinner = false;
    }

    get isMobileTabSelected() {
        return this.selectedTab == 'Mobile';
    }

    get isFixedTabSelected() {
        return this.selectedTab == 'Fixed';
    }

    handleSearchTypeChange(event) {
        this.numberReserve.selectedSearchType = event.detail.value;
    }

    handlePatternTypeChange(event) {
        this.numberReserve.selectedPatternType = event.detail.value;
    }

    handleAreaCodeChange(event) {
        let areaCode = event.detail.value;
        console.log('areaCode-->' + areaCode);
        if (!areaCode || areaCode == 'None') {
            this.numberReserve.selectedAreaCode = '';
        } else {
            this.numberReserve.selectedAreaCode = event.detail.value;
        }
        console.log('this.numberReserve.selectedAreaCode-->' + this.numberReserve.selectedAreaCode);
    }

    handleQuantityChange(event) {
        this.numberReserve.quantity = event.detail.value;
    }

    handlePatternChange(event) {
        this.numberReserve.reqPattern = event.detail.value;
    }

    handleAddAddress(event) {
        checkForPartnerUser({})
            .then((result) => {
                console.log(result);
                const isPartner = result;
                console.log('isPartner==' + isPartner);
                if (isPartner) {
                    window.open("/partners/s/communityaddresssearch");
                }
                else {
                    window.open("/lightning/n/Address_Search_New");
                }
            })
            .catch((error) => {
                console.log(error);
            });
    }

    handleAddressselection(event) {
        const textVal = event.detail;
        console.log('selectedValue-->' + textVal.selectedValue);
        console.log('selectedRecordId-->' + textVal.selectedRecordId);
        console.log(JSON.stringify(textVal.selectedRecord));
        if (textVal.selectedRecordId != undefined && textVal.selectedRecordId != '') {
            this.numberReserve.deliveryAddress = {
                Id: textVal.selectedRecordId,
                Name: textVal.selectedValue,
                Address_ID__c: textVal.selectedRecord.Address_ID__c,
                ESA_Code__c: textVal.selectedRecord.ESA_Code__c
            };
        } else {
            this.numberReserve.deliveryAddress = {};
        }
    }

    handleChangeSameExchange(event) {
        this.numberReserve.sameExchange = event.target.checked;
    }

    handleClearButtonClick(event) {
        this.numberReserve.selectedSearchType = "";
        this.numberReserve.selectedPatternType = "";
        this.numberReserve.selectedAreaCode = "";
        this.numberReserve.quantity = "";
        this.numberReserve.reqPattern = "";
        this.numberReserve.sameExchange = false;
        this.numberReserve.deliveryAddress = {};
    }

    handleSearchNumbers(event) {
        this.loadingSpinner = true;
        let msg = errorMsg;
        if (this.numberReserve.quantity == null || this.numberReserve.quantity == "") {
            this.loadingSpinner = false;
            this.showToastEvent('error', Reserve_number_quantity_required);
            return;
        }
        if (this.numberReserve.selectedSearchType == 'Non-Contiguous' && this.numberReserve.quantity > 20) {
            this.loadingSpinner = false;
            this.showToastEvent('error', msg.replace("<limit>", "20"));
            return;
        }
        if (this.numberReserve.selectedSearchType == 'Contiguous' && this.numberReserve.quantity > 400) {
            this.loadingSpinner = false;
            this.showToastEvent('error', msg.replace("<limit>", "1000"));
            return;
        }
        if (this.numberReserve.selectedSearchType == 'Contiguous' && (this.numberReserve.quantity % 100) != 0) {
            this.loadingSpinner = false;
            this.showToastEvent('error', ContiguousQuantityValidation);
            return;
        }
        if (this.numberReserve.reqPattern == undefined || this.numberReserve.reqPattern == "") {
            this.numberReserve.reqPattern = null;
        }
        if (this.numberReserve.selectedPatternType != '' && this.numberReserve.selectedPatternType != "None" && this.numberReserve.reqPattern == null) {
            this.loadingSpinner = false;
            this.showToastEvent('error', MACD_Add_pattern_help_msg, "error");
            return;
        }


        console.log(this.numberReserve);
        searchNumbers({
            searchString: JSON.stringify(this.numberReserve),
            tabType: this.selectedTab
        })
            .then((result) => {
                //console.log(result);
                if (result.lstsearchresult.length > 0) {
                    this.loadingSpinner = false;
                    this.searchNumberResult = result.lstsearchresult;
                    this.responseMessage = result.responsemessage;
                    if (this.searchNumberResult != null && this.searchNumberResult.length > 0) {
                        this.sendSearchNumberResult();
                    }

                } else {
                    this.loadingSpinner = false;
                    this.showToastEvent('Error', result.responsemessage);
                    return;
                }
            })
            .catch((error) => {
                //console.log(error);
                this.searchNumberResult = null;
                this.loadingSpinner = false;
            });


    }

    sendSearchNumberResult() {
        const custEvent = new CustomEvent(
            'callsearchnumberresult', {
            detail: {
                searchNumberType: this.numberReserve.selectedSearchType,
                searchresult: JSON.parse(JSON.stringify(this.searchNumberResult)),
                responsemessage: this.responseMessage,
            }
        });

        this.dispatchEvent(custEvent);
    }



    showToastEvent(type, message) {
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