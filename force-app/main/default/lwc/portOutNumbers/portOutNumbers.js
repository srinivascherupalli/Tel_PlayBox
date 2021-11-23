import { LightningElement,api, track } from 'lwc';
import fetchNumbers from "@salesforce/apex/PortOutNumberNGUCController.fetchNumbers"
import createPortOutOrder from "@salesforce/apex/PortOutNumberNGUCController.createPortOutOrder"
import unlockFNN from "@salesforce/apex/PortOutNumberNGUCController.unlockFNN"
import MACD_Add_order_success_msg from "@salesforce/label/c.MACD_Add_order_success_msg";
import MACD_Add_order_submit_err_msg from "@salesforce/label/c.MACD_Add_order_submit_err_msg";
import MACD_Add_order_error_msg from "@salesforce/label/c.MACD_Add_order_error_msg";
import MACD_Unlock_FNN_err_msg from "@salesforce/label/c.MACD_Unlock_FNN_err_msg";
import MACD_Unlock_FNN_suc_msg from "@salesforce/label/c.MACD_Unlock_FNN_suc_msg";


const columns = [
    {
        label: 'Number',
        fieldName: 'serviceNumber',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Service Id',
        fieldName: 'serviceId',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Range',
        fieldName: 'range',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Subscription Number',
        fieldName: 'subscriptionNumber',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Status',
        fieldName: 'status',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    }
];
export default class PortOutNumbers extends LightningElement {

  visible = false;
  type;
  message;
  columns = columns;
  loadingSpinner = false;
  @api
  subscriptionId;


  @api
  subscriptionNumber;
 
  @api
  accountId;

  //DIGI-35918
  @api
  contactId;

