import { LightningElement,wire,track,api } from 'lwc';
import fetchRecords from "@salesforce/apex/NotificationPreferenceCtrl.getPreferences";  
import { CurrentPageReference } from 'lightning/navigation';
export default class NotificationPreference extends LightningElement {
@track recordId='';
@track objectName='';
@track checkRecorddate=false;
@track searchValue ;
@track recordata;
@wire(CurrentPageReference)
wiredPageReference(currentPageReference) {
this.currentPageReference= currentPageReference;
this.recordId=this.recordIdFromState;
this.objectName= this.objectNameFromState;
}
get recordIdFromState(){
    return this.currentPageReference &&
        this.currentPageReference.state.c__recordId; 
}
get objectNameFromState(){
return this.currentPageReference &&
    this.currentPageReference.state.c__objectName; 
}
connectedCallback()
{
        this.recordId=this.recordIdFromState;
        this.objectName= this.objectNameFromState;
        //call apex after this.recordId has value
}

hanldeSearchValueChange(event) {
    console.log('event.detail: ',JSON.stringify(event.detail));
    this.searchValue = event.detail;
    this.checkRecorddate = false;
        fetchRecords(this.searchValue).then(result => {
            this.recordata=result;
            if(result==null){
                this.checkRecorddate = false;
            }
            else{
                this.checkRecorddate = true;
            }
        console.log('result:   ',JSON.stringify(result));
        })
        .catch(error => {
            this.error = error;
            this.recordata=[];
            this.checkRecorddate = false;
            console.log('fetchRecords error:   ',JSON.stringify(fetchRecords));
        });
    }
    //EDGE-171180 Kalashree Borgoankar. Refresh after bulk update
    handleRefreshEvent(event){
        console.log("this.searchValue:",JSON.stringify(this.searchValue));
        this.checkRecorddate = false;
        fetchRecords(this.searchValue).then(result => {
            this.recordata=result;
            this.checkRecorddate = true;
        })
        .catch(error => {
            this.error = error;
            this.recordata=[];
            this.checkRecorddate = false;
            console.log('fetchRecords error:   ',JSON.stringify(fetchRecords));
        });
    }
}