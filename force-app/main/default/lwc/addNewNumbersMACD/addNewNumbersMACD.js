import { LightningElement, api, track } from "lwc";
import createOrder from "@salesforce/apex/AddNewNumbersMACDController.createOrder";
import assignNumbers from "@salesforce/apex/AddNewNumbersMACDController.assignReservedNumbers";
import removeAssignNumbers from "@salesforce/apex/AddNewNumbersMACDController.removeReservedNumbers";
import fatchSubscriptions from "@salesforce/apex/AddNewNumbersMACDController.fatchSubscriptions";
import splitNumbers from "@salesforce/apex/AddNewNumbersMACDController.getContiguousSplitNumbers";
import MACD_Add_order_success_msg from "@salesforce/label/c.MACD_Add_order_success_msg";
import MACD_Add_order_submit_err_msg from "@salesforce/label/c.MACD_Add_order_submit_err_msg";
import MACD_Add_assign_error_msg from "@salesforce/label/c.MACD_Add_assign_error_msg";
import MACD_Add_unassign_msg from "@salesforce/label/c.MACD_Add_unassign_msg";
import MACD_Add_assign_info_msg from "@salesforce/label/c.MACD_Add_assign_info_msg";
import MACD_Add_order_error_msg from "@salesforce/label/c.MACD_Add_order_error_msg";
import { NavigationMixin } from "lightning/navigation";
import submitOrder from "@salesforce/apex/AddNewNumbersMACDController.submitOrder";
import MACD_ADD_Create_Order from '@salesforce/label/c.MACD_ADD_Create_Order';


export default class AddNewNumbersMACD extends NavigationMixin(LightningElement) {
  @track
  selectedTab = "Fixed";

  @track
  showSpinner = false;

  @api
  hideSearch = false;

  @api
  subscriptionId;

  @api
  subscriptionNumber;

  @api
  accountId;

  @api
  basketId;
  //DIGI-35918
  @api
  contactId;

  @track
  searchNumberResult;

  @track
  totalSearchedNumbers;

  @track
  isNumberReserved = false;
  visible = false;
  type;
  message;
  subscriptionsList = [];
  searchedType;
  numberGroupIds = [];
  orderId;
  orderURL;
  disableSubmit = true;
  label = {
    MACD_Add_order_success_msg,
    MACD_Add_order_submit_err_msg,
    MACD_Add_assign_error_msg,
    MACD_Add_unassign_msg,
    MACD_Add_assign_info_msg,
    MACD_Add_order_error_msg
  };
  columns = [
    {
      label: "Subscription Name",
      fieldName: "subscriptionName",
      type: "text",
      sortable: true,
    },
    {
      label: "Subscription Number",
      fieldName: "subscriptionNumber",
      type: "text",
      sortable: true,
    },
    {
      label: "Status",
      fieldName: "status",
      type: "text",
      sortable: true,
    },
    {
      label: "Total Recurring Charges",
      fieldName: "totalRC",
      type: "text",
      sortable: true,
    },
    {
      label: "Billing Account",
      fieldName: "billingAccount",
      type: "text",
      sortable: true,
    },
    {
      label: "Service Id",
      fieldName: "ServiceId",
      type: "text",
      sortable: true,
    },
  ];

  connectedCallback() {}
  passSearchNumberResult(event) {
    //console.log('event.detail.searchresult',JSON.stringify(event.detail.searchresult));
    //console.log('event.detail.responsemessage',JSON.stringify(event.detail.responsemessage));
    this.searchedType = event.detail.searchNumberType;
    let msg = event.detail.responsemessage;
    msg = msg.substring(0, msg.length - 1);
    if (this.searchedType == "Contiguous") {
      this.showSpinner = true;
      splitNumbers({
        searchedNumbers: JSON.stringify(event.detail.searchresult),
      })
        .then((result) => {
          this.showSpinner = false;
          this.searchNumberResult = result;
          this.totalSearchedNumbers = event.detail.responsemessage;
          this.showToastEvent("success", msg + " succesfully!");
        })
        .catch((error) => {
          this.showSpinner = false;
          //console.log(JSON.stringify(error));
          this.showToastEvent("error", erro.message);
        });
    } else {
      this.searchNumberResult = event.detail.searchresult;
      this.totalSearchedNumbers = event.detail.responsemessage;
      this.showToastEvent("success", msg + " succesfully!");
    }
  }

