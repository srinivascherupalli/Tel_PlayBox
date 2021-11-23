@isTest

public class BsktStageUpdateForClosedOpps_Test {
@testSetup 
    public static void testdatamethod1(){
         Account acc = new Account(name = 'test');
        insert acc;
        
        Opportunity testOpp = new Opportunity();
         testOpp.Account = acc;
            testOpp.Name = 'Test Account Opportunity';
            testOpp.StageName = 'Define';
             testOpp.StageName = 'Propose';
            testOpp.Product_Type__c = 'Modular';
            testOpp.CloseDate = System.Date.today();
            insert testOpp;
           
            cscfga__Product_Basket__c bas = new cscfga__Product_Basket__c();
            bas.Name = 'Test Account Opportunity Basket';
                bas.OwnerId = UserInfo.getUserId();
                bas.cscfga__Opportunity__c = testOpp.Id;
                bas.csbb__Account__c = acc.Id;
                bas.csordtelcoa__Basket_Stage__c = 'Enriched';
                bas.csbb__Synchronised_with_Opportunity__c = true;
                bas.csordtelcoa__Change_Type__c = 'New';
                insert bas;
    }
    @isTest static void testMethod1() {
       // UpdateFixedSeatCountOnIPNetwork_Test.testMethod1();
        Set<Id> closedWonOppIdSet = new Set<Id>();
        List<Opportunity> lstopp =[Select id,StageName from Opportunity WHERE Name='Test Account Opportunity'];
        for(Opportunity opp : lstopp){
            opp.StageName = 'Closed Won';
            opp.Product_Type__c = 'Modular';
            closedWonOppIdSet.add(opp.id);
        }
        Update lstopp;  
        BsktStageUpdateForClosedOppsTrigHandler objClass = new BsktStageUpdateForClosedOppsTrigHandler();
        objClass.validateClosedWon(closedWonOppIdSet, lstopp);
        objClass.cancelBasketStage(closedWonOppIdSet);
        objClass.submitBasketStage(closedWonOppIdSet);
        system.assert(lstopp[0].StageName == 'Closed Won');
    }
    
    @isTest static void testMethod2() {
       // UpdateFixedSeatCountOnIPNetwork_Test.testMethod1();
        Set<Id> closedWonOppIdSet = new Set<Id>();
        List<Opportunity> lstopp =[Select id,StageName,AccountId from Opportunity WHERE Name='Test Account Opportunity'];
       
       
       
       /* Account acc = new Account(name = 'test');
        insert acc;
        
        Opportunity testOpp = new Opportunity();
         testOpp.Account = acc;
            testOpp.Name = 'Test Account Opportunity';
            testOpp.StageName = 'Define';
             testOpp.StageName = 'Closed Won';
            testOpp.Product_Type__c = 'Modular';
            testOpp.CloseDate = System.Date.today();
            insert testOpp;
           */
            cscfga__Product_Basket__c bas = new cscfga__Product_Basket__c(Name = 'Test Account Opportunity Basket1',
                OwnerId = UserInfo.getUserId(),
                cscfga__Opportunity__c = lstopp[0].Id,
                csbb__Account__c = lstopp[0].AccountId,
                csordtelcoa__Basket_Stage__c = 'Draft',
                csbb__Synchronised_with_Opportunity__c = false,csordtelcoa__Change_Type__c = 'New');
                
                
                 Upsert bas;
                  for(Opportunity opp : lstopp){
            opp.StageName = 'Closed Won';
            opp.Product_Type__c = 'Modular';
            closedWonOppIdSet.add(opp.id);
        }
        Update lstopp;  
             //closedWonOppIdSet.add(testOpp.Id);
        BsktStageUpdateForClosedOppsTrigHandler objClass = new BsktStageUpdateForClosedOppsTrigHandler();
        objClass.validateClosedWon(closedWonOppIdSet,lstopp);
        objClass.cancelBasketStage(closedWonOppIdSet);
        objClass.submitBasketStage(closedWonOppIdSet);
        system.assert(lstopp[0].StageName == 'Closed Won');
    }
    
    @isTest
    static void testValidateDevelopOppty() {
        Delegated_Pricing_Request__c testDPR = new Delegated_Pricing_Request__c();
        Opportunity testOpp = [Select id,StageName, Product_Type__c from Opportunity WHERE Name='Test Account Opportunity'];
        testDPR.Opportunity__c = testOpp.Id;
        testDPR.isPrimary__c = true;
        testDPR.Deal_Status__c = 'Approved';
        insert testDPR;
        BsktStageUpdateForClosedOppsTrigHandler basketObject = new BsktStageUpdateForClosedOppsTrigHandler();
        Boolean expectedExceptionThrown = false;
        Test.startTest();
            try {
                basketObject.validateDevelopOppty(new Set<Id>{testOpp.Id}, new List<Opportunity>{testOpp});
            } catch(Exception e) {
                expectedExceptionThrown =  e.getMessage().contains(System.Label.Label_developOppError) ? true : false; 
            }
            
        Test.stopTest();
        
        System.assertEquals(expectedExceptionThrown, false,'Error does not occur');  
    }
    
