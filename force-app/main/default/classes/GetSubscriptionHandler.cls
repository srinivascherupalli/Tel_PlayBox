/*
===============================================================================================================================
Class : GetSubscriptionHandler 
Developer Name :
Test Class : GetSubscriptionHandlerTest
=========================================================================================================================================
Sr.No.  Developer         Date          Story Description
1.      Pradeep             02/May/2018    EDGE-66609  - Enabled getsubscription API, "MSISDN” as input in request 
and provide following information in the response payload
2.     Jannath              16/Oct/2019    EDGE-92058  - Enabled getsubscription APi,"MSISDN”, NetworkServiceId__c as input in request and 
provide following information in the response payload
3.     Dheeraj Bhatt        08-June-2020   EDGE-149915 -Modify GetSubscriptionDetails API to support duplicate number/subscription records
4.     Dheeraj Bhatt        04-Aug-2020    EDGE-162161 -Enhance Get Subscription API by exposing old device id for replacement device 
                                             subscription to support device replacement orders
5.     Dheeraj Bhatt        25-Aug-2020    EDGE-165567/EDGE-168274 -Enhance Inv MS - Get Subscription API to provide scenario type for new/cancel orders and Commercial orders
6.     Venkat T             23-Feb-2021    EDGE-200008-Notify Inventory Microservice on the Nickname changes and provide nickname details
7.	   Akanksha Jain		15-Apr-2021	   EDGE-200291 added changes in subscription query to exclude chown replaced status
8.     Gnana				14-May-2021	   EDGE-214615 - Implemented Error Logging for Exceptions (Added try catch block)
9.     Sayantan             05-Aug-2021    DIGI-10299 - Enabled TON Baring of MS
10.     Aarathi              05-Aug-2021    DIGI 4642 TNOW to query using CFS ID - Change done by Team Radium
11.    Arun Selvan          10-Aug-2021    DIGI-1409/DIGI-9672 - Added GUID Tag for Mobile Numbers not for Fixed Numbers
===========================================================================================================================================

*/

