/*
===============================================================================================================================
Class : GetSubscriptionHelper
Test Class : GetSubscriptionHelperTest
===============================================================================================================================
Sr.No.  Developer Name      Date          Story Description
1.      Shubhi Vijayvergia  21/3/2018     Edge-53883 Order Submission for Sim Replacement made changes
for removing refrences to opprtunity instead to Primary order
2.      Pradeep             02/May/2018    EDGE-66609 - Added mapping to new fields - MSISDN,CIDN,billingAccountNumber,
mobileServiceindicator,serviceStatus                                    
3.      Shubhi            09/30/2019        //Edge-O98904

4.      Vaibhav            19/11/2019      EDGE-98384 Impact on Inventory MS (R2R) to support suspend and resume TID services
5.      Shreya             22/11/2019      EDGE-117980 added calling Plans to R2R payload
6.      Vaibhav Deshpande   17/12/2019      INC000091511257  - R2R null check prod. Fix
7.      Vaibhav Deshpande   20/12/2019      EDGE-98388     Changed logic to populate fixed numbers from number object
8.      Manish Jha                          Prod incident fix
9.      Vaibhav Deshpande   12/03/2020      EDGE-140203 fix
10.     Dheeraj Bhatt       08/06/2020      EDGE-149915-Moved all SOQL from findServiceSpec method to GetSubscriptionHandler Class
and Changed findServiceSpec Method Parameters.
11.     Dheeraj Bhatt        04-Aug-2020    EDGE-162161 -Enhance Get Subscription API by exposing old device id for replacement device 
                                            subscription to support device replacement orders
12.     Dheeraj Bhatt        25-Aug-2020    EDGE-165567/EDGE-168274 -Enhance Inv MS - Get Subscription API to provide scenario type for new/cancel orders and Commercial orders
13.     Venkat T             17-Feb-2021    EDGE-200008-Notify Inventory Microservice on the Nickname changes and provide nickname details
14.   Gnana         14-May-2021  EDGE-214615 - Implemented Error Logging for Exceptions (Added try catch block)
15      Sayantan             05-Aug-2021    DIGI-10299 - Added mapping for tonBarringStatus
16      Arun Selvan          010-Aug-2021     DIGI-9672 - Added GUID Tag for Mobile Numbers not for Fixed Numbers
=====================================================================================================================================
*/
public with sharing class GetSubscriptionHelper {
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');   // EDGE-162161 -Dheeraj Bhatt-Get Static Asset Name from custom MetaData
        
        //  EDGE-7414
        
        public class ListingFNNWrapper {
            public String fnn {get;set;}
            public String range {get;set;}
        }
        
        //EDGE-98388 created DTO class for maintaing number object values
        public class Numbers {   
            public String numbers {get;set;}
            public String isPartofRange {get;set;}
            public String startRange {get;set;}
            public String endRange {get;set;}
            public String status {get;set;}
            public String GUID {get;set;} // DIGI-9672
        }
        
        private static final String CONST_INTERFACENAME = 'GetSubscriptionHelper';
        
        public static SubscriptionDetailsResponse findServiceSpec(String correlationID,csord__Subscription__c subs, List<csord__Service__c> serviceList,List<number__c> numberList,csord__Subscription__c solutionsub,List<asset> assetList){
            List<CS_SpecificationDTO.ServiceSpecification> allsrvpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
            String ucNumData='';
            List<Object> ucNumbers= new List<Object>();
            String solutionSubNumber='';//EDGE-99311
            List<Numbers> ucNumbersList= new List<Numbers>();
            String active = Label.subscription_Active_status;
            String activeArchived = Label.subscription_Active_Archived;
            String suspended=Label.subscription_Suspended_Status;
            String nums='';    //EDGE-98388 Start
            String numsFormat='';
            String numsFormats='';
            String numsFormatFinal='';//EDGE-98388 End
            //changed query to add marketable offer EDGE-91570
            //*******************************EDGE-98388 Start*****************************************************  
            Numbers numDto=new Numbers();
            Numbers numDto1=new Numbers();
            String numStr='number';
            List<Numbers> numDtoList=new List<Numbers>();          
            SubscriptionDetailsResponse sdr = new SubscriptionDetailsResponse();
            try{
            for(Number__c num:numberList)
            { 
                numDto=new Numbers();//added as part of EDGE-140203 - reinitializing DTO
                numDto.numbers=(String)num.Service_Number__c;
                if(num.is_Part_of_Range__c==true)
                { 
                    numDto.isPartofRange='Y';
                }else if(num.is_Part_of_Range__c==false)
                {
                    numDto.isPartofRange='N';
                }
                if(num.Mobile__c=='Mobile' && num.Pattern_Type__c == 'Number')  // Added as part of DIGI-9672
               { 
                numDto.GUID=num.External_Id__c;
               }
                
                numDto.startRange=num.Start_Range__c;
                numDto.endRange=num.End_range__c;
                numDto.status=num.Status__c;
                numDtoList.add(numDto);
            }
            for(integer i=0;i<numDtoList.size();i++)
            {
                if(i == 0){
                    ucNumbers.add(numDtoList[i]);
                }
                if (i > 0){
                    ucNumbers.add(numDtoList[i]);
                }
            }
            
            //*******************************EDGE-98388 End*****************************************************
            
            
                
            SubscriptionDetailsResponse.DataDTO datadto = new SubscriptionDetailsResponse.DataDTO();       
            SubscriptionDetailsResponse.ServiceSpecifications srviceSpecObj;
            SubscriptionDetailsResponse.ServiceList service;
            SubscriptionDetailsResponse.assetList aset;
            List<SubscriptionDetailsResponse.ServiceSpecifications> srviceSpecObjList;
            List<SubscriptionDetailsResponse.ServiceList> AllServiceList = new List<SubscriptionDetailsResponse.ServiceList>();
            List<SubscriptionDetailsResponse.assetList> allAssetList = new List<SubscriptionDetailsResponse.assetList>();   
            boolean isSuspension = false;
            
            datadto.correlationID = correlationID;
            if(subs.Site__r.AdborID__c!=null){
                datadto.adborID=subs.Site__r.AdborID__c;
            }
            datadto.customerID=subs.csord__Account__r.Customer_ID__c;
            datadto.MSISDN =subs.serviceMSISDN__c;
            datadto.CIDN=subs.csord__Account__r.CIDN__c;
            datadto.mobileServiceIndicator='Postpaid'; 
            datadto.billingAccountNumber =subs.Billing_Account__r.Billing_Account_Number__c;
            datadto.name=subs.name;
            datadto.nickName=subs.Nickname__c;   //EDGE-200008
            datadto.subscriptionId=subs.id;
            datadto.subscriptionNumber=subs.csordtelcoa__Subscription_Number__c;
            datadto.solutionSubscriptionNumber=solutionsub!=null?solutionsub.csordtelcoa__Subscription_Number__c:null;
            datadto.offerName=solutionsub!=null?solutionsub.MarketableOffer__r.name:null;//EDGE-149912-Dheeraj Bhatt-Modify existing GetSubscriptionDetails API to include "Parent subscription name".
            datadto.tonBarringStatus=subs.TON_Barring_Status__c;//DIGI-10299 Populating tonBarringStatus
            if(subs.Suspension_reason__c!=null){
                isSuspension = true;
                //commented below line for DIGI-13335 fix- Mahima
                //datadto.status ='Suspended';
            }
            //commented else for DIGI-13335 fix- Mahima
            //else
            datadto.status=subs.csord__Status__c;
            datadto.subscriptionVersion= subs.Product_Model_Version__c;
            datadto.modelChange= String.valueOf(subs.modelChange__c);
            datadto.suspensionReason=subs.Suspension_reason__c; //EDGE-98384 added suspension reason
            datadto.suspensionReasonSummary=subs.Suspension_reason_summary__c; //DPG-4574
            
            if(subs.csord__Order__r.CreatedDate!=null)
            { 
                datadto.orderCreationDate=subs.csord__Order__r.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ssXXX')+'';
            }
            Date d = subs.csord__Order__r.csord__Start_Date__c;
            
            if(d!=null){
                Datetime dt = datetime.newInstance(d.year(), d.month(),d.day());
                datadto.orderSubmissionDate=dt.format('yyyy-MM-dd\'T\'HH:mm:ssXXX')+'';
            }
            if(subs.MarketableOffer__r.Offer_ID__c!=null){datadto.offerId = subs.MarketableOffer__r.Offer_ID__c;}
            if(subs.Contract_Term__c!=null){
                datadto.contractTerm = subs.Contract_Term__c;}
            if(subs.Serviceability_Location__c!=null){
                datadto.serviceabilityLocation =subs.Serviceability_Location__c;}
            if(subs.Contract_Start_Date__c!=null){
                Date dd = subs.Contract_Start_Date__c;
                Datetime dtd = datetime.newInstance(dd.year(), dd.month(),dd.day());
                datadto.contractStartDate=String.valueOf(dtd.format('yyyy-MM-dd\'T\'HH:mm:ssXXX'));
            }
            if(subs.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c != null ){
                datadto.subscriptionCode = subs.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
            }
            else {
                datadto.subscriptionCode=subs.Device_Replacement_DMCAT_Id__c;//EDGE-150362-Abinash-populate device replacement offer id in the "subscriptionCode" attribute for replacement Device.
            }
            
            
            datadto.transactionID=IntegrationRecordHandlerUtil.getUUID();
            datadto.transactionTime=Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX')+'';
            // EDGE-162161 -Dheeraj Bhatt-Add replace device Id and device name in Asset Attribute in reponse 
            for(Asset asst:assetList){
                aset = new SubscriptionDetailsResponse.assetList();
                aset.name=customMetadataNameValueMap.containsKey('replacedDevice')?String.valueOf(customMetadataNameValueMap.get('replacedDevice').get('Value__c')):'';
                aset.value=asst.csordtelcoa__Replaced_Asset__r.AssetID__c;
                allAssetList.add(aset);
            }
            for(csord__Service__c serv : serviceList){
                service = new SubscriptionDetailsResponse.ServiceList();
                srviceSpecObjList = new List<SubscriptionDetailsResponse.ServiceSpecifications>();
                
                service.serviceId = serv.Id;
                service.scenarioType=serv.Scenario_Type__c;// EDGE-165567/EDGE-168274-Dheeraj Bhatt
                service.serviceNumber = serv.csordtelcoa__Service_Number__c;
                service.serviceName = serv.Name;
                service.serviceStatus =serv.csord__Status__c;
                service.serviceVersion=serv.Product_Model_Version__c;
                service.modelChange=String.valueOf(serv.modelChange__c);
                service.code =serv.ProductSpecCode__c; //DIGI-24735/Gururaj Shetty
                List<CS_SpecificationDTO.ServiceSpecification> srvAssuranceSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serv.Id),'ASSURANCE');
                List<CS_SpecificationDTO.ServiceSpecification> srvTechnicalSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serv.Id),'SOMOpenAir'); //EDGE-116372
                List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serv.Id),'FULFILMENT');
                
                if(srvAssuranceSpecList!=null && srvAssuranceSpecList.size()>0 && srvSpecList!= null){
                    srvSpecList.addAll(srvAssuranceSpecList);    
                }
                if(srvTechnicalSpecList !=null && !srvTechnicalSpecList.isEmpty() && srvSpecList!= null){ //EDGE-116372
                    srvSpecList.addAll(srvTechnicalSpecList);    
                }            
                
                for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvSpecList){
                    
                    List<SubscriptionDetailsResponse.Attributes> attributeList = new List<SubscriptionDetailsResponse.Attributes>();
                    SubscriptionDetailsResponse.Attributes attribute;
                    srviceSpecObj = new SubscriptionDetailsResponse.ServiceSpecifications();
                    srviceSpecObj.version = serv.Product_Model_Version__c; //EDGE-117694
                    srviceSpecObj.status = srvSpec.status;
                    if (srviceSpecObj.status != 'Connected' && serv.modelChange__c == true)           
                        srviceSpecObj.modelChange=String.valueOf(serv.modelChange__c);
                    else
                        srviceSpecObj.modelChange= 'false';
                    srviceSpecObj.startDate = srvSpec.startDate;
                    srviceSpecObj.specExternalID = serv.csordtelcoa__Service_Number__c+':'+srvSpec.guid;
                    if(srvSpec.productConfigurationId!=null){ //INC000091511257 - R2R null check Fix
                        srviceSpecObj.productConfigurationId = srvSpec.productConfigurationId;}
                    srviceSpecObj.name = srvSpec.description.substringBeforeLast('_');
                    srviceSpecObj.serviceId = serv.Id;       
                    srviceSpecObj.guid = srvSpec.guid;
                    srviceSpecObj.endDate = srvSpec.endDate;
                    srviceSpecObj.description = srvSpec.description;
                    srviceSpecObj.code = srvSpec.code;
                    Map<String,String> attrMap = new Map<String,String>();
                    String repStr;
                    String repStrNew;
                    //EDGE-117980 adding plan to the attribute block of payload
                    attrMap.put('callingPlans',serv.Plan__c);//EDGE-117980
                    attrMap.put('internationalDirectDial',serv.International_Direct_Dial__c);//EDGE-99311
                    attrMap.put('mobilityPlan',serv.Mobility_Plan__c);//EDGE-99311
                    for(CS_SpecificationDTO.SimpleAttributes attrsimple :srvSpec.simpleAttributes)
                    {
                        attrMap.put(attrsimple.name,attrsimple.value);
                        if(attrsimple.name =='SuspensionContext'){  //added SuspensionContext instead context
                            if(isSuspension == true){
                                datadto.status=suspended;
                                datadto.suspensionContext=attrsimple.value;
                                
                            }
                            
                        }
                    }
                    
                    
                    for(CS_SpecificationDTO.SimpleAttributes attrsimple :srvSpec.additionalAttributes){
                        attrMap.put(attrsimple.name,attrsimple.value);
                    }
                    
                    repStr=JSON.serialize(numDtoList,true);
                    repStrNew=repStr.replace('numbers','number');
                    attrMap.put('numbers',repStrNew);  //EDGE-98388
                    for(String attr : attrMap.keySet())
                    {
                        attribute = new SubscriptionDetailsResponse.Attributes();
                        attribute.Name = attr;
                        if(attribute.Name == 'numbers'){
                            attribute.value= JSON.deserializeUntyped(attrMap.get(attr));
                        }else{
                            attribute.value= attrMap.get(attr);
                        }
                        attributeList.add(attribute);
                    }
                    srviceSpecObj.attributes = attributeList;
                    srviceSpecObjList.add(srviceSpecObj);
                }
                service.specifications = srviceSpecObjList;
                AllServiceList.add(service);    
            }
            datadto.asset=allAssetList; //EDGE-162161
            datadto.services = AllServiceList;
            sdr.data = datadto;
            }
            catch(Exception e){
                logException('findServiceSpec', '', '', e.getMessage(), 'Exception occured while finding ServiceSpec');
            }
            return sdr;
        }
        
         //EDGE- 165567-Dheeraj Bhatt- Commenting Below Method as  in present we are not going to use it  but in future it can be  used for input validation error
      /*  public static SubscriptionDetailsResponse findErrorSpec(String correlationID){
            SubscriptionDetailsResponse sdr = new SubscriptionDetailsResponse();
            List<SubscriptionDetailsResponse.error> errorbad = new List<SubscriptionDetailsResponse.error>();
            SubscriptionDetailsResponse.DataDTO datadto = new SubscriptionDetailsResponse.DataDTO();
            SubscriptionDetailsResponse.error err = new SubscriptionDetailsResponse.Error();
            err.status='Bad Request';
            err.code ='400';
            err.message='Missing or invalid parameters';
            err.correlationID=correlationID;
            errorbad.add(err);
            datadto.error =  errorbad;
            sdr.data = datadto;
            
            return sdr;
        } */
      public static SubscriptionDetailsResponse findErrorSpec502(String correlationID){
            SubscriptionDetailsResponse sdr = new SubscriptionDetailsResponse();
            List<SubscriptionDetailsResponse.error> errorbad = new List<SubscriptionDetailsResponse.error>();
            SubscriptionDetailsResponse.DataDTO datadto = new SubscriptionDetailsResponse.DataDTO();
            SubscriptionDetailsResponse.error err = new SubscriptionDetailsResponse.Error();
            err.status='Internal Error';
            err.code ='502';
            err.message='Error while processing information';
            err.correlationID=correlationID;
            errorbad.add(err);
            datadto.error =  errorbad;
            sdr.data = datadto;
            return sdr;
        }
     /***********************************************************************************************************
    EDGE        - 165567
    Method      - findErrorSpec404
    Description - Configuring of 404 failure response support scenario of number not found in salesforce.
    Author      - Dheeraj Bhatt
    **************************************************************************************************************/
         public static SubscriptionDetailsResponse findErrorSpec404(String correlationID){
            SubscriptionDetailsResponse sdr = new SubscriptionDetailsResponse();
            List<SubscriptionDetailsResponse.error> errorbad = new List<SubscriptionDetailsResponse.error>();
            SubscriptionDetailsResponse.DataDTO datadto = new SubscriptionDetailsResponse.DataDTO();
            SubscriptionDetailsResponse.error err = new SubscriptionDetailsResponse.Error();
            err.status='Not Found';
            err.code ='404';
            err.message='Record not Found';
            err.correlationID=correlationID;
            errorbad.add(err);
            datadto.error =  errorbad;
            sdr.data = datadto;
            
            return sdr;
        }
        
        /*===============Error Logging Framework=============== */ 
        // Created as part of EDGE-214615
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