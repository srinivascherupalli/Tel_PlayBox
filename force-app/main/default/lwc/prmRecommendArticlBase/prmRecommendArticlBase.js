import { LightningElement, wire, track } from 'lwc';
import getKnowldegeArticleRecomendedData from '@salesforce/apex/PRMOffersCarousel.getKnowldegeArticleRecomendedData';

export default class PrmRecommendArticlBase extends LightningElement {

    @track error;

    @track knowledgeArticleRecord = [];


    @wire(getKnowldegeArticleRecomendedData)
    knowledgeArticleData({ error, data }) {
        if (data) {
            this.knowledgeArticleRecord = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.knowledgeArticleRecord = [];
        }
    }

}