/*EDGE-201628 -Alexandria - 26/02/2021 
- Test Class for AccountProgramHelper */

@isTest
public class AccountProgramHelperTest {

    @isTest
    public static void testAccountProgrambanner(){
        Test.startTest();

                   list<Account> acclist =new list<Account>();
            for(integer a=0;a<1;a++){
                Account customerAccount=TestUtil.createAccount('Testacc'+a);
                acclist.add(customerAccount);
       								}
            insert acclist; 
  
        /* Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
        for(Account customACC : customerAccount){
            customACC.Customer_Status__c = 'Active';
        }
        insert customerAccount;
        System.debug('customerAccount'+customerAccount);
        */
        Program__c prg=New Program__c();
        prg.name='Testing';
        insert prg;
      
         
        list<Program_Account__c> prgacctlist=New list<Program_Account__c>();
        System.debug('customerAccount'+acclist[0].Id);
    	String prgrecdtypeId= Schema.SObjectType.Program_Account__c.getRecordTypeInfosByDeveloperName().get('Billing_Account_and_dormant_CIDN_Cleanup').getRecordTypeId();
        String prggeneralrecdtypeId= Schema.SObjectType.Program_Account__c.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
     	System.debug('prgrecdtypeId'+prgrecdtypeId);
       	
        Program_Account__c prgacct=New Program_Account__c();
        prgacct.RecordTypeId=prgrecdtypeId;
        prgacct.Program__c=prg.Id;
       	prgacct.Enable_to_digital_products__c=TRUE;
        prgacct.Account__c=acclist[0].Id;
        prgacct.Digital_Products_Start_Date__c=Date.newInstance(2021, 12, 9);
        prgacctlist.add(prgacct);
         
        Program_Account__c prgacct1=New Program_Account__c();
        prgacct1.RecordTypeId=prgrecdtypeId;
       	prgacct1.Account__c=acclist[0].Id;
        prgacct1.Program__c=prg.Id;
        prgacct1.Enable_to_digital_products__c=TRUE;
        prgacct1.Digital_Products_Start_Date__c=Date.newInstance(2021, 12, 13);
        prgacct1.Digital_Program_Type__c = 'Transition';
        
        prgacctlist.add(prgacct1);
          insert prgacctlist;

        prgacctlist[1].RecordTypeId = prggeneralrecdtypeId;
        update prgacctlist[1];
       
        System.debug('prgdate New Instance'+Date.newInstance(2021, 12, 13));
        
       //String prgdate=AccountProgramHelper.checkaccountProgramdetails(acclist[0].Id);
       Program_Account__c prgdate=AccountProgramHelper.checkaccountProgramdetails(acclist[0].Id);//Modified for EDGE-213096
        System.debug('prgdate'+prgdate);
       system.assertEquals('2021/12/09','2021/12/09');
        Test.StopTest();
    }
    
    
    
}