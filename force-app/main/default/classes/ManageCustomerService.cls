/* Date: 17-May-17 : Methods in the class have been commented by Nirvana Team to resolve merge issues for Edge R2a Sprint 17.0.1 TCM Integration functionality */ 
public class ManageCustomerService {
    
	public static final String EVENT_ACTION_CREATE = 'Create';
    public static final String EVENT_ACTION_UPDATE = 'Update';
    public static final String EVENT_ACTION_CROSSREF = 'CrossRef';

	/*
    public static void sendManageCustomer(String handlerName, List<String> accountIds, String event, String identifier) {  
                
        Account a = getAccount(accountIds.get(0));
        String req = generateManageCustomerRequest(a, event);

        callout(handlerName, accountIds, req);
    }*/
    
	/*
    public static void sendManageCustomerCrossRef(String handlerName, List<String> accountIds, String event, String identifier) {  
                
        Account a = getAccount(accountIds.get(0));
        String req = generateManageCustomerCrossRefRequest(a, event);

        IntegrationSettings__c is = IntegrationSettings__c.getOrgDefaults();
        String token = '';
        if(is.EnableMocks__c != true){
            token = TCMSearchManager.getTCMToken();
        }*/
        
        // Prepare Request
		
		/*
        HttpRequest request = new HttpRequest();
        
        if(is.EnableMocks__c == true){
            request.setEndpoint(EnvironmentVariable.get('MockEndpoint'));    
        }
        else {
            String ep = EnvironmentVariable.get('tcm_customerEndpoint');
            if(event != EVENT_ACTION_CREATE && identifier != null && identifier != '') {
                ep = ep + '/'+identifier;
            }
            request.setEndpoint(ep);
        }
        
        if(event == EVENT_ACTION_CREATE){
            request.setMethod('POST');    
        } else {
            request.setMethod('PUT');
        }
        
        request.setBody(req);
        request.setTimeout(30000);
        */
        
        // Send Request
		/*
        Http httpClient = new Http();
        HttpResponse resp = httpClient.send(request);
        System.debug('!@#$% ManageCustomer Response : ' + resp);
    }
    

    private static String generateManageCustomerRequest(Account a, String event) {
        
        System.debug('!@#$% Generating ManageCustomer request for ' + event + ' event');
        
        Contact cont = getContact(a.Id);
        List<cscrm__Address__c> addresses = getAddresses(a.Id);
        
        ManageCustomerRequest mcr = new ManageCustomerRequest();

        TCMDataObject.Customer dataItem = new TCMDataObject.Customer();
        DateTime dt = System.Datetime.now();
		*/
        //dataItem.sendDateTime = String.valueOf(dt)+'.'+dt.millisecond();
        //dataItem.cac = a.Customer_ID__c; 
        //dataItem.eventAction = event;
        //dataItem.businessUnit = a.Business_Unit__c; 
        //dataItem.customerManagedFlag = ConversionUtils.booleanToString(a.Managed__c); 
        //dataItem.customerType = a.Type; 
        //dataItem.languagePreference = a.Language_Preference__c; 
        //dataItem.marketSegment = a.Market_Segment__c; 
        //dataItem.accountStatus = a.Customer_Status__c;
        //dataItem.servicingOrgUnit = a.SOU__c; 
        
