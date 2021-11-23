/*
DESCRIPTION: EAST address search controller 
AUTHOR: Sooraj George 24/07/2016
*/

public with sharing class EASTAddressSearchController {
          
    //private static String searchURL; //= '/v1/address-search/addresses?';
    private String urlSearchString ='';
    //private String baseUrl; //= 'https://cb.test.dev.telstra.com/org006/slot6';
    //private String tokenUrl;// = 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token';
    //private static String oauth_grant_type = 'client_credentials';
    //private static String search_scope = 'ADDRESSSEARCH';
    private static Integer numAddressReturned = 25;
    
    //attributes for VF component
    public String searchString {get; set;}
    public String objId {get; set; }
    public String objType {get; set;}
    public String pgMessage {get; set;}
    
    //List of EastAddesses to be displayed on Search page
    public List<EASTAddressSearchController.AddressSummary> addressList {get; set;}
    private Map<String, EASTAddressDataObject.EASTAddress> addressMap {get; set;}
    //selected address
    public String selectedId {get; set;}
    public EASTAddressDataObject.EASTAddress selectedAddress {get; set;}
  
    //constructor
    public EASTAddressSearchController(){
        //retrieve  url from custom settings
    //   baseUrl = EnvironmentVariable.get('okapi_base_url');
     //  tokenUrl = EnvironmentVariable.get('okapi_tokenUrl');
       //clearVar();
      //runSearch();
    }
  
    // runs the search with parameters passed via Javascript
    public void runSearch() {
        addressMap = new Map<String, EASTAddressDataObject.EASTAddress>();
        String addressLine1 = searchString;
        clearVar();
        System.debug('param: '+ addressLine1);
        urlSearchString = EnvironmentVariable.get('okapi_base_url') + EnvironmentVariable.get('okapi_east_url');// baseUrl + searchURL;
        if(addressLine1!=null)
        if(!('').equals(addressLine1) && addressLine1.length()>5) {
          
          urlSearchString += 'searchLine1=';
          urlSearchString += EncodingUtil.URLEncode(addressLine1+'&numberOfAddressesToReturn='+numAddressReturned,'UTF-8');
         // searchString = EncodingUtil.URLEncode(urlSearchString,'UTF-8');
          // run the api call
          fetchResults(urlSearchString);
        }
        // return null;
    }
  
    //function to run EAST api call
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
                        if(edo.data.size() == 0){pgMessage = 'No addresses found. Try entering more details.';}
                            for(EASTAddressDataObject.EASTAddress e : edo.data){ 
                                if(e.id!=null && (e.state!=null && e.postcode!=null)) {
                                    addressList.add(aSummarize(e));
                                    addressMap.put(e.id, e);
                                }
                            } 
                    }
                } else {
                    pgMessage = 'Something went wrong! Code: '+ adResponse.getStatusCode() + ' '+ adResponse.getStatus();
                }
        } catch(Exception e){
                pgMessage = 'Something went wrong! '+ e.getMessage();
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot find address!'));
        }
    }
    
    //get token method
    public static String getToken(String tnUrl) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        // retrieve tokenurl from custom settings
        req.setEndpoint(tnUrl);
        // retrieve tokenurl from custom settings
        req.setBody('client_id=' + EncodingUtil.urlEncode(EnvironmentVariable.get('okapi_client_id'), 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(EnvironmentVariable.get('okapi_client_secret') , 'UTF-8') +
                    '&grant_type=' + EncodingUtil.urlEncode('client_credentials', 'UTF-8') +
                    '&scope=' + EncodingUtil.urlEncode('ADDRESSSEARCH', 'UTF-8'));
                    
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        
        // parse the access token and store into the custom settings for subsequent use.
        Map<String, String> result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
        String token = result.get('access_token');
        
        return token;
    }  
    
    //send search request method
    public static HttpResponse httpCallout(String s_url, String token) {

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        Logger2 logger = Logger2.getLogger('EASTAddressSearch');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(s_url);
        req.setMethod('GET');
        try{
             res = h.send(req);
             if(res.getStatusCode() == 200){
                logger.logMessages(req.getBody(), res.getBody(), '', '', '', '', false, false);
        
            } else {
                logger.logMessages(req.getBody(), res.getBody(), '', '', res.getStatus()+': '+res.getStatusCode(), '', false, false);
            }
        }catch(Exception e){
            logger.logMessages(req.getBody(), res.getBody(), e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
            //throw e;
        }
        logger.exitLogger();
        return res;
    }

    //select address action
    public void selectRow(){
        System.debug('!@#$% Attempting to select a row . EASTAddressSearchController.selectRow()');
        System.debug('Selected Id: '+ selectedId);
        selectedAddress = addressMap.get(selectedId);
        
        /*
        cscrm__Address__c c = saveAddress();
        if(c.Id != null){
            PageReference pg = new PageReference('/'+c.Id);
            pgMessage = 'Address added successfully. '+pg.getUrl();
        }
				
        clearVar();
		*/
        System.debug('selected add: '+selectedAddress);
        //return null;
     }
    
    //clear variables
    private void clearVar(){
        addressList = new List<AddressSummary>();
        searchString = '';
        pgMessage = '';
    }
    
    //compact address for summary object
    private EASTAddressSearchController.AddressSummary aSummarize(EASTAddressDataObject.EASTAddress e){
        String stNumber ='';
        String adLine='';
        EASTAddressSearchController.AddressSummary aSum;
        if(e.numberZ != null){
            stNumber = e.numberZ;
            if(e.numberPrefix != null) {stNumber = e.numberPrefix + stNumber; }
            if(e.numberSuffix != null) {stNumber = stNumber +e.numberSuffix; }
        }
        if(e.numberTo!=null){
            String numTo = '';
            if(e.numberToPrefix != null) {numTo = e.numberToPrefix + numTo; }
            if(e.numberToSuffix != null) {numTo = numTo +e.numberToSuffix; }
            stNumber += numTo;
        }
        adLine = e.numberZ+' '+e.streetName+' '
                                  +e.streetType;
        adLine.replace('null', ' ');
      //  System.debug('asummary: '+stNumber+', '+adLine);
        return new EASTAddressSearchController.AddressSummary(e.id, adLine, e);
    }
    
    /*
     * Getters and setters
     * */
    public void setselectedId(String sid) {
        this.selectedId = sid;
    }
    
    public EASTAddressDataObject.EASTAddress getselectedAddress() {
        return this.selectedAddress;
    }
    
    public void setsearchString(String sStr){
        this.searchString = sStr;
    }
   
    //save address to cscrm
    public PageReference saveAddress() {
        System.debug('Attempting to save address');

        cscrm__Address__c csad = new cscrm__Address__c();
        {
            if(selectedAddress == null){
                return null;
            }
            try{
                 
                csad.cscrm__External_ID__c = selectedAddress.id;
                csad.Address_Line_1__c = aSummarize(selectedAddress).addressLine;
                csad.Address_Type__c = selectedAddress.addressType;
                csad.cscrm__Zip_Postal_Code__c = selectedAddress.postcode;
                csad.Locality__c = selectedAddress.locality;
                csad.cscrm__State_Province__c = selectedAddress.state;
                if(objId != '' && objType.equalsIgnoreCase('account'))
                    csad.cscrm__Account__c = Id.valueOf(objID);
                csad.Address_Status__c = selectedAddress.status;
                
                Database.SaveResult s = Database.insert(csad);
                

                System.debug('insert: '+ s);
                if(s.isSuccess()) {csad.id=s.id;}
                else {csad = null;}
            }
            catch(Exception ex){
                System.debug('Address save error: '+ ex.getMessage());
            }
        }
        return null;
    }
    
    //Address summary class
    public class AddressSummary{
        public String addressId {get; set;}
        public String addressLine {get; set;}
        public String addressType {get; set;}
        public String locality {get; set;}
        public String state {get; set;}
        public String postcode {get; set;}
        public String numberStart {get; set;}
        //EASTAddressDataObject.EASTAddress eastAddress {get; set;}
        
        public AddressSummary(String aId, String aLine, EASTAddressDataObject.EASTAddress e){
            addressId = aid;
            addressLine = aLine;
            addressType = e.addressType;
            locality = e.locality;
            state = e.state;
            postcode = e.postcode;
            numberStart = e.numberZ;
            //eastAddress = e;
        }
    }
    
}