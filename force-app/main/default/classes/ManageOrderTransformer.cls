/*
*	This need to be removed as part of 1710 NFB-4098
*/
@isTest
public class ManageOrderTransformer {
/*    
    public static List<AmdocsDTO.ManageOrderRequest> createManageOrderRequest(List<String> orderIds, Map<String, String> subscriptionIdMap, Map<Id, csord__Service__c> allServices, Map<Id, Map<String, String>> serviceAttributes,String eventType) {
        
        List<AmdocsDTO.ManageOrderRequest> requests = new List<AmdocsDTO.ManageOrderRequest>();
        System.debug('!@#$% all Services size ' + allServices.size());

        for(Integer o=0; o<orderIds.size(); o++) {
            System.debug('!@#$% Filtering out services by order ID : ' + orderIds.get(o));

            Map<Id, csord__Service__c> currentServices = filterServicesByOrderId(allServices, orderIds.get(o));
           
            AmdocsDTO.ManageOrderRequest mor = new AmdocsDTO.ManageOrderRequest();
            mor.version = Constants.VERSION;
            mor.operation = eventType;
            mor.marketType = Constants.MARKET_TYPE;
            mor.id = generateUniqueKey();
            mor.externalId = orderIds.get(o);
            mor.systemId = Constants.APPLICATION;
            mor.orderReasonCode  = Constants.DEFAULT_AMEND;
            List<AmdocsDTO.Characteristic> ordCharLst = new List<AmdocsDTO.Characteristic>();
            ordCharLst.add(createCharacteristic('Order_Submit_Date',String.valueOf(System.today())));
            
                   
            List<AmdocsDTO.Customer> ctLst = new List<AmdocsDTO.Customer>();
            System.debug('!@#$% Current Services size for this order ID : ' + currentServices.size());

            if(currentServices.size()>0){
                System.debug('currentServices.size in' +currentServices.values()[0]);
                String cidn = currentServices.values()[1].csord__Service__r.csord__Subscription__r.csord__Order__r.csord__Account__r.CIDN__c;
                String accountName = currentServices.values()[1].csord__Service__r.csord__Subscription__r.csord__Order__r.csord__Account__r.Name;
                String customerType = currentServices.values()[1].csord__Service__r.csord__Subscription__r.csord__Order__r.csord__Account__r.Type;
                System.debug('currentServices.size accountName ' + accountName);
           *//*     ordCharLst.add(createCharacteristic('Sales_Manager_ID',orderIds.get(o))); owner of the order record//TODO)
                ordCharLst.add(createCharacteristic('Order_Status',orderIds.get(o))); //TODO)*//*
                AmdocsDTO.Customer ct = new AmdocsDTO.Customer();
                ct.id = cidn;
                ct.name = accountName;
                ct.type = customerType;
                ct.role = Constants.ROLE_CUSTOMER;               
                ctLst.add(ct);

            }            

            mor.relatedParty = ctLst; 
            mor.orderCharacteristic = ordCharLst;  
            System.debug('mor.relatedParty ' + mor.relatedParty); 
            System.debug('mor ' + mor);        

            List<AmdocsDTO.Item> orderItemLst = new List<AmdocsDTO.Item>();

            System.debug('!@#$% Total Subscriptions : ' + subscriptionIdMap.size());
            
            // Order Item            
            for(Integer s=0; s<subscriptionIdMap.size(); s++) {
                
                Map<Id, csord__Service__c> filteredServices = filterServicesBySubscriptionId(currentServices, subscriptionIdMap.values()[s]);
                System.debug('!@#$% Services size for current subscription' + filteredServices.size());
                System.debug('!@#$% Filtered Services by subscription ID' + filteredServices);
                AmdocsDTO.Item orderItem = createOrderItem(filteredServices, serviceAttributes,eventType);
                orderItemLst.add(orderItem);
            }

            mor.orderItem = orderItemLst;

            requests.add(mor);
        }
            
        return requests;
    }
        
    // Create an OrderItem from Subscription
    private static AmdocsDTO.Item createOrderItem(Map<Id, csord__Service__c> services, Map<Id, Map<String, String>> serviceAttributes,String eventType) {
        
        AmdocsDTO.Item oItem = new AmdocsDTO.Item(); 
        AmdocsDTO.Product parentProduct;
        Id parentServiceId;
        Map<Id,List<AmdocsDTO.Product>> parentServiceToProduct = new Map<Id,List<AmdocsDTO.Product>>();
        Map<Id,AmdocsDTO.Product> childServiceToProduct = new Map<Id,AmdocsDTO.Product>();
        System.debug('!@#$% services list  : ' + services);
        System.debug('!@#$% serviceAttributes list  : ' + serviceAttributes);
        System.debug('!@#$% serviceAttributes list  : ' + serviceAttributes.size());

        for(Integer s=0; s<services.size(); s++) {
            System.debug('!@#$% PARENT services.values()[s].csord__Service__c   : ' + services.values()[s].csord__Service__c );
            System.debug('!@#$% PARENT services.values()[s] : ' + services.values()[s]);
            if(services.values()[s].csord__Service__c == null) {
                oItem.id = services.values()[s].id;
                oItem.action = eventType; 
                oItem.version = Constants.VERSION;
                //oItem.requestedCompletionDate = String.valueOf(services.values()[s].Customer_Requested_Date__c); 
                parentServiceId = services.values()[s].id;
                break;
            }
        }
        
        for(Integer s=0; s<services.size(); s++) {
            System.debug('!@#$% CHILD services.values()[s].csord__Service__c   : ' + services.values()[s].csord__Service__c );
            System.debug('!@#$% CHILD services.values()[s] : ' + services.values()[s]);

            if(services.values()[s].csord__Service__c != null){
                AmdocsDTO.Product childPrd = createProductItem(services.values()[s],serviceAttributes,false);
                List<AmdocsDTO.Product> childPrdLst;
                if(parentServiceToProduct.get(services.values()[s].csord__Service__c)==null){
                    childPrdLst = new List<AmdocsDTO.Product>();
                }else{
                    childPrdLst = parentServiceToProduct.get(services.values()[s].csord__Service__c);
                }
                childPrdLst.add(childPrd);
                parentServiceToProduct.put(services.values()[s].csord__Service__c,childPrdLst);
                childServiceToProduct.put(services.values()[s].id,childPrd);
            }else{
                parentProduct = createProductItem(services.values()[s],serviceAttributes,true);
            }
        }
        
        for(Id childServId : childServiceToProduct.keySet()){
            childServiceToProduct.get(childServId).productRelationship = createRelationship(parentServiceToProduct.get(childServId));
        }

        System.debug('!@#$% parentServiceId : ' + parentServiceId);
        System.debug('!@#$% parentServiceToProduct.get(parentServiceId) : ' + parentServiceToProduct.get(parentServiceId));
        if(parentServiceToProduct.get(parentServiceId) != null) {
            parentProduct.productRelationship = createRelationship(parentServiceToProduct.get(parentServiceId));
            oItem.product = parentProduct;     
        }
           
        return oItem;
    }

    private static List<AmdocsDTO.ProductRelationship> createRelationship(List<AmdocsDTO.Product> prdLst){
        System.debug('!@#$% INPUT prdLst : ' + prdLst);
        List<AmdocsDTO.ProductRelationship> relLst;
        if(prdLst!=null){
            relLst = new List<AmdocsDTO.ProductRelationship>();
            for(AmdocsDTO.Product prd : prdLst){
                System.debug('!@#$% inside for loop');
                AmdocsDTO.ProductRelationship rel = new AmdocsDTO.ProductRelationship();
                rel.type = Constants.PRODUCT_RELATIONSHIP_TYPE;  // TODO NEED TO DETERMINE WHICH FIELD VALUE FROM PRODUCT MODELING TO BE USED.
                rel.product = prd;
                relLst.add(rel);
            }
        }
        System.debug('!@#$% Returning : ' + relLst);
        return relLst;
    }

    private static AmdocsDTO.Product createProductItem(csord__Service__c serv, Map<Id, Map<String, String>> serviceAttributes, Boolean isParentService){

        System.debug('!@#$% Creating Product Item : Service Name : ' + serv.Name);
        System.debug('!@#$% Service Attributes size : ' + serviceAttributes.size());
        System.debug('!@#$% Service Attributes : ' + serviceAttributes);

        AmdocsDTO.Product prd  = new AmdocsDTO.Product();                
        AmdocsDTO.Place  plc  = new AmdocsDTO.Place();
        AmdocsDTO.Address add  = new AmdocsDTO.Address();
        AmdocsDTO.Contact ct  = new AmdocsDTO.Contact();
        AmdocsDTO.ContactMedium emailAdd = new AmdocsDTO.ContactMedium();
        AmdocsDTO.ContactMedium phn = new AmdocsDTO.ContactMedium();
        AmdocsDTO.Medium emailMed = new AmdocsDTO.Medium();
        AmdocsDTO.Medium phnMed = new AmdocsDTO.Medium();

        if(!isParentService){
            add.id = serv.csord__Service__r.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_ID__c;
            add.street1 = serv.csord__Service__r.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_Line_1__c;
            add.street2 = serv.csord__Service__r.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_Line_2__c;
            add.city = serv.csord__Service__r.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__City__c;
            add.stateOrProvince = serv.csord__Service__r.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__State_Province__c;
            add.country = serv.csord__Service__r.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Country__c;
            add.postcode = serv.csord__Service__r.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Zip_Postal_Code__c;
            ct.id = serv.csord__Service__r.csord__Subscription__r.Site__r.Primary_Contact__r.Id;
            ct.type = serv.csord__Service__r.csord__Subscription__r.Site__r.Primary_Contact__r.Contact_Type__c;
            ct.givenName = serv.csord__Service__r.csord__Subscription__r.Site__r.Primary_Contact__r.FirstName; 
            ct.familyName = serv.csord__Service__r.csord__Subscription__r.Site__r.Primary_Contact__r.lastname;
            ct.gender = serv.csord__Service__r.csord__Subscription__r.Site__r.Primary_Contact__r.FirstName; 
            ct.title = serv.csord__Service__r.csord__Subscription__r.Site__r.Primary_Contact__r.Salutation; 
            ct.MiddleName = serv.csord__Service__r.csord__Subscription__r.Site__r.Primary_Contact__r.MiddleName; 
            emailAdd.type = 'Email';
            emailMed.emailAddress = serv.csord__Service__r.csord__Subscription__r.Site__r.Primary_Contact__r.email;
            emailAdd.medium = emailMed;
            phn.type = 'Telephone';
            phnMed.number1 = serv.csord__Service__r.csord__Subscription__r.Site__r.Primary_Contact__r.Phone; 
            phn.medium = phnMed;
        }else{
            add.id = serv.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_ID__c;
            add.street1 = serv.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_Line_1__c;
            add.street2 = serv.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_Line_2__c;
            add.city = serv.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__City__c;
            add.stateOrProvince = serv.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__State_Province__c;
            add.country = serv.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Country__c;
            add.postcode = serv.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Zip_Postal_Code__c;
            ct.id = serv.csord__Subscription__r.Site__r.Primary_Contact__r.Id;
            ct.type = serv.csord__Subscription__r.Site__r.Primary_Contact__r.Contact_Type__c;
            ct.givenName = serv.csord__Subscription__r.Site__r.Primary_Contact__r.FirstName; 
            ct.familyName = serv.csord__Subscription__r.Site__r.Primary_Contact__r.lastname;
            ct.gender = serv.csord__Subscription__r.Site__r.Primary_Contact__r.FirstName; 
            ct.title = serv.csord__Subscription__r.Site__r.Primary_Contact__r.Salutation; 
            ct.MiddleName = serv.csord__Subscription__r.Site__r.Primary_Contact__r.MiddleName; 
            emailAdd.type = 'Email';
            emailMed.emailAddress = serv.csord__Subscription__r.Site__r.Primary_Contact__r.email;
            emailAdd.medium = emailMed;
            phn.type = 'Telephone';
            phnMed.number1 = serv.csord__Subscription__r.Site__r.Primary_Contact__r.Phone; 
            phn.medium = phnMed;
        }
        
        plc.address = add;
        List<AmdocsDTO.ContactMedium> contactMediums = new List<AmdocsDTO.ContactMedium>();   
        contactMediums.add(emailAdd);
        contactMediums.add(phn);
        ct.contactMedium = contactMediums;

        List<AmdocsDTO.Contact> ctLst = new List<AmdocsDTO.Contact>();
        ctLst.add(ct);

        plc.contact = ctLst;
        createOrderLineItem(prd,serv, serviceAttributes);
        return prd;
    }
    
    // Create an OrderLineItem from Service
    private static AmdocsDTO.Product createOrderLineItem(AmdocsDTO.Product prd, csord__Service__c service, Map<Id, Map<String, String>> serviceAttributes) {
        
        prd.id = service.Id;
        prd.action = Constants.PR; //TODO tp determine what type of action code is needed.
        AmdocsDTO.ProductSpecification spec = new AmdocsDTO.ProductSpecification();
        spec.code = service.Name;
        prd.productSpecification = spec;
        
        Map<String, String> attrs = serviceAttributes.get(service.Id);
        System.debug('!@#$% attrs : SERVICE NAME : ' + service.Name +' #####   ATTRS : '+ attrs);
        if(attrs != null && attrs.size() > 0) {
            List<AmdocsDTO.Characteristic> charLst = new List<AmdocsDTO.Characteristic>();
           
            List<String> keys = new List<String>();
            for(String s : attrs.keySet()) {
                keys.add(s);
            }
            
            for(String key : keys) {             
                charLst.add(createCharacteristic(key,attrs.get(key)));
            }
            prd.productCharacteristic = charLst;
        }
        
        return prd;
    }

    private static AmdocsDTO.Characteristic createCharacteristic (String key, String value){
        AmdocsDTO.Characteristic charItem = new AmdocsDTO.Characteristic();
        charItem.name = key;
        charItem.value = value;
        return charItem;
    }
    
    // Filter Services by Order ID
    private static Map<Id, csord__Service__c> filterServicesByOrderId(Map<Id, csord__Service__c> services, String orderId) {
        Map<Id, csord__Service__c> filtered = new Map<Id, csord__Service__c>();
        for(Integer i=0; i<services.size(); i++) {
            csord__Service__c serv = services.values()[i];
            if(serv.csord__Service__r.csord__Subscription__r.csord__Order__c == orderId || serv.csord__Subscription__r.csord__Order__c == orderId) {
                filtered.put(serv.Id, serv); 
            }
        } 
        return filtered;
    }
    
    // Filter Services by Subscription Id
    private static Map<Id, csord__Service__c> filterServicesBySubscriptionId(Map<Id, csord__Service__c> services, String subscriptionId) {
        Map<Id, csord__Service__c> filtered = new Map<Id, csord__Service__c>();
        for(Integer i=0; i<services.size(); i++) {
            csord__Service__c serv = services.values()[i];
            if(serv.csord__Service__r.csord__Subscription__r.Id == subscriptionId || serv.csord__Subscription__r.Id == subscriptionId) {
                filtered.put(serv.Id, serv);
            }
        }
        return filtered;
    }
    
    private static String generateUniqueKey() {
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        System.debug('!@#$% Generated Unique Key : ' + hexDigest);
        return hexDigest;
    }
*/    
}