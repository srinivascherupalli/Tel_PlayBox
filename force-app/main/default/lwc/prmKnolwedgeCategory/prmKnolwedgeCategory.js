/*
Modified By : Team Hawaii
Date : 24/7/2020
Jira No: P20B - 8101
Description: Sorted article on the basis of last published date field
Version        Jira           Modified Date            By               Description    
1             P2OB-8030       05/08/2020            Team Hawaii         Made this component generic so that it can be used at multiple places 
2             P2OB-8030       06/08/2020            Team Hawaii         Remove separate search logic
3             P2OB-8034/8035  28 August             Team Hawaii         Change references of variable,due to change in wrapper class
4             P2OB-9098       04/09/2020            Team Hawaii         Added new design attributes to conditionally show and hide filter component
5             P2OB-9098       05/09/2020            Team Hawaii         Added new method topLevelCategory to get top category name this variable is used to get custom metadata record based on category name.
6             P2OB-12539      10/3/2020             Team Hawaii         Single tile recommendation functionality
*/
import { LightningElement, track, wire, api } from 'lwc';
import getArticleCategory from '@salesforce/apex/prmArticleDetail.getArticleCategory';
import orderByLastPublishedDate from '@salesforce/label/c.PRMSortOrderLastPublishedDate';
import orderByTitle from '@salesforce/label/c.PRMSortOrderForTitle';
import pubsubEvent from 'c/prmPubSub' ; 
import { reduceErrors } from 'c/ldsUtils';
export default class PrmKnolwedgeCategory extends LightningElement {

   // design property to store api name of field, by which article needs to sort
   @api sortArticleBy;
   // design property to store sort article order,it value should be Desc/Asc.
   @api sortArticlesByOrder; 
   // design property to store number of articles to be displayed on UI.
   @api numberOfArticlesToBeDisplayed;
   // design property to store display format,it value should be ViewAll/Carousel
   @api displayFormat;
   // if checked search component will be visible on ui.
   @api isSearchAllowed;
   // Top Category Name
   @api parentCategoryName;
   // if checked it will show category name at top
   @api showCategoryNameAtTop;
   // Label to be display instead of top category label 
   @api labelofTopCategory='';
   // if checked it will show category name inside tile
   @api displayCategoryName;
   // if checked,View All button will be visible which will navigate to category landing page
   @api navigateToCategoryLanding;
   // if checked,give sort option on UI
   @api showSortOptions;
   //if checked it will display single tile structure
   @api showSingleTile;
   // if checked it will fetch article associated with child categories as well
   @api fetchChildArticles = false;
   // Maximum number of articles to be retrieved from server
   @api maximumNumberOfArticle = '';
   // Number of articles to be displayed
   @track knowledgeArticleRecord = [];
   // Total number of articles retrieved from server
   cloneKnowledgeArticleRecord = [];
   //Name of search string
   searchString = '';
   // Category Name from Top category/url
   categoryName = '';
   //Total record retrieved from server
   totalRecords;
   categoryValuesFromEvent = {};
   @track topCategoryFromEvent = '';
   // P2OB - 9098 - Added design parameter to show filter component
   @api showFilterOptions = false;
   //P2OB-12539 : page name
   @api publishPageName = '';
   //P2OB-12539 : display in recommendation view
   @api allowRecommendation = false;
   //P2OB-12539 : Boolean variable to check if data is available
   @track isLoaded=false;


    //call this method at start
    connectedCallback(){
        //subscribe pub sub event to get top category value to display on category landing page
        this.register();
        var params = (new URL(window.location.href)).searchParams;
        this.categoryName = this.parentCategoryName != '' ? this.parentCategoryName : params.get("categoryName");
        //get data from server side
        this.getArticles();
    }

    disconnectedCallback() {
        pubsubEvent.unregisterAllListeners(this);
    }

    //register event
    register(){
        pubsubEvent.registerListenerwithURL('KArticleLevels',this.handleEvent,this,window.location.href);
    }

    //store category value in categoryValuesFromEvent variable
    handleEvent(component,message){
        console.log('message value is'+JSON.stringify(message));
        this.categoryValuesFromEvent = message;
        //P2OB-9098 - Get top category name for filter functionality
        this.topLevelCategory(this.categoryValuesFromEvent);
    }

