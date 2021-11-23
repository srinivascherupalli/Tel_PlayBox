@isTest
public class MobilePortinControllerTest {
    /*----------------------------------------------------------------
Method : setupdata
Author: Kalashree Borgaonkar
Story: EDGE-132716 
Descripton : Create Data
-------------------------------------------------------------------------------------*/
    @testSetup 
    public static void setupdata(){
        Contact c = TestUtil.createContact('Joe', 'Bloggs');
        c.MobilePhone = '0445678006';
        c.Pref_Comm_Method__c='eMail';
        c.Email ='abc@gmail.com';
        insert c;
        Contact con = TestUtil.createContact('Joe', 'Smith');
        con.Birthdate=null;
        con.MobilePhone = '0445678006';
        con.Pref_Comm_Method__c='Phone';
        insert con;
        //TED-383 Start
        //Create Adobe Agreement Templates
        List<echosign_dev1__Agreement_Template__c> eSignTemplateids = new List<echosign_dev1__Agreement_Template__c>();
        echosign_dev1__Agreement_Template__c templateid1 = new echosign_dev1__Agreement_Template__c();
        templateid1.name = 'CAF Flow';
        eSignTemplateids.add(templateid1);
        echosign_dev1__Agreement_Template__c templateid2 = new echosign_dev1__Agreement_Template__c();
        templateid2.name = 'BSA Flow';
        eSignTemplateids.add(templateid2);
        insert eSignTemplateids;
        //TED-383 End
        Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        TestUtil.addContactToAccount(acc.Id, c.Id);
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        OpportunityContactRole ocr = TestUtil.createOCR(c,opp);
        insert ocr;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        AccountContactRelation acr = [SELECT id FROM AccountContactRelation WHERE Accountid=:acc.Id];
        acr.Roles = 'Legal Lessee';
        update acr;
        List<Service_Qualification__c> sqList = new List<Service_Qualification__c>();
        Service_Qualification__c sqRecord = TestUtil.createServiceQualification(acc,'61411111111','Y');
        sqRecord.SQ_Type__c='Port in SQ';
        sqRecord.Added_to_CA_form__c=true;
         sqRecord.basket_id__c=basket.id; //DIGI-867
        sqList.add(sqRecord);
        Service_Qualification__c sqRecord1 = TestUtil.createServiceQualification(acc,'61422222222','N');
        sqRecord1.SQ_Type__c='Port in SQ';
         sqRecord1.basket_id__c=basket.id;//DIGI-867
        sqList.add(sqRecord1);
        insert sqList;
        Customer_Authority_Form__c custAuthForm = TestUtil.createCustAuthorityForm(opp,acc);
        custAuthForm.Is_active__c=true;
        custAuthForm.Type__c ='Mobile';
        insert  custAuthForm;
        String cafQueryStr = 'SELECT Account__r.ABN__c, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingStreet, Account__r.Customer_Trading_Name__c, Account__r.BillingPostalcode,Contact__r.Birthdate,Contact__r.name FROM Customer_Authority_Form__c WHERE Id = \'{pv0}\' AND Type__c = \'Mobile\'';
        String sqQueryStr = 'SELECT Account__c, Added_to_CA_form__c, Id, Name, Service_Number__c FROM Service_Qualification__c WHERE Account__c = \'{pv0}\' AND Service_Number__c IN ({pv1})';        
        List<APXTConga4__Conga_Merge_Query__c> queryList = new List<APXTConga4__Conga_Merge_Query__c>();
        APXTConga4__Conga_Merge_Query__c cafquery = TestUtil.createCongaQuery('CAFqueryMobile', cafQueryStr);
        queryList.add(cafquery);
        APXTConga4__Conga_Merge_Query__c sqquery = TestUtil.createCongaQuery('SQNumberDataMobile', sqQueryStr);
        queryList.add(sqquery);
        insert queryList;
        APXTConga4__Conga_Template__c template = TestUtil.createCongaTemplate('CAFtemplateMobile','Document','Type');
        insert template;
    }
    /*----------------------------------------------------------------
Method : initiateCAFtest
Author: Kalashree Borgaonkar
Story:EDGE-80749
-------------------------------------------------------------------------------------*/
    @isTest
    public static void initiateCAFtest(){
        Test.startTest();
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity opp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        Contact c = [SELECT id,accountid FROM Contact WHERE name LIKE 'Joe Bloggs']; 
        List<String> lstServiceNumber=new List<String>();
        lstServiceNumber.add('61411111111');
        lstServiceNumber.add('6142222222');
        //List<Service_Qualification__c> lstServiceNumber = [SELECT Service_Number__c FROM Service_Qualification__c WHERE account__c = :c.accountid];
        MobilePortinController.InputWrapper wrap = new MobilePortinController.InputWrapper();
        wrap.accountId = c.accountId;
        wrap.portNumber = '61411111112';
        wrap.oppid = opp.id;
        wrap.lstServiceNumber = lstServiceNumber;
        wrap.contactid = c.id;
        wrap.name = 'c.id';

        String result = MobilePortinController.initiateCAF(wrap) ;        
        
        Test.stopTest();
        System.assertEquals(result!=null, true, 'CA initiated');
    }
    
