@isTest
public class SubmitOrderOrchestrationTest {
    @Testsetup static void dataSetup(){
        /*RecordType rectype=new RecordType();
rectype.name='Order Submitted with Appointment';
rectype.SobjectType='csord__Order__c';
*/
        Id RecordTypeIdOrder = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Order Submitted with Appointment').getRecordTypeId();
        Id RecordTypeIdSecondaryOrder = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Secondary Order').getRecordTypeId();
        csord__Order_Request__c orderRequest=new csord__Order_Request__c();
        
        
        csord__Order__c prord = new csord__Order__c();
        prord.csord__Identification__c = 'test identification';
        prord.Name = 'test order';
        prord.csord__Order_Request__c=orderRequest.id;
        prord.csord__Status2__c = 'Pending'; 
        prord.RecordTypeId=RecordTypeIdOrder;
        prord.Scenario_Type__c='';
        insert prord;
        
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification1';
        ord.Name = 'test sec order';
        ord.csord__Order_Request__c=orderRequest.id;
        //ord.csord__Status2__c = 'Pending';
        ord.RecordTypeId=RecordTypeIdSecondaryOrder;
        ord.Scenario_Type__c='';
        ord.csord__Primary_Order__c=prord.id;
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Pending';
        subs.csord__Order__c = ord.id;
        insert subs;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service1';
        serv.csord__Identification__c  = 'test identify1';
        serv.csordtelcoa__Service_Number__c = '4';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Failed';
        serv.csord__Order__c = ord.id;
        serv.Appointment_Required__c='true';
        insert serv;
        
		CSPOFA__Orchestration_Process_Template__c opt=new CSPOFA__Orchestration_Process_Template__c();
        opt.Name='Order Fulfilment Process';
        insert opt;
		
        CSPOFA__Orchestration_Process_Template__c opt1=new CSPOFA__Orchestration_Process_Template__c();
        opt1.Name='Order Fulfilment Process_New';
        insert opt1;
        
        account acc=TestDataFactory.generateAccount();
        acc.name='PortOutReversal Account';
        acc.Customer_Status__c='ACTIVE';
        update acc;
        
        Opportunity opp=new Opportunity(Name='Port Out Reversal Opportunity');
        opp.AccountId=acc.id;
        opp.StageName='Propose';
        opp.CloseDate=system.today();
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Mobile Subscription';
        productDefinition.cscfga__Description__c = 'Mobile Subscription';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000420';
        insert productDefinition;
        
        List<cscfga__Product_Configuration__c> pcList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.cscfga__Product_Definition__c = productDefinition.Id;
        productConfig.ConfigurationType1__c='SolutionComponent';
        productConfig.Remaining_Term__c  = 24;
        productConfig.cscfga__Product_Basket__c=basket.id;
        pcList.add(productConfig);
        insert pcList;
        
        List<Number__c> numList=new List<Number__c>();
        Number__c num= new Number__c(Service_Number__c='61459812342',Type__c='Port Out Reversal', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',Basket__c=basket.id,Product_Configuration__c=productConfig.id);
        numList.add(num);
        Number__c num1= new Number__c(Service_Number__c='61459812345',Type__c='Port In', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',Basket__c=basket.id,Product_Configuration__c=productConfig.id);
		numList.add(num1);
        insert numList;
        
        Customer_Authority_Form__c custAuthForm = new Customer_Authority_Form__c();
        custAuthForm.Account__c=acc.id;
        custAuthForm.Opportunity__c=opp.id;
        custAuthForm.Customer_Authorised_date__c=Date.Today().addMonths(2*(-1));
        custAuthForm.Is_active__c=false;
        insert  custAuthForm;
        
        list<Notification_Preference__c> listPref = new list<Notification_Preference__c>();
        Notification_Preference__c pref = new Notification_Preference__c();
        pref.Account_Id__c = acc.id;
        pref.Name = 'Test pref';
        pref.Service_Id__c=serv.id;
        listPref.add(pref);
        
        Notification_Preference__c pref1 = new Notification_Preference__c();
        pref1.Account_Id__c = acc.id;
        pref1.Name = 'Test pref2';
        pref1.Service_Id__c=serv.id;
        listPref.add(pref1);
        insert listPref;
    }
    
    static testMethod void createOrderOrchestrationProcessTest() {
        
        String orderIds = null;
        List<csord__Order__c> ords = [SELECT Id, Name, csord__Status2__c,csord__Identification__c from csord__Order__c where csord__Identification__c='test identification'];
        for(csord__Order__c c:ords){
            orderIds= String.valueOf(c.id);
            system.debug('orderIds'+orderIds);
        }
        SubmitOrderOrchestration.createOrderOrchestrationProcess(orderIds); 
        csord__Order__c orderRequest =[Select id,csord__Order_Request__c from csord__Order__c where id = :orderIds LIMIT 1];
        List<csord__Service__c> serviceList = [SELECT id,Name,Appointment_Required__c,csord__Order__c FROM csord__Service__c where Appointment_Required__c = 'true' and csord__Order_Request__c = :orderRequest.csord__Order_Request__c];
        List<csord__Order__c> ordsAll = [SELECT Id, Name, recordtypeId,csord__Status2__c,csord__Identification__c from csord__Order__c where id=:orderIds LIMIT 1];
        
        //List<csord__Service__c> servsAll = [SELECT ID,csord__Status__c FROM csord__Service__c WHERE csord__Order__c= : orderIds LIMIT 1];
        List<csord__Subscription__c> subsAll = [SELECT ID,csord__Status__c FROM csord__Subscription__c where csord__Order__c=:orderIds LIMIT 1];
        
        system.debug('list'+ordsAll);
        
        system.assertEquals(ordsAll!=NULL,True,'Order not created');
        //system.assertEquals('Order Submitted', Schema.SObjectType.csord__Order__c.getRecordTypeInfosById().get(ordsAll[0].recordtypeid).getname());
        
    }
    
    @isTest
    public static void createLinkTest(){// EDGE-88033
        Account acc = new Account(Name = 'Burlington');
        acc.Customer_Status__c='ACTIVE';
        insert acc;
        
        Opportunity opp=new Opportunity(Name='TestOp');
        opp.AccountId=acc.id;
        opp.StageName='Propose';
        opp.CloseDate=date.valueOf('2019-08-10T00:05:00');
        insert opp;
        
        String basketId = '';
        String rootConfigId = '';
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        
        Customer_Authority_Form__c custAuthForm = new Customer_Authority_Form__c();
        custAuthForm.Account__c=acc.id;
        custAuthForm.Opportunity__c=opp.id;
        custAuthForm.Customer_Authorised_date__c=Date.Today();
        custAuthForm.Is_active__c=true;
        //custAuthForm.Product_Basket__c=basket.id;
        insert  custAuthForm;
        
        Test.startTest();
        boolean isValid = SubmitOrderOrchestration.isPortInValid(opp.id);
        System.assertEquals(isValid==true,true,'CA Form has expired');
        Test.stopTest();
    }    
    @isTest
    public static void createLinkCheckTest(){// EDGE-88033
        Account acc = new Account(Name = 'Burlington');
        acc.Customer_Status__c='ACTIVE';
        insert acc;
        
        Opportunity opp=new Opportunity(Name='TestOp');
        opp.AccountId=acc.id;
        opp.StageName='Propose';
        opp.CloseDate=date.valueOf('2019-08-10T00:05:00');
        insert opp;
        
        String basketId = '';
        String rootConfigId = '';
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        
        Customer_Authority_Form__c custAuthForm = new Customer_Authority_Form__c();
        custAuthForm.Account__c=acc.id;
        custAuthForm.Opportunity__c=opp.id;
        custAuthForm.Customer_Authorised_date__c=Date.Today();
        custAuthForm.Is_active__c=true;
        //custAuthForm.Product_Basket__c=basket.id;
        insert  custAuthForm;
        
        
        Test.startTest();
        boolean isValid = SubmitOrderOrchestration.isPortInValid(opp.id);
        System.assertEquals(isValid==true,true,'CA Form has expired');
        Test.stopTest();
    }
    /*---------------------------------------------------------------------------------------------------
EDGE        -150285
Method      -checkPortOutReversalOrderCaFormTest
Description -Test method for checkPortOutReversalOrderCaForm method in SubmitOrderOrchestration class
Author      -Dheeraj Bhatt
------------------------------------------------------------------------------------------------*/
    @IsTest public static void checkPortOutReversalOrderCaFormTest(){
        opportunity opp=[SELECT Id,Name from opportunity WHERE Name='Port Out Reversal Opportunity' LIMIT 1];
        Test.startTest();
        Boolean isCaFormPresent=SubmitOrderOrchestration.checkPortOutReversalOrderCaForm(opp.id);
        system.assert(!isCaFormPresent);
        Test.stopTest();
    }
    /*-----------------------------------------------------------------------------------------------------------
EDGE        -150285
Method      -checkPortOutReversalOrderCaFormNegativeTest
Description -Test method for negative scenerio checkPortOutReversalOrderCaForm method in SubmitOrderOrchestration class
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------------------------------------*/
    @IsTest public static void checkPortOutReversalOrderCaFormNegativeTest(){
        opportunity opp=[SELECT Id,Name from opportunity WHERE Name='Port Out Reversal Opportunity' LIMIT 1];
        List<Customer_Authority_Form__c> caFormList = [SELECT Id,Is_active__c, Customer_Authorised_date__c FROM Customer_Authority_Form__c WHERE Opportunity__c = :opp.id LIMIT 1];
        caFormList[0].Is_active__c=true;
        Test.startTest();
        update caFormList;
        Boolean isCaFormPresent=SubmitOrderOrchestration.checkPortOutReversalOrderCaForm(opp.id);
        system.assert(isCaFormPresent);
        Test.stopTest();
    }
    /*-----------------------------------------------------------------------------------------------------------
EDGE        -149259
Method      -isPortinPpvApprovedTest
Description -Test method for isPortinPpvApproved method in SubmitOrderOrchestration class
Author      -Aishwarya Yeware
-------------------------------------------------------------------------------------------------------------*/
   
        @IsTest public static void isPortinPpvApprovedTest(){
        opportunity opp=[SELECT Id,Name from opportunity WHERE Name='Port Out Reversal Opportunity' LIMIT 1];
        List<Customer_Authority_Form__c> caFormList = [SELECT Id,Is_active__c, Customer_Authorised_date__c FROM Customer_Authority_Form__c WHERE Opportunity__c = :opp.id LIMIT 1];
        caFormList[0].Is_active__c=true;
        caFormList[0].PPV_status__c='PPV Initiate';
        Test.startTest();
        Boolean isPpvApproved=SubmitOrderOrchestration.isPortinPpvApproved(opp.id);
        system.assert(!isPpvApproved);
        Test.stopTest();
    }
    @isTest
    public static  void createOrderOrchestrationProcessBulkTest() {
        Map<Id,csord__Order__c> OrderMap =new Map<Id,csord__Order__c>();
        Map<Id,Boolean> isOrchCreated =new Map<Id,Boolean>();
		
        for(csord__Order__c ord:[SELECT Id, Name, csord__Status2__c,csord__Identification__c from csord__Order__c]){
            OrderMap.put(ord.id,ord);
        }
        SubmitOrderOrchestration.createOrderOrchestrationProcessBulk(OrderMap); 
        for(CSPOFA__Orchestration_Process__c orch :[select id,name,Order__c, CSPOFA__Orchestration_Process_Template__c,CSPOFA__Orchestration_Process_Template__r.name
        from CSPOFA__Orchestration_Process__c where Order__c IN :OrderMap.keyset()])
        {
            isOrchCreated.put(orch.Order__c,true);
        }
        for(csord__Order__c ord:[SELECT Id, Name, csord__Status2__c,csord__Identification__c from csord__Order__c]){
           system.assertEquals(isOrchCreated.containsKey(ord.id),true);
        }
        //system.assertEquals('Order Submitted', Schema.SObjectType.csord__Order__c.getRecordTypeInfosById().get(ordsAll[0].recordtypeid).getname());
        
    }
     /*-------------------------------------------------------------------------------
EDGE        -170965
Method      -isNotificationCreatedTest
Description -To Check if notification prefernces records created for order
Author      -Aishwarya
---------------------------------------------------------------------------------*/
      @IsTest public static void isNotificationCreatedTest(){
        String orderIds = null;
        List<csord__Order__c> ords = [SELECT Id, Name, csord__Status2__c,csord__Identification__c from csord__Order__c where csord__Identification__c='test identification1'];
        for(csord__Order__c c:ords){
            orderIds= String.valueOf(c.id);
            system.debug('orderIds'+orderIds);
        }
       List<Notification_Preference__c> listOfNotificationRecords=[SELECT id,Contact_Id__c,Service_Id__c from Notification_Preference__c WHERE Service_Id__r.csord__Order__c = :orderIds];

        Test.startTest();
        Boolean isNotificationCreated=SubmitOrderOrchestration.isNotificationCreated(orderIds);
        system.assert(isNotificationCreated);
        Test.stopTest();
    }

}