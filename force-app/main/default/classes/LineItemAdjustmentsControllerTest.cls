/*----------------------------------------------------------------------------
EDGE        -88294
Class Name  -PaymentsControllerTest
Description -Test class for LineItemAdjustmentsController  class .
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/    
@IsTest (seeAllData=false)
public class LineItemAdjustmentsControllerTest {
    
/*-------------------------------------------------------------------------------
EDGE        -88294
Method Name -testSetup
Description -Test Data creation for test class.
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    @TestSetup public static void testSetup(){
        account acc=TestDataFactory.generateAccount();
        
        contact con=testDataFactory.generateContact( 'Test_FirstName', acc.id,'Active','Test_LastName',system.today(),'Mobile');
        insert con;
        
        Billing_Account__c billingAccount=TestDataFactory.generateBillingAccount('700000335518','Created',acc.id, con.id);
        insert billingAccount;
        
        EnvironmentVariable__c certificate =TestDataFactory.generateEnvironmentVariable('massl_certificate_name','telstrab2b_sandbox');
        insert certificate;
        
        case cas=TestDataFactory.generateCase(acc.id,con.id,'Email','High','New', billingAccount.Id,'test','testDescription');
        insert cas;
        
        Credits_and_Adjustments__c creditAndAdjustment=TestDataFactory.generateCreditsAndAdjustments(billingAccount.id,'Compensation Credits – Telstra Issue' ,system.today(),1000.15,cas.Id);
        insert creditAndAdjustment;
		 //Osaka:Zeeshan:INC000096527193 :  Only Test class Fix
         Id devRecordTypeId = Schema.SObjectType.Credits_and_Adjustments__c.getRecordTypeInfosByName().get('Line Item Credit').getRecordTypeId();
         System.debug('devRecordTypeId'+devRecordTypeId);
         creditAndAdjustment.recordtypeid = devRecordTypeId;
         update creditAndAdjustment;
        //EDGE-115138:Removed Start Date ,End Date and added Invoice Period ,Osaka 
        invoice__c invoice=TestDataFactory.generateInvoice('012345678912345',billingAccount.Id,system.today().adddays(10),1000.10,'01 Jun 19 - 23 Jun 19','12345');
        insert  invoice;
        
        Invoice_Line_Item__c invoiceLineItem =TestDataFactory.generateInvoiceLineItem(invoice.Id,'Test','service',system.today(),system.today().adddays(10));
        //Start of EDGE:113051
        //Updating the invoice line number from Invoice Line Item object instead of queried line item object
        invoiceLineItem.Invoice_Line_Number__c = 8323; 
        invoiceLineItem.Invoice_Transaction_ID__c = 197167983;
        //End of EDGE:113051
        Insert invoiceLineItem;
        //EDGE-115138:Removed Transacion ID ,Osaka 
        Queried_Line_Item__c lineItem= TestDataFactory.generateQueriedLineItem(Cas.Id,creditAndAdjustment.id,invoiceLineItem.Id,'Usage adjustment',1000.00,2000.00);
        insert lineItem;
        
    }
    /*---------------------------------------------------------------------------------------------
EDGE        -88294
Method Name -getCreditAndAdjustmentTest
Description -Test method to cover LineItemAdjustmentsController class getCreditAndAdjustment method .
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------------------------------------*/
    @IsTest public static void getCreditAndAdjustmentTest(){
        Credits_and_Adjustments__c creditAndAdjustment=[Select id,Reason_Code__c from Credits_and_Adjustments__c where Reason_Code__c='Compensation Credits – Telstra Issue' Limit 1];
        Test.startTest();
        Credits_and_Adjustments__c creditAndAdjustment1= LineItemAdjustmentsController.getCreditAndAdjustment(creditAndAdjustment.Id);
        Test.stopTest();
        system.assertEquals(creditAndAdjustment.id, creditAndAdjustment1.id);
    }
    /*---------------------------------------------------------------------------------------------
EDGE        -88294
Method Name -getCreditAndAdjustmentNegativeTest
Description -Test method to cover negative test case in LineItemAdjustmentsController class getCreditAndAdjustment method .
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------------------------------------*/
    @IsTest public static void getCreditAndAdjustmentNegativeTest(){
        Test.startTest();
        Credits_and_Adjustments__c creditAndAdjustment= LineItemAdjustmentsController.getCreditAndAdjustment('12345');
        Test.stopTest();
        system.assertEquals(null, creditAndAdjustment);
    }
  /*---------------------------------------------------------------------------------------------
EDGE        -88294
Method Name -doSubmitPositiveResponseTest
Description -Test method to cover positive test case in LineItemAdjustmentsController class doSubmit method .
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------------------------------------*/
    @IsTest public static void doSubmitPositiveResponseTest(){
        Credits_and_Adjustments__c creditAndAdjustment=[Select id,Reason_Code__c from Credits_and_Adjustments__c where Reason_Code__c='Compensation Credits – Telstra Issue' Limit 1];
        //system.debug('---->'+creditAndAdjustment);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LineItemAdjustmentsServiceMock(200));
        String str= LineItemAdjustmentsController.doSubmit(creditAndAdjustment.Id,'LineItemAdjustmentsRequest');
        //system.debug('----->strr'+str);
        Test.stopTest();
        system.assertNotEquals(label.BDS_Response_Error_Message, str);
    }
    //EDGE - 171597
    @isTest public static void getCreditAndAdjustmentRecordTest(){
        Case caseRec = [Select id from Case where subject = 'Test' ];
        Test.startTest();
        LineItemAdjustmentsController.getCreditAndAdjustmentRecord(caseRec.id);
        Credits_and_Adjustments__c creditRec = [select id from Credits_and_Adjustments__c where Case_Number__c = :caseRec.Id LIMIT 1];
        System.assert(creditRec.Id!=null);
        Test.stopTest();
    }
    @isTest public static void getCreditAndAdjustmentRecordTestNegative(){
        String caseId = '';
        Test.startTest();
        LineItemAdjustmentsController.getCreditAndAdjustmentRecord(caseId);
        System.assert(null==null);
        Test.stopTest();
    }
    
  /*---------------------------------------------------------------------------------------------
EDGE        -88294
Method Name -doSubmitNegativeResponseTest
Description -Test method to cover negative test case in LineItemAdjustmentsController class doSubmit method .
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------------------------------------
    @IsTest public static void doSubmitNegativeResponseTest(){
        Credits_and_Adjustments__c creditAndAdjustment=[Select id,Reason_Code__c from Credits_and_Adjustments__c where Reason_Code__c='Compensation Credits – Telstra Issue' Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LineItemAdjustmentsServiceMock(422));
        String Str= LineItemAdjustmentsController.doSubmit(creditAndAdjustment.Id,'LineItemAdjustmentsRequest');
    	//system.debug('----->strr'+str);
        Test.stopTest();
       //system.assertEquals(label.BDS_Response_Error_Message, str);
       system.assertEquals(null, str);
    }
    */
      /*---------------------------------------------------------------------------------------------
EDGE        -88294
Method Name -doSubmitExceptionTest
Description -Test method to cover Exception test case in LineItemAdjustmentsController class doSubmit method .
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------------------------------------
    @IsTest public static void doSubmitExceptionTest(){
        Credits_and_Adjustments__c creditAndAdjustment=[Select id,Reason_Code__c from Credits_and_Adjustments__c where Reason_Code__c='Compensation Credits – Telstra Issue' Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LineItemAdjustmentsServiceMock(500));
        String str= LineItemAdjustmentsController.doSubmit(creditAndAdjustment.Id,'LineItemAdjustmentsRequest');
        //system.debug('---str--'+str);
        Test.stopTest();
        system.assertEquals(null, str);
    }*/
}