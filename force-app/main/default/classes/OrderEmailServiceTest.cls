/**
* Author     : Kunal Dixit
* Description: Test class for OrderEmailService class
* Class Name : EmailUtilsTest
============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Vijayalakshmi         27/11/2019    EDGE-103485 Changes to handle TID email notify
2.            Vijayalakshmi         12/12/2019    EDGE-127861 Changes to handle cancel scenario for ngUC
3.            Jayesh                23/04/2020    DPG-1415 Confirmation of canceled services
4.            Prajakta              11/08/2020    EDGE-154675
5.            Jayesh/Aruna          29/09/2020    DPG-2447 Comment Changes for DPG-1415
6. 		      Purushottam			02/02/2020    EDGE-171620
****************************************************************************************************************************
//Defect fix EDGE-117267 - Aniket Srivastava - 25/11/2019
*/

@isTest
public class OrderEmailServiceTest {
    
    @Testsetup
    static void dataSetup(){ // setup
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Account_Status__c='Active';
        acc.Customer_Status__c  = 'Active';
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.name='opp1';
        opp.StageName='Closed Won';
        opp.CloseDate=Date.newInstance(2016, 12, 9);
        opp.AccountId = acc.id;
        insert opp;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Synchronised_With_Opportunity__c = true;
        basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        insert basket;
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        contact.FirstName = 'Reena';
        contact.Pref_Comm_Method__c='eMail';
        contact.MobilePhone='+61123456789';
        contact.email='k@gmail.com';
        contact.AccountId = acc.id;
        insert contact;
        
        Billing_Account__c ba=new Billing_Account__c();
        ba.Billing_Account_Name__c='Test Billing Account';
        ba.Billing_Account_Number__c='123456789123';
        ba.Account__c=acc.Id;
        ba.Billing_Account_Owner__c=contact.Id;
        insert ba;
        
        //EDGE - 117267 Start
        List<Marketable_Offer__c> marketableOffers = new List<Marketable_Offer__c>();
        Marketable_Offer__c marketableOfferngUC = new Marketable_Offer__c();
        marketableOfferngUC.Name = 'Telstra Collaboration';
        marketableOfferngUC.Offer_ID__c = 'DMCAT_Offer_000618';
        marketableOfferngUC.OfferDefinationName__c = 'Telstra Collaboration Solution';
        system.debug('marketableOfferngUC:::' + marketableOfferngUC);
        marketableOffers.add(marketableOfferngUC);
        
        
        //DPG-1415 START
        Marketable_Offer__c marketableOfferIoT = new Marketable_Offer__c();
        marketableOfferIoT.Name = 'IoT Connectivity';
        marketableOfferIoT.Offer_ID__c = 'DMCAT_Offer_000964';
        marketableOfferIoT.OfferDefinationName__c = 'IoT solutions';
        system.debug('marketableOfferIoT:::' + marketableOfferIoT);
        marketableOffers.add(marketableOfferIoT);
        
        //DPG-1415 END
        
        //EDGE - 103485 Start
        Marketable_Offer__c marketableOfferTID = new Marketable_Offer__c();
        marketableOfferTID.Name = 'Telstra Internet Direct';
        marketableOfferTID.Offer_ID__c = 'DMCAT_Offer_000709';
        marketableOfferTID.OfferDefinationName__c = '';
        system.debug('marketableOfferTID:::' + marketableOfferTID);
        marketableOffers.add(marketableOfferTID);
        //EDGE - 103485 End
        
         //EDGE-100920 Start
        Marketable_Offer__c marketableOfferTCPS = new Marketable_Offer__c();
        marketableOfferTCPS.Name = 'Telstra Collaboration Professional Services';
        marketableOfferTCPS.Offer_ID__c = 'DMCAT_Offer_000936';
        marketableOfferTCPS.OfferDefinationName__c = 'Telstra Collaboration Professional Services Solution';
       system.debug('marketableOfferTCPS:::' + marketableOfferTCPS);
       marketableOffers.add(marketableOfferTCPS);
       insert marketableOffers;
    //EDGE-100920 End   
    
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId=contact.id;
        ocr.OpportunityId=opp.id;
        ocr.IsPrimary=true;
        ocr.ROLE = 'Decision Maker';
        insert ocr;
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
        /** EDGE-100899*/
        csord__Order_Request__c ordReq5 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq5);
        //EDGE - 117267 Start
        csord__Order_Request__c ordReq6 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq6);
        //EDGE - 117267 End
        //EDGE - 103485 Start
        csord__Order_Request__c ordReq7 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq7);
        //EDGE - 103485 End
        //EDGE-127861 Start
        csord__Order_Request__c ordReq8 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq8);
        //EDGE-127861 End
        //EDGE-100920 Start
        csord__Order_Request__c ordReq10 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq10);
        //EDGE-100920 End
        //DPG-1415 START
        csord__Order_Request__c ordReq11 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq11);
        //DPG-1415 END
        //DPG-1415 START
        csord__Order_Request__c ordReq12 = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq12);
        //DPG-1415 END
        insert ordReqs;
        //73057
        
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('TestProduct', 'TestPlan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000304';
        //insert prodDef;
        
        cscfga__Product_Definition__c prodDefMobility = ProductTestFactory.buildProductDefinition('TestProduct', 'TestPlan');
        prodDefMobility.product_Specification__c = 'DMCAT_ProductOffering_000419';
        //insert prodDefMobility;
        /** EDGE-100899*/
        cscfga__Product_Definition__c prodDef1 = ProductTestFactory.buildProductDefinition('EDGE-100899', 'EDGE-100899');
        prodDef1.product_Specification__c = 'DMCAT_ProductOffering_000420';
        //insert prodDef1;

        cscfga__Product_Definition__c prodDefTCPS = ProductTestFactory.buildProductDefinition('EDGE-100920', 'EDGE-100920');
        prodDefTCPS.product_Specification__c = 'DMCAT_Offer_000936';
        //insert prodDefTCPS;

        //EDGE-117267 Start
        cscfga__Product_Definition__c prodDefngUC = ProductTestFactory.buildProductDefinition('EDGE-117267', 'EDGE-117267');
        prodDefngUC.product_Specification__c = 'DMCAT_Offer_000618';
        //insert prodDefngUC;

        //EDGE-103485 Start
        cscfga__Product_Definition__c prodDefTID = ProductTestFactory.buildProductDefinition('EDGE-103485', 'EDGE-103485');
        prodDefTID.product_Specification__c = 'DMCAT_Offer_000709';
        //insert prodDefTID;

         //DPG-1415 START
        cscfga__Product_Definition__c prodDefIoT = ProductTestFactory.buildProductDefinition('DPG-1415', 'DPG-1415');
        prodDefIoT.product_Specification__c = 'DMCAT_Offer_000964';
        //insert prodDefIoT;
        insert new List<cscfga__Product_Definition__c>{prodDef,prodDefMobility,prodDef1,prodDefTCPS,prodDefngUC,prodDefTID,prodDefIoT};
        
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        //insert prodConfig;
        /** EDGE-100899*/
        
        //EDGE-100920 Start
        
        cscfga__Product_Configuration__c prodConfigTCPS = ProductTestFactory.buildProductConfig(prodDefTCPS.Id);
        prodConfigTCPS.Type__c = 'New';
        //insert prodConfigTCPS;
        //EDGE-100920 End
        
        
        
        cscfga__Product_Configuration__c prodConfigngUC = ProductTestFactory.buildProductConfig(prodDefngUC.Id);
        prodConfigngUC.Type__c = 'New';
        //insert prodConfigngUC;
        //EDGE-117267 End

       
        
        cscfga__Product_Configuration__c prodConfigIoT = ProductTestFactory.buildProductConfig(prodDefIoT.Id);
        prodConfigIoT.Type__c = 'New';
        //insert prodConfigIoT;
        
        cscfga__Product_Configuration__c prodConfigIoTCancel = ProductTestFactory.buildProductConfig(prodDefIoT.Id);
        prodConfigIoTCancel.Type__c = 'Cancel';
        //insert prodConfigIoTCancel;

        //DPG-1415 END
        
        //Changes for EDGE-127861
        cscfga__Product_Configuration__c prodConfigngUC_cancel = ProductTestFactory.buildProductConfig(prodDefngUC.Id);
        prodConfigngUC_cancel.Type__c = 'Cancel';
        //insert prodConfigngUC_cancel;
        //Changes for EDGE-127861
        
        
        
        cscfga__Product_Configuration__c prodConfigTID = ProductTestFactory.buildProductConfig(prodDefTID.Id);
        prodConfigTID.Type__c = 'New';
        //insert prodConfigTID;
        //EDGE-103485 End
        
        cscfga__Product_Configuration__c prodConfig1 = ProductTestFactory.buildProductConfig(prodDef1.Id);
        prodConfig1.Type__c = 'New';
        //insert prodConfig1;
        
        cscfga__Product_Configuration__c prodConfigModify = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfigModify.Type__c='Modify';
        //insert prodConfigModify;
        
        cscfga__Product_Configuration__c prodConfigMobility = ProductTestFactory.buildProductConfig(prodDefMobility.Id);
        //insert prodConfigMobility;

        insert new List<cscfga__Product_Configuration__c>{prodConfig,prodConfigTCPS,prodConfigngUC,prodConfigIoT,prodConfigIoTCancel,prodConfigngUC_cancel,prodConfigTID,prodConfig1,prodConfigModify,prodConfigMobility};
        
        List<cscfga__Configuration_Offer__c> offerList = new List<cscfga__Configuration_Offer__c>();
        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.Offer_Spec_Id__c = 'DMCAT_Offer_000303';
        offerList.add(offer);
        cscfga__Configuration_Offer__c offer1 = new cscfga__Configuration_Offer__c();
        offer1.Offer_Spec_Id__c = 'DMCAT_Offer_000646';
        offerList.add(offer1);
        //EDGE - 117267
        cscfga__Configuration_Offer__c offer2 = new cscfga__Configuration_Offer__c();
        offer2.Offer_Spec_Id__c = 'DMCAT_Offer_000618';
        offerList.add(offer2);
        //EDGE - 117267
        //EDGE - 117267
        cscfga__Configuration_Offer__c offer3 = new cscfga__Configuration_Offer__c();
        offer3.Offer_Spec_Id__c = 'DMCAT_Offer_000709';
        offerList.add(offer3);
        //EDGE - 117267
        //EDGE-100920 Start
        cscfga__Configuration_Offer__c offer4 = new cscfga__Configuration_Offer__c();
        offer4.Offer_Spec_Id__c = 'DMCAT_Offer_000936';
        offerList.add(offer4);      
        //EDGE-100920 End
        //DPG-1415 START
        cscfga__Configuration_Offer__c offer5 = new cscfga__Configuration_Offer__c();
        offer5.Offer_Spec_Id__c = 'DMCAT_Offer_000964';
        offerList.add(offer5);
        //DPG-1415 END
        insert offerList;
        
        //73057
        //Modified
        List<APXTConga4__Conga_Email_Template__c> templates=new List<APXTConga4__Conga_Email_Template__c>();
        APXTConga4__Conga_Email_Template__c congaTemplate =new APXTConga4__Conga_Email_Template__c();
        congaTemplate.APXTConga4__HTMLBody__c = 'test conga';
        //congaTemplate.Name = 'CET-00024';
        congaTemplate.APXTConga4__Name__c = 'Order_Completion_Template';
        templates.add(congaTemplate);
        //Added
        APXTConga4__Conga_Email_Template__c congaTemplate1 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate1.APXTConga4__HTMLBody__c = 'test conga';
        //congaTemplate1.Name = 'CET-00027';
        congaTemplate1.APXTConga4__Name__c = 'Modify Order Completion Template';
        templates.add(congaTemplate1);
        
        APXTConga4__Conga_Email_Template__c congaTemplate2 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate2.APXTConga4__HTMLBody__c = 'test conga';
        //congaTemplate2.Name = 'CET-00028';
        congaTemplate2.APXTConga4__Name__c = 'Add/Change CWP Services Template';
        templates.add(congaTemplate2);
        
        APXTConga4__Conga_Email_Template__c congaTemplate3 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate3.APXTConga4__HTMLBody__c = 'test conga';
        //congaTemplate3.Name = 'CET-00025';
        congaTemplate3.APXTConga4__Name__c = 'Order acknowledgement email';
        templates.add(congaTemplate3);
        
        //EDGE - 117267
        APXTConga4__Conga_Email_Template__c congaTemplate4 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate4.APXTConga4__HTMLBody__c = 'test conga';
        congaTemplate4.APXTConga4__Name__c = 'ngUC_Order_Recvd';
        templates.add(congaTemplate4);
        //EDGE - 117267

        //DPG-1415 START
        APXTConga4__Conga_Email_Template__c congaTemplate55 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate55.APXTConga4__HTMLBody__c = 'test IoT_Order_Received';
        congaTemplate55.APXTConga4__Name__c = 'IoT_Order_Received';
        templates.add(congaTemplate55);
        //DPG-1415 END
        
        //DPG-1415 START
        APXTConga4__Conga_Email_Template__c congaTemplate66 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate66.APXTConga4__HTMLBody__c = 'test IoT_Cancel_Order_Complete';
        congaTemplate66.APXTConga4__Name__c = 'IoT_Cancel_Order_Complete';
        templates.add(congaTemplate66);
        //DPG-1415 END

        
        //EDGE - 103485
        APXTConga4__Conga_Email_Template__c congaTemplate6 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate6.APXTConga4__HTMLBody__c = 'test conga';
        congaTemplate6.APXTConga4__Name__c = 'TID_New_Order_Recvd';
        templates.add(congaTemplate6);
        
        APXTConga4__Conga_Email_Template__c congaTemplate7 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate7.APXTConga4__HTMLBody__c = 'test conga';
        congaTemplate7.APXTConga4__Name__c = 'TID_New_Order_Completed';
        templates.add(congaTemplate7);
        
        APXTConga4__Conga_Email_Template__c congaTemplate8 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate8.APXTConga4__HTMLBody__c = 'test conga';
        congaTemplate8.APXTConga4__Name__c = 'TID_Modify_Order_Recvd';
        templates.add(congaTemplate8);
        
        APXTConga4__Conga_Email_Template__c congaTemplate9 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate9.APXTConga4__HTMLBody__c = 'test conga';
        congaTemplate9.APXTConga4__Name__c = 'TID_Modify_Order_Completed';
        templates.add(congaTemplate9);
        
        APXTConga4__Conga_Email_Template__c congaTemplate10 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate10.APXTConga4__HTMLBody__c = 'test conga';
        congaTemplate10.APXTConga4__Name__c = 'TID_Cancel_Order_Completed';
        templates.add(congaTemplate10);
        
        APXTConga4__Conga_Email_Template__c congaTemplate11 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate11.APXTConga4__HTMLBody__c = 'test conga';
        congaTemplate11.APXTConga4__Name__c = 'ngUC_Order_Recvd';
        templates.add(congaTemplate11);
        
        
        //EDGE - 103485

        
        
        //------------------------------------------
        /** EDGE-100899*/
        APXTConga4__Conga_Email_Template__c congaTemplate5 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate5.APXTConga4__Is_Body_Attachment__c = false;
        congaTemplate5.APXTConga4__Name__c = 'CUSTOMER_ORDER_SINGLE_AND_MULTIPLE_OFFER';
        congaTemplate5.APXTConga4__Subject__c = 'Your Telstra order';
        congaTemplate5.APXTConga4__Template_Group__c = 'Munich Templates';
        congaTemplate5.APXTConga4__HTMLBody__c = '{order_number} {offerdetails} {appointment_details}';
        templates.add(congaTemplate5);
        
        APXTConga4__Conga_Email_Template__c testCongaNew1 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew1.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew1.APXTConga4__Name__c = 'CWP_Order_Received';
        templates.add(testCongaNew1);
        
        APXTConga4__Conga_Email_Template__c testCongaNew2 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew2.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew2.APXTConga4__Name__c = 'Mobility_Future_Date_Cancellation';
        templates.add(testCongaNew2);
        
        APXTConga4__Conga_Email_Template__c testCongaNew3 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew3.APXTConga4__HTMLBody__c = 'test congaNew1';
        testCongaNew3.APXTConga4__Name__c = 'Mobility_Cancellation';
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
        testCongaNew6.APXTConga4__Name__c = 'CWP_Service_Request_Order_Complete';
        templates.add(testCongaNew6);
        
        //EDGE-154675
        APXTConga4__Conga_Email_Template__c testCongaNew7 =new APXTConga4__Conga_Email_Template__c();
        testCongaNew7.APXTConga4__HTMLBody__c = 'test conga Body';
        testCongaNew7.APXTConga4__Name__c = '   EnterprizeMobility(NGEM)_Order_Received';
        templates.add(testCongaNew7);

        //EDGE-184269
        APXTConga4__Conga_Email_Template__c congaTemplate88 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate88.APXTConga4__HTMLBody__c = 'test TID_New_Order_Recvd';
        congaTemplate88.APXTConga4__Name__c = 'TID_New_Order_Recvd';
        templates.add(congaTemplate88);
        
        //EDGE-184269
        APXTConga4__Conga_Email_Template__c congaTemplate99 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate99.APXTConga4__HTMLBody__c = 'test TID_New_Order_Completed';
        congaTemplate99.APXTConga4__Name__c = 'TID_New_Order_Completed';
        templates.add(congaTemplate99);
        
        
        insert templates;
        
        //End
        List<Customer_Notify_Metadata__c> custNotifyList=new List<Customer_Notify_Metadata__c>();
        Customer_Notify_Metadata__c custNotify = new Customer_Notify_Metadata__c();
        custNotify.productDefinitionCode__c ='DMCAT_ProductOffering_000304,DMCAT_ProductOffering_000419';
        custNotify.offerID__c = 'DMCAT_Offer_000303';
        custNotify.monitorObjectStatus__c = 'Complete';
        custNotify.scenarioType__c='';
        custNotify.monitorObject__c='Order';
        custNotify.orderType__c='New';
        custNotify.emailTemplate__c = congaTemplate7.id;
        custNotifyList.add(custNotify);
        
        Customer_Notify_Metadata__c custNotify1 = new Customer_Notify_Metadata__c();
        custNotify1.productDefinitionCode__c ='DMCAT_ProductOffering_000304,DMCAT_ProductOffering_000419';
        custNotify1.offerID__c = 'DMCAT_Offer_000303';
        custNotify1.monitorObjectStatus__c = 'In Progress';
        custNotify1.scenarioType__c='';
        custNotify1.monitorObject__c='Order';
        custNotify1.orderType__c='New';
        custNotify1.emailTemplate__c = congaTemplate9.id;
        custNotifyList.add(custNotify1);
        
        Customer_Notify_Metadata__c custNotify2 = new Customer_Notify_Metadata__c();
        custNotify2.productDefinitionCode__c ='DMCAT_ProductOffering_000419';
        custNotify2.offerID__c = 'DMCAT_Offer_000303';
        custNotify2.monitorObjectStatus__c = 'In Progress';
        custNotify2.scenarioType__c='';
        custNotify2.monitorObject__c='Order';
        custNotify2.orderType__c='New';
        custNotify2.emailTemplate__c = congaTemplate10.id;
        custNotifyList.add(custNotify2);
        
        Customer_Notify_Metadata__c custNotify3 = new Customer_Notify_Metadata__c();
        custNotify3.productDefinitionCode__c ='DMCAT_ProductOffering_000304,DMCAT_ProductOffering_000419';
        custNotify3.offerID__c = 'DMCAT_Offer_000303';
        custNotify3.monitorObjectStatus__c = 'Complete';
        custNotify3.scenarioType__c='';
        custNotify3.monitorObject__c='Order';
        custNotify3.orderType__c='Modify';
        custNotify3.emailTemplate__c = testCongaNew6.id;
        custNotifyList.add(custNotify3);
        /** EDGE-100899*/
        Customer_Notify_Metadata__c customerNotifyMetadata = new Customer_Notify_Metadata__c();
        customerNotifyMetadata.emailTemplate__c = congaTemplate5.Id;
        customerNotifyMetadata.monitorObjectStatus__c = 'In Progress';
        customerNotifyMetadata.monitorObject__c = 'Order';
        customerNotifyMetadata.offerID__c = 'DMCAT_Offer_000646';
        customerNotifyMetadata.offerName__c = 'Corporate Mobile Plus';
        customerNotifyMetadata.orderType__c = 'New';
        customerNotifyMetadata.productDefinitionCode__c = 'DMCAT_ProductOffering_000420';
        custNotifyList.add(customerNotifyMetadata);
        
        //EDGE - 117267
        Customer_Notify_Metadata__c custNotifyngUC = new Customer_Notify_Metadata__c();
        custNotifyngUC.productDefinitionCode__c ='DMCAT_Offer_000618';
        custNotifyngUC.offerID__c = 'DMCAT_Offer_000618';
        custNotifyngUC.monitorObjectStatus__c = 'In Progress';
        custNotifyngUC.scenarioType__c='';
        custNotifyngUC.monitorObject__c='Order';
        custNotifyngUC.orderType__c='New';
        custNotifyngUC.emailTemplate__c = congaTemplate4.id;
        
        custNotifyList.add(custNotifyngUC);
        //EDGE - 117267
        
        //DPG-1415 START
        Customer_Notify_Metadata__c custNotifyIoT = new Customer_Notify_Metadata__c();
        custNotifyIoT.productDefinitionCode__c ='DMCAT_ProductSpecification_000965';
        custNotifyIoT.offerID__c = 'DMCAT_Offer_000964';
        custNotifyIoT.monitorObjectStatus__c = 'In Progress';
        custNotifyIoT.scenarioType__c='';
        custNotifyIoT.monitorObject__c='Order';
        custNotifyIoT.orderType__c='New';
        custNotifyIoT.emailTemplate__c = congaTemplate55.id;
        custNotifyList.add(custNotifyIoT);
        //DPG-1415 END
        
        //DPG-1415 START
        Customer_Notify_Metadata__c custNotifyIoTCancel = new Customer_Notify_Metadata__c();
        custNotifyIoTCancel.productDefinitionCode__c ='DMCAT_ProductSpecification_000965';
        custNotifyIoTCancel.offerID__c = 'DMCAT_Offer_000964';
        custNotifyIoTCancel.monitorObjectStatus__c = 'Completed';
        custNotifyIoTCancel.scenarioType__c='';
        custNotifyIoTCancel.monitorObject__c='Order';
        custNotifyIoTCancel.orderType__c='Cancel';
        custNotifyIoTCancel.emailTemplate__c = congaTemplate66.id;
        custNotifyList.add(custNotifyIoTCancel);
        //DPG-1415 END

        //EDGE - 103485
        Customer_Notify_Metadata__c custNotifyTID = new Customer_Notify_Metadata__c();
        custNotifyTID.productDefinitionCode__c ='DMCAT_ProductSpecification_000747';
        custNotifyTID.offerID__c = 'DMCAT_Offer_000709';
        custNotifyTID.monitorObjectStatus__c = 'In Progress';
        custNotifyTID.scenarioType__c='';
        custNotifyTID.monitorObject__c='Order';
        custNotifyTID.orderType__c='New';
        custNotifyTID.emailTemplate__c = congaTemplate6.id;
        
        custNotifyList.add(custNotifyTID);
        //EDGE - 103485
        
        
        //EDGE-154675
        Customer_Notify_Metadata__c custNotifyNGEM = new Customer_Notify_Metadata__c();
        custNotifyNGEM.productDefinitionCode__c ='DMCAT_ProductSpecification_001196';
        custNotifyNGEM.offerID__c = 'DMCAT_Offer_001233';
        custNotifyNGEM.monitorObjectStatus__c = 'In Progress';
        custNotifyNGEM.scenarioType__c='';
        custNotifyNGEM.monitorObject__c='Order';
        custNotifyNGEM.orderType__c='New';
        custNotifyNGEM.emailTemplate__c = testCongaNew7.id;
        
        custNotifyList.add(custNotifyNGEM);
        //EDGE-154675
        
        insert custNotifyList;
        
        Test.startTest();
        //Added by Mukta Wadhwani to fix test class failure
        List<BDS_Notify_Settings__c> bdsSettingList = new List<BDS_Notify_Settings__c>();         
        BDS_Notify_Settings__c tsSetting = new BDS_Notify_Settings__c();         
        tsSetting.Name = 'Technical Support';        
        tsSetting.Value__c = 'TechnicalSupportShadow'; 
        bdsSettingList.add(tsSetting);
        BDS_Notify_Settings__c flSetting = new BDS_Notify_Settings__c();         
        flSetting.Name = 'Feature Level';        
        flSetting.Value__c = 'FeatureLevelShadow'; 
        bdsSettingList.add(flSetting);
        insert bdsSettingList;
        List<csord__Order__c> ords=new List<csord__Order__c>();
        //EDGE - 117267
        csord__Order__c primaryOrdngUC = ProductTestFactory.buildOrder('primaryOrdngUC', acc.id, 'Created', ordReq6.id);
        primaryOrdngUC.csord__Order_Request__c = ordReq6.Id;
        primaryOrdngUC.csord__Status2__c='In Progress';
        primaryOrdngUC.name = 'Test ngUC';
        primaryOrdngUC.csordtelcoa__Opportunity__c =opp.id;
        primaryOrdngUC.csordtelcoa__Product_Configuration__c = prodConfigngUC.Id;
        primaryOrdngUC.Billing_Account__c=ba.Id;
        ords.add(primaryOrdngUC);
        //EDGE - 117267

        //DPG-1415 START
        csord__Order__c primaryOrdIoT = ProductTestFactory.buildOrder('primaryOrdIoT', acc.id, 'Created', ordReq11.id);
        primaryOrdIoT.csord__Order_Request__c = ordReq11.Id;
        primaryOrdIoT.csord__Status2__c='In Progress';
        primaryOrdIoT.name = 'Test IoT';
        primaryOrdIoT.csordtelcoa__Opportunity__c =opp.id;
        primaryOrdIoT.csordtelcoa__Product_Configuration__c = prodConfigIoT.Id;
        primaryOrdIoT.Billing_Account__c=ba.Id;
        ords.add(primaryOrdIoT);
        //DPG-1415 END

        //DPG-1415 START
        csord__Order__c primaryOrdIoTCancel = ProductTestFactory.buildOrder('primaryOrdIoTCancel', acc.id, 'Created', ordReq12.id);
        primaryOrdIoTCancel.csord__Order_Request__c = ordReq12.Id;
        primaryOrdIoTCancel.csord__Status2__c='Completed';
        primaryOrdIoTCancel.name = 'Test IoT Cancel';
        primaryOrdIoTCancel.csordtelcoa__Opportunity__c =opp.id;
        primaryOrdIoTCancel.csordtelcoa__Product_Configuration__c = prodConfigIoTCancel.Id;
        primaryOrdIoTCancel.Billing_Account__c=ba.Id;
        ords.add(primaryOrdIoTCancel);
        //DPG-1415 END
        
        //EDGE-127861
        csord__Order__c primaryOrdngUC_cancel = ProductTestFactory.buildOrder('primaryOrdngUC_cancel', acc.id, 'Created', ordReq8.id);
        primaryOrdngUC_cancel.csord__Order_Request__c = ordReq8.Id;
        primaryOrdngUC_cancel.csord__Status2__c='Complete';
        primaryOrdngUC_cancel.name = 'Test ngUC Cancel';
        primaryOrdngUC_cancel.csordtelcoa__Opportunity__c =opp.id;
        primaryOrdngUC_cancel.csordtelcoa__Product_Configuration__c = prodConfigngUC_cancel.Id;
        primaryOrdngUC_cancel.Billing_Account__c=ba.Id;
        ords.add(primaryOrdngUC_cancel);
        //EDGE-127861
        
        //EDGE - 103485
        csord__Order__c primaryOrdTID = ProductTestFactory.buildOrder('primaryOrdTID', acc.id, 'Created', ordReq7.id);
        primaryOrdTID.csord__Order_Request__c = ordReq7.Id;
        primaryOrdTID.csord__Status2__c='In Progress';
        primaryOrdTID.name = 'Test TID';
        primaryOrdTID.csordtelcoa__Opportunity__c =opp.id;
        primaryOrdTID.csordtelcoa__Product_Configuration__c = prodConfigTID.Id;
        primaryOrdTID.Billing_Account__c=ba.Id;
        ords.add(primaryOrdTID);
        //EDGE - 103485
        
        csord__Order__c primaryOrdMobility = ProductTestFactory.buildOrder('PrimaryOrderMobility', acc.id, 'Created', ordReqMobility.id);
        primaryOrdMobility.csord__Order_Request__c = ordReqMobility.Id;
        primaryOrdMobility.csord__Status2__c='In Progress';
        primaryOrdMobility.csordtelcoa__Opportunity__c =opp.id;
        primaryOrdMobility.csordtelcoa__Product_Configuration__c = prodConfigMobility.Id;
        primaryOrdMobility.Billing_Account__c=ba.Id;
        ords.add(primaryOrdMobility);
        
        
        csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrderInProress', acc.id, 'Created', ordReq.id);
        primaryOrd.csord__Order_Request__c = ordReq3.Id;
        primaryOrd.csord__Status2__c='In Progress';
        primaryOrd.csordtelcoa__Opportunity__c =opp.id;
        primaryOrd.Billing_Account__c=ba.Id;
        ords.add(primaryOrd);
        
        csord__Order__c primaryOrd2 = ProductTestFactory.buildOrder('PrimaryOrderComplete', acc.id, 'Created', ordReq.id);
        primaryOrd2.csord__Order_Request__c = ordReq2.Id;
        primaryOrd2.csord__Status2__c='Complete';
        primaryOrd2.csordtelcoa__Opportunity__c =opp.id;
        primaryOrd2.csordtelcoa__Product_Configuration__c = prodConfigModify.Id;
        primaryOrd2.Billing_Account__c=ba.Id;
        ords.add(primaryOrd2);
        
        csord__Order__c primaryOrd3 = ProductTestFactory.buildOrder('PrimaryOrderIn Progresss', acc.id, 'Created', ordReq.id);
        primaryOrd3.csord__Order_Request__c = ordReq3.Id;
        primaryOrd3.csord__Status2__c='In Progress';
        primaryOrd3.csordtelcoa__Opportunity__c =opp.id;
        primaryOrd3.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        primaryOrd3.Billing_Account__c=ba.Id;
        ords.add(primaryOrd3);
        
        csord__Order__c primaryOrdNew = ProductTestFactory.buildOrder('PrimaryOrderNew', acc.id, 'Created', ordReq.id);
        primaryOrdNew.csord__Order_Request__c = ordReq4.Id;
        primaryOrdNew.csord__Status2__c='Complete';
        primaryOrdNew.csordtelcoa__Opportunity__c =opp.id;
        primaryOrdNew.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        primaryOrdNew.Billing_Account__c=ba.Id;
        ords.add(primaryOrdNew);
        
        /** EDGE-100899*/
        csord__Order__c createOrder = ProductTestFactory.buildOrder('EDGE-100899', acc.id, 'In Progress', ordReq.id);
        createOrder.csord__Order_Request__c = ordReq5.Id;
        createOrder.csord__Status2__c='In Progress';
        createOrder.csordtelcoa__Opportunity__c =opp.id;
        createOrder.csordtelcoa__Product_Configuration__c = prodConfig1.Id;
        createOrder.Billing_Account__c=ba.Id;
        createOrder.Project_Manager_Email__c = 'projectmanageremail@team.telstra.com';
        ords.add(createOrder);

        //EDGE-100920 Start
        csord__Order__c primaryOrdTCPS = ProductTestFactory.buildOrder('primaryOrdTCPS', acc.id, 'In Progress', ordReq10.id);
        primaryOrdTCPS.csord__Order_Request__c = ordReq10.Id;
        primaryOrdTCPS.csord__Status2__c='In Progress';
        //primaryOrdTCPS.name = 'Test TCPS';
        primaryOrdTCPS.csordtelcoa__Opportunity__c =opp.id;
        primaryOrdTCPS.csordtelcoa__Product_Configuration__c = prodConfigTCPS.Id;
        primaryOrdTCPS.Billing_Account__c=ba.Id;
        ords.add(primaryOrdTCPS);
        //EDGE-100920 End

        csord__Order__c ordMobility = ProductTestFactory.buildOrder('TestOrderMoblity', acc.id, 'Created', ordReqMobility.id);
        ordMobility.csord__Order_Request__c = ordReqMobility.Id;
        ordMobility.csord__Status2__c='In Progress';
        ordMobility.name = 'TestOrderMobility';
        ordMobility.csordtelcoa__Opportunity__c =opp.id;
        ordMobility.Billing_Account__c=ba.Id;
        
        ords.add(ordMobility);
        
        csord__Order__c ordException = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ordException.csord__Order_Request__c = ordReq.Id;
        ordException.csord__Status2__c='In Progress';
        ordException.name = 'TestOrderE';
        ordException.csordtelcoa__Opportunity__c =opp.id;
        
        //ord.csord__Primary_Order__c = primaryOrd.id;
        ords.add(ordException);
        
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csord__Status2__c='In Progress';
        ord.name = 'TestOrder';
        ord.csordtelcoa__Opportunity__c =opp.id;
        ord.Billing_Account__c=ba.Id;
        //ord.csord__Primary_Order__c = primaryOrd.id;
        ords.add(ord);
        
        csord__Order__c ord2 = ProductTestFactory.buildOrder('TestOrder2', acc.id, 'Created', ordReq2.id);
        ord.csord__Order_Request__c = ordReq2.Id;
        ord2.csord__Status2__c='Complete';
        ord2.name = 'TestOrder2';
        ord2.csordtelcoa__Opportunity__c =opp.id;
        ord2.Project_Manager_Email__c='testpmmanager@gmail.com';
        ord2.Billing_Account__c=ba.Id;
        //ord2.csord__Primary_Order__c = primaryOrd2.id;
        ords.add(ord2);
        
        csord__Order__c ord3 = ProductTestFactory.buildOrder('TestOrder3', acc.id, 'Created', ordReq3.id);
        ord3.csord__Order_Request__c = ordReq3.Id;
        ord3.csord__Status2__c='In Progress';
        ord3.Project_Manager_Email__c='testpmmanager@gmail.com';
        ord3.name = 'TestOrder3';
        ord3.Billing_Account__c=ba.Id;
        ord3.csordtelcoa__Opportunity__c =opp.id;
        
        ords.add(ord3);
        
        csord__Order__c ord4 = ProductTestFactory.buildOrder('TestOrder4', acc.id, 'Created', ordReq4.id);
        ord4.csord__Order_Request__c = ordReq4.Id;
        ord4.csord__Status2__c='Complete';
        ord4.name = 'TestOrder4';
        ord4.csordtelcoa__Opportunity__c =opp.id;
        ord4.Billing_Account__c=ba.Id;
        //ord4.csord__Primary_Order__c = primaryOrdNew.id;
        ords.add(ord4);

        insert ords;
        
        csord__Order__c secondaryOrder = ProductTestFactory.buildOrder('EDGE-100899', acc.id, 'In Progress', ordReq.id);
        secondaryOrder.csord__Order_Request__c = ordReq5.Id;
        secondaryOrder.csord__Status2__c='In Progress';
        secondaryOrder.csordtelcoa__Opportunity__c =opp.id;
        secondaryOrder.csordtelcoa__Product_Configuration__c = prodConfig1.Id;
        secondaryOrder.Billing_Account__c=ba.Id;
        secondaryOrder.csord__Primary_Order__c = createOrder.Id;
        secondaryOrder.Project_Manager_Email__c = 'projectmanageremail@team.telstra.com';
        insert secondaryOrder;
        
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
        csord__Subscription__c subsMobility=new csord__Subscription__c();
        subsMobility.name  = 'test subs Mobility';
        subsMobility.csord__Identification__c = 'test identity';
        subsMobility.csord__Order__c = ordMobility.Id;
        subsMobility.csord__Status__c = 'Provisioning In Progress';
        subsMobility.Sub_status__c = 'Active';
        subsMobility.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subsMobility.csordtelcoa__Subscription_Number__c = 'SN-00012345';
        
        subsMobility.csord__Order_Request__c = ordReqMobility.Id;
        //modified for 73057
        subsMobility.emailSent__c = false;
        subsMobility.csordtelcoa__Product_Configuration__c = prodConfigMobility.Id;
        subsMobility.Offer__c =offer.Id;
        subsMobility.Site__c = null;
        subsMobility.Primary_Order__c = primaryOrdMobility.Id;
        subList.add(subsMobility);
        /**EDGE-100899*/
        csord__Subscription__c subscriptionCreation=new csord__Subscription__c();
        subscriptionCreation.name  = 'Test Subscription';
        subscriptionCreation.csord__Identification__c = 'test identity';
        subscriptionCreation.csord__Order__c = createOrder.Id;
        subscriptionCreation.csord__Status__c = 'Provisioning In Progress';
        subscriptionCreation.Sub_status__c = 'Active';
        subscriptionCreation.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subscriptionCreation.csordtelcoa__Subscription_Number__c = 'SN-00012345';
        subscriptionCreation.csord__Order_Request__c = ordReq5.Id;
        subscriptionCreation.emailSent__c = false;
        subscriptionCreation.csordtelcoa__Product_Configuration__c = prodConfig1.Id;
        subscriptionCreation.Offer__c =offer1.Id;
        subscriptionCreation.Site__c = null;
        subList.add(subscriptionCreation);
        
        //EDGE - 117267
        csord__Subscription__c subscriptionCreationngUC=new csord__Subscription__c();
        subscriptionCreationngUC.name  = 'Test SubscriptionngUC';
        subscriptionCreationngUC.csord__Identification__c = 'test identity';
        subscriptionCreationngUC.csord__Order__c = primaryOrdngUC.Id;
        subscriptionCreationngUC.csord__Status__c = 'Provisioning In Progress';
        subscriptionCreationngUC.Sub_status__c = 'Active';
        subscriptionCreationngUC.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subscriptionCreationngUC.csordtelcoa__Subscription_Number__c = 'SN-00012345';
        subscriptionCreationngUC.csord__Order_Request__c = ordReq6.Id;
        subscriptionCreationngUC.emailSent__c = false;
        subscriptionCreationngUC.csordtelcoa__Product_Configuration__c = prodConfigngUC.Id;
        subscriptionCreationngUC.Offer__c =offer2.Id;
        subscriptionCreationngUC.Site__c = null;
        subscriptionCreationngUC.MarketableOffer__c = marketableOfferngUC.id;
        subList.add(subscriptionCreationngUC);
        system.debug('subscriptionCreationngUC::: ' + subscriptionCreationngUC);
        //EDGE - 117267

        //DPG-1415 START
        csord__Subscription__c subscriptionCreationIoTNew=new csord__Subscription__c();
        subscriptionCreationIoTNew.name  = 'Test IoT New';
        subscriptionCreationIoTNew.csord__Identification__c = 'test identity';
        subscriptionCreationIoTNew.csord__Order__c = primaryOrdIoT.Id;
        subscriptionCreationIoTNew.csord__Status__c = 'Provisioning In Progress';
        subscriptionCreationIoTNew.Sub_status__c = 'Active';
        subscriptionCreationIoTNew.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subscriptionCreationIoTNew.csordtelcoa__Subscription_Number__c = 'SN-00012345';
        subscriptionCreationIoTNew.csord__Order_Request__c = ordReq11.Id;
        subscriptionCreationIoTNew.emailSent__c = false;
        subscriptionCreationIoTNew.csordtelcoa__Product_Configuration__c = prodConfigIoT.Id;
        subscriptionCreationIoTNew.Offer__c =offer5.Id;
        subscriptionCreationIoTNew.Site__c = null;
        subscriptionCreationIoTNew.MarketableOffer__c = marketableOfferIoT.id;
        subscriptionCreationIoTNew.Billing_Account__c=ba.Id;
        subList.add(subscriptionCreationIoTNew);
        system.debug('subscriptionCreationIoTNew::: ' + subscriptionCreationIoTNew);
        //DPG-1415 END

        //DPG-1415 START
        csord__Subscription__c subscriptionCreationIoTCancel=new csord__Subscription__c();
        subscriptionCreationIoTCancel.name  = 'Test IoT Cancel';
        subscriptionCreationIoTCancel.csord__Identification__c = 'test identity';
        subscriptionCreationIoTCancel.csord__Order__c = primaryOrdIoTCancel.Id;
        subscriptionCreationIoTCancel.csord__Status__c = 'Provisioning In Progress';
        subscriptionCreationIoTCancel.Sub_status__c = 'Active';
        subscriptionCreationIoTCancel.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subscriptionCreationIoTCancel.csordtelcoa__Subscription_Number__c = 'SN-00012345';
        subscriptionCreationIoTCancel.csord__Order_Request__c = ordReq12.Id;
        subscriptionCreationIoTCancel.emailSent__c = false;
        subscriptionCreationIoTCancel.csordtelcoa__Product_Configuration__c = prodConfigIoTCancel.Id;
        subscriptionCreationIoTCancel.Offer__c =offer5.Id;
        subscriptionCreationIoTCancel.Site__c = null;
        subscriptionCreationIoTCancel.MarketableOffer__c = marketableOfferIoT.id;
        subscriptionCreationIoTCancel.Cancellation_Date_of_Effect__c=system.today().adddays(7);
        subList.add(subscriptionCreationIoTCancel);
        system.debug('subscriptionCreationIoTCancel::: ' + subscriptionCreationIoTCancel);
        //DPG-1415 END
        
        //EDGE-127861
        csord__Subscription__c subscriptionCreationngUC_cancel=new csord__Subscription__c();
        subscriptionCreationngUC_cancel.name  = 'Test SubscriptionngUC Cancel';
        subscriptionCreationngUC_cancel.csord__Identification__c = 'test identity';
        subscriptionCreationngUC_cancel.csord__Order__c = primaryOrdngUC_cancel.Id;
        subscriptionCreationngUC_cancel.csord__Status__c = 'Provisioning In Progress';
        subscriptionCreationngUC_cancel.Sub_status__c = 'Active';
        subscriptionCreationngUC_cancel.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subscriptionCreationngUC_cancel.csordtelcoa__Subscription_Number__c = 'SN-00012345';
        subscriptionCreationngUC_cancel.csord__Order_Request__c = ordReq8.Id;
        subscriptionCreationngUC_cancel.emailSent__c = false;
        subscriptionCreationngUC_cancel.csordtelcoa__Product_Configuration__c = prodConfigngUC_cancel.Id;
        subscriptionCreationngUC_cancel.Offer__c =offer2.Id;
        subscriptionCreationngUC_cancel.Site__c = null;
        subscriptionCreationngUC_cancel.MarketableOffer__c = marketableOfferngUC.id;
        subscriptionCreationngUC_cancel.Cancellation_Date_of_Effect__c=system.today().adddays(7);
        subList.add(subscriptionCreationngUC_cancel);
        system.debug('subscriptionCreationngUC_cancel::: ' + subscriptionCreationngUC_cancel);
        //EDGE-127861

        //EDGE - 103485
        csord__Subscription__c subscriptionCreationTID=new csord__Subscription__c();
        subscriptionCreationTID.name  = 'Test SubscriptionTID';
        subscriptionCreationTID.csord__Identification__c = 'test identity';
        subscriptionCreationTID.csord__Order__c = primaryOrdTID.Id;
        subscriptionCreationTID.csord__Status__c = 'Provisioning In Progress';
        subscriptionCreationTID.Sub_status__c = 'Active';
        subscriptionCreationTID.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subscriptionCreationTID.csordtelcoa__Subscription_Number__c = 'SN-00012345';
        subscriptionCreationTID.csord__Order_Request__c = ordReq7.Id;
        subscriptionCreationTID.emailSent__c = false;
        subscriptionCreationTID.csordtelcoa__Product_Configuration__c = prodConfigTID.Id;
        subscriptionCreationTID.Offer__c =offer3.Id;
        subscriptionCreationTID.Site__c = null;
        subscriptionCreationTID.MarketableOffer__c = marketableOfferTID.id;
        subList.add(subscriptionCreationTID);
        system.debug('subscriptionCreationTID::: ' + subscriptionCreationTID);
        //EDGE - 103485
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.csord__Status__c = 'Provisioning In Progress';
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Subscription_Number__c = 'SN-00012345';
        subs.Site__c = site.Id;
        subs.csord__Order_Request__c = ordReq.Id;
        //modified for 73057
        subs.emailSent__c = false;
        subs.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        subs.Offer__c =offer.Id;
        subs.Primary_Order__c = primaryOrd.Id;
        subList.add(subs);
        
        //EDGE-100920 Start
        csord__Subscription__c subscriptionCreationTCPS = new csord__Subscription__c();
        subscriptionCreationTCPS.name  = 'Test SubscriptionTCPS';
        subscriptionCreationTCPS.csord__Identification__c = 'Test Identity';
        subscriptionCreationTCPS.csord__Order__c = primaryOrdTCPS.Id;
        subscriptionCreationTCPS.csord__Status__c = 'Provisioning In Progress';
        subscriptionCreationTCPS.Sub_status__c = 'Active';
        subscriptionCreationTCPS.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subscriptionCreationTCPS.csordtelcoa__Subscription_Number__c = 'SN-00062290';
        subscriptionCreationTCPS.csord__Order_Request__c = ordReq10.Id;
        subscriptionCreationTCPS.emailSent__c = false;
        subscriptionCreationTCPS.csordtelcoa__Product_Configuration__c = prodConfigTCPS.Id;
        subscriptionCreationTCPS.Offer__c =offer4.Id;
        subscriptionCreationTCPS.Site__c = null;
        subscriptionCreationTCPS.MarketableOffer__c = marketableOfferTCPS.id;
        subList.add(subscriptionCreationTCPS);
        system.debug('subscriptionCreationTCPS::: ' + subscriptionCreationTCPS);
        //EDGE-100920 End
        
        csord__Subscription__c subs2=new csord__Subscription__c();
        subs2.name  = 'test subs2';
        subs2.csord__Identification__c = 'test identity';
        subs2.csord__Order__c = ord2.Id;
        subs2.csord__Status__c = 'Provisioning In Progress';
        subs2.Sub_status__c = 'Active';
        subs2.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294F';
        subs2.csordtelcoa__Subscription_Number__c = 'SN-123456';
        subs2.Site__c = site.Id;
        subs2.csord__Order_Request__c = ordReq2.Id;
        //modified for 73057
        subs2.csordtelcoa__Product_Configuration__c = prodConfigModify.Id;
        subs2.Offer__c =offer.Id;
        //subs2.Primary_Order__c = primaryOrd2.Id;
        subList.add(subs2);

        csord__Subscription__c subs3=new csord__Subscription__c();
        subs3.name  = 'test subs3';
        subs3.csord__Identification__c = 'test identity';
        subs3.csord__Order__c = ord3.Id;
        subs3.csord__Status__c = 'Provisioning In Progress';
        subs3.Sub_status__c = 'Active';
        subs3.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294F';
        subs3.csordtelcoa__Subscription_Number__c = 'SN-123456';
        subs3.Site__c = site.Id;
        subs3.csord__Order_Request__c = ordReq3.Id;
        //modified for 73057
        subs3.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        subs3.Offer__c =offer.Id;
        //subs3.Primary_Order__c = primaryOrd2.Id;
        subList.add(subs3);
        
        csord__Subscription__c subs4=new csord__Subscription__c();
        subs4.name  = 'test subs4';
        subs4.csord__Identification__c = 'test identity';
        subs4.csord__Order__c = ord4.Id;
        subs4.csord__Status__c = 'Provisioning In Progress';
        subs4.Sub_status__c = 'Active';
        subs4.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294F';
        subs4.csordtelcoa__Subscription_Number__c = 'SN-123456';
        subs4.Site__c = site.Id;
        subs4.csord__Order_Request__c = ordReq4.Id;
        //modified for 73057
        subs4.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        subs4.Offer__c =offer.Id;
        subs4.Primary_Order__c = primaryOrdNew.Id;
        subList.add(subs4);
        insert subList;
        
        List<Contact> contacts=new List<Contact>();
        Contact cntct1 = new Contact();
        cntct1.MobilePhone='+61123456789';
        cntct1.LastName = 'Primary';
        cntct1.FirstName='Test';
        cntct1.Phone = '+1141415958';
        cntct1.email='Primary@gmail.com';
        contacts.add(cntct1);
        
        Contact cntct2 = new Contact();
        cntct2.LastName = 'Secondary';
        cntct2.MobilePhone='+61123456789';
        cntct2.FirstName='Test';
        cntct2.Phone = '+1141415955';
        cntct2.email='Secondary@gmail.com';
        contacts.add(cntct2);
        Contact cntct3 = new Contact();
        cntct3.LastName = 'Site';
        cntct3.MobilePhone='+61123456789';
        cntct3.FirstName='Test';
        cntct3.Phone = '+114141595';
        cntct3.email='Site@gmail.com';
        contacts.add(cntct3);
        
        Contact cntct4 = new Contact();
        cntct4.LastName = 'billing';
        cntct4.MobilePhone='+61123456789';
        cntct4.FirstName='Test';
        cntct4.Phone = '+1141415951';
        cntct4.email='billing@gmail.com';
        contacts.add(cntct4);
        
        Contact cntct5 = new Contact();
        cntct5.LastName = 'Delivery';
        cntct5.MobilePhone='+61123456789';
        cntct5.FirstName='Test';
        cntct5.Phone = '+1141415952';
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
        
    
        List<csord__Service__c> services = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='IP Site';
        serv.Primary_Contact__c = contact.id;
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        serv.Order_Primary_Contact__c = contact.id;
        services.add(serv);
        //insert serv;
        
        //EDGE-103485 start
        csord__Service__c servTID = new csord__Service__c();
        servTID.name ='Internet Site';
        servTID.Primary_Contact__c = contact.id;
        servTID.csord__Identification__c  = 'test identify';
        servTID.csordtelcoa__Service_Number__c = '3';
        servTID.csord__Subscription__c = subscriptionCreationTID.Id;
        servTID.csord__Status__c = 'Service Created';
        servTID.csord__Order_Request__c = ordReq7.Id;
        servTID.csord__Order__c = primaryOrdTID.Id;
        servTID.Order_Primary_Contact__c = contact.id;
        services.add(servTID);
        //insert servTID;
        //EDGE-103485 end
        
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
        services.add(serv2);
        //insert serv2;
        
        csord__Service__c serv3 = new csord__Service__c();
        serv3.name ='IP Site';
        serv3.Primary_Contact__c = contact.id;
        serv3.csord__Identification__c  = 'test identify';
        serv3.csordtelcoa__Service_Number__c = '3';
        serv3.csord__Subscription__c = subs3.Id;
        serv3.csord__Status__c = 'Service Created';
        serv3.csord__Order_Request__c = ordReq3.Id;
        serv3.csord__Order__c = ord3.Id;
        serv3.Order_Primary_Contact__c = contact.id;
        serv3.Project_Contact__c=contact.id;
        serv3.Technical_Contact__c=contact.id;
        services.add(serv3);
        //insert serv3;
        
        csord__Service__c serv4 = new csord__Service__c();
        serv4.name ='IP Site';
        serv4.Primary_Contact__c = contact.id;
        serv4.csord__Identification__c  = 'test identify';
        serv4.csordtelcoa__Service_Number__c = '3';
        serv4.csord__Subscription__c = subs4.Id;
        serv4.csord__Status__c = 'Service Created';
        serv4.csord__Order_Request__c = ordReq4.Id;
        serv4.csord__Order__c = ord4.Id;
        serv4.Order_Primary_Contact__c = contact.id;
        services.add(serv4);
        //insert serv4;
        
        csord__Service__c serv5 = new csord__Service__c();
        serv5.name ='CWP Mobile Service';
        serv5.Primary_Contact__c = contact.id;
        serv5.csord__Identification__c  = 'test identify';
        serv5.csordtelcoa__Service_Number__c = '3';
        serv5.csord__Subscription__c = subsMobility.Id;
        serv5.csord__Status__c = 'Service Created';
        serv5.csord__Order_Request__c = ordReqMobility.Id;
        serv5.csord__Order__c = ordMobility.Id;
        serv5.Order_Primary_Contact__c = contact.id;
        serv5.Technical_Contact__c=contact.Id;
        serv5.Project_Contact__c=contact.Id;
        serv5.csord__Service__c = null;
        services.add(serv5);
        insert services;

        List<csord__Subscription__c> replacesSubscriptions = new List<csord__Subscription__c>();
        csord__Subscription__c replacedsubs = new csord__Subscription__c();
        replacedsubs.name  = 'replaced test subs1';
        replacedsubs.csord__Identification__c = 'test identity';
        replacedsubs.csordtelcoa__Replaced_Subscription__c = subs.Id;
        replacedsubs.csord__Order__c = ord.Id;
        replacedsubs.csord__Order_Request__c = ordReq.Id;
        //73057
        replacedsubs.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        replacedsubs.Offer__c =offer.Id;
        replacedsubs.Primary_Order__c = primaryOrd.Id;
        //
        replacesSubscriptions.add(replacedsubs);
        //insert replacedsubs;
        System.debug('replacedsubs::::'+replacedsubs);
        
        csord__Subscription__c replacedsubs2 = new csord__Subscription__c();
        replacedsubs2.name  = 'replaced test subs2';
        replacedsubs2.csord__Identification__c = 'test identity';
        replacedsubs2.csordtelcoa__Replaced_Subscription__c = subs2.Id;
        replacedsubs2.csord__Order__c = ord2.Id;
        replacedsubs2.csord__Order_Request__c = ordReq2.Id;
        replacedsubs2.Site__c=site.Id;
        //73057
        replacedsubs2.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        replacedsubs2.Offer__c =offer.Id;
        //replacedsubs2.Primary_Order__c = primaryOrd2.Id;
        //
        replacesSubscriptions.add(replacedsubs2);
        insert replacesSubscriptions;
        
        System.debug('replacedsubs2::::'+replacedsubs2);
        csord__Service__c replacedserv = new csord__Service__c();
        replacedserv.name ='IP Site';
        replacedserv.csord__Identification__c  = 'test identify2';
        replacedserv.csordtelcoa__Service_Number__c = '5';
        replacedserv.csord__Subscription__c = replacedsubs.Id;
        replacedserv.csord__Status__c = 'In Progress';
        replacedserv.Primary_Contact__c = contact.id;
        replacedserv.Project_Contact__c = contact.id;
        replacedserv.Technical_Contact__c = contact.id;
        replacedserv.csord__Order_Request__c = ordReq.Id;
        insert replacedserv;
        
        csord__Service__c replacedserv2 = new csord__Service__c();
        replacedserv2.name ='IP Site';
        replacedserv2.csord__Identification__c  = 'test identify2';
        replacedserv2.csordtelcoa__Service_Number__c = '5';
        replacedserv2.csord__Subscription__c = replacedsubs2.Id;
        replacedserv2.csord__Status__c = 'In Progress';
        replacedserv2.Primary_Contact__c = contact.id;
        replacedserv2.Project_Contact__c = contact.id;
        replacedserv2.Technical_Contact__c = contact.id;
        replacedserv2.csord__Order_Request__c = ordReq2.Id;
        replacedserv2.Order_Primary_Contact__c = contact.id;
        replacedserv2.csord__Order__c = ord2.Id;
        insert replacedserv2;
        /*EDGE-100899 */
        csord__Service__c orderServiceCreation = new csord__Service__c();
        orderServiceCreation.name ='IP Site';
        orderServiceCreation.csord__Identification__c  = 'test identify2';
        orderServiceCreation.csordtelcoa__Service_Number__c = '5';
        orderServiceCreation.csord__Subscription__c = subscriptionCreation.Id;
        orderServiceCreation.csord__Status__c = 'In Progress';
        orderServiceCreation.Primary_Contact__c = contact.id;
        orderServiceCreation.Project_Contact__c = contact.id;
        orderServiceCreation.Technical_Contact__c = contact.id;
        orderServiceCreation.csord__Order_Request__c = ordReq5.Id;
        orderServiceCreation.Order_Primary_Contact__c = contact.id;
        orderServiceCreation.csord__Order__c = createOrder.Id;
        
        insert orderServiceCreation;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User SignatoryContact3 = New User(Alias = 'newUser', Email='new1_kiran@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='new1_kiran@testorg.com');
        SignatoryContact3.IsActive =true; 
        // insert SignatoryContact3;
        ContractJunction__c CJ=new ContractJunction__c();
        CJ.name='testCJ';
        CJ.account__c=acc.id;
        CJ.Related_Opportunity__c = opp.id;
        CJ.Customer_Primary_Contact__c = contact.id;
        CJ.Related_Basket__c = basket.id;
        CJ.DocuSign_Signer_2__c = contact.id;
        //   CJ.DocuSign_Signer_3__c = SignatoryContact3.id;
        insert CJ;
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testprocessOrderRecordNew(){
        System.debug('testprocessOrderRecordNew');
        Test.startTest();
        csord__Subscription__c sub = [SELECT Id, csord__Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs3' limit 1];
        System.debug('sub of Test::'+sub);
        List<String> parameters = new List<String>();
        parameters.add(sub.csord__Order__c);
        System.debug('parameters of test::'+parameters);
        OrderEmailService.processOrderRecord(parameters);
        system.debug('DML Statements5632: '+System.limits.getDmlStatements());
        csord__Order__c ord = [SELECT Id, csord__Status2__c, Name from csord__Order__c where Name = 'TestOrder3'];
        Test.stopTest();
        System.assertEquals('In Progress', ord.csord__Status2__c);
    }
    
    @isTest
    static void testprocessOrderRecordNewComplete(){
        System.debug('testprocessOrderRecordNewComplete');
        Test.startTest();
        csord__Subscription__c sub = [SELECT Id, csord__Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs2' limit 1];
        List<String> parameters = new List<String>();
        parameters.add(sub.csord__Order__c);
        OrderEmailService.processOrderRecord(parameters);
        csord__Order__c ord = [SELECT Id, csord__Status2__c, Name from csord__Order__c where Name = 'TestOrder2'];
        Test.stopTest();
        System.assertEquals('Complete', ord.csord__Status2__c);
    }
    
    @isTest
    static void testprocessOrderRecordNewMobility(){
        System.debug('testprocessOrderRecordNewMobility');
        Test.startTest();
        csord__Subscription__c sub = [SELECT Id, csord__Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs Mobility' limit 1];
        List<String> parameters = new List<String>();
        parameters.add(sub.csord__Order__c);
        OrderEmailService.processOrderRecord(parameters);
        csord__Order__c ord = [SELECT Id, csord__Status2__c, Name from csord__Order__c where Name = 'TestOrder2'];
        Test.stopTest();
        System.assertEquals('Complete', ord.csord__Status2__c);
    }
    
    //EDGE - 117267
     @isTest
    static void testprocessOrderRecordngUC(){
        System.debug('testprocessOrderRecordngUC');
        Test.startTest();
        csord__Subscription__c sub = [SELECT Id, csord__Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'Test SubscriptionngUC' limit 1];
        List<String> parameters = new List<String>();
        parameters.add(sub.csord__Order__c);
        OrderEmailService.processOrderRecord(parameters);
        csord__Order__c ord = [SELECT Id, csord__Status2__c, Name from csord__Order__c where Name = 'Test ngUC'];
        system.debug('ord.csord__Status2__c:::' + ord.csord__Status2__c);
        Test.stopTest();
        System.assertEquals('In Progress', ord.csord__Status2__c);
    }
    //EDGE - 117267

    //DPG-1415 START
     @isTest
    static void testprocessOrderRecordIoTNew(){
        System.debug('##########testprocessOrderRecordIoTNew');
        Test.startTest();
        csord__Subscription__c sub = [SELECT Id, csord__Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'Test IoT New' limit 1];
        List<String> parameters = new List<String>();
        parameters.add(sub.csord__Order__c);
        OrderEmailService.processOrderRecord(parameters);
        csord__Order__c ord = [SELECT Id, csord__Status2__c, Name,csordtelcoa__Product_Configuration__r.Type__c from csord__Order__c where Name = 'Test IoT'];
        system.debug('##########ord.csord__Status2__c:::' + ord.csord__Status2__c);
        Test.stopTest();
        System.assertNotEquals('Cancel', ord.csordtelcoa__Product_Configuration__r.Type__c);
        System.assertEquals('In Progress', ord.csord__Status2__c);
    }
    //DPG-1415 END
    
    //EDGE-127861
     @isTest
    static void testprocessOrderRecordngUC_cancel(){
        System.debug('testprocessOrderRecordngUC_cancel');
        Test.startTest();
        csord__Subscription__c sub = [SELECT Id, csord__Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'Test SubscriptionngUC Cancel' limit 1];
        List<String> parameters = new List<String>();
        parameters.add(sub.csord__Order__c);
        OrderEmailService.processOrderRecord(parameters);
        csord__Order__c ord = [SELECT Id, csord__Status2__c, Name,csordtelcoa__Product_Configuration__r.Type__c from csord__Order__c where Name = 'Test ngUC Cancel'];
        system.debug('ord.csord__Status2__c:::' + ord.csord__Status2__c);
        Test.stopTest();
        System.assertNotEquals('New', ord.csordtelcoa__Product_Configuration__r.Type__c);
        System.assertEquals('Complete', ord.csord__Status2__c);
    }
    //EDGE-127861
    
    //DPG-2447
    /* 
    //DPG-1415 START
     @isTest
    static void testprocessOrderRecordIoTCancel(){
        System.debug('##########testprocessOrderRecordIoTCancel');
        Test.startTest();
        csord__Subscription__c sub = [SELECT Id, csord__Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'Test IoT Cancel' limit 1];
        List<String> parameters = new List<String>();
        parameters.add(sub.csord__Order__c);
        OrderEmailService.processOrderRecord(parameters);
        csord__Order__c ord = [SELECT Id, csord__Status2__c, Name from csord__Order__c where Name = 'Test IoT Cancel'];
        system.debug('##########ord.csord__Status2__c:::' + ord.csord__Status2__c);
        Test.stopTest();
        System.assertEquals('Completed', ord.csord__Status2__c);
    } */
    //DPG-1415 END  
        
    //EDGE - 103485
     @isTest
    static void testprocessOrderRecordTID(){
        System.debug('testprocessOrderRecordTID');
        Test.startTest();
        csord__Subscription__c sub = [SELECT Id, csord__Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'Test SubscriptionTID' limit 1];
        List<String> parameters = new List<String>();
        parameters.add(sub.csord__Order__c);
        OrderEmailService.processOrderRecord(parameters);
        csord__Order__c ord = [SELECT Id, csord__Status2__c, Name from csord__Order__c where Name = 'Test TID'];
        system.debug('ord.csord__Status2__c:::' + ord.csord__Status2__c);
        Test.stopTest();
        System.assertEquals('In Progress', ord.csord__Status2__c);
    }
    //EDGE - 103485
    
    /*@isTest
static void testprocessOrderRecordModifyOrder(){
System.debug('testprocessOrderRecordModifyOrder');
csord__Subscription__c sub = [SELECT Id, csord__Order__r.csord__Primary_Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'replaced test subs1' limit 1][0];
List<String> parameters = new List<String>();
parameters.add(sub.csord__Order__r.csord__Primary_Order__c);
Test.startTest();
OrderEmailService.processOrderRecord(parameters);
List<csord__Subscription__c> subscription = [Select Id,csord__Order__c,csord__Order__r.csord__Status2__c,csord__Order_Request__c,csordtelcoa__Replaced_Subscription__c from csord__Subscription__c where name='replaced test subs1' and csordtelcoa__Replaced_Subscription__c != null];
Test.stopTest();
System.assertEquals('In Progress', subscription[0].csord__Order__r.csord__Status2__c);
}*/
    
    @isTest
    static void testprocessOrderRecordModifyOrderComplete(){
        System.debug('testprocessOrderRecordModifyOrderComplete');
        Test.startTest();
        csord__Subscription__c sub = [SELECT Id, csord__Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'replaced test subs2' limit 1][0];
        List<String> parameters = new List<String>();
        parameters.add(sub.csord__Order__c);
        OrderEmailService.processOrderRecord(parameters);
        List<csord__Subscription__c> subscription = [Select Id,csord__Order__c,csord__Order__r.csord__Status2__c,csord__Order_Request__c,csordtelcoa__Replaced_Subscription__c from csord__Subscription__c where name='replaced test subs2' and csordtelcoa__Replaced_Subscription__c != null];
        Test.stopTest();
        System.assertEquals('Complete', subscription[0].csord__Order__r.csord__Status2__c);
    }
    
    @isTest
    static void testprocessOrderRecordException(){
        System.debug('testprocessOrderRecordNewMobility');
        Test.startTest();
        csord__Subscription__c sub = [SELECT Id, csord__Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs' limit 1];
        List<String> parameters = new List<String>();
        parameters.add(sub.csord__Order__c);
        OrderEmailService.processOrderRecord(parameters);
        csord__Order__c ord = [SELECT Id, csord__Status2__c, Name from csord__Order__c where Name = 'TestOrder'];
        Test.stopTest();
        System.assertEquals('In Progress', ord.csord__Status2__c);
        
    }
    
    @isTest
    static void testgetSubject()
    {
        Test.startTest();
        APXTConga4__Conga_Email_Template__c congaTemplate =new APXTConga4__Conga_Email_Template__c();
        congaTemplate.APXTConga4__HTMLBody__c = 'test conga';
        congaTemplate.APXTConga4__Name__c='TestName';
        congaTemplate.APXTConga4__Subject__c = 'testSubject';
        insert congaTemplate;
        System.debug('congaTemplate id'+congaTemplate.id);
        
        String subject = OrderEmailService.getSubject(congaTemplate.APXTConga4__Name__c);
        System.debug('subject email:'+subject);
        System.assert(subject !=null);
        Test.stopTest();
    }
    
    @isTest
    static void testgetSignatories()
    {
        
        Test.startTest();
        List<String> signatoryEmails = new List<String>();
        
        List<cscfga__Product_Basket__c> basket1 = [SELECT Id,csbb__Account__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c WHERE csordtelcoa__Basket_Stage__c = 'Contract Accepted' order by id desc LIMIT 1];
        
        signatoryEmails = OrderEmailService.getContractSignatories(basket1[0].id);
        System.assert(signatoryEmails!=null);
        Test.stopTest();
    }
    
    /*  @isTest
static void testCongaEmailTemplate(){
//EDGE-100899
Test.startTest();
List<Id> orderIds = new List<Id>();
for(csord__Order__c orderList : [SELECT Id,Name FROM csord__Order__c WHERE Name = 'EDGE-100899']){
orderIds.add(orderList.Id);
}
OrderEmailService.processOrderRecord(orderIds);
csord__Order__c orderList = [SELECT Id,Name,csord__Status2__c FROM csord__Order__c WHERE Name = 'EDGE-100899'][0];
Test.stopTest();
System.assertEquals('In Progress', orderList.csord__Status2__c);
}*/
    
    @isTest
    static void testgetBCCEmailsList(){
        Test.startTest();
        List<csord__Order__c> orderList = [SELECT Id,Name,Project_Manager_Email__c FROM csord__Order__c WHERE Name = 'EDGE-100899'];
        for(csord__Order__c ord : orderList){           
        OrderEmailServiceHelper.getBCCEmailsList(ord);
        }        
        csord__Order__c orderList1 = [SELECT Id,Name,csord__Status2__c,Project_Manager_Email__c FROM csord__Order__c WHERE Name = 'EDGE-100899'][0];
        Test.stopTest();
        System.assertEquals('In Progress', orderList1.csord__Status2__c);
        System.assertEquals('projectmanageremail@team.telstra.com',orderList1.Project_Manager_Email__c);
    }
    @isTest
    static void testprocessOrderTCPS(){ //EDGE-100920
        System.debug('testprocessOrderTCPS');
        Test.startTest();
        csord__Subscription__c sub = [SELECT Id, csord__Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'Test SubscriptionTCPS' limit 1];
        List<String> parameters = new List<String>();
        parameters.add(sub.csord__Order__c);
        OrderEmailService.processOrderRecord(parameters);
        csord__Order__c ord = [SELECT Id, csord__Status2__c, Name from csord__Order__c where Name = 'primaryOrdTCPS'];
        Test.stopTest();
        System.assertEquals('In Progress', ord.csord__Status2__c);
    
    } 
    
    //EDGE-184269
    @isTest
    static void testGenerateEmailDTO(){
        Test.startTest();
        csord__Subscription__c sub = [SELECT Id, csord__Order__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'Test SubscriptionTCPS' limit 1];
        List<String> parameters = new List<String>();
        parameters.add(sub.csord__Order__c);
        csord__Order__c ord = [SELECT Id, csord__Status2__c, Name from csord__Order__c where Name = 'primaryOrdTCPS'];
        List<APXTConga4__Conga_Email_Template__c> templates=[Select Id,APXTConga4__Name__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c='TID_New_Order_Completed' LIMIT 1];
        OrderEmailServiceHelper.generateEmailDTO(templates[0].Id,ord,sub);
        Test.stopTest();
        System.assertEquals('primaryOrdTCPS', ord.Name);
    }   
    //EDGE-171620
    @isTest
    static void testgenerateAmendEmailDTO(){ 
        System.debug('testgenerateAmendEmailDTO');
        Test.startTest();
        List<String> parameters = new List<String>();
        csord__Order__c order= [SELECT Id,Name,csord__Status2__c FROM csord__Order__c WHERE Name = 'Test IoT' limit 1];
        order.Fulfilment_Order_Version__c=2.0;
        update order;
        Account[] partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
        insert partnerAccount;
        ContractJunction__c cntrctJnctn= [select id from ContractJunction__c limit 1];
        csord__Subscription__c sub = [SELECT Id, csordtelcoa__Product_Configuration__c from csord__Subscription__c where csord__Order__c = :order.id limit 1];
        sub.PartnerAccount__c=partnerAccount[0].id;
        sub.contractJunction__c= cntrctJnctn.id;
        update sub;
        cscfga__Product_Configuration__c pcg= [select id from cscfga__Product_Configuration__c where id= :sub.csordtelcoa__Product_Configuration__c limit 1];
        pcg.Type__c = 'Cancel';
        update pcg;
        parameters.add(order.id);
        OrderEmailService.processOrderRecord(parameters);
        csord__Order__c ord = [SELECT Id, csord__Status2__c, Name from csord__Order__c where Name = 'Test IoT'];
        Test.stopTest();
        System.assertEquals('In Progress', ord.csord__Status2__c);
    } 
}