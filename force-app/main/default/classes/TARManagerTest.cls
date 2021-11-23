@isTest
public class TARManagerTest {
    
    @isTest static void testFetchStartDateForSite()
    {
        Test.startTest();
        cscfga__Product_Configuration__c rootConfig = new cscfga__Product_Configuration__c();
        rootConfig.name = 'Parent config';
        insert rootConfig;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('TestProduct','Test');
        prodDef.product_Specification__c ='PS_0022';
        insert prodDef;
        cscfga__Product_Configuration__c childConfig = new cscfga__Product_Configuration__c();
        childConfig.name = 'Child config';
        childConfig.cscfga__Root_Configuration__c = rootConfig.Id;
        childConfig.cscfga__Product_Definition__c = prodDef.id;
        insert childConfig;
        csedm__Specification__c spec1 = new csedm__Specification__c();
        spec1.csedm__Code__c = 'PS_0022';
        insert spec1;
        csedm__Specification__c spec2 = new csedm__Specification__c();
        spec2.csedm__Code__c = 'PS_0033';
        insert spec2;
        Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Specification__c = spec1.id;
        met1.Appointment_Required__c = true;
        met1.Installation_Lead_Time__c = 20;
        insert met1;
        Specification_Metadata__c met2 = new Specification_Metadata__c();
        met2.Type__c = 'Appointment';
        met2.Specification__c = spec2.id;
        met1.Appointment_Required__c = true;
        met1.Installation_Lead_Time__c = 22;
        insert met2;
        Double leadTime = new TARManager().fetchStartDateForSite(rootConfig.id);
        Test.stopTest();
        system.assertEquals(leadTime, 20);
    }
    
