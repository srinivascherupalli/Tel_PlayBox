/*-----------------------------------------------------------------------------------------
EDGE        -80869
Class       -DeviceReplacementController
Description -Controller Class for REPLACE customer's Under warranty faulty Mobile devices without any charge
Author      -Dheeraj Bhatt
EDGE-182667 - Updated Submisson Date with Current time
---------------------------------------------------------------------------------------------*/
public without sharing class DeviceReplacementController {
    Public static String FULFILMENT='_Fulfilment';
    public static map<string,Service_Specs_Attribute__mdt> mapOfAttributeAndServiceSpec;
    //EDGE-150372. Dheeraj Bhatt. Initiatlized map.
    public static map<string,List<Service_Specs_Attribute__mdt>> mapOfprodutCodeAndServiceSpecs=new  map<string,List<Service_Specs_Attribute__mdt>>();
    /*----------------------------------------------------------------------------------------------------
EDGE        -80869
Method      -searchDevice 
Description -Return device subscription searched by  Assurance Service Agent User by providing Device Identifier
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    @AuraEnabled public static List<csord__Subscription__c> searchDevice(String accountId,String device){
        List<csord__Subscription__c> subscriptionList=new List<csord__Subscription__c>();
        set<string> optionValueSubs=new set<string>();
        List<String> subOption = new List<String>();
        for(Reverse_Logistic_Subscription_Status__mdt opt:[SELECT Label,DeveloperName from Reverse_Logistic_Subscription_Status__mdt]){
            subOption.add(opt.Label);
        }
        set<id> subscriptionIdSet=new set<id>();
        Try{
              //EDGE-194027-Dheeraj Bhatt-fetch Current Device SKU from asset to populate on UI
            subscriptionList=[SELECT id, csord__total_contract_value__c,csordtelcoa__Product_Configuration__r.name,Site__c,csord__Order__c, Site__r.Name,Site__r.Address__c, csordtelcoa__Subscription_Number__c,CreatedDate,
                              csord__Status__c, csord__Total_Recurring_Charges__c, csord__Total_One_Off_Charges__c,CreatedById,CreatedBy.Name,
                              csord__Account__c, Name, MarketableOffer__c,serviceMSISDN__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name,Is_Bill_Stopped__c
                              ,(SELECT Id,Status,Subscription__c,Stock_Keeping_Unit__c FROM Assets__r)
                              FROM csord__Subscription__c
                              WHERE  csord__Status__c IN :subOption and id in (SELECT Subscription__c FROM asset  WHERE accountId=:accountId AND (Status='Active' OR Status =: Label.Replaced_Active) AND AssetID__c =:device)];
        }
        Catch (Exception ex){
            Logger2 log = Logger2.getLogger('DeviceReplacementController');
            log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        }
        return subscriptionList;
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -Edge-100986
Method      -assetOfferId
Description - Check if nguc offer 
Author      -Mohammed Zeeshan
--------------------------------------------------------------------------------------------------------*/
    @AuraEnabled public static boolean assetOfferId(String device){
        Boolean isTelstraofferId=false;
        List<Asset> assetRecord = [SELECT id,AssetID__c,Status,OfferID__c,accountId FROM asset WHERE  AssetID__c =:device  AND Status='Active' LIMIT 1];
        if(assetRecord.size() >0){
            if(assetRecord[0].OfferID__c ==Label.Nguc_Offer){
                isTelstraofferId= true;
            }
        }
        return isTelstraofferId;
    }
    
     /*----------------------------------------------------------------------------------------------------
EDGE        -Edge-175532
Method      -currentDeviceSKUCheck
Description - Enable Device Replacement on a device that has been transitioned from CMP-L to Digi Mobility Products 
Author      -Jayghosh Mishra
--------------------------------------------------------------------------------------------------------*/

    @AuraEnabled public static boolean currentDeviceSKUCheck(String device){
        

        Boolean isTelstraofferId=false;
        List<Asset> assetRecord = [SELECT id,AssetID__c,Status,OfferID__c,accountId FROM asset WHERE  AssetID__c =:device  AND Status='Active' LIMIT 1];
        if(assetRecord.size() >0){
            if(assetRecord[0].OfferID__c == Label.Transition_Mobile_Device_Product){
                isTelstraofferId= true;
            }
        }
        return isTelstraofferId;

    }
    

    /*----------------------------------------------------------------------------------------------------
EDGE        -Edge-100986
Method      -ngucOffer
Description - Nguc specification generation
Author      -Mohammed Zeeshan
-------------------------------------------------------------------------------------------------------*/
    @AuraEnabled public static String ngucOffer(String device){
        String ngucOffer;
        Asset assetRecord = [SELECT id,AssetID__c,Status,OfferID__c,accountId FROM asset WHERE  AssetID__c =:device  AND Status='Active' LIMIT 1];
        if(assetRecord.OfferID__c ==Label.Nguc_Offer){
            ngucOffer =  String.valueOf(assetRecord.OfferID__c);
        }
        return ngucOffer;
    } 
    /*----------------------------------------------------------------------------------------------------
EDGE        -EDGE-120942
Method      -showAddReplaceButton 
Description -Show Replace Button On UI
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    @AuraEnabled public static string showAddReplaceButton(String accountId,String device){
        List<Asset> assetList=[SELECT id,AssetID__c,Subscription__c,Status,csordtelcoa__Replaced_Asset__c FROM asset 
                               WHERE accountId=:accountId AND (Status='Active' OR Status =: Label.Replaced_Active) AND AssetID__c =:device LIMIT 1];
        if(assetList.size() >0 ){
            List<Asset> replacedAssetList=[Select id,csordtelcoa__Replaced_Asset__c,Status from Asset Where csordtelcoa__Replaced_Asset__c =:assetList[0].Id LIMIT 1];
            if(replacedAssetList.size() > 0){
                return replacedAssetList[0].Status;
            }
        }
        return null;                       
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -80857
Method      -getOptionvalue
Description -Fetch recovery method and return reason from custom metadataType
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    @AuraEnabled public static List<OptionValueWrapperClass> getOptionvalue(String SobjectApiName){
        String query='SELECT Label,DeveloperName,O2A__c FROM ' + SobjectApiName ;
        List<OptionValueWrapperClass> optionValuepairList=new List<OptionValueWrapperClass>();
        Try{
            for(SObject opt:Database.query(String.escapeSingleQuotes(query))){
                OptionValueWrapperClass optionValuePair=new OptionValueWrapperClass();
                optionValuePair.option=String.valueOf(opt.get('label'));
                optionValuePair.value=String.valueOf(opt.get('O2A__c'));
                optionValuepairList.add(optionValuePair);
            }
        }
        Catch(Exception ex){
            Logger2 log = Logger2.getLogger('DeviceReplacementController');
            log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false); }
        return optionValuepairList;   
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -87057
Method      -createOrder
Description -create new order,new subscription,new service and new asset for the replaced device.
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    @AuraEnabled public static csord__Order__c createOrder(String accountId, csord__Subscription__c subscription,String shellProductDetails,String deliveryContactId,String deliveryAddressId, String tNowCaseRef){ 
        csord__Order__c order =new  csord__Order__c ();
        csord__Order_Request__c newOrderRequest=new csord__Order_Request__c(); // New  Order Request
        csord__Order__c newOrder =new    csord__Order__c ();
        List<csord__Service__c> oldServiceList=new List<csord__Service__c>();
        Map<String,String>  oldSpecAttributeMap = new Map<String,String>();
        Savepoint sp = Database.setSavepoint();//Create a savepoint to rollback transaction when exception occured in class
        Try
        { 
            map<Id,csord__Service__c> oldServiceMap=new map<Id,csord__Service__c>([Select id,csord__Status__c,csord__Order__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                                                                                   csord__Subscription__c,Delivery_Address__c,
                                                                                   recoveryMethod__c,returnReasonType__c,devicecareCaseId__c,TNowCaseId__c
                                                                                   from csord__Service__c where csord__Order__c= :subscription.csord__Order__c 
                                                                                   AND csord__Subscription__c =:subscription.id]);
            shellProductDetailsWrapper shellProduct = (shellProductDetailsWrapper) JSON.deserialize(shellProductDetails, shellProductDetailsWrapper.class);
            
            
            csord_Order_type__mdt orderMetaData=[SELECT id,csord_Identification__c,csord_Order_Type__c,csord_Product_Type__c, // Fetching data from metaDataType to populate on order request and order.
                                                 csord_Status2__c,csord_Module_Name__c,csord_Module_Version__c,csord_Process_Status__c 
                                                 FROM csord_Order_type__mdt LIMIT 1];
            
            
            newOrderRequest.csord__Request_DateTime__c=Datetime.now();
            if(orderMetaData != null){
                newOrderRequest.csord__Module_Name__c=orderMetaData.csord_Module_Name__c;
                newOrderRequest.csord__Module_Version__c=orderMetaData.csord_Module_Version__c;
                newOrderRequest.csord__Process_Status__c=orderMetaData.csord_Process_Status__c;
            }
            insert newOrderRequest;
            getProductCodeFromCustomMetaDataType();//Fetching ProductCode from customMetaData
            getProductCodeAndServiceSpec(oldServiceMap.values(),oldSpecAttributeMap);
            newOrder=createNewOrder(accountId,orderMetaData,newOrderRequest.id,tNowCaseRef);//EDGE-132715 Added tNowCaseRef // New order creation for replaced device
            csord__Subscription__c newSubscription=createNewSubsciption(newOrder,shellProduct,subscription);//New Subscription for replaced device
            modifyOldServiceSpecsStatus(oldServiceMap.keyset(),oldSpecAttributeMap,shellProduct);
            csord__Service__c newService=createNewService(newOrder,newSubscription.Id,shellProduct,deliveryaddressId,deliveryContactId); //New services for replaced device subscription 
            Asset oldAsset=[SELECT id,AssetID__c,Subscription__c,OfferID__c,csordtelcoa__Replaced_Asset__c,parentId FROM asset //Querying Old asset 
                            WHERE accountId=:accountId AND Subscription__c =:subscription.id  AND 
                            AssetID__c=:shellProduct.replacedDeviceID LIMIT 1];
            
            Asset newAsset=createNewAsset(accountId,shellProduct,oldAsset,newService); //Create new Asset
            
            GenerateServiceSpecs base=generateServiceSpecification(newService.Id,newSubscription.Id,shellProduct,oldSpecAttributeMap,oldServiceMap.values());
            for(csord__Service__c oldService:oldServiceMap.values()){
                oldService.csord__Order__c=newOrder.id;                               
                if(mapOfprodutCodeAndServiceSpecs.containsKey(oldService.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c+FULFILMENT )){
                    //EDGE-144537-Start
                    oldService.recoveryMethod__c=shellProduct.recoveryMethod;
                    oldService.returnReasonType__c=shellProduct.returnReason;
                    oldService.devicecareCaseId__c=shellProduct.deviceCareCaseID;
                    oldService.TNowCaseId__c=shellProduct.telstraNowCaseID;
                    //EDGE-144537 End
                }
                
                oldService.Delivery_Address__c=deliveryAddressId; // Delivery address and Site contact will update irrespective of spec, only for old service-EDGE-145766 
                oldService.Site_Delivery_Contact__c = deliveryContactId !=null?deliveryContactId:oldService.Delivery_Address__c;//EDGE-144929,EDGE-144930
                oldServiceList.add(oldService);
                
            }
            
            //START of EDGE-127660:Hackathon:Osaka(Ramya)
            createServiceSpec(base, newService);
            newOrder=[SELECT id,csord__Order_Number__c FROM csord__Order__c WHERE id=:newOrder.id];
            updateOrderAndSubscription(newOrder, subscription, order);
            //END of EDGE-127660
            if(oldServiceList.size() > 0){
                update oldServiceList;
            }
            return newOrder;
        }
        catch(Exception ex){
            system.debug('Exception Occured at line number '+Ex.getLineNumber()+' '+ex.getMessage());
            Logger2 log = Logger2.getLogger('DeviceReplacementController');
            log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
            Database.rollback(sp);
            return null;
        }
        
    }
    /*********************************************************************************************************
*   @Jira Story Ref - EDGE-122982
*   @ModifiedBy     - Ramya,OSAKA
*   @Description    - Hackathon: Cyclomatic complexity: Create Spec method, called by create order.
* 
***************************************************************************************************************/
    public static void createServiceSpec(GenerateServiceSpecs base,csord__Service__c newServiceId) {
        if(base !=null){
            String serviceSpecification=JSON.serialize(base);
            Attachment   newServiceSpecificationAttachment = new Attachment(  
                Name = 'ServiceSpecifications.json',
                body = Blob.valueOf(serviceSpecification),
                parentId = newServiceId.Id
            );
            if(newServiceSpecificationAttachment!=null){
                insert newServiceSpecificationAttachment;
            }
        }
    }
    /*******************************************************************************************************************
*   @Jira Story Ref - EDGE-122982
*   @ModifiedBy     - Ramya,OSAKA
*   @Description    - Hackathon: Cyclomatic complexity: upsert order and subscription, called by create order.
* 
**********************************************************************************************************************/
    public static void updateOrderAndSubscription(csord__Order__c newOrder, csord__Subscription__c subscription,csord__Order__c order) {
        if(newOrder!=null && String.IsNotBlank(newOrder.id)){ //Hackathon: Extended check for order Id to subscription    
            if(subscription != NULL){
                subscription.csord__Order__c=newOrder.id;//Updating Old subscription order Id to New order Id 
                update subscription;
            }                  
            if(String.IsNotBlank(newOrder.csord__Order_Number__c)){
                SubmitOrderOrchestration.createOrderOrchestrationProcess(newOrder.id);// orchestration process initiation
            }
        }
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -87057
Method      -createNewOrder
Description -create new order 
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    @AuraEnabled  public static csord__Order__c createNewOrder(String accountId,csord_Order_type__mdt orderMetaData,string newOrderRequestId,String tNowCaseRef){
        String orderName = label.Device_Replacement +'_' + ('0' + String.valueOf(Date.today().day())).right(2) + ( '0' + String.valueOf(Date.today().month())).right(2) + Date.today().year() + '_' + String.valueOf(System.now().time()).left(8);
        csord__Order__c newOrder=new csord__Order__c();
        newOrder.csord__Account__c=accountId;
        newOrder.recordTypeId =Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Order Submitted').getRecordTypeId();
        if(orderMetaData != null){
            newOrder.csord__Status2__c=orderMetaData.csord_Status2__c;
            newOrder.csord__Order_Type__c=orderMetaData.csord_Order_Type__c;
            newOrder.csord__Identification__c=orderMetaData.csord_Identification__c;
            newOrder.csord__Product_Type__c=orderMetaData.csord_Product_Type__c;
        }
        newOrder.csord__Start_Date__c=Date.today();
        newOrder.telstra_ord_Start_DateTime__c=System.now();//EDGE-182667
        newOrder.Name=orderName;
        newOrder.csord__Order_Request__c=newOrderRequestId;
        newOrder.Scenario_Type__c=label.Device_Replacement;
        newOrder.OwnerId=UserInfo.getUserId();
        if(tNowCaseRef != '' && tNowCaseRef != null && tNowCaseRef != 'undefined'){
            newOrder.referencenumber__c = tNowCaseRef.toUpperCase();//EDGE-132715
            
        }       
        insert newOrder;  
        return newOrder;
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -87057
Method      -createNewSubsciption
Description -create new Subsciption for new Order
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    Public static csord__Subscription__c createNewSubsciption(csord__Order__c newOrder,shellProductDetailsWrapper shellProduct,csord__Subscription__c subscription){
        csord__Subscription__c newSubscription=new csord__Subscription__c();
        newSubscription.csord__Order__c=newOrder.id;
        newSubscription.csord__Status__c=Constants.Subscription_Status;
        newSubscription.csord__Identification__c= newOrder.csord__Identification__c;
        newSubscription.Name=subscription.Name;
        newSubscription.MarketableOffer__c = subscription.MarketableOffer__c; // EDGE-143051
        newSubscription.csord__Account__c=subscription.csord__Account__c;
        newSubscription.Billing_Account__c=subscription.Billing_Account__c;
        string dmcatId=mapOfAttributeAndServiceSpec.containsKey('code')? mapOfAttributeAndServiceSpec.get('code').Value__c:'';
        newSubscription.Device_Replacement_DMCAT_Id__c=String.isNotBlank(dmcatId)? dmcatId.replace(FULFILMENT, ''):'';
        Insert newSubscription;
        return newSubscription;
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -80869
Method      -createNewService
Description -create new Service for new Subscription
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    public static csord__Service__c createNewService(csord__Order__c newOrder,String newSubscriptionId, shellProductDetailsWrapper shellProduct,String deliveryaddressId,String deliveryContactId){
        csord__Service__c newService=new csord__Service__c();
        newService.csord__Order__c=newOrder.id;
        newService.csord__Status__c=Constants.Service_Status;
        newService.Scenario_Type__c = label.Device_Replacement;
        newService.csord__Order_Request__c=newOrder.csord__Order_Request__c;
        newService.csord__Identification__c=newOrder.csord__Identification__c;
        newService.csord__Subscription__c=newSubscriptionId;
        newService.recoveryMethod__c=shellProduct.recoveryMethod;
        newService.returnReasonType__c=shellProduct.returnReason;
        newService.devicecareCaseId__c=shellProduct.deviceCareCaseID;
        newService.TNowCaseId__c=shellProduct.telstraNowCaseID;
        newService.Delivery_Address__c=deliveryaddressId;
        newService.Primary_Contact__c=deliveryContactId;
        newService.Site_Delivery_Contact__c = deliveryContactId;//EDGE-144929,EDGE-144930
        newService.name=(shellProduct.replacementDeviceManufacturer !=null? shellProduct.replacementDeviceManufacturer:'')+' '+ shellProduct.replacementDeviceModel+' '+(shellProduct.replacementDeviceColor !=null? shellProduct.replacementDeviceColor:'');
        newService.Replaced_Device_Id__c=shellProduct.replacedDeviceID;
        insert newService;
        return newService ;
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -87057 
Method      -generateServiceSpecification
Description -generate Service Specification for new service
Author      -Dheeraj Bhatt
ModifiedBy  -Manjunath Ediga EDGE-132532
Modify By   -Dheeraj Bhatt-EDGE-150372-Moved all the service spec attribute to custom metaDatype to make it configurable
for in future new Product addition for device Replacement. 
--------------------------------------------------------------------------------------------------------*/  
    public static GenerateServiceSpecs generateServiceSpecification(String newServiceId,String newSubscriptionId,shellProductDetailsWrapper shellProduct,Map<String,String>  attributeDataMap,List<csord__Service__c> oldServices){
        String guid= GenerateServiceSpecs.getGuid();//Generate guid
        attributeDataMap.put('MobileHandsetManufacturer',shellProduct.replacementDeviceManufacturer);
        system.debug('MobileHandsetManufacturer=='+shellProduct.replacementDeviceManufacturer);
        system.debug('attributeDataMap MobileHandsetManufacturer=='+attributeDataMap.get('MobileHandsetManufacturer'));
        attributeDataMap.put('MobileHandsetModel',shellProduct.replacementDeviceModel);
        attributeDataMap.put('model',shellProduct.replacementDeviceModel);
        attributeDataMap.put('SKU',shellProduct.replacementDeviceSKU);
        attributeDataMap.put('MobileHandsetColour',shellProduct.replacementDeviceColor);
        attributeDataMap.put('instanceId',guid);
        attributeDataMap.put('guid',guid);
        attributeDataMap.put('subscriptionId',newSubscriptionId);
        attributeDataMap.put('serviceId',newServiceId);
        
        getProductCodeAndServiceSpec(oldServices,attributeDataMap);
        Map<String,String> mapdata = new Map<String,String>();
        List<CS_SpecificationDTO.SimpleAttributes> attributList=new List<CS_SpecificationDTO.SimpleAttributes>();
        for(Service_Specs_Attribute__mdt serviceSpec:mapOfAttributeAndServiceSpec.values()){
            if(serviceSpec.Name__c=='description'){
                string name=  mapOfAttributeAndServiceSpec.containsKey('name')? mapOfAttributeAndServiceSpec.get('name').Value__c:'';
                mapdata.put(serviceSpec.name__c,name + serviceSpec.value__c);
            }
            else{
                mapdata.put(serviceSpec.name__c, serviceSpec.value__c);  
            }
            if(serviceSpec.Product_Attribute__c){
                CS_SpecificationDTO.SimpleAttributes attribute=new CS_SpecificationDTO.SimpleAttributes();
                attribute.name=serviceSpec.Name__c;
                attribute.value= serviceSpec.Value__c;
                attributList.add(attribute);
            }
            
        }
        String serviceSpecsStructure = JSON.serialize(mapdata);
        GenerateServiceSpecs base=new GenerateServiceSpecs();
        base=(GenerateServiceSpecs) JSON.deserialize(serviceSpecsStructure, Type.forName('GenerateServiceSpecs'));
        base.specifications=new list<GenerateServiceSpecs.ServiceSpecificationsStructure>();
        GenerateServiceSpecs.ServiceSpecificationsStructure serSpecs=new GenerateServiceSpecs.ServiceSpecificationsStructure();
        serSpecs= (GenerateServiceSpecs.ServiceSpecificationsStructure) JSON.deserialize(serviceSpecsStructure, Type.forName('GenerateServiceSpecs.ServiceSpecificationsStructure'));
        
        serSpecs.attributes =GenerateServiceSpecs.getAttributes(attributList);
        serSpecs.additionalAttributes = GenerateServiceSpecs.getadditionalAttributes(null);//EDGE-187502
        base.specifications.add(serSpecs);
        return base;
        
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -87057
Method      -createNewAsset
Description -create New Asset for replaced device
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/     
    public static asset createNewAsset(String accountId,shellProductDetailsWrapper shellProduct,Asset oldAsset,csord__Service__c newService){
        Asset newAsset=new Asset();
        newAsset.Name=(shellProduct.replacementDeviceManufacturer !=null? shellProduct.replacementDeviceManufacturer:'')+' '+ shellProduct.replacementDeviceModel+' '+(shellProduct.replacementDeviceColor !=null? shellProduct.replacementDeviceColor:'');
        newAsset.AssetID__c='';
        newAsset.AccountId=accountId;
        newAsset.Subscription__c=newService.csord__Subscription__c;
        newAsset.csordtelcoa__Replaced_Asset__c=oldAsset.id;
        newAsset.Status=Constants.Asset_Status;
        newAsset.csord__Service__c=newService.Id;
        newAsset.Stock_Keeping_Unit__c=shellProduct.replacementDeviceSKU;
        newAsset.OfferID__c=oldAsset.OfferID__c;
        newAsset.ParentId=oldAsset.csordtelcoa__Replaced_Asset__c==null?oldasset.id:oldasset.csordtelcoa__Replaced_Asset__c;//EDGE-150173-Aishwarya yeware-to store the original device id as part of device replacement transaction	
        Insert newAsset; 
        return newAsset;
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -87057,EDGE-122982
Method      -modifyOldServiceSpecsStatus
Description -Modify status of old service specs to 'Modify'
Author      -Dheeraj Bhatt
@change : Changed return type from string to void and attributes added into map,EDGE-122982
@ModifiedBy - Ramesh Somalagari,OSAKA,Manjunath Ediga (EDGE-132532)
--------------------------------------------------------------------------------------------------------*/            
    public static void modifyOldServiceSpecsStatus(set<Id> serviceId,Map<String,String>  attributeDataMap, shellProductDetailsWrapper shellProduct){
        Map<String, CS_SpecificationDTO.ServiceSpecification> specsToBeUpdated = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
        List<Attachment> attachmentListTobeUpdated = new List<Attachment>();
        for(Attachment att:[select ID, name, body, parentId from Attachment where parentId in: serviceId and name Like : '%ServiceSpecifications%']){
            System.debug('Attachment att ' + att);
            String newServiceAttachmentStr = att.body.toString();
            System.debug('Attachment Body ' + newServiceAttachmentStr);
            Map<String, Object> updatedResults = (Map<String, Object>)JSON.deserializeUntyped(newServiceAttachmentStr);
            System.debug('Attachment body Map ' + updatedResults);
            List<Object>lstSpecifications=(List<Object>)updatedResults.get('specifications');
            System.debug('Specifications List ' + lstSpecifications);
            List<Object> newlstSpecifications = new List<Object>();
            System.debug('New Specifications List ' + newlstSpecifications);
            for(Object spec:lstSpecifications){
                Map<String, Object> specificationAttributes = (Map<String, Object>)spec;
                System.debug('Specification Attributes ' + specificationAttributes);
                getValueFromOriginalService(specificationAttributes,attributeDataMap,shellProduct);
                newlstSpecifications.add((Object)specificationAttributes); 
                System.debug('updated New Specification List ' + newlstSpecifications);
            }            
            updatedResults.put('specifications',newlstSpecifications);
            System.debug('Updated Speci ficaton Results ' + updatedResults);
            String updatednewServiceattachmentstr = JSON.serializePretty(updatedResults);
            System.debug('updatednewServiceattachmentstr ' + updatednewServiceattachmentstr);
            att.Body=Blob.valueOf(updatednewServiceattachmentstr);
            System.debug('Final attachment body ' + att.Body);
            attachmentListTobeUpdated.add(att); 
            System.debug('Final attachmentListTobeUpdated ' + attachmentListTobeUpdated);
        }
        if(!attachmentListTobeUpdated.isEmpty())
        {
            update attachmentListTobeUpdated;
        }  
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -132532
Method      -getValueFromOriginalService
Description -Read value of attributes from active service
Author      -Manju
@change     -New method for addressing cyclomatic complexity.
Modify By   -Dheeraj Bhatt-EDGE-150372-Moved all the service spec attribute to custom metaDatype to make it configurable
for in future new Product addition for device Replacement. 
--------------------------------------------------------------------------------------------------------*/      
    public static void getValueFromOriginalService(Map<String, Object> specificationAttributes, Map<String,String>  attributeDataMap, shellProductDetailsWrapper shellProduct) {

        if(!specificationAttributes.IsEmpty() && !mapOfprodutCodeAndServiceSpecs.IsEmpty()  && mapOfprodutCodeAndServiceSpecs.containsKey(specificationAttributes.get('code').toString())){
            List<Service_Specs_Attribute__mdt> serviceSpecList=mapOfprodutCodeAndServiceSpecs.get(specificationAttributes.get('code').toString());
            for(Service_Specs_Attribute__mdt attr:  serviceSpecList){
                system.debug('Reading attributes  ' +  attr.Name__c + attr.Update_Old_Spec__c  + attr.Value_to_Old_Specs__c);
                if(specificationAttributes.containsKey(attr.Name__c) && attr.Update_Old_Spec__c){
                    specificationAttributes.put(attr.Name__c,attr.Value_to_Old_Specs__c);
                    system.debug('Inside Reading attributes  ' +  specificationAttributes.get(attr.Name__c));

                    //modify  the attribute  value in  old serviceSpecs 
                }
                else if(specificationAttributes.containsKey('attributes') && attr.Update_Old_Spec__c){
                    Map<String, Object> specAttributes = (Map<String, Object>)specificationAttributes.get('attributes');
					
                    if(!specAttributes.IsEmpty() && specAttributes.containsKey(attr.Name__c)){
                        specAttributes.put(attr.Name__c,attr.Value_to_Old_Specs__c);//modify  the attribute  value in  old serviceSpecs present in attribute section
                       /* @Author    :  Jayghosh Mishra(Osaka)/Dheeraj
       				    * @Desc     :   Enable Device Replacement on a device that has been transitioned from CMP-L to Digi Mobility Products
				        * @US       :   EDGE-175532/EDGE-194624
      					* */ 
                        if(specificationAttributes.get('code') == 'DMCAT_ProductSpecification_001342_Fulfilment'){
						if(attr.Name__c == 'MobileHandsetManufacturer'){
						 specAttributes.put(attr.Name__c,shellProduct.replacementDeviceManufacturer);
						}else if(attr.Name__c == 'MobileHandsetColour'){
							specAttributes.put(attr.Name__c,shellProduct.replacementDeviceColor);
						}else if(attr.Name__c == 'SKU'){
							specAttributes.put(attr.Name__c,shellProduct.replacementDeviceSKU);
						}else if(attr.Name__c == 'MobileHandsetModel'){
							specAttributes.put(attr.Name__c,shellProduct.replacementDeviceModel);
						}
						}
                       /*-------------------     EDGE-175532/EDGE-194624 --------------------*/
                    }
                }
                
                if(attr.Copy_from_Old_Spec__c && attr.Name__c == 'ReplacedDeviceInstanceId' &&  specificationAttributes.containsKey('guid') ){
                    attributeDataMap.put(attr.Name__c, (String)specificationAttributes.get('guid'));//Copy the guid value from old serviceSpecs to populate in new ServiceSpecs
                }
                else if(attr.Copy_from_Old_Spec__c && attr.Name__c == 'NextGenerationVoiceProductInstanceID' && specificationAttributes.containsKey('additionalAttributes') ){
                    Map<String, Object> specAttributes = (Map<String, Object>)specificationAttributes.get('additionalAttributes');
                    if(!specAttributes.IsEmpty() && specAttributes.containsKey(attr.Name__c)){
                        attributeDataMap.put(attr.Name__c, (String)specAttributes.get(attr.Name__c));//Copy the guid value from old serviceSpecs additionalAttributes section to populate in new ServiceSpecs
                    }
                }
                else  if(specificationAttributes.containsKey('attributes') && attr.Copy_from_Old_Spec__c){
                    Map<String, Object> specAttributes = (Map<String, Object>)specificationAttributes.get('attributes');
                    if(!specAttributes.IsEmpty() && specAttributes.containsKey(attr.Name__c)){
                        attributeDataMap.put(attr.Name__c, (String)specAttributes.get(attr.Name__c));//Copy the guid value from old serviceSpecs attributes section to populate in new ServiceSpecs
                    }
                }
                
                
            }
        }
        
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -EDGE-150372
Method      -getProductCodeFromCustomMetaDataType 
Description -get Product code from  ReverseLogisticsServiceSpec MetaDataType which are 
eligible for device replacement 
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/  
    public static void getProductCodeFromCustomMetaDataType(){
        for(Reverse_Logistics_Service_Spec__mdt productCode:[SELECT label,developername,Value__c,
                                                             (SELECT DeveloperName,label,Name__c,Copy_from_Old_Spec__c,Product_Attribute__c,
                                                              Update_Old_Spec__c,Value__c,
                                                              Value_to_Old_Specs__c FROM Service_Specs_Attributes__r) 
                                                             from Reverse_Logistics_Service_Spec__mdt ]){
                                                                 if(!productCode.Service_Specs_Attributes__r.IsEmpty() && productCode.Service_Specs_Attributes__r != NULL){
                                                                     mapOfprodutCodeAndServiceSpecs.put(productCode.Value__c,productCode.Service_Specs_Attributes__r);    
                                                                 }
                                                             }  
    }
    /*-------------------------------------------------------------------------------------------------------------------------
EDGE        -EDGE-150372
Method      -getProductCodeAndServiceSpec 
Description -get Child specs attribute from ServiceSpecsAttributes custom Metadata for parentcode which is present in Old Service
Author      -Dheeraj Bhatt
----------------------------------------------------------------------------------------------------------------------------*/  
    public static void getProductCodeAndServiceSpec(List<csord__Service__c> oldServices,Map<String,String>  attributeDataMap){
        set<string> productIdSet=new set<string>();
        mapOfAttributeAndServiceSpec=new map<string,Service_Specs_Attribute__mdt>();
        List<Service_Specs_Attribute__mdt> serviceSpecList=new List<Service_Specs_Attribute__mdt>();
        for(csord__Service__c service:oldServices){
            productIdSet.add(service.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c+FULFILMENT);
        }
        for(String str:productIdSet){
            if(!mapOfprodutCodeAndServiceSpecs.isEmpty() && mapOfprodutCodeAndServiceSpecs.containsKey(str)){
                serviceSpecList=mapOfprodutCodeAndServiceSpecs.get(str);
            }
        }
        if(!serviceSpecList.isEmpty()){
            for(Service_Specs_Attribute__mdt serviceSpec:serviceSpecList){
                if( !attributeDataMap.isEmpty() && attributeDataMap.containsKey(serviceSpec.Name__c)){
                    serviceSpec.Value__c=attributeDataMap.get(serviceSpec.Name__c);
                }
                mapOfAttributeAndServiceSpec.put(serviceSpec.Name__c,serviceSpec);      
            }
        }
        
    }
    /*----------------------------------------------------------------------------------------------------
EDGE        -80875
class       -OptionValueWrapperClass
Description -wrapper class for value and option for customMetaDataType 
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    public Class OptionValueWrapperClass{
        @AuraEnabled public string option;
        @AuraEnabled public string value;
    } 
    /*----------------------------------------------------------------------------------------------------
EDGE        -80869
class       -shellProductDetailsWrapper
Description -wrapper class for shell details entered by users in UI  
Author      -Dheeraj Bhatt
--------------------------------------------------------------------------------------------------------*/
    public class shellProductDetailsWrapper{
        Public String replacedDeviceID;
        Public String replacementDeviceSKU;
        Public String replacementDeviceManufacturer;
        Public String replacementDeviceModel;
        Public String replacementDeviceColor;
        Public String telstraNowCaseID;
        Public String recoveryMethod;
        Public String deviceCareCaseID;
        Public String returnReason;
    }
}