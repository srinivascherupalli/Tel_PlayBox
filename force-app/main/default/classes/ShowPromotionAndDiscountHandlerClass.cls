/*
* @Author : Shubhi(Edge-135837)
* @Date : 17 feb 2020
* @Desc : handler class for common methods for lightning cmponent to fetch table data and show promotions and discounts
* @Jira : Edge-135837
*@TestClass: ShowPromotionAndDiscountHandlerClassTest 
===============================================================================================================================
Sr.No.  Developer Name      Date          Story Description 
1.      Shubhi          23.3.2020       Edge-133882
2.      Aman Soni       13.05.2020      EDGE-148661-->Duration should be Life of Subscription when discount is Unlimited
===============================================================================================================================
*/
public with sharing class ShowPromotionAndDiscountHandlerClass  {

    /*method to fetch custom metadata Edge-135837*/ // updated added check for isActive and Eligibility_Pattern__c
    public static Map < String, Promotion_Metadata__mdt > fetchPromotionMetadata(Set< String > businessIdList) {
        Map < String, Promotion_Metadata__mdt > promotionalMetadataMap = new Map < String, Promotion_Metadata__mdt > ();
        if(businessIdList!=null && businessIdList.size()>0){
            for(Promotion_Metadata__mdt pm: [SELECT id, DeveloperName, BusinessID__c,
                                            Category__c, IsDelegated__c,ReferenceAttribute__c, ReferenceField__c, ReferenceObject__c, Eligibility_Pattern__c
                                            FROM Promotion_Metadata__mdt where BusinessID__c IN: businessIdList AND isActive__c = true]) {
              promotionalMetadataMap.put(pm.BusinessID__c, pm);
          }
        }
        system.debug('promotionalMetadataMap...'+promotionalMetadataMap);
        return promotionalMetadataMap;
    }
    /*method to fetch custom selected pritem salesforce Edge-135837//added by shubhi*/
    /*method to parse solutionDto*/
    public static Map<String,SolutionDTO.Attributes> getAttMapfromSolution(String solutionID,String SolutionName, String configGuid){
        Map<String,SolutionDTO.Attributes> attmap=new Map<String,SolutionDTO.Attributes>();
        Attachment currentSolutionJSON=new Attachment();
        if(!String.isBlank(solutionID)){
            currentSolutionJSON=[Select id,body,parentid from attachment where parentID=:solutionID];
            String solutionJson=currentSolutionJSON.body.toString();  
          system.debug('@@@currentSolutionJSON@@@'+solutionJson);
          List<SolutionDTO> solutionDTO = SolutionDTO.parse(solutionJson);
          for(SolutionDTO sol:solutionDTO){
                if(sol.name==SolutionName){
                    Map<String,SolutionDTO.Configurations> congToAttMap=new Map<String,SolutionDTO.Configurations>();
                    congToAttMap=sol.Configurations;
                    system.debug('congToAttMap---->'+congToAttMap);
                    if(!String.isBlank(configGuid) && !congToAttMap.isEmpty() && congToAttMap.containsKey(configGuid)){
                        AttMap=congToAttMap.get(configGuid).attributes;
                }
            }
        }
        system.debug('Attribute map'+attmap);
        }
        
        return attmap;
    }
    /* method to fetch attribute values from solution that are needed in promotion Edge-135837*/
    public static Map < String, String > fetchAttributeValueMapFromSolution(Set < String > attributeList, Map<String,SolutionDTO.Attributes> attMap) {
        Map < String, String > attributeTovalueMap = new Map < String, String > ();
        if (AttMap!=null && !AttMap.isEmpty()) {
            for (String attName: AttMap.keyset()) {
               if (attributeList!=null && attributeList.contains(attName)) {
                attributeTovalueMap.put(attName, AttMap.get(attName).value);
               }
            }
        }
        return attributeTovalueMap;
    }
        
    /*method to fetch applicable diacounts Edge-135837*/
    // Added cspmb__Discount_Level__r.is_Unlimited__c in for loop query by Aman Soni as a part of EDGE-148661
    public static Map < String, List < cspmb__Discount_Level__c >> fetchApplicableDiscounts(String accountId,String commercialProductID,String addOnID){
        Map < String, List < cspmb__Discount_Level__c >> applicableDiscountMap = new Map < String, List < cspmb__Discount_Level__c >> ();
        if(String.isNotBlank(commercialProductID)&& String.isNotBlank(accountId)){
            for (cspmb__Discount_Association__c da: [SELECT id, cspmb__Discount_Level__c, cspmb__Discount_Level__r.name,
                    cspmb__Price_Item__c, cspmb__Discount_Level__r.Description__c,
                    cspmb__Discount_Level__r.cspmb__Discount__c,
                    cspmb__Discount_Level__r.cspmb__duration__c,
                    cspmb__Discount_Level__r.Business_ID__c,
                    cspmb__Discount_Level__r.Check_todays_date__c,
                    cspmb__Discount_Level__r.Is_Delegated__c,
                    cspmb__Discount_Level__r.cspmb__Discount_Type__c,
                    cspmb__Discount_Level__r.Effective_Start_Date__c,
                  cspmb__Discount_Level__r.Effective_End_Date__c,cspmb__Discount_Level__r.discountClass__c,
                    cspmb__Discount_Level__r.Account__c, cspmb__Discount_Level__r.Plan__c,cspmb__Discount_Level__r.is_Unlimited__c
                    FROM cspmb__Discount_Association__c
                    WHERE
                    cspmb__Price_Item__c =: commercialProductID AND cspmb__Add_On_Price_Item__c = null
                    AND cspmb__Discount_Level__r.Check_todays_date__c = true
                    AND((cspmb__Discount_Level__r.Account__c =: accountId 
                         AND cspmb__Discount_Level__r.Is_Delegated__c = true) 
                        OR(cspmb__Discount_Level__r.Account__c = null AND cspmb__Discount_Level__r.Is_Delegated__c = false))])// added start and end date in query for Edge-133882
              {
    
                List < cspmb__Discount_Level__c > dislevelList = new List < cspmb__Discount_Level__c > ();
                if (applicableDiscountMap.containsKey(da.cspmb__Discount_Level__r.Business_ID__c)) {
                    dislevelList.addAll(applicableDiscountMap.get(da.cspmb__Discount_Level__r.Business_ID__c));
                }
                cspmb__Discount_Level__c dl = new cspmb__Discount_Level__c();
                dl.id = da.cspmb__Discount_Level__c;
                dl.name = da.cspmb__Discount_Level__r.name;
                dl.is_Unlimited__c = da.cspmb__Discount_Level__r.is_Unlimited__c;//Added by Aman Soni as a part of EDGE-148661
                dl.Description__c = da.cspmb__Discount_Level__r.Description__c;
                dl.cspmb__Discount__c = da.cspmb__Discount_Level__r.cspmb__Discount__c;
                dl.cspmb__duration__c = da.cspmb__Discount_Level__r.cspmb__duration__c;
                dl.Business_ID__c = da.cspmb__Discount_Level__r.Business_ID__c;
                dl.cspmb__Discount_Type__c = da.cspmb__Discount_Level__r.cspmb__Discount_Type__c;
                dl.plan__c = da.cspmb__Discount_Level__r.Plan__c;
                 // added start and end and class date in query for Edge-133882
                dl.Effective_End_Date__c=da.cspmb__Discount_Level__r.Effective_End_Date__c;
                dl.Effective_Start_Date__c=da.cspmb__Discount_Level__r.Effective_Start_Date__c;  
                dl.discountClass__c=da.cspmb__Discount_Level__r.discountClass__c;
                dislevelList.add(dl);
                system.debug('dislevelList plan--->' + dislevelList);
                if (!dislevelList.isEmpty()) {
                    applicableDiscountMap.put(da.cspmb__Discount_Level__r.Business_ID__c, dislevelList);
                }
            }
        }
        if(String.isNotBlank(addOnID)&& String.isNotBlank(accountId)){
            for(cspmb__Discount_Association__c da: [SELECT id, cspmb__Discount_Level__c, cspmb__Discount_Level__r.name,
                cspmb__Price_Item__c, cspmb__Discount_Level__r.Description__c,
                cspmb__Discount_Level__r.cspmb__Discount__c,
                cspmb__Discount_Level__r.cspmb__duration__c,
                cspmb__Discount_Level__r.Business_ID__c,
                cspmb__Discount_Level__r.Check_todays_date__c,
                cspmb__Discount_Level__r.Is_Delegated__c,
                cspmb__Discount_Level__r.cspmb__Discount_Type__c,
                cspmb__Discount_Level__r.Effective_Start_Date__c,
                cspmb__Discount_Level__r.Effective_End_Date__c,
                cspmb__Discount_Level__r.Account__c, cspmb__Discount_Level__r.Plan__c,cspmb__Discount_Level__r.discountClass__c
                FROM cspmb__Discount_Association__c
                WHERE
                cspmb__Add_On_Price_Item__c =: addOnID AND cspmb__Price_Item__c = null
                AND cspmb__Discount_Level__r.Check_todays_date__c = true
                AND((cspmb__Discount_Level__r.Account__c =: accountId AND cspmb__Discount_Level__r.Is_Delegated__c = true) OR(cspmb__Discount_Level__r.Account__c = null AND cspmb__Discount_Level__r.Is_Delegated__c = false))]){
                // added start and end date in query for Edge-133882
                 List < cspmb__Discount_Level__c > dislevelList = new List < cspmb__Discount_Level__c > ();
                if (applicableDiscountMap.containsKey(da.cspmb__Discount_Level__r.Business_ID__c)) {
                        dislevelList.addAll(applicableDiscountMap.get(da.cspmb__Discount_Level__r.Business_ID__c));
                }
                cspmb__Discount_Level__c dl = new cspmb__Discount_Level__c();
                dl.id = da.cspmb__Discount_Level__c;
                dl.name = da.cspmb__Discount_Level__r.name;
                dl.Description__c = da.cspmb__Discount_Level__r.Description__c;
                dl.cspmb__Discount__c=da.cspmb__Discount_Level__r.cspmb__Discount__c;
                dl.cspmb__duration__c = da.cspmb__Discount_Level__r.cspmb__duration__c;
                dl.Business_ID__c = da.cspmb__Discount_Level__r.Business_ID__c;
                dl.cspmb__Discount_Type__c = da.cspmb__Discount_Level__r.cspmb__Discount_Type__c;
                dl.plan__c = da.cspmb__Discount_Level__r.Plan__c;
                // added start and end date class in query for Edge-133882
                dl.Effective_End_Date__c=da.cspmb__Discount_Level__r.Effective_End_Date__c;
                dl.Effective_Start_Date__c=da.cspmb__Discount_Level__r.Effective_Start_Date__c;    
              dl.discountClass__c=da.cspmb__Discount_Level__r.discountClass__c;
                dislevelList.add(dl);
                system.debug('dislevelList add on--->' + dislevelList);
                if (!dislevelList.isEmpty()) {
                    applicableDiscountMap.put(da.cspmb__Discount_Level__r.Business_ID__c, dislevelList);
                }
            }
        }
        system.debug('applicableDiscountMap---->' + applicableDiscountMap);
        return applicableDiscountMap;
    }
    /*--------------------------------------------------------------------------------------------------
    # method to populate return DTO fromDiscount level
    # added this method to handle display data for all screens that need view Discount attribute
    # Edge-133882
    # Author: shubhi
    --------------------------------------------------------------------------------------------------*/
    public static DiscountDTO getDiscounTDTOData(cspmb__Discount_Level__c dl){
        DiscountDTO dto=new DiscountDTO();
        if(dl!=null){
            dto.discountName=dl.name;
            dto.description = dl.Description__c==null ? '' : dl.Description__c;
            dto.discDuration = dl.is_Unlimited__c==true ? 'Life of Subscription' : dl.cspmb__duration__c==null ? '' : String.valueOf(dl.cspmb__duration__c);
            dto.promotionID = dl.Business_ID__c==null ? '' : dl.Business_ID__c;
            dto.DiscountType = dl.cspmb__Discount_Type__c==null ? '' : dl.cspmb__Discount_Type__c;
            dto.startDate=dl.Effective_Start_Date__c==null?'':String.valueOf(dl.Effective_Start_Date__c.day())+' '+String.valueOf(ShowPromotionAndDiscountHandlerClass.calculateMonth(dl.Effective_Start_Date__c.month()))+' '+String.valueOf(dl.Effective_Start_Date__c.year());
            dto.endDate=dl.Effective_End_Date__c==null?'':String.valueOf(dl.Effective_End_Date__c.day())+' '+String.valueOf(ShowPromotionAndDiscountHandlerClass.calculateMonth(dl.Effective_End_Date__c.month()))+' '+String.valueOf(dl.Effective_End_Date__c.year());
            dto.discAmount=dl.cspmb__Discount__c==null?'':dto.DiscountType=='Amount'?'$'+String.valueOf(dl.cspmb__Discount__c):dto.DiscountType=='Credit Months'||dto.DiscountType.contains('Percent') ?String.valueOf(dl.cspmb__Discount__c)+'%':String.valueOf(dl.cspmb__Discount__c);  
        }
        return dto;
    }
      /*--------------------------------------------------------------------------------------------------
    # method to calculateMonth for date in dd/mmm/yyyy
    # Edge-133882
    # Author: shubhi
    --------------------------------------------------------------------------------------------------*/
    public Static string calculateMonth(Integer dateMonth){
        String month='';
        switch on dateMonth {
            when 1 {    
                month='January';
            }  
            when 2 {    
                month='February';  
            }
            when 3 {    
                month='March';
            }
            when 4 {     
                month='April';
            }
            when 5 {    
                month='May';
            }  
            when 6 {    
                month='June';
            }
            when 7 {    
                month='July';
            }
            when 8 {      
                month='August';
            }
            when 9 {    
                month='September';
            }  
            when 10 {    
                month='October';
            }
            when 11 {    
                month='November';
            }
            when 12 {      
                month='December';
            }
        }
        return month;
    }   
}