  numberReserved(event) {
    if (event.detail.isnumberreserved) {
      fatchSubscriptions({
        accountId: this.accountId,
        actionTypeSelected: "Manage Fixed Numbers",
        subscriptionId: this.subscriptionId,
      })
        .then((result) => {
          let resultMessage = result;
          this.showSpinner = false;
          if (resultMessage.includes("Error")) {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error!!!",
                message: resultMessage,
                variant: "error",
              })
            );
          } else {
            this.subscriptionsList = result;
            this.isNumberReserved = event.detail.isnumberreserved;
          }
        })
        .catch((error) => {
          //console.log(JSON.stringify(error));
          //console.log('this.accountId-->' + this.accountId);
          this.showSpinner = false;
        });
    }
  }

  get showSearchSection() {
    return !this.hideSearch;
  }

  get isReserved() {
    return this.isNumberReserved;
  }

  createOrder(event) {
    this.showSpinner = true;
    let subscriptionsTable = this.template.querySelector(
      '[data-id="activeSubscriptions"]'
    );
    let subscriptionsList = subscriptionsTable.selectedRowData();
    if (
      this.numberGroupIds &&
      this.numberGroupIds.length > 0 &&
      subscriptionsList &&
      subscriptionsList.length &&
      this.accountId
    ) 
    //DIGI-35918
    {
      createOrder({
        listSelSearchNum: this.numberGroupIds,
        subscription: JSON.stringify(subscriptionsList),
        accountId: this.accountId,
        contactId: this.contactId
      })
        .then((result) => {
          let resultMessage = result;
          //console.log("resultMessage", resultMessage);
          this.showSpinner = false;
          if (
            resultMessage == MACD_Add_order_submit_err_msg ||
            resultMessage == MACD_Add_order_error_msg
          ) {
            //console.log(resultMessage);
            this.showToastEvent("error", resultMessage);
          } else {
            this.orderURL = resultMessage;
            this.orderId = resultMessage != null && resultMessage.split('/').length > 0 ? resultMessage.split('/')[resultMessage.split('/').length - 1] : '';
            this.disableSubmit = false;
            this.showToastEvent('success', MACD_ADD_Create_Order);
          }
        })
        .catch((error) => {
          //console.log(JSON.stringify(error));
          //console.log(JSON.stringify(subscriptionsList));
          //console.log('this.accountId-->' + this.accountId);
          this.showSpinner = false;
          this.showToastEvent("error", MACD_Add_order_submit_err_msg);
        });
    } else {
      //console.log('Data invalid');
      //console.log(JSON.stringify(subscriptionsList));
      //console.log('this.accountId-->' + this.accountId);
      this.showSpinner = false;
      this.showToastEvent("error", MACD_Add_order_submit_err_msg);
    }
  }
  submitOrder(event) {
    this.showSpinner = true;

    submitOrder({
            orderRecordId: this.orderId
        })
        .then(result => {
            this.showToastEvent('success', MACD_Add_order_success_msg);
            window.location.href = this.orderURL;

        })

        .catch(error => {
            this.showToastEvent('error', error.message);


        });

}
  assignSelectedNumbers(event) {
    try {
      this.showSpinner = true;
      let reserveEle = this.template.querySelector(
        '[data-id="reserveNumberResult"]'
      );
      let reservedNumbers = reserveEle.getSelectedReservedNumbers();
      let subscriptionsTable = this.template.querySelector(
        '[data-id="activeSubscriptions"]'
      );
      let subscriptionsList = subscriptionsTable.selectedRowData();
      if (
        reservedNumbers &&
        reservedNumbers.length &&
        subscriptionsList &&
        subscriptionsList.length
      ) {
        let assignedNumbers = [];
        let unAssignedNumbers = [];
        for (let index = 0; index < reservedNumbers.length; index++) {
          if (reservedNumbers[index].Status == "Unassigned") {
            unAssignedNumbers.push(reservedNumbers[index]);
          } else {
            assignedNumbers.push(reservedNumbers[index]);
          }
        }
        if (unAssignedNumbers && unAssignedNumbers.length > 0) {
          if (assignedNumbers.length == 0) {
            assignNumbers({
              inputData: JSON.stringify(unAssignedNumbers),
              subscription: JSON.stringify(subscriptionsList),
              accountId: this.accountId,
            })
              .then((result) => {
                let resultMessage = result;
                this.showSpinner = false;
                if (!resultMessage.isSuccess) {
                  this.showToastEvent("error", resultMessage.message);
                } else {
                  if (
                    resultMessage.recordIds &&
                    resultMessage.recordIds.length > 0
                  ) {
                    for (let i = 0; i < resultMessage.recordIds.length; i++) {
                      this.numberGroupIds.push(resultMessage.recordIds[i]);
                    }
                  }
                  let refreshResult = reserveEle.reservedNumbersList();
                  this.showToastEvent("success", resultMessage.message);
                }
              })
              .catch((error) => {
                //console.log(JSON.stringify(error));
                //console.log(JSON.stringify(reservedNumbers));
                //console.log(JSON.stringify(subscriptionsList));
                //console.log('this.accountId-->' + this.accountId);
                this.showSpinner = false;
                this.showToastEvent("error", MACD_Add_assign_error_msg);
              });
          } else {
            this.showSpinner = false;
            this.showToastEvent(
              "error",
              "Selected " + assignedNumbers.length + " number already assigned."
            );
          }
        } else {
          //console.log('Data invalid');
          //console.log(JSON.stringify(unAssignedNumbers));
          //console.log(JSON.stringify(subscriptionsList));
          //console.log('this.accountId-->' + this.accountId);
          this.showSpinner = false;
          this.showToastEvent("error", MACD_Add_assign_error_msg);
        }
      } else {
        //console.log('Data invalid');
        //console.log(JSON.stringify(reservedNumbers));
        //console.log(JSON.stringify(subscriptionsList));
        //console.log('this.accountId-->' + this.accountId);
        this.showSpinner = false;
        this.showToastEvent("error", MACD_Add_assign_info_msg);
      }
    } catch (error) {
      //console.log('catch');
      this.showSpinner = false;
      this.showToastEvent("error", MACD_Add_assign_info_msg);
    }
  }
  removeSelectedNumbers(event) {
    try {
      this.showSpinner = true;
      let reserveEle = this.template.querySelector(
        '[data-id="reserveNumberResult"]'
      );
      let reservedNumbers = reserveEle.getSelectedReservedNumbers();
      let subscriptionsTable = this.template.querySelector(
        '[data-id="activeSubscriptions"]'
      );
      let subscriptionsList = subscriptionsTable.selectedRowData();
      let assignedNumbers = [];
      let unAssignedNumbers = [];
      for (let index = 0; index < reservedNumbers.length; index++) {
        if (reservedNumbers[index].Status == "Assigned") {
          if (reservedNumbers[index].PhoneNumber) {
            let element = reservedNumbers[index].PhoneNumber;
            if (this.searchedType == "Contiguous" && element.includes(" - ")) {
              let startOrEnd = element.split(" - ");
              //console.log('startOrEnd',startOrEnd);
              let stNum = element.split(" - ")[0].trim();
              //console.log('stNum',stNum);
              let edNum = element.split(" - ")[1].trim();
              //console.log('edNum',edNum);
              if (stNum < edNum) {
                for (let i = stNum; i <= edNum; i++) {
                  assignedNumbers.push(i);
                }
              }
            } else {
              assignedNumbers.push(element);
            }
          }
        } else {
          unAssignedNumbers.push(reservedNumbers[index]);
        }
      }
      if (
        assignedNumbers &&
        assignedNumbers.length > 0 &&
        subscriptionsList &&
        subscriptionsList.length > 0
      ) {
        if (!unAssignedNumbers || unAssignedNumbers.length == 0) {
          removeAssignNumbers({
            selectedNumbers: assignedNumbers,
            subscription: JSON.stringify(subscriptionsList),
          })
            .then((result) => {
              let resultMessage = result;
              this.showSpinner = false;
              if (!resultMessage.isSuccess) {
                this.showToastEvent("error", resultMessage.message);
              } else {
                this.showToastEvent("success", resultMessage.message);
                let refreshResult = reserveEle.reservedNumbersList();
              }
            })
            .catch((error) => {
              //(JSON.stringify(error));
              //console.log(JSON.stringify(reservedNumbers));
              this.showSpinner = false;
              this.showToastEvent("error", MACD_Add_unassign_msg);
            });
        } else {
          this.showToastEvent("error", MACD_Add_unassign_msg);
        }
      } else {
        //console.log('Data invalid');
        //console.log(JSON.stringify(reservedNumbers));
        this.showSpinner = false;
        this.showToastEvent("error", MACD_Add_assign_info_msg);
      }
    } catch (error) {
      this.showSpinner = false;
      this.showToastEvent("error", MACD_Add_unassign_msg);
    }
  }
  
  fillSearchNumbers(event){
    console.log(' call fillSearchNumbers');
    try {
      console.log('fillSearchNumbers ',event.detail);
      this.searchNumberResult = [];
      window.setTimeout(()=>{this.searchNumberResult = [...JSON.parse(event.detail)]},100)
      console.log('this.searchNumberResult ===>',this.searchNumberResult)
    } catch (error) {
      console.log('fillSearchNumbers error',error)
    }
    
  }
  showToastEvent(type, message) {
    this.type = type;
    this.message = message;
    this.visible = true;
    let delay = 5000;
    setTimeout(() => {
      this.visible = false;
    }, delay);
  }
  closeModel() {
    this.visible = false;
    this.type = "";
    this.message = "";
  }
  get getIconName() {
    return "utility:" + this.type;
  }
  get innerClass() {
    return (
      "slds-icon_container slds-icon-utility-" +
      this.type +
      " slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top"
    );
  }

  get outerClass() {
    return "slds-notify slds-notify_toast slds-theme_" + this.type;
  }
}