import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import formFactorPropertyName from '@salesforce/client/formFactor'


import getGetCaseConfigurations from '@salesforce/apex/csGetCaseConfigurationsCtrl.getGetCaseConfigurations';

export default class CsGetCaseConfigurations extends LightningElement {
    @track value = '';  
    @track radioValue = '';
    @track mapTypetoSubTypes;
    @track mapSubTypeFlowInput;
    @track mapSubTypeDescription;
    @track errorMsg;
    @track error;
    @track caseTypeList =[];
    @track caseSubTypeList =[];
    @api flowInput='';
    @track showEmptyMessage = false;
    @api recordId;
    @track pageType = '';
    @track record ='';

    //This method will call on Load of LWC comp to get basis configs
    connectedCallback() {
        this.isLoading = true;
        this.disableSubmit = true;
        this.record = this.recordId;
        if(!this.recordId){
            this.pageType = 'Home';
        }
        getGetCaseConfigurations({ strRecordId: this.recordId , strContext: formFactorPropertyName, strPageType: this.pageType})
            .then(response => {
                if (!response.success) {                    
                    return;
                } 
                console.log('response++++++++++',response);
                this.mapTypetoSubTypes = response.mapTypetoSubTypes;
                this.mapSubTypeFlowInput = response.mapSubTypeFlowInput;
                this.mapSubTypeDescription = response.mapSubTypeDescription;
                this.mapTypeCount = response.mapTypeCount;
                const mapTypetoSubTypesConst = this.mapTypetoSubTypes;
                const mapSubTypeFlowName = response.mapSubTypeFlowName;
                const sentFlowNameEvent = new CustomEvent("flowname", {
                    detail: { mapSubTypeFlowName, mapTypetoSubTypesConst }
                });
                this.dispatchEvent(sentFlowNameEvent);
                // eslint-disable-next-line guard-for-in
                for(var key in this.mapTypetoSubTypes){                    
                    const option = {
                        label: key + ' ('+this.mapTypeCount[key]+')',
                        value: key
                    };
                    
                    this.caseTypeList = [ ...this.caseTypeList, option ];
                }
                this.value = 'All';
                // eslint-disable-next-line guard-for-in
                for(var key in this.mapTypetoSubTypes[this.value]){
                    const option = [{
                        label: this.mapTypetoSubTypes[this.value][key] ,
                        value: this.mapTypetoSubTypes[this.value][key]
                    }];

                    const radioOption = {
                        label: this.mapTypetoSubTypes[this.value][key] ,
                        value: option,
                        description: this.mapSubTypeDescription[this.mapTypetoSubTypes[this.value][key]]
                    };
                    
                    this.caseSubTypeList = [ ...this.caseSubTypeList, radioOption ];
                    
                }
                if(response.strError){
                    this.dispatchEvent(
                        new ShowToastEvent({
                                  title: 'Error!',
                                  message: response.strError,
                                  variant: 'error',
                                  mode: 'sticky'
                              })
                    );                    
                    
                }
                window.console.log(this.caseTypeList);
            }).catch(error => {
                window.console.log(error);
            })

    }
    
    //To get the support Type option
    get options() {
        return this.metadatarecord.data.fields.Type__c.value;
    }

    //To populate radio option
    handleChange(event) {
        this.caseSubTypeList =[];
        this.value = event.detail.value;
        // eslint-disable-next-line guard-for-in
        for(var key in this.mapTypetoSubTypes[this.value]){
            const option = [{
                label: this.mapTypetoSubTypes[this.value][key] ,
                value: this.mapTypetoSubTypes[this.value][key]
            }];

            const radioOption = {
                label: this.mapTypetoSubTypes[this.value][key] ,
                value: option,
                description: this.mapSubTypeDescription[this.mapTypetoSubTypes[this.value][key]]
            };
            
            this.caseSubTypeList = [ ...this.caseSubTypeList, radioOption ];
        }

        const typeVal =  event.detail.value;
        const typeChangeEvent = new CustomEvent("typeSelected", {
            detail: { typeVal}
        });
        this.dispatchEvent(typeChangeEvent);

    }

    //to show toast message
    showToast(errorMsg) {
        const evt = new ShowToastEvent({
                title: 'Application Error',
                message: errorMsg,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
    }

    //to send selected radio option to parent LC comp
    handleRadioChange(event) {
        this.radioValue = event.detail.value;
        this.flowInput = this.mapSubTypeFlowInput[this.radioValue];
        const flowInputParam = this.flowInput;
        const categoryLabel = this.radioValue;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { flowInputParam , categoryLabel}
        });
        this.dispatchEvent(valueChangeEvent);
        window.console.log(this.radioValue);
    }

    handleSearch(event){
        //this.caseSubTypeList = null;
        this.caseSubTypeList =[];
        // eslint-disable-next-line guard-for-in
        for(var key in  event.detail.caseSubType ){            
            
            this.caseSubTypeList = [ ...this.caseSubTypeList,  event.detail.caseSubType[key] ];
        }
        if((this.caseSubTypeList).length === 0){
            this.showEmptyMessage = true;
        }else{
            this.showEmptyMessage = false;
            const isSearched = true;
            const validSearchDone = new CustomEvent("searchDone", {
                detail: { isSearched }
            });
            this.dispatchEvent(validSearchDone);
        }
    }
}