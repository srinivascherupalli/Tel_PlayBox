@isTest
public class EnvironmentVariableTest {
    
    static testmethod void TestEnvironmentVariablePositive(){
        
        List<EnvironmentVariable__c> lrecord = new List<EnvironmentVariable__c>();
        EnvironmentVariable__c record = new EnvironmentVariable__c();
        record.name='TestData';
        record.value__c='TestValue';
        lrecord.add(record);
        insert lrecord;
        
        EnvironmentVariable.get('TestData');
        EnvironmentVariable.put('NewData', 'NewValue');
        EnvironmentVariable.remove('NewData');
        
         System.assert(lrecord.size()==1);
        
    }  
    
    static testmethod void TestEnvironmentVariableNegative(){
        
        List<EnvironmentVariable__c> lrecord = new List<EnvironmentVariable__c>();
        EnvironmentVariable.get('TestData');
        System.assert(lrecord.size() == 0);
       
    }  

}