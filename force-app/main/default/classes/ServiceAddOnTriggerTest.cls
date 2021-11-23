@isTest
public class ServiceAddOnTriggerTest {
    public static testMethod void testPositiveCIDN(){
        
        Account acc = new Account();
        acc.Name = 'Test Account1';
        acc.CIDN__c = '8841630008';        
        insert acc;
        
        test.startTest();
        Service_Add_On__c sAdd = new Service_Add_On__c();
        sAdd.Name = 'Test ServiceAddon1';
        sAdd.CIDN__c = '8841630008'; 
        sAdd.Transaction_Type__c = 'Migration';
        sAdd.Contract_Type__c = 'HRO';
         insert sAdd;
        
        sAdd = [SELECT Id,Account__c FROM Service_Add_On__c WHERE CIDN__c = '8841630008'];
        system.assertEquals(sAdd.Account__c , acc.Id);
        test.stopTest();
    }
    
    public static testMethod void testBulkSAddOn(){
        List<Service_Add_On__c> sAddList = new List<Service_Add_On__c>();
        Account acc = new Account();
        acc.Name = 'Account1';
        acc.CIDN__c = '8841630008';        
        insert acc;
        
        test.startTest();
        Service_Add_On__c sAdd = new Service_Add_On__c();
        for(integer i=1; i<=10; i++){
            sAdd = new Service_Add_On__c(Name = 'ServiceAddon'+i ,CIDN__c = '884163000'+i, Contract_Type__c = 'HRO', Transaction_Type__c = 'Migration' );
      sAddList.add(sAdd);
        }
    insert sAddList;
        
        sAdd = [SELECT Id,Account__c FROM Service_Add_On__c WHERE CIDN__c = '8841630008'];
        system.assertEquals(sAdd.Account__c , acc.Id);
        test.stopTest();
    }
    
    public static testMethod void testNegativeScenario(){
        List<Account> accList = new List<Account>();
        
        Account acc = new Account();
        acc.Name = 'Test Account2';
        acc.CIDN__c = '8841630008';   
        accList.add(acc);
        
        Account acc2 = new Account();
        acc2.Name = 'Test Account3';
        acc2.CIDN__c = '8841630009';
        accList.add(acc2);
        
        insert accList;
        
        test.startTest();
        Service_Add_On__c sAdd = new Service_Add_On__c();
        sAdd.Name = 'Test ServiceAddon2';
        sAdd.CIDN__c = '8841630009';  
        sAdd.Transaction_Type__c = 'Migration';
         insert sAdd;
        
        sAdd = [SELECT Id,Account__c FROM Service_Add_On__c WHERE CIDN__c = '8841630009'];
        system.assertNotEquals(sAdd.Account__c , acc.Id);
        test.stopTest();
    }

}