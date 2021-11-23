@isTest
/********************************************************************
EDGE        : EDGE-116382
Class       : OneFundRedemptionCredit
Description : Approved Redemption Details needs to be sent to ARIA
Author      : Hari
Date        :10/02/2020
********************************************************************/

public class OneFundRedemptionCreditTest {
    public static Id RetrospectiveRedemptionRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Billing_OneFund_Retrospective_Redemption').getRecordTypeId();
    public static Id AllocationRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();   
    public static Id redemptionRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Redemptions').getRecordTypeId();   
    
    /********************************************************************
EDGE        : EDGE-116382
Class  		: OneFundRedemptionCredit
Description : Method to create testdata
Author      : Hari
Date        :10/02/2020
*******************************************************************/  
    Public static list<OneFundRedemptionCredit.FlowInputs> tesetup(){
        List<Queried_Line_Item__c> lstqil = new List<Queried_Line_Item__c>();
        List<OneFundRedemptionCredit.FlowInputs> FlowInputlst = new list<OneFundRedemptionCredit.FlowInputs>();
        Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211231');
        Billing_Account__c OneFundRBillingAccount =new Billing_Account__c(Account__c=accountRecord.id, Billing_Account_Name__c='TestOneFund',Billing_Account_Number__c='221298645728');
        insert OneFundRBillingAccount;
        case OneFundRcase =new case(Account=accountRecord,Billing_Account__c=OneFundRBillingAccount.id,Subject='OneFundTest',status = 'New', RecordTypeId=RetrospectiveRedemptionRecordId);
        insert OneFundRcase;
        Credits_and_Adjustments__c cra = new  Credits_and_Adjustments__c();
        cra.Case_Number__c =  OneFundRcase.id;
        cra.Comments__c ='Dispute Against';
        cra.Charge_Status__c ='Pending';
        cra.Charge_Type__c ='Downgrade'; 
        insert cra;
        OneFund__c OneFundRecord  = new OneFund__c();
        OneFundRecord.Billing_Account__c = OneFundRBillingAccount.id ;
        OneFundRecord.CIDN__c = accountRecord.id ;
        insert OneFundRecord;
        OneFund_Transactions__c AllocationOFT = new OneFund_Transactions__c();
        AllocationOFT.Redeemed_Amount__c = 1000;
        AllocationOFT.Transaction_Status__c ='Pending';
        // AllocationOFT.Case_Number__c = OneFundRcase.id;
        AllocationOFT.OneFund__c = OneFundRecord.id;
        AllocationOFT.RecordTypeId=AllocationRecordId;
        insert AllocationOFT;
        OneFund_Transactions__c RedemptionOFT = new OneFund_Transactions__c();
        RedemptionOFT.Redeemed_Amount__c = 20;
        RedemptionOFT.Transaction_Status__c ='Pending';
        RedemptionOFT.Case_Number__c = OneFundRcase.id;
        RedemptionOFT.OneFund__c = OneFundRecord.id;
        RedemptionOFT.RecordTypeId=redemptionRecordId;
        RedemptionOFT.Related_Accrual__c=AllocationOFT.id;
        insert RedemptionOFT;
        Invoice__c inv = new Invoice__c();
        Inv.name = '9900000182888';
        inv.Aria_Invoice_Number__c ='248148064';
        inv.Payments_and_Adjustments__c =0.0;
        insert inv;
        Invoice_Line_Item__c invlineitem =new Invoice_Line_Item__c();
        invlineitem.Invoice_Line_Number__c =7;
        invlineitem.Offer_Name__c ='Connected Workplace';
        invlineitem.Quantity__c ='3';
        invlineitem.Charge_Including_GST__c =450.00;
        invlineitem.Charge_Type__c = 'OnceOffCharge';
        invlineitem.Charge_Excluding_GST__c =450.00;
        invlineitem.Charge_Identifier__c =10566;
        invlineitem.Is_Queryable__c =true;
        invlineitem.Excluding_Cost__c=450.00;
        invlineitem.Invoice_Transaction_ID__c =200989724;
        //invlineitem.Charge_Type__c = 'OnceOffCharge';
        invlineitem.Invoice__c =inv.id;
        insert invlineitem;
        Queried_Line_Item__c  qli = new Queried_Line_Item__c(); 
        qli.Invoice_Line_Item__c =invlineitem.id;
        qli.Invoice_Line_Number__c = 7;
        qli.Invoice_Transaction_ID__c ='200989724 ';
        qli.Line_Item_Identifier__c ='10566';
        qli.Max_Credit_Amount__c =450.00;
        qli.Redemption_Amount__c = 450.00;
        qli.Credit_Adjustment__c = cra.Id;
        qli.Case__c = OneFundRcase.id ;
        insert qli;
        if(qli.id != null){
            lstqil.add(qli);
        }
        Non_Marketable_Product__c recordOfProduct= new Non_Marketable_Product__c(Name='Redemption',billingSpecId__c='DMCAT_NonRecurringCharge_000882',currency__c='AUD',externalId__c='DMCAT_StandaloneProduct_000879_DMCAT_NonRecurringCharge_000882_1173',
                                                                                     specId__c='DMCAT_StandaloneProduct_000879',productDescription__c='Onefunds Downgrade Charge',taxTreatment__c='GST Applicable');
        insert recordOfProduct;
        
        OneFundRedemptionCredit.FlowInputs flowinputs = new OneFundRedemptionCredit.FlowInputs();
        flowinputs.instanceId =cra.id;
        flowinputs.adjustmentType ='Redemption-credit';
        flowinputs.ariaInvoiceNumber ='149311676';
        flowinputs.comments ='Dispute Against Line Item';
        flowinputs.currencyCode = 'AUD';
        flowinputs.caseReferenceNumber = '00044332'; 
        flowinputs.productId = 'DMCAT_StandaloneProduct_000879' ; 
        flowinputs.lineItemReasonCode ='5001';
        flowinputs.caseid =OneFundRcase.Id ;
        flowinputs.creditAndAdjustmentid =cra.id;
        flowinputs.QLI_list = lstqil;
        FlowInputlst.add(flowinputs);
        
        return FlowInputlst;
        
    }
    /********************************************************************
EDGE        : EDGE-116382
Class  		: OneFundRedemptionCredit
Description : Method to cover submmitOneFundRedemptionCredit
Author      : Hari
Date        :10/02/2020
*******************************************************************/
    @isTest
    