    @isTest static void testPopulateSlotSiteAddress()
    {
        Test.startTest();
        cscfga__Product_Configuration__c rootConfig = new cscfga__Product_Configuration__c();
        rootConfig.name = 'Parent config';
        insert rootConfig;
        cscfga__Attribute__c attr = ProductTestFactory.buildAttribute('AdborID','112233',rootConfig.Id);
        insert attr;
		AppointmentSlotRequestDTO.SlotSiteAddress slotSite = new TARManager().populateSlotSiteAddress(rootConfig.Id);        
        Test.stopTest();
        system.assertEquals(slotSite.id, '112233');
    }
    
    
    @isTest static void testPopulateSlotTasks()
    {
        Test.startTest();
        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.Name = 'Connected Workplace';
        insert offer;
		
		csedm__Specification__c spec1 = new csedm__Specification__c();
        spec1.csedm__Code__c = 'PS_0011';
        insert spec1;
		
		csedm__Specification__c spec2 = new csedm__Specification__c();
        spec2.csedm__Code__c = 'PS_0022';
        insert spec2;
		
		csedm__Specification__c spec3 = new csedm__Specification__c();
        spec2.csedm__Code__c = 'PS_0033';
        insert spec3;
		
		cscfga__Product_Definition__c prodDef1 = ProductTestFactory.buildProductDefinition('TestProduct1','Test');
        prodDef1.product_Specification__c ='PS_0011';
        insert prodDef1;
		
		cscfga__Product_Definition__c prodDef2 = ProductTestFactory.buildProductDefinition('TestProduct2','Test');
        prodDef2.product_Specification__c ='PS_0022';
        insert prodDef2;
		
		cscfga__Product_Definition__c prodDef3 = ProductTestFactory.buildProductDefinition('TestProduct2','Test');
        prodDef3.product_Specification__c ='PS_0033';
        insert prodDef3;
		
		cscfga__Product_Configuration__c rootConfig = new cscfga__Product_Configuration__c();
        rootConfig.name = 'Parent config';
		rootConfig.cscfga__Configuration_Offer__c = offer.id;
        insert rootConfig;
		
		cscfga__Product_Configuration__c childConfig1 = new cscfga__Product_Configuration__c();
        childConfig1.name = 'Child config';
        childConfig1.cscfga__Root_Configuration__c = rootConfig.Id;
		childConfig1.cscfga__Product_Definition__c = prodDef1.id;
		insert childConfig1;
		cscfga__Product_Configuration__c childConfig2 = new cscfga__Product_Configuration__c();
        childConfig2.name = 'Child config';
        childConfig2.cscfga__Root_Configuration__c = rootConfig.Id;
		childConfig2.cscfga__Product_Definition__c = prodDef2.id;
		insert childConfig2;
		cscfga__Product_Configuration__c childConfig3 = new cscfga__Product_Configuration__c();
        childConfig3.name = 'Child config';
        childConfig3.cscfga__Root_Configuration__c = rootConfig.Id;
		childConfig3.cscfga__Product_Definition__c = prodDef3.id;
		insert childConfig3;
		cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('SwitchModel','Meraki',childConfig1.Id);
        insert attr1;
		cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('Model','1177',childConfig2.Id);
        insert attr2;
		
		Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Specification__c = spec1.id;
        met1.Appointment_Required__c = true;
		met1.name = 'Managed Switch';
        met1.Product_TAR_Name__c = '';
        insert met1;
		
		Specification_Metadata__c met2 = new Specification_Metadata__c();
        met2.Type__c = 'Appointment';
        met2.Specification__c = spec2.id;
        met2.Appointment_Required__c = true;
        met2.name = 'Managed Router';
        met2.Product_TAR_Name__c = '';
        insert met2;
		
		Specification_Metadata__c met3 = new Specification_Metadata__c();
        met3.Type__c = 'Appointment';
        met3.Specification__c = spec3.id;
        met3.Appointment_Required__c = false;
        met3.Name='Telstra Fibre Access';
		met3.Product_TAR_Name__c ='FTTP';
        insert met3;
		
		TAR_Metadata__c tar1 = new TAR_Metadata__c();
		
		tar1.Type__c = 'Resource';
		tar1.Weight__c = 1;
		tar1.IsReference__c = true;
		tar1.Specification_Metadata__c = met1.id;
        tar1.Attribute_TAR_Value__c = 'Switch';
        tar1.Attribute_Name__c = 'SwitchModel';
        insert tar1;
		
		TAR_Metadata__c tar2 = new TAR_Metadata__c();
        TAR_Metadata__c tar3 = new TAR_Metadata__c();
		
		tar2.Type__c = 'Job Description';
		tar2.Weight__c = 1;
		tar2.IsReference__c = true;
		tar2.Specification_Metadata__c = met2.id;
        tar2.Attribute_TAR_Value__c = 'CISCO';
        tar2.Attribute_Name__c = 'Vendor';
        insert tar2;
        
        tar3.Type__c = 'Job Description';
		tar3.Weight__c = 2;
		tar3.IsReference__c = false;
		tar3.Specification_Metadata__c = met2.id;
        tar3.Attribute_TAR_Value__c = 'Router';
        tar3.Attribute_Name__c = 'Model';
        insert tar3;
        List<AppointmentSlotRequestDTO.SlotTask> slotTaskList = new TARManager().populateSlotTasks(rootConfig.Id);
        Test.stopTest();
        system.assertEquals(2, slotTaskList.size());
    }
    
    
    @isTest static void testPopulateContactForReserveAppointment()
    {
        Test.startTest();
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        insert basket;
        
        cscfga__Product_Configuration__c rootConfig = new cscfga__Product_Configuration__c();
        rootConfig.name = 'Parent config';
		rootConfig.cscfga__Product_Basket__c = basket.id;
        insert rootConfig;
        
        cscfga__Product_Configuration__c childConfig = new cscfga__Product_Configuration__c();
        childConfig.name = 'Site Details';
		childConfig.cscfga__Product_Basket__c = basket.id;
        insert childConfig;
        
        Contact cntct1 = new Contact();
        cntct1.LastName = 'Primary';
        cntct1.Phone = '111222';
        insert cntct1;
        Contact cntct2 = new Contact();
        cntct2.LastName = 'Secondary';
        cntct2.Phone = '22223333';
        insert cntct2;
        Contact cntct3 = new Contact();
        cntct3.LastName = 'Site';
        cntct3.Phone = '33334444';
        insert cntct3;
        
        cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('Primary Site Contact',cntct1.Id,childConfig.Id);
        insert attr1;
		cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('Technical contact',cntct2.Id,childConfig.Id);
        insert attr2;
        cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Site Delivery Contact',cntct3.Id,childConfig.Id);
        insert attr3;
		
        List<AppointmentReserveRequestDTO.Contacts> contactList = new TARManager().populateContactForReserveAppointment(rootConfig.Id);
        Test.stopTest();
        system.assertEquals(2, contactList.size());
    }
    
