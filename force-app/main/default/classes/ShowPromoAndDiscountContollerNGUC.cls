/*
* @Author : Shubhi
* @Date : 17 feb 2020
* @Desc : controller class for lightning cmponent to fetch table data for NGUC Device
* @Jira : Edge-135837
1. 133882 updated by shubhi 
// modified by shubhi for Edge-143527

*@TestClass: ShowPromoAndDiscountContollerNGUCTest */
public with Sharing class ShowPromoAndDiscountContollerNGUC{
    /*created by shubhi*/
    /*method to fetch selected priceitem salesforce id Edge-135837*/    
    public static String fetchCommercialProductIDFromSolution(Map<String,SolutionDTO.Attributes> attMap,String configGuid,String solutionName){
        String CommercialProductId = '';
        system.debug('configGuid' + configGuid);
        Map <String,String> DiscountConstantsMap = DiscountConstants.GetDiscountConstBasedonSolName(solutionName);
        system.debug('DiscountConstantsMap...' + DiscountConstantsMap);
        if (DiscountConstantsMap.size() > 0){
            String shadowTCVIdentifier = '';
            String commercialProductIdentifier = '';
            if(DiscountConstantsMap.containsKey('commercialProductIdentifier')) {
                commercialProductIdentifier = DiscountConstantsMap.get('commercialProductIdentifier');
            }
            system.debug('@@@AttMap-->' + AttMap);
            if (!String.IsBlank(commercialProductIdentifier) && AttMap.containsKey(commercialProductIdentifier) && !String.isBlank(AttMap.get(commercialProductIdentifier).value)) {
                CommercialProductId = AttMap.get(commercialProductIdentifier).value;
            }
        }
        return CommercialProductId;
    }
    
    /*created by shubhi*/
    /*method to get final applicable + eligible discount Dto for  selected priceitem Edge-135837*/  
    //added attmap as new param  Edge-143527
    public static Map < String, Set < cspmb__Discount_Level__c >> getEligibleDiscountMap(String accountID ,String solutionID, String configGuid, String solutionName,Map<String,SolutionDTO.Attributes> attMap){ 
    Map<String,Set<cspmb__Discount_Level__c>> eligibleDiscountMap=new Map<String,Set<cspmb__Discount_Level__c>>();  
        if(!String.isBlank(accountID) && !String.isBlank(solutionID) && !String.isBlank(configGuid) && !String.isBlank(solutionName) && attMap!=null && attMap.size()>0){  
      System.debug('attMap NGUC...'+attMap);// Edge-143527 Edge-143527
      String  commercialProductID = fetchCommercialProductIDFromSolution(attMap,configGuid,solutionName);
      System.debug('commercialProductID NGUC...'+commercialProductID);
      //applicable discount list
      Map<String,List<cspmb__Discount_Level__c>> applicableDiscountMap = ShowPromotionAndDiscountHandlerClass.fetchApplicableDiscounts(accountId,commercialProductID,'');     
      if(applicableDiscountMap.size()>0){
        system.debug('applicableDiscountMap keyset...'+applicableDiscountMap.keySet());
        Map<String,Promotion_Metadata__mdt> promotionalMetadataMap=ShowPromotionAndDiscountHandlerClass.fetchPromotionMetadata(applicableDiscountMap.keySet());
        Set<String> busIdforDisLevelEligibleRec=new Set<String>();
        Set<String> attributesTobeMatched=new Set<String>();
        if(!promotionalMetadataMap.isEmpty()){
          for(String s:promotionalMetadataMap.keySet()){
            if(promotionalMetadataMap.get(s).ReferenceObject__c!=null){
              busIdforDisLevelEligibleRec.add(s);
              attributesTobeMatched.add(promotionalMetadataMap.get(s).ReferenceAttribute__c);
              
            }else{
              if(applicableDiscountMap.containskey(s)){
                Set<cspmb__Discount_Level__c> setDisMap=new Set<cspmb__Discount_Level__c>(); 
                setDisMap.addAll(applicableDiscountMap.get(s));
                if(setDisMap.size()>0){
                  eligibleDiscountMap.put(s,setDisMap);
                }
              }
            }
          }
          String queryCondition='Business_ID__c IN: busIdforDisLevelEligibleRec AND  Is_Delegated__c=true AND Account__c =: accountID';
          List < cspmb__Discount_Level__c > toBeEligibleDiscounts = getToBeEligibleDiscounts(queryCondition,busIdforDisLevelEligibleRec,accountID);
          system.debug('eligible discount-->'+toBeEligibleDiscounts);
          Map < String, String >attributeToValueMap=new Map < String, String >();
          if(!attributesTobeMatched.isEmpty()){
            attributeToValueMap=ShowPromotionAndDiscountHandlerClass.fetchAttributeValueMapFromSolution(attributesTobeMatched,attMap);
          }
          system.debug('@@atMap-->'+attributeToValueMap);
          if(toBeEligibleDiscounts.size()>0){
            for(cspmb__Discount_Level__c dl1:toBeEligibleDiscounts){
              Set<cspmb__Discount_Level__c> dislevelList=new Set<cspmb__Discount_Level__c>();
              //for(cspmb__Discount_Level__c dl1:toBeEligibleDiscounts){
              if(eligibleDiscountMap!=null && eligibleDiscountMap.containsKey(dl1.Business_ID__c)){
                if(eligibleDiscountMap.get(dl1.Business_ID__c)!=null)
                  dislevelList.addAll(eligibleDiscountMap.get(dl1.Business_ID__c));
              }
              if(promotionalMetadataMap.containsKey(dl1.Business_ID__c) && attributeToValueMap.size()>0
                 && dl1.get(promotionalMetadataMap.get(dl1.Business_ID__c).ReferenceField__c)==attributeToValueMap.get(promotionalMetadataMap.get(dl1.Business_ID__c).ReferenceAttribute__c)){
                   cspmb__Discount_Level__c dl=new cspmb__Discount_Level__c();
                   dl.name = dl1.name;
                                dl.Description__c = dl1.Description__c;
                                dl.cspmb__Discount__c=dl1.cspmb__Discount__c;
                                dl.cspmb__duration__c = dl1.cspmb__duration__c;
                                dl.Business_ID__c = dl1.Business_ID__c;
                                dl.cspmb__Discount_Type__c =dl1.cspmb__Discount_Type__c;
                                dl.plan__c = dl1.Plan__c;
                                // added start and end date class in query for Edge-133882
                                dl.Effective_End_Date__c=dl1.Effective_End_Date__c;
                                dl.Effective_Start_Date__c=dl1.Effective_Start_Date__c;    
                                dl.discountClass__c=dl1.discountClass__c;
                 dislevelList.add(dl);
               }
               if(dislevelList!=null && !dislevelList.isEmpty()){
                 eligibleDiscountMap.put(dl1.Business_ID__c,dislevelList);
               }
            }
          }
        }
      }
    }
        return eligibleDiscountMap;       
    }
    //Edge-135837 aded by shubhi to pass data to lightning // method modified by shubhi for Edge-143527
    @AuraEnabled
    public static List<DiscountDTO> getDiscountdata(String accountID,String solutionID, String configGuid, String solutionName,Object mapJsonString){
        List < DiscountDTO > discountDTOList = new List < DiscountDTO > ();
        //Edge-143527 syart
        if(mapJsonString!=null){
        Map<String,SolutionDTO.Attributes>  Attmap = (Map<String,SolutionDTO.Attributes>)JSON.deserialize(String.valueOf(mapJsonString), Map<String,SolutionDTO.Attributes>.class);
        Map<String,Set<cspmb__Discount_Level__c>> eligibleDiscountMap=getEligibleDiscountMap(accountID,solutionID,configGuid,solutionName,Attmap);
        system.debug('@@atMap-->'+eligibleDiscountMap);
            // Edge-143527 end
        for(String busId:eligibleDiscountMap.keySet()){
            for(cspmb__Discount_Level__c dl:eligibleDiscountMap.get(busId)){
                DiscountDTO dto=ShowPromotionAndDiscountHandlerClass.getDiscounTDTOData(dl); 
                //created common method in handler class so that consistency can be maintained  Edge-133882       
                discountDTOList.add(dto);
            }
        }
        }
        return discountDTOList;
        
    }
    //Edge-135837 aded by shubhi to fetch dynamic data for reference object in this case discount level 
  public static List <cspmb__Discount_Level__c> getToBeEligibleDiscounts(String queryCondition, set<String> busIdforDisLevelEligibleRec, String accountID){       
        List < cspmb__Discount_Level__c > toBeEligibleDiscounts = new List < cspmb__Discount_Level__c > ();
    String SobjectApiName = 'cspmb__Discount_Level__c';
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
    String commaSepratedFields = '';
    String query='';
    for(String fieldName : fieldMap.keyset()){
      if(commaSepratedFields == null || commaSepratedFields == ''){
        commaSepratedFields = fieldName;
      }else{
        commaSepratedFields = commaSepratedFields + ', ' + fieldName;
      }
    }
    if(String.isNotBlank(queryCondition))
      query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName+' where '+queryCondition;
    else
      query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName;
    toBeEligibleDiscounts = Database.query(query);
    
    return toBeEligibleDiscounts;
    }


}