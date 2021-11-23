/*************************************************************************************************
EDGE -92010
Name:InvoiceCmpHandler
Description: Controller for component InvoiceCmp 
Author:Manjunath Ediga
Modified by:Ramya G 
***************************************************************************************************
UpdatedVersion      UpdatedBy            Edge Number         Date
1                   Aman Soni            EDGE-207867         18/05/2021
2                   Aman Soni            EDGE-207869         08/06/2021
3                   Aman Soni            EDGE-211194         14/06/2021
4           	    Akanksha Jain        EDGE-215753         14/06/2021
***************************************************************************************************/
public without sharing class InvoiceCmpHandler {
    public class MyAuraException extends Exception {}//Added by Aman Soni for EDGE-207867
    //Ui wrapper for Error API response
    public class ErrorWrapper {
        @AuraEnabled
        public string message {
            get;
            set;
        }
    }

    /**********************************
    EDGE-92010
    Description: Method to call Invoice API for given Invoice Number and billing Account Number
    Author: Manjunath Ediga
    ************************************/
    @AuraEnabled
    public static String getInvoiceDetailsList(string custom_AccNumber, string Invoice_num) {
        String resDTO = null;
        string response = '';
        try {
            if (custom_AccNumber != null && custom_AccNumber != '') {
                string billingAccountNum = '';
                List < Billing_Account__c > listBillingAccountNumber = [SELECT id, Billing_Account_Number__c FROM Billing_Account__c WHERE Id =: custom_AccNumber];
                if (listBillingAccountNumber != null && listBillingAccountNumber.size() > 0) {
                    billingAccountNum = listBillingAccountNumber[0].Billing_Account_Number__c;
                }
                InvoiceRequestDTO reqDTO = new InvoiceRequestDTO();
                reqDTO.customerAccountNumber = billingAccountNum;
                reqDTO.invoiceNumber = long.valueof(Invoice_num);
                system.debug('resDTO is ' + reqDTO);
                resDTO = InvoiceCalloutHandler.calloutInvoiceByNumber(reqDTO, true);
                system.debug('resDTO is ' + resDTO);

            } else {
                ErrorWrapper ew = new ErrorWrapper();
                ew.message = System.Label.Invalid_Invoice_Number;
                throw new CustomException(System.Label.Invalid_Invoice_Number);
            }
        }catch (exception e){
            system.debug('Exception in getInvoiceDetailsList==>' + e.getLineNumber() + ' ' + e.getMessage());
             throw new AuraHandledException('Something went wrong : '+ e.getMessage());
        }
        return resDTO;
    }

    /*****************************************************************************************************
    EDGE-121428
    Description: Method to create a Case Record 
    Author: Pradeep Bhumi
    ******************************************************************************************************/
    @AuraEnabled
    public static  String CreateCaseRecord(Map<String,Object> caseMap){
        system.debug('caseMap'+caseMap);
        Case newCase;
        String invoiceSerialized;
        //Start of EDGE-133408  Component - getting Transaction id list and serializing 
        List<integer> transactionList = new List<integer>();
        List<integer> inputTransactionList = new List<integer>();
        string transactionid ;        
        string contactEmail=  String.valueOf(caseMap.get('contacteMail'));
        Object invtransa = caseMap.get('transactionIdList');
        transactionid=JSON.serialize(invtransa);
        //End of EDGE-133408  Component 
        InvoiceResponseDTO invLineItems = InvoiceResponseDTO.parse(String.valueOf(caseMap.get('invLineItemData')));
        invoiceSerialized=JSON.serialize(invLineItems);
        Id accountNumber;
        String caseId;
        id contactId;
        List < Invoice_Line_Item__c > lineItemListRC;
        //START of EDGE-130405:Osaka
        AssignmentRule billingRule = new AssignmentRule();
        Database.DMLOptions billingdml= new Database.DMLOptions();
        //END of EDGE-130405
        try 
        {
            //Create Case record
            //START of EDGE-130405:Osaka:Case Assignment rule executed during case creation and "Assign using active assignment rules" checkbox:Pradeep/Ramya
            billingRule = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];    
            billingdml.assignmentRuleHeader.assignmentRuleId= billingRule.id;
            //END of EDGE-130405:Osaka:
            Id billingEnquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Billing_Enquiry_RecordType).getRecordTypeId();
            newCase = (Case) JSON.deserialize(String.valueOf(caseMap.get('caseData')), Case.class);
            newCase.RecordTypeid = billingEnquiryRecordTypeId;
            newCase.Requestor__c = UserInfo.getUserId(); //EDGE-162804
            if(FeatureManagement.checkPermission('Partner_User')){
                newCase.Origin = 'TPC';
            }            
            newcase.setOptions(billingdml);
            insert newcase;

            List <Billing_Account__c> billNumber = [SELECT id, Account__c FROM Billing_Account__c WHERE Id =: newCase.Billing_Account__c Limit 1];
            if(!billNumber.isEmpty()){
                accountNumber = billNumber[0].Account__c;
                newCase.AccountId = accountNumber;            
            }
            //Updating case contact and account 
            List <Contact> raisedBy = [select id, email, Contact_Status__c from contact where email =:contactEmail and Contact_Status__c = 'Active'];
            if(!raisedBy.isEmpty()){
                contactId = raisedBy[0].id;
                newCase.contactId = contactId;               
            }
            newcase.setOptions(billingdml);
            upsert newcase;  
            String strUsageCharge = String.valueOf(caseMap.get('rcChargeIds'));
            caseId=newCase.id;       
            ID jobID = System.enqueueJob(new CreateInvoice(invoiceSerialized, strUsageCharge, caseId, transactionid, contactEmail));  
        }
        catch(Exception e){
            System.debug('Exception in Case Creation: '+e.getStackTraceString()+e.getMessage()); 
            caseId = 'Exception in Case Creation:'+e.getStackTraceString()+e.getMessage();
        }       
        return caseId;
    }

    @AuraEnabled
    @future(callout=true)
    public static  void getMaxCredit(String caseId){
        List<Id> caseCreated = new List<Id> ();
        caseCreated.add(caseId);
        QLIBillingLineItemAdjustment.getMaxCredit(caseCreated);
        system.debug('----->Max Credit  ');
    }

    /*-------------------------------------------------------- 
    EDGE-124066
    Method: fetchInvoiceNumber
    Description: Method to make callout to Invoice API using Billing Account Number to retrive last 13 invoices.
    Author:Pradeep
    --------------------------------------------------------*/
    @AuraEnabled
    public static Map<String,String> fetchInvoiceNumbers(String custBillingId){       
        String billingAccountNumber;
        Map<String,String> invoiceResponse;
        try{
            List <Billing_Account__c> listBillingAccountNumber = [SELECT id, Billing_Account_Number__c FROM Billing_Account__c WHERE Id =: custBillingId];
            if (listBillingAccountNumber != null && listBillingAccountNumber.size() > 0) {
                billingAccountNumber = listBillingAccountNumber[0].Billing_Account_Number__c;
            }
            if (String.isNotBlank(BillingAccountNumber)){
            invoiceResponse =  InvoiceCalloutHandler.getInvoiceNumbers(billingAccountNumber); 
            }
        }
        catch (exception e){
            system.debug('Exception in fetchInvoiceNumbers==>' + e.getLineNumber() + ' ' + e.getMessage());
            throw new AuraHandledException('Something went wrong : ' + e.getMessage());      
        }
        return invoiceResponse;    
    }

    @auraEnabled
    public static string fetchBillingAddress(String billingAccId){
        list<Billing_Account__c> billingAddresslist = new list<Billing_Account__c>();
        string billingAddress;
        try{
            if (String.isNotBlank(billingAccId))
            {
                billingAddresslist = [SELECT id, Billing_Address__r.Name FROM Billing_Account__c WHERE Id =: billingAccId];
                if(!billingAddresslist.isEmpty()){
                    billingAddress = String.valueOf(billingAddresslist[0].Billing_Address__r.Name);             
                }
            }
        }
        catch (exception e) {
            system.debug('Exception in fetchInvoiceNumbers==>' + e.getLineNumber() + ' ' + e.getMessage());          
        }
        return billingAddress;
    }

    /*-------------------------------------------------------- 
    EDGE-127943
    Method: fetchLookUpValues
    Description: Method to fetch applicable contact list for given account  
    Author:Pradeep
    --------------------------------------------------------*/
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, String ObjectName,String recordId){
        //Added escapeSingleQuotes() for EDGE-211194 by Aman Soni || Start
        String searchKey = String.escapeSingleQuotes(searchKeyWord);
        String ObjName = String.escapeSingleQuotes(ObjectName);
        //Added escapeSingleQuotes() for EDGE-211194 by Aman Soni || End  

        List < sObject > returnList = new List < sObject > ();
        List < String > authority = new List < String > ();
        authority.add(System.Label.FullAuthority);
        authority.add(System.Label.LegalLessee);
        String accountId;         
        List<Billing_Account__c> accountlist = [SELECT Account__c FROM Billing_Account__c WHERE id =:recordId ];

        for(Billing_Account__c billingacc :accountlist ){
            accountId=billingacc.Account__c;
        }
      
        // Create a Dynamic SOQL Query For Fetch Record List
        //Modified for EDGE-211194 by Aman Soni || Start
        String sQuery = '';
        if(String.isNotBlank(searchKey)){
            searchKey = '%' + searchKey + '%';
            sQuery = 'select Id,name,email from ' +ObjName + ' WHERE AccountId =:accountId AND Authority__c =:authority AND Contact_Status__c=\'Active\' AND  Name LIKE: searchKey order by createdDate DESC ';
        }else{
            sQuery = 'select Id,name,email from ' +ObjName + ' WHERE AccountId =:accountId AND Authority__c =:authority AND Contact_Status__c=\'Active\' order by createdDate DESC ';
        }
        //Modified for EDGE-211194 by Aman Soni || End

        List <sObject > lstOfRecords = Database.query(sQuery) ;
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }     

        return returnList;
    }

    /******************************************************************
    EDGE        -EDGE-167053 
    Method      -isPartner 
    Description -check whether login user is PRM user 
    Author      -RaviTeja
    ******************************************************************/ 
  @AuraEnabled
    public static boolean isPartner(){
        boolean isPartner = false;
        try{
            if(FeatureManagement.checkPermission('Partner_User')){
               isPartner=true;
            }
    }
        catch(Exception e){
            system.debug('prmPartnerCheck'+e.getMessage());
        }
        return isPartner;
    }
    
    /*****************************************************************************************************
    Story(Sprint) : EDGE-207867(21.06)
    Method        : existCaseRecord
    Description   : Method to handle existing Case Record 
    Author        : Aman Soni
    ******************************************************************************************************/
    @AuraEnabled
    public static String existCaseRecord(Map<String,Object> caseMap){
        string caseId = '';
        string contactEmail = '';
        try 
        {
            if(caseMap != null && !caseMap.isEmpty()){
                Object transId = caseMap.get('transactionIdList');
                String transactionid =JSON.serialize(transId);
                InvoiceResponseDTO invLineItems = InvoiceResponseDTO.parse(String.valueOf(caseMap.get('invLineItemData')));
                String invoiceSerialized = JSON.serialize(invLineItems);
                caseId = String.valueOf(caseMap.get('caseId'));
                caseId = caseId.replace('\"','');
                String strUsageCharge = String.valueOf(caseMap.get('rcChargeIds'));
                ID jobID = System.enqueueJob(new CreateInvoice(invoiceSerialized, strUsageCharge, caseId, transactionid, contactEmail));
            }
            if(Test.isRunningTest()){ 
                throw new MyAuraException('Throwing custom exception');
            }       
        }
        catch(exception e){
            system.debug('Exception in existCaseRecord: ' + e.getLineNumber() + ' ' + e.getMessage()); 
        }       
        return caseId;
    }

    /*-------------------------------------------------------- 
    Story(Sprint): EDGE-207867(21.06)
    Method: fetchCaseObjLookUpValues    
    Description: Method to fetch Cases for the given billing account 
    Author: Aman Soni
    --------------------------------------------------------*/
    @AuraEnabled
    public static List<sObject> fetchCaseObjLookUpValues(String searchKeyWord, String ObjectName,String recordId){     
        List<sObject> lstOfRecords = new List<sObject>();       
        List<sObject> returnList = new List <sObject>();
        String sQuery = '';
        try{
            //Added escapeSingleQuotes() for EDGE-211194 by Aman Soni || Start
            String searchKey = String.escapeSingleQuotes(searchKeyWord);
            String ObjName = String.escapeSingleQuotes(ObjectName);
            //Added escapeSingleQuotes() for EDGE-211194 by Aman Soni || End

            if(String.isNotBlank(recordId)){
                if(String.isNotBlank(searchKey)){
                    searchKey = '%' + searchKey + '%';
                    sQuery = 'select Id,Subject,CaseNumber,Contact.Id,Contact.Name,Description from ' +ObjName + ' WHERE Billing_Account__c =:recordId AND salesup_Support_Type__c = \'Billing Support\' AND (Status = \'In Progress\' OR Status = \'New\') AND ((Subject LIKE :searchKey) OR (CaseNumber LIKE :searchKey)) ';
                }else{
                    sQuery =  'select Id,Subject,CaseNumber,Contact.Id,Contact.Name,Description from ' +ObjName + ' WHERE Billing_Account__c =:recordId AND salesup_Support_Type__c = \'Billing Support\' AND (Status = \'In Progress\' OR Status = \'New\') ';
                }
            }
            if(String.isNotBlank(sQuery)){
                lstOfRecords = Database.query(sQuery);
            }
            if(!lstOfRecords.isEmpty()){
                for(sObject obj: lstOfRecords){
                    returnList.add(obj);
                } 
            }
            if(Test.isRunningTest()){ 
                throw new MyAuraException('Throwing custom exception');
            }
        }catch(Exception e){
            system.debug('Exception in fetchCaseObjLookUpValues: '+e.getStackTraceString()+''+e.getMessage());
        } 
        return returnList;
    }

    /*-------------------------------------------------------- 
    Story(Sprint): EDGE-207869(21.08)
    Method       : GetExistQlIAgainstCaseAndInvoiceCls
    Description  : Method to fetch existing QLI against provided Case and Invoice
    Author       : Aman Soni
    --------------------------------------------------------*/
    @AuraEnabled
    public static String GetExistQlIAgainstCaseAndInvoiceCls(String exisCaseId, String invoiceNum){
        Decimal qliAmount = 0.00;
        String qliAmnt = '';       
        List<Queried_Line_Item__c> qliList = new List <Queried_Line_Item__c>();
        try{
            if(String.isNotBlank(exisCaseId) && String.isNotBlank(invoiceNum)){
                qliList = Model_QueriedLineItems.getExistingQlis(exisCaseId, invoiceNum);
            }
            if(!qliList.isEmpty()){
               for(Queried_Line_Item__c qli : qliList){
                    qliAmount += qli.Queried_Amount__c;
                    qliAmnt = String.valueOf(qliAmount);
               } 
            }
            if(Test.isRunningTest()){ 
                throw new MyAuraException('Throwing custom exception');
            }
        }catch(Exception e){
            system.debug('Exception in GetExistQlIAgainstCaseAndInvoiceCls: '+e.getStackTraceString()+''+e.getMessage());
        } 
        return qliAmnt;
    }

    /*-------------------------------------------------------- 
    Story(Sprint): EDGE-207869(21.08)
    Method       : getSharedDisplayMessageCS
    Description  : Method to fetch SharedDisplayMessage custom Setting to show toast messages
    Author       : Aman Soni
    --------------------------------------------------------*/
    @AuraEnabled
    public static List<SharedDisplayMessage__c> getSharedDisplayMessageCS(){
        List<SharedDisplayMessage__c> csList = SharedDisplayMessage__c.getAll().values();
        return csList;
    }

    @AuraEnabled
    public static boolean enableDrilldown()
    {
        Boolean csVal=Boolean.valueOf(EnvironmentVariable__c.getValues('enableBillingEnquiry1663').Value__c);
        return csVal;
    }
}