import { LightningElement,track } from 'lwc';
import getSubscriptions from "@salesforce/apex/searchSubscriptions.getSubscriptions";

export default class ManageCommissionsPartner extends LightningElement {
    @track searchValue;
    @track recordata;
    @track checkRecorddate=false;
    hanldeSearchValueChange(event) {
        this.searchValue = event.detail;
        this.checkRecorddate = false;
        console.log(this.searchValue+'%%%%%%%%%%%%%');
        getSubscriptions(this.searchValue).then(result => {
                this.recordata=result;
                console.log(this.recordata+'%%%%%%%%%%%%%');
                if(result==null){
                    this.checkRecorddate = false;
                }
                else{
                    this.checkRecorddate = true;
                }
            console.log('result: ',JSON.stringify(result));
            })
            .catch(error => {
                this.error = error;
                this.recordata=[];
                this.checkRecorddate = false;
                //console.log('fetchRecords error:   ',JSON.stringify(fetchRecords));
            });
        }

        handleRefreshEvent(event){
            console.log("this.searchValue:",JSON.stringify(this.searchValue));
            this.checkRecorddate = false;
            getSubscriptions(this.searchValue).then(result => {
                this.recordata=result;
                this.checkRecorddate = true;
            })
            .catch(error => {
                this.error = error;
                this.recordata=[];
                this.checkRecorddate = false;
            });
        }
}