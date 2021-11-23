/***************************************************************************************************************************
Class Name : EmailUtilsTest
============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Vijayalakshmi         06/11/2019    EDGE-103485 Test method for TID email notify scenario
2.            Vijayalakshmi         06/11/2019    EDGE-103485 Handle the cancel for TID email notify scenario 
3.            Vijayalakshmi         08/01/2020    EDGE-130265 Changes to handle soql limit for dataSetup
4.            Aarathi               24/12/2019    DPG 668
5.            Manish Jha            23/03/2020    Edge-141343 defect fix
6.            Aruna Aware           29/06/2020    DPG-1753    IoT Shared Plan - Order confirmation email for new Order
7.            Prajakta              11/08/2020    EDGE-154675
8.            Neha Trivedi          28/09/2020    DPG- 2735 IoT Annual Data Plan - Order confirmation email for new Order
9.            Kamlesh Kumar         13/04/2021    EDGE-205667 Testing updateCoBaMergeField method
****************************************************************************************************************************
*/
@isTest
public class EmailUtilsTest{
    @Testsetup
    public static void dataSetup(){ // setup
        
        BDS_Notify_Settings__c featureLevel = new BDS_Notify_Settings__c(name = 'Feature Level',Value__c = 'FeatureLevelShadow',Is_SI5_Offer__c  = true);
        BDS_Notify_Settings__c technicalSupport = new BDS_Notify_Settings__c(name = 'Technical Support',Value__c = 'TechnicalSupportShadow ',Is_SI5_Offer__c  = true);
        insert new List<BDS_Notify_Settings__c>{featureLevel,technicalSupport};
        
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Account_Status__c='Active';
        acc.Customer_Status__c  = 'Active';
        insert acc;

        Billing_Account__c ba = new Billing_Account__c();
        ba.Billing_Account_Number__c = '123456789012';
        insert ba;
        
        
       //END-- 28/09/2020    DPG- 2735 
        
        List<User> testUsers = null;
        //Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        //opp.amount = 4600;
        //opp.AccountId = acc.id;
        //insert opp;
        //EDGE-78509 - start for Test data creation 
        // Changes start for EDGE-130265
    Test.startTest(); 
    // Changes end for EDGE-130265    
        Profile pro = [SELECT Id,name FROM Profile WHERE Name like '%Sales Enterprise B2B%' limit 1];  
        if(pro!=null){
           createTestUser( pro.Id, 'Munich', 'UTTester');
            /*new User( Alias = 'standt', Email='standarduser@tt.com',  
            EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',  
            LocaleSidKey='en_US', ProfileId = pro.Id, Phone = '234434344343', title = 'Sales Manager',
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@tt.com');
            User usrPRM = new User( Alias = 'user2', Email='standarduser1@tt.com',  
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',  
            LocaleSidKey='en_US', ProfileId = pro.Id, Title = null,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@tt.com',phone='+121231231234');*/
            testUsers  = new List<User>();
            testUsers= [SELECT Id, Alias,Email,EmailEncodingKey,LastName,LanguageLocaleKey,LocaleSidKey,ProfileId,Phone,title,TimeZoneSidKey,UserName FROM User WHERE ProfileId =: pro.Id];
            
            
        }     
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.name='opp1';
        opp.StageName='Closed Won';
        opp.CloseDate=System.today()+5;
        opp.AccountId = acc.id;
        oppList.add(opp);
       //START-- 28/09/2020    DPG- 2735 
        Opportunity opp2 = new Opportunity();
        opp2.name='opp2';
        opp2.StageName='Closed Won';
        opp2.CloseDate=System.today()+5;
        opp2.AccountId = acc.id;
        oppList.add(opp2);
        
        Opportunity opp3 = new Opportunity();
        opp3.name='opp3';
        opp3.StageName='Closed Won';
        opp3.CloseDate=System.today()+5;
        opp3.AccountId = acc.id;
        oppList.add(opp3);

        Opportunity partnerOpp  = new Opportunity();
        partnerOpp.Name = 'TestOpp';
        partnerOpp.AccountId = acc.id;
        partnerOpp.StageName = 'Committed';
        partnerOpp.Opportunity_Source__c = 'Partner';
        partnerOpp.CloseDate = System.today();
        partnerOpp.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        oppList.add(partnerOpp);
        
        Opportunity partnerOpp2  = new Opportunity();
        partnerOpp2.Name = 'TestOpp2';
        partnerOpp2.AccountId = acc.id;
        partnerOpp2.StageName = 'Committed';
        partnerOpp2.Opportunity_Source__c = 'Partner';
        partnerOpp2.CloseDate = System.today();
        partnerOpp2.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        oppList.add(partnerOpp2);
        insert oppList;
        
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Synchronised_With_Opportunity__c = true;
        basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        basketList.add(basket);
        
        //START-- 28/09/2020    DPG- 2735 
        cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c();
        basket2.cscfga__Opportunity__c = opp2.id;
        basket2.csbb__Synchronised_With_Opportunity__c = true;
        basket2.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        basketList.add(basket2);
        //END-- 28/09/2020    DPG- 2735 

        cscfga__Product_Basket__c basket3 = new cscfga__Product_Basket__c();
        basket3.cscfga__Opportunity__c = opp3.id;
        basket3.csbb__Synchronised_With_Opportunity__c = true;
        basket3.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        basketList.add(basket3);
        insert basketList;
        
        List<Contact> conList=new List<Contact>();
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        //EDGE - 87289 Start
        contact.FirstName = 'Reena';
        contact.LastName = 'Primary';

        //EDGE - 87289 End
        contact.Pref_Comm_Method__c='eMail';
        contact.MobilePhone='+61123456789';
        contact.Email=System.UserInfo.getUserEmail();
        contact.AccountId = acc.id;
        conList.add(contact);
        //insert contact;
        
        //EDGE - 87289 Start
        Contact contact1 = AccountTestFactory.buildContact(acc, 'Timson');
        contact1.FirstName = '';
        contact1.Pref_Comm_Method__c='eMail';
        contact1.MobilePhone='+61123456789';
        contact1.Email=System.UserInfo.getUserEmail();
        contact1.AccountId = acc.id;
        conList.add(contact1);
        insert conList;
       // test.stopTest();
        //insert contact1;
        //EDGE - 87289 End
        
        List<OpportunityContactRole> oppContactRole = new List<OpportunityContactRole>();
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId=contact.id;
        ocr.OpportunityId=opp.id;
        ocr.IsPrimary=true;
        ocr.ROLE = 'Decision Maker';
        oppContactRole.add(ocr);
        
        //START-- 28/09/2020    DPG- 2735 
        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.ContactId=contact.id;
        ocr2.OpportunityId=opp2.id;
        ocr2.IsPrimary=true;
        ocr2.ROLE = 'Decision Maker';
        oppContactRole.add(ocr2);
        
        OpportunityContactRole ocr3 = new OpportunityContactRole();
        ocr3.ContactId=contact.id;
        ocr3.OpportunityId=opp3.id;
        ocr3.IsPrimary=true;
        ocr3.ROLE = 'Decision Maker';
        oppContactRole.add(ocr3);
        insert oppContactRole;
        //END-- 28/09/2020    DPG- 2735 

        List<csord__Order_Request__c> ordReqs=new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        
        ordReqs.add(ordReq);
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq2);
        csord__Order_Request__c ordReq3 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq3);
        csord__Order_Request__c ordReq4 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq4);
        csord__Order_Request__c ordReqMobility = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReqMobility);
        csord__Order_Request__c ordReq5 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq5);
        csord__Order_Request__c ordReq6 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq6);
        csord__Order_Request__c ordReq7 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq7);
        insert ordReqs;
        
        List<cscfga__Product_Definition__c> productDefinitionList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('TestProduct', 'TestPlan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000304';
        productDefinitionList.add(prodDef);
                
        cscfga__Product_Definition__c prodDefMobility = ProductTestFactory.buildProductDefinition('TestProduct', 'TestPlan');
        prodDefMobility.product_Specification__c = 'DMCAT_ProductSpecification_000420';
        productDefinitionList.add(prodDefMobility);
        
        // DPG-1753 - IoT Shared Plan - Order confirmation email for new Order
        cscfga__Product_Definition__c prodDefIoT = ProductTestFactory.buildProductDefinition('TestProductIOT', 'TestPlanIot');
        prodDefIoT.product_Specification__c = 'DMCAT_ProductSpecification_000965';
        productDefinitionList.add(prodDefIoT);
        insert productDefinitionList;        
        
        List<cscfga__Product_Configuration__c> prdConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        prdConfigList.add(prodConfig);
        
        cscfga__Product_Configuration__c prodConfigMobility = ProductTestFactory.buildProductConfig(prodDefMobility.Id);
        prdConfigList.add(prodConfigMobility);
        // EDGE-98409
        cscfga__Product_Configuration__c prodConfigMobility1 = ProductTestFactory.buildProductConfig(prodDefMobility.Id);
        prodConfigMobility1.Type__c='Cancel';
        prdConfigList.add(prodConfigMobility1);
        
        cscfga__Product_Configuration__c prodConfigModify = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfigModify.Type__c='Modify';
        prdConfigList.add(prodConfigModify);
        // DPG-1753 - IoT Shared Plan - Order confirmation email for new Order 
        cscfga__Product_Configuration__c prodConfigIOT = ProductTestFactory.buildProductConfig(prodDefIoT.Id);
        prodConfigIOT.Name='IoT Shared Plan';
        prdConfigList.add(prodConfigIOT);
       //START-- 28/09/2020    DPG- 2735 
        cscfga__Product_Configuration__c prodConfigIOT1 = ProductTestFactory.buildProductConfig(prodDefIoT.Id);
        prodConfigIOT1.Name='IoT Right Plan';
        prdConfigList.add(prodConfigIOT1);       
        cscfga__Product_Configuration__c prodConfigIOT2 = ProductTestFactory.buildProductConfig(prodDefIoT.Id);
        prodConfigIOT2.Name='IoT Annual Data Plan';
        prdConfigList.add(prodConfigIOT2);
        insert prdConfigList;
        //END-- 28/09/2020    DPG- 2735 

        
        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.Offer_Spec_Id__c = 'DMCAT_Offer_000303';
        insert offer;     
        
        List<APXTConga4__Conga_Email_Template__c> templates=new List<APXTConga4__Conga_Email_Template__c>();
        APXTConga4__Conga_Email_Template__c congaTemplate =new APXTConga4__Conga_Email_Template__c();
        congaTemplate.APXTConga4__HTMLBody__c = 'test conga';
        congaTemplate.APXTConga4__Name__c = 'Order_Completed';
        templates.add(congaTemplate);
        
        
        
        APXTConga4__Conga_Email_Template__c testCongaNew1 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew1.APXTConga4__HTMLBody__c = '<img alt=\"\" src=\"https://cloud.telstra.com/static/email/00002/Email_blue_600.jpg\" style=\"width: 100%;\"></img><br><span style=\"font-size: 9.5pt;\"><span><span style=\"font-family: Arial,sans-serif;\"><span class=\"MsoHyperlink\" style=\"color: #004d9d;\"><span style=\"font-size: 11.0pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Your Telstra Connected Workplace order</span></span> </span></span></span></span></span><br><span style=\"font-size: 10px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Order number: &lt;Order ID&gt;</span></span><br><br><span style=\"font-size: 10px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Thanks for ordering Connected Workplace services for the following locations:</span></span><br><span style=\"font-size: 10px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">&lt;Site Names&gt;​</span></span><br><br><span style=\"font-size: 9.5pt;\"><span><span style=\"font-family: Arial,sans-serif;\"><span style=\"font-size: 10.0pt;\"><span style=\"font-size: 10px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Refer to your order form for full details of your order.</span></span> </span></span></span></span><br><br><span style=\"color: #40E0D0;\"><span style=\"font-size: 10px;\"><span style=\"font-family: arial,helvetica,sans-serif;\"><strong>Next steps</strong></span></span></span><br> \n<table class=\"MsoTableGrid\"><tbody><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">YOU</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Start setting up Telstra Collaboration and Telstra Internet Protection</span></span></span><br>\t\t\t<span style=\"font-size: 10px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #414141;\">Log in to our Telstra Collaboration Management Portal to set up users and allocate their phone numbers. If you’re a new customer, login details are on their way. You’ll also receive configuration details to help you get started with Telstra Internet Protection.</span></span></span></td></tr><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">WE</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Introduce you to our project manager</span></span></span><br>\t\t\t<span style=\"font-size: 10px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #414141;\">Your project manager is your key contact during your Connected Workplace setup.</span></span></span><br>\t\t\t<span style=\"font-size: 9.5pt;\"><span><span><span style=\"font-family: Arial,sans-serif;\"><span style=\"font-size: 10.0pt;\"><span><span style=\"color: #414141;\"><span style=\"font-size: 10px;\">They’ll call you to discuss the project plan and keep you posted on how it’s tracking</span>.</span></span></span></span></span></span></span></td></tr><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">WE</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Call you for tech details</span></span></span><br>\t\t\t<span style=\"font-size: 10px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #414141;\">We’ll contact you for details about your IP addresses and domain names to help us establish your Telstra Internet Protection service.</span></span></span></td></tr><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">WE</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Deliver your hardware</span></span></span><br>\t\t\t<span style=\"font-size: 10px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #414141;\">You’ll hear from our delivery partner confirming when your new network and phone hardware arrives at each of your sites.</span></span></span></td></tr><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">WE</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Install network access for your new <a target=\"_blank\">service</a></span></span></span><br>\t\t\t<span style=\"font-size: 9.5pt;\"><span><span style=\"font-family: Arial,sans-serif;\"><span style=\"font-size: 10.0pt;\"><span><span style=\"color: #414141;\"><span style=\"font-size: 10px;\">We’ll send your primary and site contacts an email confirming when our field technician will  arrive</span>.</span></span></span></span></span></span></td></tr><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">YOU</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Test and activate your new phone service</span></span></span><br>\t\t\t<span style=\"font-size: 10px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #414141;\">Once your new network access is installed, you’ll be able to switch over your existing phone service to your new Telstra Collaboration service. We’ll email you details of how to do this. </span></span></span></td></tr><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">YOU</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Sign off once you’re happy</span></span></span><br>\t\t\t<span style=\"font-size: 10px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #414141;\">Once all your sites are ready with your new Connected Workplace services, we’ll email you a final acceptance form to sign.</span></span></span></td></tr></tbody></table>\n<br><span style=\"font-size: 9.5pt;\"><span><span style=\"font-family: Arial,sans-serif;\"><span style=\"font-size: 9px;\"><span style=\"color: #40E0D0;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Get on board with Telstra Connect</span></span></span></span></span></span><br><br><span style=\"font-size: 9px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Telstra Connect will soon be the single digital platform for all your business interactions with us, simplifying the way you manage your Telstra products and services. Log in to our app (<i><a href=\"http://bit.ly/tconnect-ios-pp\" style=\"color: #004d9d; font-weight: bold; font-style: italic;\" target=\"_blank\"><b>iOS</b></a></i>/<i><a href=\"http://bit.ly/tconnect-and-pp\" style=\"color: #004d9d; font-weight: bold; font-style: italic;\" target=\"_blank\"><b>Android</b></a></i>) or simply log in to <span style=\"color: #0070c0;\"><a href=\"https://connectapp.telstra.com\" style=\"color: #004d9d; font-weight: bold; font-style: italic;\" target=\"_blank\"><b><span style=\"color: #0070c0;\">https://connectapp.telstra.com</span></b></a></span>.</span></span><br><br><span style=\"font-size: 9.5pt;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"font-family: arial,helvetica,sans-serif;\"><span style=\"font-size: 9px;\"><span style=\"color: #40E0D0;\">Don’t have access to Telstra Connect?</span></span></span> </span></span><br><br><span style=\"font-family: arial,helvetica,sans-serif;\"><span style=\"font-size: 10px;\"><a href=\"https://www.telstra.com.au/business-enterprise/self-service/telstra-connect\" style=\"color: #004d9d; font-weight: bold; font-style: italic;\" target=\"_blank\"><b>Sign up now</b></a></span><br><br><span style=\"font-size: 9px;\"><strong><span style=\"color: #000000;\"><span class=\"MsoHyperlink\"><span style=\"font-weight: normal;\">Any questions?</span></span></span></strong></span></span><br><span style=\"font-size: 9px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Call us within Australia on 1800 370 430. We’re available 24/7 for faults and Monday to Friday 9 am to 5 pm (AET) for billing and general inquiries. </span></span><br><br><span style=\"font-size: 9px;\"><i>Please do not reply to this email. It’s been sent from an automated system.</i></span>\n\n<div><span style=\"font-size: 9px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">This communication may contain confidential or copyright information of Telstra Corporation Limited (ABN 33 051 775 556). If you&#39;ve received this in error, please delete it immediately. <a href=\"https://www.telstra.com.au/privacy\" target=\"_blank\"><strong><em>Privacy at Telstra</em></strong></a>.</span></span>\n\n<hr class=\"msocomoff\"></hr>\n<div>\n<div class=\"msocomtxt\"> </div>\n</div>\n</div>';
        testCongaNew1.APXTConga4__Name__c = 'CWP_Order_Received';
        templates.add(testCongaNew1);
        //Edge-141343
        APXTConga4__Conga_Email_Template__c testCongaNewNGUCNew =new APXTConga4__Conga_Email_Template__c();
        testCongaNewNGUCNew.APXTConga4__HTMLBody__c = '<img alt=\"\" src=\"https://cloud.telstra.com/static/email/00002/Email_blue_600.jpg\" style=\"width: 100%;\"></img><br><span style=\"font-size: 9.5pt;\"><span><span style=\"font-family: Arial,sans-serif;\"><span class=\"MsoHyperlink\" style=\"color: #004d9d;\"><span style=\"font-size: 11.0pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Your Telstra Connected Workplace order</span></span> </span></span></span></span></span><br><span style=\"font-size: 10px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Order number: &lt;Order ID&gt;</span></span><br><br><span style=\"font-size: 10px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Thanks for ordering Connected Workplace services for the following locations:</span></span><br><span style=\"font-size: 10px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">&lt;Site Names&gt;​</span></span><br><br><span style=\"font-size: 9.5pt;\"><span><span style=\"font-family: Arial,sans-serif;\"><span style=\"font-size: 10.0pt;\"><span style=\"font-size: 10px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Refer to your order form for full details of your order.</span></span> </span></span></span></span><br><br><span style=\"color: #40E0D0;\"><span style=\"font-size: 10px;\"><span style=\"font-family: arial,helvetica,sans-serif;\"><strong>Next steps</strong></span></span></span><br> \n<table class=\"MsoTableGrid\"><tbody><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">YOU</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Start setting up Telstra Collaboration and Telstra Internet Protection</span></span></span><br>\t\t\t<span style=\"font-size: 10px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #414141;\">Log in to our Telstra Collaboration Management Portal to set up users and allocate their phone numbers. If you’re a new customer, login details are on their way. You’ll also receive configuration details to help you get started with Telstra Internet Protection.</span></span></span></td></tr><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">WE</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Introduce you to our project manager</span></span></span><br>\t\t\t<span style=\"font-size: 10px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #414141;\">Your project manager is your key contact during your Connected Workplace setup.</span></span></span><br>\t\t\t<span style=\"font-size: 9.5pt;\"><span><span><span style=\"font-family: Arial,sans-serif;\"><span style=\"font-size: 10.0pt;\"><span><span style=\"color: #414141;\"><span style=\"font-size: 10px;\">They’ll call you to discuss the project plan and keep you posted on how it’s tracking</span>.</span></span></span></span></span></span></span></td></tr><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">WE</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Call you for tech details</span></span></span><br>\t\t\t<span style=\"font-size: 10px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #414141;\">We’ll contact you for details about your IP addresses and domain names to help us establish your Telstra Internet Protection service.</span></span></span></td></tr><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">WE</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Deliver your hardware</span></span></span><br>\t\t\t<span style=\"font-size: 10px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #414141;\">You’ll hear from our delivery partner confirming when your new network and phone hardware arrives at each of your sites.</span></span></span></td></tr><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">WE</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Install network access for your new <a target=\"_blank\">service</a></span></span></span><br>\t\t\t<span style=\"font-size: 9.5pt;\"><span><span style=\"font-family: Arial,sans-serif;\"><span style=\"font-size: 10.0pt;\"><span><span style=\"color: #414141;\"><span style=\"font-size: 10px;\">We’ll send your primary and site contacts an email confirming when our field technician will  arrive</span>.</span></span></span></span></span></span></td></tr><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">YOU</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Test and activate your new phone service</span></span></span><br>\t\t\t<span style=\"font-size: 10px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #414141;\">Once your new network access is installed, you’ll be able to switch over your existing phone service to your new Telstra Collaboration service. We’ll email you details of how to do this. </span></span></span></td></tr><tr><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 44.4pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">YOU</span></span></span><br>\t\t\t </td><td colspan=\"1\" rowspan=\"1\" valign=\"top\" style=\"width: 427.5pt;\"><span style=\"font-size: 11px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #0064d2;\">Sign off once you’re happy</span></span></span><br>\t\t\t<span style=\"font-size: 10px;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"color: #414141;\">Once all your sites are ready with your new Connected Workplace services, we’ll email you a final acceptance form to sign.</span></span></span></td></tr></tbody></table>\n<br><span style=\"font-size: 9.5pt;\"><span><span style=\"font-family: Arial,sans-serif;\"><span style=\"font-size: 9px;\"><span style=\"color: #40E0D0;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Get on board with Telstra Connect</span></span></span></span></span></span><br><br><span style=\"font-size: 9px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Telstra Connect will soon be the single digital platform for all your business interactions with us, simplifying the way you manage your Telstra products and services. Log in to our app (<i><a href=\"http://bit.ly/tconnect-ios-pp\" style=\"color: #004d9d; font-weight: bold; font-style: italic;\" target=\"_blank\"><b>iOS</b></a></i>/<i><a href=\"http://bit.ly/tconnect-and-pp\" style=\"color: #004d9d; font-weight: bold; font-style: italic;\" target=\"_blank\"><b>Android</b></a></i>) or simply log in to <span style=\"color: #0070c0;\"><a href=\"https://connectapp.telstra.com\" style=\"color: #004d9d; font-weight: bold; font-style: italic;\" target=\"_blank\"><b><span style=\"color: #0070c0;\">https://connectapp.telstra.com</span></b></a></span>.</span></span><br><br><span style=\"font-size: 9.5pt;\"><span style=\"font-family: Arial,sans-serif;\"><span style=\"font-family: arial,helvetica,sans-serif;\"><span style=\"font-size: 9px;\"><span style=\"color: #40E0D0;\">Don’t have access to Telstra Connect?</span></span></span> </span></span><br><br><span style=\"font-family: arial,helvetica,sans-serif;\"><span style=\"font-size: 10px;\"><a href=\"https://www.telstra.com.au/business-enterprise/self-service/telstra-connect\" style=\"color: #004d9d; font-weight: bold; font-style: italic;\" target=\"_blank\"><b>Sign up now</b></a></span><br><br><span style=\"font-size: 9px;\"><strong><span style=\"color: #000000;\"><span class=\"MsoHyperlink\"><span style=\"font-weight: normal;\">Any questions?</span></span></span></strong></span></span><br><span style=\"font-size: 9px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">Call us within Australia on 1800 370 430. We’re available 24/7 for faults and Monday to Friday 9 am to 5 pm (AET) for billing and general inquiries. </span></span><br><br><span style=\"font-size: 9px;\"><i>Please do not reply to this email. It’s been sent from an automated system.</i></span>\n\n<div><span style=\"font-size: 9px;\"><span style=\"font-family: arial,helvetica,sans-serif;\">This communication may contain confidential or copyright information of Telstra Corporation Limited (ABN 33 051 775 556). If you&#39;ve received this in error, please delete it immediately. <a href=\"https://www.telstra.com.au/privacy\" target=\"_blank\"><strong><em>Privacy at Telstra</em></strong></a>.</span></span>\n\n<hr class=\"msocomoff\"></hr>\n<div>\n<div class=\"msocomtxt\"> </div>\n</div>\n</div>';
        testCongaNewNGUCNew.APXTConga4__Name__c = 'ngUC_Order_Recvd';
        templates.add(testCongaNewNGUCNew);
        
        APXTConga4__Conga_Email_Template__c testCongaNew2 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew2.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew2.APXTConga4__Name__c = 'Mobility_Future_Date_Cancellation';
        templates.add(testCongaNew2);
        
        APXTConga4__Conga_Email_Template__c testCongaNew3 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew3.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew3.APXTConga4__Name__c = 'Customer Email template - CWP - mobile worker cancellation';
        templates.add(testCongaNew3);
        
        APXTConga4__Conga_Email_Template__c testCongaNew4 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew4.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew4.APXTConga4__Name__c = 'Mobility_Order_Received';
        templates.add(testCongaNew4);
        
        APXTConga4__Conga_Email_Template__c testCongaNew5 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew5.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew5.APXTConga4__Name__c = 'CWP_Individual_Location_Complete_Ready_To_Bill';
        templates.add(testCongaNew5);
        
        APXTConga4__Conga_Email_Template__c testCongaNew6 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew6.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew6.APXTConga4__Name__c = '9. Customer Email template - CWP - service request order complete';
        templates.add(testCongaNew6);
        
        //Manoj : EDGE-108431
        APXTConga4__Conga_Email_Template__c testCongaNew7 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew7.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew7.APXTConga4__Name__c = 'ngUCSignupCommunicationTemplate';
        templates.add(testCongaNew7);
        
        APXTConga4__Conga_Email_Template__c testCongaNew8 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew8.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew8.APXTConga4__Name__c = 'CUSTOMER_ORDER_SINGLE_AND_MULTIPLE_OFFER';
        templates.add(testCongaNew8);
        
        APXTConga4__Conga_Email_Template__c testCongaNew9 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew9.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew9.APXTConga4__Name__c = 'OfferCancellation';
        templates.add(testCongaNew9);
         //DPG -668
        APXTConga4__Conga_Email_Template__c testCongaNew14 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew14.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew14.APXTConga4__Name__c = 'IoT_Order_Received';
        templates.add(testCongaNew14);
        
        // EDGE-103485 -- Changes start for TID Email Notify
        APXTConga4__Conga_Email_Template__c testCongaNew10 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew10.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew10.APXTConga4__Name__c = 'TID_New_Order_Recvd';
        templates.add(testCongaNew10);
        APXTConga4__Conga_Email_Template__c testCongaNew11 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew11.APXTConga4__HTMLBody__c = '';
        testCongaNew11.APXTConga4__Name__c = 'TID_New_Order_Completed';
        templates.add(testCongaNew11);
        APXTConga4__Conga_Email_Template__c testCongaNew12 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew12.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew12.APXTConga4__Name__c = 'TID_Cancel_Order_Completed';
        templates.add(testCongaNew12);
        // EDGE-103485 -- Changes end for TID Email Notify
        //EDGE-98409 : Start
        APXTConga4__Conga_Email_Template__c testCongaNew13 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew13.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew13.APXTConga4__Name__c = 'CMPOfferCancellation';
        templates.add(testCongaNew13);
        //EDGE-98409 : End
        
        APXTConga4__Conga_Email_Template__c testConga14 =new APXTConga4__Conga_Email_Template__c();
        testConga14.APXTConga4__HTMLBody__c = 'test congaTem';
        testConga14.APXTConga4__Name__c = 'EnterprizeMobility(NGEM)_Order_Received';
        templates.add(testConga14);
        
        insert templates;
        
        List<csord__Order__c> ords=new List<csord__Order__c>();
        csord__Order__c primaryOrd1 = ProductTestFactory.buildOrder('PrimaryOrderInProgress', acc.id, 'Created', ordReq.id);
        primaryOrd1.csord__Order_Request__c = ordReq.Id;
        primaryOrd1.csord__Status2__c='In Progress';
        primaryOrd1.csordtelcoa__Opportunity__c =opp.id;
        ords.add(primaryOrd1);

        csord__Order__c primaryOrd12 = ProductTestFactory.buildOrder('PrimaryOrderComplete12', acc.id, 'Created', ordReq.id);
        primaryOrd12.csord__Order_Request__c = ordReqs[6].Id;
        primaryOrd12.csord__Status2__c='In Progress';
        primaryOrd12.csordtelcoa__Opportunity__c =opp2.id;
        ords.add(primaryOrd12);
        
        csord__Order__c primaryOrd13 = ProductTestFactory.buildOrder('PrimaryOrderComplete123', acc.id, 'Created', ordReq.id);
        primaryOrd13.csord__Order_Request__c = ordReqs[7].Id;
        primaryOrd13.csord__Status2__c='In Progress';
        primaryOrd13.csordtelcoa__Opportunity__c =opp3.id;
        ords.add(primaryOrd13);
        //EDGE-103485 -- Changes start for TID Email Notify
        csord__Order__c primaryOrd3 = ProductTestFactory.buildOrder('TIDPrimaryOrderInProgress', acc.id, 'Created', ordReq.id);
        primaryOrd3.csord__Order_Request__c = ordReq5.Id;
        primaryOrd3.csord__Status2__c='In Progress';
        primaryOrd3.csordtelcoa__Opportunity__c =opp.id;
        ords.add(primaryOrd3);
        //EDGE-103485 -- Changes end for TID Email Notify
        
        csord__Order__c primaryOrd2 = ProductTestFactory.buildOrder('PrimaryOrderComplete', acc.id, 'Created', ordReq.id);
        primaryOrd2.csord__Order_Request__c = ordReq2.Id;
        primaryOrd2.csord__Status2__c='Complete';
        primaryOrd2.csordtelcoa__Opportunity__c =opp.id;
        ords.add(primaryOrd2);   
        
        csord__Order__c ord1 = ProductTestFactory.buildOrder('TestOrder1', acc.id, 'Created', ordReq.id);
        ord1.csord__Order_Request__c = ordReq.Id;
        ord1.csord__Status2__c='In Progress';
        ord1.name = 'TestOrder';
        ord1.csordtelcoa__Opportunity__c =opp.id;
        ord1.csord__Primary_Order__c = primaryOrd1.id;
        ords.add(ord1);
        
        csord__Order__c ord12 = ProductTestFactory.buildOrder('testOrderRightplan1', acc.id, 'Created', ordReq.id);
        ord12.csord__Order_Request__c = ordReq6.Id;
        ord12.csord__Status2__c='In Progress';
        ord12.name = 'testOrderRightplan12';
        ord12.csordtelcoa__Opportunity__c = opp.id;
        ord12.csord__Primary_Order__c = primaryOrd12.id;
        ords.add(ord12); 
        
        csord__Order__c ord13 = ProductTestFactory.buildOrder('testOrderRightplan1', acc.id, 'Created', ordReq.id);
        ord13.csord__Order_Request__c = ordReq7.Id;
        ord13.csord__Status2__c='In Progress';
        ord13.name = 'testOrderRightplan12';
        ord13.csordtelcoa__Opportunity__c = opp3.id;
        ord13.csord__Primary_Order__c = primaryOrd13.id;
        ords.add(ord13); 
        
        //EDGE-103485 -- Changes start for TID Email Notify
        csord__Order__c ord3 = ProductTestFactory.buildOrder('TestOrder1', acc.id, 'Created', ordReq.id);
        ord3.csord__Order_Request__c = ordReq5.Id;
        ord3.csord__Status2__c='In Progress';
        ord3.name = 'TestOrder';
        ord3.csordtelcoa__Opportunity__c =opp.id;
        ord3.csord__Primary_Order__c = primaryOrd1.id;
        ords.add(ord3);
        //EDGE-103485 -- Changes end for TID Email Notify
        
        csord__Order__c ord2 = ProductTestFactory.buildOrder('TestOrder2', acc.id, 'Created', ordReq2.id);
        ord2.csord__Order_Request__c = ordReq2.Id;
        ord2.csord__Status2__c='Complete';
        ord2.name = 'TestOrder2';
        ord2.csordtelcoa__Opportunity__c =opp.id;
        ord2.Project_Manager_Email__c='testpmmanager@gmail.com';
        ord2.csord__Primary_Order__c = primaryOrd2.id;
        ords.add(ord2);
        
        insert ords;
        
    // Changes start for EDGE-130265
        Test.stopTest();
    // Changes end for EDGE-130265
    
        cscrm__Address__c address = new cscrm__Address__c();
        address.name = 'LonsdaleUnconfiremed VIC 3001(1010101010)';
        address.Address_ID__c = '1010101010';
        address.cscrm__Account__c = acc.id; 
        upsert address;
        
        cscrm__Site__c site = new cscrm__Site__c();
        site.cscrm__Account__c = acc.id;
        site.cscrm__Installation_Address__c = address.id;
        site.name = 'Sydney harbour house';
        site.Composite_Key__c = '1211010101010';
        upsert site; 
        
        List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
        csord__Subscription__c subs1=new csord__Subscription__c();
        subs1.name  = 'IP SITE';
        subs1.csord__Identification__c = 'test identity';
        subs1.csord__Order__c = ord1.Id;
        subs1.csord__Status__c = 'Provisioning In Progress';
        subs1.Sub_status__c = 'Active';
        subs1.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs1.csordtelcoa__Subscription_Number__c = 'SN-00012345';
        subs1.Site__c = site.Id;
        subs1.Cancellation_Date_of_Effect__c=system.today()+3;
        subs1.csord__Order_Request__c = ordReq.Id;
        //modified for 73057
        subs1.emailSent__c = false;
        subs1.csordtelcoa__Product_Configuration__c = prodConfigMobility.Id;
        subs1.Offer__c =offer.Id;
        subs1.Primary_Order__c = primaryOrd1.Id;
        subList.add(subs1);
        
        csord__Subscription__c subs2=new csord__Subscription__c();
        subs2.name  = 'IP SITE';
        subs2.csord__Identification__c = 'test identity';
        subs2.csord__Order__c = ord2.Id;
        subs2.csord__Status__c = 'Provisioning In Progress';
        subs2.Sub_status__c = 'Active';
        subs2.Cancellation_Date_of_Effect__c=system.today()+3;
        subs2.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294F';
        subs2.csordtelcoa__Subscription_Number__c = 'SN-123456';
        subs2.Site__c = site.Id;
        subs2.csord__Order_Request__c = ordReq2.Id;
        //modified for 73057
        subs2.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        subs2.Offer__c =offer.Id;
        subList.add(subs2);
        
        //EDGE-103485 -- Changes start for TID Email Notify
        csord__Subscription__c subs3=new csord__Subscription__c();
        subs3.name  = 'Internet Site';
        subs3.csord__Identification__c = 'test identity';
        subs3.csord__Order__c = ord1.Id;
        subs3.csord__Status__c = 'Provisioning In Progress';
        subs3.Sub_status__c = 'Active';
        subs3.Cancellation_Date_of_Effect__c=system.today()+3;
        subs3.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294F';
        subs3.csordtelcoa__Subscription_Number__c = 'SN-123456';
        subs3.Site__c = site.Id;
        subs3.csord__Order_Request__c = ordReq2.Id;
        //modified for 73057
        subs3.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        subs3.Offer__c =offer.Id;
        subList.add(subs3);
        //EDGE-103485 -- Changes end for TID Email Notify
        //EDGE-98409 : Start
        csord__Subscription__c subs4=new csord__Subscription__c();
        subs4.name  = 'FairPlay Data - Global';
        subs4.csord__Identification__c = 'test identity';
        subs4.csord__Order__c = ord1.Id;
        subs4.csord__Status__c = 'Inactive';
        subs4.Sub_status__c = 'Inactive';
        subs4.Cancellation_Date_of_Effect__c=system.today()+3;
        subs4.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294F';
        subs4.csordtelcoa__Subscription_Number__c = 'SN-000052234';
        subs4.Site__c = site.Id;
        subs4.emailSent__c=False;
        subs4.serviceMSISDN__c='61419454751';
        subs4.csord__Order_Request__c = ordReq2.Id;
        //modified for 73057
        subs4.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        subs4.Offer__c =offer.Id;
        //subs2.Primary_Order__c = primaryOrd2.Id;
        subList.add(subs4);
        
        // DPG-1753 - IoT Shared Plan - Order confirmation email for new Order 
        csord__Subscription__c subs5=new csord__Subscription__c();
        subs5.name  = 'IoT Shared Plan';
        subs5.csord__Identification__c = 'test identity-1';
        subs5.csord__Order__c = ord1.Id;
        subs5.csord__Status__c = 'Active';
        subs5.csordtelcoa__Subscription_Number__c = 'SN-000052235';
        subs5.serviceMSISDN__c='61419454752';
        subs5.csord__Order_Request__c = ordReq2.Id;
        subs5.csordtelcoa__Product_Configuration__c = prodConfigIOT.Id;
        subs5.Offer__c =offer.Id;
        subList.add(subs5);
        
       //START-- 28/09/2020    DPG- 2735 
        csord__Subscription__c subs10=new csord__Subscription__c();
        subs10.name  = 'IoT Right Plan';
        subs10.csord__Identification__c = 'test identity-2';
        subs10.csord__Order__c = primaryOrd12.Id;
        subs10.csord__Status__c = 'Active';
        subs10.csordtelcoa__Subscription_Number__c = 'SN-000052555';
        subs10.serviceMSISDN__c='61419454999';
        subs10.csord__Order_Request__c = ordReqs[5].Id;
        subs10.csordtelcoa__Product_Configuration__c = prodConfigIOT1.Id;
        subs10.Offer__c =offer.Id;
        subList.add(subs10);
        
        csord__Subscription__c subs11=new csord__Subscription__c();
        subs11.name  = 'IoT Annual Data Plan';
        subs11.csord__Identification__c = 'test identity-3';
        subs11.csord__Order__c = primaryOrd13.Id;
        subs11.csord__Status__c = 'Active';
        subs11.csordtelcoa__Subscription_Number__c = 'SN-000052555';
        subs11.serviceMSISDN__c='61419454999';
        subs11.csord__Order_Request__c = ordReqs[7].Id;
        subs11.csordtelcoa__Product_Configuration__c = prodConfigIOT2.Id;
        subs11.Offer__c =offer.Id;
        subList.add(subs11);
       //END-- 28/09/2020    DPG- 2735 
        
        //EDGE-98409 : End
        insert subList;
        
        List<Contact> contacts=new List<Contact>();
        Contact contact12 = AccountTestFactory.buildContact(acc, 'Timson');
        contact12.FirstName = '';
        contact12.LastName = 'Kumar';
        contact12.Pref_Comm_Method__c='eMail';
        contact12.MobilePhone='+61123456789';
        contact12.Email='sl@gmail.com';
        contact12.AccountId = acc.id;
        contacts.add(contact12);

        Contact cntct1 = new Contact();
        cntct1.FirstName='Test';
        cntct1.LastName = 'Primary';
        cntct1.Phone = '111222';
        cntct1.email='Primary@gmail.com';
        contacts.add(cntct1);
        
        Contact cntct2 = new Contact();
        cntct2.LastName = 'Secondary';
        cntct2.Phone = '22223333';
        cntct2.email='Secondary@gmail.com';
        contacts.add(cntct2);
        Contact cntct3 = new Contact();
        cntct3.LastName = 'Site';
        cntct3.Phone = '33334444';
        cntct3.email='Site@gmail.com';
        contacts.add(cntct3);
        
        Contact cntct4 = new Contact();
        cntct4.LastName = 'billing';
        cntct4.Phone = '33334444';
        cntct4.email='billing@gmail.com';
        contacts.add(cntct4);
        
        Contact cntct5 = new Contact();
        cntct5.LastName = 'Delivery';
        cntct5.Phone = '33334444';
        cntct5.email='Delivery@gmail.com';
        contacts.add(cntct5);
        insert contacts;
        
        List<Functional_Contact_Role__c> fnRoles=new List<Functional_Contact_Role__c>();
        Functional_Contact_Role__c fcRole1 = new Functional_Contact_Role__c();
        Functional_Contact_Role__c fcRole2 = new Functional_Contact_Role__c();
        Functional_Contact_Role__c fcRole3 = new Functional_Contact_Role__c();
        Functional_Contact_Role__c fcRole4 = new Functional_Contact_Role__c();
        Functional_Contact_Role__c fcRole5 = new Functional_Contact_Role__c();
        
        fcRole1.Role__c = 'Primary Site Contact';
        fcRole2.Role__c = 'Technical Contact';
        fcRole3.Role__c = 'Project Contact';
        fcRole4.Role__c = 'Billing Contact';
        fcRole4.Is_Primary__c=true;
        fcRole5.Role__c = 'Delivery Contact';
        
        
        fcRole1.ContactID__c = cntct1.id;
        fcRole2.ContactID__c = cntct2.id;
        fcRole3.ContactID__c = cntct3.id;
        fcRole4.ContactID__c = cntct4.id;
        fcRole5.ContactID__c = cntct5.id;
        
        fcRole1.SiteID__c = site.id;
        fcRole2.SiteID__c = site.id;
        fcRole3.SiteID__c = site.id;
        fcRole4.SiteID__c = site.id;
        fcRole5.SiteID__c = site.id;
        
        fnRoles.add(fcRole1);
        fnRoles.add(fcRole2);
        fnRoles.add(fcRole3);
        fnRoles.add(fcRole4);
        fnRoles.add(fcRole5);
        insert fnRoles;
        List<csord__Service__c> servList=new List<csord__Service__c>();
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='IP Site';
        serv1.Primary_Contact__c = contact.id;
        serv1.csord__Identification__c  = 'test identify';
        serv1.csordtelcoa__Service_Number__c = '3';
        serv1.csord__Subscription__c = subs1.Id;
        serv1.csord__Status__c = 'Service Created';
        serv1.csord__Order_Request__c = ordReq.Id;
        serv1.csord__Order__c = ord1.Id;
        serv1.serviceMSISDN__c='898098098098';
        serv1.Order_Primary_Contact__c = contact.id;
        serv1.BandwidthWeight__c = 30;
        serv1.AccessType__c = 'Test';
        serv1.customer_facing_service_id__c = '123';
        
        servList.add(serv1);
        
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='IP Site';
        serv2.Primary_Contact__c = contact.id;
        serv2.csord__Identification__c  = 'test identify';
        serv2.csordtelcoa__Service_Number__c = '3';
        serv2.csord__Subscription__c = subs2.Id;
        serv2.csord__Status__c = 'Service Created';
        serv2.csord__Order_Request__c = ordReq2.Id;
        serv2.csord__Order__c = ord2.Id;
        serv2.Order_Primary_Contact__c = contact.id;
        servList.add(serv2); 
        
        //EDGE - 87289 Start
        csord__Service__c serv3 = new csord__Service__c();
        serv3.name ='IP Site';
        serv3.Primary_Contact__c = contact1.id;
        serv3.csord__Identification__c  = 'test identify';
        serv3.csordtelcoa__Service_Number__c = '3';
        serv3.csord__Subscription__c = subs1.Id;
        serv3.csord__Status__c = 'Service Created';
        serv3.csord__Order_Request__c = ordReq.Id;
        serv3.csord__Order__c = ord1.Id;
        serv3.serviceMSISDN__c='898098098098';
        serv3.Order_Primary_Contact__c = contact1.id;
        servList.add(serv3);
        
        csord__Service__c serv4 = new csord__Service__c();
        serv4.name ='IP Site';
        serv4.Primary_Contact__c = contact1.id;
        serv4.csord__Identification__c  = 'test identify';
        serv4.csordtelcoa__Service_Number__c = '3';
        serv4.csord__Subscription__c = subs2.Id;
        serv4.csord__Status__c = 'Service Created';
        serv4.csord__Order_Request__c = ordReq2.Id;
        serv4.csord__Order__c = ord2.Id;
        serv4.Order_Primary_Contact__c = contact1.id;
        servList.add(serv4);
        //EDGE-98409 : Start
        csord__Service__c serv6 = new csord__Service__c();
        serv6.name ='FairPlay Data - Global';
        serv6.Primary_Contact__c = contact1.id;
        serv6.csord__Identification__c  = 'test identify';
        serv6.csordtelcoa__Service_Number__c = '3';
        serv6.csord__Subscription__c = subs4.Id;
        serv6.csord__Status__c = 'Service Created';
        serv6.csord__Order_Request__c = ordReq2.Id;
        serv6.csord__Order__c = ord2.Id;
        serv6.Order_Primary_Contact__c = contact1.id;
        servList.add(serv6);
        //EDGE-98409 : End
        
        
        //EDGE-103485 -- Changes start for TID Email Notify
        csord__Service__c serv5 = new csord__Service__c();
        serv5.name ='Internet Site';
        serv5.Primary_Contact__c = contact.id;
        serv5.csord__Identification__c  = 'test identify';
        serv5.csordtelcoa__Service_Number__c = '3';
        serv5.csord__Subscription__c = subs1.Id;
        serv5.csord__Status__c = 'Service Created';
        serv5.csord__Order_Request__c = ordReq5.Id;
        serv5.csord__Order__c = ord3.Id;
        serv5.serviceMSISDN__c='898098098098';
        serv5.Order_Primary_Contact__c = contact.id;
        serv5.BandwidthWeight__c = 30;
        serv5.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        serv5.AccessType__c = 'Test';
        serv5.customer_facing_service_id__c = '123';
        servList.add(serv5);
        
        //START-- 28/09/2020    DPG- 2735 
        csord__Service__c serv7 = new csord__Service__c();
        serv7.name ='Internet Site 12';
        serv7.Primary_Contact__c = contact.id;
        serv7.csord__Identification__c  = 'test identify';
        serv7.csordtelcoa__Service_Number__c = '3';
        serv7.csord__Subscription__c = subs10.Id;
        serv7.csord__Status__c = 'Service Created';
        serv7.csord__Order_Request__c = ordReqs[6].Id;
        serv7.csord__Order__c = primaryOrd12.Id;
        serv7.serviceMSISDN__c='898098098098';
        serv7.Order_Primary_Contact__c = contact.id;
        serv7.BandwidthWeight__c = 30;
        serv7.csordtelcoa__Product_Configuration__c = prodConfigIOT1.Id;
        serv7.AccessType__c = 'Test';
        serv7.customer_facing_service_id__c = '123';
        servList.add(serv7);
        
        
        csord__Service__c serv8 = new csord__Service__c();
        serv8.name ='Internet Site 123';
        serv8.Primary_Contact__c = contact.id;
        serv8.csord__Identification__c  = 'test identify';
        serv8.csordtelcoa__Service_Number__c = '3';
        serv8.csord__Subscription__c = subs11.Id;
        serv8.csord__Status__c = 'Service Created';
        serv8.csord__Order_Request__c = ordReqs[7].Id;
        serv8.csord__Order__c = primaryOrd13.Id;
        serv8.serviceMSISDN__c='898098098098';
        serv8.Order_Primary_Contact__c = contact.id;
        serv8.BandwidthWeight__c = 30;
        serv8.csordtelcoa__Product_Configuration__c = prodConfigIOT2.Id;
        serv8.AccessType__c = 'Test';
        serv8.customer_facing_service_id__c = '123';
        servList.add(serv8);
        insert servList;
        //END-- 28/09/2020    DPG- 2735 

        
        List<cscfga__Attribute__c> attrList=new List<cscfga__Attribute__c>();
        cscfga__Attribute__c attr = new cscfga__Attribute__c();
        attr.cscfga__Product_Configuration__c = prodConfig.Id;
        attr.Name = 'Bandwidth Shadow';
        attr.cscfga__Value__c = '50';
        attrList.add(attr);
        
        cscfga__Attribute__c attr1 = new cscfga__Attribute__c();
        attr1.cscfga__Product_Configuration__c = prodConfig.Id;
        attr1.Name = 'Zone Shadow';
        attr1.cscfga__Value__c = '1';
        attrList.add(attr1);
        
        
        cscfga__Attribute__c attr2 = new cscfga__Attribute__c();
        attr2.cscfga__Product_Configuration__c = prodConfig.Id;
        attr2.Name = 'AccessTechnology';
        attr.cscfga__Value__c = 'Telstra Fibre Access';
        attrList.add(attr2);
        insert attrList;
        
        //EDGE-103485 -- Changes end for TID Email Notify
        
        //EDGE:205667
        Case caseObj = new Case();
        caseObj.Reason = 'Requested by Customer';
        caseObj.Status = 'Closed';
        caseObj.AccountId = acc.id;
        caseObj.ContactId = contact12.id;
        caseObj.Billing_Account__c  = ba.id;
        insert caseObj;

        Subscriptions_to_Case_Association__c sc = new Subscriptions_to_Case_Association__c();
        sc.Case__c = caseObj.id;
        sc.csord_Subscription__c = subList[1].id;
        insert sc;
        
        //EDGE - 87289 End
        APXTConga4__Conga_Email_Template__c templateCIS= new APXTConga4__Conga_Email_Template__c();
        templateCIS.APXTConga4__HTMLBody__c ='HTML Body';
        insert templateCIS;
        templateCIS.APXTConga4__Name__c = Label.CISCommunicationForContract;
        update templateCIS;

        List<ContractJunction__c> contractList = new List<ContractJunction__c>();
        ContractJunction__c contractCRM = new ContractJunction__c(Related_Opportunity__c=opp.id,Account__c=acc.id,Customer_Primary_Contact__c=contact.id,Name='testContract1');
        contractCRM.Related_Basket__c=basket.Id;
        contractCRM.DocuSign_Signer_2__c=cntct1.Id;
        contractList.add(contractCRM);
        
        // //EDGE - 87289 Start     
        ContractJunction__c contractCRM1 = new ContractJunction__c(Related_Opportunity__c=opp.id,Account__c=acc.id,Customer_Primary_Contact__c=contact1.id,Name='testContract11');
        contractCRM1.Related_Basket__c=basket.Id;
        contractCRM1.DocuSign_Signer_2__c=cntct1.Id;
        contractList.add(contractCRM1);
        ////EDGE - 87289 End
        
        
        ContractJunction__c contractPRM = new ContractJunction__c(Related_Opportunity__c=partnerOpp.id,Account__c=acc.id,Customer_Primary_Contact__c=contact.id,Name='testContract2');
        contractList.add(contractPRM);
        if(contractList!=null)
            insert contractList;
    }
    
    
    @isTest public static void emailBodyByTemplateId_CWP_Order_Recd_Test() {
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'In Progress' and Name  = 'PrimaryOrderInProgress' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID, APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'CWP_Order_Received' LIMIT 1];
        SYSTEM.DEBUG('template_1::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email); 
        Test.stopTest();
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
    }
    
    //EDGE-103485 -- Changes start for TID Email Notify
    @isTest public static void emailBodyByTemplateId_TID_Test() {
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'In Progress' and Name  = 'TIDPrimaryOrderInProgress' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID, APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'TID_New_Order_Recvd' LIMIT 1];
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        SYSTEM.DEBUG('template_1::' + template);
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email); 
        Test.stopTest();
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
        
    }
    
    @isTest public static void emailBodyByTemplateId_TIDCancel_Test() {
        csord__Subscription__c sub= [SELECT Id, Name,csord__Subscription__c.csord__Order__c from csord__Subscription__c LIMIT 1];
        Contact orderRequestor = [SELECT Id, FirstName FROM CONTACT LIMIT 1];
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'In Progress' and Name  = 'TIDPrimaryOrderInProgress' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c templateCancel = [SELECT ID, APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'TID_Cancel_Order_Completed' LIMIT 1];
        String templateIdCancel = templateCancel.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateIdCancel, sub.id,email); 
        SYSTEM.DEBUG('template_1::' + templateCancel);
        Test.stopTest();
        System.assertNotEquals(templateCancel.APXTConga4__HTMLBody__c,Null);
        
    }
    //EDGE-103485 -- Changes end for TID Email Notify
    
    //EDGE-103485 -- Changes start for TID Email Notify Negative Scenario
    @isTest public static void emailBodyByTemplateId_TID_Neg_Test() {
        csord__Subscription__c sub= [SELECT Id, Name,csord__Subscription__c.csord__Order__c from csord__Subscription__c LIMIT 1];
        Contact orderRequestor = [SELECT Id, FirstName FROM CONTACT LIMIT 1];
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'In Progress' and Name  = 'TIDPrimaryOrderInProgress' LIMIT 1];
        List<String> email = new  List<String>();
        //email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID, APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'TID_New_Order_Completed' LIMIT 1];
        //List<csord__Service__c> service=[select Id,name,BandwidthWeight__c,AccessType__c,csord__Subscription__r.Site__r.name,customer_facing_service_id__c from csord__Service__c LIMIT 1];
        SYSTEM.DEBUG('template_1::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, sub.id,email); 
        Test.stopTest();
        System.assertEquals(template.APXTConga4__HTMLBody__c,Null);
        
    }
    //EDGE-103485 -- Changes end for TID Email Notify
    
    //EDGE-98409 :Start

    @isTest public static void emailBodyByTemplateId_CMPCancel_Test() {
        Test.startTest();
        csord__Subscription__c sub= [SELECT Id, Name,csord__Subscription__c.csord__Order__c from csord__Subscription__c LIMIT 1];
        Contact orderRequestor = [SELECT Id, FirstName FROM CONTACT LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template4 = [SELECT ID,APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'CMPOfferCancellation' LIMIT 1];
        String templateId = template4.APXTConga4__Name__c;
        EmailUtils.emailBodyByTemplateId(templateId,sub.id,email); 
        Test.stopTest();
        System.assertNotEquals(template4.APXTConga4__HTMLBody__c,Null);
    }
    
    
    
    @isTest public static void emailBodyByTemplateId_CMP_Neg_Test() {
        Test.startTest();
        csord__Subscription__c sub= [SELECT Id, Name,csord__Subscription__c.csord__Order__c from csord__Subscription__c where Name = 'FairPlay Data - Global' LIMIT 1];
        Contact orderRequestor = [SELECT Id, FirstName FROM CONTACT LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template4 = [SELECT ID,APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'CMPOfferCancellation' LIMIT 1];
        String templateId = template4.APXTConga4__Name__c;
        EmailUtils.emailBodyByTemplateId(templateId,sub.id,email); 
        Test.stopTest();
        System.assertNotEquals(template4.APXTConga4__HTMLBody__c,Null);
    }
    //EDGE-98409 : End
    
    
    
    @isTest public static void emailBodyByTemplateId_CWP_Order_Completed_Test() {
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'Complete' and Name  = 'PrimaryOrderComplete' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID,APXTConga4__Name__c,APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Order_Completed' LIMIT 1];
        SYSTEM.DEBUG('template_2::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email);
        Test.stopTest();
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
    }
    @isTest public static void emailBodyByTemplateId_CWP_Srvc_Req_Test() {
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'Complete' and Name  = 'PrimaryOrderComplete' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID,APXTConga4__Name__c,APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = '9. Customer Email template - CWP - service request order complete' LIMIT 1];
        SYSTEM.DEBUG('template_3::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email); 
        Test.stopTest();
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
    }
    
    @isTest public static void emailBodyByTemplateId_CWP_Ready_To_Bill_Test() {
        csord__Subscription__c sub= [SELECT Id, Name from csord__Subscription__c where Name = 'IP SITE' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template4 = [SELECT ID,APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'CWP_Individual_Location_Complete_Ready_To_Bill' LIMIT 1];

        SYSTEM.DEBUG('template_4::' + template4);
        String templateId = template4.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId,sub.id,email); 
        Test.stopTest();
        System.assertNotEquals(template4.APXTConga4__HTMLBody__c,Null); 
    }
    
    @isTest public static void emailBodyByTemplateId_Mobility_Recvd_Test() {
         csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'Complete' and Name  = 'PrimaryOrderComplete' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID,APXTConga4__Name__c,APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Mobility_Order_Received' LIMIT 1];
        SYSTEM.DEBUG('template_2::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email); 
        Test.stopTest();
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
    }
    
    @isTest public static void emailBodyByTemplateId_Mobility_Future_Test() {
         csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'Complete' and Name  = 'PrimaryOrderComplete' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID,APXTConga4__Name__c,APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'Mobility_Future_Date_Cancellation' LIMIT 1];
        SYSTEM.DEBUG('template_2::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email); 
        Test.stopTest();
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
    }

    @isTest public static void emailBodyByTemplateId_NGUC_Test() {
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'Complete' and Name  = 'PrimaryOrderComplete' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID,APXTConga4__Name__c,APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'ngUCSignupCommunicationTemplate' LIMIT 1];
        SYSTEM.DEBUG('template_2::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email); 
        Test.stopTest();
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
    }
     // added for DPG 668
     // DPG-1753 - IoT Shared Plan - Order confirmation email for new Order 
     @isTest public static void emailBodyByTemplateId_IOT_Test() {
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'Complete' and Name  = 'PrimaryOrderComplete' LIMIT 1];
        csord__Subscription__c sub= [SELECT Id, Name, csordtelcoa__Product_Configuration__r.Name from csord__Subscription__c where Name = 'IoT Shared Plan' LIMIT 1];

        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID,APXTConga4__Name__c,APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'IoT_Order_Received' LIMIT 1];
        SYSTEM.DEBUG('template_2::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email); 
        Test.stopTest();
        System.assertEquals(sub.csordtelcoa__Product_Configuration__r.Name, 'IoT Shared Plan');
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
    }
    
     //START-- 28/09/2020    DPG- 2735 
     @isTest public static void emailBodyByTemplateId_IOTRight_Test() {
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'In Progress' and  Name  = 'PrimaryOrderComplete12' LIMIT 1];
        csord__Subscription__c sub= [SELECT Id, Name, csordtelcoa__Product_Configuration__r.Name from csord__Subscription__c where Name = 'IoT Right Plan' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID,APXTConga4__Name__c,APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'IoT_Order_Received' LIMIT 1];
        SYSTEM.DEBUG('template_2::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email); 
        Test.stopTest();
        System.assertEquals(sub.csordtelcoa__Product_Configuration__r.Name, 'IoT Right Plan');
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
     }
    
     @isTest public static void emailBodyByTemplateId_IOTAnnual_Test() {
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'In Progress' and  Name  = 'PrimaryOrderComplete123' LIMIT 1];
        csord__Subscription__c sub= [SELECT Id, Name, csordtelcoa__Product_Configuration__r.Name from csord__Subscription__c where Name = 'IoT Annual Data Plan' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID,APXTConga4__Name__c,APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'IoT_Order_Received' LIMIT 1];
        SYSTEM.DEBUG('template_2::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email); 
        Test.stopTest();
        System.assertEquals(sub.csordtelcoa__Product_Configuration__r.Name, 'IoT Annual Data Plan');
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
     }
    //END-- 28/09/2020    DPG- 2735 

    @isTest public static void emailBodyByTemplateId_NGUC_Signup_Test() {
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'Complete' and Name  = 'PrimaryOrderComplete' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID,APXTConga4__Name__c,APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'ngUCSignupCommunicationTemplate' LIMIT 1];
        SYSTEM.DEBUG('template_2::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email); 
        Test.stopTest();
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
    }
    
    @isTest public static void emailBodyByTemplateId_Single_Multiple_offer_Test() {
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'Complete' and Name  = 'PrimaryOrderComplete' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID,APXTConga4__Name__c,APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'CUSTOMER_ORDER_SINGLE_AND_MULTIPLE_OFFER' LIMIT 1];
        SYSTEM.DEBUG('template_2::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email); 
        Test.stopTest();
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
    }
    
     @isTest public static void emailBodyByTemplateId_Offer_Cancel_Test() {
         Test.startTest();
        csord__Subscription__c sub= [SELECT Id, Name,csord__Subscription__c.csord__Order__c from csord__Subscription__c where Name = 'IP SITE' LIMIT 1];
        Contact orderRequestor = [SELECT Id, FirstName FROM CONTACT LIMIT 1];
      //  List<csord__Service__c> services=[select Id,name,serviceMSISDN__c from csord__Service__c LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template4 = [SELECT ID,APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'OfferCancellation' LIMIT 1];

        String templateId = template4.APXTConga4__Name__c;
        
        EmailUtils.emailBodyByTemplateId(templateId,sub.id,email); 
        Test.stopTest();
        System.assertNotEquals(template4.APXTConga4__HTMLBody__c,Null); 
    }
    
    @isTest public static void emailBodyByTemplateId_Multiple_Offer_Test() {
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'Complete' and Name  = 'PrimaryOrderComplete' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID,APXTConga4__Name__c,APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'CUSTOMER_ORDER_SINGLE_AND_MULTIPLE_OFFER' LIMIT 1];
        SYSTEM.DEBUG('template_2::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email); 
        Test.stopTest();
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
    }
    
    
    
    @isTest public static void emailBodyByTemplateId_Cancel_Test() {
         Test.startTest();
        csord__Subscription__c sub= [SELECT Id, Name,csord__Subscription__c.csord__Order__c from csord__Subscription__c where Name = 'IP SITE' LIMIT 1];
        Contact orderRequestor = [SELECT Id, FirstName FROM CONTACT LIMIT 1];
        //  List<csord__Service__c> services=[select Id,name,serviceMSISDN__c from csord__Service__c LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
       
        APXTConga4__Conga_Email_Template__c template4 = [SELECT ID,APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'OfferCancellation' LIMIT 1];
        
        String templateId = template4.APXTConga4__Name__c;
        
        EmailUtils.emailBodyByTemplateId(templateId,sub.id,email); 
        Test.stopTest();
        System.assertNotEquals(template4.APXTConga4__HTMLBody__c,Null); 
    }
    
    //EDGE-154675
     @isTest public static void emailBodyByTemplateId_NGEM_Test() {
        csord__Order__c ord= [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Status2__c = 'Complete' and Name  = 'PrimaryOrderComplete' LIMIT 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c template = [SELECT ID,APXTConga4__Name__c,APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = 'EnterprizeMobility(NGEM)_Order_Received' LIMIT 1];
        SYSTEM.DEBUG('template_2::' + template);
        String templateId = template.APXTConga4__Name__c;
        Test.startTest();
        EmailUtils.emailBodyByTemplateId(templateId, ord.id,email); 
        Test.stopTest();
        System.assertNotEquals(template.APXTConga4__HTMLBody__c,Null);
    }
    
    
    @isTest public static void emailBodyByTemplateId_CIS_Email_Body_Test() {
        ContractJunction__c contract= [SELECT Id,name,Related_Opportunity__c,Account__c,Customer_Primary_Contact__c from contractjunction__c where Name=:'testContract1' limit 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c templateCIS = [SELECT ID,APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c =: Label.CISCommunicationForContract LIMIT 1];
        String templateId = '',emailBody='';
        if(templateCIS!=null)
            templateId = templateCIS.APXTConga4__Name__c;
        if(contract!=null ){
            Test.startTest();
            emailBody=EmailUtils.cisEmailBodyByTemplateId(templateId, contract.id,email);
            Test.stopTest();
        }
             
        System.assertEquals(String.isBlank(emailBody),false); 
    }
    //EDGE - 87289 Start
    @isTest public static void emailBodyByTemplateId_CIS_Email_Body_Contact_Test() {
        ContractJunction__c contract= [SELECT Id,name,Related_Opportunity__c,Account__c,Customer_Primary_Contact__c from contractjunction__c where Name=:'testContract11' limit 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c templateCIS = [SELECT ID,APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c =: Label.CISCommunicationForContract LIMIT 1];
        String templateId = '',emailBody='';
        if(templateCIS!=null)
            templateId = templateCIS.APXTConga4__Name__c;
        if(contract!=null ){
            Test.startTest();
            emailBody=EmailUtils.cisEmailBodyByTemplateId(templateId, contract.id,email);
            Test.stopTest();
        }
             
        System.assertEquals(String.isBlank(emailBody),false); 
    }
    ////EDGE - 87289 End
    @isTest public static void emailBodyByTemplateId_CIS_Email_Body_Contact_Fail() {
        ContractJunction__c contract= [SELECT Id,name,Related_Opportunity__c,Account__c,Customer_Primary_Contact__c from contractjunction__c where Name=:'testContract2' limit 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c templateCIS = [SELECT ID,APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c =: Label.CISCommunicationForContract LIMIT 1];
        String templateId = '',emailBody='';
        if(templateCIS!=null)
            templateId = templateCIS.APXTConga4__Name__c;
        if(contract!=null ){
            Test.startTest();
            emailBody=EmailUtils.cisEmailBodyByTemplateId(templateId, contract.id,email);
            Test.stopTest();
        }
             
        System.assertEquals(String.isBlank(emailBody),false); 
    }
     ////Edge-141343
    @isTest public static void emailBodyByTemplateId_NGUC_New() {
        ContractJunction__c contract= [SELECT Id,name,Related_Opportunity__c,Account__c,Customer_Primary_Contact__c from contractjunction__c where Name=:'testContract2' limit 1];
        List<String> email = new  List<String>();
        email.add('firstname@lastname.com');
        APXTConga4__Conga_Email_Template__c templateCIS = [SELECT ID,APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c =: 'ngUC_Order_Recvd' LIMIT 1];
        String templateId = '',emailBody='';
        if(templateCIS!=null)
            templateId = templateCIS.APXTConga4__Name__c;
        if(contract!=null ){
            Test.startTest();
            emailBody=EmailUtils.cisEmailBodyByTemplateId(templateId, contract.id,email);
            Test.stopTest();
        }
             
        System.assertEquals(String.isBlank(emailBody),false); 
    }
    
    @future
    public static void createTestUser( Id profID, String fName, String lName) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                                lastName = lName,
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey='UTF-8',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                Phone = '234434344343',
                                ProfileId = profId
                                );
        insert tuser;
        
    }
    
   /*
   *@CreatedBy : Kamleh Kumar
   *@CreatedDate : 13/4/2021
   *@Breif : 205667 Testing updateCoBaMergeField method
   */
   static testMethod void updateCoBaMergeFieldTest(){
        Test.starttest();
        Utility_Settings__c tu=new Utility_Settings__c (Template_Name__c = 'CoBA Case Completion');
        insert tu;
        APXTConga4__Conga_Email_Template__c testCongaNew4 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew4.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew4.APXTConga4__Name__c = 'CoBA Case Completion';
        testCongaNew4.APXTConga4__Subject__c = 'This is testing : [CoBASubject]';
        insert testCongaNew4;
         List<Case> caseObjList = [SELECT id, Status FROM case WHERE Status = 'Closed'];
         EmailUtils.emailBodyByTemplateId('CoBA Case Completion', caseObjList[0].id,new List<String>()); 
         System.assertEquals('Closed', caseObjList[0].Status);
        test.stoptest();
    }
}