/*
Modified By : Team Hawaii
Date : 17/7/2020
Jira No: 7463
Description: This component contain all logic to display Knowledge article on Partner Community
Version        Jira       Modified Date            By               Description    
1             P2OB-8379   31/07/2020            Team Hawaii      Added logic to conditionlly display published date and Tabs
2             P2OB-8611   03/08/2020            Team Hawaii      Display banner if product status field has value Discontinued/End of Life
3             P20B-8379   07/09/2020            Team Hawaii      Display message,when user does not have access to article
4             P2OB-10032  24/09/2020            Team Hawaii      Fixed Accordian clickable issue on 2nd time
5             P2OB-10985  09/12/2020            Team Hawaii      Fixed Locale as per logged in user
*/
import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import { registerListener, unregisterAllListeners } from 'c/prmPubSub';
import getKnowledgeArticleDetail from '@salesforce/apex/prmArticleDetail.getArticleDetail';
import articleJs from '@salesforce/resourceUrl/JScripts';
import faqRecordType from '@salesforce/label/c.PRM_Knowledge_FAQ_Record_Type';
import insufficientArticleAccess from '@salesforce/label/c.PRMInsufficientArticleAccess';
import productBanner from '@salesforce/label/c.PRMProductStatusBanner';
import knowledgeRecordType from '@salesforce/label/c.PRM_Knowledge_Record_Types';
import prmKnowledgeRecordType from '@salesforce/label/c.PRM_Knowledge_Article_Record_Type';
import LOCALE from '@salesforce/i18n/locale';
export default class prmArticleDetails extends LightningElement {

  @wire(CurrentPageReference)
  pageRef;
  parameters;
  //variable store data retrieve from server side
  @track knArticleDetail = {};
  //content of Tab 1 (Details__c,Tab_1_Additional_Content_1__c,Tab_1_Additional_Content_2__c,Tab_1_Additional_Content_3__c,Tab_1_Additional_Content_4__c)
  tab1Content = '';
  //content of Tab 2 (Tab_2_Content__c,Tab_2_Additional_Content__c)
  tab2Content = '';
  //content of Tab 3 (Tab_3_Content__c,Tab_3_Additional_Content__c)
  tab3Content = '';
  //content of Tab 4 (Tab_4_Content__c,Tab_4_Additional_Content__c)
  tab4Content = '';
  //variable true when record type is not FAQ
  @track nonFAQSection = false;
  //variable store value of summary field
  @track summary = '';
  //store error 
  @track error;
  // initialized variable 
  hasRendered = false;

  //Boolean variable to show banner
  @track showBanner = false;

  //Message to be displayed on banner
  @track bannerMsg = '';

  //Show Child Component
  @track showChildComponent;

  //object to store boolean value,If any tab is exclude in design parameters that tab does not visible on UI.
  @track obj = {
    hideTab1: false,
    hideTab2: false,
    hideTab3: false,
    hideTab4: false
  }

  //P2OB-8956 - Boolean variable to only show tab1 for retail live and partner sales enablement
  @track showTab1 = false;
  //design parameter to conditionally show and hide published date
  @api showPublishedDate;
  //design parameter to conditionally show and hide tabs
  @api hideTab;

  //variable to store error message if user does not have access to perticular article
  notAuthorize;
  showLastPublishedDate = false;

  //call when component inserted into the dom
  connectedCallback() {
    if (this.pageRef) {
      registerListener('changeArticleDetails', this.handleChangeArticleDetail, this);
    }
    this.parameters = this.getQueryParameters();
    this.getArticleData();
  }

  //get published date in DD/MM/YYYY format
  get displayLastPublishedDate() {
    if (Object.keys(this.knArticleDetail).length !== 0) {
      var date = new Date(this.knArticleDetail.LastPublishedDate);
      //Changed to set Locale for logged in user P2OB-10985
      return date.toLocaleDateString(LOCALE);
    }
  }

  /* get hasRecord(){
     return Object.keys(this.knArticleDetail).length !== 0;
   }*/

  //this function get the data from server
  getArticleData() {
    getKnowledgeArticleDetail({ param: this.parameters }).then(result => {

      if (result.hasOwnProperty('articleDetail') && Object.keys(result['articleDetail']).length !== 0) {
        this.knArticleDetail = result.articleDetail;
        //P2OB-8611 - Display banner if product status field has value Discontinued/End of Life
        if (this.knArticleDetail.hasOwnProperty('Product_Status__c') && this.knArticleDetail.Product_Status__c != '' && (this.knArticleDetail.Product_Status__c == 'Discontinued' || this.knArticleDetail.Product_Status__c == 'End of Life')) {
          this.bannerMsg = productBanner + ' ' + this.knArticleDetail.Product_Status__c + '.';
          this.showBanner = true;
        }

        let separateLabels = prmKnowledgeRecordType.split(",")
        if (separateLabels.includes(this.knArticleDetail.RecordType.Name)) {
          this.showChildComponent = true;
        }
        //if record type of article not 'FAQ'
        if (this.knArticleDetail.RecordType.Name !== faqRecordType) {
          this.nonFAQSection = true;
          this.setVariables(this.knArticleDetail);
          this.hasRendered = true;
          if (this.knArticleDetail.RecordType.Name === 'Enterprise Partner Knowledge Content') {
            this.showTab1 = true;
          }
          //if record type of article is 'FAQ'
        } else if (this.knArticleDetail.RecordType.Name === faqRecordType) {
          this.summary = this.knArticleDetail.Summary;
        }
        this.populatelastPublishedDate();
      } else {
        this.notAuthorize = insufficientArticleAccess;
      }

    }).catch(error => {
      this.error = error;
    });
  }

