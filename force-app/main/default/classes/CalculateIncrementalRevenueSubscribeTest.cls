/*********************************************************************************************************************************
 *Class Name      :   CalculateIncrementalRevenueSubscriber
 *Story             :   EDGE-89844  Unable to place Mobility Cancel order in QA2 environment
 *Developer         :   Rohit Tripathi

Test Class : CalculateIncrementalRevenueSubscriberTest
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Rohit  Tripathi 		6/7/2019     	 Unable to place Mobility Cancel order in QA2 environment (EDGE-89844)

 *********************************************************************************************************************************
*/
@isTest
public class CalculateIncrementalRevenueSubscribeTest  {
    @TestSetup static void dataSetup()
    {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;

        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.CloseDate = System.Date.today();
        insert testOpp;

        Opportunity testOpp2 = new Opportunity();
        testOpp.Account = testAccount;
        testOpp2.Name = 'testOpp2';
        testOpp2.StageName = 'Define';
        testOpp2.CloseDate = System.Date.today();
        insert testOpp2;

        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'newTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;

        cscfga__Product_Basket__c testBasket2 = new cscfga__Product_Basket__c();
        testBasket2.csbb__Account__c = testAccount.Id;
        testBasket2.Name = 'replacedTestBasket2';
        testBasket2.cscfga__Opportunity__c = testOpp2.Id;
        insert testBasket2;

        List<cscfga__Product_Configuration__c> testConfigList= new List<cscfga__Product_Configuration__c>();

        cscfga__Product_Configuration__c testConfigReplaced = new cscfga__Product_Configuration__c();
        testConfigReplaced.Name = 'replacedConfigTEST';
        testConfigReplaced.cscfga__Product_Basket__c = testBasket.Id;
        testConfigReplaced.cscfga__total_recurring_charge__c = 5;
        testConfigReplaced.cscfga__total_one_off_charge__c = 0;
        insert testConfigReplaced;

        cscfga__Product_Configuration__c testConfigReplaced2 = new cscfga__Product_Configuration__c();
        testConfigReplaced2.Name = 'replacedConfigTEST2';
        testConfigReplaced2.cscfga__Product_Basket__c = testBasket.Id;
        testConfigReplaced2.cscfga__total_recurring_charge__c = 6;
        testConfigReplaced2.cscfga__total_one_off_charge__c = 0;
        insert testConfigReplaced2;

        cscfga__Product_Configuration__c testConfigRoot = new cscfga__Product_Configuration__c();
        testConfigRoot.Name = 'rootConfigTEST';
        testConfigRoot.cscfga__Product_Basket__c = testBasket.Id;
        testConfigRoot.Incremental_Revenue__c = 0;
        testConfigRoot.csordtelcoa__Replaced_Product_Configuration__c = testConfigReplaced2.Id;
        testConfigRoot.cscfga__total_recurring_charge__c = 7;
        testConfigRoot.cscfga__total_one_off_charge__c = 0;
        testConfigList.add(testConfigRoot);
        
        cscfga__Product_Configuration__c testConfigNew = new cscfga__Product_Configuration__c();
        testConfigNew.Name = 'newConfigTEST';
        testConfigNew.cscfga__Product_Basket__c = testBasket.Id;
        testConfigNew.csordtelcoa__Replaced_Product_Configuration__c = testConfigReplaced.Id;
        testConfigNew.cscfga__total_recurring_charge__c = 6;
        testConfigNew.cscfga__total_one_off_charge__c = 0;
        testConfigList.add(testConfigNew);
            
        
        insert testConfigList;

        csord__Order__c testOrder = new csord__Order__c();
        testOrder.Name = 'testOrder';
        testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder.csord__Identification__c = 'test';
        testOrder.csord__End_Date__c = Date.today().addDays(30);
        insert testOrder;
        
    }

    @IsTest
    static void testCalculationFilter()
    {
        List<String> nameList = new List<String>{'replacedConfigTEST','replacedConfigTEST2','rootConfigTEST','newConfigTEST'};
        List<cscfga__Product_Configuration__c> testList = [SELECT id, Name, cscfga__Product_Basket__c, csordtelcoa__Replaced_Product_Configuration__c, cscfga__total_recurring_charge__c 
                                                            FROM cscfga__Product_Configuration__c
                                                            WHERE Name in: nameList];

        List<cscfga__Product_Configuration__c> rootConf = [SELECT id, Name, cscfga__Product_Basket__c, csordtelcoa__Replaced_Product_Configuration__c, cscfga__total_recurring_charge__c, Incremental_Revenue__c 
                                                            FROM cscfga__Product_Configuration__c
                                                            WHERE Name = 'rootConfigTEST'];

        List<Id> IdList = new List<Id>();
        for (cscfga__Product_Configuration__c conf : testList)
        {
            IdList.add(conf.Id);
        }
        CalculateIncrementalRevenueSubscriber testInstance = new CalculateIncrementalRevenueSubscriber();
        Test.startTest();
            testInstance.calculationFilter(IdList, rootConf[0]);
        Test.stopTest();

        System.assertEquals(2.0,rootConf[0].Incremental_Revenue__c,'Calculation incorrect');

    }
     @IsTest
    static void testOnMessage()
    {
        //   string jsonValue = '{"AllConfigs":"[\'testConfigReplaced\']","RootConfig":"[\'testConfigReplaced2\']"}';
        String jsonvalue = '{"d":{"results":[{"AllConfigs":"testConfigReplaced","RootConfig":"testConfigReplaced2"}]}}';
						  
		Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(jsonValue);
			String topic = 'topic';
			String subject = 'subject';
	CalculateIncrementalRevenueSubscriber testInstance = new CalculateIncrementalRevenueSubscriber();
	        Test.startTest();
            testInstance.onMessage(topic, subject,payload);
			Test.stopTest();
	
	
	System.assert(topic!=null);
	

}
}