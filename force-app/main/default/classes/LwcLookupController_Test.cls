@isTest
private with sharing class LwcLookupController_Test {
    static testMethod void findRecords_account(){
        Account ac = new Account();
        ac.name = 'Test';
        insert ac;
        Account ac1 = new Account();
        ac1.name = 'Test1';
        insert ac1;
        Account ac2 = new Account();
        ac2.name = 'Test2';
        insert ac2;

        Contact con2 = new Contact(LastName ='testCon2',AccountId = ac.Id);
        insert con2;

        csord__Order__c ord = new csord__Order__c();
        ord.Name = 'TestOrder';
        ord.csord__Account__c = ac.Id;
        ord.csord__Identification__c = 'test Indentification';
        insert ord;
        string acc = 'AccountId=\''+ac.Id+'\'';
        String searchFields='CIDN__c';
        List < SObject > returnrec = LwcLookupController.findRecords('t', 'contact',acc,searchFields);
        system.assertEquals(returnrec.Size() > 0 ,true); 
        
    }
}