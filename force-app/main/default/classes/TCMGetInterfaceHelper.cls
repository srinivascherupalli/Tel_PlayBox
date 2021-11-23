/**
* @Description : Get Customer and Contacts from TCM application based on CIDN and insert/update in Force.com.
* @Author : ChandrakanthReddy B.
* @Date : 14/Nov/2017
* @Story : EDGE-4090
* @Story : EDGE-34, @Author : Anu Yadav, @Date : 29/11/2017 
*/
public class TCMGetInterfaceHelper {
    
    private string token;
    private static final String MOCK_URL = 'http://mocksandbox.getsandbox.com/search';
    private static TCMGetInterfaceHelper instance = null;
    public Map<String,String> requestMapURL{private set;get;}
    
    private TCMGetInterfaceHelper(){
        requestMapURL = new Map<String,String>();
    }
    
    public static TCMGetInterfaceHelper getInstance(){
        if(instance == null) instance = new TCMGetInterfaceHelper();
        return instance;
    }
    
    public HttpResponse tcmCallout(String cidn, String masterId, boolean includeContacts){
        Integer offset = 0;
        Integer upper_limit = Integer.valueOf(Label.CUSTOMER_SEARCH_PAGE_SIZE);
        IntegrationSettings__c is = IntegrationSettings__c.getOrgDefaults();
        String url = (is.EnableMocks__c) ? MOCK_URL : EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts';
        if(cidn != null && String.isNotBlank(cidn)){
            url += '?cidn=' + cidn + '&limit='+upper_limit+'&offset='+offset;	
            requestMapURL.put(cidn, url);
        }
        if(masterId != null && String.isNotBlank(masterId)){
            url += '/'+masterId + '?limit='+upper_limit+'&offset='+offset;
            url += (includeContacts) ? '&include=contacts' : '';
            requestMapURL.put(masterId, url);
        }
        return tcmCallOuts(url);
    }
    
    public HttpResponse tcmGetContactInfoCallout(String uuid){
        Integer offset = 0;
        Integer upper_limit = Integer.valueOf(Label.CUSTOMER_SEARCH_PAGE_SIZE);
        IntegrationSettings__c is = IntegrationSettings__c.getOrgDefaults();
        String url = (is.EnableMocks__c) ? MOCK_URL : EnvironmentVariable.get('tcm_contactEndpoint');
        url = url + '/' +uuid + '?include=customer-accounts&limit='+upper_limit+'&offset='+offset;
        requestMapURL.put(uuid, url);
        return tcmGetContactCallOuts(url);
    }
    
    private HttpResponse tcmGetContactCallOuts(String url){
        HttpResponse response = null;
        try{
            System.debug('TCMCustomerContactHelper - TCM Callout url : ' + url );
            //if(token == null && String.isNotBlank(token)) 
            token = TCMApiHelper.getTCMContactToken();
            response = TCMApiHelper.tcmCallout(url, token);
        } catch(Exception e){
            System.debug('Message : ' + e.getMessage());
            //throw new TCMException.TCMCallOutException(e.getMessage(), e);
        }
        return response;
    }
    
    /**
    * Callouts for Getting Customer Records and Contact Records assoicated to Customer.
    */
    private HttpResponse tcmCallOuts(String url){
        HttpResponse response = null;
        try{
            System.debug('TCMCustomerContactHelper - TCM Callout url : ' + url );
            //if(token == null && String.isNotBlank(token)) 
            token = TCMSearchManager.getTCMToken();
            response = TCMSearchService.tcmCallOut(url, token);
        } catch(Exception e){
            System.debug('Message : ' + e.getMessage());
            throw new TCMException.TCMCallOutException(e.getMessage(), e);
        }
        return response;
    }
    
}