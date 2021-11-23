/*
Modified By : Team Hawaii
Date : 22/7/2020
Jira No: P20B - 7462
Description: This component contain all logic to display Category hierarchy
Modifications : 
1. 10-08-2020 : Team Hawaii : Ritika Jaiswal : P2OB-7583 - To pass Category-levels for selected-article
*/
import { LightningElement, track, wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
//import categoryLandingUrl from '@salesforce/label/c.PRMCategoryLandingUrl';
import getBaseURL from '@salesforce/apex/salesup_ThankYouScreenController.returnBaseUrl';
import getCategoryGroup from '@salesforce/apex/PRMOffersCarousel.getCategoryList';
import getCategoryArticleMap from '@salesforce/apex/PRMOffersCarousel.getArticleList';
import getCategoryFromArticleUrl from '@salesforce/apex/PRMOffersCarousel.getArticleCategory';
import { reduceErrors } from 'c/ldsUtils';
import prmpubsub from 'c/prmPubSub' ;
export default class prmKArticleAccord extends NavigationMixin(LightningElement) {
  
  //List - store top category as key and value as associated article
  @track parentCategoryArticleList = [];
  
  //List - store category as key and value as associated article
  @track categoryGroupArticleList = [];
  
  //Map - map of category and article
  @track categotyGroupArticleMap = new Map();
  
  //variable to store error
  @track errors;
  
  //configurable property set in Community Builder
  @api sortArticlesBy = '';
  
  //configurable property set in Community Builder
  @api sortArticlesByOrder = '';
   
  //object to store open categories
  @track levelOpenCategory = new Object();
  @track isSelectedLevelOpen = new Object();
  //P2OB-8369 - Hawaii - Added variables for Parent Categroy Reference
  @api parentCategoryName = '';
  @api showParent = false;
  @api parentCategoryFromURL;
  @wire(CurrentPageReference)
  pageRef;
  parameters;
  
  // name of category taken from url to decide which section to be open on component render
  @track categoryName;
  baseURL; // DIGI-15298

    connectedCallback(){
      getBaseURL()
        .then(result => {
            this.baseURL = result+'/s/category-landing';
            console.log('*****base url*****'+this.baseURL);
        })
        .catch(error => {
        });

      var params = (new URL(window.location.href)).searchParams;
      this.categoryName = params.get("categoryName");  
    //P2OB-8369 - getting the Parent Category from URL
      this.parentCategoryFromURL = params.get("defaultFieldValues"); 
      
	    //When component renders on article detail page
      if(this.parentCategoryFromURL == null || this.parentCategoryFromURL == undefined){
        this.parentCategoryFromURL = this.parentCategoryName;
      }else{
          this.parentCategoryFromURL = decodeURI(this.parentCategoryFromURL);
          console.log('::this.parentCategoryFromURL >>1>>'+this.parentCategoryFromURL);
          if(this.parentCategoryFromURL.indexOf(',') >= 0){
              
              var defaultParam = this.parentCategoryFromURL.split(',');
              if(defaultParam.length > 0){
                  this.parentCategoryFromURL = defaultParam[0];
      }
              if(defaultParam.length > 1){
                  this.categoryName = defaultParam[1];
              }
            }
      }
      
	    //When component renders on category landing page 
      if(this.categoryName != null && this.categoryName != undefined){          
          this.categoryName = decodeURI(this.categoryName);  
          this.CategoryArticleMap();
         // this.categoryGroup();
      }else{ 
          
		    //when component renders on article page but through recommended/trending article
        var articleUrl = this.getQueryParameters();   
        this.getCategory(articleUrl);      
      }
      
    }
	
	  // this function get article urlname from url
    getQueryParameters() {
      let search = window.location.pathname.split('/');
      return search.length > 0 ? search[search.length - 1] : '';
    }
	//this function calls apex method to get category associated to an article
  getCategory(articleUrl){
    getCategoryFromArticleUrl({urlName:articleUrl}).then(result =>{
        var categoryResponse = JSON.parse(result);
        if(categoryResponse){
          this.parentCategoryFromURL = categoryResponse.topCategoryName;
          this.categoryName = categoryResponse.categoryName;
        }
        this.CategoryArticleMap();
      })
	  .catch(error => {
        this.errors = reduceErrors(error); // code to execute if the promise is rejected
    });
  }
	//this function calls apex to get all category and related article
	CategoryArticleMap(){
	  getCategoryArticleMap().then(result => {
      if (result) {
        for (let [key, articleList] of Object.entries(result)) {
		      //store key value from apex into map
          this.categotyGroupArticleMap.set(key,articleList);
		      //Check if article to be sort by ascending order
          if(this.sortArticlesByOrder === 'Ascending'){
            var value = this.sortArrayByAsc(articleList.slice(),this.sortArticlesBy);
		      //Check if article to be sort by descending order
          }else if(this.sortArticlesByOrder === 'Descending'){
            var value = this.sortArrayByDesc(articleList.slice(),this.sortArticlesBy);
          }
		      //store values in key value format in list
          this.categoryGroupArticleList.push({
            key, value
          })
        }
        this.categoryGroup();  
      }
      
    })
	  .catch(error => {
                this.errors = reduceErrors(error); // code to execute if the promise is rejected
    });
  }
  
  //this function calls apex to get category hierarchy
  categoryGroup(){
    getCategoryGroup({parentCategoryName:this.parentCategoryFromURL, isShowParent : this.showParent}).then(result => {
        if (result) {
            var response = JSON.parse(result);
            this.popluateOpenCategories(response);
            for(var i=0;i < response.length;i++){
              if(this.categotyGroupArticleMap.has(response[i].label) && this.categotyGroupArticleMap.get(response[i].label) !== undefined){  
                if(this.sortArticlesByOrder === 'Ascending'){
                  var sortedArrayList = this.sortArrayByAsc(this.categotyGroupArticleMap.get(response[i].label).slice(),this.sortArticlesBy);
                }else if(this.sortArticlesByOrder === 'Descending'){
                  var sortedArrayList = this.sortArrayByDesc(this.categotyGroupArticleMap.get(response[i].label).slice(),this.sortArticlesBy);
                }
                  
                this.parentCategoryArticleList.push({key:response[i],value:sortedArrayList});
            
              }else{
                var val;
                if(response[i].childCategories != undefined && response[i].childCategories.length > 0){
                  val = [];
                }
                this.parentCategoryArticleList.push({key:response[i],value:val});
              }
	}
          }
    })
	  .catch(error => {
         this.errors = reduceErrors(error); // code to execute if the promise is rejected
     });
  }

	//this function sets value of levelOpenCategory object. levelOpenCategory is used to determine which accordian should be open
	popluateOpenCategories(categoryList){
		for(var i=0;i < categoryList.length;i++){ // level 1
			//when category is at top then open top category
			if(categoryList[i].name == this.categoryName){ 
        this.levelOpenCategory.level1OpenCategory = categoryList[i].name;
        this.levelOpenCategory.level1OpenCategoryLabel = categoryList[i].label;
			  break;
			} // if
			if(categoryList[i].childCategories != undefined && categoryList[i].childCategories.length > 0){ // level 2
				for(var j=0; j < categoryList[i].childCategories.length;j++){
					var level1Category = categoryList[i].childCategories[j];
					//when category is 1st child then open top category and 1 st child category 
					if(level1Category.name == this.categoryName){
						this.levelOpenCategory.level2OpenCategory = level1Category.name;
            this.levelOpenCategory.level1OpenCategory = categoryList[i].name;
            
            this.levelOpenCategory.level2OpenCategoryLabel = level1Category.label;
						this.levelOpenCategory.level1OpenCategoryLabel = categoryList[i].label;

						break;
					} // level 2 if
					if(level1Category.childCategories != undefined && level1Category.childCategories.length > 0){ // level 3
						for(var k=0; k < level1Category.childCategories.length;k++){
							var level2Category = level1Category.childCategories[k];
							//when category is 2nd child then open top category,1 st child category and 2nd child category
							if(level2Category.name == this.categoryName){
								this.levelOpenCategory.level3OpenCategory = level2Category.name;
								this.levelOpenCategory.level2OpenCategory = level1Category.name;
                this.levelOpenCategory.level1OpenCategory = categoryList[i].name;
                
                this.levelOpenCategory.level3OpenCategoryLabel = level2Category.label;
								this.levelOpenCategory.level2OpenCategoryLabel = level1Category.label;
                this.levelOpenCategory.level1OpenCategoryLabel = categoryList[i].label;

								break;
							 } // level 3 if
							if(level2Category.childCategories != undefined && level2Category.childCategories.length > 0){ // level 4
								for(var l=0; l < level2Category.childCategories.length;l++){
									var level3Category = level2Category.childCategories[l];
									//when category is 3rd child then open top category,1 st child category, 2nd child category and 3 rd Child category
									if(level3Category.name == this.categoryName){
										this.levelOpenCategory.level4OpenCategory = level3Category.name;
										this.levelOpenCategory.level3OpenCategory = level2Category.name;
										this.levelOpenCategory.level2OpenCategory = level1Category.name;
                    this.levelOpenCategory.level1OpenCategory = categoryList[i].name;
                    
                    this.levelOpenCategory.level4OpenCategoryLabel = level3Category.label;
										this.levelOpenCategory.level3OpenCategoryLabel = level2Category.label;
										this.levelOpenCategory.level2OpenCategoryLabel = level1Category.label;
                    this.levelOpenCategory.level1OpenCategoryLabel = categoryList[i].label;  


										break;
									} // level 4 if
									if(level3Category.childCategories != undefined && level3Category.childCategories.length > 0){ // level 5
										for(var m=0; m < level3Category.childCategories.length;m++){
											var level4Category = level3Category.childCategories[m];
											//when category is 4th child then open top category,1 st child category, 2nd child category,3 rd Child category and 4th child category
											if(level4Category.name == this.categoryName){
												this.levelOpenCategory.level5OpenCategory = level4Category.name;
												this.levelOpenCategory.level4OpenCategory = level3Category.name;
												this.levelOpenCategory.level3OpenCategory = level2Category.name;
												this.levelOpenCategory.level2OpenCategory = level1Category.name;
                        this.levelOpenCategory.level1OpenCategory = categoryList[i].name;
                        
                        this.levelOpenCategory.level5OpenCategoryLabel = level4Category.label;
												this.levelOpenCategory.level4OpenCategoryLabel = level3Category.label;
												this.levelOpenCategory.level3OpenCategoryLabel = level2Category.label;
												this.levelOpenCategory.level2OpenCategoryLabel = level1Category.label;
                        this.levelOpenCategory.level1OpenCategoryLabel = categoryList[i].label;  
												break;
											} // level 5 if
										}// level 5 for
									}// level 5 child category if
								} // level 4 for
							}// level 4 child category if
						}// level 3 for
					}// level 3 child Category if
				} // level 2 for 
			}// level 2 child Category if
		}//level 1 for 
	}
    
	showArticleDetail = (event) => {
		event.preventDefault();
		this[NavigationMixin.Navigate]({
		  type: 'standard__knowledgeArticlePage',
		  attributes: {
			  urlName: event.target.dataset.id
		  },
		  state: {
			  defaultFieldValues : this.parentCategoryFromURL + ',' + event.target.dataset.name
		  }
		});
	}
	
	//P2OB-8101 : This function sort article by descending order
	sortArrayByDesc(array, key) {
	  return array.sort(function (a, b) {
         var x = a["Parent"][key]; var y = b["Parent"][key];
         return ((x > y) ? -1 : ((x < y) ? 1 : 0));
      });
	} 
   
	//P2OB-8101 This function sort article by Ascending order
	sortArrayByAsc(array, key) {
       return array.sort(function (a, b) {
           var x = a["Parent"][key]; var y = b["Parent"][key];
           return ((x < y) ? -1 : ((x > y) ? 1 : 0));
       });
	}
    renderedCallback(){
      
    }
	/* P2OB-7462 - click event on Level 1 */
	openLevel1Category(event){
    this.openCategoryRedirect(event.detail.openSections,this.levelOpenCategory.level1OpenCategory, 'level1');
    this.firePubSub();
	} 

	/* P2OB-7462 - click event on Level 2 */
	openLevel2Category(event){
    this.openCategoryRedirect(event.detail.openSections,this.levelOpenCategory.level2OpenCategory,'level2');
	}

	/* P2OB-7462 - click event on Level 3 */
	openLevel3Category(event){
    this.openCategoryRedirect(event.detail.openSections,this.levelOpenCategory.level3OpenCategory,'level3');
	}
  
	/* P2OB-7462 - click event on Level 4 */
	openLevel4Category(event){
    this.openCategoryRedirect(event.detail.openSections,this.levelOpenCategory.level4OpenCategory,'level4');
  }
	
	/* P2OB-7462 - click event on Level 5 */
	openLevel5Category(event){
    this.openCategoryRedirect(event.detail.openSections,this.levelOpenCategory.level5OpenCategory, 'level5');
	}

	/* P2OB-7462 - click event generic method */
	openCategoryRedirect(sectionDetails, openCategory,selectedLevel){
    var selectedItem;
    /*if(this.isSelectedLevelOpen[selectedLevel] == true){
        selectedItem = sectionDetails;
    }*/
    if(sectionDetails.length > 1){
        for(var i = 0 ; i< sectionDetails.length;i++){
          if(openCategory != sectionDetails[i]){
            selectedItem = sectionDetails[i];
          }
        }
    }else if((openCategory == undefined || this.isSelectedLevelOpen[selectedLevel] == true) && sectionDetails.length == 1){
        selectedItem = sectionDetails;
    }
    if(selectedItem != undefined && selectedItem != null && selectedItem != ''){
     //P2OB-8369 - added Parent Category in Parameter
      this.parentCategoryFromURL
      window.location.href = this.baseURL + '?categoryName='+selectedItem
          +'&defaultFieldValues='+this.parentCategoryFromURL; // DIGI-15298
    }
    this.isSelectedLevelOpen[selectedLevel] = true;
    
    
  }
    
  firePubSub(){
        //P2OB-7583 : Publish message for pubSub , message will include label of category-levels for selected-article 
        var path =  window.location.href;
        var urlParser = 'w*/article/w*?';
        var categoryLandingUrlParser = 'w*/category-landing?w*';
        var result = path.match(new RegExp(urlParser,'g'));
        var resultCategoryLandingUrl = path.match(new RegExp(categoryLandingUrlParser,'g'));
        if((result !== null && result !== '') || (resultCategoryLandingUrl != null && resultCategoryLandingUrl != '')){
          console.log('level open cate'+JSON.stringify(this.levelOpenCategory));
          let message = {
                "category1" : this.levelOpenCategory.level1OpenCategoryLabel,
                "category2" : this.levelOpenCategory.level2OpenCategoryLabel,
                "category3" : this.levelOpenCategory.level3OpenCategoryLabel,
                "category4" : this.levelOpenCategory.level4OpenCategoryLabel,
                "category5" : this.levelOpenCategory.level5OpenCategoryLabel
            }

            //P2OB-9099 : Hawaii
            setTimeout(function() {
              prmpubsub.fireEvent(window.location.href,'KArticleLevels', message );
            }, 1000);
            //prmpubsub.fireEvent(window.location.href,'KArticleLevels', message );
         }
         //P2OB-7583 :End
  }
}