/**
*  Description of the purpose of the method.
*  @name WithdrawAgreementTest
*  @description               : Test Class for WithdrawAgreement
**/
@istest
public class WithdrawAgreementTest {
    
    @testsetup static void testsetUpData(){
            
         		List< Partner_of_Record__c> domainList = PRMTestUtility.createPartnerOfRecords(1, new List<String> {'Mobile','Data and IP'});
               
    }
    @isTest
    public static void testActivePOR(){
        user u = [select id from user where Email ='test@noemail45345555.com0'];
        
        system.runAs(u){
            Test.startTest();
            
            Partner_of_Record__c por=[SELECT Id,Status__c from Partner_of_Record__c];
            Approval.lock(por.Id);
           		Partner_of_Record__c porresult = WithdrawAgreement.checkstatus(por.Id);
               system.assertEquals(porresult.Status__c, 'Active');
             Test.stopTest();
        }
    }
      @isTest
    public static void teststatus(){
        user u = [select id from user where Email ='test@noemail45345555.com0'];
        
        system.runAs(u){
            Test.startTest();
            Partner_of_Record__c por=[SELECT Id,Status__c from Partner_of_Record__c];
            	 Approval.lock(por.Id);
           		Boolean b =  WithdrawAgreement.changestatus(por.Id,'Telstra Choice');  
                Partner_of_Record__c record=[SELECT Id,Status__c from Partner_of_Record__c where id =:por.Id ];
               system.assertEquals(record.Status__c, 'Withdraw');
             Test.stopTest();
        }
    }
    @isTest
    public static void testpreviousvalue(){
        user u = [select id from user where Email ='test@noemail1234.com0'];
        
        system.runAs(u){
            Test.startTest();
            list<Partner_of_Record__c> P_list =new list <Partner_of_Record__c>();
            P_list=[SELECT Id,Status__c from Partner_of_Record__c];
            Partner_of_Record__c p = new Partner_of_Record__c();
            	p.id=P_list[0].Id;
        		p.Status__c='Modification in progress';
        		update p;
            
            list<Partner_of_Record_Domain__c> P1 =new list <Partner_of_Record_Domain__c>();
             P1=[select id,	Domain_Name__c ,Status__c,Sub_Status__c from Partner_of_Record_Domain__c ];
            for(Partner_of_Record_Domain__c list1 :P1){
                Partner_of_Record_Domain__c p2 =new Partner_of_Record_Domain__c();
        									p2.id=list1.id;
        									p2.Status__c='Pending Approval';
        									update p2;
                 }
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for Modification approval.');
                req.setObjectId(P_list[0].Id);
                req.setProcessDefinitionNameOrId('Partner_Of_Record_Modify_Approval');
                Approval.ProcessResult approvalResult = Approval.process(req);
            		
            	Approval.lock(P_list[0].Id);
            Boolean b =  WithdrawAgreement.changetoPreviousValue(P_list[0].Id);
            Partner_of_Record_Domain__c record=[select id,	Domain_Name__c ,Status__c,Sub_Status__c from Partner_of_Record_Domain__c where Domain_Name__c='Mobile' ];
               
           		
            	system.assertEquals(record.Status__c, 'Withdraw');
               //system.assertEquals(b, false);
             Test.stopTest();
        }
    }
    
