/*******************************************************************
Created By          :   Garg / Ashish
Created Date        :   
Desc                :   This is used to show craousel data on partner community

Date            Version             Modified By             Desc
7-August-2019        1              Ashish garg                
***********************************************************************/
/*******************************************************************
Modified By      :  Hawaii
Modified Date    :  22/07/2020
Desc             :  Added Methods getArticleList,getCategoryList,getArticleCategory to filter articles based on 
                    permission set and record type combination for partner users

Date            Version            Modified By             Desc
14-July-2020         1             Hawaii                  P2OB-7462 
22-July-2020         2             Hawaii                  P2OB-7462 
7-August-2020        3             Hawaii                  P2OB-8030 && P20B-7893 - Modified Existing Method  'getKnowldegeArticleData' to search article based on reord type and category combination           
11 -August-2020      4             Hawaii                  P2OB-8030 && P20B-7893 - Updated logic in method getKnowldegeArticleRecomendedData
12 -August-2020      5             Hawaii                  P2OB-8030 && P20B-7893 - Updated getKnowldegeArticleData method to handle multiple data category input
13- Sept - 2020      6             Hawaii                  Added String.escapeSingleQuotes to avoid p1 in pmd rules
12-Mar-2021          7             Hawaii                  P2OB-12539: Pass False value in getAvailableCategory method
***********************************************************************/

