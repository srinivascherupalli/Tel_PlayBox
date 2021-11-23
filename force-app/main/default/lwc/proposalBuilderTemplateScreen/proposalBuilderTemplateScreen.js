import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import getProposalTemplate from '@salesforce/apex/ProposalGenerationController.getProposalTemplate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import FORM_FACTOR from '@salesforce/client/formFactor'

const columns = [
    { label: 'Template Name', fieldName: 'Template_Name__c' }
];

export default class ProposalBuilderTemplateScreen extends LightningElement {
    @api SelectedTemplateName;
    @api basketId;
    @track availableTemplates;
    @track displayRecords = true;
    @track preSelectedRows=[];

    columns = columns; 

    @wire(getProposalTemplate,{basketId : '$basketId'})
    wiredProposalTemplate({ error, data }) {
        var preselected=[];
        if (data) {
            this.availableTemplates = data;
            console.log(data);
            this.error = undefined;
            /*for(let i = 0; i < data.length; i++) {            
                preselected.push(result[i].Id);
                this.preSelectedRows = preselected;
                this.SelectedTemplateName= result[i].Id;       
            }*/
            preselected.push(data[0].Template_Name__c);
            this.preSelectedRows = preselected;
            this.SelectedTemplateName= data[0].Template_Name__c;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    rowselection(event) {
        const selectedRows = event.detail.selectedRows;
        if(selectedRows == ''){
            this.SelectedTemplateName = this.preSelectedRows;
        }else{
            this.SelectedTemplateName = selectedRows[0].Template_Name__c;
        }
        
    }

}