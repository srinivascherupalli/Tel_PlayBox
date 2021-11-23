/* 
Author : Vimal Verma 
Company : Telstra
Description : EDGE-1145 - Manage Order interface structure component 
History : Initail Version Mon Oct 16 09:56:44 2017
ChagneSet No    Name            Date                    Description
CH-1            Abinash         09/24/2019          EDGE-80870 want to Submit Order to O2A & Receive order notification from 
O2A to REPLACE customer's Warranty Replacements [Manage Order Interface]
2.              Vaibhav         23/02/2020          EDGE-128126  Shipping required fix
3.              Manish Jha      06/04/2020          Design gap fix
*/
public with sharing class ManageOrderServiceUtility {
    public Static boolean isDeviceReplacePresent = false; //Abinash
    public Static String replacedServiceDeliveryAddressId;//EDGE-130234-Dheeraj Bhatt-02-Jan-19-Address ID should be same for Replaced and Replacement device
    public static final Map < String, String > contactDataMap = new Map < String, String > {
        'Primary Site Contact' => 'Site Contact',
            'After Hours Contact' => 'Out of Ofc Hrs',
            'Technical Contact' => 'customerProjectContact',
            'Project Contact' => 'customerTechnicalContact'
            };
                
                public static Map < String, List < ManageOrderDataObject.CharacteristicDataObject >> specToCharacteristicMap = new Map < String, List < ManageOrderDataObject.CharacteristicDataObject >> ();
                public static Map < String, List < ManageOrderDataObject.CharacteristicDataObject >> prodCharwithinProdCharMap = new Map < String, List < ManageOrderDataObject.CharacteristicDataObject >> ();
    public class AccountData {
        public String name;
        public String accountId;
        public String accountType;
        public String cidn;
    }
    
    public class OrderData {
        public Id orderId;
        public String orderName;
        public String orderType;
        public String orderNumber;
        public Date requestedDate;
        public String fulfilmentNumber;
        public Decimal fulfilmentVersion;
        
        //Added as part of EDGE-80798
        public String ownerId;
        
        //Added as part of EDGE-66477
        public String scenarioType;
        
        
        List < ManageOrderDataObject.CharacteristicDataObject > ordCharacteristics;
    }
    
    public static Map < Id, AccountData > getAccountData(Map < Id, csord__Order__c > allOrders) {
        Map < Id, AccountData > accountData = new Map < Id, AccountData > ();
        for (csord__Order__c ord: allOrders.values()) {
            if (!accountData.containsKey(ord.Id)) {
                AccountData acc = new AccountData();
                acc.name = ord.csord__Account__r.Name;
                acc.accountId = ord.csord__Account__r.CIDN__c;
                acc.accountType = ord.csord__Account__r.Type;
                accountData.put(ord.Id, acc);
            }
        }
        System.debug('getAccountData::: ' + accountData);
        return accountData;
    }
    
    public static Map < Id, OrderData > getOrderData(Map < Id, csord__Order__c > allOrders) {
        Map < Id, OrderData > ordersData = new Map < Id, OrderData > ();
        for (Id orderId: new List < Id > (allOrders.keySet())) {
            if (!ordersData.containsKey(allOrders.get(orderId).Id)) {
                csord__Order__c order = allOrders.get(orderId);
                OrderData ord = new OrderData();
                ord.orderId = order.Id;
                ord.orderName = order.Name;
                ord.orderType = order.csord__Order_Type__c;
                ord.orderNumber = order.csord__Order_Number__c;
                ord.fulfilmentNumber = order.Fulfilment_Order_Number__c;
                ord.fulfilmentVersion = order.Fulfilment_Order_Version__c;
                ord.requestedDate = order.csord__End_Date__c;
                
                //Added as part of EDGE-80798
                ord.ownerId = order.OwnerId;
                
                //Added as part of EDGE-66477
                ord.scenarioType = order.Scenario_Type__c;
                
                ord.ordCharacteristics = ManageOrderServiceUtilityHelper.getOrderCharacteristics(order);
                ordersData.put(order.Id, ord);
            }
        }
        System.debug('getOrderData::: ' + ordersData);
        return ordersData;
    }
    
    public static Map < Id, List < ManageOrderServicesDTO >> getServiceData(Map < Id, csord__Service__c > serviceMap) {
        Map < Id, List < ManageOrderServicesDTO >> servicesData = new Map < Id, List < ManageOrderServicesDTO >> ();
        for (csord__Service__c svc: serviceMap.values()) {
            ManageOrderServicesDTO serv = new ManageOrderServicesDTO(svc.Id, svc.Name, svc.csordtelcoa__Service_Number__c, svc.csord__Subscription__c, svc.csord__Status__c);
            Id orderId = svc.csord__Order__r.csord__Primary_Order__c != null ? svc.csord__Order__r.csord__Primary_Order__c : svc.csord__Order__c;
            if (String.isNotBlank(svc.csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c)) {
                orderId = svc.csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__Primary_Order__c != null ? svc.csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__Primary_Order__c : svc.csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c;
            }
            
            if (servicesData.containsKey(orderId)) {
                servicesData.get(orderId).add(serv);
            } else {
                servicesData.put(orderId, new List < ManageOrderServicesDTO > {
                    serv
                        });
            }
        }
        System.debug('getServiceData::: ' + servicesData);
        return servicesData;
    }
    
    public static Map < Id, Map < Id, List < ManageOrderDataObject.PlaceDataObject >>> getSitesData(Map < Id, csord__Service__c > serviceMap, Map < Id, List < ManageOrderServicesDTO >> servicesData) {
        //outputs Map<OrderId, Map<ServiceId, List<ManageOrderDataObject.PlaceDataObject>>>
        Map < Id, Map < Id, List < ManageOrderDataObject.PlaceDataObject >>> sitesMap = new Map < Id, Map < Id, List < ManageOrderDataObject.PlaceDataObject >>> ();
        Map < Id, List < Id >> siteIdMap = new Map < Id, List < Id >> ();
        for (Id orderId: servicesData.keySet()) {
            List < ManageOrderServicesDTO > servicesDTO = servicesData.get(orderId);
            if (servicesDTO != null) {
                Set < Id > siteIds = new Set < Id > ();
                for (ManageOrderServicesDTO svcDTO: servicesDTO) {
                    if (serviceMap.get(svcDTO.svcId).csord__Subscription__r.Site__c != null)
                        siteIds.add(serviceMap.get(svcDTO.svcId).csord__Subscription__r.Site__c);
                }
                siteIdMap.put(orderId, new List < Id > (siteIds));
            }
            //System.debug('OrderId : '+ orderId);
        }
        
        //System.debug('SiteIdMap : '+siteIdMap);
        Map < Id, Map < Id, List < Functional_Contact_Role__c >>> siteContactRoleList = ManageOrderServiceHelper.getSiteContacts(siteIdMap);
        //System.debug('SiteContactRole : '+siteContactRoleList);
        for (Id orderId: servicesData.keySet()) {
            List < ManageOrderServicesDTO > servicesDTO = servicesData.get(orderId);
            if (servicesDTO != null) {
                //Set<Id> siteIds = new Set<Id>();
                for (ManageOrderServicesDTO svcDTO: servicesDTO) {
                    csord__Service__c svc = serviceMap.get(svcDTO.svcId);
                    if (svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__c != null) {
                        List < ManageOrderDataObject.PlaceDataObject > places = new List < ManageOrderDataObject.PlaceDataObject > ();
                        ManageOrderDataObject.PlaceDataObject place = new ManageOrderDataObject.PlaceDataObject();
                        ManageOrderDataObject.AddressDataObject addr = new ManageOrderDataObject.AddressDataObject();
                        List < ManageOrderDataObject.ContactDataObject > persons = new List < ManageOrderDataObject.ContactDataObject > ();
                        place.role = 'Installation';
                        putAddressData(addr, svc);
                        place.address = addr;
                        if (siteContactRoleList.get(orderId).containsKey(svc.csord__Subscription__r.Site__c)) {
                            List < Functional_Contact_Role__c > contacts = siteContactRoleList.get(orderId).get(svc.csord__Subscription__r.Site__c);
                            if (contacts != null) {
                                fetchContactData(contacts, persons);
                            }
                        }
                        if (persons != null) {
                            place.contact = persons;
                        }
                        places.add(place);
                        
                        if (sitesMap.containsKey(orderId)) {
                            sitesMap.get(orderId).put(svc.Id, places);
                        } else {
                            sitesMap.put(orderId, new Map < Id, List < ManageOrderDataObject.PlaceDataObject >> {
                                svc.Id => places
                                    });
                        }
                    }
                }
            }
        }
        System.debug('getSitesData::: ' + sitesMap);
        return sitesMap;
    }
    
    private static void fetchContactData(List < Functional_Contact_Role__c > contacts, List < ManageOrderDataObject.ContactDataObject > persons) {
        for (Functional_Contact_Role__c contact: contacts) {
            ManageOrderDataObject.ContactDataObject person = new ManageOrderDataObject.ContactDataObject();
            putContactData(person, contact);
            persons.add(person);
        }
    }
    
    public static void putOrderData(Id orderId, ManageOrderDataObject.ProductOrder orderDTO, Map < Id, OrderData > ordersData) {
        if (ordersData.containsKey(orderId)) {
            orderDTO.externalId = ordersData.get(orderId).fulfilmentNumber;
            orderDTO.version = ManageOrderService.VERSION;
            
            System.debug('Order :' + ordersData.get(orderId));
            System.debug('OrderType :' + ordersData.get(orderId).orderType);
            if (ordersData.get(orderId).orderType != null) {
                if ((ordersData.get(orderId).orderType).contains('Amend')) {
                    orderDTO.version = Integer.valueof(ordersData.get(orderId).fulfilmentVersion + 1);
                }
            }
            
            orderDTO.systemId = String.valueOf(ManageOrderService.APPLICATION);
            if (ordersData.get(orderId).requestedDate != null) {
                Datetime reqDate = ordersData.get(orderId).requestedDate;
                orderDTO.requestedCompletionDate = String.valueOf(reqDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS'));
            }
            //orderDTO.marketType = 'Business';
            orderDTO.orderReasonCode = null;
            orderDTO.orderSpecificationCode = 'CloudSense_CPO';
            orderDTO.orderCharacteristic = ordersData.get(orderId).ordCharacteristics;
        }
        System.debug('putOrderData::: ' + orderDTO);
    }
    
    public static void putAccountData(Id orderId, ManageOrderDataObject.ProductOrder orderDTO, Map < Id, AccountData > accountData) {
        if (accountData.containsKey(orderId)) {
            List < ManageOrderDataObject.RelatedPartyDataObject > relatedParties = new List < ManageOrderDataObject.RelatedPartyDataObject > ();
            ManageOrderDataObject.RelatedPartyDataObject relatedParty = new ManageOrderDataObject.RelatedPartyDataObject();
            relatedParty.id = accountData.get(orderId).accountId;
            relatedParty.name = accountData.get(orderId).name;
            relatedParty.type = accountData.get(orderId).accountType;
            relatedParty.role = 'customer';
            relatedParties.add(relatedParty);
            orderDTO.relatedParty = relatedParties;
        }
        System.debug('putAccountData::: ' + orderDTO);
    }
    // Update for 65707 :: 19.4 :: 14/3/2019 :: by one extra Arg - serviceDeliveryContactMap
    //Start
    public static List < ManageOrderDataObject.OrderItemDataObject > convertEDMtoOrderItems(Map < String, String > serviceCancelDateMap, ManageOrderServiceUtility.OrderData order, ManageOrderDataObject.ProductOrder orderDTO, List < CS_SpecificationDTO.ServiceSpecification > cfsMap,
            List < ManageOrderServicesDTO > servicesData, Map < Id, List < ManageOrderDataObject.PlaceDataObject >> orderSitesMap, Map < String, Contact > serviceDeliveryContactMap, Map < String, Map < String, String >> guidToTransientAttributesMap) {
                //End
                List < ManageOrderDataObject.OrderItemDataObject > orderItems = new List < ManageOrderDataObject.OrderItemDataObject > ();
                Map < String, CS_SpecificationDTO.ServiceSpecification > serviceEDMMap = new Map < String, CS_SpecificationDTO.ServiceSpecification > ();
                Map < String, ManageOrderDataObject.ProductDataObject > OrderprodSet = new Map < String, ManageOrderDataObject.ProductDataObject > ();
                Map < String, ManageOrderDataObject.ProductDataObject > orderProds = new Map < String, ManageOrderDataObject.ProductDataObject > ();
                Map < String, Id > serviceIdGUIDMap = new Map < String, Id > ();
                list < String > subsIds = new List < String > ();
                List < String > serviceIds = new List < String > ();
                Map < String, List < String >> ProdChildConfigIds = new Map < String, List < String >> ();
                System.debug('cfsMap : ' + cfsMap);
                Map < Id, ManageOrderServicesDTO > servicesMap = new Map < Id, ManageOrderServicesDTO > ();
                
                for (ManageOrderServicesDTO srv: servicesData) {
                    servicesMap.put(srv.svcId, srv);
                    subsIds.add(srv.svcSubscriptionId);
                    serviceIds.add(srv.svcId);
                }
                Map < String, Task__c > taskAppointmentMap = AppointmentServiceHelper.getAppointmentsDetails(subsIds);
                Map < Id, csord__Service__c > ServiceMap = AppointmentServiceHelper.getServiceData(serviceIds);
                //EDGE-80870 start
                
                
                Map<String, List<Order_Service_Type__mdt>> mapServiceType = new Map<String, List<Order_Service_Type__mdt>>();
                for(Order_Service_Type__mdt serviceType: [SELECT DeveloperName,Id,Label,reference_Field__c,
                  Scenario_Type__c,Value__c FROM Order_Service_Type__mdt]){
                      if(mapServiceType.containsKey(serviceType.Scenario_Type__c)){
                          mapServiceType.get(serviceType.Scenario_Type__c).add(serviceType);
                      }else{
                          mapServiceType.put(serviceType.Scenario_Type__c, new List<Order_Service_Type__mdt>{serviceType});
                      }             
                  }
                
                
                
                system.debug('isDeviceReplacePresent292>>>>>>>>>>>' + isDeviceReplacePresent);
                
                List<ManageOrderDataObject.CharacteristicDataObject> lstprodCharAttribute = new List<ManageOrderDataObject.CharacteristicDataObject>();
                            
                map<ID,ID>  serIDPCIDmap = new  map<ID,ID>();
                for (csord__Service__c ser : serviceMap.values())
                {
                    //
                    system.debug('Scenario Type>>>>>>>>>>>' + ser.Scenario_Type__c);
                    if(ser.Scenario_Type__c == System.Label.Device_Replacement){
                        isDeviceReplacePresent=true;                
                        replacedServiceDeliveryAddressId=ServiceMap.get(ser.id).Delivery_Address__r.Address_ID__c; 
                        for(Order_Service_Type__mdt orderServiceType: mapServiceType.get(ser.Scenario_Type__c)){
                            ManageOrderDataObject.CharacteristicDataObject prodCharAttribute = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharAttribute.name = orderServiceType.DeveloperName;
                            String APIName = orderServiceType.reference_Field__c;
                            prodCharAttribute.value = string.valueof(ser.get(APIName));
                            lstprodCharAttribute.add(prodCharAttribute);
                            system.debug('prodCharAttribute>>>>>>>>>>>' + prodCharAttribute);
                            //prodCharList.add(prodCharAttribute);
                        }
                          break;
                    }
                    serIDPCIDmap.put(ser.Id,ser.csordtelcoa__Product_Configuration__c);
                }
                if (cfsMap != null) {
                    for (CS_SpecificationDTO.ServiceSpecification srvCfs: cfsMap) {
                        serviceEDMMap.put(srvCfs.guid, srvCfs);
                    }
                    System.debug('ServiceEDM : ' + serviceEDMMap);
                    for (CS_SpecificationDTO.ServiceSpecification cfs: cfsMap) {
                        serviceIdGUIDMap.put(cfs.guid, cfs.serviceId);
                    }
                    
                    orderProds = createProd(cfsMap, taskAppointmentMap, guidToTransientAttributesMap);
                    System.debug('orderProds::' + orderProds);
                    OrderprodSet = fetchRelations(orderProds, serviceEDMMap, ProdChildConfigIds);
                    System.debug('OrderprodSet:::' + OrderprodSet);
                    System.debug('ProdChildIds:::' + ProdChildConfigIds);
                    System.debug('taskAppointmentMap:::' + taskAppointmentMap);
                }
                //EDGE-66627 Changes Start
                           
                map<Id,String> servIdTransIdMap = new map<Id,String>();
                map<Id,String> servIdIMSIIdMap = new map<Id,String>();//added for IMSI mapping to payload
                for(Number__c num : [SELECT id,Product_Configuration__c,Transition_Id__c,Imsi__c FROM Number__c WHERE Product_Configuration__c in : serIDPCIDmap.values()])
                {
                    servIdTransIdMap.put(num.Product_Configuration__c,num.Transition_Id__c);
                    servIdIMSIIdMap.put(num.Product_Configuration__c,num.Imsi__c);
                }
                system.debug('*****servIdTransIdMap=' + servIdTransIdMap);
                //EDGE-66627 Changes End
                
                if (OrderprodSet != null) {
                    for (String prodId: new List < String > (OrderprodSet.keySet())) {
                        System.debug('prodId : ' + prodId);
                        ManageOrderDataObject.OrderItemDataObject orderItem = new ManageOrderDataObject.OrderItemDataObject();
                        ManageOrderDataObject.ProductDataObject prod = OrderprodSet.get(prodId);
                        if (orderSitesMap != null) {
                            prod.place = orderSitesMap.get(serviceIdGUIDMap.get(prodId));
                        }
                        orderItem.id = String.valueOf(order.fulfilmentNumber) + '|' + String.valueOf(servicesMap.get(serviceIdGUIDMap.get(prodId)).svcNumber) + '|' + String.valueOf(prodId);
                        orderItem.version = orderDTO.version;
                        orderItem.action = ManageOrderServiceHelper.getItemAction(servicesMap.get(serviceIdGUIDMap.get(prodId)).status);
                        orderItem.product = prod;
                        if ((serviceCancelDateMap.containsKey(servicesMap.get(serviceIdGUIDMap.get(prodId)).svcNumber)) && serviceCancelDateMap.get(servicesMap.get(serviceIdGUIDMap.get(prodId)).svcNumber) != null) {
                            //Datetime reqDate = order.requestedDate;
                            //orderItem.requestedCompletionDate  = String.valueOf(reqDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS'));
                            orderItem.requestedCompletionDate = serviceCancelDateMap.get(servicesMap.get(serviceIdGUIDMap.get(prodId)).svcNumber);
                        }
                        
                        orderItem.appointment = ManageOrderServiceUtilityHelper.getAppointment(taskAppointmentMap, serviceEDMMap, prodId, ProdChildConfigIds);
                        if (taskAppointmentMap.containsKey(prodId)) {
                            system.debug('appointment' + taskAppointmentMap.get(prodId));
                            ManageOrderDataObject.CharacteristicDataObject prodCharComp = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharComp.name = 'AppointmentNotes';
                            
                            prodCharComp.value = taskAppointmentMap.get(prodId).Appointment__r.Notes__c;
                            
                            if (specToCharacteristicMap.containsKey(prodId)) {
                                specToCharacteristicMap.get(prodId).add(prodCharComp);
                            } else {
                                List < ManageOrderDataObject.CharacteristicDataObject > prodChar = new List < ManageOrderDataObject.CharacteristicDataObject > ();
                                prodChar.add(prodCharComp);
                                specToCharacteristicMap.put(prodId, prodChar);
                            }
                            
                        } else {
                            if (ProdChildConfigIds.get(prodId) != null) {
                                Boolean FlagVar = false;
                                for (String ChildId: ProdChildConfigIds.get(prodId)) {
                                    if (taskAppointmentMap.containskey(ChildId)) {
                                        
                                        ManageOrderDataObject.CharacteristicDataObject prodCharComp = new ManageOrderDataObject.CharacteristicDataObject();
                                        prodCharComp.name = 'AppointmentNotes';
                                        prodCharComp.value = taskAppointmentMap.get(ChildId).Appointment__r.Notes__c;
                                        
                                        if (specToCharacteristicMap.containsKey(prodId)) {
                                            List < ManageOrderDataObject.CharacteristicDataObject > existingCharComp = specToCharacteristicMap.get(prodId);
                                            for (ManageOrderDataObject.CharacteristicDataObject exstChar: existingCharComp) {
                                                if (exstChar.name.contains('AppointmentNotes')) {
                                                    FlagVar = true;
                                                }
                                            }
                                            if (FlagVar == false) {
                                                specToCharacteristicMap.get(prodId).add(prodCharComp);
                                            }
                                        } else {
                                            List < ManageOrderDataObject.CharacteristicDataObject > prodChar = new List < ManageOrderDataObject.CharacteristicDataObject > ();
                                            prodChar.add(prodCharComp);
                                            specToCharacteristicMap.put(prodId, prodChar);
                                        }
                                    }
                                }
                            }
                        }
                        
                        if (ServiceMap.containsKey(serviceIdGUIDMap.get(prodId))) {
                            //EDGE-81134 MDM tenancy
                            if(ServiceMap.get(serviceIdGUIDMap.get(prodId)).TenancyPrimaryContact__c!=null){
                                List < ManageOrderDataObject.CharacteristicDataObject > prodCharList = new List < ManageOrderDataObject.CharacteristicDataObject > ();
                                ManageOrderDataObject.CharacteristicDataObject prodCharCompMDMFirstName = new ManageOrderDataObject.CharacteristicDataObject();
                                prodCharCompMDMFirstName.name='TenancyAdminFirstName';
                                
                                ManageOrderDataObject.CharacteristicDataObject prodCharCompMDMLastName = new ManageOrderDataObject.CharacteristicDataObject();
                                prodCharCompMDMLastName.name='TenancyAdminLastName';
                                
                                ManageOrderDataObject.CharacteristicDataObject prodCharCompMDMPhone = new ManageOrderDataObject.CharacteristicDataObject();
                                prodCharCompMDMPhone.name='TenancyAdminPhoneNumber';
                                
                                ManageOrderDataObject.CharacteristicDataObject prodCharCompMDMEmail = new ManageOrderDataObject.CharacteristicDataObject();
                                prodCharCompMDMEmail.name='TenancyAdminEmailId';
                                
                                if(ServiceMap.get(serviceIdGUIDMap.get(prodId)).TenancyPrimaryContact__r.firstName!=null){
                                    prodCharCompMDMFirstName.value=ServiceMap.get(serviceIdGUIDMap.get(prodId)).TenancyPrimaryContact__r.firstName;
                                }
                                else
                                    prodCharCompMDMFirstName.value='';
                                prodCharList.add(prodCharCompMDMFirstName);
                                
                                if(ServiceMap.get(serviceIdGUIDMap.get(prodId)).TenancyPrimaryContact__r.lastName!=null){
                                    prodCharCompMDMLastName.value=ServiceMap.get(serviceIdGUIDMap.get(prodId)).TenancyPrimaryContact__r.lastName;
                                }
                                else
                                    prodCharCompMDMLastName.value='';
                                prodCharList.add(prodCharCompMDMLastName);
                                
                                if(ServiceMap.get(serviceIdGUIDMap.get(prodId)).TenancyPrimaryContact__r.MobilePhone!=null){
                                    prodCharCompMDMPhone.value=ServiceMap.get(serviceIdGUIDMap.get(prodId)).TenancyPrimaryContact__r.MobilePhone;
                                }
                                else if(ServiceMap.get(serviceIdGUIDMap.get(prodId)).TenancyPrimaryContact__r.Phone!=null)
                                    prodCharCompMDMPhone.value=ServiceMap.get(serviceIdGUIDMap.get(prodId)).TenancyPrimaryContact__r.Phone;
                                else
                                    prodCharCompMDMPhone.value='';
                                prodCharList.add(prodCharCompMDMPhone);
                                
                                if(ServiceMap.get(serviceIdGUIDMap.get(prodId)).TenancyPrimaryContact__r.Email!=null){
                                    prodCharCompMDMEmail.value=ServiceMap.get(serviceIdGUIDMap.get(prodId)).TenancyPrimaryContact__r.Email;
                                }
                                else
                                    prodCharCompMDMEmail.value='';
                                prodCharList.add(prodCharCompMDMEmail);
                                
                                if (prodCharList != null && !prodCharList.isEmpty()) {
                                    if (specToCharacteristicMap.containsKey(prodId)) {
                                        specToCharacteristicMap.get(prodId).addAll(prodCharList);
                                    } else {
                                        List < ManageOrderDataObject.CharacteristicDataObject > prodChar = new List < ManageOrderDataObject.CharacteristicDataObject > ();
                                        prodChar.addAll(prodCharList);
                                        specToCharacteristicMap.put(prodId, prodChar);
                                    }
                                }
                            }
                            
                            //END EDGE-81134
                            if (ServiceMap.get(serviceIdGUIDMap.get(prodId)).toBeCancelled__c == 'false') {
                                system.debug('ServiceMap=' + ServiceMap);
                                system.debug('serviceIdGUIDMap=' + serviceIdGUIDMap);
                                List < ManageOrderDataObject.CharacteristicDataObject > prodCharList = new List < ManageOrderDataObject.CharacteristicDataObject > ();
                                //EDGE-66477 start
                                ManageOrderDataObject.CharacteristicDataObject prodCharCompScenarioType;
                                if(ServiceMap.get(serviceIdGUIDMap.get(prodId)).Scenario_Type__c != null && !isDeviceReplacePresent)
                                {
                                    
                                    prodCharCompScenarioType = new ManageOrderDataObject.CharacteristicDataObject();
                                    prodCharCompScenarioType.name = 'ScenarioType';
                                    prodCharCompScenarioType.value = ServiceMap.get(serviceIdGUIDMap.get(prodId)).Scenario_Type__c;
                                    prodCharList.add(prodCharCompScenarioType);
                                }
                               
                                if(ServiceMap.get(serviceIdGUIDMap.get(prodId)).Scenario_Type__c == 'Transition')
                                {
                                    ManageOrderDataObject.CharacteristicDataObject prodCharCompTransitionId = new ManageOrderDataObject.CharacteristicDataObject();
                                    prodCharCompTransitionId.name = 'transitionId';
                                    prodCharCompTransitionId.value = servIdTransIdMap.get(ServiceMap.get(serviceIdGUIDMap.get(prodId)).csordtelcoa__Product_Configuration__c);
                                    prodCharList.add(prodCharCompTransitionId);
                                    system.debug('*****prodCharCompTransitionId=' + prodCharCompTransitionId);
                                    
                                    /*//added to propagate IMSI to O2A
                                    ManageOrderDataObject.CharacteristicDataObject prodCharCompIMSI = new ManageOrderDataObject.CharacteristicDataObject();
                                    prodCharCompIMSI.name = 'IMSI';
                                    prodCharCompIMSI.value = servIdIMSIIdMap.get(ServiceMap.get(serviceIdGUIDMap.get(prodId)).csordtelcoa__Product_Configuration__c);
                                    prodCharList.add(prodCharCompIMSI);
                                    system.debug('*****prodCharCompIMSI=' + prodCharCompIMSI);
                                    */
                                }
                                
                                /*
                                if(order.scenarioType != null){
                                prodCharCompScenarioType.value = order.scenarioType;
                                }
                                else{ prodCharCompScenarioType.value = '';}*/
                                                                                                                
                        //EDGE-66477 End
                        // EDGE-80870 Start                        
                        
                        csord__Service__c objService = ServiceMap.get(serviceIdGUIDMap.get(prodId));
                            
                        if(isDeviceReplacePresent){   
                            system.debug('lstprodCharAttribute>>>>>>>>>>>' + lstprodCharAttribute);
                            for(ManageOrderDataObject.CharacteristicDataObject objrec: lstprodCharAttribute){
                                prodCharList.add(objrec);
                            } 
                            /*ManageOrderDataObject.CharacteristicDataObject objQuantity = new ManageOrderDataObject.CharacteristicDataObject();
                            objQuantity.name = 'Quantity';
                            objQuantity.value = '1';
                            prodCharList.add(objQuantity);    */                  
                            
                            if(objService.Scenario_Type__c == System.Label.Device_Replacement){                             
                                ManageOrderDataObject.CharacteristicDataObject recTitle = new ManageOrderDataObject.CharacteristicDataObject();
                                recTitle.name = 'deliveryContactTitle';
                                recTitle.value = objService.Primary_Contact__r.Title==null?'':objService.Primary_Contact__r.Title;
                                
                                ManageOrderDataObject.CharacteristicDataObject recfirstName = new ManageOrderDataObject.CharacteristicDataObject();
                                recfirstName.name = 'deliveryContactFirstName';
                                recfirstName.value = objService.Primary_Contact__r.firstName==null?'':objService.Primary_Contact__r.firstName;
                                
                                ManageOrderDataObject.CharacteristicDataObject reclastName = new ManageOrderDataObject.CharacteristicDataObject();
                                reclastName.name = 'deliveryContactLastName';
                                reclastName.value = objService.Primary_Contact__r.LastName==null?'':objService.Primary_Contact__r.LastName;
                                
                                ManageOrderDataObject.CharacteristicDataObject emailAddress = new ManageOrderDataObject.CharacteristicDataObject();
                                emailAddress.name = 'deliveryContactEmailAddress';
                                emailAddress.value = objService.Primary_Contact__r.Email==null?'':objService.Primary_Contact__r.Email;
                                
                                ManageOrderDataObject.CharacteristicDataObject phoneNumber = new ManageOrderDataObject.CharacteristicDataObject();
                                phoneNumber.name = 'deliveryContactPhoneNumber';
                                phoneNumber.value = objService.Primary_Contact__r.MobilePhone ==null?'':objService.Primary_Contact__r.MobilePhone;
                                
                                
                                /*ManageOrderDataObject.CharacteristicDataObject deviceId = new ManageOrderDataObject.CharacteristicDataObject(); 
                                deviceId.name = 'DeviceId'; 
                                deviceId.value = objService.Replaced_Device_Id__c==null ? '': objService.Replaced_Device_Id__c;
                                */
                                
                               // Reverse Log:Ramya
                               
                               //prodCharList.add(deviceId);
                                prodCharList.add(recTitle);
                                prodCharList.add(recfirstName);
                                prodCharList.add(reclastName);
                                prodCharList.add(emailAddress);
                                prodCharList.add(phoneNumber);
                                
                                //For Device
                /*if (prodCharwithinProdCharMap.containsKey(prodId)) {
                  prodCharwithinProdCharMap.get(prodId).add(deviceId);
                } else {
                  List < ManageOrderDataObject.CharacteristicDataObject > prodWithProdChar = new List < ManageOrderDataObject.CharacteristicDataObject > ();
                  prodWithProdChar.add(deviceId);
                   prodCharwithinProdCharMap.put(prodId, prodWithProdChar);
                }*/
                            }
                        }
                        // EDGE-80870 End
                        //EDGE-80750 Start
						
                        if(ServiceMap.get(serviceIdGUIDMap.get(prodId)).Scenario_Type__c == 'Port In' || ServiceMap.get(serviceIdGUIDMap.get(prodId)).Scenario_Type__c == 'Port Out Reversal'){
                            ManageOrderDataObject.CharacteristicDataObject prodCharCompIncumAccNum = new ManageOrderDataObject.CharacteristicDataObject();
                            ManageOrderDataObject.CharacteristicDataObject prodCharCompCustAuthDate = new ManageOrderDataObject.CharacteristicDataObject();
                            ManageOrderDataObject.CharacteristicDataObject prodCharCompCAExpDate = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharCompIncumAccNum.name = 'IncumbentAccountNumber';
                            prodCharCompIncumAccNum.value = ServiceMap.get(serviceIdGUIDMap.get(prodId)).Incumbent_Account_Number__c;
                            prodCharCompCustAuthDate.name = 'CustomerAuthorisationDate';
                            prodCharCompCustAuthDate.value = string.valueof(ServiceMap.get(serviceIdGUIDMap.get(prodId)).Customer_Authorised_date__c);
                            prodCharCompCAExpDate.name = 'CAExpiryDate';
                            prodCharCompCAExpDate.value = string.valueof(ServiceMap.get(serviceIdGUIDMap.get(prodId)).CA_Expiry_Date__c);
                            prodCharList.add(prodCharCompIncumAccNum);
                            prodCharList.add(prodCharCompCustAuthDate);
                            prodCharList.add(prodCharCompCAExpDate);
                            system.debug('*****prodCharCompIncumAccNum=' + prodCharCompIncumAccNum);
                        }
                        //EDGE-80750 End
                        if (ServiceMap.get(serviceIdGUIDMap.get(prodId)).Not_Before_CRD__c != null) {
                            ManageOrderDataObject.CharacteristicDataObject prodCharComp = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharComp.name = 'notBeforeCRD';
                            //Datetime notbeforeCRD = datetime.valueOf(ServiceMap.get(serviceIdGUIDMap.get(prodId)).Not_Before_CRD__c);
                            Datetime notbeforeCRD = ServiceMap.get(serviceIdGUIDMap.get(prodId)).Not_Before_CRD__c;
                            //prodCharComp.value = ServiceMap.get(serviceIdGUIDMap.get(prodId)).Not_Before_CRD__c;
                            if (notbeforeCRD != Null) {
                                prodCharComp.value = String.valueOf(notbeforeCRD.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss-SS:SS'));
                                
                            }
                            prodCharList.add(prodCharComp);
                        }
                        
                        if (ServiceMap.get(serviceIdGUIDMap.get(prodId)).Preferred_CRD__c != null) {
                            ManageOrderDataObject.CharacteristicDataObject prodCharComp1 = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharComp1.name = 'preferredCRD';
                            
                            //Datetime preferCRD = datetime.valueOf(ServiceMap.get(serviceIdGUIDMap.get(prodId)).Preferred_CRD__c);
                            Datetime preferCRD = ServiceMap.get(serviceIdGUIDMap.get(prodId)).Preferred_CRD__c;
                            //prodCharComp1.value = ServiceMap.get(serviceIdGUIDMap.get(prodId)).Not_Before_CRD__c;
                            if (preferCRD != Null) {
                                
                                prodCharComp1.value = String.valueOf(preferCRD.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss-SS:SS'));
                                System.debug('preferCRD::: ' + prodCharComp1.value);
                            }
                            prodCharList.add(prodCharComp1);
                        }
                        
                        if (ServiceMap.get(serviceIdGUIDMap.get(prodId)).Notes__c != null) {
                            ManageOrderDataObject.CharacteristicDataObject prodCharComp2 = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharComp2.name = 'Notes';
                            prodCharComp2.value = ServiceMap.get(serviceIdGUIDMap.get(prodId)).Notes__c;
                            prodCharList.add(prodCharComp2);
                        }
                        boolean isMobilityMac = false;
                        // EDGE-53797
                        if (Label.MobilitySpecCode.equalsIgnoreCase(ServiceMap.get(serviceIdGUIDMap.get(prodId)).csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c)) {
                            if (String.isNotBlank(ServiceMap.get(serviceIdGUIDMap.get(prodId)).csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c)) {
                                isMobilityMac = true;
                            }
                        }
                        boolean shippingCheck=false;//added as part of EDGE-128126
                        //added as part of EDGE-128126
System.debug('prod.productRelationship:::'+prod.productRelationship);
for(ManageOrderDataObject.CharacteristicDataObject chars: prod.productCharacteristic ){
  if(chars.name == 'ShippingRequired' && chars.value == 'TRUE'){
  System.debug('prod.productRelationship:::'+chars);
  shippingCheck = true;
  break;
  }
 
   }
if(prod.productRelationship != null && !shippingCheck){
                        for(ManageOrderDataObject.ProductRelationshipDataObject attrs:prod.productRelationship){
System.debug('prod.productRelationship2:::'+prod.productRelationship);
  for(ManageOrderDataObject.CharacteristicDataObject chars: attrs.product.productCharacteristic ){
  if(chars.name == 'ShippingRequired' && chars.value == 'TRUE'){
  System.debug('prod.productRelationship:::'+chars);
  shippingCheck = true;
  break;
  }
 
  }
  if(shippingCheck)
  break;
                        }
}

                        
                    if(shippingCheck){ //added as part of EDGE-128126 - if Shipping required is true then only populate delivery details in payload
                        if(ServiceMap.get(serviceIdGUIDMap.get(prodId)).Delivery_Address__c != null && !isDeviceReplacePresent) {
                            ManageOrderDataObject.CharacteristicDataObject prodCharComp4 = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharComp4.name = 'deliveryAddressID';
                            prodCharComp4.value = ServiceMap.get(serviceIdGUIDMap.get(prodId)).Delivery_Address__r.Address_ID__c;
                            prodCharList.add(prodCharComp4);
                            
                        }else if(ServiceMap.get(serviceIdGUIDMap.get(prodId)).csord__Service__c != null && !isDeviceReplacePresent){ //added by Manish - Design gap fix
                            String parentService = ServiceMap.get(serviceIdGUIDMap.get(prodId)).csord__Service__c;
                            if(ServiceMap.get(parentService).Delivery_Address__c != null){
                            ManageOrderDataObject.CharacteristicDataObject prodCharComp4 = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharComp4.name = 'deliveryAddressID';
                            prodCharComp4.value = ServiceMap.get(parentService).Delivery_Address__r.Address_ID__c;
                            prodCharList.add(prodCharComp4);}
                            
                        } //END - Design gap fix 
                        
                                //EDGE-130234-Dheeraj Bhatt-02-Jan-19-Address ID should be same for Replaced and Replacement device
                                else{
                                    ManageOrderDataObject.CharacteristicDataObject prodCharComp4 = new ManageOrderDataObject.CharacteristicDataObject();
                                    prodCharComp4.name = 'deliveryAddressID';
                                    prodCharComp4.value =replacedServiceDeliveryAddressId ;
                                    prodCharList.add(prodCharComp4);
                                }
                        // Added for 65707 :: 19.4 :: 14/3/2019 :: 
                        //Start
                        csord__Service__c serviceObj = ServiceMap.get(serviceIdGUIDMap.get(prodId));
                        if (serviceDeliveryContactMap.containsKey(serviceObj.csordtelcoa__Service_Number__c)) {
                            
                            Contact contact = serviceDeliveryContactMap.get(serviceObj.csordtelcoa__Service_Number__c);
                            
                            ManageOrderDataObject.CharacteristicDataObject prodCharComp5 = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharComp5.name = 'deliveryContactTitle';
                            prodCharComp5.value = contact.Title;
                            prodCharList.add(prodCharComp5);
                            
                            ManageOrderDataObject.CharacteristicDataObject prodCharComp6 = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharComp6.name = 'deliveryContactFirstName';
                            prodCharComp6.value = contact.FirstName;
                            prodCharList.add(prodCharComp6);
                            
                            ManageOrderDataObject.CharacteristicDataObject prodCharComp7 = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharComp7.name = 'deliveryContactLastName';
                            prodCharComp7.value = contact.LastName;
                            prodCharList.add(prodCharComp7);
                            
                            ManageOrderDataObject.CharacteristicDataObject prodCharComp8 = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharComp8.name = 'deliveryContactEmailAddress';
                            prodCharComp8.value = contact.Email;
                            prodCharList.add(prodCharComp8);
                            
                            ManageOrderDataObject.CharacteristicDataObject prodCharComp9 = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharComp9.name = 'deliveryContactPhoneNumber';
                            if (Contact.MobilePhone != null) {
                                prodCharComp9.value = contact.MobilePhone;
                            } else if (Contact.Phone != null) {
                                prodCharComp9.value = contact.Phone;
                            }
                            prodCharList.add(prodCharComp9);
                            
                        }
                    }
                        //End
                        system.debug('prodCharList==' + prodCharList);
                        if (prodCharList != NULL && !prodCharList.isEmpty()) {
                            if (specToCharacteristicMap.containsKey(prodId)) {
                                specToCharacteristicMap.get(prodId).addAll(prodCharList);
                            } else {
                                List < ManageOrderDataObject.CharacteristicDataObject > prodChar = new List < ManageOrderDataObject.CharacteristicDataObject > ();
                                prodChar.addAll(prodCharList);
                                specToCharacteristicMap.put(prodId, prodChar);
                            }
                        }
                    } else {
                        List < ManageOrderDataObject.CharacteristicDataObject > prodCharList = new List < ManageOrderDataObject.CharacteristicDataObject > ();
                        
                        if (ServiceMap.get(serviceIdGUIDMap.get(prodId)).Cust_Req_Disconn_Date__c != null) {
                            ManageOrderDataObject.CharacteristicDataObject prodCharComp3 = new ManageOrderDataObject.CharacteristicDataObject();
                            prodCharComp3.name = 'requestedCompletionDate';
                            Datetime reqdiscdate = ServiceMap.get(serviceIdGUIDMap.get(prodId)).Cust_Req_Disconn_Date__c;
                            if (reqdiscdate != Null) {
                                prodCharComp3.value = String.valueOf(reqdiscdate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS'));
                            }
                            prodCharList.add(prodCharComp3);
                        }
                        
                        //add to orderiteams
                        if (prodCharList != NULL && !prodCharList.isEmpty()) {
                            if (specToCharacteristicMap.containsKey(prodId)) {
							//EDGE-144900 Kalashree Borgaonkar. Populate 'Port out' in scenarioType. Start
								 if(ServiceMap.get(serviceIdGUIDMap.get(prodId)).Scenario_Type__c =='Port Out')
                                {        
                                    ManageOrderDataObject.CharacteristicDataObject prodCharCompScenarioType = new ManageOrderDataObject.CharacteristicDataObject();
                                    prodCharCompScenarioType.name = 'ScenarioType';
                                    prodCharCompScenarioType.value = ServiceMap.get(serviceIdGUIDMap.get(prodId)).Scenario_Type__c;
                                    prodCharList.add(prodCharCompScenarioType);
									System.debug('Port Out ScenarioType: ');
                                }
								//EDGE-144900 Kalashree Borgaonkar. Populate 'Port out' in scenarioType. End
                                specToCharacteristicMap.get(prodId).addAll(prodCharList);
                            } else {
							//EDGE-144900 Kalashree Borgaonkar. Populate 'Port out' in scenarioType. Start
								if(ServiceMap.get(serviceIdGUIDMap.get(prodId)).Scenario_Type__c =='Port Out')
                                {         
                                    ManageOrderDataObject.CharacteristicDataObject prodCharCompScenarioType = new ManageOrderDataObject.CharacteristicDataObject();
                                    prodCharCompScenarioType.name = 'ScenarioType';
                                    prodCharCompScenarioType.value = ServiceMap.get(serviceIdGUIDMap.get(prodId)).Scenario_Type__c;
                                    prodCharList.add(prodCharCompScenarioType);
									 System.debug('Port Out ScenarioType: ');
                                }
								//EDGE-144900 Kalashree Borgaonkar. Populate 'Port out' in scenarioType. End
                                List < ManageOrderDataObject.CharacteristicDataObject > prodChar = new List < ManageOrderDataObject.CharacteristicDataObject > ();
                                prodChar.addAll(prodCharList);
                                specToCharacteristicMap.put(prodId, prodChar);
                            }
                        }
                    }
                    
                }
                
                
                if (specToCharacteristicMap.containsKey(prodId)) {
                    orderItem.orderItemCharacteristic = specToCharacteristicMap.get(prodId);
                }
                orderItems.add(orderItem);
                System.debug('OrderItem::: ' + orderItem);
            }
        }
        
        
        System.debug(orderItems);
        return orderItems;
    }
    
    @testVisible
    private static Map < String, ManageOrderDataObject.ProductDataObject > fetchRelations(Map < String, ManageOrderDataObject.ProductDataObject > srvOrderProd, Map < String, CS_SpecificationDTO.ServiceSpecification > serviceEDMMap, Map < String, List < String >> ProdChildConfigIds) {
        //Boolean hasChildren = false; 
        Boolean childOrderItem = false;
        Map < String, ManageOrderDataObject.ProductDataObject > prodSet = new Map < String, ManageOrderDataObject.ProductDataObject > ();
        Map < String, String > prerelations = new Map < String, String > ();
        Map < String, List < String >> relations = new Map < String, List < String >> ();
        for (String specId: new List < String > (srvOrderProd.keySet())) {
            System.debug('SpecId : ' + specId);
            ManageOrderDataObject.ProductDataObject prod = srvOrderProd.get(specId);
            System.debug('Prod : ' + prod);
            List < ManageOrderDataObject.CharacteristicDataObject > prodChars = prod.productCharacteristic;
            String parentSpec = null;
            String parentGUID = null;
            if (!prodChars.isEmpty()) {
                for (ManageOrderDataObject.CharacteristicDataObject attr: prodChars) {
                    if (attr.name.contains('parentSpec') && String.isNotEmpty(attr.value)) {
                        childOrderItem = true;
                        parentSpec = attr.value;
                        System.debug('parentSpec : ' + parentSpec);
                    }
                }
                if (childOrderItem) {
                    for (ManageOrderDataObject.ProductDataObject spec: new List < ManageOrderDataObject.ProductDataObject > (srvOrderProd.values())) {
                        
                        if (spec.id == parentSpec) {
                            parentGUID = spec.id;
                            
                        }
                    }
                }
            }
            if (childOrderItem && (parentGUID != null)) {
                if (relations.get(parentGUID) != null) {
                    relations.get(parentGUID).add(specId);
                } else
                    relations.put(parentGUID, new List < String > {
                        specid
                            });
            } else {
                if (relations.get(specId) == null)
                    relations.put(specId, null);
            }
        }
        Map < String, List < String >> updatedRelations = new Map < String, List < String >> ();
        for (String specId: relations.keySet()) {
            integer modifycount = 0;
            integer addcount = 0;
            integer disconnectCount = 0;
            Integer childCount = 0;
            Integer completedCount = 0;
            List < String > childSpecs = new List < String > (relations.get(specId));
            if (childSpecs != null) {
                childCount = childSpecs.size();
            }
            if (childCount == 0) {
                CS_SpecificationDTO.ServiceSpecification specNoChild = serviceEDMMap.get(specId);
                if (!specNoChild.status.contains('Complete') && !specNoChild.status.contains('Disconnected')) {
                    updatedRelations.put(specId, null);
                }
            } else {
                CS_SpecificationDTO.ServiceSpecification spec = serviceEDMMap.get(specId);
                ManageOrderDataObject.ProductDataObject parentProd = srvOrderProd.get(specId);
                
                if (!spec.status.contains('Complete') && !spec.status.contains('Disconnected')) {
                    updatedRelations.put(specId, childSpecs);
                } else {
                    //CS_SpecificationDTO.ServiceSpecification spec = serviceEDMMap.get(specId);
                    for (String childSpecId: childSpecs) {
                        CS_SpecificationDTO.ServiceSpecification childSpec = serviceEDMMap.get(childSpecId);
                        if (childSpec.status.contains('Created')) {
                            addCount += 1;
                        } else if (childSpec.status.contains('Modified')) {
                            modifycount += 1;
                        } else if (childSpec.status.contains('Disconnect')) {
                            disconnectCount += 1;
                        } else if (childSpec.status.contains('Complete')) {
                            completedCount += 1;
                        }
                        if (!childSpec.status.contains('Complete') && !childSpec.status.contains('Disconnected')) {
                            updatedRelations.put(specId, childSpecs);
                            break;
                        }
                    }
                    if (modifycount > 0 || addCount > 0 || disconnectCount > 0) {
                        parentProd.action = 'modify';
                    } else if ((childCount == completedCount) && (completedCount > 0)) {
                        parentProd.action = 'no_change';
                    }
                    
                }
            }
        }
        system.debug('updatedRelations==' + updatedRelations);
        system.debug('relations==' + relations);
        ProdChildConfigIds.putAll(updatedRelations);
        for (String prodid: New List < String > (updatedRelations.keySet())) {
            prodSet.put(prodid, srvOrderProd.get(prodid));
            system.debug('prodid ==' + prodid);
            List < String > childProds = relations.get(prodid);
            System.debug('ChildProds : ' + childProds);
            if (childProds != null) {
                
                addChildProd(childProds, prodid, srvOrderProd, prodSet);
            }
        }
        System.debug('fetchRelationship::: ' + prodSet);
        return prodSet;
    }
    
    @testVisible
    private static void addChildProd(List < String > childProds, String prodid, Map < String, ManageOrderDataObject.ProductDataObject > srvOrderProd, Map < String, ManageOrderDataObject.ProductDataObject > prodSet) {
        List < ManageOrderDataObject.ProductRelationshipDataObject > childProdrelation = new List < ManageOrderDataObject.ProductRelationshipDataObject > ();
        for (String childId: childProds) {
            ManageOrderDataObject.ProductRelationshipDataObject childProd = new ManageOrderDataObject.ProductRelationshipDataObject();
            childProd.type = 'contains';
            childProd.product = srvOrderProd.get(childId);
            childProdrelation.add(childProd);
        }
        if (prodSet.get(prodid) != null)
            prodSet.get(prodid).productRelationship = childProdrelation;
    }
    
    @testVisible
    private static Map < String, ManageOrderDataObject.ProductDataObject > createProd(List < CS_SpecificationDTO.ServiceSpecification > serviceCfs, Map < String, Task__c > taskAppointmentMap, Map < String, Map < String, String >> guidToTransientAttributesMap) {
        Map < String, ManageOrderDataObject.ProductDataObject > srvOrderProd = new Map < String, ManageOrderDataObject.ProductDataObject > ();
        for (CS_SpecificationDTO.ServiceSpecification service: serviceCfs) {
            if(service.status !='Paid Out'){
            ManageOrderDataObject.ProductDataObject prod = new ManageOrderDataObject.ProductDataObject();
            ManageOrderDataObject.ProductSpecificationDataObject prodSpec = new ManageOrderDataObject.ProductSpecificationDataObject();
            List < ManageOrderDataObject.CharacteristicDataObject > prodChars = new List < ManageOrderDataObject.CharacteristicDataObject > ();
            prodSpec.code = service.code.removeEnd('_Fulfilment');
            if (String.isNotEmpty(service.instanceId)) {
                prod.id = service.instanceId;
            } else {
                prod.id = service.guid;
            }
            prod.action = ManageOrderServiceHelper.getProdAction(service.status);
            prod.productSpecification = prodSpec;
            addProductSimpleAttributes(prod, service.simpleAttributes, guidToTransientAttributesMap);
            if (taskAppointmentMap.containsKey(service.guid)) {
                ManageOrderDataObject.CharacteristicDataObject prodCharComplex = new ManageOrderDataObject.CharacteristicDataObject();
                prodCharComplex.name = 'TaskId';
                prodCharComplex.value = taskAppointmentMap.get(service.guid).TaskId__c;
                prod.productCharacteristic.add(prodCharComplex);
            }
            if (service.additionalAttributes != NULL && !service.additionalAttributes.isEmpty()) {
                addProductSimpleAttributes(prod, service.additionalAttributes, guidToTransientAttributesMap);
            }
            if (service.complexAttributes != NULL && !service.code.contains('DMCAT_ProductSpecification_000313')) {
                for (List < CS_SpecificationDTO.ComplexAttributes > complexChars: service.complexAttributes.values()) {
                    addProductComplexAttributes(prod, complexChars, guidToTransientAttributesMap);
                }
            }
            system.debug('test===' + service.code);
            if (service.code.contains('DMCAT_ProductSpecification_000313') || service.code.contains('DMCAT_ProductSpecification_000871')) {
                ManageOrderServiceUtilityHelper.transformNumbertToProductCharacteristic(service, prod);
            }
            srvOrderProd.put(prod.id, prod);
        }}
        
        return srvOrderProd;
    }
    // Update for 65707 :: 19.4 :: 14/3/2019 :: by one extra Arg - serviceDeliveryContactMap
    //Start
    public static void putServiceData(Map < String, String > serviceCancelDateMap, ManageOrderServiceUtility.OrderData order, ManageOrderDataObject.ProductOrder orderDTO, List < ManageOrderServicesDTO > servicesData,
                                      List < CS_SpecificationDTO.ServiceSpecification > cfsMap, Map < Id, List < ManageOrderDataObject.PlaceDataObject >> orderSitesMap, Map < String, Contact > serviceDeliveryContactMap, Map < String, Map < String, String >> guidToTransientAttributesMap) {
                                          System.debug('guidToTransientAttributesMap in putServiceData==>'+guidToTransientAttributesMap);
                                          //End
                                          //if(servicesData.containsKey(order.orderId)){
                                          List < ManageOrderDataObject.OrderItemDataObject > orderItems = new List < ManageOrderDataObject.OrderItemDataObject > ();
                                          // Update for 65707 :: 19.4 :: 14/3/2019 :: by one extra Arg - serviceDeliveryContactMap
                                          //Start 
                                          orderItems = convertEDMtoOrderItems(serviceCancelDateMap, order, orderDTO, cfsMap, servicesData, orderSitesMap, serviceDeliveryContactMap, guidToTransientAttributesMap);
                                          //End
                                          orderDTO.orderItem = orderItems;
                                          //}
                                      }
    
    private static void addProductComplexAttributes(ManageOrderDataObject.ProductDataObject prod, List < CS_SpecificationDTO.ComplexAttributes > complexChars, Map < String, Map < String, String >> guidToTransientAttributesMap) {
        System.debug('guidToTransientAttributesMap in addProductComplexAttributes==>'+guidToTransientAttributesMap);
        for (CS_SpecificationDTO.ComplexAttributes complexChar: complexChars) {
            addProductSimpleAttributes(prod, complexChar.simpleAttributes, guidToTransientAttributesMap);
        }
    }
    
    private static void addProductSimpleAttributes(ManageOrderDataObject.ProductDataObject prod, List < CS_SpecificationDTO.SimpleAttributes > simpleChars, Map < String, Map < String, String >> guidToTransientAttributesMap) {
        Boolean FlagVar = false;
        System.debug('ProductDataObject:::' + prod + '--SimpleAttributes:::' + simpleChars);
        Map < String, ManageOrderDataObject.CharacteristicDataObject > prodCharacteristicMap = new Map < String, ManageOrderDataObject.CharacteristicDataObject > ();
        
        List < String > exclusionList = ManageOrderServiceAttributes.getExclusionAttribute('FulfilmentPayload');
        List<ManageOrderDataObject.CharacteristicDataObject> prodCharComplex2 = new List<ManageOrderDataObject.CharacteristicDataObject>();
        
        if (prod.productCharacteristic != null) {
            for (ManageOrderDataObject.CharacteristicDataObject productChar: prod.productCharacteristic) {

                prodCharacteristicMap.put(productChar.name, productChar);
                /*
                if(guidToTransientAttributesMap.keyset().contains(prod.id)){
                    System.debug('prod.id==>'+prod.id);
                    
                    Map < String, String > tranAttrMap = guidToTransientAttributesMap.get(prod.id);
                    for (String str: tranAttrMap.keySet()) {
                        if(tranAttrMap.get(str) != null && tranAttrMap.get(str) != ''){
                            
                            ManageOrderDataObject.CharacteristicDataObject prodCharComplex1 = new ManageOrderDataObject.CharacteristicDataObject();
                            
                            prodCharComplex1.name = str;
                            prodCharComplex1.value = tranAttrMap.get(str);
                            System.debug('prodCharComplex.name==>'+prodCharComplex1.name +'prodCharComplex.value==>'+prodCharComplex1.value);
                            //prodCharComplex2.add(prodCharComplex1);
                            prodCharacteristicMap.put(prodCharComplex1.name, prodCharComplex1);
                        }
                    }
                    
                }
                */
            }
        }
        
        for (CS_SpecificationDTO.SimpleAttributes simpleAttr: simpleChars) {
            ManageOrderDataObject.CharacteristicDataObject prodCharComplex = new ManageOrderDataObject.CharacteristicDataObject();
            // if(!simpleAttr.name.contains('Appointment_') && !simpleAttr.name.contains('feasibilityNumber') && !simpleAttr.name.contains('CPEDeliveryDate')){
            if (!exclusionList.contains(simpleAttr.name.removeStart(prod.productSpecification.code + '_'))) {
                if (simpleAttr.name.contains('ModuleInstanceId')) {
                    prodCharComplex.name = simpleAttr.name;
                    prodCharComplex.value = prod.id;
                } else if (prodCharacteristicMap.containsKey(simpleAttr.name)) {
                    prodCharComplex.name = simpleAttr.name;
                    prodCharComplex.value = simpleAttr.value;
                    prodCharacteristicMap.put(prodCharComplex.name, prodCharComplex);
                } else {
                    prodCharComplex.name = simpleAttr.name;
                    prodCharComplex.value = simpleAttr.value;
                }
                prodCharacteristicMap.put(prodCharComplex.name, prodCharComplex);
            }
            system.debug('isDeviceReplacePresent>>>>'+isDeviceReplacePresent);
                        
            if (simpleAttr.name.contains(prod.productSpecification.code)) {
                ManageOrderDataObject.CharacteristicDataObject prodCharComp = new ManageOrderDataObject.CharacteristicDataObject();
                prodCharComp.name = simpleAttr.name.removeStart(prod.productSpecification.code + '_');
                prodCharComp.value = simpleAttr.value;
                if (specToCharacteristicMap.containsKey(prod.id)) {
                    
                    List < ManageOrderDataObject.CharacteristicDataObject > prodCharComp1 = specToCharacteristicMap.get(prod.id);
                    for (ManageOrderDataObject.CharacteristicDataObject prodchar: prodCharComp1) {
                        system.debug('specToCharacteristicMap1' + prodchar.name + prodchar.value);
                        
                        if (prodchar.name.contains('CPEDeliveryDate')) {
                            system.debug('prodCharComp' + prodCharComp);
                            if (prodCharComp.value >= prodchar.value) {
                                prodchar.value = prodCharComp.value;
                                FlagVar = true;
                            }
                        }
                    }
                    system.debug('prodCharComp1List' + prodCharComp1);
                    if (FlagVar) {
                        system.debug('I am inside flag');
                        
                        specToCharacteristicMap.put(prod.id, prodCharComp1);
                    }
                } else {
                    List < ManageOrderDataObject.CharacteristicDataObject > prodChar = new List < ManageOrderDataObject.CharacteristicDataObject > ();
                    prodChar.add(prodCharComp);
                    specToCharacteristicMap.put(prod.id, prodChar);
                }
            }
        }
        
        if(guidToTransientAttributesMap.keyset().contains(prod.id)){
            System.debug('prod.id==>'+prod.id);         
            Map < String, String > tranAttrMap = guidToTransientAttributesMap.get(prod.id);
            for (String str: tranAttrMap.keySet()) {
                if(tranAttrMap.get(str) != null && tranAttrMap.get(str) != ''){
                    
                    ManageOrderDataObject.CharacteristicDataObject prodCharComplex1 = new ManageOrderDataObject.CharacteristicDataObject();
                    prodCharComplex1.name = str;
                    prodCharComplex1.value = tranAttrMap.get(str);
                    System.debug('prodCharComplex.name==>'+prodCharComplex1.name +'prodCharComplex.value==>'+prodCharComplex1.value);
                    //prodCharComplex2.add(prodCharComplex1);
                    prodCharacteristicMap.put(prodCharComplex1.name, prodCharComplex1);
                }
            }           
        }
        
        
        
        prod.productCharacteristic = prodCharacteristicMap.values();
        
        System.debug('prod.productCharacteristic==>'+prod.productCharacteristic);
    }
    
    private static void putAddressData(ManageOrderDataObject.AddressDataObject addr, csord__Service__c svc) {
        addr.id = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_ID__c;
        addr.type = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Address_Type__c;
        addr.street1 = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_Line_1__c;
        addr.street2 = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_Line_2__c;
        addr.city = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__City__c;
        addr.stateOrProvince = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__State_Province__c;
        addr.postCode = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Zip_Postal_Code__c;
        addr.country = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Country__c;
        addr.room = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Street_Number_From__c;
        addr.streetNr = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Street_Number_From__c;
        addr.apartment = svc.csord__Subscription__r.Site__r.Name;
        addr.floor = svc.csord__Subscription__r.Site__r.cscrm__Floor__c;
        addr.buildingName = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Building_Name__c;
        addr.streetType = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.streetType__c;
        addr.streetName = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Street_Name__c;
        addr.locality = svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Locality__c;
        ManageOrderDataObject.GeocodeDataObject geoCode = new ManageOrderDataObject.GeocodeDataObject();
        geoCode.latitude = String.valueOf(svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Geolocation__latitude__s);
        geoCode.longitude = String.valueOf(svc.csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Geolocation__longitude__s);
        if (geoCode.latitude != null && geoCode.longitude != null) {
            addr.geocode = geoCode;
        }
    }
    
    private static void putContactData(ManageOrderDataObject.ContactDataObject person, Functional_Contact_Role__c siteContactRole) {
        List < ManageOrderDataObject.ContactMediumDataObject > mediumTypes = new List < ManageOrderDataObject.ContactMediumDataObject > ();
        ManageOrderDataObject.ContactMediumDataObject mediumEmail = new ManageOrderDataObject.ContactMediumDataObject();
        ManageOrderDataObject.ContactMediumDataObject mediumTele = new ManageOrderDataObject.ContactMediumDataObject();
        ManageOrderDataObject.MediumDataObject mediumE = new ManageOrderDataObject.MediumDataObject();
        ManageOrderDataObject.MediumDataObject mediumN = new ManageOrderDataObject.MediumDataObject();
        
        mediumN.number1 = siteContactRole.ContactID__r.Phone;
        mediumE.emailAddress = siteContactRole.ContactID__r.Email;
        if (mediumE.emailAddress != null && mediumE.emailAddress != '') {
            mediumEmail.type = 'Email';
            mediumEmail.medium = mediumE;
            mediumTypes.add(mediumEmail);
        }
        if (mediumN.number1 != null && mediumN.number1 != '') {
            mediumTele.type = 'Telephone';
            mediumTele.medium = mediumN;
            mediumTypes.add(mediumTele);
        }
        
        person.givenName = siteContactRole.ContactID__r.FirstName;
        
        person.familyName = siteContactRole.ContactID__r.LastName;
        person.middleName = siteContactRole.ContactID__r.MiddleName;
        person.id = siteContactRole.ContactID__c;
        person.title = siteContactRole.ContactID__r.Title;
        
        person.type = ManageOrderServiceUtilityHelper.translateContactType(siteContactRole.Role__c);
        person.contactMedium = mediumTypes;
        
        //System.debug('putContactData : '+ siteContactRole+' : '+ person);
    }
}