public with sharing class PRMOffersCarousel {

    @AuraEnabled(cacheable=true)
    public static List<PRMCarouselWrapper> getOfferCarouselData(String objectName, Integer numberOfRecord){
        List<PRMCarouselWrapper> listOfWrapper = new List<PRMCarouselWrapper>();
        if(objectName.equals('Offer')){
        //return listOfWrapper;
        }else {
            List<Id> knowledgeArtclIds = new List<Id>();
            String categoryName = null;
            knowledgeCommunityName__c knwObj = knowledgeCommunityName__c.getValues('EDGE Partners');
            String CommunityName = knwObj.comm_name__c;
            String imageURL = null;
            List<Network> networkList = [Select id,Name from Network Where Name = :CommunityName LIMIT 1];
            
            //this is the way to find out trending article in community
            if(networkList.size() > 0){
               for(ConnectApi.KnowledgeArticleVersion trendingArticleList :  ConnectApi.Knowledge.getTrendingArticles(''+networkList[0].Id, numberOfRecord).items){
                   knowledgeArtclIds.add(trendingArticleList.knowledgeArticleId);
               }
            }

            // we have to fetch other custom field whihc is not directly provided by connectAPI
            for(Knowledge__kav kav : [SELECT Id,Title,Summary,Sub_Title__c,Featured_Image__c,Featured_Image_Upload__Body__s,UrlName,
                                                 (SELECT Id, toLabel(DataCategoryName), DataCategoryGroupName 
                                                            FROM DataCategorySelections)
                                                FROM Knowledge__kav where KnowledgeArticleId in : knowledgeArtclIds 
                                                AND PublishStatus = 'Online']){
                categoryName = kav.DataCategorySelections.size() > 0 ? kav.DataCategorySelections[0].DataCategoryName:'';
                // Updated Megha
                kav.Featured_Image__c = kav.Featured_Image_Upload__Body__s != null ? '/servlet/fileField?entityId='+kav.Id+'&field=Featured_Image_Upload__Body__s' : kav.Featured_Image__c;
                listOfWrapper.add(new PRMCarouselWrapper(categoryName,kav));
            }
        }

        return listOfWrapper;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,List<Knowledge__DataCategorySelection>> getArticleCategoryGroupList(){
        Map<String,List<Knowledge__DataCategorySelection>> knDataCategoryMap = new Map<String,List<Knowledge__DataCategorySelection>>();
     
        List<Knowledge__DataCategorySelection> knDataCategory = [Select id,
                                                    toLabel(DataCategoryName),
                                                    Parent.UrlName,
                                                    Parent.Title,
                                                    Parent.Sub_Title__c
                                                    From Knowledge__DataCategorySelection
                                                    Where Parent.PublishStatus = 'Online'];
     
        for(Knowledge__DataCategorySelection dcs : knDataCategory) {
     
            if(!knDataCategoryMap.containsKey(dcs.DataCategoryName))
            {
                knDataCategoryMap.put(dcs.DataCategoryName,new List<Knowledge__DataCategorySelection>());
            }
            knDataCategoryMap.get(dcs.DataCategoryName).add(dcs);
     
        }
     
        return knDataCategoryMap;
 
    }
 
    // Megha : P2OB-7462 :This method get map of data category and associated knowledge articles based on record type and Permission set of user
    // This method is called from LWC component 'prmKArticleAccord'
    @AuraEnabled(cacheable=true)
    public static Map<String,List<Knowledge__DataCategorySelection>> getArticleList(){
        Map<String,List<Knowledge__DataCategorySelection>> knDataCategoryMap = PRMKnowledgeArticleUtility.getArticleBasedOnCategories();
        return knDataCategoryMap;
     
    }
    
    // Megha : P2OB-7462 :This method get hierarchy of data category assigned to 'Partner'category group
    // This method is called from LWC component 'prmKArticleAccord'
    // Updated P2OB-8611 - Hawaii added parentCategoryName and isShowParent parameters
    @AuraEnabled(cacheable=true)
    public static String getCategoryList(String parentCategoryName, Boolean isShowParent){
        return PRMKnowledgeArticleUtility.getCategoryList(parentCategoryName, isShowParent);
     
    }
    
    //P2OB-8030 && P20B-7893 : Hawaii - Modify this method to get articles as per requirement P2OB-8030 && P20B-7893
    //This method is used in component prmRecommendArticlBase
    //Updated this method as per new business logic as we are not deleting existing 'prmRecommendArticlBase' lwc component
    @AuraEnabled(cacheable=true)
    public static List<PRMCarouselWrapper> getKnowldegeArticleRecomendedData(){

        //Initialize wrapper class
        List<PRMCarouselWrapper> listOfWrapper = new List<PRMCarouselWrapper>();
        //initialize knowlede object
        List<Knowledge__kav> kavArticle = new List<Knowledge__kav>();
        //get base query of knowledge to fetch knowledge details
        String fieldQuery = PRMKnowledgeArticleUtility.getArticleBaseQuery();
        //get available record types based on custom permission
        String validRecordTypes = PRMKnowledgeArticleUtility.getAvailableRecordtypes();
        //P2OB-12539: Pass False value in getAvailableCategory method
        //get available categories based on custom permission
        String searchCategory = PRMKnowledgeArticleUtility.getAvailableCategory(false);

        fieldQuery += (string.isNotBlank(validRecordTypes) ? ' And RecordType.Name IN ' +validRecordTypes:'')+(String.isNotBlank(searchCategory) ? ' WITH DATA CATEGORY Partner__c below '+String.escapeSingleQuotes(searchCategory):'');
        //Get knowledge articles based on final query generated
        kavArticle = Database.query(fieldQuery);
    	if(kavArticle.size () > 0){
       		//call method to set wrapper class variable 
      		PRMKnowledgeArticleUtility.getArticleInfo(kavArticle,listOfWrapper,'');
        }
        return listOfWrapper;
    }

    /*
    Modified By : Hawaii
    Jira : P2OB-8030 && P20B-7893
    Description : Modified method to fetach articles based on record type and category combination which user has access
                  passed additional variable topcategory which will be design parameter in lwc component.If top category is present 
                  it will search articles associated with top category else all articles associated with data categories which user has access.
    */
    @AuraEnabled(cacheable=true)
    public static List<PRMCarouselWrapper> getKnowldegeArticleData(String searchString,String topCategory){
        List<PRMCarouselWrapper> listOfWrapper = new List<PRMCarouselWrapper>();
        List<Knowledge__kav> knowledgeKAV = new List<Knowledge__kav>();
        //get base query for articles
        String fieldQuery = PRMKnowledgeArticleUtility.getArticleBaseQuery();
        //P2OB-12539: Pass False value in getAvailableCategory method
        //get available categories based on custom permission
        String searchCategory = PRMKnowledgeArticleUtility.getAvailableCategory(false);
        //get valid record types based on custom permission
        String validRecordTypes = PRMKnowledgeArticleUtility.getAvailableRecordtypes();

        fieldQuery += (string.isNotBlank(validRecordTypes) ? ' And RecordType.Name IN ' +validRecordTypes:'');

        List<String> categoryList = String.isNotBlank(topCategory) ? topCategory.split(',') : null;
        
        // generate formatted category structure when we have multiple category as input
        String category = '';
        if(categoryList != null && categoryList.size() > 0){
            category = '(';
            for(String str : categoryList){
                category += str +'__c,';
            }
            category = category.trim().endsWith(',') ? category.subString(0,category.length()-1) + ')' : ')';
        }
        
        //if search string is blank - get articles based on record type and categories which user has access
    if(String.isBlank(searchString)){
            //if top category present fetch article associated with top category else article associated with all data categories which user has access
            fieldQuery += String.isNotBlank(topCategory) ? ' WITH DATA CATEGORY Partner__c BELOW '+ category : (String.isNotBlank(searchCategory) ? ' WITH DATA CATEGORY Partner__c BELOW '+searchCategory :'');
            //fetch articles 
            knowledgeKAV = Database.query(fieldQuery);
        }else{

            //if top category present fetch article associated with top category else article associated with all data categories which user has access
            fieldQuery += ' AND (Title like ' + '\''+'%'+String.escapeSingleQuotes(searchString)+'%'+'\''+ ' OR Summary like '+'\''+'%'+String.escapeSingleQuotes(searchString)+'%'+'\''+')' ;
            fieldQuery += String.isNotBlank(topCategory) ? ' WITH DATA CATEGORY Partner__c BELOW '+ category : (String.isNotBlank(searchCategory) ? ' WITH DATA CATEGORY Partner__c BELOW '+searchCategory :'');
            //fetch articles 
            knowledgeKAV = Database.query(fieldQuery);
        }
        
    if(knowledgeKAV.size () > 0){
            //call this method to get all article detail in required format to display on UI.
            PRMKnowledgeArticleUtility.getArticleInfo(knowledgeKAV,listOfWrapper,'');
        }
        // return wrapper class
        return listOfWrapper;
    }
   
   // Megha : P2OB-7462 : This method get data category associated to input urlName
   // This method is called from LWC component 'prmKArticleAccord'
   @AuraEnabled(cacheable=true)
   public static String getArticleCategory(String urlName){
       return PRMKnowledgeArticleUtility.getCategoryFromArticle(urlName);
   }

}