    Public static void submmitOneFundRedemptionCreditTest(){
        
        Test.startTest(); 
        List<OneFundRedemptionCredit.FlowInputs> FlowInputslst = tesetup();
        OneFundRedemptionCredit.submmitOneFundRedemptionCredit(FlowInputslst);
        Test.setMock(HttpCalloutMock.class, new Onefundlineitemmock('success_Response'));
        Test.stopTest();
        case c1 =[Select id, Description,status from case where subject ='OneFundTest'];
        system.assertEquals('Closed', c1.Status );
        Credits_and_Adjustments__c c2 = [select id,Submitted__c,Redemption_Status__c from Credits_and_Adjustments__c where 	Case_Number__c =:c1.Id];
        system.assertEquals(true, c2.Submitted__c );
        system.assertEquals('Posted', c2.Redemption_Status__c);
    }
    /********************************************************************
EDGE        : EDGE-116382
Class  : OneFundRedemptionCredit
Description : Method to cover submmitOneFundRedemptionCrediterrormessag
Author      : Hari
Date        :10/02/2020
*******************************************************************/
    @istest
    Public static void submmitOneFundRedemptionCrediterrormessageTest(){
        Test.startTest();
        List<OneFundRedemptionCredit.FlowInputs> FlowInputslst = tesetup();
        OneFundRedemptionCredit.submmitOneFundRedemptionCredit(FlowInputslst);
        Test.setMock(HttpCalloutMock.class, new Onefundlineitemmock('success_error'));
        Test.stopTest();
        case c1 =[Select id, Description,status from case where subject ='OneFundTest'];
        system.assertEquals('Submission Failed', c1.Status );
        Credits_and_Adjustments__c  c2= [select id,Redemption_Status__c from Credits_and_Adjustments__c where 	Case_Number__c =:c1.Id];
        system.assertEquals('Submission Failed', c2.Redemption_Status__c);
    }  
    
}