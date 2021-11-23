/* **********************************************************************************************************
Sprint        - SFO Sprint 20.17, P2OB-11314.
Component   	- opportunityDuplicateRule
Descriptionc	- Displays warning message with Opportunity is Identified as deplicate.  
Author      	- Amar Chakka. 
************************************************************************************************************ */
import { LightningElement,track,wire,api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import dupOppCheck from '@salesforce/apex/OpportunityDuplicateRuleCheck.dupOppCheck';

const oppFields = [
  'Opportunity.Name',
  'Opportunity.AccountId', 
  'Opportunity.CreatedDate',
  'Opportunity.ASV__c',
  'Opportunity.New_Income_Revenue_Rollup__c',
];
export default class OpportunityDuplicateRule extends LightningElement {


@api recordId;  
@track getRec;
@api oppDupWarMsg = 'As this opportunity is similar to another opportunity, or the Incremental Annuity has been filled out for a renewal opportunity, it may be reviewed by the Audit Team. If you are the Opportunity Owner, your one-up manager will be alerted.';
@api oppDupWarTitle = 'Potential duplicate identified';
wiredResult;
@track showMessage = false;
@track oppData;

/*eslint-disable no-console */
@wire(getRecord, { recordId: '$recordId', fields: oppFields })
wiredProperty({ error, data }){
  if (error) {
    console.log('There is an error');
  } else if (data) { 
    this.getRec = data; 
    this.refresh();
    console.log('Data Retrive Successful'+this.getRec.fields.ASV__c.value +this.getRec.fields.CreatedDate.value);
  }
}

@wire(dupOppCheck, { oppId : '$recordId' })
wiredfunctionoppDetails(result){
  console.log('Calling Apex From Wired Function');
  this.wiredResult = result;
  refreshApex(this.wiredResult);
  if(this.wiredResult.data){
      console.log('Apex Class Result is'+this.wiredResult.data.duplicateOpp);
      if(this.wiredResult.data.duplicateOpp){
        this.showMessage = true;
      }
      else{
        this.showMessage = false;
      }
  }
  else if(result.error){
    console.log('Into Error On Update');
  }
}

refresh(){
  console.log('InsideRefressh');
  refreshApex(this.wiredResult);
}

}