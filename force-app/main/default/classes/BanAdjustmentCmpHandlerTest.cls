/*************************************************************************************************
EDGE -104930
Name: BanAdjustmentCmpHandlerTest
Description: A test class created to validate the class BanAdjustmentCmpHandler and BanAdjustmentPaymentService
Author:Mahima 
***************************************************************************************************/
@isTest
public class BanAdjustmentCmpHandlerTest {
    
    /**********************************
    EDGE-104930 
    Description: Test data setup method
    Author: Mahima
    ************************************/
    @TestSetup 
    public static void setupData(){
        account acc=TestDataFactory.generateAccount();
        
        contact con=testDataFactory.generateContact( 'Test_FirstName', acc.id,'Active','Test_LastName',system.today(),'Mobile');
        insert con;
        
        Billing_Account__c billingAccount=TestDataFactory.generateBillingAccount('700000335518','Created',acc.id, con.id);
        insert billingAccount;
        
                List<EnvironmentVariable__c> variableList=new List<EnvironmentVariable__c>();
        EnvironmentVariable__c certificate =new EnvironmentVariable__c();
        certificate.Name='massl_certificate_name';
        certificate.Value__c='telstrab2b_sandbox';
        variableList.add(certificate);
        
        EnvironmentVariable__c certificate1 =new EnvironmentVariable__c();
        certificate1.Name='PlatformCache_Expiry_Time';
        certificate1.Value__c='3599';
        variableList.add(certificate1);
        
    }
    
    /**********************************
    EDGE-104930 
    Description: Positive Test for getAdjustmentList
    Author: Mahima
    ************************************/
    @IsTest 
    public static void  getAdjustmentListTest(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];       
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new BANAdjustmentServiceMock(200));
        BanAdjustmentCmpHandler.AdjustmentFullWrapper lstResponseWrap=BanAdjustmentCmpHandler.getAdjustmentList('2019-01-01','2019-08-19', billingAccount.Id);
        system.debug('lstResponseWrap>>>>'+lstResponseWrap);
        if(lstResponseWrap!= null && lstResponseWrap.lstAddWrapper != null)
        	system.assertEquals(lstResponseWrap.lstAddWrapper.size()>0, true);
        test.stopTest();
        
        
    }
    
    /**********************************
    EDGE-104930 
    Description: Negative Test for getAdjustmentList when dates are null
    Author: Mahima
    ************************************/
    @IsTest 
    public static void  getAdjustmentList2Test(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];       
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new BANAdjustmentServiceMock(200));
        BanAdjustmentCmpHandler.AdjustmentFullWrapper lstResponseWrap=BanAdjustmentCmpHandler.getAdjustmentList(null,null, billingAccount.Id);
        system.debug('lstResponseWrap>>>>'+lstResponseWrap);
        if(lstResponseWrap!= null && lstResponseWrap.lstAddWrapper!=null)
        	system.assertEquals(lstResponseWrap.lstAddWrapper.size()>0, true);
        test.stopTest();
        
        
    }
    
    /**********************************
    EDGE-104930 
    Description: Negative Test for getAdjustmentList when BAN is null
    Author: Mahima
    ************************************/
    @IsTest 
    public static void  getAdjustmentListNullCaseTest(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];       
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new BANAdjustmentServiceMock(200));
        BanAdjustmentCmpHandler.AdjustmentFullWrapper lstResponseWrap=BanAdjustmentCmpHandler.getAdjustmentList(null,null, null);
        system.assertEquals(lstResponseWrap.lstAddWrapper, null);
        test.stopTest();
        
        
    }
    
    /**********************************
    EDGE-104930 
    Description: Negative Test for getAdjustmentList when API returns an Error response
    Author: Mahima
    ************************************/
    @IsTest 
    public static void  getAdjustmentListErrorTest(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];       
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new BANAdjustmentServiceMock(422));
        BanAdjustmentCmpHandler.AdjustmentFullWrapper lstResponseWrap=BanAdjustmentCmpHandler.getAdjustmentList(null,null, billingAccount.Id);
        system.assertNotEquals(null, lstResponseWrap.errorwr);        
        test.stopTest();
        
        
    }

}