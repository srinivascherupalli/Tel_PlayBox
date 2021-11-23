/********************************************************

    Class Name : EDISSingleManagerHelper

    ===============================================================================================================================

    Change.No.    Developer Name          Date              Story Description

    1.             Milos                 12/07/2021          DIGI-869
    2.           Pawan Devaliya         29/07/2021          EDGE-229526
    3.           Pawan Devaliya         18/08/2021          DIGI-14827 : added condition for          service type NBN VOIP
    **********************************************************/
    public without sharing class EDISSingleManagerHelper {

        // private final static String PRODOFF323 = 'DMCAT_ProductOffering_000323';
        private final static String CONST_INTERFACENAME = 'EDISSingleManagerHelper';
        // private final static String INPROGRESSS = 'In Progress';
        private final static String COMPLETED = 'Completed';
        private final static String COMPLETE = 'Complete';
        private final static String UNLISTEDNUMBER = 'UL';
        private final static String LISTCODE = 'listCode';
        private final static String ACTIVE = 'ACTIVE';
        // private final static String INTRANSITION = 'Transition';
        // private final static String FNN = 'FNN';
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
        // private final static String CUSTOMERCONTACTNAME = 'customerContactGivenNames';
        // private final static String CUSTOMERCONTACTFAMILYNAME = 'customerContactFamilyName';
        // private final static String CONTACTFNN = 'contactFNN';
        // private final static String CONTACTEMAIL = 'contactEmail';
        private final static String DEL = 'Delete';
        private final static String ADD = 'Add';
        // private final static String TRANSITIONADD = 'Transition-Add';
        // private final static String SCENARIOTYPE = 'scenarioType';
        // private final static String CHANGEMOBILENUM = 'Change of Mobile Number';
        private final static String UPDATEACTION = 'Update';
        // private final static String CCAID = 'ccaIdentifier';
        private final static String DISCONNECT = 'Disconnect';
        private final static String CONNECT = 'Connect';
        private final static String PROVISIONING = 'Provisioning';
        // private final static String ORDER = 'order';
        // private final static String ORDERID = 'orderID';
        private final static String PORTOUT = 'Port Out';
        private final static String PORTIN = 'Port In';
        private final static String NOTAPPLICABLE = 'Not Applicable';
        // private final static String BUSINESSDL = 'Business Directory Listing';
        // private final static String TELSTRAADDRESSID = 'telstraAddressId';
        // private final static String SOCREATIONTIME = 'soCreationTimestamp';
        // private final static String TELSTRACOMITDATE = 'telstraCommitmentDate';
        private final static String SERVN = 'N';
        private final static String FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ssXXX';
        // private final static String PRIMARYADDRESS = 'Primary Address';
        // private final static String UNIFIEDCOMM = 'Unified Communication';
        // private final static String TYPE = 'type';
        // private final static String FAMILYORENTITYNAME = 'familyOrEntityName';
        // private final static String ORGANIZATIONNAME = 'organizationName';
        // private final static String PENDING = 'pending';
        // private final static String LISTINGFNN = 'listingFNN';
        private final static String RESIDENTIAL = 'Residential';
        private final static String SOLETRADER = 'Sole Trader';
        // private final static String PERSONAL = 'Personal';
        private final static String COMPANY = 'Company';
        private final static String ORGANISATION = 'Organisation';
        // private final static String WHOLESALE = 'Wholesale';
        private final static String NONPROFITORG = 'Non Profit Organisation';
        private final static String CHANGEFNN = 'Change FNN';
        // private final static String ACTIVENUM = 'Active';
        // private final static String PROVINPROG = 'Provisioning In Progress';
        // private final static String DISCPENDING = 'Disconnect Pending';
        // private final static String DISINPROGRESS = 'Disconnect In Progress';
        private final static String INACTIVENUM = 'Inactive';
        // private final static String NEW1 = 'New';
        private final static String REPLACED = 'Replaced';  
        private final static String CHOWN = 'CHOWN';    
        private final static String CHOWNADD = 'CHOWN-Add';
        private final static String MOBILE = 'Mobile';
        private final static String CHANGEOFMOBILENUMBER = 'Change of Mobile Number';
    
        private static Map<String, List<Number__c>> serviceToNumber {get; set;}
        private static Map<String, csord__Service__c> serviceNumberToService {get; set;}
        private static Map<String, Number__c> oldNumbersMap {get; set;}
        private static Map<String, Number__c> numberMap {get; set;}
    
        public static void buildingMaps(List<Number__c> listofNum) {
            try {
                Set<String> servIds = new Set<String>();
    
                for (Number__c num : listofNum) {
                    servIds.add(num.Service_Id__c);
                }
    
                List<Number__c> oldNumbersList = new List<Number__c>([SELECT Service_Id__c, Service_Number__c FROM Number__c WHERE Status__c = :REPLACED AND Service_Id__c IN :servIds ORDER BY CreatedDate ASC]);
    
                oldNumbersMap = new Map<String, Number__c>();
    
                for (Number__c num : oldNumbersList) {
                    oldNumbersMap.put(num.Service_Id__c, num);
                }
    
                serviceToNumber = new Map<String, List<Number__c>>();
                numberMap = new Map<String, Number__c>();
    
                for(Number__c num : listofNum) {
                    numberMap.put(num.Service_Number__c, num);
    
                    if (serviceToNumber.containsKey(num.Service_Id__c)) {
                        serviceToNumber.get(num.Service_Id__c).add(num);
                    } else {
                        serviceToNumber.put(num.Service_Id__c, new List<Number__c>{num});
                    }
                }
        
                Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([SELECT Id, 
                    Name, 
                    Scenario_Type__c, 
                    Billing_Account__r.Billing_Account_Owner__r.Email, 
                    Billing_Account__r.Billing_Account_Owner__c, 
                    Billing_Account__r.Billing_Account_Owner__r.FirstName, 
                    Billing_Account__r.Billing_Account_Owner__r.LastName, 
                    Billing_Account__r.Billing_Account_Owner__r.Phone,
                    Billing_Account__r.Billing_Account_Owner__r.Mobile_Phone_Number__c, 
                    Action_Type__c,
                    csordtelcoa__Product_Configuration__r.Remaining_Term__c,
                    csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name, 
                    csordtelcoa__Replaced_Service__c, 
                    csordtelcoa__Service_Number__c,
                    csord__Order__c,
                    csord__Order__r.csord__Primary_Order__c,
                    csord__Order__r.csord__Account__c,
                    csord__Order__r.csord__Status2__c,
                    csord__Order__r.csord__Account__r.Name, 
                    csord__Order__r.csord__Account__r.Customer_Trading_Name__c,
                    csord__Order__r.csord__Account__r.Type,
                    csord__Order__r.csord__Account__r.Email__c, 
                    csord__Order__r.csord__Account__r.CIDN__c, 
                    csord__Order__r.csord__Account__r.Title__c,
                    csord__Order__r.csord__Start_Date__c,
                    csord__Order__r.CreatedDate,
                    csord__Order__r.csord__Order_Number__c,
                    csord__Order__r.Telstra_Committed_Date__c, 
                    csord__Order__r.Scenario_Type__c,
                    csord__Order__r.csord__Account__r.Primary_Address__r.Address_ID__c,
                    csord__Subscription__c,
                    toBeCancelled__c,
                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Product_Specification__c, 
                    csord__Order__r.csordtelcoa__Opportunity__r.Type, 
                    csord__Subscription__r.oldServiceMSISDN__c,
                    csord__Subscription__r.Site__c,
                    csord__Subscription__r.Site__r.AdborID__c
                FROM csord__Service__c WHERE csord__Status__c != 'Closed Replaced' AND csord__Status__c != 'CHOWN Replaced' AND csordtelcoa__Service_Number__c IN :serviceToNumber.keySet()]);
        
                serviceNumberToService = new Map<String, csord__Service__c>();
    
                System.debug('serviceToNumber>>>'+serviceToNumber.keySet());
                System.debug('serviceMap>>>'+serviceMap);
    
                for (csord__Service__c serv : serviceMap.values()) {
                    serviceNumberToService.put(serv.csordtelcoa__Service_Number__c, serv);
                }
    
                buildDTOs();
            } catch (Exception e) {
                serviceToNumber = new Map<String, List<Number__c>>();
                serviceNumberToService = new Map<String, csord__Service__c>();
                oldNumbersMap = new Map<String, Number__c>();
                logException('buildDTOs', String.valueOf(e.getLineNumber()), '', e.getMessage(), 'Error building maps for the preparation of the DTO population!');
            }
        }
    
        private static void buildDTOs() {
            Map<String, EDISSingleRequestDTO> dtoMap = new Map<String, EDISSingleRequestDTO>();
    
            for (String servNum : serviceToNumber.keySet()) {
               for (Number__c num : serviceToNumber.get(servNum)) {
                   csord__Service__c tempServ = serviceNumberToService.get(servNum);
    
                    EDISSingleRequestDTO dto = new EDISSingleRequestDTO();
                    dto.path = PATH;
                    dto.method = POST;
                    dto.data = populateEdisReqDTO(tempServ, num);
    
                    dtoMap.put(num.Service_Number__c, dto);
                }
            }
    
            if (!dtoMap.isEmpty() && !numberMap.isEmpty() ) {
                EDISDirectoryCallout edisCallout = new EDISDirectoryCallout(dtoMap, numberMap);
                edisCallout.callEDISSingleService();
            }
        }
    
        private static EDISSingleRequestDTO.EDISReqDTO populateEdisReqDTO(csord__Service__c tempServ, Number__c num) {
            EDISSingleRequestDTO.EDISReqDTO data = new EDISSingleRequestDTO.EDISReqDTO();
            data.type = getOrderDataType(tempServ);
            data.listingDetails = populateListingDetailsDTO(tempServ, num);
            data.customerDetails = populateCustomerDetailsDTO(tempServ, num);
            data.customerContactAddress = populateCustomerContactAddressDTO(tempServ, num);
            data.serviceOrderDetails = populateServiceOrderDetailsDTO(tempServ, num);
    
            return data;
        }
        
        @testVisible
        private static EDISSingleRequestDTO.ListingDetails populateListingDetailsDTO(csord__Service__c tempServ, Number__c num) {
            EDISSingleRequestDTO.ListingDetails listingDetails = new EDISSingleRequestDTO.ListingDetails();
            listingDetails.listingFNN = num?.Service_Number__c;
            listingDetails.actionCode = getActionCode(tempServ, num);
            listingDetails.familyOrEntityName = tempServ?.csord__Order__r?.csord__Account__r?.Name;
            //EDGE-229526 : Added null check as it is conditional mandatory
            if (getOrganizationName(tempServ) != '') {
            listingDetails.organizationName = getOrganizationName(tempServ);
            }
            if (getSubActionCode(tempServ) != '') {
                listingDetails.subActionCode = getSubActionCode(tempServ);
            }
            if (getGivenNames(tempServ) != '') {
                listingDetails.givenNames = getGivenNames(tempServ);
            }
        
            return listingDetails;
        }
    
        private static EDISSingleRequestDTO.CustomerDetails populateCustomerDetailsDTO(csord__Service__c tempServ, Number__c num) {
            EDISSingleRequestDTO.CustomerDetails customerDetails = new EDISSingleRequestDTO.CustomerDetails();
            customerDetails.customerId = tempServ?.csord__Order__r?.csord__Account__r?.CIDN__c;
            customerDetails.customerType = tempServ?.csord__Order__r?.csord__Account__r?.Type;
            //Added null check as it is optional field
            if(tempServ?.csord__Order__r?.csord__Account__r?.Title__c != null){
                customerDetails.customerTitle = tempServ?.csord__Order__r?.csord__Account__r?.Title__c;
            }
            if(tempServ?.Billing_Account__r?.Billing_Account_Owner__r?.Email != null){
            customerDetails.contactEmail = tempServ?.Billing_Account__r?.Billing_Account_Owner__r?.Email;
            }
            if (getGivenNames(tempServ) != '') {
                customerDetails.givenNames = getGivenNames(tempServ);
                customerDetails.familyName = getGivenNames(tempServ);
            }
            if (getRegisteredCompanyName(tempServ) != '') {
                customerDetails.registeredCompanyName = getRegisteredCompanyName(tempServ);
            }
            if (getCustomerContactFamilyName(tempServ) != '') {
                if(tempServ?.Billing_Account__r?.Billing_Account_Owner__r?.FirstName != null){
                customerDetails.customerContactGivenNames = tempServ?.Billing_Account__r?.Billing_Account_Owner__r?.FirstName;
                }
                customerDetails.customerContactFamilyName = getCustomerContactFamilyName(tempServ);
                if (getContactFNN(tempServ) != '') {
                    customerDetails.contactFNN = getContactFNN(tempServ);
                }
            }
        
        if(getServiceType(num)== System.Label.VOIP){// added as part of DIGI-14827
          if (getContactFNN(tempServ) != '') {
                    customerDetails.contactFNN = getContactFNN(tempServ);
                }
        }
    
            return customerDetails;
        }
    
        private static EDISSingleRequestDTO.CustomerContactAddress populateCustomerContactAddressDTO(csord__Service__c tempServ, Number__c num) {
            EDISSingleRequestDTO.CustomerContactAddress customerContactAddress  = new EDISSingleRequestDTO.CustomerContactAddress();
            customerContactAddress.ccaIdentifier = tempServ?.csord__Order__r?.csord__Account__r?.Primary_Address__r?.Address_ID__c;
    
            return customerContactAddress;
        }
    
        private static EDISSingleRequestDTO.ServiceOrderDetails populateServiceOrderDetailsDTO(csord__Service__c tempServ, Number__c num) {
            EDISSingleRequestDTO.ServiceOrderDetails serviceOrderDetails  = new EDISSingleRequestDTO.ServiceOrderDetails();
            serviceOrderDetails.originatingSystem = System.Label.SFDC_B2B;
            serviceOrderDetails.serviceType = getServiceType(num);
            serviceOrderDetails.orderType  = getOrderType(tempServ, num);
            serviceOrderDetails.orderId = tempServ?.csord__Order__r?.csord__Order_Number__c;
            serviceOrderDetails.listCode = UNLISTEDNUMBER;
            serviceOrderDetails.portFlag  = getPortFlag(tempServ);
            if(tempServ?.csord__Order__r?.csord__Account__r?.Name != null){
                serviceOrderDetails.originalFamilyOrEntityName = tempServ?.csord__Order__r?.csord__Account__r?.Name;
                serviceOrderDetails.originalGivenNames = tempServ?.csord__Order__r?.csord__Account__r?.Name;
            }
            if(tempServ?.csord__Order__r?.csord__Account__r?.Primary_Address__r?.Address_ID__c != null){
                serviceOrderDetails.originalAddressIdentifier  = tempServ?.csord__Order__r?.csord__Account__r?.Primary_Address__r?.Address_ID__c;
            }        
            serviceOrderDetails.lineItemStatus = getOrderStatus(tempServ);
            serviceOrderDetails.soCreationTimestamp = String.valueOf((tempServ.csord__Order__r?.CreatedDate).format(FORMAT));
          //   serviceOrderDetails.alternateAddressFlag = System.Label.AlternateAddressFlag;removed as per api V4 update
          //  serviceOrderDetails.temporaryServiceIndicator = SERVN; // confirm with Satheesh
          //  serviceOrderDetails.interimServiceIndicator = SERVN; //confirm with Satheesh
            serviceOrderDetails.telstraAddressId = getTelstraAddressId(tempServ);
            if (getOrderStatus(tempServ) != '') {
                serviceOrderDetails.orderStatus = getOrderStatus(tempServ);
            }
            if (getOriginalFNN(num) != '') {
                serviceOrderDetails.originalFNN = getOriginalFNN(num);
            }
            if (getProvisionCompletionDate(tempServ) != '') {
                serviceOrderDetails.provisionCompletionDate = getProvisionCompletionDate(tempServ);
            }
            if (getTelstraCommitmentDate(tempServ) != '') {
                serviceOrderDetails.telstraCommitmentDate = getTelstraCommitmentDate(tempServ);
            }
    
            return serviceOrderDetails;
        }
    
        private static String getOrderStatus(csord__Service__c tempServ) {
            if (tempServ?.csord__Order__r?.csord__Status2__c == COMPLETED) {
                return COMPLETE;
            } else {
                return PROVISIONING;
            }
        }
    
        private static String getContactFNN(csord__Service__c tempServ) {
            if (tempServ?.Billing_Account__r?.Billing_Account_Owner__r?.Phone != null) {
                return tempServ?.Billing_Account__r?.Billing_Account_Owner__r?.Phone;
            } else if (tempServ?.Billing_Account__r?.Billing_Account_Owner__r?.Mobile_Phone_Number__c != null) {
                return tempServ?.Billing_Account__r?.Billing_Account_Owner__r?.Mobile_Phone_Number__c;
            }
    
            return '';
        }
    
        private static String getOriginalFNN(Number__c num) {
            if (oldNumbersMap.containsKey(num.Service_Id__c)) {
                return oldNumbersMap.get(num.Service_Id__c).Service_Number__c;
            }
    
            return '';
        }
    
        private static String getServiceType(Number__c num) {
            if (num?.Mobile__c == MOBILE) {
                return System.Label.Mobile;
            } else {
                return System.Label.VOIP;
            }
        }
    
        private static String getOrderType(csord__Service__c tempServ, Number__c num) {
            if (num?.Status__c == INACTIVENUM) {
                return DISCONNECT;
            } else if (getOriginalFNN(num) != '') {
                return CHANGEFNN;
            } else {
                return CONNECT;
            }
        }
    
        private static String getPortFlag(csord__Service__c tempServ) {
            if(tempServ?.Scenario_Type__c != null){
                if (tempServ?.Scenario_Type__c == PORTOUT) {
                    return PORTOUT;
                } else if (tempServ?.Scenario_Type__c == PORTIN) {
                    return PORTIN;
                }
            }
            return NOTAPPLICABLE;
        }
    
        private static String getProvisionCompletionDate(csord__Service__c tempServ) {
            if (tempServ?.csord__Order__r?.csord__Status2__c == COMPLETED) {
                return Datetime.now().format(FORMAT)+'';
            }
    
            return '';
        }
    
        private static String getTelstraCommitmentDate(csord__Service__c tempServ) {
            if (tempServ?.csord__Order__r?.csord__Status2__c != COMPLETED) {
                return (tempServ?.csord__Order__r?.Telstra_Committed_Date__c).format(FORMAT)+'';
            }
    
            return '';
        }
    
        private static String getTelstraAddressId(csord__Service__c tempServ) {
            if (tempServ?.Id != null && tempServ?.csord__Subscription__r?.Site__c != null) {
                return tempServ?.csord__Subscription__r?.Site__r?.AdborID__c;
            } else if (tempServ?.csord__Order__r?.csord__Account__c != null && tempServ?.csord__Order__r?.csord__Account__r?.Primary_Address__r?.Address_ID__c != null) {
                return tempServ?.csord__Order__r?.csord__Account__r?.Primary_Address__r?.Address_ID__c;
            }
    
            return '';
        }
    
        private static String getOrderDataType(csord__Service__c tempServ) {
            if (tempServ?.csord__Order__r?.csordtelcoa__Opportunity__r?.Type != null && tempServ?.csord__Order__r?.csordtelcoa__Opportunity__r?.Type.contains(CHOWN)) {
                return CHOWN;
            } else if (tempServ?.csord__Order__r?.csord__Status2__c == COMPLETED) {
                return ORDERCOMPLETED;
            } else {
                return ORDERPROVISIONED;
            }
        }
    
        private static String getActionCode(csord__Service__c tempServ, Number__c num) {
            if (tempServ?.Scenario_Type__c != null && tempServ?.Scenario_Type__c == CHANGEOFMOBILENUMBER) {
                return UPDATEACTION;
            } else if (num?.status__c == INACTIVENUM) {
                return DEL;
            } else {
                return ADD;
            }
        }
    
        private static String getSubActionCode(csord__Service__c tempServ) {
            // if type is CHOWN -> CHOWN-Add otherwise don't add it
            if (tempServ?.csord__Order__r?.csordtelcoa__Opportunity__r?.Type != null && tempServ?.csord__Order__r?.csordtelcoa__Opportunity__r?.Type.contains(CHOWN)) {
                return CHOWNADD;
            } else {
                return '';
            }
        }   
    
        private static String getGivenNames(csord__Service__c tempServ) {
            if (tempServ?.csord__Order__r?.csord__Account__r?.Type == RESIDENTIAL || tempServ?.csord__Order__r?.csord__Account__r?.Type == SOLETRADER) {
                return tempServ?.csord__Order__r?.csord__Account__r?.Name;
            } else {
                return '';
            }
        }
        
        private static String getOrganizationName(csord__Service__c tempServ) {
            if (tempServ?.csord__Order__r?.csord__Account__r?.Type == RESIDENTIAL || tempServ?.csord__Order__r?.csord__Account__r?.Type == SOLETRADER || tempServ?.csord__Order__r?.csord__Account__r?.Type == COMPANY || tempServ?.csord__Order__r?.csord__Account__r?.Type == ORGANISATION || tempServ?.csord__Order__r?.csord__Account__r?.Type == NONPROFITORG) {
                if (tempServ?.csord__Order__r?.csord__Account__r?.Customer_Trading_Name__c != null) {
                    return tempServ?.csord__Order__r?.csord__Account__r?.Customer_Trading_Name__c;
                }
                else if (tempServ?.csord__Order__r?.csord__Account__r?.Name != null) {
                    if (tempServ?.csord__Order__r?.csord__Account__r?.Type == COMPANY || tempServ?.csord__Order__r?.csord__Account__r?.Type == ORGANISATION || tempServ?.csord__Order__r?.csord__Account__r?.Type == NONPROFITORG) {
                        return tempServ?.csord__Order__r?.csord__Account__r?.Name;
                    }
                } 
            }
    
            return '';
        }
    
        private static String getRegisteredCompanyName(csord__Service__c tempServ) {
            if (tempServ?.csord__Order__r?.csord__Account__r?.Type == COMPANY || tempServ?.csord__Order__r?.csord__Account__r?.Type == ORGANISATION || tempServ?.csord__Order__r?.csord__Account__r?.Type == NONPROFITORG) {
                if (tempServ?.csord__Order__r?.csord__Account__r?.Name != null) {
                    return tempServ?.csord__Order__r?.csord__Account__r?.Name;
                } 
            }
    
            return '';
        }
    
        private static String getCustomerContactFamilyName(csord__Service__c tempServ) {
            if (tempServ?.csord__Order__r?.csord__Account__r?.Type == COMPANY || tempServ?.csord__Order__r?.csord__Account__r?.Type == ORGANISATION || tempServ?.csord__Order__r?.csord__Account__r?.Type == NONPROFITORG) {
                if (tempServ?.csord__Order__r?.csord__Account__r?.Name != null) {
                    return tempServ?.Billing_Account__r?.Billing_Account_Owner__r?.LastName;
                }
            }
    
            return '';
        }
    
        /**  
        * @description Exception Handling Framework  
        */  
        private static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription) {  
            Map<String, Object> eLogMap = new Map<String, Object>();  
            eLogMap.put('interfaceName', CONST_INTERFACENAME);  // class name
            eLogMap.put('elementName', methodName);  
            eLogMap.put('referenceNumber', referenceNumber); // line number of err 
            eLogMap.put('correlationId', correlationId);  // leave empty
            eLogMap.put('errorDescription', errorMessage);  // error message
            eLogMap.put('businessDescription', businessDescription);  
            C2O_Utilities.logException(eLogMap, false);  
        }
    }