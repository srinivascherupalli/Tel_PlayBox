@isTest
public class DPRSyncwithOpportunityTriggerTest  {
 
    @isTest
    public static void testOppWithOneDPRModularAndScored(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        System.assertNotEquals(null,acc);
        
        //CREATE PRODUCT
        Product2 prod = new Product2(Name = 'Adaptive Mobility',Family = 'Mobile', ProductCode = 'DMCAT_Offer_001233');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
        
        //CREATE PRICEBOOKENTRY
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;
        
        insert pbe;
        
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        opp.StageName = 'Define';
        opp.Pricing_Method__c = 'Delegated Pricing';
        insert opp;
        System.assertNotEquals(null,opp);
         
        Opportunity orpportunityDetailsRecord = ProductTestFactory.getOpportunityBasic(acc);
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        //orpportunityDetailsRecord.AccountId = acc.Id;
        insert orpportunityDetailsRecord;
        
        //Create two dpr and one dpr scored and synced
        //List<delegated_Pricing_Request__c> dprList = new List<delegated_Pricing_Request__c>();
        delegated_Pricing_Request__c dpr = ProductTestFactory.buildEmptyDPR();
        dpr.Opportunity__c = opp.id;
        dpr.deal_status__c='Draft';
        dpr.isPrimary__c = true;
        dpr.Synchronise_With_Opportunity__c=true;
        //dprList.add(dpr);
        insert dpr;
        
        //List<dpr_Offer__c> dprOfferList = new List<dpr_Offer__c>();
        dpr_Offer__c dprOffer = new dpr_Offer__c();
        dprOffer.delegated_Pricing_Request__c = dpr.id;
        dprOffer.Name = 'Adaptive Mobility';
        dprOffer.PF_Contract_Term__c = 24; //EDGE-229638
        //dprOfferList.add(dprOffer);
        insert dprOffer;
        
        //List<DPR_Offer_Line_Item__c> DPRoliList = new List<DPR_Offer_Line_Item__c>();
        DPR_Offer_Line_Item__c DPRoli = new DPR_Offer_Line_Item__c();
        DPRoli.Delegated_Pricing_Request__c = dpr.id;
        DPRoli.DPR_Offer__c = dprOffer.id;
        DPRoli.Quantity__c = 2;
        DPRoli.Recontracting_Quantity__c = 2;
        DPRoli.DPR_Offer_Line_Item_Type__c = 'Plan';
        DPRoli.Overridden_Unit_Price__c = 25;
        DPRoli.Overridden_Total_Price__c = 100;
        DPRoli.isNegotiableCharge__c = true;
        //DPRoliList.add(DPRoli);
        insert DPRoli;
        
        System.debug('dprOffer......... '+dprOffer);
        
        Test.startTest();
        
            dpr.deal_status__c='Scored';
            update dpr;
        
            dpr.deal_status__c='Approved';
            update dpr;
        
            dpr.deal_status__c='Contract Generated';
            update dpr;
            
            dpr.deal_status__c='Draft';
            update dpr;
            
            dpr.deal_status__c='Rejected';
            update dpr;
            
            
            
        Test.stopTest();  
        //added assert statements for DPR offer line items - EDGE 184803
         List<DPR_Offer_Line_Item__c> doli = [Select id from DPR_Offer_Line_Item__c];
         DPR_Offer_Line_Item__c DPRli = [select isNegotiableCharge__c from DPR_Offer_Line_Item__c where DPR_Offer_Line_Item_Type__c = 'Plan'];
         system.assertEquals(1,doli.size());
         system.assertEquals(true,DPRli.isNegotiableCharge__c);
    }    
    
}