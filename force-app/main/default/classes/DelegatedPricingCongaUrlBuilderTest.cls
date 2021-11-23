/*
* @Author : Rahul
* @Date : 2 Nov 2020
* @Desc : Test class for DelegatedPricingCongaUrlBuilder
* @Jira Cloud : EDGE-176683 & EDGE-185984
*/
@isTest
public class DelegatedPricingCongaUrlBuilderTest{
    private void setup() { 
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;
        
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        
        Delegated_Pricing_Request__c dpr= new Delegated_Pricing_Request__c();
        dpr.Opportunity__c=opp.id;
        dpr.Commitment_Frequency__c='Quarterly';
        insert dpr;
        
        /*DPR_Offer_Line_Item__c dolineitem= new DPR_Offer_Line_Item__c();
        dolineitem.Delegated_Pricing_Request__c=dpr.id;
        dolineitem.List_Price__c=10;
        insert dolineitem;*/
        
        csconta__Frame_Agreement__c framAg= new csconta__Frame_Agreement__c();
        framAg.csconta__Account__c=acc.id;
        framAg.Opportunity__c=opp.id;
        framAg.Delegated_Pricing_Request__c=dpr.id;
        framAg.csconta__Agreement_Name__c='AGR-TEST';
        insert framAg;
    }
    
    @isTest static void getCongaURLPositive(){
        DelegatedPricingCongaUrlBuilderTest testclass=new DelegatedPricingCongaUrlBuilderTest();
         testclass.setup();
        List <APXTConga4__Conga_Merge_Query__c> congaquerylist= new List <APXTConga4__Conga_Merge_Query__c>();
           for(DPR_Deal_Query_Mapping__mdt dprQrMappingLoop:[Select  id,Query_Name__c from DPR_Deal_Query_Mapping__mdt]){
                APXTConga4__Conga_Merge_Query__c congaq= new APXTConga4__Conga_Merge_Query__c();
                congaq.APXTConga4__Name__c=dprQrMappingLoop.Query_Name__c;
                congaquerylist.add(congaq);
           }
        insert congaquerylist;
        Map<String,APXTConga4__Conga_Merge_Query__c> congaQueriesRecordsMap= new Map<String,APXTConga4__Conga_Merge_Query__c>();
        for(APXTConga4__Conga_Merge_Query__c congaqrloop:[select id,APXTConga4__Name__c,name  from APXTConga4__Conga_Merge_Query__c where id in:congaquerylist]){
            congaQueriesRecordsMap.put(congaqrloop.APXTConga4__Name__c,congaqrloop);
        }
         
        csconta__Frame_Agreement__c frmAgrRecord=[select id from csconta__Frame_Agreement__c where csconta__Agreement_Name__c=:'AGR-TEST' limit 1];
        String congaURL=DelegatedPricingCongaUrlBuilder.congaURLCreater(congaQueriesRecordsMap,frmAgrRecord.id);
        system.debug('congaURL'+congaURL);
         System.assert(congaURL.contains('DPRQuoteDeviceOC'));
    }
    
    @isTest static void getCongaURLnegative(){
        DelegatedPricingCongaUrlBuilderTest testclass=new DelegatedPricingCongaUrlBuilderTest();
         testclass.setup();
        
        Map<String,APXTConga4__Conga_Merge_Query__c> congaQueriesRecordsMap= new Map<String,APXTConga4__Conga_Merge_Query__c>();
        csconta__Frame_Agreement__c frmAgrRecord=[select id from csconta__Frame_Agreement__c where csconta__Agreement_Name__c=:'AGR-TEST' limit 1];
        String congaURL=DelegatedPricingCongaUrlBuilder.congaURLCreater(congaQueriesRecordsMap,frmAgrRecord.id);
        system.debug('congaURL'+congaURL);
          System.assertEquals(congaURL,null);
    }
}