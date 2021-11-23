/******************************************************************************************************************************
Class Name : PerformOpsAfterMigrationTest
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint
1.      Aman Soni           03/03/2021    EDGE-191138(New Class)           21.03
******************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class PerformOpsAfterMigrationTest{

   //Desc: Test Data Setup
   @TestSetup
   public static void setup(){
     Profile pf = [select id from profile where name =:Label.Profile_SystemAdmin];
     User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                      lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                      profileid = pf.id,
                      timezonesidkey='Australia/Sydney',
                      username='adminuser@testAdmin.com',phone='+121231231234');
    insert sales;
    
    List<Account> accLst= new List<Account>();
    Account accOut = new Account();
    accOut.name = 'Test CHOWN Outgoing Account';
    accLst.add(accOut);
    
    Account accIn = new Account();
    accIn.name = 'Test CHOWN Incoming Account';
    accLst.add(accIn);
    insert accLst;

    List<Opportunity> opptyLst= new List<Opportunity>();
    Opportunity opptyOut = new Opportunity();
    opptyOut.Account = accOut;
    opptyOut.name = 'Test CHOWN Outgoing Oppty';
    opptyOut.StageName = 'Propose';
    opptyOut.CloseDate = System.today()+1;
    opptyLst.add(opptyOut);
    
    Opportunity opptyIn = new Opportunity();
    opptyIn.Account = accIn;
    opptyIn.name = 'Test CHOWN Incoming Oppty';
    opptyIn.StageName = 'Propose';
    opptyIn.CloseDate = System.today()+1;
    opptyLst.add(opptyIn);
    insert opptyLst;
    
    List<cscfga__Product_Basket__c> basketLst= new List<cscfga__Product_Basket__c>();
    cscfga__Product_Basket__c basketOut = new cscfga__Product_Basket__c();
    basketOut.name = 'Test CHOWN Outgoing Basket';
    basketOut.BasketType__c = 'Outgoing';
    basketOut.csbb__Account__c = accOut.id;
    basketOut.cscfga__Opportunity__c = opptyOut.id;
    basketLst.add(basketOut);
    
    cscfga__Product_Basket__c basketIn = new cscfga__Product_Basket__c();
    basketIn.name = 'Test CHOWN Outgoing Basket';
    basketIn.BasketType__c = 'Incoming';
    basketIn.csbb__Account__c = accIn.id;
    basketIn.cscfga__Opportunity__c = opptyIn.id;
    basketLst.add(basketIn);
    insert basketLst;
    
    List<cscfga__Product_Configuration__c> configLst = new List<cscfga__Product_Configuration__c>();
    cscfga__Product_Configuration__c configOut = new cscfga__Product_Configuration__c();         
    configOut.name = 'Test Outgoing Config';
    configOut.configGUID__c = 'dfghjkl56789067890vbnjkf';
    configOut.cscfga__Product_Basket__c = basketOut.Id;
    configOut.ConfigurationType1__c = '';
    configLst.add(configOut);
    
    cscfga__Product_Configuration__c configIn = new cscfga__Product_Configuration__c();         
    configIn.name = 'Test Outgoing Config';
    configIn.configGUID__c = 'dfghjkl56789067890vbnjkf';
    configIn.cscfga__Product_Basket__c = basketIn.Id;
    configIn.ConfigurationType1__c = '';
    configLst.add(configIn);
    insert configLst;
    
    List<csord__Subscription__c> subList = new List<csord__Subscription__c>();  
    csord__Subscription__c subOut = new csord__Subscription__c();
    subOut.csord__Identification__c = 'Subscription_1';
    subOut.csordtelcoa__Product_Configuration__c = configOut.id;
    subOut.name = 'Test Outgoing Subscription';
    subOut.csordtelcoa__Replacement_Subscription__c = null;
    subList.add(subOut);
    
    csord__Subscription__c subIn = new csord__Subscription__c();
    subIn.csord__Identification__c = 'Subscription_2';
    subIn.csordtelcoa__Product_Configuration__c = configIn.id;
    subIn.name = 'Test Incoming Subscription';
    subIn.csordtelcoa__Replaced_Subscription__c = null;
    subList.add(subIn);
    insert subList;
    
    List<csord__Service__c> servList = new List<csord__Service__c>();
    csord__Service__c servOut = new csord__Service__c();
    servOut.csordtelcoa__Product_Configuration__c = configOut.id;
    servOut.csord__Subscription__c = subOut.id;
    servOut.csord__Identification__c = 'Service_0';
    servOut.name = 'Test Outgoing Service';
    servList.add(servOut);
    
    csord__Service__c servIn = new csord__Service__c();
    servIn.csordtelcoa__Product_Configuration__c = configIn.id;
    servIn.csord__Subscription__c = subIn.id;
    servIn.csord__Identification__c = 'Service_1';
    servIn.csordtelcoa__Replaced_Service__c = null;
    servIn.name = 'Test Incoming Service';
    servList.add(servIn);
    insert servList;
    
    List<Migration_Change_Request__c> mcrLst = new List<Migration_Change_Request__c>();
    Migration_Change_Request__c mcr = new Migration_Change_Request__c();
    mcr.migration_status__c = 'Completed';
    String basketOutId = basketOut.id;
    String basketInId = basketIn.id;
    String basketMACId = basketOutId+','+basketInId;
    mcr.macd_basket_ids__c = basketMACId;
    mcrLst.add(mcr);
    insert mcrLst;
  }
  
  //Positive Scenario
  @IsTest
  public static void linkSubsAfterMigrationPositive(){
    User sales = [select id,name,lastname from User where username='adminuser@testAdmin.com' limit 1];
    System.runAS(sales){      
    Test.startTest();
    Migration_Change_Request__c mcrRec = [select id,macd_basket_ids__c from Migration_Change_Request__c limit 1];
    PerformOpsAfterMigration perOps = new PerformOpsAfterMigration();
    perOps.linkSubsAfterMigration(mcrRec.Id);
    csord__Subscription__c subInc = [select id,name,csordtelcoa__Replaced_Subscription__c from csord__Subscription__c where name = 'Test Incoming Subscription' limit 1];
    csord__Subscription__c subOut = [select id,name,csordtelcoa__Replacement_Subscription__c from csord__Subscription__c where name = 'Test Outgoing Subscription' limit 1];
    csord__Service__c servOut = [select id,name,csordtelcoa__Replacement_Service__c from csord__Service__c where name ='Test Outgoing Service'];
    csord__Service__c servIn = [select id,name,csordtelcoa__Replaced_Service__c from csord__Service__c where name ='Test Incoming Service'];
    System.assertEquals(subInc.csordtelcoa__Replaced_Subscription__c, subOut.id);
    System.assertEquals(subOut.csordtelcoa__Replacement_Subscription__c, subInc.id);
    System.assertEquals(servIn.csordtelcoa__Replaced_Service__c, servOut.id);
    System.assertEquals(servOut.csordtelcoa__Replacement_Service__c, servIn.id);
    Test.stopTest();
    }  
  }
  
  //Negative Scenario
  @IsTest
  public static void linkSubsAfterMigrationNegative(){
    User sales = [select id,name,lastname from User where username='adminuser@testAdmin.com' limit 1];
    System.runAS(sales){      
    Test.startTest();
    PerformOpsAfterMigration perOps = new PerformOpsAfterMigration();
    String mcrId ='';
    perOps.linkSubsAfterMigration(mcrId);
    csord__Subscription__c subInc = [select id,name,csordtelcoa__Replaced_Subscription__c from csord__Subscription__c where name = 'Test Incoming Subscription' limit 1];
    System.assertEquals(subInc.csordtelcoa__Replaced_Subscription__c, null);
    Test.stopTest();
    }  
  }
}