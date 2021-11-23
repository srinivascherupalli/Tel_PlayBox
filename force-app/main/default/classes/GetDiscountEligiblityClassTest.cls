/*********************************************************************************************************************************
 *Class Name      :   GetDiscountEligiblityClass

Test Class : GetDiscountEligiblityClassTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Ankit Goswami        20/02/2024     EDGE-123594  Created
 *********************************************************************************************************************************
**/


@isTest
private class GetDiscountEligiblityClassTest {
    static testmethod void PositiveEligibleDiscountListTest() {
        Map<String,Promotion_Metadata__mdt> promotionMetadataMap=new map<String,Promotion_Metadata__mdt>();
        Map<String,String> attributeToValueMap=new Map<String,String>();
        List<Promotion_Metadata__mdt> PramotionDataList=new List<Promotion_Metadata__mdt>();
        Promotion_Metadata__mdt PatternA=new Promotion_Metadata__mdt();
        PatternA.BusinessID__c='DMCAT_Discount_000961';
        PatternA.Eligibility_Pattern__c='Pattern A';
        PramotionDataList.add(PatternA);
        
        Promotion_Metadata__mdt PatternB=new Promotion_Metadata__mdt();
        PatternB.BusinessID__c='DMCAT_Discount_000957';
        PatternB.ReferenceAttribute__c='SelectPlanName';
        PatternB.ReferenceField__c='Plan__c';
        PatternB.ReferenceObject__c='cspmb__Discount_Level__c';
        PatternB.isActive__c=true;
        PatternB.IsDelegated__c=true;
        PatternB.Category__c='Discount';
        PatternB.Eligibility_Pattern__c='Pattern B';
        PramotionDataList.add(PatternB);
        
        Promotion_Metadata__mdt PatternC=new Promotion_Metadata__mdt();
        PatternC.BusinessID__c='DMCAT_Discount_000951';
        PatternC.Eligibility_Pattern__c='Pattern C';
        PatternC.ReferenceAttribute__c='ChangeType';
        PramotionDataList.add(PatternC);
        
        Promotion_Metadata__mdt PatternD=new Promotion_Metadata__mdt();
        PatternD.BusinessID__c='DMCAT_Discount_000846';
        PatternD.Eligibility_Pattern__c='Pattern D';
        PramotionDataList.add(PatternD);
        
        Promotion_Metadata__mdt PatternE=new Promotion_Metadata__mdt();
        PatternE.BusinessID__c='DMCAT_Discount_000847';
        PatternE.Eligibility_Pattern__c='Pattern E';
        PramotionDataList.add(PatternE);
        
        Promotion_Metadata__mdt PatternF=new Promotion_Metadata__mdt();
        PatternF.BusinessID__c='DMCAT_Discount_000850';
        PatternF.Eligibility_Pattern__c='Pattern F';
        PramotionDataList.add(PatternF);
        
        Promotion_Metadata__mdt PatternG=new Promotion_Metadata__mdt();
        PatternG.BusinessID__c='DMCAT_Discount_000953';
        PatternG.Eligibility_Pattern__c='Pattern G';
        PatternG.ReferenceAttribute__c='isRecontractingDiscountEligible';
        PatternG.isActive__c=true;
        PatternG.IsDelegated__c=true;
        PramotionDataList.add(PatternG);
        
        for(Promotion_Metadata__mdt pmData:PramotionDataList){
            promotionMetadataMap.put(pmData.BusinessID__c,pmData);
        }
        
        List<cspmb__Discount_Level__c> discountLevelList= new List<cspmb__Discount_Level__c>();
        cspmb__Discount_Level__c DiscountLevelA=new cspmb__Discount_Level__c();
        DiscountLevelA.Business_ID__c='DMCAT_Discount_000961';
        discountLevelList.add(DiscountLevelA);
        
        cspmb__Discount_Level__c DiscountLevelB=new cspmb__Discount_Level__c();
        DiscountLevelB.Business_ID__c='DMCAT_Discount_000957';
        discountLevelList.add(DiscountLevelB);
        
        cspmb__Discount_Level__c DiscountLevelC=new cspmb__Discount_Level__c();
        DiscountLevelC.Business_ID__c='DMCAT_Discount_000951';
        discountLevelList.add(DiscountLevelC);
        
        cspmb__Discount_Level__c DiscountLevelD=new cspmb__Discount_Level__c();
        DiscountLevelD.Business_ID__c='DMCAT_Discount_000846';
        discountLevelList.add(DiscountLevelD);
        
        cspmb__Discount_Level__c DiscountLevelE=new cspmb__Discount_Level__c();
        DiscountLevelE.Business_ID__c='DMCAT_Discount_000847';
        discountLevelList.add(DiscountLevelE);
        
        cspmb__Discount_Level__c DiscountLevelF=new cspmb__Discount_Level__c();
        DiscountLevelF.Business_ID__c='DMCAT_Discount_000850';
        discountLevelList.add(DiscountLevelF);
        
        cspmb__Discount_Level__c DiscountLevelG=new cspmb__Discount_Level__c();
        DiscountLevelG.Business_ID__c='DMCAT_Discount_000953';
        discountLevelList.add(DiscountLevelG);
        
        
        attributeToValueMap.put('DMCAT_Discount_000957','SelectPlanName');
        attributeToValueMap.put('DMCAT_Discount_000957','Plan__c');
        attributeToValueMap.put('DMCAT_Discount_000957','cspmb__Discount_Level__c');
        attributeToValueMap.put('ChangeType','Modify');
        attributeToValueMap.put('ChangeType','New');
        attributeToValueMap.put('ChangeType','Transition');
        attributeToValueMap.put('isPaymentTypeOneFund','false');
        attributeToValueMap.put('TotalPlanBonus','9.1');
        attributeToValueMap.put('isRecontractingDiscountEligible','true');
        GetDiscountEligiblityClass GetDis= new GetDiscountEligiblityClass();
        List<cspmb__Discount_Level__c> DiscountList=GetDis.EligibleDiscountList(discountLevelList,promotionMetadataMap,attributeToValueMap);
        system.assert(!DiscountList.isEmpty());
    }
    static testmethod void NegativeDiscountListTest() {
        Map<String,Promotion_Metadata__mdt> promotionMetadataMap=new map<String,Promotion_Metadata__mdt>();
        Map<String,String> attributeToValueMap=new Map<String,String>();
        List<Promotion_Metadata__mdt> PramotionDataList=[select Id,BusinessID__c,Category__c,Eligibility_Pattern__c,isActive__c,IsDelegated__c,ReferenceAttribute__c,ReferenceField__c,ReferenceObject__c from Promotion_Metadata__mdt];
        Promotion_Metadata__mdt PatternD=new Promotion_Metadata__mdt();
        PatternD.BusinessID__c='DMCAT_Discount_000846';
        PatternD.Eligibility_Pattern__c='Pattern D';
        PramotionDataList.add(PatternD);
        Promotion_Metadata__mdt PatternE=new Promotion_Metadata__mdt();
        PatternE.BusinessID__c='DMCAT_Discount_000847';
        PatternE.Eligibility_Pattern__c='Pattern E';
        PramotionDataList.add(PatternE);
        for(Promotion_Metadata__mdt pmData:PramotionDataList){
            if(pmData.BusinessID__c=='DMCAT_Discount_000957'){
                pmData.ReferenceObject__c='';
            }
            if(pmData.Eligibility_Pattern__c !='Pattern A')
            promotionMetadataMap.put(pmData.BusinessID__c,pmData);
        }
        
        List<cspmb__Discount_Level__c> discountLevelList= [select id,Business_ID__c From cspmb__Discount_Level__c];
        cspmb__Discount_Level__c DiscountLevelD=new cspmb__Discount_Level__c();
        DiscountLevelD.Business_ID__c='DMCAT_Discount_000846';
        discountLevelList.add(DiscountLevelD);
        
        cspmb__Discount_Level__c DiscountLevelE=new cspmb__Discount_Level__c();
        DiscountLevelE.Business_ID__c='DMCAT_Discount_000847';
        discountLevelList.add(DiscountLevelE);
        
         cspmb__Discount_Level__c DiscountLevelG=new cspmb__Discount_Level__c();
        DiscountLevelG.Business_ID__c='DMCAT_Offer_000646';
        discountLevelList.add(DiscountLevelG);
        
        attributeToValueMap.put('DMCAT_Discount_000957','SelectPlanName');
        attributeToValueMap.put('DMCAT_Discount_000957','Plan__c');
        attributeToValueMap.put('DMCAT_Discount_000957','cspmb__Discount_Level__c');
        attributeToValueMap.put('ChangeType','');
        attributeToValueMap.put('isPaymentTypeOneFund','true');
        attributeToValueMap.put('TotalPlanBonus','9.1');
        attributeToValueMap.put('isRecontractingDiscountEligible','false');
        GetDiscountEligiblityClass GetDis= new GetDiscountEligiblityClass();
        List<cspmb__Discount_Level__c> DiscountList=GetDis.EligibleDiscountList(discountLevelList,promotionMetadataMap,attributeToValueMap);
        system.assert(DiscountList.isEmpty());
    }
}