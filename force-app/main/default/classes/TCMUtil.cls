public with sharing class TCMUtil 
{
   
    public static Boolean isCustomerSoleTrader(TCMDataObject.Customer cust){
        return cust.customerType =='Sole Trader' ? true : false;
    }
    
    /********************************************************************** 
        
        MAP DATA METHODS  -- START 

    ***********************************************************************/
    
    public static TCMDataObject.Contact mapContactToRequestWithRelation(Contact c, String event, String contactType, String contactUsage){
        
        if(c != null && event != null && event != ''){
            TCMDataObject.Contact data = new TCMDataObject.Contact();
            
            data.id = c.UUID__c;
            data.title = c.Title;
            data.firstName = c.FirstName; // INTERFACE MANDATORY
            data.middleName = c.MiddleName;
            data.lastName = c.LastName; // INTERFACE MANDATORY
            data.birthDate = '';
            if(c.Birthdate != null){
                data.birthDate = String.valueOf(c.Birthdate);     
            }
            data.status = c.Contact_Status__c; // INTERFACE MANDATORY
            //data.onlineFlag = '';
            data.preferredMethod = c.Pref_Comm_Method__c;
            data.eventAction = event; // INTERFACE MANDATORY
            DateTime dt = System.Datetime.now();
            data.sendDateTime = String.valueOf(dt)+'.'+dt.millisecond(); // INTERFACE MANDATORY
            String contactId = c.Id;
            contactId = contactId.substring(3);
            data.contactId = contactId; // INTERFACE MANDATORY

            /*
            data.lastVerifiedDate = '';
            data.notes = '';
            data.numberInHousehold = '';
            data.occupation = '';
            data.timeZone = '';
            data.reviewedFlag = '';
            data.languagePreference = '';
            data.lastUpdated = '';
            */

            data.customerAccounts = new List<TCMDataObject.CustomerAccounts>();
            System.debug('TTTTT1' + c.AccountId);
            System.debug('TTTTT2' + c);
            List<AccountContactRelation> acrs = getAccountsByContId(c.Id); 
            for(AccountContactRelation acr : acrs){
                TCMDataObject.CustomerAccounts CustomerAccobj = new TCMDataObject.CustomerAccounts();
                if(acr.Account.Account_UUID__c != null)
                    CustomerAccobj.accountUuid = acr.Account.Account_UUID__c;
                else
                    CustomerAccobj.accountUuid = '';
                CustomerAccobj.customerCode = '';
                //CustomerAccobj.emailOptIn = '';
                //CustomerAccobj.phoneOptIn = '';
                
                CustomerAccobj.contactRelationship = new TCMDataObject.ContactRelationship();
                //CustomerAccobj.contactRelationship.endDate = acr.EndDate;
                CustomerAccobj.contactRelationship.contactType = String.isNotBlank(acr.Contact_Type__c) ? acr.Contact_Type__c : null; // INTERFACE MANDATORY
                CustomerAccobj.contactRelationship.contactUsage = String.isNotBlank(acr.Contact_Usage__c) ? acr.Contact_Usage__c : null; // INTERFACE MANDATORY
                data.customerAccounts.add(CustomerAccobj);
            }
            
            System.debug('TTTTT5' + data);
            return data;
        }
        else
            return null;
    }
    
    public static TCMDataObject.Customer mapCustomerToRequest(Account a, String event, Boolean crossRefReq){
        TCMDataObject.Customer dataItem = new TCMDataObject.Customer();
        if(crossRefReq == false){
            if(a != null && event != null && event != ''){
                //Contact cont = getContact(a.Id);
                
                DateTime dt = System.Datetime.now();
                dataItem.sendDateTime = String.valueOf(dt)+'.'+dt.millisecond(); // INTERFACE MANDATORY
                dataItem.cac = a.Customer_ID__c; //INTERFACE MANDATORY
                dataItem.eventAction = event; //INTERFACE MANDATORY
                dataItem.businessUnit = a.Business_Unit__c; //INTERFACE MANDATORY
                dataItem.customerManagedFlag = ConversionUtils.booleanToString(a.Managed__c); //INTERFACE MANDATORY
                dataItem.customerType = a.Type; //INTERFACE MANDATORY
                dataItem.languagePreference = a.Language_Preference__c; //INTERFACE MANDATORY
                dataItem.marketSegment = a.Market_Segment__c; //INTERFACE MANDATORY
                dataItem.accountStatus = a.Customer_Status__c; //INTERFACE MANDATORY
                dataItem.servicingOrgUnit = a.SOU__c; //INTERFACE MANDATORY
                
                dataItem.cidn = stripNulls(a.CIDN__c);
                dataItem.parentCidn = stripNulls(a.Parent_CIDN__c);
                dataItem.premiumService = ConversionUtils.booleanToString(a.Premium_Service__c);
                dataItem.abnOverride = stripNulls(a.ABN_Overide__c);
                
                // Category
                TCMDataObject.Category categoryItem = new TCMDataObject.Category();
                categoryItem.online = '';
                categoryItem.bpProtect = '';
                categoryItem.protect = ConversionUtils.booleanToString(a.Protect__c);
                dataItem.category = categoryItem;
                
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
                TCMDataObject.CustomerAccount customerAccountItem = new TCMDataObject.CustomerAccount();
                customerAccountItem.lastName = stripNulls(a.Name); //INTERFACE MANDATORY
                /*
                if(cont != null){
                    customerAccountItem.title = stripNulls(cont.Salutation);
                    customerAccountItem.firstName = stripNulls(cont.FirstName);
                    customerAccountItem.birthDate = '';
                    if(cont.Birthdate != null){
                        customerAccountItem.birthDate = String.valueOf(cont.Birthdate);     
                    }
                    customerAccountItem.phoneNumber = stripNulls(cont.Phone);
                }
                */
                
                customerAccountItem.emailAddress = stripNulls(a.Email__c);
                customerAccountItem.abn = a.ABN__c;
                customerAccountItem.faxNumber = a.Fax;
                customerAccountItem.acn = a.ACN__c;
                customerAccountItem.webAddress = stripNulls(a.Website);
                customerAccountItem.preferredMethod = a.Pref_Comm_Method__c; //INTERFACE MANDATORY
                customerAccountItem.dataSovereignty = a.Data_Sovereign_Status__c;
                /*
                customerAccountItem.driverLicenseNumber = '';
                customerAccountItem.driverLicenseState = '';
                customerAccountItem.fraudFlag = '';
                customerAccountItem.vipFlag = '';
                */
                customerAccountItem.accountUuid = a.Account_UUID__c;
                
                dataItem.customerAccount = customerAccountItem;
                
                dataItem.address = new List<TCMDataObject.Address>();
                List<cscrm__Account_Address_Relationship__c> aars = getAddressesByAcctId(a.Id);
                for(cscrm__Account_Address_Relationship__c aar : aars){
                    TCMDataObject.Address addressItem = new TCMDataObject.Address();
                    
                    if(aar.cscrm__Address_Type__c != null) {
                        if(aar.cscrm__Address_Type__c.equals(Constants.ADDRESS_TYPE_PRIMARY))
                            addressItem.isPrimary = 'Y'; //INTERFACE MANDATORY
                        else
                            addressItem.isPrimary = 'N'; //INTERFACE MANDATORY    
                    }
                    
                    addressItem.addressId = aar.cscrm__Address__r.Address_ID__c; //INTERFACE MANDATORY
                    addressItem.country = aar.cscrm__Address__r.cscrm__Country__c; //INTERFACE MANDATORY
                    //addressItem.status = 'CO';
                    //addressItem.statusCode = 'CONFIRMED';
                    addressItem.addressType = aar.cscrm__Address_Type__c;
                    //addressItem.addressTypeCode = 'LEVEL';
                    addressItem.state = aar.cscrm__Address__r.cscrm__State_Province__c;
                    addressItem.postalCode = aar.cscrm__Address__r.cscrm__Zip_Postal_Code__c;
                    addressItem.streetName = aar.cscrm__Address__r.cscrm__Street_Name__c;
                    
                    addressItem.streetType = aar.cscrm__Address__r.cscrm__Street_Type__c;
                    addressItem.streetTypeCode = '';
                    addressItem.streetTypeSuffix = '';
                    addressItem.streetTypeSuffixCode = '';
                    addressItem.streetNumberStart = aar.cscrm__Address__r.cscrm__Street_Number_Start__c;
                    addressItem.streetNumberStartSuffix = '';
                    addressItem.streetNumberEnd = aar.cscrm__Address__r.cscrm__Street_Number_End__c;
                    addressItem.streetNumberEndSuffix = '';
                    addressItem.internationalPostcode = '';
                    addressItem.internationalState = '';
                    addressItem.deliveryPointId = '';
                    addressItem.registeredPlan = '';
                    addressItem.locality = aar.cscrm__Address__r.Locality__c;
                    addressItem.additionalInfo = '';
                    addressItem.geographicalLocationCode = '';
                    // SubAddress
                    addressItem.subAddress = new TCMDataObject.SubAddress();
                    
                    addressItem.subAddress.buildingName = '';
                    addressItem.subAddress.propertyName = '';
                    addressItem.subAddress.numberStart = '';
                    addressItem.subAddress.numberEnd = '';
                    addressItem.subAddress.privateStreetName = '';
                    addressItem.subAddress.privateStreetType = '';
                    addressItem.subAddress.privateStreetTypeCode = '';
                    // Details
                    /*
                    TCMDataObject.Detail detailItem = new TCMDataObject.Detail();
                    
                    detailItem.detailType = '';
                    detailItem.detailTypeCode = '';
                    detailItem.value = '';
                    addressItem.subAddress.details = new List<TCMDataObject.Detail>();
                            
                    addressItem.subAddress.details.add(detailItem);
                    */
                            
                    if(aar.cscrm__Address__r.Address_Line_1__c != null) {
                        addressItem.subAddress.addressLines = new List<String>();
                        addressItem.subAddress.addressLines.add(aar.cscrm__Address__r.Address_Line_1__c);      
                    }
                    if(aar.cscrm__Address__r.Address_Line_2__c != null) {
                        addressItem.subAddress.addressLines.add(aar.cscrm__Address__r.Address_Line_2__c);
                    }
                    if(aar.cscrm__Address__r.Address_Line_3__c != null) {
                        addressItem.subAddress.addressLines.add(aar.cscrm__Address__r.Address_Line_3__c);
                    }
                    dataItem.address.add(addressItem);
                    
                }                
                
                                
                // Account Trading
                TCMDataObject.AccountTrading atItem = new TCMDataObject.AccountTrading();
                
                atItem.isPrimary = a.Primary__c == true ? 'Y' : 'N'; //INTERFACE MANDATORY
                atItem.startDate = '';
                atItem.endDate = '';
                atItem.tradingName = '';
                
                dataItem.accountTrading = new List<TCMDataObject.AccountTrading>();
                dataItem.accountTrading.add(atItem);
            }
            return dataItem;
        }
        else if(crossRefReq == true){
            if(a != null && event != null && event != ''){
                Contact cont = getContact(a.Id);
                
                DateTime dt = System.Datetime.now();
                dataItem.sendDateTime = String.valueOf(dt)+'.'+dt.millisecond();
                dataItem.cac = a.Customer_ID__c;
                dataItem.eventAction = event;
                
                // Customer Account
                TCMDataObject.CustomerAccount customerAccountItem = new TCMDataObject.CustomerAccount();
                customerAccountItem.accountUuid = a.Account_UUID__c;
                dataItem.customerAccount = customerAccountItem;
                
                // Address
                dataItem.address = new List<TCMDataObject.Address>();
                List<cscrm__Account_Address_Relationship__c> aars = getAddressesByAcctId(a.Id);
                    
                for(cscrm__Account_Address_Relationship__c aar : aars){
                    TCMDataObject.Address addressItem = new TCMDataObject.Address();
                    addressItem.addressId = aar.cscrm__Address__r.Address_ID__c; 
                    dataItem.address.add(addressItem);
                }
            }
            return dataItem;
        }
        else
            return null;
    }
    
    public static Account mapCustomerDataToAccount(TCMDataObject.Customer customerData, Account a) {
        if(a == null){
            a = new Account();
        }
        a.Name = customerData.customerAccount.lastName;
        a.ABN_Overide__c = customerData.abnOverride;
        a.ABN__c = customerData.customerAccount.abn;
        a.AccountSource = customerData.parentSourceSystem;
        a.ACN__c = customerData.customerAccount.acn;
        if(!String.isBlank(customerData.masterID)) {
            a.TCM_MasterID__c =customerData.masterID;    
        }
        a.Account_UUID__c = customerData.customerAccount.accountUuid;
        //a.Business_Unit__c = customerData.businessUnit;
        a.Market_Segment__c = customerData.marketSegment;
        a.SOU__c = customerData.servicingOrgUnit;
        a.Pref_Comm_Method__c = customerData.customerAccount.preferredMethod;
        a.CIDN__c = customerData.cidn;
        a.Customer_ID__c = customerData.cac;
        a.Customer_Status__c = customerData.accountStatus;
        a.Description = customerData.description;
        a.Email__c = customerData.customerAccount.emailAddress;
        a.Fax = customerData.customerAccount.faxNumber;
        a.GB2B_Customer_Status__c = customerData.accountStatus;
        a.Industry = customerData.primaryIndustryIndicator;
        a.Language_Preference__c = customerData.languagePreference;
        a.Name = customerData.customerAccount.lastName;
        a.Parent_CIDN__c = customerData.parentCidn;
        if(customerData.customerManagedFlag != null && customerData.customerManagedFlag != ''){
            if(customerData.customerManagedFlag == 'Y'){
                a.Managed__c = true;
            } else {
                a.Managed__c = false;
            }
        }
        a.Send_Create_Event__c = false;
        
        if(customerData.accountTrading != null){
            a.Trading_As_Names__c = customerData.accountTrading[0].tradingName;    
        }
        
        a.Type = customerData.customerType;
        a.Ultimate_Parent_CIDN__c = customerData.parentCidn;
        a.Website = customerData.customerAccount.webAddress;
        
        return a;
    }
    
    public static Contact mapContactDataToContact(TCMDataObject.Contact contactData, Contact c) {
        if(c == null){
            c = new Contact();
        }
        
        c.UUID__c = contactData.id;
        c.Salutation = contactData.title;
        c.firstName = contactData.firstName;
        c.MiddleName = contactData.middleName;
        c.lastName = contactData.lastName;
        if(contactData.birthDate != null && contactData.birthDate != '') {
            c.Birthdate = System.Date.valueOf(contactData.birthDate);    
        }
        
        if(contactData.homeContact != null){
            c.Home_Email__c = contactData.homeContact.emailAddress;
            c.HomePhone__c = contactData.homeContact.phoneNumber;
            c.Home_Fax__c = contactData.homeContact.faxNumber;  
        }
        if(contactData.workContact != null){
            c.Email = contactData.workContact.emailAddress;
            c.MobilePhone = contactData.workContact.mobileNumber;
            c.Phone = contactData.workContact.phoneNumber;
            c.Fax = contactData.workContact.faxNumber;   
        }
        
        c.Pref_Comm_Method__c = contactData.preferredMethod;
        
        if(contactData.identification != null && contactData.identification.driverLicense != null){
            c.Driver_License_Id__c = contactData.identification.driverLicense.driversLicenseNo;
            c.Driver_Licence_State__c = contactData.identification.driverLicense.state;    
        }
        
        c.Contact_Status__c = contactData.status;
        c.Title = contactData.jobTitle;
        c.Language_Preference__c = contactData.languagePreference;
        c.Send_Create_Event__c = false;
        
        if(contactData.customerAccounts != null && contactData.customerAccounts.size() > 0 ){
            System.debug('PP AccountID : '+contactData.customerAccounts[0].accountUUID);
            Account accountUUIdObj = getAccountByUUID(contactData.customerAccounts[0].accountUUID);
            if(accountUUIdObj != null)
            c.AccountId = accountUUIdObj.id;              
        }
        
        
        return c;
    }
    
    public static Contact mapContactDataToContact(TCMDataObject.Contact1 contactData, Contact c) {
        if(c == null){
            c = new Contact();
        }
        
        c.UUID__c = contactData.id;
        c.Salutation = contactData.title;
        c.firstName = contactData.firstName;
        c.MiddleName = contactData.middleName;
        c.lastName = contactData.lastName;
        if(contactData.birthDate != null && contactData.birthDate != '') {
            c.Birthdate = System.Date.valueOf(contactData.birthDate);    
        }
        
        if(contactData.homeContact != null){
            c.Home_Email__c = contactData.homeContact.emailAddress;
            c.HomePhone__c = contactData.homeContact.phoneNumber;
            c.Home_Fax__c = contactData.homeContact.faxNumber;  
        }
        if(contactData.workContact != null){
            c.Email = contactData.workContact.emailAddress;
            c.MobilePhone = contactData.workContact.mobileNumber;
            c.Phone = contactData.workContact.phoneNumber;
            c.Fax = contactData.workContact.faxNumber;   
        }
        
        c.Pref_Comm_Method__c = contactData.preferredMethod;
        
        if(contactData.identification != null && contactData.identification.driverLicense != null){
            c.Driver_License_Id__c = contactData.identification.driverLicense.driversLicenseNo;
            c.Driver_Licence_State__c = contactData.identification.driverLicense.state;    
        }
        
        c.Contact_Status__c = contactData.status;
        c.Title = contactData.jobTitle;
        c.Language_Preference__c = contactData.languagePreference;
        c.Send_Create_Event__c = false;
        
        //if(contactData.customerAccounts != null && contactData.customerAccounts.size() > 0 ){
            System.debug('PP AccountID : '+contactData.customerAccounts.accountUUID);
            if(contactData.customerAccounts.accountUUID != null) {
                Account accountUUIdObj = getAccountByUUID(contactData.customerAccounts.accountUUID);   
                if(accountUUIdObj != null)
                   c.AccountId = accountUUIdObj.id; 
            }
            
        //}
        
        
        return c;
    }
    
    public static cscrm__Address__c mapAddressDataToAddress(TCMDataObject.Address add, cscrm__Address__c address, Account a) {
        if(address == null){
            address = new cscrm__Address__c();    
        }
        
        //address.cscrm__Account__c = a!=null ? a.Id : null;
        address.Address_ID__c = add.addressId;
        address.cscrm__State_Province__c = add.state;
        address.cscrm__Zip_Postal_Code__c = add.postalCode;
        address.cscrm__Street_Name__c = add.streetName;
        address.cscrm__Street_Type__c = add.streetType;
        address.cscrm__Street_Number_Start__c = add.streetNumberStart;
        address.cscrm__Street_Number_End__c = add.streetNumberEnd;
        address.cscrm__Is_Billing_Address__c = true;
        address.Locality__c = add.locality;
        address.cscrm__Country__c = add.country;
        address.Name = address.cscrm__Street_Number_Start__c +' '+ address.cscrm__Street_Name__c +' '+ address.cscrm__Street_Type__c +' '+ address.cscrm__State_Province__c +' '+ address.cscrm__Zip_Postal_Code__c;
        
        if(add.subAddress != null){
            if(add.subAddress.addressLines != null){
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
        } 
        return address;
    }
    /********************************************************************** 
        
        MAP DATA METHODS  -- END 

    ***********************************************************************/
    

    /********************************************************************** 
        
        ACCOUNT RETERIVAL METHODS  -- START 

    ***********************************************************************/
    public static Account getAccountByAccountId(String accountId)
    {
        System.debug('!@#$% Querying for exisitng account with AccountId: ' + accountId);
        if(accountId != null && accountId != '')
        {
            String queryString = queryBuilder('Account');
            queryString = queryString + ' where Id = \'' + accountId + '\'';
            List<Account> accList = Database.Query(queryString);
            System.debug('!@#$% Query result : ' + accList);
            if(!accList.isEmpty()){
                return accList.get(0);
            }
        }
        return null;
    }

    public static Account getAccountByUUID(String accountUUID)
    {
        System.debug('!@#$% Querying for exisitng account with AccountId: ' + accountUUID);
        if(accountUUID != null && accountUUID != '')
        {
            String queryString = queryBuilder('Account');
            queryString = queryString + ' where Account_UUID__c = \'' + accountUUID + '\'';
            List<Account> accList = Database.Query(queryString);
            System.debug('!@#$% Query result : ' + accList);
            if(!accList.isEmpty()){
                return accList.get(0);
            }
        }
        return null;
    }

    public static Account getAccountByCustomerId(String cac)
    {
        System.debug('!@#$% Querying for exisitng account with AccountId: ' + cac);
        if(cac != null && cac != '')
        {
            String queryString = queryBuilder('Account');
            queryString = queryString + ' where Customer_ID__c = \'' + cac + '\'';
            List<Account> accList = Database.Query(queryString);
            System.debug('!@#$% Query result : ' + accList);
            if(!accList.isEmpty()){
                return accList.get(0);
            }
        }
        return null;
    }

     /********************************************************************** 
        
        ACCOUNT RETERIVAL METHODS  -- END 

    ***********************************************************************/   


     /********************************************************************** 
        
        CONTACT RETERIVAL METHODS  -- START 

    ***********************************************************************/
     
    public static Contact getContact(Id accountId) {
        if(String.isNotBlank(accountId)){
            String queryString = queryBuilder('AccountContactRelation');
            queryString = queryString + ' where AccountId = \'' + accountId + '\'';
            queryString = queryString +' and Roles INCLUDES (\'' + Constants.DEFAULT_CONTACT_ROLE + '\')';
            Contact c = null;
            List<AccountContactRelation> accContacts = Database.Query(queryString);
            Set<id> contIds = new Set<Id>();
            for(AccountContactRelation rel : accContacts){
                contIds.add(rel.ContactId);
            }

            if(contIds.size()>0){
                queryString = queryBuilder('Contact');
                queryString = queryString + ' where id IN :contIds';
                List<Contact> contacts = Database.Query(queryString);
                if(!contacts.isEmpty()){
                    c = contacts[0];
                }
            }
            return c;
        }
        else
            return null;
    }
        
    public static Contact getContactByUUId(String uuid) {
        System.debug('!@#$% Querying for Contact using Contact UUID : ' + uuid);
        if(uuid != null && uuid != ''){
            String queryString = queryBuilder('Contact');
            queryString = queryString + ' where UUID__c = \'' + uuid + '\'';
            List<Contact> contList = Database.Query(queryString);
            System.debug('!@#$% Query result : ' + contList);
            if(!contList.isEmpty()){
                return contList.get(0);
            }
        }
        
        return null;
    }
    
    public static Contact getContactBySalesforceContactId(String contactId) {
        System.debug('!@#$% Querying for Contact using Contact UUID : ' + contactId);
        if(contactId != null && contactId != ''){
            String queryString = queryBuilder('Contact');
            queryString = queryString + ' where Id = \'' + contactId + '\'';
            List<Contact> contList = Database.Query(queryString);
            System.debug('!@#$% Query result : ' + contList);
            if(!contList.isEmpty()){
                return contList.get(0);
            }           
        }

        return null;
    }    
    
    public static Map<String,Contact> getContactsByExternalIdList( List<String> ExternalIdList ) 
    {
        if( !ExternalIdList.IsEmpty())
        {
            Map<String,Contact> contactMap = new Map<String,Contact>();
            String queryString = queryBuilder('Contact');
            queryString = queryString + ' where UUID__c in: ExternalIdList';
            List<Contact> contactList = Database.Query(queryString);
            for(Contact c : contactList){
                contactMap.put(c.UUID__c, c);
            }
            return contactMap;
        }
        return null;
    }
    
    public static List<AccountContactRelation> getAccountsByContId(Id contactId) {
        if(String.isNotBlank(contactId)){
            String queryString = 'SELECT AccountId, ContactId, StartDate, IsActive, Contact_Type__c, Contact_Usage__c,Account.Account_UUID__c FROM AccountContactRelation';
            queryString = queryString + ' where ContactId = \'' + contactId + '\'';
            List<AccountContactRelation> accountContRelatn = Database.Query(queryString);
            return accountContRelatn;           
        }
        return null;
    }
    
    
     /********************************************************************** 
        
        CONTACT RETERIVAL METHODS  -- END 

    ***********************************************************************/    
    
    /********************************************************************** 
        
        ADDRESS RETERIVAL METHODS  -- START 

    ***********************************************************************/    
    public static cscrm__Address__c getAddressesByExternalId( String ExternalId ) 
    {
        if( String.isNotBlank(ExternalId))
        {
            List<String> AddExIDList = new List<String>();
            AddExIDList.add(ExternalId);
            Map<String, cscrm__Address__c> addressMap = new Map<String, cscrm__Address__c>();
            addressMap = getAddressesByExternalIdList(AddExIDList);       
            if(!addressMap.isEmpty())
            {
                return addressMap.values().get(0);
            }  
         }          
         return null;           
    }
    
    public static Map<String,cscrm__Address__c> getAddressesByExternalIdList( List<String> ExternalIdList ) 
    {
       if( !ExternalIdList.IsEmpty())
       {
            Map<String, cscrm__Address__c> addressMap = new Map<String, cscrm__Address__c>();
            String queryString = queryBuilder('cscrm__Address__c');
            queryString = queryString + ' where Address_ID__c in: ExternalIdList';
            List<cscrm__Address__c> AddressList = Database.Query(queryString);
            for(cscrm__Address__c addr : addressList) 
            {
                addressMap.put(addr.Address_ID__c , addr);// check external id field 
            }
            return addressMap;
       }
       return null;
    }
    
    public static List<cscrm__Account_Address_Relationship__c> getAddressesByAcctId(Id accountId) {
        if(String.isNotBlank(accountId)){
            String queryString = 'SELECT cscrm__Account__c, cscrm__Address__c, cscrm__Active__c, cscrm__Address_Type__c, cscrm__Address__r.Address_ID__c, cscrm__Address__r.cscrm__Country__c , cscrm__Address__r.cscrm__State_Province__c, cscrm__Address__r.cscrm__Zip_Postal_Code__c, cscrm__Address__r.cscrm__Street_Name__c, cscrm__Address__r.cscrm__Street_Type__c, cscrm__Address__r.cscrm__Street_Number_Start__c, cscrm__Address__r.cscrm__Street_Number_End__c, cscrm__Address__r.Locality__c, cscrm__Address__r.Address_Line_1__c, cscrm__Address__r.Address_Line_2__c, cscrm__Address__r.Address_Line_3__c FROM cscrm__Account_Address_Relationship__c';
            queryString = queryString + ' where cscrm__Account__c = \'' + accountId + '\'';
            List<cscrm__Account_Address_Relationship__c> accountAddRelatn = Database.Query(queryString);
            return accountAddRelatn;           
        }
        return null;
    }   

    /********************************************************************** 
        
        ADDRESS RETERIVAL METHODS  -- END 

    ***********************************************************************/ 

    // *******************Create AccountAddress RelationShip ******************//
    public static cscrm__Account_Address_Relationship__c createAccountAddressRelationship(String accountId, String addressId,String type) {
        cscrm__Account_Address_Relationship__c aar = new cscrm__Account_Address_Relationship__c();
        aar.cscrm__Account__c = accountId;
        aar.cscrm__Address__c = addressId;
        aar.cscrm__Active__c = true;
        aar.cscrm__Address_Type__c = type;
        aar.cscrm__Start_Date__c = System.today();  
        return aar;
    }
    
    // *******************Update AccountAddress RelationShip ******************//
    public static cscrm__Account_Address_Relationship__c updateAccountAddressRelationship(String relRecordId) {
        cscrm__Account_Address_Relationship__c aar = new cscrm__Account_Address_Relationship__c();
        aar.id=relRecordId;
        aar.cscrm__Active__c = false;
        return aar;
    }
    
    // *******************Create AccountContact RelationShip ******************//
    public static AccountContactRelation createAccountContactRelationship(String accountId, String contactId,String role,String usaage) {
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = accountId;
        acr.ContactId = contactId;
        acr.StartDate = System.today();
        acr.IsActive = true;
        acr.Contact_Type__c = role;
        acr.Contact_Usage__c = usaage;
        return acr;
    }    
    
    // *******************Update AccountContact RelationShip ******************//
    public static AccountContactRelation updateAccountContactRelationship(String relRecordId,String role,String usaage) {
        AccountContactRelation acr = new AccountContactRelation();
        acr.id=relRecordId;        
        acr.EndDate = System.today();
        acr.IsActive = false;
        acr.Contact_Type__c = role;
        acr.Contact_Usage__c = usaage;
        return acr;
    }
    
    // *******************Query Builder ******************//
    public static String queryBuilder(String sobjName){
        if(sobjName != null && sobjName != ''){
            String SobjectApiName = sobjName;
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            String commaSepratedFields = '';
            for(Schema.SObjectField val : fieldMap.values()){
                if(val.getDescribe().isAccessible()){                    
                    if(commaSepratedFields == null || commaSepratedFields == ''){
                        commaSepratedFields = val.getDescribe().getName();
                    }else{
                        commaSepratedFields = commaSepratedFields + ', ' + val.getDescribe().getName();
                    }
                }                
            }
            
            String query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName;
            return query;
        }        
        return null;
    }


    // **********RR: Check Address RelationShip Exists or not***********************//
    public static cscrm__Account_Address_Relationship__c checkAccountAddressRelationshipExist(String AddressId, String accountId, String Type)
    {
        if( String.isNotBlank(AddressId) && String.isNotBlank(accountId))
        {
            String queryString = queryBuilder('cscrm__Account_Address_Relationship__c');
            queryString = queryString + ' where cscrm__Account__c = \'' + accountId + '\'' + ' and cscrm__Address__c = \'' + AddressId + '\'';
            queryString = String.isNotBlank(Type) ? (queryString +' and cscrm__Address_Type__c = \'' + Type + '\'') : queryString;
            List<cscrm__Account_Address_Relationship__c> accountAddRelatn = Database.Query(queryString);
            if( accountAddRelatn != null && accountAddRelatn.size()>0)
            {
                return accountAddRelatn.get(0) ;
            }
            
        }
        return null;
    }

    // **********: Check Account Contact RelationShip Exists or not***********************//
    public static AccountContactRelation checkAccountContactRelationshipExist(String contactId, String accountId, String role)
    {
        if(String.isNotBlank(contactId) && String.isNotBlank(accountId))
        {
            String queryString = queryBuilder('AccountContactRelation');
            queryString = queryString + ' where AccountId = \'' + accountId + '\'' + ' and contactId = \'' + contactId + '\'';
            //queryString = String.isNotBlank(role) ? (queryString +' and Roles = \'' + role + '\'') : queryString;
            queryString = String.isNotBlank(role) ? (queryString +' and Contact_Type__c =:role') : queryString;
            List<AccountContactRelation> acrList = Database.Query(queryString);
            System.debug('Account Contact Relationship List : '+acrList);
            if( acrList != null && acrList.size()>0)
            {
                return acrList.get(0) ;
            }            
        }      
        return null;
    } 
    
    public static List<AccountContactRelation> checkAccountContactRelationshipExistList(String contactId, String accountId, String role)
    {
        if(String.isNotBlank(contactId) && String.isNotBlank(accountId))
        {
            String queryString = queryBuilder('AccountContactRelation');
            queryString = queryString + ' where AccountId = \'' + accountId + '\'' + ' and contactId = \'' + contactId + '\'';                    
            queryString = String.isNotBlank(role) ? (queryString +' and Contact_Type__c =:role') : queryString;
            List<AccountContactRelation> acrList = Database.Query(queryString);
            System.debug('Account Contact Relationship List : '+acrList);
            if( acrList != null && acrList.size()>0)
            {
                return acrList;
            }            
        }      
        return null;
    } 

    public static Map<Id,List<AccountContactRelation>> checkAccountContactRelationshipExist(List<String> contactIds, String accountId)
    {
        if(String.isNotBlank(accountId))
        {
            String queryString = queryBuilder('AccountContactRelation');
            queryString = queryString + ' where AccountId = \'' + accountId + '\'' + ' and contactId in :contactIds';                    
            //queryString = String.isNotBlank(role) ? (queryString +' and Contact_Type__c =:role') : queryString;
            List<AccountContactRelation> acrList = Database.Query(queryString);
            System.debug('checkAccountContactRelationshipExistList Account Contact Relationship List : '+acrList);
            if( acrList != null && acrList.size()>0)
            {
                Map<Id,List<AccountContactRelation>> retMap = new Map<Id,List<AccountContactRelation>>();
                
                for(AccountContactRelation rel : acrList){
                    List<AccountContactRelation> currLst;
                    if(retMap.get(rel.contactId)==null){
                        currLst = new List<AccountContactRelation>();
                    }else{
                        currLst = retMap.get(rel.contactId);
                    }
                    currLst.add(rel);
                    retMap.put(rel.contactId,currLst);
                }
                return retMap;                
            }            
        }      
        return null;
    }
    
    public static List<cscrm__Account_Address_Relationship__c> checkAccountAddressRelationshipExistList(String AddressId, String accountId, String Type)
    {
        if( String.isNotBlank(AddressId) && String.isNotBlank(accountId))
        {
            String queryString = queryBuilder('cscrm__Account_Address_Relationship__c');
            queryString = queryString + ' where cscrm__Account__c = \'' + accountId + '\'' + ' and cscrm__Address__c = \'' + AddressId + '\'';
            queryString = String.isNotBlank(Type) ? (queryString +' and cscrm__Address_Type__c = \'' + Type + '\'') : queryString;
            List<cscrm__Account_Address_Relationship__c> accountAddRelatn = Database.Query(queryString);
            if( accountAddRelatn != null && accountAddRelatn.size()>0)
            {
                return accountAddRelatn;
            }
            
        }
        return null;
    }
    
    public static Map<Id,List<cscrm__Account_Address_Relationship__c>> checkAccountAddressRelationshipExistList(List<String> AddressIds, String accountId)
    {
        if( String.isNotBlank(accountId))
        {
            String queryString = queryBuilder('cscrm__Account_Address_Relationship__c');
            queryString = queryString + ' where cscrm__Account__c = \'' + accountId + '\'' + ' and cscrm__Address__c in :AddressIds';
            //queryString = String.isNotBlank(Type) ? (queryString +' and cscrm__Address_Type__c = \'' + Type + '\'') : queryString;
            List<cscrm__Account_Address_Relationship__c> accountAddRelatn = Database.Query(queryString);
            Map<Id,List<cscrm__Account_Address_Relationship__c>> retMap = new 
                                                                Map<Id,List<cscrm__Account_Address_Relationship__c>>();
            if( accountAddRelatn != null && accountAddRelatn.size()>0)
            {
                for(cscrm__Account_Address_Relationship__c rel : accountAddRelatn){
                    List<cscrm__Account_Address_Relationship__c> currLst;
                    if(retMap.get(rel.cscrm__Address__c)==null){
                        currLst = new List<cscrm__Account_Address_Relationship__c>();
                    }else{
                        currLst = retMap.get(rel.cscrm__Address__c);
                    }
                    currLst.add(rel);
                    retMap.put(rel.cscrm__Address__c,currLst);
                }
                return retMap;
            }
            
        }
        return null;
    }
    
    public static List<cscrm__Account_Address_Relationship__c> checkAndCreateAccountAddressRelationships(List<TCMDataObject.Address> tcmAddresses,Id accountId){
        System.debug('!@#$% Method Entry -----> checkAndCreateAccountAddressRelationships');
        System.debug('!@#$% tcmAddresses : ' + tcmAddresses);
        System.debug('!@#$% accountId : ' + accountId);

        List<String> adborIds = new List<String>();
        for(TCMDataObject.Address add : tcmAddresses) {
            if(!String.isBlank(add.addressId))
                adborIds.add(add.addressId);
        }
        System.debug('!@#$% adborIds : ' + adborIds);

        Map<String,cscrm__Address__c> addressMap = TCMUtil.getAddressesByExternalIdList(adborIds); 
        System.debug('!@#$% addressMap : ' + addressMap);

        List<cscrm__Address__c> insertAddressList = new List<cscrm__Address__c>();
        List<cscrm__Account_Address_Relationship__c> accountAddressRelationships = new List<cscrm__Account_Address_Relationship__c>();
        
        for(TCMDataObject.Address add : tcmAddresses) {
            cscrm__Address__c address = addressMap.get(add.addressId);                    
            address = TCMUtil.mapAddressDataToAddress(add, address, null);
            insertAddressList.add(address); 
        }
        System.debug('!@#$% insertAddressList : ' + insertAddressList);

        if(!insertAddressList.IsEmpty()) {
            upsert insertAddressList Address_ID__c;
        }

        addressMap = TCMUtil.getAddressesByExternalIdList(adborIds);

        List<String> addrIds = new List<String>();
        for(TCMDataObject.Address add : tcmAddresses) {
            cscrm__Address__c addr = addressMap.get(add.addressId);                  
            addrIds.add(addr.Id);
        }
        System.debug('!@#$% addrIds : ' + addrIds);

        Map<Id,List<cscrm__Account_Address_Relationship__c>>  existingAccAddrRelations =
                                         TCMUtil.checkAccountAddressRelationshipExistList(addrIds, accountId);
        
        System.debug('!@#$% existingAccAddrRelations : ' + existingAccAddrRelations);
        for(TCMDataObject.Address add : tcmAddresses) {
            cscrm__Address__c addr = addressMap.get(add.addressId);
            List<cscrm__Account_Address_Relationship__c> currRels = new List<cscrm__Account_Address_Relationship__c>();   
            if(existingAccAddrRelations != null) {
                currRels = existingAccAddrRelations.get(addr.id); 
            }    
            System.debug('!@#$% currRels : ' + currRels);          

            Boolean hasExistingRel = false;
            
            if(currRels != null) {
                for(cscrm__Account_Address_Relationship__c currRel : currRels){
                    System.debug('!@#$% currRel.cscrm__Address_Type__c : ' + currRel.cscrm__Address_Type__c);  
                    System.debug('!@#$% add.addressType : ' + add.addressType);
                    if(currRel.cscrm__Address_Type__c == add.addressType){
                        hasExistingRel = true;
                        break;
                    }
                }
            }                
            
            if(!hasExistingRel) {
                accountAddressRelationships.add(TCMUtil.createAccountAddressRelationship(accountId, addr.Id,add.addressType));
            }
        }  

        System.debug('!@#$% accountAddressRelationships : ' + accountAddressRelationships);                    

        if(!accountAddressRelationships.IsEmpty()) {
            upsert accountAddressRelationships;
        }

        return accountAddressRelationships;
    }
    
    public static List<AccountContactRelation> checkAndCreateAccountContactRelationships(List<TCMDataObject.Contact1> tcmContacts, Id accountId) {
        List<String> uuidList = new List<String>();
        for(TCMDataObject.Contact1 contact : tcmContacts) {                                   
            if(!String.isBlank(contact.id))
                uuidList.add(contact.id);
        }
        System.debug('!@#$% uuidList : ' + uuidList);

        Map<String,Contact> contactMap = TCMUtil.getContactsByExternalIdList(uuidList);
        System.debug('!@#$% contactMap : ' + contactMap);

        List<Contact> contactRecsToUpsert = new List<Contact>();
        List<AccountContactRelation> acctContRecToUpsert = new List<AccountContactRelation>();

        for(TCMDataObject.Contact1 contact : tcmContacts) {
            Contact contactObj = contactMap.get(contact.Id);
            contactObj = TCMUtil.mapContactDataToContact(contact, contactObj);
            contactObj.AccountId = accountId;
            contactObj.Contact_Status__c = 'Active';
            contactRecsToUpsert.add(contactObj);
        }

        if(!contactRecsToUpsert.IsEmpty())
            upsert contactRecsToUpsert;

        contactMap = TCMUtil.getContactsByExternalIdList(uuidList);

        List<String> contactIds = new List<String>();
        for(TCMDataObject.Contact1 cont : tcmContacts) {
            Contact cnt = contactMap.get(cont.id);
            contactIds.add(cnt.Id);
        }
        System.debug('!@#$% Contact Ids : ' + contactIds);

        Map<Id, List<AccountContactRelation>> existingAccContRelations = TCMUtil.checkAccountContactRelationshipExist(contactIds, accountId);


        for(TCMDataObject.Contact1 contact : tcmContacts) {
            Contact cont = contactMap.get(contact.Id);
            List<AccountContactRelation> currRels = new List<AccountContactRelation>();
            if(existingAccContRelations != null) {
                currRels = existingAccContRelations.get(cont.Id);
            }
            System.debug('!@#$% currRels : ' + currRels);          

            Boolean hasExistingRel = false;

            System.debug('!@#$% Current Contact ID : ' + cont.Id);

            if(currRels != null) {
                for(AccountContactRelation currRel : currRels){
                    System.debug('!@#$% currRel.Contact_Type__c : ' + currRel.Contact_Type__c);  
                    System.debug('!@#$% contact.customerAccounts.contactRelationship.contactType : ' + contact.customerAccounts.contactRelationship.contactType);  
                    if(currRel.Contact_Type__c == contact.customerAccounts.contactRelationship.contactType){
                        hasExistingRel = true;
                        break;
                    }
                }
            }                
            
            if(!hasExistingRel) {
                System.debug('!@#$% Entering createAccountContactRelationship | ContactType : ' + contact.customerAccounts.contactRelationship.contactType + ' | contact.customerAccounts.contactRelationship.contacUsage : ' + contact.customerAccounts.contactRelationship.contactUsage);
                if(!existingAccContRelations.containsKey(cont.Id))
                    acctContRecToUpsert.add(TCMUtil.createAccountContactRelationship(accountId, cont.Id, contact.customerAccounts.contactRelationship.contactType, contact.customerAccounts.contactRelationship.contactUsage));
            }
        }
        
        System.debug('!@#$% acctContRecToUpsert : ' + acctContRecToUpsert);
        if(!acctContRecToUpsert.IsEmpty())
            upsert acctContRecToUpsert;

        return acctContRecToUpsert;
    }
    
    public static String stripNulls(String input){
        if(input == null || input == ''){
            return '';
        }
        else {
            return input;
        }
    }

    public static Exception__c mapRequestToException(TCMDataObject.Fault fault) {
        
        Exception__c e = new Exception__c();
        if(fault != null) {
            e.Fault_Code__c = fault.faultCode;
            e.Fault_String__c = fault.faultString;
            e.Fault_Actor__c = fault.faultActor;
            e.Server_Name__c = fault.serverName;
            e.Process_Id__c = fault.processId;
            e.Thread_Id__c = fault.threadId;
            e.Program_Name__c = fault.programName;
            e.Program_Location__c = fault.programLocation;
            e.Time_Stamp__c = fault.timestamp;
            e.Initiating_Entity_Id__c = fault.initiatingEntityId;
            e.Program_Status_Code__c = fault.programStatusCode;
            e.Program_Status_Description__c = fault.programStatusDescription;
            e.Program_Fault_Id__c = fault.programFaultId;
            e.Program_Fault_Description__c = fault.programFaultDescription;
            e.Fault_Category__c = fault.faultCategory;
            e.Entity_Name__c = fault.entityName;
            e.Entity_Value__c = fault.entityValue;
            e.Status__c = 'Unresolved';

            Account a = getAccountByCustomerId(fault.entityValue);
            if(a != null) {
                e.Account_with_Exception__c = a.Id;
            } else {
                Contact c = getContactBySalesforceContactId(fault.entityValue);
                if(c != null){
                    e.Contact_with_Exception__c = fault.entityValue;      
                }    
            }
            
            return e;       
        }   

        return null;

    }
    
    /*
    //DELETE LATER..... 
    
    public static List<Contact> getContactByUUIdList(String uuid) {
        System.debug('!@#$% Querying for Contact using Contact UUID : ' + uuid);
        if(uuid != null && uuid != ''){
            String queryString = queryBuilder('Contact');
            queryString = queryString + ' where UUID__c = \'' + uuid + '\'';
            List<Contact> contList = Database.Query(queryString);
            System.debug('!@#$% Query result : ' + contList);
            if(!contList.isEmpty()){
                return contList;
            }
        }
        
        return null;
    }
    
    public static Contact getContactWithoutUUId(String accId) {
        System.debug('!@#$% Querying for Contact without Contact UUID : ' + accId);
        List<Contact> contacts = new List<Contact>();
        if(String.isNotBlank(accId)){
            String queryString = queryBuilder('Contact');
            queryString = queryString + ' where AccountId = \'' + accId + '\' and UUID__c = \'\'';
            contacts = Database.Query(queryString);
            if(!contacts.isEmpty()){
                System.debug('PP contacts : '+contacts);
                return contacts.get(0);
            }
        }       
        return null;
    }
    
    public static cscrm__Address__c getAddressBySalesforceAddressId(String AddressId)
   {
        if( String.isNotBlank(AddressId))
        {
            List<String> AddId = new List<String>();
            AddId.add(AddressId);
        
            Map<String, cscrm__Address__c> addressMap = new Map<String, cscrm__Address__c>();
            
            addressMap = getAddressesBySalesforceIDList(AddId);       
            if(!addressMap.isEmpty())
            {
                return addressMap.values().get(0);
            }            
        }
        return null;
       
    }   
    
    public static Map<String,cscrm__Address__c> getAddressesBySalesforceIDList(List<String> AddIds) 
    {
       if( !AddIds.IsEmpty())
       {
            Map<String, cscrm__Address__c> addressMap = new Map<String, cscrm__Address__c>();
            String queryString = queryBuilder('cscrm__Address__c');
            queryString = queryString + ' where Id in: AddIds';
            List<cscrm__Address__c> addressList = Database.Query(queryString);
            System.debug('TTT:Address list from AddressID =' + addressList );
            for(cscrm__Address__c addr : addressList) 
            {
                addressMap.put(addr.Address_ID__c , addr);// check external id field 
            }
            return addressMap;
       }
       return null;
    }
    
    public static Map<Contact,Map<Id,List<AccountContactRelation>>> getContactsByAcctId(Id accountId,String Type) {
        if(String.isNotBlank(accountId))
        {
            String queryString = queryBuilder('AccountContactRelation');
            queryString = queryString + ' where AccountId = \'' + accountId + '\'';
            queryString = String.isNotBlank(Type) ? (queryString +' and Contact_Type__c = \'' + Type + '\'') : queryString;
            List<AccountContactRelation> accountContRelatn = Database.Query(queryString);            
            Set<id> contIds = new Set<Id>();            
            for(AccountContactRelation rel : accountContRelatn){
                contIds.add(rel.ContactId);
            }
            if(contIds.size()>0){
                Map<Contact,Map<Id,List<AccountContactRelation>>> contactToAcctContactMap = new Map<Contact,Map<Id,List<AccountContactRelation>>>();
                queryString = queryBuilder('Contact');
                queryString = queryString + ' where id IN :contIds';
                List<Contact> contacts = Database.Query(queryString);
                System.debug('contacts : '+contacts);
                for(Contact cont : contacts){
                    Map<Id,List<AccountContactRelation>> acctContactMap = new Map<Id,List<AccountContactRelation>>();
                    List<AccountContactRelation> acctContList = new List<AccountContactRelation>();
                    for(AccountContactRelation rel : accountContRelatn){
                        if(rel.ContactId == cont.Id){
                            acctContList.add(rel);
                        }
                    }
                    System.debug('acctContList : '+acctContList);
                    if(!acctContList.isEmpty()){
                        acctContactMap.put(cont.Id,acctContList);
                        System.debug('YY inner map : '+acctContactMap);
                        contactToAcctContactMap.put(cont,acctContactMap);
                        System.debug('YY outer map : '+contactToAcctContactMap);
                    }
                }
                System.debug('contactToAcctContactMap keys : '+contactToAcctContactMap.keySet());
                System.debug('contactToAcctContactMap values : '+contactToAcctContactMap.values());
                return contactToAcctContactMap;
            }
            
        }        
        return null;
    }
    
    public static Map<cscrm__Address__c,Map<Id,List<cscrm__Account_Address_Relationship__c>>> getAddressesByAcctId(Id accountId,String Type) {
        if(String.isNotBlank(accountId))
        {
            String queryString = queryBuilder('cscrm__Account_Address_Relationship__c');
            queryString = queryString + ' where cscrm__Account__c = \'' + accountId + '\'';
            queryString = String.isNotBlank(Type) ? (queryString +' and cscrm__Address_Type__c = \'' + Type + '\'') : queryString;
            List<cscrm__Account_Address_Relationship__c> accountAddRelatn = Database.Query(queryString);            
            Set<id> addrIds = new Set<Id>();            
            for(cscrm__Account_Address_Relationship__c rel : accountAddRelatn){
                addrIds.add(rel.cscrm__Address__c);
            }
            if(addrIds.size()>0){
                Map<cscrm__Address__c,Map<Id,List<cscrm__Account_Address_Relationship__c>>> addressToAcctAddressMap = new Map<cscrm__Address__c,Map<Id,List<cscrm__Account_Address_Relationship__c>>>();
                queryString = queryBuilder('cscrm__Address__c');
                queryString = queryString + ' where id IN :addrIds';
                List<cscrm__Address__c> addresses = Database.Query(queryString);
                System.debug('addresses : '+addresses);
                for(cscrm__Address__c address : addresses){
                    Map<Id,List<cscrm__Account_Address_Relationship__c>> acctAddressMap = new Map<Id,List<cscrm__Account_Address_Relationship__c>>();
                    List<cscrm__Account_Address_Relationship__c> acctAddList = new List<cscrm__Account_Address_Relationship__c>();
                    for(cscrm__Account_Address_Relationship__c rel : accountAddRelatn){
                        if(rel.cscrm__Address__c == address.Id){
                            acctAddList.add(rel);
                        }
                    }
                    System.debug('acctAddList : '+acctAddList);
                    if(!acctAddList.isEmpty()){
                        acctAddressMap.put(address.Id,acctAddList);
                        System.debug('YY inner map : '+acctAddressMap);
                        addressToAcctAddressMap.put(address,acctAddressMap);
                        System.debug('YY outer map : '+addressToAcctAddressMap);
                    }
                }
                System.debug('addressToAcctAddressMap keys : '+addressToAcctAddressMap.keySet());
                System.debug('addressToAcctAddressMap values : '+addressToAcctAddressMap.values());
                return addressToAcctAddressMap;
            }
            
        }        
        return null;
    }
    
    public static TCMDataObject.Contact mapContactToRequest(Contact c, String event){
        
        if(c != null && event != null && event != ''){
            TCMDataObject.Contact data = new TCMDataObject.Contact();
            
            data.id = c.UUID__c;
            data.title = c.Title;
            data.firstName = c.FirstName; // INTERFACE MANDATORY
            data.middleName = c.MiddleName;
            data.lastName = c.LastName; // INTERFACE MANDATORY
            data.birthDate = '';
            if(c.Birthdate != null){
                data.birthDate = String.valueOf(c.Birthdate);     
            }
            data.status = c.Contact_Status__c; // INTERFACE MANDATORY
            data.onlineFlag = '';
            data.preferredMethod = c.Pref_Comm_Method__c;
            data.eventAction = event; // INTERFACE MANDATORY
            DateTime dt = System.Datetime.now();
            data.sendDateTime = String.valueOf(dt)+'.'+dt.millisecond(); // INTERFACE MANDATORY
            String contactId = c.Id;
            contactId = contactId.substring(3);
            data.contactId = contactId; // INTERFACE MANDATORY
            data.lastVerifiedDate = '';
            data.notes = '';
            data.numberInHousehold = '';
            data.occupation = '';
            data.timeZone = '';
            data.jobDescription = '';
            data.jobTitle = '';
            data.reviewedFlag = '';
            data.languagePreference = '';
            data.lastUpdated = '';
            
            //data.customerAccounts = new ManageContactRequest.CustomerAccounts();
            data.customerAccounts = new List<TCMDataObject.CustomerAccounts>();
            //Account a = getAccount(c.AccountId);
            System.debug('TTTTT1' + c.AccountId);
            System.debug('TTTTT2' + c);
            Account a = getAccountByAccountId(c.AccountId);
            
            System.debug('TTTTT3' + a);
            
            TCMDataObject.CustomerAccounts CustomerAccobj = new TCMDataObject.CustomerAccounts();
            
            if(a != null && a.Account_Uuid__c != null) {
                CustomerAccobj.accountUuid = a.Account_UUID__c; // INTERFACE MANDATORY    
            }
            else {
                CustomerAccobj.accountUuid = ''; // INTERFACE MANDATORY
            }
            
            CustomerAccobj.customerCode = '';
            CustomerAccobj.mmsOptIn = '';
            CustomerAccobj.smsOptIn = '';
            CustomerAccobj.emailOptIn = '';
            CustomerAccobj.faceToFaceOptIn = '';
            CustomerAccobj.phoneOptIn = '';
            CustomerAccobj.directMailOptIn = '';
            //data.customerAccounts.contactRelationship = new ManageContactRequest.ContactRelationship();
            CustomerAccobj.contactRelationship = new TCMDataObject.ContactRelationship();
            
            CustomerAccobj.contactRelationship.endDate = '';
            CustomerAccobj.contactRelationship.contactType = c.Contact_Type__c; // INTERFACE MANDATORY
            CustomerAccobj.contactRelationship.contactUsage = ''; // INTERFACE MANDATORY
            data.customerAccounts.add(CustomerAccobj);
            System.debug('TTTTT5' + data);
            return data;
        }
        else
            return null;
    }
    
    
    public static List<cscrm__Address__c> getAddressesByAcctIdOld(Id accountId,String Type) {
        if(String.isNotBlank(accountId))
        {
            String queryString = queryBuilder('cscrm__Account_Address_Relationship__c');
            queryString = queryString + ' where cscrm__Account__c = \'' + accountId + '\'';
            queryString = String.isNotBlank(Type) ? (queryString +' and cscrm__Address_Type__c = \'' + Type + '\'') : queryString;
            List<cscrm__Account_Address_Relationship__c> accountAddRelatn = Database.Query(queryString);

            Set<id> addrIds = new Set<Id>();            
            for(cscrm__Account_Address_Relationship__c rel : accountAddRelatn){
                addrIds.add(rel.cscrm__Address__c);
            }

            if(addrIds.size()>0){
                queryString = queryBuilder('cscrm__Address__c');
                queryString = queryString + ' where id IN :addrIds';
                List<cscrm__Address__c> accountAddresses = Database.Query(queryString);
                return accountAddresses;
            }
            
        }        
        return null;
    }

     public static Contact getContactByAccountId(Id accountId) {
        System.debug('!@#$% Querying for exisitng contact with Account ID : ' + accountId);
        List<Contact> contList = [SELECT AccountId,AssistantName,AssistantPhone,Birthdate,CanAllowPortalSelfReg,Contact_Status__c,CreatedById,CreatedDate,Department,Description,DoNotCall,Email,EmailBouncedDate,EmailBouncedReason,Fax,FirstName,HasOptedOutOfEmail,HasOptedOutOfFax,HomePhone,HomePhone__c,Home_Email__c,Home_Fax__c,Id,IsDeleted,IsEmailBounced,Jigsaw,JigsawContactId,Language_Preference__c,LastActivityDate,LastCURequestDate,LastCUUpdateDate,LastModifiedById,LastModifiedDate,LastName,LastReferencedDate,LastViewedDate,LeadSource,MailingAddress,MailingCity,MailingCountry,MailingGeocodeAccuracy,MailingLatitude,MailingLongitude,MailingPostalCode,MailingState,MailingStreet,MasterRecordId,MobilePhone,Name,OtherAddress,OtherCity,OtherCountry,OtherGeocodeAccuracy,OtherLatitude,OtherLongitude,OtherPhone,OtherPostalCode,OtherState,OtherStreet,OwnerId,Phone,PhotoUrl,Pref_Comm_Method__c,ReportsToId,Salutation,SystemModstamp,Driver_License_Id__c,Driver_Licence_State__c,Title FROM Contact WHERE AccountId = :accountId];
        System.debug('!@#$% Querying result : ' + contList);
        if(!contList.isEmpty())
        {
            return contList.get(0);
        } 
        return null;
    }
    
    public static Contact getContactByContactId(String contactId) {
        System.debug('!@#$% Querying for Contact using Contact UUID : ' + contactId);
        
        List<Contact> contList = [SELECT AccountId,AssistantName,AssistantPhone,Birthdate,CanAllowPortalSelfReg,Contact_Status__c,CreatedById,CreatedDate,Department,Description,DoNotCall,Email,EmailBouncedDate,EmailBouncedReason,Fax,FirstName,HasOptedOutOfEmail,HasOptedOutOfFax,HomePhone,HomePhone__c,Home_Email__c,Home_Fax__c,Id,IsDeleted,IsEmailBounced,Jigsaw,JigsawContactId,Language_Preference__c,LastActivityDate,LastCURequestDate,LastCUUpdateDate,LastModifiedById,LastModifiedDate,LastName,LastReferencedDate,LastViewedDate,LeadSource,MailingAddress,MailingCity,MailingCountry,MailingGeocodeAccuracy,MailingLatitude,MailingLongitude,MailingPostalCode,MailingState,MailingStreet,MasterRecordId,MobilePhone,Name,OtherAddress,OtherCity,OtherCountry,OtherGeocodeAccuracy,OtherLatitude,OtherLongitude,OtherPhone,OtherPostalCode,OtherState,OtherStreet,OwnerId,Phone,PhotoUrl,Pref_Comm_Method__c,ReportsToId,Salutation,SystemModstamp,Driver_License_Id__c,Driver_Licence_State__c,Title FROM Contact WHERE UUID__c = :contactId];
        System.debug('!@#$% Query result : ' + contList);
        if(!contList.isEmpty())
        {
            return contList.get(0);
        }
        return null;
    }
    
    ///PLEASE 
    public static List<cscrm__Address__c> getAddressesByAccountId(Id accountId) {
        System.debug('!@#$% Querying for exisitng addresses with Account ID : ' + accountId);
        List<cscrm__Address__c> addrsList = [SELECT cscrm__Account__c,Address_Line_1__c,Locality__c,cscrm__Address_Details__c,cscrm__Address_Type__c,cscrm__Building_Name__c,cscrm__Building_Number__c,cscrm__Building_Type__c,cscrm__City__c,cscrm__Country__c,cscrm__External_Address_Id__c,cscrm__External_ID__c,cscrm__Geolocation__c,cscrm__Geolocation__Latitude__s,cscrm__Geolocation__Longitude__s,cscrm__Is_Billing_Address__c,cscrm__Is_Installation_Address__c,cscrm__Is_Registered_Office_Address__c,cscrm__Is_Shipping_Address__c,cscrm__Level_Number__c,cscrm__Level_Type__c,cscrm__Plan_Number__c,cscrm__Property_Name__c,cscrm__State_Province__c,cscrm__Street_Name__c,cscrm__Street_Number_End__c,cscrm__Street_Number_Start__c,cscrm__Street_Type__c,cscrm__Street__c,cscrm__Unit_Number__c,cscrm__Unit_Type__c,cscrm__Zip_Postal_Code__c,Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,Name,OwnerId,SystemModstamp FROM cscrm__Address__c WHERE cscrm__Account__c = :accountId];
        System.debug('!@#$% Querying result : ' + addrsList);
        if(!addrsList.isEmpty())
        {
            return addrsList;
        }
        return null;
    }   
    
    public static Contact mapCustomerDataToContact(TCMDataObject.Customer customerData, Contact c, Account a) {
        if(c == null){
            c = new Contact();
        }
        c.AccountId = a.Id;
        c.Salutation = customerData.customerAccount.title;
        c.FirstName = customerData.customerAccount.firstName;
        c.LastName = customerData.customerAccount.LastName;
        if(customerData.customerAccount.birthDate != null && customerData.customerAccount.birthDate != ''){
            c.Birthdate = Date.valueOf(customerData.customerAccount.birthDate);    
        }
        c.Contact_Status__c = 'Active';
        
        
        return c;
    }
    */
    
}