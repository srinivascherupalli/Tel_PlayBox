import { LightningElement,api,wire,track } from 'lwc';
import getBillingAccNum from '@salesforce/apex/InvoiceDrillDownHandler.getBillingAccNum';
const headerColumns = [
    { label: 'Invoice Number', fieldName: 'invoiceNumber' },
    { label: 'Offer Name', fieldName: 'offerName'},
    { label: 'Charge Description', fieldName: 'chargeDescription'}
];

export default class InvoiceDrillDownSummary extends LightningElement {
    
    @api drillDownEndPoint = '';
    @api chargeId = '';
    @track titleForCharges= '';
    @track isModalOpen = true;
    @api invoiceNumber ='';
    @api offerName ='';
    @api chargeDescription ='';
//    @api childPageMapData= '';
    @track isOnceOffCharge= false;
    @track isRecurringCharge= false;
    @track isFeaturePack= false;
    @track isRepaymentCharge= false;
    @api billingAccId='';
    @track billingAccNum ='';
    @track loadSpinner = false;
    @api previousSelectedRows;
    @api previousSelectedRowData;
    @api mapOfRowsToChargeId;

    
    

    connectedCallback(){
        console.log("inside invoice drill down previousSelectedRows:", this.previousSelectedRows);
        console.log('drillDownEndPoint',this.drillDownEndPoint);
        switch(this.drillDownEndPoint) {
            case 'Recurring details':  
                 this.titleForCharges ='Recurring Charge Details';
                 this.isRecurringCharge = true;
                break;
        
            case 'Order details':  
                   this.titleForCharges ='Once Off Charge Details';
                    this.isOnceOffCharge = true;
                break;
         
           case 'FeaturePackDetails':
                    this.titleForCharges ='Feature Pack(Consumption based) Details';
                    this.isFeaturePack = true;
                    break;
            case 'Repayment details':
             this.titleForCharges ='Repayment Charge Details';
             this.isRepaymentCharge = true;
            break;
        
            default:
             this.titleForCharges ='Charge Details';
            
        }
        this.headerColumns = headerColumns;
        this.setBillingAccNum();
    }

    closeModal() {
        console.log("modal close=====>",this.previousSelectedRowData);
        this.isModalOpen = false;
        const closePopup = new CustomEvent('closePopup', {  
        });
        this.dispatchEvent(closePopup);
    }

    setBillingAccNum()
    {
        getBillingAccNum({ billAccId: this.billingAccId
        })
        .then((result) => {
            this.billingAccNum = result;
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            this.billingAccNum = undefined;
        });
       
    }
    navToInvoiceCmp()
    {
        let selectedResRows = this.template.querySelector('[data-id="chargeTable"]').selectedRowData();
        let finalRows =[];
        for (let index = 0; index < selectedResRows.length-2; index++) {
            selectedResRows[index].offerName = this.offerName;
            selectedResRows[index].chargeType = this.chargeType;
            selectedResRows[index].chargedescription = this.chargeDescription;
            selectedResRows[index].excludingGSTcostFmtd = '$'.concat(selectedResRows[index].excludingGSTcostFmtd.toString());
            selectedResRows[index].includingGSTcostFmtd = '$'.concat(selectedResRows[index].includingGSTcostFmtd.toString());
            selectedResRows[index].chargeId = this.chargeId;
           // console.log('selectedResRows-------',JSON.stringify(selectedResRows[index]));
            finalRows.push(selectedResRows[index]);
        } 
        
        let mapValue = selectedResRows[selectedResRows.length -2];
        let mapDataValue = selectedResRows[selectedResRows.length - 1];
        this.previousSelectedRows = mapValue;
        this.previousSelectedRowData = mapDataValue;
        let rowsToDisplay = new Map();
       
        if(this.mapOfRowsToChargeId!= null && this.mapOfRowsToChargeId!= undefined)
        {
            rowsToDisplay = this.mapOfRowsToChargeId;
            console.log('rowsToDisplay',rowsToDisplay); 
        }
        rowsToDisplay.set(this.chargeId,finalRows);
        console.log('rowsToDisplay---LWC',rowsToDisplay);
        
        console.log("this.previousSelectedRows===>",this.previousSelectedRows);
        const navToInvoice = new CustomEvent('navToInvoice', {   detail: {
            reviewTableData: finalRows,
            mapOfRowsForReview:rowsToDisplay,
            rowCount: selectedResRows.length,
            chargeType: this.chargeType,
            rowData: this.previousSelectedRows,
            selectedRowMap : this.previousSelectedRowData,
            chargeId: this.chargeId
        }
        });
        this.dispatchEvent(navToInvoice);
    
    }
    
    
   
}