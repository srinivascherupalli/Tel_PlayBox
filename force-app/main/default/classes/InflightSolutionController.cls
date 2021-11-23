/**
 * @description       : 
 * @author            : Rajiv kumar singh
 * @group             : 
 * @last modified on  : 02-19-2021
 * @last modified by  : Rajiv kumar singh
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   02-19-2021    Rajiv kumar singh                    Initial Version
 
 11.05.2021     Arinjay Singh   EDGE-218063
**/
public with sharing class InflightSolutionController {
    //  EDGE-198709 Calling pushRemediationFlagToHeroku method after clicking of Amend Order button
        public InflightSolutionController(String orderId){
            csord__Order__c ord = [SELECT Id,csord__Status2__c FROM csord__Order__c WHERE Id=:orderId];
            Boolean result= HerokuConfigurationsUtility.pushRemediationFlagToHeroku(orderId);
            System.debug('HerokuConfigurationsUtility result: ' + result);
        }
        static Map<Id,String> amendMapForMasterSubscription = new Map<Id,String>(); 
        /*
        Method Name : getSolutions
        Description : This method will return all the solutions for the order.
        */
     @AuraEnabled
     public static Object getSolutions(string orderId){
         csord__Order__c ord = [SELECT Id,csord__Status2__c FROM csord__Order__c WHERE Id=:orderId];
         List<Object> solutionResultList = new List<Object>();
         List<csord__Subscription__c> subscriptionList = new  List<csord__Subscription__c>();
         set<Id> masterSubscriptionIdSet = new set<Id>();
         try {
            
             set<Id> solutionIdSet = new set<Id>();
             if(ord.csord__Status2__c == 'Amend Rejected'){
                 subscriptionList = [SELECT ID,Name,csord__Order__c,customerFacingServiceId__c,csord__Status__c,cssdm__solution_association__c,Point_of_No_Return_Reached__c,csordtelcoa__Product_Configuration__r.ConfigurationType__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,csordtelcoa__Product_Configuration__c FROM csord__Subscription__c WHERE csord__Order__c =:orderId AND csord__Status__c='Amend Rejected'];
             }else{
                 subscriptionList = [SELECT ID,Name,csord__Order__c,customerFacingServiceId__c,csord__Status__c,cssdm__solution_association__c,Point_of_No_Return_Reached__c,csordtelcoa__Product_Configuration__r.ConfigurationType__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c FROM csord__Subscription__c WHERE csord__Order__c =:orderId AND csord__Status__c != 'Amend Rejected'];
             }
             system.debug('subscriptionList '+subscriptionList.size());
             for(csord__Subscription__c sub : subscriptionList){
                 solutionIdSet.add(sub.cssdm__solution_association__c);
                 if(sub.csordtelcoa__Product_Configuration__c != null && (sub.csordtelcoa__Product_Configuration__r.ConfigurationType__c!=null || sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c!=null) && (sub.csordtelcoa__Product_Configuration__r.ConfigurationType__c=='SolutionComponent' ||sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c=='SolutionComponent')){
                    masterSubscriptionIdSet.add(sub.Id);
                 }
             }
             Map<Id,csord__Solution__c> solutionsMap = new Map<Id,csord__Solution__c>([SELECT Id,csord__Order__c,Name,csord__Status__c FROM csord__Solution__c WHERE Id IN :solutionIdSet]);
             Map<Id,List<csord__Subscription__c>> solutionSubscriptionMap = new Map<Id,List<csord__Subscription__c>>();
             for(csord__Subscription__c subs : subscriptionList){
                 if(solutionSubscriptionMap.containskey(subs.cssdm__solution_association__c)){
                     solutionSubscriptionMap.get(subs.cssdm__solution_association__c).add(subs);
                 }else{
                     solutionSubscriptionMap.put(subs.cssdm__solution_association__c, new List<csord__Subscription__c>{subs});
                 }
             }
             for(csord__Solution__c solution : solutionsMap.values()){
                 if(!solutionSubscriptionMap.containskey(solution.Id)){
                     solutionSubscriptionMap.put(solution.Id,new List<csord__Subscription__c>{});
                 }
             }
             
             for(csord__Solution__c sol : solutionsMap.values()){
                 String amendAllowed;
                 Boolean dmcategory = checkForDMCategory(sol.Id);
                 for(csord__Subscription__c subs : solutionSubscriptionMap.get(sol.Id)){
                     if(!masterSubscriptionIdSet.contains(subs.Id)){
                        if(subs.Point_of_No_Return_Reached__c){
                            amendAllowed = 'No';
                        }else{
                            amendAllowed = 'Yes';
                            break;
                        }
                     }
                 }
                 for(csord__Subscription__c subs : solutionSubscriptionMap.get(sol.Id)){
                    if(masterSubscriptionIdSet.contains(subs.Id)){
                        system.debug('amendMapForMasterSubscription '+amendMapForMasterSubscription);
                        amendMapForMasterSubscription.put(subs.Id,amendAllowed);
                    }
                 }
                 Map<String,Object> solRec = new Map<String,Object>();
                 solRec = (Map<String,Object>)getJSONStructureForSolution((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(sol)),'amendAllowed',amendAllowed);
                 solRec = (Map<String,Object>)getJSONStructureForSolution(solRec,'dmcategory',dmcategory);
                 system.debug('solRec '+solRec);
                 solutionResultList.add(solRec);
             }
            
             
         } catch (Exception e) {
             throw new AuraHandledException(e.getMessage());
         }
         return solutionResultList;
     }
     /*
     Method Name : getJSONStructureForSubscription
      Description : This method will modify the json format for solution record.
      */
    public static Object getJSONStructureForSubscription(Object recordObject){
        system.debug('amendMapForMasterSubscription '+amendMapForMasterSubscription);
        Map<String,Object> record = (Map<String,Object>)recordObject;
        String recordurl = url.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/csord__Subscription__c/'+record.get('Id')+'/view';
        record.put('recordurl',recordurl);
        String amendAllowed;
        String estiatedPONRDate;
        if(record.containskey('Point_of_No_Return_Reached__c') && Boolean.valueOf(record.get('Point_of_No_Return_Reached__c'))){
         amendAllowed = 'No';
        }else{
         amendAllowed = 'Yes';
        }
        if(record.containskey('Id') && amendMapForMasterSubscription.containskey((Id)record.get('Id'))){
            amendAllowed = amendMapForMasterSubscription.get((Id)record.get('Id'));
        }
        if((record.containskey('Point_of_No_Return_Reached__c') && Boolean.valueOf(record.get('Point_of_No_Return_Reached__c'))) && (record.containskey('cancel_Point_of_No_Return_Reached__c') && Boolean.valueOf(record.get('cancel_Point_of_No_Return_Reached__c')))){
         estiatedPONRDate = 'N/A';
        }else if((record.containskey('Point_of_No_Return_Reached__c') && !Boolean.valueOf(record.get('Point_of_No_Return_Reached__c'))) && (record.containskey('cancel_Point_of_No_Return_Reached__c') && !Boolean.valueOf(record.get('cancel_Point_of_No_Return_Reached__c')))){
           if( record.containskey('Estimated_PONR_Date__c') && record.get('Estimated_PONR_Date__c') == null ){
             estiatedPONRDate = ' ';
           }else{
             if(record.get('Estimated_PONR_Date__c') != null && record.get('Estimated_PONR_Date__c') != ''){
                 estiatedPONRDate = String.valueOf(record.get('Estimated_PONR_Date__c')).split('T')[0];
             }else{
                 estiatedPONRDate = String.valueOf(record.get('Estimated_PONR_Date__c'));
             }
           }
        }
        record.put('amendAllowed',amendAllowed);
        record.put('estiatedPONRDate',estiatedPONRDate);
        return record;
    }
    /*
     Method Name : getJSONStructureForSolution
      Description : This method will modify the json format.
      */
    public static Object getJSONStructureForSolution(Object recordObject,String key,Object value){
     Map<String,Object> record = (Map<String,Object>)recordObject;
     record.put(key,value);
     return record;
 }
   /*
     Method Name : getOpportunityIdForTheOrder
      Description : This method will get the opportunity Id record using order Id
      */
    @AuraEnabled
    public static string getOpportunityIdForTheOrder(String orderId){
       return [SELECT csordtelcoa__Opportunity__c FROM csord__Order__c WHERE ID=:orderId].csordtelcoa__Opportunity__c;
    }
      /*
     Method Name : getOpportunityRoleRecord
      Description : This method will get the opportunity role record using order Id
      */
    @AuraEnabled
    public static OpportunityContactRole getOpportunityRoleRecord(String orderId){
     OpportunityContactRole ocr;
     csord__Order__c orderRecord = [SELECT Id,Product_Basket__c,csordtelcoa__Opportunity__c FROM csord__Order__c WHERE Id=:orderId];
     if(orderRecord.csordtelcoa__Opportunity__c != null){
         ocr = [SELECT ID,ContactId,Contact_Name__c,OpportunityId FROM OpportunityContactRole WHERE OpportunityId=:orderRecord.csordtelcoa__Opportunity__c];
     }
     system.System.debug('ocr '+ocr);
     return ocr;
    }
     /*EDGE-201556
     Method Name : getSolutionsOnSerach
      Description : This method will search the solutions based on order Id and search key
      */
    @AuraEnabled
    public static Object getSolutionsOnSerach(String searchKey,String orderId){
     Map<String,Object> resultMap = new Map<String,Object>();
     set<Id> masterSubscriptionIdSet = new set<Id>();
     csord__Order__c ord = [SELECT Id,csord__Status2__c FROM csord__Order__c WHERE Id=:orderId];
     List<Object> solutionResultList = new List<Object>();
     System.debug('searchKey in apex '+searchKey);
     resultMap.put('serach key',searchKey);
       List<csord__Solution__c> solutionList;
       set<Id> solutionIdSet = new set<Id>();
       List<csord__Subscription__c> subscriptionList;
       if(searchKey!=null){
         system.debug('search key '+searchKey.trim());
            if(ord.csord__Status2__c == 'Amend Rejected'){
             searchKey = '%'+searchKey.trim()+'%';
             subscriptionList = [SELECT Id,Name,customerFacingServiceId__c,cssdm__solution_association__c,Point_of_No_Return_Reached__c,csord__Status__c,csordtelcoa__Product_Configuration__r.ConfigurationType__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c FROM csord__Subscription__c WHERE (customerFacingServiceId__c LIKE : searchKey OR csordtelcoa__Subscription_Number__c LIKE : searchKey OR Name LIKE : searchKey) AND csord__Order__c=:orderId AND csord__Status__c='Amend Rejected'];
            }else{
             searchKey = '%'+searchKey.trim()+'%';
             subscriptionList = [SELECT Id,Name,customerFacingServiceId__c,cssdm__solution_association__c,Point_of_No_Return_Reached__c,csord__Status__c,csordtelcoa__Product_Configuration__r.ConfigurationType__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c FROM csord__Subscription__c WHERE (customerFacingServiceId__c LIKE : searchKey OR csordtelcoa__Subscription_Number__c LIKE : searchKey OR Name LIKE : searchKey) AND csord__Order__c=:orderId AND csord__Status__c!='Amend Rejected'];
            }
          system.debug('subscriptionList '+subscriptionList);
         if(subscriptionList!=null){
             for(csord__Subscription__c sub : subscriptionList){
                 solutionIdSet.add(sub.cssdm__solution_association__c);
                 if(sub.csordtelcoa__Product_Configuration__c != null && (sub.csordtelcoa__Product_Configuration__r.ConfigurationType__c!=null || sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c!=null) && (sub.csordtelcoa__Product_Configuration__r.ConfigurationType__c=='SolutionComponent' ||sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c=='SolutionComponent')){
                    masterSubscriptionIdSet.add(sub.Id);
                 }
             }
         }
         solutionList = [SELECT ID,Name,csord__Status__c FROM csord__Solution__c WHERE Id IN : solutionIdSet];
         Map<Id,List<csord__Subscription__c>> solutionSubscriptionMap = new Map<Id,List<csord__Subscription__c>>();
         for(csord__Subscription__c subs : subscriptionList){
             if(solutionSubscriptionMap.containskey(subs.cssdm__solution_association__c)){
                 solutionSubscriptionMap.get(subs.cssdm__solution_association__c).add(subs);
             }else{
                 solutionSubscriptionMap.put(subs.cssdm__solution_association__c, new List<csord__Subscription__c>{subs});
             }
         }
         for(csord__Solution__c sol : solutionList){
             String amendAllowed;
             Boolean dmcategory = checkForDMCategory(sol.Id);
             for(csord__Subscription__c subs : solutionSubscriptionMap.get(sol.Id)){
                 if(subs.Point_of_No_Return_Reached__c){
                     amendAllowed = 'No';
                 }else{
                     amendAllowed = 'Yes';
                     break;
                 }
             }
             for(csord__Subscription__c subs : solutionSubscriptionMap.get(sol.Id)){
                if(masterSubscriptionIdSet.contains(subs.Id)){
                    system.debug('amendMapForMasterSubscription '+amendMapForMasterSubscription);
                    amendMapForMasterSubscription.put(subs.Id,amendAllowed);
                }
             }
             Map<String,Object> solRec = new Map<String,Object>();
             solRec = (Map<String,Object>)getJSONStructureForSolution((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(sol)),'amendAllowed',amendAllowed);
             solutionResultList.add(solRec);
         }
         if(subscriptionList!=null && subscriptionList.size() > 0){
            // 
             resultMap.put('Solution list',solutionResultList);
             resultMap.put('Subscription list',subscriptionList);
             resultMap.put('serach key',searchKey);
         }
       }
       system.debug('result is '+resultMap);
       return resultMap;
    }
      /*
     Method Name : getOrderNumber
      Description : This method will provide order order number
      */
    @AuraEnabled
    public static string getOrderNumber(String orderId){
        String orderNumber;
        try {
            if(orderId!=null && orderId!=''){
             orderNumber = [SELECT csord__Order_Number__c FROM csord__Order__c WHERE ID =: orderId].csord__Order_Number__c;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return orderNumber;
    }
      /*
     Method Name : getOrderDetails
      Description : This method will provide order record details
      */
    @AuraEnabled
    public static Object getOrderDetails(String orderId){
        InflightSolutionController inflight = new InflightSolutionController(orderId);
      if(orderId != null){
          return [SELECT Id,Push_Heroku_Configurations_Job_Id__c FROM csord__Order__c WHERE Id=:orderId LIMIT 1];
      }else{
          return null;
      }
    }
    @AuraEnabled
    public static List<String> getPicklistvalues(String objectName, String field_apiname,Boolean nullRequired){
     List<String> optionlist = new List<String>();       
     Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
     Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
     List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();       
     if(nullRequired == true){
         optionlist.add('--None--');
     }       
     for (Schema.PicklistEntry pv : picklistValues) {
         optionlist.add(pv.getValue());
     }
     return optionlist;
 }
  /*
     Method Name : checkLoggedInUserProfile
      Description : Check for logged in user profile
      */
    @AuraEnabled
    public static Boolean checkLoggedInUserProfile(){
        Boolean showTelstraCaseNumber = false;
        Id userID = UserInfo.getUserId();
        String profileName = [SELECT Id,Profile.Name FROM User WHERE Id=:userID].Profile.Name;
        if(profileName == 'Assurance Service Agent'){
            showTelstraCaseNumber = true;
        }
        return showTelstraCaseNumber;
    }
    
      /*
     Method Name : checkForPointOfNoContact
      Description : Get all the subscriptions according to amendment FLAG. EDGE -201556
      */
  @AuraEnabled
  public static Object getSubscriptions(String solutionId,String serachKey,String orderId,boolean amendRejected,String amendAllowed){
     List<csord__Subscription__c> subscriptionList;
     List<Object> subscriptionObjectList = new List<Object>();
     if(solutionId!=null){
         if(serachKey!=null && serachKey!=''){
             serachKey = '%'+serachKey+'%';
             if(amendRejected){
                subscriptionList = Database.query('SELECT ID,Name,Estimated_PONR_Date__c,csordtelcoa__Subscription_Number__c,csord__Status__c,customerFacingServiceId__c,Point_of_No_Return_Reached__c,cancel_Point_of_No_Return_Reached__c,csordtelcoa__Product_Configuration__r.ConfigurationType__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c FROM csord__Subscription__c WHERE cssdm__solution_association__c =: solutionId AND (customerFacingServiceId__c LIKE : serachKey OR Name LIKE : serachKey) AND csord__Order__c=:orderId AND csord__Status__c=\'Amend Rejected\'');
             }else{
                subscriptionList =  Database.query('SELECT ID,Name,Estimated_PONR_Date__c,csordtelcoa__Subscription_Number__c,csord__Status__c,customerFacingServiceId__c,Point_of_No_Return_Reached__c,cancel_Point_of_No_Return_Reached__c,csordtelcoa__Product_Configuration__r.ConfigurationType__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c FROM csord__Subscription__c WHERE cssdm__solution_association__c =: solutionId AND (customerFacingServiceId__c LIKE : serachKey OR Name LIKE : serachKey) AND csord__Order__c=:orderId AND csord__Status__c!=\'Amend Rejected\'');
             }
         }else{
            if(amendRejected){
                subscriptionList = Database.query('SELECT ID,Name,Estimated_PONR_Date__c,csordtelcoa__Subscription_Number__c,csord__Status__c,customerFacingServiceId__c,Point_of_No_Return_Reached__c,cancel_Point_of_No_Return_Reached__c,csordtelcoa__Product_Configuration__r.ConfigurationType__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c FROM csord__Subscription__c WHERE cssdm__solution_association__c =: solutionId AND csord__Order__c=:orderId AND csord__Status__c=\'Amend Rejected\'');
            }else{
                subscriptionList = Database.query('SELECT ID,Name,Estimated_PONR_Date__c,csordtelcoa__Subscription_Number__c,csord__Status__c,customerFacingServiceId__c,Point_of_No_Return_Reached__c,cancel_Point_of_No_Return_Reached__c,csordtelcoa__Product_Configuration__r.ConfigurationType__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c FROM csord__Subscription__c WHERE cssdm__solution_association__c =: solutionId AND csord__Order__c=:orderId AND csord__Status__C!=\'Amend Rejected\'');
            }
         }
         for(csord__Subscription__c sub : subscriptionList){
            if(sub.csordtelcoa__Product_Configuration__c != null && (sub.csordtelcoa__Product_Configuration__r.ConfigurationType__c!=null || sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c!=null) && (sub.csordtelcoa__Product_Configuration__r.ConfigurationType__c=='SolutionComponent' ||sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c=='SolutionComponent')){
                amendMapForMasterSubscription.put(sub.Id,amendAllowed);
            }
        }
         for(csord__Subscription__c subs : subscriptionList){
             Map<String,Object> subRec = new Map<String,Object>();
             subRec = (Map<String,Object>)getJSONStructureForSubscription((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(subs)));
             subscriptionObjectList.add(subRec);
         }
     }
     return subscriptionObjectList;
  }
    /*
     Method Name : checkForPointOfNoContact
      Description : This method is check for Point of no Contact
      */
  @AuraEnabled
  public static Object checkForPointOfNoContact(String orderId){
    InflightSolutionController infController = new InflightSolutionController(orderId);
      Boolean result = false;
      Map<String,Object> resultMap = new Map<String,Object>();
     csord__Order__c ord = [SELECT Id,csordtelcoa__Point_of_No_Return_Reached__c,csord__Status2__c FROM csord__Order__c WHERE Id=:orderId];
     if(ord.csord__Status2__c == 'Amend Rejected'){
         result = true;
         resultMap.put('amend rejected',true);
     }else{
         if(ord.csordtelcoa__Point_of_No_Return_Reached__c){
                 result = false;
                 resultMap.put('PONR reached',false);
         }else{
             resultMap.put('PONR reached',true);
            if(ord.csord__Status2__c == 'in Progress'){
                result = true;
                resultMap.put('order status',true);
            }else{
             resultMap.put('order status',false);
            }
         }
     }
     return resultMap;
  }
 
     @AuraEnabled
     public static String getJobStatus(String targetBasketid){
         return InflightBasketUtility.getJobStatus(targetBasketid);
     }
 
     @AuraEnabled
     public static String onAmend(String orderId,List<String> solutionIdSet,String teslStraCaseNumber,String amendType){
         system.debug('telstra case number '+teslStraCaseNumber);
         system.debug('amend type '+amendType);
         System.debug('order Id '+orderId);
         System.debug('solutions '+solutionIdSet);
         List<Map<String,String>> result = InflightBasketUtility.createInFlightBasket(orderId, solutionIdSet); 
         System.debug('Basket Created and Solution Added');
         String serData = null;
          String errorMessage = '';
         if(!result.isEmpty() && result != null){
          errorMessage = result.get(0).get('errorMessage');
         }
         
         if(errorMessage == null && result.size() > 0) {
             String targetBasketId = result.get(0).get('targetBasketId');
             Map<String, List<Map<String,String>>> basketMap = new Map<String, List<Map<String,String>>>();
             basketMap.put(targetBasketId,result);
             serData = JSON.serialize(basketMap);
             System.debug('Check serData = ' + serData);
         }
         else
             serData = 'error=' + errorMessage;
         return serData;
         
     }
 
     @AuraEnabled
     public static String updateBasketAndOpty(String basketId, String amendType, String caseId){
         Boolean result = false;
         try{
             result = InflightBasketUtility.updateBasket(basketId, amendType, caseId);
             if(result){
                 result = InflightBasketUtility.updateOpportunity(basketId);
             }
         }
         catch(Exception e){
             /*Logger2 logger = Logger2.getlogger('InflightSolutionController');
             logger.logMessages('', '', '', 'Technical', 'Unable to update basket or opportunity',e.getLineNumber() + ' ' + e.getMessage(), false, false);
             logger.exitLogger();*/
         }
         if(result) 
             return 'SUCCESS'; 
         else 
             return 'FAILURE';
        
     }
 
     @AuraEnabled
     public static String getTargetMainConfigurationId(String basketId, String data){
         Logger2 logger = Logger2.getlogger('InflightSolutionController');
         logger.logMessages('', '', '', 'Technical', 'Data to push to Heroku is ',data, false, false);
         logger.exitLogger();
 
         List<Map<String, String>> lstData=(List<Map<String, String>>)JSON.deserialize(data,List<Map<String, String>>.class);
         String targetMainConfigId = null;
         if (data != null) {
             for (Map<String, String> dataToPush : lstData) {
                 logger = Logger2.getlogger('InflightSolutionController');
                 logger.logMessages('', '', '', 'Technical', 'dataToPush.get(basketId) ',dataToPush.get('targetBasketId'), false, false);
                 logger.logMessages('', '', '', 'Technical', 'dataToPush.get(replacedSolutionId) ',dataToPush.get('replacedMainConfigurationId'), false, false);
                 logger.exitLogger();
                 targetMainConfigId =  InflightBasketUtility.getTargetMainConfigurationId(dataToPush.get('targetBasketId'),dataToPush.get('replacedMainConfigurationId'));
                 break;
             }
         }
         logger = Logger2.getlogger('InflightSolutionController');
         logger.logMessages('', '', '', 'Technical', 'targetMainConfigId is ',targetMainConfigId, false, false);
         logger.exitLogger();
         return targetMainConfigId;
     }
     @AuraEnabled
     public static String postInflightBasketProcessing(String data, String replacedMainConfigurationId){
         List<Map<String, String>> lstData=(List<Map<String, String>>)JSON.deserialize(data,List<Map<String, String>>.class);
         String result = 'FAILURE';
         if (data != null) {
             result =  InflightBasketUtility.pushSolutionToHeroku(data ,replacedMainConfigurationId);
         }
         return result;
     }
     
     /*EDGE-194442 - In-Flight: Restrict offers ineligible for Inflight Amend
     Method Name:checkForDMCategory
      Description : This method checks if the selected solution has the correct Marketable offer
      */
     
     @AuraEnabled
     public static boolean checkForDMCategory(String solutionId){
         boolean result = false;
          try {
              List<csord__Subscription__c> subscriptionList = [SELECT Id,ConfigSpecID__c, MarketableOffer__r.Offer_ID__c  FROM csord__Subscription__c WHERE cssdm__solution_association__c=:solutionId];
             List<Offers_allowed_for_inflight_amend__mdt> offersAllowedForInflightAmendList = [SELECT Offer_Name__c,DM_Category__c FROM Offers_allowed_for_inflight_amend__mdt];
             set<String> dmCategorySet = new set<String>();
              for(Offers_allowed_for_inflight_amend__mdt mdtRec : offersAllowedForInflightAmendList){
                  system.debug('dm cat metadata '+mdtRec.DM_Category__c);
                  dmCategorySet.add(mdtRec.DM_Category__c);
              }
              for(csord__Subscription__c subRec : subscriptionList){
                  system.debug('DM Cat '+subRec.MarketableOffer__r.Offer_ID__c);
                  if(subRec.MarketableOffer__r.Offer_ID__c != null && dmCategorySet.contains(subRec.MarketableOffer__r.Offer_ID__c)){
                      result = true;
                      break;
                  }else if(subRec.MarketableOffer__r.Offer_ID__c == null){
                    result = true;
                  }else{
                      result = false;
                 }
             }
          } catch (Exception e) {
              throw new AuraHandledException(e.getMessage());
          }
         return result;
     }
     /*
     Method Name : getDefaultValues
      Description : This method is used to prepopulate the Requestor, Amend type and telstra case number.
      */
     @AuraEnabled
     public static Object getDefaultValues(boolean amendRejected,String orderId){
        Map<String,Object> result = new Map<String,Object>();
        cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c();
        csord__Order__c ord = [SELECT Product_Basket__c,csordtelcoa__Opportunity__c FROM csord__Order__c WHERE Id=:orderId];
        system.debug('ord '+ord);
        //if(ord.Product_Basket__c != null){
            //Shweta changed SalesSupport_CaseNumber__r.CaseNumber to referencenumber__c for EDGE-205081,EDGE-204575
          //prodBasket = [SELECT Id,Order_Requester__c,Amend_Type__c,referencenumber__c FROM cscfga__Product_Basket__c WHERE Id=:ord.Product_Basket__c  LIMIT 1];
        //}else{
          if(ord.csordtelcoa__Opportunity__c != null){
            prodBasket = [SELECT Id,Order_Requester__c,Amend_Type__c,referencenumber__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__c=:ord.csordtelcoa__Opportunity__c AND csordtelcoa__Basket_Stage__c = 'Submitted'  Order By createdDate DESC LIMIT 1];
          }
        //}
        
        system.debug('prod basket '+prodBasket);
        if(prodBasket.Order_Requester__c != null){
         result.put('requestor',prodBasket.Order_Requester__c);
        }
        if(prodBasket.Amend_Type__c != null){
         result.put('amed type',prodBasket.Amend_Type__c);
        }
        if(prodBasket.referencenumber__c != null){
         result.put('tesltra case number',prodBasket.referencenumber__c);
        }
         
        system.debug('result for default val '+result);
        return result;
     }

    /*
        EDGE - 218063
        Method Name : checkAmendRestriction
        Description : Method Checking if Amend is allowed or not
    */
    @AuraEnabled
    public static Object checkAmendRestriction(String orderId){
        Map<String,Object> resultMap = new Map<String,Object>();
       
        csord__Order__c order = [SELECT Id,csord__Status2__c,csordtelcoa__Opportunity__c,Fulfilment_Order_Version__c FROM csord__Order__c WHERE Id=:orderId];
        List<cscfga__Product_Basket__c> prodBasketList = [
            SELECT id, csordtelcoa__Basket_Stage__c, RecordType.Name, cscfga__Opportunity__c,BasketType__c
            FROM cscfga__Product_Basket__c
            WHERE  RecordType.Name = 'Inflight Change' AND cscfga__Opportunity__c = :order.csordtelcoa__Opportunity__c
            ORDER BY CreatedDate desc LIMIT 1
        ];
        if(System.Label.Restrict_Amend_On_Amend == 'Yes'
           && order != null
           && prodBasketList != null 
           && prodBasketList.size() > 0
           && order.csord__Status2__c != 'Amend Rejected'
           && order.Fulfilment_Order_Version__c > 1
           && prodBasketList.get(0).BasketType__c != 'Remediate'
          ){
              resultMap.put('Amend Restricted',true);
              return resultMap;
          }
        
        resultMap.put('Amend Restricted',false);
        return resultMap;
    }
 }