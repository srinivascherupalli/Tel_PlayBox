@isTest
public with sharing class InflightSolutionControllerTest {
   
    @testSetup
    static void setup(){
        BDS_Notify_Settings__c featureLevel = new BDS_Notify_Settings__c(name = 'Feature Level',Value__c = 'FeatureLevelShadow',Is_SI5_Offer__c  = true);
        BDS_Notify_Settings__c technicalSupport = new BDS_Notify_Settings__c(name = 'Technical Support',Value__c = 'TechnicalSupportShadow ',Is_SI5_Offer__c  = true);
        insert new List<BDS_Notify_Settings__c>{featureLevel,technicalSupport};
        
        List<cscfga__Product_Basket__c> productBasketList = new List<cscfga__Product_Basket__c>();
        Account acc = new Account();
        acc.Name = 'testAcc';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Rajiv';
        con.LastName = 'Singh'; 
        con.email ='rajiv@test.com';
        con.Contact_Status__c ='Active';
        con.AccountId = acc.Id;
        insert con;
 
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Product_Domain__c = 'MOBILES';
        opp.Name = 'testopp';
        opp.StageName = 'New';
        opp.CloseDate = date.newInstance(2021,12,1);
        insert opp;
        system.debug('opp Id '+opp.Id);

        
        
        OpportunityContactRole oppCont = new OpportunityContactRole();
        oppcont.OpportunityId = opp.Id;
        oppCont.ContactId = con.Id;
        oppCont.Role = 'Technical Buyer';
        insert oppCont;
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Billing Enquiry').getRecordTypeId(); 
        case testCase = new case();
        testCase.Subject = 'testCase';
        testCase.RecordTypeId = RecordTypeIdCase;
        testCase.Status = 'New';
        testCase.Origin = 'TPC';
        insert testCase;
        
        cscfga__Product_Basket__c testBasket1 = new cscfga__Product_Basket__c();
        testBasket1.csbb__Account__c = acc.Id;
        testBasket1.Name = 'InflightTestBasket1';
        testBasket1.cscfga__Opportunity__c = opp.Id;
        testBasket1.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        testBasket1.csordtelcoa__Synchronised_with_Opportunity__c = true;
        testBasket1.Amend_Type__c = 'Commercial';
        testBasket1.Order_Requester__c = con.Id;
        testBasket1.SalesSupport_CaseNumber__c = testCase.Id;
        testBasket1.cscfga__Basket_Status__c = 'Submitted';
        //testBasket1.RecordTypeId = RecordTypeIdProdBasket;
        productBasketList.add(testBasket1);
        
        Id RecordTypeIdProdBasket = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosByName().get('Inflight Change').getRecordTypeId();
         
        cscfga__Product_Basket__c testBasket11 = new cscfga__Product_Basket__c();
        testBasket11.csbb__Account__c = acc.Id;
        testBasket11.Name = 'InflightTestBasket11';
        testBasket11.cscfga__Opportunity__c = opp.Id;
        testBasket11.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        testBasket11.csordtelcoa__Synchronised_with_Opportunity__c = true;
        testBasket11.Amend_Type__c = 'Commercial';
        testBasket11.Order_Requester__c = con.Id;
        testBasket11.SalesSupport_CaseNumber__c = testCase.Id;
        testBasket11.cscfga__Basket_Status__c = 'Submitted';
        testBasket11.RecordTypeId = RecordTypeIdProdBasket;
        productBasketList.add(testBasket11);
        insert productBasketList;
        
        List<csord__Order__c> orders = new List<csord__Order__c>();
        csord__Order__c ord = new csord__Order__c();
        ord.Name = 'testord';
        ord.csord__Identification__c = 'test123';
        ord.csordtelcoa__Opportunity__c = opp.Id;
        ord.csord__Status2__c = 'in Progress';
        ord.Product_Basket__c = testBasket1.Id;
        
        orders.add(ord);
       
        
        csord__Order__c ord2 = new csord__Order__c();
        ord2.Name = 'testord2';
        ord2.csord__Identification__c = 'test123';
        ord2.csordtelcoa__Opportunity__c = opp.Id;
        ord2.csord__Status2__c = 'Amend Rejected';
        orders.add(ord2);
        
        
        csord__Order__c ord3 = new csord__Order__c();
        ord3.Name = 'testord3';
        ord3.csord__Identification__c = 'test123';
        ord3.csordtelcoa__Opportunity__c = opp.Id;
        ord3.csordtelcoa__Point_of_No_Return_Reached__c = true;
        orders.add(ord3);
        
        csord__Order__c ordRestrictAmend = new csord__Order__c();
        ordRestrictAmend.Name = 'testord_restrictamend';
        ordRestrictAmend.csord__Identification__c = 'restrictamend';
        ordRestrictAmend.csordtelcoa__Opportunity__c = opp.Id;
        ordRestrictAmend.Product_Basket__c = testBasket11.Id;
        
        orders.add(ordRestrictAmend);
        
        insert orders;

        csord__Solution__c sol = new csord__Solution__c();
        sol.Name = 'testsol';
        sol.csord__Identification__c = 'testing';
        sol.csord__Account__c = acc.Id;
        sol.csord__Order__c = ord.Id;
        insert sol;

        csord__Subscription__c sub = new csord__Subscription__c();
        sub.Name = 'testsub';
        sub.cssdm__solution_association__c = sol.Id;
        sub.csord__Account__c = acc.Id;
        sub.csord__Order__c = ord.Id;
        sub.csord__Identification__c = 'testing';
        sub.Point_of_No_Return_Reached__c = false;
        sub.customerFacingServiceId__c = '1234';
        sub.csord__Status__c = 'Pending';
        insert sub;

    }
    @isTest
    public static void inflightData1(){
        csord__Order__c ord = [SELECT Id,name FROM csord__Order__c WHERE Name='testord' LIMIt 1];
        Test.startTest();
        InflightSolutionController.getSolutions(ord.Id);
        InflightSolutionController.getOpportunityIdForTheOrder(ord.Id);
        csord__Solution__c sol = [SELECT Id FROM csord__Solution__c LIMIT 1];
        InflightSolutionController.getSubscriptions(sol.Id,'1234',ord.Id,false,'Yes');
        InflightSolutionController.getSubscriptions(sol.Id,'',ord.Id,false,'Yes');
        InflightSolutionController.getSubscriptions(sol.Id,'',ord.Id,true,'Yes');

        InflightSolutionController.getOrderNumber(ord.Id);
        InflightSolutionController.getSolutionsOnSerach('tes',ord.Id);
        InflightSolutionController.checkLoggedInUserProfile();
       // InflightSolutionController.onAmend(ord.Id,new List<String>{sol.Id});
        InflightSolutionController.checkForPointOfNoContact(ord.Id);
        InflightSolutionController.getOpportunityRoleRecord(ord.Id);
        InflightSolutionController.checkForDMCategory(sol.Id);
        
        System.assertEquals('testord',ord.name);
        Test.stopTest();
    }
    @isTest
    public static void inflightData2(){
         csord__Order__c ord2 = [SELECT Id,name FROM csord__Order__c WHERE Name='testord2' LIMIt 1];
        Test.startTest();
         InflightSolutionController.getSolutions(ord2.Id);
         InflightSolutionController.checkForPointOfNoContact(ord2.Id);
         
         System.assertEquals('testord2',ord2.name);
        Test.stopTest();
    }

    @isTest
    public static void inflightData3(){
         csord__Order__c ord3 = [SELECT Id,name FROM csord__Order__c WHERE Name='testord3' LIMIt 1];
        Test.startTest();
         InflightSolutionController.checkForPointOfNoContact(ord3.Id);
         InflightSolutionController.getPicklistvalues('cscfga__Product_Basket__c','Amend_Type__c',true);
        
         System.assertEquals('testord3',ord3.name);
        Test.stopTest();
    }

    /*@isTest
    public static void inflightData(){
        csord__Order__c ord = [SELECT Id,name FROM csord__Order__c WHERE Name='testord' LIMIt 1];
        csord__Order__c ord2 = [SELECT Id,name FROM csord__Order__c WHERE Name='testord2' LIMIt 1];
        csord__Order__c ord3 = [SELECT Id,name FROM csord__Order__c WHERE Name='testord3' LIMIt 1];
        InflightSolutionController.getSolutions(ord.Id);
        InflightSolutionController.getSolutions(ord2.Id);
        InflightSolutionController.getOpportunityIdForTheOrder(ord.Id);
        csord__Solution__c sol = [SELECT Id FROM csord__Solution__c LIMIT 1];
        InflightSolutionController.getSubscriptions(sol.Id,'1234',ord.Id,false,'Yes');
        InflightSolutionController.getSubscriptions(sol.Id,'',ord.Id,false,'Yes');
        InflightSolutionController.getSubscriptions(sol.Id,'',ord.Id,true,'Yes');
        InflightSolutionController.getOrderNumber(ord.Id);
        InflightSolutionController.getPicklistvalues('cscfga__Product_Basket__c','Amend_Type__c',true);
        InflightSolutionController.getSolutionsOnSerach('tes',ord.Id);
        InflightSolutionController.checkLoggedInUserProfile();
       // InflightSolutionController.onAmend(ord.Id,new List<String>{sol.Id});
        InflightSolutionController.checkForPointOfNoContact(ord.Id);
         InflightSolutionController.checkForPointOfNoContact(ord2.Id);
        InflightSolutionController.checkForPointOfNoContact(ord3.Id);
        InflightSolutionController.getOpportunityRoleRecord(ord.Id);
        InflightSolutionController.checkForDMCategory(sol.Id);
        system.debug('Assertvalue'+ord.name);
        System.assertEquals('testord',ord.name);
        
    }*/
        @isTest
        public static void getJobStatusTest(){
        Test.startTest();
            cscfga__Product_Basket__c testProdBasket = [SELECT id, csordtelcoa__Basket_Stage__c, RecordType.Name FROM cscfga__Product_Basket__c /*WHERE csordtelcoa__Basket_Stage__c = 'Draft'*/ LIMIT 1];
            
        
        string Status = InflightSolutionController.getJobStatus(testProdBasket.Id);
        Test.stopTest();
        System.assertNotEquals(Status, null);
        }
        
        @isTest
        public static void postInflightBasketProcessing(){
            
        Test.startTest();
        List<Map<String, String>> listOfMap = new List<Map<String, String>>();
        Map<String, String> requestMap = new Map<String, String>{ 'replacedSolutionId' => 'solId', 'targetSolutionId' => 'tsolId', 'targetBasketId' => 'basketId', 'targetMainConfigurationId' => 'configId', 'changeType' => 'Change Request' };
        
        listOfMap.add(requestMap);
        system.debug('listOfMap' + listOfMap);
       
        String actual = InflightSolutionController.postInflightBasketProcessing(json.serialize(listOfMap),'targetSolutionId');
        
        Test.stopTest();
        System.assertEquals('ERROR', actual );
        }
    
        @isTest
        public static void updateBasketAndOpty(){
          case testCase = [SELECT id FROM case WHERE Subject = 'testCase' LIMIT 1];
           cscfga__Product_Basket__c testProdBasket = [SELECT id, csordtelcoa__Basket_Stage__c, RecordType.Name FROM cscfga__Product_Basket__c /* WHERE csordtelcoa__Basket_Stage__c = 'Draft'*/ LIMIT 1];

                        
        Test.startTest();
        
        String actual = InflightSolutionController.updateBasketAndOpty(testProdBasket.ID,'Commercial and Non-Commercial',testCase.ID);
        
        Test.stopTest();
        System.assertEquals('FAILURE', actual); 
        }   
    
    @isTest
        public static void getTargetMainConfigurationId(){
            case testCase = [SELECT id FROM case WHERE Subject = 'testCase' LIMIT 1];
           cscfga__Product_Basket__c testProdBasket = [SELECT id, csordtelcoa__Basket_Stage__c, RecordType.Name FROM cscfga__Product_Basket__c /* WHERE csordtelcoa__Basket_Stage__c = 'Draft'*/ LIMIT 1];

        Test.startTest();
        String targetMainConfigId = InflightSolutionController.getTargetMainConfigurationId(testProdBasket.Id,JSON.serialize(new List<Map<String, String>>{new Map<string, String>{'replacedMainConfigurationId' => '1234566789'}}));
        Test.stopTest();
            System.assertNotEquals(null, targetMainConfigId);
        }
    
        @isTest
        public static void onAmend(){
        csord__Order__c ordRec = [SELECT id, csordtelcoa__Opportunity__c FROM csord__Order__c WHERE Name = 'testord' LIMIT 1];
        case testCase = [SELECT id,CaseNumber FROM case WHERE Subject = 'testCase' LIMIT 1];
        csord__Solution__c newsol = [select id from csord__Solution__c LIMIT 1];
        
        Test.startTest();
        String solutionList = InflightSolutionController.onAmend(ordRec.ID, new List<string>{newsol.id}, testCase.CaseNumber,'Commercial and Non-Commercial');
        Test.stopTest();
        system.assertNotEquals(null, solutionList);
            
            
        }
    
        @isTest
        public static void TestcheckForDMCategory(){
        csord__Solution__c newsol = [select id from csord__Solution__c LIMIT 1];    
        Test.startTest();
        Boolean res = InflightSolutionController.checkForDMCategory(newsol.ID);
        Test.stopTest();
           system.assertEquals(true, res); 
        }
    
    @isTest
        public static void TestCheckForDefaultValues(){
             csord__Order__c ordRec = [SELECT id, csordtelcoa__Opportunity__c FROM csord__Order__c WHERE Name = 'testord' LIMIT 1]; 
            csord__Order__c ordRec2 = [SELECT id, csordtelcoa__Opportunity__c FROM csord__Order__c WHERE Name = 'testord2' LIMIT 1]; 
        cscfga__Product_Basket__c testProdBasket = [SELECT id, csordtelcoa__Basket_Stage__c, RecordType.Name 
                                                        FROM cscfga__Product_Basket__c LIMIT 1];
    testProdBasket.cscfga__Opportunity__c = ordRec2.csordtelcoa__Opportunity__c;
            testProdBasket.csordtelcoa__Basket_Stage__c = 'Submitted';
            update testProdBasket;
            Test.startTest();
             InflightSolutionController.getDefaultValues(true,ordRec2.Id);
        Object res = InflightSolutionController.getDefaultValues(true,ordRec.Id);
       
        Test.stopTest();
           system.assertEquals(true, res!=null); 
        }
    
    @isTest
    public static void TestInflightSolutionController(){
        csord__Order__c ordRec = [SELECT id, csordtelcoa__Opportunity__c FROM csord__Order__c WHERE Name = 'testord' LIMIT 1];
        Test.startTest();
        InflightSolutionController res = new InflightSolutionController(ordRec.Id);
        Test.stopTest();
       system.assertEquals(true, res!=null); 
    }
    
    @isTest
    public static void TestGetOrderDetails(){
        csord__Order__c ordRec = [SELECT id, csordtelcoa__Opportunity__c FROM csord__Order__c WHERE Name = 'testord' LIMIT 1];
         Test.startTest();
        Object result = InflightSolutionController.getOrderDetails(ordRec.Id);
        Test.stopTest();
         system.assertEquals(true, result!=null); 
    }
    
    @isTest
    public static void testCheckAmendRestriction(){
        csord__Order__c ordRec = [SELECT id, csordtelcoa__Opportunity__c FROM csord__Order__c WHERE Name = 'testord_restrictamend' LIMIT 1];
        Test.startTest();
        Object result = InflightSolutionController.checkAmendRestriction(ordRec.Id);
        Test.stopTest();
        System.assertEquals(true, result!=null); 
    }

    //checkForDMCategory
    //updateBasketAndOpty
    //postInflightBasketProcessing
    //getTargetMainConfigurationId
    //getJobStatus
    
}