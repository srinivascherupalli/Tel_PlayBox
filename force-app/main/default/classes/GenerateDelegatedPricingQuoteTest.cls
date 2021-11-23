/*
* @Author : Rahul
* @Date : 2 Nov 2020
* @Desc : Test class for GenerateDelegatedPricingQuoteTest
* @Jira Cloud : EDGE-176683 & EDGE-185984
*/
@isTest
public class GenerateDelegatedPricingQuoteTest{
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
    
    @isTest static void delegatedpricingquotePositive(){
        GenerateDelegatedPricingQuoteTest testclass=new GenerateDelegatedPricingQuoteTest();
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
        GenerateDelegatedPricingQuote.GenerateQuoteResult gr= new GenerateDelegatedPricingQuote.GenerateQuoteResult ();
        Test.startTest();
        gr=GenerateDelegatedPricingQuote.createQuote(frmAgrRecord.id);
        Test.stopTest();
        system.debug('quoteId'+gr);
        Quote q=[select id,Name,Frame_Agreement__r.csconta__Agreement_Name__c from quote where id=:gr.id];
       System.assertEquals(q.Frame_Agreement__r.csconta__Agreement_Name__c,'AGR-TEST');
    }
    
    @isTest static void delegatedpricingquoteNegative(){
        GenerateDelegatedPricingQuoteTest testclass=new GenerateDelegatedPricingQuoteTest();
         testclass.setup();
        GenerateDelegatedPricingQuote.GenerateQuoteResult gr= new GenerateDelegatedPricingQuote.GenerateQuoteResult ();
        Map<String,APXTConga4__Conga_Merge_Query__c> congaQueriesRecordsMap= new Map<String,APXTConga4__Conga_Merge_Query__c>();
        csconta__Frame_Agreement__c frmAgrRecord=[select id from csconta__Frame_Agreement__c where csconta__Agreement_Name__c=:'AGR-TEST' limit 1];
        Test.startTest();   
        gr=GenerateDelegatedPricingQuote.createQuote(null);
        Test.stopTest();    
        system.debug('quoteId'+gr);
        System.assertEquals(gr.errorMessage,'Quote generation failed: Frame Agreement Id is Null');
    }
    
    @isTest static void delegatedpricingExistingQuote(){
        GenerateDelegatedPricingQuoteTest testclass=new GenerateDelegatedPricingQuoteTest();
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
         
        csconta__Frame_Agreement__c frmAgrRecord=[select id,name,Opportunity__c from csconta__Frame_Agreement__c where csconta__Agreement_Name__c=:'AGR-TEST' limit 1];
        Quote quo = new Quote();
                    quo.Name = frmAgrRecord.name;
                    quo.Frame_Agreement__c = frmAgrRecord.Id;
                    quo.opportunityid=frmAgrRecord.Opportunity__c;
                    quo.ExpirationDate =system.today()+30;
                    quo.Conga_Status__c ='InProgress' ;
                    //  quo.ContactId = fetchPrimaryContactQuote(productBasket); // EDGE-52268 
                    //quo.ContactId = fetchDelegatedQuoteRecipient(frameAgreement);
                    quo.Conga_Request_Time__c = System.now();
                    insert quo;
        GenerateDelegatedPricingQuote.GenerateQuoteResult gr= new GenerateDelegatedPricingQuote.GenerateQuoteResult (); 
        Test.startTest();       
        gr=GenerateDelegatedPricingQuote.createQuote(frmAgrRecord.id);
        Test.stopTest();
        Quote q=[select id,Name,Frame_Agreement__r.csconta__Agreement_Name__c from quote where id=:gr.id];
        System.assertEquals(q.Frame_Agreement__r.csconta__Agreement_Name__c,'AGR-TEST');
        //system.debug('quoteId'+quoteId);
         
    }
    
}