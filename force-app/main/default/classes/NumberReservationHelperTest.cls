/*************************************************************************************************
Name     : NumberReservationController
Description :Controller class for Modified Number Reservation 
Author    :Kalashree Borgaonkar
Story    : EDGE-140792
Revision : EDGE-149261
***************************************************************************************************/
@isTest
public class NumberReservationHelperTest {
    @testSetup 
    public static void setupdata(){ 
        setupdataForMobile();
    }
    public static void setupdataForMobile(){ 
        
        List<user> userList = new List<user>();
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile where Name in ('System Administrator','PRM Community User - Australia','Migration BOH user')]){
            profilesMap.put(profile.Name, profile);
        }
        
        User migrationUser = new User(alias = 'migBoh', email='migrationBOHUser@test.com',
                                      emailencodingkey='UTF-8', lastname='BOHUser', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid =profilesMap.get('Migration BOH user').id, country='United States',IsActive =true,                
                                      timezonesidkey='America/Los_Angeles', username='migrationBOHUser02@test.com');
        userList.add(migrationUser);
        insert userList;
        
        id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        Account customerAccount=TestUtil.createAccount('Test_Account');
        customerAccount.OwnerId=migrationUser.id;
        insert customerAccount;
         cscfga__Product_Basket__c migrationOppBasket = new cscfga__Product_Basket__c();
         system.runAs(migrationUser){
            
            Opportunity migrationOpp = new Opportunity();
            migrationOpp.AccountId = customerAccount.Id;
            migrationOpp.recordTypeId=oppRecordTypeId;
            migrationOpp.Name = 'Migration Opportunity';
            migrationOpp.Product_Domain__c = 'Other';
            migrationOpp.StageName = 'Develop';
            migrationOpp.Product_Type__c = 'Modular';
            migrationOpp.CloseDate = System.Date.today();
            migrationOpp.Description__c = 'test';
            migrationOpp.Type = 'Migration';
            insert  migrationOpp;
            
           
            migrationOppBasket.csbb__Account__c = customerAccount.Id;
            migrationOppBasket.Name = 'Migration Opportunity Basket';
            migrationOppBasket.cscfga__Opportunity__c = migrationOpp.Id;
            migrationOppBasket.Express_Flow__c = false;
            migrationOppBasket.Primary_Basket__c = True;
            migrationOppBasket.csbb__Synchronised_With_Opportunity__c = True;
            migrationOppBasket.csordtelcoa__Synchronised_with_Opportunity__c  = True;
            migrationOppBasket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
            insert migrationOppBasket;
        }
        
             cscfga__Product_Configuration__c productConfig = ProductTestService.createProductConfiguration();
             productConfig.cscfga__Product_Basket__c = migrationOppBasket.id;
             productConfig.cscfga__Description__c = 'test Description ';
             productConfig.cscfga__Contract_Term__c = 36;
             productConfig.cscfga__Configuration_Status__c = 'Valid';
             productConfig.name = 'Adaptive Mobility';
             update productConfig;
        
        List<cscfga__Attribute__c> lstAttr= new List<cscfga__Attribute__c>();
        cspmb__Price_Item__c commProd= new cspmb__Price_Item__c(Colour__C='Red', Model__C='Apple');
        insert commProd;
        cscfga__Product_Configuration__c prodConfig = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='MobilityPlanSelected';
        attr1.cscfga__Value__c='';
        attr1.cscfga__Product_Configuration__c=prodConfig.id;
        lstAttr.add(attr1);
        cscfga__Attribute__c attr2= new cscfga__Attribute__c();
        attr2.name ='ModelString';
        attr2.cscfga__Value__c=prodConfig.id;
        attr2.cscfga__Product_Configuration__c=prodConfig.id;
        lstAttr.add(attr2);
        cscfga__Attribute__c attr3= new cscfga__Attribute__c();
        attr3.name ='ColourString';
        attr3.cscfga__Value__c='';
        attr3.cscfga__Product_Configuration__c=prodConfig.id;
        lstAttr.add(attr3);
        
        
        cscfga__Product_Configuration__c prodConfig2 = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr= new cscfga__Attribute__c();
        attr.name ='Mobile Device';
        attr.cscfga__Value__c=prodConfig.id;
        attr.cscfga__Product_Configuration__c=prodConfig2.id;
        lstAttr.add(attr);
        cscfga__Attribute__c attr1Mob= new cscfga__Attribute__c();
        attr1Mob.name ='MobileHandsetModel';
        attr1Mob.cscfga__Value__c=commProd.id;
        attr1Mob.cscfga__Product_Configuration__c=prodConfig2.id;
        lstAttr.add(attr1Mob);
        cscfga__Attribute__c attr2Mob= new cscfga__Attribute__c();
        attr2Mob.name ='MobileHandsetColour';
        attr2Mob.cscfga__Value__c=commProd.id;
        attr2Mob.cscfga__Product_Configuration__c=prodConfig2.id;
        lstAttr.add(attr2Mob);
        //EDGE-149261 - Added SelectedPlanName attribute
        cscfga__Attribute__c attr3Mob= new cscfga__Attribute__c();
        attr3Mob.name ='SelectPlanName';
        attr3Mob.cscfga__Value__c='Essential';
        attr3Mob.cscfga__is_active__c = true;
        attr3Mob.cscfga__Product_Configuration__c=prodConfig2.id;
        lstAttr.add(attr3Mob);
        
        cscfga__Attribute__c attr3Mob1= new cscfga__Attribute__c();
        attr3Mob1.name ='PlanTypeString';
        attr3Mob1.cscfga__Value__c='Handheld';
        attr3Mob1.cscfga__is_active__c = true;
        attr3Mob1.cscfga__Product_Configuration__c=prodConfig2.id;
        lstAttr.add(attr3Mob1);
        
        cscfga__Attribute__c attr4Mob= new cscfga__Attribute__c();
        attr4Mob.name ='isPortOutReversal';
        attr4Mob.cscfga__Value__c='Yes';
        attr4Mob.cscfga__is_active__c = true;
        attr4Mob.cscfga__Product_Configuration__c=prodConfig2.id;
        lstAttr.add(attr4Mob);
        
        cscfga__Attribute__c attr5Mob= new cscfga__Attribute__c();
        attr5Mob.name ='PlanTypeString';
        attr5Mob.cscfga__Value__c='Handheld';
        attr5Mob.cscfga__is_active__c = true;
        attr5Mob.cscfga__Product_Configuration__c=productConfig.id;
        lstAttr.add(attr5Mob);
        
        cscfga__Attribute__c attr6Mob= new cscfga__Attribute__c();
        attr6Mob.name ='SelectPlanName';
        attr6Mob.cscfga__Value__c='Essential';
        attr6Mob.cscfga__is_active__c = true;
        attr6Mob.cscfga__Product_Configuration__c=productConfig.id;
        lstAttr.add(attr6Mob);
        
        insert lstAttr;
        system.debug(prodConfig2);
        cscfga__Product_Definition__c pd=TestDataFactory.generateProductDefinition();
        pd.Name='Mobility';
        pd.product_Specification__c='DMCAT_ProductSpecification_000420';
        update pd;
        System.debug('pd: '+pd);
        prodConfig2.name='CWP Mobile Seat';
        prodConfig2.cscfga__Product_Definition__c=pd.id;
        // prodConfig2.cscfga__Parent_Configuration__c=prodConfig.id;
        update prodConfig2;
        System.debug('prodConfig2: '+prodConfig2+' spec'+prodConfig2.cscfga__Product_Definition__r.product_Specification__c);
        cscfga__Product_Configuration__c testconfig = [SELECT cscfga__Product_Definition__r.product_Specification__c FROM cscfga__Product_Configuration__c where id=:prodConfig2.id];
        System.debug('testconfig: '+testconfig.cscfga__Product_Definition__r.product_Specification__c);
        String cmpbasketId= prodConfig2.cscfga__Product_Basket__c;
        List<Number__c> lstNum= new List<Number__c>();
        Number__c num= new Number__c(Service_Number__c='61459834542',Type__c='Transition', Mobile__c='Mobile', Basket__c=prodConfig2.cscfga__Product_Basket__c,Plan_Type__c='Postpaid Handheld');
        lstNum.add(num);
        Number__c num1= new Number__c(Service_Number__c='61459812342',Type__c='Port In',Basket__c=prodConfig2.cscfga__Product_Basket__c,Product_Configuration__c= prodConfig2.id);
        lstNum.add(num1);
        //EDGE-149261 - Setting test Data.
        Number__c num2= new Number__c(Service_Number__c='61459812345',Type__c='Transition',Basket__c=prodConfig2.cscfga__Product_Basket__c,Product_Configuration__c= prodConfig2.id, sim_serial_number__c= '89610179078138000029');
        lstNum.add(num2);
        Number__c num3= new Number__c(Service_Number__c='61459834532',Type__c='New', Mobile__c='Mobile', Basket__c=prodConfig.cscfga__Product_Basket__c,Product_Configuration__c=prodConfig.id);
        lstNum.add(num3);
        
        Number__c migrationNumber= new Number__c(Service_Number__c='61459834555',Type__c='Transition', Mobile__c='Mobile', Basket__c=migrationOppBasket.Id,Plan_Name__c='Adaptive Mobile Essential');
        lstNum.add(migrationNumber);
        
         Number__c migrationNumber2= new Number__c(Service_Number__c='6145983444',Type__c='Transition', Mobile__c='Mobile', Basket__c=migrationOppBasket.Id,Plan_Name__c='Adaptive Mobile Enhanced');
        lstNum.add(migrationNumber2);
        insert lstNum;
        List<Number__c> lst = [SELECT Service_Number__c FROM Number__c];
        System.debug(' lst '+lst);
        List<cscfga__Product_Configuration__c> configListtemp = [SELECT id,cscfga__Product_Basket__c,cscfga__Product_Definition__r.name FROM cscfga__Product_Configuration__c ];
        for(cscfga__Product_Configuration__c con:configListtemp ){
            System.debug('con.'+con.cscfga__Product_Definition__r.name);
        }
        
    }
    
    @isTest
    public static void createPayloadContiguousNoPatternTest(){
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Contiguous';
        numReserve.selectedPatternType='None';
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Fixed');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
    @isTest
    public static void createPayloadNonContiguousMobileTest(){
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Non-Contiguous';
        numReserve.selectedPatternType='None';
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Mobile');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
    @isTest
    public static void createPayloadContiguousStartswithPatternTest(){
        cscrm__Address__c address = TestUtil.createAddress();
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Contiguous';
        numReserve.selectedPatternType='Starts With';
        numReserve.reqPattern=123;
        numReserve.selectedAreaCode = '123';
        numReserve.deliveryAddress = address;
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Fixed');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
    @isTest
    public static void createPayloadNonContiguousStartwithPatternTest(){       
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Non-Contiguous';
        numReserve.selectedPatternType='Starts With';
        numReserve.reqPattern=123;
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Fixed');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
    @isTest
    public static void createPayloadContiguousContainsPatternTest(){
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Contiguous';
        numReserve.selectedPatternType='Contains';
        numReserve.reqPattern=123;
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Fixed');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
    @isTest
    public static void createPayloadNonContiguousContainsPatternTest(){
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Non-Contiguous';
        numReserve.selectedPatternType='Contains';
        numReserve.reqPattern=123;
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Fixed');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
    @isTest
    public static void createPayloadNonContiguousEndwithPatternTest(){
        NumberReservationController.NumberReserve numReserve = new NumberReservationController.NumberReserve();
        numReserve.quantity=1;
        numReserve.selectedSearchType='Non-Contiguous';
        numReserve.selectedPatternType='Ends With';
        numReserve.reqPattern=123;
        Test.startTest();
        FNNSearchRequestDTO dto = NumberReservationHelper.createSearchPayload(numReserve,'Fixed');
        System.assertEquals(dto!=null,true,'Fixed payload contiguous - no pattern');
        Test.stopTest();
    }
    /******************************************************************
EDGE-126317
Method:getPatternType 
Author:Kalashree Borgaonkar
******************************************************************/ 
    @isTest
    public static void getPatternTypeTest(){
        Test.startTest();
        List<SelectOptionz> selectOptions = NumberReservationHelper.getPatternType('Contiguous');
        Test.stopTest();
        System.assertEquals(selectOptions!=null,true,'Options retrieved');
    }
    
    @isTest
    public static void assignMSISDNNumbersTest(){
        Test.startTest();
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c,cscfga__Parent_Configuration__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility' LIMIT 1];
        List<String> pcList = new List<String>();
        for(cscfga__Product_Configuration__c pc : configList){
            pcList.add(pc.id);
        }
        List<Number__c> numbList = [SELECT service_number__c FROM Number__c WHERE service_number__c = '61459834542'];
        List<String> numberList = new List<String> ();
        numberList.add(numbList[0].service_number__c);
        Object result = NumberReservationHelper.assignMSISDNNumbers(pcList,numberList,configList[0].cscfga__Product_Basket__c,'SIM Card','Existing Active SIM','Transition');
        Test.stopTest();
        System.assertEquals(result!=null,true,'Options retrieved');
    }
     @isTest
    public static void assignSIMTest(){
        Test.startTest();
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c,cscfga__Parent_Configuration__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility' LIMIT 1];
        String pcWrapper = '[{"assignedNumber":"61459834542","basketName":"BT000-200-757","configId":"'+configList[0].id+'","Id":"'+configList[0].id+'","isDisabled":true,"isngEMPresent":true,"isSelected":true,"planName":"Handheld-Essential","productConfig":"Handheld-Essential","solution":"Handheld-Essential"}]';
        String result = NumberReservationHelper.assignSIM(pcWrapper,configList[0].cscfga__Product_Basket__c,'SIM Card','Existing Active SIM');
        Test.stopTest();
        System.assertEquals(result!=null,true,'Options retrieved');
    }
    @isTest
    public static void assignSIMnewSIMTest(){
        Test.startTest();
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c,cscfga__Parent_Configuration__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility' LIMIT 1];
        String pcWrapper = '[{"assignedNumber":"61459834542","basketName":"BT000-200-757","configId":"'+configList[0].id+'","Id":"'+configList[0].id+'","isDisabled":true,"isngEMPresent":true,"isSelected":true,"planName":"Handheld-Essential","productConfig":"Handheld-Essential","solution":"Handheld-Essential"}]';
        String result = NumberReservationHelper.assignSIM(pcWrapper,configList[0].cscfga__Product_Basket__c,'SIM Card','New SIM');
        Test.stopTest();
        System.assertEquals(result!=null,true,'Options retrieved');
    }
     @isTest
    public static void assignSIMExceptionTest(){
        Test.startTest();
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c,cscfga__Parent_Configuration__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility' LIMIT 1];
        String pcWrapper = '[{"assignedNumber":"61459834542","basketName":"BT000-200-757","configId":"'+configList[0].id+'","Id":"'+configList[0].id+'","isDisabled":true,"isngEMPresent":true,"isSelected":true,"planName":"Handheld-Essential","productConfig":"Handheld-Essential","solution":"Handheld-Essential"}';
        String result = NumberReservationHelper.assignSIM(pcWrapper,configList[0].cscfga__Product_Basket__c,'SIM Card','New SIM');
        Test.stopTest();
        System.assertEquals(result!=null,true,'Options retrieved');
    }
     @isTest
    public static void assignSIMUpdateTest(){
        Test.startTest();
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c,cscfga__Parent_Configuration__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility' LIMIT 1];
        List<Number__c> numList = [SELECT id FROM Number__c WHERE service_number__c='61459834542'];
        String pcWrapper = '[{"assignedNumber":"61459834542","basketName":"BT000-200-757","configId":"'+configList[0].id+'","Id":"'+configList[0].id+'","isDisabled":true,"isngEMPresent":true,"isSelected":true,"planName":"Handheld-Essential","productConfig":"Handheld-Essential","solution":"Handheld-Essential","numberId":"'+numList[0].id+'"}]';
        String result = NumberReservationHelper.assignSIM(pcWrapper,configList[0].cscfga__Product_Basket__c,'SIM Card','New SIM');
        Test.stopTest();
        System.assertEquals(result!=null,true,'Options retrieved');
    }
    @isTest
    public static void autoReserveMSISDNTest(){
        cscfga__Product_Configuration__c Config = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
        String result = NumberReservationHelper.autoReserveMSISDN(Config.cscfga__Product_Basket__c,1);
        Test.stopTest();
        system.assertEquals(result!=null,true,'Auto reserve');
    }
    @IsTest public static void reserveNumbersMobileSuccessTest(){ 
        cscfga__Product_Configuration__c Config = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        List<String> numberList = new List<String>{'61352326786','61352326186'};
            String reserveString = JSON.serialize(numberList);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('search_nonCon'));
        String result = NumberReservationHelper.reserveNumbers(reserveString,'Mobile',Config.cscfga__Product_Basket__c);
        Test.stopTest();
        system.assertEquals(result!=null,true,'Reserve Success');
    }
    @IsTest public static void reserveNumbersMobileFailureTest(){ 
        cscfga__Product_Configuration__c Config = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE  cscfga__Product_Definition__r.name = 'Mobility'];
        List<String> numberList = new List<String>{'61352326786','61352326186'};
            String reserveString = JSON.serialize(numberList);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('errorResponse'));
        String result = NumberReservationHelper.reserveNumbers(reserveString,'Mobile',Config.cscfga__Product_Basket__c);
        Test.stopTest();
        system.assertEquals(result!=null,true,'Reserve Success');
    }
    
    @IsTest public static void unreserveMobileNumbersTest(){ 
        List<String> numberList = new List<String>{'61459834542'};
            cscfga__Product_Configuration__c Config = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('success_fixed'));
        NumberReservationFixedHandler.ResponseWrapper responseWrapper = NumberReservationHelper.unreserveMobileNumbers(numberList,Config.cscfga__Product_Basket__c);
        Test.stopTest();
        system.assertEquals(responseWrapper!=null,true,'UnReserve success');
    }
    @IsTest public static void unreserveMobilePortinNumbersTest(){ 
        List<String> numberList = new List<String>{'61459812342'};
            cscfga__Product_Configuration__c Config = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.startTest();
        NumberReservationFixedHandler.ResponseWrapper responseWrapper = NumberReservationHelper.unreserveMobileNumbers(numberList,Config.cscfga__Product_Basket__c);
        Test.stopTest();
        system.assertEquals(responseWrapper!=null,true,'UnReserve success');
    }
    
    
    @IsTest public static void removeAssignedNumbersTest(){  
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        List<String> pcList = new List<String>();
        for(cscfga__Product_Configuration__c pc : configList){
            pcList.add(pc.id);
        }
        Test.startTest();
        String result = NumberReservationHelper.removeAssignedNumbers(pcList,configList[0].cscfga__Product_Basket__c,'Mobile');
        Test.stopTest();
        system.assertEquals(result!=null,true,'Unassigned Mobile numbers');
    }
    @IsTest public static void getAllreserveNumbersTest(){ 
        cscfga__Product_Configuration__c Config = [SELECT cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Test.startTest();
        List<NumberReservationHelper.EachRecord> eachRecordList= NumberReservationHelper.getAllreserveNumbers(Config.cscfga__Product_Basket__c,'New');
        Test.stopTest();
        system.assertEquals(eachRecordList!=null, true,'table created');
        
    }
    @isTest
    public static void getPCReactivateServiceTest(){
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Config.subtype__c= Label.Reactivate_subScenario;
        update Config;
        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='CustomerFacingServiceId';
        attr1.cscfga__Value__c='';
        attr1.cscfga__Product_Configuration__c=Config.id;
        insert attr1;
        List<Number__c> deleteNumberList = [SELECT id from Number__C WHERE product_configuration__c = :Config.id];
        if(!deleteNumberList.isEmpty()){
            delete deleteNumberList;
        }
        System.debug('Config: '+Config.cscfga__Product_Definition__r.product_Specification__c);
        Test.startTest();
        List<NumberReservationHelper.ProdConfigWrapper> mobileDetailsWrapper = NumberReservationHelper.getProdConfig(Config.cscfga__Product_Basket__c,'reactiveServices');
        System.assertEquals(mobileDetailsWrapper!=null,true,'Mobile details fetched');
        Test.stopTest();
    }
    @isTest
    public static void getPCReactivateNumberAssignedTest(){
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Config.subtype__c= Label.Reactivate_subScenario;
        update Config;
        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='CustomerFacingServiceId';
        attr1.cscfga__Value__c='';
        attr1.cscfga__Product_Configuration__c=Config.id;
        insert attr1;
        List<Number__c> deleteNumberList = [SELECT id from Number__C WHERE product_configuration__c = :Config.id];
        if(!deleteNumberList.isEmpty()){
            delete deleteNumberList;
        }
        Number__c num1= new Number__c(Service_Number__c='61459812345',Type__c='Reactivate',Basket__c=Config.cscfga__Product_Basket__c,Product_Configuration__c= Config.id);
        insert num1;
        System.debug('Config: '+Config.cscfga__Product_Definition__r.product_Specification__c);
        Test.startTest();
        List<NumberReservationHelper.ProdConfigWrapper> mobileDetailsWrapper = NumberReservationHelper.getProdConfig(Config.cscfga__Product_Basket__c,'reactiveServices');
        System.assertEquals(mobileDetailsWrapper!=null,true,'Mobile details fetched');
        Test.stopTest();
    }
    @isTest
    public static void finishReservationMobileTest(){
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        System.debug('Config: '+Config.cscfga__Product_Definition__r.product_Specification__c);
        Test.startTest();
        NumberReservationHelper.ValidationWrapper validationWrapper = NumberReservationHelper.finishReservationMobile(Config.cscfga__Product_Basket__c);
        System.assertEquals(validationWrapper!=null,true,'Mobile details fetched');
        Test.stopTest();
    }
    @isTest
    public static void getProdConfigMobileSubTest(){
        List<cscfga__Attribute__c> lstAttr= new List<cscfga__Attribute__c>();
        cspmb__Price_Item__c commProd= new cspmb__Price_Item__c(Colour__C='Red', Model__C='Apple');
        insert commProd;
        cscfga__Product_Configuration__c testProductConfiguration1 = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='MobileHandsetModel';
        attr1.cscfga__Value__c=commProd.id;
        attr1.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr1);
        cscfga__Attribute__c attr2= new cscfga__Attribute__c();
        attr2.name ='MobileHandsetColour';
        attr2.cscfga__Value__c=commProd.id;
        attr2.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr2);
        cscfga__Attribute__c attr3= new cscfga__Attribute__c();
        attr3.name ='ColourString';
        attr3.cscfga__Value__c='';
        attr3.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr3);
        insert lstAttr;
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr= new cscfga__Attribute__c();
        attr.name ='Device';
        attr.cscfga__Value__c=testProductConfiguration1.id;
        attr.cscfga__Product_Configuration__c=testProductConfiguration.id;
        insert attr;
        system.debug(testProductConfiguration);
        cscfga__Product_Definition__c pd=TestDataFactory.generateProductDefinition();
        pd.Name='Mobile Subscription';
        pd.product_Specification__c='DMCAT_ProductSpecification_000420';
        update pd;
        testProductConfiguration.Type__c='Modify';
        testProductConfiguration.name='PPHH Standalone';
        update testProductConfiguration;
        String      PCId=testProductConfiguration.id;
        List<Number__c> lstNum= new List<Number__c>();
        String basketId= testProductConfiguration.cscfga__Product_Basket__c;
        Number__c num= new Number__c(Service_Number__c='62384723',Type__c='New', Mobile__c='Mobile', Basket__c=basketId,Product_Configuration__c= PCId);
        lstNum.add(num);
        Number__c num2= new Number__c(Service_Number__c='62384723',Type__c='FNN', Mobile__c='Mobile', Basket__c=basketId,Product_Configuration__c= PCId,Start_Range__c='62384722',End_Range__c='62384724');
        lstNum.add(num2);
        Number__c num1= new Number__c(Service_Number__c='62384721',Type__c='Port In',Basket__c=basketId,Product_Configuration__c= PCId);
        lstNum.add(num1);
        insert lstNum;
        Test.startTest();
        List<NumberReservationHelper.ProdConfigWrapper> mobileDetailsWrapper = NumberReservationHelper.getProdConfig(testProductConfiguration.cscfga__Product_Basket__c,'Mobile');
        System.assertEquals(mobileDetailsWrapper!=null,true,'Mobile details fetched');
        Test.stopTest();
    }
       @isTest
    public static void getProdConfigNoNumbersAssignedTest(){
        List<cscfga__Attribute__c> lstAttr= new List<cscfga__Attribute__c>();
        cspmb__Price_Item__c commProd= new cspmb__Price_Item__c(Colour__C='Red', Model__C='Apple');
        insert commProd;
        cscfga__Product_Configuration__c testProductConfiguration1 = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr1= new cscfga__Attribute__c();
        attr1.name ='MobileHandsetModel';
        attr1.cscfga__Value__c=commProd.id;
        attr1.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr1);
        cscfga__Attribute__c attr2= new cscfga__Attribute__c();
        attr2.name ='MobileHandsetColour';
        attr2.cscfga__Value__c=commProd.id;
        attr2.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr2);
        cscfga__Attribute__c attr3= new cscfga__Attribute__c();
        attr3.name ='ColourString';
        attr3.cscfga__Value__c='';
        attr3.cscfga__Product_Configuration__c=testProductConfiguration1.id;
        lstAttr.add(attr3);
        insert lstAttr;
        cscfga__Product_Configuration__c testProductConfiguration = TestDataFactory.generateProductConfiguration();
        cscfga__Attribute__c attr= new cscfga__Attribute__c();
        attr.name ='Device';
        attr.cscfga__Value__c=testProductConfiguration1.id;
        attr.cscfga__Product_Configuration__c=testProductConfiguration.id;
        insert attr;
        system.debug(testProductConfiguration);
        cscfga__Product_Definition__c pd=TestDataFactory.generateProductDefinition();
        pd.Name='Mobile Subscription';
        pd.product_Specification__c='DMCAT_ProductSpecification_000420';
        update pd;
        testProductConfiguration.Type__c='Modify';
        testProductConfiguration.name='PPHH Standalone';
        update testProductConfiguration;
        String      PCId=testProductConfiguration.id;
        List<Number__c> lstNum= new List<Number__c>();
        String basketId= testProductConfiguration.cscfga__Product_Basket__c;
        Test.startTest();
        List<NumberReservationHelper.ProdConfigWrapper> mobileDetailsWrapper = NumberReservationHelper.getProdConfig(testProductConfiguration.cscfga__Product_Basket__c,'Mobile');
        System.assertEquals(mobileDetailsWrapper!=null,true,'Mobile details fetched');
        Test.stopTest();
    }
    //EDGE-149261 - Test Coverage 
    @isTest
    public static void assignMSISDNNumbersTest2(){
        Test.startTest();
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility' LIMIT 1];
        List<String> pcList = new List<String>();
        for(cscfga__Product_Configuration__c pc : configList){
            pcList.add(pc.id);
        }
        List<Number__c> numbList = [SELECT service_number__c, Type__c, sim_serial_number__c FROM Number__c WHERE service_number__c = '61459812345'];
        List<String> numberList = new List<String> ();
        numberList.add(numbList[0].service_number__c);
        Object result = NumberReservationHelper.assignMSISDNNumbers(pcList,numberList,configList[0].cscfga__Product_Basket__c,'SIM Card','Existing Active SIM','Others');
        List<Number__c> numbList1 = [SELECT service_number__c, Type__c, sim_serial_number__c FROM Number__c WHERE service_number__c = '61459812345'];
        Test.stopTest();
        System.assertNotEquals(null, numbList1[0].sim_serial_number__c);
    }
   /* @isTest
    public static void getPortOutReversalRadioTest(){
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        System.debug('Config: '+Config.cscfga__Product_Definition__r.product_Specification__c);
        Test.startTest();
        Boolean isPortOutReversalTrue = NumberReservationHelper.getPortOutReversalRadio(Config.cscfga__Product_Basket__c);
        System.assertEquals(isPortOutReversalTrue,true,'Show Portout Reversal button');
        Test.stopTest();
    }*/
    @isTest
    public static void getRadioOptionsTest(){
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Config.subtype__c = Label.Reactivate_subScenario;
        update Config;
        System.debug('Config: '+Config.cscfga__Product_Definition__r.product_Specification__c);
        Test.startTest();
        NumberReservationHelper.RadioOptionsWrapper radioOptions = NumberReservationHelper.getRadioOptions(Config.cscfga__Product_Basket__c);
        System.assertEquals(radioOptions.showPortOutReversal,true,'Show Portout Reversal button');
        Test.stopTest();
    }
    @isTest
    public static void checkValidSIMNegativeTest(){
        List<cscfga__Product_Configuration__c> Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c,
                                                         (SELECT isSimvalid__c, Sim_Serial_Number__c,SimAvailabilityType__c,Service_Id__c,Service_Number__c FROM numbers__r) 
                                                         FROM cscfga__Product_Configuration__c 
                                                         WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        
        List<Number__C> numberList = new List<Number__C>();
        numberList.addAll(Config[0].numbers__r);
        for(Number__C num : numberList){
            num.SimAvailabilityType__c= 'Existing Blank SIM';
            num.Sim_Serial_Number__c = '8912345678912';
        }
        Test.startTest();
        NumberReservationHelper.ValidationWrapper validationWrapper = NumberReservationHelper.checkValidSIM(numberList);
        System.assertEquals(validationWrapper.isValid==false,true,'SIM invalid');
        Test.stopTest();
    }
    @isTest
    public static void checkValidSIMpositiveTest(){
        List<cscfga__Product_Configuration__c> Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c,
                                                         (SELECT isSimvalid__c, Sim_Serial_Number__c,SimAvailabilityType__c,Service_Id__c,Service_Number__c FROM numbers__r) 
                                                         FROM cscfga__Product_Configuration__c 
                                                         WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        
        List<Number__C> numberList = new List<Number__C>();
        numberList.addAll(Config[0].numbers__r);
        for(Number__C num : numberList){
            num.SimAvailabilityType__c= 'Existing Blank SIM';
            num.Sim_Serial_Number__c = '8912345678912';
            num.isSimvalid__c =true;
        }
        Test.startTest();
        NumberReservationHelper.ValidationWrapper validationWrapper = NumberReservationHelper.checkValidSIM(numberList);
        System.assertEquals(validationWrapper.isValid==true,true,'SIM valid');
        Test.stopTest();
    }
    @isTest
    public static void validatSimSerialCalloutWarningTest(){
        List<cscfga__Product_Configuration__c> Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c ,
                                                         (SELECT isSimvalid__c, Sim_Serial_Number__c,SimAvailabilityType__c,Service_Id__c,Service_Number__c FROM numbers__r) 
                                                         FROM cscfga__Product_Configuration__c 
                                                         WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        
        NumberReservationHelper.SimSerialDetails simDetail = new NumberReservationHelper.SimSerialDetails('8912345678912','SIM card');
        NumberReservationHelper.SimSerialDetails simDetail1 = new NumberReservationHelper.SimSerialDetails('89610182000501374392','SIM card');
        List<NumberReservationHelper.SimSerialDetails> simDetailList = new List<NumberReservationHelper.SimSerialDetails>();
        simDetailList.add(simDetail);
        simDetailList.add(simDetail1);
        String prodConfig  = '[{"assignedNumber":"61459834542","basketName":"BT000-199-877","color":"BLACK","config.Id":"'+Config[0].id+'","Id":"'+Config[0].id+'","isDisabled":true,"isngEMPresent":false,"isSelected":true,"model":"APPLE IPHONE 11 128GB 4GX","newExistingSim":"Existing Blank SIM","planName":"Committed Data-Professional","productConfig":"Committed Data-Professional","simSerialNumber":"89610182000501374392","simType":"SIM card"}]';
        List<Number__C> numberList = new List<Number__C>();
        numberList.addAll(Config[0].numbers__r);
        for(Number__C num : numberList){
            num.SimAvailabilityType__c= 'Existing Blank SIM';
            num.Sim_Serial_Number__c = '89610182000501374392';
            num.isSimvalid__c =true;
        }
        update numberList;
         Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(200,'Partial Success',null));
        Test.startTest();
        List<NumberReservationHelper.prodConfigWrapper> prodConfigList = NumberReservationHelper.validatSimSerialCallout(simDetailList,prodConfig,Config[0].cscfga__Product_Basket__c);         
        Test.stopTest();
        System.assertEquals(prodConfigList.size()>0,true,'Validate sim');
        
    }
    @isTest
    public static void validatSimSerialCalloutTest(){
        List<cscfga__Product_Configuration__c> Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c ,
                                                         (SELECT isSimvalid__c, Sim_Serial_Number__c,SimAvailabilityType__c,Service_Id__c,Service_Number__c FROM numbers__r) 
                                                         FROM cscfga__Product_Configuration__c 
                                                         WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        
        NumberReservationHelper.SimSerialDetails simDetail = new NumberReservationHelper.SimSerialDetails('89610182000501374304','SIM card');
        NumberReservationHelper.SimSerialDetails simDetail1 = new NumberReservationHelper.SimSerialDetails('89610182000501374402','SIM card');
        List<NumberReservationHelper.SimSerialDetails> simDetailList = new List<NumberReservationHelper.SimSerialDetails>();
        simDetailList.add(simDetail);
        simDetailList.add(simDetail1);
        String prodConfig  = '[{"assignedNumber":"61459834542","basketName":"BT000-199-877","color":"BLACK","config.Id":"'+Config[0].id+'","Id":"'+Config[0].id+'","isDisabled":true,"isngEMPresent":false,"isSelected":true,"model":"APPLE IPHONE 11 128GB 4GX","newExistingSim":"Existing Blank SIM","planName":"Committed Data-Professional","productConfig":"Committed Data-Professional","simSerialNumber":"89610182000501374304","simType":"SIM card"}]';
        List<Number__C> numberList = new List<Number__C>();
        numberList.addAll(Config[0].numbers__r);
        for(Number__C num : numberList){
            num.SimAvailabilityType__c= 'Existing Blank SIM';
            num.Sim_Serial_Number__c = '89610182000501374304';
            num.isSimvalid__c =true;
        }
        update numberList;
         Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(200,'Success',null));
        Test.startTest();
        List<NumberReservationHelper.prodConfigWrapper> prodConfigList = NumberReservationHelper.validatSimSerialCallout(simDetailList,prodConfig,Config[0].cscfga__Product_Basket__c);         
        Test.stopTest();
        System.assertEquals(prodConfigList.size()>0,true,'Validate sim');
        
    }
    @isTest
    public static void saveSimValidationDetailsTest(){
        List<cscfga__Product_Configuration__c> Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c ,
                                                         (SELECT isSimvalid__c, Sim_Serial_Number__c,SimAvailabilityType__c,Service_Id__c,Service_Number__c FROM numbers__r) 
                                                         FROM cscfga__Product_Configuration__c 
                                                         WHERE cscfga__Product_Definition__r.name = 'Mobility']; 
        List<Number__C> numberList = new List<Number__C>();
        numberList.addAll(Config[0].numbers__r);
        for(Number__C num : numberList){ 
            num.SimAvailabilityType__c= 'Existing Blank SIM';
            num.Sim_Serial_Number__c = '8200050137412';
        }
        update numberList;
        Map<String,String> simToStatusMap = new  Map<String,String>();
        simToStatusMap.put('8200050137412', 'AVAILABLE');
        simToStatusMap.put('8200050137442', 'SIM serial is not valid');
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(200,'Partial Success',null));
        Test.startTest();
        String result = NumberReservationHelper.saveSimValidationDetails(simToStatusMap,Config[0].cscfga__Product_Basket__c);
        Test.stopTest();
        System.assertEquals(result=='Success',true,'Validate sim response saved');
    }
    @isTest
    public static void finishReservationMobileNegativeTest(){
        List<cscfga__Product_Configuration__c> Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c ,
                                                         (SELECT isSimvalid__c, Sim_Serial_Number__c,SimAvailabilityType__c,Service_Id__c,Service_Number__c FROM numbers__r) 
                                                         FROM cscfga__Product_Configuration__c 
                                                         WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        
        List<Number__C> numberList = new List<Number__C>();
        numberList.addAll(Config[0].numbers__r);
        for(Number__C num : numberList){ 
            num.SimAvailabilityType__c= 'Existing Blank SIM';
            num.Sim_Serial_Number__c = '8200050137412';
        }
        update numberList;
        Test.startTest();
        NumberReservationHelper.ValidationWrapper validationWrapper = NumberReservationHelper.finishReservationMobile(Config[0].cscfga__Product_Basket__c);
        System.assertEquals(validationWrapper.isValid==false,true,'Mobile details fetched');
        Test.stopTest();
    }
    @isTest
    public static void finishReservationNoAssignmentTest(){
        List<cscfga__Product_Configuration__c> Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c ,
                                                         (SELECT isSimvalid__c, Sim_Serial_Number__c,SimAvailabilityType__c,Service_Id__c,Service_Number__c FROM numbers__r) 
                                                         FROM cscfga__Product_Configuration__c 
                                                         WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        
        List<Number__C> numberList = new List<Number__C>();
        numberList.addAll(Config[0].numbers__r);
        delete numberList;
        Test.startTest();
        NumberReservationHelper.ValidationWrapper validationWrapper = NumberReservationHelper.finishReservationMobile(Config[0].cscfga__Product_Basket__c);
        System.assertEquals(validationWrapper.isValid==false,true,'Mobile details fetched');
        Test.stopTest();
    }
    @isTest
    public static void finishReservationPortinTest(){
        List<cscfga__Product_Configuration__c> Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c ,
                                                         (SELECT isSimvalid__c, Sim_Serial_Number__c,SimAvailabilityType__c,Service_Id__c,Service_Number__c FROM numbers__r) 
                                                         FROM cscfga__Product_Configuration__c 
                                                         WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        
        List<Number__C> numberList = new List<Number__C>();
        numberList.addAll(Config[0].numbers__r);
        for(Number__C num : numberList){
            num.Type__c='Port In';
            num.Product_Configuration__c=null;
        }
        update numberList;
        Test.startTest();
        NumberReservationHelper.ValidationWrapper validationWrapper = NumberReservationHelper.finishReservationMobile(Config[0].cscfga__Product_Basket__c);
        System.assertEquals(validationWrapper.isValid==false,true,'Mobile details fetched');
        Test.stopTest();
    }
    //EDGE-179277: Test  Method for mapNumTypeToPCSubtype
    /*@isTest
    public static void mapNumTypeToPCSubtypeTest(){
        
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c,cscfga__Parent_Configuration__c,subType__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility' LIMIT 1];
        cscfga__Product_Configuration__c prodConfig3 = TestDataFactory.generateProductConfiguration();
        prodConfig3.name='NETGEAR NIGHTHAWK M1 DEFAULT';
        prodConfig3.cscfga__Parent_Configuration__c=configList[0].id;
        update prodConfig3;
        Test.startTest();
        List<Number__c> numbList = [SELECT service_number__c ,Type__c,Product_Configuration__c FROM Number__c WHERE service_number__c IN('61459834542','61459834532')];
        Map<id,string> mapNumTypeToPC=new Map<id,string>();
        for(Number__c num : numbList){
            mapNumTypeToPC.put(num.Product_Configuration__c,num.Type__c);
        }
        NumberReservationHelper.mapNumTypeToPCSubtype(mapNumTypeToPC);
        Test.stopTest();
        cscfga__Product_Configuration__c childPc = [SELECT id,cscfga__Product_Basket__c,cscfga__Parent_Configuration__c,subType__c FROM cscfga__Product_Configuration__c WHERE id=:prodConfig3.id];
        
        System.assertEquals(childPc.subType__c=='New',true,'Populated PC subtype');
    }*/
     @isTest
    public static void checkReactivateServicesPresentTest(){
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility'];
        Config.subtype__c = Label.Reactivate_subScenario;
        update Config;
        System.debug('Config: '+Config.cscfga__Product_Definition__r.product_Specification__c);
        Test.startTest();
        Boolean isReactivateServicePresent = NumberReservationHelper.checkReactivateServices(Config.cscfga__Product_Basket__c);
        System.assertEquals(isReactivateServicePresent,true,'Reactivate service present');
        Test.stopTest();
    }
     @isTest
    public static void checkReactivateServicesAbsentTest(){ 
        cscfga__Product_Configuration__c Config = [SELECT csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.name = 'Mobility']; 
        System.debug('Config: '+Config.cscfga__Product_Definition__r.product_Specification__c);
        Test.startTest();
        Boolean isReactivateServicePresent = NumberReservationHelper.checkReactivateServices(Config.cscfga__Product_Basket__c);
        System.assertEquals(isReactivateServicePresent,false,'Reactivate service not present');
        Test.stopTest();
    }
    
    @isTest
    public static void getNGUCProductConfigTest(){
        List<cscfga__Product_Configuration__c> configListtemp = [SELECT id,cscfga__Product_Basket__c,cscfga__Product_Definition__r.name FROM cscfga__Product_Configuration__c ];
        Test.startTest();
        List<Object> result = NumberReservationHelper.getNGUCProdConfig(configListtemp[0].cscfga__Product_Basket__c,'Manage Number');
         System.assertEquals(result!=null,true,'Values retrieved');
        Test.stopTest();
    }
        @isTest
    public static void migrationPlanMappingTest(){
        Test.startTest();
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c,cscfga__Parent_Configuration__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__r.cscfga__Opportunity__r.type='Migration' LIMIT 1];
        List<String> pcList = new List<String>();
        for(cscfga__Product_Configuration__c pc : configList){
            pcList.add(pc.id);
        }
        List<Number__c> numbList = [SELECT service_number__c,Id FROM Number__c WHERE  Service_Number__c='61459834555'];
        List<String> numberList = new List<String> ();
        numberList.add(numbList[0].service_number__c);
        Object result = NumberReservationHelper.assignMSISDNNumbers(pcList,numberList,configList[0].cscfga__Product_Basket__c,'SIM Card','Existing Active SIM','Transition');
        numbList = [SELECT service_number__c,Id,Product_Configuration__c FROM Number__c WHERE  Service_Number__c='61459834555'];
        Test.stopTest();
        System.assertEquals(numbList[0].Product_Configuration__c,pcList[0]);
    }
    	@isTest  
    public static void migrationPlanMappingNegativeTest(){
        Test.startTest();
        List<cscfga__Product_Configuration__c> configList = [SELECT id,cscfga__Product_Basket__c,cscfga__Parent_Configuration__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__r.cscfga__Opportunity__r.type='Migration' LIMIT 1];
        List<String> pcList = new List<String>();
        for(cscfga__Product_Configuration__c pc : configList){
            pcList.add(pc.id);
        }
        List<Number__c> numbList = [SELECT service_number__c,id FROM Number__c WHERE  Service_Number__c='6145983444'];
        List<String> numberList = new List<String> ();
        numberList.add(numbList[0].service_number__c);
        Object result = NumberReservationHelper.assignMSISDNNumbers(pcList,numberList,configList[0].cscfga__Product_Basket__c,'SIM Card','Existing Active SIM','Transition');
        numbList = [SELECT service_number__c,Id,Product_Configuration__c FROM Number__c WHERE  Service_Number__c='6145983444'];
        Test.stopTest();
        System.assertNotEquals(numbList[0].Product_Configuration__c,pcList[0]);
    }
		 
}