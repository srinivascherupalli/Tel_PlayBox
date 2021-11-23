/******************************************************************************************************************************
Class Name : Model_ServiceAddOnsTest
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint
1.      Aman Soni           20/03/2020    EDGE-173469(New Class)           20.14
2.      Aman Soni           05/02/2021    EDGE-191077                      21.02
3.      Aman Soni           05/02/2021    EDGE-194029                      21.02
4.      Aman Soni           17/02/2021    EDGE-203220                      21.03

******************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class Model_ServiceAddOnsTest{

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
    Opportunity opptyMigration = new Opportunity();
    opptyMigration.Account = acc;
    opptyMigration.recordtypeId = recordTypeOppty;
    opptyMigration.name = 'Test Oppty Migration';
    opptyMigration.Type = 'Migration';
    opptyMigration.StageName = 'Develop';
    opptyMigration.CloseDate = System.today()+1;
    opptyLst.add(opptyMigration);
    
    Opportunity opptyTransition = new Opportunity();
    opptyTransition.Account = acc;
    opptyTransition.recordtypeId = recordTypeOppty;
    opptyTransition.name = 'Test Oppty Transition';
    opptyTransition.Type = 'New To Market';
    opptyTransition.StageName = 'Develop';
    opptyTransition.CloseDate = System.today()+1;
    opptyLst.add(opptyTransition);
    insert opptyLst;
    
    List<cscfga__Product_Basket__c> basketLst= new List<cscfga__Product_Basket__c>();
    cscfga__Product_Basket__c basketMig = new cscfga__Product_Basket__c();
    basketMig.name = 'Test Migration Basket';
    basketMig.csbb__Account__c = acc.id;
    basketMig.cscfga__Opportunity__c = opptyMigration.id;
    basketLst.add(basketMig);
    
    cscfga__Product_Basket__c basketTrans = new cscfga__Product_Basket__c();
    basketTrans.name = 'Test Transition Basket';
    basketTrans.csbb__Account__c = acc.id;
    basketTrans.cscfga__Opportunity__c = opptyTransition.id;
    basketLst.add(basketTrans);
    insert basketLst;
    //Added for EDGE-191077 || End 
    
    List<Legacy_Service__c> legcyServLst= new List<Legacy_Service__c>();
    Legacy_Service__c legcyServ = new Legacy_Service__c();
    legcyServ.Eligibility_Status__c = 'Eligible';
    legcyServ.Select__c = true;
    legcyServ.Product_Basket__c = basketMig.id;
    legcyServLst.add(legcyServ);
    
    Legacy_Service__c legcyServTrans = new Legacy_Service__c();
    legcyServTrans.Eligibility_Status__c = 'Eligible';
    legcyServTrans.Select__c = false;
    legcyServTrans.Product_Basket__c = basketTrans.id;
    legcyServLst.add(legcyServTrans);
    insert legcyServLst;
    
    List<Service_Add_On__c> servAddOnLst= new List<Service_Add_On__c>();
    Service_Add_On__c servAddOn = new Service_Add_On__c();
    servAddOn.Device_Id__c = '1234568';
    servAddOn.Name = 'Test Service Add On';
    servAddOn.Status__c = 'Ready for Sync';
    servAddOn.Instance_Id__c = '43227654';
    servAddOn.Product_Basket__c = basketMig.id;
    servAddOn.Contract_Type__c = 'MRO';
    servAddOn.Account__c = acc.id;
    servAddOn.Legacy_Service__c = legcyServ.id;
    servAddOn.Transaction_Type__c = 'Migration';
    servAddOnLst.add(servAddOn);
    
    Service_Add_On__c servAddOn1 = new Service_Add_On__c();
    servAddOn1.Device_Id__c = '1234568';
    servAddOn1.Name = 'Test Service Add On1';
    servAddOn1.Status__c = 'Ready for Sync';
    servAddOn1.Instance_Id__c = '43227655';
    servAddOn1.Product_Basket__c = basketMig.id;
    servAddOn1.Contract_Type__c = 'MRO';
    servAddOn1.Account__c = acc.id;
    servAddOn1.Transaction_Type__c = 'Migration';
    servAddOn1.Legacy_Service__c = legcyServ.id;
    servAddOnLst.add(servAddOn1);
    
    Service_Add_On__c servAddOn2 = new Service_Add_On__c();
    servAddOn2.Device_Id__c = '1234568';
    servAddOn2.Name = 'Test Service Add On2';
    servAddOn2.Status__c = 'Sync Removal Pending';
    servAddOn2.Instance_Id__c = '43227651';
    servAddOn2.Product_Basket__c = basketTrans.id;
    servAddOn2.Solution_Id__c = 'sdfghrtyuio3456';
    servAddOn2.Contract_Type__c = 'MRO';
    servAddOn2.Transaction_Type__c = 'Transition';
    servAddOn2.Legacy_Service__c = legcyServTrans.id;
    servAddOnLst.add(servAddOn2);
    insert servAddOnLst;
  }
  
  //Desc: Method for getServAddOnsForCleanUp || Added for EDGE-194029
  @IsTest
  public static void getServAddOnsForCleanUpTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    Opportunity oppty = [Select id,name from Opportunity where Type ='Migration' limit 1];
    System.runAS(sales){      
    Test.startTest();
    List<cscfga__Product_Basket__c> basketLst = [select id,name,csbb__Account__c,cscfga__Opportunity__c from cscfga__Product_Basket__c where cscfga__Opportunity__c =: oppty.id];
    List<Service_Add_On__c> serAddOnList = new List<Service_Add_On__c>();   
    serAddOnList = Model_ServiceAddOns.getServAddOnsForCleanUp(basketLst);
    for(Service_Add_On__c serv : serAddOnList){
        System.assertEquals(serv.Status__c, 'Ready for Sync');
    }       
    Test.stopTest();
    }  
  }
  
  //Desc: Method for retSyncRemPendingBeforeSave || Added for EDGE-191077
  @IsTest
  public static void retSyncRemPendingBeforeSaveTest(){
     User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    System.runAS(sales){
    Test.startTest();
        List<Id> addOnlst = new List<Id>();
        for(Service_Add_On__c addOn : [select id,name,Legacy_Service__r.Select__c,Device_Id__c,Mobile_Handset_Model__c,Mobile_Handset_Manufacturer__c,Device_ID_Type__c,Account__c,Legacy_Billing_Account_Number__c,Status__c,Device_Type__c,Solution_Id__c,Contract_Type__c,Monthly_Amount__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Instance_Id__c,Transaction_Type__c,Product_Basket__c from Service_Add_On__c]){
        addOnlst.add(addOn.id); 
        }
        
        Set<Service_Add_On__c> servAddOnSet = new Set<Service_Add_On__c>(); 
        servAddOnSet = Model_ServiceAddOns.retSyncRemPendingBeforeSave(addOnlst);
        for(Service_Add_On__c serv : servAddOnSet){
            if(serv.Transaction_Type__c == 'Migration'){
                System.assertEquals(serv.Transaction_Type__c, 'Migration'); 
            }else{
                System.assertEquals(serv.Transaction_Type__c, 'Transition');    
            }
            
        }       
    Test.stopTest();
    }  
  }
  
  //Desc: Method for returnServiceAddonRecords || Added for EDGE-191077
  @IsTest
  public static void returnServiceAddonRecordsMigrationTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];        
    List<Account> acc = [select id,name from Account];
    System.runAS(sales){    
    Test.startTest();  
        String basketId = '';
        String solutionId = '';
        String category = 'Transition Device';
        String contractType = '';
        if(category.equalsIgnoreCase('Transition Device')){
            contractType = 'MRO';
        }
        Id accountId = acc[0].id;
        String opptyType = 'Migration';
        Set<Service_Add_On__c> servAddOnSet = new Set<Service_Add_On__c>(); 
        servAddOnSet = Model_ServiceAddOns.returnServiceAddonRecords(basketId, solutionId, contractType, category, accountId, opptyType);
        for(Service_Add_On__c serv : servAddOnSet){
            System.assertEquals(serv.Transaction_Type__c, 'Migration');
        }       
    Test.stopTest();
    }  
  }

  //Desc: Method for returnServiceAddonRecords || Added for EDGE-191077
  @IsTest
  public static void returnServiceAddonRecordsTransitionTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    Opportunity oppty = [Select id,name from Opportunity where Type ='New To Market'];
    System.runAS(sales){   
    Test.startTest();
        cscfga__Product_Basket__c basketRec = [select id,name,csbb__Account__c,cscfga__Opportunity__c,Opportunity_Type__c from cscfga__Product_Basket__c where cscfga__Opportunity__c=: oppty.Id limit 1];
        String basketId = basketRec.id;
        String solutionId = '';
        String category = 'Transition Device';
        String contractType = '';
        if(category.equalsIgnoreCase('Transition Device')){
            contractType = 'MRO';
        }
        Id accountId = null;
        String opptyType = basketRec.Opportunity_Type__c;
        Set<Service_Add_On__c> servAddOnSet = new Set<Service_Add_On__c>(); 
        servAddOnSet = Model_ServiceAddOns.returnServiceAddonRecords(basketId, solutionId, contractType, category, accountId, opptyType);
        for(Service_Add_On__c serv : servAddOnSet){
            System.assertEquals(serv.Transaction_Type__c, 'Transition');
        }       
    Test.stopTest();
    }  
  }
  
  //Desc: Positive Scenario for getSynRemPendingAddOnsForTransition || Added for EDGE-203220
  @IsTest
  public static void getSynRemPendingAddOnsForTransitionTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1 ];
    Opportunity oppty = [Select id,name from Opportunity where Type ='New To Market'];  
    System.runAS(sales){   
    Test.startTest();
        cscfga__Product_Basket__c basketRec = [select id,name,csbb__Account__c,cscfga__Opportunity__c,Opportunity_Type__c from cscfga__Product_Basket__c where cscfga__Opportunity__c=: oppty.Id limit 1];
        String basketId = basketRec.id;
        String solutionId = 'sdfghrtyuio3456';
        String category = 'Transition Device';
        String contractType = '';
        if(category.equalsIgnoreCase('Transition Device')){
            contractType = 'MRO';
        }
        Id accountId = null;
        String opptyType = basketRec.Opportunity_Type__c;
        Set<Service_Add_On__c> servAddOnSet = new Set<Service_Add_On__c>(); 
        servAddOnSet = Model_ServiceAddOns.getSynRemPendingAddOnsForTransition(basketId, solutionId, contractType, category, opptyType);
        for(Service_Add_On__c serv : servAddOnSet){
            System.assertEquals(serv.Status__c, 'Sync Removal Pending');
        }       
    Test.stopTest();
    }  
  }
  
  //Desc: Negative scenario for getSynRemPendingAddOnsForTransition || Added for EDGE-203220
  @IsTest
  public static void getSynRemPendingAddOnsForTransitionNegTest(){
    User sales = [select name,id, lastname from  User where username='salesunifieduser@testsales.com' limit 1];
    Opportunity oppty = [Select id,name,Type from Opportunity where Type ='Migration'];
    System.runAS(sales){   
    Test.startTest();    
        cscfga__Product_Basket__c basketRec = [select id,name,csbb__Account__c,cscfga__Opportunity__c,Opportunity_Type__c from cscfga__Product_Basket__c where cscfga__Opportunity__c=: oppty.Id limit 1];
        String basketId = basketRec.id;
        String solutionId = 'sdfghrtyuio3456';
        String category = 'Transition Device';
        String contractType = '';
        if(category.equalsIgnoreCase('Transition Device')){
            contractType = 'MRO';
        }
        Id accountId = null;
        String opptyType = basketRec.Opportunity_Type__c;
        Set<Service_Add_On__c> servAddOnSet = new Set<Service_Add_On__c>(); 
        servAddOnSet = Model_ServiceAddOns.getSynRemPendingAddOnsForTransition(basketId, solutionId, contractType, category, opptyType);
        System.assertEquals(servAddOnSet.size(), 0);     
    Test.stopTest();
    }  
  }
}