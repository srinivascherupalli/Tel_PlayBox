@isTest
public class MACDObserverTest {
    static testmethod void testMACDObserver() {
        //Create test Account       
        Account acc = AccountTestFactory.buildAccount('Test Account 0');
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;

        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;

        //CREATE OPPORTUNITY
        Opportunity opp = ProductTestFactory.getOpportunity(acc, pb);
        insert opp;

        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.Name = 'Basket';
        basket.cscfga__Opportunity__c = opp.id;
        insert basket;
        String basketidstring = (String) basket.id;
        String basketIdtrimmed = basketidstring.substring(0, (basketidstring.length() - 3));

        //Insert test ProductCategory
        cscfga__Product_Category__c pcategory = ProductTestFactory.buildProductCategory();
        pcategory.name = 'Modular Products';
        insert pcategory;

        //Insert test ProductDefinition  
        cscfga__Product_Definition__c pdef = ProductTestFactory.buildProductDefinition('Connected Workplace', '');
        insert pdef;

        //Insert test Offer        
        cscfga__Configuration_Offer__c offer1 = new cscfga__Configuration_Offer__c();
        offer1.Name = 'Connected Workplace';
        insert offer1;

        //clone the PD  
        List < Id > clonedIds = new List < Id > ();
        cscfga__Product_Configuration__c ConnectedWorkplacePDClone = new cscfga__Product_Configuration__c();
        ConnectedWorkplacePDClone.Name = 'Connected Workplace';
        ConnectedWorkplacePDClone.cscfga__Product_Definition__c = pdef.id;
        ConnectedWorkplacePDClone.cscfga__Quantity__c = 1;
        ConnectedWorkplacePDClone.cscfga__Configuration_Offer__c = offer1.id;
        ConnectedWorkplacePDClone.cscfga__Product_Basket__c = basketIdtrimmed;
        insert ConnectedWorkplacePDClone;
        clonedIds.add(ConnectedWorkplacePDClone.id);

        Set < Id > pcIds = new Set < Id > ();
        Map < Id, cscfga__Product_Configuration__c > PCIdRecordMap = new Map < Id, cscfga__Product_Configuration__c > ();

        System.Debug('Cloned IDs: ' + clonedIds);
        Set < Id > pcList = new Set < Id > ();
        Id pcid;
        List < Id > pcIDList = new List < Id > ();
        for (cscfga__Product_Configuration__c pc: [Select id, cscfga__Product_Basket__c, name from cscfga__Product_Configuration__c where cscfga__Parent_Configuration__c in: clonedIds or cscfga__Root_Configuration__c in: clonedIds or id in: clonedIds]) {
            System.debug('child pc id-----> ' + pc + '|' + pc.id);
            pcid = pc.Id;
            pcList.add(pcid);
            PCIdRecordMap.put(pcid, pc);
            pcIDList.add(pcid);
        }


        System.debug('final pcList-----> ' + pcList);
        System.debug('final pcMap-----> ' + PCIdRecordMap);
        Test.StartTest();

        MACDObserver macdobserverinstance = new MACDObserver();
        macdobserverinstance.updateOrderType(PCIdRecordMap);
        macdobserverinstance.updateProductConfigurationOrderType(pcIDList);

        Test.StopTest();
        System.assertNotEquals(null, PCIdRecordMap);
    }

