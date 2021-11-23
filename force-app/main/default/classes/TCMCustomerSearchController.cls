/*
    AUTHOR : Vineeth Batreddy    
    DESCRIPTION : This class is used to make realtime http/https callouts to TCM to search on TCM records and selectively import records into Salesforce
    
    Modified By: Anuja Pandey(D837426)
    Modified On: 10/11/2016
    Modification Info: IPD-1145: 1. Import Contact Callouts and Imports merged with Import Accounts Method.
                                 2. Cosmetic changes on Pages: adding Columns, Removing Columns 
    Changed Methods: searchByMasterID();, doCallout(Boolean appendParams), importAccount()
    Methods not in Use:  importContacts(), findAccountByMasterId(Decimal masterId)
*/

public class TCMCustomerSearchController {
    public String requestLabel;
    public String result {get;set;}
    public String error {get; set;}
    public Object obj {get; set;}
    public String message1 {get; set;}
    public String message2 {get; set;}
    public String message3 {get; set;}
    public JSON2TCMCustomerContactObject customerContact {get; set;}
    public CustomerObject customer {get; set;}
    public List<CustomerObject.Customer> customerList {get; set;}
    public List<Account> accountsList {get; set;}
    public String openingAccount {get;set;}
    public Account a;
    public String selectedCustomerAccountUUID {get; set;}
    public CustomerObject.Customer selectedCustomer {get; set;}
    
    public String lastName {get; set;}
    public String abn {get; set;}
    public String acn {get; set;}
    public String masterId {get; set;}
    public Boolean includeContacts = false;
    public String cidn {get; set;}
    public String cac {get; set;}
    public string birthDate{get;set;}
    
    public String params {get; set;}
    public Integer internalResultCount {get; set;}
    public boolean searchedInternally {get; set;}
    public boolean searchedOnTCM {get; set;}

    private static final String exclusion = 'out of scope'; 
    private static final String DEFAULT_ADDRESS_TYPE = 'Primary Address';

    private static final Integer upper_limit = Integer.valueOf(Label.CUSTOMER_SEARCH_PAGE_SIZE);
    public Integer offset {get; set;}
    
       
    //To be removed later on - For testing purposes ONLY  
    private static final String MOCK_URL = 'http://mocksandbox.getsandbox.com/search';
    
