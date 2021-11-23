/*
Modified By : Team Hawaii
Date : 22/7/2020
Jira No : P20B-7462
Description: This component shows articled associated to child category
JIRA No : P2OB-8611 - Hawaii - 08/08/2020

*/
import { LightningElement,track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class prmKArticleChildAccord extends NavigationMixin(LightningElement) {

    //Child Category Label
    @api childCategoryLabel;
    //list :  category as key and article as value
    @api knowledgeArticleData;
    //Child Category Name
    @api childCategoryName;
    //list of child article to be displayed
    @track knowledgeArticleDetails = [];
    //  P2OB-8369 - parent Categroy Name
    @api parentCateName;
    
    
    connectedCallback(){
        /* when child category matches with category where article is present it stores detail of that article 
        on  'knowledgeArticleDetails' and displaces those article on UI */
		if(this.knowledgeArticleData.key == this.childCategoryLabel){
			this.knowledgeArticleDetails.push({key:this.knowledgeArticleData.key,value:this.knowledgeArticleData.value});
        }
        
	}

    //on click of article it opens article detail page
    showArticleDetail = (event) => {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
          type: 'standard__knowledgeArticlePage',
          attributes: {
            urlName: event.target.dataset.id
          },
          state: {
            defaultFieldValues : this.parentCateName + ',' + event.target.dataset.name
          }
        });
    }
}