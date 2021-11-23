/*************************************************************************************************
Name : SQButtonContentHandler
EDGE-> 72901
Description : To Make Callout To Initiate SQ for Site
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Rohit Tripathi     16/04/2019     To initiate the NBN SQ from the product configuration page
2.        Shubhi Vijayvergia 7/02/2019      Edge-93552 Intiate SQ update  
===============================================================================================================================
***************************************************************************************************/

public without sharing class SQButtonContentHandler {
    // Initialising Variables To store NBN Fields
    public String addressid {get; set;}
    public String accId {get; set;}
    public String markSQRequired {get; set;}
    public String SQCheckDone {get; set;}
	public static final String handler =  'SiteSQAddressHandler';
    public String alertType {get;set;}
    public SQButtonContentHandler() {
        System.debug(LoggingLevel.INFO, 'SQButtonContentHandler.SQButtonContentHandler');
        markSQRequired = 'false';
        String unescapedaddressid = ApexPages.currentPage().getParameters().get('adborId'); // Fetching Adbord ID from VF Page
        String unescapedaccId = ApexPages.currentPage().getParameters().get('accountId'); // Fetching Account ID from VF Page
        addressid = EncodingUtil.urlEncode(unescapedaddressid, 'UTF-8'); // Converting To UTF-8 format
        accId = EncodingUtil.urlEncode(unescapedaccId, 'UTF-8'); // Converting To UTF-8 format
    }

    public PageReference callSQService() {
        addressid = addressid;
        SqResponseDTO responseDTO = null;
        Map<String, HttpResponse> addressToResponseMap = new Map<String, HttpResponse>();
        HttpResponse res;
        try {
            List<String> addressList = new List<String>();
            addressList.add(addressid);//Edge-93552
            String token = AuthenticationManager.getOauthToken(handler);//Edge-93552
            SQcheckCalloutHandler sqCalloutHandler = new SQcheckCalloutHandler(addressList,accId);//Edge-93552
            SiteSQContractCalloutHandler sqHandler = new  SiteSQContractCalloutHandler();
            //DIGI-2540 code refactoring changes
            responseDTO = sqCalloutHandler.callSQService(token,'');
            system.debug('---responseDTO ' + responseDTO);
            
            Integer resultCode = responseDTO.code;
            if (resultCode != null && (resultCode == 200 || resultCode == 201 || resultCode == 202)) {
                System.debug('----->Inside 200 status code <-----');
            	SQCheckDone = 'true';
            }
			return null;
        } catch (Exception e) {
            system.debug('Error in callSQService ' + e);
            return null;
        }
    }  
}