    topLevelCategory(categoryValues){
        if(categoryValues.hasOwnProperty('category1') && categoryValues['category1'] != undefined && categoryValues['category1'] != ''){
            this.topCategoryFromEvent = categoryValues['category1'];
            console.log('this.topCategoryFromEvent value is'+this.topCategoryFromEvent);
        }
    }

    //get recommendation value
    get recommendationAllowed(){
        return this.allowRecommendation;
    }

    // Call apex to get article 
    getArticles(){
        //P2OB-12539 : Pass additional parameters to apex method (publishPageName,allowRecommendation)
        getArticleCategory({searchString : this.searchString,categoryName: this.categoryName,retrieveChildArticle : this.fetchChildArticles,displayFormat : this.displayFormat,numberOfArticles : parseInt(this.maximumNumberOfArticle),sortBy : this.sortArticleBy,orderBy : this.sortArticlesByOrder,publishPageName:this.publishPageName,allowRecommendation:this.allowRecommendation}).then(result =>{
            if(result){
                this.knowledgeArticleRecord = result;
                this.cloneKnowledgeArticleRecord = this.knowledgeArticleRecord;
                this.totalRecords = this.knowledgeArticleRecord.length;
                this.totalPages = Math.ceil(this.totalRecords.toString()/this.numberOfArticlesToBeDisplayed.toString());
                this.handlePaggination();
                //P2OB-12539 : Set boolean variable value
                this.isLoaded = true;
             }
          })
          .catch(error => {
            this.errors = reduceErrors(error); // code to execute if the promise is rejected
            this.knowledgeArticleRecord = [];
        });
    }

    //handle search change loic
    handleSearchTermChange = (event) => {
        // Debouncing this method: do not update the reactive property as
        // long as this function is being called within a delay of 300 ms.
        // This is to avoid a very large number of Apex method calls.

        window.clearTimeout(this.delayTimeout);
        this.searchString = event.target.value;
        if (this.searchString === '') {
            //P2OB-12539 : Pass additional parameters to apex method (publishPageName,allowRecommendation)
            getArticleCategory({searchString : this.searchString,categoryName: this.categoryName,retrieveChildArticle : this.fetchChildArticles,displayFormat : this.displayFormat,numberOfArticles : parseInt(this.maximumNumberOfArticle),sortBy : this.sortArticleBy,orderBy : this.sortArticlesByOrder,publishPageName:this.publishPageName,allowRecommendation:this.allowRecommendation})
                .then(result => {
                    //P2OB-8101 : This function sort article by descending order
                    this.cloneKnowledgeArticleRecord = result;
                    this.totalRecords = this.cloneKnowledgeArticleRecord.length;
                    this.totalPages = Math.ceil(this.totalRecords.toString() / this.numberOfArticlesToBeDisplayed.toString());
                    this.handlePaggination();
                    
                })
                .catch(error => {
                    this.error = error;
                    this.knowledgeArticleRecord = [];
                });

            return;
        }else if (this.searchString.length < 3) {
            this.knowledgeArticleRecord = [];
            this.totalRecords = 0;
            this.totalPages = 0;
            return;
        }
        this.delayTimeout = setTimeout(() => {
            this.getArticles();
        }, 300);
    }

    //get display format value
    get displayFormatArticle(){
       return this.displayFormat
    }
   
    //get display category value
    get displayCategory(){
       return this.displayCategoryName;
    }

    //show category name at top
    get categoryNameAtTop(){
        return this.showCategoryNameAtTop;
    }
   
