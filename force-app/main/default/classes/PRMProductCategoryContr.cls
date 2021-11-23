/*******************************************************************
* Team : Team Hawaii
* Jira No :  P2OB - 8369
* Description : Controller Class for Product Categories Component
* Created Date : 07-August-2020
* Class covered By Test Class : 
* Modified Date : 07-August-2020
***********************************************************************/

public with sharing class PRMProductCategoryContr {
    /* Method to get Valid Product Categories*/
    @AuraEnabled(cacheable=true)
    public static List<PRMDataCategoryWrapper> getTopProductCategories(String categoryName){
        List<String> allCategories = new List<String>();
        List<PRMDataCategoryWrapper> categoryDetails = new List<PRMDataCategoryWrapper>();
        List<PRMDataCategoryDetails__mdt> imageUrlList = [Select ImageURL__c ,DeveloperName from PRMDataCategoryDetails__mdt];
        Map<String,String> categoryToUrlMap = new Map<String,String>();
        String envLabel = System.Label.PRM_ENV_URL;
        //Map Category Api Name to URL from Metadata

        for(PRMDataCategoryDetails__mdt imgUrl : imageUrlList){
            categoryToUrlMap.put(imgUrl.DeveloperName,imgUrl.ImageURL__c);
        }

        //Default image to populate if Metadata record is not available.
        String defaultURL = envLabel + categoryToUrlMap.get('Basics_and_Navigation');
        //Fetch the relevant categories and subcategories.
        String categoryJson = PRMKnowledgeArticleUtility.getCategoryList(categoryName,false);
        List<Object> productCategoryList = (List<Object>) JSON.deserializeUntyped(categoryJson);
        //Populate the list of wrapper class for category name, apiName and Image URL

        for (Object obj: productCategoryList) {
            Map<String, Object> categoryMap = (Map<String, Object>)obj;
            PRMDataCategoryWrapper wrapperRec = new PRMDataCategoryWrapper();
            wrapperRec.label = (String) categoryMap.get('label');
            wrapperRec.categoryApi = (String) categoryMap.get('name');
            if(categoryToUrlMap.containsKey(wrapperRec.categoryApi)){
                wrapperRec.imageURL = envLabel + categoryToUrlMap.get(wrapperRec.categoryApi);
            }
            else{
                wrapperRec.imageURL = defaultURL;
            }

            categoryDetails.add(wrapperRec);
        }
        //Return the wrapper class
        return categoryDetails;   
    }
    //Wrapper Class for category label, apiName and Image URL.

    public class PRMDataCategoryWrapper{
        @auraenabled
        public string label{get;set;}
        @auraenabled
        public string categoryApi{get;set;}
        @auraenabled
        public string imageURL{get;set;}
    }


}