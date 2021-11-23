/*
* Updates:
* 1. Ritika Jaiswal : EDGE - 66137 - ETC when PortOut
* 2. Ritika Jaiswal : EDGE - 66137 - Defect fix regarding disconnection-date
* 3. Vaibhav : EDGE-116482 - ShippingRequired fix
* 4. Vaibhav : EDGE-96386 - Suspend/Resume related changes
* 5. Vaibhav : EDGE-128090 - Inserted new mobile numbers into number object for change of number Orders
* 6. Vaibhav : EDGE-128126 - Filtered out delivery details information
* 7. Sandip  : EDGE-144389 - Changed billing subtype as per Sigma
* 8. Maq     : EDGE-144389 - Strategic Fix for Port out order
* 9. Vaibhav : EDGE-128126 - ScenarioType fix for Suspend and Resume Order

* 10.Manish  : EDGE-152563
* 11 Aruna Aware : DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services
* 12 Manish  : EDGE-159332 - Portout order code overwrite fix
* 13 Gnana   : EDGE-154370 - Updated Forecasted_Delivery_Date__c, Telstra_Committed_Date__c of Service's records to NULL
               to resolve an incident-INC000092634429
* 14 Gnana   : EDGE-167554 - As part of Spring'20 Upgrade, generateOrderSpecification api was depreciated, so provided a fix
               by calling generateSpecifications api
* 15 Gnana   : EDGE-165552 - Modified logic to set ShippingRequired to false irrespective of Product Spec for Port Out Order 
* 16 Gnana   : EDGE-165552 - Modified logic to call etcCahrge only when BillingSubType is ROETC and Port Out Order
* 17 Gnana   : EDGE-175208 - Modified csedm__CFS_Mapping_List__c to csedm__edm_mapping_list__c  
* 18 Vaibhav : EDGE-180200 - updated Cust_Req_Disconn_Date__c on services for port out order
* 19 Pawan   : EDGE-179370 - PayOut/PaidOut for PortOut scenarios
* 20 Gnana   : EDGE-185450 - ChangeType changes for PortOut and ChangeInMobileNumber Scenarios
* 21 Swapna  :EDGE-182667 - Updated Submisson Date with Current time
* 22 Ila/Krunal  :DPG:4543/DPG:4544 -DPG | Adaptive Mobility | Suspend Resume | P2O - Enhance 'suspend' submit order
* 23 Vaibhav :EDGE-223085  
*/ 
public with sharing class OrderGeneratorUtil{
    public static List<string>resourceList = new List<string>();
    /*CONSTANTS - begin --*/
    private final static String REQUESTED = 'Requested';
    private final static String MODULE_NAME = 'CS Order Implementation Module Telco A';
    private final static String MODULE_VER = '1.0';
    private final static String ORD_SUBMITTED = 'Order Submitted';
    private final static String ORDER = 'Order';
    private final static String ORDER_456 = 'Order_456';
    private final static String CHANGE_OF_MOBILE_NUMBER = 'Change of Mobile Number';
    private final static String PACKAGE_ORDER = 'Package Order';
    private final static String ORDER_6789 = 'Order_6789';
    private final static String SECONDARY = 'Secondary';
    private final static String PENDING = 'Pending';
    private final static String SECONDARY_ORDER = 'Secondary Order';
    //EDGE-91568
    private final static String  SUSPEND = 'Suspend';
    private final static String REQUESTED_BY_CUSTMOR = 'Requested by Customer';
    private final static String SUSPENDCONTEXT = 'SuspensionContext';
    private final static String CUSTOMER = 'CUSTOMER';
    private final static String SIMPLEX = 'Simplex';
    //EDGE-91569
    private final static String  RESUME = 'Resume';
    private final static String  ACTIVE = 'Active';
    private final static String  CONNECTED = 'Connected';
    private final static String  PROVISIONING_IN_PROGRESS = 'Provisioning In Progress';
    private final static String Devicename = 'Device';//Added for EDGE-148420
    /*CONSTANTS - end --*/
    /************** creating orders on submit order button************************/
    public static List<csord__Order__c>  generateOrderForScenarioType(List<String> subscriptionIdList, ID accountId,String scenerioType,String tNowCaseRef){    
        Map<String,Map<String,String>> guidAddAttrMap = new Map<String,Map<String,String>>();
        Map<String,String> addAttrMap = new Map<String,String>();
        Map<String,Map<String,String>> AttrMap = new Map<String,Map<String,String>>();
        Map<Id,Decimal> subscriptionVsETC = new Map<Id,Decimal>();
        List<Id> portOutOrders = new List<Id>();
        List<Number__c> numList=new List<Number__c>();//EDGE-128090 - added new list to store numbers
        
        Map<String,String> subToDisconnectDate = new Map<String,String>();//EDGE-180200
        List < csord__Subscription__c> subList = [
            SELECT id,
            Site__c,
            Site__r.Name,
            Site__r.Address__c,
            csordtelcoa__Subscription_Number__c,
            CreatedDate,
            csord__Status__c,
            csord__Total_Recurring_Charges__c,
            csord__Total_One_Off_Charges__c,
            CreatedById,
            CreatedBy.Name,
            csord__Account__c,
            Name, serviceMSISDN__c,
            Billing_Account__r.Billing_Account_Number__c,csordtelcoa__Product_Configuration__c,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,Trigger_RTS__c,orderversion__c  
            FROM csord__Subscription__c
            WHERE ID IN: subscriptionIdList
        ];//EDGE-128090 - added field csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c in query
        Map<ID,String> servMSIDNMap = new Map<Id,String>();
        string result='';
        Map<String,csord__Subscription__c> SubIdMap= new Map<String,csord__Subscription__c>();
        //if(scenerioType == CHANGE_OF_MOBILE_NUMBER){
        for(csord__Subscription__c sub:subList){
        if(scenerioType == CHANGE_OF_MOBILE_NUMBER){
            Number__c num=new Number__c(); //EDGE-128090 - Start
            num.Service_Number__c=sub.serviceMSISDN__c;
            num.Status__c='RESERVED';
            num.Account__c=sub.csord__Account__c;
            num.Subscription_number__c=sub.csordtelcoa__Subscription_Number__c;
            num.Mobile__c='Mobile';
            num.Product_ID__c=sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
            num.Type__c='New';
            //num.ListingCode__c='LE';
            num.Product_Configuration__c=sub.csordtelcoa__Product_Configuration__c;
            numList.add(num); //EDGE-128090 - End
        }
            SubIdMap.put(sub.id,sub);
            servMSIDNMap.put(sub.id,sub.serviceMSISDN__c);
        }//}

        //EDGE-180200
        for(DisconnectionRequest__c dr :[Select id,Requested_DateTime__c,Subscription__c,Subscription_ID__c,Subscription__r.id from DisconnectionRequest__c where Subscription__r.id IN:subscriptionIdList]){
            subToDisconnectDate.put(dr.Subscription__r.id,dr.Requested_DateTime__c);
            system.debug('dr106'+dr);
            system.debug('subToDisconnectDate107'+subToDisconnectDate);
        }
        //EDGE-180200

        List<csord__Order__c> OrderList=new List<csord__Order__c>();
        if(!SubIdMap.keyset().IsEmpty())
        {
            Boolean isROETCBillSubType = false;
            //selected subscription
            List<csord__Subscription__c> subscriptionList=[select id,
                                                           name,
                                                           csord__Status__c,
                                                           csord__Order__c,
                                                           Trigger_RTS__c,
                                                           csord__Order__r.csord__Order_Number__c, 
                                                           serviceMSISDN__c, oldServiceMSISDN__c
                                                           from 
                                                           csord__Subscription__c 
                                                           where 
                                                           id IN:SubIdMap.keyset()];
            List<csord__Service__c> serviceList=[select id,
                                                 name,
                                                 csord__Status__c,
                                                 csord__Order__c,
                                                 Delivery_Address__c,
                                                 Site_Delivery_Contact__c,
                                                 Sim_Serial_Number__c,
                                                 Initial_Activation_Date__c,
                                                 Scenario_Type__c, 
                                                 csord__Subscription__r.Id,
                                                 csord__Service__c, serviceMSISDN__c,
                                                 csordtelcoa__Service_Number__c,
                                                 csordtelcoa__Product_Configuration__c,
                                                 csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name,
                                                 csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                                                 csordtelcoa__Product_Configuration__r.Type__c
                                                 from 
                                                 csord__Service__c 
                                                 where 
                                                 csord__Subscription__c IN:SubIdMap.keyset()];
            
            System.debug('serviceList...'+serviceList);
            
            List<cscfga__Product_Configuration__c> pcList = new List< cscfga__Product_Configuration__c>(); // Added as part of EDGE-165552 
            
            Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>();
            Map<String, Number__c> ServNumToNumberMap = new Map<String, Number__c>();
            String ordName = '';
            if(scenerioType != null){
                ordName = scenerioType+'_' + ('0' + String.valueOf(Date.today().day())).right(2) + ( '0' + String.valueOf(Date.today().month())).right(2) + Date.today().year() + '_' + String.valueOf(System.now().time()).left(8);
            }
            //Order request data
            csord__Order_Request__c orderReq=new csord__Order_Request__c();
            orderReq.csord__Process_Status__c=REQUESTED;
            orderReq.csord__Request_DateTime__c=Datetime.now();
            orderReq.csord__Module_Name__c= MODULE_NAME;
            orderReq.csord__Module_Version__c= MODULE_VER;            
            insert orderReq;
            //order data
            csord__Order__c newOrder =new csord__Order__c();
            newOrder.csord__Account__c=accountId;
            newOrder.recordTypeId =Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get(ORD_SUBMITTED).getRecordTypeId();
            newOrder.csord__Status2__c= ORD_SUBMITTED;
            newOrder.csord__Order_Type__c= ORDER;
            newOrder.csord__Identification__c= ORDER_456;
            newOrder.csord__Start_Date__c=Date.today();
            newOrder.telstra_ord_Start_DateTime__c=System.now();//EDGE-182667
            newOrder.Fulfilment_Order_Version__c = 1;
            // DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services - Added if product is related to IOT then do not populate Product type on order

            if(!(serviceList!= null && !serviceList.isEmpty() && serviceList[0].csordtelcoa__Product_Configuration__c != null && serviceList[0].csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c != null && serviceList[0].csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name.contains('IOT')))

            newOrder.csord__Product_Type__c=System.Label.Mobility;
            //newOrder.csord__Product_Type__c=System.Label.Mobility;
            newOrder.Name=ordName;
            newOrder.csord__Order_Request__c=orderReq.id; 
            newOrder.OwnerId=UserInfo.getUserId();
            //added Project_Complexity__c and PM_Required__c for EDGE-91568
            newOrder.Project_Complexity__c=SIMPLEX;
            newOrder.PM_Required__c=false;
            if(tNowCaseRef != '' && tNowCaseRef != null && tNowCaseRef != 'undefined'){
                newOrder.referencenumber__c = tNowCaseRef.toUpperCase();//EDGE-132715
            }
            insert newOrder;   
           // System.debug('newOrder::'+newOrder);
           
            List<Id>serId = new List<Id>();
                           
            if(newOrder.id!=null)
            {
                for(csord__Subscription__c subs:subscriptionList){
                    subs.csord__Order_Request__c=newOrder.csord__Order_Request__c;
                    subs.csord__Order__c=newOrder.id;
                    subs.orderversion__c = newOrder.Fulfilment_Order_Version__c; //added as part of EDGE-223085
                    if(scenerioType == CHANGE_OF_MOBILE_NUMBER ){
                        subs.csord__Status__c= PENDING;
                        subs.changeType__c = CHANGE_OF_MOBILE_NUMBER; // Added as part of EDGE-185450
                    }else if(scenerioType == System.Label.PortOut){
                        subs.csord__Status__c= PENDING;  
                        subs.changeType__c = System.Label.PortOut; // Added as part of EDGE-185450
                        //subs.Trigger_RTS__c =  true;  --//Commented by Manish as part of EDGE-159332
                    }
                    /*else if(scenerioType == SUSPEND){
                        subs.csord__Status__c= PENDING;
                        subs.Suspension_reason__c = REQUESTED_BY_CUSTMOR;
                    }else {
                        subs.csord__Status__c= PENDING;
                        subs.Suspension_reason__c =null;//EDGE-98385 - suspension reason value set to null
                    }*/
                    //subs.serviceMSISDN__c =resource;
                    //update subs;
                }
                //update services
                List<CS_SpecificationDTO.ServiceSpecification> srvspecList = new List<CS_SpecificationDTO.ServiceSpecification> ();
                List<CS_SpecificationDTO.ServiceSpecification> srvspecListBilling = new List<CS_SpecificationDTO.ServiceSpecification> ();
                List<CS_SpecificationDTO.ServiceSpecification> srvspecListAll = new List<CS_SpecificationDTO.ServiceSpecification> ();
                string srvAttStr='';
                string servAttToUptStr = '';
                Map<Id,Attachment> updatedAttMap = new Map <Id,Attachment>();
               // List<Id>serId = new List<Id>();
                Map<String,String> serviceAttachmentBody = new Map<String,String>();
                Map<String,Attachment> serviceIdAttachment = new Map<String,Attachment>();
                Set<String> servNumSet = new Set<String>();
                for(csord__Service__c serv :serviceList){
                serId.add(serv.id);
                servNumSet.add(serv.csordtelcoa__Service_Number__c);
                }
                for(Attachment att:[SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: serId and name = 'ServiceSpecifications.json']){
                    serviceAttachmentBody.put(att.ParentId, att.body.toString());
                    serviceIdAttachment.put(att.parentId,att);


                }

                /*EDGE-174221 - Fetch SIMAvalibility type from number to set Shipping Required True or false*/
                for (Number__c num : [SELECT Id,Status__c,toBeCancelled__c, Service_Id__c, Mobile__c, Service_Number__c, IMSI__c, Sim_Serial_Number__c,SIM_Type__c,SimAvailabilityType__c FROM Number__c WHERE Service_Id__c IN :servNumSet AND Mobile__c = 'Mobile']) {
                    //Create Service Number to Number Map
                    ServNumToNumberMap.put(num.Service_Id__c, num);
                }

                /* EDGE-165552 - ROETC logic for Port Out Order - Start*/
                List<CS_SpecificationDTO.ServiceSpecification> srvspecListBilling_ROETC = new List<CS_SpecificationDTO.ServiceSpecification> ();
                Set<String> listOfProdSpecs = new Set<String>();
                if(scenerioType == System.Label.PortOut){
                    for(csord__Service__c serv:serviceList){
                        srvspecListBilling_ROETC = ServiceSpecificationUtils.getAllServSpecsByServId(serv.id, 'BILLING');
                        for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecListBilling_ROETC){
                            listOfProdSpecs.add(srvSpec.code.SubStringBefore('_Billing'));
                        }
                    }

                    if(listOfProdSpecs.size()>0 && listOfProdSpecs!=null){
                        System.debug('listOfProdSpecs..'+listOfProdSpecs);
                        List<cspmb__Price_Item__c> listOfCommProduct = [SELECT Id FROM cspmb__Price_Item__c WHERE ProdSpecId__c = :listOfProdSpecs AND billingSubtype__c ='ROETC'];
                        System.debug('listOfCommProduct..'+listOfCommProduct);
                        if(listOfCommProduct.size()>0 && listOfCommProduct!=null){
                            isROETCBillSubType = true;
                        }
                    }
                }
                /* EDGE-165552 - ROETC logic for Port Out Order - End*/
                List<Number__c> numtoUpdateList = new List<Number__c>();
                for(csord__Service__c serv:serviceList){
                    srvspecListAll = new List<CS_SpecificationDTO.ServiceSpecification> ();
                    String updatedAttachment = serviceAttachmentBody.get(serv.id);
                    cscfga__Product_Configuration__c updatePC = new cscfga__Product_Configuration__c(); // Added as part of EDGE-165552 
                    //EDGE-91568
                    //get all the service spec attachments for services
                    //EDGE-152563
                    srvspecList=ServiceSpecificationUtils.getAllServSpecsByServId(serv.id, 'FULFILMENT');
                    srvspecListBilling = ServiceSpecificationUtils.getAllServSpecsByServId(serv.id, 'BILLING');
                    if(!srvspecList.isEmpty())
                    srvspecListAll.addAll(srvspecList);
                    if(!srvspecListBilling.isEmpty())
                    srvspecListAll.addAll(srvspecListBilling);
                    srvAttStr=JSON.serialize(srvspecList);
                    system.debug('srvAttStr==> '+srvAttStr);
                    serv.csord__Order__c=newOrder.id;
                    if(serv.csord__Service__c==NULL){
                        if(scenerioType == CHANGE_OF_MOBILE_NUMBER || scenerioType == System.Label.PortOut){
                            if(ServNumToNumberMap.get(serv.csordtelcoa__Service_Number__c) != null ){
                                Number__c numtoUpdate = ServNumToNumberMap.get(serv.csordtelcoa__Service_Number__c);
                                if(numtoUpdate.Status__c != 'Disconnect Pending')
                                numtoUpdate.Status__c = 'Disconnect Pending';
                                if(numtoUpdate.toBeCancelled__c != true)
                                numtoUpdate.toBeCancelled__c = true;
                            
                                numtoUpdateList.add(numtoUpdate);
                            }
                            serv.csord__Status__c= PENDING;
                            //Populating  Scenario_Type__c only on parent mobility service
                            if(scenerioType == CHANGE_OF_MOBILE_NUMBER){
                                serv.Scenario_Type__c = CHANGE_OF_MOBILE_NUMBER; //service secenrio type
                                serv.changeType__c = CHANGE_OF_MOBILE_NUMBER; // Added as part of EDGE-185450
                            }else if(scenerioType == System.Label.PortOut){
                                serv.Scenario_Type__c = System.Label.PortOut; //Port out secenrio type

                                serv.changeType__c = System.Label.PortOut; // Added as part of EDGE-185450

                                //serv.csordtelcoa__Product_Configuration__r.Type__c = 'cancel'; Commented as part of EDGE-165552 
                                /* EDGE-165552 - Update PC Type to Cancel - Start*/
                                if(serv.csordtelcoa__Product_Configuration__c !=null){
                                    updatePC.Id = serv.csordtelcoa__Product_Configuration__c;
                                    updatePC.Type__c = 'Cancel';
                                    pcList.add(updatePC);
                                }
                                /* EDGE-165552 - Update PC Type to Cancel - End*/
                            }
                        }/*else if(scenerioType == SUSPEND){
                            serv.csord__Status__c= PENDING; // For Suspend
                            //serv.Scenario_Type__c = SUSPEND;
                        }else {
                            serv.csord__Status__c= PENDING; // For Resume
                            //serv.Scenario_Type__c = RESUME;
                        }*/
                    }
                    //EDGE-180200
                    system.debug('subToDisconnectDate.get(serv.csord__Subscription__r.Id)'+subToDisconnectDate.get(serv.csord__Subscription__r.Id));
                    system.debug('serv.csord__Subscription__r.Id'+serv.csord__Subscription__r.Id);
                    system.debug('subToDisconnectDate306'+subToDisconnectDate);
                    if(scenerioType == System.Label.PortOut && subToDisconnectDate.get(serv.csord__Subscription__r.Id)!=null){
                        serv.Cust_Req_Disconn_Date__c = Date.valueOf(subToDisconnectDate.get(serv.csord__Subscription__r.Id));
                    }else{
                        serv.Cust_Req_Disconn_Date__c = Date.Today();
                    }
                    //EDGE-180200
                    //serv.serviceMSISDN__c = resource;
                    serv.csord__Order_Request__c=orderReq.id;
                    serv.Telstra_Committed_Date__c = null; // Added as part of EDGE-154370
                    serv.Forecasted_Delivery_Date__c = null; // Added as part of EDGE-154370
                    // update serv;
                    serviceMap.put(serv.id,serv);
                    
                    List<CS_SpecificationDTO.ServiceSpecification> servSpecMA=new List<CS_SpecificationDTO.ServiceSpecification>();
                    List<CS_SpecificationDTO.ServiceSpecification> servSpecMd=new List<CS_SpecificationDTO.ServiceSpecification>();
                    for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecList){
                        guidAddAttrMap = new Map<String,Map<String,String>>(); //EDGE-128126 - reinitialized
                        addAttrMap = new Map<String,String>();  //EDGE-128126 - reinitialized
                        AttrMap = new Map<String,Map<String,String>>();  //EDGE-128126 - reinitialized
                        if(srvSpec.code.contains('DMCAT_ProductSpecification_000420'))
                        {
                            guidAddAttrMap = new Map<String,Map<String,String>>(); //EDGE-128126 - reinitialized
                            addAttrMap = new Map<String,String>();  //EDGE-128126 - reinitialized
                            AttrMap = new Map<String,Map<String,String>>(); 
                            // Bhargava 10/11/2020 EDGE-179268  :Change of mobil number
                            //updatedAttachment = csedm.API_1.updateServiceSpecificationProperty(updatedAttachment,srvSpec.guid,'status','Modified');
                        }else if(srvSpec.code.contains('DMCAT_ProductSpecification_000263'))
                        {
                           /* if(scenerioType==SUSPEND){
                                csedm.API_1.updateServiceSpecificationPropertyById(srvSpec.serviceId,srvSpec.guid,'status','Suspend');
                            }
                            else if(scenerioType==RESUME){
                                csedm.API_1.updateServiceSpecificationPropertyById(srvSpec.serviceId,srvSpec.guid,'status','Resume');
                            }*/
                            /*Bhargava 10/11/2020 EDGE-179268  :Change of mobil number for partner
                             if(scenerioType==CHANGE_OF_MOBILE_NUMBER){
                                updatedAttachment = csedm.API_1.updateServiceSpecificationProperty(updatedAttachment,srvSpec.guid,'status','Modified');



                            }*/
                            /*if(scenerioType==SUSPEND || scenerioType==RESUME || scenerioType==CHANGE_OF_MOBILE_NUMBER)// EDGE-165552 - Removed Port Out Order Condition

                            {
                                for(CS_SpecificationDTO.SimpleAttributes simplAttr :srvSpec.simpleAttributes){
                                    if(simplAttr.name.contains('ShippingRequired')){
                                        simplAttr.value = 'FALSE'; // for Suspend/Resume/change of number shipping not reqd.
                                    addAttrMap.put(simplAttr.name,simplAttr.value);  
                                }//EDGE-116482
                                }
                            }*/


                        }/*else if(srvSpec.code.contains('DMCAT_ProductSpecification_000423'))
                        {
                            if(scenerioType==SUSPEND || scenerioType==RESUME || scenerioType==CHANGE_OF_MOBILE_NUMBER) // EDGE-165552 - Removed Port Out Order Condition
                            {
                                for(CS_SpecificationDTO.SimpleAttributes simplAttr :srvSpec.simpleAttributes){
                                    if(simplAttr.name.contains('ShippingRequired')){ simplAttr.value = 'FALSE'; // for Suspend/Resume?change of number shipping not reqd.
                                    addAttrMap.put(simplAttr.name,simplAttr.value); 
                                    }                                   //EDGE-116482
                                }
                            }
                        }*/
                        
                        // EDGE-165552 - ShippingRequired will be set to false irrespective of the Product Spec for PortOut Order
                        /*if(scenerioType == System.Label.PortOut){
                            for(CS_SpecificationDTO.SimpleAttributes simplAttr :srvSpec.simpleAttributes){
                                if(simplAttr.name.contains('ShippingRequired')){ 
                                    simplAttr.value = 'FALSE';
                                    addAttrMap.put(simplAttr.name,simplAttr.value); 
                                }
                            }
                        }*/
                        // EDGE-165552 - PortOut Order Change End

                        //EDGE-174221 - Check SIMAvalibility on number for Shipping Required flag
                        String isSIM ='FALSE';
                        if(ServNumToNumberMap.containsKey(serv.csordtelcoa__Service_Number__c)){
                            Number__c num = ServNumToNumberMap.get(serv.csordtelcoa__Service_Number__c); 
                            if(num.SimAvailabilityType__c =='New SIM')
                                isSIM= 'TRUE';

                        }
                        
                        for(CS_SpecificationDTO.SimpleAttributes simplAttr :srvSpec.simpleAttributes){
                                if(simplAttr.name.contains('ShippingRequired')){ 
                                    simplAttr.value = isSIM;
                                    addAttrMap.put(simplAttr.name,simplAttr.value); 
                                }
                        }
                        //EDGE-174221 - Chnages END

                        for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes){
                            addAttrMap.put(attr.name,attr.value);
                        }
                        Map<String,String> newAddAttrMap = new Map<String,String>();
                        newAddAttrMap.put('SuspensionContext','CUSTOMER');
                        if(!addAttrMap.keySet().isEmpty()){
                        guidAddAttrMap.put(srvSpec.guid,addAttrMap);
                        }
                        Map<String,String> existingAttrMap = new Map<String,String>();
                        for(String key : guidAddAttrMap.keyset())
                        {
                            existingAttrMap.putAll(guidAddAttrMap.get(key));
                            existingAttrMap.putAll(newAddAttrMap);
                        }
                        AttrMap.put(srvSpec.guid,existingAttrMap);
                        //System.debug('AttrMap::' + AttrMap);


                        for(String guid : AttrMap.keyset()) {
                        //    updatedAttachment = csedm.API_1.addCharacteristic(updatedAttachment,serv.Id, guid, AttrMap.get(guid)); // added as part of EDGE-128126  
                           // System.debug('serv.id'+serv.id);
                           // System.debug('srvSpec.serviceId'+srvSpec.serviceId);
                            //System.debug('guid'+guid);
                        }
                    }
                    
                    //EDGE-152563
                  //EDGE-179370 : Moved code below as the cahnges gets overriden after CS APi call
                  System.debug('(scenerioType :: '+scenerioType);
                     if(scenerioType==System.label.PortOut){
                            for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecList){
                                //Map<String, Object> specificationObject = (Map<String, Object>) srvSpec;
                                string code =  srvSpec.code;
                                if(code.contains('DMCAT_ProductSpecification_000423') || code.contains('DMCAT_ProductSpecification_001211') || code.contains('DMCAT_ProductSpecification_000622')){
                                    updatedAttachment = csedm.API_1.updateServiceSpecificationProperty(updatedAttachment,srvSpec.guid,'status','Complete');
                                }
                                else{
                                updatedAttachment = csedm.API_1.updateServiceSpecificationProperty(updatedAttachment,srvSpec.guid,'status','Disconnect Pending');
                            }                            
                     }
                     }
                    //EDGE-152563
                     if(scenerioType==System.label.PortOut){
                            for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecListBilling){
                                updatedAttachment = csedm.API_1.updateServiceSpecificationProperty(updatedAttachment,srvSpec.guid,'status','Disconnect Pending');
                            }
                    }



                    /*  if(servSpecMA!=null){          //updating serviceSpec for Suspend and Resume Order
for(CS_SpecificationDTO.ServiceSpecification serv1:servSpecMA)
{
csedm.API_1.updateServiceSpecificationPropertyById(serv1.serviceId,serv1.guid,'status','Modified');
}
}
if(servSpecMd!=null){
for(CS_SpecificationDTO.ServiceSpecification serv2:servSpecMd)
{
if(scenerioType==SUSPEND){
csedm.API_1.updateServiceSpecificationPropertyById(serv2.serviceId,serv2.guid,'status','Suspend');
}else if(scenerioType==RESUME){
csedm.API_1.updateServiceSpecificationPropertyById(serv2.serviceId,serv2.guid,'status','Resume');
}
else if(scenerioType==CHANGE_OF_MOBILE_NUMBER){
csedm.API_1.updateServiceSpecificationPropertyById(serv2.serviceId,serv2.guid,'status','Modified');
}
}}*/            Attachment attToBeUpdated = new Attachment();
                attToBeUpdated = serviceIdAttachment.get(serv.Id);
                if(updatedAttachment!=null){
                attToBeUpdated.body = BLOB.valueOf(updatedAttachment);
                updatedAttMap.put(attToBeUpdated.id,attToBeUpdated);
                }
                }

                if(!numtoUpdateList.isEmpty())
                {
                    update numtoUpdateList;
                }
                
                //taking DML statement out of for loop 
                if(!updatedAttMap.isEmpty()) {

                   // update updatedAttMap.values();
                  // Bhargava 10/11/2020 EDGE-179268  :Change of mobil number for partner
                    LRMMSISDNAttachUpdate.MISDANAttachUpdateId(updatedAttMap);

                }


                if(!numList.isEmpty())
                 {
                    insert numList; 
                 } //EDGE-128090 - inserted numbers into number objet
                update subscriptionList;
                System.debug('subscriptionList::'+subscriptionList);
                update serviceList; 
                //System.debug('serviceList::'+serviceList);
                
                // Added as part of EDGE-165552 
                if(pcList.size()>0 && pcList !=null){
                    update pcList;
                }
                                
                //EDGE-91568
                //Adding SuspensionContext in additional attribute of Mobility parent service
                Map<String,String> additionalAttr=new Map<String,String>();
                if(scenerioType.contains(SUSPEND) || scenerioType.contains(RESUME)){  additionalAttr.put(SUSPENDCONTEXT,CUSTOMER);
                    //system.debug('inside if additionalAttr::'+additionalAttr);
                }
                /*system.debug('srvAttStr1==> '+srvAttStr);
                 if(scenerioType == SUSPEND)
                {
                for(CS_SpecificationDTO.ServiceSpecification servSpecDTO : serviceSpecDTOList){
                system.debug('servSpecDTO.serviceId '+servSpecDTO.serviceId); 
                system.debug('servSpecDTO.guid'+servSpecDTO.guid); 
                csedm.API_1.updateServiceSpecificationPropertyById(servSpecDTO.serviceId,servSpecDTO.guid,'status','Modified');
                system.debug('servSpecDTO '+servSpecDTO);                                                                     
                }  
                }*/
            }    
              List<CS_SpecificationDTO.ServiceSpecification> srvspecListFulfillment = new List<CS_SpecificationDTO.ServiceSpecification> ();
                List<CS_SpecificationDTO.ServiceSpecification> srvspecListBilling2 = new List<CS_SpecificationDTO.ServiceSpecification> ();
                List<CS_SpecificationDTO.ServiceSpecification> srvspecListAll2 = new List<CS_SpecificationDTO.ServiceSpecification> ();
                Map<String,String> serviceAttachmentBody2 = new Map<String,String>();
                Map<String,Attachment> serviceIdAttachment2 = new Map<String,Attachment>();
                Map<Id,Attachment> updatedAttMap2 = new Map <Id,Attachment>();
            //EDGE-66137: ETC calculation when port-oorderut request received from TM4
            if(scenerioType == System.Label.PortOut && isROETCBillSubType){ // EDGE-165552 - Added isROETCBillSubType condition
                subscriptionVsETC = calculateETCForServices(SubIdMap,serviceList);
                //csedm.API_1.generateOrderSpecification(new List<Id>(subscriptionVsETC.keySet()), new List<Id>{newOrder.id}, true); // Commented this as part of EDGE-167554
                csedm.API_1.generateSpecifications(new List<Id>(subscriptionVsETC.keySet()), new List<Id>{newOrder.id}, true); // Added this as part of //EDGE-167554
                
                for(Attachment att:[SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: serId and name = 'ServiceSpecifications.json']){
                serviceAttachmentBody2.put(att.ParentId, att.body.toString());
                serviceIdAttachment2.put(att.parentId,att);
                }
                
                            List<csord__Service__c> serviceListUpdated=[select id,
                                                 name,
                                                 csord__Status__c,
                                                 csord__Order__c,
                                                 Delivery_Address__c,
                                                 Site_Delivery_Contact__c,
                                                 Sim_Serial_Number__c,
                                                 Initial_Activation_Date__c,
                                                 Scenario_Type__c,
                                                 Action_type__c,
                                                 csord__Subscription__r.Id,
                                                 csord__Service__c, serviceMSISDN__c,
                                                 csordtelcoa__Service_Number__c,
                                                 csordtelcoa__Product_Configuration__c,
                                                 csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name,
                                                 csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                                                 csordtelcoa__Product_Configuration__r.Type__c
                                                 from 
                                                 csord__Service__c 
                                                 where 
                                                 id IN: serId ];
                
                for(csord__Service__c serv:serviceListUpdated){
                    String updatedAttachment2 = serviceAttachmentBody2.get(serv.id);
                    srvspecListFulfillment =ServiceSpecificationUtils.getAllServSpecsByServId(serv.id, 'FULFILMENT');
                    srvspecListBilling2 = ServiceSpecificationUtils.getAllServSpecsByServId(serv.id, 'BILLING');
                    
                                        //EDGE-152563
                  
                            for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecListFulfillment){
                                //Map<String, Object> specificationObject = (Map<String, Object>) srvSpec;
                                string code =  srvSpec.code;
                                if(code.contains('DMCAT_ProductSpecification_000423') || code.contains('DMCAT_ProductSpecification_001211') || code.contains('DMCAT_ProductSpecification_000622')){
                                    updatedAttachment2 = csedm.API_1.updateServiceSpecificationProperty(updatedAttachment2,srvSpec.guid,'status','Complete');
                                }
                                else{
                                updatedAttachment2 = csedm.API_1.updateServiceSpecificationProperty(updatedAttachment2,srvSpec.guid,'status','Disconnect Pending');
                                }
                            }   
                    //EDGE-152563
                            for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecListBilling2){
                                if(serv.action_type__c.equalsIgnoreCase('PaidOut')){
                                    updatedAttachment2 = csedm.API_1.updateServiceSpecificationProperty(updatedAttachment2,srvSpec.guid,'status','Paid Out');
                                }
                                else{
                                string code =  srvSpec.code;
                                if(code.contains('Billing_NonRecurringCharge') && serv.csord__Service__c != null){
                                
                                }
                                else{
                                    updatedAttachment2 = csedm.API_1.updateServiceSpecificationProperty(updatedAttachment2,srvSpec.guid,'status','Disconnect Pending');
                                }
                            }
                            }
                Attachment attToBeUpdated2 = new Attachment();
                attToBeUpdated2 = serviceIdAttachment2.get(serv.Id);
                if(updatedAttachment2!=null){
                attToBeUpdated2.body = BLOB.valueOf(updatedAttachment2);
                updatedAttMap2.put(attToBeUpdated2.id,attToBeUpdated2);
                }
                

                }
                
                 if(!updatedAttMap2.isEmpty()) {
                    update updatedAttMap2.values();
                }
                
            }//EDGE-66137:END
            newOrder=[Select id,csord__Order_Number__c from csord__Order__c where id =: newOrder.id];
            //result=newOrder.csord__Order_Number__c;
            if(newOrder!=null && newOrder.csord__Order_Number__c!=null){
                SubmitOrderOrchestration.createOrderOrchestrationProcess(newOrder.id); // orchestration initiation
                //System.debug('Orchestration done::');
            }                
            //FIX
            OrderList.add(newOrder);
        }
        return OrderList;
    }
    public static List<csord__Order__c>  generateOrderForSuspendResume(List<String> subscriptionIdList, ID accountId,String scenerioType,String tNowCaseRef, Map<String, String> subsToReasonMap) //DPG-4543 || DPG-4544, Ila || Krunal, Removed reason parameter
    {    

        Map<Id,Decimal> subscriptionVsETC = new Map<Id,Decimal>();
        List<Id> portOutOrders = new List<Id>();
        List<CS_SpecificationDTO.ServiceSpecification> srvspecList = new List<CS_SpecificationDTO.ServiceSpecification> ();
        Map<String,Map<String,String>> guidAddAttrMap = new Map<String,Map<String,String>>();
        Map<String,String> addAttrMap = new Map<String,String>();
        Map<String,String> newAddAttrMap = new Map<String,String>();
        Map<String,Map<String,String>> AttrMap = new Map<String,Map<String,String>>();
        List<CS_SpecificationDTO.ServiceSpecification> servSpecMA=new List<CS_SpecificationDTO.ServiceSpecification>();
        List<CS_SpecificationDTO.ServiceSpecification> servSpecMd=new List<CS_SpecificationDTO.ServiceSpecification>();
        List < csord__Subscription__c> subList = [
            SELECT id,
            Site__c,
            Site__r.Name,
            Site__r.Address__c,
            csordtelcoa__Subscription_Number__c,
            CreatedDate,
            csord__Status__c,
            csord__Total_Recurring_Charges__c,
            csord__Total_One_Off_Charges__c,
            CreatedById,
            CreatedBy.Name,
            csord__Account__c,
            Name, serviceMSISDN__c,
            Billing_Account__r.Billing_Account_Number__c,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name,orderversion__c
            FROM csord__Subscription__c
            WHERE ID IN: subscriptionIdList
        ];
        
       
        Map<ID,String> servMSIDNMap = new Map<Id,String>();
        string result='';
        Map<String,csord__Subscription__c> SubIdMap= new Map<String,csord__Subscription__c>();
        for(csord__Subscription__c sub:subList){
            SubIdMap.put(sub.id,sub);
            servMSIDNMap.put(sub.id,sub.serviceMSISDN__c);
        }
        List<csord__Order__c> OrderList=new List<csord__Order__c>();


        if(!SubIdMap.keyset().IsEmpty())
        {
            //selected subscription
            List<csord__Subscription__c> subscriptionList=[select id,
                                                           name,
                                                           csord__Status__c,
                                                           csord__Order__c,
                                                           csord__Order__r.csord__Order_Number__c, 
                                                           serviceMSISDN__c, oldServiceMSISDN__c,Suspension_reason__c,Suspension_reason_summary__c,orderversion__c
                                                           from 
                                                           csord__Subscription__c 
                                                           where 
                                                           id IN:SubIdMap.keyset()];
            List<csord__Service__c> serviceList=[select id,
                                                 name,
                                                 csord__Status__c,
                                                 csord__Order__c,
                                                 Delivery_Address__c,
                                                 Site_Delivery_Contact__c,
                                                 Sim_Serial_Number__c,
                                                 Initial_Activation_Date__c,
                                                 Scenario_Type__c, 
                                                 csord__Subscription__r.Id,
                                                 csord__Service__c, serviceMSISDN__c,
                                                 csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name,
                                                 csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                         csord__Subscription__r.MarketableOffer__r.Offer_ID__c
                                                 from 
                                                 csord__Service__c 
                                                 where 
                                                 csord__Subscription__c IN:SubIdMap.keyset()];


            Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>();
            String ordName = '';
            if(scenerioType != null){
                ordName = scenerioType+'_' + ('0' + String.valueOf(Date.today().day())).right(2) + ( '0' + String.valueOf(Date.today().month())).right(2) + Date.today().year() + '_' + String.valueOf(System.now().time()).left(8);
            }
            //Order request data
            csord__Order_Request__c orderReq=new csord__Order_Request__c();
            orderReq.csord__Process_Status__c=REQUESTED;
            orderReq.csord__Request_DateTime__c=Datetime.now();
            orderReq.csord__Module_Name__c= MODULE_NAME;
            orderReq.csord__Module_Version__c= MODULE_VER;            
            insert orderReq;
            //order data
            csord__Order__c newOrder =new csord__Order__c();
            newOrder.csord__Account__c=accountId;
            newOrder.recordTypeId =Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get(ORD_SUBMITTED).getRecordTypeId();
            newOrder.csord__Status2__c= ORD_SUBMITTED;
            newOrder.csord__Order_Type__c= ORDER;
            newOrder.csord__Identification__c= ORDER_456;
            newOrder.csord__Start_Date__c=Date.today();
            newOrder.telstra_ord_Start_DateTime__c=System.now();//EDGE-182667
            newOrder.Fulfilment_Order_Version__c = 1;
            // DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services - Added if product is related to IOT then do not populate Product type on order

            if(!(serviceList!= null && !serviceList.isEmpty() && serviceList[0].csordtelcoa__Product_Configuration__c != null && serviceList[0].csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c != null && serviceList[0].csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name.contains('IOT')))

            newOrder.csord__Product_Type__c=System.Label.Mobility;
            newOrder.Name=ordName;
            newOrder.csord__Order_Request__c=orderReq.id; 
            newOrder.OwnerId=UserInfo.getUserId();
            //added Project_Complexity__c and PM_Required__c for EDGE-91568
            newOrder.Project_Complexity__c=SIMPLEX;
            newOrder.PM_Required__c=false;
            if(tNowCaseRef != '' && tNowCaseRef != null && tNowCaseRef != 'undefined'){
                newOrder.referencenumber__c = tNowCaseRef.toUpperCase();//EDGE-132715
            }            
            insert newOrder;   
            //System.debug('newOrder::'+newOrder);
            if(newOrder.id!=null)
            {
                for(csord__Subscription__c subs:subscriptionList){
                    subs.csord__Order_Request__c=newOrder.csord__Order_Request__c;
                    subs.csord__Order__c=newOrder.id;
                    subs.orderversion__c = newOrder.Fulfilment_Order_Version__c; //added as part of EDGE-223085
                   // subs.changeType__c=$Label.
                    if(scenerioType == SUSPEND){
                        subs.csord__Status__c= PENDING;
                        subs.changeType__c='Suspend';
                        //if(reason!=null)
                            if(!subsToReasonMap.isEmpty() && subsToReasonMap.containsKey(subs.Id)) //DPG-4543 || DPG-4544: Map of Suspension Reason ;Ila/Krunal
                        {
                            subs.Suspension_reason__c = subsToReasonMap.get(subs.Id);
                            //DPG-4543: Populate Reason Summary for AM and CMP || Ila Start
                                if(subs.Suspension_reason_summary__c==null){
                                    subs.Suspension_reason_summary__c= subsToReasonMap.get(subs.Id);
                                }
                                else{
                                subs.Suspension_reason_summary__c+= ',' +subsToReasonMap.get(subs.Id); 
                                }
                            
                        //DPG-4543 End
                        }
                        /*else
                        {
                            subs.Suspension_reason__c=REQUESTED_BY_CUSTMOR;
                        }*/ //DPG-4543: Reason Code will never be null, handled in UI
                    }else if(scenerioType == RESUME){subs.csord__Status__c= PENDING;
                   subs.changeType__c='Resume';     
                        subs.Suspension_reason__c = null;//EDGE-98385 - suspension reason value set to null
                        //Remove Suspend Reason codes from Suspension reason summary Field -- Krunal - Start -  DPG-4544
                        if(!subsToReasonMap.isEmpty() && subs.Suspension_reason_summary__c != null && subs.Suspension_reason_summary__c.contains(subsToReasonMap.get(subs.Id))){
                            List<String> reasonSummaryList = subs.Suspension_reason_summary__c.split(',');
                            String updatedReasonSummary; //Temporary variable to capture summary reason 
                            for(String rs : reasonSummaryList){
                                if(rs != subsToReasonMap.get(subs.Id)){
                                    if(updatedReasonSummary == null){
                                        updatedReasonSummary = rs + ',';
                                    }
                                    else{
                                        updatedReasonSummary += rs + ',';
                                    }
                                }
                            }

                            if(updatedReasonSummary != null){
                                subs.Suspension_reason_summary__c = updatedReasonSummary.removeEnd(',');
                            }
                            else{
                                subs.Suspension_reason_summary__c = ''; 
                            }
                        }

                        //Remove Suspend Reason codes from Suspension reason summary Field -- Krunal - End -  DPG-4544
                    }
                }
                //update services
                //List<CS_SpecificationDTO.ServiceSpecification> srvspecList = new List<CS_SpecificationDTO.ServiceSpecification> ();
                string srvAttStr='';
                string servAttToUptStr = '';
                Map<Id,Attachment> updatedAttMap = new Map <Id,Attachment>();
                for(csord__Service__c serv:serviceList){
                    //EDGE-91568
                    //get all the service spec attachments for services
                    //srvspecList=ServiceSpecificationUtils.getAllServSpecsByServId(serv.id, 'FULFILMENT');
                    //srvAttStr=JSON.serialize(srvspecList);
                    //system.debug('srvAttStr==> '+srvAttStr);
                    serv.csord__Order__c=newOrder.id;
                    if(serv.csord__Service__c==NULL){
                        if(scenerioType == SUSPEND){
                              serv.changeType__c='Suspend';
                            serv.csord__Status__c= PENDING; // For Suspend
                            serv.Scenario_Type__c=null;// added as part of observation - in case of suspend removing value of scenario type as this is not needed
                        }else if(scenerioType == RESUME){serv.csord__Status__c= PENDING; // For Resume
                            serv.changeType__c='Resume';// 
                            serv.Scenario_Type__c=null;// added as part of observation - in case of resume removing value of scenario type as this is not needed
                        }
                    }
          //DPG:5275 Defect fix Start
          if(serv.csord__Service__c!=NULL && serv.csord__Subscription__r.MarketableOffer__r.Offer_ID__c=='DMCAT_Offer_001233'){
              if(scenerioType == SUSPEND){
                              serv.changeType__c='Suspend';
                            serv.csord__Status__c= PENDING; // For Suspend
                            serv.Scenario_Type__c=null;// added as part of observation - in case of suspend removing value of scenario type as this is not needed
                        }else if(scenerioType == RESUME){serv.csord__Status__c= PENDING; // For Resume
                            serv.changeType__c='Resume';
                            serv.Scenario_Type__c=null;// added as part of observation - in case of resume removing value of scenario type as this is not needed
                        }
          }
          //DPG:5275 Defect fix End
                    //serv.serviceMSISDN__c = resource;
                    serv.csord__Order_Request__c=orderReq.id;
                    serv.Telstra_Committed_Date__c = null; // Added as part of EDGE-154370
                    serv.Forecasted_Delivery_Date__c = null; // Added as part of EDGE-154370
                    // update serv;
                    serviceMap.put(serv.id,serv);
                }
                //taking DML statement out of for loop 
                if(!subscriptionList.isEmpty())
                update subscriptionList;
               // System.debug('subscriptionList::'+subscriptionList);
                if(!serviceMap.values().isEmpty())
                update serviceMap.values(); 
                //System.debug('serviceList::'+serviceList);
                Map<Id,Attachment> attMapToStore=new Map<Id,Attachment>();
                //Commented as part of EDGE-179268 moved to Orchestraction step ,Orchestration_SuspendorResumeService
           /*     for(csord__Service__c serv:serviceMap.values()){
                    //EDGE-91568
                    //get all the service spec attachments for services
                    srvspecList=ServiceSpecificationUtils.getAllServSpecsByServId(serv.id, 'FULFILMENT');
                    for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecList){
                        newAddAttrMap = new Map<String,String>(); //EDGE-128126 - reinitialized
                        guidAddAttrMap = new Map<String,Map<String,String>>(); //EDGE-128126 - reinitialized
                        AttrMap = new Map<String,Map<String,String>>(); //EDGE-128126 - reinitialized
                        addAttrMap = new Map<String,String>(); //EDGE-128126 - reinitialized
                        //system.debug('addAttrMap '+addAttrMap);
                        updatedAttMap = new Map<Id,Attachment>(); //EDGE-128126 - reinitialized
                        // DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services - Added IOT specific product specifications
                        if(srvSpec.code.contains('DMCAT_ProductSpecification_000420') || srvSpec.code.contains('DMCAT_ProductSpecification_000965'))
                        {
                          //  csedm.API_1.updateServiceSpecificationPropertyById(srvSpec.serviceId,srvSpec.guid,'status','Modified');
                        }else if(srvSpec.code.contains('DMCAT_ProductSpecification_000263') || srvSpec.code.contains('DMCAT_ProductSpecification_000871') || srvSpec.code.contains('DMCAT_ProductSpecification_000710') || srvSpec.code.contains('DMCAT_ProductSpecification_000966')) //EDGE-96386 - added product spec code for TID product
                        {
                            if(scenerioType==SUSPEND){
                            //    csedm.API_1.updateServiceSpecificationPropertyById(srvSpec.serviceId,srvSpec.guid,'status','Suspend');
                                 for(csord__Subscription__c sub:subscriptionList) // added as part of EDGE-128126 
                                {
                                if(sub.Suspension_reason__c!=null){
                                if(sub.Suspension_reason__c.containsIgnoreCase('Requested by Customer'))
                                {
                                    newAddAttrMap.put('SuspensionContext','CUSTOMER');
                                }else if(sub.Suspension_reason__c.containsIgnoreCase('Requested by Telstra'))
                                {
                                    newAddAttrMap.put('SuspensionContext','CREDIT MANAGEMENT');
                                }else
                                {
                                    newAddAttrMap.put('SuspensionContext','NA'); 
                                }
                            }
                                }
                               // system.debug('newAddAttrMap ' + newAddAttrMap);
                            }
                            else if(scenerioType==RESUME){
                            //    csedm.API_1.updateServiceSpecificationPropertyById(srvSpec.serviceId,srvSpec.guid,'status','Resume');
                            }


                            if(scenerioType==SUSPEND || scenerioType==RESUME )
                            {
                                for(CS_SpecificationDTO.SimpleAttributes simplAttr :srvSpec.simpleAttributes){
                                    if(simplAttr.name.contains('ShippingRequired'))
                                        simplAttr.value = 'FALSE'; // for Suspend/Resume/change of number shipping not reqd.
                                    addAttrMap.put(simplAttr.name,simplAttr.value);//EDGE-116482
                                }
                            }
                        }else if(srvSpec.code.contains('DMCAT_ProductSpecification_000423'))
                        {
                            if(scenerioType==SUSPEND || scenerioType==RESUME )
                            {
                                for(CS_SpecificationDTO.SimpleAttributes simplAttr :srvSpec.simpleAttributes){
                                    if(simplAttr.name.contains('ShippingRequired'))
                                        simplAttr.value = 'FALSE'; // for Suspend/Resume/change of number shipping not reqd.
                                    addAttrMap.put(simplAttr.name,simplAttr.value);//EDGE-116482
                                }
                            }
                        }


                        for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes){
                            addAttrMap.put(attr.name,attr.value);
                        }
                       // System.debug('addAttrMap===>'+addAttrMap);
                       // Commeted
                        Map<String,String> newAddAttrMap = new Map<String,String>();
                        for(csord__Subscription__c sub:subscriptionList)
                        {
                            if(sub.Suspension_reason__c!=null){
                                if(sub.Suspension_reason__c.containsIgnoreCase('Requested by Customer'))
                                {
                                    newAddAttrMap.put('SuspensionContext','CUSTOMER');
                                }else if(sub.Suspension_reason__c.containsIgnoreCase('Requested by Telstra'))
                                {
                                    newAddAttrMap.put('SuspensionContext','CREDIT MANAGEMENT');
                                }else
                                {
                                    newAddAttrMap.put('SuspensionContext','NA'); 
                                }
                            }
                        }
                        //commented 
                      // System.debug('newAddAttrMap.values()===>'+newAddAttrMap);
                        guidAddAttrMap.put(srvSpec.guid,addAttrMap);
                       // System.debug('guidAddAttrMap==>'+guidAddAttrMap);

                        Map<String,String> existingAttrMap = new Map<String,String>();
                        for(String key : guidAddAttrMap.keyset())
                        {
                           // System.debug('guidAddAttrMap.keyset()==>'+guidAddAttrMap.keyset());
                            existingAttrMap.putAll(guidAddAttrMap.get(key));
                            //System.debug('existingAttrMap 1===>'+existingAttrMap);
                            existingAttrMap.putAll(newAddAttrMap);
                        }    
//                        System.debug('existingAttrMap final===>'+existingAttrMap);
                        AttrMap.put(srvSpec.guid,existingAttrMap);


                      //  System.debug('AttrMap::' + AttrMap);
                       // System.debug('AttrMap values::' + AttrMap.values());
                        for(String guid : AttrMap.keyset()) {
                          if(!srvSpec.code.contains('DMCAT_ProductSpecification_000712'))
                          {
                              if(Test.isRunningTest()){                               
                              }
                              else{
                        //    csedm.API_1.addCharacteristic(serv.id, guid, AttrMap.get(guid)); //added as part of EDGE-128126 
                              }


                           //attMapToStore = ServiceSpecificationUtils.getAddCharacteristic(serv.id,guid,AttrMap.get(guid));
                            //System.debug('attMapToStore==>'+attMapToStore);
                          }
                        }
                         // updatedAttMap.putAll(attMapToStore);
                          //  System.debug('updatedAttMap==hdjwh'+updatedAttMap); 
                    }
                }
                */
                 //Commented as part of EDGE-179268 moved to Orchestraction step ,Orchestration_SuspendorResumeService
               /* System.debug('updatedAttMap==>'+updatedAttMap);
                if(!updatedAttMap.isEmpty()) {
                    update updatedAttMap.values();
                }*/
            }
            newOrder=[Select id,csord__Order_Number__c from csord__Order__c where id =: newOrder.id];
            //result=newOrder.csord__Order_Number__c;
            if(newOrder!=null && newOrder.csord__Order_Number__c!=null){
                SubmitOrderOrchestration.createOrderOrchestrationProcess(newOrder.id); // orchestration initiation
                //System.debug('Orchestration done::');
            }                
            //FIX
            OrderList.add(newOrder);
        }
        return OrderList;
    }
    public static void getChangeOfMobileNumberEvent (List<string> resList){resourceList = resList;
    }
    /*  Method to
*  -Calculate ETC for port-out order
*  -update attributes-EarlyCalculationCharges, MobileDeviceETC
*  -update CFS-mapping field of PC   
*  EDGE-66137: ETC calculation when port-out request received from TM4
*/
    @testvisible
    private static Map<Id,Decimal> calculateETCForServices(Map<String,csord__Subscription__c> SubIdMap,List<csord__Service__c> serviceList){
        List<csord__Service__c> serviceListToUpdate = new List<csord__Service__c>();
        String billingAccountNumber;
        Date initialActivationDate;
        Integer contractTerm=0;
        Decimal unitPrice=0;
        String ETCCharges='0';
        Map<Id,Decimal> subscriptionVsETC = new Map<Id,Decimal>();
        DisconnectionRequest__c disconnectRequest;
        List<cscfga__Product_Configuration__c> pcToUpdate = new List<cscfga__Product_Configuration__c>();
        List<Id> idsOfPCs = new List<Id>();
        List<cscfga__Attribute__c> attrToUpdate = new List<cscfga__Attribute__c>();
        // EDGE-144389 - Strategic Fix for Port out order - Add my Maq
        map < String, TelstraCollab_RateCard_Reference__mdt > TelstraCollabMapping = new map < String, TelstraCollab_RateCard_Reference__mdt> ();
        // Fetch custom metadata value ----
        for (TelstraCollab_RateCard_Reference__mdt TCCustomData: [SELECT DeveloperName, Label, Billing_Subtype__c FROM TelstraCollab_RateCard_Reference__mdt WHERE isActive__c = true AND label = 'ROETC']) {
            TelstraCollabMapping.put(TCCustomData.Label, TCCustomData);
        }
        system.debug('TelstraCollabMapping#######>>>>>************* TelstraCollabMapping: ' + JSON.serialize(TelstraCollabMapping));
        List<String> devicePCList= new List<String>();
        for(csord__Service__c serv:serviceList){
            idsOfPCs.add(serv.csordtelcoa__Product_Configuration__c);
            if(serv.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name==Devicename){
                devicePCList.add(serv.csordtelcoa__Product_Configuration__c);
            }
        }
        // EDGE-144389 - Strategic Fix for Port out order - Updated my Maq
        String query = 'SELECT cscfga__Product_Definition__r.product_Specification__c,' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cscfga__Product_Configuration__c')) + ' ,(SELECT Id, Name, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Name FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Name In (\'ContractTerm\',\'InstalmentCharge\',\'OfferId\',\'MobileDeviceETC\',\'EarlyTerminationCharge\',\'DisconnectionDate\')) ' +
            ' FROM cscfga__Product_Configuration__c WHERE id IN :idsOfPCs';
        //query= String.escapeSingleQuotes(query);
        Map<id,cscfga__Product_Configuration__c> devicePCs = new Map<id,cscfga__Product_Configuration__c>((List<cscfga__Product_Configuration__c>)Database.query(query));
        query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Price_Item__c')) + ' ' +
            ' FROM cspmb__Price_Item__c WHERE billingSubtype__c IN (\'' + String.escapeSingleQuotes(TelstraCollabMapping.get('ROETC').Billing_Subtype__c) + '\')'; // EDGE-144389 - Strategic Fix for Port out order - Updated my Maq
        Map<String,List<cspmb__Price_Item__c>> prodSpecVSpriceItemsRecords = new Map<String,List<cspmb__Price_Item__c>>();       
        for(cspmb__Price_Item__c pi:Database.query(query)){
            if(prodSpecVSpriceItemsRecords.get(pi.Offer_Id__c) == null)
                prodSpecVSpriceItemsRecords.put(pi.Offer_Id__c,new List<cspmb__Price_Item__c>());
            (prodSpecVSpriceItemsRecords.get(pi.Offer_Id__c)).add(pi);
        }
        List<String> ids = new List<String>(SubIdMap.keySet());
        query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('DisconnectionRequest__c')) + ' ' +
            ' FROM DisconnectionRequest__c WHERE Subscription__c IN :ids order by createddate desc limit 1';
        Map<id,DisconnectionRequest__c> subVSdisconnectRequests = new Map<id,DisconnectionRequest__c>();
        for(DisconnectionRequest__c dr:Database.query(query)){
            subVSdisconnectRequests.put(dr.Subscription__c,dr);
        }
        system.debug('valueofidsOfPCs'+idsOfPCs);
        //Changes Start for EDGE-148420 
        if(devicePCList.size()>0){
                Map<String, Object> allConfigData = cscfga.API_1.getProductConfigurations(devicePCList);
                for(String prodConfgIdloop:devicePCList){
                    String billDescText = 'Device Payout -';
                    String modelString = '';
                    String colourString = '';
                    List<cscfga__attribute__c> attList1 = (List<cscfga__attribute__c>) allConfigData.get(prodConfgIdloop + '-attributes');
                        system.debug('AttributeListvalue'+attList1 );
                        for (cscfga__attribute__c attloop:attList1 ){
                           if(attloop.name=='ColourString'){ colourString = attloop.cscfga__Value__c;
                                system.debug('VALUE'+attloop.cscfga__Value__c);
                            }
                            if(attloop.name=='ModelString'){
                                modelString = attloop.cscfga__Value__c;
                                system.debug('VALUE'+attloop.cscfga__Value__c);
                            }
                        }
                        billDescText = billDescText +' '+ modelString +' '+ colourString;
                        system.debug('billDescText '+billDescText );
                        for (cscfga__attribute__c attloopNew:attList1 ){
                            if(attloopNew.name=='BillDescText'){
                                attloopNew.cscfga__Value__c=billDescText;
                                system.debug('VALUE'+attloopNew.cscfga__Value__c);
                            }
                            if(attloopNew.name=='ChangeType'){
                                attloopNew.cscfga__Value__c='Cancel';
                            }
                        }
                }
                if(allConfigData.size()>0)
                cscfga.API_1.updateProductConfigurations(allConfigData);
        }
        //Changes End for EDGE-148420  
        for(csord__Subscription__c subscription:SubIdMap.values()){
            billingAccountNumber = subscription.Billing_Account__r.Billing_Account_Number__c;
            disconnectRequest = subVSdisconnectRequests.get(subscription.id);
            System.debug('***Telstra:disconnectRequest:'+disconnectRequest);
            for(csord__Service__c service: serviceList){
            cscfga__Product_Configuration__c pc = devicePCs.get(service.csordtelcoa__Product_Configuration__c);
             if(pc!=null && pc.Type__c!= null){
                  cscfga__Attribute__c ETCAttr,MobileDeviceETC,DisconnectionDate,ChangeTypeDevice;
                  cspmb__Price_Item__c priceRecord;
                 pc.Type__c = 'Cancel';
                if(service.csord__Service__c!=null){  //Gets service related to Device
                    System.debug('Service:'+service);
                    initialActivationDate = service.Initial_Activation_Date__c;
                    //cscfga__Product_Configuration__c pc = devicePCs.get(service.csordtelcoa__Product_Configuration__c);
                    contractTerm = Integer.valueOf(pc.cscfga__Contract_Term__c);
                    for(cscfga__Attribute__c attr:pc.cscfga__Attributes__r){                    
                        if(attr.name.equalsIgnoreCase('InstalmentCharge'))
                            unitPrice = Decimal.valueOf(attr.cscfga__Value__c);
                        if(attr.name.equalsIgnoreCase('EarlyTerminationCharge'))
                            ETCAttr = attr;
                        if(attr.name.equalsIgnoreCase('MobileDeviceETC'))
                            MobileDeviceETC = attr;
                        if(attr.name.equalsIgnorecase('DisconnectionDate'))
                            DisconnectionDate = attr;
                        if(attr.name.equalsIgnoreCase('OfferId')){
                            if(prodSpecVSpriceItemsRecords.containsKey(attr.cscfga__Value__c) && prodSpecVSpriceItemsRecords.get(attr.cscfga__Value__c) != null){
                            for(cspmb__Price_Item__c precord:prodSpecVSpriceItemsRecords.get(attr.cscfga__Value__c)){
                                if(precord.ProdSpecId__c == pc.cscfga__Product_Definition__r.product_Specification__c)
                                    priceRecord = precord ; 
                            }
                        } 
                        }
                    }}
                    
                    if(initialActivationDate!= null && billingAccountNumber!=null){
                        System.debug('date and BAN:'+initialActivationDate+':'+billingAccountNumber);
                        ETCCharges = EarlyCancellationCalcService.CancelChargesCalcWithBillDay(0,initialActivationDate,Date.valueOf((disconnectRequest.Requested_DateTime__c).substringbefore('T')), contractTerm,unitPrice, true,  billingAccountNumber,disconnectRequest.BillingCycleDay__c);
                        System.debug('ETCCharges  : '+ETCCharges);
                        ETCAttr.cscfga__Display_Value__c = ETCCharges;
                        ETCAttr.cscfga__Value__c = ETCCharges;
                        attrToUpdate.add(ETCAttr);
                        System.debug('***Telstra:DisconnectionDate'+DisconnectionDate+':disconnectRequest'+disconnectRequest.Requested_DateTime__c);
                        DisconnectionDate.cscfga__Display_Value__c = (DateTime.valueOf((disconnectRequest.Requested_DateTime__c).replaceAll('T',' '))).format('dd/MM/yyyy');
                        DisconnectionDate.cscfga__Value__c = (DateTime.valueOf((disconnectRequest.Requested_DateTime__c).replaceAll('T',' '))).format('dd/MM/yyyy');
                        attrToUpdate.add(DisconnectionDate); 
                        if(priceRecord!=null){
                            MobileDeviceETC.cscfga__Display_Value__c = priceRecord.id;
                            MobileDeviceETC.cscfga__Value__c = priceRecord.id;
                        } 
                        attrToUpdate.add(MobileDeviceETC);

                        //pc.csedm__CFS_Mapping_List__c = pc.csedm__CFS_Mapping_List__c+',423_NRC_605'; // Commented out as part of EDGE-175208
                        pc.csedm__edm_mapping_list__c = pc.csedm__edm_mapping_list__c+',423_NRC_605'; // Added as part of EDGE-175208
                       // System.debug('ETC:'+ETCCharges+'MobileDeviceETC:'+priceRecord.id+'DisconnectionDate:'+DisconnectionDate.cscfga__Value__c);
                       //EDGE-179370 Start
                    if(ETCCharges != null && ETCCharges != 'Error' && Decimal.valueOf(ETCCharges) > 0 ){
                        service.action_type__c = 'PayOut';
                        serviceListToUpdate.add(service);
                    }
                    else{
                        service.action_type__c = 'PaidOut';
                        serviceListToUpdate.add(service);
                    }//EDGE-179370 End

                    }
                    subscriptionVsETC.put(subscription.id,Decimal.valueOf(ETCCharges));
                }
                if(pc != null){pcToUpdate.add(pc);  }
            }
        }
        update attrToUpdate;
        if(pcToUpdate != null){
            update pcToUpdate;  }      
        //EDGE-179370
        if(serviceListToUpdate != null){
            update serviceListToUpdate;
            }           
            
        return subscriptionVsETC;
    }
    
}