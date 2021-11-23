/******************************************************************************************************************************
Class Name : GetSyncTransitionDeviceTest
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint
1.      Aman Soni           20/03/2020    EDGE-173469(New Class)           20.14
2.      Aman Soni           05/02/2021    EDGE-191077                      21.02
3.      Aman Soni           17/02/2021    EDGE-203220                      21.03
4.      Aman Soni           08/04/2021    EDGE-207355                      21.05

******************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class GetSyncTransitionDeviceTest{
    
   //Desc: Test Data Setup
   @TestSetup
   public static void setup(){
     Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
     User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                      lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                      profileid = pf.id,
                      timezonesidkey='Australia/Sydney',
                      username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;
    
    //Added for EDGE-191077 || Start    
    Id recordTypeOppty = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
    
    List<Account> accLst= new List<Account>();
    Account acc = new Account();
    acc.name = 'Test Account';
    accLst.add(acc);
    insert accLst;

    List<Opportunity> opptyLst= new List<Opportunity>();
    Opportunity oppty = new Opportunity();
    oppty.Account = acc;
    oppty.name = 'Test Oppty';
    oppty.recordtypeId = recordTypeOppty;
    oppty.Type = 'Migration';
    oppty.StageName = 'Develop';
    oppty.CloseDate = System.today()+1;
    opptyLst.add(oppty);
    
    Opportunity oppty1 = new Opportunity();
    oppty1.Account = acc;
    oppty1.name = 'Test New Oppty';
    oppty1.recordtypeId = recordTypeOppty;
    oppty1.Type = 'New To Market';
    oppty1.StageName = 'Develop';
    oppty1.CloseDate = System.today()+1;
    opptyLst.add(oppty1);
    insert opptyLst;
    
    List<cscfga__Product_Basket__c> basketLst= new List<cscfga__Product_Basket__c>();
    cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
    basket.name = 'Test Basket';
    basket.csbb__Account__c = acc.id;
    basket.cscfga__Opportunity__c = oppty.id;
    basketLst.add(basket);
    
    cscfga__Product_Basket__c basket1 = new cscfga__Product_Basket__c();
    basket1.name = 'Test Basket';
    basket1.csbb__Account__c = acc.id;
    basket1.cscfga__Opportunity__c = oppty1.id;
    basketLst.add(basket1);
    insert basketLst;
    //Added for EDGE-191077 || End 
    
    List<Legacy_Service__c> legcyServLst= new List<Legacy_Service__c>();
    Legacy_Service__c legcyServ = new Legacy_Service__c();
    legcyServ.Eligibility_Status__c = 'Eligible';
    legcyServ.Select__c = true;
    legcyServ.Product_Basket__c = basket.id;
    legcyServLst.add(legcyServ);
    
    Legacy_Service__c legcyServ1 = new Legacy_Service__c();
    legcyServ1.Eligibility_Status__c = 'Eligible';
    legcyServ1.Select__c = false;
    legcyServ1.Product_Basket__c = basket1.id;
    legcyServLst.add(legcyServ1);
    insert legcyServLst;
    
    List<Service_Add_On__c> servAddOnLst= new List<Service_Add_On__c>();
    Service_Add_On__c servAddOn = new Service_Add_On__c();
    servAddOn.Device_Id__c = '1234568';
    servAddOn.Name = 'Test Service Add On';
    servAddOn.Status__c = 'Ready for Sync';
    servAddOn.Instance_Id__c = '43227651';
    servAddOn.Contract_Type__c = 'MRO';
    servAddOn.Product_Basket__c = null;
    servAddOn.Solution_Id__c = '';
    servAddOn.Monthly_Amount__c = 5;
    servAddOn.Legacy_Billing_Account_Number__c = '3456789';
    servAddOn.Residual_Remaining_Amount__c =2;
    servAddOn.Residual_Remaining_Term__c=3;
    servAddOn.Account__c = acc.id;
    servAddOn.Transaction_Type__c = 'Migration';
    servAddOn.Legacy_Service__c = legcyServ.id;
    servAddOn.SKU__c = '333333333';
    servAddOnLst.add(servAddOn);
    
    Service_Add_On__c servAddOn1 = new Service_Add_On__c();
    servAddOn1.Device_Id__c = '1234568';
    servAddOn1.Name = 'Test Service Add On';
    servAddOn1.Status__c = 'Ready for Sync';
    servAddOn1.Instance_Id__c = '43227650';
    servAddOn1.Contract_Type__c = 'MRO';
    servAddOn1.Product_Basket__c = null;
    servAddOn1.Solution_Id__c = '';
    servAddOn1.Monthly_Amount__c = 10;  
    servAddOn1.Legacy_Billing_Account_Number__c = '3456789';
    servAddOn1.Account__c = acc.id;
    servAddOn1.Residual_Remaining_Amount__c =2;
    servAddOn1.Residual_Remaining_Term__c=3;
    servAddOn1.Transaction_Type__c = 'Migration';
    servAddOn1.Legacy_Service__c = legcyServ.id;
    servAddOn1.SKU__c = '222222222';
    servAddOnLst.add(servAddOn1);
    
    Service_Add_On__c servAddOn2 = new Service_Add_On__c();
    servAddOn2.Device_Id__c = '1234568';
    servAddOn2.Name = 'Test Service Add On';
    servAddOn2.Status__c = 'Sync Removal Pending';
    servAddOn2.Instance_Id__c = '43227652';
    servAddOn2.Contract_Type__c = 'MRO';
    servAddOn2.Product_Basket__c = basket1.id;
    servAddOn2.Solution_Id__c = '';
    servAddOn2.Monthly_Amount__c = 10;  
    servAddOn2.Legacy_Billing_Account_Number__c = '3456789';
    servAddOn2.Account__c = acc.id;
    servAddOn2.Residual_Remaining_Amount__c =2;
    servAddOn2.Residual_Remaining_Term__c=3;
    servAddOn2.Transaction_Type__c = 'Transition';
    servAddOn2.Legacy_Service__c = legcyServ1.id;
    servAddOn2.SKU__c = '333333333';
    servAddOnLst.add(servAddOn2);
    insert servAddOnLst;    
       
        List<cspmb__Price_Item__c> priceItemList = new List<cspmb__Price_Item__c> ();
        cspmb__Price_Item__c pi = new cspmb__Price_Item__c();
        pi.Name = 'Mobile Device';
        pi.Billing_Description__c = 'Apple iPhone Xr 128GB Black';
        pi.cspmb__Is_Active__c = true;
        pi.SKU__c = '333333333';
        pi.Contract_Type__c = 'Hardware Repayment';
        priceItemList.add(pi);
        cspmb__Price_Item__c pi1 = new cspmb__Price_Item__c();
        pi1.Name = 'Mobile Device 1';
        pi1.Billing_Description__c = 'Apple iPhone Xr 128GB White';
        pi1.cspmb__Is_Active__c = true;
        pi1.SKU__c = '222222222';
        pi1.Contract_Type__c = 'Hardware Repayment';
        priceItemList.add(pi1);
        insert priceItemList;
       
        
  }

  //Desc: Positive scenario for getData
  @IsTest
  public static void getDataTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    System.runAS(sales){
    Test.startTest();
        Map<String,Object> inputMap = new Map<String,Object>();
        List<cscfga__Product_Basket__c> basketRec = [select id,name from cscfga__Product_Basket__c];
        String basketId = basketRec[0].id;
        String instanceId ='43227659';
        String solutionId = '45678dfghjklhgf';
        String category = 'Transition Device';
        String contractType = '';
        if(category.equalsIgnoreCase('Transition Device')){
            contractType = 'MRO';
        }
        String instanceIdStatus ='43227651';
        inputMap.put('basketId', basketId);
        inputMap.put('instanceIdList', instanceId);
        inputMap.put('insLstForStatusUpd', instanceIdStatus);
        inputMap.put('solutionId', solutionId);
        inputMap.put('category', category);
        inputMap.put('contractType', contractType);
        Map<String, Object> returnMap = new Map<String, Object>();   
        returnMap = GetSyncTransitionDevice.getData(inputMap);
        System.assertEquals(false, returnMap.containsKey('GetSyncTransitionDevice'));
    Test.stopTest();
    }
  }

  //Desc: Method for getBasketOpptyType || Added for EDGE-191077
  @IsTest
  public static void getBasketOpptyTypeTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    System.runAS(sales){
    Test.startTest();
        List<cscfga__Product_Basket__c> basketRec = [select id,name from cscfga__Product_Basket__c];
        String basketId = basketRec[0].id;
        String opptyType;  
        opptyType = GetSyncTransitionDevice.getBasketOpptyType(basketId);
        System.assertEquals('Migration', opptyType);
    Test.stopTest();
    }
  }
  
  //Desc: Method for getServiceAddOns || Added for EDGE-191077
  @IsTest
  public static void getServiceAddOnsTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    System.runAS(sales){   
    Test.startTest();   
        Service_Add_On__c addOn = [select id,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Transaction_Type__c,Product_Basket__c,SKU__c from Service_Add_On__c limit 1];  
        List<cscfga__Product_Basket__c> basketRec = [select id,name,csbb__Account__c from cscfga__Product_Basket__c];
        String basketId = basketRec[0].id;
        String inst = '43227651';
        String category = 'Transition Device';
        String contractType = '';
        if(category.equalsIgnoreCase('Transition Device')){
            contractType = 'MRO';
        }
        List<String> instIdList = new List<String>();
        instIdList.add(inst);
        
        Map<String, List<String>> priceItemMap = new Map<String, List<String>>();
         String billingDesc = '';
        String sku = '';
        String skuValue = '';
        String skuNewValue = '';
        String billingDescValue = '';
        String billingDescNewValue = '';
		List<String> skuList = new List<String> ();
		List<String> piList = new List<String> ();  
        Set<Service_Add_On__c> servAddSet = new Set<Service_Add_On__c>();
		servAddSet.add(addOn);
		for(Service_Add_On__c servAdd : servAddSet){
			skuValue = 'skuValue';
			sku = servAdd.SKU__c;
			skuList.add(sku);
			priceItemMap.put(skuValue, skuList);
		}
        for(String skuFinalValue : skuList){
            skuNewValue = skuFinalValue;
        }
         List<cspmb__Price_Item__c> priceItems = [SELECT Id, Billing_Description__c, cspmb__Is_Active__c, SKU__c, Contract_Type__c FROM cspmb__Price_Item__c WHERE SKU__c =: skuNewValue LIMIT 1];
        Set<cspmb__Price_Item__c> priceItemSet = new Set<cspmb__Price_Item__c>();
        priceItemSet.addAll(priceItems);
		 for(cspmb__Price_Item__c priceItemValue : priceItemSet){
			 billingDesc = 'billingDescription';
			 billingDescValue = priceItemValue.Billing_Description__c;
			 piList.add(billingDescValue);
			 priceItemMap.put(billingDesc, piList);
		 }
        for(String billingDescFinalValue : piList){
            billingDescNewValue = billingDescFinalValue;
        }
        
        List<ServiceAddOnWrapperData> servAddWrapList = new List<ServiceAddOnWrapperData>();    
        servAddWrapList = GetSyncTransitionDevice.getServiceAddOns(basketId, '', contractType, category, instIdList);
        for(ServiceAddOnWrapperData servWrapper : servAddWrapList){
             System.assertEquals(addOn.Status__c, servWrapper.status );
        }
    Test.stopTest();
    }
  }
  
  //Desc: Method for getFilteredRecForSelectedBAN || Added for EDGE-191077
  @IsTest
  public static void getFilteredRecForSelectedBANTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    System.runAS(sales){ 
    Test.startTest();
        Service_Add_On__c addOn = [select id,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Transaction_Type__c,Product_Basket__c from Service_Add_On__c limit 1];  
        List<cscfga__Product_Basket__c> basketRec = [select id,name,csbb__Account__c from cscfga__Product_Basket__c];
        String basketId = basketRec[0].id;
        String inst = '43227651';
        List<String> instIdList = new List<String>();
        instIdList.add(inst);
        String mainBAN = '3456789';
        String category = 'Transition Device';
        String contractType = '';
        if(category.equalsIgnoreCase('Transition Device')){
            contractType = 'MRO';
        }
        List<ServiceAddOnWrapperData> servAddWrapList = new List<ServiceAddOnWrapperData>();    
        servAddWrapList = GetSyncTransitionDevice.getFilteredRecForSelectedBAN(basketId, '', contractType, category, mainBAN, instIdList);
        for(ServiceAddOnWrapperData servWrapper : servAddWrapList){
             System.assertEquals(addOn.Legacy_Billing_Account_Number__c, servWrapper.legacyBillingAccount);
        }
    Test.stopTest();
    }
  }
  
  //Desc: Method for getFilteredRecForSelectedBAN || Added for EDGE-207355 
  @IsTest
  public static void getFilteredRecForSelectedBANAllTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    System.runAS(sales){ 
    Test.startTest();
        Service_Add_On__c addOn = [select id,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Transaction_Type__c,Product_Basket__c from Service_Add_On__c limit 1];  
        List<cscfga__Product_Basket__c> basketRec = [select id,name,csbb__Account__c from cscfga__Product_Basket__c];
        String basketId = basketRec[0].id;
        String inst = '43227651';
        List<String> instIdList = new List<String>();
        instIdList.add(inst);
        String mainBAN = 'All';
        String category = 'Transition Device';
        String contractType = '';
        if(category.equalsIgnoreCase('Transition Device')){
            contractType = 'MRO';
        }
        List<ServiceAddOnWrapperData> servAddWrapList = new List<ServiceAddOnWrapperData>();    
        servAddWrapList = GetSyncTransitionDevice.getFilteredRecForSelectedBAN(basketId, '', contractType, category, mainBAN, instIdList);
        for(ServiceAddOnWrapperData servWrapper : servAddWrapList){
             System.assertEquals(addOn.Legacy_Billing_Account_Number__c, servWrapper.legacyBillingAccount);
        }
    Test.stopTest();
    }
  }
  
  //Desc: Method for getLegacyBillAccount || Added for EDGE-191077
  @IsTest
  public static void getLegacyBillAccountTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    System.runAS(sales){   
    Test.startTest();
        Service_Add_On__c addOn = [select id,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Transaction_Type__c,Product_Basket__c from Service_Add_On__c limit 1];  
        List<cscfga__Product_Basket__c> basketRec = [select id,name,csbb__Account__c from cscfga__Product_Basket__c];
        String basketId = basketRec[0].id;
        String category = 'Transition Device';
        String contractType = '';
        if(category.equalsIgnoreCase('Transition Device')){
            contractType = 'MRO';
        }
        List<String> banLst = new List<String>();   
        banLst = GetSyncTransitionDevice.getLegacyBillAccount(basketId,'',category,contractType);
        for(String ban : banLst){
             System.assertEquals(addOn.Legacy_Billing_Account_Number__c, '3456789');
        }
    Test.stopTest();
    }
  }
  
  //Desc: Method for getSynRemPendingRecs Transition Scenario || Added for EDGE-191077
  @IsTest
  public static void getSynRemPendingRecsTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    Opportunity oppty = [Select id,name,Type from Opportunity where Type = 'New To Market' limit 1];
    System.runAS(sales){   
    Test.startTest();   
        cscfga__Product_Basket__c basketRec = [select id,name,csbb__Account__c,cscfga__Opportunity__c,Opportunity_Type__c  from cscfga__Product_Basket__c where cscfga__Opportunity__c =: oppty.id limit 1];
        List<Id> addOnIdlst = new List<Id>();
        List<Service_Add_On__c> addOnlst = [select id,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Transaction_Type__c,Product_Basket__c from Service_Add_On__c where Transaction_Type__c ='Transition'];
        for(Service_Add_On__c addOn : addOnlst){
            addOnIdlst.add(addOn.id);
        }     
        String opptyType = basketRec.Opportunity_Type__c;
        String basketId = basketRec.id;  
        GetSyncTransitionDevice.getSynRemPendingRecs(basketId,addOnIdlst);
        List<Service_Add_On__c> updatedAddonlst = [select id,name,Status__c from Service_Add_On__c where id IN: addOnIdlst];
        for(Service_Add_On__c addOn : updatedAddonlst){
              System.assertEquals(addOn.Status__c, 'Sync Removal Completed');
        }
    Test.stopTest();
    }
  }
  
  //Desc: Method for getSynRemPendingRecs Migration Scenario|| Added for EDGE-191077
  @IsTest
  public static void getSynRemPendingRecsTransTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    Opportunity oppty = [Select id,name,Type from Opportunity where Type = 'Migration' limit 1];
    System.runAS(sales){   
    Test.startTest();   
        cscfga__Product_Basket__c basketRec = [select id,name,csbb__Account__c,cscfga__Opportunity__c,Opportunity_Type__c  from cscfga__Product_Basket__c where cscfga__Opportunity__c =: oppty.id limit 1];
        List<Id> addOnIdlst = new List<Id>();
        List<Service_Add_On__c> addOnlst = [select id,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Transaction_Type__c,Product_Basket__c from Service_Add_On__c where Transaction_Type__c ='Migration'];
        for(Service_Add_On__c addOn : addOnlst){
            addOnIdlst.add(addOn.id);
        }     
        String opptyType = basketRec.Opportunity_Type__c;
        String basketId = basketRec.id;     
        GetSyncTransitionDevice.getSynRemPendingRecs(basketId,addOnIdlst);      
        List<Service_Add_On__c> updatedAddonlst = [select id,name,Status__c from Service_Add_On__c where id IN: addOnIdlst];
        for(Service_Add_On__c addOn : updatedAddonlst){
             System.assertEquals(addOn.Status__c, 'Ready for Sync');
        }
    Test.stopTest();
    }
  }
  
  //Desc: Positive Scenario for getSyncPendingRecsForTransition || Added for EDGE-203220
  @IsTest
  public static void getSyncPendingRecsForTransitionTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    Opportunity oppty = [Select id,name,Type from Opportunity where Type = 'New To Market' limit 1];
    System.runAS(sales){   
    Test.startTest();
        cscfga__Product_Basket__c basketRec = [select id,name,csbb__Account__c,cscfga__Opportunity__c,Opportunity_Type__c  from cscfga__Product_Basket__c where cscfga__Opportunity__c =: oppty.id limit 1];
        Service_Add_On__c addOn = [select id,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Transaction_Type__c,Product_Basket__c, SKU__c from Service_Add_On__c where Transaction_Type__c = 'Transition' limit 1];
        String basketId = basketRec.id;
        String inst = '43227652';
        List<String> instIdList = new List<String>();
        instIdList.add(inst);
        String solutionId = '';
        String category = 'Transition Device';
        String contractType = '';
        if(category.equalsIgnoreCase('Transition Device')){
            contractType = 'MRO';
        }
          Map<String, List<String>> priceItemMap = new Map<String, List<String>>();
         String billingDesc = '';
        String billingDescValue = '';
        String billingDescNewValue = '';
		List<String> skuList = new List<String> ();
		List<String> piList = new List<String> ();
         List<cspmb__Price_Item__c> priceItems = [SELECT Id, Billing_Description__c, cspmb__Is_Active__c, SKU__c, Contract_Type__c FROM cspmb__Price_Item__c LIMIT 1];
        Set<cspmb__Price_Item__c> priceItemSet = new Set<cspmb__Price_Item__c>();
        priceItemSet.addAll(priceItems);
		 for(cspmb__Price_Item__c priceItemValue : priceItemSet){
			 billingDesc = 'billingDescription';
			 billingDescValue = priceItemValue.Billing_Description__c;
			 piList.add(billingDescValue);
			 priceItemMap.put(billingDesc, piList);
		 }
        for(String billingDescFinalValue : piList){
            billingDescNewValue = billingDescFinalValue;
        }
        List<ServiceAddOnWrapperData> wrapLst = new List<ServiceAddOnWrapperData>();        
        wrapLst = GetSyncTransitionDevice.getSyncPendingRecsForTransition(basketId,solutionId,contractType,category,instIdList);
        for(ServiceAddOnWrapperData servWrapper : wrapLst){
             System.assertEquals(addOn.Status__c, servWrapper.status);
        }
    Test.stopTest();
    }
  }

  //Desc: Negative Scenario for getSyncPendingRecsForTransition || Added for EDGE-203220
  @IsTest
  public static void getSyncPendingRecsForTransitionNegTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    System.runAS(sales){   
    Test.startTest();
        String basketId = '';
        String inst = '43227652';
        List<String> instIdList = new List<String>();
        instIdList.add(inst);
        String solutionId = '';
        String category = 'Transition Device';
        String contractType = '';
        if(category.equalsIgnoreCase('Transition Device')){
            contractType = 'MRO';
        }
        List<ServiceAddOnWrapperData> wrapLst = new List<ServiceAddOnWrapperData>();        
        wrapLst = GetSyncTransitionDevice.getSyncPendingRecsForTransition(basketId,solutionId,contractType,category,instIdList);
        System.assertEquals(wrapLst.size(), 0);
    Test.stopTest();
    }
  }
    // Added for EDGE-208433
  @IsTest
  public static void fetchBillingDescriptionFromPriceItemTest(){
	  
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    System.runAS(sales){ 
    Map<String, List<String>> priceItemMap = new Map<String, List<String>>();
        Map<String, List<String>> skuMap = new Map<String, List<String>>();
		Test.startTest();
        Service_Add_On__c addOn = [select id,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Transaction_Type__c,Product_Basket__c,SKU__c from Service_Add_On__c limit 1];
        String billingDesc = '';
        String sku = '';
        String skuValue = '';
        String skuNewValue = '';
        String billingDescValue = '';
        String billingDescNewValue = '';
		List<String> skuList = new List<String> ();
		List<String> piList = new List<String> ();  
        Set<Service_Add_On__c> servAddSet = new Set<Service_Add_On__c>();
		servAddSet.add(addOn);
		for(Service_Add_On__c servAdd : servAddSet){
			skuValue = 'skuValue';
			sku = servAdd.SKU__c;
			skuList.add(sku);
			priceItemMap.put(skuValue, skuList);
		}
        for(String skuFinalValue : skuList){
            skuNewValue = skuFinalValue;
        }
         List<cspmb__Price_Item__c> priceItems = [SELECT Id, Billing_Description__c, cspmb__Is_Active__c, SKU__c, Contract_Type__c FROM cspmb__Price_Item__c WHERE SKU__c =: skuNewValue LIMIT 1];
        Set<cspmb__Price_Item__c> priceItemSet = new Set<cspmb__Price_Item__c>();
        priceItemSet.addAll(priceItems);
		 for(cspmb__Price_Item__c priceItemValue : priceItemSet){
			 billingDesc = 'billingDescription';
			 billingDescValue = priceItemValue.Billing_Description__c;
			 piList.add(billingDescValue);
			 priceItemMap.put(billingDesc, piList);
		 }
        for(String billingDescFinalValue : piList){
            billingDescNewValue = billingDescFinalValue;
        }

        Map<String, String> fetchBillingMap = new Map<String, String>();
		fetchBillingMap = GetSyncTransitionDevice.fetchBillingDescriptionFromPriceItem(servAddSet);
		System.assertEquals(priceItems.size()>0, true);
		Test.stopTest();
	}
  }
}