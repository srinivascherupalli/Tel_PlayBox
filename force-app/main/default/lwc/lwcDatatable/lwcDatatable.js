import { LightningElement, track, api } from 'lwc';
import removeSelected from '@salesforce/apex/PortOutReversalController.removeSelected';

export default class LwcDatatable extends LightningElement {
    @api columns;
    @api recordata;
    @track showremoveassignbutton;
    @api showbutton;
    @track selectedNumberid ;
    @track loadspinner = false;

/**********************************************************************************************************
EDGE        - 142347
Method      - handleRowSelection
Description - method on selection of rows
Author      - Kalashree Borgaonkar
************************************************************************************************************/
    handleRowSelection(event){
        const selectedRows = event.detail.selectedRows;
        this.selectedNumberid = selectedRows;
       
    }
/**********************************************************************************************************
EDGE        - 142347
Method      - handleRemoveAssignedNumbers
Description - remove assigned numbers
Author      - Kalashree Borgaonkar
************************************************************************************************************/
    handleRemoveAssignedNumbers(){
        this.loadspinner = true;
        console.log('this.loadspinner',this.loadspinner);
        var selectedList =  []; 
        if(this.selectedNumberid!=null){
            for(var i=0; i<this.selectedNumberid.length; i++){
                selectedList.push(this.selectedNumberid[i].pcid);
            }
        }
        else{
            //show toast
           // this.loadspinner = false;
            return;
        }
        if(selectedList!=null && (selectedList.length == 0)){
            //this.loadspinner = false;
        }
        const listofPc = JSON.stringify(selectedList);        
        removeSelected({
            selectedPCid : listofPc
        })
        .then(result => {
            this.recordata=[];
            const refreshEvent = new CustomEvent("refresh");
            this.dispatchEvent(refreshEvent);
            this.selectedNumberid = [];
            
        })
        .catch(error => {
            console.log('error data:',error);
            
        })
       
        this.loadspinner = false;
       
    }
    
}