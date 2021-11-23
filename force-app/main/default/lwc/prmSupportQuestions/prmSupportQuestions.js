/*
Modified By : Team Hawaii
Date : 28-August-2020
Jira No: P20B - 9098
Description: Changes in wrapper class 'PRMCarouselWrapper'.Added sobject variable in wrapper class.
Version        Jira       Modified Date            By               Description    
*/
import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getSupportQuestionArticleCategory from '@salesforce/apex/prmArticleDetail.getSupportQuestionArticleCategory';
export default class PrmSupportQuestions extends NavigationMixin(LightningElement) {

    @track knSupportQuestion = [];
    @track error;

    parameters = '';

    @wire(getSupportQuestionArticleCategory, { categoryName: '$parameters' })
    areticleSupportQuestion({ error, data }) {
        if (data) {
            console.log('parameter value is'+this.parameters);
            this.knSupportQuestion = data;
        } else {
            this.error = error;
            this.knSupportQuestion = [];
        }
    }

    connectedCallback() {
        this.parameters = this.getQueryParameters();
    }

    getQueryParameters() {
        var params = (new URL(window.location.href)).searchParams;
        return params.get("categoryName") != undefined && params.get("categoryName") != null ? params.get("categoryName") : '';
    }

    handleReadMore = (event) => {

        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__knowledgeArticlePage',
            attributes: {
                urlName: event.target.dataset.id
            }
        });

    }

    get hasRecord() {
        return this.knSupportQuestion.length > 0;
    };
}