    @isTest static void testGetMaxLeadTime()
    {
        Test.startTest();
        Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Appointment_Required__c = true;
        met1.Installation_Lead_Time__c = 20;
        insert met1;
        Specification_Metadata__c met2 = new Specification_Metadata__c();
        met2.Type__c = 'Appointment';
        met2.Appointment_Required__c = true;
        met2.Installation_Lead_Time__c = 2;
        insert met2;
        Specification_Metadata__c met3 = new Specification_Metadata__c();
        met3.Type__c = 'Appointment';
        met3.Appointment_Required__c = false;
        met3.Installation_Lead_Time__c = 30;
        insert met3;
        List<String> specMetIDList = new List<String>();
        specMetIDList.add(met1.id);
        specMetIDList.add(met2.id);
        specMetIDList.add(met3.id);
        Double leadTime = new TARManager().getMaxLeadTime(specMetIDList);
        Test.stopTest();
        System.assertEquals(leadTime, 20);
    }
    
    @isTest 
    static void testGetAllRelatedProductSpecCodeList()
    {
        Test.startTest();
        cscfga__Product_Configuration__c rootConfig = new cscfga__Product_Configuration__c();
        rootConfig.name = 'Parent config';
        insert rootConfig;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('TestProduct','Test');
        prodDef.product_Specification__c ='PS_0022';
        insert prodDef;
        cscfga__Product_Configuration__c childConfig = new cscfga__Product_Configuration__c();
        childConfig.name = 'Child config';
        childConfig.cscfga__Root_Configuration__c = rootConfig.Id;
        childConfig.cscfga__Product_Definition__c = prodDef.id;
        insert childConfig;
        List<String> specList = new TARManager().getAllRelatedProductSpecCodeList(rootConfig.Id);
        String specCode = '';
        for(String str : specList){
            specCode = str;
        }
        Test.stopTest();
        system.assertEquals(specCode, 'PS_0022');
    }
    
    @isTest static void testGetProdConfigAttributeValue()
    {
        Test.startTest();	
        cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c();
        config.name = 'test config';
        insert config;
        cscfga__Attribute__c attr = ProductTestFactory.buildAttribute('testAttrName','testAttrValue',config.Id);
        insert attr;
        String returnValue = new TARManager().getProdConfigAttributeValue(config.Id,'testAttrName');
        Test.stopTest();
        System.assertEquals(returnValue, 'testAttrValue');
    }
 
    @isTest static void testCalculateTechnology()
    {
        Test.startTest();
        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.Name = 'Connected Workplace';
        insert offer;
        
        cscfga__Product_Configuration__c rootConfig = new cscfga__Product_Configuration__c();
        rootConfig.name = 'Parent config';
        rootConfig.cscfga__Configuration_Offer__c = offer.id;
        //rootConfig.cscfga__originating_offer__c = offer.id;
        insert rootConfig;
        Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Appointment_Required__c = true;
        met1.Product_TAR_Name__c ='FTTP';
        met1.Name='Telstra Fibre Access';
        insert met1;
        
        String technology1 = new TARManager().calculateTechnology(met1, rootConfig);
        String technology2 = new TARManager().calculateTechnology(met1, null);
        Test.stopTest();
        system.assertEquals(technology2, 'FTTP');
    }
    
    @isTest static void testCalculateResource()
    {
        Test.startTest();
        cscfga__Product_Configuration__c rootConfig = new cscfga__Product_Configuration__c();
        rootConfig.name = 'Parent config';
        insert rootConfig;
        cscfga__Attribute__c attr = ProductTestFactory.buildAttribute('SwitchModel','Meraki',rootConfig.Id);
        insert attr;
        Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Appointment_Required__c = true;
        met1.Installation_Lead_Time__c = 20;
        met1.name = 'Managed Switch';
        met1.Product_TAR_Name__c = '';
        insert met1;
        
        TAR_Metadata__c tar1 = new TAR_Metadata__c();
        TAR_Metadata__c tar2 = new TAR_Metadata__c();
		
		tar1.Type__c = 'Resource';
		tar1.Weight__c = 1;
		tar1.IsReference__c = true;
		tar1.Specification_Metadata__c = met1.id;
        tar1.Attribute_TAR_Value__c = 'Switch';
        tar1.Attribute_Name__c = 'SwitchModel';
        insert tar1;
        
        tar2.Type__c = 'Resource';
		tar2.Weight__c = 2;
		tar2.IsReference__c = false;
		tar2.Specification_Metadata__c = met1.id;
        tar2.Attribute_TAR_Value__c = 'Switch';
        tar2.Attribute_Name__c = 'SwitchModel';
        insert tar2;
        
        String resource = new TARManager().calculateResource(met1, rootConfig);
        String resource2 = new TARManager().calculateResource(null, rootConfig);
        Test.stopTest();
        System.assertEquals(resource, 'Switch Meraki');
    }
    
