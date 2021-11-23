public class CustomerCreationController {
    
    // Variable and Object declarations
    public Account account;
    public Contact contact;
    
    public String abnValid {get; set;}
    public String acnValid {get; set;}
    public Boolean copyAddress {get; set;}
    public String searchString {get; set;}
    public String pgMessage {get; set;}
    
    public List<EASTAddressSearchController.AddressSummary> addressList {get; set;}
    public Map<String, EASTAddressDataObject.EASTAddress> addressMap {get; set;}
    
    public String selectedBillingAddressId {get; set;}
    public EASTAddressDataObject.EASTAddress selectedBillingAddress {get; set;}
    
    public String selectedMailingAddressId {get; set;}
    public EASTAddressDataObject.EASTAddress selectedMailingAddress {get; set;}
    
    private String urlSearchString ='';
    private static String oauth_grant_type = 'client_credentials';
    private static String search_scope = 'ADDRESSSEARCH';
    private static Integer numAddressReturned = 25;

    private static final String cnst_valid = 'valid';
    private static final String cnst_invalid = 'invalid';
    private static final String header_authorization = 'Authorization';
    private static final String header_contentType = 'Content-Type';
    private static final String http_method_get = 'GET';

    // getters
    public Account getAccount(){
      if(account == null) {
          account = new Account();
      }
      return account;
    }

    public Contact getContact(){
      if(contact == null) {
          contact = new Contact();
      }
      return contact;
    }
    
    public CustomerCreationController() {
        copyAddress = false;
    }
    
    // Save
    public PageReference createCustomer() {
        Savepoint sp = Database.setSavepoint();
        try{
            // Commit Account
            account.Data_Sovereign_Status__c = 'SFDC Integration';
            insert account;

            // Commit Contact
            contact.AccountId = account.Id;
            insert contact; 
            
            System.debug('!@#$% Copy Billing Address : ' + copyAddress);
            
            // Commit Billing Address
            cscrm__Address__c csadBilling = new cscrm__Address__c();
            
            if(selectedBillingAddress != null) {
				csadBilling = EASTAddressDataObjectUtils.createBillingAddressRecord(selectedBillingAddress, account.Id);
				
                Database.SaveResult s = Database.insert(csadBilling);
                
                System.debug('insert: '+ s);
                if(s.isSuccess()) {csadBilling.id=s.id;}
                else {csadBilling = null;}

            }

            // Commit Mailing Address
            cscrm__Address__c csadMailing = new cscrm__Address__c();
            
            if(selectedBillingAddress != null && copyAddress) {
                selectedMailingAddress = selectedBillingAddress;
            }

            if(selectedMailingAddress != null || copyAddress) {
                csadMailing = EASTAddressDataObjectUtils.createMailingAddressRecord(selectedMailingAddress, account.Id);
                Database.SaveResult s = Database.insert(csadMailing);
                
                System.debug('insert: '+ s);
                if(s.isSuccess()) {csadMailing.id=s.id;}
                else {csadMailing = null;}

            }

            // Redirect to newly created Account
            PageReference accountPage = new PageReference('/'+ account.id);
            accountPage.setRedirect(true);

            return accountPage; 
        }
        catch(Exception e) {
            System.debug('!@#$% Exception caught');
            
            Database.rollback(sp);
            if(!System.Test.isRunningTest()) {
            	PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
                pageRef.setRedirect(true);
                return pageRef;    
            }
        } 
        return null;
    }
    
    // Validate the legitimacy of an ABN
    public void validateABN() {
        Boolean valid = ABNValidator.runValidation(account.ABN__c);   
        if(valid){abnValid = cnst_valid;}
        else{abnValid = cnst_invalid;}
        
    }
    
    // Validate the legitimacy of an ACN
    public void validateACN() {
        Boolean valid = ACNValidator.runValidation(account.ACN__c);   
        if(valid){acnValid = cnst_valid;}
        else{acnValid = cnst_invalid;}
        
    }
    
    // Initiate search
    public void runSearch() {
        addressMap = new Map<String, EASTAddressDataObject.EASTAddress>();
        String addressLine1 = searchString;
        clearVar();
        System.debug('param: '+ addressLine1);
        urlSearchString = EnvironmentVariable.get('okapi_base_url') + EnvironmentVariable.get('okapi_east_url');// baseUrl + searchURL;
        if(addressLine1!=null)
        if(!addressLine1.equals('') && addressLine1.length()>5) {
          
          urlSearchString += 'searchLine1=';
          urlSearchString += EncodingUtil.URLEncode(addressLine1+'&numberOfAddressesToReturn='+numAddressReturned,'UTF-8');
         
          fetchResults(urlSearchString);
        }
    }
    
    // Grab search results
    public void fetchResults(String search_url){
        try{
            //run http requests here 
            String token = getToken(EnvironmentVariable.get('okapi_token_url'));
            System.debug('Search string: '+search_url);
            HttpResponse adResponse = httpCallout(search_url, token);
            System.debug('Response status code: '+adResponse.getStatusCode());
            if(adResponse.getStatusCode() == 200){
                System.debug('json'+adResponse.getBody());
                EASTAddressDataObject edo = EASTAddressDataObject.parse(adResponse.getBody());
                System.debug('obj: '+edo);
                if(edo != null){
                    if(edo.data.size() == 0){
                        pgMessage = 'No addresses found. Try entering more details.';
                    }
                    for(EASTAddressDataObject.EASTAddress e : edo.data){ 
                        if(e.id!=null && (e.state!=null && e.postcode!=null)) {
                            addressList.add(EASTAddressDataObjectUtils.aSummarize(e));
                            addressMap.put(e.id, e);
                        }
                    } 
                }
            } 
            else {
                pgMessage = 'Something went wrong! Code: '+ adResponse.getStatusCode() + ' '+ adResponse.getStatus();
            }
        } 
        catch(Exception e){
                pgMessage = 'Something went wrong! '+ e.getMessage();
        }
    }
    
    // Get appropriate access token to do address search
    public static String getToken(String tnUrl) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(tnUrl);
        req.setBody('client_id=' + EncodingUtil.urlEncode(EnvironmentVariable.get('okapi_client_id'), 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(EnvironmentVariable.get('okapi_client_secret') , 'UTF-8') +
                    '&grant_type=' + EncodingUtil.urlEncode('client_credentials', 'UTF-8') +
                    '&scope=' + EncodingUtil.urlEncode('ADDRESSSEARCH', 'UTF-8'));
        System.debug('!@#$% Body : ' + req.getBody());           
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        
        Map<String, String> result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
        String token = result.get('access_token');
        
        return token;
    }  
    
    // Do the HTTP callout
    public static HttpResponse httpCallout(String s_url, String token) {

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        Logger log = Logger.getLogger('AddressSearch');
        req.setHeader(header_authorization, 'Bearer ' + token);
        req.setHeader(header_contentType, 'application/json');
        req.setEndpoint(s_url);
        req.setMethod(http_method_get);
        try {
             res = h.send(req);
        }
        catch(Exception e) {
            log.debug(e);
            throw e;
        }
        log.logRequest(req.getBody(), true);
        log.logResponse(res.getBody(), true);
        return res;
    }
        
    // Select a billing address from the list
    public void selectBillingAddress(){
        System.debug('!@#$% Attempting to select a row . EASTAddressSearchController.selectRow()');
        System.debug('Selected Id: '+ selectedBillingAddressId);
        selectedBillingAddress = addressMap.get(selectedBillingAddressId);
        
        System.debug('selected add: '+selectedBillingAddress);
    }

    // Select a mailing address from the list
    public void selectMailingAddress(){
        System.debug('!@#$% Attempting to select a row . EASTAddressSearchController.selectRow()');
        System.debug('Selected Id: '+ selectedMailingAddressId);
        selectedMailingAddress = addressMap.get(selectedMailingAddressId);
        
        System.debug('selected add: '+selectedMailingAddress);
    }
    
    // Reset variables
    private void clearVar(){
        addressList = new List<EastAddressSearchController.AddressSummary>();
        searchString = '';
        pgMessage = '';
    }
    
    public void copyTheAddress() {
        System.debug('!@#$% check box BEFORE : ' + copyAddress);
        if(copyAddress){
            copyAddress= false;
        }else {
            copyAddress= true;
        }
        System.debug('!@#$% check box AFTER : ' + copyAddress);
    }
    
    // Address summary data object
    /*
    public class AddressSummary{
        public String addressId {get; set;}
        public String addressLine {get; set;}
        public String addressType {get; set;}
        public String locality {get; set;}
        public String state {get; set;}
        public String postcode {get; set;}
        public String numberStart {get; set;}
        
        public AddressSummary(String aId, String aLine, EASTAddressDataObject.EASTAddress e){
            addressId = aid;
            addressLine = aLine;
            addressType = e.addressType;
            locality = e.locality;
            state = e.state;
            postcode = e.postcode;
            numberStart = e.number_Z;
        }
    }
	*/
}