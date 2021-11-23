@IsTest
public class AddressCheckTest {

    @isTest
    static void getAddresses_WillReturnNull_WhenNoAddressId() {
        System.assert(AddressCheck.getAddresses('', null,'') == null);
    }

    /*@isTest
    static void getAddresses_WillReturnNoAddress_WhenNoMatchForAddressId() {
        String addresses = AddressCheck.getAddresses('','2desde2322ds2ws');
        List<Object> sites = (List<Object>) JSON.deserializeUntyped(addresses);
        System.assertEquals(0, sites.size());
    }*/

    @isTest
    static void getAddresses_WillReturnAddress_WhenMatchFoundForAddressId() {
        Test.startTest();
            Account acc = AccountTestFactory.buildAccount('Test Name');
            insert acc;
            cscrm__Address__c address = AccountTestFactory.buildAddress('AddressID-1');
            insert address;
          cscrm__Address__c address2 = AccountTestFactory.buildAddress('AddressID-2');
            insert address2;
            Contact pc = AccountTestFactory.buildContact(acc, 'testPC', 'testabc122@test.com');
            insert pc;
            Contact sc = AccountTestFactory.buildContact(acc, 'testSC', 'estabc13222@testdom.com');
            insert sc;
            //cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
            //insert basket;
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csordtelcoa__Synchronised_with_Opportunity__c = true;
            insert basket;
            cscfga__Product_Definition__c PD = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
            PD.csordtelcoa__Product_Type__c = 'Subscription';
            PD.cscfga__Active__c = true;
            insert PD;
        
            cscfga__Product_Configuration__c PCon = ProductTestFactory.buildProductConfig(PD.Id);
            PCon.cscfga__Product_Basket__c = basket.Id;
            PCon.Name = System.Label.Label_CWP;
            PCon.cscfga__Product_Definition__c = PD.Id;
            PCon.csordtelcoa__Hierarchy_Level__c = 0;
            PCon.csexpimp1__guid__c = 'cdksjf48ruwjfkweoifjwef';
            PCon.cscfga__Configuration_Status__c = 'Valid';
            PCon.cscfga__Key__c = '53294892fjwoidfdsif'; 
            insert PCon;
        
            csbb__Product_Configuration_Request__c pcr = ProductTestFactory.buildConfigRequest(basket.Id, PCon.Id);
            pcr.csbb__Product_Configuration__c =PCon.id;
            pcr.csbb__Optionals__c='{"selectedAddressDisplay":"150 Loansdale Street, VIC, Melbourne, 3000, Australia","hiddenParam1":"181026455"}';
            insert pcr;
          
          csord__Order_Request__c orderReq1 = ProductTestFactory.buildOrderRequest();
          insert orderReq1;
        
          csord__Order__c order = ProductTestFactory.buildOrder('Test order', acc.Id, 'New', orderReq1.Id);
          insert order;
        
          cscrm__Site__c site = AccountTestFactory.buildSite(address.id, acc.id);
            site.Primary_Contact__c = pc.id;
            site.Secondary_Contact__c = sc.id;
            insert site;
        
          cscrm__Site__c site2 = AccountTestFactory.buildSite(address2.id, acc.id);
            site2.Primary_Contact__c = pc.id;
            site2.Secondary_Contact__c = sc.id;
            insert site2;
        
          csord__Subscription__c subs = ProductTestFactory.buildSubscription(System.Label.Label_CWP, acc.Id, order.Id, orderReq1.Id);
          subs.Site__c = site2.Id;
          insert subs;
          
        
            
            
        Test.stopTest();
        String addresses = AddressCheck.getAddresses('add',acc.id,basket.id);
        List<Object> sites = (List<Object>) JSON.deserializeUntyped(addresses);
        System.assertEquals(1, sites.size());
    }

}