/**
* @Description : Get Customer and Contacts from TCM application based on CIDN and insert/update in Force.com.
* @Author : ChandrakanthReddy B.
* @Date : 14/Nov/2017
* @Story : EDGE-4090
* @Story : EDGE-34, @Author : Anu Yadav, @Date : 29/11/2017 
*/
public class TCMGetInterface {
    
    public Map<String, CustomerObject.customer> tcmCustomerObject{private set; get;}
    public Map<String, JSON2TCMCustomerContactObject> tcmContactObject{private set; get;}
    public Map<String, JSON2TCMCustomerContactObject.ErrorMessage> tcmCustomerError{private set; get;}
    public Map<String, ContactObject> tcmGetContactObject{private set; get;}
    private TCMGetInterfaceHelper getInterfaceHelper = null;

    public Map<String, TCMRequestResponseCapture> callOutDataCapture {private set; get;}
    
    public Class TCMRequestResponseCapture{
        public String url{get; set;}
        public String key{get;set;}
        public HttpResponse httpResponse{get; set;}
        public TCMRequestResponseCapture(String url, HttpResponse httpResponse){
            this.url = url;
            this.httpResponse = httpResponse;
        }
        public TCMRequestResponseCapture(String url, String key, HttpResponse httpResponse){
            this.url = url;
            this.key = key;
            this.httpResponse = httpResponse;
        }
    }
    
	//Get Interface should be singleton.
    private TCMGetInterface(){
        tcmCustomerObject = new Map<String, CustomerObject.customer>();
        tcmContactObject = new Map<String, JSON2TCMCustomerContactObject>();
        tcmCustomerError = new Map<String, JSON2TCMCustomerContactObject.ErrorMessage>();
        tcmGetContactObject = new Map<String, ContactObject>();
        callOutDataCapture = new Map<String,TCMRequestResponseCapture>();
        getInterfaceHelper =  TCMGetInterfaceHelper.getInstance();
    }
    
    private static TCMGetInterface instance = null;
    
    public static TCMGetInterface getInstance(){
        if(instance == null) instance = new TCMGetInterface();
        return instance;
    }
    
    public void getCustomer(String cidn){
        //TCMCustomerContactHelper tcmHelper = new TCMCustomerContactHelper();
        HttpResponse customerResponse = getInterfaceHelper.tcmCallout(cidn, null, false);
        if(customerResponse != null){
            Integer statusCode = customerResponse.getStatusCode();
            if(statusCode == 200 || statusCode == 400 || statusCode == 500){
                JSON2TCMCustomerContactObject.ErrorMessage errorcodeobj = (JSON2TCMCustomerContactObject.ErrorMessage)JSON.deserialize(customerResponse.getBody(), JSON2TCMCustomerContactObject.ErrorMessage.class);
                if(errorcodeobj != null && errorcodeobj.message == null){
                    CustomerObject tcmCustomerObj = (CustomerObject)JSON.deserialize(customerResponse.getBody(), CustomerObject.class);
                    for(CustomerObject.customer cust : tcmCustomerObj.data.customers){
                        if(cust.customerAccount != null){
                            tcmCustomerObject.put(cust.cidn, cust);
                            callOutDataCapture.put(cust.cidn, new TCMGetInterface.TCMRequestResponseCapture
                                                   (getInterfaceHelper.requestMapURL.get(cidn),cidn,customerResponse));
                        }
                    }
                } else {
                    tcmCustomerError.put(cidn, errorcodeobj);
                    callOutDataCapture.put(cidn, new TCMGetInterface.TCMRequestResponseCapture
                                           (getInterfaceHelper.requestMapURL.get(cidn),cidn,customerResponse));
                }
            } else {
                callOutDataCapture.put(cidn, new TCMGetInterface.TCMRequestResponseCapture
                                           (getInterfaceHelper.requestMapURL.get(cidn),cidn,customerResponse));
                throw new TCMException.TCMCallOutException(customerResponse.getStatus()+ ' : '+customerResponse.getStatusCode());
            }
        }
    }
    
    public void getCustomerContact(String masterID){
        System.debug('MasterID : ' + masterID);
        //TCMCustomerContactHelper tcmHelper = new TCMCustomerContactHelper();
        HttpResponse contactResponse = getInterfaceHelper.tcmCallout(null, masterID, true);
        if(contactResponse != null){
            Integer statusCode = contactResponse.getStatusCode();
            if(statusCode == 200){
                JSON2TCMCustomerContactObject.ErrorMessage errorcodeobj = (JSON2TCMCustomerContactObject.ErrorMessage)JSON.deserialize(contactResponse.getBody(), JSON2TCMCustomerContactObject.ErrorMessage.class);
                if(errorcodeobj != null && errorcodeobj.message == null){
                    JSON2TCMCustomerContactObject customerContact = (JSON2TCMCustomerContactObject)JSON.deserialize(contactResponse.getBody(), JSON2TCMCustomerContactObject.class);    
                    if(customerContact != null){
                        tcmContactObject.put(masterID, customerContact);
                        callOutDataCapture.put(masterID, new TCMGetInterface.TCMRequestResponseCapture
                                               (getInterfaceHelper.requestMapURL.get(masterID),masterID,contactResponse));
                    }                   
                } else {
                	tcmCustomerError.put(masterID, errorcodeobj);
                    callOutDataCapture.put(masterID, new TCMGetInterface.TCMRequestResponseCapture
                                           (getInterfaceHelper.requestMapURL.get(masterID),masterID,contactResponse));
                }
            } else {
                callOutDataCapture.put(masterID, new TCMGetInterface.TCMRequestResponseCapture
                                           (getInterfaceHelper.requestMapURL.get(masterID),masterID,contactResponse));
                throw new TCMException.TCMCallOutException(contactResponse.getStatus()+ ' : '+contactResponse.getStatusCode());
            }
        }
    }
    
    public void getContactInfo(List<String> contactUUIDs){
        //TCMCustomerContactHelper tcmHelper = new TCMCustomerContactHelper();
        for(String uuid : contactUUIDs){
            System.debug('Contact uuid : ' + uuid);
            HttpResponse contactResponse = getInterfaceHelper.tcmGetContactInfoCallout(uuid);
            if(contactResponse != null && contactResponse.getStatusCode() == 200){
                JSON2TCMCustomerContactObject.ErrorMessage errorcodeobj = (JSON2TCMCustomerContactObject.ErrorMessage)JSON.deserialize(contactResponse.getBody(), JSON2TCMCustomerContactObject.ErrorMessage.class);
                if(errorcodeobj != null && errorcodeobj.message == null){
                    ContactObject contacts = ContactObject.parse(contactResponse.getBody());
                    //ContactObject contacts = (ContactObject)JSON.deserialize(contactResponse.getBody(), ContactObject.class);
                    tcmGetContactObject.put(uuid, contacts);
                } else {
                    tcmCustomerError.put(uuid, errorcodeobj);
                }
                callOutDataCapture.put(uuid, new TCMGetInterface.TCMRequestResponseCapture
                                       (getInterfaceHelper.requestMapURL.get(uuid),uuid,contactResponse));
            } else if(contactResponse != null) {
                callOutDataCapture.put(uuid, new TCMGetInterface.TCMRequestResponseCapture
                                       (getInterfaceHelper.requestMapURL.get(uuid),contactResponse));
            }
        }
    }
    
}