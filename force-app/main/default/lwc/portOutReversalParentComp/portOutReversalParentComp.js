import { LightningElement, track, api } from 'lwc';
import getProductConfigDetails from '@salesforce/apex/PortOutReversalController.getProductConfigDetails';
import finishReservation from '@salesforce/apex/PortOutReversalController.finishReservation';

export default class PortOutReversalParentComp extends LightningElement {

    //As part of EDGE-166187, duplicated the column/s based on the solution. Also added new column field 'SIM Type' and commented Serial number
    @track columns = [ 
        {label: 'Mobile Plan', fieldName: 'name', type: 'text'},
        {label: 'Number', fieldName: 'number_x', type: 'text'},
        {label: 'SIM Serial', fieldName: 'simSerial', type: 'text'},        
        {label: 'SIM Type', fieldName: 'simtypeval', type: 'text'},
      // {label: 'Serial Number', fieldName: 'serialNumber', type: 'text'}  
   ];

   @track column = [ 
        {label: 'Mobile Plan', fieldName: 'name', type: 'text'},
        {label: 'Number', fieldName: 'number_x', type: 'text'},
        {label: 'SIM Serial', fieldName: 'simSerial', type: 'text'} 
    // {label: 'Serial Number', fieldName: 'serialNumber', type: 'text'}  
    ];
     
  
    @track recordata;  
    @api basketid;               
    @track error; 
    @track pcid; 
    @track imsi; 
    @track toasttitle;
    @track toastmsg
    @track toastvariant;
    @track loadspinner = true;
    @api solutionnameval;  // EDGE-166187
    @track enablesimtype = false;  

    connectedCallback(){
        this.getPCdetails();
        if(this.solutionnameval == "Corporate Mobile Plus"){ // EDGE-166187
            this.enablesimtype = true;
        }
    }
/**********************************************************************************************************
EDGE        - 142347
Method      - closePopup
Description - closePopup
Author      - Kalashree Borgaonkar
************************************************************************************************************/
    closePopup(){
       const closePopupEvent = new CustomEvent("select");
       this.dispatchEvent(closePopupEvent);
    }
/**********************************************************************************************************
EDGE        - 142347
Method      - handleDatatableRefresh
Description - handleDatatableRefresh
Author      - Kalashree Borgaonkar
************************************************************************************************************/
    handleDatatableRefresh(){
        this.getPCdetails();
    }

/**********************************************************************************************************
EDGE        - 174219
Method      - handleDataRefreshandFireEvent
Description - handleDataRefreshandFireEvent
Author      - Dheeraj
************************************************************************************************************/
handleDataRefreshandFireEvent(){
    console.log('Inside handledatafireevnt controller');
    // this.getPCdetails();
   
    const basket_id = this.basketid;
        getProductConfigDetails({
            basketid : basket_id
        })
        .then(result => {
            console.log('result data:',result);
            this.recordata = result;
            this.pcid = this.recordata[0].pcid;
            console.log('Record Data ',JSON.stringify(this.recordata));
            const selectEvent = new CustomEvent('callVFEvent', {
                detail: {
                    recordsString: JSON.stringify(this.recordata),
                }
        
            });
           this.dispatchEvent(selectEvent);
           console.log('selectEvent  = '+selectEvent);
           
        })
        .catch(error => {
            console.log('error data:',error);
            this.error = error;
        })
        this.loadspinner =false;
}
/**********************************************************************************************************
EDGE        - 142347
Method      - handleDatatableRefresh
Description - handleDatatableRefresh
Author      - Kalashree Borgaonkar
************************************************************************************************************/
    getPCdetails(){
        const basket_id = this.basketid;
        getProductConfigDetails({
            basketid : basket_id
        })
        .then(result => {
            console.log('result data:',result);
            this.recordata = result;
            this.pcid = this.recordata[0].pcid;
        })
        .catch(error => {
            console.log('error data:',error);
            this.error = error;
        })
        this.loadspinner =false;
    }
/**********************************************************************************************************
EDGE        - 142347
Method      - handleFinish
Description - finish reservation validation
Author      - Kalashree Borgaonkar
************************************************************************************************************/
    handleFinish(){
        console.log('in finish:');
        const basket_id = this.basketid;
        finishReservation({
            basketid : basket_id
        })
        .then(result => {
            console.log('result data:',result);
            if(result==false){
                this.setToastvalues('Error','A number is required to be assigned to the product item','error');
            }
            else{
                this.closePopup();
            }    
        })
        .catch(error => {
            console.log('error data:',error);
            this.error = error;
        })

        
    }
/**********************************************************************************************************
EDGE        - 142347
Method      - setToastvalues
Description - set values for toast
Author      - Kalashree Borgaonkar
************************************************************************************************************/
    setToastvalues(toasttitle,toastmsg,toastvariant){
        this.toasttitle = toasttitle;
        this.toastmsg = toastmsg;
        this.toastvariant = toastvariant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice(); 
    }
    customTostEvent(event){
        this.toasttitle = event.detail.toasttitle;
        this.toastmsg = event.detail.toastmsg;
        this.toastvariant = event.detail.toastvariant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice(); 
    }
}