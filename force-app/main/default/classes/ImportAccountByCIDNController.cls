/* Date: 17-May-17 : Methods in the class have been commented by Nirvana Team to resolve merge issues for Edge R2a Sprint 17.0.1 TCM Integration functionality */ 
/*
AUTHOR      : Priyanka Manoharan
DESCRIPTION : Import Account and its related Contacts, Addresses, Account-Contact and Account-Address 
              from TCM based on a CIDN value in Lead record
*/
public class ImportAccountByCIDNController {
    
	public ImportAccountByCIDNController(){}
	/*
    public static String result {get;set;}
    public static Object obj {get; set;}
    public static JSON2TCMCustomerContactObject customerContact {get; set;}
    public static CustomerObject customer {get; set;}
    
    public static Account a;
    public static TCMDataObject.Customer selectedCustomer {get; set;}
    
    public static String masterId {get; set;}
    public static Boolean includeContacts = false;
    public static String cidn {get; set;}
    public static String sourceleadId {get; set;}
   // public static String leadEmail 	{get ; set; }
    
    
    public static String params {get; set;}
    
    private static final Integer upper_limit = Integer.valueOf(Label.CUSTOMER_SEARCH_PAGE_SIZE);
    public static Integer offset {get; set;}
    
    // Reset state
    public static void initialise() {
        System.debug('!@#$% Attempting to initialise variables');
        result = '';
        params = '';     
    }
    
    //Import Account and its related Contacts, Addresses, Account-Contact and Account-Address from TCM
    public static String importAccountCIDN()
    {
        try
        {                                       
            System.debug('!@#$% Attempting to import selected customer account');
            if(selectedCustomer != null && selectedCustomer.customerAccount != null)
            {
                System.debug('PP selectedCustomer.cidn : '+selectedCustomer.cidn);
                System.debug('PP selectedCustomer.masterID : '+selectedCustomer.masterID);
                List<Account> aList = CustomerSearchHelper.searchAccountsByCAC(selectedCustomer.cac);
                
                if(aList.size() > 0){
                     
                     String accId = aList.get(0).Id;
                    //Convert Lead - Commented by Arun Nair
                    //CustomerSearchHelper.convertLead(sourceleadId, accId);
                    return accId;
                }
                else if(selectedCustomer.customerAccount.dataSovereignty.toLowerCase() == EnvironmentVariable.get('exclusion'))
                {                
                    return null;
                }                
                else
                {                    
                    // Retrieve Contacts by a second callout to TCM
                    system.debug('trying to import contacts' + selectedCustomer );
                    includecontacts =true;
                    masterId = selectedCustomer.masterID; 
                    System.debug('PP masterId : '+masterId);
                    
                    HTTPResponse httpResp = new HTTPResponse();
                    if(masterId != null && masterId != '') {
                        params = CustomerSearchHelper.getParamsForMasterIdSearch(masterId, includeContacts);
                        httpResp = CustomerSearchHelper.searchTCM(params, includeContacts, offset, upper_limit);
                        
                        obj = CustomerSearchHelper.deserialize(httpResp.getBody(), includeContacts);
                        customerContact = (JSON2TCMCustomerContactObject)obj;
                    }                    
                    
                    // Create Account
                    a = CustomerSearchHelper.importAccount(selectedCustomer);
                    System.debug('!@#$% Account inserted : ' + a.Id);
                    
                    // Create Addresses with Account-Address Relationships
                    CustomerSearchHelper.importAddresses(selectedCustomer, a);
                    
                    // Create Contacts with Account-Contact Relationships
                    CustomerSearchHelper.importContacts(customerContact, selectedCustomer, a.Id);
                    
                    //Convert Lead - Commented by Arun Nair
                    CustomerSearchHelper.convertLead(sourceleadId, a.Id);
                        
                   return a.Id;                    
                }
            }
            else 
            {
                return null;
            }
        }
        catch(Exception e)
        {
            System.debug('!@#$% Import account creation exception !');
            return null;
        }
    }
    
    //Every CIDN should ideally return one customer account from TCM. This method assigns the result from TCM to selectedCustomer
    public static void selectCustomerCIDN(){
        
        if(customer != null && customer.data != null && customer.data.customers != null){
            for(TCMDataObject.Customer cust : customer.data.customers)
            {
                if(cust.customerAccount != null){
                    if(cust.customerAccount.accountUuid != null && cust.customerAccount.accountUuid != ''){
                        selectedCustomer = cust; 
                        System.debug('!@#$% Attempting to select a row . Selected Customer account UUID : ' + selectedCustomer);
                    }
                }    
            }    
        }        
    }
    
    //Query CIDN from Lead record
    @AuraEnabled
    public static String getCIDN(String leadid){
        if(String.isNotBlank(leadId)){
            List<Lead> leadRec = [SELECT CIDN__c FROM Lead WHERE Id = :leadId];            
            String cidnVal = !leadRec.isEmpty() && leadRec != null ? leadRec.get(0).CIDN__c : null;
           
            System.debug('CIDN val : ' + cidnVal);
            
            return cidnVal;
        }
        return null;
    }
    
    //Method that imports account and its related data using the leadId id passed through lightning component
    @AuraEnabled
    public static String getLeadSearchByCIDN(String leadId){  
        cidn = getCIDN(leadId);
        sourceleadId=leadId;
        String accID;
        String body = '';
        HTTPResponse httpResp = new HTTPResponse();
        
        initialise();
        System.debug('!@#$% Searching by CIDN from Lead: ' + cidn);
        if(cidn != null && cidn != ''){
            List<Account> accObj = [SELECT Id, CIDN__c FROM Account WHERE CIDN__c = :cidn];
            if(!accObj.isEmpty()){
                String localAccId = accObj.get(0).Id;
                System.debug('accObj Id : '+localAccId);
                //Convert Lead - Commented by Arun Nair
                CustomerSearchHelper.convertLead(sourceleadId, localAccId);
                return localAccId;
            }
            params = params + CustomerSearchHelper.getParamsForCidnSearch(cidn);
            offset = 0;
            httpResp = CustomerSearchHelper.searchTCM(params, true, offset, upper_limit);
            body = httpResp.getBody();
            System.debug('!@#$% HTTP Response Body : ' + body);                
            result = body;            
            System.debug('Convert call from Advanced search ' );
            obj = CustomerSearchHelper.deserialize(body, includeContacts);
            if(includeContacts) {
                customerContact = (JSON2TCMCustomerContactObject)obj;    
            } else {
                customer = (CustomerObject)obj;
            }
            selectCustomerCIDN();
            System.debug('PP selectedCustomer : '+selectedCustomer);
            accID = importAccountCIDN();  
			
			//if(accID!=null)
            //CustomerSearchHelper.convertLead(sourceleadId, accID);
			
			}
        return accID;                
    }
    
    //Imports Legacy Addresses
    @AuraEnabled
    public static void getLegacyAddress(String accId){
        List<cscrm__Address__c> addressList = new List<cscrm__Address__c>();
        if(!String.isEmpty(accId)){
            addressList = ReplicatorManager.getCustomerAddresses(accId);
            System.debug('PP addressList : '+addressList);
        }
        List<String> addIds = new List<String>();
        for(cscrm__Address__c add : addressList){
            addIds.add(add.Id);
        }
        System.debug('PP addIds : '+addIds);
        Map<Id,List<cscrm__Account_Address_Relationship__c>> existingAccAddrRelations = TCMUtil.checkAccountAddressRelationshipExistList(addIds,accId);
        System.debug('!@#$% existingAccAddrRelations : ' + existingAccAddrRelations);
        List<cscrm__Account_Address_Relationship__c> accountAddressRelationships = new List<cscrm__Account_Address_Relationship__c>();
        for(cscrm__Address__c addr : addressList){
            if(existingAccAddrRelations != null){
                if(existingAccAddrRelations.get(addr.Id) == null)
                    accountAddressRelationships.add(TCMUtil.createAccountAddressRelationship(accId, addr.Id,addr.Address_Type__c));
            }
            else
                accountAddressRelationships.add(TCMUtil.createAccountAddressRelationship(accId, addr.Id,addr.Address_Type__c));
        }
        System.debug('PP accountAddressRelationships : '+accountAddressRelationships);
        if(!accountAddressRelationships.IsEmpty())
            upsert accountAddressRelationships;
    }
    
    //Query for lead record based on id
    @AuraEnabled
    public static Lead getLead(String leadId){
        if(!String.isEmpty(leadId)){
            List<Lead> lead = [SELECT Id, Name, CIDN__c, Email FROM Lead WHERE Id = :leadId];
            System.debug('Lead rec : ' + lead);
            if(!lead.isEmpty() && lead != null)
                return lead.get(0);
        }
        return null;
    }
	*/
}