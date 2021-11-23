/*
===============================================================================================================================
Class : MACService
Developer Name :
Test Class : MACServiceTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
  1.      Ravi Bhatnagar     30/12/19      EDGE-124891 : Refactor Orchestration Processes
  2.      Vaibhav Deshpande  06/03/20      EDGE-115662 & EDGE-137502 Fix
  3.      Sandip Deshmane    18/03/2020    EDGE-138605 - Removed condition to filter Solution level services.
  4.      Manish Jha(For Eureka) 20/03/2020 EDGE-110172 - Fulfiling the design gap of the story
  5.      Pawan Devaliya     15/05/2020     EDGE-144704:Update status of svc,subs, ord to Paid out for NGUC device and accesories for paid out scenario
  6.      Gnana              15/05/2020     EDGE-146358 : Added a new method updateOrderToSkipFullfillment
===============================================================================================================================
*/
public with sharing class MACService
{
    //EDGE-124891 : Method changed as part of refactoring
    public static void updateServiceStatus(List<Id> serviceIds){       
        Map<Id,csord__Service__c> updatedServiceMap = new Map<Id,csord__Service__c>();
        Set<Id> subscriptionIdSet = new Set<Id>();
        Map<Id,csord__Subscription__c> updatedSubscriptionMap = new Map<Id,csord__Subscription__c>();
        //EDGE-138605 - Removed condition to filter Solution level services.
        Map<Id,csord__Service__c> serviceMap = new Map<Id,csord__Service__c>([SELECT Id, Name, toBeCancelled__c, csord__Status__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, csordtelcoa__Replaced_Service__r.csord__Status__c,csordtelcoa__Replaced_Service__r.Payment_Type__c,Payment_Type__c, CreatedDate, Action_Type__c,csordtelcoa__Product_Configuration__r.Remaining_Term__c,csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name FROM csord__Service__c WHERE Id IN : serviceIds and csordtelcoa__Replaced_Service__c!=null]);
        Set<Id> serviceIdSet =  new Set<Id>();
        if (!serviceMap.isEmpty())
            serviceIdSet = serviceMap.keySet();
        //EDGE-124891 : Commented as part of refactoring 
        /*for(csord__Service__c serv : serviceList){
            serviceMap.put(serv.Id, serv);
            serviceIdSet.add(serv.Id);
        }*/
        //Create a map of service and its attachment
        Map<Id, Attachment> attmAP = new Map<Id, Attachment>([SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: serviceIdSet and name = 'ServiceSpecifications.json']);
        Map<Id, Attachment> serviceIdToSpecAttachMap = new Map<Id, Attachment>();
        Map<String,String> guidToServiceMap = new Map<String,String>();
        Map<String,String> guidToStatusCodeMap = new Map<String,String>();//EDGE-119749 - bugfix
        Map<String,String> guidToCodMap = new Map<String,String>();//Added by Rahul for EDGE-110172
        Map<String,String> guidToTargetSystemMap = new Map<String,String>();
        if(attmAP.values() != null){
            
            for(Attachment tempAttachment: attmAP.values()){
                serviceIdToSpecAttachMap.put(tempAttachment.parentId, tempAttachment);
            }
        }
        //EDGE-124891 : Added as part of refactoring
        attmAP.clear();
        Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();
        Set<String> guidListToBeDisconnected = new Set<String>();
        
        for(Id serId : serviceIds){ 
            guidToServiceMap = new Map<String,String>();
            //fetch the attachment for this servie
            String serviceattachmentstr = '';
            Attachment attch = serviceIdToSpecAttachMap.get(serId);
            System.debug('attch======'+attch);
            if(attch != null){
            serviceattachmentstr = attch.body.toString();
            }
           
            System.debug('serviceattachmentstr===>');
            //deserialise the attachment
            List<Object> lstSpecifications = new List<Object>();
            System.debug('serviceattachmentstr===>1111');
            //deserialise the attachment
            if(attch != null){
                System.debug('serviceattachmentstr===>1122211');
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(serviceattachmentstr);
            System.debug('serviceattachmentstr===>11222231');
            lstSpecifications = (List<Object>)results.get('specifications');
            }
            List<Object> lstFulfilmentSpecifications = new List<Object>();
            List<Object> lstBillingSpecifications = new List<Object>();
            List<Object> lstAssuranceSpecifications = new List<Object>();
            //System.debug('cancel status================================================='+serviceMap.get(serId).toBeCancelled__c);
            Boolean isServiceToBeDisconnected=false;
            System.debug('isServiceToBeDisconnected===>1111');
            if(serviceMap.get(serId)!=null){
                isServiceToBeDisconnected = serviceMap.get(serId).toBeCancelled__c.equalsIgnoreCase('true');
            }
            System.debug('isServiceToBeDisconnected===>1113331');
            if(isServiceToBeDisconnected){
                //update the status of service to disconnect pending as this is a cease scenario
                csord__Service__c service = serviceMap.get(serId);
                service.csord__Status__c = 'Disconnect Pending';
                updatedServiceMap.put(service.Id,service);
                
                
                //create empty list of objects to hold the deserialized specifications based on the targetSystem value
                List<Object> lstAllSpecifications = new List<Object>();
                //iterate over the entire list of deserialized specifications
                System.debug('lstSpecifications  '+lstSpecifications);
                for (Object specification : lstSpecifications) {
                    //fetch the attributes block in the specs
                    Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
                    //fetch only the simple attributes
                    Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('attributes');
                    //iterate over the simple attributes
                    for(String atrributeattName: attributesMap.keyset()){
                        string tempValue = '';
                        //check if the attribute name is targetSystem
                        if(atrributeattName.contains('__targetSystem')){
                            tempValue = (String)JSON.deserialize(JSON.serialize(attributesMap.get(atrributeattName)), String.class);
                            //filter and populate the list of deserialized specs
                            if(tempValue == 'FULFILMENT'){
                                lstFulfilmentSpecifications.add(specification);
                                lstAllSpecifications.add(specification);
                            }
							else if(tempValue == 'BILLING'){
                                lstBillingSpecifications.add(specification);
                                lstAllSpecifications.add(specification);
                            }
							else if(tempValue == 'ASSURANCE'){
                                lstAssuranceSpecifications.add(specification);
                                lstAllSpecifications.add(specification);
                            }
                        }
                    }
                }
                //system.debug('lstAllSpecifications ' + lstAllSpecifications.size());
                
                //iterate over all the deserialized specs. Note that there is a future scope of chance where in not all the specs should be marked as Disconnect Pending,
                //for that case do not iterate over all the specs but just the ones required as filtered above
                for(Object specification : lstAllSpecifications){
                    Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
                    //fetch the guid value
                    string specguid = (String) specificationAttributes.get('guid');
                    string specCode = (String) specificationAttributes.get('code');//Added by Rahul for EDGE-110172
                    //system.debug('guid value ' + specguid);
                    //add the value of guid of the spec whose status needs to be changed
                    string statusGuid =  (String) specificationAttributes.get('status');//EDGE-119749 - bugfix
                    Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('attributes');
                    guidListToBeDisconnected.add(specguid);
                    guidToCodMap.put(specguid,specCode);//Added by Rahul for EDGE-110172
                    guidToServiceMap.put(specguid,serId);
                    guidToStatusCodeMap.put(specguid,statusGuid);//EDGE-119749 - bugfix
                    guidToTargetSystemMap.put(specguid,String.valueOf(attributesMap.get('__targetSystem')));
                    System.debug('guidToTargetSystemMap  '+guidToTargetSystemMap);
                }
                System.debug('guidListToBeDisconnected====>'+guidListToBeDisconnected);
                //update the service spec status values
                if(guidToServiceMap!=null && guidToServiceMap.size()>0){
                    String updatedServiceattachmentstr=serviceIdToSpecAttachMap.get(serId).body.toString(); // changes from attchBody to updatedServiceattachmentstr to support multiple spec update
                   // if(guidListToBeDisconnected!=null && guidListToBeDisconnected.size()>0){
                    for(String guid : guidToServiceMap.keySet()){
                        if(guidToStatusCodeMap.get(guid) != 'Created'){//EDGE-119749 - bugfix
                       // String attchBody = serviceIdToSpecAttachMap.get(serId).body.toString();
                        //Start By Rahul for EDGE-110172
                       // String updatedServiceattachmentstr='';
                        system.debug('*****guidToCodMap.get guid --> '+ guidToCodMap.get(guid));
                        system.debug('*****service - Payment_Type__c --> '+ serviceMap.get(guidToServiceMap.get(guid)).Payment_Type__c);
                        System.debug('Eureka::'+guidToCodMap.get(guid)+':::'+serviceMap.get(guidToServiceMap.get(guid)).Payment_Type__c+':::'+guidToTargetSystemMap.get(guid)+'::::'+ServiceMap.get(guidToServiceMap.get(guid)).csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name);
  
                        //EDGE : 144704 : Added Paid Out and spec code condition 
                         if((guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000423') || guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000623') || guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000622')) && (serviceMap.get(guidToServiceMap.get(guid)).Action_Type__c=='PayOut' || serviceMap.get(guidToServiceMap.get(guid)).Action_Type__c.equalsIgnoreCase('PaidOut'))){
                            if(guidToTargetSystemMap.get(guid)=='BILLING'){

                                if(serviceMap.get(guidToServiceMap.get(guid)).Action_Type__c.equalsIgnoreCase('PaidOut')){ updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(updatedServiceattachmentstr), guid, 'status','Paid Out');
                                }
                                else if(guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000423')){ updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(updatedServiceattachmentstr), guid, 'status','Disconnect Pending');
                                }
                                
                             }else if(guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000423') && serviceMap.get(guidToServiceMap.get(guid)).Action_Type__c=='PayOut'){  updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(updatedServiceattachmentstr), guid, 'status','Paid Out');
                             }
                        }
                        else if(guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000423') && (serviceMap.get(guidToServiceMap.get(guid)).Action_Type__c=='None') && serviceMap.get(guidToServiceMap.get(guid)).csordtelcoa__Product_Configuration__r.Remaining_Term__c == 0){
                                 updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(updatedServiceattachmentstr), guid, 'status','Paid Out');
                        }
                        else if((guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000622') || guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000423')) && serviceMap.get(guidToServiceMap.get(guid)).Payment_Type__c=='Rental'){
                            System.debug('Wrong COndition');
                            updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(updatedServiceattachmentstr), guid, 'status','Disconnect Pending');
                        }else if((guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000622') || guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000623')) && serviceMap.get(guidToServiceMap.get(guid)).Payment_Type__c != 'Rental' && guidToTargetSystemMap.get(guid).contains('FULFILMENT') && ServiceMap.get(guidToServiceMap.get(guid)).csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name != 'Device Outright Purchase'){
                            System.debug('Eureka Design Gap test::');
                            updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(updatedServiceattachmentstr), guid, 'status','Disconnected');
                        }//EDGE-110172 Upliftment
                        else{
							System.debug('updatedServiceattachmentstr  177 '+String.valueof(updatedServiceattachmentstr));
							updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(updatedServiceattachmentstr), guid, 'status','Disconnect Pending');
                        }
                        //End Here for EDGE-110172
                        Attachment toUpdateAtt = serviceIdToSpecAttachMap.get(serId);
                        toUpdateAtt.body = Blob.valueof(updatedServiceattachmentstr);
                        serviceIdToSpecAttachMap.put(toUpdateAtt.parentId,toUpdateAtt);
                        updatedAttSet.put(toUpdateAtt.id,toUpdateAtt);
                    }//EDGE-119749 - bugfix
                    }
                }
            }
            //this is the else block that handles the service when not to be cancelled
            else{
                Integer counterFulfilment = 0;
                Integer counterBilling = 0;
                //fetch the fulfilment specs
                List<Object> lstAllSpecifications = new List<Object>();//Changed by Rahul for EDGE-110172
                if(lstSpecifications != null)
                for (Object specification : lstSpecifications) {
                    //fetch the attributes block in the specs
                    Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
                    //fetch only the simple attributes
                    Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('attributes');
                    //iterate over the simple attributes
                    for(String atrributeattName: attributesMap.keyset()){
                        string tempValue = '';
                        //check if the attribute name is targetSystem
                        if(atrributeattName.contains('__targetSystem')){
                            tempValue = (String)JSON.deserialize(JSON.serialize(attributesMap.get(atrributeattName)), String.class);
                            //filter and populate the list of deserialized specs
                            if(tempValue == 'FULFILMENT'){
                                lstFulfilmentSpecifications.add(specification);
                                lstAllSpecifications.add(specification);
                            }
                            if(tempValue == 'BILLING'){
                                lstBillingSpecifications.add(specification);
                                lstAllSpecifications.add(specification);
                            }
                        }
                    }
                }
                //Start By Rahul for EDGE-110172
                for(Object specification : lstAllSpecifications){
                    Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
                    //fetch the guid value
                    string specguid = (String) specificationAttributes.get('guid');
                    string specCode = (String) specificationAttributes.get('code');//Added by Rahul for EDGE-110172
                    //system.debug('guid value ' + specguid);
                    //add the value of guid of the spec whose status needs to be changed
                    
                    guidToCodMap.put(specguid,specCode);////Added by Rahul for EDGE-110172
                    guidToServiceMap.put(specguid,serId);
                }
                
                if(guidToServiceMap!=null && guidToServiceMap.size()>0){
                    String updatedServiceattachmentstr = serviceIdToSpecAttachMap.get(serId).body.toString(); // changes from attchBody to updatedServiceattachmentstr to support multiple spec update
                   // if(guidListToBeDisconnected!=null && guidListToBeDisconnected.size()>0){
                    for(String guid : guidToServiceMap.keySet()){
                        
                       // String attchBody = serviceIdToSpecAttachMap.get(serId).body.toString();
                        //String updatedServiceattachmentstr;
                        system.debug('*****guidToCodMap.get guid --> '+ guidToCodMap.get(guid));
                        system.debug('*****service - Payment_Type__c --> '+ serviceMap.get(serId).Payment_Type__c);
                        system.debug('*****Replaced service - Payment_Type__c --> '+ serviceMap.get(serId).csordtelcoa__Replaced_Service__r.Payment_Type__c);
                                   //EDGE : 144704 : Added Paid Out and spec code condition 
                        if((guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000423')|| guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000623') || guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000622')) && (serviceMap.get(guidToServiceMap.get(guid)).Action_Type__c=='PayOut' || serviceMap.get(guidToServiceMap.get(guid)).Action_Type__c.equalsIgnoreCase('PaidOut'))){
                            System.debug('guid  243 '+guid);
                            System.debug('guid  244 '+guidToTargetSystemMap.get(guid));
                            System.debug('guid  245 '+guidToTargetSystemMap);
                            if(guidToTargetSystemMap.get(guid)=='BILLING'){
                                if(serviceMap.get(guidToServiceMap.get(guid)).Action_Type__c.equalsIgnoreCase('PaidOut')){ updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(updatedServiceattachmentstr), guid, 'status','Paid Out');
                             }
                                else if(guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000423')){updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(updatedServiceattachmentstr), guid, 'status','Disconnect Pending');
                        }
                                
                             }else if(guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000423') && serviceMap.get(guidToServiceMap.get(guid)).Action_Type__c=='PayOut'){updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(updatedServiceattachmentstr), guid, 'status','Paid Out');
                             }
                        }
                        else if(guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000423') && (serviceMap.get(guidToServiceMap.get(guid)).Action_Type__c=='None') && serviceMap.get(guidToServiceMap.get(guid)).csordtelcoa__Product_Configuration__r.Remaining_Term__c == 0){ updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(updatedServiceattachmentstr), guid, 'status','Paid Out');
                             
                        }
                        else if((guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000622') || guidToCodMap.get(guid).contains('DMCAT_ProductSpecification_000423')) && serviceMap.get(serId).Payment_Type__c!=serviceMap.get(serId).csordtelcoa__Replaced_Service__r.Payment_Type__c && serviceMap.get(serId).Payment_Type__c=='Rental'){
                                updatedServiceattachmentstr = csedm.API_1.updateServiceSpecificationProperty(String.valueof(updatedServiceattachmentstr), guid, 'status','Disconnect Pending');//EDGE-119749 - bugfix
                            }
                            //Start Here Rahul for EDGE-110172
                            if(updatedServiceattachmentstr!=null){
                                Attachment toUpdateAtt = serviceIdToSpecAttachMap.get(serId);
                                toUpdateAtt.body = Blob.valueof(updatedServiceattachmentstr);
                                serviceIdToSpecAttachMap.put(toUpdateAtt.parentId,toUpdateAtt);
                                updatedAttSet.put(toUpdateAtt.id,toUpdateAtt);
                            }
                            //End Here Rahul for EDGE-110172
                        
                    }
                }
                
                system.debug('else here111');
                //if fulfilment specs are present
                if(lstFulfilmentSpecifications.size() > 0){
                    for(Object specification : lstFulfilmentSpecifications){
                        Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
                        //fetch the status value
                        string specStatus = (String) specificationAttributes.get('status');
                        
                        
                        if(specStatus== Label.Complete){
                            counterFulfilment = counterFulfilment + 1; 
                        }
                        
                    }
                    if(lstFulfilmentSpecifications.size() == counterFulfilment ){
                        csord__Service__c ser = serviceMap.get(serId);
                        //Set the value of the statuc of service to Connected
                        ser.csord__Status__c = ser.csordtelcoa__Replaced_Service__r.csord__Status__c;
                        updatedServiceMap.put(ser.Id,ser);
                    }
                }
                //this is the else block which gets executed if the service does not contain any fulfilment spec
                else{
                    system.debug('else here111 else');
                    csord__Service__c ser = new csord__Service__c();
                    if(serviceMap.get(serId)!=null){
                         ser = serviceMap.get(serId);
                    }else{
                        ser.id= serId;
                    }
                    //csord__Service__c ser = serviceMap.get(serId);
                    ser.csord__Status__c = Label.MO_Service_Status_Connected;
                    updatedServiceMap.put(ser.Id,ser);
                }    
            }
        }
        //update the attachments
        if(!updatedAttSet.isEmpty()){
            update updatedAttSet.values();
        }
        
        //update the service records
        //EDGE-124891 : Commented as part of refactoring
        //List<csord__Service__c> updatedServiceList = new List<csord__Service__c>();
        if(updatedServiceMap.values() != NULL){
                for(Id servId : updatedServiceMap.keySet()){
                    subscriptionIdSet.add(updatedServiceMap.get(servId).csord__Subscription__c);
            }
            update updatedServiceMap.values();
        }
        //EDGE-124891 : Commented as part of refactoring
        /*List<csord__Service__c> updatedServiceList = [SELECT Id, Name, toBeCancelled__c, csord__Status__c, csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, csordtelcoa__Replaced_Service__r.csord__Status__c, CreatedDate FROM csord__Service__c WHERE Id IN : updatedServiceMap.keySet()];*/

        
        Map<Id,csord__Subscription__c> subscriptionMap = new Map<Id,csord__Subscription__c>([select id, csord__Status__c from csord__Subscription__c where id in:subscriptionIdSet]);
        
        Map<Id,Integer> subServiceCountMap = new Map<Id,Integer>();
        for(Id subId : subscriptionMap.keySet()){
            Integer servCount =0;
            for(csord__Service__c serv : serviceMap.values()){
                if(serv.csord__Subscription__c == subId){
                    servCount = servCount+1;
                }
            }
            subServiceCountMap.put(subId,servCount);
        }
        if(subscriptionIdSet.size()>0){
            
            for(Id subId : subscriptionIdSet){
                Integer countConnectedServices = 0;
                for(csord__Service__c serv : updatedServiceMap.values()){
                    if(serv.csord__Subscription__c == subId && updatedServiceMap.keySet().contains(serv.id) && serv.toBeCancelled__c != 'true'){
                        countConnectedServices = countConnectedServices+1;
                    }
                }
                if(countConnectedServices == subServiceCountMap.get(subId)){
                    csord__Subscription__c sub = subscriptionMap.get(subId);
                    sub.csord__Status__c = 'Active';
                    //commented code as part of EDGE-115662 & EDGE-137502
                    /*if(sub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent'){
                       sub.csord__Status__c = 'Active';
                    }else{
                     sub.csord__Status__c = 'Provisioned';
                     sub.triggerBill_RTB__c = true;
                    }*/
                    updatedSubscriptionMap.put(sub.id,sub);
                }
                
            }
        }
        //update the subscription if all the services are connected
        if(!updatedSubscriptionMap.isEmpty()){
            update updatedSubscriptionMap.values();
        }
    }
    
    //EDGE-81566
    Public static void updateServiceStatusMobileAccess(List<Id> orderIdList){ 
    //EDGE-124891 : Commented as part of refactoring    
        //try{
            
            List<csord__Subscription__c>  subList = [SELECT Id, Name,MarketableOffer__r.Config__c, csord__Order__r.csord__Primary_Order__c, csord__Status__c,triggerBill_RTB__c,Trigger_RTS__c,toBeCancelled__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name,(SELECT Id, Name, csord__Order__r.csord__Primary_Order__c, csord__Status__c,csordtelcoa__Replaced_Service__c,Action_Type__c,toBeCancelled__c,csordtelcoa__Product_Configuration__r.Remaining_Term__c  from csord__Services__r) from csord__Subscription__c where csord__Order__c IN: orderIdList];
            Map<Id,csord__Subscription__c> allSubMap = new  Map<Id,csord__Subscription__c>();
            //Added by Ravi
            Map<Id,csord__Service__c> allservMap =  new Map<Id,csord__Service__c>();
            for(csord__Subscription__c subscription : subList){
                //Ignore Partner delivery offers PS MDM, PS TC and MMS, chaneged for EDGE-127047
                Boolean isPartnerDeliveredOffer = false;
                System.debug('subscriptionSOM'+subscription);
                if(subscription.MarketableOffer__r != NULL && String.isNotBlank(subscription.MarketableOffer__r.Config__c))
                {
                    Map<String, Object> basketConfiguration = (Map<String, Object>)JSON.deserializeUntyped(subscription.MarketableOffer__r.Config__c);
                    if(basketConfiguration.get('SOMOpenAir') != NULL && (Boolean)basketConfiguration.get('SOMOpenAir'))
                    {
                       // System.debug('subscriptionSOM'+subscription.Id);
                        isPartnerDeliveredOffer = true;   
                    }
                }
                //if(!isPartnerDeliveredOffer) {
                    allSubMap.put(subscription.Id,subscription);
                    //Added by Ravi
                    for(csord__Service__c ser : subscription.csord__Services__r){
                        allservMap.put(ser.id,ser);
                    }                    
                //}
                //End  EDGE-127047
            }
            //EDGE-124891 : Commented as part of refactoring
            //List<csord__Service__c> servList = [SELECT Id, Name, csord__Status__c,csord__Order__c from csord__Service__c where csord__Subscription__c IN:allSubMap.keySet()];
            //Commented by Ravi
            /*Set<Id> serviceIdSet =  new Set<Id>();
            for(csord__Service__c serv : servList){
                serviceIdSet.add(serv.Id);
            }*/
            
            
            
            Map<Id, Attachment> attmAP = new Map<Id, Attachment>([SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: allservMap.keySet() and name = 'ServiceSpecifications.json']);
            
            Map<Id, Attachment> serviceIdToSpecAttachMap = new Map<Id, Attachment>();
                if(attmAP.values() != null){
            for(Attachment tempAttachment: attmAP.values()){
                serviceIdToSpecAttachMap.put(tempAttachment.parentId, tempAttachment);
            }
        }
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Service__c> serviceListToUpdate = new List<csord__Service__c>();
            // start changes EDGE-99305
            for(csord__Subscription__c subs : allSubMap.values()){
            String reqType = isFulfilmentRequired(subs,serviceIdToSpecAttachMap,subs.csord__Services__r);
            if (reqType == 'NotRequired'){
                if(subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent')
                 subs.csord__Status__c = 'Active';
                else{
                 subs.csord__Status__c = 'Provisioned';
                }
                    
                subscriptionList.add(subs);
                //commented code as part of EDGE-115662 & EDGE-137502
                /*if(subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent'){subs.csord__Status__c = 'Active';subscriptionList.add(subs);
                }else{
                     subs.csord__Status__c = 'Provisioned';subscriptionList.add(subs); subs.triggerBill_RTB__c = true;
                }*/
                 
                    System.debug('sub1==>'+subs); 
                for(csord__Service__c ser : subs.csord__Services__r){
                    
                    if(ser.Action_Type__c == 'None' && ser.csordtelcoa__Product_Configuration__c!=null && ser.csordtelcoa__Product_Configuration__r.Remaining_Term__c !=null && ser.csordtelcoa__Product_Configuration__r.Remaining_Term__c == 0)ser.csord__Status__c = 'Paid Out';
                    else
                    ser.csord__Status__c = 'Connected'; serviceListToUpdate.add(ser);
                }
            } 
            // End changes for EDGE-99305
            else if(reqType == 'OnlyFulfilmentRequired' || reqType == 'BothRequired'){
                    subs.csord__Status__c = 'Pending';
                    subscriptionList.add(subs);
                for(csord__Service__c ser : subs.csord__Services__r){
                    ser.csord__Status__c = 'Pending';serviceListToUpdate.add(ser); }
            }else if(reqType == 'OnlyBillingRequired'){
                subs.csord__Status__c = 'Provisioned';
                if(subs.toBeCancelled__c == 'true'){
                //commented code as part of EDGE-115662 & EDGE-137502
                //Uncommented code for EDGE-139661
                //EDGE-110172 upliftment
                if((subs.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c == 'DMCAT_ProductSpecification_000622' || subs.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c == 'DMCAT_ProductSpecification_000623') && subs.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name != 'Device Outright Purchase'){
                        subs.Trigger_RTS__c = true;}
                }
                    subscriptionList.add(subs);
                for(csord__Service__c ser : subs.csord__Services__r){
                    if(ser.toBeCancelled__c == 'true' && subs.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name != 'Device Outright Purchase')
                    ser.csord__Status__c = 'Disconnected';
                    else
                    ser.csord__Status__c = 'Connected';
                    serviceListToUpdate.add(ser);
                
                }
            }
            // End EDGE-99305
            
        }
        if(serviceListToUpdate != null )
        update serviceListToUpdate;
        if(subscriptionList != null)
        update subscriptionList;
        /*}
        catch(Exception ex){
            //catch exception
        }*/
        
    }
    
    /*************************************************************************************************************************
    * Method Name      :   isFulfilmentRequired
    *Return            :   returns fulfilment is required or not for mobility modify order
                            (Order Orchestration to support standalone Enterprise Mobility Offer - Modify Order)
                           
    *Story             :   EDGE-99305
    *************************************************************************************************************************/
    // start changes for EDGE-99305
    Public static String isFulfilmentRequired (csord__Subscription__c SubIds,Map<Id, Attachment> serviceIdToSpecAttachMap, List<csord__Service__c> servList){
        String requirementType = '';
        List<Object> lstFulfilmentSpecs = new List<Object>();
        List<Object> lstBillingSpecs = new List<Object>();
        List<Object> listOfSpecs = new List<Object>();
        
            for (csord__Service__c serId : servList){
            String serviceattachmentstr = '';
            Attachment attch = serviceIdToSpecAttachMap.get(serId.id);
            System.debug('attch======'+attch);
            if(attch != null){
            serviceattachmentstr = attch.body.toString();
            }
            
            
            //deserialise the attachment
            if(attch != null){   
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(serviceattachmentstr);
                listOfSpecs.addAll((List<Object>)results.get('specifications'));
            }
            }
                Integer countFulfilment = 0;
                Integer countDisconnected = 0;
                Integer countBilling = 0;
                Integer countDisconnectedBilling = 0;
                //fetch the fulfilment specs
                if(listOfSpecs != null){
                for (Object specification : listOfSpecs) {
                    //fetch the attributes block in the specs
                    Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
                    //fetch only the simple attributes
                    Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('attributes');
                    //iterate over the simple attributes
                    for(String atrributeattName: attributesMap.keyset()){
                        string tempValue = '';
                        //check if the attribute name is targetSystem
                        if(atrributeattName.contains('__targetSystem')){
                            tempValue = (String)JSON.deserialize(JSON.serialize(attributesMap.get(atrributeattName)), String.class);
                            //filter and populate the list of deserialized specs
                            if(tempValue == 'FULFILMENT'){
                                lstFulfilmentSpecs.add(specification);
                            }
                            if(tempValue == 'BILLING'){
                                lstBillingSpecs.add(specification);
                            }
                         
                        }
                    }
                }
                
                if(lstFulfilmentSpecs.size() > 0){
                    for(Object specification : lstFulfilmentSpecs){
                        Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
                        //fetch the status value
                        string specStatus = (String) specificationAttributes.get('status');
                        if(specStatus== Label.Complete || specStatus == 'Paid Out'){
                            countFulfilment = countFulfilment + 1; 
                        }
                        else if(specStatus== 'Disconnected'){countDisconnected = countDisconnected + 1; 
                        }
                    }
                }
                if(lstBillingSpecs.size() > 0){
                    for(Object specification : lstBillingSpecs){
                        Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
                        //fetch the status value
                        string specStatus = (String) specificationAttributes.get('status');
                        if(specStatus== Label.Complete || specStatus == 'Paid Out'){countBilling = countBilling + 1; 
                        }
                        else if(specStatus== 'Disconnected'){countDisconnectedBilling = countDisconnectedBilling + 1; 
                        }
                    }
                }
                    System.debug('Size::'+lstFulfilmentSpecs.size()+' countFulfilment'+countFulfilment+' countDisconnected'+countDisconnected+' lstBillingSpecs.size()'+lstBillingSpecs.size()+' countBilling'+countBilling+ ' countDisconnectedBilling'+countDisconnectedBilling);
                    if(lstFulfilmentSpecs != null && (lstFulfilmentSpecs.size()==0 || lstFulfilmentSpecs.size() == countFulfilment + countDisconnected) &&  (lstBillingSpecs!= null && (lstBillingSpecs.size() == 0 || lstBillingSpecs.size() == countBilling + countDisconnectedBilling))){
                        requirementType = 'NotRequired';
                        
                    }else if((lstFulfilmentSpecs != null && lstFulfilmentSpecs.size()!=0 && lstFulfilmentSpecs.size() != countFulfilment + countDisconnected) && (lstBillingSpecs!= null && (lstBillingSpecs.size() == 0 || lstBillingSpecs.size() == countBilling + countDisconnectedBilling))){
                        requirementType = 'OnlyFulfilmentRequired';
                    }else if(( lstFulfilmentSpecs != null && lstFulfilmentSpecs.size()!=0 && lstFulfilmentSpecs.size() != countFulfilment + countDisconnected) && (lstBillingSpecs!= null && lstBillingSpecs.size() != countBilling + countDisconnectedBilling)){
                        requirementType = 'BothRequired';
                    }else if((lstFulfilmentSpecs != null && (lstFulfilmentSpecs.size()==0 || lstFulfilmentSpecs.size() == countFulfilment + countDisconnected)) && (lstBillingSpecs!= null && lstBillingSpecs.size() != countBilling + countDisconnectedBilling)){
                        requirementType = 'OnlyBillingRequired';
                    }
                
            }
        System.debug('SubIds::'+SubIds.Id);
        System.debug('requirementType::'+requirementType);
        return requirementType;
            
    }
    // end changes for EDGE-99305
        
    /*  
     * Method Name : updateOrderToSkipFullfillment
     * Input Parameter 1 : orderIdList - List of Order Ids
     * Description : Updates Order's skipFulfillment_c to true if all Subscrptions under that order is in any
     *               one of these Statuses ("Pending","Provisioning In Progress","Disconnect Pending",
     *               "Disconnect in Progress")
     * EDGE-146358
    */
    Public static void updateOrderToSkipFullfillment(List<Id> orderIdList){
        List<csord__Order__c> ordListWithSubs = [SELECT Id, (SELECT Id,Name,csord__Order__c,csord__Status__c FROM csord__Subscriptions__r) FROM csord__Order__c WHERE Id IN :orderIdList];
        List<csord__Order__c> listOfOrdersToUpdate = new List<csord__Order__c>();
        for(csord__Order__c ord : ordListWithSubs){
            Boolean skipFullfillment;
            for(csord__Subscription__c subs : ord.csord__Subscriptions__r){
                System.debug('subs.csord__Status__c...'+subs.csord__Status__c);
                if(subs.csord__Status__c == 'Pending' || subs.csord__Status__c == 'Provisioning In Progress' || subs.csord__Status__c == 'Disconnect Pending' || subs.csord__Status__c == 'Disconnect in Progress'){
                    skipFullfillment = false;
                    break;
                }
                else{
                    skipFullfillment = true;
                }
            }
            
            csord__Order__c ordToUpdate= new csord__Order__c(Id=ord.Id);
            ordToUpdate.skipFulfillment__c  = skipFullfillment;
            listOfOrdersToUpdate.add(ordToUpdate);
            
        }
        try{
            if(listOfOrdersToUpdate != null && listOfOrdersToUpdate.size()>0){
                System.debug('Updating order...'+listOfOrdersToUpdate);
                UPDATE listOfOrdersToUpdate;
            }
        }
        catch(Exception e){
            System.debug('Skip Fullfillment Update Failed...'+e.getMessage());
        }
    }
    
}