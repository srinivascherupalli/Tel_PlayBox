import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import getProductBasket from '@salesforce/apex/ProposalGenerationController.getProductBasket';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import FORM_FACTOR from '@salesforce/client/formFactor'

const columns = [
    { label: 'Product Basket Name', fieldName: 'Name' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
    { label: 'Synchronised With Opportunity', fieldName: 'csbb__Synchronised_With_Opportunity__c', type: 'boolean' }

];

export default class ProposalBuilderBasketScreen extends LightningElement {
    @api OppID;
    @api SelectedBasketId;
    @track availableBaskets;
    @track displayRecords = true;
    @track preSelectedRows=[];
    @api recordId;

    columns = columns; 

    connectedCallback(){
        getProductBasket({ OpptyId: this.OppID})
            .then(result => {
                if(result.length >= 1){
                    this.availableBaskets = result;
                    this.displayRecords = true; 
                    var preselected=[];
                    for(let i = 0; i < result.length; i++) {            
                        if(result[i].Primary_Basket__c){
                            preselected.push(result[i].Id);
                            this.preSelectedRows = preselected;
                            this.SelectedBasketId= result[i].Id;
                        }
                    }

                }
                else{

                    this.displayRecords = false;
                }
            })
    }

    rowselection(event) {
        const selectedRows = event.detail.selectedRows;
        console.log('selectedRows '+selectedRows);
        if(selectedRows == ''){
            this.SelectedBasketId = this.preSelectedRows;

        }else{

            this.SelectedBasketId = selectedRows[0].Id;

        }

    }
}