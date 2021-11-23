//Updated for EDGE-4048
/**************************************************
 * Desc: This class is used by ManageOrderService to query Order and related objects (Services)
 * Sites, Site Contacts, Site address
**************************************************/
public with sharing class ManageOrderServiceHelper {
    Map<Id, List<Id>> orderToReplacedSubscriptionsMap = new Map<Id, List<Id>>();
    public static Map<Id, csord__Order__c> fetchAllOrders(List<Id> orderIds){
        Map<Id, csord__Order__c> subOrderMap = new Map<Id, csord__Order__c>();
        if(!orderIds.isEmpty()){
            //Fetch parent and sub orders
            //Added OwnerId in the Query below : Changes for EDGE-80798
            List<csord__Order__c> allOrders = [SELECT Id,ModelChange__c, csord__Cease_Category__c, Name, csord__Cease_Reason__c,csord__Cease_Reason_Comment__c,
               csord__Cease_Stage__c,csord__Customer_Order_Number__c, csord__Delivered_Date__c,csord__Desired_Cease_Date__c, csord__End_Date__c, 
               Opportunity_ID__c, csord__Order_Number__c,Fulfilment_Order_Number__c,Fulfilment_Order_Version__c, csord__Order_Type__c,
               csord__Primary_Order__c,csordtelcoa__Product_Configuration__c, csord__Product_Type__c,csord__Reference__c,Service_Number__c,
               csord__Start_Date__c,csord__Status2__c, csord__Status_Reason__c,csord__Total_One_Off_Charges__c,csord__Account__c,
               csord__Account__r.Name,csord__Account__r.ABN__c,csord__Account__r.ABN_Overide__c,csord__Account__r.CIDN__c, csord__Account__r.Type,
               csord__Account__r.ABN_Registered_Name__c,csord__Account__r.ABN_Status__c,csord__Account__r.ABN_Trading_Name__c,csord__Account__r.ABN_Type__c,csord__Account__r.Business_Unit__c,
               Project_ID__c,PM_Required__c,Project_Complexity__c,Project_Manager_User_ID__c,Project_Manager_Contact_Number__c,Project_Manager_Email__c,
               csordtelcoa__Opportunity__r.Owner.FederationIdentifier,csordtelcoa__Opportunity__r.Owner.FirstName,csordtelcoa__Opportunity__r.Owner.LastName,
               csordtelcoa__Opportunity__r.Owner.Email,csordtelcoa__Opportunity__r.Owner.Phone,createdDate,OwnerId,
                                               Scenario_Type__c,Tactical_Handling_Type__c,
                                               (select id,name,ContactID__r.FirstName,ContactID__r.LastName,ContactID__r.Phone,ContactID__r.MobilePhone,ContactID__r.Email from Functional_Contact_Roles__r where Role_Type__c  = 'Order' LIMIT 1 )
               FROM csord__Order__c WHERE (Id IN:orderIds OR csord__Primary_Order__c IN:orderIds)];
            // Scenario Type added as part of EDGE-66477
            System.debug('allOrders:::' + allOrders);
            for(csord__Order__c ord: allOrders){
                
                if(!subOrderMap.containsKey(ord.Id) && ord.csord__Primary_Order__c == null)
                    subOrderMap.put(ord.Id, ord);
            }

            for(csord__Order__c ord: allOrders){
                
                if(ord.csord__Primary_Order__c != null){
                    if(!subOrderMap.containsKey(ord.Id))
                        subOrderMap.put(ord.Id, subOrderMap.get(ord.csord__Primary_Order__c));
                }
            }
        }
        System.debug('fetchAllOrders::: '+subOrderMap);
        return subOrderMap;

    }

    public static Map<Id, csord__Service__c> getOderDetails(List<String> orderIds, Map<Id, List<Id>> orderToReplacedSubMap){
        List<csord__Service__c> servicelist = new List<csord__Service__c>();
        List<csord__Service__c> replacedServicelist = new List<csord__Service__c>();
        servicelist = [SELECT Id,Name,AAN_Service_Desk__c,AccessType__c,csordtelcoa__Service_Number__c, csord__Activation_Date__c,
                       AdOnHold__c,csordtelcoa__Main_Contact__c,ContractTerms__c,Customer_Requested_Date__c,
                       csord__Deactivation_Date__c,csord__Deactivation_Reason__c,csordtelcoa__Delta_Status__c,
                       csord__Service__c,csord__Status__c,TechnologyType__c,csord__Total_One_Off_Charges__c,
                       csord__Total_Recurring_Charges__c,TrainingType__c,VoicePlanType__c,Speed__c,SiteId__c,
                       Service_Codes_Add_1__c,Service_Codes_Add_2__c,csord__Order__c,csord__Order__r.csord__Cease_Category__c,
                       csord__Order__r.Name, csord__Order__r.csord__Cease_Reason__c,csord__Order__r.csord__Cease_Reason_Comment__c,
                       csord__Order__r.csord__Cease_Stage__c,csord__Order__r.csord__Customer_Order_Number__c,
                       csord__Order__r.csord__Delivered_Date__c,csord__Order__r.csord__Desired_Cease_Date__c,
                       csord__Order__r.csord__End_Date__c, csord__Order__r.Opportunity_ID__c, csord__Order__r.csord__Order_Number__c,
                       csord__Order__r.Fulfilment_Order_Number__c,csord__Order__r.Fulfilment_Order_Version__c,
                       csord__Order__r.csord__Order_Type__c,csord__Order__r.csord__Primary_Order__c,csord__Order__r.csordtelcoa__Product_Configuration__c,
                       csord__Order__r.csord__Product_Type__c,csord__Order__r.csord__Reference__c,csord__Order__r.Service_Number__c,
                       csord__Order__r.csord__Start_Date__c,csord__Order__r.csord__Status2__c,csord__Order__r.csord__Status__c,
                       csord__Order__r.csord__Status_Reason__c,csord__Order__r.csord__Total_One_Off_Charges__c,csord__Subscription__c,
                       csord__Subscription__r.csord__Account__c, csord__Subscription__r.csconta__Billing_Account__c,
                       csord__Subscription__r.Cancellation_Date_of_Effect__c,csord__Subscription__r.csordtelcoa__Change_Type__c,
                       csord__Subscription__r.csordtelcoa__Closed_Replaced__c,csord__Subscription__r.Customer_Application_Date__c,
                       csord__Subscription__r.Customer_Reference_Number__c,csord__Subscription__r.Parent_Subscription__c,
                       csord__Subscription__r.Parent_TRN__c,csord__Subscription__r.PM_Details__c,csord__Subscription__r.PM_Group__c,
                       csord__Subscription__r.PM_ID__c,csord__Subscription__r.Reason_for_cancellation__c,csord__Subscription__r.Site__c,
                       csord__Subscription__r.csord__Solution__c,csord__Subscription__r.csord__Status__c,csord__Subscription__r.csord__Total_One_Off_Charges__c,
                       csord__Subscription__r.csordtelcoa__Subscription_Number__c,csord__Subscription__r.csord__Total_Recurring_Charges__c,
                       csord__Subscription__r.csord__Total_Service_One_Off_Charges__c,csord__Subscription__r.csord__Total_Service_Recurring_Charges__c,
                       csord__Order__r.csord__Account__c,csord__Order__r.csord__Account__r.Name,csord__Order__r.csord__Account__r.ABN__c,
                       csord__Order__r.csord__Account__r.ABN_Overide__c,csord__Order__r.csord__Account__r.CIDN__c, csord__Order__r.csord__Account__r.Type,
                       csord__Order__r.csord__Account__r.ABN_Registered_Name__c,csord__Order__r.csord__Account__r.ABN_Status__c,
                       csord__Order__r.csord__Account__r.ABN_Trading_Name__c,csord__Order__r.csord__Account__r.ABN_Type__c,
                       csord__Subscription__r.Site__r.Name,csord__Subscription__r.Site__r.cscrm__Position__c,csord__Subscription__r.Site__r.cscrm__Floor__c,csord__Subscription__r.Site__r.cscrm__Rack_Location__c,
                       csord__Subscription__r.Site__r.cscrm__Spare_Network_Port__c,csord__Subscription__r.Site__r.Status__c,csord__Subscription__r.Site__r.cscrm__Suite_Room__c,
                       csord__Subscription__r.Site__r.cscrm__Installation_Address__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Address_Type__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_ID__c,
                       csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_Line_1__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_Line_2__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__City__c,
                       csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__State_Province__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Zip_Postal_Code__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Country__c,
                       csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Building_Name__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.streetType__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Street_Name__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Street_Type__c,
                       csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Locality__c, csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Geolocation__latitude__s, csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Geolocation__longitude__s,
                       csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Property_Name__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Street_Number_From__c,
                       csord__Subscription__r.csordtelcoa__Replaced_Subscription__c, csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c,csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__Primary_Order__c,
                       TenancyPrimaryContact__c,TenancyPrimaryContact__r.firstName,TenancyPrimaryContact__r.lastName,TenancyPrimaryContact__r.MobilePhone,TenancyPrimaryContact__r.Phone,TenancyPrimaryContact__r.Email
                       FROM csord__Service__c WHERE csord__Order__c IN:orderIds AND csord__Order__c != null];

        Map<Id, csord__Service__c> srvcMap = new Map<Id, csord__Service__c>(); 
        List<Id> replacedSubscriptionList = new List<Id>();     
        for(csord__Service__c srv : servicelist){
            if(String.isNotBlank(srv.csord__Subscription__r.csordtelcoa__Replaced_Subscription__c) && String.isBlank(srv.csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c)) {
                system.debug('entered buggggg---->>>>>>>\\\\');
                replacedSubscriptionList.add(srv.csord__Subscription__r.csordtelcoa__Replaced_Subscription__c);
            }
            srvcMap.put(srv.Id, srv);
        }
        
        if(!replacedSubscriptionList.isEmpty()){
        replacedServicelist = new List<csord__Service__c>([SELECT Id,Name,AAN_Service_Desk__c,AccessType__c,csordtelcoa__Service_Number__c, csord__Activation_Date__c,AdOnHold__c,csordtelcoa__Main_Contact__c,ContractTerms__c,Customer_Requested_Date__c,
                       csord__Deactivation_Date__c,csord__Deactivation_Reason__c,csordtelcoa__Delta_Status__c,
                       csord__Service__c,csord__Status__c,TechnologyType__c,csord__Total_One_Off_Charges__c,
                       csord__Total_Recurring_Charges__c,TrainingType__c,VoicePlanType__c,Speed__c,SiteId__c,
                       Service_Codes_Add_1__c,Service_Codes_Add_2__c,csord__Order__c,csord__Order__r.csord__Cease_Category__c,
                       csord__Order__r.Name, csord__Order__r.csord__Cease_Reason__c,csord__Order__r.csord__Cease_Reason_Comment__c,
                       csord__Order__r.csord__Cease_Stage__c,csord__Order__r.csord__Customer_Order_Number__c,
                       csord__Order__r.csord__Delivered_Date__c,csord__Order__r.csord__Desired_Cease_Date__c,
                       csord__Order__r.csord__End_Date__c, csord__Order__r.Opportunity_ID__c, csord__Order__r.csord__Order_Number__c,
                       csord__Order__r.Fulfilment_Order_Number__c,csord__Order__r.Fulfilment_Order_Version__c,
                       csord__Order__r.csord__Order_Type__c,csord__Order__r.csord__Primary_Order__c,csord__Order__r.csordtelcoa__Product_Configuration__c,
                       csord__Order__r.csord__Product_Type__c,csord__Order__r.csord__Reference__c,csord__Order__r.Service_Number__c,
                       csord__Order__r.csord__Start_Date__c,csord__Order__r.csord__Status2__c,csord__Order__r.csord__Status__c,
                       csord__Order__r.csord__Status_Reason__c,csord__Order__r.csord__Total_One_Off_Charges__c,csord__Subscription__c,
                       csord__Subscription__r.csord__Account__c, csord__Subscription__r.csconta__Billing_Account__c,
                       csord__Subscription__r.Cancellation_Date_of_Effect__c,csord__Subscription__r.csordtelcoa__Change_Type__c,
                       csord__Subscription__r.csordtelcoa__Closed_Replaced__c,csord__Subscription__r.Customer_Application_Date__c,
                       csord__Subscription__r.Customer_Reference_Number__c,csord__Subscription__r.Parent_Subscription__c,
                       csord__Subscription__r.Parent_TRN__c,csord__Subscription__r.PM_Details__c,csord__Subscription__r.PM_Group__c,
                       csord__Subscription__r.PM_ID__c,csord__Subscription__r.Reason_for_cancellation__c,csord__Subscription__r.Site__c,
                       csord__Subscription__r.csord__Solution__c,csord__Subscription__r.csord__Status__c,csord__Subscription__r.csord__Total_One_Off_Charges__c,
                       csord__Subscription__r.csordtelcoa__Subscription_Number__c,csord__Subscription__r.csord__Total_Recurring_Charges__c,
                       csord__Subscription__r.csord__Total_Service_One_Off_Charges__c,csord__Subscription__r.csord__Total_Service_Recurring_Charges__c,
                       csord__Order__r.csord__Account__c,csord__Order__r.csord__Account__r.Name,csord__Order__r.csord__Account__r.ABN__c,
                       csord__Order__r.csord__Account__r.ABN_Overide__c,csord__Order__r.csord__Account__r.CIDN__c, csord__Order__r.csord__Account__r.Type,
                       csord__Order__r.csord__Account__r.ABN_Registered_Name__c,csord__Order__r.csord__Account__r.ABN_Status__c,
                       csord__Order__r.csord__Account__r.ABN_Trading_Name__c,csord__Order__r.csord__Account__r.ABN_Type__c,
                       csord__Subscription__r.Site__r.Name,csord__Subscription__r.Site__r.cscrm__Position__c,csord__Subscription__r.Site__r.cscrm__Floor__c,csord__Subscription__r.Site__r.cscrm__Rack_Location__c,
                       csord__Subscription__r.Site__r.cscrm__Spare_Network_Port__c,csord__Subscription__r.Site__r.Status__c,csord__Subscription__r.Site__r.cscrm__Suite_Room__c,
                       csord__Subscription__r.Site__r.cscrm__Installation_Address__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Address_Type__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_ID__c,
                       csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_Line_1__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Address_Line_2__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__City__c,
                       csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__State_Province__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Zip_Postal_Code__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Country__c,
                       csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Building_Name__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.streetType__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Street_Name__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Street_Type__c,
                       csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Locality__c, csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Geolocation__latitude__s, csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Geolocation__longitude__s,
                       csord__Subscription__r.Site__r.cscrm__Installation_Address__r.cscrm__Property_Name__c,csord__Subscription__r.Site__r.cscrm__Installation_Address__r.Street_Number_From__c,
                       csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__Primary_Order__c,
                       TenancyPrimaryContact__c,TenancyPrimaryContact__r.firstName,TenancyPrimaryContact__r.lastName,TenancyPrimaryContact__r.MobilePhone,TenancyPrimaryContact__r.Phone,TenancyPrimaryContact__r.Email
                       FROM csord__Service__c
                       WHERE csord__Subscription__c IN :replacedSubscriptionList]);
        }
        for(csord__Service__c srv : replacedServicelist) {
            //Id currentOrderId = srv.csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c;
            Id currentOrderId = srv.csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__Primary_Order__c != null? srv.csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__Primary_Order__c : srv.csord__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c;
            if(String.isNotBlank(currentOrderId)) {
                Set<Id> subIds = new Set<Id>();
                if(orderToReplacedSubMap.containsKey(currentOrderId)) {
                    subIds = new Set<Id>(orderToReplacedSubMap.get(currentOrderId));
                }
                subIds.add(srv.csord__Subscription__c);
                orderToReplacedSubMap.put(currentOrderId, new List<Id>(subIds));
            }
            
            srvcMap.put(srv.Id, srv);
        }
        System.debug('getOderDetails:::' + srvcMap);
        return srvcMap;
    }
    
    public static Map<Id, Map<Id, List<Functional_Contact_Role__c>>> getSiteContacts (Map<Id, List<Id>> siteIdMap){
        Map<Id, Map<Id, List<Functional_Contact_Role__c>>> siteContactMap = new Map<Id, Map<Id, List<Functional_Contact_Role__c>>>();
        
        Set<Id> siteIdSet = new Set<Id>();
        for(Id orderId: new List<Id>(siteIdMap.keySet())){
            siteIdSet.addAll(siteIdMap.get(orderId));
        }
        List<Functional_Contact_Role__c> siteContactRoleList = new List<Functional_Contact_Role__c>();
        siteContactRoleList = [SELECT Id, ContactID__c, SiteID__c, Role__c, ContactID__r.FirstName, ContactID__r.MiddleName, ContactID__r.LastName, ContactID__r.Email, ContactID__r.Phone, ContactID__r.UUID__c, ContactID__r.Title from Functional_Contact_Role__c where SiteID__c in:siteIdSet];
        Map<Id, List<Functional_Contact_Role__c>> siteContactRoleMap = new Map<Id, List<Functional_Contact_Role__c>>();
        for(Functional_Contact_Role__c siteContact: siteContactRoleList){
            if(siteContactRoleMap.containsKey(siteContact.SiteID__c)){
                siteContactRoleMap.get(siteContact.SiteID__c).add(siteContact);
            } else{
                List<Functional_Contact_Role__c> siteContactRoles = new List<Functional_Contact_Role__c>();
                siteContactRoles.add(siteContact);
                siteContactRoleMap.put(siteContact.SiteID__c, siteContactRoles);
            }
        }
        
        for(Id orderId: new List<Id>(siteIdMap.keySet())){
            for(Id siteId: siteIdMap.get(orderId)){
                if(siteContactMap.containsKey(orderId)){
                    siteContactMap.get(orderId).put(siteId, siteContactRoleMap.get(siteId));
                } else{
                    Map<Id, List<Functional_Contact_Role__c>> siteContactRolesMap = new Map<Id, List<Functional_Contact_Role__c>>();
                    siteContactRolesMap.put(siteId, siteContactRoleMap.get(siteId));
                    siteContactMap.put(orderId, siteContactRolesMap);
                }
            }
        }
        System.debug('getSiteContacts : '+siteContactMap);
        return siteContactMap;
    }
        
    public static Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> getOrderSpecs(Map<Id, csord__Order__c> orders, Map<Id, List<Id>> orderToReplacedSubMap){
        
        Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> specMap = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();
        //Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> specPrimaryOrderMap = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();
        List<Id> orderIds = new List<Id>(orders.keySet());
        for (Id ordId: orderIds) {
            String orderSpec = csedm.API_1.getOrderSpecificationsById(ordId);
            system.debug('testspec:'+orderSpec);
            if(!String.isEmpty(orderSpec)){
                List<CS_SpecificationDTO.ServiceSpecification> specList = new List<CS_SpecificationDTO.ServiceSpecification>(CS_SpecificationDTO.parse(orderSpec,'FULFILMENT'));
                System.debug('SpecList : '+specList);
                if(orders.get(ordId) != null){
                    if(specMap.get(orders.get(ordId).Id) != null)
                        specMap.get(orders.get(ordId).Id).addAll(specList);
                    else
                        specMap.put(orders.get(ordId).Id, specList);
                }
            }
           
            if(orderToReplacedSubMap.containsKey(ordId)){
                for(Id subId : orderToReplacedSubMap.get(ordId)){ 
                    String subSpec = csedm.API_1.getSubscriptionSpecificationsById(subId);
                    if(!String.isEmpty(subSpec)){
                        List<CS_SpecificationDTO.ServiceSpecification> specList2 = CS_SpecificationDTO.parseSubscriptionSpec(subSpec,'FULFILMENT');
                        if(specMap.get(ordId) != null) {
                            specMap.get(ordId).addAll(specList2);
                        }
                        else {
                            specMap.put(ordId, specList2);
                        }
                    }
                }
            }
        }
        
        System.debug('getOrderSpecs : '+specMap);
        return specMap;
    }

    public static Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> getOrderSpecs(Map<Id, csord__Order__c> orders){
        
        Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> specMap = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();

        Set<Id> allOrderIds = orders.keySet();
        //query all EDM attachments
        Map<Id, csord__Service__c> srvcList = new Map<Id, csord__Service__c>([SELECT Id, Name, csord__Subscription__c, csord__Order__c FROM csord__Service__c WHERE csord__Order__c IN :allOrderIds]);
        List<Attachment> srvcAttachments = [SELECT Id, ParentId, Name, Body from Attachment WHERE Name = 'ServiceSpecifications.json' AND ParentId IN :srvcList.keySet()];
        //convert EDM attachments into Specs
        for(Attachment att : srvcAttachments){
          String specStr = EDMConversionUtil.ConvertServiceEDMToSpec(att.Body.toString());
          List<CS_SpecificationDTO.ServiceSpecification> specList = CS_SpecificationDTO.parseServiceSpec(specStr,'FULFILMENT');
          if(orders.get(srvcList.get(att.ParentId).csord__Order__c) != null){
            if(specMap.get(orders.get(srvcList.get(att.ParentId).csord__Order__c).Id) != null)
                specMap.get(orders.get(srvcList.get(att.ParentId).csord__Order__c).Id).addAll(specList);
            else
                specMap.put(orders.get(srvcList.get(att.ParentId).csord__Order__c).Id, specList);
          }
        }
        
        System.debug('getOrderSpecs : '+specMap);
        return specMap;
    }

    public static String getItemAction(String status){
        String action = 'Create';
        if(String.isNotBlank(status)){
        if(status.contains('Disconnect')){
            action = 'Create';
        }
        else if(status.contains('Cancel')){
            action = 'Cancel';
        }
        }
        return action;
    }

    public static String getProdAction(String status){
        String action = System.Label.Add;
        if(status.contains('Disconnect')){
            action = System.Label.Cease;
        }
        else if(status.contains('Modified')){
            action = System.Label.Modify1;
        }
        else if(status.contains('Complete') || status.contains('Cancelled')){
            action = System.Label.NoChange;
        }
        else if(status.contains('Suspend'))
        {
            action = System.Label.suspend;
        }else if(status.contains('Resume'))
        {
            action = System.Label.resume;
        }
        return action;
    }
}