import { LightningElement, api, track } from 'lwc';

export default class TransitionServiceFilter extends LightningElement {
    @track showService = true;
    @track MapKey;
    @track value;
    @track tableData;
    @api tableName;
    @api mroData;
    @api aroData;
    @api
    get mapKey() { return this.MapKey; }
    set mapKey(value) {
        this.MapKey = value;
        this.setData();
    }
    @api
    get paymentType() { return this.value; }
    set paymentType(value) {
        this.value = value;
        this.setData();
    }
    setData() {
        if (this.value == 'ARO') {
            if (Array.isArray(this.aroData) && this.aroData.length) {
                this.showService = true;
                if (this.template.querySelector('c-inline-edit-data-table')) {
                    this.template.querySelector('c-inline-edit-data-table').setData(this.aroData);
                }
                else {
                    this.tableData = this.aroData;
                }
            }
            else {
                this.showService = false;
                if (this.template.querySelector('c-inline-edit-data-table')) {
                    this.template.querySelector('c-inline-edit-data-table').setData([]);
                }
                else {
                    this.tableData = [];
                }
            }

        }
        else if (this.value == 'MRO') {
            if (Array.isArray(this.mroData) && this.mroData.length) {
                this.showService = true;
                if (this.template.querySelector('c-inline-edit-data-table')) {
                    this.template.querySelector('c-inline-edit-data-table').setData(this.mroData);
                }
                else {
                    this.tableData = this.mroData;
                }
            }
            else {
                this.showService = false;
                if (this.template.querySelector('c-inline-edit-data-table')) {
                    this.template.querySelector('c-inline-edit-data-table').setData([]);
                }
                else {
                    this.tableData = [];
                }
            }
        }
        else {
            if (Array.isArray(this.mroData) && this.mroData.length && Array.isArray(this.aroData) && this.aroData.length) {
                if (this.template.querySelector('c-inline-edit-data-table')) {
                    this.template.querySelector('c-inline-edit-data-table').setData(this.aroData.concat(this.mroData));
                }
                else {
                    this.tableData = this.aroData.concat(this.mroData);
                }
            }
            else if (Array.isArray(this.mroData) && this.mroData.length) {
                if (this.template.querySelector('c-inline-edit-data-table')) {
                    this.template.querySelector('c-inline-edit-data-table').setData(this.mroData);
                }
                else {
                    this.tableData = this.mroData;
                }
            }
            else if (Array.isArray(this.aroData) && this.aroData.length) {
                if (this.template.querySelector('c-inline-edit-data-table')) {
                    this.template.querySelector('c-inline-edit-data-table').setData(this.aroData);
                }
                else {
                    this.tableData = this.aroData;
                }
            }
            this.showService = true;
        }
    }

}