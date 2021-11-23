/*
* @Author : Shubhi(Edge-120132)
* @Date : 26 Nov 2019
* @Desc : controller class for lightning cmponent to fetch table data
* @Jira : Edge-120132
* @TestClass: ShowPromotionAndDiscountContollerTest 
* @EDGE-127421      Added Method to Populate MRO Bonus Discount!!
* @EDGE-123594      Added logic to discount eligible by ankit
* @EDGE-135278      Commented by Aman Soni to Show Promotion & Discount custom Attribute On Mobile Subscription UI
* @EDGE-144227      Added by Shubhi to resolve duplicate add on error for one plan
* @EDGE-143527      Added by Aman Soni to generalize and improve performance
* @EDGE-143527      Modified by Aman Soni as part of EDGE-143527||EDGE-144227
*/

public with Sharing class ShowPromotionAndDiscountContoller {
    
    //Modified by Aman Soni as a part of EDGE-143527  || Start
    @AuraEnabled
    public static String fetchCommercialProductIDFromSolution(Map<String,SolutionDTO.Attributes> AttMap){
        String CommercialProductId='';
               if(AttMap != null && AttMap.size()>0){
                    system.debug('@@@AttMap-->'+AttMap);
                            if(AttMap.containsKey('Select Plan') &&  !String.isBlank(AttMap.get('Select Plan').value)){
                                CommercialProductId=AttMap.get('Select Plan').value;
                            }
                    }                 
        return CommercialProductId;
    }
    //Modified by Aman Soni as a part of EDGE-143527  || End
    
    //Modified by Aman Soni as a part of EDGE-143527  || Start
    /*Laxmi ..method to fetch custom selected pritem salesforce id Edge-EDGE-129044 */
    @AuraEnabled
    public static String fetchIIDIDFromSoln(Map<String,SolutionDTO.Attributes> AttMap){
        String addOnID='';
        Boolean AddonApplicable=false;
                if(AttMap != null && AttMap.size()>0){
                        system.debug('@@@Attmap*****'+AttMap);
                            if(AttMap.containsKey('IDD Charge') && !String.isBlank(AttMap.get('IDD Charge').value) && AttMap.get('IDD Charge').value!='0' && AttMap.containsKey('IDD ChargeLookup') &&  !String.isBlank(AttMap.get('IDD ChargeLookup').value)){
                                system.debug('@@@Inside loop*****'+AttMap.get('IDD ChargeLookup').value);
                                addOnID=AttMap.get('IDD ChargeLookup').value;
                            }
                        }                      
        return addOnID;
    }
    //Modified by Aman Soni as a part of EDGE-143527  || End
    
    //Modified by Aman Soni as a part of EDGE-143527  || Start
    /*Laxmi .. Method to fetch the Plan Discount Attribute frm the Map EDGE-127421 */
    @AuraEnabled
    public static Map<String,String> fetchPlanDiscount(Map<String,SolutionDTO.Attributes> AttMap){
        SolutionDTO.Configurations selectedConfig=new SolutionDTO.Configurations();
        Map <String, String > discountAttributes = new Map <String , String>();
        String totalPlanBonus = '';
        String contractTerm = '24';
        String remainingTerm = '';
        String isPaymentTypeOneFund = 'false';
                if(AttMap != null && AttMap.size()>0){        
                        system.debug('@@@Attmap*****'+AttMap);
                      // Added additional check of value great than Zero.
                        if(AttMap.size()>0 && AttMap.containsKey('TotalPlanBonus') && String.isNotBlank(AttMap.get('TotalPlanBonus').value) && Decimal.valueOf(AttMap.get('TotalPlanBonus').value)>0){
                                totalPlanBonus=AttMap.get('TotalPlanBonus').value;  
                        }else
                            totalPlanBonus = '0';                    
                            system.debug('@@@totalPlanBonus*****'+totalPlanBonus);
                            system.debug('@@@ContractTerm*****'+AttMap.containsKey('ContractTerm'));                 
                        if(AttMap.size()>0 && AttMap.containsKey('isPaymentTypeOneFund') && String.isNotBlank(AttMap.get('isPaymentTypeOneFund').value)){
                                isPaymentTypeOneFund=AttMap.get('isPaymentTypeOneFund').value;  
                         }                   
                    if(AttMap.size()>0 && AttMap.containsKey('RemainingTerm') && String.isNotBlank(AttMap.get('RemainingTerm').value)){                       
                            remainingTerm=AttMap.get('RemainingTerm').value;                        
                    }else
                            remainingTerm = '0';           
                    
                    if (remainingTerm!='0' && remainingTerm!=''){
                        contractTerm = remainingTerm;
                    }
                    discountAttributes.put ('contractTerm',contractTerm);
                    discountAttributes.put ('totalPlanBonus',totalPlanBonus);
                    discountAttributes.put ('isPaymentTypeOneFund',isPaymentTypeOneFund);

                }
        return discountAttributes;
    }
    //Laxmi Changes ENd
    //Modified by Aman Soni as a part of EDGE-143527  || End
    
    //Modified by Aman Soni as a part of EDGE-143527  || Start
    /* method to fetch attribute values from solution that are needed in promotion Edge-120132*/
    @AuraEnabled
    public static Map<String,String> fetchAttributeValueMapFromSolution(List<String> attributeList,Map<String,SolutionDTO.Attributes> AttMap){
        Map<String,String> attributeTovalueMap=new Map<String,String>();
                if(AttMap != null && AttMap.size()>0){
                        for(String attName:AttMap.keyset()){
                            if(attributeList.contains(attName)){
                                attributeTovalueMap.put(attName,AttMap.get(attName).value);
                            }
                        }
                }
        return attributeTovalueMap;
    }    
    /*method to get final table data for ui Edge-120132*/
    //Modified by Aman Soni as a part of EDGE-143527  || End
    
    //Modified by Aman Soni as a part of EDGE-143527  || Start
    @AuraEnabled
    public static List<DiscountDTO> getDiscountdata(String accountID,String solutionID,String configGuid, String tabName,object mapJsonString){
        List<DiscountDTO> discountDTOList =new List<DiscountDTO>();
        system.debug('mapJsonString-->'+mapJsonString);
        
         //Edge-143527 start
        if(mapJsonString!=null){
            Map<String,SolutionDTO.Attributes>  Attmap = (Map<String,SolutionDTO.Attributes>)JSON.deserialize(String.valueOf(mapJsonString), Map<String,SolutionDTO.Attributes>.class);
            // Edge-143527 end
            if(!String.isBlank(accountID) && !String.isBlank(solutionID) && !String.isBlank(configGuid) && AttMap!=null && AttMap.size()>0){ 
            // If Selected Tab is Add On get the Add On Lookup ID else get the Commercial product ID
            String addOnID = '';
            String commercialProductID ='';
            system.debug('tabname-->'+tabName);     
            if (tabName == 'AddOn')
            {
                addOnID=fetchIIDIDFromSoln(AttMap);
    
            }else if (tabName == 'PromotionAndDis') {
            commercialProductID=fetchCommercialProductIDFromSolution(AttMap);
            }
            system.debug('commercialProductID---->'+commercialProductID +'  &&&  '+'addOnID---->'+addOnID); 
            Map<String,List<cspmb__Discount_Level__c>> applicableDiscountMap = ShowPromotionAndDiscountHandlerClass.fetchApplicableDiscounts(accountId,commercialProductID,addOnID); 
            system.debug('applicableDiscountMap in Showp---->'+applicableDiscountMap);        
           
            if(applicableDiscountMap.size()>0){
                //Added by Shubhi for EDGE-144227 / Modified by Aman Soni as part of EDGE-143527 || Start
                Set<String> discountLevelSet = new Set<String>();
                for(List<cspmb__Discount_Level__c> applDlsLst : applicableDiscountMap.values()){
                    for(cspmb__Discount_Level__c applDls : applDlsLst){
                    discountLevelSet.add(applDls.id);                       
                    }
                }
                system.debug('discountLevelSet in Showp---->'+discountLevelSet); 
                //Added by Shubhi for EDGE-144227 / Modified by Aman Soni as part of EDGE-143527 || End
                 
                Map<String,Set<cspmb__Discount_Level__c>> eligibleDiscountMap=new Map<String,Set<cspmb__Discount_Level__c>>();
                Map<String,Promotion_Metadata__mdt> promotionalMetadataMap=new Map<String,Promotion_Metadata__mdt>();
                promotionalMetadataMap=ShowPromotionAndDiscountHandlerClass.fetchPromotionMetadata(applicableDiscountMap.keySet());
                system.debug('promotionalMetadataMap-->'+promotionalMetadataMap);
                Set<String> busIdforDisLevelEligibleRec=new Set<String>();
                Map<String,String> attributeToValueMap=new Map<String,String>(); 
                String queryString='SELECT id,name,Description__c,cspmb__Discount__c,cspmb__duration__c,Business_ID__c,Plan__c,cspmb__Discount_Type__c,is_Unlimited__c,';
                List<String> attributesTobeMatched=new List<String>();
                if(!promotionalMetadataMap.isEmpty()){
                    for(String s:promotionalMetadataMap.keySet()){
                        if(promotionalMetadataMap.get(s).ReferenceObject__c!=null ){
                            busIdforDisLevelEligibleRec.add(s);
                            if(promotionalMetadataMap.get(s).ReferenceField__c != null && !queryString.containsIgnoreCase(promotionalMetadataMap.get(s).ReferenceField__c)){
                                queryString+=promotionalMetadataMap.get(s).ReferenceField__c;
                            }
                            attributesTobeMatched.add(promotionalMetadataMap.get(s).ReferenceAttribute__c);
                        }else{
                            //Added ReferenceAttribute__c as part of EDGE-123594 by ankit || Start
                            if(promotionalMetadataMap.get(s).ReferenceAttribute__c != null){
                                 attributesTobeMatched.add(promotionalMetadataMap.get(s).ReferenceAttribute__c);
                            }
                            //Added ReferenceAttribute__c as part of EDGE-123594 by ankit || End
                            if(applicableDiscountMap.containskey(s)){
                                Set<cspmb__Discount_Level__c> setDisMap=new Set<cspmb__Discount_Level__c>(); 
                                setDisMap.addAll(applicableDiscountMap.get(s));
                                eligibleDiscountMap.put(s,setDisMap);
                            }
                        }
                    }
                    queryString=queryString.removeEnd(',');
                    queryString+=' FROM cspmb__Discount_Level__c WHERE Business_ID__c IN: busIdforDisLevelEligibleRec AND  Is_Delegated__c=true AND Account__c =: accountID';   //added for EDGE-135837 as it was fetching extra records     
                    system.debug('!!!!!queryString!!!!'+queryString);
                    system.debug('!!!!!busIdforDisLevelEligibleRec!!!!'+busIdforDisLevelEligibleRec);
                    List<cspmb__Discount_Level__c> toBeEligibleDiscounts=new List<cspmb__Discount_Level__c>();
                    if(busIdforDisLevelEligibleRec.size()>0){
                        toBeEligibleDiscounts=Database.query(queryString);
                    }
                    system.debug('eligible discount-->'+toBeEligibleDiscounts);
                    system.debug('attributesTobeMatched-->'+attributesTobeMatched);
                    if(!attributesTobeMatched.isEmpty()){
                        attributeToValueMap=ShowPromotionAndDiscountContoller.fetchAttributeValueMapFromSolution(attributesTobeMatched,AttMap);
                    }
                    system.debug('attributeToValueMap-->'+attributeToValueMap);

                    if(toBeEligibleDiscounts.size()>0){
                        for(cspmb__Discount_Level__c disL:toBeEligibleDiscounts){
                            Set<cspmb__Discount_Level__c> dislevelList=new Set<cspmb__Discount_Level__c>();
                            for(cspmb__Discount_Level__c dl1:toBeEligibleDiscounts){
                                if(disL.Business_ID__c==dl1.Business_ID__c){
                                    if(promotionalMetadataMap.containsKey(dl1.Business_ID__c) && attributeToValueMap.size()>0 && promotionalMetadataMap.get(dl1.Business_ID__c).ReferenceField__c != null && promotionalMetadataMap.get(dl1.Business_ID__c).ReferenceAttribute__c != null 
                                    && dl1.get(promotionalMetadataMap.get(dl1.Business_ID__c).ReferenceField__c)==attributeToValueMap.get(promotionalMetadataMap.get(dl1.Business_ID__c).ReferenceAttribute__c) && discountLevelSet.contains(String.valueof(dl1.id))){//Added by Shubhi for EDGE-144227 / Modified by Aman Soni as part of EDGE-143527
                                        cspmb__Discount_Level__c dl=new cspmb__Discount_Level__c();
                                        dl.id=dl1.id;
                                        dl.name=dl1.name;
                                        dl.Description__c=dl1.Description__c;
                                        dl.cspmb__Discount__c=dl1.cspmb__Discount__c;
                                        dl.cspmb__duration__c=dl1.cspmb__duration__c;
                                        dl.Business_ID__c=dl1.Business_ID__c;
                                        dl.cspmb__Discount_Type__c=dl1.cspmb__Discount_Type__c;
                                        dl.is_Unlimited__c=dl1.is_Unlimited__c;
                                        dl.plan__c=dl1.plan__c;
                                        dislevelList.add(dl);
                                    }
                                }
                            }
                            if(!dislevelList.isEmpty())
                            eligibleDiscountMap.put(disL.Business_ID__c,dislevelList);
                        }
                    }
                    List<cspmb__Discount_Level__c>DisList=new List<cspmb__Discount_Level__c>();
                    for(String busId:eligibleDiscountMap.keySet()){
                        for(cspmb__Discount_Level__c dl:eligibleDiscountMap.get(busId)){
                            DisList.add(dl);
                        }
                    }
                    system.debug('@@eligibleDiscountMap-->'+eligibleDiscountMap);
                     //added As part of EDGE-123594
                    GetDiscountEligiblityClass EllClass= new GetDiscountEligiblityClass();
                     List<cspmb__Discount_Level__c>EligiblediscountLevelList=EllClass.EligibleDiscountList(DisList,promotionalMetadataMap,attributeToValueMap); 
                        for(cspmb__Discount_Level__c dl:EligiblediscountLevelList){
                            DiscountDTO dto=ShowPromotionAndDiscountHandlerClass.getDiscounTDTOData(dl);
                            discountDTOList.add(dto);
                        }                
                }                
            }
    
           // 127421 Laxmi Changes Start -
    
            //Only Add MRO Data when the tab name is PromotionAndDis
            if (tabName == 'PromotionAndDis') {
                     String businessIDMRO ='DMCAT_Discount_000850';
                    Map <String, String > discountAttributes  = new Map <String, String>();
                    discountAttributes = fetchPlanDiscount(AttMap);
                    String totalBonus = '';
                    String contractTerm = '';
                    String isPaymentTypeOneFund = 'false'; 
                    if(!discountAttributes.isEmpty() && discountAttributes.containsKey('totalPlanBonus')){
                            totalBonus=discountAttributes.get('totalPlanBonus');
                        }
                    if(!discountAttributes.isEmpty() && discountAttributes.containsKey('contractTerm')){
                            contractTerm=discountAttributes.get('contractTerm');
                        }
            
                     if(!discountAttributes.isEmpty() && discountAttributes.containsKey('isPaymentTypeOneFund')){
                            isPaymentTypeOneFund=discountAttributes.get('isPaymentTypeOneFund');
                         system.debug ('@@@@@@@@@@@@isPaymentTypeOneFund --------'+ isPaymentTypeOneFund);
                        }
                    // Display DIscounts only when the isPaymentTypeOneFund is not True and there is value in Plan DIscount field on Solution
                    
                    //Added As part of Edge 123594 by Ankit || start
                    Map<String,Promotion_Metadata__mdt> promotionalMetadataMap=new Map<String,Promotion_Metadata__mdt>();
                    Set<String> applicableDiscountMapkeysList=new Set<String>();
                    string PatternValue;
                    applicableDiscountMapkeysList.add(businessIDMRO);
                    promotionalMetadataMap=ShowPromotionAndDiscountHandlerClass.fetchPromotionMetadata(applicableDiscountMapkeysList);
                      if(promotionalMetadataMap.containsKey(businessIDMRO)){
                            PatternValue=promotionalMetadataMap.get(businessIDMRO).Eligibility_Pattern__c;
                        }
                    //Added As part of Edge 123594 by Ankit || End
                    
                    if (!String.isBlank (totalBonus) && totalBonus!='0' && isPaymentTypeOneFund != 'true' &&promotionalMetadataMap.containskey(businessIDMRO) && PatternValue=='Pattern F' ){ //Added conditions  As part of Edge 123594 by Ankit
                        DiscountDTO dtoMRO=new DiscountDTO();
                        dtoMRO.discountName= Constants.MRO_DISCOUNT_NAME;
                        dtoMRO.description=Constants.MRO_DISCOUNT_DESC;
                        dtoMRO.discAmount='$'+totalBonus;
                        dtoMRO.discDuration=contractTerm;
                        dtoMRO.promotionID='';
                        dtoMRO.DiscountType=Constants.DISCOUNT_TYPE;
                        discountDTOList.add(dtoMRO);
                        system.debug('@@discountDTOList MRO-->'+discountDTOList);
                    }
                 }          
            } 
        }
        system.debug('@@discountDTOList-->'+discountDTOList);
        return discountDTOList;     
        // Laxmi Changes End      
    }
    //Modified by Aman Soni as a part of EDGE-143527  || End
}