    @isTest
     public static void testtopreviousvalueActive(){
        user u = [select id from user where Email ='test@noemail1234.com0'];
        
        system.runAs(u){
            Test.startTest();
            list<Partner_of_Record__c> P_list =new list <Partner_of_Record__c>();
            P_list=[SELECT Id,Status__c from Partner_of_Record__c];
            Partner_of_Record__c p = new Partner_of_Record__c();
            	p.id=P_list[0].Id;
        		p.Status__c='Modification in progress';
        		update p;
            list<Partner_of_Record_Domain__c> P1 =new list <Partner_of_Record_Domain__c>();
             P1=[select id,	Domain_Name__c ,Status__c,Sub_Status__c from Partner_of_Record_Domain__c ];
            for(Partner_of_Record_Domain__c list1 :P1){
                Partner_of_Record_Domain__c p2 =new Partner_of_Record_Domain__c();
        									p2.id=list1.id;
        									p2.Status__c='Cancelled';
        									update p2;
                 }
            		Boolean b =  WithdrawAgreement.changetoPreviousValue(P_list[0].Id);
            	 Partner_of_Record_Domain__c record=[select id,	Domain_Name__c ,Status__c,Sub_Status__c from Partner_of_Record_Domain__c where Domain_Name__c='Mobile'];
               
            system.assertEquals(record.Status__c, 'Active');
           		
               //system.assertEquals(b, true);
             Test.stopTest();
        }
    }
    @isTest
    public static void testNegativeActivePOR(){
        user u = [select id from user where Email ='test@noemail45345555.com0'];
        
        system.runAs(u){
            Test.startTest();
            Partner_of_Record__c por=[SELECT Id,Status__c from Partner_of_Record__c];
           		Partner_of_Record__c porresult = WithdrawAgreement.checkstatus(null);
               system.assertEquals(porresult, null);
             Test.stopTest();
        }
    }
      @isTest
    public static void testNegativestatus(){
        user u = [select id from user where Email ='test@noemail45345555.com0'];
        
        system.runAs(u){
            Test.startTest();
            Partner_of_Record__c por=[SELECT Id,Status__c from Partner_of_Record__c];
           		Boolean b =  WithdrawAgreement.changestatus(null,null);
               system.assertEquals(b, false);
             Test.stopTest();
        }
    }
    
    @isTest
    public static void testNegativepreviousvalue(){
        user u = [select id from user where Email ='test@noemail1234.com0'];
        
        system.runAs(u){
            Test.startTest();
            list<Partner_of_Record__c> P_list =new list <Partner_of_Record__c>();
            P_list=[SELECT Id,Status__c from Partner_of_Record__c];
            Partner_of_Record__c p = new Partner_of_Record__c();
            	p.id=P_list[0].Id;
        		p.Status__c='Modification in progress';
        		update p;
            	Approval.lock(P_list[0].Id);
           		Boolean b =  WithdrawAgreement.changetoPreviousValue(null);
               system.assertEquals(b, false);
             Test.stopTest();
        }
    }
    
    @isTest
    public static void testerrorActivePOR(){
    Try{
        user u = [select id from user where Email ='test@noemail45345555.com0'];
        
        system.runAs(u){
            Test.startTest();
            
            Partner_of_Record__c por=[SELECT Id,Status__c from Partner_of_Record__c];
            Approval.lock(por.Id);
           		Partner_of_Record__c porresult = WithdrawAgreement.checkstatus('test');
               system.assertEquals(porresult.Status__c, 'Active');
             Test.stopTest();
        }
    }
         catch(Exception e)
        {
            system.debug(' '+e.getMessage());
        }
    }
    
    @isTest
    public static void testerrorpreviousvalue(){
        try{
        user u = [select id from user where Email ='test@noemail45345555.com0'];
        
        system.runAs(u){
            Test.startTest();
            list<Partner_of_Record__c> P_list =new list <Partner_of_Record__c>();
            P_list=[SELECT Id,Status__c from Partner_of_Record__c];
            Partner_of_Record__c p = new Partner_of_Record__c();
            	p.id=P_list[0].Id;
        		p.Status__c='Modification in progress';
        		update p;
        
            	Approval.lock(P_list[0].Id);
           		Boolean b =  WithdrawAgreement.changetoPreviousValue('test');
               system.assertEquals(b, false);
             Test.stopTest();
        }
    }
    
    catch(Exception e)
        {
            system.debug(' '+e.getMessage());
        }
    }
     @isTest
    public static void testNegativeStatuschange(){
        user u = [select id from user where Email ='test@noemail45345555.com0'];
        
        system.runAs(u){
            Test.startTest();
            Partner_of_Record__c por=[SELECT Id,Status__c from Partner_of_Record__c];
           		Boolean b = WithdrawAgreementHelper.changeStatusvalue(null,null);
               system.assertEquals(b, false);
             Test.stopTest();
        }
    }
    }