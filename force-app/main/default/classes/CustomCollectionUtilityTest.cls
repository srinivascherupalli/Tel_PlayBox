/*************************************************************************************************
Name : CustomCollectionUtilityTest
===============================================================================================================================    
 Sr.No.     Developer Name      Date            Story           Description
    1.      Vamsi            25/MAR/2021       EDGE-178892     Device Id to be updated in Heroku to enable quick search in solution console
===============================================================================================================================
***************************************************************************************************/
@isTest
public class CustomCollectionUtilityTest {
    
         @TestSetup
   public static void testSetup(){
       
               Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        List<User> listOfUsers = new List<User>();
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        //insert sales;
        listOfUsers.add(sales);

        Profile asaProfile = [select id from profile where name = 'Assurance Service Agent'];
        User asa = new User(alias = 'asauser',email='asauser@testasauser.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='ASA_Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = asaProfile.id,
                              timezonesidkey='Australia/Sydney',
                              username='asauser@testasauser.com',phone='0424289156');
        listOfUsers.add(asa);
        Insert listOfUsers;
       
    List<csord__Solution__c> solList = new List<csord__Solution__c>();
    csord__Solution__c solution = new csord__Solution__c();
    solution.Name = 'Test Solution';
    solution.csord__Identification__c = 'Solution Management';
    solList.add(solution);
       
    csord__Solution__c solution1 = new csord__Solution__c();
    solution1.Name = 'Test Solution';
    solution1.csord__Identification__c = 'Solution Management';
    solList.add(solution1);
       
    insert solList;
   }
      
    @isTest
  static void testIfCase(){
    Test.startTest();
    User asaUser = [SELECT id,name FROM User Where username='asauser@testasauser.com'];      
    System.runAs(asaUser){
     Map<String,List<Id>> returnMap = new Map<String,List<Id>>();
     Map<String,List<Id>> fromMap = new Map<String,List<Id>>();
        
        List<Id> ids = new List<Id>();
    List<csord__Solution__c> sollst = [SELECT id FROM csord__Solution__c];
        for(csord__Solution__c obj:sollst)
        {
            ids.add(obj.id);
        }
        
        fromMap.put('solutionId', ids);
        returnMap.put('solutionId', ids);
        CustomCollectionUtility.copyMap(returnMap,fromMap);
    }
    Test.stopTest();
      List<csord__Solution__c> lstOfSol = [SELECT id FROM csord__Solution__c];
      system.assert(lstOfSol != null && !lstOfSol.isEmpty());
  }
    
        @isTest
  static void testElseCase(){
    Test.startTest();
    User asaUser = [SELECT id,name FROM User Where username='asauser@testasauser.com'];      
    System.runAs(asaUser){
     Map<String,List<Id>> returnMap = new Map<String,List<Id>>();
     Map<String,List<Id>> fromMap = new Map<String,List<Id>>();
        
        List<Id> ids = new List<Id>();
    List<csord__Solution__c> sollst = [SELECT id FROM csord__Solution__c];
        for(csord__Solution__c obj:sollst)
        {
            ids.add(obj.id);
        }
        
        fromMap.put('solutionId', ids);
        CustomCollectionUtility.copyMap(returnMap,fromMap);
    }
    Test.stopTest();
      List<csord__Solution__c> lstOfSol = [SELECT id FROM csord__Solution__c];
      system.assert(lstOfSol != null && !lstOfSol.isEmpty());
  }

}