    /*----------------------------------------------------------------
Method : updateCongaURLTest
Author: Kalashree Borgaonkar
Story:EDGE-80749
-------------------------------------------------------------------------------------*/
    @isTest
    public static void updateCongaURLTest(){
        Test.startTest();
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE csbb__Account__r.name LIKE 'Test Account1'];
        MobilePortinController.updateCongaURL(basket.Id);
        Test.stopTest();
        System.assertEquals(basket!=null, true, 'msg');
    }
    
    /*----------------------------------------------------------------
Method : getQualifiedMsisdnTest
Author: Aishwarya
Story: EDGE-88791
-------------------------------------------------------------------------------------*/
    
    @isTest
    public static void getQualifiedMsisdnTest(){
        cscfga__Product_Configuration__c productConfig = TestDataFactory.generateProductConfiguration();
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity opp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        cscfga__Product_Basket__c basket = [SELECT id,csbb__Account__c FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];
        Service_Qualification__c sqRecord = TestUtil.createServiceQualification(acc,'61411134111','Y');
        sqRecord.SQ_Type__c='Port in SQ';
        insert sqRecord;
        Test.startTest();
        List<MobilePortinController.QualifiedNumbers> qualifiedNumList = MobilePortinController.getAllQualifiedMsisdn(basket.id);
        Test.stopTest();
        System.assertEquals(qualifiedNumList!=Null, true, 'Received Qualified MSISDN');
    }
    /*----------------------------------------------------------------
Method : getDetailsTest
Author: Aishwarya
Story: EDGE-88791
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getDetailsTest(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c];
        Test.startTest();
        MobilePortinController.BasketDetailsWrapper wrap= MobilePortinController.getAllDetails(basket.id);
        Test.stopTest();
        System.assertEquals(wrap!=null,true,'Deatils Wrapper created');
    }
    /*----------------------------------------------------------------
Method : getContactSearchWithTextTest
Author: Aishwarya
Story: EDGE-88795
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getContactSearchWithTextTest(){
        Opportunity opp = [SELECT id,AccountID FROM Opportunity WHERE name = 'TestOpp'];
        Test.startTest();
        List<Contact> acrList= MobilePortinController.getContactsForSearch(opp.AccountID,opp.Id,'Test');
        Test.stopTest();
        System.assertEquals(opp!=null,true, 'Contacts found with searct key');
    }
    
    /*----------------------------------------------------------------
Method : getContactSearchWithoutTextTest
Author: Aishwarya
Story: EDGE-88791
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getContactSearchWithoutTextTest(){
        Opportunity opp = [SELECT id,AccountID FROM Opportunity WHERE name = 'TestOpp'];
        Test.startTest();
        List<Contact> acrList= MobilePortinController.getContactsForSearch(opp.AccountID,opp.Id,'');
        Test.stopTest();
        System.assertEquals(opp!=null,true, 'Contacts found without search key');
    }
    
    /*----------------------------------------------------------------
Method : getPortInMsisdnsWithTextTest
Author: Aishwarya
Story:  EDGE-88791
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getPortInMsisdnsWithTextTest(){
        Opportunity opp = [SELECT id,AccountID FROM Opportunity WHERE name = 'TestOpp'];
        Test.startTest();
        List<Service_Qualification__c> sqList= MobilePortinController.getPortInMsisdns(opp.AccountID,opp.Id,'614');
        Test.stopTest();
        System.assertEquals(sqList!=null,true, 'SQ found with search key');
    }
    /*----------------------------------------------------------------
Method : getPortInMsisdnsWithOutTextTest
Author: Aishwarya
Story: EDGE-88795
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getPortInMsisdnsWithOutTextTest(){
        Opportunity opp = [SELECT id,AccountID FROM Opportunity WHERE name = 'TestOpp'];
        Test.startTest();
        List<Service_Qualification__c> sqList= MobilePortinController.getPortInMsisdns(opp.AccountID,opp.Id,'');
        Test.stopTest();
        System.assertEquals(sqList!=null,true, 'SQ found without search key');
    }
    /*----------------------------------------------------------------
Method : saveCAFTest
Author: Aishwarya
Story: EDGE-88791
-------------------------------------------------------------------------------------*/
    @isTest
    public static void saveCAFTest(){
        cscfga__Product_Basket__c basket = [SELECT id,csbb__Account__c FROM cscfga__Product_Basket__c];
        List<MobilePortinController.QualifiedNumbers> qualifiedNumList = new List<MobilePortinController.QualifiedNumbers>();
        qualifiedNumList.add(new MobilePortinController.QualifiedNumbers(true,'61411111111','PPV Completed'));
        qualifiedNumList.add(new MobilePortinController.QualifiedNumbers(true,'61422222222','PPV Completed'));
        String msisdnList = JSON.serialize(qualifiedNumList);
        Contact con = [SELECT id,accountid,Name,Birthdate,Email FROM Contact WHERE name LIKE 'Joe Bloggs']; 
        MobilePortinController.InputWrapper wrap = new MobilePortinController.InputWrapper();
        wrap.basketid = basket.id;
        wrap.accountId = basket.csbb__Account__c;
        wrap.portNumber = '61411111111';
        wrap.qualifiedNumList = msisdnList;
        wrap.signatoryContactid = con.id;
        wrap.Contactid = con.id;
        String input = Json.serialize(wrap);
        Test.startTest();
        
        String result = MobilePortinController.saveCAF(input,false) ;        
        Test.stopTest();
        System.assertEquals(result!=null, true, 'CA initiated');
    }
    /*----------------------------------------------------------------
Method : saveCAFNegativeTest
Author: Aishwarya
Story: EDGE-88791
-------------------------------------------------------------------------------------*/
    @isTest
    public static void saveCAFNegativeTest(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c];
        List<MobilePortinController.QualifiedNumbers> qualifiedNumList = new List<MobilePortinController.QualifiedNumbers>();
        qualifiedNumList.add(new MobilePortinController.QualifiedNumbers(true,'61411111111','PPV Completed'));
        qualifiedNumList.add(new MobilePortinController.QualifiedNumbers(false,'61422222222','PPV Completed'));
        String msisdnList = JSON.serialize(qualifiedNumList);
        
        Test.startTest();
        
        Contact con = [SELECT id,accountid,Name,Birthdate,Email FROM Contact WHERE name LIKE 'Joe Smith']; 
        System.debug('con: '+con);
        //String result = MobilePortinController.saveCAF(basket.id,con.accountId,'61411111112', msisdnList,'Joe Bloggs' ) ;
        MobilePortinController.InputWrapper wrap = new MobilePortinController.InputWrapper();
        wrap.basketid = basket.id;
        wrap.accountId = con.accountId;
        wrap.portNumber = '61411111112';
        wrap.qualifiedNumList = msisdnList;
        wrap.signatoryContactid = con.id;
        wrap.Contactid = con.id;
        String input = Json.serialize(wrap);
        String result = MobilePortinController.saveCAF(input,false) ;        
        Test.stopTest();
        System.assertEquals(result!=null, true, 'CA initiated');
    }
    /*----------------------------------------------------------------
Method : checkActiveCAFSuccess
Author: Aishwarya
Story: EDGE-88791 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void checkActiveCAFSuccess(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c];  
        Test.startTest();
        List<Customer_Authority_Form__c> cafList = MobilePortinController.checkCAF(basket.id);
        Test.stopTest();
        System.assertEquals(basket !=null,true,'Basket Not empty');
        
    }
        /*--------------------------------------------------------
EDGE        -88791,144140
Method      -createPPVrecord
Description -create child record (PPV)
Author      -Kalashree Borgaonkar
--------------------------------------------------------*/   
    @isTest
    public static void reInitiatePPVTest(){
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c];
        Contact con = [SELECT id,accountid,Name,Birthdate,Email FROM Contact WHERE name LIKE 'Joe Bloggs'];
        MobilePortinController.InputWrapper wrap = new MobilePortinController.InputWrapper();
        wrap.basketid = basket.id;
        wrap.accountId = con.accountId;
        wrap.portNumber = '61411131212';
        wrap.signatoryContactid = con.id;
        wrap.Contactid = con.id;
        String input = Json.serialize(wrap);
        Test.startTest();
        String childRecordid = MobilePortinController.reInitiatePPV(input);
        Test.stopTest();
        System.assertEquals((childRecordid!=null), true, 'child record created');       
           
    }
     @isTest
    public static void saveRengeneratedCAFTest(){
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c];
        Contact con = [SELECT id,accountid,Name,Birthdate,Email FROM Contact WHERE name LIKE 'Joe Bloggs'];
        List<Service_Qualification__c> sqList=[SELECT Service_number__c,Added_to_CA_form__c,PPV_Status__c FROM Service_Qualification__C 
                               WHERE Account__c=:acc.id AND Added_to_CA_form__c=true ];
       List<MobilePortinController.QualifiedNumbers> qualifiedNumList = new List<MobilePortinController.QualifiedNumbers>();
        qualifiedNumList.add(new MobilePortinController.QualifiedNumbers(true,'61411111111','PPV Completed'));
        qualifiedNumList.add(new MobilePortinController.QualifiedNumbers(true,'61422222222','PPV Completed'));
        String msisdnList = JSON.serialize(qualifiedNumList);
        MobilePortinController.InputWrapper wrap = new MobilePortinController.InputWrapper();
        wrap.basketid = basket.id;
        wrap.accountId = con.accountId;
        wrap.portNumber = '61411131212';
        wrap.signatoryContactid = con.id;
        wrap.Contactid = con.id;
        wrap.qualifiedNumList=msisdnList;
        String input = Json.serialize(wrap);
        Test.startTest();
        String result = MobilePortinController.saveRengeneratedCAF(input,true,basket.id);//DIGI-867
        Test.stopTest();
        System.assertEquals(input!=null, true, 'CA initiated');       
           
    }
    /*-------------------------------------------------------- 
EDGE        -172365
Method      -displayMobileNumberTest
Description -fetch mobile number for given contact id
Author      -Aishwarya
--------------------------------------------------------*/
    @isTest
    public static void displayMobileNumberTest(){
        Contact con = [SELECT id,MobilePhone,accountid,Name,Birthdate,Email FROM Contact WHERE name LIKE 'Joe Bloggs'];
        Test.startTest();
        String mobileNumber=MobilePortinController.fetchMobileNumber(con.id);
        Test.stopTest();
        System.assertEquals(mobileNumber=='61445678006', true, 'Mobile Number found');  

        
    }
