/*
Modified By : Team Hawaii
Date : 10/8/2020
Jira No: P2OB-8030 && P20B-7893
Description: Search cmponent which display article based on data categories and record type access of user
Version             Jira                     Modified Date        By         Description 
12 -August-2020     P2OB-8030 && P20B-7893   12 August 2020       Hawaii     Updated Description in metadata file for topCategory variable.It will take comma separated value 
*/
import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
//get first name field of user object
import FIRSTNAME_FIELD from '@salesforce/schema/User.FirstName';
//get middle name field of user object
import MIDDLENAME_FIELD from '@salesforce/schema/User.MiddleName';
//get last name field of user object
import LASTNAME_FIELD from '@salesforce/schema/User.LastName';
import getKnowldegeArticleData from '@salesforce/apex/PRMOffersCarousel.getKnowldegeArticleData';
const fields = [FIRSTNAME_FIELD, MIDDLENAME_FIELD, LASTNAME_FIELD];
import { reduceErrors } from 'c/ldsUtils';
export default class PRMknowledgeArticleSearch extends LightningElement {


    @track error;
    @track knowledgeArticleRecord = [];
    userId = Id;
    pageSizeOption = [
        { label: 3, value: '3' },
        { label: 6, value: '6' },
        { label: 9, value: '9' },
    ];
    pageSize = '6';
    page = '1';
    totalRecords;
    searchString = '';
    cloneKnowledgeArticleRecord = [];
    //attribute to show and hide text message to user
    @api showMessageAtTop= false;
    //attribute to store field name of user object
    @api userFields = '';
    //attribute to store message content
    @api messageText='';
    //top category 
    @api topCategory = '';

    //wire adapter to get a user's data.
    @wire(getRecord, { recordId: '$userId', fields })
    user;

    //method to generate name of user
    get userName(){
        var name='';
        if(this.user.data != undefined && this.userFields != ''){
            if(this.userFields.includes('FirstName')){
            name = name != '' ? ' '+ getFieldValue(this.user.data, FIRSTNAME_FIELD) : getFieldValue(this.user.data, FIRSTNAME_FIELD);
            }
            if(this.userFields.includes('MiddleName')){
                name += name != '' ? ' '+getFieldValue(this.user.data, MIDDLENAME_FIELD):getFieldValue(this.user.data, MIDDLENAME_FIELD);
            }
            if(this.userFields.includes('LastName')){
                name += name != '' ? ' '+getFieldValue(this.user.data, LASTNAME_FIELD):getFieldValue(this.user.data, LASTNAME_FIELD);
            }
        }
        return name;
    }

    //method to show and hide pagination functionality
    get showSearchData() {
        return this.knowledgeArticleRecord.length > 0;
    }

    //method to show and hide result template
    get showNoResultMesg() {
        return (this.searchString !== '' && this.searchString.length > 2);
    }


    //on change event on search text change
    handleSearchTermChange = (event) => {
        // Debouncing this method: do not update the reactive property as
        // long as this function is being called within a delay of 300 ms.
        // This is to avoid a very large number of Apex method calls.

        window.clearTimeout(this.delayTimeout);
        this.searchString = event.target.value;
        if (this.searchString === '' || this.searchString.length < 3) {
            this.knowledgeArticleRecord = [];
            return;
        }
        this.delayTimeout = setTimeout(() => {
            this.page = '1';
            this.getKnowledgeArtclData();
        }, 300);
    }

    //Method to get article details from apex
    getKnowledgeArtclData(){
        getKnowldegeArticleData({searchString : this.searchString,topCategory : this.topCategory}).then(result =>{
            if(result){
                this.knowledgeArticleRecord = result;
                this.cloneKnowledgeArticleRecord = this.knowledgeArticleRecord;
                this.totalRecords = this.knowledgeArticleRecord.length;
                this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                this.handlePaggination();
             }
          })
          .catch(error => {
            this.errors = reduceErrors(error); // code to execute if the promise is rejected
        });
    }

    //handle pagesize event fired from prmPaginationComp
    handlePageSizeChange = (event) => {
        this.page = '1';
        this.pageSize = event.detail;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        this.handlePaggination();
    }

    //handle previous event fired from prmPaginationComp
    handlePrevious() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.handlePaggination();
        }
    }

    //handle next event fired from prmPaginationComp
    handleNext() {
        if (this.page < this.totalPages) {
            this.page = parseInt(this.page) + 1;
            this.handlePaggination();
        }
    }

    //handle pagecountchange event fired from prmPaginationComp
    handlePageCountChange = (event) => {
        this.page = event.detail;
        this.handlePaggination();
    }

    //Update knowledgeArticleRecord variable so that relevent records are visible to users
    handlePaggination = () => {
        let offSetSart = (this.page - 1) * this.pageSize;
        let offSetEnd = (this.page * this.pageSize);
        this.knowledgeArticleRecord = this.cloneKnowledgeArticleRecord.slice(offSetSart, offSetEnd);
    }
}