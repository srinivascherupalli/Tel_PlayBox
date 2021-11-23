/*
AUTHOR : Anu Yadav
DESCRIPTION : This class is used to generate and send request messages for ManageCustomer
*/

public without sharing class ManageCustomerHandler {
    public static List<cscrm__Address__c> addresses{get;private set;}
    public static final String EVENT_ACTION_CREATE = 'Create';
    public static final String EVENT_ACTION_UPDATE = 'Update';
    public static final String EVENT_ACTION_CROSSREF = 'CrossRef';
    public static final String PRIMARY_ADDRESS = 'Primary Address';
    public static final String Certificate_name = EnvironmentVariable.get('certificate_name');
    private static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    public static String generateManageCustomerRequest(Account a, String event) {
        
        System.debug('!@#$% Generating ManageCustomer request for ' + event + ' event');
        
        addresses = getAddresses(a.Id);
        ManageCustomerRequest mcr = new ManageCustomerRequest();
        
        ManageCustomerRequest.Data dataItem = new ManageCustomerRequest.Data();
        getMCRData(dataItem,a,event);
        
        // Category
        ManageCustomerRequest.Category categoryItem = new ManageCustomerRequest.Category();
        getMCRCategory(categoryItem,a);
        dataItem.category = categoryItem;
        
        // Credit Situation
        ManageCustomerRequest.CreditSituation creditSituationItem = new ManageCustomerRequest.CreditSituation();
        getMCRCreditSituation(creditSituationItem,a);
        dataItem.creditSituation = creditSituationItem;
        
        // Concession
        ManageCustomerRequest.Concession concessionItem = new ManageCustomerRequest.Concession();
        getMCRConcession(concessionItem,a);
        dataItem.concession = concessionItem;
        
        // Customer Account - ##INTERFACE MANDATORY##
        ManageCustomerRequest.CustomerAccount customerAccountItem = new ManageCustomerRequest.CustomerAccount();
        getMCRCustomerAccount(customerAccountItem,a);
        dataItem.customerAccount = customerAccountItem;
        
        //Commenting as part of EDGE-13603
        //ManageCustomerRequest.AccountPortfolio customerPortfolioItem = new ManageCustomerRequest.AccountPortfolio();
        //getMCRAccountPortfolio(customerPortfolioItem,a,event);
        //dataItem.accountPortfolio = customerPortfolioItem;
        // Address - ##INTERFACE MANDATORY##
        // Currently we are sending only primary Address
        dataItem.address = getMCRAccountAddress(addresses, true);
        
        // Account Trading
        ManageCustomerRequest.AccountTrading atItem = new ManageCustomerRequest.AccountTrading();
        getMCRAccountTrading(atItem,a,event);
        dataItem.accountTrading = new List<ManageCustomerRequest.AccountTrading>();
        dataItem.accountTrading.add(atItem);
        
        mcr.data = dataItem;       
        return System.JSON.serializePretty(mcr, true);
    }
       
    public static List<cscrm__Address__c> getAddresses(Id accountId) {
       List<cscrm__Address__c> addrs = new List<cscrm__Address__c>();
       List<cscrm__Account_Address_Relationship__c> aarList = [SELECT cscrm__Address__r.Id,cscrm__Address__r.Address_ID__c,cscrm__Address__r.Address_Line_1__c,cscrm__Address__r.Address_Line_2__c,cscrm__Address__r.Address_Line_3__c,cscrm__Address__r.Address_Status__c,cscrm__Address__r.Address_Type__c,cscrm__Address__r.Building_Name__c,cscrm__Address__r.cscrm__Account__c,cscrm__Address__r.cscrm__Address_Details__c,cscrm__Address__r.cscrm__Address_Type__c,cscrm__Address__r.cscrm__Building_Name__c,cscrm__Address__r.cscrm__Building_Number__c,cscrm__Address__r.cscrm__Building_Type__c,cscrm__Address__r.cscrm__City__c,cscrm__Address__r.cscrm__Country__c,cscrm__Address__r.cscrm__External_Address_Id__c,cscrm__Address__r.cscrm__External_ID__c,cscrm__Address__r.cscrm__Geolocation__c,cscrm__Address__r.cscrm__Is_Billing_Address__c,cscrm__Address__r.cscrm__Is_Installation_Address__c,cscrm__Address__r.cscrm__Is_Registered_Office_Address__c,cscrm__Address__r.cscrm__Is_Shipping_Address__c,cscrm__Address__r.cscrm__Level_Number__c,cscrm__Address__r.cscrm__Level_Type__c,cscrm__Address__r.cscrm__Plan_Number__c,cscrm__Address__r.cscrm__Property_Name__c,cscrm__Address__r.cscrm__State_Province__c,cscrm__Address__r.cscrm__Street_Name__c,cscrm__Address__r.cscrm__Street_Number_End__c,cscrm__Address__r.cscrm__Street_Number_Start__c,cscrm__Address__r.cscrm__Street_Type__c,cscrm__Address__r.cscrm__Street__c,cscrm__Address__r.cscrm__Unit_Number__c,cscrm__Address__r.cscrm__Unit_Type__c,cscrm__Address__r.cscrm__Zip_Postal_Code__c,cscrm__Address__r.DP_Id__c,cscrm__Address__r.Is_Primary_Address__c,cscrm__Address__r.Locality__c,cscrm__Address__r.Name,cscrm__Address__r.NBN_Location_Id__c,cscrm__Address__r.NBN_Status_Image__c,cscrm__Address__r.NBN_Status__c,cscrm__Address__r.Number_of_Sub_addresses__c,cscrm__Address__r.Parent_Address_Id__c,cscrm__Address__r.Postal_Delivery_Type__c,cscrm__Address__r.Ready_For_Service_Date__c,cscrm__Address__r.Rural_Mail_Type__c,cscrm__Address__r.Source_System__c,cscrm__Address__r.streetNumberEndSuffix__c,cscrm__Address__r.streetNumberStartSuffix__c,cscrm__Address__r.streetTypeSuffix__c,cscrm__Address__r.streetType__c,cscrm__Address__r.Street_Number_End_calc__c,cscrm__Address__r.Street_Number_From_calc__c,cscrm__Address__r.Street_Number_From__c,cscrm__Address__r.Street_Number_Start_calc__c,cscrm__Address__r.Street_Number_To__c,cscrm__Address__r.Street_Type_calc__c,cscrm__Address__r.Sub_Address1_Number__c,cscrm__Address__r.Sub_Address1_Type_Code__c,cscrm__Address__r.Sub_Address1_Type__c,cscrm__Address__r.Sub_Address2_Number__c,cscrm__Address__r.Sub_Address2_Type_Code__c,cscrm__Address__r.Sub_Address2_Type__c,cscrm__Address__r.Sub_Address_3_Number__c,cscrm__Address__r.Sub_Address_3_Type_Code__c,cscrm__Address__r.Sub_Address_3_Type__c,cscrm__Address__r.Sub_Address_4_Number__c,cscrm__Address__r.Sub_Address_4_Type_Code__c,cscrm__Address__r.Sub_Address_4_Type__c,cscrm__Address__r.Sub_Address_Level_1_calc__c,cscrm__Address__r.Sub_Address_Level_1__c,cscrm__Address__r.Sub_Address_Level_2_calc__c,cscrm__Address__r.Sub_Address_Level_2__c,cscrm__Address__r.Sub_Address_Level_3_calc__c,cscrm__Address__r.Sub_Address_Level_3__c,cscrm__Address__r.Sub_Address_Level_4_calc__c,cscrm__Address__r.Sub_Address_Level_4__c,cscrm__Address__r.Sub_Address_Number__c,cscrm__Address__r.Sub_Address_Type__c,cscrm__Address__r.TCM_additionalInfo__c,cscrm__Address__r.TCM_Address_Type_Value__c,cscrm__Address__r.TCM_internationalPostcode__c,cscrm__Address__r.TCM_internationalState__c,cscrm__Address__r.TCM_numberEnd__c,cscrm__Address__r.TCM_numberStart__c,cscrm__Address__r.TCM_privateStreetName__c,cscrm__Address__r.TCM_privateStreetTypeCode__c,cscrm__Address__r.TCM_privateStreetType__c,cscrm__Address__r.TCM_registeredPlan__c,cscrm__Address__r.TCM_status_Code__c,cscrm__Address__r.TCM_Street_Type_code__c,cscrm__Address__r.TCM_street_Type_Suffix_Code__c,    cscrm__Active__c,cscrm__Address_Type__c FROM cscrm__Account_Address_Relationship__c where cscrm__Active__c = True AND cscrm__Address_Type__c =: PRIMARY_ADDRESS AND cscrm__Account__c = :accountId order by LastModifiedDate desc LIMIT 1];
       if(aarList != NULL && !aarList.isEmpty()){
            for(cscrm__Account_Address_Relationship__c aar: aarList){
                addrs.add(aar.cscrm__Address__r);
          }
           return addrs;
        }
        return null;
    }
    /**************** Start of Edge 85839 *****************/
    //Override the method with one extra boolean argument to extend the existing functionality to use in SyncUpCustomerTCM Batch.
    @future(callout=true)
    public static void sendManageCustomer(String req, String event, String identifier) { 
        /**************** Start of Edge 85839 *****************/
         HttpResponse responseData = sendManageCustomer(req,event,identifier, false);
         System.debug('responseData :: '+responseData);
        /**************** End of Edge 85839 *****************/
    }
    
    
    /**
     * @createdBy               : 
     * @description             : This method is called from the SyncUpCustomerTCM batch class.
                                  Overridden the existing method by adding one more argument to the method "sendManageCustomer(String req, String event, String identifier)"
                                  and added one boolean argument which is used to bypass the DML operations from the existing functionality.
     * @name sendManageCustomer
     * @param req               : Account record request 
     * @param event             : EVENT_ACTION_UPDATE
     * @param identifier        : acc.Customer_ID__c
     * @param isBatch           : true
     * @return HttpResponse     : HttpResponse
     * @jiraStoryRef            : EDGE-85839
     * @UpdatedBy               : Sasidhar Devarapalli,OSAKA
     * 
     * */ 
    public static HttpResponse sendManageCustomer(String req, String event, String identifier, boolean isBatch) {  
        Logger2 log = null;
        HttpResponse resp;
        /**************** Start of Edge 85839 *****************/
        if(!isBatch)
            log = Logger2.getLogger('ManageCustomerRequest');
        /**************** End of Edge 85839 *****************/
        IntegrationSettings__c is = IntegrationSettings__c.getOrgDefaults();
        String token = '';
        if(!is.EnableMocks__c){
            token = TCMSearchManager.getTCMToken();
        }
        
        // Prepare Request
        HttpRequest request = new HttpRequest();
        
        if(is.EnableMocks__c == true){
            request.setEndpoint(EnvironmentVariable.get('MockEndpoint'));    
        } else {
            String ep = EnvironmentVariable.get('tcm_customerEndpoint');
            if(event != EVENT_ACTION_CREATE && String.isNotBlank(identifier)) {
                ep = ep + '/'+identifier;
            }
            request.setEndpoint(ep);
        }
        
        if(event == EVENT_ACTION_CREATE){
            request.setMethod('POST');    
        } else {
            request.setMethod('PUT');
        }
        //Set Certificate
        if(Certificate_name != null){
            request.setClientCertificateName(Certificate_name);
        }
        request.setBody(req);
        request.setTimeout(30000);
        
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + token);
        
        System.debug('!@#$% Request : ' + request);
        System.debug('!@#$% ManageCustomerRequest Body : ' + request.getBody());
        
        // Send Request
        Http httpClient = new Http();
        
        try{
            resp = httpClient.send(request);
        }catch(Exception e){
        /**************** Start of Edge 85839 *****************/
            if(!isBatch)
                log.logMessages(request.getBody(), (resp !=null ? resp.getBody() : ''), e.getStackTraceString(), 'Technical', '', '', false, false, (resp !=null ? resp.getStatusCode() : null),null,identifier, null);
        } finally {
            if(!isBatch)
                log.logMessages(request.getBody(), (resp !=null ? resp.getBody() : ''), '', '', '', '', false, false, (resp !=null ? resp.getStatusCode() : null),null,identifier, null);
        }
        return resp;
        /**************** End of Edge 85839 *****************/
    }
    /**************** Start of Edge 85839 *****************/
    
    private static void getMCRData(ManageCustomerRequest.Data dataItem, Account customer, String event){
        //ManageCustomerRequest.Data dataItem = new ManageCustomerRequest.Data();
        DateTime dt = System.Datetime.now();
        dataItem.sendDateTime = String.valueOf(dt)+'.'+dt.millisecond(); // INTERFACE MANDATORY
        dataItem.externalSystemId = (customer.Source_System__c == null)?'':customer.Source_System__c;
        dataItem.cac = (customer.Customer_ID__c == null)?'':customer.Customer_ID__c; //INTERFACE MANDATORY
        dataItem.eventAction = event; //INTERFACE MANDATORY
        dataItem.businessUnit = (customer.Business_Unit__c == null)?'':customer.Business_Unit__c; //INTERFACE MANDATORY
        dataItem.customerManagedFlag =(customer.Managed__c == null)?'':ConversionUtils.booleanToString(customer.Managed__c); //INTERFACE MANDATORY
        dataItem.customerType = (customer.Type == null)?'':customer.Type; //INTERFACE MANDATORY
        dataItem.languagePreference = (customer.Language_Preference__c == null)?'':customer.Language_Preference__c; //INTERFACE MANDATORY
        dataItem.marketSegment = (customer.Market_Segment__c == null)?'':customer.Market_Segment__c; //INTERFACE MANDATORY
        dataItem.accountStatus = (customer.Customer_Status__c == null)?'':customer.Customer_Status__c; //INTERFACE MANDATORY
        dataItem.servicingOrgUnit = (customer.Legacy_SOU__c == null)?'':customer.Legacy_SOU__c; //INTERFACE MANDATORY
        dataItem.cidn =(customer.CIDN__c == null)?'':customer.CIDN__c;
        //dataItem.parentCidn =(customer.Parent_CIDN__c == null)?'':customer.Parent_CIDN__c;
        //dataItem.ultimateParentCidn =(customer.Ultimate_Parent_CIDN__c == null)?'':customer.Ultimate_Parent_CIDN__c;
        //dataItem.premiumService = (customer.Premium_Service__c == null)?'':ConversionUtils.booleanToString(customer.Premium_Service__c);
        //dataItem.abnOverride =(customer.ABN_Overide__c == null)?'':customer.ABN_Overide__c;
        //dataItem.rootCidn = '';
        //dataItem.ownershipCode = (customer.Legacy_Ownership_Code__c == null)?'':customer.Legacy_Ownership_Code__c;
        //dataItem.priorityAssist = (customer.PriorityAssist__c == null)?'':ConversionUtils.booleanToString(customer.PriorityAssist__c);
        dataItem.lastModifiedDate = (customer.Actual_Retired_Date__c == null)?'':validateDateField(customer.Actual_Retired_Date__c);//String.valueOfGmt(customer.Actual_Retired_Date__c);
        dataItem.location = (customer.Loc__c == null) ? '' : customer.Loc__c;
        dataItem.churnpropensity = (customer.Churn_Propensity__c == null)?'':customer.Churn_Propensity__c;
        dataItem.customerSince = (customer.Date_Started_Trading_with_Telstra__c == null)?'':validateDateField(customer.Date_Started_Trading_with_Telstra__c);
        dataItem.description = (customer.Acount_Description__c == null)?'':customer.Acount_Description__c;
        dataItem.franchiseArrange = (customer.Franchisee_Arrange__c == null)?'':customer.Franchisee_Arrange__c; 
        dataItem.retiredUId = (customer.Retired_UserID__c == null)?'':customer.Retired_UserID__c;
        dataItem.retirementReason = (customer.Retirement_Reason__c == null)?'':customer.Retirement_Reason__c;
        dataItem.timeZone =(customer.Time_Zone__c == null)?'':customer.Time_Zone__c;
        dataItem.writtenaAuthorityRequiredFlag = (customer.Wriiten_Auth_Required__c == null)?'':ConversionUtils.booleanToString(customer.Wriiten_Auth_Required__c);
        dataItem.effectiveRetiredDate = (customer.Effective_Retired_Date__c == null)?'':validateDateField(customer.Effective_Retired_Date__c);
        dataItem.lastVerifiedDate = (customer.Customer_Last_Verified_Date__c == null)?'':validateDateField(customer.Customer_Last_Verified_Date__c);
        dataItem.createdDate = (customer.Legacy_Created_date__c == null)?'':validateDateFieldWithTZD(customer.Legacy_Created_date__c);
        //dataItem.duplicateOverrideReason = '';
        //dataItem.revenueOrganisationUnit = (customer.Legacy_ROU__c == null)?'':customer.Legacy_ROU__c;
        dataItem.potentialRevenue = (customer.Customer_Potential_Revenue__c == null)?'':customer.Customer_Potential_Revenue__c;
        dataItem.currentRevenue =  (customer.Customer_Current_Revenue__c == null)?'':customer.Customer_Current_Revenue__c;
        dataItem.partners = (customer.Partners__c == null)?'':customer.Partners__c;  
        dataItem.approveDeclineReason =(customer.Approve_Decline_Reason__c == null)?'':customer.Approve_Decline_Reason__c;
        dataItem.recommendedPaymentMethod = (customer.Recommended_Payment_Method__c == null)?'':customer.Recommended_Payment_Method__c;
        dataItem.recommendedBillingFrequency = (customer.Recommended_Billing_Frequency__c == null)?'':customer.Recommended_Billing_Frequency__c;
        dataItem.validationCustomerConsent = (customer.Validation_Customer_Consent__c == null)?'':customer.Validation_Customer_Consent__c;
        dataItem.validationConsentRequestDate = (customer.Validation_Consent_Request_Date__c == null)?'':validateDateFieldWithTZD(customer.Validation_Consent_Request_Date__c);
        dataItem.customerEffectiveStartDate = (customer.Customer_Effective_Start_Date__c == null)?'':validateDateField(customer.Customer_Effective_Start_Date__c);
        dataItem.relationshipType = (customer.Relationship_Type__c== null)?'':customer.Relationship_Type__c;
        dataItem.reportingPointIndicator = (customer.Reporting_Point_Indicator__c == null)?'':customer.Reporting_Point_Indicator__c;
        dataItem.customerEffectiveEndDate = (customer.Customer_Effective_EndDate__c == null)?'':validateDateField(customer.Customer_Effective_EndDate__c);
        dataItem.ansicCode = customer.Sic;
        //dataItem.primaryIndustryIndicator = '';
        dataItem.dateOfApplication =(customer.Date_of_Application__c == null)?'':validateDateFieldWithTZD(customer.Date_of_Application__c);     
        dataItem.geographicalLocationCode = (customer.Geographical_LocationCode__c == null)?'':customer.Geographical_LocationCode__c;       
        dataItem.masterID = (customer.TCM_MasterID__c == null)?'':String.valueOf(customer.TCM_MasterID__c);
        dataItem.lastUpdated =(customer.TCM_Last_Updated__c == null)?'':validateDateFieldWithTZD(customer.TCM_Last_Updated__c);
       }
    
    private static void getMCRCategory(ManageCustomerRequest.Category categoryItem, Account customer){
        //ManageCustomerRequest.Category categoryItem = new ManageCustomerRequest.Category();
        categoryItem.online =(customer.OLB_Online_Bill_Registered__c== null)?'':ConversionUtils.booleanToString(customer.OLB_Online_Bill_Registered__c);
        //categoryItem.bpProtect = '';
        //categoryItem.protect = '';
    }
    
    private static void getMCRCreditSituation(ManageCustomerRequest.CreditSituation creditSituationItem, Account customer){
        //ManageCustomerRequest.CreditSituation creditSituationItem = new ManageCustomerRequest.CreditSituation();
        creditSituationItem.creditLimit = (customer.Credit_Limit__c == null)?'':String.valueOf(customer.Credit_Limit__c);
        creditSituationItem.creditManagementStatus = (customer.Credit_Management_Status__c == null)?'':customer.Credit_Management_Status__c;
        creditSituationItem.creditRating = (customer.Credit_Rating__c == null)?'':String.valueOf(customer.Credit_Rating__c);
    }
    
    private static void getMCRConcession(ManageCustomerRequest.Concession concessionItem, Account customer){
        //ManageCustomerRequest.Concession concessionItem = new ManageCustomerRequest.Concession();
        concessionItem.concessionAuthority = (customer.Concession_Authority__c == null)?'':customer.Concession_Authority__c;
        concessionItem.concessionNumber = (customer.Concession_Number__c == null)?'':customer.Concession_Number__c;
        concessionItem.concessionType = (customer.Concession_Type__c == null)?'':customer.Concession_Type__c;
        //concessionItem.paymentType = (customer.Payment_Type__c == null)?'':customer.Payment_Type__c;
        //concessionItem.paymentStatus = (customer.Payment_Status__c == null)?'':customer.Payment_Status__c;
        concessionItem.validConcessionFlag = (customer.Valid_Concession_Flag__c == null)?'':ConversionUtils.booleanToString(customer.Valid_Concession_Flag__c);
        concessionItem.lastValidatedDate = (customer.Last_Validated_Date__c== null)?'':validateDateField(customer.Last_Validated_Date__c);
        concessionItem.bypassConcessionValidation = (customer.Bypass_Concession_Validation__c == null)?'':customer.Bypass_Concession_Validation__c;
        concessionItem.validationResultOverride = (customer.Validation_Result_Override__c== null)?'':customer.Validation_Result_Override__c;
    }
    
    private static Contact getLegalLesseContact(Account customer){
        List<AccountContactRelation> acrList = [SELECT Contact.LastName, Contact.FirstName,Relationship_End_Date__c FROM AccountContactRelation where Roles  = 'Legal Lessee' and accountId = :customer.Id];
        Contact legalLesseeContact = null;
        if(!acrList.isEmpty()){
            for(AccountContactRelation acr : acrList){
                if(acr.Relationship_End_Date__c == null || acr.Relationship_End_Date__c > System.today()){
                    legalLesseeContact = acr.contact;
                    System.debug('fistName, LastName' + legalLesseeContact.firstName + ', ' + legalLesseeContact.lastName);
                }
            }
        }
        return legalLesseeContact;
    }
    
    private static void getMCRCustomerAccount(ManageCustomerRequest.CustomerAccount customerAccountItem, Account customer){
        if(customer.type == 'Sole Trader' || customer.type == 'Residential'){
            Contact legalLesseeContact = getLegalLesseContact(customer);
            if(legalLesseeContact != null && isNotNullAndBlank(legalLesseeContact.FirstName) && isNotNullAndBlank(legalLesseeContact.LastName)){
                customerAccountItem.firstName = legalLesseeContact.FirstName;
                customerAccountItem.lastName = legalLesseeContact.LastName; //INTERFACE MANDATORY                     
            }
        } else {
            customerAccountItem.lastName = (customer.Name == null)?'':customer.Name; //INTERFACE MANDATORY
        }
        customerAccountItem.phoneNumber = (customer.Phone == null)?'':customer.Phone;
        customerAccountItem.emailAddress = (customer.Email__c == null)?'':customer.Email__c;
        customerAccountItem.abn = (customer.ABN__c == null)?'':customer.ABN__c;
        customerAccountItem.faxNumber = (customer.Fax == null)?'':customer.Fax;
        customerAccountItem.acn = (customer.ACN__c == null)?'':customer.ACN__c;
        customerAccountItem.webAddress = (customer.Website == null)?'':customer.Website;
        customerAccountItem.fraudFlag = (customer.FraudFlag__c == null)?'':ConversionUtils.booleanToString(customer.FraudFlag__c);
        customerAccountItem.vipFlag =  (customer.VIP_Customer__c == null)?'':ConversionUtils.booleanToString(customer.VIP_Customer__c);
        customerAccountItem.accountUuid = (customer.Account_UUID__c == null)?'':customer.Account_UUID__c;
        customerAccountItem.preferredMethod = (customer.Pref_Comm_Method__c == null)?'':customer.Pref_Comm_Method__c; //INTERFACE MANDATORY
        customerAccountItem.dataSovereignty = (customer.Data_Sovereign_Status__c == null)?'':customer.Data_Sovereign_Status__c;
    }
    
    private static void getMCRAccountTrading(ManageCustomerRequest.AccountTrading atItem, Account customer, String event){
        //ManageCustomerRequest.AccountTrading atItem = new ManageCustomerRequest.AccountTrading();
        if(event == EVENT_ACTION_CREATE){
            atItem.isPrimary = customer.Primary__c == true ? 'Y' : 'N'; //INTERFACE MANDATORY            
        }
        //atItem.startDate = '';
        //atItem.endDate = '';
        atItem.tradingName = (customer.Customer_Trading_Name__c == null)?'':customer.Customer_Trading_Name__c;
    }
    private static void getMCRAccountPortfolio(ManageCustomerRequest.AccountPortfolio apItem, Account customer,String event){
        //ManageCustomerRequest.AccountTrading atItem = new ManageCustomerRequest.AccountTrading();
        if(event == EVENT_ACTION_CREATE){
        apItem.isPrimary = (customer.Primary_Portfolio_Indicator__c == null)?'':String.valueof(customer.Primary_Portfolio_Indicator__c); //INTERFACE MANDATORY
       }
       apItem.portfolioCode=(customer.Portfolio_Code__c == null)?'':String.valueof(customer.Portfolio_Code__c);
     }
                /*------------------------------------------------------------ 
EDGE-39902
Method: getMCRAccountAddress 
Description: generate address payload
Inputs: List if cscrm__Address__c
Returns: 
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    @TestVisible
    private static List<ManageCustomerRequest.Address> getMCRAccountAddress(List<cscrm__Address__c> addresses, Boolean isPrimaryAddress){
        List<ManageCustomerRequest.Address> dataItemAddress= new List<ManageCustomerRequest.Address>();
        if(addresses != null && !addresses.isEmpty() ){
            for(cscrm__Address__c address : addresses){
                ManageCustomerRequest.Address addressItem = new ManageCustomerRequest.Address();
                addressItem.isPrimary = (isPrimaryAddress) ? 'Y' : 'N';//INTERFACE MANDATORY
                addressItem.addressId = (address.Address_ID__c == null)?'':address.Address_ID__c; //INTERFACE MANDATORY
                addressItem.country = (address.cscrm__Country__c == null)?'':address.cscrm__Country__c;//'AUSTRALIA'; //INTERFACE MANDATORY
                addressItem.status = (address.Address_Status__c == null)?'':validateAddressStatus(address.Address_Status__c);//
                
                //addressItem.statusCode = (address.TCM_status_Code__c == null)?'':address.TCM_status_Code__c;
                //addressItem.addressType = (isPrimaryAddress) ? 'Primary Address' : (address.cscrm__Address_Type__c == null)?'':address.cscrm__Address_Type__c;//
                //addressItem.addressTypeCode = (address.TCM_Address_Type_Value__c == null)?'':address.TCM_Address_Type_Value__c;
                addressItem.addressType = (address.Sub_Address_Type__c == null)?'':AddressTriggerHandler.getAddressTypeForTCMManage(address.Parent_Address_Id__c,address.Number_of_Sub_addresses__c,address.Sub_Address_Type__c);//EDGE-39902
                addressItem.state = (address.cscrm__State_Province__c == null)?'':address.cscrm__State_Province__c;
                addressItem.postalCode = (address.cscrm__Zip_Postal_Code__c == null)?'':address.cscrm__Zip_Postal_Code__c;
                addressItem.streetName = (address.cscrm__Street_Name__c == null)?'':address.cscrm__Street_Name__c;
                addressItem.streetType = (address.streetType__c == null)?'':AddressTriggerHandler.getStreetTypeForTCMManage(address.streetType__c); //EDGE-39902
                //addressItem.streetTypeCode = (address.TCM_Street_Type_code__c == null)?'':address.TCM_Street_Type_code__c;
                addressItem.streetTypeSuffix = (address.streetTypeSuffix__c == null)?'':address.streetTypeSuffix__c;
                //addressItem.streetTypeSuffixCode = (address.TCM_street_Type_Suffix_Code__c == null)?'':address.TCM_street_Type_Suffix_Code__c;
                //Changed As per Discussion with Eureka's Designer foe street start number field
                addressItem.streetNumberStart = (address.Street_Number_From_calc__c == null)?'':address.Street_Number_From_calc__c;
                addressItem.streetNumberStartSuffix = (address.streetNumberStartSuffix__c == null)?'':address.streetNumberStartSuffix__c;
                addressItem.streetNumberEnd = (address.cscrm__Street_Number_End__c == null)?'':address.cscrm__Street_Number_End__c;
                addressItem.streetNumberEndSuffix = (address.streetNumberEndSuffix__c == null)?'':address.streetNumberEndSuffix__c;
                addressItem.internationalPostCode = (address.TCM_internationalPostcode__c == null)?'':address.TCM_internationalPostcode__c;
                addressItem.internationalState = (address.TCM_internationalState__c == null)?'':address.TCM_internationalState__c;
                addressItem.deliveryPointId = (address.DP_Id__c == null)?'':address.DP_Id__c;
                addressItem.registeredPlan = (address.TCM_registeredPlan__c == null)?'':address.TCM_registeredPlan__c;
                addressItem.locality = (address.Locality__c == null)?'':address.Locality__c;
                addressItem.additionalInfo = (address.TCM_additionalInfo__c == null)?'':address.TCM_additionalInfo__c;
                //addressItem.geographicalLocationCode = '';
                // SubAddress
                addressItem.subAddress = new ManageCustomerRequest.SubAddress();
                addressItem.subAddress.buildingName = (address.cscrm__Building_Name__c == null)?'':address.cscrm__Building_Name__c;
                addressItem.subAddress.propertyName = (address.cscrm__Property_Name__c == null)?'':address.cscrm__Property_Name__c;
                addressItem.subAddress.numberStart = (address.TCM_numberStart__c == null)?'':address.TCM_numberStart__c;
                addressItem.subAddress.numberEnd = (address.TCM_numberEnd__c == null)?'': address.TCM_numberEnd__c;
                addressItem.subAddress.privateStreetName = (address.TCM_privateStreetName__c == null)?'':address.TCM_privateStreetName__c;
                addressItem.subAddress.privateStreetType = (address.TCM_privateStreetType__c == null)?'':address.TCM_privateStreetType__c;
                //addressItem.subAddress.privateStreetTypeCode = (address.TCM_privateStreetTypeCode__c == null)?'':address.TCM_privateStreetTypeCode__c;
                // Details
                ManageCustomerRequest.Detail detailItem1 = new ManageCustomerRequest.Detail();
                detailItem1.detailType = (address.Sub_Address1_Type__c == null)?'':address.Sub_Address1_Type__c;
                //detailItem1.detailTypeCode = (address.Sub_Address1_Type_Code__c == null)?'':address.Sub_Address1_Type_Code__c;
                detailItem1.value = (address.Sub_Address1_Number__c == null)?'':address.Sub_Address1_Number__c;
                ManageCustomerRequest.Detail detailItem2 = new ManageCustomerRequest.Detail();
                detailItem2.detailType = (address.Sub_Address2_Type__c == null)?'':address.Sub_Address2_Type__c;
                //detailItem2.detailTypeCode = (address.Sub_Address2_Type_Code__c == null)?'':address.Sub_Address2_Type_Code__c;
                detailItem2.value = (address.Sub_Address2_Number__c == null)?'':address.Sub_Address2_Number__c;
                addressItem.subAddress.details = new List<ManageCustomerRequest.Detail>();
                addressItem.subAddress.details.add(detailItem1);
                addressItem.subAddress.details.add(detailItem2);
                if(address.Address_Line_1__c != null){
                    addressItem.subAddress.addressLines = new List<String>();
                    addressItem.subAddress.addressLines.add(address.Address_Line_1__c);      
                }
                if(address.Address_Line_2__c != null){
                    addressItem.subAddress.addressLines.add(address.Address_Line_2__c);      
                }
                if(address.Address_Line_3__c != null){
                    addressItem.subAddress.addressLines.add(address.Address_Line_3__c);      
                }
                dataItemAddress.add(addressItem);
            }
        }
        return dataItemAddress;
    }
    @TestVisible
     private static boolean isNotNullAndBlank(String value){
        return (value != null && String.isNotBlank(value)) ? true : false;
    }
    @TestVisible
    private static String validateDateField(Date value){
        DateTime d = value ;
        String dateStr = d.format('yyyy-MM-dd');
        return dateStr;
    } 
    @TestVisible
    private static String validateDateFieldWithTZD(Datetime value){
        String dateStr = value.format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        return dateStr;
    } 
    @TestVisible
    private static String validateAddressStatus(String value){
        String status ='';
        if(value =='CONFIRMED') {
            status = 'CO';
        }
        else if(value == 'UNCONFIRMED'){
            status = 'UN';
        }
        return status;
    }
}