/********************************************************
Class Name : EDISSingleManagerUsingNumber
Test Class : EDISSingleManagerUsingNumberTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description

1.            Shreya                 21/10/2019     EDGE-113553  Added callEDIS method 
2.            Prajakta               11/07/1019     Impact on EDIS-MS API to generate payload from Number Object record
3.            Ashish A.              29/11/2019     EDGE-92550 Added method getServiceSpecsDisconnect
4.            Vaibhav/Pawan          19/06/2020     Added null check for Telstra_Committed_Date__c
5.            Pooja                  22/02/2021     EDGE-152480 EDIS MS API request to provide incoming Customer details on directory listing for CHOWN of individual Mobility Subscription(s)
6.            Gunjan                 22/02/2020     EDGE-203562 EDIS MS API request to update outgoing Customer details on directory listing for CHOWN of individual Mobility Subscription(s)
7.            Sayantan               09/03/2021     EDGE-185863 EDIS-MS request generation to include correct order reference in case of cancellation (disconnection) of fixed dial-able numbers
8.            Sayantan               08/06/2021     EDGE-222599 Fix for directory update (DES API) issues: Mapping changes
**********************************************************
*/
public with sharing class EDISSingleManagerUsingNumber {
    
    public Class ListingFNNWrapper{
        public String orderId {get;set;}
        public String serviceId {get;set;}
        public String orderStatus {get;set;}
        public Boolean isTransition {get;set;}
        public String fnn {get;set;}
        public String listCode {get;set;}
        public Boolean isCease {get;set;}
        public Boolean isMobile {get;set;}
        public Boolean isPortOut {get;set;}
        public String oppType {get;set;}//EDGE-152480
        public String actionType {get;set;}//EDGE-152480
    }
    public List<ListingFNNWrapper> fnnWrapperList{get;set;}
    
    //Constants : a part of CODE SMELL correction
    private final static String PRODOFF323 = 'DMCAT_ProductOffering_000323';
    private final static String INPROGRESSS = 'In Progress';
    private final static String COMPLETE = 'Complete';
    private final static String NOENTRY = 'No Entry Line';
    private final static String LISTCODE = 'listCode';
    private final static String ACTIVE = 'ACTIVE';
    private final static String INTRANSITION = 'Transition';
    private final static String FNN = 'FNN';
    private final static String POST = 'POST';
    private final static String PATH = '/application/edis-eai/v3/directory-listings';
    private final static String TRANSITION = 'Transition (Change Svc Type)';
    private final static String ORDERPROVISIONED = 'Order Provisioned';
    private final static String ORDERCOMPLETED = 'Order Completed';
    private final static String CUSTOMERID = 'customerID';
    private final static String CUSTOMERTYPE = 'customerType';
    private final static String FAMILYNAME = 'familyName';
    private final static String GIVENNAMES = 'givenNames';
    private final static String REGISTEREDCOMPANYNAME = 'registeredCompanyName';
    private final static String CUSTOMERTITLE = 'customerTitle';
    private final static String CUSTOMERCONTACTNAME = 'customerContactGivenNames';
    private final static String CUSTOMERCONTACTFAMILYNAME = 'customerContactFamilyName';
    private final static String CONTACTFNN = 'contactFNN';
    private final static String CONTACTEMAIL = 'contactEmail';
    private final static String DEL = 'Delete';
    private final static String ADD = 'Add';
    private final static String TRANSITIONADD = 'Transition-Add';
    private final static String SCENARIOTYPE = 'scenarioType';
    private final static String CHANGEMOBILENUM = 'Change of Mobile Number';
    private final static String UPDATEACTION = 'Update';
    private final static String CCAID = 'ccaIdentifier';
    private final static String DISCONNECT = 'Disconnect';
    private final static String CONNECT = 'Connect';
    private final static String PROVISIONING = 'Provisioning';
    private final static String ORDER = 'order';
    private final static String ORDERID = 'orderID';
    private final static String PORTOUT = 'Port Out';
    private final static String BUSINESSDL = 'Business Directory Listing';
    private final static String TELSTRAADDRESSID = 'telstraAddressId';
    private final static String SOCREATIONTIME = 'soCreationTimestamp';
    private final static String TELSTRACOMITDATE = 'telstraCommitmentDate';
    private final static String SERVN = 'N';
    private final static String FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ssXXX';
    private final static String PRIMARYADDRESS = 'Primary Address';
    private final static String UNIFIEDCOMM = 'Unified Communication';
    private final static String TYPE = 'type';
    private final static String FAMILYORENTITYNAME = 'familyOrEntityName';
    private final static String ORGANIZATIONNAME = 'organizationName'; //EDGE-222599
    private final static String PENDING = 'pending';
    private final static String LISTINGFNN = 'listingFNN';
    private final static String RESIDENTIAL = 'Residential';
    private final static String SOLETRADER = 'Sole Trader';
    private final static String PERSONAL = 'Personal';
    private final static String COMPANY = 'Company';
    private final static String ORGANISATION = 'Organisation';
    private final static String WHOLESALE = 'Wholesale';
    private final static String NONPROFITORG = 'Non Profit Organisation';
    private final static String CHANGEFNN = 'Change FNN';
    private final static String ACTIVENUM = 'Active';
    private final static String PROVINPROG = 'Provisioning In Progress';
    private final static String DISCPENDING = 'Disconnect Pending';
    private final static String DISINPROGRESS = 'Disconnect In Progress';
    private final static String INACTIVENUM = 'Inactive';
    private final static String NEW1 = 'New';
    private final static String REPLACED = 'Replaced';  
    
    //EDGE-152480 start

    //private final static String CHOWNOPPTYPE = 'CHOWN (Change of Ownership)'; // Commenting as type value will be CHOWN

    private final static String CHOWN = 'CHOWN';
    //private final static String CHOWNIN = 'Chown In';
    private final static String CHOWNADD = 'CHOWN-Add';
    //EDGE-152480 end
    
    //EDGE-88646
    public static Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>();  
    public static string isProcessedfromBatch = 'false';
    /*@method name - callEDIS
@Jira Story Ref - EDGE-113553
@Created by - Shreya
@desc - This method gets called from DirectoryListingUsingNumber process builder and calls the respective method based on status received
*/
    @InvocableMethod
    public static void callEDIS(List<String> param)
    {   System.debug('param received :'+param);
     List<String> parameter = param[0].split(':::');
     String status;
     String srvcNumber;
     String num;
     if(parameter != null){
         status = parameter[0];
         srvcNumber = parameter[1];
         num = parameter[2];
                if(parameter.size()>3){
         isProcessedfromBatch = parameter[3];
                }
     }
     if(status.equals(ACTIVENUM) || status.equals(INACTIVENUM))
         processEDISOrderCompletion(srvcNumber,num);
     else if(status.equals(PROVINPROG))
         getServiceSpecs(srvcNumber,num);
     else if(status.equals(DISCPENDING))
         getServiceSpecsDisconnect(srvcNumber,num);
    }
    //Modified for EDGE-113553 formal arguement list modified
    public static void getServiceSpecs(String srvcNumber,String num)
    {
        List<ListingFNNWrapper> fnnWrapperList= new List<ListingFNNWrapper>();
        
        buildFNNWrapper(srvcNumber,num,INPROGRESSS,fnnWrapperList);
        
        system.debug('fnnWrapperList.size()'+fnnWrapperList.size());
        system.debug('fnnWrapperList'+fnnWrapperList);
        if(fnnWrapperList.size()>0){
            //System.debug('fnnWrapperList::' + fnnWrapperList); 
            
            buildEDISPayload(fnnWrapperList);
        }
        
    }
    //added for EDGE-92550 - P2O Enhance Modify Order to remove fixed service number(s) to support NextGenUC
    public static void getServiceSpecsDisconnect(String srvcNumber,String num)
    {
        List<ListingFNNWrapper> fnnWrapperList= new List<ListingFNNWrapper>();
        
        buildFNNWrapper(srvcNumber,num,DISINPROGRESS,fnnWrapperList);
        
        system.debug('fnnWrapperList.size()'+fnnWrapperList.size());
        system.debug('fnnWrapperList'+fnnWrapperList);
        if(fnnWrapperList.size()>0){
            buildEDISPayload(fnnWrapperList);
        }
        
    }
    //Modified for EDGE-113553 formal arguement list modified
    public static void processEDISOrderCompletion(String srvcNumber, String num){
        
        //use input parameters to identify the service and the complex simple attributes
        List<ListingFNNWrapper> fnnWrapperList= new List<ListingFNNWrapper>();
        //Modified for EDGE-113553
        
        buildFNNWrapper(srvcNumber,num,COMPLETE,fnnWrapperList);
        
        system.debug('fnnWrapperList.size()'+fnnWrapperList.size());
        system.debug('fnnWrapperList'+fnnWrapperList);
        if(fnnWrapperList.size()>0){
            buildEDISPayload(fnnWrapperList);
        }
        
        
    }
    public static void buildFNNWrapper(String srvcNumber, String num,String orderStatus,List<ListingFNNWrapper>fnnWrapperList){
        
        System.debug('Inside buildFNNWrapper::'); 
        ListingFNNWrapper fnnWrapper = new ListingFNNWrapper();
        ListingFNNWrapper fnnWrapperRange;
        fnnWrapper.isTransition = false;
        fnnWrapper.isPortOut = false;
        List<ListingFNNWrapper> fnnRangeList;
        
        Integer rangeTo=0;
        Integer rangeFrom=0;
        if(srvcNumber!=null){
            //EDGE-152480
            List<csord__Service__c> serviceList = [SELECT Id, Name,csordtelcoa__Replaced_Service__c, csordtelcoa__Service_Number__c,csord__Order__c,csord__Order__r.csord__Primary_Order__c,csord__Subscription__c,toBeCancelled__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c, Action_Type__c, csord__Order__r.csordtelcoa__Opportunity__r.Type FROM csord__Service__c WHERE csordtelcoa__Service_Number__c =:srvcNumber AND csord__Status__c != 'Closed Replaced' AND csord__Service__c=null];
            //Query for service has been modified for EDGE-185863
            List<Number__c> numberList = [select id,Status__c,Service_Number__c,Service_Id__c,Type__c from Number__c where Service_Number__c =:num];
            
            
            if(numberList != null){
                for(Number__c num1 :numberList){
                    if(num1.Status__c == INACTIVENUM){
                        fnnWrapper.isCease=true;}
                    if(num1.Type__c == NEW1){
                        fnnWrapper.isMobile=true;
                    }
                    if(num1.Type__c == INTRANSITION){
                        fnnWrapper.isTransition=true;
                    }
                }
            } 
            system.debug('serviceList!!' + serviceList);
            if(serviceList != null){
                for(csord__Service__c serv :serviceList){
                    if(serv.action_type__c !='Chown Out') { //EDGE-152480
                    fnnWrapper.orderId = serv.csord__Order__c;
                    System.debug('fnnWrapper.orderId::' + fnnWrapper.orderId); 
                    fnnWrapper.serviceId = serv.id;
                    fnnWrapper.actionType = serv.Action_Type__c;//EDGE-152480 
                    fnnWrapper.oppType = serv.csord__Order__r.csordtelcoa__Opportunity__r.Type;//EDGE-152480
                    }
                }
            }
            fnnWrapper.listCode = NOENTRY;
            fnnWrapper.fnn = num;                   
            fnnWrapper.orderStatus = orderStatus;
             

            //EDGE-203562 - Gunjan
            if(fnnWrapper.oppType == CHOWN  && (fnnWrapper.actionType != CHOWN || fnnWrapper.orderStatus == 'Submitting' )){
                fnnWrapper.fnn = '';    
            }
                         
            System.debug('fnnWrapper.orderStatus::' + fnnWrapper.orderStatus); 
            System.debug('fnnWrapper::' + fnnWrapper); 

            
            if(String.isNotBlank(fnnWrapper.fnn)){
                System.debug('I am inside else if::');
                fnnWrapperList.add(fnnWrapper);
            }
            System.debug('fnnWrapperList::'+fnnWrapperList);
        }
        
        
    } 
    public static void buildEDISPayload(List<ListingFNNWrapper> fnnWrapperList){
        System.debug('fnnWrapperListInEDISpayload::'+fnnWrapperList);
        System.debug('fnnWrapperListInEDISpayload size::'+fnnWrapperList.size());
        List<EDISSingleRequestDTO> listEDISDTO = new List<EDISSingleRequestDTO>();
        Map<Id,List<ListingFNNWrapper>> orderFNNsMap = new Map<Id,List<ListingFNNWrapper>>();
        Set<Id> orderIdSet = new Set<Id>();
        for(ListingFNNWrapper fnnWrapper : fnnWrapperList){
            orderIdSet.add(fnnWrapper.orderId);
        }
        
        system.debug('orderIdSet::'+orderIdSet);
        //EDGE-88646
        List<csord__service__c> services = [select Id, csord__Subscription__r.oldServiceMSISDN__c, Scenario_Type__c, csord__order__r.csord__Primary_Order__c, csordtelcoa__Service_Number__c from csord__service__c where csord__Order__c IN :orderIdSet];      
        system.debug('services::::'+services);
        for(csord__service__c serv : services){
            System.debug('servtocheck::'+serv);
            System.debug('servtocheck::'+serv.Scenario_Type__c);
            System.debug('servtocheck::'+serv.csord__Subscription__r.oldServiceMSISDN__c);
            serviceMap.put(serv.Id, serv);
        }
        //
        for(Id orderID : orderIdSet){
            List<ListingFNNWrapper> orderFNNList = new List<ListingFNNWrapper>();
            for(ListingFNNWrapper fnnWrapper : fnnWrapperList){
                if(orderID == fnnWrapper.orderId){
                    orderFNNList.add(fnnWrapper);
                }
            }
            if(orderFNNList.size()>0){
                orderFNNsMap.put(orderID,orderFNNList);
            }
        }
        system.debug('orderFNNsMap::'+orderFNNsMap);
        for(Id orderID : orderFNNsMap.keySet()){
            
            system.debug('orderID::'+orderID);
            Map<String,String> commonDetailsMap = new Map<String,String>();
            commonDetailsMap = fetchCommonDetails(String.valueOf(orderID),commonDetailsMap,fnnWrapperList);
            
            for(ListingFNNWrapper fnnWrapper : orderFNNsMap.get(orderID)){
                EDISSingleRequestDTO edisDto = new EDISSingleRequestDTO();
                
                
                EDISSingleRequestDTO.EDISReqDTO reqDto = new EDISSingleRequestDTO.EDISReqDTO();
                
                buildIndividualNumberPayload(fnnWrapper,edisDto,reqDto);
                buildCustomerDetails(commonDetailsMap,reqDto);
                buildListingDetails(fnnWrapper,commonDetailsMap,reqDto);
                buildServiceOrderDetails(fnnWrapper,commonDetailsMap,reqDto);
                buildCustomerContactAddressDetails(commonDetailsMap,reqDto);
                edisDto.data = reqDto;
                System.debug('edisDto::'+edisDto); 
                listEDISDTO.add(edisDto);
            }
        }
        if(listEDISDTO.size()>0){
            System.debug('listEDISDTO::'+listEDISDTO);
            List<String> dtoStrList = new List<String>();
            for(EDISSingleRequestDTO dto : listEDISDTO){
                System.debug('dto::'+dto);
                dtoStrList.add(JSON.serialize(dto,true));
            }
            if(isProcessedfromBatch == 'true'){
                processDirectoryListing_batch(dtoStrList);
            }else{
                processDirectoryListing(dtoStrList);
            }
            
        }
        
    }
    public static void buildIndividualNumberPayload(ListingFNNWrapper fnnWrapper,EDISSingleRequestDTO edisDto,EDISSingleRequestDTO.EDISReqDTO reqDto){
        //edisDto.correlationId=IntegrationRecordHandlerUtil.getUUID();
        edisDto.correlationId = getUID();
        edisDto.method = POST;
        edisDto.path = PATH;
        if(fnnWrapper.isTransition && fnnWrapper.orderStatus !=INPROGRESSS){
            reqDto.type=TRANSITION;   
        }
        else if(fnnWrapper.orderStatus==INPROGRESSS){
            System.debug('orderStatus::'+fnnWrapper.orderStatus); 
            reqDto.type=ORDERPROVISIONED;
            
        }else{
            System.debug('orderStatus1::'+fnnWrapper.orderStatus); 
            reqDto.type=ORDERCOMPLETED;
        }
        
        //Added by Pooja EDGE-152480
        buildIndividualNumberPayloadForChown(fnnWrapper, reqDto);
        
    }
    
    public static void buildCustomerDetails(Map<String,String> commonDetailsMap,EDISSingleRequestDTO.EDISReqDTO reqDto){
        
        EDISSingleRequestDTO.CustomerDetails custDetails =new EDISSingleRequestDTO.CustomerDetails();
        if(commonDetailsMap.containsKey(CUSTOMERID))
            custDetails.customerID = commonDetailsMap.get(CUSTOMERID);
        if(commonDetailsMap.containsKey(CUSTOMERTYPE))
            custDetails.customerType = commonDetailsMap.get(CUSTOMERTYPE);
        if(commonDetailsMap.containsKey(FAMILYNAME))
            custDetails.familyName = commonDetailsMap.get(FAMILYNAME);
        if(commonDetailsMap.containsKey(GIVENNAMES))
            custDetails.givenNames = commonDetailsMap.get(GIVENNAMES);
        if(commonDetailsMap.containsKey(REGISTEREDCOMPANYNAME))
            custDetails.registeredCompanyName = commonDetailsMap.get(REGISTEREDCOMPANYNAME);
        if(commonDetailsMap.containsKey(CUSTOMERTITLE))
            custDetails.customerTitle = commonDetailsMap.get(CUSTOMERTITLE);
        if(commonDetailsMap.containsKey(CUSTOMERCONTACTNAME))
            custDetails.customerContactGivenNames = commonDetailsMap.get(CUSTOMERCONTACTNAME);
        if(commonDetailsMap.containsKey(CUSTOMERCONTACTFAMILYNAME))
            custDetails.customerContactFamilyName = commonDetailsMap.get(CUSTOMERCONTACTFAMILYNAME);
        if(commonDetailsMap.containsKey(CONTACTFNN)) 
            custDetails.contactFNN = commonDetailsMap.get(CONTACTFNN);
        if(commonDetailsMap.containsKey(CONTACTEMAIL))
            custDetails.contactEmail = commonDetailsMap.get(CONTACTEMAIL);
        system.debug('custDetails::'+custDetails);
        reqDto.customerDetails = custDetails;
        
    }
    public static void buildListingDetails(ListingFNNWrapper fnnWrapper,Map<String,String> commonDetailsMap,EDISSingleRequestDTO.EDISReqDTO reqDto){
        EDISSingleRequestDTO.ListingDetails listDetails = new EDISSingleRequestDTO.ListingDetails();
        system.debug('inside buildListingDetails::');
        if(commonDetailsMap.containsKey(FAMILYORENTITYNAME))
            listDetails.familyOrEntityName = commonDetailsMap.get(FAMILYORENTITYNAME);
        if(commonDetailsMap.containsKey(ORGANIZATIONNAME))
            listDetails.organizationName = commonDetailsMap.get(ORGANIZATIONNAME);            
        if(commonDetailsMap.containsKey(GIVENNAMES))
            listDetails.givenNames = commonDetailsMap.get(GIVENNAMES);
        listDetails.listingFNN = fnnWrapper.fnn;
        if(fnnWrapper.isCease == true){
            listDetails.actionCode =DEL;
        }else{
            listDetails.actionCode = ADD; }
        if(fnnWrapper.isTransition && fnnWrapper.orderStatus !=INPROGRESSS)
            listDetails.subactionCode = TRANSITIONADD;
        //EDGE-88646 :Added
        
        if(commonDetailsMap.containsKey(SCENARIOTYPE)){
            if(commonDetailsMap.get(SCENARIOTYPE).contains(CHANGEMOBILENUM))
                listDetails.actionCode = UPDATEACTION;
        }
        //
        system.debug('listDetails::'+listDetails);
        buildListingDetailsForChown(fnnWrapper, listDetails);//Added by Pooja EDGE-152480
        reqDto.listingDetails = listDetails;
        
        
    }
    
    public static void buildServiceOrderDetails(ListingFNNWrapper fnnWrapper,Map<String,String> commonDetailsMap,EDISSingleRequestDTO.EDISReqDTO reqDto){
        EDISSingleRequestDTO.ServiceOrderDetails servOrderDetails = new EDISSingleRequestDTO.ServiceOrderDetails();
        //EDGE-88646: Added
        String primOrdId;
        String srvcNum;
        for(Id servId : serviceMap.keySet()){
            if(CHANGEMOBILENUM.equals(serviceMap.get(servId).Scenario_Type__c)){
                system.debug('servId'+servId);
                primOrdId = serviceMap.get(servId).csord__order__c;
                srvcNum = serviceMap.get(servId).csordtelcoa__Service_Number__c;
            }
            if(serviceMap.get(servId).Scenario_Type__c == System.Label.PortOut)
            {
                fnnWrapper.isPortOut = true;
            }
        }
        
        List<Number__c> numList = [select id,Status__c,Service_Number__c,Service_Id__c from Number__c where Service_Id__c =:srvcNum and Status__c = :REPLACED ORDER BY Createddate DESC LIMIT 1];
        
        if(numList != null)
        {
            for(Number__c oldnum :numList){
                servOrderDetails.originalFNN = oldnum.Service_Number__c;}
        }   
        servOrderDetails.originalFamilyName = commonDetailsMap.get(FAMILYORENTITYNAME);
        servOrderDetails.originalGivenNames = commonDetailsMap.get(GIVENNAMES);
        servOrderDetails.originalAddressIdentifier = commonDetailsMap.get(CCAID);
        servOrderDetails.orderType = CHANGEMOBILENUM;
        servOrderDetails.listCode = fnnWrapper.listCode;
        if(fnnWrapper.isCease == true){
            servOrderDetails.orderType = DISCONNECT;
        }else if(servOrderDetails.originalFNN != null){
            servOrderDetails.orderType = CHANGEFNN;
        }else{
            servOrderDetails.orderType = CONNECT;}
        if(fnnWrapper.orderStatus == INPROGRESSS){
            servOrderDetails.orderStatus = PROVISIONING;}
        else{
            servOrderDetails.orderStatus = COMPLETE;
        }
        
        if(fnnWrapper.isMobile==true) {servOrderDetails.serviceType=Label.Mobile;}
        else{servOrderDetails.serviceType = Label.VOIP; }
        
        if(commonDetailsMap.containsKey(ORDERID))
            servOrderDetails.orderID = commonDetailsMap.get(ORDERID);
        servOrderDetails.originatingSystem = Label.SFDC_B2B;
        if(fnnWrapper.isPortOut==true) servOrderDetails.portFlag=PORTOUT;
        else {servOrderDetails.portFlag = Label.PortFlag;}
        servOrderDetails.productName =BUSINESSDL;
        if(commonDetailsMap.containsKey(TELSTRAADDRESSID))
            servOrderDetails.telstraAddressId = commonDetailsMap.get(TELSTRAADDRESSID);
        if(commonDetailsMap.containsKey(SOCREATIONTIME))
            servOrderDetails.soCreationTimestamp = commonDetailsMap.get(SOCREATIONTIME);
        if(commonDetailsMap.containsKey(TELSTRACOMITDATE))
            servOrderDetails.telstraCommitmentDate = commonDetailsMap.get(TELSTRACOMITDATE);
        servOrderDetails.temporaryServiceIndicator = SERVN;
        servOrderDetails.interimServiceIndicator = SERVN;
        servOrderDetails.alternateAddressFlag = Label.AlternateAddressFlag;
        if(fnnWrapper.orderStatus == COMPLETE){
            servOrderDetails.lineItemStatus = COMPLETE;
            servOrderDetails.provisionCompletionDate = Datetime.now().format(FORMAT)+'';
        }
        else{
            servOrderDetails.lineItemStatus =PROVISIONING;
        }
        system.debug('servOrderDetails::'+servOrderDetails);
        reqDto.serviceOrderDetails = servOrderDetails;
    }
    
    public static void buildCustomerContactAddressDetails(Map<String,String> commonDetailsMap,EDISSingleRequestDTO.EDISReqDTO reqDto){
        EDISSingleRequestDTO.CustomerContactAddress custContactAddress = new EDISSingleRequestDTO.CustomerContactAddress();
        
        if(commonDetailsMap.containsKey(CCAID))
            custContactAddress.ccaIdentifier = commonDetailsMap.get(CCAID);
        system.debug('custContactAddress::'+custContactAddress);
        reqDto.customerContactAddress=custContactAddress;
    }
    
    public static Map<String,String> fetchCommonDetails(String ordId,Map<String,String> commonDetailsMap,List<ListingFNNWrapper> fnnWrapperList){
        system.debug('Inside fetchCommonDetails::');
        //EDGE-88646 :updated
        List<csord__Order__c> ordList= [select id,csord__Account__c,csord__Status2__c,csord__Account__r.name, csord__Account__r.Customer_Trading_Name__c ,csord__Account__r.Type,csord__Account__r.Email__c, csord__Account__r.CIDN__c , csord__Account__r.Title__c,csord__Start_Date__c,CreatedDate,csord__Order_Number__c,Telstra_Committed_Date__c, Scenario_Type__c From csord__Order__c where id =:ordId];
        system.debug('ordList::'+ordList);
        List<Id> accountList = new List<Id>();
        Set<Id> opp = new Set<Id>();
        Map<String , String> OrderAccounts =  new Map<String , String>();
        Map<Id,csord__Service__c> serviceMap = new Map<Id,csord__Service__c>();
        for(csord__Order__c orders : ordList){
            accountList.add(orders.csord__Account__c);
            OrderAccounts.put(orders.Id ,String.valueOf(orders.csord__Account__c));
        }
        system.debug('accountList::'+accountList);
        List <cscrm__Account_Address_Relationship__c> addressList = [select id, cscrm__Address__c,cscrm__Account__c, cscrm__Address__r.Address_ID__c,cscrm__Address_Type__c From cscrm__Account_Address_Relationship__c where cscrm__Account__c IN:accountList and cscrm__Address_Type__c =:PRIMARYADDRESS and cscrm__Active__c = true limit 1]; 
        system.debug('addressList::'+addressList);
        Map<String , cscrm__Account_Address_Relationship__c> MapOrderAddress =  new Map<String , cscrm__Account_Address_Relationship__c>();
        for(cscrm__Account_Address_Relationship__c  address : addressList ){
            MapOrderAddress.put(address.cscrm__Account__c, address);
            
        }
        
        system.debug('MapOrderAddress::'+MapOrderAddress);
        
        //For EDGE-222599: updated
        List<csord__Service__c> servList = [SELECT Id, Name,csordtelcoa__Service_Number__c,csord__Subscription__c,csord__Subscription__r.Site__r.AdborID__c,csord__Service__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,Order_Primary_Contact__c, csord__Order__c,Scenario_Type__c, Billing_Account__c, Billing_Account__r.Billing_Account_Owner__c, Billing_Account__r.Billing_Account_Owner__r.FirstName, Billing_Account__r.Billing_Account_Owner__r.LastName, Billing_Account__r.Billing_Account_Owner__r.Phone, Billing_Account__r.Billing_Account_Owner__r.Mobile_Phone_Number__c, Billing_Account__r.Billing_Account_Owner__r.Email  from csord__Service__c where csord__Order__c =: ordId AND csord__Service__c = null];
        system.debug('servList::'+servlist);
                
        List<ID> orderIdList = new List<ID>();
        for(csord__Order__c ord : ordList){
            orderIdList.add(ord.id);
        }
        
        for(csord__order__c ordObj : [select Id, csordtelcoa__Opportunity__c from csord__order__c where id IN :orderIdList]){
            opp.add(ordObj.csordtelcoa__Opportunity__c);
        }

        //Commented as part of EDGE-222599
        //List<csord__Service__c> UceservList = [SELECT Id, Name,csord__Order__c,csordtelcoa__Service_Number__c,csord__Subscription__c,csord__Service__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,Order_Primary_Contact__c,csord__Order__r.csordtelcoa__Opportunity__c,Order_Primary_Contact__r.FirstName,Order_Primary_Contact__r.LastName,Order_Primary_Contact__r.Phone,Order_Primary_Contact__r.Mobile_Phone_Number__c,Order_Primary_Contact__r.Email from csord__Service__c where Name=:UNIFIEDCOMM AND csord__Order__r.csordtelcoa__Opportunity__c IN : opp];
        
        //till here
        
        for(csord__Order__c ord : ordList){
            system.debug('Inside for loop::');
            commonDetailsMap.put(CUSTOMERID,ord.csord__Account__r.CIDN__c);
            if (ord.csord__Account__r.Type!=null){
                commonDetailsMap.put(CUSTOMERTYPE,ord.csord__Account__r.Type);}
            
            if(commonDetailsMap.get(CUSTOMERTYPE)==RESIDENTIAL||commonDetailsMap.get(CUSTOMERTYPE)==PERSONAL||commonDetailsMap.get(CUSTOMERTYPE)==SOLETRADER){
                commonDetailsMap.put(GIVENNAMES,ord.csord__Account__r.name);}
            
            if(commonDetailsMap.get(CUSTOMERTYPE)==RESIDENTIAL||commonDetailsMap.get(CUSTOMERTYPE)==PERSONAL||commonDetailsMap.get(CUSTOMERTYPE)==SOLETRADER){
                commonDetailsMap.put(FAMILYNAME,ord.csord__Account__r.name);}
            
                //EDGE-222599 start
            if(commonDetailsMap.get(CUSTOMERTYPE)==COMPANY||commonDetailsMap.get(CUSTOMERTYPE)==ORGANISATION||commonDetailsMap.get(CUSTOMERTYPE)==WHOLESALE||commonDetailsMap.get(CUSTOMERTYPE)==NONPROFITORG){
                /*if(ord.csord__Account__r.Customer_Trading_Name__c != null){
                    commonDetailsMap.put(REGISTEREDCOMPANYNAME,ord.csord__Account__r.Customer_Trading_Name__c);}*/
                if (ord.csord__Account__r.name !=null) {
                    commonDetailsMap.put(REGISTEREDCOMPANYNAME,ord.csord__Account__r.name);}  }
            if(commonDetailsMap.get(CUSTOMERTYPE)==RESIDENTIAL||commonDetailsMap.get(CUSTOMERTYPE)==PERSONAL|| commonDetailsMap.get(CUSTOMERTYPE)==SOLETRADER || commonDetailsMap.get(CUSTOMERTYPE)==COMPANY||commonDetailsMap.get(CUSTOMERTYPE)==ORGANISATION||commonDetailsMap.get(CUSTOMERTYPE)==WHOLESALE||commonDetailsMap.get(CUSTOMERTYPE)==NONPROFITORG){
                if(ord.csord__Account__r.Customer_Trading_Name__c != null){
                            commonDetailsMap.put(ORGANIZATIONNAME,ord.csord__Account__r.Customer_Trading_Name__c);}
                else if (ord.csord__Account__r.name !=null) {
                            if(commonDetailsMap.get(CUSTOMERTYPE)==COMPANY||commonDetailsMap.get(CUSTOMERTYPE)==ORGANISATION||commonDetailsMap.get(CUSTOMERTYPE)==WHOLESALE||commonDetailsMap.get(CUSTOMERTYPE)==NONPROFITORG){
                                commonDetailsMap.put(ORGANIZATIONNAME,ord.csord__Account__r.name);} } 
                         }        
                //For EDGE-222599 end    
                    
            
            if(ord.csord__Account__r.Title__c!=null){
                commonDetailsMap.put(CUSTOMERTITLE,ord.csord__Account__r.Title__c);}


            system.debug('familyOrEntityNameord:::'+ord.csord__Account__r.name);
            system.debug('orderID:::'+ord.csord__Order_Number__c);   
            
            commonDetailsMap.put(FAMILYORENTITYNAME,+ord.csord__Account__r.name);
            commonDetailsMap.put(ORDERID,ord.csord__Order_Number__c);
            
            if(ord.CreatedDate!=null){
                commonDetailsMap.put(SOCREATIONTIME,String.valueOf((ord.CreatedDate).format(FORMAT)));
                if(ord.Telstra_Committed_Date__c != null){    //Added null check 
                    commonDetailsMap.put(TELSTRACOMITDATE,String.valueOf((ord.Telstra_Committed_Date__c).format(FORMAT)));
                    System.debug('telstraCommitmentDate:::'+String.valueOf((ord.Telstra_Committed_Date__c).format(FORMAT)));
                }
                
                system.debug('soCreationTimestamp:::'+String.valueOf((ord.CreatedDate).format(FORMAT)));   
                
            }
            
            
            
            if(addressList!=null) {
                if(MapOrderAddress.containsKey(ord.csord__Account__c)){
                    if(MapOrderAddress.get(ord.csord__Account__c).cscrm__Address__r.Address_ID__c != null){
                        commonDetailsMap.put('telstraAddressId',MapOrderAddress.get(ord.csord__Account__c).cscrm__Address__r.Address_ID__c);
                        system.debug('ccaIdentifier::'+MapOrderAddress.get(ord.csord__Account__c).cscrm__Address__r.Address_ID__c);
                        commonDetailsMap.put(CCAID,MapOrderAddress.get(ord.csord__Account__c).cscrm__Address__r.Address_ID__c);}
                    
                    
                }
            }
            
            for(csord__Service__c ser :servList)
            {
                if(servList!=null){
                    serviceMap.put(ser.id,ser);}
                    system.debug('servieMap::'+serviceMap);
                //EDGE-88646
                System.debug('populating scenariotype in map');
                if(ser.Scenario_Type__c!= null){
                    commonDetailsMap.put(SCENARIOTYPE,ser.Scenario_Type__c);
                    system.debug('inside loop putting scenariotye as::'+ser.Scenario_Type__c);
                    system.debug('inside loop putting scenariotye as::'+ser.Billing_Account__r.Billing_Account_Owner__r.Email);
                    system.debug('inside loop billing account owner::'+ser.Billing_Account__r.Billing_Account_Owner__c);
                }
                //EDGE-222599 start
                if(ser.Billing_Account__r.Billing_Account_Owner__c!=null){
                    commonDetailsMap.put(CUSTOMERCONTACTNAME,ser.Billing_Account__r.Billing_Account_Owner__r.FirstName);
                    commonDetailsMap.put(CUSTOMERCONTACTFAMILYNAME,ser.Billing_Account__r.Billing_Account_Owner__r.LastName);              
                if(ser.Billing_Account__r.Billing_Account_Owner__r.Phone != null){
                    commonDetailsMap.put(CONTACTFNN,ser.Billing_Account__r.Billing_Account_Owner__r.Phone);
                }else if(ser.Billing_Account__r.Billing_Account_Owner__r.Mobile_Phone_Number__c != null){
                    commonDetailsMap.put(CONTACTFNN,ser.Billing_Account__r.Billing_Account_Owner__r.Mobile_Phone_Number__c);}
                if(ser.Billing_Account__r.Billing_Account_Owner__r.Email!=null){
                    commonDetailsMap.put(CONTACTEMAIL,ser.Billing_Account__r.Billing_Account_Owner__r.Email);}
                 }
                //EDGE-222599 end
                
                
                //END
            }
            
            //system.debug('fnnWrapperList11111::'+fnnWrapperList);  
            for(ListingFNNWrapper fnnwrapper :fnnWrapperList){
                
                System.debug('fnnWrapperList===>'+fnnWrapperList);
                system.debug('servList::'+servList);
                if(serviceMap.size()>0){
                    if(serviceMap.get(fnnwrapper.serviceId) != null && serviceMap.get(fnnwrapper.serviceId).csord__Subscription__r.Site__c!=null){
                        commonDetailsMap.put(TELSTRAADDRESSID,serviceMap.get(fnnwrapper.serviceId).csord__Subscription__r.Site__r.AdborID__c);}
                }
                else if(MapOrderAddress.get(ord.csord__Account__c) != null && MapOrderAddress.get(ord.csord__Account__c).cscrm__Address__r.Address_ID__c != null){
                    commonDetailsMap.put(TELSTRAADDRESSID,MapOrderAddress.get(ord.csord__Account__c).cscrm__Address__r.Address_ID__c);
                }
                
                
            }  

            //EDGE-222599: Commented out//

            /*system.debug('commonDetailsMap1'+commonDetailsMap);
            for(csord__Service__c uceserv :UceservList){
                if(UceservList!=null){
                    system.debug('UceservList:::'+UceservList);
                    if(uceserv.csord__Service__c ==null && uceserv.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c ==PRODOFF323 && uceserv.Order_Primary_Contact__c!=null){
                        //system.debug('contact:::'+uceserv.Order_Primary_Contact__r.FirstName);
                        commonDetailsMap.put(CUSTOMERCONTACTNAME,uceserv.Order_Primary_Contact__r.FirstName);
                        commonDetailsMap.put(CUSTOMERCONTACTFAMILYNAME,uceserv.Order_Primary_Contact__r.LastName);
                        
                        if(uceserv.Order_Primary_Contact__r.Phone != null){
                            commonDetailsMap.put(CONTACTFNN,uceserv.Order_Primary_Contact__r.Phone);
                        }else if(uceserv.Order_Primary_Contact__r.Mobile_Phone_Number__c != null){
                            commonDetailsMap.put(CONTACTFNN,uceserv.Order_Primary_Contact__r.Mobile_Phone_Number__c);}
                        if(uceserv.Order_Primary_Contact__r.Email!=null){
                            commonDetailsMap.put(CONTACTEMAIL,uceserv.Order_Primary_Contact__r.Email);} 
                        
                        
                    }
                }
            }*/
            
        }
        system.debug('commonDetailsMap'+commonDetailsMap);
        return commonDetailsMap;    
        
    }
    
    @future
    public static void processDirectoryListing(List<String> dtoStrList)
    {
        List<EDISSingleRequestDTO> processDLReqDTOList = new List<EDISSingleRequestDTO>();
        
        for(String reqStr : dtoStrList){
            processDLReqDTOList.add(EDISSingleRequestDTO.parse(reqStr));
        }
        if(processDLReqDTOList!=null && processDLReqDTOList.size()>0){
            system.debug('Size of Directory DTO List sent for enqueing ' + processDLReqDTOList.size());
            EDISEnqueueDirectoryListing edl = new EDISEnqueueDirectoryListing();
            edl.EDISEnqueueListing(processDLReqDTOList);
        }
        
    }
    
    public static void processDirectoryListing_batch(List<String> dtoStrList)
    {
        List<EDISSingleRequestDTO> processDLReqDTOList = new List<EDISSingleRequestDTO>();
        
        for(String reqStr : dtoStrList){
            processDLReqDTOList.add(EDISSingleRequestDTO.parse(reqStr));
        }
        if(processDLReqDTOList!=null && processDLReqDTOList.size()>0){
            system.debug('Size of Directory DTO List sent for enqueing ' + processDLReqDTOList.size());
            EDISEnqueueDirectoryListing edl = new EDISEnqueueDirectoryListing();
            edl.EDISEnqueueListing(processDLReqDTOList);
        }
        
    }
    
    public static void buildEDISForFailedNumbers(Map<String,Map<String,String>> fnnMap){
        ListingFNNWrapper fnnWrapper = new ListingFNNWrapper();
        List<ListingFNNWrapper>fnnWrapperList = new List<ListingFNNWrapper>();
        List<EDISSingleRequestDTO> listEDISDTO1 = new List<EDISSingleRequestDTO>();
        for (String key :  fnnMap.keySet()){
            
            Map<String,String> fnndetailsMap = fnnMap.get(key);
            system.debug('Kunal--> '+fnndetailsMap);
            String order = fnndetailsMap.get(ORDER);
            fnnWrapper.orderId =fnndetailsMap.get(ORDERID);
            fnnWrapper.serviceId = '';
            if(fnndetailsMap.get(TYPE) == ORDERPROVISIONED){
                fnnWrapper.orderStatus =PENDING;}
            else{fnnWrapper.orderStatus =INPROGRESSS;}
            if(fnndetailsMap.get(TYPE) == TRANSITION){
                
                fnnWrapper.isTransition = true;}
            else{
                
                fnnWrapper.isTransition = false;}
            fnnWrapper.fnn = fnndetailsMap.get(LISTINGFNN);
            fnnWrapper.listCode = fnndetailsMap.get(LISTCODE);
            fnnWrapperList.add(fnnWrapper);
            //System.debug('failed fnnWrapper::' + fnnWrapper);
            System.debug('order::' + order);
            Map<String,String> commonDetailsMap1 = new Map<String,String>();
            commonDetailsMap1 = fetchCommonDetails(order,commonDetailsMap1,fnnWrapperList);
            
            //iterate over the list to populate requestDTO
            for(ListingFNNWrapper fnnWrapper1 : fnnWrapperList){
                EDISSingleRequestDTO edisDto = new EDISSingleRequestDTO();
                
                
                EDISSingleRequestDTO.EDISReqDTO reqDto = new EDISSingleRequestDTO.EDISReqDTO();
                
                buildIndividualNumberPayload(fnnWrapper1,edisDto,reqDto);
                buildCustomerDetails(commonDetailsMap1,reqDto);
                buildListingDetails(fnnWrapper1,commonDetailsMap1,reqDto);
                buildServiceOrderDetails(fnnWrapper1,commonDetailsMap1,reqDto);
                buildCustomerContactAddressDetails(commonDetailsMap1,reqDto);
                edisDto.data = reqDto;
                System.debug('edisDto::'+edisDto); 
                listEDISDTO1.add(edisDto);
            }
        }
        if(listEDISDTO1.size()>0){
            System.debug('listEDISDTO1::'+listEDISDTO1);
            List<String> dtoStrList1 = new List<String>();
            for(EDISSingleRequestDTO dto1 : listEDISDTO1){
                System.debug('dto1::'+dto1);
                dtoStrList1.add(JSON.serialize(dto1,true));
            }
            processDirectoryListing(dtoStrList1);
        }   
    }
    
    public static String getUID(){
        Blob aes = Crypto.generateAesKey(128);
        String hex = EncodingUtil.convertToHex(aes);    
        String uuid = hex.substring(0,8) + '-' + hex.substring(8,12) + '-' +hex.substring(12,16) + '-' + hex.substring(16,20) + '-' + hex.substring(20,32);
        System.debug('uuid is::' + uuid);
        return uuid;
    }
    
    //Added by Pooja EDGE-152480
    public static void buildIndividualNumberPayloadForChown(ListingFNNWrapper fnnWrapper, EDISSingleRequestDTO.EDISReqDTO reqDto){

        if(fnnWrapper.oppType == CHOWN){

            reqDto.type = CHOWN;
        }
    }
    
    //Added by Pooja EDGE-152480 - For Incoming chown service
    public static void buildListingDetailsForChown(ListingFNNWrapper fnnWrapper, EDISSingleRequestDTO.ListingDetails listDetails){

        if(fnnWrapper.oppType == CHOWN && fnnWrapper.actionType == CHOWN){

            listDetails.subactionCode = CHOWNADD;
        }
    }
}