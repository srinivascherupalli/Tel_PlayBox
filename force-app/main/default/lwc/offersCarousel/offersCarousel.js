/*******************************************************************
Created By          :   Garg / Ashish
Created Date        :   
Desc                :   This is LWC for show offer carousel on PRM portal

Date            Version             Modified By             Desc
7-August-2019        1              Ashish garg                                        
***********************************************************************/

import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getOfferCarouselData from '@salesforce/apex/PRMOffersCarousel.getOfferCarouselData';

export default class OffersCarousel extends NavigationMixin(LightningElement) {
    @track record = [];
    @track error;
    @track isKnowledgeArticle = false;

    slideCountNumber = 1;
    slideIndex = 1;// start slide index default from 1
    sliderInitialized = true;// it will prevent to call show slide before render dom.


    @api objectNameCarosule;
    @api recordNumberCarosule;

    // it will call apex method from controller to get data
    @wire(getOfferCarouselData, { objectName: "$objectNameCarosule", numberOfRecord: "$recordNumberCarosule" })
    wiredData({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
            this.sliderInitialized = false;//once the get data and dom render then we will call showSlide method from renderedCallback()
        } else if (error) {
            this.record = [];
            this.error = error;
        }
    }

    renderedCallback() {
        this.isKnowledgeArticle = this.objectNameCarosule === 'Knowledge Article' ? true : false;
        if (this.sliderInitialized) {
            return;
        }
        this.sliderInitialized = true;
        this.showSlides(this.slideIndex);// here we call showSlide after render dom
    }

    showSlides = (n) => {
        let i;
        let slides = this.template.querySelectorAll(".mySlides");
        let dots = this.template.querySelectorAll(".dot");
        if (n > slides.length) { this.slideIndex = 1 }
        if (n < 1) { this.slideIndex = slides.length }
        for (i = 0; i < slides.length; i++) {
            slides[i].style.display = "none";
        }
        for (i = 0; i < dots.length; i++) {
            dots[i].className = dots[i].className.replace(" active", "");
        }
        slides[this.slideIndex - 1].style.display = "block";
        dots[this.slideIndex - 1].className += " active";
    }

    prevSlides = () => {
        this.showSlides(this.slideIndex -= 1);
    }

    nextSlides = () => {
        this.showSlides(this.slideIndex += 1);
    }

    currentSlide = (event) => {
        this.showSlides(this.slideIndex = (+event.target.dataset.id));
    }

    get countSlides() {
        return this.slideCountNumber++;
    }

    handleOfferClick(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                actionName: 'view'
            }
        });
    }

    get isRecordAvailable() {
        return this.record.length > 0;
    }
}