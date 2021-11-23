@RestResource(urlMapping='/NotifyCustomer/*')
global with sharing class NotifyCustomer {
public static List<cscrm__Address__c> cscrmAddressList;
       
// Delete an existing account
@HttpDelete
global static String doDelete() {
    Logger log = Logger.getLogger('NotifyCustomerDelete');
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
    List<Account> account = [SELECT Id FROM Account WHERE Id = :accountId];
    if(!account.isEmpty())
            Database.delete(account,false) ;
    log.logRequest(string.valueOf(req.requestURI), true);
    log.logResponse('Account : ' + accountId + ' successfully deleted.' ,true);
    return 'Account : ' + accountId + ' successfully deleted.';
}

// Retrieve an existing account
@HttpGet
global static Account doGet() {
    Logger log = Logger.getLogger('NotifyCustomerGet');
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
    //String accountId='001O0000019pNv5IAE';
    Account response = getAccount(accountId);
    log.logRequest(string.valueOf(req.requestURI), true);
    log.logResponse(response != null? string.valueOf(response) : 'No records found' , true);
    return response;
}
public static void evaluatedata(NotifyCustomerRequest request,List<cscrm__Address__c> addresses){
    cscrmAddressList = new List<cscrm__Address__c>();
    for(NotifyCustomerRequest.Address addr : request.data.address) {

            if(addresses != null) {
                for(cscrm__Address__c address : addresses) {
                    System.debug('!@#$% Comparing address External ID from request : '+addr.addressId+' with existing address found | External ID'+address.cscrm__External_ID__c);
                    if(addr.addressId == address.cscrm__External_ID__c) {
                        //address = mapRequestToAddress(addr, address, account);
                        cscrmAddressList.add(address);
                    }
                }
            }
          else{
            cscrm__Address__c address=new cscrm__Address__c();
            //address = mapRequestToAddress(addr, address, account);
            cscrmAddressList.add(address);
        }

            //EDGE=83916
            for(cscrm__Address__c address : cscrmAddressList)
            {
                //boolean isPrime =Boolean.valueOf(address.Is_Primary_Address__c);
                //saveNewAddressRel('Primary Address',account.Id,address.Id,address.Is_Primary_Address__c);
            }
            //EDGE=83916 Ends

        }
    if(!cscrmAddressList.isEmpty())
    {
        upsert cscrmAddressList;
    }
}
// Create a Customer
@HttpPost
global static NotifyCustomerResponse doPost(NotifyCustomerRequest request) {
    System.debug('!@#$% Request received : ' + request);

NotifyCustomerResponse response = new NotifyCustomerResponse();
    Logger2 logger = Logger2.getLogger('NotifyCustomerPost');
    try{
        // Check for existing account
        String operation = '';
        Account account = null;
        if(request != null && request.data != null){
            
            account = request.data.cac != null ? getExistingAccount(request.data.cac) : null;
            /*if(request.data.cac != null){
                System.debug('!@#$% Searching with CAC : ' + request.data.cac);
                account = getExistingAccount(request.data.cac);
            }*/
            System.debug('!@#$% Existing account found : ' + account);

            if(  account!= null){
                operation = 'updated';
                account = mapRequestToAccount(request, account);
                if(account.Type == 'Sole Trader'){
                    String accName = getLegalLesseContactNameForSoleTrader(account.Id);
                    account.Name = (accName != null) ? accName : account.Name;
                }

                update account;

                System.debug('!@#$% Updated account : ' + account);

                //AC2 EDGE-61
                List<Account_Industry_Relationship__c> accountIndustry = NULL;
                accountIndustry = NotifyCustomerHelper.getExistingAccountIndustry(account.Id);
                if(accountIndustry == null || accountIndustry.isEmpty()){
                    List<Account_Industry_Relationship__c> AccIndustry = NotifyCustomerHelper.mapRequestToAccountIndustry(request,account);
                    insert AccIndustry;
                    System.debug('!@#$% inserted AccountIndustry : ' + AccIndustry);
                }
                // End of EDGE-61, AC2//

       /*************************************************************
      EDGE: 67176
      Author: Ila Anmol Verma
      Description: Custom Setting to ignore TCM updates for Address
      ****************************************************************/
       String flag = EnvironmentVariable__c.getValues('TCMupdate').Value__c;
      if(flag=='True'){
          cscrmAddressList = new List<cscrm__Address__c>();
       //List<cscrm__Address__c> cscrmAddressList = new List<cscrm__Address__c>();
       /*-----------------------------Upadted as a part of EDGE-83916------------------------------
        ----------------------------------------------------------------------------------*/
                Set<String> addressIds = new Set<String>();

                if(request.data.address != null) {

                    for(NotifyCustomerRequest.Address addr : request.data.address) {
          addressIds.add(addr.addressId);
        }
                   List<cscrm__Address__c> addresses = getExistingAddresses(addressIds);

        evaluatedata(request,addresses);
        /*for(NotifyCustomerRequest.Address addr : request.data.address) {

            if(addresses != null) {
                for(cscrm__Address__c address : addresses) {
                    System.debug('!@#$% Comparing address External ID from request : '+addr.addressId+' with existing address found | External ID'+address.cscrm__External_ID__c);
                    if(addr.addressId == address.cscrm__External_ID__c) {
                        address = mapRequestToAddress(addr, address, account);
                        cscrmAddressList.add(address);
                    }
                }
            }
          else{
            cscrm__Address__c address=new cscrm__Address__c();
            address = mapRequestToAddress(addr, address, account);
            cscrmAddressList.add(address);
        }

            //EDGE=83916
            for(cscrm__Address__c address : cscrmAddressList)
            {
                //boolean isPrime =Boolean.valueOf(address.Is_Primary_Address__c);
                saveNewAddressRel('Primary Address',account.Id,address.Id,address.Is_Primary_Address__c);
            }
            //EDGE=83916 Ends

        }*/
                    //Removed DML inside For loop
                    /*if(!cscrmAddressList.isEmpty())
                    {
                        upsert cscrmAddressList;
                    }*/
                }
      }
            } else {
                if(request.data.accountStatus != 'RETIRED'){
                    operation = 'created';

                    account = mapRequestToAccount(request, account);
                    insert account;

                    //Commented As part of QC115052
                    //Contact contact = mapRequestToContact(request, null, account);
                    //insert contact;

                  //AC2 EDGE-61
                  List<Account_Industry_Relationship__c> AccountIndustry = NotifyCustomerHelper.mapRequestToAccountIndustry(request,account);
                  insert AccountIndustry;
                  System.debug('!@#$% inserted AccountIndustry : ' + AccountIndustry);

                  /*------Commented to avoid dupliacte address insertion---------
                    if(request.data.address != Null){
                        List<cscrm__Address__c> cscrmAddressList = new List<cscrm__Address__c>();
                        for(NotifyCustomerRequest.Address addr : request.data.address){
                            cscrm__Address__c address = mapRequestToAddress(addr, null, account);
                            cscrmAddressList.add(address);
                        }
                        if(!cscrmAddressList.isEmpty())
                            insert cscrmAddressList;
                    }*/
        /*************************************************************
        EDGE: 67176
        Author: Ila Anmol Verma
        Description: Custom Setting to ignore TCM updates for Address
        ****************************************************************/
        String flag = EnvironmentVariable__c.getValues('TCMupdate').Value__c;
      if(flag=='True'){
                     List<cscrm__Address__c> cscrmAddressList = new List<cscrm__Address__c>();
       /*-----------------------------Upadted as a part of EDGE-83916------------------------------
        ----------------------------------------------------------------------------------*/
                Set<String> addressIds = new Set<String>();
                if(request.data.address != null) {

                    for(NotifyCustomerRequest.Address addr : request.data.address) {
          addressIds.add(addr.addressId);
        }
                   List<cscrm__Address__c> addresses = getExistingAddresses(addressIds);

       evaluatedata(request,addresses);
        /*for(NotifyCustomerRequest.Address addr : request.data.address) {

                        if(addresses != null) {

                            for(cscrm__Address__c address : addresses) {
                                System.debug('!@#$% Comparing address External ID from request : '+addr.addressId+' with existing address found | External ID'+address.cscrm__External_ID__c);
                                if(addr.addressId == address.cscrm__External_ID__c) {
                                    address = mapRequestToAddress(addr, address, account);
                                    cscrmAddressList.add(address);
                                }
                            }
          }
          else{
          cscrm__Address__c address=new cscrm__Address__c();
        address = mapRequestToAddress(addr, address, account);
        cscrmAddressList.add(address);
      }

            //EDGE=83916
            for(cscrm__Address__c address : cscrmAddressList)
            {
                //boolean isPrime =Boolean.valueOf(address.Is_Primary_Address__c);
                saveNewAddressRel('Primary Address',account.Id,address.Id,address.Is_Primary_Address__c);
            }
            //EDGE=83916 Ends

        }
                    //Removed DML inside For loop
                    if(!cscrmAddressList.isEmpty())
                    {
                        upsert cscrmAddressList;
                    }*/

                }
      }
                }
            }
        }

        if(account!= null){
            response.Data = account.id;
        }else{
            response.Data = null;
        }
        response.Status = 'Success';
        response.StatusCode = 200;
        response.ErrorCode = null;
        response.Message = 'Customer ' + operation;
    }catch(DmlException e){
        //EDGE-2331
        response.Status = 'Success';
        response.StatusCode = 200;
        response.ErrorCode = TCMBusinessErrorCode.getInstance().getCode(e.getMessage().toLowerCase());
        response.Message = 'Customer ' + e.getMessage();
        logger.logMessages(JSON.serialize(request), JSON.serialize(response), e.getStackTraceString(), 'Business', TCMBusinessErrorCode.getInstance().getCode(e.getMessage().toLowerCase()), e.getMessage(), false, false,response.StatusCode,request.Data.cac,request.Data.customerAccount.accountUuid,TCMCustomerContactConstants.TCMERRORCODE_FAILURE);
    } finally {
        logger.logMessages(JSON.serialize(request), JSON.serialize(response), '', '', '', '', false, false, response.StatusCode,request.Data.cac,request.Data.customerAccount.accountUuid, null);
        logger.exitLogger();
    }
    return response;

}

private static Account getAccount(String accountId){
    Account result = [SELECT AccountSource,AnnualRevenue,BillingAddress,BillingCity,BillingCountry,BillingGeocodeAccuracy,BillingLatitude,BillingLongitude,BillingPostalCode,BillingState,BillingStreet,CreatedById,CreatedDate,cscfga__Active__c,cscfga__SLAExpirationDate__c,cscfga__SLASerialNumber__c,cspmb__Discount_Level__c,Description,Fax,Id,Industry,IsCustomerPortal,IsDeleted,Jigsaw,JigsawCompanyId,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,MasterRecordId,Name,NumberOfEmployees,OwnerId,ParentId,Phone,PhotoUrl,ShippingAddress,ShippingCity,ShippingCountry,ShippingGeocodeAccuracy,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStreet,SicDesc,SystemModstamp,Type,Website FROM Account WHERE Id = :accountId];
    //Account result=[select name FROM Account WHERE Id = :accountId ] ;
    return result;
}

private static Account getExistingAccount(String cac) {
    System.debug('!@#$% Querying for exisitng account with CAC : ' + cac);
    List<Account> acctList = [SELECT ABN_Overide__c,ABN__c,AccountSource,ACN__c,Actual_Retired_Date__c,AnnualRevenue,BillingAddress,BillingCity,BillingCountry,BillingGeocodeAccuracy,BillingLatitude,BillingLongitude,BillingPostalCode,BillingState,BillingStreet,Business_Unit__c,CreatedById,CreatedDate,cscfga__Active__c,cscfga__SLAExpirationDate__c,cscfga__SLASerialNumber__c,cspmb__Discount_Level__c,CIDN__c,Customer_Effective_Start_Date__c,Customer_ID__c,Customer_Status__c,Date_of_Application__c,Date_Started_Trading_with_Telstra__c,Description,Email__c,End_Date__c,Fax,GB2B_Customer_Status__c,Geographical_Location_Code__c,Geographical_Location_Code__Latitude__s,Geographical_Location_Code__Longitude__s,Id,Industry,Internal_CAC__c,IsCustomerPortal,IsDeleted,Jigsaw,JigsawCompanyId,Language_Preference__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Managed__c,MasterRecordId,Name,NumberOfEmployees,OwnerId,Legacy_Ownership_Code__c,ParentId,Parent_CIDN__c,Phone,PhotoUrl,Portfolio_Code__c,Pref_Comm_Method__c,Premium_Service__c,Primary_Portfolio_Indicator__c,Primary__c,Protect__c,ShippingAddress,ShippingCity,ShippingCountry,ShippingGeocodeAccuracy,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStreet,SicDesc,Legacy_SOU__c,Start_Date__c,SystemModstamp,Customer_Trading_Name__c,Type,Ultimate_Parent_CIDN__c,Website FROM Account WHERE Customer_ID__c = :cac];
    System.debug('!@#$% Querying result : ' + acctList);
    if(!acctList.isEmpty()){
        return acctList.get(0);
    } else {
        return null;
    }
}

/*
EDGE-83916
`Description:Method updated to Chcek existing addresses against External Id
Author     :Aishwarya Yeware
*/
public static List<cscrm__Address__c> getExistingAddresses(Set<String> externalId) {
    System.debug('!@#$% Querying for exisitng addresses with External  ID : ' + externalId);
    List<cscrm__Address__c> addrsList = [SELECT cscrm__Account__c,Address_Line_1__c,Locality__c,cscrm__Address_Details__c,cscrm__Address_Type__c,cscrm__Building_Name__c,cscrm__Building_Number__c,cscrm__Building_Type__c,cscrm__City__c,cscrm__Country__c,cscrm__External_Address_Id__c,cscrm__External_ID__c,cscrm__Geolocation__c,cscrm__Geolocation__Latitude__s,cscrm__Geolocation__Longitude__s,cscrm__Is_Billing_Address__c,cscrm__Is_Installation_Address__c,cscrm__Is_Registered_Office_Address__c,cscrm__Is_Shipping_Address__c,cscrm__Level_Number__c,cscrm__Level_Type__c,cscrm__Plan_Number__c,cscrm__Property_Name__c,cscrm__State_Province__c,cscrm__Street_Name__c,cscrm__Street_Number_End__c,cscrm__Street_Number_Start__c,cscrm__Street_Type__c,cscrm__Street__c,cscrm__Unit_Number__c,cscrm__Unit_Type__c,cscrm__Zip_Postal_Code__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Name,OwnerId,SystemModstamp FROM cscrm__Address__c WHERE cscrm__External_ID__c = :externalId];
    System.debug('!@#$% Querying result : ' + addrsList);
    if(!addrsList.isEmpty()){
        return addrsList;
    }
    return null;
}

public static String getLegalLesseContactNameForSoleTrader(Id accountId){
    List<AccountContactRelation> acrList = [SELECT Id, AccountId, ContactId, Contact_Type__c FROM AccountContactRelation where Contact_Type__c = 'Legal Lessee' and AccountId = :accountId]  ;
    if(!acrList.isEmpty()){
        Id ContactId = acrList.get(0).contactId;
        if(ContactId != NULL) {
            List<Contact> contactList= [SELECT Id,Name,FirstName, LastName, MiddleName FROM Contact where Id = :ContactId];
            if(!contactList.isEmpty()){
                return (contactList.get(0) != null && contactList.get(0).Name != null) ? contactList.get(0).Name : null;
            }
        }

    }
    return Null;
}
private static Account returnAccountdetail(NotifyCustomerRequest req, Account a){
    if(isNotNullAndBlank(req.data.customerManagedFlag)){
        a.Managed__c = (req.data.customerManagedFlag == 'Y') ? true : false;
    }
    
    if(req.data.accountTrading != null && !req.data.accountTrading.isEmpty()){
        a.Customer_Trading_Name__c =(isNotNullAndBlank(req.data.accountTrading[0].tradingName))?req.data.accountTrading[0].tradingName :'';
        a.Primary__c = (isNotNullAndBlank(req.data.accountTrading[0].isPrimary) && req.data.accountTrading[0].isPrimary == 'Y')? True : False;
    }
    if(req.data.Concession != NULL){
        a.Concession_Authority__c = req.data.Concession.concessionAuthority;    
        a.Concession_Number__c = req.data.Concession.concessionNumber;    
        a.Concession_Type__c = req.data.Concession.concessionType;    
        a.Payment_Type__c = req.data.Concession.paymentType;    
        a.Payment_Status__c = req.data.Concession.paymentStatus;    
        if(isNotNullAndBlank(req.data.Concession.validConcessionFlag)){    
            a.Valid_Concession_Flag__c = ConversionUtils.stringtoBoolean(req.data.Concession.validConcessionFlag);    
        }      
        a.Last_Validated_Date__c = validateDateField(req.data.Concession.lastValidatedDate);
        a.Bypass_Concession_Validation__c = req.data.Concession.bypassConcessionValidation;    
        a.Validation_Result_Override__c = req.data.Concession.validationResultOverride;    
    }
    a = returnAccountdata(req,a);

    return a;
}
private static Account returnAccountdata(NotifyCustomerRequest req, Account a){
    if(isNotNullAndBlank(req.data.retiredUId)){ 
        a.Retired_UserID__c= req.data.retiredUId;   
    }   
        
    if(isNotNullAndBlank(req.data.priorityAssist)){    
        a.PriorityAssist__c =  Boolean.valueOf(req.data.priorityAssist);    
    }    
    if(isNotNullAndBlank(req.data.writtenaAuthorityRequiredFlag)){    
        a.Wriiten_Auth_Required__c = ConversionUtils.stringtoBoolean(req.data.writtenaAuthorityRequiredFlag);    
    }    
    if(isNotNullAndBlank(req.data.createdDate)){     
        a.Legacy_Created_date__c = date.valueof(req.data.createdDate);    
    }    
    if(req.data.Category != null && isNotNullAndBlank(req.data.Category.online)){     
        a.OLB_Online_Bill_Registered__c = ConversionUtils.stringtoBoolean(req.data.Category.online);    
    }    
    if(isNotNullAndBlank(req.data.potentialRevenue)){     
        a.Customer_Potential_Revenue__c = req.data.potentialRevenue;     
    }      
    if(isNotNullAndBlank(req.data.currentRevenue)){     
        a.Customer_Current_Revenue__c = req.data.currentRevenue;    
    }

    return a;
}

private static Account mapRequestToAccount(NotifyCustomerRequest req, Account a) {
    if(a == null){
        a = new Account();
    }
    String accountName = (req.data.customerType == 'Sole Trader' || req.data.customerType == 'Residential')?
        req.data.customerAccount.firstName +' '+req.data.customerAccount.lastName:req.data.customerAccount.lastName;
    a.Name = accountName.unescapeHtml4();
    a.ABN_Overide__c = req.data.abnOverride;
    a.AccountSource = req.data.parentSourceSystem;
    if(req.data.customerAccount != null){
        a.ABN__c = req.data.customerAccount.abn;
        a.ACN__c = req.data.customerAccount.acn;
        a.Account_UUID__c = req.data.customerAccount.accountUuid;
        a.Pref_Comm_Method__c = req.data.customerAccount.preferredMethod;
        a.Email__c = req.data.customerAccount.emailAddress;
        a.Phone = TCMCustomerContactHelper.formatNumber( req.data.CustomerAccount.phoneNumber);    
        a.Fax = TCMCustomerContactHelper.formatNumber(req.data.CustomerAccount.faxNumber);   
        a.Website = req.data.customerAccount.webAddress;
        if(isNotNullAndBlank(req.data.CustomerAccount.fraudFlag)){    
            a.FraudFlag__c =  Boolean.valueOf(req.data.CustomerAccount.fraudFlag);    
        }
    }
    if(isNotNullAndBlank(req.data.masterID)) {
        a.TCM_MasterID__c = req.data.masterID;    
    }
    a.Business_Unit__c = req.data.businessUnit;  
    a.Market_Segment__c = (String.isNotBlank(req.data.marketSegment)) ? req.data.marketSegment.unescapeHtml4() : null;
    a.Legacy_SOU__c = req.data.servicingOrgUnit;
    
    a.CIDN__c = req.data.cidn;
    a.Customer_ID__c = req.data.cac;
    a.Customer_Status__c = req.data.accountStatus;
    a.Acount_Description__c = req.data.description;
    
    //a.GB2B_Customer_Status__c = req.data.accountStatus;
    //a.Industry = req.data.primaryIndustryIndicator;
    a.Language_Preference__c = req.data.languagePreference;
    
    a.Parent_CIDN__c = req.data.parentCidn;
    a.Imported__c =  true;
    a.Send_Create_Event__c = false;
    a = returnAccountdetail(req, a);
    /*if(isNotNullAndBlank(req.data.customerManagedFlag)){
        a.Managed__c = (req.data.customerManagedFlag == 'Y') ? true : false;
    }
    
    
    if(req.data.accountTrading != null && !req.data.accountTrading.isEmpty()){
        a.Customer_Trading_Name__c =(isNotNullAndBlank(req.data.accountTrading[0].tradingName))?req.data.accountTrading[0].tradingName :'';
        a.Primary__c = (isNotNullAndBlank(req.data.accountTrading[0].isPrimary) && req.data.accountTrading[0].isPrimary == 'Y')? True : False;
    }*/
    
    a.Type = req.data.customerType;
    a.Ultimate_Parent_CIDN__c = req.data.parentCidn;
    
    
    a.loc__c = req.data.location;            
    a.Portfolio_Code__c = req.data.portfolioCode;    
    a.Geographical_LocationCode__c = req.data.geographicalLocationCode;  
    /*if(req.data.CreditSituation != NULL){
        a.Credit_Management_Status__c = req.data.CreditSituation.creditManagementStatus;   
        if(isNotNullAndBlank(req.data.CreditSituation.creditLimit)){    
            a.Credit_Limit__c = req.data.CreditSituation.creditLimit;    
        }     
        if(isNotNullAndBlank(req.data.CreditSituation.creditRating)){    
            a.Credit_Rating__c = req.data.CreditSituation.creditRating;    
        }  
    }*/   
    
    a.Churn_Propensity__c = req.data.churnpropensity;  
    /*if(req.data.Concession != NULL){
        a.Concession_Authority__c = req.data.Concession.concessionAuthority;    
        a.Concession_Number__c = req.data.Concession.concessionNumber;    
        a.Concession_Type__c = req.data.Concession.concessionType;    
        a.Payment_Type__c = req.data.Concession.paymentType;    
        a.Payment_Status__c = req.data.Concession.paymentStatus;    
        if(isNotNullAndBlank(req.data.Concession.validConcessionFlag)){    
            a.Valid_Concession_Flag__c = ConversionUtils.stringtoBoolean(req.data.Concession.validConcessionFlag);    
        }      
        a.Last_Validated_Date__c = validateDateField(req.data.Concession.lastValidatedDate);
        a.Bypass_Concession_Validation__c = req.data.Concession.bypassConcessionValidation;    
        a.Validation_Result_Override__c = req.data.Concession.validationResultOverride;    
    }*/
    a.Date_Started_Trading_with_Telstra__c = validateDateField(req.data.customerSince);    
    a.Effective_Retired_Date__c = validateDateField(req.data.effectiveRetiredDate);    
    a.Franchisee_Arrange__c = req.data.franchiseArrange;    
    a.Customer_Last_Verified_Date__c = (String.isNotBlank(req.data.lastVerifiedDate))? validateDateField(req.data.lastVerifiedDate) : TCMCustomerContactHelper.setLastVerifiedDateField(req.data.lastVerifiedDate); 
    a.Retirement_Reason__c = req.data.retirementReason;
    a.Time_Zone__c = req.data.timeZone;    
    a.Legacy_Ownership_Code__c = req.data.ownershipCode;    
    a.Legacy_ROU__c =  req.data.revenueOrganisationUnit;    
    /*if(isNotNullAndBlank(req.data.retiredUId)){ 
        a.Retired_UserID__c= req.data.retiredUId;   
    }   
        
    if(isNotNullAndBlank(req.data.priorityAssist)){    
        a.PriorityAssist__c =  Boolean.valueOf(req.data.priorityAssist);    
    }    
    if(isNotNullAndBlank(req.data.writtenaAuthorityRequiredFlag)){    
        a.Wriiten_Auth_Required__c = ConversionUtils.stringtoBoolean(req.data.writtenaAuthorityRequiredFlag);    
    }    
    if(isNotNullAndBlank(req.data.createdDate)){     
        a.Legacy_Created_date__c = date.valueof(req.data.createdDate);    
    }    
    if(req.data.Category != null && isNotNullAndBlank(req.data.Category.online)){     
        a.OLB_Online_Bill_Registered__c = ConversionUtils.stringtoBoolean(req.data.Category.online);    
    }    
    if(isNotNullAndBlank(req.data.potentialRevenue)){     
        a.Customer_Potential_Revenue__c = req.data.potentialRevenue;     
    }      
    if(isNotNullAndBlank(req.data.currentRevenue)){     
        a.Customer_Current_Revenue__c = req.data.currentRevenue;    
    }   */ 
    a.TCM_Merge_Status__c = req.data.mergeStatus;    
    a.Partners__c = req.data.partners;    
    a.Date_of_Application__c = validateDateField(req.data.dateOfApplication);    
    a.Approve_Decline_Reason__c = req.data.approveDeclineReason;    
    a.Recommended_Payment_Method__c = req.data.recommendedPaymentMethod;    
    a.Recommended_Billing_Frequency__c = req.data.recommendedBillingFrequency;    
    a.Source_System_Operation__c = req.data.sourceSysOperation;    
    a.Validation_Customer_Consent__c = req.data.validationCustomerConsent;    
    a.Validation_Consent_Request_Date__c = validateDateField(req.data.validationConsentRequestDate);    
    a.Ultimate_Parent_CIDN__c = req.data.rootCidn;    
    a.Customer_Effective_Start_Date__c = validateDateField(req.data.customerEffectiveStartDate);     
    a.Relationship_Type__c = req.data.relationshipType;    
    a.Reporting_Point_Indicator__c = req.data.reportingPointIndicator;    
    a.Customer_Effective_EndDate__c = validateDateField(req.data.customerEffectiveEndDate);   
    a.Data_Sovereign_Status__c = req.data.dataSovereignty;
    return a;
}
public Static cscrm__Address__c returnaddressLines(cscrm__Address__c address, NotifyCustomerRequest.Address add){
    if(add.subAddress.addressLines != null  && !add.subAddress.addressLines.isEmpty()){
        if(add.subAddress.addressLines[0] != null){
            address.Address_Line_1__c = add.subAddress.addressLines[0];    
        }
        if(add.subAddress.addressLines[1] != null){
            address.Address_Line_2__c = add.subAddress.addressLines[1];    
        }
        if(add.subAddress.addressLines[2] != null){
            address.Address_Line_3__c = add.subAddress.addressLines[2];    
        }
    }       
    return address;
}

public Static cscrm__Address__c returnsubaddressdetails(cscrm__Address__c address, NotifyCustomerRequest.Address add){
    if(add.SubAddress.details != null){
        if(add.subAddress.details[0]!=null){
            address.Sub_Address2_Number__c = add.subAddress.details[0].value;
            address.Sub_Address2_Type__c = add.subAddress.details[0].detailType;
            address.Sub_Address2_Type_Code__c = add.subAddress.details[0].detailTypeCode;
            address.Sub_Address_Level_2__c = address.Sub_Address2_Type__c + ' ' + address.Sub_Address2_Number__c;
        }
        if(add.subAddress.details[1]!=null){
            address.Sub_Address_3_Number__c = add.subAddress.details[1].value;
            address.Sub_Address_3_Type__c = add.subAddress.details[1].detailType;
            address.Sub_Address_3_Type_Code__c = add.subAddress.details[1].detailTypeCode;
            address.Sub_Address_Level_3__c = address.Sub_Address_3_Type__c + ' ' + address.Sub_Address_3_Number__c;
        }
    }
    if(add.subAddress.numberStart != null ){
            address.TCM_numberStart__c =add.subAddress.numberStart; 
        }
        if(add.subAddress.numberEnd != null ){
            address.TCM_numberEnd__c =add.subAddress.numberEnd; 
        }
    return address;
}

public Static cscrm__Address__c returnStreetNumber(cscrm__Address__c address, NotifyCustomerRequest.Address add){
    String stNumber = ''; 
    String numTo = '';
    if(add.streetNumberStart != null){
        stNumber  = add.streetNumberStart;
        if (add.streetNumberStartSuffix != null) {stNumber = stNumber + add.streetNumberStartSuffix; }
        address.cscrm__Street_Number_Start__c  = stNumber;
    }
    
    if(add.streetNumberEnd != null){
        numTo =add.streetNumberEnd;
        if (add.streetNumberEndSuffix != null) {numTo = numTo + add.streetNumberEndSuffix; }
        address.cscrm__Street_Number_End__c = numTo;
    }
    return address;
}

public static cscrm__Address__c mapRequestToAddress(NotifyCustomerRequest.Address add, cscrm__Address__c address, Account a) {
   // String stNumber = ''; 
    //String numTo = '';
    if(address == null){
        address = new cscrm__Address__c();    
    }
    address.cscrm__Country__c = add.country;
  //address.cscrm__Account__c = a.Id;  //Aishwarya, removed this as a part of EDGE-83916
    address.Address_Status__c = add.status;
    address.cscrm__Address_Type__c =add.addressType;
    system.debug('isPrimary++' + add.isPrimary);
    if(add.isPrimary != NULL && add.isPrimary != '')
        //Added as a part of EDGE-83916
        address.Is_Primary_Address__c=(add.isPrimary == 'Y') ? true : false; 
        //address.Is_Primary_Address__c =Boolean.valueOf(add.isPrimary);
    system.debug('isPrimary++' + address.Is_Primary_Address__c);
    address.cscrm__Country__c =add.country;
    address.streetNumberEndSuffix__c =add.streetNumberEndSuffix;
    //address.Address_ID__c =add.addressId;  removed this as a part of EDGE-83916
     address.cscrm__External_ID__c =add.addressId; //Added as a part of EDGE-83916
    address.cscrm__Zip_Postal_Code__c = add.postalCode;
    address.cscrm__Address_Type__c = add.isPrimary;
    address.TCM_registeredPlan__c =add.registeredPlan;
    address.streetNumberStartSuffix__c =add.streetNumberStartSuffix;
    address.cscrm__State_Province__c =add.state;
    address = returnStreetNumber(address, add);
    /*if(add.streetNumberStart != null){
        stNumber  = add.streetNumberStart;
        if (add.streetNumberStartSuffix != null) {stNumber = stNumber + add.streetNumberStartSuffix; }
        address.cscrm__Street_Number_Start__c  = stNumber;
    }
    
    if(add.streetNumberEnd != null){
        numTo =add.streetNumberEnd;
        if (add.streetNumberEndSuffix != null) {numTo = numTo + add.streetNumberEndSuffix; }
        address.cscrm__Street_Number_End__c = numTo;
    }*/
    
    address.cscrm__Street_Type__c =add.streetType;
    address.streetTypeSuffix__c =add.streetTypeSuffix;
    address.TCM_additionalInfo__c =add.additionalInfo;
    address.TCM_internationalPostcode__c =add.internationalPostCode;
    address.TCM_internationalState__c =add.internationalState;
    address.cscrm__City__c =add.locality;
    address.Locality__c =add.locality;
    address.cscrm__Street_Name__c =add.streetName;
    address.DP_Id__c =add.deliveryPointId;
    address.TCM_Address_Type_Value__c =add.addressTypeCode;
    address.TCM_Street_Type_code__c =add.streetTypeCode;
    address.TCM_street_Type_Suffix_Code__c =add.streetTypeSuffixCode;
    address.TCM_status_Code__c =add.statusCode;
    
    if(add.subAddress != null){
        /*if(add.subAddress.numberStart != null ){
            address.TCM_numberStart__c =add.subAddress.numberStart; 
        }
        if(add.subAddress.numberEnd != null ){
            address.TCM_numberEnd__c =add.subAddress.numberEnd; 
        }*/
        address.Sub_Address1_Type__c = add.addressTypeCode;
        address.Sub_Address1_Number__c = address.TCM_numberStart__c + ((address.TCM_numberEnd__c != null && address.TCM_numberEnd__c != '0' && address.TCM_numberEnd__c != '') ? ('-' + address.TCM_numberEnd__c) : '');
        address.Sub_Address_Level_1__c = address.Sub_Address1_Type__c + ' ' + address.Sub_Address1_Number__c;                   
        
        address.TCM_privateStreetName__c =add.subAddress.privateStreetName;
        address.TCM_privateStreetType__c = add.subAddress.privateStreetType;
        address.cscrm__Property_Name__c = add.subAddress.propertyName;
        address.TCM_privateStreetTypeCode__c =add.subAddress.privateStreetTypeCode;
        address.cscrm__Building_Name__c = add.subAddress.propertyName;
        address = returnaddressLines(address, add);
        address = returnsubaddressdetails(address, add);
        /*if(add.subAddress.addressLines != null  && !add.subAddress.addressLines.isEmpty()){
            if(add.subAddress.addressLines[0] != null){
                address.Address_Line_1__c = add.subAddress.addressLines[0];    
            }
            if(add.subAddress.addressLines[1] != null){
                address.Address_Line_2__c = add.subAddress.addressLines[1];    
            }
            if(add.subAddress.addressLines[2] != null){
                address.Address_Line_3__c = add.subAddress.addressLines[2];    
            }
        }
        if(add.SubAddress.details != null){
            if(add.subAddress.details[0]!=null){
                address.Sub_Address2_Number__c = add.subAddress.details[0].value;
                address.Sub_Address2_Type__c = add.subAddress.details[0].detailType;
                address.Sub_Address2_Type_Code__c = add.subAddress.details[0].detailTypeCode;
                address.Sub_Address_Level_2__c = address.Sub_Address2_Type__c + ' ' + address.Sub_Address2_Number__c;
            }
            if(add.subAddress.details[1]!=null){
                address.Sub_Address_3_Number__c = add.subAddress.details[1].value;
                address.Sub_Address_3_Type__c = add.subAddress.details[1].detailType;
                address.Sub_Address_3_Type_Code__c = add.subAddress.details[1].detailTypeCode;
                address.Sub_Address_Level_3__c = address.Sub_Address_3_Type__c + ' ' + address.Sub_Address_3_Number__c;
            }
        }*/
    } 
    
    return address;
}


private static boolean isNotNullAndBlank(String value){
    return (value != null && String.isNotBlank(value)) ? true : false;
}
private static Date validateDateField(String value){
    return (value != null && String.isNotBlank(value)) ? Date.valueOf(value) : null;
}
/*
EDGE: 83916
Host: Aishwarya Yeware
Description: Method to save the new adddress on Account Address Relationship
*/
public static String saveNewAddressRel(String addressType, String account, String address,Boolean isPrimary){
    cscrm__Account_Address_Relationship__c accountAddressRelationship = new cscrm__Account_Address_Relationship__c();
    accountAddressRelationship.cscrm__Address_Type__c = addressType;
    accountAddressRelationship.cscrm__Account__c = account;
    accountAddressRelationship.cscrm__Address__c = address;
    system.debug('isPrimary'+isPrimary);

    if(isPrimary)
{
  hasAddress(addressType,account);
        accountAddressRelationship.cscrm__Active__c = true;
    }
else
{
  accountAddressRelationship.cscrm__Active__c = false;
}


    accountAddressRelationship.AccountAddressRelationship__c=accountAddressRelationship.cscrm__Account__c+''+accountAddressRelationship.cscrm__Address__c;
    return addressRelSaveUtility(accountAddressRelationship);
}

/*
EDGE: 83916
Host: Aishwarya Yeware
Description: Checks the availability of address
*/
public static void hasAddress(String addressType,String account){
    List<cscrm__Account_Address_Relationship__c> accAddressRelationship = [SELECT Id, cscrm__Account__c, cscrm__Address_Type__c FROM cscrm__Account_Address_Relationship__c where cscrm__Active__c = true and cscrm__Account__c = :account and cscrm__Address_Type__c = :addressType];
    if(accAddressRelationship !=NULL && !accAddressRelationship.isEmpty())
     accAddressRelationship[0].cscrm__Active__c = false;
update accAddressRelationship;

}

/*
EDGE: 83916
Host: Aishwarya Yeware
Description: Common upsert utility for AccountAddressRelationship
*/
public static String addressRelSaveUtility (cscrm__Account_Address_Relationship__c accountAddress){
    try{
        Schema.SObjectField accountAddressRelationship = cscrm__Account_Address_Relationship__c.Fields.AccountAddressRelationship__c;
        Database.UpsertResult upsertResult= Database.upsert(accountAddress,accountAddressRelationship,false);
        if (!upsertResult.isSuccess()){
            return 'Failed';
        }else{
            return 'Success';
        }
    }
    catch(Exception e){
        Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
        Logger.exitLogger();
        return 'Failed';
    }
}

/*************************************************************
EDGE: 67176
Author: Ila Anmol Verma
Description: Util method to return map of  fields from fieldset
****************************************************************/
public static Map<String, String> getFieldMetaData() {

Map<String,String> finalMap = new Map<String, String>();

List<Schema.FieldSetMember> accFieldList= SObjectType.Account.FieldSets.NotifyUpdateCustomer.getFields();

system.debug('accFieldList+' +accFieldList);

for(Schema.FieldSetMember fld :accFieldList){
finalMap.put(fld.getFieldPath(), fld.getLabel());
}

system.debug('finalMap+' +finalMap);
return finalMap;
}


}