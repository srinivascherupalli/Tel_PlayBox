/*************************************************************************************************
Name : Model_Subscription
===============================================================================================================================
Sr.No.    Developer Name      Date            Story Description
1.        Shubhi              21-09-2020      DIGI-16898  (new)
================================================================================================================================
***************************************************************************************************/
@isTest
public class macDiscountHandlerTest {
	public static Governor_Limits__c governerLimit = new Governor_Limits__c();
    public static List<account> accountList = new List<account>();
    public static List<Opportunity> OpportunityList = new List<Opportunity>();
    public static List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
    public static List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
    public static List<csord__Service__c> servlist = new List<csord__Service__c>();
    public static List<csord__Order__c> orderList = new List<csord__Order__c>();
    public static list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
    public static list<cscfga__Product_Configuration__c> productconfiglistList1 = new List<cscfga__Product_Configuration__c>();
    public static list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
    public static List<Marketable_Offer__c> marketableList = new List<Marketable_Offer__c>();
    public static List<Charge_Line_Item__c> cLIs = new List<Charge_Line_Item__c>();
    public static List<Discount_Line_Item__c> dSLIs = new List<Discount_Line_Item__c>();
    
    public static List<ApplicationLog__c> appLog = new List<ApplicationLog__c>();
    public static List<cscrm__Site__c> sites = new List<cscrm__Site__c>();
    
    @Testsetup
    static void dataSetup() {
        governerLimit = Orchestration_TestUtility.buildLimits();
        
        accountList = Orchestration_TestUtility.buildAccount(false, 2);
        accountList[1].Customer_Status__c = 'Acquired';
        insert accountList;
        
        OpportunityList = Orchestration_TestUtility.buildOpp(false, 1, accountList);
        OpportunityList[0].Model_Change__c = false;
        insert OpportunityList;
        Billing_Account__c ba = new Billing_Account__c();
        ba.Account__c = accountList[0].Id;
        ba.Billing_Account_Number__c = '123123122234';
        insert ba;
        
        sites = Orchestration_TestUtility.buildsite(true, 1, accountList);
        cscfga__Product_Basket__c pb = new cscfga__Product_Basket__c(Name = 'test', cscfga__Opportunity__c = OpportunityList[0].Id);
        insert pb;
        List<cscfga__Product_Definition__c> productDefList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c productDef = new cscfga__Product_Definition__c(
          Name = 'Mobile Subscription', // Name
          csordtelcoa__Product_Type__c = 'Subscription', // Product Type
          cscfga__Description__c = 'Mobile Subscription', // Description
          cscfga__Label__c = 'Mobile Subscription', // Label
          product_Specification__c = 'DMCAT_ProductSpecification_000420' // product Specification 
          
        );
        productDefList.add(productDef);
        cscfga__Product_Definition__c productDefNGUC = new cscfga__Product_Definition__c(
                        Name = 'User Support', // Name
                        csordtelcoa__Product_Type__c = 'Subscription', // Product Type
                        cscfga__Description__c = 'User Support', // Description
                        cscfga__Label__c = 'User Support', // Label
                        product_Specification__c = 'DMCAT_ProductSpecification_000871' // product Specification
                        
                    );
                    
        productDefList.add(productDefNGUC);
        insert productDefList;
        
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false, 2);
        orderList[0].Billing_Account__c = ba.Id;
        orderList[1].Billing_Account__c = ba.Id;
        insert orderList;
        
        //orderList[0].csord__Primary_Order__c = orderList[0].Id;
        orderList[1].csord__Primary_Order__c = orderList[0].Id;
        update orderList;
        
