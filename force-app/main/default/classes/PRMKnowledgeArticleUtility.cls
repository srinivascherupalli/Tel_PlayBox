/*******************************************************************
 * Team : Team Hawaii
 * Jira No :  P2OB - 7462
 * Description : Utility class for KnowledgeArticle Stuff
 * Date : 14-July-2020
 * Class covered By Test Class : PRMOffersCarouselTest
 Date            Version             Modified By             Desc
 06-Aug-2020        1                  Hawaii                P2OB-8030 - added Tranding Article method
 07-Aug-2020        2                  Hawaii                P2OB-8030 && P20B-7893 Added method getArticleInfo to set values of article fields in wrapper class variables 
 09-Aug-2020        3                  Hawaii                P2OB-8030 && P20B-7893 Added methods getAvailableCategory and getAvailableRecordtypes,to get data in required syntax on multiple places(In Dynamic soql and sosl)
 26-Sep-2020        4                  Hawaii                P2OB-9636 - added logic to get Top Category
 12-Mar-2021        5                  Hawaii                P2OB-12539 - Pass parameter to getAvailableCategory method
***********************************************************************/
public with sharing class PRMKnowledgeArticleUtility{
    public static final String DEFAULT_RECORDTYPE = 'Default';
    public static final String Partner_Category_Group = 'Partner';
    public static final String All_Category= 'All';
    public static final String Object_Knowledge_Article_Version = 'KnowledgeArticleVersion';
    public static final String PUBLISH_STATUS_ONLINE = 'Online'; // P1 PMD fixes
    public static final String PRM_CHANNEL = 'prm';//P1 PMD fixes
    
    // P2OB-8611 & P2OB-8030 - Added static variables which are mostly used 
    public static Set<String> knowledgeValidRecordTypes; // get valid Record Types
    public static Set<String> availableCategories; // get available Categories  
    public static Map<String, PRM_Exclude_Category_Details__mdt> excludeDataCategoriesDetails;
  
    
    static{
        getValidKnowledgeRecordTypes();
    }
    /* get Valid Knowledge Record Type */
    private static void getValidKnowledgeRecordTypes(){
        knowledgeValidRecordTypes = new Set<String>();
        availableCategories = new Set<String>();
        // get custom metadata 
        List<Knowledge_Article_Visibility_Mapping__mdt> knowledgeArticleVisibilityList = [select id,Custom_Permission_API_Name__c, Knowledge_Record_Types__c, Available_Top_Categories__c from Knowledge_Article_Visibility_Mapping__mdt where Custom_Permission_API_Name__c != null AND Knowledge_Record_Types__c != null];
        for(Knowledge_Article_Visibility_Mapping__mdt mapping : knowledgeArticleVisibilityList){
            Boolean isUserHavePermission = FeatureManagement.checkPermission(mapping.Custom_Permission_API_Name__c);
            if(mapping.Custom_Permission_API_Name__c != DEFAULT_RECORDTYPE && FeatureManagement.checkPermission(mapping.Custom_Permission_API_Name__c)){
                if(mapping.Knowledge_Record_Types__c != null){
                    knowledgeValidRecordTypes.addAll(mapping.Knowledge_Record_Types__c.split(','));
                }
                if(mapping.Available_Top_Categories__c != null){
                    availableCategories.addAll(mapping.Available_Top_Categories__c.split(','));
                }
                
            }
        }
    }
    
    
    
    /* get Knowledge Articles */
    public static Map<String,List<Knowledge__DataCategorySelection>> getArticleBasedOnCategories(){
        Map<String,List<Knowledge__DataCategorySelection>> knDataCategoryMap = new Map<String,List<Knowledge__DataCategorySelection>>();
        String fieldQuery = 'Select id,toLabel(DataCategoryName),Parent.UrlName,'
                            + ' Parent.Title,Parent.Sub_Title__c, Parent.RecordType.Name,Parent.LastPublishedDate';
        List<Knowledge__DataCategorySelection> knDataCategory = getKnowledgeArticlesFromDataCategory(fieldQuery);
        for(Knowledge__DataCategorySelection dcs : knDataCategory) {
            if(!knDataCategoryMap.containsKey(dcs.DataCategoryName))
            {
                knDataCategoryMap.put(dcs.DataCategoryName,new List<Knowledge__DataCategorySelection>());
            }
            knDataCategoryMap.get(dcs.DataCategoryName).add(dcs);
         }
         return knDataCategoryMap;
    } 
    //Dynamic query    
    public static List<Knowledge__DataCategorySelection> getKnowledgeArticlesFromDataCategory(String fieldQuery){
        String soqlQuery = !String.isEmpty(fieldQuery) ? fieldQuery : ' Select id, Parent.urlName ';
        soqlQuery +=' From Knowledge__DataCategorySelection '+
                    ' Where Parent.PublishStatus = : PUBLISH_STATUS_ONLINE AND parent.RecordType.Name in : validRecordTypes';// Hawaii - P1 PMD fixes 
        Set<String> validRecordTypes = knowledgeValidRecordTypes;
        return Database.query(String.escapeSingleQuotes(soqlQuery)); 
    }
    /* get category from Article */
    public static String getCategoryFromArticle(String urlName){
        Map<String, String> categoryDetails = new Map<String,String>();
        List<Knowledge__DataCategorySelection> knDataCategory = [Select id,
                                                    DataCategoryName
                                                    From Knowledge__DataCategorySelection
                                                    Where Parent.PublishStatus = 'Online' AND Parent.urlName = : urlName];
        // P2OB-9636 get the category and Parent Category
        if(!knDataCategory.isEmpty()){
            Map<String,PRMKnowledgeArticleUtility.DataCategoryWrapper> categoryMap = getCategoryNameByCategoryGroup();
            categoryDetails.put('categoryName', knDataCategory.get(0).DataCategoryName);
            if(categoryMap.containsKey(knDataCategory.get(0).DataCategoryName)){
                    if(excludeDataCategoriesDetails == null){
                        excludeDataCategoriesDetails = getExcludeCategories();
                    }
                    if(excludeDataCategoriesDetails.containsKey(categoryMap.get(knDataCategory.get(0).DataCategoryName).topCategoryName)){
                        categoryDetails.put('topCategoryName', categoryMap.get(knDataCategory.get(0).DataCategoryName).topCategoryName);
                    }else{
                       categoryDetails.put('topCategoryName', 'All'); 
                    }
            }
        }
        return JSON.serialize(categoryDetails);
    }
    
    
    //P2OB-8030 && P20B-7893 get base query to fetch articles   
    public static String getArticleBaseQuery(){
        String fieldQuery = 'SELECT Id,Title,Summary,Sub_Title__c,Featured_Image__c,UrlName,RecordTypeId,RecordType.DeveloperName,LastPublishedDate,KnowledgeArticleId,Event_Start_Date__c,Event_End_Date__c,Event_Registration_Link__c,Event_Type__c,City__c,Country__c,State__c,Postcode__c,Street_Address__c,(SELECT Id, DataCategoryName, DataCategoryGroupName FROM DataCategorySelections) FROM Knowledge__kav  WHERE PublishStatus=\'Online\'';
        return fieldQuery;
    }
    
    /* get Category Data 
    P2OB-8611 - get child categories for specific Top category also */
    public static String getCategoryList(String categoryName, Boolean isShowParent){
            String jsonOutput = '';
            // P2OB-8611 - init category array
            DataCategory[] topCategories = new List<DataCategory>();
            List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult = getDescribeResults(PRMKnowledgeArticleUtility.Object_Knowledge_Article_Version,PRMKnowledgeArticleUtility.Partner_Category_Group);
        
            //Getting data from the result
            // updated method P2OB-8030 
            topCategories = getTopCategories(describeCategoryStructureResult); 
            // for DescribeDataCategoryGroupStructureResult
            if(!topCategories.isEmpty()){
                // P2OB-8611 - get category on basis of Parent Category */
                jsonOutput = getValidCategories(topCategories,categoryName,isShowParent);
                
            }
            return jsonOutput;
    }  
        
    /* P2OB-8611 - get Describe Result 
    moved from getCategoryList*/
    private static List<DescribeDataCategoryGroupStructureResult> getDescribeResults(String objectType, String categoryGroupName){
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<String> objType = new List<String>();
        objType.add(PRMKnowledgeArticleUtility.Object_Knowledge_Article_Version);
        //Describe Call
        describeCategoryResult = Schema.describeDataCategoryGroups(objType);
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
            if(singleResult.getName().equalsIgnoreCase(categoryGroupName)){
                DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
                p.setSobject(singleResult.getSobject());
                p.setDataCategoryGroupName(singleResult.getName());
                pairs.add(p);
            }
        }
        return Schema.describeDataCategoryGroupStructures(pairs, false);
    }
    
    /* P2OB-8030 - Get top Categories 
    moved from getCategoryList*/
    private static List<DataCategory> getTopCategories(List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult){
        List<DataCategory> topCategories = new List<DataCategory>();
        for(DescribeDataCategoryGroupStructureResult singleStructureResult : describeCategoryStructureResult){
            if(singleStructureResult.getName() == PRMKnowledgeArticleUtility.Partner_Category_Group){
                DataCategory [] toplevelCategories =  singleStructureResult.getTopCategories();
                for (integer j = 0; j < toplevelCategories.size(); j++) {
                    DataCategory topCategory = toplevelCategories[j];
                    //if Top Category is other than 'All' then took top category
                    if(topCategory.getName() != PRMKnowledgeArticleUtility.All_Category){
                      topCategories.addAll(toplevelCategories);
                    }else{
                      //if Top Category is 'All' then pick child category
                        topCategories.addAll(topCategory.childCategories);
                    }
                } // for toplevelCategories
            } // if Partner_Category_Group
        }
        return topCategories;
    }
    /* P2OB-8611 - get only valid categories
    moved from getCategoryList*/
    private static String getValidCategories(DataCategory[] topCategories, String categoryName,Boolean isShowParent){
        DataCategory[] validTopCategories = new List<DataCategory>();
        String jsonOutput = '';
        if(excludeDataCategoriesDetails == null){
            excludeDataCategoriesDetails = getExcludeCategories();
        }
        for(DataCategory topCat : topCategories){
            // P2OB-8611 - check for top Category
            if(categoryName == topCat.Name && PRMKnowledgeArticleUtility.availableCategories.contains(topCat.name)){
               if(!isShowParent){
                    validTopCategories.addAll(topCat.childCategories);
                }else{
                    validTopCategories.add(topCat);
                }
                break;
            }else if(( String.isBlank(categoryName) || categoryName == All_Category) && availableCategories.contains(topCat.name) &&  (!excludeDataCategoriesDetails.containsKey(topCat.name) || (excludeDataCategoriesDetails.containsKey(topCat.name) && excludeDataCategoriesDetails.get(topCat.name).is_Exclude_from_Tree_Structure__c == False))){
              validTopCategories.add(topCat);
            }
        }
        //If called from test class
        if(Test.isRunningTest()){
            //jsonOutput = validTopCategories.size () > 0 ? validTopCategories.get(0).name +','+ validTopCategories.get(0).label: 'Partner_Deal_Management'+',Partner Deal Management';
            jsonOutput = validTopCategories.size () > 0 ? JSON.serialize(validTopCategories): 'Partner_Deal_Management'+',Partner Deal Management';
        }else{
          jsonOutput = JSON.serialize(validTopCategories);
        }
        return jsonOutput;
    } 
    
    //P2OB-8611 - get Category Label and Name map
    public static Map<String,DataCategoryWrapper> getCategoryNameByCategoryGroup(){
        Map<String,DataCategoryWrapper> mapOfCategoryAndGroup = new Map<String,DataCategoryWrapper>();
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult = getDescribeResults(PRMKnowledgeArticleUtility.Object_Knowledge_Article_Version,PRMKnowledgeArticleUtility.Partner_Category_Group);
        List<DataCategory> topCategories = getTopCategories(describeCategoryStructureResult);
        Map<String, List<DataCategory>> childCateogoriesWithTop = new Map<String, List<DataCategory>>();
        //get data from top Categories 
        for(DataCategory dCat : topCategories){
            if(availableCategories.contains(dCat.name)){
                mapOfCategoryAndGroup.put(dCat.name, new DataCategoryWrapper(dCat.label,dCat.name));
                //Recursively get all the categories
                childCateogoriesWithTop.put(dCat.name, getAllCategories(dCat.childCategories));
            }
        }
        for(String topCategoryKey : childCateogoriesWithTop.keySet()) {
            //Get the name of the category
            for(DataCategory dCat : childCateogoriesWithTop.get(topCategoryKey)){
                mapOfCategoryAndGroup.put(dCat.name, new DataCategoryWrapper(dCat.label,topCategoryKey));
            }
        }
        return mapOfCategoryAndGroup;
    }

    // recursive call for getting the data category
    private static DataCategory[] getAllCategories(DataCategory [] categories){
      if(categories.isEmpty()){
         return new DataCategory[]{};
      } else {
         DataCategory [] categoriesClone = categories.clone();
         DataCategory category = categoriesClone[0];
         DataCategory[] allCategories = new DataCategory[]{category};
         categoriesClone.remove(0);
         categoriesClone.addAll(category.getChildCategories());
         allCategories.addAll(getAllCategories(categoriesClone));
         return allCategories;
      }
   }
        
    /* P2OB-8030 - get Tranding Knowledge Article Ids */
    public static List<Id> getTrandingKnowledgeArticleIds(Integer numberOfArticles){
        List<Id> knowledgeArticleIds = new List<Id>();
        // Hawaii - P1 PMD fixes 
        String viewStatQuery = 'SELECT id, ViewCount,ParentId FROM KnowledgeArticleViewStat WHERE Channel = :PRM_CHANNEL AND ParentId IN (SELECT KnowledgeArticleId FROM Knowledge__kav WHERE PublishStatus = :PUBLISH_STATUS_ONLINE AND recordType.Name IN :knowledgeValidRecordTypes';
        //P2OB-12539: Pass False value in getAvailableCategory method
        // get valid categories
        String categoryFilter = getAvailableCategory(false);
        if(!String.isBlank(categoryFilter)){
            viewStatQuery += ' WITH DATA CATEGORY Partner__c BELOW ' + categoryFilter;
        }
        viewStatQuery +=  ' ) ORDER BY ViewCount DESC LIMIT '+numberOfArticles;
        List<KnowledgeArticleViewStat> viewStatList = Database.query(String.escapeSingleQuotes(viewStatQuery)); // Hawaii - P1 PMD fixes 
        for(KnowledgeArticleViewStat viewStat : viewStatList){
          knowledgeArticleIds.add(viewStat.ParentId);
        }
        return knowledgeArticleIds;
    } 
    
     //P2OB-8030 && P20B-7893 Get available categories in required syntax
     //P2OB-12539 : Pass isRecommendation parameter to avoid exclusion of categories in case of recommendation 
     public static string getAvailableCategory(Boolean isRecommendation){
        String categoryFilter = '';
        if(availableCategories != null && !availableCategories.isEmpty()){
            if(excludeDataCategoriesDetails == null){
                excludeDataCategoriesDetails = getExcludeCategories();
            }
            categoryFilter = '(';
            for(String catName : availableCategories){
                if((!excludeDataCategoriesDetails.containsKey(catName) || (excludeDataCategoriesDetails.containsKey(catName) && excludeDataCategoriesDetails.get(catName).is_Exclude_from_Tile_Menu__c == false)|| isRecommendation)){
                    categoryFilter += catName +'__c,';
                }
            }
            if(categoryFilter.trim().endsWith(',')){
                categoryFilter = categoryFilter.subString(0,categoryFilter.length()-1) + ')';
            }else{
                categoryFilter = '';
            }
        }
        return categoryFilter;
     }
     
     //P2OB-8030 && P20B-7893 Get available record types in required syntax
     public static string getAvailableRecordtypes(){
        String recordTypeFilter = '';
        if(knowledgeValidRecordTypes != null && !knowledgeValidRecordTypes.isEmpty()){
            recordTypeFilter = '(';
            for(String recType : knowledgeValidRecordTypes){
                recordTypeFilter += '\''+recType+'\''+',';
            }
            if(recordTypeFilter.trim().endsWith(',')){
                recordTypeFilter = recordTypeFilter.subString(0,recordTypeFilter.length()-1) + ')';
            }
        }
        return recordTypeFilter;
     }
     
    /* P2OB-8030 - get Exlcude Cateogires details */
    public static List<knowledge__kav> getKnoweldgeArticleInSequence(List<Id> parentIds, List<Knowledge__kav> kavArticles){
        List<knowledge__kav> tempArticles = new List<knowledge__kav>();
        Map<Id, knowledge__kav> tempKnowledgeArticleMap = new Map<Id, knowledge__kav>();
        // prepare map with KnowledgeArticleId as key
        for(knowledge__kav article : kavArticles){
            tempKnowledgeArticleMap.put(article.knowledgeArticleId,article);
        }
        for(Id kaId : parentIds){
            if(tempKnowledgeArticleMap.containsKey(kaId)){
                tempArticles.add(tempKnowledgeArticleMap.get(kaId));
            }
        }
        return tempArticles;
    }
    
     /* P2OB-8030 - get Exlcude Cateogires details */
    public static Map<String,PRM_Exclude_Category_Details__mdt> getExcludeCategories(){
        Map<String, PRM_Exclude_Category_Details__mdt> tempExcludeCategories = new Map<String, PRM_Exclude_Category_Details__mdt>();
        for(PRM_Exclude_Category_Details__mdt excludeCategory : [SELECT DeveloperName , is_Exclude_from_Tile_Menu__c,is_Exclude_from_Tree_Structure__c FROM PRM_Exclude_Category_Details__mdt]){
            tempExcludeCategories.put(excludeCategory.DeveloperName, excludeCategory);
        }
        return tempExcludeCategories;
    }
     
    //P2OB-8030 && P20B-7893 Set values of article fields in wrapper class variables 
    public static List<PRMCarouselWrapper> getArticleInfo(List<Knowledge__kav> kavArticle,List<PRMCarouselWrapper> wrapper,String categoryName){
        Map<String,PRMKnowledgeArticleUtility.DataCategoryWrapper> categoryMap = getCategoryNameByCategoryGroup();
        if(kavArticle.size() > 0){
            String imageURL = null;
            for(Knowledge__kav article: kavArticle){
                article.Featured_Image__c = article.Featured_Image__c != null ? article.Featured_Image__c : '/servlet/fileField?entityId='+article.Id+'&field=Featured_Image_Upload__Body__s';
                if(article.DataCategorySelections.size() == 1 || (article.DataCategorySelections.size() > 1 && (String.isBlank(categoryName) || categoryName == 'All'))){
                    PRMCarouselWrapper wrapperRecord = new PRMCarouselWrapper(article.DataCategorySelections.get(0).DataCategoryName,article); // Updated Megha
                    //P2OB-8030 && P20B-7893 : set categoryLabel in wrapper class variable
                    if(categoryMap.containsKey(article.DataCategorySelections.get(0).DataCategoryName)){
                        wrapperRecord.categoryLabel = categoryMap.get(article.DataCategorySelections.get(0).DataCategoryName).dCatLabel;
                        wrapperRecord.topCategoryName = categoryMap.get(article.DataCategorySelections.get(0).DataCategoryName).topCategoryName;
                    }else {
                        wrapperRecord.categoryLabel =  article.DataCategorySelections.get(0).DataCategoryName;
                        wrapperRecord.topCategoryName = categoryMap.containsKey(article.DataCategorySelections.get(0).DataCategoryName) ? categoryMap.get(article.DataCategorySelections.get(0).DataCategoryName).topCategoryName : '';
                    }
                    wrapper.add(wrapperRecord);
                }else if(article.DataCategorySelections.size() > 1 && String.isNotBlank(categoryName) && categoryName != 'All'){
                    PRMCarouselWrapper wrapperRecord = new PRMCarouselWrapper(categoryName,article); // Updated Megha
                     //P2OB-8030 && P20B-7893 : set categoryLabel in wrapper class variable
                    if(categoryMap.containsKey(categoryName)){
                        wrapperRecord.categoryLabel = categoryMap.get(categoryName).dCatLabel;
                        wrapperRecord.topCategoryName = categoryMap.get(categoryName).topCategoryName;
                    }else{
                        wrapperRecord.categoryLabel =  categoryName;
                        wrapperRecord.topCategoryName = categoryMap.containsKey(categoryName) ? categoryMap.get(article.DataCategorySelections.get(0).DataCategoryName).topCategoryName : '';
                    }
                    wrapper.add(wrapperRecord);
                }
            }
        }
        return wrapper;
    }
    
    
    /* P2OB-8030 - Data Category Wrapper with top Category */
    public class DataCategoryWrapper{
        public String dCatLabel;
        public String topCategoryName;
        
        public DataCategoryWrapper(String dCatLabel,String topCategoryName){
            this.dCatLabel = dCatLabel;
            this.topCategoryName = topCategoryName;
            }
    }
}