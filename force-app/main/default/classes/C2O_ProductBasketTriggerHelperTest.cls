/*****
Code Coverage for Classes : C2O_ProductBasketTriggerHelper
* Class Name  : C2O_ProductBasketTriggerHelperTest
* Description : C2O_ProductBasketTriggerHelperTest runs the test class coverage logic on Product Basket records 
* Created By  : Uday Dunna 
* Change Log  : Created  
* Date : 16/09/2021 
********/ 

@isTest
public class C2O_ProductBasketTriggerHelperTest { 
    private static String OFT_Accrual_RecordType  = Schema.SObjectType.OneFund_Transactions__c.RecordTypeInfosByName.get('Fund Allocation').RecordTypeId;
    @testSetup static void testDataSetup() {
        //Creating Account test data
        List<Account> accList           =   new List<Account>();        
        Account testPartnerAccount = SYS_TestDataFactory.createAccount('1234565','Partner');
        testPartnerAccount.Name = 'Partner';
        accList.add(testPartnerAccount);
        
        Account testAccount             =   SYS_TestDataFactory.createAccount('1234567');
        testAccount.Name = 'TestAccount';
        accList.add(testAccount);
        insert accList;
        
        //Creating Contact test data
        List<Contact> contactList       =   new List<Contact>();
        Contact partnerContact = SYS_TestDataFactory.createContact(testPartnerAccount.Id);
        contactList.add(partnerContact);
        Contact testContact = SYS_TestDataFactory.createContact(testAccount.Id);
        contactList.add(testContact);
        insert contactList;
        
        //Creating Opportunity test data
        List<Opportunity> oppyList      =   new List<Opportunity>();
        Opportunity testpartnerOpp = SYS_TestDataFactory.createOpportunity(testPartnerAccount.Id);
        testpartnerOpp.Name             =   'testpartnerOpp';
        testpartnerOpp.Product_Type__c  =   'Modular';
        oppyList.add(testpartnerOpp);
        Opportunity testOpp = SYS_TestDataFactory.createOpportunity(testAccount.Id);
        testpartnerOpp.Name             =   'testOpp';
        testOpp.Product_Type__c         =   'Modular';
        oppyList.add(testOpp);
        Opportunity testOpp1 = SYS_TestDataFactory.createOpportunity(testAccount.Id);
        testpartnerOpp.Name             =   'testOpp1';
        testOpp1.Product_Type__c        =   'Non Modular';
        oppyList.add(testOpp1);
        insert oppyList;
        
        //Creating Product Definition test data
        cscfga__Product_Definition__c prodDef_IPNetwork = SYS_TestDataFactory.createProductDefinition('IP Network Description','Test');
        prodDef_IPNetwork.Name                          =   'IP Network';
        insert prodDef_IPNetwork;
        
        //Creating Product Basket test data
        List<cscfga__Product_Basket__c> basketList      =   new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket1 = SYS_TestDataFactory.createProductBasket(testPartnerAccount.Id,testpartnerOpp.Id);
        basket1.Name                                    =   'Basket 1';
        basket1.csordtelcoa__Basket_Stage__c            =   'Contract Accepted';
        basket1.Primary_Basket__c = true;
        basket1.csordtelcoa__Synchronised_with_Opportunity__c  = true;  
        basketList.add(basket1);
        
        cscfga__Product_Basket__c basket2 = SYS_TestDataFactory.createProductBasket(testAccount.Id,testOpp.Id);
        basket2.Name                                    =   'Basket 2';
        basket2.csordtelcoa__Basket_Stage__c            =   'Commercial Configuration';
        basketList.add(basket2);
        
        cscfga__Product_Basket__c basket3 = SYS_TestDataFactory.createProductBasket(testAccount.Id,testOpp1.Id);
        basket3.Name                                    =   'Basket 3';
        basket3.csordtelcoa__Basket_Stage__c            =   'Commercial Configuration';
        basketList.add(basket3);
        insert basketList;
        
        //Creating Product Configuration test data
        List <cscfga__Product_Configuration__c> pcList  =   new List <cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c config1 = SYS_TestDataFactory.createProductDefinition('IP Network Partner 1',basket1.Id,prodDef_IPNetwork.id);
        config1.cscfga__Product_Family__c               =   'Modular';
        config1.Quantity_Product_Configuration__c       =   1;
        config1.cscfga__Contract_Term__c                =   12;
        config1.Quantity_Product_Configuration__c       =   6;
        pcList.add(config1);
        
        cscfga__Product_Configuration__c config1IPSubt = SYS_TestDataFactory.createProductDefinition('IP Network Subcription Partner 1',basket1.Id,null); // Added as part of EDGE-133414
        config1IPSubt.cscfga__Product_Family__c         =   'Modular';
        config1IPSubt.Quantity_Product_Configuration__c =   1;
        config1IPSubt.cscfga__Contract_Term__c          =   12;
        pcList.add(config1IPSubt);
        
        cscfga__Product_Configuration__c config2 = SYS_TestDataFactory.createProductDefinition('IP Network 1',basket2.Id,prodDef_IPNetwork.id);  //EDGE-144345  changed to use ProductTestFactory
        config2.cscfga__Product_Family__c               =   'Modular';
        config2.Quantity_Product_Configuration__c       =   1;
        config2.cscfga__Contract_Term__c                =   12;
        config2.Quantity_Product_Configuration__c       =   6;
        pcList.add(config2);
        
        cscfga__Product_Configuration__c config2IPSubt = SYS_TestDataFactory.createProductDefinition('IP Network Subcription 1',basket2.Id,null); // Added as part of EDGE-133414
        config2IPSubt.cscfga__Product_Family__c         =   'Modular';
        config2IPSubt.Quantity_Product_Configuration__c =   1;
        config2IPSubt.cscfga__Contract_Term__c          =   12;
        pcList.add(config2IPSubt);
        
        cscfga__Product_Configuration__c config1Cancel = SYS_TestDataFactory.createProductDefinition('IP Network Subcription 1',basket2.Id,null); // Added as part of EDGE-133414
        config1Cancel.cscfga__Product_Family__c         =   'Modular';
        config1Cancel.Quantity_Product_Configuration__c =   1;
        config1Cancel.cscfga__Contract_Term__c          =   12;
        config1Cancel.Type__c                           =   'Cancel';
        pcList.add(config1Cancel);
        
        cscfga__Product_Configuration__c config3IPSubt = SYS_TestDataFactory.createProductDefinition('IP Network Subcription 1',basket3.Id,prodDef_IPNetwork.Id); // Added as part of EDGE-133414
        config3IPSubt.cscfga__Product_Family__c         =   'Non Modular';
        config3IPSubt.Quantity_Product_Configuration__c =   1;
        config3IPSubt.cscfga__Contract_Term__c          =   36;
        pcList.add(config3IPSubt);
        insert pcList;
        
        //Creating Attribute Data
        List <cscfga__Attribute__c> attributeList       =   new List <cscfga__Attribute__c>();  // Added as part of EDGE-133414
        cscfga__Attribute__c attETC1 = SYS_TestDataFactory.createAttribute('EarlyTerminationCharge',config1.Id);
        attETC1.cscfga__is_active__c                    =   true;
        attETC1.cscfga__Line_Item_Description__c        =   'IP Network Partner 1';        
        attETC1.cscfga__Recurring__c                    =   true;
        attributeList.add(attETC1);
        
        cscfga__Attribute__c attETC2 = SYS_TestDataFactory.createAttribute('EarlyTerminationCharge',config2.Id);
        attETC2.cscfga__is_active__c                    =   true;
        attETC2.cscfga__Line_Item_Description__c        =   'IP Network 1';        
        attETC2.cscfga__Recurring__c                    =   true;
        attributeList.add(attETC2); 
        
        cscfga__Attribute__c attETC3 = SYS_TestDataFactory.createAttribute('ETC',config1Cancel.Id);
        attETC3.cscfga__is_active__c                    =   true;
        attETC3.cscfga__Line_Item_Description__c        =   'IP Network 1';        
        attETC3.cscfga__Recurring__c                    =   true;
        attributeList.add(attETC3); 
        
        cscfga__Attribute__c attETCIPSubt1              =   SYS_TestDataFactory.createAttribute('ETC',config1IPSubt.Id);
        attETCIPSubt1.cscfga__is_active__c              =   true;
        attETCIPSubt1.cscfga__Line_Item_Description__c  =   'IP Network Subcription  1';        
        attributeList.add(attETCIPSubt1);
        
        cscfga__Attribute__c attETCIPSubt2              =   SYS_TestDataFactory.createAttribute('ETC',config2IPSubt.Id); 
        attETCIPSubt2.cscfga__is_active__c              =   true;
        attETCIPSubt2.cscfga__Line_Item_Description__c  =   'IP Network Subcription  1';        
        attributeList.add(attETCIPSubt2);
        
        cscfga__Attribute__c attSplCharge               =   SYS_TestDataFactory.createAttribute('ETC',config3IPSubt.Id); 
        attSplCharge.cscfga__is_active__c               =   true;
        attSplCharge.cscfga__Line_Item_Description__c   =   'Special Charge'; 
        attributeList.add(attSplCharge);
        
        cscfga__Attribute__c attRF1                     =   SYS_TestDataFactory.createAttribute('ETC',config1.Id); 
        attributeList.add(attRF1);           
    }   //End of testDataSetup()
    
    
    @istest 
    private static void unitTest1(){
        List<cscfga__Product_Basket__c> basketList  =   [SELECT Id,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c];
        Set<String> setProductBasketId              =   new Set<String>();        
        for(cscfga__Product_Basket__c oBasket : basketList) {
            oBasket.csbb__Synchronised_With_Opportunity__c  =   true;
            setProductBasketId.add(oBasket.Id);
        }
        
        Test.startTest();
        if(!basketList.isEmpty()) {
            update basketList;
        }
        
        
        List<cscfga__Product_Basket__c> updatebasketList  =   [SELECT Id,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Basket__c];
        set<string> basketId = new Set<String>();
        for(cscfga__Product_Basket__c basket : updatebasketList) {
            basket.csbb__Synchronised_With_Opportunity__c = false;
            basketId.add(basket.Id);
        }
        ProductUtility.createOLIs(basketId);
        List<OpportunityLineItem> oliList   =   new List<OpportunityLineItem>([SELECT Id,Name,OpportunityId,Opportunity.Name,Opportunity.Basket_Redemption_amount__c FROM OpportunityLineItem]);
        System.assertNotEquals(11, oliList.size(), 'OLIs are also created for Attribute with Is Line Item != true');
        
        update updatebasketList;
        Test.stopTest();
    }
    