        Orchestration_TestUtility.productconfiglistList = new list<cscfga__Product_Configuration__c>();
        productconfiglistList1 = Orchestration_TestUtility.buildProductConfiguration(true, 1);
        Orchestration_TestUtility.productconfiglistList = new list<cscfga__Product_Configuration__c>();
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 8);
        productconfiglistList[0].ConfigurationType1__c = '';
        productconfiglistList[0].cscfga__Product_Definition__c = productDef.Id;
        productconfiglistList[0].cscfga__Product_Basket__c = pb.Id;
        productconfiglistList[0].csordtelcoa__Replaced_Product_Configuration__c = productconfiglistList1[0].id;
        productconfiglistList[7].ConfigurationType1__c = '';
        productconfiglistList[7].cscfga__Product_Definition__c = productDefList[1].Id;
        productconfiglistList[7].cscfga__Product_Basket__c = pb.Id;  
        update productconfiglistList;
        
        solutionList = Orchestration_TestUtility.buildSolution(false, 2);
        solutionList[0].Name = 'TestSubsforTest0';
        insert solutionList;
        
        marketableList = Orchestration_TestUtility.buildMarkertableOffer(false, 2);
        marketableList[0].Auto_Expired_Entity__c = true;
        marketableList[0].Offer_ID__c = 'DMCAT_Offer_000646';
        marketableList[0].Invoice_Definition__c = 'TEST_DEFINITION';
        // marketableList[0].Auto_Expired_Entity__c = true;
        marketableList[1].Auto_Expired_Entity__c = true;
        marketableList[1].Offer_ID__c = 'DMCAT_Offer_000618';
        marketableList[1].Invoice_Definition__c = 'Invoice_Def_1';
        insert marketableList;
        
        subscriptionList = Orchestration_TestUtility.buildSubscription(false, 2, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        csord__Subscription__c sbs = [SELECT Id FROM csord__Subscription__c];
        subscriptionList[0].csord__Account__c = accountList[1].id; // account which is already in Acquired state.
        subscriptionList[0].Name = 'Unified Communication Tenancy Solution';
        subscriptionList[0].MarketableOffer__c = marketableList[0].id;
        subscriptionList[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
        subscriptionList[0].Billing_Account__c = ba.Id;
        subscriptionList[0].Site__c = sites[0].Id;
        subscriptionList[0].isAggregationPoint__c = true;
        subscriptionList[0].oldServiceMSISDN__c = 'Testing';
        subscriptionList[1].csordtelcoa__Replaced_Subscription__c = sbs.Id;
        subscriptionList[0].csordtelcoa__Replaced_Subscription__c = sbs.Id;
        subscriptionList[0].autoExpiry__c = true;
        subscriptionList[1].autoExpiry__c = true;
        subscriptionList[0].TenancyID__c = 'T1002';
        csord__Subscription__c subPrdChar=new csord__Subscription__c();
        subPrdChar.name  = 'TestPrdChar';
        subPrdChar.csord__Identification__c = 'TestPrdChar';
        subPrdChar.csord__Status__c='Provisioned';
        subPrdChar.csord__Order__c = orderList[0].Id;
        subPrdChar.csordtelcoa__Product_Configuration__c=productconfiglistList[0].id;
        //subPrdChar.Billing_Account__c=billingAccount.id;
        subscriptionList.add(subPrdChar);
        
        csord__Subscription__c subFNN=new csord__Subscription__c();
        subFNN.name  = 'TestPrdCharFNN';
        subFNN.csord__Identification__c = 'TestPrdCharFNN';
        subFNN.csord__Status__c='Provisioned';
        subFNN.csord__Order__c = orderList[0].Id;
        subFNN.csordtelcoa__Product_Configuration__c=productconfiglistList[0].id;
        subscriptionList.add(subFNN);
        
        csord__Subscription__c subCOMN =new csord__Subscription__c();
        subCOMN.name  = 'TestChangeOfNum';
        subCOMN.csord__Identification__c = 'TestChangeOfNum';
        subCOMN.csord__Status__c='Provisioned';
        subCOMN.csord__Order__c = orderList[0].Id;
        subCOMN.csordtelcoa__Product_Configuration__c=productconfiglistList[0].id;
        subCOMN.serviceMSISDN__c = '61244547317';
        subCOMN.oldServiceMSISDN__c = '61244547316';
        subscriptionList.add(subCOMN);
            
        csord__Subscription__c subPrdChar1=new csord__Subscription__c();
        subPrdChar1.name  = 'TestRFA';
        subPrdChar1.csord__Identification__c = 'TestRFA';
        subPrdChar1.csord__Status__c='Ready for Activation';
        subPrdChar1.Trigger_RFA__c= true;
        subPrdChar1.csord__Order__c = orderList[0].Id;
        subPrdChar1.csordtelcoa__Product_Configuration__c=productconfiglistList[1].id;
        subscriptionList.add(subPrdChar1);
        csord__Subscription__c testSubscription = new csord__Subscription__c();
                      testSubscription.MarketableOffer__c = marketableList[1].id;
                      testSubscription.Name = 'test Subscription for NGUC';
                      testSubscription.csord__Account__c = accountList[1].id;
                      testSubscription.csord__Identification__c = 'test';
                      testSubscription.csord__Status__c = OrchestratorConstants.SubscriptionStatus.Active; // used in Orchestration_EvaluateOrderStatusTest
                      testSubscription.csord__Order__c = orderList[0].id; // used in Orchestration_EvaluateOrderStatusTest
                      testSubscription.csordtelcoa__Product_Configuration__c = productconfiglistList[7].id;   
                      testSubscription.triggerBill_RTB__c = false;
                      //testSubscription.Billing_Account__c = ba[0];
                      testSubscription.cssdm__solution_association__c = solutionList[0].id;
                      testSubscription.isAggregationPoint__c = true;
                      testSubscription.oldServiceMSISDN__c = 'Testing';
                      testSubscription.autoExpiry__c = true;
                      testSubscription.TenancyID__c = 'T1002';
                      subscriptionList.add(testSubscription);
    
        insert subscriptionList;
        
        servlist = Orchestration_TestUtility.buildService(false, 2, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        servList[0].Scenario_Type__c = 'Change of Mobile Number';
        servList[1].Scenario_Type__c = 'Replace SIM';
        servList[0].Offer_Type__c = 'Committed Data';
        servList[0].Mobility_Plan__c = 'Local Data SIM BYO';
        servlist[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
        
        csord__Service__c prdCharServ = new csord__Service__c();
        prdCharServ.name ='TestProdChar';
        prdCharServ.csord__Identification__c  = 'TestProdChar';
        prdCharServ.csord__Subscription__c = subPrdChar.Id;
        prdCharServ.csord__Status__c = 'Connected'; 
        prdCharServ.csord__Order__c = orderList[0].Id;
        servlist.add(prdCharServ);
        
        csord__Service__c prdCharFNN = new csord__Service__c();
        prdCharFNN.name ='TestProdCharFNN';
        prdCharFNN.csord__Identification__c  = 'TestProdCharFNN';
        prdCharFNN.csord__Subscription__c = subFNN.Id;
        prdCharFNN.csord__Status__c = 'Connected'; 
        prdCharFNN.csord__Order__c = orderList[0].Id;
        servlist.add(prdCharFNN);
            
        csord__Service__c prdCharCOMN = new csord__Service__c();
        prdCharCOMN.name ='TestProdCharFNN';
        prdCharCOMN.csord__Identification__c  = 'TestProdCharFNN';
        prdCharCOMN.csord__Subscription__c = subCOMN.Id;
        prdCharCOMN.csord__Status__c = 'Connected'; 
        prdCharCOMN.csord__Order__c = orderList[0].Id;
        prdCharCOMN.Scenario_Type__c = 'Change of Mobile Number';
        servlist.add(prdCharCOMN);
            
        csord__Service__c prdCharServ1 = new csord__Service__c();
        prdCharServ1.name ='TestProdChar1';
        prdCharServ1.csord__Identification__c  = 'TestProdChar1';
        prdCharServ1.csord__Subscription__c = subPrdChar1.Id;
        prdCharServ1.csord__Status__c = 'In Progress'; 
        prdCharServ1.csord__Order__c = orderList[0].Id;
        servlist.add(prdCharServ1);
        csord__Service__c ngucService = new csord__Service__c();
        ngucService.csord__Order__c = orderList[0].Id;
        ngucService.csord__Status__c = 'created';
        ngucService.csord__Identification__c  = 'ngucService';
        ngucService.csord__Subscription__c = testSubscription.Id;
        ngucService.csordtelcoa__Product_Configuration__c = productconfiglistList[7].id;
        ngucService.Scenario_Type__c = 'NGUC Service';
        servlist.add(ngucService);
       
        insert servlist;
        
        cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 1, servlist));
        cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 1, servlist));
        cLIs.addAll(Orchestration_TestUtility.buildCLIs(false, 1, servlist));
        cLIs[0].chargeType__c = 'Tiered Recurring';
        cLIs[1].chargeType__c = 'Tiered Recurring';
        //cLIs[1].
        insert cLIs;
        
        dSLIs.addAll(Orchestration_TestUtility.buildDLIs(true, 3, cLIs));
       	dSLIs[0].isUnlimited__c=true;
        update dSLIs[0];
	}
    @isTest
  	static void TestDMS() {        
      Map<String, Object> inputMap=new Map<String, Object>();
      inputMap.put('getCarryForwardDiscounts','');
      String inputConfigList= '';
      for(cscfga__Product_Configuration__c pc:[Select id from cscfga__Product_Configuration__c]){
            if(inputConfigList!='')
                inputConfigList+=','+pc.id;
         	else
                inputConfigList+=pc.id; 
      }
      inputMap.put('configList',inputConfigList); 
      inputMap.put('checkFeatureEligibility',''); 
      Map<String, Object> returnMap=macDiscountHandler.getData(inputMap);
      system.assert(returnMap.containsKey('enableTED423'));
 	}
}