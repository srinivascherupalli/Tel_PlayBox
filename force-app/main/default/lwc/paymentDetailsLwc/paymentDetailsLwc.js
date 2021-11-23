/*
*@Created Date : 20-05-2021
*@Created By : Kamlesh Kumar
*@Parent Component - Payments(Aura component)
*@Breif : EDGE - 212793. On click of tetlstra id button on Payment. The Modal will get loaded and shows different data based on payment type
*/
import { LightningElement,api,track } from 'lwc';
import paymentDetails from '@salesforce/apex/PaymentsController.getPaymentByTransactionId';

export default class PaymentDetailsLwc extends LightningElement {
    @api paymentInfoData = [];
    @api errorInfoData = [];
    @api invoiceData = [];
    @api openModal = false;
    @api showLoading;
    @api handler;
    @api ban;
    @api transactionId;
    @api Reversed = false;
    columns = [
        {
        label: "Invoice Number",
        fieldName: "invoiceNumber",
        },
        {
            label: "Invoice Date",
            fieldName: "invoiceDate",
        },
        {
            label: "Amount Applied",
            fieldName: "amountApplied",
        }
    ];

    @track unappliedAmount;
    @track totalappliedAmount;
    @track enabledTransactionDetails;
    

    connectedCallback() {
        this.showModal();
    }
     
     @api
    showModal() {
        this.showLoading = true;
        this.openModal = true;
        this.paymentInfoData = [];
        this.totalappliedAmount = '';
        this.errorInfoData = '';
        this.enabledTransactionDetails;
        
        paymentDetails({handler: this.handler,ban: this.ban,transactionId:this.transactionId})
            .then(result=>{
                if (result) {
                    if(result.errors) {
                        this.errorInfoData = result.errors[0];
                        this.enabledTransactionDetails = false;
                    }
                    else if(result.payments) {
                        this.paymentInfoData = result.payments[0];
                        if(result.payments[0].isReversed) {
                            this.Reversed = JSON.parse(result.payments[0].isReversed);
                        }
                        if(result.payments[0].paymentApplicationDetails) {
                           for(let i =0 ;i<result.payments[0].paymentApplicationDetails.length;i++) {
                            result.payments[0].paymentApplicationDetails[i].amountApplied = '$'+result.payments[0].paymentApplicationDetails[i].amountApplied;
                           }
                           this.invoiceData = result.payments[0].paymentApplicationDetails;
                        }
                        if(result.payments[0].paymentAmount) {
                            if(result.payments[0].paymentAmountIndicator) {
                                result.payments[0].paymentAmount = '$'+result.payments[0].paymentAmount+' '+result.payments[0].paymentAmountIndicator;
                            }
                            else {
                                result.payments[0].paymentAmount = '$'+result.payments[0].paymentAmount;;
                            }
                           
                        }
                        if(result.payments[0].paymentAppliedAmount || result.payments[0].paymentAppliedAmount === 0) {
                            result.payments[0].paymentAppliedAmount = '$'+ (result.payments[0].paymentAppliedAmount).toFixed(2);
                        }
                       
                        if(result.payments[0].paymentUnappliedAmount || result.payments[0].paymentUnappliedAmount === 0) {
                            result.payments[0].paymentUnappliedAmount = '$'+result.payments[0].paymentUnappliedAmount;
                        }
                        this.enabledTransactionDetails = true;
                    }
                
                    this.openModal = true;
                    this.showLoading = false;
                }
		})
    }

    
    handleReturnPayment() {
        this.openModal = false;
    }
    
}