  //check if published date need to show or not
  populatelastPublishedDate() {
    this.showLastPublishedDate = this.showPublishedDate && Object.keys(this.knArticleDetail).length !== 0 ? true : false;
  }

  //P2OB-8379 - show/hide tabs 
  showHideTabs(articles) {
    var tabs = this.hideTab.split(',');
    if (knowledgeRecordType.includes(articles.RecordType.Name)) {
      if (articles.hasOwnProperty('Tab_1_Name__c') && tabs.includes('Tab_1_Name__c')) {
        this.obj.hideTab1 = true;
      }
      if (articles.hasOwnProperty('Tab_2_Name__c') && tabs.includes('Tab_2_Name__c')) {
        this.obj.hideTab2 = true;
      }
      if (articles.hasOwnProperty('Tab_3_Name__c') && tabs.includes('Tab_3_Name__c')) {
        this.obj.hideTab3 = true;
      }
      if (articles.hasOwnProperty('Tab_4_Name__c') && tabs.includes('Tab_4_Name__c')) {
        this.obj.hideTab4 = true;
      }
    }
  }

  //this function concatenates value of fields to display in respective tab fields 
  setVariables(articleDetail) {
    this.tab1Content = (articleDetail.Details__c !== undefined ? '<div>' + articleDetail.Details__c : '<div>')
      + (articleDetail.Tab_1_Additional_Content_1__c != undefined ? articleDetail.Tab_1_Additional_Content_1__c : '')
      + (articleDetail.Tab_1_Additional_Content_2__c != undefined ? articleDetail.Tab_1_Additional_Content_2__c : '')
      + (articleDetail.Tab_1_Additional_Content_3__c != undefined ? articleDetail.Tab_1_Additional_Content_3__c : '')
      + (articleDetail.Tab_1_Additional_Content_4__c != undefined ? articleDetail.Tab_1_Additional_Content_4__c + '</div>' : '</div>');
    this.tab2Content = (articleDetail.Tab_2_Content__c !== undefined ? '<div>' + articleDetail.Tab_2_Content__c : '<div>')
      + (articleDetail.Tab_2_Additional_Content__c != undefined ? articleDetail.Tab_2_Additional_Content__c + '</div>' : '</div>');
    this.tab3Content = (articleDetail.Tab_3_Content__c !== undefined ? '<div>' + articleDetail.Tab_3_Content__c : '<div>')
      + (articleDetail.Tab_3_Additional_Content__c != undefined ? articleDetail.Tab_3_Additional_Content__c + '</div>' : '</div>');
    this.tab4Content = (articleDetail.Tab_4_Content__c !== undefined ? '<div>' + articleDetail.Tab_4_Content__c : '<div>')
      + (articleDetail.Tab_4_Additional_Content__c != undefined ? articleDetail.Tab_4_Additional_Content__c + '</div>' : '</div>');

    //call show hide function
    this.showHideTabs(this.knArticleDetail);

  }
  //Once component dom is available applying jquery functions 
  renderedCallback() {
    if (this.hasRendered) {
      //initialize variable to initial value 
      this.hasRendered = false;
      var tabContent1 = this.template.querySelector('.tabContent1');
      if (tabContent1 !== null) {
        tabContent1.innerHTML = this.tab1Content;
      }
      var tabContent2 = this.template.querySelector('.tabContent2');
      if (tabContent2 !== null) {
        tabContent2.innerHTML = this.tab2Content;
      }
      var tabContent3 = this.template.querySelector('.tabContent3');
      if (tabContent3 !== null) {
        tabContent3.innerHTML = this.tab3Content;
      }
      var tabContent4 = this.template.querySelector('.tabContent4');
      if (tabContent4 !== null) {
        tabContent4.innerHTML = this.tab4Content;
      }
      const allDivContent = this.template.querySelectorAll('.htmlContent div.articleTab');
      const getAllContentAfterHtmlContent = this.template.querySelectorAll('.htmlContent *');
      const nextDivContent = this.template.querySelector('.htmlContent div.articleTab');
      const getHtmlContent = this.template.querySelector('.htmlContent');
      loadScript(this, articleJs + '/jquery-3.5.1.min.js')
        .then(() => {
          //P2OB-10032 - changed getHtmlContent to document as jquery should be applied once complete dom is rendered
          $(document).ready(function () {
            //$('.tabContent4 h5').addClass(' toggled');
            $(getHtmlContent).on('click', "h5", function () {
              var headings = $('h1, h2, h3, h4, h5');
              $(this).toggleClass("toggled").nextUntil(headings).toggle();
            });
            $(nextDivContent).first().addClass("active").nextUntil("div.articleTab");
            var getNextTab = $(getHtmlContent).find(nextDivContent).first().nextUntil(nextDivContent).html();
            //if contentHTML class does not have any content it is showing undefined value,to prevent that added undefined check
            var el = $("<div class='contentHTML'>" + (getNextTab != undefined ? getNextTab : '') + "</div>");
            $(getHtmlContent).append(el);
            $(allDivContent).click(function () {
              $(allDivContent).removeClass("active");
              $(getAllContentAfterHtmlContent).removeClass("active");
              var content = $(this).addClass("active").next("div.tabContent").not("div#contentHTML").clone(true);
              el.html(content);
            });
          })
        })
    }
  }
  //this function get the article url
  getQueryParameters() {
    let search = window.location.pathname.split('/');
    return search.length > 0 ? search[search.length - 1] : '';

  }
  handleChangeArticleDetail = (urlName) => {
    this.parameters = urlName;
  }
  disconnectedCallback() {
    // unsubscribe from changeArticleDetails event
    unregisterAllListeners(this);
  }
}