    @isTest private static void unitTest2() {
        Test.startTest();
        Account acc                             =   [SELECT Id FROM Account WHERE Name = 'testAccount' LIMIT 1];
        cscfga__Product_Basket__c prodBasket    =   [SELECT Id,cscfga__Opportunity__c,csbb__Account__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.Id LIMIT 1];
        cscfga__Product_Definition__c oProdDef  =   [SELECT Id FROM cscfga__Product_Definition__c WHERE Name='IP Network' LIMIT 1];
        
        //prodBasket.csbb__Synchronised_With_Opportunity__c   =   true;
        //update prodBasket;
        
        cscfga__Product_Basket__c basket1   =   new cscfga__Product_Basket__c(
            Name = 'Test Basket',
            csbb__Account__c = prodBasket.csbb__Account__c, 
            cscfga__Opportunity__c = prodBasket.cscfga__Opportunity__c,
            csordtelcoa__Basket_Stage__c = 'Commercial Configuration');
        insert basket1;
        
        cscfga__Product_Configuration__c config1        =   ProductTestFactory.buildProductConfig(oProdDef.Id);
        config1.Name                                    =   'IP Network Partner 1';
        config1.cscfga__Product_Basket__c               =   basket1.Id;
        config1.cscfga__Product_Family__c               =   'Modular';
        config1.Quantity_Product_Configuration__c       =   1;
        config1.cscfga__Contract_Term__c                =   12;
        config1.Quantity_Product_Configuration__c       =   6;
        insert config1;
        
        List <cscfga__Attribute__c> attributeList       =   new List <cscfga__Attribute__c>();
        cscfga__Attribute__c attSplCharge               =   ProductTestFactory.buildPriceAttribute('Special Charge','300',config1.Id,true,300);
        attSplCharge.cscfga__is_active__c               =   true;
        attSplCharge.cscfga__Line_Item_Description__c   =   'Special Charge'; 
        attributeList.add(attSplCharge);
        cscfga__Attribute__c attAddress                 =   ProductTestFactory.buildAttribute('Address','X Street',config1.Id);
        attributeList.add(attAddress);
        insert attributeList;
        
        basket1.csbb__Synchronised_With_Opportunity__c  =   true;
        update basket1;
        Test.stopTest(); 
        
        List<cscfga__Product_Basket__c> prodbasketList = [SELECT Id,Name,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__c =: prodBasket.cscfga__Opportunity__c];
        for(cscfga__Product_Basket__c basket : prodbasketList) {
            if(basket.Name=='Test Basket') {
                System.assertEquals(true, basket.csordtelcoa__Synchronised_with_Opportunity__c, 'Basket is not synchronised with opportunity sucessfully');
                System.assertEquals(true, basket.csbb__Synchronised_With_Opportunity__c,'Basket is not synchronised with opportunity sucessfully');
            } 
        }
    }   //End of unitTest2()
    