    public TCMCustomerSearchController() {
        accountsList = new List<Account>();
        searchedInternally = false;
    } 
    // This method do internal search in force.com side
    public void startSearch() {
        System.debug('!@#$% Attempting to search internally'); 
        initialise();
        customer = new CustomerObject();
        internalSearch();
    }
    // This method do search in TCM
    public void startAdvancedSearch() {
        System.debug('!@#$% Attempting to search on TCM'); 
        initialise();
        accountsList = new List<Account>();
        
        /*
        if((lastName != null && lastName != '' && abn != null && abn != '') || (lastName != null && lastName != '' && acn != null && acn != '')) {
            searchByLastName();
        }
        */
        if(abn !=null && abn !='')
       {
            if((acn!=null && acn !='') ||(cac !=null && cac !='')||(cidn !=null && cidn !='')||(masterId !=null && masterId !='')||(birthDate !=null && birthDate !=''))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Combination '));
                
            }else{
                searchByABN();
            }
            
       }
        else if(acn !=null && acn !='')
        {
            if((cac !=null && cac !='')||(cidn !=null && cidn !='')||(masterId !=null && masterId !='')||(birthDate !=null && birthDate !=''))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Combination '));
            }else{
                 searchByACN();
            }
       
            
        }
        else if(masterId != null && masterId != '')
        { 
            if((lastName !=null && lastName !='')|| (cidn !=null && cidn !='')||(cac !=null && cac!='')||(birthDate!=null && birthDate!=''))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Combination '));
            }else{
                searchByMasterID();
            }
            
            
        }
        else if(cidn != null && cidn != '') 
        {
            if((cac !=null && cac !='')||(lastName !=null && lastName !='')||(birthDate!=null && birthDate !=''))
            {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Combination '));
            }else{
                searchByCIDN();
            }
            
            
        }
        else if(cac != null && cac != '')
        {
           if((lastName !=null && lastName !='')||(birthDate !=null && birthDate !=''))
           {
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Combination ')); 
           }else{
            searchByCAC();
           }
            
            
        }
        
        else if((lastName != null && lastName != '') || (abn != null && abn != '') || (acn != null && acn != '') ||(birthDate !=null && birthDate !=''))
        {
            if(lastName != null && lastName != '' && abn != null && abn != ''){
             searchByABN();
            }
            else if(lastName != null && lastName != '' && acn != null && acn != ''){
                searchByACN();
            }
            else if(lastName != null && lastName != '' && birthDate != null && birthDate != '')
            {
               searchByDOB();
            }
            else if((lastName != null && lastName != '') || (cidn == null && cidn == '') || (cac == null && cac == '') || (birthDate == null && birthDate == '') || (abn == null && abn == '') || (acn == null && acn == '') || (masterId == null && masterId == ''))
           {
               searchByLastName();
           }
              else if((lastName == null || lastName == '') || (cidn == null && cidn == '') || (cac == null && cac == '') || (masterId == null && masterId == '')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.CUSTOMER_SEARCH_WARNING_MISSING_LASTNAME));
            }
            else if((abn == null || abn == '') || (acn == null || acn == '')||(birthDate == null || birthDate =='') && (cidn == null && cidn == '') && (cac == null && cac == '') && (masterId == null && masterId == '')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.CUSTOMER_SEARCH_WARNING_MISSING_ABN_ACN));
            }
        }
        else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.CUSTOMER_SEARCH_WARNING_NO_SEARCH_CRITERIA));
        }     

        convert();
      
        if(searchedOnTCM && (customer == null || customer.data == null || customer.data.customers == null) && (customerContact == null || customerContact.data == null)){
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.CUSTOMER_SEARCH_INFO_NOT_FOUND));
            message2 = 'true';
            }
            
        
      
    }
    
    // Internal search
    public void internalSearch() {  
        accountsList = new List<Account>();
        Boolean showSearchResult = true;
        searchedInternally = true;
        if(lastName != null && lastName != '' && abn !=null && abn !='') 
        {
            if((acn!=null && acn!='')||(cidn !=null && cidn !='')||(birthDate !=null && birthDate !='')||(masterId !=null && masterId !=''))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Combination '));
                showSearchResult = false;
            }
            else
            {
                if (abn.isNumeric()) 
                {
                accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c FROM Account WHERE ABN__c = :abn and Name LIKE :'%'+lastName+'%' ];    
                }
              else 
               {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid value entered for ABN or LastName'));
                showSearchResult = false;
               }  
            }
       }
        else if(lastName != null && lastName != '' && acn !=null && acn !='') 
        {
            if((cidn !=null && cidn !='')||(birthDate !=null && birthDate !='')||(masterId !=null && masterId !=''))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Combination '));
                showSearchResult = false;
            }
            else
            {  
               if (acn.isNumeric()) 
               {
                accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c FROM Account WHERE ACN__c = :acn and Name LIKE :'%'+lastName+'%' ];    
              }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid value entered for ACN or LastName'));
                showSearchResult = false;
              }  
           }
        }
        else if(lastName != null && lastName != '' && birthDate !=null && birthDate !='' ) 
        {
            if((cidn!=null && cidn !='')||(masterId !=null && masterId !=''))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Combination '));
                showSearchResult = false;
            }
          else
          {   
            if (birthDate.length() ==10) 
            {
                accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c FROM Account WHERE birthDate__c = :birthDate and Name LIKE :'%'+lastName+'%' ];    
            }
            else 
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid value entered for BirthDate or LastName'));
                showSearchResult = false;
            }  
          }
        }
        else if(lastName != null && lastName != '') 
        {
            if((abn !=null && abn !='')||(acn!=null && acn !='') ||(cac !=null && cac !='')||(cidn !=null && cidn !='')||(masterId !=null && masterId !='')||(birthDate !=null && birthDate !=''))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Combination '));
                showSearchResult = false;
            }
            else
            {
            accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c, Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c FROM Account WHERE Name LIKE :'%'+lastName+'%' LIMIT 25];    
            }
        }
        else if(abn != null && abn != '') 
         {
            if((acn!=null && acn !='') ||(cac !=null && cac !='')||(cidn !=null && cidn !='')||(masterId !=null && masterId !='')||(birthDate !=null && birthDate !=''))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Combination '));
                showSearchResult = false;
            }
            else
            {
                if (abn.isNumeric()) 
                {
                accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c FROM Account WHERE ABN__c = :abn];    
                }
                else 
                {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid value entered for ABN'));
                showSearchResult = false;
                }
           }
        }
        else if(acn != null && acn != '')
        {
            if((cac !=null && cac !='')||(cidn !=null && cidn !='')||(masterId !=null && masterId !='')||(birthDate !=null && birthDate !=''))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Combination '));
                showSearchResult = false;
            }
            else  
            {
            if (acn.isNumeric()) {            
                accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c FROM Account WHERE ACN__c = :acn];    
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid value entered for ACN'));
                showSearchResult = false;
            }
           }
        }
        
        else if(cidn != null && cidn != '') 
        {
            if((masterId !=null && masterId !='')||(birthDate !=null && birthDate !=''))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Combination '));
                showSearchResult = false;
            }
            else 
            {
            if (cidn.isNumeric()) {
                accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c FROM Account WHERE CIDN__c = :cidn];        
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid value entered for CIDN.'));
                showSearchResult = false;
            }  
            }
        }
        else if(cac != null && cac != '') 
        {
            if((masterId !=null && masterId !='')||(birthDate !=null && birthDate !=''))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Combination '));
                showSearchResult = false;
            }
            else
            {
            if (cac.isNumeric()) 
            {
                accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c FROM Account WHERE Customer_ID__c = :cac];        
            }
            else 
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid value entered for CAC'));
                showSearchResult = false;                
            }
            }
        }
        else if(masterId != null && masterId != '') 
        {
             try 
             {
                accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c,Data_Sovereign_Status__c, CIDN__c,birthDate__c,Type,Business_Unit__c FROM Account WHERE TCM_MasterID__c = :masterId];
            }
            catch (TypeException e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid value entered for Master ID'));
                showSearchResult = false;
            }
            
        }
        else {
            showSearchResult = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.CUSTOMER_SEARCH_WARNING_NO_SEARCH_CRITERIA));
        }  

        if (accountsList.size() > 0) {
            internalResultCount = accountsList.size();
        }
        else internalResultCount = 0;

        if (showSearchResult) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Found '+ internalResultCount + ' customers. Consider doing an TCM search for more results.'));
            message1 = 'true';
        }
        System.debug('!@#$% Internal Search Result : ' + accountsList);
    }

    //Search by Master ID
    public void searchByMasterID(){  
        System.debug('!@#$% Searching by MasterId : ' + masterId);   
        System.debug('!@#$% includeContacts : ' + includeContacts);
        if(includeContacts==false){
            params = params + '/'+masterId;
        }
        Boolean append = false;
        
        if(includeContacts==true){
        system.debug('inside include contacts search');
            params='';
            params = params + '/'+masterId + '?include=contacts';
            append = true;
        }

        doCallout(append);
    }

    //Search by lastName
    public void searchByLastName(){  
        System.debug('!@#$% Searching by lastName : ' + lastName);   

        params = params + '?lastName='+lastName;
        if(abn != null && abn != '') {
            params += '&abn='+abn;    
        }
        
        if(acn != null && acn != '') {
            params += '&acn='+acn;    
        }
        
        doCallout(true);
    }
    //Search by Birthdate
    public void searchByDOB(){  
        System.debug('!@#$% Searching by DOB : ' + birthDate);
        params = params +'?birthDate='+birthDate;
         if(lastName != null && lastName != '') 
         {
            params += '&lastName='+lastName;  
            System.debug('==++params'+params);
         }
        
        doCallout(true);
    }
    
    //Search by CIDN
    public void searchByCIDN(){  
        System.debug('!@#$% Searching by CIDN : ' + cidn);   

        params = params + '?cidn='+cidn;
        
        doCallout(true);
    }

    //Search by CIDN
    public void searchByCAC(){  
        System.debug('!@#$% Searching by CAC : ' + cac);   

        params = params + '?cac='+cac;
        
        doCallout(true);
    }

    //Search by ABN
    public void searchByABN(){  
        System.debug('!@#$% Searching by ABN : ' + abn);

        params = params + '?abn='+abn;
        
        if(lastName != null && lastName != '') {
            params += '&lastName='+lastName;    
        }
        
        doCallout(true);
    }

    //Search by ABN
    public void searchByACN(){  
        System.debug('Searching by ACN : ' + acn);

        params = params + '?acn='+acn;
        
        if(lastName != null && lastName != '') {
            params += '&lastName='+lastName;    
        }
        
        doCallout(true);
    }

    // Do callout to endpoint
    public void doCallout(Boolean appendParams){
        System.debug('!@#$% Attempting to do a callout to TCM');

        Boolean calloutUnsuccesful = false;
        system.debug('i am failing here'+calloutUnsuccesful);
        // N.Forsyth 27.9.16: Wrapping this in try/catch block to ensure custom settings are defined as part of deployment
        try {
       		TCMGetInterface getInstance = TCMGetInterface.getInstance();
            String token = TCMSearchManager.getTCMToken();
            system.debug('i am failing here after Token'+ token);

            String url;
            IntegrationSettings__c is = IntegrationSettings__c.getOrgDefaults();
            if(is.EnableMocks__c){
                url = MOCK_URL;
            }
            else {
           
                url = EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts';
                system.debug('i am failing here in URL'+ url);
            }
            
            if(offset == null) {
                offset = 0;
            }
            
            if(appendParams) {
           
                params = params + '&limit='+upper_limit+'&offset='+offset;
                //params = params + '&limit='+record+'&offset='+offset;
                 
            }
            else {
            
                params = params + '?limit='+upper_limit+'&offset='+offset;
                //params = params + '&limit='+record+'&offset='+offset;
                
            }
            
            HttpResponse resp = TCMSearchService.callout(url+params, token);
            System.debug('===+++resp'+resp);    
            String body = resp.getBody();
            System.debug('!@#$% HTTP Response Body : ' + body);
            
            searchedOnTCM = true;
            this.result = body;  
            this.error = '';
            
            if(resp.getStatusCode() != 200)
            {
                calloutUnsuccesful = true;
                searchedOnTCM = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.CUSTOMER_SEARCH_ERROR_TCMDOWN));   
            }

            
        }
        catch(NullPointerException e) {
            calloutUnsuccesful = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.CUSTOMER_SEARCH_ERROR_CUSTOMSETTINGS_UNDEFINED));
        }
        catch(CalloutException ce) {
            calloutUnsuccesful = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.CUSTOMER_SEARCH_ERROR_TCMDOWN));
        }

    }

    // Convert
    public Object convert() {
        
        System.debug('!@#$% Attempting to convert the result');
        if(result != null && result != ''){
            
           // if(includeContacts != null){
                if(includeContacts==true){
                 system.debug('inside include contacts Json Converter');
                    JSON2TCMCustomerContactObject convertedObj = (JSON2TCMCustomerContactObject)JSON.deserialize(result, JSON2TCMCustomerContactObject.class);    
                    this.obj = convertedObj;
                    customerContact = convertedObj;
                    System.debug('!@#$% Converted CustomerContact : ' + customerContact);
                  
                    return customerContact;
                }
                else {
                    CustomerObject convertedObj = (CustomerObject)JSON.deserialize(result, CustomerObject.class); 
                    this.obj = convertedObj; 
                    customer = convertedObj;
                    System.debug('!@#$% Converted Customer : ' + customer);
                    return customer;
                }    
           // }
        }
        
        return null;
    }

    // Reset state
    public void initialise() {
        System.debug('!@#$% Attempting to initialise variables');
        message1 = '';
        message2 = '';
        message3 = '';
        result = '';
        params = '';
        accountsList = null;
        searchedOnTCM = false;     
    }
    
    // Clear all variables
    public void clear() {
        System.debug('!@#$% Attempting to clear all variables');
        message1 = '';
        message2 = '';
        message3 = '';
        result = '';
        params = '';        
        lastName = '';
        abn = '';
        acn = '';
        masterId = '';
        cidn = '';
        cac = '';
        birthDate = '';
        includeContacts = false;
        searchedInternally = false;
        searchedOnTCM = false;
        customerContact = null;
        customer = null;
        accountsList = new List<Account>();
    }

    // Redirect to customer creation page
    public PageReference createCustomer() {
        PageReference creationPage = new PageReference('/apex/CustomerCreation');
        creationPage.setRedirect(true);
        return creationPage;
    }
    
    public PageReference openAccount() {
        System.debug('!@#$% Opening Account');
        PageReference accPage = new PageReference('/'+openingAccount);
        accPage .setRedirect(true);
        return accPage ;
    }
    
    public void selectCustomer(){
        System.debug('!@#$% Attempting to select a row . Selected Customer account UUID : ' + selectedCustomerAccountUUID);
        if(customer != null && customer.data != null && customer.data.customers != null){
            for(CustomerObject.Customer cust : customer.data.customers){
                System.debug('!@#$% customer data : ' + selectedCustomerAccountUUID);
                if(cust.customerAccount != null){
                    if(cust.customerAccount.accountUuid != null && cust.customerAccount.accountUuid != ''){
                        if(selectedCustomerAccountUUID == cust.customerAccount.accountUuid){
                            selectedCustomer = cust;  
                             System.debug('!@#$% Attempting to select a row . Selected Customer account UUID : ' + selectedCustomerAccountUUID);      
                        }
                    }
                }    
            }    
        }        
    }
    //This method imports account and its related contacts from TCM 
    public PageReference importAccount() {
        System.debug('!@#$% Attempting to import selected customer account');
		System.debug('selectedCustomer=='+selectedCustomer);
        if(selectedCustomer != null && selectedCustomer.customerAccount != null){
			if(selectedCustomer.customerAccount.dataSovereignty.toLowerCase() == exclusion){                
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.CUSTOMER_SEARCH_ERROR_DATA_SOVEREIGNTY));
                 message3 = 'true';
                 return null;
            } else {
                system.debug('inside import contacts method');
                Account tcmCustomer = null;
                Savepoint sp = null;
                TCMCustomerImportByCIDN tcmImportByCIDN = new TCMCustomerImportByCIDN();
				tcmImportByCIDN.selectedCustomer = selectedCustomer;
                try {
                    TCMGetInterface.getInstance().tcmCustomerObject.put(selectedCustomer.masterID, selectedCustomer);
                    TCMGetContactFuture tcmGetConFuture = new TCMGetContactFuture();
                    tcmImportByCIDN.tcmObjects(selectedCustomer.cidn);
                    sp = Database.setSavepoint();
                    tcmImportByCIDN.createTCMCustomer(selectedCustomer.cidn);
                    tcmCustomer = tcmImportByCIDN.tcmCustomer;
                    tcmGetConFuture.futureCalloutAccount(tcmCustomer,'TCMSEARCHSERVICE');
                } catch(TCMException.TCMCallOutException e) {
                    System.debug('Exception root cause : ' + e.getStackTraceString());
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.CUSTOMER_SEARCH_ERROR_IMPORT));
                    return null;
                } catch(TCMException.TCMCustomerCreationException tcmException){
                    //EDGE-2331
                    Database.rollback(sp);
                    TCMBusinessErrorCode.getInstance().logCustomerExcepction(selectedCustomer.masterId,'TCMSEARCHSERVICE',tcmException);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.CUSTOMER_SEARCH_ERROR_IMPORT));
                    return null;
                } catch(TCMException.TCMContactCreationException e){
                    Database.rollback(sp);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.CUSTOMER_SEARCH_ERROR_IMPORT));
                    return null;
                } catch(Exception e) {
                    System.debug('!@#$% Account creation exception !');
                    System.debug('Exception root cause : ' + e.getStackTraceString());
                    Database.rollback(sp);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.CUSTOMER_SEARCH_ERROR_IMPORT));
                    return null;
                }
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.CUSTOMER_SEARCH_INFO_CONTACTS_IMPORT_SUCCESSFUL));
                // Redirect to newly created record
                PageReference pageRef = new PageReference('/' + tcmCustomer.Id);
                return pageRef;
            }
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.CUSTOMER_SEARCH_WARNING_SELECTION));
            message3 = 'true';
            return null;
        }
    }
    // implements next button to view next set of records
    public void next(){
        offset = offset + upper_limit; 
        //offset = offset + Integer.valueOf(record);
        System.debug('!@#$% OFFSET : ' + offset);
        startAdvancedSearch();
    }
    //implements previous button to view previous set of records
    public void previous(){
        offset = offset - upper_limit;
        //offset = offset - Integer.valueOf(record);
        System.debug('!@#$% OFFSET : ' + offset);
        startAdvancedSearch();
    }

}