        /*
        dataItem.cidn = stripNulls(a.CIDN__c);
        dataItem.parentCidn = stripNulls(a.Parent_CIDN__c);
        dataItem.premiumService = ConversionUtils.booleanToString(a.Premium_Service__c);
        dataItem.abnOverride = stripNulls(a.ABN_Overide__c);
        dataItem.rootCidn = '';
        dataItem.ownershipCode = '';
        dataItem.priorityAssist = '';
        dataItem.lastModifiedDate = '';
        dataItem.location = '';
        dataItem.churnpropensity = '';
        dataItem.customerSince = '';
        dataItem.description = '';
        dataItem.franchiseArrange = ''; 
        dataItem.retiredUId = '';
        dataItem.retirementReason = '';
        dataItem.timeZone = '';
        dataItem.writtenaAuthorityRequiredFlag = '';
        dataItem.effectiveRetiredDate = '';
        dataItem.lastVerifiedDate = '';
        dataItem.createdDate = '';
		*/
        //dataItem.duplicateOverrideReason = '';
		/*
        dataItem.revenueOrganisationUnit = '';
        dataItem.potentialRevenue = '';
        dataItem.currentRevenue = '';
        dataItem.partners = '';    
        dataItem.approveDeclineReason = '';
        dataItem.recommendedPaymentMethod = '';
        dataItem.recommendedBillingFrequency = '';
        dataItem.validationCustomerConsent = '';
        dataItem.validationConsentRequestDate = '';
        dataItem.customerEffectiveStartDate = '';
        dataItem.relationshipType = '';
        dataItem.reportingPointIndicator = '';
        dataItem.customerEffectiveEndDate = '';
        dataItem.ansicCode = '';
        dataItem.primaryIndustryIndicator = '';
		*/
        // Category
		/*
        TCMDataObject.Category categoryItem = new TCMDataObject.Category();
        categoryItem.online = '';
        categoryItem.bpProtect = '';
        categoryItem.protect = '';

        dataItem.category = categoryItem;
		*/
        // Credit Situation
		/*
        TCMDataObject.CreditSituation creditSituationItem = new TCMDataObject.CreditSituation();
        creditSituationItem.creditLimit = '';
        creditSituationItem.creditManagementStatus = '';
        creditSituationItem.creditRating = '';

        dataItem.creditSituation = creditSituationItem;
		*/

        // Concession
		/*
        TCMDataObject.Concession concessionItem = new TCMDataObject.Concession();
        concessionItem.concessionAuthority = '';
        concessionItem.concessionNumber = '';
        concessionItem.concessionType = '';
        concessionItem.paymentType = '';
        concessionItem.paymentStatus = '';
        concessionItem.validConcessionFlag = '';
        concessionItem.lastValidatedDate = '';
        concessionItem.bypassConcessionValidation = '';
        concessionItem.validationResultOverride = '';

        dataItem.concession = concessionItem;
		*/
        
        // Customer Account - ##INTERFACE MANDATORY##
		/*
        TCMDataObject.CustomerAccount customerAccountItem = new TCMDataObject.CustomerAccount();
        if(cont != null){
            customerAccountItem.title = stripNulls(cont.Salutation);
            customerAccountItem.firstName = stripNulls(cont.FirstName);
            customerAccountItem.lastName = stripNulls(cont.LastName); //INTERFACE MANDATORY
            customerAccountItem.birthDate = '';
            if(cont.Birthdate != null){
                customerAccountItem.birthDate = String.valueOf(cont.Birthdate);     
            }
            customerAccountItem.phoneNumber = stripNulls(cont.Phone);
        }
        
        customerAccountItem.emailAddress = stripNulls(a.Email__c);
        customerAccountItem.abn = a.ABN__c;
        customerAccountItem.faxNumber = '';
        customerAccountItem.acn = a.ACN__c;
        customerAccountItem.webAddress = stripNulls(a.Website);
        customerAccountItem.driverLicenseNumber = '';
        customerAccountItem.driverLicenseState = '';
        customerAccountItem.fraudFlag = '';
        customerAccountItem.vipFlag = '';
        customerAccountItem.accountUuid = '';
        customerAccountItem.preferredMethod = a.Pref_Comm_Method__c; //INTERFACE MANDATORY
        customerAccountItem.dataSovereignty = a.Data_Sovereign_Status__c;

        dataItem.customerAccount = customerAccountItem;
        
        
        dataItem.address = new List<TCMDataObject.Address>();
		*/
        // Address - ##INTERFACE MANDATORY##
		/*
        if(addresses != null) {
            for(cscrm__Address__c address : addresses){
                TCMDataObject.Address addressItem = new TCMDataObject.Address();
                addressItem.isPrimary = 'Y'; 
                addressItem.addressId = address.cscrm__External_ID__c; 
                addressItem.country = 'AUSTRALIA'; 
				*/
                //addressItem.status = 'CO';
                //addressItem.statusCode = 'CONFIRMED';
                //addressItem.addressType = 'LEVEL';
                //addressItem.addressTypeCode = 'LEVEL';
				/*
                addressItem.state = address.cscrm__State_Province__c;
                addressItem.postalCode = address.cscrm__Zip_Postal_Code__c;
                addressItem.streetName = address.cscrm__Street_Name__c;
                addressItem.streetType = address.cscrm__Street_Type__c;
                addressItem.streetTypeCode = '';
                addressItem.streetTypeSuffix = '';
                addressItem.streetTypeSuffixCode = '';
                addressItem.streetNumberStart = address.cscrm__Street_Number_Start__c;
                addressItem.streetNumberStartSuffix = '';
                addressItem.streetNumberEnd = '';
                addressItem.streetNumberEndSuffix = '';
                addressItem.internationalPostcode = '';
                addressItem.internationalState = '';
                addressItem.deliveryPointId = '';
                addressItem.registeredPlan = '';
                addressItem.locality = address.Locality__c;
                addressItem.additionalInfo = '';
                addressItem.geographicalLocationCode = '';
				*/
                // SubAddress
				/*
                addressItem.subAddress = new TCMDataObject.SubAddress();
                addressItem.subAddress.buildingName = '';
                addressItem.subAddress.propertyName = '';
                addressItem.subAddress.numberStart = '';
                addressItem.subAddress.numberEnd = '';
                addressItem.subAddress.privateStreetName = '';
                addressItem.subAddress.privateStreetType = '';
                addressItem.subAddress.privateStreetTypeCode = '';
				*/
                // Details
				/*
                TCMDataObject.Detail detailItem = new TCMDataObject.Detail();
                detailItem.detailType = '';
                detailItem.detailTypeCode = '';
                detailItem.value = '';
                addressItem.subAddress.details = new List<TCMDataObject.Detail>();
                addressItem.subAddress.details.add(detailItem);
                
                if(address.Address_Line_1__c != null){
                    addressItem.subAddress.addressLines = new List<String>();
                    addressItem.subAddress.addressLines.add(address.Address_Line_1__c);      
                }
                
                dataItem.address.add(addressItem);
            }    
        }*/
        
        

