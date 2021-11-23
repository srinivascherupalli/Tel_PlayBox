/*******************************************************************

 * Team : Hawaii
 * Jira No : P2OB-7463
 * Description : This class contains logic to display article on Partner community
 * Date : 20/7/2020

 * 21/7/2020 - P2OB-7462 - Hawaii - restrict article on the basis of record type access
 Date            Version             Modified By             Desc
 22-July-2020      1                 Megha                   restrict article on the basis of record type access
 24-July-2020      2                 Paresh                  P2OB-8611 - Added LastPublishedDate in query so that wrapper class variable can be set
 06-Aug-2020       3                 Paresh                  P2OB-8611 - Added Product status field in query
 11-Aug-2020       4                 Paresh                  P2OB-8030 && P20B-7893 - Modified getArticleCategory method to get article data for knowledge base,retail live and partner sales enablement
 4-Sep-2020        5                 Paresh                  P2OB-9098 - Get custom metadata to generate dynamic filter
 13-Sep-2020       6                 Paresh                  Added String.escapeSingleQuotes to avoid p1 in pmd rules
 12-Mar-2021       7                 Paresh 				 P2OB-12539 - Get article associated with recommendations
***********************************************************************/

public with sharing class prmArticleDetail {
    public class KnowledgeArticleWrapper {
        @AuraEnabled
        public Knowledge__kav articleDetail {get; set;}
        public KnowledgeArticleWrapper() {
            if(articleDetail == null){
                articleDetail = new Knowledge__kav();
            }
        }
    }

    //Added record type condition to allow partners to see authorized articles
    //P2OB-8611 - Added Product_Status__c field in Query
    @AuraEnabled(cacheable=true)
    public static KnowledgeArticleWrapper getArticleDetail(String param){
        KnowledgeArticleWrapper kaWrapper = new KnowledgeArticleWrapper();
        String publishedStatus = 'Online';
        Set<String> validRecordTypes = PRMKnowledgeArticleUtility.knowledgeValidRecordTypes;
        String query = 'SELECT Id,'+ 
                            'PublishStatus,'+
                            'ArticleNumber,'+
                            'Title,'+
                            'Summary,'+
                            'Featured_Image__c,'+
                            'In_this_article_you_will_learn__c,'+ 
                            'Sub_Title__c,'+
                            'LastPublishedDate,'+ 
                            'Details__c,Tab_1_Name__c,Tab_2_Name__c,Tab_3_Name__c,Tab_4_Name__c,'+
                            'Tab_1_Additional_Content_1__c,Tab_1_Additional_Content_2__c,Tab_1_Additional_Content_3__c,'+
                            'Tab_1_Additional_Content_4__c,Tab_2_Content__c,Tab_3_Content__c,Tab_4_Content__c,'+
                            'Tab_3_Additional_Content__c,Tab_4_Additional_Content__c,Tab_2_Additional_Content__c,'+
                            'RecordType.Name,'+
                            'Product_Status__c'+
                    ' FROM Knowledge__kav where urlName =:param AND PublishStatus =:publishedStatus' + (validRecordTypes != null && validRecordTypes.size() > 0 ? ' AND RecordType.Name in : validRecordTypes' : '') + ' UPDATE VIEWSTAT';
        for(Knowledge__kav kav : Database.query(String.escapeSingleQuotes(query))){
                    kaWrapper.articleDetail = kav;
            }
        return kaWrapper;
    }

    //P2OB-8030 && P20B-7893 : Modified method to get data for knowledge base/retail live/partner sales enablement
    //P2OB-12539 - Pass additional paramaters to methods from component
    @AuraEnabled(cacheable=true)
    public static List<PRMCarouselWrapper> getArticleCategory(String searchString,String categoryName,Boolean retrieveChildArticle,String displayFormat,Integer numberOfArticles,String sortBy,String orderBy,String publishPageName,Boolean allowRecommendation){
        system.debug('searchString value is'+searchString);
        //Initialize wrapper class
        List<PRMCarouselWrapper> listOfWrapper = new List<PRMCarouselWrapper>();
        //initialize knowlede object
        List<Knowledge__kav> kavArticle = new List<Knowledge__kav>();
        //get base query of knowledge to fetch knowledge details
        String fieldQuery = PRMKnowledgeArticleUtility.getArticleBaseQuery();
        //get available record types based on custom permission
        String validRecordTypes = PRMKnowledgeArticleUtility.getAvailableRecordtypes();
        //P2OB-12539 - Pass Parameter 'allowRecommendation' to getAvailableCategory method
        //get available categories based on custom permission
        String searchCategory = PRMKnowledgeArticleUtility.getAvailableCategory(allowRecommendation);
        //generate limit part of query based on condition
        String articleLimit = String.isNotBlank(displayFormat) && (displayFormat == 'ViewAll' || displayFormat == 'Carousel') && numberOfArticles != null ? ' limit '+numberOfArticles : '';
        //generate sorting part of query based on condition
        String sortArticle = String.isNotBlank(sortBy) && String.isNotBlank(orderBy) ? ' order by '+String.escapeSingleQuotes(sortBy)+' '+String.escapeSingleQuotes(orderBy) : '';
        //P2OB-12539 - Get articles for recommendations
        if(allowRecommendation){
            fieldQuery +=  ' AND Publish_as_Recommendation_on_TPC__c = true AND Publish_Recommendation_Until__c >= today' + (String.isNotBlank(publishPageName) ? ' AND TPC_Publish_Page__c includes ('+'\''+String.escapeSingleQuotes(publishPageName)+'\')':'') + (string.isNotBlank(validRecordTypes) ? ' And RecordType.Name IN ' +validRecordTypes:'') +(String.isNotBlank(searchCategory) ? ' WITH DATA CATEGORY Partner__c below '+String.escapeSingleQuotes(searchCategory):'') + String.escapeSingleQuotes(sortArticle) + String.escapeSingleQuotes(articleLimit);
            //Get knowledge articles based on final query generated
            kavArticle = Database.query(fieldQuery);
        }else{
        // search functionality when category is specified in lwc component and search functionality is enabled
        if(String.isNotBlank(searchString) && String.isNotBlank(categoryName)){
            //get valid record type
            fieldQuery += (string.isNotBlank(validRecordTypes) ? ' And RecordType.Name IN ' +validRecordTypes:'');
            //search in title and summary fields
            fieldQuery += ' AND (Title like ' + '\''+'%'+String.escapeSingleQuotes(searchString)+'%'+'\''+ ' OR Summary like '+'\''+'%'+String.escapeSingleQuotes(searchString)+'%'+'\''+')' ;
            //Search within data categories
            fieldQuery += ' WITH DATA CATEGORY Partner__c';
            //This code will fetch article associated with child categories and top category
            if(retrieveChildArticle){
                fieldQuery += ' below '+String.escapeSingleQuotes(categoryName)+'__c' +String.escapeSingleQuotes(sortArticle) + String.escapeSingleQuotes(articleLimit);
             //This code will fetch article associated with top category only
            }else{
                fieldQuery += ' AT '+String.escapeSingleQuotes(categoryName)+'__c' + String.escapeSingleQuotes(sortArticle) + String.escapeSingleQuotes(articleLimit);
                } 
            //Get knowledge articles based on final query generated
            kavArticle = Database.query(fieldQuery);
        // This code will execute when Top category is passed from 'prmKnolwedgeCategory' component  
        }else if(String.isNotBlank(categoryName)){
            // define category name as 'All' when Recommended articles needs to display on ui
            if(categoryName == 'All'){
                fieldQuery += (string.isNotBlank(validRecordTypes) ? ' And RecordType.Name IN ' +validRecordTypes:'')+(String.isNotBlank(searchCategory) ? ' WITH DATA CATEGORY Partner__c below '+String.escapeSingleQuotes(searchCategory):'') + String.escapeSingleQuotes(sortArticle) + String.escapeSingleQuotes(articleLimit);
                // This piece of code will execute when Top categoy is pass from LWC component
            }else{
                fieldQuery += (string.isNotBlank(validRecordTypes) ? ' And RecordType.Name IN ' +validRecordTypes:'')+' WITH DATA CATEGORY Partner__c';
                 //This code will fetch article associated with child categories and top category
                if(retrieveChildArticle){
                    fieldQuery += ' below '+String.escapeSingleQuotes(categoryName)+'__c' +String.escapeSingleQuotes(sortArticle) + String.escapeSingleQuotes(articleLimit);
                 //This code will fetch article associated with top category only
                }else{
                    fieldQuery += ' AT '+String.escapeSingleQuotes(categoryName)+'__c' + String.escapeSingleQuotes(sortArticle) + String.escapeSingleQuotes(articleLimit);
                }
            }
            //Get knowledge articles based on final query generated
            kavArticle = Database.query(fieldQuery);
        // This piece of code will execute to get trending articles
        }else if(String.isBlank(categoryName) && numberOfArticles != null){
            //get parent id to fetch associated knowledge articles
            List<Id> parentId = PRMKnowledgeArticleUtility.getTrandingKnowledgeArticleIds(numberOfArticles);
            if(parentId.size() > 0){
                fieldQuery += ' AND knowledgeArticleId IN : parentId';
            }
            //Get knowledge articles based on final query generated
            kavArticle = Database.query(fieldQuery);
            kavArticle = PRMKnowledgeArticleUtility.getKnoweldgeArticleInSequence(parentId, kavArticle);
            }
        }
        if(kavArticle.size () > 0){
            //call method to set wrapper class variable 
            PRMKnowledgeArticleUtility.getArticleInfo(kavArticle,listOfWrapper,categoryName);
            system.debug('listOfWrapper value is'+listOfWrapper);
        }
    return listOfWrapper;
    }


    @AuraEnabled(cacheable=true)
    public static List<PRMCarouselWrapper> getSupportQuestionArticleCategory(String categoryName){
        List<PRMCarouselWrapper> listOfWrapper = new List<PRMCarouselWrapper>();
        List<String> catList = prmArticleDetail.getCategoryAndChildCategory(categoryName);
        List<Knowledge__DataCategorySelection> dataCatSel = [select Id,
                                                                DataCategoryName,
                                                                Parent.Title, 
                                                                Parent.UrlName
                                                                FROM Knowledge__DataCategorySelection 
                                                                WHERE Parent.PublishStatus = 'Online' AND Parent.RecordType.Name = 'FAQ'];
    for(String cat : catList){
        for(Knowledge__DataCategorySelection kds : dataCatSel){
        if(cat.equalsIgnoreCase(kds.DataCategoryName)){
                    listOfWrapper.add(new PRMCarouselWrapper(kds.DataCategoryName, kds.Parent)); // Updated Megha
              }
        }
    }
        return listOfWrapper;
    }

    public prmArticleDetail() {
    }

    private static List<String> getCategoryAndChildCategory(String categoryName){
        List<String> categories = new List<String>();
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
            //Creating the list of sobjects to use for the describe call
            List<String> objType = new List<String>();
            objType.add('KnowledgeArticleVersion');
            //Describe Call
            describeCategoryResult = Schema.describeDataCategoryGroups(objType);
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
                if(singleResult.getName().equalsIgnoreCase('Partner')){
                    DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
                    p.setSobject(singleResult.getSobject());
                    p.setDataCategoryGroupName(singleResult.getName());
                    pairs.add(p);
                }
            }
        
                //describeDataCategoryGroupStructures()
                describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
                //Getting data from the result
                for(DescribeDataCategoryGroupStructureResult singleStructureResult : describeCategoryStructureResult){
                    //Get name of the associated Sobject
                    //Get the top level categories
                    DataCategory [] toplevelCategories =  singleStructureResult.getTopCategories();
                    for(DataCategory category : toplevelCategories) {
                        if(categoryName.equals(category.getName())){
                            categories.add(category.getName());
                            if( category.getChildCategories().size() > 0){
                                for(DataCategory catChild : category.getChildCategories()){
                                    categories.add(catChild.getName());
                                }
                            }
                        }else if(category.getChildCategories().size() > 0){
                            for(DataCategory catChild : category.getChildCategories()){
                                if(categoryName.equals(catChild.getName())){
                                    categories.add(catChild.getName());
                                        for(DataCategory catChildChild : catChild.getChildCategories()){
                                                categories.add(catChildChild.getName());
                                        }
                                }else if(catChild.getChildCategories().size() > 0){
                                    for(DataCategory catChildToChild : catChild.getChildCategories()){
                                        if(categoryName.equals(catChildToChild.getName())){
                                            categories.add(catChildToChild.getName());
                                            for(DataCategory catChildToChildToChild: catChildToChild.getChildCategories()){
                                                categories.add(catChildToChildToChild.getName());
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                return categories;
    }

    //P2OB-9098 : Get filter condition from custom metadata
    @AuraEnabled(cacheable=true)
    public static List<filterWrapper> getFilterMetadata(String categoryName){
        List<filterWrapper> wrapper = new List<filterWrapper>();
        if(String.isNotBlank(categoryName)){
            //Query on custom metadata
            for(PRMKnowledgeArticleFilter__mdt  mdt : [Select id,Category__c,Dependent_Field__c,Field_API_Name__c,Field_Type__c,Filter_By__c,FieldValues__c,Order_Number__c from PRMKnowledgeArticleFilter__mdt where Category__c =: categoryName order by Order_Number__c]){
                filterWrapper wrap = new filterWrapper(mdt.Category__c,mdt.Field_API_Name__c,mdt.Field_Type__c,mdt.Filter_By__c,mdt.Dependent_Field__c,mdt.FieldValues__C);
                wrapper.add(wrap);
            }
        }
        //return wrapper
        return wrapper;
    }
    

    /* get Excluded Categories */
    @AuraEnabled(cacheable=true)
    public static List<String> getExcludedCategories(){
        List<String> excludedCategories = new List<String>();
        if(PRMKnowledgeArticleUtility.excludeDataCategoriesDetails == null){
            PRMKnowledgeArticleUtility.excludeDataCategoriesDetails = PRMKnowledgeArticleUtility.getExcludeCategories();
        }
        excludedCategories.addAll(PRMKnowledgeArticleUtility.excludeDataCategoriesDetails.keySet());
        return excludedCategories;
    }

    //P2OB-9098 wrapper class to store variables
    public class filterWrapper{
        
        @auraenabled
        public String category{get;set;}
        
        @auraenabled
        public String fieldApiName{get;set;}
    
        @auraenabled
        public String fieldType{get;set;}

        @auraenabled
        public String filterBy{get;set;}

        @AuraEnabled
        public String dependentField{get;set;}

        @auraEnabled
        public string fieldValues{get;set;}
        
        //P2OB-9098 Wrapper class constructor to set values of variables
        public filterWrapper(String category,String fieldApiName,String fieldType,String filterBy,String dependentField,String fieldValues){
            this.category = category;
            this.fieldApiName = fieldApiName;
            this.fieldType = fieldType;
            this.filterBy = filterBy;
            this.dependentField = dependentField;
            this.fieldValues = fieldValues;
        }

    }
}