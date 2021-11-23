import { LightningElement, api, track } from 'lwc';
import getArticleDetail from '@salesforce/apex/PRMEventDetailsContr.getArticleDetail';
import { reduceErrors } from 'c/ldsUtils';

export default class PrmEventDetails extends LightningElement {

    //Get Article record Id from Parent Component
    @api getIdFromParent;
    //Get record from parent
    @api getRecord;
    //Get category from frontend
    @api category;
    //Show Image based on component property
    @api showImage;
    //Show component at all?
    @track showComponent;
    //Get sObject Name from FrontEnd;
    @api sobjectName = '';
    //Article Detail
    @track articleDetail;
    //ImageUrl from static resource
    @track imageUrl;
    //Sobject detail
    @track SobjectDetail = [];
    //Show Caetegory
    @track isCategoryShow = true;
    //User TimeZone
    @track userTimeZone;
    //Result found or not
    //@track isArtclResult;

    connectedCallback() {
        this.getCategories();
    }

    //Call server side controller to get record details
    getCategories() {
        getArticleDetail({ articleDetailId: this.getIdFromParent, sObj: this.sobjectName }).then(result => {
            if (result) {
                if(this.getIdFromParent == null){
                    this.articleDetail = this.getRecord;
                }
                else{
                    this.articleDetail = result.articleDetail;
                }
                var receivedMap = result.fieldDetailsList;
                this.userTimeZone = result.userTimeZone;

                //Show Image on the component
                if (this.articleDetail.Featured_Image__c && this.showImage != false) {
                    this.showImage = true;
                    this.imageUrl = this.articleDetail.Featured_Image__c;
                }
                //Populate article category
                if (this.sobjectName == 'Knowledge__kav' && this.isCategoryShow && this.articleDetail.DataCategorySelections != undefined && this.articleDetail.DataCategorySelections.length > 0) {
                    let cateObj = new Object();
                    cateObj.fieldLabel = 'Category';
                    cateObj.finalValue = this.articleDetail.DataCategorySelections[0].DataCategoryName;
                    cateObj.isLabelShow = true;
                    this.SobjectDetail.push(cateObj);
                }
                //Populate object with formatting based on various field types from Metadata 
                for (let j = 0; j < receivedMap.length; ++j) {
                    let obj = new Object();
                    obj.fieldLabel = receivedMap[j].fieldLabel;
                    obj.isDateFormatted = receivedMap[j].isDateFormatRequired;
                    obj.isButton = receivedMap[j].isButton;
                    obj.fieldDetails = new Object();

                    if (!obj.isDateFormatted && !obj.isButton) {
                        obj.finalValue = '';
                        for (let i = 0; i < receivedMap[j].fieldAPINames.length; ++i) {
                            //obj.finalValue += this.articleDetail[receivedMap[j].fieldAPINames[i]] + ', ';
                            obj.finalValue += (this.articleDetail[receivedMap[j].fieldAPINames[i]] == undefined) ? '' : this.articleDetail[receivedMap[j].fieldAPINames[i]] + ', ';
                        }
                    } else if (obj.isDateFormatted) {
                        if (receivedMap[j].fieldAPINames.length > 0) {
                            obj.fieldDetails.stDate = (this.articleDetail[receivedMap[j].fieldAPINames[0]] == undefined) ? '' : this.articleDetail[receivedMap[j].fieldAPINames[0]];
                        }
                        if (receivedMap[j].fieldAPINames.length > 1) {
                            obj.fieldDetails.conChar = ' to ';
                            obj.fieldDetails.endDate = (this.articleDetail[receivedMap[j].fieldAPINames[1]] == undefined) ? '' : this.articleDetail[receivedMap[j].fieldAPINames[1]];
                        }

                    } else if (obj.isButton && receivedMap[j].fieldAPINames.length > 0) {
                        obj.finalValue = (this.articleDetail[receivedMap[j].fieldAPINames[0]] == undefined) ? '' : this.articleDetail[receivedMap[j].fieldAPINames[0]];
                        
                    }
                    
                    //Remove last comma from the string
                    if(obj.finalValue !== undefined){
                        obj.finalValue = obj.finalValue.trim();
                        let lastChar = obj.finalValue.slice(-1);
                        if(lastChar == ',') {
                            obj.finalValue = obj.finalValue.slice(0, -1);
                        }
                        
                    }
                    //If Label value is undefined, dont add it to the object
                    if((obj.finalValue !== null && obj.finalValue !== "" && obj.finalValue !== undefined) 
                    || obj.fieldDetails.stDate != undefined){
                        obj.isLabelShow = true;
                    }
                    
                    this.SobjectDetail.push(obj);
                }

            }
        }).catch(error => {
            this.errors = reduceErrors(error); // code to execute if the promise is rejected
        });
    }

}