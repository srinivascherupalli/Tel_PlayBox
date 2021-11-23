//Last Updated on 9-01-2020 , for P2OB - 4275 implemented validation rule : Primary_Distributor_is_must_for_Nominate
@Istest(SeeAllData=false)
public class PartnerBulkLoadUtilTest {
    @Istest
    public static void readFiletest()
    {
        
        Account accdis2 = new Account(Name = 'Test Accountdit2',Partner_Type__c='Distributor',customer_status__c = 'ACTIVE');
        insert accdis2;
        System.assertEquals(accdis2.Name, 'Test Accountdit2');
//Field Primary_Distributor__c Added for P2OB - 4275 implemented validation rule : Primary_Distributor_is_must_for_Nominate
   Id PartnerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();    
Account testAcc2 = new Account(Name='testAcc', Telstra_Online_Service_Agreement__c = True,Partner_Type__c = 'Nominate',recordtypeid=PartnerRecTypeId,Primary_Distributor__c=accdis2.id );
insert testAcc2;

Contact con1 = new Contact();
        con1.AccountId = testAcc2.Id;
        con1.LastName = 'TestLastName';
        con1.Email = 'test@test345345345345.com';
        con1.OTP_Mobile_Phone_Number__c = '+911234567891'; 
        con1.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); 
        con1.Onboarding_Status__c='Active';
        
        insert con1;   
       
        testAcc2.IsPartner=TRUE;
        testAcc2.Partner_Code__c='MBE00';
        testAcc2.Account_Status__c='Active';
        testAcc2.Customer_Trading_Name__c = 'Test';
        testAcc2.ABN__c='aaaa';
        testAcc2.ACN__c='ccc';
        testAcc2.PartnerPrincipalContact__c=con1.id;
        testAcc2.State_Coverage__c = 'SA';
        testAcc2.Partner_Type__c='Partner';
        testAcc2.Website='www.vsygwoci.com';
        testAcc2.Phone='0412354323';
        testAcc2.Overall_Accreditation__c='Platinum';
        testAcc2.Mobility_Accreditation__c='Platinum';
        testAcc2.Cloud_Accreditation__c='Platinum';
        testAcc2.Data_Security_Accreditation__c='Platinum';
        testAcc2.Collaboration_Accreditation__c='Platinum';
        update testAcc2;
        
         Account acc = AccountTestFactory.buildAccount('Test Account') ;
         acc.Customer_Status__c='Active';
		
        insert acc;
         test.starttest();
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        insert opp;
        
        Map<String,String> mapProductToPartner= new map<String,String>();
        mapProductToPartner.put('1TF6DR','XYZ');
        mapProductToPartner.put('1TF6DX','ssssss'); 
        
        //opp.Opportunity_Number__c = 'A-00041598';
        //update opp;
        System.assertNotEquals(null,opp);
        
       
        //Create two Baskets and one basket synced
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        basketList.add(basket);
        
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.Name = 'basket2';
        basket1.csbb__Synchronised_With_Opportunity__c =true;
        basket1.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket1.Primary_Basket__c = true;
        basketList.add(basket1);
        
        insert basketList;
        
        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
 
        //CREATE PRODUCT
        Product2 prod = ProductTestFactory.getProduct();
        prod.Name = 'Recurring';
        insert prod;

        //CREATE PRICEBOOKENTRY
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;
        insert pbe;
        
        //Create Product definition
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c();
        userPD.Name = PRMConstants.BULK_TAGGING_CS_PRODUCTDEFINITION_NAME;
        userPD.cscfga__Description__c = 'User';
        insert userPD;
        
        

        //Create config
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>();

        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basketList[1].id;
        config1.cscfga__Product_Definition__c = userPD.id;
        config1.cscfga__Description__c = 'test Description 1';
        config1.cscfga__Contract_Term__c = 24;
        configList.add(config1);
        
        cscfga__Product_Configuration__c config2 = ProductTestService.createProductConfiguration();
        config2.cscfga__Product_Basket__c = basketList[1].id;
        config2.cscfga__Product_Definition__c = userPD.id;
        config2.cscfga__Description__c = 'test Description 2';
        config2.cscfga__Contract_Term__c = 12;
        configList.add(config2);
        
        upsert configList;

