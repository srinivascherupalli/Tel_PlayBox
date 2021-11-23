import {
  LightningElement,
  wire,
  track,
  api
} from "lwc";

import {
  ShowToastEvent
} from "lightning/platformShowToastEvent";
import getAllSubs from "@salesforce/apex/subscriptionTableCompController.getSubscriptionData";

const columns = [{
    label: "Subscription Name",
    fieldName: "subNameLink",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "subscriptionName"
      },
      target: "_blank"
    },
    sortable: true
  },
  {
    label: "Subscription Number",
    fieldName: "subscriptionNumber",
    type: "text"
  },
  {
    label: "Service ID",
    fieldName: "ServiceId",
    type: "text"
  },
  {
    label: "Site Address",
    fieldName: "siteAddress",
    type: "text"
  },
  {
    label: "First Activation Date",
    fieldName: "firstActivationDate",
    type: "text"
  },
  {
    label: "Created Date",
    fieldName: "createdDateVal",
    type: "date"
  },
  {
    label: "Status",
    fieldName: "status",
    type: "text"
  },

  {
    label: "Total Recurring Charges",
    fieldName: "totalRCVal",
    type: "currency"
  },
  {
    label: "Billing_Account__c",
    fieldName: "billingAccount",
    type: "text"
  }
];

export default class SubscriptionTableComp extends LightningElement {
  @track page = 1;
  @track items = [];
  @track startingRecord = 1;
  @track endingRecord = 0;
  @track pageSize = 5;
  @track totalRecountCount = 0;
  @track totalPage = 0;
  @api subids = [];
  @api checkbox;
  @api selectedRows = ['a4g4Y0000001Xzi'];
  @api checkbox1;
  columns = columns;
  pagelinks = [];
  isLoading = false;

  get options() {
    return [{
        label: "5",
        value: "5"
      },
      {
        label: "10",
        value: "10"
      },
      {
        label: "50",
        value: "50"
      },
      {
        label: "100",
        value: "100"
      },
      {
        label: "200",
        value: "200"
      },
      {
        label: "500",
        value: "500"
      }
    ];
  }

  connectedCallback() {
    this.isLoading = true;
    this.pagelinks.length = 0;
  }
  @wire(getAllSubs, {
    subIds: "$subids"
  })
  subList({
    error,
    data
  }) {
    if (data) {
      this.page = 1;
      this.startingRecord = 1;
      this.items = data;
      this.totalRecountCount = data.length;
      if (this.totalRecountCount == 0) {
        this.page = 0;
        this.startingRecord = 0;
      }

      this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
      this.data = this.items.slice(0, this.pageSize);
      this.endingRecord = this.pageSize;
      this.endingRecord =
        this.endingRecord > this.totalRecountCount ?
        this.totalRecountCount :
        this.endingRecord;
      this.columns = columns;
      this.error = undefined;
      this.pagelinks.length = 0;
      for (let i = 1; i <= this.totalPage; i++) {
        this.pagelinks.push(i);
      }
    } else if (error) {
      this.error = error;
      this.data = undefined;

      const event = new ShowToastEvent({
        title: "Error!",
        message: "Please try again and in case the issue persist please contact your admin",
        variant: "error"
      });
      this.dispatchEvent(event);
    }
    this.isLoading = false;
  }

  previousHandler() {
    if (this.page > 1) {
      this.page = this.page - 1;
      this.displayRecordPerPage(this.page);
      this.handlePageChange();
    }
  }

  nextHandler() {
    console.log("in next");
    if (this.page < this.totalPage && this.page !== this.totalPage) {
      this.page = this.page + 1;
      this.displayRecordPerPage(this.page);
      this.handlePageChange();
    }
  }

  firstHandler() {
    this.page = 1;
    this.displayRecordPerPage(this.page);
    this.handlePageChange();
  }

  lastHandler() {
    this.page = this.totalPage;
    this.displayRecordPerPage(this.page);
    this.handlePageChange();
  }

  handlePage(button) {
    this.page = button.target.label;
    this.displayRecordPerPage(this.page);
    this.handlePageChange();
  }

  handleComboBoxChange(event) {
    this.page = 1;
    this.pageSize = event.target.value;
    this.displayRecordPerPage(this.page);
  }

  handlePageChange() {
    console.log("handle page change-----");
    const message = "PageChange";
    const pageChangeEvent = new CustomEvent("pageChangeEvt", {
      detail: {
        message
      }
    });
    this.dispatchEvent(pageChangeEvent);
  }

  getSelectedName(event) {
    const selectedRows = event.detail.selectedRows;
    const rowSelectionEvent = new CustomEvent("rowselectionevt", {
      detail: {
        selectedRows
      }
    });
    this.dispatchEvent(rowSelectionEvent);
  }

  displayRecordPerPage(page) {
    this.startingRecord = (page - 1) * this.pageSize;
    this.endingRecord = this.pageSize * page;
    this.endingRecord =
      this.endingRecord > this.totalRecountCount ?
      this.totalRecountCount :
      this.endingRecord;
    this.data = this.items.slice(this.startingRecord, this.endingRecord);
    this.startingRecord = this.startingRecord + 1;
    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
    this.pagelinks.length = 0;
    for (let i = 1; i <= this.totalPage; i++) {
      this.pagelinks.push(i);
    }
    this.isLoading = false;
  }
}