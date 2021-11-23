/*
    AUTHOR : Sajal Shah    
    DESCRIPTION : LWC for One Fund Balance Transfer
*/

import { LightningElement, track, api } from 'lwc';
import checkOneFundAccount from '@salesforce/apex/FundBalanceTransfer.CheckOneFundRecords';
import fundBalanceTranseferError from '@salesforce/label/c.FundBalanceTransferErrorMessage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class FundBalanceTransferComp extends LightningElement {
    hasOneFundAccount = false;
    @track errorMessage;
    @api recordId;
    renderCalled = false;
    @track mapData= [];

    connectedCallback(){
        
    }

    renderedCallback(){
        if(this.renderCalled === false && (this.recordId !== undefined && this.recordId !== '' )){
            this.checkOneFundAccount();
            this.renderCalled = true;
        }
    }

    checkOneFundAccount(){
        checkOneFundAccount({accountRecId : this.recordId})
        .then(result => {
            console.log('---result---'+JSON.stringify(result));
            if(result == null){
                console.log('---result null---');
                this.errorMessage = fundBalanceTranseferError;
                const event = new ShowToastEvent({
                    "title": "Error!",
                    "message": this.errorMessage,
                    "variant": "Error"
                });
                this.dispatchEvent(event);
            }
            else{
                console.log('---result in else---'+result);
                var message = result.message;
                var errorBool = result.Error;
                if(message.includes('success') && errorBool === 'false'){
                    const event = new ShowToastEvent({
                        "title": "Success!",
                        "message": message,
                        "variant": "success"
                    });
                    this.dispatchEvent(event);
                }
                //START: Modified for DIGI-2094
                else if(message.includes('One fund record inserted') && errorBool === 'false'){
                    this.checkOneFundAccount();
                }
                //END for DIGI-2094
                else{
                    const event = new ShowToastEvent({
                        "title": "Error!",
                        "message": message,
                        "variant": "error"
                    });
                    this.dispatchEvent(event);
                }
            }
            //START: Modified for DIGI-2094
            if(!message.includes('One fund record inserted')){
                const value = 'completed';
                const valueChangeEvent = new CustomEvent("valuechange", {
                    detail: { value }
                });
                this.dispatchEvent(valueChangeEvent);
            }
            //END for DIGI-2094
        }).catch(error => {
            console.log('---Error in checkOneFundAccount---',error);
        }); 
    }
}