        //Creation of Attributes with different attrbiutes Name and values.
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        for(cscfga__Product_Configuration__c config:configList){
            cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('SRM', '100.00', config.id);
            attList.add(attr0);
            system.debug(attList);
            cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('PartnerName', '200.00', config.id);
            attList.add(attr1);
            
            cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('OC', '400.00', config.id);
            attList.add(attr2);
            
            cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Product', '400.00', config.id);
            attr3.cscfga__Is_Line_Item__c = true;
            attList.add(attr3);
            cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('Partner', null, config.id);
            attList.add(attr4);
            cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('DealerCode', null, config.id);
            attList.add(attr5);
            cscfga__Attribute__c attr6 = ProductTestFactory.buildAttribute('ProductCode', 'TCMP040', config.id);
            attList.add(attr6);
            cscfga__Attribute__c attr7 = ProductTestFactory.buildAttribute('Channel', 'Direct', config.id);
            attList.add(attr7);
            }
            
			
            insert attList;
            
            List<cscfga__Attribute__c> newattrList = new List<cscfga__Attribute__c>();
            for(cscfga__Attribute__c attr : attList){
                if(attr.Name == 'Product'){
                    newattrList.add(attr);
                }
            }
            
        //create opportunity Line Item
        
        List<OpportunityLineItem> oLIList = new List<OpportunityLineItem>();
        OpportunityLineItem oli1  = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Won', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = basketList[1].cscfga__Opportunity__c, Description = configList[0].cscfga__Description__c, cscfga__Attribute__c = newattrList[0].Id);
        oli1.Product_Code__c = 'TCMP040';
        oLIList.add(oli1);
        OpportunityLineItem oli2 = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Won', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = basketList[1].cscfga__Opportunity__c, Description = configList[0].cscfga__Description__c, cscfga__Attribute__c = newattrList[0].Id);
        oLIList.add(oli2);
        OpportunityLineItem oli3 = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Won', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = basketList[1].cscfga__Opportunity__c, Description = configList[0].cscfga__Description__c, cscfga__Attribute__c = newattrList[0].Id);
        oLIList.add(oli3);

        insert oLIList;


        
                       
            string str=PartnerBulkLoadUtil.init();                       
            PartnerBulkLoadUtil.Response wrap= new PartnerBulkLoadUtil.Response(); 
            wrap=(PartnerBulkLoadUtil.Response)JSON.deserialize(str, PartnerBulkLoadUtil.Response.class);
            List<Opportunity>sNew = new List<Opportunity>();
            sNew = [select Id, Name, Opportunity_Number__c from Opportunity where id = : opp.id];
            system.debug('opp.Opportunity_Number__c'+sNew[0].Opportunity_Number__c);
            string source='Opportunity ID,Product Code,Updated Partner Code,Submitted By\r\n'+sNew[0].Opportunity_Number__c +',TCMP040,MBE00,Boyd Taylor\r';
            system.debug('source'+source);
            string source1='Opportunity ID,Product Code,Updated Partner Code,Submitted By\r\n'+',TCMP040,MBE00,Boyd Taylor\r';
            string source2='Opportunity ID,Product Code,Updated Partner Code,Submitted By\r\n'+sNew[0].Opportunity_Number__c +',,MBE00,Boyd Taylor\r';
            string source3='Opportunity ID,Product Code,Updated Partner Code,Submitted By\r\n'+sNew[0].Opportunity_Number__c+',TCMP040,Boyd Taylor\r';
            //String opportunityId='A-00041598';
            //Map<String,String> mapProductToPartner= new map<String,String>();
            //mapProductToPartner.put('1TF6DR','XYZ'); 
            //mapProductToPartner.put('1TF6DX','ssssss'); 
            //string batchid='Test'; 
            PartnerBulkLoadUtil.readFile(source);
            PartnerBulkLoadUtil.readFile(source1);
            PartnerBulkLoadUtil.readFile(source2);
            PartnerBulkLoadUtil.readFile(source3);     
            test.stoptest();
            
            list<Bulk_Load_Staging__c> statusrec=[select id,status__c,Bulk_Load_Staging__c from Bulk_Load_Staging__c where Bulk_Load_Staging__c!=null];
            
            system.debug('reccount'+statusrec.size());