    @isTest static void testCalculateDescription()
    {
        Test.startTest();
        cscfga__Product_Configuration__c rootConfig = new cscfga__Product_Configuration__c();
        rootConfig.name = 'Parent config';
        insert rootConfig;
        cscfga__Attribute__c attr = ProductTestFactory.buildAttribute('Model','1177',rootConfig.Id);
        insert attr;
        Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Appointment_Required__c = true;
        met1.Installation_Lead_Time__c = 20;
        met1.name = 'Managed Router';
        met1.Product_TAR_Name__c = '';
        insert met1;
        
        TAR_Metadata__c tar1 = new TAR_Metadata__c();
        TAR_Metadata__c tar2 = new TAR_Metadata__c();
		
		tar1.Type__c = 'Job Description';
		tar1.Weight__c = 1;
		tar1.IsReference__c = true;
		tar1.Specification_Metadata__c = met1.id;
        tar1.Attribute_TAR_Value__c = 'CISCO';
        tar1.Attribute_Name__c = 'Vendor';
        insert tar1;
        
        tar2.Type__c = 'Job Description';
		tar2.Weight__c = 2;
		tar2.IsReference__c = false;
		tar2.Specification_Metadata__c = met1.id;
        tar2.Attribute_TAR_Value__c = 'Router';
        tar2.Attribute_Name__c = 'Model';
        insert tar2;
        
        String description = new TARManager().calculateDescription(met1, rootConfig);
        String description2 = new TARManager().calculateDescription(null, rootConfig);
        Test.stopTest();
        System.assertEquals(description, 'Install CISCO 1177');
        
    }
    
    @isTest static void testGetSpecificationMetadataRecords()
    {
        Test.startTest();
        List<String> specList = new List<String>();
        specList.add('PS_0011');
        specList.add('PS_0022');
        csedm__Specification__c spec1 = new csedm__Specification__c();
        spec1.csedm__Code__c = 'PS_0011';
        insert spec1;
        csedm__Specification__c spec2 = new csedm__Specification__c();
        spec2.csedm__Code__c = 'PS_0033';
        insert spec2;
        Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Specification__c = spec1.id;
        insert met1;
        Specification_Metadata__c met2 = new Specification_Metadata__c();
        met2.Type__c = 'Appointment';
        met2.Specification__c = spec2.id;
        insert met2;
        List<String> returnList = new TARManager().getSpecificationMetadataRecords(specList);
        Test.stopTest();
        System.assert(returnList.size()>0);
    }
    
