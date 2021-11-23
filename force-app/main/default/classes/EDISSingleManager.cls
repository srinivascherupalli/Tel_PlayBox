/*
Author : Prajakta Patil 
Company : Telstra
Description -Directory Listing callout ,triggered when order status = In Progress and after complete notification
HISTORY EDGE-53794 and EDGE-53801 
*/
public with sharing class EDISSingleManager {

    public Class ListingFNNWrapper{
        public String orderId {get;set;}
        public String serviceId {get;set;}
        public String orderStatus {get;set;}
        public Boolean isNew {get;set;}
        public Boolean isTransition {get;set;}
        public String fnn {get;set;}
        public String listCode {get;set;}
        public Boolean isCease {get;set;}
        public Boolean isMobile {get;set;}
        public Boolean isPortOut {get;set;}
    }
    public List<ListingFNNWrapper> fnnWrapperList{get;set;}
    
    //Constants : a part of CODE SMELL correction
    private final static String PROD263 = 'DMCAT_ProductSpecification_000263_Fulfilment';
    private final static String PROD313 = 'DMCAT_ProductSpecification_000313_Fulfilment';
    private final static String PROD420 = 'DMCAT_ProductSpecification_000420_Fulfilment';
    private final static String PROD312 = 'DMCAT_ProductSpecification_000312_Fulfilment';
    private final static String PRODOFF323 = 'DMCAT_ProductOffering_000323';
    private final static String INPROGRESSS = 'In Progress';
    private final static String COMPLETE = 'Complete';
    private final static String CFSID = 'CustomerFacingServiceId';
    private final static String NOENTRY = 'No Entry Line';
    private final static String LISTCODE = 'listCode';
    private final static String STATUS = 'status';
    private final static String ACTIVE = 'ACTIVE';
    private final static String RESERVED = 'RESERVED';
    private final static String INTRANSITION = 'IN TRANSITION';
    private final static String FNN = 'FNN';
    private final static String RANGESTART = 'rangeTo';
    private final static String RANGEEND = 'rangeFrom';
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
    //EDGE-88646
    public static Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>();  
    
    @InvocableMethod
    public static void getServiceSpecs(List<Id> OrderId)
    {
        List<ListingFNNWrapper> fnnWrapperList= new List<ListingFNNWrapper>();
        //List<Id>serviceIds=new List<Id>();
        Map<String,String>fnnMapping=new Map<String,String>();
        Set<Id> oppIdSet = new Set<Id>();
        List<CS_SpecificationDTO.ServiceSpecification> srvspecList = new List<CS_SpecificationDTO.ServiceSpecification> ();
        csord__Subscription__c sub = new csord__Subscription__c();
        
        for(csord__order__c orderObj : [select Id, csordtelcoa__Opportunity__c from csord__order__c where id IN:OrderId ]){
            oppIdSet.add(orderObj.csordtelcoa__Opportunity__c);
        }
    List<csord__Service__c> serviceList = [SELECT Id, Name,csordtelcoa__Replaced_Service__c, csordtelcoa__Service_Number__c,csord__Order__c,csord__Order__r.csord__Primary_Order__c,csord__Subscription__c,toBeCancelled__c FROM csord__Service__c WHERE csord__Order__r.csordtelcoa__Opportunity__c IN : oppIdSet AND csord__Service__c=null];
        system.debug('serviceList:::' + serviceList);
         for(csord__Service__c srv :  serviceList)
                {
         srvspecList = ServiceSpecificationUtils.getServiceSpecList(srv.id);
                   
                    for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecList){
                if(srvSpec.code==PROD263 || srvSpec.code==PROD313 || srvSpec.code==PROD312){
                    if(srvSpec.code==PROD313){
                                    for(List<CS_SpecificationDTO.ComplexAttributes> complexChars :srvSpec.complexAttributes.values())
                                    {   
                                        system.debug('complexChars '+ complexChars );
                                        for(CS_SpecificationDTO.ComplexAttributes complexChar :complexChars){ 
                                            system.debug('Before buildFNNWrapper:::');
                                buildFNNWrapper(complexChar.simpleAttributes,srv,INPROGRESSS,fnnWrapperList);
                                        }
                                    }
                    }else if(srvSpec.code==PROD263 && (srv.csordtelcoa__Replaced_Service__c==null || 'true'.equals(srv.toBeCancelled__c))){
                        buildFNNWrapper(srvSpec.additionalAttributes,srv,INPROGRESSS,fnnWrapperList);
                                }
                               
                            } 
                    }
                }
            system.debug('fnnWrapperList.size()'+fnnWrapperList.size());
           system.debug('fnnWrapperList'+fnnWrapperList);
        if(fnnWrapperList.size()>0){
            //System.debug('fnnWrapperList::' + fnnWrapperList); 
            
            buildEDISPayload(fnnWrapperList);
        }
      
    }
    
       public static void processEDISOrderCompletion(String orderId, String srvcNumber){
        //List<csord__Service__c> servList = [select id from csord__service__c where csordtelcoa__Service_Number__c =: srvcNumber];    
                   
            //use input parameters to identify the service and the complex simple attributes
            List<ListingFNNWrapper> fnnWrapperList= new List<ListingFNNWrapper>();
             List<csord__Service__c> serviceList = [SELECT Id, Name,csordtelcoa__Replaced_Service__c, csordtelcoa__Service_Number__c,csord__Order__c,csord__Order__r.csord__Primary_Order__c,toBeCancelled__c from csord__Service__c where csordtelcoa__Service_Number__c =:srvcNumber AND csord__Order__c =:orderId];
        List<CS_SpecificationDTO.ServiceSpecification> srvspecList = new List<CS_SpecificationDTO.ServiceSpecification> ();
            for(csord__Service__c srv :serviceList)
            {
            
            srvspecList = ServiceSpecificationUtils.getServiceSpecList(srv.id);
                   
                    for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecList){

                if(srvSpec.code.contains(PROD263) || srvSpec.code.contains(PROD313)){
                    if(srvSpec.code.contains(PROD313)){
                                    for(List<CS_SpecificationDTO.ComplexAttributes> complexChars :srvSpec.complexAttributes.values())
                                    {   
                                        system.debug('complexChars '+ complexChars );
                                        for(CS_SpecificationDTO.ComplexAttributes complexChar :complexChars){ 
                                            system.debug('Before buildFNNWrapper:::');
                                buildFNNWrapper(complexChar.simpleAttributes,srv,COMPLETE,fnnWrapperList);
                                        }
                                    }

                    }else if(srvSpec.code.contains(PROD263) && (srv.csordtelcoa__Replaced_Service__c==null || 'true'.equals(srv.toBeCancelled__c))){
                       system.debug('buildfnn for 263');
                        buildFNNWrapper(srvSpec.additionalAttributes,srv,COMPLETE,fnnWrapperList);
                                }
                               
                            } 
                    }
                
            }
           system.debug('fnnWrapperList.size()'+fnnWrapperList.size());
           system.debug('fnnWrapperList'+fnnWrapperList);
            if(fnnWrapperList.size()>0){
                buildEDISPayload(fnnWrapperList);
            }
            
        
    }
    public static void buildFNNWrapper(List<CS_SpecificationDTO.SimpleAttributes> simpleChars,csord__service__c serv, String orderStatus,List<ListingFNNWrapper>fnnWrapperList){
        
        System.debug('Inside buildFNNWrapper::'); 
        ListingFNNWrapper fnnWrapper = new ListingFNNWrapper();
        ListingFNNWrapper fnnWrapperRange;
        fnnWrapper.isNew = false;
        fnnWrapper.isTransition = false;
        fnnWrapper.isPortOut = false;
        List<ListingFNNWrapper> fnnRangeList;
        
        Integer rangeTo=0;
        Integer rangeFrom=0;
        if(serv!=null){
            if (serv.toBeCancelled__c =='true'){
                fnnWrapper.isCease = true;
               //EDGE- 66496 - start
               List<CS_SpecificationDTO.ServiceSpecification> srvspecList = ServiceSpecificationUtils.getServiceSpecList(serv.id);
               system.debug('buildFNNWrapper::srvspecList::' + srvspecList);
 
               for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecList){
 

                   if(srvSpec.code==PROD263 || srvSpec.code==PROD420 )
                   {
                       fnnWrapper.isPortOut = true;
                   }
               }
               system.debug('buildFNNWrapper::fnnWrapper.isPortOut::' + fnnWrapper.isPortOut);
               //EDGE- 66496 - end
            }
            fnnWrapper.orderId = serv.csord__Order__c;
            System.debug('fnnWrapper.orderId::' + fnnWrapper.orderId); 
            fnnWrapper.serviceId = serv.id;
            fnnWrapper.orderStatus = orderStatus;
            }
            for(CS_SpecificationDTO.SimpleAttributes simpleAttr: simpleChars){
              System.debug('simpleChars::'+simpleChars);   
            if(simpleAttr.name.contains(CFSID)){
                fnnWrapper.isMobile=true;
                if(serv.csordtelcoa__Replaced_Service__c != null && serv.toBeCancelled__c=='false'){
                    break;
                }else{

                    fnnWrapper.listCode = NOENTRY;
                    fnnWrapper.fnn = simpleAttr.value;
                    fnnWrapper.isNew = true;
                }
            }

            
            if(simpleAttr.name.contains(LISTCODE)){
                fnnWrapper.listCode =  simpleAttr.value;
            }
            if(simpleAttr.name.contains(STATUS)){
                if(simpleAttr.value.contains(ACTIVE)&& serv.toBeCancelled__c!='true'){
                    break;
                }else if(simpleAttr.value.contains(RESERVED)){
                    fnnWrapper.isNew = true;
                }else if(simpleAttr.value.contains(INTRANSITION)){
                    fnnWrapper.isTransition = true;
                }else{
                    break;
                }
            }
            System.debug('I am here::');   
            if(simpleAttr.name.contains(FNN) && simpleAttr.value != null && simpleAttr.value != '' && simpleAttr.value != '')
                fnnWrapper.fnn =  simpleAttr.value;
            if((simpleAttr.name.contains(RANGESTART)) && simpleAttr.value != null && simpleAttr.value != '') {
                
                 rangeTo= integer.valueOf(simpleAttr.value);
            }
            if((simpleAttr.name.contains(RANGEEND))&& simpleAttr.value != null && simpleAttr.value != '') {
                 rangeFrom= integer.valueOf(simpleAttr.value);
            }
            System.debug('fnnWrapper1::'+fnnWrapper);   
        }
        
        
        fnnRangeList = new List<ListingFNNWrapper>();
        
        Map<String, ListingFNNWrapper> fnnMap = new Map<String, ListingFNNWrapper>();
        if(rangeTo != null && rangeFrom != null && rangeTo>0 && rangeFrom>0){
            
            System.debug('fnnWrapper2::'+fnnWrapper);
            
            for(integer j=rangeFrom;j<=rangeTo;j++){
                System.debug('rangeFrom::'+rangeFrom);
                System.debug('rangeTo::'+rangeTo);
                fnnWrapperRange = new ListingFNNWrapper();
                fnnWrapperRange.orderId = fnnWrapper.orderId;
                fnnWrapperRange.serviceId = fnnWrapper.serviceId;
                fnnWrapperRange.orderStatus = fnnWrapper.orderStatus;
                fnnWrapperRange.isNew = fnnWrapper.isNew;
                fnnWrapperRange.isTransition = fnnWrapper.isTransition;
                fnnWrapperRange.listcode = fnnWrapper.listcode;
                fnnWrapperRange.isCease = fnnWrapper.isCease;
                //System.debug('j::'+j);
                fnnWrapperRange.fnn = String.valueOf(j);
                //fnnMap.put(j,fnnWrapperRange);
                
                System.debug('fnnWrapperRange::'+fnnWrapperRange);
                
                fnnRangeList.add(fnnWrapperRange);
                
                
            }
        }
        //System.debug('fnnMap::'+fnnMap);
        
        
        
        
        
        if(fnnRangeList.size()>0){
            System.debug('fnnRangeList::'+fnnRangeList);
            //fnnWrapperList.addAll(fnnMap.values());
            fnnWrapperList.addAll(fnnRangeList);
             System.debug('fnnRangeListafteradd::'+fnnRangeList);
            
        }else if(fnnWrapper.fnn != null && fnnWrapper.fnn!= ''){
            System.debug('I am inside else if::');
            fnnWrapperList.add(fnnWrapper);
        }
         System.debug('fnnWrapperList::'+fnnWrapperList);
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
        List<csord__service__c> services = [select Id, csord__Subscription__r.oldServiceMSISDN__c, Scenario_Type__c, csord__order__r.csord__Primary_Order__c from csord__service__c where csord__Order__c IN :orderIdSet];      
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
                processDirectoryListing(dtoStrList);
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
        reqDto.listingDetails = listDetails;
            
        
    }
     
    public static void buildServiceOrderDetails(ListingFNNWrapper fnnWrapper,Map<String,String> commonDetailsMap,EDISSingleRequestDTO.EDISReqDTO reqDto){
        EDISSingleRequestDTO.ServiceOrderDetails servOrderDetails = new EDISSingleRequestDTO.ServiceOrderDetails();
        //EDGE-88646: Added
        String oldMSISDNNumber;
        String primOrdId;
        for(Id servId : serviceMap.keySet()){
            if(CHANGEMOBILENUM.equals(serviceMap.get(servId).Scenario_Type__c)){
                system.debug('servId'+servId);
                oldMSISDNNumber = serviceMap.get(servId).csord__Subscription__r.oldServiceMSISDN__c;
                primOrdId = serviceMap.get(servId).csord__order__c;
            }
        }
        if(oldMSISDNNumber != null)
        {
            csord__order__c orderTOUpdate = [Select Id, csord__Order_Type__c from csord__order__c where Id =:primOrdId];
            orderTOUpdate.csord__Order_Type__c = CHANGEMOBILENUM;
            update orderTOUpdate;
            servOrderDetails.originalFNN = oldMSISDNNumber;
            servOrderDetails.originalFamilyName = commonDetailsMap.get(FAMILYORENTITYNAME);
            servOrderDetails.originalGivenNames = commonDetailsMap.get(GIVENNAMES);
            servOrderDetails.originalAddressIdentifier = commonDetailsMap.get(CCAID);
        }
            
        //
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
        //EDGE-886464 :updated
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
        //List <cscrm__Account_Address_Relationship__c> addressList = [select id, cscrm__Address__c,cscrm__Account__c, cscrm__Address__r.Address_ID__c,cscrm__Address__r.Is_Primary_Address__c,cscrm__Address_Type__c    From cscrm__Account_Address_Relationship__c where cscrm__Account__c IN:accountList and cscrm__Address_Type__c = 'Primary Address' limit 1];   
        system.debug('addressList::'+addressList);
          Map<String , cscrm__Account_Address_Relationship__c> MapOrderAddress =  new Map<String , cscrm__Account_Address_Relationship__c>();
          for(cscrm__Account_Address_Relationship__c  address : addressList ){
              MapOrderAddress.put(address.cscrm__Account__c, address);
              
          }
          
          system.debug('MapOrderAddress::'+MapOrderAddress);
         /* List <Functional_Contact_Role__c> FCRList = [Select id, OrderID__c, ContactID__r.Id,ContactID__r.FirstName, ContactID__r.LastName,ContactID__r.Phone, ContactID__r.Mobile_Phone_Number__c, ContactID__r.Email, Is_Primary__c from Functional_Contact_Role__c  where OrderID__c = :ordId and  Role_Type__c = 'Order'];
           system.debug('FCRList::'+FCRList);
        Map<Id, Functional_Contact_Role__c>  FCRMap = new Map<Id, Functional_Contact_Role__c>();
        for(Functional_Contact_Role__c fcr:FCRList){
            FCRMap.put(fcr.OrderID__c, fcr);
        }
         system.debug('FCRMap::'+FCRMap);*/
          
        //code smell correction
        
        List<csord__Service__c> servList = [SELECT Id, Name,csordtelcoa__Service_Number__c,csord__Subscription__c,csord__Subscription__r.Site__r.AdborID__c,csord__Service__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,Order_Primary_Contact__c, csord__Order__c,Scenario_Type__c from csord__Service__c where csord__Order__c =: ordId AND csord__Service__c = null];
        
        List<ID> orderIdList = new List<ID>();
        for(csord__Order__c ord : ordList){
            orderIdList.add(ord.id);
        }
        
        for(csord__order__c ordObj : [select Id, csordtelcoa__Opportunity__c from csord__order__c where id IN :orderIdList]){
                opp.add(ordObj.csordtelcoa__Opportunity__c);
        }
        List<csord__Service__c> UceservList = [SELECT Id, Name,csord__Order__c,csordtelcoa__Service_Number__c,csord__Subscription__c,csord__Service__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,Order_Primary_Contact__c,csord__Order__r.csordtelcoa__Opportunity__c,Order_Primary_Contact__r.FirstName,Order_Primary_Contact__r.LastName,Order_Primary_Contact__r.Phone,Order_Primary_Contact__r.Mobile_Phone_Number__c,Order_Primary_Contact__r.Email from csord__Service__c where Name=:UNIFIEDCOMM AND csord__Order__r.csordtelcoa__Opportunity__c IN : opp];
         
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
        
            if(commonDetailsMap.get(CUSTOMERTYPE)==COMPANY||commonDetailsMap.get(CUSTOMERTYPE)==ORGANISATION||commonDetailsMap.get(CUSTOMERTYPE)==WHOLESALE||commonDetailsMap.get(CUSTOMERTYPE)==NONPROFITORG){
             if(ord.csord__Account__r.Customer_Trading_Name__c != null){
                    commonDetailsMap.put(REGISTEREDCOMPANYNAME,ord.csord__Account__r.Customer_Trading_Name__c);}  }
                    
        if(ord.csord__Account__r.Title__c!=null){
                commonDetailsMap.put(CUSTOMERTITLE,ord.csord__Account__r.Title__c);}
        
           
        system.debug('familyOrEntityNameord:::'+ord.csord__Account__r.name);
         system.debug('orderID:::'+ord.csord__Order_Number__c);   

            commonDetailsMap.put(FAMILYORENTITYNAME,+ord.csord__Account__r.name);
            commonDetailsMap.put(ORDERID,ord.csord__Order_Number__c);
        
        if(ord.CreatedDate!=null){
                commonDetailsMap.put(SOCREATIONTIME,String.valueOf((ord.CreatedDate).format(FORMAT)));
                commonDetailsMap.put(TELSTRACOMITDATE,String.valueOf((ord.Telstra_Committed_Date__c).format(FORMAT)));
                system.debug('soCreationTimestamp:::'+String.valueOf((ord.CreatedDate).format(FORMAT)));   
                system.debug('telstraCommitmentDate:::'+String.valueOf((ord.Telstra_Committed_Date__c).format(FORMAT)));   
        }
        
    
        
        if(addressList!=null) {
            if(MapOrderAddress.containsKey(ord.csord__Account__c)){
                     if(MapOrderAddress.get(ord.csord__Account__c).cscrm__Address__r.Address_ID__c != null){
                       // commonDetailsMap.put('telstraAddressId',MapOrderAddress.get(ord.csord__Account__c).cscrm__Address__r.Address_ID__c);
                       system.debug('ccaIdentifier::'+MapOrderAddress.get(ord.csord__Account__c).cscrm__Address__r.Address_ID__c);
                        commonDetailsMap.put(CCAID,MapOrderAddress.get(ord.csord__Account__c).cscrm__Address__r.Address_ID__c);}
                     
             
            }
        }
            
            for(csord__Service__c ser :servList)
            {
                if(servList!=null){
                serviceMap.put(ser.id,ser);}
                //EDGE-88646
                System.debug('populating scenariotype in map');
                if(ser.Scenario_Type__c!= null){
                commonDetailsMap.put(SCENARIOTYPE,ser.Scenario_Type__c);
                }
                
                //END
            }
            
           //system.debug('fnnWrapperList11111::'+fnnWrapperList);  
         for(ListingFNNWrapper fnnwrapper :fnnWrapperList){
                
                System.debug('fnnWrapperList===>'+fnnWrapperList);
                system.debug('servList::'+servList);
                        if(serviceMap.get(fnnwrapper.serviceId).csord__Subscription__r.Site__c!=null){
                            commonDetailsMap.put(TELSTRAADDRESSID,serviceMap.get(fnnwrapper.serviceId).csord__Subscription__r.Site__r.AdborID__c);}
                else if(MapOrderAddress.get(ord.csord__Account__c).cscrm__Address__r.Address_ID__c != null){
                            commonDetailsMap.put(TELSTRAADDRESSID,MapOrderAddress.get(ord.csord__Account__c).cscrm__Address__r.Address_ID__c);
                }
                
                    
                
            
     }  
     
     

            
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
        }

    }
        //
    
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
            fnnWrapper.isNew = false;
            fnnWrapper.isTransition = true;}
        else{
            fnnWrapper.isNew = true;
            fnnWrapper.isTransition = false;}
            fnnWrapper.fnn = fnndetailsMap.get(LISTINGFNN);
            fnnWrapper.listCode = fnndetailsMap.get(LISTCODE);
        fnnWrapperList.add(fnnWrapper);
        //System.debug('failed fnnWrapper::' + fnnWrapper);
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
 
    //EDGE-56828
   public static void processEDISCeaseCompletion(String subscriptionId){
       try{
            List<ListingFNNWrapper> fnnWrapperList= new List<ListingFNNWrapper>();
    
            List<csord__Service__c> services = [SELECT Id, Name, csord__Order__c, csordtelcoa__Replaced_Service__c, csord__Status__c, csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c,toBeCancelled__c from csord__Service__c WHERE csord__Subscription__c =:subscriptionId];
            system.debug('services::'+services);
            
            Set<Id> servId = new Set<Id>();
            for(csord__Service__c srv: services){
            servId.add(srv.id);
            }
            List<CS_SpecificationDTO.ServiceSpecification> srvspecList = new List<CS_SpecificationDTO.ServiceSpecification> ();
            
            Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([Select Id, Name,ModelChange__c, csord__Service__c,  Appointment_Required__c, TechnologyType__c, csord__Order_Request__c, csordtelcoa__Replaced_Service__c,toBeCancelled__c,csord__Order__c,csord__Order__r.csord__Primary_Order__c from csord__Service__c where Id IN:servId]);
             system.debug('serviceMap::' + serviceMap);
             for(csord__Service__c service :serviceMap.values())
             {
               srvspecList = ServiceSpecificationUtils.getServiceSpecList(service.id);
            
                    for(CS_SpecificationDTO.ServiceSpecification serviceSpec : srvspecList){
                    if(serviceSpec.code==PROD263 || serviceSpec.code==PROD313 || serviceSpec.code==PROD312){
                        if(serviceSpec.code==PROD313){
                            for(List<CS_SpecificationDTO.ComplexAttributes> complexChars :serviceSpec.complexAttributes.values()){
                                      
                                        system.debug('complexChars '+ complexChars );
                                        for(CS_SpecificationDTO.ComplexAttributes complexChar :complexChars){ 
                                            system.debug('Before buildFNNWrapper:::');
                                    buildFNNWrapper(complexChar.simpleAttributes,service,COMPLETE,fnnWrapperList);
                                        }
                        
                            }
                        }
                        
                        else if(serviceSpec.code==PROD263 && (service.csordtelcoa__Replaced_Service__c==null || 'true'.equals(service.toBeCancelled__c))){
                            buildFNNWrapper(serviceSpec.additionalAttributes,service,COMPLETE,fnnWrapperList);
                        }
                        }
                               
             }
             }
             if(fnnWrapperList.size()>0){
                 system.debug('Before buildEDISPayload ::');
                buildEDISPayload(fnnWrapperList);
            }
            
           
        }catch(Exception e){
            system.debug('Exception in processEDISCeaseCompletion ' + e);
        }
       
   }
   
}