            system.assert(statusrec.size()==4);
    }
    
     @Istest
      public static void cleanUpMethodTest()
    {    
        Bulk_Load_Staging__c parentRecord = new Bulk_Load_Staging__c();
        parentRecord.Name='Parent Record';   
       
        insert parentRecord;
        
        Datetime timePeriod = Datetime.now().addDays(-400);
            
        Bulk_Load_Staging__c childRecord = new Bulk_Load_Staging__c();
        childRecord.Name='child record';
        childRecord.Bulk_Load_Staging__c=parentRecord.Id;  
       
        insert childRecord;
        Test.setCreatedDate(childRecord.Id, timePeriod);
        update childRecord;
        system.debug('saran5'+childRecord.CreatedDate);
        
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        
        acc.Customer_Status__c='Active';
        acc.Partner_Code__c='A87654';
        update acc;
        
        //CREATE OPPORTUNITY
        Opportunity opp   = new Opportunity();
        opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        
        
        insert opp;
        opp = [select Id,name,Opportunity_Number__c from opportunity where Id = :opp.Id];
        System.assertNotEquals(null,opp);
              
        Map<String,String> mapProductToPartner= new map<String,String>();
        mapProductToPartner.put('XYZ','A12345');
        mapProductToPartner.put('ABC','A87654'); 
        string batchid='Test';
        system.debug(opp);
        system.debug(opp.Opportunity_Number__c);
        
        //Create two Baskets and one basket synced
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        basketList.add(basket);
        
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.Name = 'basket2';
        basket1.csbb__Synchronised_With_Opportunity__c =true;
        basket1.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket1.Primary_Basket__c = true;
        basketList.add(basket1);
        
        insert basketList;
         
        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
 
        //CREATE PRODUCT
        Product2 prod = ProductTestFactory.getProduct();
        prod.Name = 'Recurring';
        insert prod;
		
        //CREATE PRICEBOOKENTRY
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;
        insert pbe;
        
        //Create Product definition
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c();
        userPD.Name = PRMConstants.BULK_TAGGING_CS_PRODUCTDEFINITION_NAME;
        userPD.cscfga__Description__c = 'User';
        insert userPD;

        //Create config
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>();

        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basketList[1].id;
        config1.cscfga__Product_Definition__c=userPD.Id;
        config1.cscfga__Description__c = 'test Description 1';
        config1.cscfga__Contract_Term__c = 24;
        configList.add(config1);
        
        cscfga__Product_Configuration__c config2 = ProductTestService.createProductConfiguration();
        config2.cscfga__Product_Basket__c = basketList[1].id;        
        config1.cscfga__Product_Definition__c=userPD.Id;
        config2.cscfga__Description__c = 'test Description 2';
        config2.cscfga__Contract_Term__c = 12;
        configList.add(config2);
        
        upsert configList;

        //Creation of Attributes with different attrbiutes Name and values.
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        for(cscfga__Product_Configuration__c config:configList){
            cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('Partner', '100.00', config.id);
            attList.add(attr0);
            system.debug(attList);
            cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('ProductCode', 'ABC', config.id);
            attList.add(attr1);
            
            cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('PartnerName', '400.00', config.id);
            attList.add(attr2);
            
            cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Product', '400.00', config.id);
            attList.add(attr3);
            cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('DealerCode', null, config.id);
            attList.add(attr5);
            cscfga__Attribute__c attr6 = ProductTestFactory.buildAttribute('ProductCode', null, config.id);
            attList.add(attr6);
            cscfga__Attribute__c attr7 = ProductTestFactory.buildAttribute('Channel', 'Direct', config.id);
            attList.add(attr7);
            }
			test.startTest();
            insert attList;
            
            List<cscfga__Attribute__c> newattrList = new List<cscfga__Attribute__c>();
            for(cscfga__Attribute__c attr : attList){
                if(attr.Name == 'Product'){
                    newattrList.add(attr);
                    }
               }
            
        //create opportunity Line Item
        
        List<OpportunityLineItem> oLIList = new List<OpportunityLineItem>();
        OpportunityLineItem oli1  = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Won', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = basketList[1].cscfga__Opportunity__c, Description = configList[0].cscfga__Description__c, cscfga__Attribute__c = newattrList[0].Id);
        oLIList.add(oli1);
        OpportunityLineItem oli2 = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Won', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = basketList[1].cscfga__Opportunity__c, Description = configList[0].cscfga__Description__c, cscfga__Attribute__c = newattrList[0].Id);
        oLIList.add(oli2);
        OpportunityLineItem oli3 = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Won', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = basketList[1].cscfga__Opportunity__c, Description = configList[0].cscfga__Description__c, cscfga__Attribute__c = newattrList[0].Id);
        oLIList.add(oli3);
		test.stopTest();
        insert oLIList;

        parentRecord.ExternalId__c=batchId+''+opp.Opportunity_Number__c+'ABC'; 
        update parentRecord;
        
        
        
        PartnerBulkLoadUtil.cleanUp();
        PartnerBulkLoadUtil.getFieldValue(opp, 'name');
        PartnerBulkLoadUtil.updatePartnerTags(opp.Opportunity_Number__c, mapProductToPartner,batchid);
        PartnerBulkLoadUtil.checkjobStatus();
        
        
    }
    
     @Istest
    public static void partnerSharingTest()
    {
        Account accdis2 = new Account(Name = 'Test Accountdit2',Partner_Type__c='Distributor',customer_status__c = 'ACTIVE');
        insert accdis2;
        System.assertEquals(accdis2.Name, 'Test Accountdit2');

//Field Primary_Distributor__c Added for P2OB - 4275 implemented validation rule : Primary_Distributor_is_must_for_Nominate
       
   Id PartnerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();    
Account testAcc2 = new Account(Name='testAcc', Telstra_Online_Service_Agreement__c = True,Partner_Type__c = 'Nominate',recordtypeid=PartnerRecTypeId,Primary_Distributor__c=accdis2.id );
insert testAcc2;
List<Contact> contacts = new List<Contact>();
Contact con1 = new Contact();
        con1.AccountId = testAcc2.Id;
        con1.LastName = 'TestLastName';
        con1.Email = 'test@test345345345345.com';
        con1.OTP_Mobile_Phone_Number__c = '+911234567891'; 
        con1.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); 
        con1.Onboarding_Status__c='Active';
        contacts.add(con1);

        Contact con2 = new Contact();
        con2.AccountId = testAcc2.Id;
        con2.LastName = 'TestLastName1';
        con2.Email = 'test@121.com';
        con2.OTP_Mobile_Phone_Number__c = '+911234567891'; 
        con2.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); 
        con2.Onboarding_Status__c='Active';  
        contacts.add(con2);
        insert contacts;   
        
        testAcc2.IsPartner=TRUE;
        testAcc2.Partner_Code__c='MBE00';
        testAcc2.Account_Status__c='Active';
        testAcc2.Customer_Trading_Name__c = 'Test';
        testAcc2.ABN__c='aaaa';
        testAcc2.ACN__c='ccc';
        testAcc2.PartnerPrincipalContact__c=con1.id;
        testAcc2.State_Coverage__c = 'SA';
        testAcc2.Partner_Type__c='Partner';
        testAcc2.Website='www.vsygwoci.com';
        testAcc2.Phone='0412354323';
        testAcc2.Overall_Accreditation__c='Platinum';
        testAcc2.Mobility_Accreditation__c='Platinum';
        testAcc2.Cloud_Accreditation__c='Platinum';
        testAcc2.Data_Security_Accreditation__c='Platinum';
        testAcc2.Collaboration_Accreditation__c='Platinum';
        update testAcc2;
        List<User> partnerUsers;
        //Team Hawaii
        System.runAs(new User(Id = UserInfo.getUserId())){
            Set<Id> ConIds = new Set<Id>();
            for(Contact con : contacts){
                ConIds.add(con.Id);
            }
            partnerUsers = createPartnerUser(ConIds);
        }
         Account acc = AccountTestFactory.buildAccount('Test Account') ;
         acc.Customer_Status__c='Active';

        insert acc;
        test.starttest();
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
        insert opp;
        OpportunityShare opptyShare = new OpportunityShare(opportunityId = opp.Id, UserOrGroupId = partnerUsers.get(1).id, 
        RowCause = 'Manual' ,OpportunityAccessLevel = 'Read');
        insert opptyShare;
        Map<String,String> mapProductToPartner= new map<String,String>();
        mapProductToPartner.put('1TF6DR','XYZ');
        mapProductToPartner.put('1TF6DX','ssssss'); 
        
        //opp.Opportunity_Number__c = 'A-00041598';
        //update opp;
        System.assertNotEquals(null,opp);
        
       
        //Create two Baskets and one basket synced
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        basketList.add(basket);
        
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.Name = 'basket2';
        basket1.csbb__Synchronised_With_Opportunity__c =true;
        basket1.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket1.Primary_Basket__c = true;
        basketList.add(basket1);
        
        insert basketList;
        
        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
 
        //CREATE PRODUCT
        Product2 prod = ProductTestFactory.getProduct();
        prod.Name = 'Recurring';
        insert prod;

        //CREATE PRICEBOOKENTRY
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;
        insert pbe;
        
        //Create Product definition
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c();
        userPD.Name = PRMConstants.BULK_TAGGING_CS_PRODUCTDEFINITION_NAME;
        userPD.cscfga__Description__c = 'User';
        insert userPD;
        
        

        //Create config
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>();

        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basketList[1].id;
        config1.cscfga__Product_Definition__c = userPD.id;
        config1.cscfga__Description__c = 'test Description 1';
        config1.cscfga__Contract_Term__c = 24;
        configList.add(config1);
        
        cscfga__Product_Configuration__c config2 = ProductTestService.createProductConfiguration();
        config2.cscfga__Product_Basket__c = basketList[1].id;
        config2.cscfga__Product_Definition__c = userPD.id;
        config2.cscfga__Description__c = 'test Description 2';
        config2.cscfga__Contract_Term__c = 12;
        configList.add(config2);
        
        upsert configList;

        //Creation of Attributes with different attrbiutes Name and values.
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        for(cscfga__Product_Configuration__c config:configList){
            cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('SRM', '100.00', config.id);
            attList.add(attr0);
            system.debug(attList);
            cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('PartnerName', '200.00', config.id);
            attList.add(attr1);
            
            cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('OC', '400.00', config.id);
            attList.add(attr2);
            
            cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Product', '400.00', config.id);
            attr3.cscfga__Is_Line_Item__c = true;
            attList.add(attr3);
            cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('Partner', null, config.id);
            attList.add(attr4);
            cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('DealerCode', null, config.id);
            attList.add(attr5);
            cscfga__Attribute__c attr6 = ProductTestFactory.buildAttribute('ProductCode', 'TCMP040', config.id);
            attList.add(attr6);
            cscfga__Attribute__c attr7 = ProductTestFactory.buildAttribute('Channel', 'Direct', config.id);
            attList.add(attr7);
            }
            

            insert attList;
            
            List<cscfga__Attribute__c> newattrList = new List<cscfga__Attribute__c>();
            for(cscfga__Attribute__c attr : attList){
                if(attr.Name == 'Product'){
                    newattrList.add(attr);
                }
            }
            
        //create opportunity Line Item
        
        List<OpportunityLineItem> oLIList = new List<OpportunityLineItem>();
        OpportunityLineItem oli1  = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Won', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = basketList[1].cscfga__Opportunity__c, Description = configList[0].cscfga__Description__c, cscfga__Attribute__c = newattrList[0].Id);
        oli1.Product_Code__c = 'TCMP040';
        oLIList.add(oli1);
        insert oLIList;
		test.stoptest();

        
                       
            string str=PartnerBulkLoadUtil.init();                       
            PartnerBulkLoadUtil.Response wrap= new PartnerBulkLoadUtil.Response(); 
            wrap=(PartnerBulkLoadUtil.Response)JSON.deserialize(str, PartnerBulkLoadUtil.Response.class);
            List<Opportunity>sNew = new List<Opportunity>();
            sNew = [select Id, Name, Opportunity_Number__c from Opportunity where id = : opp.id];
            system.debug('opp.Opportunity_Number__c'+sNew[0].Opportunity_Number__c);
            string source='Opportunity ID,Product Code,Updated Partner Code,Submitted By\r\n'+sNew[0].Opportunity_Number__c +',TCMP040,MBE00,Boyd Taylor\r';
            system.debug('source'+source);
            PartnerBulkLoadUtil.readFile(source);
         
            
            list<Bulk_Load_Staging__c> statusrec=[select id,status__c,Bulk_Load_Staging__c from Bulk_Load_Staging__c where Bulk_Load_Staging__c!=null];
       
    }
    
    
    private static List<User> createPartnerUser(Set<Id> conIds){
        Id p = [select id from profile where name=:System.label.PRM_Community_User].id;
        // Id p = [select id from profile where name=:System.label.PRM_Community_User /*'Partner Community User'].id;
        List<User> partnerUsers = new List<User>();
        Integer i = 1;
        for(Id conId : conIds){
        User u1 = new User(alias = 'prmAp', email='prmApp456'+i+'@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                           ContactId = conId,
                           timezonesidkey='America/Los_Angeles', username='prmApp456'+i+'@noemail.com');
        partnerUsers.add(u1);  
        i++;
       }
       insert partnerUsers;
       return partnerUsers;   
        
    }
}