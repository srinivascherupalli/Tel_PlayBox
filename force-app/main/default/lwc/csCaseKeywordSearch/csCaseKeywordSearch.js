import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getSearchResults from '@salesforce/apex/csCaseKeywordSearchCtlr.getSearchResults';
import doMetadataEmpty from '@salesforce/apex/csFileUploadMetadataHandler.doMetadataEmpty';
import formFactorPropertyName from '@salesforce/client/formFactor'
// Import custom labels
import csSearchHistoryLabel from '@salesforce/label/c.csSearchHistoryLabel';
import csSearchDefaultLabel from '@salesforce/label/c.csSearchDefaultLabel';


export default class CsCaseKeywordSearch extends LightningElement {
      
    @track contactsRecord;
    searchValue = '';
    @api caseSubTypeList;
    @track recentList;
    @track callFromRecent =false;
    @track labelValue = '';
    @api value ;
    @api recordIdVar;

    //to Show comma
    get showComma() {
        return this.key !== 4;
    }

    //This method will call on Load of LWC comp to get basis configs
    connectedCallback() {
        console.log('recordIdVar :'+this.recordIdVar);
        getSearchResults({ strSearchKeyword: this.searchValue, strContext: formFactorPropertyName, category : this.value, strRecordId: this.recordIdVar})
        .then(response => {
            if (!response.success) {                    
                return;
            }  
            this.recentList = response.searchHistoryList;
            if(response.isDefault){ 
                this.labelValue = csSearchDefaultLabel;
            } else {
                this.labelValue = csSearchHistoryLabel;
            }
        }).catch(error => {
            window.console.log(error);
        })

        doMetadataEmpty()
    }
 
    // update searchValue var when input field value change
    searchKeyword(event) {
        this.searchValue = event.target.value;
        console.log('this._caseSubTypeList' +this.caseSubTypeList);
        if(this.searchValue >= 3){
            handleSearchKeyword();
        }
    }

    // handle searchValue when click on recent search
    handleRecentSearch(event){
        this.callFromRecent = true;
        event.target.value = event.target.value.trimStart();
        this.caseSubTypeList =[];
        this.handleSearchKeyword(event);
    }
 
    // call apex method on button click 
    handleSearchKeyword(event) {
        this.searchValue = event.target.value;
        if(this.searchValue !== '' && (event.which === 13 || this.callFromRecent)){
            this.callFromRecent = false;
            if(this.searchValue.length >= 3){
                this.caseSubTypeList = null;
                this.caseSubTypeList =[];
                getSearchResults({ strSearchKeyword: this.searchValue, strContext: formFactorPropertyName, category : this.value , strRecordId: this.recordIdVar})
                .then(response => {
                    if (!response.success) {                    
                        return;
                    }  
                    // eslint-disable-next-line guard-for-in
                    this.recentList = response.searchHistoryList;
                    this.labelValue = csSearchHistoryLabel;
                    // eslint-disable-next-line guard-for-in
                    for(var key in response.caseTypeRecords){                    
                        const option = [{
                            label: response.caseTypeRecords[key].Category__c,
                            value: response.caseTypeRecords[key].Category__c
                        }];

                        const radioOption = {
                            label: response.caseTypeRecords[key].Category__c,
                            value: option,
                            description:response.caseTypeRecords[key].Category_Description__c
                        };
                        
                        this.caseSubTypeList = [ ...this.caseSubTypeList, radioOption ];
                    } 
                    if(this.caseSubTypeList !== [])  {
                        const valueChangeEvent = new CustomEvent("casesubtypechange", {
                            detail: { caseSubType: this.caseSubTypeList }
                        });
                        this.dispatchEvent(valueChangeEvent);
                    }     
                //window.console.log(this.caseTypeList);
            }).catch(error => {
                //showToast('Something went wrong'+error);
                window.console.log(error);
            })
            
            }    
        
           //
        } else {
            // fire toast event if input field is blank
            const custevent = new ShowToastEvent({
                variant: 'error',
                message: 'Search text missing..',
            });
        }
    }
}