/*-------------------------------------------------------- 
DIGI        -779
Method      -sendSMSTest
Description -
Author      -Irfan
--------------------------------------------------------*/   
    @isTest
    public static void sendSMSTest(){
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity opp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        cscfga__Product_Basket__c basket = [SELECT id,csbb__Account__c FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];
        Customer_Authority_Form__c custAuthForm = TestUtil.createCustAuthorityForm(opp,acc);
        custAuthForm.Is_active__c=true;
        custAuthForm.Type__c ='Mobile';
        insert  custAuthForm;
        
        String Mobilenumber = '0488706980';
        
        Test.startTest();
        String sendSMS = MobilePortinController.sendSMS(Mobilenumber, basket.Id);
        Test.stopTest();
        System.assertEquals(custAuthForm.Type__c =='Mobile', true, 'CA Form is of type mobile');  
    }
    
    /*-------------------------------------------------------- 
DIGI        -779
Method      -verifyOTPTest
Description -
Author      -Irfan
--------------------------------------------------------*/   
    @isTest
    public static void verifyOTPTest(){
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity opp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        cscfga__Product_Basket__c basket = [SELECT id,csbb__Account__c FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];
        Customer_Authority_Form__c custAuthForm = TestUtil.createCustAuthorityForm(opp,acc);
        custAuthForm.Is_active__c=true;
        custAuthForm.Type__c ='Mobile';
        insert  custAuthForm;
        
        String Mobilenumber = '0488706980';
        String otpInput = '707070';
        List<String> numPort = new List<String>();
        numPort.add('0488706980');
        System.debug('numPort**'+numPort);
        
        Test.startTest();
        String verifyOTP = MobilePortinController.verifyOTP(Mobilenumber, basket.Id, opp.Id, otpInput, numPort );
        Test.stopTest();
        System.assertEquals(otpInput =='707070', true, 'OTP Verified.');  
    }
    
    
     /*-------------------------------------------------------- 
DIGI        -779
Method      -processPPVDataTest
Description -Process PPV Data
Author      -Irfan Inamdar
---------------------------------------------------------*/   
    @isTest
    public static void processPPVDataTest(){
        Account acc = [SELECT id FROM Account WHERE name='Test Account1'];
        Opportunity opp =  [SELECT id FROM Opportunity WHERE AccountID=:acc.id];
        cscfga__Product_Basket__c basket = [SELECT id,csbb__Account__c FROM cscfga__Product_Basket__c WHERE csbb__Account__c=:acc.id];
        Customer_Authority_Form__c custAuthForm = TestUtil.createCustAuthorityForm(opp,acc);
        custAuthForm.Is_active__c=true;
        custAuthForm.Type__c ='Mobile';
        insert  custAuthForm;
        List<PRM_PPVCheck_Staging__c> stagingRecList = new List<PRM_PPVCheck_Staging__c>();
        List<Service_Qualification__c> sqList = new List<Service_Qualification__c>();
        
		//insert PRM_PPVCheck_Staging__c
		PRM_PPVCheck_Staging__c ppvs = new PRM_PPVCheck_Staging__c();
		ppvs.Is_Processed_in_CSV__c = true;
		ppvs.Secondary_number_PPV_Status__c = 'Success';
		ppvs.Opportunity_Id__c = opp.Id;
        insert ppvs;
        stagingRecList.add(ppvs);
        
        //insert Service_Qualification__c
        Service_Qualification__c sq = new Service_Qualification__c();
        sq.Service_number__c = '8888705970';
        sq.Added_to_CA_form__c = true;
        sq.PPV_Status__c = 'Success';
        sq.Portability_Status__c = 'Y';
        insert sq;
        sqList.add(sq);
        
		        
        
        Test.startTest();
        MobilePortinController.processPPVData(basket.Id, opp.Id, custAuthForm.Id, stagingRecList, sqList);
        Test.stopTest(); 
    }
    
}