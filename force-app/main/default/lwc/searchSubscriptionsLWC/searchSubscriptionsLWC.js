import { LightningElement, track } from 'lwc';
import getSubscriptions from "@salesforce/apex/searchSubscriptions.getSubscriptions";

export default class SearchSubscriptionsLWC extends LightningElement {
@track fromDate;
@track toDate;
@track todayDate;
@track validationError = false;
@track futureDatevalidation = false;
@track customerAccStr = 'RecordType.name=\'Enterprise\'';
@track partnerAccStr = 'RecordType.name=\'Partner\'';
@track custAccountName;
@track custAccountName;
@track partnerAccountName;
@track partnerAccountRecordId;
@track CIDN;
@track partnerCode;
@track pickListVal;
@track mandateVal = false;
@track recordsList;
@track errorMsg;
@track error;
@track message;

@track todayValidate;

connectedCallback(){
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = dd + '/' + mm + '/' + yyyy;
    this.todayDate = today;

   
    this.todayValidate = yyyy + '-' + mm + '-' + dd;
    console.log(this.todayValidate+'@@@@@@@@');
}
selectedfromDate(event){
    this.fromDate = event.target.value;
    if(this.fromDate == null){
        this.validationError = false;
    }

    if(this.toDate != undefined && this.fromDate != undefined){
        if(this.fromDate > this.toDate){
            this.validationError = true;
        }else{
            this.validationError = false;
        }
    }


}
selectedtoDate(event){
    this.toDate = event.target.value;
    if(this.toDate == null){
        this.validationError = false;
    }

    if(this.toDate != undefined && this.fromDate != undefined){
        if(this.fromDate > this.toDate){
            this.validationError = true;
        }else{
            this.validationError = false;
        }
    }
    if(this.toDate > this.todayDate){
        //this.futureDatevalidation = true;
    }else{
        this.futureDatevalidation = false;
    }
}
onCustomerAccSelection(event){ 
    this.custAccountName = event.detail.selectedValue;  
    this.custAccountRecordId = event.detail.selectedRecordId;
    this.mandateVal = false;
}
onPartneraccSelection(event){ 
    this.partnerAccountName = event.detail.selectedValue;  
    this.partnerAccountRecordId = event.detail.selectedRecordId;
    this.mandateVal = false;
}
handleCIDNChange(event){
    this.mandateVal = false;
    this.CIDN = event.target.value;
    console.log(this.CIDN+'CIDN');
}
handlepartnercode(event){
    this.mandateVal = false;
    this.partnerCode = event.target.value;
}
changeHandler(event){
    this.pickListVal = event.target.value;
}
handleSearch(event){
    console.log(event.target.label);
        var inp=this.template.querySelectorAll("lightning-input");

        inp.forEach(function(element){
            if(element.name=="CIDN")
                this.CIDN=element.value;
            else if(element.name=="partnerCode")
                this.partnerCode=element.value;
        },this);
    if(this.custAccountName == undefined && this.partnerAccountName == undefined &&
        (this.CIDN == undefined || this.CIDN == '') && (this.partnerCode == undefined || this.partnerCode == '')){
        this.mandateVal = true;
    }else{
        this.mandateVal = false;
        //this.callHandler();

        if(this.validationError == false){
            this.callApexMethod();
        }
    }
}

callApexMethod(){
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("callsearchvaluechange", {
                            detail: { 
                                partnerAccount : this.partnerAccountRecordId,
                                customerAccount : this.custAccountRecordId,
                                CIDN : this.CIDN,
                                partnerCode : this.partnerCode,
                                startDate : this.fromDate,
                                endDate : this.toDate,
                                type : this.pickListVal
                                    }
      });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
callHandler(){
    console.log('Calling Apex');
    getSubscriptions ({partnerAccount : this.partnerAccountRecordId,customerAccount : this.custAccountRecordId,
        CIDN : this.CIDN,partnerCode : this.partnerCode,startDate : this.fromDate,endDate : this.toDate,type : this.pickListVal})
    .then(result => {
    if (result.length===0) {  
        this.recordsList = [];  
        this.message = "No Records Found";  
        } else {  
        this.recordsList = result;  
        this.message = "";  
        }  
        this.error = undefined; 
        this.createSearchEvent(); 
    }).catch((error) => {  
        this.errorMsg = error;  
        this.recordsList = undefined;  
        });
       
}
createSearchEvent(){
    const selectedEvent = new CustomEvent("callsearchvaluechange", {
        detail: this.recordsList
    });
    this.dispatchEvent(selectedEvent);
}
selectedDate(event){
    console.log(this.todayDate+'this.todayDate');
    this.fromDate = this.todayDate;
    
}
selectedDateTo(event){
    console.log(this.todayDate+'this.todayDate');
    this.toDate = this.todayDate;
}
}