/*----------------------------------------------------------------
Method : updateInvoiceLineDetailTest
Author: Manjunath Ediga
Story: EDGE-164871
-------------------------------------------------------------------------------------*/
@isTest
public class UpdateInvoiceDetailTest {
    @isTest
    public static void updateInvoiceLineDetailTest(){
        String invoiceNumber = '9900000202486';
        String year = null;
        List<string> dateStringSplit;
        Account accountData = TestDataFactory.generateAccount();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        insert contactData;
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        Invoice__c invoiceData = new Invoice__c(Name = '9900000202486',Billing_Account__c = billingAccountData.Id,Aria_Invoice_Number__c = '012345678912345'); 
        insert  invoiceData;
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c(Invoice__c=invoiceData.id, Invoice_Transaction_ID__c=19735360,Service_Type__c='Test');
        insert ili;
        InvoiceRequestDTO requestDto = InvoiceCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Search'));
        InvoiceResponseDTO responseDto =  InvoiceCalloutHandler.calloutInvoiceByNumber(requestDto);
        system.debug('responseDto is -->'+responseDto);
        dateStringSplit =  responseDto.PaymentSummary.dueDate.split(' ');
        year = '20'+dateStringSplit[2];
        Map<Integer,InvoiceCalloutHandler.ProductOffer> productsMap = new Map<Integer,InvoiceCalloutHandler.ProductOffer>();
        dateStringSplit =  responseDto.InvoiceDetails.invoiceIssueDate.split(' ');
        productsMap = InvoiceCalloutHandler.getProducts(responseDto,null,'2019');
        List <Invoice_Line_Item__c> productILI = new List <Invoice_Line_Item__c>();
        productILI = InvoiceCalloutHandler.updateInvoiceLineItems(productsMap,null,'2019');
        updateInvoiceDetail.updateInvoiceLineDetails(productILI,invoiceData.id);
        Test.stopTest();
        List<Invoice_Line_Item__c> resIli = [SELECT id,Physical_Location_Name__c FROM Invoice_Line_Item__c WHERE Invoice__c =:invoiceData.Id AND Invoice_Transaction_ID__c=19735360 AND Service_Type__c='Test'];
        system.debug('resIli'+resIli);
        system.assertEquals(resIli[0].Physical_Location_Name__c !=null,false);
    }
}