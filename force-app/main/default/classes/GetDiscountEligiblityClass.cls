/*********************************************************************************************************************************
 *Class Name      :   GetDiscountEligiblityClass

Test Class : GetDiscountEligiblityClassTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Ankit Goswami        20/02/2020      EDGE-123594  Created
2.             Shubhi                18/03/2020    added by shubhi for test class fix
 *********************************************************************************************************************************
**/


public with sharing  class GetDiscountEligiblityClass{
    
    public List<cspmb__Discount_Level__c> EligibleDiscountList(List<cspmb__Discount_Level__c> discountLevelList,Map<String,Promotion_Metadata__mdt> promotionMetadataMap,Map<String,String> attributeToValueMap){
        List<cspmb__Discount_Level__c> dliList=new List<cspmb__Discount_Level__c>();
        for(cspmb__Discount_Level__c disLevel : discountLevelList){
            Boolean isEligible=false; //added by shubhi for test class fix
            if(promotionMetadataMap.containskey(disLevel.Business_ID__c)){
                String PatternValue=promotionMetadataMap.get(disLevel.Business_ID__c).Eligibility_Pattern__c;
                if(PatternValue=='Pattern A')
                isEligible=CheckDiscountPatternA(PatternValue);
            
                if(PatternValue=='Pattern B')
                isEligible=CheckDiscountPatternB(disLevel,promotionMetadataMap,attributeToValueMap);
            
                if(PatternValue=='Pattern C')
                isEligible=CheckDiscountPatternC(disLevel,promotionMetadataMap,attributeToValueMap);
            
                if(PatternValue=='Pattern D')
                isEligible=CheckDiscountPatternD(disLevel,promotionMetadataMap,attributeToValueMap);
                
                if(PatternValue=='Pattern E')
                isEligible=CheckDiscountPatternE(disLevel,promotionMetadataMap,attributeToValueMap);
                
                if(PatternValue=='Pattern F')
                isEligible=CheckDiscountPatternF(disLevel,promotionMetadataMap,attributeToValueMap);
            
                if(PatternValue=='Pattern G')
                isEligible=CheckDiscountPatternG(disLevel,promotionMetadataMap,attributeToValueMap);
                
                if(isEligible){
                    dliList.add(disLevel);
                }
                system.debug('dliList------>'+dliList);
            }
        }
        return dliList;
    }
    
    public  boolean CheckDiscountPatternA(String PatternValue){
        return true;
    }
    public  boolean CheckDiscountPatternB(cspmb__Discount_Level__c disLevel,Map<String,Promotion_Metadata__mdt> promotionMetadataMap,Map<String,String> attributeToValueMap){
         Promotion_Metadata__mdt pm=promotionMetadataMap.get(disLevel.Business_ID__c);
         if(pm.ReferenceObject__c!=null){
          system.debug('disLevel1'+disLevel);
           system.debug('disLevel1'+promotionMetadataMap.get(disLevel.Business_ID__c).ReferenceField__c);
         system.debug('disLevel'+disLevel.get(promotionMetadataMap.get(disLevel.Business_ID__c).ReferenceField__c));
                  system.debug('attribut+ :::'+attributeToValueMap.get(promotionMetadataMap.get(disLevel.Business_ID__c).ReferenceAttribute__c));

            if(attributeToValueMap.size()>0 && attributeToValueMap.containskey(promotionMetadataMap.get(disLevel.Business_ID__c).ReferenceAttribute__c) &&
                    (disLevel.get(promotionMetadataMap.get(disLevel.Business_ID__c).ReferenceField__c)==attributeToValueMap.get(promotionMetadataMap.get(disLevel.Business_ID__c).ReferenceAttribute__c))){               
                system.debug('CheckDiscountPatternB::::');
                return true;
               
            }
        }
        return false;
    }
    public  boolean CheckDiscountPatternC(cspmb__Discount_Level__c disLevel,Map<String,Promotion_Metadata__mdt> promotionMetadataMap,Map<String,String> attributeToValueMap){
            if(attributeToValueMap.size()>0 && attributeToValueMap.containskey('ChangeType') && attributeToValueMap.get('ChangeType')=='New'){               
                system.debug('CheckDiscountPatternC::::');
                return true;
               
            }
        return false;
    }
    public  boolean CheckDiscountPatternD(cspmb__Discount_Level__c disLevel,Map<String,Promotion_Metadata__mdt> promotionMetadataMap,Map<String,String> attributeToValueMap){
        if(attributeToValueMap.size()>0 && attributeToValueMap.containskey('ChangeType') && attributeToValueMap.get('ChangeType')=='Modify'){               
                system.debug('CheckDiscountPatternD::::');
                return true;
               
        }
        return false;
    }
    public  boolean CheckDiscountPatternE(cspmb__Discount_Level__c disLevel,Map<String,Promotion_Metadata__mdt> promotionMetadataMap,Map<String,String> attributeToValueMap){
        if(attributeToValueMap.size()>0 && attributeToValueMap.containskey('ChangeType') && attributeToValueMap.get('ChangeType')=='Transition'){               
                system.debug('CheckDiscountPatternE::::');
                return true;
        }
        return false;
    }
   public  boolean CheckDiscountPatternF(cspmb__Discount_Level__c disLevel,Map<String,Promotion_Metadata__mdt> promotionMetadataMap,Map<String,String> attributeToValueMap){
        if(attributeToValueMap.size()>0 && attributeToValueMap.containsKey('isPaymentTypeOneFund') && attributeToValueMap.get('isPaymentTypeOneFund')=='false'
        && attributeToValueMap.containsKey('TotalPlanBonus') && attributeToValueMap.get('TotalPlanBonus')!='' && Decimal.valueOf(attributeToValueMap.get('TotalPlanBonus'))>0){               
                system.debug('CheckDiscountPatternF::::');
                return true;
        }
        return false;
    }
    public boolean CheckDiscountPatternG(cspmb__Discount_Level__c disLevel,Map<String,Promotion_Metadata__mdt> promotionMetadataMap,Map<String,String> attributeToValueMap){
        if(attributeToValueMap.size()>0 && attributeToValueMap.containskey('isRecontractingDiscountEligible') && attributeToValueMap.get('isRecontractingDiscountEligible')=='true' && attributeToValueMap.containskey('ChangeType') && attributeToValueMap.get('ChangeType') !='Modify' && attributeToValueMap.get('ChangeType') !='Cancel'){               
               system.debug('CheckDiscountPatternG::::');
                return true;
        }
        return false;
    }

}