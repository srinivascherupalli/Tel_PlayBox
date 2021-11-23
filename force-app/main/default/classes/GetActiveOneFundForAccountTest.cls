@isTest
public class GetActiveOneFundForAccountTest {

    private void setup(){
         //CREATE ACCOUNT
        List<Account> AccList = new List<Account>();
        Account acc1 = AccountTestFactory.buildAccount('Test Account1');
        acc1.Customer_Status__c='Active'; 
        acc1.CIDN__c = '1234567';
        acc1.Parent_CIDN__c = '76576878';
        acc1.Ultimate_Parent_CIDN__c = '34556557';  
        AccList.add(acc1);
            
        Account acc2 = AccountTestFactory.buildAccount('Test Account2');
        acc2.Customer_Status__c='Active'; 
        acc2.CIDN__c = '76576878';
        AccList.add(acc2);
        
        Account acc3 = AccountTestFactory.buildAccount('Test Account3');
        acc3.Customer_Status__c='Active'; 
        acc3.CIDN__c = '34556557';
        AccList.add(acc3);
        
        Account acc4 = AccountTestFactory.buildAccount('Test Account4');
        acc4.Customer_Status__c='Active'; 
        acc4.CIDN__c = '12345743';
        acc4.Parent_CIDN__c = '76576878';
        acc4.Ultimate_Parent_CIDN__c = '34556557';  
        AccList.add(acc4);
        
        Account acc5 = AccountTestFactory.buildAccount('Test Account5');
        acc5.Customer_Status__c='Active'; 
        acc5.CIDN__c = '12345703';
        acc5.Parent_CIDN__c = '10000000';
        acc5.Ultimate_Parent_CIDN__c = '34556557';  
        AccList.add(acc5);
        
        insert AccList;
        
        List<OneFund__c> OFList = new List<OneFund__c>();
        OneFund__c onefund1 = new OneFund__c();
        onefund1.CIDN__c = acc1.id;
        onefund1.OneFund_Status__c = 'Active';
        onefund1.Start_Date__c = system.today();
        onefund1.OneFund_Accrual_Frequency__c = 'Monthly';
        OFList.add(onefund1);
        
        OneFund__c onefund2 = new OneFund__c();
        onefund2.CIDN__c = acc2.id;
        onefund2.OneFund_Status__c = 'Active';
        onefund2.Start_Date__c = system.today();
        onefund2.OneFund_Accrual_Frequency__c = 'Monthly';
        OFList.add(onefund2);
        
        OneFund__c onefund3 = new OneFund__c();
        onefund3.CIDN__c = acc3.id;
        onefund3.OneFund_Status__c = 'Active';
        onefund3.Start_Date__c = system.today();
        onefund3.OneFund_Accrual_Frequency__c = 'Monthly';
        OFList.add(onefund3);
        
        insert OFList; 
}
    @isTest
    //test with child CIDN
    static void getOneFundIdTestScenario1() {
        GetActiveOneFundForAccountTest test1 = new GetActiveOneFundForAccountTest();
        test1.setup();
        Test.startTest();
        Account acc = [Select Id from Account where name ='Test Account1' limit 1];
        String ofid = null;
        ofid = GetActiveOneFundForAccount.getOneFundId(acc.id);
        OneFund__c ofidacc = [Select Id from OneFund__c where CIDN__c =:acc.id];
        Test.stopTest();
        System.assertEquals(ofid, ofidacc.Id);
      
    }
    @isTest
    //test with parent CIDN
     static void getOneFundIdTestScenario2() {
        GetActiveOneFundForAccountTest test1 = new GetActiveOneFundForAccountTest();
        test1.setup();
        Test.startTest();
        Account acc = [Select Id from Account where name ='Test Account4' limit 1];
        Account acc1 = [Select Id from Account where name ='Test Account2' limit 1];
        String ofid = null;
        ofid = GetActiveOneFundForAccount.getOneFundId(acc.id);
        OneFund__c ofidacc = [Select Id from OneFund__c where CIDN__c =:acc1.id];
        Test.stopTest();
        System.assertEquals(ofid, ofidacc.Id);
      
    }
    @isTest
    //test with ultimate parent CIDN
    static void getOneFundIdTestPositiveScenario3() {
        GetActiveOneFundForAccountTest test1 = new GetActiveOneFundForAccountTest();
        test1.setup();
        Test.startTest();
        Account acc = [Select Id from Account where name ='Test Account5' limit 1];
        Account acc1 = [Select Id from Account where name ='Test Account3' limit 1];
        String ofid = null;
        ofid = GetActiveOneFundForAccount.getOneFundId(acc.id);
        OneFund__c ofidacc = [Select Id from OneFund__c where CIDN__c =:acc1.id];Test.stopTest();
        System.assertEquals(ofid, ofidacc.Id);
      
    }
}