    //get cateory label
    get categoryLabel(){
        if(this.labelofTopCategory != ''){
            return  this.labelofTopCategory;
        // get the value of the variable categoryValuesFromEvent from pub sub event fired from accord component and based on the values display label
        }else if(Object.keys(this.categoryValuesFromEvent).length !== 0){
			if(this.categoryValuesFromEvent.hasOwnProperty('category5') && this.categoryValuesFromEvent['category5'] != undefined && this.categoryValuesFromEvent['category5'] != ''){
				return this.categoryValuesFromEvent['category5'];
			}
			else if(this.categoryValuesFromEvent.hasOwnProperty('category4') && this.categoryValuesFromEvent['category4'] != undefined && this.categoryValuesFromEvent['category4'] != ''){
				return this.categoryValuesFromEvent['category4'];
			}else if(this.categoryValuesFromEvent.hasOwnProperty('category3') && this.categoryValuesFromEvent['category3'] != undefined && this.categoryValuesFromEvent['category3'] != ''){
				return this.categoryValuesFromEvent['category3'];
			}else if(this.categoryValuesFromEvent.hasOwnProperty('category2') && this.categoryValuesFromEvent['category2'] != undefined && this.categoryValuesFromEvent['category2'] != ''){
				return this.categoryValuesFromEvent['category2'];
			}else if(this.categoryValuesFromEvent.hasOwnProperty('category1') && this.categoryValuesFromEvent['category1'] != undefined && this.categoryValuesFromEvent['category1'] != ''){
                return this.categoryValuesFromEvent['category1'];
			}
		}else{
			return (this.knowledgeArticleRecord.length > 0 ? this.knowledgeArticleRecord[0].categoryLabel : '');
		}
	}

    //get number of articles to be diplayed
    get numberOfArticles(){
        return this.numberOfArticlesToBeDisplayed;
    }

    //get sort option checkbox value
    get sortOptions(){
        return this.showSortOptions;
    }

    //get navigate to category landing page checkbox value
    get viewAllNavigation(){
        return this.navigateToCategoryLanding;
    }

    //get cateory name
    get parentCategory(){
        return this.categoryName;
    }

    //handle paggination to show articles based on condition
    handlePaggination = () => {

        let offSetSart = 0;
        // P2OB-12539 : Bypass single tile logic when allowRecommendation is true 
        //show single tile when showSingleTile checkbox is true
        if(this.showSingleTile && !this.allowRecommendation){
            let offSetEnd = 1;
            this.knowledgeArticleRecord = this.cloneKnowledgeArticleRecord.slice(offSetSart, offSetEnd);
        }else{
            let offSetEnd =  this.numberOfArticlesToBeDisplayed != "" ? this.numberOfArticlesToBeDisplayed : this.cloneKnowledgeArticleRecord.length;
            this.knowledgeArticleRecord = this.cloneKnowledgeArticleRecord.slice(offSetSart, offSetEnd);
        }
    }

    //This function sort article by descending order
	sortArrayByDesc(array, key) {
        return array.sort(function (a, b) {
           //P2OB-8034/8035 - Change in reference variable
           var x = a["sobjectRecord"][key]; var y = b["sobjectRecord"][key];
           return ((x > y) ? -1 : ((x < y) ? 1 : 0));
        });
    } 

    //This function sort article by Ascending order
    sortArrayByAsc(array, key) {
        return array.sort(function (a, b) {
            //P2OB-8034/8035 - Change in reference variable
            var x = a["sobjectRecord"][key]; var y = b["sobjectRecord"][key];
            return ((x < y) ? -1 : ((x > y) ? 1 : 0));
        });
    }

    handleSortArticle = (event) => {
        this.sortBy = event.detail;
        //sort article based on user input
        //P2OB-8034/8035 - Change in reference variable name
		if(this.sortBy == 'LastPublishedDate'){
            //sort articles in descending order
			if(orderByLastPublishedDate == 'Descending'){
				this.cloneKnowledgeArticleRecord = this.sortArrayByDesc(this.cloneKnowledgeArticleRecord.slice(),this.sortBy);
			}else{
                //sort article in ascending order
				this.cloneKnowledgeArticleRecord = this.sortArrayByAsc(this.cloneKnowledgeArticleRecord.slice(),this.sortBy);
            }
        //sort article based on title
        //P2OB-8034/8035 - Change in reference variable name
        }else if(this.sortBy == 'Title'){
            //sort article in ascending order
			if(orderByTitle == 'Ascending'){
				this.cloneKnowledgeArticleRecord = this.sortArrayByAsc(this.cloneKnowledgeArticleRecord.slice(),this.sortBy);
			}else{
				this.cloneKnowledgeArticleRecord = this.sortArrayByDesc(this.cloneKnowledgeArticleRecord.slice(),this.sortBy);
			}
        }
        this.totalrecords = this.cloneKnowledgeArticleRecord.length;
        this.totalPages = Math.ceil(this.totalrecords.toString() / this.numberOfArticlesToBeDisplayed.toString());
        this.handlePaggination();
    }
}