    @istest 
    private static void unitTest3(){
        Test.startTest();
        Account acc                             =   [SELECT Id FROM Account WHERE Name = 'testAccount' LIMIT 1];
        cscfga__Product_Basket__c prodBasket    =   [SELECT Id,cscfga__Opportunity__c,csbb__Account__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.Id AND cscfga__Opportunity__r.Product_Type__c='Modular' LIMIT 1];
        cscfga__Product_Definition__c oProdDef  =   [SELECT Id FROM cscfga__Product_Definition__c WHERE Name='IP Network' LIMIT 1];
        Id opportunityId                        =   prodBasket.cscfga__Opportunity__c;
        
        prodBasket.csbb__Synchronised_With_Opportunity__c   =   true;
        update prodBasket;
        
        ProductUtility.createOLIs(new Set<String>{prodBasket.Id});
        
        
        Map<Id,cscfga__Product_Basket__c> updatebasketMap  =   new Map<Id,cscfga__Product_Basket__c>([SELECT Id,csordtelcoa__Basket_Stage__c,cscfga__Opportunity__c,cscfga__total_contract_value__c,Primary_Basket__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c,cscfga__Opportunity__r.Product_Type__c FROM cscfga__Product_Basket__c WHERE Id=:prodBasket.Id]);
        for(cscfga__Product_Basket__c basket : updatebasketMap.values()) {
            System.assertEquals(true, basket.csordtelcoa__Synchronised_with_Opportunity__c, 'Basket is not synchronised with opportunity sucessfully');
            System.assertEquals(true, basket.csbb__Synchronised_With_Opportunity__c,'Basket is not synchronised with opportunity sucessfully');
        }
        
        List<OpportunityLineItem> oliList   =   new List<OpportunityLineItem>([SELECT Id,Name,Domain__c,OpportunityId,Opportunity.Name,Opportunity.Basket_Redemption_amount__c FROM OpportunityLineItem]);
        
        Integer i = 1;
        for(OpportunityLineItem oli : oliList) {
            if(i==1) { i++; continue; }
            oli.Domain__c = oli.Name + ' i';
            i++;
        }        
        update oliList;        
        
        BasketOpportunityUpdateHelper.updateOpportunityDetails(updatebasketMap,new Set<Id>{opportunityId});  
        Test.stopTest(); 
        List<Opportunity> oppList = [SELECT Id,Domain__c FROM Opportunity WHERE Id=:opportunityId];
        System.assertEquals('Single',oppList[0].Domain__c);
        
    } 
    /****************************************************************************************************************
* Method Name : OnBeforeUpdateTest
* Description : Used to simulate and test the logic of OnBeforeUpdate method in ProductBasketCustomTriggerHandler
* Parameters  : NA
* Return      : NA                      
****************************************************************************************************************/
    static testmethod void onBeforeUpdateTest() {
        Test.startTest();
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Name = 'Test Basket', csordtelcoa__Account__c = acc.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE);
        INSERT basket;
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c(Name = 'IP Site', cscfga__Product_Definition__c = TestDataFactory.generateProductDefinition().Id,
                                                                                           Quantity_Product_Configuration__c = 2, cscfga__Product_Basket__c = basket.Id );
        INSERT prodConfig;
        
        basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        UPDATE basket;
        System.assert(basket!=null);
        Test.stopTest();
        
    }
    
    /****************************************************************************************************************
* Method Name : OnBeforeUpdateTest1
* Description : Used to simulate and test the logic of OnBeforeUpdate method in ProductBasketCustomTriggerHandler
* Parameters  : NA
* Return      : NA                      
****************************************************************************************************************/
    static testmethod void onBeforeUpdateTest1() {
        Test.startTest();
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Name = 'Test Basket', csordtelcoa__Account__c = acc.Id, cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE,Project_Complexity__c='Complex');
        INSERT basket;
        
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c(Name = 'Test Config', cscfga__Product_Definition__c = TestDataFactory.generateProductDefinition().Id,
                                                                                           Quantity_Product_Configuration__c = 2, cscfga__Product_Basket__c = basket.Id );
        INSERT prodConfig;
        
        basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        UPDATE basket;
        System.assert(basket!=null);
        Test.stopTest();
    }
    /****************************************************************************************************************
* Method Name : OnBeforeUpdateTest1
* Description : Used to simulate and test the logic of OnBeforeUpdate method in ProductBasketCustomTriggerHandler
* Parameters  : NA
* Return      : NA                      
****************************************************************************************************************/
    static testmethod void onAfterUpdateTest() {
        Test.startTest();
        cscfga__Product_Basket__c basket = [Select id,csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c limit 1];
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c(Name = 'IP Site', cscfga__Product_Definition__c = TestDataFactory.generateProductDefinition().Id,
                                                                                           Quantity_Product_Configuration__c = 2, cscfga__Product_Basket__c = basket.Id );
        INSERT prodConfig;
        
        basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        UPDATE basket;
        System.assert(basket!=null);
        Test.stopTest();
    }
    /***************************************************************************************************************
* Method Name : OnAfterUpdateTest2
* Description : Used to simulate and test the logic of OnAfterUpdate method in ProductBasketCustomTriggerHandler
* Parameters  : NA
* Return      : NA                      
//Pooja : Added this method as part of Spring'20 Upgrade, to increase the code coverage
***************************************************************************************************************/
    static testmethod void onAfterUpdateTest2() { 
        Test.startTest();
        Account oAcc            =   [SELECT Id,Name FROM Account WHERE Name='testAccount' LIMIT 1];
        Opportunity oOppy       =   [SELECT Id,Name,AccountId,Product_Type__c FROM Opportunity WHERE AccountId=:oAcc.Id LIMIT 1];
        oOppy.Product_Type__c   =   'Non Modular';
        update oOppy;
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
        for(cscfga__Product_Basket__c oBask : [SELECT Id,Name,csordtelcoa__Account__c,cscfga__Opportunity__c,cscfga__Products_In_Basket__c,Primary_Basket__c, csordtelcoa__Basket_Stage__c,cscfga__Basket_Status__c,csbb__Synchronised_with_Opportunity__c,cscfga__Products_Id_Qty_In_Basket__c FROM cscfga__Product_Basket__c WHERE csordtelcoa__Account__c =:oAcc.Id AND cscfga__Opportunity__c =:oOppy.Id]) {
            if(oBask.Name=='Test Basket12345') {oBask.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';oBask.cscfga__Products_In_Basket__c='Test';}
            if(oBask.Name=='Test Basket1102012') oBask.csordtelcoa__Basket_Stage__c = 'Quote';
            basketList.add(oBask);
        }
        update basketList;
        System.assertEquals(1,basketList.size());  
        Test.stopTest();
    }
    
    static testMethod void negativeTest2(){
        Test.startTest();
        C2O_ProductBasketTriggerHelper.updateOldQuotesToVoid(null);
        Test.stopTest();
    }
    
    static testmethod void negativeTest(){
        C2O_ProductBasketTriggerHelper.updateProductBasketName(null); 
        C2O_ProductBasketTriggerHelper.updateAttributeInfo(null,null);
    }
    
    static testmethod void unSyncProductBasketAfterInsertUpdateTest(){
        Test.startTest();
        Account oAcc            =   [SELECT Id,Name FROM Account WHERE Name='testAccount' LIMIT 1];
        Opportunity opp       =   [SELECT Id,Name,AccountId,Product_Type__c FROM Opportunity WHERE AccountId=:oAcc.Id LIMIT 1];
        
        cscfga__Product_Basket__c basket1 = SYS_TestDataFactory.createProductBasket(oAcc.Id,opp.Id);
        basket1.Name                                    =   'Basket 1';
        basket1.csordtelcoa__Basket_Stage__c            =   'Contract Accepted';
        basket1.Primary_Basket__c = true;
        basket1.csordtelcoa__Synchronised_with_Opportunity__c  = true;  
        insert basket1;
        
        cscfga__Product_Basket__c basket2 = SYS_TestDataFactory.createProductBasket(oAcc.Id,opp.Id);
        basket2.Name                                    =   'Basket 2';
        basket2.csordtelcoa__Basket_Stage__c            =   'Commercial Configuration';
        insert basket2;
        
        basket2.csordtelcoa__Synchronised_with_Opportunity__c  = true;  
        update basket2; 
        Test.stopTest(); 
    }
    
    static testmethod void deleteOLIsProductDetailsAfterUpdateTest(){
        Test.startTest();
        Account acc1            =   [SELECT Id,Name FROM Account WHERE Name='testAccount' LIMIT 1];
        Opportunity opp       =   [SELECT Id,Name,AccountId,Product_Type__c FROM Opportunity WHERE AccountId=:acc1.Id LIMIT 1];
        
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Name = 'Test Basket12345',cscfga__Opportunity__c = opp.Id, csordtelcoa__Account__c = acc1.Id,  Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Commercial Configuration', cscfga__Basket_Status__c = 'Valid',cscfga__Products_Id_Qty_In_Basket__c= '1',csordtelcoa__Synchronised_with_Opportunity__c = true);
        insert basket1;
        
        basket1.csordtelcoa__Synchronised_with_Opportunity__c = false;
        update basket1;
        Test.stopTest();
    }
    static testmethod void updateOpportunityDetailsInsertUpdateTest(){
        Test.startTest();
        Map<Id,cscfga__Product_Basket__c> mapNewPB = new Map<Id,cscfga__Product_Basket__c>();
        Account acc1 = new Account(Name = 'Test Account1');
        INSERT acc1;
        Opportunity opp = new Opportunity(Name = 'Test Opp1', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp;
        Opportunity oppty = new Opportunity(Name = 'Test Oppty', StageName = 'Develop',  CloseDate = Date.today());
        INSERT oppty;
        
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Name = 'Test Basket12345',cscfga__Opportunity__c = opp.Id, csordtelcoa__Account__c = acc1.Id,  Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Commercial Configuration', cscfga__Basket_Status__c = 'Valid',cscfga__Products_Id_Qty_In_Basket__c= '1',csordtelcoa__Synchronised_with_Opportunity__c = true);
        insert basket1;
        
        basket1.cscfga__Opportunity__c = oppty.Id;
        update basket1;
        
        cscfga__Product_Basket__c bskt = [Select Id,cscfga__Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c From cscfga__Product_Basket__c Where Id = :basket1.Id];      
        mapNewPB.put(bskt.Id,bskt);
        Test.stopTest();
    }
    
    static testMethod void revalidateProductBasketsAfterUpdateTest(){
        Test.startTest();
        List<cscfga__Product_Basket__c> lstNewPB = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Name = 'Test Basket12345', Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Commercial Configuration', cscfga__Basket_Status__c = 'Valid',cscfga__Products_Id_Qty_In_Basket__c= '1',csordtelcoa__Synchronised_with_Opportunity__c = true);
        insert basket1;
        lstNewPB.add(basket1);
        Test.stopTest();
    }
    
    static testMethod void updateOldQuotesToVoidTest(){
        Test.startTest();
        Opportunity opp = new Opportunity(Name = 'Test Opp1', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp;
        List<cscfga__Product_Basket__c> lstNewPB = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Name = 'Test Basket12345',cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Contract Initiated', cscfga__Basket_Status__c = 'Valid',cscfga__Products_Id_Qty_In_Basket__c= '1',csordtelcoa__Synchronised_with_Opportunity__c = true);
        insert basket1;
        Quote qte = new Quote();
        qte.Name = 'Test';
        qte.Product_Basket__c = basket1.Id;
        qte.Status = 'Presented';
        qte.OpportunityId = opp.Id;
        insert qte;
        basket1.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        update basket1;
        lstNewPB.add(basket1);
        C2O_ProductBasketTriggerHelper.updateOldQuotesToVoid(lstNewPB); 
        Test.stopTest();
    }
    
    static testMethod void updateBasketStageTest(){
        Test.startTest();
        List<cscfga__Product_Basket__c> lstNewPB = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Name = 'Test Basket12345',Project_Complexity__c = 'Complex', csordtelcoa__Basket_Stage__c = 'Contract Accepted',Primary_Basket__c = TRUE, cscfga__Basket_Status__c = 'Valid',cscfga__Products_Id_Qty_In_Basket__c= '1',csordtelcoa__Synchronised_with_Opportunity__c = true);
        insert basket1;
        lstNewPB.add(basket1);
        Test.stopTest();
    }
    
    static testMethod void getUpdatedAttributeTest(){
        Test.startTest();
        cscfga__Product_Basket__c basket = [Select id,csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c limit 1];
        cscfga__Product_Configuration__c prodConfig = new cscfga__Product_Configuration__c(Name = 'IP Site', cscfga__Product_Definition__c = TestDataFactory.generateProductDefinition().Id,
                                                                                           Quantity_Product_Configuration__c = 2, cscfga__Product_Basket__c = basket.Id );
        insert prodConfig;
        
        cscfga__Attribute__c att = new cscfga__Attribute__c();
        att.cscfga__Product_Configuration__c = prodConfig.Id;
        att.Name = 'Test';
        insert att; 
        
        C2O_ProductBasketTriggerHelper.getUpdatedAttribute(att,'Test','Test'); 
        Test.stopTest(); 
    }
    
    static testMethod void getUpdatedQuoteStatusTest(){
        Test.startTest();
        map <id,cscfga__Product_Basket__c> updateQuoteMap = new map <id,cscfga__Product_Basket__c>();
        Opportunity opp = new Opportunity(Name = 'Test Opp1', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp;
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Name = 'Test Basket12345',cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Contract Initiated', cscfga__Basket_Status__c = 'Valid',cscfga__Products_Id_Qty_In_Basket__c= '1',csordtelcoa__Synchronised_with_Opportunity__c = true);
        insert basket1;
        updateQuoteMap.put(basket1.cscfga__Opportunity__c,basket1);
        Quote qte = new Quote();
        qte.Name = 'Test';
        qte.Product_Basket__c = basket1.Id;
        qte.Status = 'Presented';
        qte.OpportunityId = opp.Id;
        insert qte;
        C2O_ProductBasketTriggerHelper.getUpdatedQuoteStatus(updateQuoteMap);
        Test.stopTest();
    }
    
    static testMethod void getUpdatedQuoteStatusTest2(){
        Test.startTest();
        map <id,cscfga__Product_Basket__c> updateQuoteMap = new map <id,cscfga__Product_Basket__c>();
        Opportunity opp = new Opportunity(Name = 'Test Opp1', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp;
        Opportunity opp1 = new Opportunity(Name = 'Test Opp2', StageName = 'Develop',  CloseDate = Date.today());
        INSERT opp1;
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Name = 'Test Basket12345',cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Contract Initiated', cscfga__Basket_Status__c = 'Valid',cscfga__Products_Id_Qty_In_Basket__c= '1',csordtelcoa__Synchronised_with_Opportunity__c = true);
        insert basket1;
        cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c(Name = 'Test Basket123456',cscfga__Opportunity__c = opp1.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Contract Initiated', cscfga__Basket_Status__c = 'Valid',cscfga__Products_Id_Qty_In_Basket__c= '1',csordtelcoa__Synchronised_with_Opportunity__c = true);
        insert basket2;
        updateQuoteMap.put(opp1.Id,basket1); 
        Quote qte = new Quote();
        qte.Name = 'Test';
        qte.Product_Basket__c = basket2.Id;
        qte.Status = 'Presented'; 
        qte.OpportunityId = opp1.Id;
        insert qte;
        C2O_ProductBasketTriggerHelper.getUpdatedQuoteStatus(updateQuoteMap);
        Test.stopTest();
    }
    
    static testMethod void oneFundTransactionBasedOnExpiryDateTest1(){
        Test.startTest();
        Account acc1            =   [SELECT Id,Name FROM Account WHERE Name='testAccount' LIMIT 1];
        Opportunity opp       =   [SELECT Basket_Redemption_amount__c FROM Opportunity WHERE AccountId=:acc1.Id LIMIT 1];
        opp.Basket_Redemption_amount__c = 30;
        update opp;        
        
        OneFund__c fundRecord1 = new OneFund__c(Contract_Duration__c = '24',Customer_Commitment__c = '1000',CIDN__c = acc1.id);
        insert fundRecord1;
         
        OneFund_Transactions__c tran = new OneFund_Transactions__c();
		tran.Transaction_Amount__c = 25;
        tran.Redeemed_Amount__c = 15;
        tran.Expiry_Date__c = Date.today() + 10;
        tran.RecordTypeId = OFT_Accrual_RecordType;
        tran.Transaction_Status__c = 'Active';
        tran.OneFund__c = fundRecord1.Id;
        insert tran;
      
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Name = 'Test Basket12345',cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Contract Accepted', cscfga__Basket_Status__c = 'Valid',cscfga__Products_Id_Qty_In_Basket__c= '1',csbb__Synchronised_With_Opportunity__c = true);
        insert basket1;
        Test.stopTest();
    }
    
    static testMethod void oneFundTransactionBasedOnExpiryDateTest2(){
        Test.startTest();
        Account acc1            =   [SELECT Id,Name FROM Account WHERE Name='testAccount' LIMIT 1];
        Opportunity opp       =   [SELECT Basket_Redemption_amount__c FROM Opportunity WHERE AccountId=:acc1.Id LIMIT 1];
        opp.Basket_Redemption_amount__c = 10;
        update opp;        
        
        OneFund__c fundRecord1 = new OneFund__c(Contract_Duration__c = '24',Customer_Commitment__c = '1000',CIDN__c = acc1.id);
        insert fundRecord1;
         
        OneFund_Transactions__c tran = new OneFund_Transactions__c();
		tran.Transaction_Amount__c = 45;
        tran.Redeemed_Amount__c = 15;
        tran.Expiry_Date__c = Date.today() + 10;
        tran.RecordTypeId = OFT_Accrual_RecordType;
        tran.Transaction_Status__c = 'Active';
        tran.OneFund__c = fundRecord1.Id;
        insert tran;
      
        cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Name = 'Test Basket12345',cscfga__Opportunity__c = opp.Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Contract Accepted', cscfga__Basket_Status__c = 'Valid',cscfga__Products_Id_Qty_In_Basket__c= '1',csbb__Synchronised_With_Opportunity__c = true);
        insert basket1;
        Test.stopTest();
    }

    //DIGI-6869 : Test Method to cover Non Modular Opportunity Reopen Logic
    static testMethod void reopenStdOpportunityTest() {
        List<Account> accLst        =   [SELECT Id,Name FROM Account WHERE Name='TestAccount' LIMIT 1];
        List<Opportunity> oppLst    =   [SELECT Id,Name,StageName FROM Opportunity WHERE AccountId=:accLst[0].Id AND Product_Type__c = 'Non Modular' LIMIT 1];
        
        Environment_Configurations__c ecCS  =   new Environment_Configurations__c();
        ecCS.No_Validations__c              =   true;
        insert ecCS;

        Test.startTest();
            if(oppLst.size() == 1) {
                cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c(Name = 'Test Basket12345',cscfga__Opportunity__c = oppLst[0].Id, Primary_Basket__c = TRUE, csordtelcoa__Basket_Stage__c = 'Commercial Configuration', cscfga__Basket_Status__c = 'Valid',cscfga__Products_Id_Qty_In_Basket__c= '1',csbb__Synchronised_With_Opportunity__c = true);
                insert basket1;
                oppLst[0].StageName = 'Closed Won';
                update oppLst; 
                List<cscfga__Product_Basket__c> basktLst = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE Id=:basket1.Id];
                System.assertNotEquals(0, basktLst.size());
                System.assertEquals('Submitted', basktLst[0].csordtelcoa__Basket_Stage__c);

                OpportunityTriggerHelper.isUpdateBasket = false;
                
                oppLst[0].StageName = 'Propose'; 
                update oppLst;
                List<cscfga__Product_Basket__c> basktLst1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE Id=:basket1.Id];
                System.assertNotEquals(0, basktLst1.size());
                System.assertEquals('Commercial Configuration', basktLst1[0].csordtelcoa__Basket_Stage__c);
            }
        Test.stopTest();
    }
}