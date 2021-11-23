/* Date: 17-May-17 : Methods in the class have been commented by Nirvana Team to resolve merge issues for Edge R2a Sprint 17.0.1 TCM Integration functionality */ 
/*
    AUTHOR : Vineeth Batreddy    
    DESCRIPTION : Helper class that holds methods to search internally in salesforce, search on TCM and importing records from TCM
*/
public class CustomerSearchHelper {

	public CustomerSearchHelper() {}
    
	/*
    // Search for salesforce accounts by Account Name
    public static List<Account> searchAccountsByName(String name) {
        System.debug('!@#$% Querying for exisitng account with Name : ' + name);
        List<Account> accList = new List<Account>();
        if(String.isNotBlank(name)) {
            String queryString = TCMUtil.queryBuilder('Account');
            queryString = queryString + ' where Name LIKE \'%'+name+'%\'' + 'LIMIT 25';
            accList = Database.Query(queryString);
            System.debug('!@#$% Query result : ' + accList);                
        }
        return accList;
    }   

    // Search for salesforce accounts by ABN number
    public static List<Account> searchAccountsByABN(String abn) {
        System.debug('!@#$% Querying for existing account with ABN : ' + abn);
        List<Account> accList = new List<Account>();
        if(String.isNotBlank(abn)) {
            String queryString = TCMUtil.queryBuilder('Account');
            queryString = queryString + ' where ABN__c = \'' + abn + '\'';
            accList = Database.Query(queryString);
            System.debug('!@#$% Query result : ' + accList);
        }
        return accList;
    } 

    // Search for salesforce accounts by ACN number
    public static List<Account> searchAccountsByACN(String acn) {
        System.debug('!@#$% Querying for existing account with ACN : ' + acn);
        List<Account> accList = new List<Account>();
        if(String.isNotBlank(acn)) {
            String queryString = TCMUtil.queryBuilder('Account');
            queryString = queryString + ' where ACN__c = \'' + acn + '\'';
            accList = Database.Query(queryString);
            System.debug('!@#$% Query result : ' + accList);
        }
        return accList;
    }

    // Search for salesforce accounts by Master ID
    public static List<Account> searchAccountsByMasterId(String masterId) {
        System.debug('!@#$% Querying for existing accounts with masterId : ' + masterId);
        List<Account> accList = new List<Account>();
        if(String.isNotBlank(masterId)) {
            accList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_Master_ID__c,Data_Sovereign_Status__c, CIDN__c FROM Account WHERE TCM_Master_ID__c = :System.Decimal.valueOf(masterId)];
            System.debug('!@#$% Query result : ' + accList);
        }
        return accList;
    }

    // Search for salesforce accounts by CIDN
    public static List<Account> searchAccountsByCIDN(String cidn) {
        System.debug('!@#$% Querying for existing accounts with cidn : ' + cidn);
        List<Account> accList = new List<Account>();
        if(String.isNotBlank(cidn)) {
            String queryString = TCMUtil.queryBuilder('Account');
            queryString = queryString + ' where CIDN__c = \'' + cidn + '\'';
            accList = Database.Query(queryString);
            System.debug('!@#$% Query result : ' + accList);
        }
        return accList;
    }

    // Search for salesforce accounts by Customer Account Code
    public static List<Account> searchAccountsByCAC(String cac) {
        System.debug('!@#$% Querying for existing accounts with cac : ' + cac);
        List<Account> accList = new List<Account>();
        if(String.isNotBlank(cac)) {
            String queryString = TCMUtil.queryBuilder('Account');
            queryString = queryString + ' where Customer_ID__c = \'' + cac + '\'';
            accList = Database.Query(queryString);
            System.debug('!@#$% Query result : ' + accList);
        }
        return accList;
    }

    // Construct url parameters for TCM master id search
    public static String getParamsForMasterIdSearch(String masterId, Boolean includeContacts) {
        String params = '';
        if(!includeContacts) {
            params = params +'/'+masterId;
        }

        if(includeContacts) {
            params='';
            params = params + '/'+masterId + '?include=contacts';
        }
        
        return params;
    }

    // Construct url parameters for TCM lastname search
    public static String getParamsForLastnameSearch(String lastname, String abn, String acn) {
        String params = '';
        params = params + '?lastName=' + lastname;
        if(String.isNotBlank(abn)) {
            params += '&abn='+abn;
        }

        if(String.isNotBlank(acn)) {
            params += '&acn='+acn;
        }

        return params;
    }

    // Construct url parameters for TCM cidn search
    public static String getParamsForCidnSearch(String cidn) {
        return '?cidn='+cidn;
    }

    // Construct url parameters for TCM CAC search
    public static String getParamsForCacSearch(String cac) {
        return '?cac='+cac;
    }

    // Construct url parameters for TCM ABN search
    public static String getParamsForAbnSearch(String abn, String lastname) {
        String params = '';
        params = params + '?abn='+abn;

        if(String.isNotBlank(lastName)) {
            params += '&lastName='+lastname;
        }

        return params;
    }

    // Construct url parameters for TCM ACN search
    public static String getParamsForAcnSearch(String acn, String lastname) {
        String params = '';
        params = params + '?acn='+acn;

        if(String.isNotBlank(lastname)) {
            params +='&lastName='+lastname;
        }

        return params;
    }

    // Search on TCM by initiating a callout
    public static HTTPResponse searchTCM(String params, Boolean appendParams, Integer offset, Integer upper_limit) {

        System.debug('!@#$% Attempting to do a callout to TCM');
        HttpResponse httpResponse = new HttpResponse();

        try {
       
            String token = TCMSearchManager.getTCMToken();
            system.debug('!@#$% Token'+ token);

            String url;
            IntegrationSettings__c is = IntegrationSettings__c.getOrgDefaults();

            if(is.EnableMocks__c){
                url = EnvironmentVariable.get('MOCK_URL');
            }
            else {
           
                url = EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts';
            }
            
            if(offset == null) {
                offset = 0;
            }
            
            if(appendParams) {
                params = params + '&limit='+upper_limit+'&offset='+offset;
            }
            else {
                params = params + '?limit='+upper_limit+'&offset='+offset;
            }
            
            httpResponse = TCMSearchService.callout(url+params, token);
            
        }
        catch(NullPointerException e) {
            return null;
        }
        catch(CalloutException ce) {
            return null;
        }

        return httpResponse;
    }

    // Deserialize TCM search response into customer or contact objects
    public static Object deserialize(String jsonStr, Boolean isContact) {
        if(String.isNotBlank(jsonStr)) {
            if(isContact){
                JSON2TCMCustomerContactObject contacts = (JSON2TCMCustomerContactObject)JSON.deserialize(jsonStr, JSON2TCMCustomerContactObject.class);
                return contacts;
            } else {
                CustomerObject customer = (CustomerObject)JSON.deserialize(jsonStr, CustomerObject.class);
                return customer;
            }
        }

        return null;
    }

    // Create account from TCM search response
    public static Account importAccount(TCMDataObject.Customer selectedCustomer) {
        Account acc = new Account();
        acc = TCMUtil.mapCustomerDataToAccount(selectedCustomer, acc);
        acc.Imported__c = true;               
        acc.Data_Sovereign_Status__c = 'SFDC Integration';
    
        insert acc;
        return acc;
    }

    // Create address and account-address relationships from TCM search response
    public static void importAddresses(TCMDataObject.Customer selectedCustomer, Account account) {
        if(String.isNotBlank(account.Id) && selectedCustomer.address != null) {
            TCMUtil.checkAndCreateAccountAddressRelationships(selectedCustomer.address,account.Id);            
        }
    } 

    // Create contacts and account-contact relationships from TCM search response
    public static void importContacts(JSON2TCMCustomerContactObject customerContact, TCMDataObject.Customer selectedCustomer, String accountId) {
        if(String.isNotBlank(accountId) && customerContact != null && customerContact.data != null &&  String.isNotBlank(customerContact.data.id) ) {   
            if(customerContact.data.contacts != null && customerContact.data.contacts.size()>0) {
                TCMUtil.checkAndCreateAccountContactRelationships(customerContact.data.contacts, accountId);
            }                                                
        }
    }
    // Convert the lead based on the leadId and account ID provided. No opportunity will be created
    public static void convertLead(String leadId, String accId){
        			//Finding the email 
        			 if(String.isNotBlank(leadId)){
            			List<Lead> leadRec = [SELECT Id,Email FROM Lead WHERE Id = :leadId LIMIT 1]; 
                     }
     				//Convert Lead
                    Database.LeadConvert lc = new Database.LeadConvert();
        			LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        			Contact randomContact = [SELECT Id FROM Contact where accountid =:accId LIMIT 1];
                    
					lc.setLeadId(leadId);
					lc.setAccountId(accId);
                        if(randomContact!=null && randomContact.id!=null)
                        {
                        lc.setContactId(randomContact.id);
                        }
					lc.setConvertedStatus(convertStatus.MasterLabel);
        			lc.setDoNotCreateOpportunity(true);
					Database.LeadConvertResult lcr = Database.convertLead(lc);
                    System.debug('IS LEAD CONVERT SUCCESS?'+ lcr.isSuccess());
                     
        
    }
	*/
                    
            
}