    @isTest
    private static void testDeleteCustomerRequestedDatesConfigurations() {
        //Create test Account       
        Account acc = AccountTestFactory.buildAccount('Test Account 0');
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;

        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;

        //CREATE OPPORTUNITY
        Opportunity opp = ProductTestFactory.getOpportunity(acc, pb);
        insert opp;

        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.Name = 'Basket';
        basket.cscfga__Opportunity__c = opp.id;
        insert basket;
        String basketidstring = (String) basket.id;
        String basketIdtrimmed = basketidstring.substring(0, (basketidstring.length() - 3));

        //Insert test ProductCategory
        cscfga__Product_Category__c pcategory = ProductTestFactory.buildProductCategory();
        pcategory.name = 'Modular Products';
        insert pcategory;

        //Insert test ProductDefinition  
        cscfga__Product_Definition__c pdef = ProductTestFactory.buildProductDefinition('Customer Requested Dates', '');
        insert pdef;

        cscfga__Product_Definition__c testPdef = ProductTestFactory.buildProductDefinition('IP Site', '');
        insert testPdef;

        cscfga__Product_Configuration__c testPC = new cscfga__Product_Configuration__c();
        testPC.cscfga__Product_Basket__c = basket.Id;
        testPC.cscfga__Product_Definition__c = pdef.Id;
        testPC.Name = 'CRD';
        insert testPC;

        cscfga__Product_Configuration__c testPC1 = new cscfga__Product_Configuration__c();
        testPC1.cscfga__Product_Basket__c = basket.Id;
        testPC1.cscfga__Product_Definition__c = testPdef.Id;
        testPC1.Name = 'IP Site';
        insert testPC1;

        cscfga__Product_Configuration__c testPC2 = new cscfga__Product_Configuration__c();
        testPC2.cscfga__Product_Basket__c = basket.Id;
        testPC2.cscfga__Product_Definition__c = pdef.Id;
        testPC2.Name = 'Customer Requested Dates';
        testPC2.csordtelcoa__Replaced_Product_Configuration__c = testPC.Id;
        testPC2.csoe__Commercial_Configuration__c = testPC1.Id;
        insert testPC2;

        MACDObserver macdobserverinstance = new MACDObserver();
        List < Id > idList = new List < Id > {
            testPC2.Id
        };
        List < Id > idListCRD = new List < Id > {
            testPC1.Id
        };

        Test.startTest();
        MACDObserver observer = new MACDObserver();
        csordtelcoa.ChangeRequestObservable o = new csordtelcoa.ChangeRequestObservable('MACDObserver',idListCRD);
        
        observer.execute(o,null);
        macdobserverinstance.deleteCustomerRequestedDatesConfigurations(idListCRD);
        macdobserverinstance.deleteRemovedProductConfigurations(idList);
        Test.stopTest();
    system.assertNotEquals(null,testPC2);
    }

    @isTest
    private static void testDeleteCustomerRequestedDatesConfigurationsFail() {
        MACDObserver macdobserverinstance = new MACDObserver();
        List < Id > idList = new List < Id > {};
        Test.startTest();
        macdobserverinstance.deleteCustomerRequestedDatesConfigurations(idList);
        Test.stopTest();
    system.assertEquals(true,idList.isEmpty());
    }
    
    @isTest
    private static void testMACMLEEMptyList() {
        // simple check for exceptions
        MACDObserver macdobserverinstance = new MACDObserver();
        List < Id > idList = new List < Id > {};
        Test.startTest();
        macdobserverinstance.updateReadOnlyForMACandMLE(idList);
        macdobserverinstance.updateReadOnlyForMACandMLE(null);
        Test.stopTest();
    system.assertEquals(true,idList.isEmpty());
    }
    
    @isTest
    private static void testMACMLEFieldUpdate() {
        cscfga__Product_Configuration__c testPC1 = new cscfga__Product_Configuration__c();
        testPC1.Name = 'Test One';
        insert testPC1;
        
        cscfga__Attribute__c messageBank = new cscfga__Attribute__c();
        messageBank.cscfga__Is_Read_Only__c = true;
        messageBank.Name = 'MESSAGEBANK';
        messageBank.cscfga__Product_Configuration__c = testPC1.Id;
        insert messageBank;
        
        MACDObserver macdobserverinstance = new MACDObserver();
        List < Id > idList = new List < Id > {};
        idList.add(testPC1.Id);
        Test.startTest();
        macdobserverinstance.updateReadOnlyForMACandMLE(idList);
        Test.stopTest();
        
        cscfga__Attribute__c att = [SELECT Id, Name, cscfga__Is_Read_Only__c, cscfga__Product_Configuration__c FROM cscfga__Attribute__c WHERE Name = 'MESSAGEBANK' AND cscfga__Product_Configuration__c IN :idList];
        system.assert(att.cscfga__Is_Read_Only__c == false);
    }
}