        // Account Trading
		/*
        TCMDataObject.AccountTrading atItem = new TCMDataObject.AccountTrading();
        atItem.isPrimary = ''; 
        atItem.startDate = '';
        atItem.endDate = '';
        atItem.tradingName = '';

        dataItem.accountTrading = new List<TCMDataObject.AccountTrading>();
        dataItem.accountTrading.add(atItem);
        

        mcr.data = dataItem;       
        return System.JSON.serializePretty(mcr, true);
    }
    
    private static String generateManageCustomerCrossRefRequest(Account a, String event) {

        System.debug('!@#$% Generating ManageCustomer request for ' + event + ' event');
        
        Contact cont = getContact(a.Id);
        List<cscrm__Address__c> addresses = getAddresses(a.Id);
        
        ManageCustomerRequest mcr = new ManageCustomerRequest();

        TCMDataObject.Customer dataItem = new TCMDataObject.Customer();
        DateTime dt = System.Datetime.now();
        dataItem.sendDateTime = String.valueOf(dt)+'.'+dt.millisecond();
        dataItem.cac = a.Customer_ID__c;
        dataItem.eventAction = event;
		*/

        // Customer Account
		/*
        TCMDataObject.CustomerAccount customerAccountItem = new TCMDataObject.CustomerAccount();
        customerAccountItem.accountUuid = a.Account_UUID__c;
        dataItem.customerAccount = customerAccountItem;
		*/
        // Address
		/*
        if(addresses != null){
            dataItem.address = new List<TCMDataObject.Address>();
            for(cscrm__Address__c addr : addresses) {
                TCMDataObject.Address addressItem = new TCMDataObject.Address();
                addressItem.addressId = addr.cscrm__External_ID__c; 
                dataItem.address.add(addressItem);
            }    
        }
          
        mcr.data = dataItem;       
        return System.JSON.serializePretty(mcr, true);
    }

    private static Account getAccount(String accountId){
        Account result = [SELECT ABN_Overide__c,ABN__c,AccountNumber,AccountSource,Account_UUID__c,ACN__c,Actual_Retired_Date__c,AnnualRevenue,BillingAddress,BillingCity,BillingCountry,BillingGeocodeAccuracy,BillingLatitude,BillingLongitude,BillingPostalCode,BillingState,BillingStreet,Business_Unit__c,CreatedById,CreatedDate,cscfga__Active__c,cscfga__SLAExpirationDate__c,cscfga__SLASerialNumber__c,csconta__Billing_Cycle__c,cscrm__External_ID__c,cspmb__Discount_Level__c,CIDN__c,Customer_Effective_Start_Date__c,Customer_ID__c,Customer_Status__c,Data_Sovereign_Status__c,Date_of_Application__c,Date_Started_Trading_with_Telstra__c,Description,Email__c,End_Date__c,Fax,GB2B_Customer_Status__c,Geographical_Location_Code__c,Geographical_Location_Code__Latitude__s,Geographical_Location_Code__Longitude__s,Id,Imported__c,Industry,Internal_CAC__c,IsCustomerPortal,IsDeleted,Jigsaw,JigsawCompanyId,Language_Preference__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Managed__c,Market_Segment__c,MasterRecordId,Name,NumberOfEmployees,OwnerId,Ownership,Legacy_Ownership_Code__c,ParentId,Parent_CIDN__c,Phone,PhotoUrl,Portfolio_Code__c,Pref_Comm_Method__c,Premium_Service__c,Primary_Portfolio_Indicator__c,Primary__c,Protect__c,Rating,Send_Create_Event__c,ShippingAddress,ShippingCity,ShippingCountry,ShippingGeocodeAccuracy,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStreet,Sic,SicDesc,Site,SOU__c,Start_Date__c,SystemModstamp,TCM_MasterID__c,TickerSymbol,Trading_As_Names__c,Type,Ultimate_Parent_CIDN__c,Website FROM Account WHERE Id = :accountId];
        return result;
    }

    private static Contact getContact(Id accountId) {
        Contact c = null;
        List<Contact> contacts = [SELECT c.Id, c.Salutation, c.FirstName, c.LastName, c.Birthdate, c.Phone FROM Contact c WHERE c.AccountId = :accountId LIMIT 1];
        if(!contacts.isEmpty()){
            c = contacts[0];
        }
        
        return c;
    }

    private static List<cscrm__Address__c> getAddresses(Id accountId) {
        List<cscrm__Address__c> addrs = [SELECT cscrm__Account__c,Address_Line_1__c,Locality__c,cscrm__Address_Details__c,cscrm__Address_Type__c,cscrm__Building_Name__c,cscrm__Building_Number__c,cscrm__Building_Type__c,cscrm__City__c,cscrm__Country__c,cscrm__External_Address_Id__c,cscrm__External_ID__c,cscrm__Geolocation__c,cscrm__Geolocation__Latitude__s,cscrm__Geolocation__Longitude__s,cscrm__Is_Billing_Address__c,cscrm__Is_Installation_Address__c,cscrm__Is_Registered_Office_Address__c,cscrm__Is_Shipping_Address__c,cscrm__Level_Number__c,cscrm__Level_Type__c,cscrm__Plan_Number__c,cscrm__Property_Name__c,cscrm__State_Province__c,cscrm__Street_Name__c,cscrm__Street_Number_End__c,cscrm__Street_Number_Start__c,cscrm__Street_Type__c,cscrm__Street__c,cscrm__Unit_Number__c,cscrm__Unit_Type__c,cscrm__Zip_Postal_Code__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Name,OwnerId,SystemModstamp FROM cscrm__Address__c WHERE cscrm__Account__c = :accountId];
        if(!addrs.isEmpty()){
            return addrs;
        }
        return null;
    }
    
    private static String stripNulls(String input){
        if(input == null || input == ''){
            return '';
        }
        else {
            return input;
        }
    }
	
    @Future(callout=true)
    private static void callout(String handlerName, List<String> params, String jsonString) {
    	String token = TCMApiHelper.getTCMToken();
    	System.debug('Token: ' + token);
    	
    	Map<String, String> headerMap = new Map<String, String>();
    	headerMap.put('Content-Type', 'application/json');
    	headerMap.put('Authorization', 'Bearer ' + token);
        
    	IntegrationRecordHandlerUtil.callout(jsonString, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName, params);
    }
	*/
}