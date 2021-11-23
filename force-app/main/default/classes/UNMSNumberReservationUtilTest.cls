/*************************************************************************************************
Name : UNMSNumberReservationUtilTest
Description : Test class for UNMS Number Rservation for IOT & CWP - UNMSNumberReservationUtil
Author: Ila/Kiran
Story: DPG-1802 & DPG-1797
Revision : 
DPG-1803 20 May 2020 Kiran
***************************************************************************************************/

@isTest
public class UNMSNumberReservationUtilTest {
    @TestSetup static void dataSetup()
    {
        Test.startTest();
        Account acc=new Account();
        acc.Name='testacc';
        acc.CIDN__c='987654321';
        acc.ABN__c='1235';
        acc.Customer_Status__c='ACTIVE';
        insert acc;
        
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'IOT Subscription';                                              
        prodDef.csordtelcoa__Product_Type__c = 'Subscription';
        prodDef.cscfga__Label__c = 'IOT Subscription';
        prodDef.cscfga__Description__c = 'IOT Subscription';
        prodDef.cscfga__Is_Shared_Context_Definition__c = false;
        prodDef.cscfga__Name_Is_Read_Only__c = false;
        prodDef.cscfga__Active__c = true;
        prodDef.product_Specification__c = 'DMCAT_ProductSpecification_000965';
        prodDef.cscfga__Default_Frequency__c = 'Monthly';
        prodDef.cscfga__Default_Billing_Frequency__c = 'Monthly';
        prodDef.cscfga__Restrict_Access__c = false;
        prodDef.cscfga__IsArchived__c = false;
        prodDef.cscfga__Reprocess_Rules__c = false;
        insert prodDef;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        //basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;
        
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        config.cscfga__Description__c = 'test Description ';
        config.cscfga__Contract_Term__c = 36;
        config.cscfga__Configuration_Status__c = 'Valid';
        config.cscfga__Product_Definition__c = prodDef.Id;
        
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>{config};
            update configList;
        
        csord__Order_Request__c orderReq = new csord__Order_Request__c();
        orderReq.name = 'OR-12121';
        orderReq.csord__Module_Name__c = 'TestReq';
        orderReq.csord__Module_Version__c = '12';
        insert orderReq;
        
        csord__Order__c  pord = new csord__Order__c();
        pord.name = 'TestOrder';
        pord.csord__Account__c = acc.id;
        pord.csord__Status2__c = 'Created';
        pord.csord__Order_Request__c = orderReq.Id;
        pord.csord__Identification__c = 'IDE1322';
        pord.stage__c = 'Being Fulfilled';  
        pord.IOTMSISDNRequired__c= true; 
        pord.RecordType= [SELECT id  FROM RecordType WHERE DeveloperName = 'MSISDN_Reserved'];      
        insert pord;
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Smiths');
        insert contact;
        
        cscrm__Address__c address = new cscrm__Address__c();
        address.Name='Unit 1 1234 Lostmy Way';
        address.Address_Line_1__c='Unit 4 Mahatma';
        address.Locality__c='Sydney';
        address.cscrm__Zip_Postal_Code__c='2000';
        address.cscrm__State_Province__c='NSW';
        address.cscrm__Country__c='Australia';
        address.cscrm__Street_Name__c ='Melbourne';
        
        insert address;
        
        cscrm__Site__c  site = AccountTestFactory.buildSite(address.Id, acc.Id);
        site.Primary_Contact__c = contact.Id;
        site.cscrm__Installation_Address__r = address;
        insert site;  
        
        csord__Subscription__c subs = new csord__Subscription__c();
        subs.name = 'TestOrder';
        subs.csord__Account__c = acc.id;
        subs.csord__Order__c = pord.id;
        subs.Site__c = site.Id;
        subs.csord__Identification__c = 'IDE1322';
        subs.csord__Order_Request__c = orderReq.id;
        insert subs;
        
        List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
        subList.add(subs);
        update subList;
        
        csord__Service__c ser = new csord__Service__c();
        ser.name = 'TestOrder';
        ser.csord__Order__c = pord.id;
        ser.csord__Subscription__c = subs.id;
        ser.csord__Identification__c =  'IDE1322';
        ser.csord__Order_Request__c = orderReq.id;
        ser.Model__c = 'TestOrder';
        ser.csordtelcoa__Product_Configuration__c = config.id;
        ser.TechnologyType__c = 'Mobile Access';
        insert ser;
        
        
        
        Test.stopTest();
    }
    
    @isTest
    public static void createFallbackTaskTest()
    {
        Test.startTest();
        csord__Order__c pord = [select id,csord__Order_Number__c,CreatedById from csord__Order__c where name = 'TestOrder' limit 1];
        Map<Id,csord__Order__c> failedOrderMap = new  Map<Id,csord__Order__c>();
        failedOrderMap.put(pord.id,pord );
        UNMSNumberReservationUtil.createFallbackTask(failedOrderMap);
        Task tsk  = [select id,OwnerId from task where Subject = :Label.DPGTasksubject limit 1 ];
        system.assertNotEquals(null, tsk);
        system.assertEquals(pord.CreatedById, tsk.OwnerId);
        Test.stopTest();

    }
}