public with sharing class GetSubscriptionHandler {
    public static List<csord__Subscription__c> subscriptionList;
    public static List<csord__Subscription__c> solutionSubscriptionList;
    public static List<csord__Service__c> serviceList;
    public static List<number__c> numberList;
    public static map<id,list<Asset>> subscriptionAssetMap;//EDGE-162161-Dheeraj Bhatt-Map of subscription and its related assets
    public static map<id,list<csord__Service__c>> subscriptionServicesMap;
    public static map<id,csord__Subscription__c> solutionSubscriptionMap;
    public static map<id,List<number__c>> subscriptionNumberMap;
    public static Boolean SubscriptionDetailsAsArrayApi=false;
    public static set<string>subscriptionIdSet=new set<string>();  
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');   
    public Static map<string,id> subscriptionNumberIdMap=new map<string,id>();
    private static final String CONST_INTERFACENAME = 'GetSubscriptionHandler';

    public static String validateRequest(String correlationID){
        set<string> subscriptionNumberSet=new set<string>();
        try{
            if(correlationID!= null ){
                getSubscriptionRelatedServicesAndNumbers(correlationID);//Check correlationID has existing subscriptions or services or FNN Numbers.
                if(!subscriptionList.isEmpty()){
                    for(csord__Subscription__c subs:subscriptionList){
                        if(!subscriptionNumberIdMap.containsKey(subs.csordtelcoa__Subscription_Number__c)){
                            subscriptionNumberIdMap.put(subs.csordtelcoa__Subscription_Number__c, subs.id);
                        }
                    }
                }
                
                else if(!serviceList.isEmpty()){
                    for(csord__Service__c service:serviceList){
                        if(!subscriptionNumberIdMap.containsKey(service.csord__Subscription__r.csordtelcoa__Subscription_Number__c)){
                            subscriptionNumberIdMap.put(service.csord__Subscription__r.csordtelcoa__Subscription_Number__c, service.csord__Subscription__c);
                        } 
                    }
                }
                else if(!numberList.isEmpty()){
                    for(number__c num:numberList){
                        subscriptionNumberSet.add(num.Subscription_number__c);
                    } 
                    if(!subscriptionNumberSet.isEmpty()){
                        for(csord__Subscription__c subs:[SELECT id,csordtelcoa__Subscription_Number__c,Nickname__c     
                                                         FROM csord__Subscription__c WHERE csordtelcoa__Subscription_Number__c IN :subscriptionNumberSet]){   // EDGE-200008 Added Nickname__c 
                                                             if(!subscriptionNumberIdMap.containsKey(subs.csordtelcoa__Subscription_Number__c)){
                                                                 subscriptionNumberIdMap.put(subs.csordtelcoa__Subscription_Number__c, subs.id);
                                                             }
                                                         }
                    }
                }
                if(!subscriptionNumberIdMap.IsEmpty()){
                    for(String subsId:subscriptionNumberIdMap.values()){
                        subscriptionIdSet.add(subsId);
                    }
                    return 'Valid';
                }
                else{
                    return 'Invalid';
                }
            }
            else{
                return 'Invalid';
            }
            
        }catch(Exception e){
            logException('validateRequest', '', '', e.getMessage(), 'Exception occured while validating request');
            return 'Invalid';
        }
    }
 /*****************************************************************************************
EDGE        - 149915
Method      - generateResponse
Description - Generate response by passing  subsciption and  its related service,number,solution subscription and asset.
Author      - Dheeraj Bhatt
**********************************************************************************/
    public static RestResponse generateResponse(RestResponse res,String correlationID){
        String subscriptionID = '';
        String responseBody='';
        List<csord__Service__c> mapServiceList=new List<csord__Service__c>();
        List<number__c> mapNumberList=new List<number__c>();
        List<Asset> mapAssetList=new List<Asset>();//EDGE-162161-Dheeraj Bhatt-fetch related assets of each subscription.
        csord__Subscription__c solutionSubscription=new  csord__Subscription__c();
        List<SubscriptionDetailsResponse>SubscriptionDetailsResponseList=new List<SubscriptionDetailsResponse>();
        SubscriptionResponseAsArray  subscriptionListAsResponse=new SubscriptionResponseAsArray();
        try{
            
            if(validateRequest(correlationID)=='Valid'){
                getSubscriptionRelatedServicesAndNumbers(correlationID);
                //EDGE-149915 -Dheeraj Bhatt-Modify GetSubscriptionDetails API to support duplicate number/subscription records
                if(SubscriptionDetailsAsArrayApi){
                    for(csord__Subscription__c subs:subscriptionList){
                        if(!subscriptionServicesMap.isEmpty() && subscriptionServicesMap.containsKey(subs.Id)){
                            mapServiceList= subscriptionServicesMap.get(subs.Id);
                        }
                        if( !subscriptionNumberMap.isEmpty() && subscriptionNumberMap.containsKey(subs.Id)){
                            mapNumberList=subscriptionNumberMap.get(subs.Id);
                        }
                        if(!solutionSubscriptionMap.isEmpty() && solutionSubscriptionMap.containsKey(subs.csord__Order__c)){
                            solutionSubscription=solutionSubscriptionMap.get(subs.csord__Order__c);
                        }
                       // EDGE-162161
                        if( !subscriptionAssetMap.isEmpty() && subscriptionAssetMap.containsKey(subs.Id)){
                            mapAssetList=subscriptionAssetMap.get(subs.Id);
                        }
                        SubscriptionDetailsResponse dtoResponse = GetSubscriptionHelper.findServiceSpec(correlationID,subs,mapServiceList,mapNumberList,solutionSubscription,mapAssetList);
                        SubscriptionDetailsResponseList.add(dtoResponse);
                    }
                    subscriptionListAsResponse.subscriptions=SubscriptionDetailsResponseList;
                    responseBody = (JSON.serialize(subscriptionListAsResponse,true)).replace('_Fulfilment','').replace('_Assurance','').replace('_New Value','');
                    
                }
                //EDGE-149915 -Dheeraj Bhatt-For fetching single subscription as a part of getSubscriptionApi Interface v1
                else{
                    if(!subscriptionServicesMap.isEmpty() && subscriptionServicesMap.containsKey(subscriptionList[0].Id)){
                        mapServiceList= subscriptionServicesMap.get(subscriptionList[0].Id);
                    }
                    if( !subscriptionNumberMap.isEmpty() && subscriptionNumberMap.containsKey(subscriptionList[0].Id)){
                        mapNumberList=subscriptionNumberMap.get(subscriptionList[0].Id);
                    }
                    if(!solutionSubscriptionMap.isEmpty() && solutionSubscriptionMap.containsKey(subscriptionList[0].csord__Order__c)){
                        solutionSubscription=solutionSubscriptionMap.get(subscriptionList[0].csord__Order__c);
                    }
                    // EDGE-162161
                    if( !subscriptionAssetMap.isEmpty() && subscriptionAssetMap.containsKey(subscriptionList[0].Id)){
                            mapAssetList=subscriptionAssetMap.get(subscriptionList[0].Id);
                        }
                    SubscriptionDetailsResponse dto = GetSubscriptionHelper.findServiceSpec(correlationID, subscriptionList[0],mapServiceList,mapNumberList,solutionSubscription,mapAssetList);
                    responseBody = (JSON.serialize(dto,true)).replace('_Fulfilment','').replace('_Assurance','').replace('_New Value','');
                    
                }
                res.statusCode = 200;
                String resBody = responseBody.replace('FULFILMENT','ASSURANCE');
                resBody = responseBody.replace('SOMOpenAir','ASSURANCE'); // EDGE-116372
                System.debug('res:::'+resBody);
                res.responseBody = Blob.valueOf(resBody);
                res.addHeader('Content-Type','application/json');
                
                
            }
            if(validateRequest(correlationID)=='Invalid'){
                res.statusCode = 404;
                SubscriptionDetailsResponse edto = GetSubscriptionHelper.findErrorSpec404(correlationID);
                responseBody = (JSON.serialize(edto));
                System.debug('res:::'+responseBody);
                res.responseBody = Blob.valueOf(JSON.serialize(edto,true));
                res.addHeader('Content-Type','application/json');
            }
            
            
        }
        catch(Exception e){
            System.debug('Exception...'+e.getMessage());
            logException('generateResponse', '', '', e.getMessage(), 'Exception occured while generating response');
            if(Test.isRunningTest()){
                res = new RestResponse();
            }
            res.statusCode = 500;
            SubscriptionDetailsResponse errdto = GetSubscriptionHelper.findErrorSpec502(correlationID);
            responseBody = (JSON.serialize(errdto));
            System.debug('res:::'+responseBody);
            res.responseBody = Blob.valueOf(JSON.serialize(errdto,true));
            res.addHeader('Content-Type','application/json');
            
        }
        return res;  
        
    }
    /*****************************************************************************************
EDGE        - 149915
Method      - generateResponseForArray
Description - to support duplicate number/subscription records for subscriptionApi v2
Author      - Dheeraj Bhatt
**********************************************************************************/
    public static RestResponse generateResponseForArray(RestResponse response,String correlationID){
        SubscriptionDetailsAsArrayApi=true;
        generateResponse(response,correlationID);
        return response;
    }
    /***********************************************************************************************************
EDGE        - 149915
Method      - getSubscriptionRelatedServicesAndNumbers
Description - Check correlationID is Valid or not. If correlationID is Valid then Fetch subscription, services 
and numbers for that correlationID 
Author      - Dheeraj Bhatt
**************************************************************************************************************/
    public static void getSubscriptionRelatedServicesAndNumbers(String correlationID){
        set<string> subscriptionNumberSet=new set<string>();
        subscriptionList=new List<csord__Subscription__c>();
        solutionSubscriptionList=new List<csord__Subscription__c>();
        serviceList=new List<csord__Service__c>();
        List<csord__Service__c> servList;
        numberList=new List<number__c>();
        List<Asset> tempAssetList;
        List<number__c> subscriptionNumberList;
        subscriptionServicesMap=new map<id,list<csord__Service__c>>();
        subscriptionNumberMap=new map<id,list<number__c>>();
        solutionSubscriptionMap= new map<id,csord__Subscription__c>();
        subscriptionAssetMap=new map<id,List<Asset>>();
        set<Id> orderIdSet=new set<Id>();
        set<Id> solutionAssociationIdSet=new set<Id>();//TC-34576-Dheeraj Bhatt-Solution Association Id to get Solution Subscription 
        try{
        String SolutionComponent=customMetadataNameValueMap.containsKey('SolutionComponent')? String.valueOf(customMetadataNameValueMap.get('SolutionComponent').get('Value__c')):'';
        String fixed=customMetadataNameValueMap.containsKey('Fixed')?String.valueOf(customMetadataNameValueMap.get('Fixed').get('Value__c')):'';
		String Mobile = 'Mobile';
		String Pattern_Type = 'Number';
        //DPG-4574 Added Suspension_reason_summary__c
        //DIGI-10299 Added TON_Barring_Status__c
        String subscriptionQuery='SELECT id,name,Suspension_reason__c,Suspension_reason_summary__c,MarketableOffer__c,MarketableOffer__r.Offer_ID__c,'+
            'csord__Account__c,csord__Account__r.Customer_ID__c,serviceMSISDN__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,'+
            'csord__Account__r.CIDN__c,Billing_Account__r.Billing_Account_Number__c,cssdm__solution_association__c,'+ 
            'Parent_Subscription__r.name,csordtelcoa__Subscription_Number__c,Right_to_Bill_Date__c,csord__Status__c,'+ 
            'csord__Order__r.csord__Start_Date__c,csord__Order__r.CreatedDate,csord__Order__r.csord__End_Date__c,'+
            'csord__Order__c, Contract_Term__c,Serviceability_Location__c,Contract_Start_Date__c,'+
            'Offer__r.Offer_Spec_Id__c,Site__r.name,Site__r.AdborID__c,'+
            'csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,'+
            'csord__Order__r.csordtelcoa__Opportunity__c,csord__Order__r.csord__Primary_Order__c,'+ 
            'Product_Model_Version__c, modelChange__c,Device_Replacement_DMCAT_Id__c,Nickname__c,TON_Barring_Status__c FROM csord__Subscription__c WHERE ' ;      // EDGE-200008 Added Nickname__c 
        
        //To check correlationID passed as Subscription Number has any subscriptions.
        // DIGI 4642 TNOW to query using CFS ID - Change done by Team Radium
        if(String.isNotBlank(correlationID) && subscriptionIdSet.IsEmpty()){
            subscriptionQuery+= '( csordtelcoa__Subscription_Number__c = \'' + correlationID + '\' OR customerFacingServiceId__c = \'' + correlationID + '\' OR serviceMSISDN__c =\''+ correlationID + '\' ) AND csord__Status__c NOT IN('+Label.TerminalSubStatuses+') order by CreatedDate desc';//EDGE-200291
        }
        
        else if(!subscriptionIdSet.IsEmpty()){
            subscriptionQuery+=' Id In: subscriptionIdSet order by CreatedDate desc';
        }
        subscriptionList=Database.query(subscriptionQuery);
        if(!subscriptionIdSet.IsEmpty()){
            for(csord__Subscription__c sub:subscriptionList){
                subscriptionNumberSet.add(sub.csordtelcoa__Subscription_Number__c);
                orderIdSet.add(sub.csord__Order__c);
                solutionAssociationIdSet.add(sub.cssdm__solution_association__c); //TC-34576-Dheeraj Bhatt-Solution Association Id to fetch Solution Subscription.
            }
        }
        
        string serviceQuery = 'SELECT Id,ProductSpecCode__c,csord__Subscription__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c, Name,csord__Status__c,csordtelcoa__Service_Number__c,'+
            'csord__Order__c,NetworkServiceId__c, csord__Order__r.csordtelcoa__Opportunity__c,serviceMSISDN__c,'+
            'Product_Model_Version__c,modelChange__c,International_Direct_Dial__c,Mobility_Plan__c, Plan__c,Scenario_Type__c '+
            'FROM  csord__Service__c WHERE ';
        
        //To check correlationID passed as serviceMSISDN or NetworkServiceId has any services in the system.
        // DIGI 4642 TNOW to query using CFS ID - Change done by Team Radium
        if (String.isNotBlank(correlationID) && subscriptionIdSet.IsEmpty()){
            serviceQuery += ' serviceMSISDN__c = \''+correlationID+'\' OR csord__Subscription__r.customerFacingServiceId__c = \''+correlationID+'\' OR NetworkServiceId__c =\''+ correlationID + '\'  order by CreatedDate desc';  
        }
        else {
            serviceQuery += ' csord__Subscription__r.csordtelcoa__Subscription_Number__c IN: subscriptionNumberSet ';  
        }
        
        serviceList=Database.query(serviceQuery);
        
        String serviceNumberQuery='SELECT id,Service_Id__c,Service_Number__c,Status__c,is_Part_of_Range__c,Start_Range__c,End_range__c, Subscription_number__c,Mobile__c,External_Id__c,Pattern_Type__c From Number__c  WHERE ';
        
        //To check correlationID passed as FNN  has any Numbers in the system.
        if(String.isNotBlank(correlationID) && subscriptionIdSet.IsEmpty()){
            serviceNumberQuery+= ' Service_Number__c =\''+correlationID+'\' AND Subscription_number__c != NULL ';
        }
        else{
            serviceNumberQuery+='Subscription_number__c IN : subscriptionNumberSet AND ( Mobile__c =\''+Fixed+'\' OR (Mobile__c= \''+Mobile+'\' AND Number_Group__r.Pattern_Type__c=\''+Pattern_Type+'\'))'; //  DIGI-1409/DIGI-9672
        }
        numberList=Database.query(serviceNumberQuery);
        if (!subscriptionIdSet.IsEmpty()){
            // EDGE-162161-Dheeraj Bhatt-Fetch all the asset related to subscription
         List<asset> assetList=   [SELECT Id,Subscription__c, Subscription__r.csordtelcoa__Subscription_Number__c,
                                  csordtelcoa__Replaced_Asset__r.AssetID__c,csordtelcoa__Replaced_Asset__r.Name FROM Asset 
                                  WHERE Subscription__r.csordtelcoa__Subscription_Number__c IN :subscriptionNumberSet AND csordtelcoa__Replaced_Asset__c!=NULL LIMIT 1];
            // created a map of Subscription and its related services.
            for(csord__Subscription__c sub:subscriptionList){
                servList=new List<csord__Service__c>();
                for(csord__Service__c service:serviceList){
                    if(sub.Id == service.csord__Subscription__c){
                        servList.add(service);
                        subscriptionServicesMap.put(sub.Id , servList);
                    }
                }
                // created a map of Subscription and its related serviceMSISDN numbers. 
                subscriptionNumberList=new List<number__c>();
                for(number__c num:numberList){
                    if(sub.csordtelcoa__Subscription_Number__c == num.Subscription_number__c){
                        subscriptionNumberList.add(num);
                        subscriptionNumberMap.put(sub.id,subscriptionNumberList);
                    } 
                }
                // EDGE-162161-Create a map of subscription and its related subscription
                tempAssetList= new List<Asset>();
                for( Asset asst :assetList){
                    if(asst.Subscription__c == sub.Id){
                    tempAssetList.add(asst);
                    subscriptionAssetMap.put(sub.Id,tempAssetList);
                    }
                    
                }
            }
            
            // fetch Solution Component Subscription from Order and map it against order.
            for(csord__Subscription__c solutionSubscription : [SELECT id,csord__Order__c,MarketableOffer__r.name,csord__Subscription__c.Parent_Subscription__r.name,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
                                                               csordtelcoa__Subscription_Number__c,cssdm__solution_association__c,Nickname__c  from csord__Subscription__c 
                                                               where csord__Order__c IN:orderIdSet AND
                                                               csordtelcoa__Product_Configuration__r.ConfigurationType1__c =:SolutionComponent 
                                                               AND cssdm__solution_association__c IN :solutionAssociationIdSet
                                                               order by CreatedDate desc]){     // EDGE-200008 Added Nickname__c 
                                                                   solutionSubscriptionMap.put(solutionSubscription.csord__Order__c,solutionSubscription);   
                                                               }

        }
        }catch(Exception e){
            logException('getSubscriptionRelatedServicesAndNumbers', '', '', e.getMessage(), 'Exception occured while querying related Services and Numbers for Subscriptions');
        }
    } 
        
    /*** @description Exception Handling Framework */
    //Created as part of EDGE-214615
    private static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    } 
}