  @api
  basketId;
  @track portOutNumblist= [] ;
  @track  searchNumberResult= [];
  subsColumns = [
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


  connectedCallback(){
    // console.log('generix table - columns-'+ JSON.stringify(this.columns));
    // console.log('connectedcallback-');
    // console.log('subscriptionId-'+JSON.stringify(this.subscriptionId));
    this.loadingSpinner = true;
    fetchNumbers({ subscriptionIdList: this.subscriptionId })
      .then((result) => {
          this.error = undefined;
          // console.log('result-'+JSON.stringify(result));
          this.searchNumberResult = result;
          // console.log('this.searchNumberResult.length-'+this.searchNumberResult.length);
          this.loadingSpinner = false;

      })
      .catch((error) => {
          this.error = error;
          this.loadingSpinner = false;

      });
  }

    get isNumberAvailable() {
        return (this.searchNumberResult != null && this.searchNumberResult.length > 0);
    }

    get havePortOutNumb(){
        return (this.portOutNumblist && this.portOutNumblist.length > 0 );
    }

    showToastEvent(type, message) {
      // console.log('tostcall',message);
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

    handleReserveNumber(event) {
        let  selectedSearchRows;
        this.loadingSpinner = true;
        if(event.target.name == 'addSelectedToPortOutPool'){
          selectedSearchRows = this.template.querySelector('[data-id="searchNumbers"]').selectedRowData();
        }
        else{
          selectedSearchRows = this.searchNumberResult;
        }
        
        // console.log('selectedSearchRows-'+JSON.stringify( selectedSearchRows));
        if (selectedSearchRows && selectedSearchRows.length > 0) {
          // console.log('this.portOutNumblist.length-'+this.portOutNumblist.length);
          // console.log('this.searchNumberResult.length-'+this.searchNumberResult.length);

          this.portOutNumblist = [...this.portOutNumblist ,...selectedSearchRows ] ;
          // console.log('after  this.portOutNumblist-'+JSON.stringify( this.portOutNumblist));
          // remove those nos from search table 
          let searchLeft = this.searchNumberResult.filter(({ numberId: id1 }) => !this.portOutNumblist.some(({ numberId: id2 }) => id2 === id1));
          // console.log('searchLeft-'+ JSON.stringify(searchLeft));
          this.searchNumberResult = searchLeft;
          // console.log('after  this.portOutNumblist-'+JSON.stringify( this.portOutNumblist));
          // console.log('this.portOutNumblist.length-'+this.portOutNumblist.length);
          // console.log('this.searchNumberResult.length-'+this.searchNumberResult.length);
          this.loadingSpinner = false;
        }else{
            this.loadingSpinner = false;
            this.showToastEvent('error',MACD_Add_select_number_val_msg);
        }
    }
    
    handleSubmit(){
      // console.log('submit');
      this.loadingSpinner = true;
      let selPortnumbRemove;
      
      try{
          selPortnumbRemove = this.template.querySelector('[data-id="portOutNumbers"]').selectedRowData();
      }catch (error){
        this.showToastEvent("error", 'Please add at least one number to port-out pool.');
        this.loadingSpinner = false;
      }
      // console.log('this.portOutNumblist-'+JSON.stringify(this.portOutNumblist));
      // console.log('this.portOutNumblist.length-'+this.portOutNumblist.length);
      if(this.portOutNumblist.length == 0)
      {
        this.showToastEvent("error", 'Please add at least one number to port-out pool');
        this.loadingSpinner = false;
        return;
      }

     // create order - String accountId ,string subscription, list<NumberWrap>  listNumberWrap
     //DIGI-35918
      createPortOutOrder({ 
        accountId : this.accountId,        
        numbersWrapStr : JSON.stringify(this.portOutNumblist),
        contactId : this.contactId      
      })
          .then((result) => {
              this.loadingSpinner = false;
              this.error = undefined;
              // console.log('result-'+JSON.stringify(result));

              let resultMessage = result;
              console.log("resultMessage", resultMessage);
              if (
                resultMessage == MACD_Add_order_submit_err_msg ||
                resultMessage == MACD_Add_order_error_msg
              ) {
                //console.log(resultMessage);
                this.showToastEvent("error", resultMessage);
              } else {
                window.location.href = resultMessage; 
                this.showToastEvent("success", MACD_Add_order_success_msg);
              }
              
          })
          .catch((error) => {
            this.loadingSpinner = false;
              this.error = error;
              this.showToastEvent('error','Something went wrong! ');
          });
    
    }

    handleRemoveResPoolNumb(event){
      // console.log('handleRemoveResPoolNumb');
      this.loadingSpinner = true;
      let selPortnumbRemove ;
      

      if(event.target.name == 'removeSelectfromPortOutPool'){
        selPortnumbRemove = this.template.querySelector('[data-id="portOutNumbers"]').selectedRowData();
      }else{
        selPortnumbRemove = this.portOutNumblist;
      }
      // console.log('this.searchNumberResult.length-'+ JSON.stringify(this.searchNumberResult.length));
      // console.log('selPortnumbRemove-'+ JSON.stringify(selPortnumbRemove));
      //push selected numb to search table
      this.searchNumberResult = [...this.searchNumberResult,...selPortnumbRemove];

      // remove selected from port out pool 
      let portOutPoolLeft = this.portOutNumblist.filter(({ numberId: id1 }) => !selPortnumbRemove.some(({ numberId: id2 }) => id2 === id1)); 

      this.portOutNumblist = portOutPoolLeft;
      // console.log('portOutPoolLeft-'+ JSON.stringify(portOutPoolLeft));
      // console.log('this.searchNumberResult-'+ JSON.stringify(this.searchNumberResult));
      // console.log('this.searchNumberResult.length-'+this.searchNumberResult.length);

      this.loadingSpinner = false;
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
    //Added as part of DIGI-27804 to unlock FNN
    handleUnlock(){ 
      this.loadingSpinner = true;
        let selectedNumbers = this.template.querySelector('[data-id="searchNumbers"]') != null ? this.template.querySelector('[data-id="searchNumbers"]').selectedRowData() : [];
        console.log(this.template.querySelector('[data-id="searchNumbers"]'));
        if(selectedNumbers.length > 0){
          unlockFNN(
            {numberWrapperString : JSON.stringify(selectedNumbers)}
            ).then(result => {
              this.searchNumberResult = [];
              this.showToastEvent('success',MACD_Unlock_FNN_suc_msg);
              this.connectedCallback();
              
            })
        }
        else{
          this.showToastEvent('error',MACD_Unlock_FNN_err_msg);
          this.loadingSpinner = false;
        }
    }
}