/****************************************************************************
@Name			: OpportunityLineItemTriggerHandlerTest
@Author			: SFO(SanFrancisco)/Sravanthi
@Sprint 		: 20.08[P2OB-6818]
@CreateDate		: 15/06/2020
@Description	: Test class for OpportunityLineItemTriggerHandler
********************************************************************************/
@isTest
public class OpportunityLineItemTriggerHandlerTest {
    @testSetup static void setup() {
        List<User> userList = new List<User>();
        User adminUser = TestUtil.createUser('admina1s2@test.com', 'adm', System.Label.Profile_SystemAdmin);
        User salesUser = TestUtil.createUser('salesone@test.com', 'sus', System.Label.Profile_SalesEnterprise);
        salesUser.Phone = '0445678001';
        userList.add(salesUser);
        userList.add(adminUser);
        insert userList;
        system.runas(adminUser){
            //CREATE Account
            Account acc = TestUtil.createAccount('Test Account');
            acc.OwnerId=salesUser.id;
            insert acc;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            //CREATE Pricebook
            Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
            insert pbk1;
            
            //CREATE Product
            Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
            insert prd1;
            
            //CREATE PricebookEntry
            PricebookEntry pbEntry = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
            insert pbEntry;
            
            //CREATE Opportunities
            List<Opportunity> oppList = new List<Opportunity>();
            for(integer i=0;i<5;i++){
                Opportunity opp = TestUtil.createOpportunity(acc.id);
                opp.Name='testopporunity'+i;
                //P2OB-6787 , Bypassed the NPSS field population for modular opportunities.
                opp.Product_Type__c =Label.Opp_ProductType_NonModular;
                oppList.add(opp);
            }
            insert oppList;
            
            //CREATE NPSS
            List<NPSS__c> npssList = new List<NPSS__c>();
            for(integer i=0;i<5;i++){
                NPSS__c npss = TestUtil.createNPSS('Test_ProductCode'+i);
                npssList.add(npss);
            }
            insert npssList;
            
            //CREATE OpportunityLineItem
            List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
            for(integer i=0;i<5;i++){
                OpportunityLineItem oppLineItem = TestUtil.createOpportunityLineItem(oppList[i].id);
                oppLineItem.PriceBookEntryID=pbEntry.id;
                oppLineItem.Product_Code__c ='Test_ProductCode'+i;
                oppLineItemList.add(oppLineItem);
            }
            OpportunityLineItem oppLineItem1 = TestUtil.createOpportunityLineItem(oppList[0].id);
            oppLineItem1.PriceBookEntryID=pbEntry.id;
            oppLineItem1.Product_Code__c ='Test_ProductCode';
            oppLineItemList.add(oppLineItem1);
            insert oppLineItemList;
        }
    }
    /*
Team SFO, sprint 20.08, P2OB-6818(Sravanthi)  
Testmethod to cover handleBeforeInsert & handleBeforeUpdate from class SFOOpportunityLineItemTriggerHandler
*/
    @isTest
    static void oppLineItemUnitTest(){   
        Test.startTest();
        OpportunityLineItem oppLineItemres = [SELECT ID,NPSS__c FROM OpportunityLineItem WHERE Product_Code__c='Test_ProductCode' LIMIT 1];
        system.assertEquals(oppLineItemres.NPSS__c, null);
        oppLineItemres.Product_Code__c ='Test_ProductCode4';
        update oppLineItemres;
        OpportunityLineItem oppLineItemrec2 = [SELECT ID,NPSS__c FROM OpportunityLineItem WHERE Product_Code__c='Test_ProductCode4' LIMIT 1];
        system.assertNotEquals(oppLineItemrec2.NPSS__c, null);
        Test.stopTest();
    }
    /*
Team SFO, sprint 20.08, P2OB-6264(Sravanthi)  
Testmethod to cover  handleBeforeInsert & handleBeforeUpdate from class SFOOpportunityLineItemTriggerHandler
*/
    @isTest
    static void oppLineItemNegUnitTest(){   
        Test.startTest();
        NPSS__c npss = [SELECT id FROM NPSS__c WHERE Name = 'Test_ProductCode1'];
        OpportunityLineItem oppLineItemres = [SELECT ID,NPSS__c FROM OpportunityLineItem WHERE Product_Code__c='Test_ProductCode1' LIMIT 1];
        system.assertEquals(oppLineItemres.NPSS__c, npss.Id);
        oppLineItemres.Product_Code__c ='Test_ProductCode3';
        update oppLineItemres;
        OpportunityLineItem oppLineItemrec2 = [SELECT ID,NPSS__c FROM OpportunityLineItem WHERE Product_Code__c='Test_ProductCode3' LIMIT 1];
        system.assertNotEquals(oppLineItemrec2.NPSS__c, null);
        Test.stopTest();
    }
}