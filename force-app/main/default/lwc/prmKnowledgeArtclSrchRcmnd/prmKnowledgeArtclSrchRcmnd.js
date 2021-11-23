/*
Modified By : Team Hawaii
Date : 5 - August -2020
Jira No: P20B - 8030
Description: show articles based on categories and different attributes of component
Version        Jira            Modified Date            By               Description  
1              P2OB-9098       28 August                Hawaii           Change references of variable,due to change in wrapper class
2              P2OB-8034/8035  28 August                Hawaii           Get excluded categories to generate correct urls
3              P2OB-9098       04 September             Hawaii           Conditionally display filter component 
4              P2OB-12539      10 March 2021            Hawaii           Single tile recommendation functionality
*/

import { LightningElement, track, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//import categoryLandingUrl from '@salesforce/label/c.PRMCategoryLandingUrl';
import getBaseURL from '@salesforce/apex/salesup_ThankYouScreenController.returnBaseUrl';
import getExcludedCategory from '@salesforce/apex/prmArticleDetail.getExcludedCategories';
import { reduceErrors } from 'c/ldsUtils';
export default class PrmKnowledgeArtclSrchRcmnd extends NavigationMixin(LightningElement) {
    // variable to get data from parent component.This variable determine which records need to show on UI
    @api knowledgeArticleList;
    // P20B - 9098 - As title is moved to parent component this value is only passed from 'pRMknowledgeArticleSearch' component
    @api titleString;
    // input variable to get value of attribute to display category
    @api displayCategory = false;
    // number of articles as input from parent
    @api numberOfArticle;
    // complete record list from parent
    @api cloneKnowledgeArticleRecordFromParent;
    //default page size 
    page = 1;
    // total records from server as input from parent component
    @api totalRecords;
    //total pages from parent component
    @api totalPages;
    // variable to store display view as input
    @api displayView;
    // sort article as input from parent
    @api sortArticles;
    // boolean value as input to show view all button
    @api navigateUsingViewAll;
    // name of category
    @api categoryName;
    //boolean value as input to show/hide category name at top
    @api showCategoryAtTop;
    //boolean value as input to show single tile
    @api isPartnerSalesNewsletter;
    //This variable identify if we need to show paggination or not
    @api isPagination = false;
    //list of excluded categories
    @track excludedCategoriesList = [];
    count = 0;
    // P2OB - 9098 - Show filter option if the value is true
    @api showFilter = false;
    // P2OB - 9098 - parent category From event
    @api categoryFromEvent = '';
    //P2OB-12539 : Allow Recommendation
    @api isAllowRecommendation = false;
    //P2OB-12539 : check if data is got from server then only fire renderedcallback
    @api isLoaded = false;
    baseURL; // DIGI-15298

    // identify which component needs to render like single tile,pagination or carousel
    get displayCarouselSection(){
        if(this.isPartnerSalesNewsletter){
            return false;
        }else if(this.isPagination){
            return false;
        }else{
            return true;
        }
    }

    connectedCallback(){
        //P2OB-8034/8035 : get excluded categories
        this.getExcludedCategoriesFromMetadata();
        // DIGI-15298 : adding baseurl invocation to get base url dunamically across all environments
        getBaseURL()
        .then(result => {
            this.baseURL = result+'/s/category-landing';
            console.log('*****base url*****'+this.baseURL);
        })
        .catch(error => {
        });
    }

    // Call apex to get excluded categories list 
    getExcludedCategoriesFromMetadata(){
        getExcludedCategory().then(result =>{
            if(result){
                this.excludedCategoriesList = result;
            }
          })
          .catch(error => {
                this.errors = reduceErrors(error); // code to execute if the promise is rejected
        });
    }

    //options for sorting
    get options() {
        return [
                 {label: 'Recently Posted', value: 'LastPublishedDate'},
                 {label: 'Title', value: 'Title'},
        ];
    }

    //show/hide view all based on condition
    get displayViewAll(){
        return (this.displayView == 'ViewAll' && this.totalRecords > this.numberOfArticle && this.knowledgeArticleList.length < this.cloneKnowledgeArticleRecordFromParent.length) ? true : false;
    }

    //show/hide carousel
    get displayCarousel(){
        return this.displayView == "Carousel" ? true : false; 
    }

    //show/hide right carousel
    get showRightCarousel(){
        if(this.page < this.totalPages){
            return true;
        }
        return false;
    }

    //show/hide left carousel
    get showLeftCarousel(){
        if(this.page > 1){
            return true;
        }
        return false;
    }

    //P2OB-12539 : Fire on click of visual indicator
    openRecomendedArticle = (event) => {
        event.preventDefault();
        //get current target
        let clickElement = event.currentTarget.dataset.rec;
        this.page = parseInt(clickElement)+1;
        //Highlight visual indicator
        this.highlightVisualIndicator(this.page);
        //display highlighted tile
        this.handleArticleChange();
    }

    //show/hide category at top
    get categoryAtTop(){
        return this.showCategoryAtTop;
    }

    //show/hide article results
    get isArtlclResult() {
        return this.knowledgeArticleList.length > 0;
    }

    get keyCount() {
        return this.count++;
    }

    //show/hide category
    get displayCategotyName(){
        return this.displayCategory;
    }

    //show/hide single tile
    get displaySingleTile(){
        return this.isPartnerSalesNewsletter;
    }

    // action on next button of carousel
    nextArticles(){
        if(this.page < this.totalPages){
            this.page = parseInt(this.page) + 1;
            //P2OB-12539 : highlight visual indicator on click of next
            //Start
            if(this.isAllowRecommendation){
                this.highlightVisualIndicator(this.page);
            }
            //END
            this.handleArticleChange();
        }    
    }

    // action on previous button of carousel
    previousArticles(){
        if(this.page > 1){
            this.page = this.page - 1;
            //P2OB-12539 : Highlight visual indicator on click of previous
            //Start
            if(this.isAllowRecommendation){
                this.highlightVisualIndicator(this.page);
            }
            //END
            this.handleArticleChange();
        }
    }

    //P2OB-12539 : Visual indicator Method to add class on selected indicator
    highlightVisualIndicator(pageNum){
        //get dom element
        let liElement = this.template.querySelectorAll('.visualIndicator a li');
        if(liElement){
            for(var i=0;i<Array.from(liElement).length;i++){
                //Add class to matched element
                if(pageNum == parseInt(i+1)){
                    Array.from(liElement)[i].classList.add('tab-selected');
                //remove class from remaining element
                }else{
                    Array.from(liElement)[i].classList.remove('tab-selected');
                }
            }
        }
    }

    //display all articles 
    showAllArticles = (event) => {
        event.preventDefault();
        this.knowledgeArticleList = this.cloneKnowledgeArticleRecordFromParent;
    }

    //navigate to category landing page
    navigateToCategoryLandingPage = (event) => {
        event.preventDefault();
        if(this.categoryName != undefined){
            //window.location.href = categoryLandingUrl + '?categoryName='+this.categoryName+'&defaultFieldValues='+this.categoryName+','+this.categoryName; // DIGI-15298 OLD CODE
            window.location.href = this.baseURL + '?categoryName='+this.categoryName+'&defaultFieldValues='+this.categoryName+','+this.categoryName; // DIGI-15298
        }
    }

    //sorting event call based on sort value change
    handleChange(event) {
        this.value = event.detail.value;
        this.dispatchEvent(new CustomEvent('sorting', {
            detail: this.value
        }));
    }

    //P2OB-9098 - Handle event fired from prmKnowledgeFilterComponent to update list and render component
    handleEvent = (event) => {
        this.knowledgeArticleList = event.detail;
    }
    
    //action on read more click
    handleReadMore = (event) => {
        event.preventDefault();
        //check if category is excluded or not
        let topCategory = event.target.dataset.category != undefined && this.excludedCategoriesList.length > 0 && this.excludedCategoriesList.includes(event.target.dataset.category) ? event.target.dataset.category : 'All';
        let articleCategory = event.target.dataset.name != undefined ? event.target.dataset.name : '';
        this[NavigationMixin.Navigate]({
            type: 'standard__knowledgeArticlePage',
            attributes: {
                urlName: event.target.dataset.id
            },
            state: {
                defaultFieldValues : (topCategory !=undefined && articleCategory != undefined ? topCategory+','+articleCategory : '')
            }

        });
    }

    //update knowledgeArticleList to render component based on new values 
    handleArticleChange = () => {
        let offSetSart = (this.page - 1) * this.numberOfArticle;
        let offSetEnd =  this.page * this.numberOfArticle;
        this.knowledgeArticleList = this.cloneKnowledgeArticleRecordFromParent.slice(offSetSart, offSetEnd);
    }


    ////P2OB-12539 : Added rendered callback method to highlight first li elemnt in visual indicator class element 
    renderedCallback(){
        //if is loaded false then return
        if(!this.isLoaded) return;
        //if data is available highlight the li element
        if(this.isLoaded){
            let liElement = this.template.querySelectorAll('.visualIndicator a li');
            if(liElement){
                for(var i=0;i<Array.from(liElement).length;i++){
                    //add class to first element
                    Array.from(liElement)[i].classList.add('tab-selected');
                    break;
                }
                this.isLoaded = false;
            }
        }
    }
}