    @isTest static void testPopulateSlotTasksForMAC()
    {
        Test.startTest();
        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.Name = 'Connected Workplace';
        insert offer;
		
		csedm__Specification__c spec1 = new csedm__Specification__c();
        spec1.csedm__Code__c = 'PS_0011';
        insert spec1;
		
		csedm__Specification__c spec2 = new csedm__Specification__c();
        spec2.csedm__Code__c = 'PS_0022';
        insert spec2;
		
		csedm__Specification__c spec3 = new csedm__Specification__c();
        spec2.csedm__Code__c = 'PS_0033';
        insert spec3;
		
		cscfga__Product_Definition__c prodDef1 = ProductTestFactory.buildProductDefinition('TestProduct1','Test');
        prodDef1.product_Specification__c ='PS_0011';
        insert prodDef1;
		
		cscfga__Product_Definition__c prodDef2 = ProductTestFactory.buildProductDefinition('TestProduct2','Test');
        prodDef2.product_Specification__c ='PS_0022';
        insert prodDef2;
		
		cscfga__Product_Definition__c prodDef3 = ProductTestFactory.buildProductDefinition('TestProduct2','Test');
        prodDef3.product_Specification__c ='PS_0033';
        insert prodDef3;
		
		cscfga__Product_Configuration__c rootConfig = new cscfga__Product_Configuration__c();
        rootConfig.name = 'Parent config';
		rootConfig.cscfga__Configuration_Offer__c = offer.id;
        insert rootConfig;
		
		cscfga__Product_Configuration__c childConfig1 = new cscfga__Product_Configuration__c();
        childConfig1.name = 'Child config';
        childConfig1.cscfga__Root_Configuration__c = rootConfig.Id;
		childConfig1.cscfga__Product_Definition__c = prodDef1.id;
		insert childConfig1;
		cscfga__Product_Configuration__c childConfig2 = new cscfga__Product_Configuration__c();
        childConfig2.name = 'Child config';
        childConfig2.cscfga__Root_Configuration__c = rootConfig.Id;
		childConfig2.cscfga__Product_Definition__c = prodDef2.id;
		insert childConfig2;
		cscfga__Product_Configuration__c childConfig3 = new cscfga__Product_Configuration__c();
        childConfig3.name = 'Child config';
        childConfig3.cscfga__Root_Configuration__c = rootConfig.Id;
		childConfig3.cscfga__Product_Definition__c = prodDef3.id;
		insert childConfig3;
		cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('SwitchModel','Meraki',childConfig1.Id);
        insert attr1;
		cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('Model','1177',childConfig2.Id);
        insert attr2;
        cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('IPSiteConfigurationChanged','true',rootConfig.Id);
        insert attr3;
        cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('MSConfigurationChanged','true',childConfig1.Id);
        insert attr4;
        cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('MSConfigurationChanged','true',childConfig2.Id);
        insert attr5;
		
		Specification_Metadata__c met1 = new Specification_Metadata__c();
        met1.Type__c = 'Appointment';
        met1.Specification__c = spec1.id;
        met1.Appointment_Required__c = true;
		met1.name = 'Managed Switch';
        met1.Product_TAR_Name__c = '';
        insert met1;
		
		Specification_Metadata__c met2 = new Specification_Metadata__c();
        met2.Type__c = 'Appointment';
        met2.Specification__c = spec2.id;
        met2.Appointment_Required__c = true;
        met2.name = 'Managed Router';
        met2.Product_TAR_Name__c = '';
        insert met2;
		
		Specification_Metadata__c met3 = new Specification_Metadata__c();
        met3.Type__c = 'Appointment';
        met3.Specification__c = spec3.id;
        met3.Appointment_Required__c = false;
        met3.Name='Telstra Fibre Access';
		met3.Product_TAR_Name__c ='FTTP';
        insert met3;
		
		TAR_Metadata__c tar1 = new TAR_Metadata__c();
		
		tar1.Type__c = 'Resource';
		tar1.Weight__c = 1;
		tar1.IsReference__c = true;
		tar1.Specification_Metadata__c = met1.id;
        tar1.Attribute_TAR_Value__c = 'Switch';
        tar1.Attribute_Name__c = 'SwitchModel';
        insert tar1;
		
		TAR_Metadata__c tar2 = new TAR_Metadata__c();
        TAR_Metadata__c tar3 = new TAR_Metadata__c();
		
		tar2.Type__c = 'Job Description';
		tar2.Weight__c = 1;
		tar2.IsReference__c = true;
		tar2.Specification_Metadata__c = met2.id;
        tar2.Attribute_TAR_Value__c = 'CISCO';
        tar2.Attribute_Name__c = 'Vendor';
        insert tar2;
        
        tar3.Type__c = 'Job Description';
		tar3.Weight__c = 2;
		tar3.IsReference__c = false;
		tar3.Specification_Metadata__c = met2.id;
        tar3.Attribute_TAR_Value__c = 'Router';
        tar3.Attribute_Name__c = 'Model';
        insert tar3;
        List<AppointmentSlotRequestDTO.SlotTask> slotTaskList = new TARManager().populateSlotTasks(rootConfig.Id);
        Test.stopTest();
        system.assertEquals(2, slotTaskList.size());
    }
    @isTest 
    static void testGetAllRelatedProductSpecCodeListForMac()
    {
        Test.startTest();
        cscfga__Product_Configuration__c rootConfig = new cscfga__Product_Configuration__c();
        rootConfig.name = 'Parent config';
        insert rootConfig;
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('TestProduct','Test');
        prodDef.product_Specification__c ='PS_0022';
        insert prodDef;
        cscfga__Product_Configuration__c childConfig = new cscfga__Product_Configuration__c();
        childConfig.name = 'Child config';
        childConfig.cscfga__Root_Configuration__c = rootConfig.Id;
        childConfig.cscfga__Product_Definition__c = prodDef.id;
        insert childConfig;
        cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('IPSiteConfigurationChanged','true',rootConfig.Id);
        insert attr1;
        cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('MSConfigurationChanged','true',childConfig.Id);
        insert attr2;
        List<String> specList = new TARManager().getAllRelatedProductSpecCodeList(rootConfig.Id);
        String specCode = '';
        for(String str : specList){
            specCode = str;
        }
        Test.stopTest();
        system.assertEquals(specCode, 'PS_0022');
    }
    
    
}