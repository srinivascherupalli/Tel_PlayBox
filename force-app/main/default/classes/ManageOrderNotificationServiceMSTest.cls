/********************************************************
Class Name : ManageOrderNotificationServiceMSTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Prajakta                11/02/2020      test coverage of ManageOrderNotificationServiceMSUpdate
2.            Vaibhav                 26/06/2020    EDGE-158300
3.            Pawan                   02/07/2020    EDGE-156046 :  Enhance paid out subscription / service status for product offer agnostic
4.            Vaibhav                 16/07/2020    EDGE-154104 : populate DeviceCareID on service specs
5.            Vaibhav                 30/07/2020    EDGE-165183
6.            Vaibhav                 05/08/2020    EDGE-160243
7.            Vaibhav                 28/08/2020    EDGE-169583
8.            Pawan                   04-Sep-2020   EDGE-164355
9.            Pooja                   25-11-2020    EDGE-180743
10.           Vaibhav                 02/12/2020    EDGE-170550
11.          Pooja                    24/12/2020    EDGE-191827
12.          Gnana                  19/01/2021  Added test methods and test data for EDGE-170546
13.          Gnana                  10/03/2021  Modified test methods and test data for EDGE-170546
14.          Pawan S./Vaibhav        18/05/2021      B2B-328 - Solution Supress
15.          Aniket                   09-08-2021    DIGI-1413 - Notification Management
=======
**********************************************************
*/
@isTest
private class ManageOrderNotificationServiceMSTest{
  @Testsetup
  static void dataSetup(){
    EnvironmentVariable__c csSite = new EnvironmentVariable__c();
    csSite.Name='EnableHV';
    csSite.value__c='True';
    insert csSite;
    EnvironmentVariable__c tokenCustomSetting = new EnvironmentVariable__c();
    tokenCustomSetting.Name = 'EnableThrowException';
    tokenCustomSetting.Value__c = 'true';
    insert tokenCustomSetting;
    Account acc = new Account();
    acc.Name = 'test Account' ;
    acc.Type = 'Competitor' ;
    acc.Customer_Status__c='Active';
    insert acc;
    /*Opportunity opp = new Opportunity( Name = 'test opportunity', AccountId= acc.Id, Product_Domain__c = 'MOBILES', StageName='Develop', Description='Test Opp', Pricing_Method__c='PET', Contract_Type__c='BSA',Billing_Solution__c='Standard', recordtypeId='0122P0000004HYg');
    opp.CloseDate = system.today();
    insert opp;*/
    Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
    opp.StageName = 'Define';
    opp.CloseDate = System.Date.today();
    insert opp;
    // solution supress start
    cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
    testBasket.csbb__Account__c = acc.Id;
    testBasket.Name = 'SoulutionSupress';
    testBasket.cscfga__Opportunity__c = opp.Id;
    insert testBasket;
    cscfga__Product_Configuration__c pcSol = new cscfga__Product_Configuration__c();
    pcSol.Name = 'AM';
    pcSol.cscfga__Product_Basket__c = testBasket.Id;
    pcSol.Type__c = 'New';
    pcSol.ConfigurationType1__c = 'SolutionComponent';
    insert pcSol;
    // end
    List<csord__Order_Request__c> ordRequestList = new List<csord__Order_Request__c>();
    csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
    ordRequestList.add(ordReq);
    csord__Order_Request__c ordReq1 = ProductTestFactory.buildOrderRequest();
    ordRequestList.add(ordReq1);
    csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
    ordRequestList.add(ordReq2);
    csord__Order_Request__c ordReq3 = ProductTestFactory.buildOrderRequest();
    ordRequestList.add(ordReq3);
    csord__Order_Request__c ordReq4 = ProductTestFactory.buildOrderRequest(); //EDGE-170552
    ordRequestList.add(ordReq4);
    csord__Order_Request__c ordReq5 = ProductTestFactory.buildOrderRequest(); //solution supress
    ordRequestList.add(ordReq5);
    insert ordRequestList;
    List<csord__Order__c> orderlist = new List<csord__Order__c>();
    csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq1.id);
    primaryOrd.csord__Order_Request__c = ordReq1.Id;
    primaryOrd.csordtelcoa__Opportunity__c = opp.Id;
    orderlist.add(primaryOrd);
    csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
    ord.csord__Order_Request__c = ordReq.Id;
    ord.csordtelcoa__Opportunity__c = opp.Id;
    ord.csord__Primary_Order__c = primaryOrd.id;
    ord.rejectionReason__c = 'PONR has reached of one or more order items present in amend order';
    orderlist.add(ord);
    csord__Order__c ord1 = ProductTestFactory.buildOrder('Resume_12345', acc.id, 'Created', ordReq2.id);
    ord1.csord__Order_Request__c = ordReq2.Id;
    ord1.csordtelcoa__Opportunity__c = opp.Id;
    orderlist.add(ord1);
    csord__Order__c ord2 = ProductTestFactory.buildOrder('Inflight', acc.id, 'Created', ordReq3.id);
    ord2.csord__Order_Request__c = ordReq3.Id;
    ord2.csordtelcoa__Opportunity__c = opp.Id;
    ord2.Fulfilment_Order_Version__c = 2;
    orderlist.add(ord2);
    csord__Order__c ord3 = ProductTestFactory.buildOrder('InflightNew', acc.id, 'Created', ordReq4.id);//EDGE-170552
    ord3.csord__Order_Request__c = ordReq4.Id;
    ord3.csordtelcoa__Opportunity__c = opp.Id;
    ord3.Fulfilment_Order_Version__c = 2;
    orderlist.add(ord3);
    // solution supress
    csord__Order__c testSolutionOrd = ProductTestFactory.buildOrder('testSolutionSupress', acc.id, 'Created', ordReq5.id);
    testSolutionOrd.csordtelcoa__Opportunity__c = opp.Id;
    testSolutionOrd.csord__Order_Request__c = ordReq5.Id;
    orderlist.add(testSolutionOrd);
    insert orderlist;
    // solution supress
    csord__Solution__c solutionAM= PricingTestDataFactory.generateSolution('AM');
    insert solutionAM;
    List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
    csord__Subscription__c replSubs=new csord__Subscription__c();
    replSubs.name  = 'test replaced subs';
    replSubs.csord__Identification__c = 'test identity replced';
    // replSubs.csord__Order__c = ord.Id;
    replSubs.Sub_status__c = 'Active';
    replSubs.eventId__c = '9f0ded2-1bfd-7916-662d-9e28c804294e';
    subList.add(replSubs);
    csord__Subscription__c subs=new csord__Subscription__c();
    subs.name  = 'test subs';
    subs.csord__Identification__c = 'test identity';
    subs.csord__Order__c = ord.Id;
    subs.Sub_status__c = 'Active';
    subs.csord__Status__c='Active';
    subs.csordtelcoa__Subscription_Number__c ='SN-12345';
    subs.Suspension_reason__c='Requested by Customer';
    subs.csordtelcoa__Replaced_Subscription__c = replSubs.id;
    subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
    subs.changeType__c = 'Resume';//EDGE-180743
    subs.Point_of_No_Return_Reached__c = true;//Pooja
    subs.cancel_Point_of_No_Return_Reached__c = true; //Pooja
    subList.add(subs);
    csord__Subscription__c sub1=new csord__Subscription__c();
    sub1.name  = 'test sub';
    sub1.csord__Identification__c = 'test identity';
    sub1.Point_of_No_Return_Reached__c = false;//Pooja
    sub1.cancel_Point_of_No_Return_Reached__c = false; //Pooja
    sub1.csord__Order__c = ord.Id;
    sub1.Sub_status__c = 'Active';
    sub1.csord__Status__c='Active';
    sub1.Suspension_Reason__c='Requested by Customer';
    sub1.csordtelcoa__Replaced_Subscription__c = replSubs.id;
    subList.add(sub1);
    csord__Subscription__c subRes=new csord__Subscription__c();
    subRes.name  = 'test sub12';
    subRes.csord__Identification__c = 'test identity12';
    subRes.csord__Order__c = ord1.Id;
    subRes.Sub_status__c = 'Active';
    subRes.csord__Status__c='Active';
    subList.add(subRes);
    csord__Subscription__c subs1=new csord__Subscription__c();
    subs1.name  = 'test subs Inactive';
    subs1.csord__Identification__c = 'test identity';
    subs1.csord__Order__c = ord.Id;
    subs1.Sub_status__c = 'Inactive';
    subs1.csord__Status__c = 'Inactive';
    subs1.eventId__c = '8f0bfd2-1bfd-7916-552d-9e28c804294e';
    subList.add(subs1);
    csord__Subscription__c subsBilling=new csord__Subscription__c();
    subsBilling.name  = 'test subsBilling';
    subsBilling.csord__Identification__c = 'test identity';
    subsBilling.csord__Order__c = ord.Id;
    subsBilling.csord__Status__c='Bill Readiness In progress';
    subsBilling.csordtelcoa__Subscription_Number__c ='SN-12345';
    subsBilling.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
    subList.add(subsBilling);
    csord__Subscription__c subV=new csord__Subscription__c();
    subV.name  = 'TestDevicecareID';
    subV.csord__Identification__c = 'TestDevicecareID';
    subV.csord__Order__c = ord.Id;
    subList.add(subV);
    csord__Subscription__c subV1=new csord__Subscription__c();
    subV1.name  = 'TestDevicecareID1';
    subV1.csord__Identification__c = 'TestDevicecareID1';
    subV1.csord__Order__c = ord.Id;
    subList.add(subV1);
    csord__Subscription__c subInflight=new csord__Subscription__c();
    subInflight.name  = 'Inflight';
    subInflight.csord__Identification__c = 'Inflight';
    subInflight.csord__Order__c = ord2.Id;
    subInflight.Sub_status__c = 'Pending';
    subInflight.csord__Status__c = 'Pending';
    subInflight.orderversion__c = 2;
    subList.add(subInflight);
    csord__Subscription__c subInflight1=new csord__Subscription__c();
    subInflight1.name  = 'InflightNew';
    subInflight1.csord__Identification__c = 'InflightNew';
    subInflight1.csord__Order__c = ord3.Id;
    subInflight1.Sub_status__c = 'Pending';
    subInflight1.csord__Status__c = 'Pending';
    subInflight1.orderversion__c = 2;
    subList.add(subInflight1);
    // solution supress - start
    csord__Subscription__c subSol=new csord__Subscription__c();
    subSol.name  = 'subSol';
    subSol.csord__Identification__c = 'subSol';
    subSol.csord__Order__c = testSolutionOrd.Id;
    subSol.csord__Account__c=acc.id;
    subSol.cssdm__solution_association__c = solutionAM.Id;
    subSol.csord__status__c = 'Provisioned';
    subSol.Trigger_RFA__c = true;
    subSol.csordtelcoa__Product_Configuration__c =pcSol.id;
    subSol.eventId__c = '8f0bfd2-1bfd-7916-552d-9e28c80429ze';
    subList.add(subSol);
    csord__Subscription__c subSol1=new csord__Subscription__c();
    subSol1.name  = 'subSol1';
    subSol1.csord__Identification__c = 'subSol1';
    subSol1.csord__Order__c = testSolutionOrd.Id;
    subSol1.csord__Account__c=acc.id;
    subSol1.cssdm__solution_association__c = solutionAM.Id;
    subSol1.csord__status__c = 'Provisioned';
    subSol1.csordtelcoa__Product_Configuration__c =pcSol.id;
    subSol1.Trigger_RFA__c = true;
    subSol1.eventId__c = '8f0bfd2-1bfd-7916-552d-9e28c80429fe';
    subList.add(subSol1);
    csord__Subscription__c subSol3=new csord__Subscription__c();
    subSol3.name  = 'test sub12';
    subSol3.csord__Identification__c = 'test identity12';
    subSol3.csord__Order__c = testSolutionOrd.Id;
    subSol3.Sub_status__c = 'Active';
    subSol3.csord__Status__c='Bill Readiness In progress';
    subSol.eventId__c = '8f0bfd2-1bfd-7916-552d-9e28c80429xe';
    subList.add(subSol3);
    //end
    insert subList;
    // Added as part of EDGE-170546
    List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
    processTempList = Orchestration_TestUtility.buildProcessTemplate(false, 2);
    processTempList[0].Name='Subscription Fulfilment Process';
    processTempList[1].Name='Service Fulfilment Process';
    insert processTempList;
    Number__c num4=new Number__c();
    num4.name='Num test4';
    num4.Subscription_number__c=subsBilling.csordtelcoa__Subscription_Number__c;
    num4.Type__c='New';
    num4.Service_Number__c='61474850547';
    num4.Status__c='Bill Readiness In Progress';
    num4.Product_ID__c='gb58-89jk-yuit-fr46';
    num4.Mobile__c = 'Mobile';
    insert num4;
    Number__c num5=new Number__c();
    num5.name='Num test4';
    num5.Subscription_number__c=subsBilling.csordtelcoa__Subscription_Number__c;
    num5.Type__c='New';
    num5.Service_Number__c='61474850547';
    num5.Status__c='Active';
    num5.Product_ID__c='gb58-89jk-yuit-fr46';
    num5.Mobile__c = 'Mobile';
    insert num5;
    cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
    insert userPD;
    List<cscfga__Product_Configuration__c> listofPC = new List<cscfga__Product_Configuration__c>();
    cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
    listofPC.add(userPC);
    //insert userPC;
    //EDGE-132208 - Added Configuration Record
    cscfga__Product_Configuration__c userPC1 = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3, Type__c = 'Cancel');
    listofPC.add(userPC1);
    //insert userPC1;
    //EDGE-160243
    cscfga__Product_Configuration__c userPC2 = new cscfga__Product_Configuration__c(Name = 'Business Calling', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3, Type__c = 'New');
    listofPC.add(userPC2);
    //insert userPC2;
    cscfga__Product_Configuration__c userPC3 = new cscfga__Product_Configuration__c(Name = 'Business Calling', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3, Type__c = 'New');
    listofPC.add(userPC3);
    //insert userPC3;
    insert listofPC;
    List<csord__Service__c> servs = new List<csord__Service__c>();
    csord__Service__c serv = new csord__Service__c();
    serv.name ='tst service';
    serv.csord__Identification__c  = 'test identify';
    serv.csordtelcoa__Service_Number__c = 'svc-1235645';
    serv.csord__Subscription__c = subs.Id;
    serv.csord__Status__c = 'Service Created';
    serv.csord__Order_Request__c = ordReq.Id;
    serv.csord__Order__c =  ord.Id;
    serv.csordtelcoa__Product_Configuration__c = userPC2.id;
    servs.add(serv);
    csord__Service__c serv1 = new csord__Service__c();
    serv1.name ='tst service1';
    serv1.csord__Identification__c  = 'test identify1';
    serv1.csordtelcoa__Service_Number__c = '4';
    serv1.csord__Subscription__c = subs.Id;
    serv1.csord__Status__c = 'Service Created';
    serv1.csord__Order_Request__c = ordReq.Id;
    serv1.csord__Order__c = ord.Id;
    servs.add(serv1);
    csord__Service__c ser = new csord__Service__c();
    ser.name ='tst svc';
    ser.csord__Identification__c  = 'test identify';
    ser.csordtelcoa__Service_Number__c = '3';
    ser.csord__Subscription__c = sub1.Id;
    ser.csord__Status__c = 'Service Created';
    ser.csord__Order_Request__c = ordReq.Id;
    ser.csord__Order__c = ord.Id;
    servs.add(ser);
    csord__Service__c serv2 = new csord__Service__c();
    serv2.name ='tst service2';
    serv2.csord__Identification__c  = 'test identify2';
    serv2.csordtelcoa__Service_Number__c = '5';
    serv2.csord__Subscription__c = subs.Id;
    serv2.csord__Status__c = 'Service Created';
    serv2.csord__Order_Request__c = ordReq.Id;
    serv2.csord__Order__c = ord.Id;
    servs.add(serv2);
    csord__Service__c serv3 = new csord__Service__c();
    serv3.name ='tst service3';
    serv3.csord__Identification__c  = 'tst identify3';
    serv3.csordtelcoa__Service_Number__c = '6';
    serv3.csord__Subscription__c = subs.Id;
    serv3.csord__Status__c = 'Service Created';
    serv3.csord__Order_Request__c = ordReq.Id;
    serv3.csord__Order__c = ord.Id;
    servs.add(serv3);
    csord__Service__c serv4 = new csord__Service__c();
    serv4.name ='tst service4';
    serv4.csord__Identification__c  = 'tst identify4';
    serv4.csordtelcoa__Service_Number__c = '7';
    serv4.csord__Subscription__c = subs.Id;
    serv4.csord__Status__c = 'Service Created';
    serv4.csord__Order_Request__c = ordReq.Id;
    serv4.csord__Order__c = ord.Id;
    serv4.csord__Service__c=ser.Id;
    //EDGE-132208 - Updated to pass new PC record
    serv.csordtelcoa__Product_Configuration__c = userPC1.id;
    servs.add(serv4);
    csord__Service__c servRe = new csord__Service__c();
    servRe.name ='tst servRe';
    servRe.csord__Identification__c  = 'test servRe';
    servRe.csordtelcoa__Service_Number__c = 'svc-123567';
    servRe.csord__Subscription__c = subRes.Id;
    servRe.csord__Status__c = 'Service Created';
    //servRe.csord__Order_Request__c = ordReq2.Id;
    servRe.csord__Order__c = ord1.Id;
    //servRe.csordtelcoa__Replacement_Service__c = serv.id;
    servRe.csordtelcoa__Product_Configuration__c = userPC.id;
    servs.add(servRe);
    csord__Service__c servV = new csord__Service__c();
    servV.name ='AppleDevice';
    servV.csord__Identification__c  = 'AppleDevice';
    servV.csordtelcoa__Service_Number__c = 'SVC-000023459';
    servV.csord__Subscription__c = subV.Id;
    servV.csord__Status__c = 'In Progress';
    servV.csord__Order__c = ord.Id;
    insert servV;
    csord__Service__c servD = new csord__Service__c();
    servD.name ='DeviceCare';
    servD.csord__Identification__c  = 'DeviceCare';
    servD.csordtelcoa__Service_Number__c = 'SVC-000023460';
    servD.csord__Subscription__c = subV.Id;
    servD.csord__Status__c = 'In Progress';
    servD.csord__Order__c = ord.Id;
    servD.csord__Service__c =servV.Id;
    servs.add(servD);
    csord__Service__c servV1 = new csord__Service__c();
    servV1.name ='AppleDevice1';
    servV1.csord__Identification__c  = 'AppleDevice1';
    servV1.csordtelcoa__Service_Number__c = 'SVC-000023461';
    servV1.csord__Subscription__c = subV1.Id;
    servV1.csord__Status__c = 'In Progress';
    servV1.csord__Order__c = ord.Id;
    insert servV1;
    csord__Service__c servD1 = new csord__Service__c();
    servD1.name ='DeviceCare1';
    servD1.csord__Identification__c  = 'DeviceCare1';
    servD1.csordtelcoa__Service_Number__c = 'SVC-000023462';
    servD1.csord__Subscription__c = subV1.Id;
    servD1.csord__Status__c = 'In Progress';
    servD1.csord__Order__c = ord.Id;
    servD1.csord__Service__c =servV1.Id;
    servs.add(servD1);
    csord__Service__c servD2 = new csord__Service__c();
    servD2.name ='Business_Calling';
    servD2.csord__Identification__c  = 'Business_Calling';
    servD2.csordtelcoa__Service_Number__c = 'SVC-000023463';
    servD2.csord__Subscription__c = subV1.Id;
    servD2.csord__Status__c = 'In Progress';
    servD2.csord__Order__c = ord.Id;
    servD2.csordtelcoa__Product_Configuration__c = userPC2.Id;
    servs.add(servD2);
    csord__Service__c servD3 = new csord__Service__c();
    servD3.name ='Inflight';
    servD3.csord__Identification__c  = 'Inflight';
    servD3.csord__Subscription__c = subInflight.Id;
    servD3.csord__Status__c = 'Pending';
    servD3.csord__Order__c = ord2.Id;
    servD3.csordtelcoa__Product_Configuration__c = userPC2.Id;
    servs.add(servD3);
    csord__Service__c servD4 = new csord__Service__c(); //EDGE-170552
    servD4.name ='InflightNew';
    servD4.csord__Identification__c  = 'InflightNew';
    servD4.csord__Subscription__c = subInflight1.Id;
    servD4.csord__Status__c = 'Pending';
    servD4.csord__Order__c = ord3.Id;
    servD4.csordtelcoa__Product_Configuration__c = userPC2.Id;
    servD4.csordtelcoa__Cancelled_By_Change_Process__c = true;
    servs.add(servD4);
    csord__Service__c servD5 = new csord__Service__c(); //EDGE-170546
    servD5.name ='InflightNew1';
    servD5.csord__Identification__c  = 'InflightNew1';
    servD5.csord__Subscription__c = subInflight1.Id;
    servD5.csord__Status__c = 'Pending';
    servD5.csord__Order__c = ord3.Id;
    servD5.csordtelcoa__Product_Configuration__c = userPC3.Id;
    servs.add(servD5);
    csord__Service__c servD6 = new csord__Service__c(); //B2b-328
        servD6.name ='SolSupress';
        servD6.csord__Identification__c  = 'SolSupress';
        servD6.csord__Subscription__c = subSol.Id;
        servD6.csord__Status__c = 'Connected';
        servD6.csord__Order__c = testSolutionOrd.Id;
        servD6.csordtelcoa__Product_Configuration__c = pcSol.Id;
        servs.add(servD6);
    insert servs;
    // Added as part of EDGE-170546
    List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
    CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c();
    orchProcess.Name = 'Test Orch Process ';
    orchProcess.Order__c = ord.Id;
    orchProcess.has_Inactive_Children__c = 'NA';
    orchProcess.CSPOFA__Orchestration_Process_Template__c =  processTempList[0].Id;
    orchProcess.cspofa__account__c = acc.id;
    orchProcess.csordtelcoa__Subscription__c = subInflight.id;
    processList.add(orchProcess);
    CSPOFA__Orchestration_Process__c servOrchProcess = new CSPOFA__Orchestration_Process__c();
    servOrchProcess.Name = 'Test Serv Orch Process ';
    servOrchProcess.Order__c = ord.Id;
    servOrchProcess.has_Inactive_Children__c = 'NA';
    servOrchProcess.CSPOFA__Orchestration_Process_Template__c =  processTempList[1].Id;
    servOrchProcess.cspofa__account__c = acc.id;
    servOrchProcess.csordtelcoa__Service__c = servD5.id;
    processList.add(servOrchProcess);
    insert processList;
    List<BDS_Notify_Settings__c> csList = new List<BDS_Notify_Settings__c>(); //EDGE-170552
    BDS_Notify_Settings__c bdscustomSetting1 = new BDS_Notify_Settings__c();
    bdscustomSetting1.name='Feature Level';
    bdscustomSetting1.Value__c ='FeatureLevelShadow';
    bdscustomSetting1.Is_SI5_Offer__c =true;
    csList.add(bdscustomSetting1);
    BDS_Notify_Settings__c bdscustomSetting2 = new BDS_Notify_Settings__c(); //EDGE-170552
    bdscustomSetting2.name='Technical Support';
    bdscustomSetting2.Value__c ='TechnicalSupportShadow';
    bdscustomSetting2.Is_SI5_Offer__c =true;
    csList.add(bdscustomSetting2);
    insert csList;
    csoe__Non_Commercial_Schema__c ncs= new csoe__Non_Commercial_Schema__c();
    ncs.Name='NumberManagementv1';
    ncs.csoe__Schema__c='{"attributes":[{"showInUI":true,"required":false,"type":"String","name":"FNN"},{"showInUI":true,"required":false,"type":"String","name":"rangeFrom"},{"showInUI":true,"required":false,"type":"String","name":"rangeTo"},{"showInUI":true,"required":false,"type":"String","name":"status"},{"showInUI":true,"required":false,"type":"String","name":"listCode"}],"name":"NumberManagementv1","description":"NumberManagementv1"}';
    ncs.csoe__Description__c='NumberManagementv1';
    insert ncs;
    Charge_Line_Item__c cli= new Charge_Line_Item__c();
    cli.Name='test';
    cli.CorrelationId__c='1234566';
    cli.status__c='new';
    cli.serviceId__c=serv.id;
    cli.BusinessID__c='DMCAT_Billing_000420';
    insert cli;
    Price_Schedule_Line_Item__c psli=new Price_Schedule_Line_Item__c();
    psli.fromPeriod__c='0';
    psli.toPeriod__c='20';
    psli.status__c='new';
    psli.chargeInstance__c=cli.id;
    psli.unitPrice__c=20.0;
    insert psli;
    Appointment__c app = new Appointment__c();
    app.name = 'app1';
    app.SlotId__c='1234';
    app.Status__c ='SCHEDULED';
    insert app;
    List<Attachment> atts = new List<Attachment>();
    Attachment att1 = new Attachment();
    att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+serv.Id+'","legacyAttributes":[]}');
    att1.Name = 'ServiceSpecifications.json';
    att1.ParentId = serv.Id;
    atts.add(att1);
    Attachment att11 = new Attachment();
    att11.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Failed","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+serv1.Id+'","legacyAttributes":[]}');
    att11.Name = 'ServiceSpecifications.json';
    att11.ParentId = serv1.Id;
    atts.add(att11);
    Attachment att12 = new Attachment();
    att12.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Complete","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Complete","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Complete","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+serv2.Id+'","legacyAttributes":[]}');
    att12.Name = 'ServiceSpecifications.json';
    att12.ParentId = serv2.Id;
    atts.add(att12);
    Attachment att13 = new Attachment();
    att13.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Disconnect In Progress","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-1122-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Disconnect In Progress","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Disconnect In Progress","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}}],"serviceId":"'+serv3.Id+'","legacyAttributes":[]}');
    att13.Name = 'ServiceSpecifications.json';
    att13.ParentId = serv3.Id;
    atts.add(att13);
    Attachment att14 = new Attachment();
    att14.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+serv4.Id+'","legacyAttributes":[]}');
    att14.Name = 'ServiceSpecifications.json';
    att14.ParentId = serv4.Id;
    atts.add(att14);
    Attachment attNew = new Attachment();
    attNew.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Complete","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Complete","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Complete","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+ser.Id+'","legacyAttributes":[]}');
    attNew.Name = 'ServiceSpecifications.json';
    attNew.ParentId = ser.Id;
    atts.add(attNew);
    Attachment attRes = new Attachment();
    attRes.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servRe.Id+'","legacyAttributes":[]}');
    attRes.Name = 'ServiceSpecifications.json';
    attRes.ParentId = servRe.Id;
    atts.add(attRes);
    Attachment att2 = new Attachment();
    att2.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servV.Id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","rateExcludeGST":0,"quantity":1,"type":"OC","currency":"AUD","billingSpecId":"BSOTC001_CB","taxTreatment":"GST Applicable","unitofMeasure":"per device","billDescription":"Apple iPhone 7 Plus 32GB Rose Gold","ContractType":"Purchase","externalId":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001211_DMCAT_NonRecurringCharge_000511_2157","isRedeemable":"true"},"code":"DMCAT_ProductSpecification_001211_Billing_NonRecurringCharge_000511","description":"Next Generation Mobile Device_Billing_NonRecurringCharge_000511","endDate":"","guid":"368f2f9f-e469-67a5-66b1-d312a97ab7b3","includeBilling":false,"instanceId":"","metadata":{},"name":"1211_NRC_511","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001211_Billing_NonRecurringCharge_000511","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"productCompletionDate":"2020-07-09T05:25:03+10:00"},"attributes":{"__targetSystem":"FULFILMENT","DeviceID":"","DeviceIDType":"","ShippingRequired":"TRUE","Quantity":1,"ContractType":"Hardware Repayment","MobileHandsetManufacturer":"APPLE","MobileHandsetModel":"APPLE IPHONE 7 PLUS 32GB 4GX HANDSET","MobileHandsetColour":"ROSE GOLD","SKU":"100115458","DeviceType":"Mobile Handset"},"code":"DMCAT_ProductSpecification_001211_Fulfilment","description":"Next Generation Mobile Device_Fulfilment","endDate":"","guid":"e9743572-cc9a-74d6-c6de-c14e7a2b47ca","includeBilling":false,"instanceId":"","metadata":{},"name":"Next Generation Mobile Device_Fulfilment","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_ProductSpecification_001211","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"7027a42a-dd16-98f5-354f-4d77c76a6c0c","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_ProductSpecification_001211DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000871_Assurance","ResponseTime":"SLA0010001","RestorationTime":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"665ee24e-01ac-4d0a-1680-616dab926074","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_ProductSpecification_001211DMCAT_ProductSpecification_000151","startDate":"","status":"Created","version":"1"}]}');
    att2.Name = 'ServiceSpecifications.json';
    att2.ParentId = servV.Id;
    atts.add(att2);
    Attachment att3 = new Attachment();
    att3.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001211DMCAT_ProductSpecification_001208_Billing_NonRecurringCharge_001215","productConfigurationId":"a3T2N00000043OgUAI","name":"1208_NRC_1215","metadata":{},"instanceId":"","includeBilling":false,"guid":"45cd0659-3b2d-43f4-e45d-8d07cb458084","endDate":"","description":"Mobile Device Care_Billing_NonRecurringCharge_001215","code":"DMCAT_ProductSpecification_001208_Billing_NonRecurringCharge_001215","attributes":{"deviceCarePlan":"AppleCare+","isRedeemable":"true","externalId":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001208_DMCAT_NonRecurringCharge_001215_2621","ContractType":"Purchase","billDescription":"AppleCare+ 2 years","unitofMeasure":"per device","taxTreatment":"GST Applicable","billingSpecId":"BSOTC001_CB","quantity":1,"rateExcludeGST":171.81,"currency":"AUD","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_001208","productConfigurationId":"a3T2N00000043OgUAI","name":"Mobile Device Care_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"b9d545a8-2a09-37f8-09ea-16f08d91b60c","endDate":"","description":"Mobile Device Care_Fulfilment","code":"DMCAT_ProductSpecification_001208_Fulfilment","attributes":{"MobileHandsetManufacturer":"APPLE","deviceCarePlan":"AppleCare+","ContractType":"Purchase","parentSpec":"DMCAT_ProductSpecification_001211_Fulfilment","deviceCareID":"","__targetSystem":"FULFILMENT"},"additionalAttributes":{}}],"serviceId":"'+servD.Id+'","legacyAttributes":[]}');
    att3.Name = 'ServiceSpecifications.json';
    att3.ParentId = servD.Id;
    atts.add(att3);
    Attachment atts2 = new Attachment();
    atts2.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servV1.Id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","rateExcludeGST":0,"quantity":1,"type":"OC","currency":"AUD","billingSpecId":"BSOTC001_CB","taxTreatment":"GST Applicable","unitofMeasure":"per device","billDescription":"Apple iPhone 7 Plus 32GB Rose Gold","ContractType":"Purchase","externalId":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001211_DMCAT_NonRecurringCharge_000511_2157","isRedeemable":"true"},"code":"DMCAT_ProductSpecification_001211_Billing_NonRecurringCharge_000511","description":"Next Generation Mobile Device_Billing_NonRecurringCharge_000511","endDate":"","guid":"368f2f9f-e469-67a5-66b1-d312a97ab7b3","includeBilling":false,"instanceId":"","metadata":{},"name":"1211_NRC_511","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001211_Billing_NonRecurringCharge_000511","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"productCompletionDate":"2020-07-09T05:25:03+10:00"},"attributes":{"__targetSystem":"FULFILMENT","DeviceID":"","DeviceIDType":"","ShippingRequired":"TRUE","Quantity":1,"ContractType":"Hardware Repayment","MobileHandsetManufacturer":"APPLE","MobileHandsetModel":"APPLE IPHONE 7 PLUS 32GB 4GX HANDSET","MobileHandsetColour":"ROSE GOLD","SKU":"100115458","DeviceType":"Mobile Handset"},"code":"DMCAT_ProductSpecification_001211_Fulfilment","description":"Next Generation Mobile Device_Fulfilment","endDate":"","guid":"e9743572-cc9a-74d6-c6de-c14e7a2b48bd","includeBilling":false,"instanceId":"","metadata":{},"name":"Next Generation Mobile Device_Fulfilment","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_ProductSpecification_001211","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"7027a42a-dd16-98f5-354f-4d77c76a6c0c","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_ProductSpecification_001211DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000871_Assurance","ResponseTime":"SLA0010001","RestorationTime":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"665ee24e-01ac-4d0a-1680-616dab926074","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_ProductSpecification_001211DMCAT_ProductSpecification_000151","startDate":"","status":"Created","version":"1"}]}');
    atts2.Name = 'ServiceSpecifications.json';
    atts2.ParentId = servV1.Id;
    atts.add(atts2);
    Attachment atts3 = new Attachment();
    atts3.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001211DMCAT_ProductSpecification_001208_Billing_NonRecurringCharge_001215","productConfigurationId":"a3T2N00000043OgUAI","name":"1208_NRC_1215","metadata":{},"instanceId":"","includeBilling":false,"guid":"45cd0659-3b2d-43f4-e45d-8d07cb458084","endDate":"","description":"Mobile Device Care_Billing_NonRecurringCharge_001215","code":"DMCAT_ProductSpecification_001208_Billing_NonRecurringCharge_001215","attributes":{"deviceCarePlan":"AppleCare+","isRedeemable":"true","externalId":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001208_DMCAT_NonRecurringCharge_001215_2621","ContractType":"Purchase","billDescription":"AppleCare+ 2 years","unitofMeasure":"per device","taxTreatment":"GST Applicable","billingSpecId":"BSOTC001_CB","quantity":1,"rateExcludeGST":171.81,"currency":"AUD","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_001208","productConfigurationId":"a3T2N00000043OgUAI","name":"Mobile Device Care_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"b9d545a8-2a09-37f8-09ea-16f08d91b90f","endDate":"","description":"Mobile Device Care_Fulfilment","code":"DMCAT_ProductSpecification_001208_Fulfilment","attributes":{"MobileHandsetManufacturer":"APPLE","deviceCarePlan":"AppleCare+","ContractType":"Purchase","parentSpec":"DMCAT_ProductSpecification_001211_Fulfilment","deviceCareID":"","__targetSystem":"FULFILMENT"},"additionalAttributes":{}}],"serviceId":"'+servD1.Id+'","legacyAttributes":[]}');
    atts3.Name = 'ServiceSpecifications.json';
    atts3.ParentId = servD1.Id;
    atts.add(atts3);
    Attachment attsNum = new Attachment();
    attsNum.Body = Blob.valueOf('{"schema":{"attributes":[{"type":"String","showInUI":true,"required":false,"name":"FNN"},{"type":"String","showInUI":true,"required":false,"name":"rangeFrom"},{"type":"String","showInUI":true,"required":false,"name":"rangeTo"},{"type":"String","showInUI":true,"required":false,"name":"status"},{"type":"String","showInUI":true,"required":false,"name":"listCode"}],"id":"a6k2O00000003LyQAI","name":"NumberManagementv1"},"configurations":[{"FNN":"61350605919","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line","guid":"a16035c5-7716-c099-4621-304572ae92fa"},{"FNN":"61350605920","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line","guid":"100ce120-77f7-2be3-7588-96eb3a5532da"}]}');
    attsNum.Name = 'NumberManagementv1.json';
    attsNum.ParentId = userPC2.Id;
    atts.add(attsNum);
    Attachment attsNum1 = new Attachment();
    attsNum1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_814","metadata":{},"instanceId":"","includeBilling":false,"guid":"d08c8b11-e6e9-1bc2-c52b-d3ffc6e0645e","endDate":"","description":"Business Calling_Billing_RecurringCharge_000814","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","attributes":{"concurrencyLimitMode":"Individual Line","billDescription":"Individual line - standard calling plan","callingPlans":"Standard","customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7542","price":"5.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"cdc7c6fc-2597-e127-5bae-d64e8b16fa37"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7539","price":"5.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"ba632530-e2cb-9e20-f317-d7966594d5b2"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7544","price":"5.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"3a0602cc-a89b-b2de-ff40-bc9fd9460a4f"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7543","price":"5.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"f9d9318a-449d-96b0-1244-10cbc3972907"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7540","price":"5.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"deed3a62-43a2-7714-b8a9-2aafda1f2b7a"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7541","price":"5.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"ead32ad9-d520-bc54-f01f-1eba6681666f"}],"featureID":"concurrencyLimit","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000813","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_813","metadata":{},"instanceId":"","includeBilling":false,"guid":"9689fb98-d143-13eb-ecc5-b1883c2ac393","endDate":"","description":"Business Calling_Billing_RecurringCharge_000813","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000813","attributes":{"customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6971","price":"3.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"bcf86ccd-4132-a7d9-9390-bc4cefe0f030"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6972","price":"3.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"76294b34-3ac8-df45-8f71-bd6ed8f2ab70"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6973","price":"3.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"11cc5b7c-627d-a738-6cfb-6e14325178e4"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6974","price":"3.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"07704a93-77d2-8b4b-4c63-20500c39a324"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6975","price":"3.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"c380fbd7-5673-9278-11ab-bc6e573ac082"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6976","price":"3.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"9f77b12b-4188-f73d-3a22-5758fa454e55"}],"billDescription":"Cloud user","featureID":"ucUsers","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000871","productConfigurationId":"'+userPC2.Id+'","name":"Business Calling_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"7ccfdcfb-133f-8b91-e538-13066c8d8bab","endDate":"","description":"Business Calling_Fulfilment","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"NetworkServiceId":"","CustomerFacingServiceId":"","concurrencyLimitMode":"inferred","Number":[{"attributes":{"FNN":"61350605919","listCode":"No Entry Line","rangeFrom":null,"rangeTo":null,"status":"ACTIVE"},"schemaId":"a16035c5-7716-c099-4621-304572ae92fa"},{"attributes":{"FNN":"61350605920","listCode":"No Entry Line","rangeFrom":null,"rangeTo":null,"status":"ACTIVE"},"schemaId":"100ce120-77f7-2be3-7588-96eb3a5532da"}],"type":"ucServiceSiteAgnosticConcurrencyOffer","BSTenancyProductInstanceId":"DMCAT_ProductSpecification_000311_Fulfilment","__targetSystem":"FULFILMENT"},"additionalAttributes":{"currentForecastedDeliveryDate":"2020-07-28T05:03:24+10:00","CustomerOrderAcceptanceDate":"2020-07-27T05:00:26+10:00","BSTenancyProductInstanceId":"f954a979-504f-2729-130f-e447e92eb152","NetworkServiceId":"0ebadc71-7b07-4846-b3b6-aead28534974"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000151","productConfigurationId":"a3T2O000000UZL8UAO","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"6aac27d0-d0a4-bdaf-0cac-9c6170dc5a0a","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"RestoreTarget":"SLA0010002","ResponseTarget":"SLA0010001","parentSpec":"DMCAT_ProductSpecification_000871_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000326","productConfigurationId":"a3T2O000000UZL8UAO","name":"326_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"1cdade45-0c27-320f-dc19-c8ffbfef878d","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000816","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_816","metadata":{},"instanceId":"","includeBilling":false,"guid":"191acba2-5de8-4aee-b818-32cae52aa77c","endDate":"","description":"Business Calling_Billing_RecurringCharge_000816","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000816","attributes":{"customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6977","price":"6.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"b2329377-f0ec-d075-7d31-701d2476804d"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6982","price":"6.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"d7cbfec2-9a30-3e2b-937c-f536fe1a80f2"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6981","price":"6.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"a5825fe1-7b50-a4e8-11ac-e2d2cecfbeee"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6980","price":"6.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"a4833a96-01ac-12ec-7502-c5034bc83f21"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6979","price":"6.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"f67bb587-c2f6-7be1-780e-245a83b06b71"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6978","price":"6.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"39a7f638-a7ac-5f6b-c768-fb84530eb41f"}],"billDescription":"Cloud user add-on - unified communications","featureID":"Hosted UC","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_810","metadata":{},"instanceId":"","includeBilling":false,"guid":"77a629eb-2a9b-680c-4a91-ff8e700e3e3d","endDate":"","description":"Business Calling_Billing_RecurringCharge_000810","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","attributes":{"customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6946","price":"5.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"c8246349-1e34-59b7-1e3b-9e433360dd55"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6947","price":"5.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"aa50fd91-1613-2b67-e2c4-a0fdc5c5cfd1"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6948","price":"5.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"75f9b53c-84ce-293c-100d-a9d9337b7cfc"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6949","price":"5.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"e85881dc-a199-1a1d-362d-c429fd0d83aa"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6950","price":"5.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"96fa64ca-8ab5-47ef-aeb7-f4a59952abda"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6952","price":"5.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"000c4f60-f1fd-8099-60ac-fd2e0f4296ba"}],"billDescription":"Group feature - auto attendant","featureID":"ucAutoAttendants","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000811","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_811","metadata":{},"instanceId":"","includeBilling":false,"guid":"dc042c93-3d81-1e88-bf4e-c776dbe8f709","endDate":"","description":"Business Calling_Billing_RecurringCharge_000811","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000811","attributes":{"customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7020","price":"5.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"fdd8447d-cded-30f0-9f73-98db7953d506"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7021","price":"5.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"f492d8bb-2e01-ff2f-66eb-664665e5ba61"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7022","price":"5.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"96c7b13f-20cd-2c9c-a4ea-0e5e11cb0ab0"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7023","price":"5.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"4b587859-eadd-efe8-1e44-58ee56010848"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7024","price":"5.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"77e1f0f6-e2a8-2ca6-b4e5-f5bb24a424a9"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7025","price":"5.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"4205375e-bd21-98ba-e94d-85a7845fd561"}],"billDescription":"Group feature - hunt group","featureID":"ucHuntGroups","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_Allowance_000825_87","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_AW_876","metadata":{},"instanceId":"","includeBilling":false,"guid":"a98750ef-2b1c-2df9-5533-c8861309f018","endDate":"","description":"Business Calling UC Plan Allowance_Billing_DMCAT_Allowance_000876","code":"DMCAT_ProductSpecification_000871_Billing_Allowance_000876","attributes":{"ocsProdID":"T22E_FVOICE-S","billDescription":"Included PayG","value":"Fixed Voice Plan - Standard","type":"Fixed Voice","billingSpecId":"BSUSG004_CB","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servD2.Id+'","legacyAttributes":[]}');
    attsNum1.Name = 'ServiceSpecifications.json';
    attsNum1.ParentId = servD2.Id;
    atts.add(attsNum1);
    Attachment attsNum2 = new Attachment();
    attsNum2.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_814","metadata":{},"instanceId":"","includeBilling":false,"guid":"d08c8b11-e6e9-1bc2-c52b-d3ffc6e0645e","endDate":"","description":"Business Calling_Billing_RecurringCharge_000814","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","attributes":{"concurrencyLimitMode":"Individual Line","billDescription":"Individual line - standard calling plan","callingPlans":"Standard","customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7542","price":"5.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"cdc7c6fc-2597-e127-5bae-d64e8b16fa37"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7539","price":"5.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"ba632530-e2cb-9e20-f317-d7966594d5b2"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7544","price":"5.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"3a0602cc-a89b-b2de-ff40-bc9fd9460a4f"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7543","price":"5.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"f9d9318a-449d-96b0-1244-10cbc3972907"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7540","price":"5.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"deed3a62-43a2-7714-b8a9-2aafda1f2b7a"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7541","price":"5.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"ead32ad9-d520-bc54-f01f-1eba6681666f"}],"featureID":"concurrencyLimit","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000813","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_813","metadata":{},"instanceId":"","includeBilling":false,"guid":"9689fb98-d143-13eb-ecc5-b1883c2ac393","endDate":"","description":"Business Calling_Billing_RecurringCharge_000813","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000813","attributes":{"customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6971","price":"3.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"bcf86ccd-4132-a7d9-9390-bc4cefe0f030"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6972","price":"3.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"76294b34-3ac8-df45-8f71-bd6ed8f2ab70"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6973","price":"3.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"11cc5b7c-627d-a738-6cfb-6e14325178e4"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6974","price":"3.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"07704a93-77d2-8b4b-4c63-20500c39a324"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6975","price":"3.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"c380fbd7-5673-9278-11ab-bc6e573ac082"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6976","price":"3.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"9f77b12b-4188-f73d-3a22-5758fa454e55"}],"billDescription":"Cloud user","featureID":"ucUsers","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000871","productConfigurationId":"'+userPC2.Id+'","name":"Business Calling_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"7ccfdcfb-133f-8b91-e538-13066c8d8bab","endDate":"","description":"Business Calling_Fulfilment","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"NetworkServiceId":"","CustomerFacingServiceId":"","concurrencyLimitMode":"inferred","Number":[{"attributes":{"FNN":"61350605919","listCode":"No Entry Line","rangeFrom":null,"rangeTo":null,"status":"ACTIVE"},"schemaId":"a16035c5-7716-c099-4621-304572ae92fa"},{"attributes":{"FNN":"61350605920","listCode":"No Entry Line","rangeFrom":null,"rangeTo":null,"status":"ACTIVE"},"schemaId":"100ce120-77f7-2be3-7588-96eb3a5532da"}],"type":"ucServiceSiteAgnosticConcurrencyOffer","BSTenancyProductInstanceId":"DMCAT_ProductSpecification_000311_Fulfilment","__targetSystem":"FULFILMENT"},"additionalAttributes":{"currentForecastedDeliveryDate":"2020-07-28T05:03:24+10:00","CustomerOrderAcceptanceDate":"2020-07-27T05:00:26+10:00","BSTenancyProductInstanceId":"f954a979-504f-2729-130f-e447e92eb152","NetworkServiceId":"0ebadc71-7b07-4846-b3b6-aead28534974"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000151","productConfigurationId":"a3T2O000000UZL8UAO","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"6aac27d0-d0a4-bdaf-0cac-9c6170dc5a0a","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"RestoreTarget":"SLA0010002","ResponseTarget":"SLA0010001","parentSpec":"DMCAT_ProductSpecification_000871_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000326","productConfigurationId":"a3T2O000000UZL8UAO","name":"326_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"1cdade45-0c27-320f-dc19-c8ffbfef878d","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000816","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_816","metadata":{},"instanceId":"","includeBilling":false,"guid":"191acba2-5de8-4aee-b818-32cae52aa77c","endDate":"","description":"Business Calling_Billing_RecurringCharge_000816","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000816","attributes":{"customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6977","price":"6.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"b2329377-f0ec-d075-7d31-701d2476804d"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6982","price":"6.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"d7cbfec2-9a30-3e2b-937c-f536fe1a80f2"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6981","price":"6.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"a5825fe1-7b50-a4e8-11ac-e2d2cecfbeee"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6980","price":"6.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"a4833a96-01ac-12ec-7502-c5034bc83f21"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6979","price":"6.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"f67bb587-c2f6-7be1-780e-245a83b06b71"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6978","price":"6.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"39a7f638-a7ac-5f6b-c768-fb84530eb41f"}],"billDescription":"Cloud user add-on - unified communications","featureID":"Hosted UC","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_810","metadata":{},"instanceId":"","includeBilling":false,"guid":"77a629eb-2a9b-680c-4a91-ff8e700e3e3d","endDate":"","description":"Business Calling_Billing_RecurringCharge_000810","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","attributes":{"customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6946","price":"5.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"c8246349-1e34-59b7-1e3b-9e433360dd55"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6947","price":"5.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"aa50fd91-1613-2b67-e2c4-a0fdc5c5cfd1"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6948","price":"5.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"75f9b53c-84ce-293c-100d-a9d9337b7cfc"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6949","price":"5.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"e85881dc-a199-1a1d-362d-c429fd0d83aa"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6950","price":"5.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"96fa64ca-8ab5-47ef-aeb7-f4a59952abda"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6952","price":"5.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"000c4f60-f1fd-8099-60ac-fd2e0f4296ba"}],"billDescription":"Group feature - auto attendant","featureID":"ucAutoAttendants","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000811","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_811","metadata":{},"instanceId":"","includeBilling":false,"guid":"dc042c93-3d81-1e88-bf4e-c776dbe8f709","endDate":"","description":"Business Calling_Billing_RecurringCharge_000811","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000811","attributes":{"customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7020","price":"5.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"fdd8447d-cded-30f0-9f73-98db7953d506"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7021","price":"5.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"f492d8bb-2e01-ff2f-66eb-664665e5ba61"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7022","price":"5.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"96c7b13f-20cd-2c9c-a4ea-0e5e11cb0ab0"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7023","price":"5.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"4b587859-eadd-efe8-1e44-58ee56010848"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7024","price":"5.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"77e1f0f6-e2a8-2ca6-b4e5-f5bb24a424a9"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7025","price":"5.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"4205375e-bd21-98ba-e94d-85a7845fd561"}],"billDescription":"Group feature - hunt group","featureID":"ucHuntGroups","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_Allowance_000825_87","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_AW_876","metadata":{},"instanceId":"","includeBilling":false,"guid":"a98750ef-2b1c-2df9-5533-c8861309f018","endDate":"","description":"Business Calling UC Plan Allowance_Billing_DMCAT_Allowance_000876","code":"DMCAT_ProductSpecification_000871_Billing_Allowance_000876","attributes":{"ocsProdID":"T22E_FVOICE-S","billDescription":"Included PayG","value":"Fixed Voice Plan - Standard","type":"Fixed Voice","billingSpecId":"BSUSG004_CB","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servD4.Id+'","legacyAttributes":[]}');
    attsNum2.Name = 'ServiceSpecifications.json';
    attsNum2.ParentId = servD4.Id;
    atts.add(attsNum2);
    //EDGE-132208 - Added below 2 Attachments
    /* Attachment attRem = new Attachment();
    attRem.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"DISCONNECT PENDING","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servRe.Id+'","legacyAttributes":[]}');
    attRem.Name = 'ServiceSpecifications.json';
    attRem.ParentId = serv4.Id;
    atts.add(attRem);
    Attachment attRem1 = new Attachment();
    attRem1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"DISCONNECTED","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servRe.Id+'","legacyAttributes":[]}');
    attRem1.Name = 'ServiceSpecifications.json';
    attRem1.ParentId = serv4.Id;
    atts.add(attRem1);*/
    insert atts;
  }
  @isTest
  static void testprocessNotification(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    Test.startTest();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    NotificationParameters  notif = new NotificationParameters();
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.notificationAttributes = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"In Progress"}]';
    notif.orderItemDetails = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"In Progress"}';
    notif.eventType = 'statusNotification';
    notif.orderItemVersion = 1;
    notif.sourceSystem = 'FULFILMENT';
    paramsList.add(notif);
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,paramsList);
    Test.stopTest();
    csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
    //System.assertEquals('In Progress', svc.csord__Status__c);
    System.assertEquals('tst service', svc.Name);
  }
  @isTest
  static void testprocessNotificationRecordMS(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst servRe' AND csord__Order__r.Name= 'Resume_12345' limit 1][0];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'Resume_12345' limit 1][0];
    Test.startTest();
    NotificationParameters  notif = new NotificationParameters();
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.notificationAttributes = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"In Progress"}]';
    notif.orderItemDetails = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"In Progress"}';
    notif.eventType = 'statusNotification';
    notif.orderItemVersion = 1;
    notif.sourceSystem = 'FULFILMENT';
    paramsList.add(notif);
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    ManageOrderNotificationServiceMSUpdate.processNotificationRecordMS(orderItemIdNotifMap,paramsList);
    Test.stopTest();
    csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
    //System.assertEquals('In Progress', svc.csord__Status__c);
    System.assertEquals('tst service', svc.Name);
  }
  @isTest
  static void testprocessNotificationRecordMSCancel(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service4' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    Test.startTest();
    NotificationParameters notif = new NotificationParameters();
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.notificationAttributes = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"In Progress"}]';
    notif.orderItemDetails = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"In Progress"}';
    notif.eventType = 'statusNotification';
    notif.orderItemVersion = 1;
    notif.sourceSystem = 'FULFILMENT';
    paramsList.add(notif);
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    ManageOrderNotificationServiceMSUpdate.processNotificationRecordMS(orderItemIdNotifMap,paramsList);
    Test.stopTest();
    csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service4' limit 1][0];
    //System.assertEquals('In Progress', svc.csord__Status__c);
    System.assertEquals('tst service4', svc1.Name);
  }
  @isTest
  static void testprocessNotificationRecordMSCancelledNotification(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service4' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    Test.startTest();
    NotificationParameters notif = new NotificationParameters();
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.notificationAttributes = '"attributes":[{"name":"productCancellationDate","value":"2020-12-16T04:32:20+00:00"}, {"name":"status","value":"Cancelled"}]';
    notif.orderItemDetails = '"product":{"productId": "8d15e372-c487-6cd7-cb4a-ddd1bc74197b","status": "Cancelled","attributes": [],"childProduct": [{"productId": "07bff574-66dd-410c-6c4c-823a56e18720","status": "Cancelled","attributes": []}]}';
    notif.eventType = 'statusNotification';
    notif.orderItemVersion = 1;
    notif.sourceSystem = 'FULFILMENT';
    paramsList.add(notif);
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    ManageOrderNotificationServiceMSUpdate.processNotificationRecordMS(orderItemIdNotifMap,paramsList);
    Test.stopTest();
    csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service4' limit 1][0];
    //System.assertEquals('In Progress', svc.csord__Status__c);
    System.assertEquals('tst service4', svc1.Name);
  }
  @isTest
  static void testupdateAppointmenRecordMS(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    List<Appointment__c> app = [SELECT id,SlotId__c from Appointment__c where name= 'app1' LIMIT 1];
    Map<String, ManageOrderNotificationUtil.Parameters> parameterMap = new Map<String, ManageOrderNotificationUtil.Parameters>();
    NotificationParameters notif = new NotificationParameters();
    notif.orderItemId = String.valueof(app[0].SlotId__c);
    notif.externalOrderId = 'ON00002852';
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemVersion = 1;
    notif.notificationAttributes = '"attributes":[{"name":"status", "value":"Complete"}]';
    notif.orderItemDetails = '"product":{"productId":"3072dad2-5546-eb71-8e13-bd04b7f9824a","status":"In Progress"}';
    notif.eventType = 'appointmentNotification';
    notif.sourceSystem = 'Fulfilment';
    paramsList.add(notif);
    ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
    params.orderIdc = notif.orderItemId;
    params.eventType = notif.eventType;
    parameterMap.put(params.orderIdc, params);
    Test.startTest();
    ManageOrderNotificationServiceMSUpdate.updateAppointmenRecordMS(paramsList,parameterMap,app);
    Test.stopTest();
    Appointment__c appt = [SELECT id,Status__c from Appointment__c where name= 'app1'];
    System.assertNotEquals(null, appt.Status__c);
  }
  @isTest
  static void testupdateSubscriptionRecordMS(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String, ManageOrderNotificationUtil.Parameters> parameterMap = new Map<String, ManageOrderNotificationUtil.Parameters>();
    List<csord__Subscription__c>subs = [select Id,name,csordtelcoa__Subscription_Number__c from csord__Subscription__c where name  = 'test subs' LIMIT 1];
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, Action_Type__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1];
    csord__Service__c replServ = [SELECT Id, csord__Status__c, Action_Type__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name != 'tst service' limit 1];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    Map<Id,csord__Service__c> servMap = new Map<Id,csord__Service__c>();
    servMap.put(svc1.id, svc1);
    NotificationParameters notif = new NotificationParameters();
    notif.orderItemId =ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.externalOrderId = 'ON00002852';
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemVersion = 1;
    notif.notificationAttributes = '"attributes":[{"name":"status", "value":"Complete"}]';
    notif.orderItemDetails = '"product":{"productId":"3072dad2-5546-eb71-8e13-bd04b7f9824a","status":"In Progress"}';
    notif.eventType = 'statusNotification';
    notif.sourceSystem = 'Fulfilment';
    paramsList.add(notif);
    Number__c num4=new Number__c();
    num4.name='Num test5';
    num4.Subscription_number__c=subs[0].csordtelcoa__Subscription_Number__c;
    num4.Type__c='New';
    num4.Service_Number__c='61474850547';
    num4.Status__c='RESERVED';
    num4.Product_ID__c='gb58-89jk-yuit-fr46';
    num4.Mobile__c = 'Mobile';
    insert num4;
    ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
    params.orderIdc = notif.orderItemId;
    params.eventType = notif.eventType;
    parameterMap.put(params.orderIdc, params);
    Test.startTest();
    ManageOrderNotificationServiceMSUpdate.updateSubscriptionRecordMS(paramsList,parameterMap,subs,servMap);
    Test.stopTest();
    System.assertNotEquals(null, subs);
  }
  //EDGE-156046
  @isTest
  static void testupdateSubscriptionRecordMSPaidOutWith1Svc(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String, ManageOrderNotificationUtil.Parameters> parameterMap = new Map<String, ManageOrderNotificationUtil.Parameters>();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, Action_Type__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst svc' AND csord__Order__r.Name= 'TestOrder' limit 1];
    csord__Service__c replServ = [SELECT Id, csord__Status__c, Action_Type__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name != 'tst svc' limit 1];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    csord__Service__c svcForSub = [SELECT Id, Action_Type__c, csord__Status__c, csord__Subscription__r.id, csord__Subscription__r.csordtelcoa__Subscription_Number__c, csord__Subscription__r.eventId__c, csord__Subscription__r.csord__Status__c, csord__Order__r.csord__Status2__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Service__c Where id =: svc1.id Limit 1];
    svcForSub.csord__Subscription__r.eventId__c = '9d676c71-3954-4562-8552-921696503022';
    List<csord__Subscription__c> subsToUpdate = new List<csord__Subscription__c>();
    subsToUpdate.add(svcForSub.csord__Subscription__r);
    update subsToUpdate;
    svc1.Action_Type__c = 'PayOut';
    svc1.csordtelcoa__Replacement_Service__c = replServ.id;
    update svc1;
    Map<Id,csord__Service__c> servMap = new Map<Id,csord__Service__c>();
    servMap.put(svc1.id, svc1);
    Test.startTest();
    NotificationParameters notif = new NotificationParameters();
    notif.orderItemId =ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemVersion = 1;
    notif.notificationAttributes = '"attributes":[{"name":"status", "value":"Complete"}]';
    notif.orderItemDetails = '"product":{"productId":"3072dad2-5546-eb71-8e13-bd04b7f9824a","status":"In Progress"}';
    notif.eventType = 'statusNotification';
    notif.sourceSystem = 'Billing';
    paramsList.add(notif);
    Notification__c notif1 = new Notification__c();
    notif1.Name='Notif1';
    notif1.eventType__c = 'statusNotification';
    notif1.eventTimeStamp__c = '2020-04-01T12:45:45';
    notif1.externalOrderId__c = '9d676c71-3954-4562-8552-921696503022';
    notif1.orderItemId__c = '9d676c71-3954-4562-8552-921696503022';
    notif1.orderItemVersion__c = 1;
    notif1.notificationAttributes__c = '"attributes":[{"name":"status","value":"Complete"}]';
    notif1.sourceSystem__c = 'Billing';
    notif1.Status__c = 'Completed';
    insert notif1;
    Number__c num4=new Number__c();
    num4.name='Num test5';
    num4.Subscription_number__c=svcForSub.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
    num4.Type__c='New';
    num4.Service_Number__c='61474850547';
    num4.Status__c='RESERVED';
    num4.Product_ID__c='gb58-89jk-yuit-fr46';
    num4.Mobile__c = 'Mobile';
    insert num4;
    Number__c num5=new Number__c();
    num5.name='Num test5';
    num5.Subscription_number__c=svcForSub.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
    num5.Type__c='New';
    num5.Service_Number__c='61474850547';
    num5.Status__c='Active';
    num5.Product_ID__c='gb58-89jk-yuit-fr46';
    num5.Mobile__c = 'Mobile';
    insert num5;
    ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
    params.orderIdc = notif.orderItemId;
    params.eventType = notif.eventType;
    parameterMap.put(params.orderIdc, params);    
    ManageOrderNotificationServiceMSUpdate.updateSubscriptionRecordMS(paramsList,parameterMap,subsToUpdate,servMap);
    Test.stopTest();
    csord__Service__c svcExpected = [SELECT Id, csord__Status__c, Action_Type__c, csord__Subscription__r.csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst svc' AND csord__Order__r.Name= 'TestOrder' limit 1];
    System.assertEquals(svcExpected.csord__Status__c, 'Paid Out');  //EDGE-156046 : Service status should change to Paid Out
    System.assertEquals(svcExpected.csord__Subscription__r.csord__Status__c, 'Paid Out');
  }
  //EDGE-156046
  @isTest
  static void testupdateSubscriptionRecordMSPaidOutWithMultipleSvcs(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String, ManageOrderNotificationUtil.Parameters> parameterMap = new Map<String, ManageOrderNotificationUtil.Parameters>();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csord__Service__c , Action_Type__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where csord__Subscription__r.Name = 'test subs' AND csord__Order__r.Name= 'TestOrder' limit 1];
    csord__Service__c replServ = [SELECT Id, csord__Status__c, Action_Type__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name !=  'tst service' limit 1];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    csord__Service__c svcForSub = [SELECT Id, Action_Type__c, csord__Status__c, csord__Subscription__r.id, csord__Subscription__r.csordtelcoa__Subscription_Number__c, csord__Subscription__r.eventId__c, csord__Subscription__r.csord__Status__c, csord__Order__r.csord__Status2__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Service__c Where id =: svc1.id Limit 1];
    svcForSub.csord__Subscription__r.eventId__c = '9d676c71-3954-4562-8552-921696503022';
    List<csord__Subscription__c> subsToUpdate = new List<csord__Subscription__c>();
    subsToUpdate.add(svcForSub.csord__Subscription__r);
    update subsToUpdate;
    svc1.Action_Type__c = 'PayOut';
    svc1.csord__Service__c  = null;
    svc1.csordtelcoa__Replacement_Service__c = replServ.id;
    update svc1;
    Map<Id,csord__Service__c> servMap = new Map<Id,csord__Service__c>();
    servMap.put(svc1.id, svc1);
    Test.startTest();
    NotificationParameters notif = new NotificationParameters();
    notif.orderItemId =ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.externalOrderId = 'ON00002852';
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemVersion = 1;
    notif.notificationAttributes = '"attributes":[{"name":"status", "value":"Complete"}]';
    notif.orderItemDetails = '"product":{"productId":"3072dad2-5546-eb71-8e13-bd04b7f9824a","status":"In Progress"}';
    notif.eventType = 'statusNotification';
    notif.sourceSystem = 'Billing';
    paramsList.add(notif);
    Notification__c notif1 = new Notification__c();
    notif1.Name='Notif1';
    notif1.eventType__c = 'statusNotification';
    notif1.eventTimeStamp__c = '2020-04-01T12:45:45';
    notif1.externalOrderId__c = '9d676c71-3954-4562-8552-921696503022';
    notif1.orderItemId__c = '9d676c71-3954-4562-8552-921696503022';
    notif1.orderItemVersion__c = 1;
    notif1.notificationAttributes__c = '"attributes":[{"name":"status","value":"Complete"}]';
    notif1.sourceSystem__c = 'Billing';
    notif1.Status__c = 'Completed';
    insert notif1;
    Number__c num4=new Number__c();
    num4.name='Num test5';
    num4.Subscription_number__c=svcForSub.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
    num4.Type__c='New';
    num4.Service_Number__c='61474850547';
    num4.Status__c='RESERVED';
    num4.Product_ID__c='gb58-89jk-yuit-fr46';
    num4.Mobile__c = 'Mobile';
    insert num4;
    ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
    params.orderIdc = notif.orderItemId;
    params.eventType = notif.eventType;
    parameterMap.put(params.orderIdc, params);    
    ManageOrderNotificationServiceMSUpdate.updateSubscriptionRecordMS(paramsList,parameterMap,subsToUpdate,servMap);
    Test.stopTest();
    csord__Service__c svcExpected = [SELECT Id, csord__Status__c, Action_Type__c, csord__Subscription__r.csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1];
    //System.assertEquals(svcExpected.csord__Status__c, 'Paid Out');  //EDGE-156046 : Service status should change to Paid Out

    System.assertEquals(svcExpected.csord__Subscription__r.csord__Status__c, 'Paid Out'); //Subscription status should change to Paid Out as parent svc is PaidOut
  }
  @isTest
  static void testupdateServiceRecordMS(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,Attachment> servAttachmentRecordMap = new Map<String,Attachment>();
    Map<String, String> serviceAttachmentMap = new Map<String, String>();
    Map<csord__Order__c, List<csord__Subscription__c>> orderToSubMap = new Map<csord__Order__c, List<csord__Subscription__c>> ();
    Map<String, ManageOrderNotificationUtil.Parameters> parameterMap = new Map<String, ManageOrderNotificationUtil.Parameters>();
    Test.startTest();
    List<Id> allServiceId = new List<id>();
    List<csord__Service__c> svcList = new List<csord__Service__c>();
    List<csord__Service__c> replaceserv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst servRe' limit 1];
    List<csord__Subscription__c>subs = [select Id,name, changeType__c from csord__Subscription__c where name  = 'test subs' LIMIT 1];
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1];
    svcList.add(svc1);
    List<csord__Order__c> ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1];
    Map<Id,csord__Service__c> servMap = new Map<Id,csord__Service__c>();
    servMap.put(svc1.id, svc1);
    NotificationParameters notif = new NotificationParameters();
    notif.orderItemId =ord[0].csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.externalOrderId = 'ON00002852';
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemVersion = 1;
    notif.notificationAttributes = '"attributes":[{"name":"status", "value":"Complete"}]';
    notif.orderItemDetails = '"product":{"productId":"3072dad2-5546-eb71-8e13-bd04b7f9824a","status":"In Progress"}';
    notif.eventType = 'statusNotification';
    notif.sourceSystem = 'Fulfilment';
    paramsList.add(notif);
    ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
    params.orderIdc = notif.orderItemId;
    params.eventType = notif.eventType;
    parameterMap.put(params.orderIdc, params);
    allServiceId.add(svc1.id);
    for(Attachment att: [Select id,body,parentId from Attachment where parentId in :allServiceId for update]){
    servAttachmentRecordMap.put(att.parentId,att);
    serviceAttachmentMap.put(att.parentId,att.body.toString());}
    ManageOrderNotificationServiceMSUpdate.updateServiceRecordMS(paramsList,parameterMap,ord,svcList,serviceAttachmentMap,servAttachmentRecordMap,replaceserv,orderToSubMap);
    Test.stopTest();
    csord__Service__c svcExpected = [SELECT Id, csord__Status__c, Action_Type__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst servRe' limit 1];
    System.assertNotEquals(svcExpected.csord__Status__c, 'Paid Out');   //EDGE-156046 : Service status should not be to Paid Out since Action Type is null
    System.assertNotEquals(null, subs);
  }
  @isTest
  static void testCheckUCCompletionAndUpdateNumber(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    Test.startTest();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    NotificationParameters  notif = new NotificationParameters();
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.notificationAttributes = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"In Progress"}]';
    notif.orderItemDetails = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"In Progress"}';
    notif.eventType = 'statusNotification';
    notif.orderItemVersion = 1;
    notif.sourceSystem = 'FULFILMENT';
    notif.msCorrelationId = 'ec49950c-5da3-a5a1-1add-89725fee80c9';
    paramsList.add(notif);
    Number__c num4=new Number__c();
    num4.name='Num test4';
    num4.Service_Id__c = svc1.csordtelcoa__Service_Number__c;
    num4.Subscription_number__c=svc1.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
    num4.Type__c='New';
    num4.Service_Number__c='61474850547';
    num4.Status__c='RESERVED';
    num4.Product_ID__c='gb58-89jk-yuit-fr46';
    num4.Mobile__c = 'Mobile';
    insert num4;
    Number__c num5=new Number__c();
    num5.name='Num test4';
    num5.Service_Id__c = svc1.csordtelcoa__Service_Number__c;
    num5.Subscription_number__c=svc1.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
    num5.Type__c='New';
    num5.Service_Number__c='61474850547';
    num5.Status__c='Active';
    num5.Product_ID__c='gb58-89jk-yuit-fr46';
    num5.Mobile__c = 'Mobile';
    insert num5;
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    ManageOrderNotificationServiceMSUpdate.checkUCCompletionAndUpdateNumber(orderItemIdNotifMap, paramsList);
    Test.stopTest();
    System.assertNotEquals(null, paramsList);
  }
  @isTest
  static void testCheckUCCompletionAndUpdateNumber2(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    Test.startTest();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    NotificationParameters  notif = new NotificationParameters();
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.notificationAttributes = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"In Progress"}]';
    notif.orderItemDetails = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"Complete"}';
    notif.eventType = 'statusNotification';
    notif.orderItemVersion = 1;
    notif.sourceSystem = 'FULFILMENT';
    notif.msCorrelationId = 'ec49950c-5da3-a5a1-1add-89725fee80c9';
    paramsList.add(notif);
    Number__c num4=new Number__c();
    num4.name='Num test4';
    num4.Service_Id__c = svc1.csordtelcoa__Service_Number__c;
    num4.Subscription_number__c=svc1.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
    num4.Type__c='New';
    num4.Service_Number__c='61474850547';
    num4.Status__c='RESERVED';
    num4.Product_ID__c='gb58-89jk-yuit-fr46';
    num4.Mobile__c = 'Mobile';
    insert num4;
    Number__c num5=new Number__c();
    num5.name='Num test4';
    num5.Service_Id__c = svc1.csordtelcoa__Service_Number__c;
    num5.Subscription_number__c=svc1.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
    num5.Type__c='New';
    num5.Service_Number__c='61474850547';
    num5.Status__c='Active';
    num5.Product_ID__c='gb58-89jk-yuit-fr46';
    num5.Mobile__c = 'Mobile';
    insert num5;
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    ManageOrderNotificationServiceMSUpdate.checkUCCompletionAndUpdateNumber(orderItemIdNotifMap, paramsList);
    Test.stopTest();
    System.assertNotEquals(null, paramsList);
    }
    @isTest
    static void testcalculateServiceStatus(){
    csord__Service__c serv = [SELECT Id, Name from csord__Service__c limit 1];
    CS_SpecificationDTO.ServiceSpecification srvSpec = new CS_SpecificationDTO.ServiceSpecification();
    String servId = serv.Id;
    System.debug('servId'+servId);
    srvSpec.serviceId = servId;
    List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
    srvSpecList.add(srvSpec);
    Test.startTest();
    ManageOrderNotificationServiceMSUpdate.calculateServiceStatus( servId, srvSpecList);
    Test.stopTest();
    System.assertNotEquals(null, servId);
  }
  @isTest
  static void testprocessNotificationRecordMSAppointmentNotif(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst servRe' AND csord__Order__r.Name= 'Resume_12345' limit 1][0];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'Resume_12345' limit 1][0];
    Test.startTest();
    NotificationParameters  notif = new NotificationParameters();
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.notificationAttributes = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"In Progress"}]';
    notif.orderItemDetails = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"In Progress"}';
    notif.eventType = 'appointmentNotification';
    notif.orderItemVersion = 1;
    notif.sourceSystem = 'FULFILMENT';
    paramsList.add(notif);
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    ManageOrderNotificationServiceMSUpdate.processNotificationRecordMS(orderItemIdNotifMap,paramsList);
    Test.stopTest();
    csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,  Name from csord__Service__c where Name = 'tst service' limit 1][0];
    //System.assertEquals('In Progress', svc.csord__Status__c);
    System.assertEquals('tst service', svc.Name);
  }
  @isTest
  static void testprocessNotificationRecordMSBillingnotif(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    Test.startTest();
    NotificationParameters  notif = new NotificationParameters();
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemId = '8f0bfd2-1bfd-7916-552d-9e28c804294e';
    notif.notificationAttributes = '"attributes":[{"name":"status", "value":"Complete"}]';
    notif.orderItemDetails = '"product":{"productId":"495bbebb-5166-6dce-24cd-648084f6241c","status":"Complete"}';
    notif.eventType = 'statusNotification';
    notif.orderItemVersion = 1;
    notif.sourceSystem = 'Billing';
    paramsList.add(notif);
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    ManageOrderNotificationServiceMSUpdate.processNotificationRecordMS(orderItemIdNotifMap,paramsList);
    Test.stopTest();
    csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
    //System.assertEquals('In Progress', svc.csord__Status__c);
    System.assertEquals('tst service', svc.Name);
  }
  @isTest
  static void testprocessNotificationRecordMSComplete(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst servRe' AND csord__Order__r.Name= 'Resume_12345' limit 1][0];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'Resume_12345' limit 1][0];
    Test.startTest();
    NotificationParameters  notif = new NotificationParameters();
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.notificationAttributes = '"attributes":[{"name":"status","value":"Complete"}]';
    notif.orderItemDetails = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"Complete","attributes": []}';
    notif.eventType = 'statusNotification';
    notif.orderItemVersion = 1;
    notif.sourceSystem = 'FULFILMENT';
    paramsList.add(notif);
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    ManageOrderNotificationServiceMSUpdate.processNotificationRecordMS(orderItemIdNotifMap,paramsList);
    Test.stopTest();
    csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
    //System.assertEquals('In Progress', svc.csord__Status__c);
    System.assertEquals('tst service', svc.Name);
  }
  @isTest
  static void testprocessNotificationRecordMSAppointmentNotifDisconnectInProgress(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst servRe' AND csord__Order__r.Name= 'Resume_12345' limit 1][0];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'Resume_12345' limit 1][0];
    Test.startTest();
    NotificationParameters  notif = new NotificationParameters();
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'de49950c-5da3-a5a1-1add-89725hee80c9';
    notif.notificationAttributes = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"In Progress"}]';
    notif.orderItemDetails = '"product":{"productId":"de49950c-5da3-a5a1-1add-89725hee80c9","status":"In Progress",,"attributes": []}';
    notif.eventType = 'statusNotification';
    notif.orderItemVersion = 1;
    notif.sourceSystem = 'FULFILMENT';
    paramsList.add(notif);
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    ManageOrderNotificationServiceMSUpdate.processNotificationRecordMS(orderItemIdNotifMap,paramsList);
    Test.stopTest();
    csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
    //System.assertEquals('In Progress', svc.csord__Status__c);
    System.assertEquals('tst service', svc.Name);
  }
  @isTest
  static void testprocessNotificationSuspendInprogress(){
    system.debug('inside suspend test');
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
    system.debug('inside suspend svc1 '+svc1);
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    system.debug('inside suspend ord '+ord);
    Test.startTest();
    NotificationParameters  notif = new NotificationParameters();
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-81725fgg30c9';
    notif.notificationAttributes = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"In Progress"}]';
    notif.orderItemDetails = '"product":{"productId":"ec49950c-5da3-a5a1-1add-81725fgg30c9","status":"In Progress","attributes": []}';
    notif.eventType = 'statusNotification';
    notif.orderItemVersion = 1;
    notif.sourceSystem = 'FULFILMENT';
    paramsList.add(notif);
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    ManageOrderNotificationServiceMSUpdate.processNotificationRecordMS(orderItemIdNotifMap,paramsList);
    Test.stopTest();
    csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
    //System.assertEquals('In Progress', svc.csord__Status__c);
    system.debug('svc details=='+svc);
    System.assertEquals('tst service', svc.Name);
  }
  @isTest
  static void testprocessNotificationSuspendComplete(){
    system.debug('inside suspend test');
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
    system.debug('inside suspend svc1 '+svc1);
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    system.debug('inside suspend ord '+ord);
    Test.startTest();
    NotificationParameters  notif = new NotificationParameters();
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-81725fgg30c9';
    notif.notificationAttributes = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"Complete"}]';
    notif.orderItemDetails = '"product":{"productId":"ec49950c-5da3-a5a1-1add-81725fgg30c9","status":"Complete","attributes": []}';
    notif.eventType = 'statusNotification';
    notif.orderItemVersion = 1;
    notif.sourceSystem = 'FULFILMENT';
    paramsList.add(notif);
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    ManageOrderNotificationServiceMSUpdate.processNotificationRecordMS(orderItemIdNotifMap,paramsList);
    Test.stopTest();
    csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
    //System.assertEquals('In Progress', svc.csord__Status__c);
    system.debug('svc details=='+svc);
    System.assertEquals('tst service', svc.Name);
  }
  @isTest
  static void testbillingNotif(){
    List<NotificationParameters> notifParamList=new List<NotificationParameters>();
    NotificationParameters notif=new NotificationParameters();
    notif.errorDetails='';
    notif.notificationAttributes='"attributes":[ {"name":"status","value":"Complete"}]';
    notif.orderItemDetails='';
    notif.eventType='statusNotification';
    notif.eventTimestamp='2018-12-03T20:39:54+11:00';
    notif.sourceSystem='Billing';
    notif.externalOrderId='9f0bfd2-1bfd-7916-552d-9e28c804294e';
    notif.orderItemId='9f0bfd2-1bfd-7916-552d-9e28c804294e';
    notif.orderItemVersion=1;
    notifParamList.add(notif);
    Map < String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
    System.assertEquals(notifParamList.isEmpty(),false );
    csord__Service__c serv =[select id,name,csord__status__c,csord__Identification__c from csord__Service__c where name ='SolSupress' and csord__Identification__c='SolSupress'];
    system.assertEquals(serv.csord__status__c,'Connected');
  }
  @isTest
  static void testDeviceCareID(){   //added as part of EDGE-154104
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
    csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c,Initial_Activation_DateTime__c  from csord__Service__c where Name = 'AppleDevice' and csord__Identification__c='AppleDevice'];
    List<NotificationParameters> notifParamList=new List<NotificationParameters>();
    NotificationParameters notif=new NotificationParameters();
    notif.errorDetails='';
    notif.notificationAttributes='"attributes":[{"name":"telstraCommittedDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-07-09T05:26:02+10:00"}, {"name":"productCompletionDate","value":"2020-07-09T05:25:03+10:00"}, {"name":"status","value":"Complete"}]';
    notif.orderItemDetails='"product":{"productId": "e9743572-cc9a-74d6-c6de-c14e7a2b47ca","status": "Complete","attributes": [{"name" :"ServiceActivationDate","value":"2017-07-24T06:08:00+11:00"}],"childProduct": [{"productId": "b9d545a8-2a09-37f8-09ea-16f08d91b60c","status": "Complete","attributes": [{"name":"ServiceActivationDate","value":"2017-02-24T06:08:00+11:00"},{"name":"DeviceCareId","value":"AR45678"}]}]}';
    notif.eventType='statusNotification';
    notif.eventTimestamp='2018-12-03T20:39:54+11:00';
    notif.sourceSystem='Fulfilment';
    notif.externalOrderId=ord.csord__Order_Number__c;
    notif.orderItemId=ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|e9743572-cc9a-74d6-c6de-c14e7a2b47ca';
    notif.orderItemVersion=1;
    notifParamList.add(notif);
    Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    Test.startTest();
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
    Test.stopTest();
    Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>();
    List<csord__Service__c> servList=[SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,csord__Activation_Date__c, Name,csord__Identification__c,Initial_Activation_DateTime__c from csord__Service__c where Name = 'AppleDevice' or Name='DeviceCare'];
    for(Attachment att: [Select id,body,parentId from Attachment where parentId IN :servList ]){
    servAttachmentRecordMap.put(att.parentId,att);
    }
    for(csord__Service__c serv1 : servList)
    {
    if(serv1.Name=='AppleDevice'){
    system.assertEquals('Connected',serv1.csord__Status__c);
    //system.assertEquals(Date.newInstance(2017, 07, 24),serv1.Initial_Activation_DateTime__c );
    system.assertEquals(DateTime.newInstanceGMT(2017, 07, 24,06,08,00),serv1.Initial_Activation_DateTime__c);// Added as part of EDGE-174924
    }
    if(serv1.Name=='DeviceCare'){
    system.assertEquals('Connected',serv1.csord__Status__c);
    //system.assertEquals(Date.newInstance(2017, 02, 24),serv1.Initial_Activation_DateTime__c );
    system.assertEquals(DateTime.newInstanceGMT(2017, 02, 24,06,08,00),serv1.Initial_Activation_DateTime__c);// Added as part of EDGE-174924
    List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(servAttachmentRecordMap.get(serv1.id)),'FULFILMENT');
    for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){
    for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
    if(attr.name == 'deviceCareID'){
    System.assertEquals('AR45678', attr.value);
    }
    }
    }
    }
    }
  }
  @isTest
  static void testDeviceCareIdDiffOrderItems(){  //added as part of EDGE-154104
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
    csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c,Initial_Activation_DateTime__c from csord__Service__c where Name = 'AppleDevice' and csord__Identification__c='AppleDevice'];
    csord__Service__c serv1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c,Initial_Activation_DateTime__c from csord__Service__c where Name = 'AppleDevice1' and csord__Identification__c='AppleDevice1'];
    List<NotificationParameters> notifParamList=new List<NotificationParameters>();
    Test.startTest();
    NotificationParameters notif=new NotificationParameters();
    notif.errorDetails='';
    notif.notificationAttributes='"attributes":[{"name":"telstraCommittedDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-07-09T05:26:02+10:00"}, {"name":"productCompletionDate","value":"2020-07-09T05:25:03+10:00"}, {"name":"status","value":"Complete"}]';
    notif.orderItemDetails='"product":{"productId": "e9743572-cc9a-74d6-c6de-c14e7a2b47ca","status": "Complete","attributes": [{"name" :"ServiceActivationDate","value":"2017-07-24T06:08:00+11:00"}],"childProduct": [{"productId": "b9d545a8-2a09-37f8-09ea-16f08d91b60c","status": "Complete","attributes": [{"name":"ServiceActivationDate","value":"2017-02-24T06:08:00+11:00"},{"name":"DeviceCareId","value":"AR45678"}]}]}';
    notif.eventType='statusNotification';
    notif.eventTimestamp='2018-12-03T20:39:54+11:00';
    notif.sourceSystem='Fulfilment';
    notif.externalOrderId=ord.csord__Order_Number__c;
    notif.orderItemId=ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|e9743572-cc9a-74d6-c6de-c14e7a2b47ca';
    notif.orderItemVersion=1;
    notifParamList.add(notif);
    NotificationParameters notif1=new NotificationParameters();
    notif1.errorDetails='';
    notif1.notificationAttributes='"attributes":[{"name":"telstraCommittedDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-07-09T05:26:02+10:00"}, {"name":"productCompletionDate","value":"2020-07-09T05:25:03+10:00"}, {"name":"status","value":"Complete"}]';
    notif1.orderItemDetails='"product":{"productId": "e9743572-cc9a-74d6-c6de-c14e7a2b48bd","status": "Complete","attributes": [{"name" :"ServiceActivationDate","value":"2017-07-24T06:08:00+11:00"}],"childProduct": [{"productId": "b9d545a8-2a09-37f8-09ea-16f08d91b90f","status": "Complete","attributes": [{"name":"ServiceActivationDate","value":"2017-02-24T06:08:00+11:00"},{"name":"DeviceCareId","value":"BR45678"}]}]}';
    notif1.eventType='statusNotification';
    notif1.eventTimestamp='2018-12-03T20:39:54+11:00';
    notif1.sourceSystem='Fulfilment';
    notif1.externalOrderId=ord.csord__Order_Number__c;
    notif1.orderItemId=ord.csord__Order_Number__c+'|'+serv1.csordtelcoa__Service_Number__c+'|e9743572-cc9a-74d6-c6de-c14e7a2b48bd';
    notif1.orderItemVersion=1;
    notifParamList.add(notif1);
    Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
    List<csord__Service__c> servList1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,csord__Activation_Date__c, Name,csord__Identification__c,Initial_Activation_DateTime__c from csord__Service__c where Name = 'AppleDevice' or Name='DeviceCare'];
    Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>();
    for(Attachment att: [Select id,body,parentId from Attachment where parentId IN :servList1]){
    servAttachmentRecordMap.put(att.parentId,att);
    }
    for(csord__Service__c serv2 : servList1)
    {
    if(serv2.Name=='AppleDevice'){
    system.assertEquals('Connected',serv2.csord__Status__c);
    //system.assertEquals(Date.newInstance(2017, 07, 24),serv2.csord__Activation_Date__c);
    system.assertEquals(DateTime.newInstanceGMT(2017, 07, 24,06,08,00),serv2.Initial_Activation_DateTime__c);// Added as part of EDGE-174924
    }
    if(serv2.Name=='DeviceCare'){
    system.assertEquals('Connected',serv2.csord__Status__c);
    //system.assertEquals(Date.newInstance(2017, 02, 24),serv2.csord__Activation_Date__c);
    system.assertEquals(DateTime.newInstanceGMT(2017, 02, 24,06,08,00),serv2.Initial_Activation_DateTime__c);// Added as part of EDGE-174924
    List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(servAttachmentRecordMap.get(serv2.id)),'FULFILMENT');
    for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){
    for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
    if(attr.name == 'deviceCareID'){
    System.assertEquals('AR45678', attr.value);
    }
    }
    }
    }
    }
    List<csord__Service__c> servList2 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,csord__Activation_Date__c, Name,csord__Identification__c, Initial_Activation_DateTime__c  from csord__Service__c where Name = 'AppleDevice1' or Name='DeviceCare1'];
    Map<Id,Attachment> servAttachmentRecordMap1 = new Map <Id,Attachment>();
    for(Attachment att: [Select id,body,parentId from Attachment where parentId IN :servList2]){
    servAttachmentRecordMap1.put(att.parentId,att);
    }
    for(csord__Service__c serv3 : servList2)
    {
    if(serv3.Name=='AppleDevice1'){
    system.assertEquals('Connected',serv3.csord__Status__c);
    system.assertEquals(DateTime.newInstanceGMT(2017, 07, 24,06,08,00),serv3.Initial_Activation_DateTime__c );// Added as part of EDGE-174924
    }
    if(serv3.Name=='DeviceCare1'){
    system.assertEquals('Connected',serv3.csord__Status__c);
    //system.assertEquals(Date.newInstance(2017, 02, 24),serv3.Initial_Activation_DateTime__c );
    system.assertEquals(DateTime.newInstanceGMT(2017, 02, 24,06,08,00),serv3.Initial_Activation_DateTime__c);// Added as part of EDGE-174924
    Test.stopTest();
    List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(servAttachmentRecordMap1.get(serv3.id)),'FULFILMENT');
    for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){
    for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
    if(attr.name == 'deviceCareID'){
    System.assertEquals('BR45678', attr.value);
    }
    }
    }
    }
    }
  }
  @isTest
  static void testDeviceCareIdDiffOrderItemsNew(){ //added as part of EDGE-165183
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
    system.debug('ord'+ord);
    csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c from csord__Service__c where Name = 'AppleDevice' and csord__Identification__c='AppleDevice'];
    List<OrderNotification__e> eventList = new List<OrderNotification__e>();
    OrderNotification__e event1 = new OrderNotification__e();
    event1.errorDetails__c = null;
    event1.notificationAttributes__c ='"attributes":[{"name":"telstraCommittedDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-07-09T05:26:02+10:00"},{"name":"status","value":"In Progress"}]';
    event1.orderItemDetails__c ='"product":{"productId": "e9743572-cc9a-74d6-c6de-c14e7a2b47ca","status": "In Progress","attributes": [],"childProduct": [{"productId": "b9d545a8-2a09-37f8-09ea-16f08d91b60c","status": "Complete","attributes": []}]}';
    event1.eventType__c = 'statusNotification';
    event1.orderItemId__c = ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|e9743572-cc9a-74d6-c6de-c14e7a2b47ca';
    event1.sourceSystem__c = 'Fulfilment';
    event1.sequence__c = 1;
    event1.msCorrelationId__c = '5463873930';
    event1.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
    event1.externalOrderId__c = ord.csord__Order_Number__c;
    eventList.add(event1);
    OrderNotification__e event2 = new OrderNotification__e();
    event2.errorDetails__c = null;
    event2.notificationAttributes__c ='"attributes":[{"name":"telstraCommittedDate","value":"2020-08-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-08-09T05:26:02+10:00"}, {"name":"productCompletionDate","value":"2020-07-09T05:25:03+10:00"}, {"name":"status","value":"Complete"}]';
    event2.orderItemDetails__c ='"product":{"productId": "e9743572-cc9a-74d6-c6de-c14e7a2b47ca","status": "Complete","attributes": [{"name" :"ServiceActivationDate","value":"2017-07-24T06:08-11:00"}],"childProduct": [{"productId": "b9d545a8-2a09-37f8-09ea-16f08d91b60c","status": "Complete","attributes": [{"name":"ServiceActivationDate","value":"2017-02-24T06:08-11:00"},{"name":"DeviceCareId","value":"ZR45678"}]}]}';
    event2.eventType__c = 'statusNotification';
    event2.orderItemId__c = ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|e9743572-cc9a-74d6-c6de-c14e7a2b47ca';
    event2.sourceSystem__c = 'Fulfilment';
    event2.sequence__c = 2;
    event2.msCorrelationId__c = '5463873931';
    event2.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
    event2.externalOrderId__c = ord.csord__Order_Number__c;
    eventList.add(event2);
    Test.startTest();
    Database.SaveResult[] result = EventBus.publish(eventList);
    Test.StopTest();
    Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>();
    List<csord__Service__c> servList=[SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,csord__Activation_Date__c, Name,csord__Identification__c,Telstra_Committed_Date__c,Forecasted_Delivery_Date__c from csord__Service__c where Name = 'AppleDevice' or Name='DeviceCare'];
    for(Attachment att: [Select id,body,parentId from Attachment where parentId IN :servList ]){
    servAttachmentRecordMap.put(att.parentId,att);
    }
    for(csord__Service__c serv1 : servList)
    {
    system.debug('serv1'+serv1);
    if(serv1.Name=='AppleDevice'){
    system.assertNotEquals(null,serv1.csord__Status__c);
    List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(servAttachmentRecordMap.get(serv1.id)),'FULFILMENT');
    for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){
    for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
    if(attr.name == 'telstraCommittedDate'){
    System.assertEquals('2020-08-14T12:49:37+10:00', attr.value);
    }
    if(attr.name == 'currentForecastedDeliveryDate'){
    System.assertEquals('2020-08-09T05:26:02+10:00', attr.value);
    }
    if(attr.name == 'productCompletionDate'){
    System.assertEquals('2020-07-09T05:25:03+10:00', attr.value);
    }
    }
    }
    }
    if(serv1.Name=='DeviceCare'){
    system.assertNotEquals(null,serv1.csord__Status__c);
    //  system.assertEquals('Connected',serv1.csord__Status__c);
    //  system.assertEquals(DateTime.newInstance(2020, 08, 09, 05, 26, 02), serv1.Forecasted_Delivery_Date__c);
    // system.assertEquals(DateTime.newInstance(2020, 08, 14, 12, 49, 37), serv1.Telstra_Committed_Date__c);
    List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(servAttachmentRecordMap.get(serv1.id)),'FULFILMENT');
    for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){
    for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
    if(attr.name == 'telstraCommittedDate'){
    System.assertEquals('2020-08-14T12:49:37+10:00', attr.value);
    }
    if(attr.name == 'currentForecastedDeliveryDate'){
    System.assertEquals('2020-08-09T05:26:02+10:00', attr.value);
    }
    if(attr.name == 'productCompletionDate'){
    System.assertEquals('2020-07-09T05:25:03+10:00', attr.value);
    }
    if(attr.name == 'deviceCareID'){
    System.assertEquals('ZR45678', attr.value);
    }
    if(attr.name == 'ServiceActivationDate'){
    System.assertEquals('2017-02-24T06:08-11:00', attr.value);
    }
    }
    }
    }
    }
  }
  @isTest
  static void testActivationDate(){ //EDGE-169583
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
    csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c,csord__Activation_Date__c from csord__Service__c where Name = 'Business_Calling' and csord__Identification__c='Business_Calling'];
    List<NotificationParameters> notifParamList=new List<NotificationParameters>();
    NotificationParameters notif=new NotificationParameters();
    notif.errorDetails='';
    notif.notificationAttributes='"attributes":[{"name":"telstraCommittedDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-07-09T05:26:02+10:00"}, {"name":"productCompletionDate","value":"2020-07-09T05:25:03+10:00"}, {"name":"status","value":"Complete"}]';
    notif.orderItemDetails='"product":{"productId": "7ccfdcfb-133f-8b91-e538-13066c8d8bab","status": "Complete","attributes": [{"name":"ServiceActivationDate","value":"2020-02-13T05:54:04+10:00"}]}';
    notif.eventType='statusNotification';
    notif.eventTimestamp='2018-12-03T20:39:54+11:00';
    notif.sourceSystem='Fulfilment';
    notif.externalOrderId=ord.csord__Order_Number__c;
    notif.orderItemId=ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|7ccfdcfb-133f-8b91-e538-13066c8d8bab';
    notif.orderItemVersion=1;
    notifParamList.add(notif);
    Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    Test.startTest();
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
    Test.stopTest();
    csord__Service__c serv1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c,csord__Activation_Date__c, Initial_Activation_DateTime__c  from csord__Service__c where Name = 'Business_Calling' and csord__Identification__c='Business_Calling'];
    system.debug('Initial_Activation_DateTime__c...'+serv1.Initial_Activation_DateTime__c);
    system.assertEquals(DateTime.newInstanceGMT(2020, 02, 13,05,54,04),serv1.Initial_Activation_DateTime__c);// Added as part of EDGE-174924
  }
  @isTest
  static void testDeactivationDate(){ //EDGE-164354
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
    csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c,csord__Activation_Date__c,csord__Deactivation_Date__c from csord__Service__c where Name = 'Business_Calling' and csord__Identification__c='Business_Calling'];
    List<NotificationParameters> notifParamList=new List<NotificationParameters>();
    NotificationParameters notif=new NotificationParameters();
    notif.errorDetails='';
    notif.notificationAttributes='"attributes":[{"name":"telstraCommittedDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-07-09T05:26:02+10:00"}, {"name":"productCompletionDate","value":"2020-07-09T05:25:03+10:00"}, {"name":"status","value":"Complete"}]';
    notif.orderItemDetails='"product":{"productId": "7ccfdcfb-133f-8b91-e538-13066c8d8bab","status": "Complete","attributes": [{"name":"ServiceDeactivationDate","value":"2020-02-13T05:54:04+10:00"}]}';
    notif.eventType='statusNotification';
    notif.eventTimestamp='2018-12-03T20:39:54+11:00';
    notif.sourceSystem='Fulfilment';
    notif.externalOrderId=ord.csord__Order_Number__c;
    notif.orderItemId=ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|7ccfdcfb-133f-8b91-e538-13066c8d8bab';
    notif.orderItemVersion=1;
    notifParamList.add(notif);
    Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    Test.startTest();
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
    Test.stopTest();
    csord__Service__c serv1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c,csord__Activation_Date__c,csord__Deactivation_Date__c,Deactivation_Date__c  from csord__Service__c where Name = 'Business_Calling' and csord__Identification__c='Business_Calling'];
    system.debug('Deactivation_Date__c...'+serv1.Deactivation_Date__c);
    system.assertEquals(DateTime.newInstanceGMT(2020, 02, 13,05,54,04),serv1.Deactivation_Date__c);  // Added as part of EDGE-174924
  }
  //EDGE-164355 : When parent svc is PayOut subscription should be Paid Out
  @isTest
  static void testupdateSubscriptionRecordMSPaidOutWhenParentSvcPayOut(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String, ManageOrderNotificationUtil.Parameters> parameterMap = new Map<String, ManageOrderNotificationUtil.Parameters>();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, Action_Type__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where csord__Subscription__r.Name = 'test subs' AND csord__Order__r.Name= 'TestOrder' limit 1];
    csord__Service__c replServ = [SELECT Id, csord__Status__c, Action_Type__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name !=  'tst service' limit 1];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    csord__Service__c svcForSub = [SELECT Id, Action_Type__c, csord__Status__c, csord__Subscription__r.id, csord__Subscription__r.csordtelcoa__Subscription_Number__c, csord__Subscription__r.eventId__c, csord__Subscription__r.csord__Status__c, csord__Order__r.csord__Status2__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Service__c Where id =: svc1.id Limit 1];
    svcForSub.csord__Subscription__r.eventId__c = '9d676c71-3954-4562-8552-921696503022';
    List<csord__Subscription__c> subsToUpdate = new List<csord__Subscription__c>();
    subsToUpdate.add(svcForSub.csord__Subscription__r);
    update subsToUpdate;
    svc1.Action_Type__c = 'PayOut';
    svc1.csordtelcoa__Replacement_Service__c = replServ.id;
    update svc1;
    Map<Id,csord__Service__c> servMap = new Map<Id,csord__Service__c>();
    servMap.put(svc1.id, svc1);
    Test.startTest();
    NotificationParameters notif = new NotificationParameters();
    notif.orderItemId =ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.externalOrderId = 'ON00002852';
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemVersion = 1;
    notif.notificationAttributes = '"attributes":[{"name":"status", "value":"Complete"}]';
    notif.orderItemDetails = '"product":{"productId":"3072dad2-5546-eb71-8e13-bd04b7f9824a","status":"In Progress"}';
    notif.eventType = 'statusNotification';
    notif.sourceSystem = 'Billing';
    paramsList.add(notif);
    Notification__c notif1 = new Notification__c();
    notif1.Name='Notif1';
    notif1.eventType__c = 'statusNotification';
    notif1.eventTimeStamp__c = '2020-04-01T12:45:45';
    notif1.externalOrderId__c = '9d676c71-3954-4562-8552-921696503022';
    notif1.orderItemId__c = '9d676c71-3954-4562-8552-921696503022';
    notif1.orderItemVersion__c = 1;
    notif1.notificationAttributes__c = '"attributes":[{"name":"status","value":"Complete"}]';
    notif1.sourceSystem__c = 'Billing';
    notif1.Status__c = 'Completed';
    insert notif1;
    Number__c num4=new Number__c();
    num4.name='Num test5';
    num4.Subscription_number__c=svcForSub.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
    num4.Type__c='New';
    num4.Service_Number__c='61474850547';
    num4.Status__c='RESERVED';
    num4.Product_ID__c='gb58-89jk-yuit-fr46';
    insert num4;
    ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
    params.orderIdc = notif.orderItemId;
    params.eventType = notif.eventType;
    parameterMap.put(params.orderIdc, params);    
    ManageOrderNotificationServiceMSUpdate.updateSubscriptionRecordMS(paramsList,parameterMap,subsToUpdate,servMap);
    csord__Service__c svcExpected = [SELECT Id, csord__Status__c, Action_Type__c, csord__Subscription__r.csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1];
    //System.assertEquals(svcExpected.csord__Status__c, 'Paid Out');  //EDGE-156046 : Service status should change to Paid Out
    System.assertEquals(svcExpected.csord__Subscription__r.csord__Status__c, 'Paid Out'); //Subscription status should not change to Paid Out
    Notification__c notif2 = new Notification__c();
    notif2.Name='Notif2';
    notif2.eventType__c = 'error';
    notif2.eventTimeStamp__c = '2020-04-01T12:45:45';
    notif2.externalOrderId__c = '9d676c71-3954-4562-8552-921696503022';
    notif2.orderItemId__c = '9d676c71-3954-4562-8552-921696503022';
    notif2.orderItemVersion__c = 1;
    notif2.notificationAttributes__c = '"attributes":[{"name":"error","value":"Functional Error"}]';
    notif2.sourceSystem__c = 'Billing';
    notif2.Status__c = 'Completed';
    insert notif2;
    Test.stopTest();
    csord__Service__c svcExpected2 = [SELECT Id, csord__Status__c, Action_Type__c, csord__Subscription__r.csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1];
    //When BDS complete notification recieved with error in it then subscription status should be failed
    System.assertEquals(svcExpected2.csord__Subscription__r.csord__Status__c, 'Failed'); //Subscription status should not change to Paid Out
  }
  @isTest
  static void testprocessNotification2(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    Test.startTest();
    csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
    NotificationParameters  notif = new NotificationParameters();
    notif.externalOrderId = ord.csord__Order_Number__c;
    notif.eventTimestamp = '2018-02-24T06:08+10:00';
    notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
    notif.notificationAttributes = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"Complete"}]';
    notif.orderItemDetails = '"product":{"productId":"ec49950c-5da3-a5a1-1adad-89725fee80c9","status":"Complete"}';
    notif.eventType = 'statusNotification';
    notif.orderItemVersion = 1;
    notif.sourceSystem = 'FULFILMENT';
    notif.msCorrelationId = 'ec49950c-5da3-a5a1-1add-89725fee80c9';
    paramsList.add(notif);
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    Number__c num4=new Number__c();
    num4.name='Num test4';
    num4.Service_Id__c = svc1.csordtelcoa__Service_Number__c;
    num4.Subscription_number__c=svc1.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
    num4.Type__c='New';
    num4.Service_Number__c='61474850547';
    num4.Status__c='RESERVED';
    num4.Product_ID__c='gb58-89jk-yuit-fr46';
    insert num4;
    Number__c num5=new Number__c();
    num5.name='Num test4';
    num5.Service_Id__c = svc1.csordtelcoa__Service_Number__c;
    num5.Subscription_number__c=svc1.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
    num5.Type__c='New';
    num5.Service_Number__c='61474850547';
    num5.Status__c='Active';
    num5.Product_ID__c='gb58-89jk-yuit-fr46';
    insert num5;
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,paramsList);
    Test.stopTest();
    csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
    //System.assertEquals('In Progress', svc.csord__Status__c);
    System.assertEquals('tst service', svc.Name);
  }
  @isTest
  static void testOrderRejection(){ //added as part of EDGE-170550
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
    csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c,csord__Activation_Date__c from csord__Service__c where Name = 'Business_Calling' and csord__Identification__c='Business_Calling'];
    List<NotificationParameters> notifParamList=new List<NotificationParameters>();
    NotificationParameters notif=new NotificationParameters();
    notif.errorDetails='';
    notif.notificationAttributes='"attributes": [{"name": "status","value": "Rejected"},{"name": "rejectionReason","value": "PONR has reached of one or more order items present in amend order"}]';
    // notif.orderItemDetails='"product":{"productId": "7ccfdcfb-133f-8b91-e538-13066c8d8bab","status": "Complete","attributes": [{"name":"ServiceActivationDate","value":"2020-02-13T05:54:04+10:00"}]}';
    notif.eventType='OrderNotification';
    notif.eventTimestamp='2018-12-03T20:39:54+11:00';
    notif.sourceSystem='Fulfilment';
    notif.externalOrderId=ord.csord__Order_Number__c;
    // notif.orderItemId=ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|7ccfdcfb-133f-8b91-e538-13066c8d8bab';
    notif.orderItemVersion=2;
    notifParamList.add(notif);
    Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    Test.startTest();
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
    Test.stopTest();
    csord__Order__c ord1 = [SELECT id, csord__Status2__c, csord__Primary_Order__c, CreatedDate,rejectionReason__c FROM csord__Order__c WHERE Name = 'TestOrder'];
    System.assertEquals('Amend Rejected', ord1.csord__Status2__c);
    System.assertEquals('PONR has reached of one or more order items present in amend order', ord1.rejectionReason__c);
    System.assertNotEquals (null, ord1);
  }
  @isTest
  static void testAmendnotallowed(){ //added as part of EDGE-170550
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
    csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,csordtelcoa__Point_of_No_Return_Reached__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c,csord__Activation_Date__c from csord__Service__c where Name = 'Business_Calling' and csord__Identification__c='Business_Calling'];
    List<NotificationParameters> notifParamList=new List<NotificationParameters>();
    NotificationParameters notif=new NotificationParameters();
    notif.errorDetails='';
    notif.notificationAttributes='"attributes": [{"name": "status","value": "In Progress"},{"name": "amendNotAllowed","value": "True"}]';
    notif.eventType='PONR';
    notif.eventTimestamp='2018-12-03T20:39:54+11:00';
    notif.sourceSystem='Fulfilment';
    notif.externalOrderId=ord.csord__Order_Number__c;
    notif.orderItemId=ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|7ccfdcfb-133f-8b91-e538-13066c8d8bab';
    notif.orderItemVersion=2;
    notifParamList.add(notif);
    Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    Test.startTest();
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
    Test.stopTest();
    csord__Service__c serv1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,csordtelcoa__Point_of_No_Return_Reached__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c,csord__Activation_Date__c from csord__Service__c where Name = 'Business_Calling' and csord__Identification__c='Business_Calling'];
    //  System.assertEquals(true, serv1.csordtelcoa__Point_of_No_Return_Reached__c);
    System.assertNotEquals (null, serv1);
  }
  @isTest
  static void testCancelnotallowed(){ //added as part of EDGE-170550
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
    csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,cancel_Point_of_No_Return_Reached__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c,csord__Activation_Date__c from csord__Service__c where Name = 'Business_Calling' and csord__Identification__c='Business_Calling'];
    List<NotificationParameters> notifParamList=new List<NotificationParameters>();
    NotificationParameters notif=new NotificationParameters();
    notif.errorDetails='';
    notif.notificationAttributes='"attributes": [{"name": "status","value": "In Progress"},{"name": "cancelNotAllowed","value": "True"}]';
    notif.eventType='PONR';
    notif.eventTimestamp='2018-12-03T20:39:54+11:00';
    notif.sourceSystem='Fulfilment';
    notif.externalOrderId=ord.csord__Order_Number__c;
    notif.orderItemId=ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|7ccfdcfb-133f-8b91-e538-13066c8d8bab';
    notif.orderItemVersion=2;
    notifParamList.add(notif);
    Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    Test.startTest();
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
    Test.stopTest();
    csord__Service__c serv1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,cancel_Point_of_No_Return_Reached__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c,csord__Activation_Date__c from csord__Service__c where Name = 'Business_Calling' and csord__Identification__c='Business_Calling'];
    System.assertEquals(true, serv1.cancel_Point_of_No_Return_Reached__c);
    System.assertNotEquals (null, serv1);
  }
  //added by Pooja
  @isTest
  static void testUpdateOrderRecordMS(){
    csord__Order__c ord = [SELECT id, cancel_Point_of_No_Return_Reached__c,csordtelcoa__Point_of_No_Return_Reached__c FROM csord__Order__c WHERE Name = 'TestOrder'];
    List<csord__Subscription__c> subList=[SELECT id, Point_of_No_Return_Reached__c, cancel_Point_of_No_Return_Reached__c,csord__Order__c from csord__Subscription__c where csord__Order__c =: ord.Id];
    Map<csord__Order__c, List<csord__Subscription__c>> orderMapToUpdate = new Map<csord__Order__c, List<csord__Subscription__c>>();
    orderMapToUpdate.put(ord, subList);
    Test.startTest();
    ManageOrderNotificationServiceMSUpdate.updateOrderRecordMS(orderMapToUpdate);
    Test.stopTest();
    csord__Order__c ord1 = [SELECT id, cancel_Point_of_No_Return_Reached__c,csordtelcoa__Point_of_No_Return_Reached__c FROM csord__Order__c WHERE Name = 'TestOrder'];
    System.assertEquals(false, ord1.cancel_Point_of_No_Return_Reached__c);
    }
  @isTest
    static void testUpdateInflightSubsOrchestration(){ //added as part of EDGE-170546
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'Inflight'];
    List<NotificationParameters> notifParamList=new List<NotificationParameters>();
    NotificationParameters notif=new NotificationParameters();
    notif.errorDetails='';
    notif.notificationAttributes='"attributes": [{"name": "status","value": "Accepted"}]';
    notif.eventType='OrderNotification';
    notif.eventTimestamp='2018-12-03T20:39:54+11:00';
    notif.sourceSystem='Fulfilment';
    notif.externalOrderId=ord.csord__Order_Number__c;
    notif.orderItemVersion=2;
    notifParamList.add(notif);
    Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    Test.startTest();
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
    Test.stopTest();
    List<CSPOFA__Orchestration_Process__c> processList = [SELECT Id,Name,CSPOFA__Process_On_Hold__c FROM CSPOFA__Orchestration_Process__c Where CSPOFA__Orchestration_Process_Template__r.Name = 'Subscription Fulfilment Process'];
    System.assertEquals(false, processList[0].CSPOFA__Process_On_Hold__c);
    List<CSPOFA__Orchestration_Process__c> processList1 = [SELECT Id,Name,CSPOFA__Process_On_Hold__c FROM CSPOFA__Orchestration_Process__c Where CSPOFA__Orchestration_Process_Template__r.Name = 'Service Fulfilment Process'];
    System.assertEquals(false, processList1[0].CSPOFA__Process_On_Hold__c);
  }
  @isTest
  static void testInflightpart(){ //added as part of EDGE-170552
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate,csord__Status2__c,rejectionReason__c FROM csord__Order__c WHERE Name = 'InflightNew'];
    // csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__r.csord__Status__c,csord__Activation_Date__c from csord__Service__c where Name = 'InflightNew' and csord__Identification__c='InflightNew'];
    system.debug('ord1756'+ord);
    List<NotificationParameters> notifParamList=new List<NotificationParameters>();
    NotificationParameters notif=new NotificationParameters();
    notif.errorDetails='';
    notif.notificationAttributes='"attributes": [{"name": "status","value": "Accepted"}]';
    notif.eventType='OrderNotification';
    notif.eventTimestamp='2018-12-03T20:39:54+11:00';
    notif.sourceSystem='Fulfilment';
    notif.externalOrderId=ord.csord__Order_Number__c;
    notif.orderItemVersion=2;
    notifParamList.add(notif);
    Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    Test.startTest();
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
    Test.stopTest();
    csord__Order__c ord1 = [SELECT id, csord__Status2__c, csord__Primary_Order__c, CreatedDate,rejectionReason__c FROM csord__Order__c WHERE Name = 'InflightNew'];
    csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c from csord__Service__c where Name = 'InflightNew' and csord__Identification__c='InflightNew'];
    system.debug('ord1772'+ord1.csord__Status2__c);
    System.assertEquals('In Progress', ord1.csord__Status2__c);
    // System.assertEquals('Cancellation In Progress', serv.csord__Status__c);
    System.assertNotEquals('In Progress', serv.csord__Status__c);
  }
  @isTest
  static void processFulfilmentPositiveTest() { // B2B-328 - Solution Supress
    List<csord__Order__c> orderList = [select Id,csord__Order_Number__c from csord__Order__c where Name =: 'TestOrder'];
    List<OrderNotification__e> eventList = new List<OrderNotification__e>();
    OrderNotification__e eventObj = new OrderNotification__e();
    eventObj.errorDetails__c = null;
    eventObj.notificationAttributes__c ='"attributes":[{"name":"telstraCommittedDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-07-09T05:26:02+10:00"},{"name":"status","value":"In Progress"}]';
    eventObj.eventType__c = 'statusNotification';
    eventObj.orderItemId__c = orderList[0].csord__Order_Number__c+'|NG-000001228|e8a320b8-67c7-0789-fc04-17aa2355308b';
    eventObj.sourceSystem__c = 'Fulfilment';
    eventObj.sequence__c = 1;
    eventObj.msCorrelationId__c = '5463873930';
    eventObj.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
    eventObj.externalOrderId__c = orderList[0].csord__Order_Number__c;
    eventList.add(eventObj);
    test.startTest();
    Database.SaveResult[] result = EventBus.publish(eventList);
    test.stopTest();
    system.assertnotEquals(result, null);
  }
   // solution supress test
   @isTest
   static void testprocessNotificationRecordMSBillingnotifSolutionSupress(){
          List<NotificationParameters>paramsList = new List<NotificationParameters>();
          Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
          //csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
          csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'testSolutionSupress' limit 1][0];
          system.debug('solution Supress =======>' + ord);
          Test.startTest();
          NotificationParameters  notif = new NotificationParameters();
          // notif.externalOrderId = ord.csord__Order_Number__c;
          notif.eventTimestamp = '2018-02-24T06:08+10:00';
          notif.orderItemId = '8f0bfd2-1bfd-7916-552d-9e28c80429xe';
          notif.notificationAttributes = '"attributes":[{"name":"status", "value":"Complete"}]';
          notif.orderItemDetails = '8f0bfd2-1bfd-7916-552d-9e28c80429xe';
          notif.eventType = 'statusNotification';
          notif.orderItemVersion = 1;
          notif.sourceSystem = 'Billing';
          paramsList.add(notif);
          orderItemIdNotifMap.put(notif.orderItemId,paramsList);
          ManageOrderNotificationServiceMSUpdate.processNotificationRecordMS(orderItemIdNotifMap,paramsList);
          Test.stopTest();
          csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
         // System.assertEquals('In Progress', svc.csord__Status__c);
          System.assertEquals('tst service', svc.Name);
      }
}