    @isTest
    static void testValidateDevelopOpptyNegativeScenario() {
        Delegated_Pricing_Request__c testDPR = new Delegated_Pricing_Request__c();
        Opportunity testOpp = [Select id,StageName,Product_Type__c from Opportunity WHERE Name='Test Account Opportunity'];
        testDPR.Opportunity__c = testOpp.Id;
        testDPR.isPrimary__c = true;
        testDPR.Deal_Status__c = 'Rejected';
        insert testDPR;
        BsktStageUpdateForClosedOppsTrigHandler basketObject = new BsktStageUpdateForClosedOppsTrigHandler();
        Boolean expectedExceptionThrown = false;
        Test.startTest();
            try {
                basketObject.validateDevelopOppty(new Set<Id>{testOpp.Id}, new List<Opportunity>{testOpp});
            } catch(Exception e) {
                expectedExceptionThrown =  e.getMessage().contains(System.Label.Label_developOppError) ? true : false; 
            }
            
        Test.stopTest();
        
        System.assertNotEquals(expectedExceptionThrown, true,'Error does occur');  
    }
    
    @isTest
    static void testCancelDPRStage() {
        Delegated_Pricing_Request__c testDPR = new Delegated_Pricing_Request__c();
        csconta__frame_agreement__c testCFA =  new csconta__frame_agreement__c();           // Added as part of EDGE-205345
        Opportunity testOpp = [Select id,StageName,Product_Type__c,Pricing_Method__c from Opportunity WHERE Name='Test Account Opportunity'];
        testOpp.Pricing_Method__c = 'Delegated Pricing';
        update testOpp;
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prd1;
        PricebookEntry pbEntry = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert pbEntry;
        OpportunityLineItem testOLI = new OpportunityLineItem();
        testOLI.OpportunityId = testOpp.Id;
        testOLI.Quantity = 4;
        testOLI.TotalPrice = 100;
        testOLI.PriceBookEntryID=pbEntry.id;
        testOLI.Product_Code__c ='Test_ProductCode';
        insert testOLI;
        testDPR.Opportunity__c = testOpp.Id;
        insert testDPR;
        testCFA.Opportunity__c = testOpp.Id;       // Added as part of EDGE-205345
        insert testCFA;                           // Added as part of EDGE-205345
        BsktStageUpdateForClosedOppsTrigHandler basketObject = new BsktStageUpdateForClosedOppsTrigHandler();
        
        Test.startTest();
                basketObject.cancelDPRStage(new Set<Id>{testOpp.Id});
        Test.stopTest();
        
        System.assertNotEquals(testDPR.deal_status__c,'Cancelled','Status should be cancelled');  
        System.assertNotEquals(testCFA.csconta__Status__c,'Cancelled','Status should be cancelled');         // Added as part of EDGE-205345    
    }
    
    @isTest
    static void testupdateFADPRStatus() {
        Delegated_Pricing_Request__c testDPR = new Delegated_Pricing_Request__c();
        csconta__frame_agreement__c testFA =  new csconta__frame_agreement__c();
        Opportunity testOpp = [Select id,StageName,Product_Type__c,Pricing_Method__c from Opportunity WHERE Name='Test Account Opportunity'];
        testOpp.Pricing_Method__c = 'Delegated Pricing';
        testOpp.StageName = 'Closed Won';
        testOpp.Product_Type__c = 'Modular';
        update testOpp;
        testDPR.Opportunity__c = testOpp.Id;
        testDPR.isPrimary__c = false;
        testDPR.Deal_Status__c = 'Approved';
        insert testDPR;
        testFA.Opportunity__c = testOpp.Id; 
        testFA.csconta__Status__c = 'Approved';
        insert testFA;
         BsktStageUpdateForClosedOppsTrigHandler FADPR = new BsktStageUpdateForClosedOppsTrigHandler();       
        Test.startTest();
                FADPR.updateFAAndDealStatus(new list<Opportunity>{testOpp});
        Test.stopTest();
        delegated_Pricing_Request__c dpr= [select deal_Status__c from delegated_Pricing_Request__c where Opportunity__c = :testOpp.Id];
        csconta__Frame_Agreement__c fa =  [select csconta__Status__c from csconta__Frame_Agreement__c where Opportunity__c = :testOpp.Id];
        system.assertEquals('Cancelled',dpr.Deal_Status__c,'cancelled test pass');
        system.assertEquals('Cancelled',fa.csconta__Status__c,'cancelled test pass');
    }
    
}