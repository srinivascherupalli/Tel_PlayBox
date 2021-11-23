/*
===============================================================================================================================
Class : SimReplacementController
Developer Name : Shubhi
Test Class : SimReplacementControllerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia  21/3/2019     Edge-53882 MAC page for Sim Replacement for Assurance service agen Profile  
2.        Shubhi Vijayvergia  21/3/2019     Edge-53883 Order Submission for Sim Replacement for Assurance service agen Profile  
3.        Mladen Badrov       26/4/2019     EDGE-78305 SIM replacement Name and Scenario Type change
4.        shubhi vijayvergia  29/4/2019     EDGE-53883/82202  Issues Related to SIM replacement order
5.        Laxmi Rahate        09/10/2019    EDGE-113351 Added condition to make shipping req flag false in case of Mobile device and device
6.        Gnana               29/7/2020     EDGE-154370 - Updated Forecasted_Delivery_Date__c, Telstra_Committed_Date__c of Service's records to NULL
                                            to resolve an incident-INC000092634429
7.        Ankit Goswami       31/08/2020    EDGE-165020/EDGE-168784 added SIM_Type__c in query
8.        Ankit Goswami       22/09/2020    EDGE-167254 add verifySIMSerial method
9.        Raviteja            28/09/2020    INC000093944951 - Billing Spec to get updated in System mode-PRM user has access issues
10.       Ankit Goswami       06/10/2020    EDGE-169091 changes in verifySIMSerial method
11.      Gnana           27/10/2020  EDGE-185450 - ChangeType changes for SimReplacement Scenario
12.       swapna              27/11/2020    EDGE-182667 - Updated Submission Date with Current time
13.       Shweta              11/1/2020     EDGE-185521 - Enhance non commercial order flow to redirect user to order details page after submission
14.       Shubhi V            15/03/2021    EDGE-208607
15.       Vaibhav             11/06/2021    EDGE-223085
16.       Shashidhar Kumar    26/08/2021    DIGI-14511
17.  Vamsi Krishna Vaddipalli 26OCT2021     DIGI-17911  SimReplacement transctionlogger splunk
===============================================================================================================================*/
public with sharing class SimReplacementController{
    private static final String OPPORTUNITY_REC_TYPE = 'Enterprise - In Contract';
    private static final String OPPORTUNITY_STAGE = 'Develop';
    private static final String OPPORTUNITY_TYPE_MAC = 'MACs (Moves, Adds & Change)';
    private static final String OPPORTUNITY_TYPE_DISCONNECT = 'Disconnect';
    private static final String OPPORTUNITY_PRODUCT_TYPE = 'Modular';
    private static final String OPPORTUNITY_PRIMARY_DOMAIN = 'Other';
    private static final String OPPORTUNITY_IN_CONTRACT = 'Yes';
    private static final String CHANGE_TYPE_MODIFY = 'Modify';
    private static final String CHANGE_TYPE_CANCEL = 'Cancel';    
    private static final String BASKET_CHANGE_TYPE = 'Upgrade';
    private static final String BASKET_CHANGE_STAGE = 'Commercial Configuration';
    private static final String REPLACE_SIM = 'Replace SIM';
    private static final String SIMPLEX = 'Simplex';
    private static final String DMCAT_420= 'DMCAT_ProductSpecification_000420';
    private static final String DMCAT_263='DMCAT_ProductSpecification_000263';
    private static final String DMCAT_263_FULFILL='DMCAT_ProductSpecification_000263_Fulfilment';
    // Sr no 5 - 
    private static final String DMCAT_423_FULFILL='DMCAT_ProductSpecification_000423_Fulfilment';
     private static final String DMCAT_1196_FULFILL='DMCAT_ProductSpecification_001196_Fulfilment'; //EDGE-168784 added by ankit

    private static final String STATUS = 'status';
    private static final String MODIFIED = 'Modified';
    //to refer account details inlightning component
    @AuraEnabled
    public static Account acc { get; set; }
    //private static final string  ERROR_MESSAGE = 'Error Message From Apex: ';
    @AuraEnabled
    public static String errorMsg { get; set; }
    @AuraEnabled //Sr 1. to fetch account details
    public static Account getAccountDetails(String accountId) {
        Account acc=new Account();
        if (accountId != '') {
            acc = [SELECT id, name FROM Account WHERE Id = :accountId];
        }
        
        return acc;
    }
    @AuraEnabled ///Sr.1 new method to display selected subscription on sim replacement page
    public static List<SubWrapper> getSimReplacementsubscription(List<String> subscriptionIdList) {
        //System.debug('subscriptionIdList===>'+subscriptionIdList);
        map<string, map<string, string>> numberMap = new Map<string, map<string, string>>(); //EDGE-165020 added by ankit

        Map<string,string>numberNewSIMMap=new Map<string,string>();//EDGE-174221 Check SIMAvaliabilty Type
        List <csord__Subscription__c > subList = [
            SELECT
                id,
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
                Name,
                serviceMSISDN__c,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name,
            csordtelcoa__Product_Configuration__r.id,
            MarketableOffer__r.Name
            FROM csord__Subscription__c
            WHERE ID IN: subscriptionIdList
        ];
        numberMap=simTypeOnNumber(subList);//EDGE-165020 added by ankit

       // numberNewSIMMap = SimAvailabilityTypeOnNumber(subList); //EDGE-174221 Check SimAvailabilityType value on Number
       system.debug('numberMap::::'+numberMap);

        List < Subwrapper > subwrapList = new List < SubWrapper > ();
        List<String> args = new List<String>{ '0', 'number', '###,###,##0.00' };
                    for (csord__Subscription__c su: subList) {
                        SubWrapper suw = new SubWrapper();
                        suw.SubscriptionID = su.id;
                        suw.subscriptionName = su.Name;
                        suw.status = su.csord__Status__c;
                        suw.ServiceId = su.serviceMSISDN__c;
                        suw.subscriptionNumber = su.csordtelcoa__Subscription_Number__c;
                        suw.SimDispatchedRequired = false;
                        suw.isValidSIM = true;// EDGE-165020
                        suw.DeliveryContact = '';
                        suw.DeliveryContactID = '';
                        suw.DeliveryAddress = '';
                        suw.DeliveryAddressID = '';
                        suw.SimSerialNumber = '';
                        suw.IsDeliveryDetailsDisabled=true;
                        suw.IsSimSerialNumber=false;
                        //EDGE-165020 added by ankit ||strat
                         //system.debug('NumberList:::'+NumberMap.containsKey(su.csordtelcoa__Product_Configuration__r.id));
                        if(numberMap.containsKey(su.csordtelcoa__Product_Configuration__r.id)){
                         suw.ExistingSIMType=numberMap.get(su.csordtelcoa__Product_Configuration__r.id).get('SIMType');
                        }
                        suw.RequestedSIMType='';
                        suw.ProductOffer=su.MarketableOffer__r.Name;
                        //EDGE-165020 added by ankit ||End
                        
                        //EDGE-174221 start
                        if(numberMap.containsKey(su.csordtelcoa__Product_Configuration__r.id)){
                         suw.SimAvailabilityType=numberMap.get(su.csordtelcoa__Product_Configuration__r.id).get('SimAvailabilityType');
                        }
                        //EDGE-174221 End

                        //suw.disableSIMSerialNumber='NoCss';
                        subwrapList.add(suw);                    
                    }
        //system.debug('**subwrapList**'+subwrapList);
        return subwrapList;
    }
    @AuraEnabled //Sr.1 new method for removing subscription from sim replacement page
    public static List < SubWrapper > deleteSubscription(List<Subwrapper> subscriptionList , String subscriptionId){
        List<SubWrapper> finalsublist=new List<SubWrapper>();
        for(SubWrapper suw:subscriptionList){
            if(suw.subscriptionId!=subscriptionId){
                finalsublist.add(suw);
            }
        }
        
        return finalsublist;    
    }
    @AuraEnabled //Sr2. method for creating orders on submit order button
    public static String createOrder(List<Subwrapper> subwrapperList, ID accountId, String tNowCaseRef,String SelectReplacereason){  
        //System.debug('subwrapperList==>'+subwrapperList+'accountId==>'+accountId);  
        String ordName =
            'SIM Replacement_' +
            ('0' + String.valueOf(Date.today().day())).right(2) +
            ('0' + String.valueOf(Date.today().month())).right(2) +
            Date.today().year() +
            '_' +
            String.valueOf(System.now().time()).left(8);
        string result='';
        
        Map<String,Subwrapper> subWrapperToIdMap= new Map<String,Subwrapper>();
        for(Subwrapper subw:subwrapperList){
            subWrapperToIdMap.put(subw.subscriptionId,subw);
        }
        //System.debug('subWrapperToIdMap==>'+subWrapperToIdMap);
        //List<csord__Order__c> SimReplacementOrders=new List<csord__Order__c>();
        
        if (!subWrapperToIdMap.keyset().IsEmpty()) {
            //selected subscription
            List<csord__Subscription__c> subscriptionList = [
                SELECT id, name, csord__Status__c, csord__Order__c, csord__Order__r.csord__Order_Number__c, csordtelcoa__Product_Configuration__r.id,csordtelcoa__Subscription_Number__c,orderversion__c//EDGE-168784 added by ankit
                FROM csord__Subscription__c
                WHERE id IN :subWrapperToIdMap.keyset()
            ];
            //System.debug('subscriptionList===>'+subscriptionList);
            //services
            List<csord__Service__c> serviceList = [
                SELECT
                    id, name,
                    csord__Status__c,
                    csord__Order__c,
                    Delivery_Address__c,
                    Site_Delivery_Contact__c,
                    Sim_Serial_Number__c,
                    csord__Subscription__c,
                    Scenario_Type__c,
                    csord__Service__c 
                FROM csord__Service__c
                WHERE csord__Subscription__c IN :subWrapperToIdMap.keyset()
            ];
            //System.debug('serviceList==>'+serviceList);
            
            //checking already order on selected subscription
            for(csord__Subscription__c subs:subscriptionList){
                if (subs.csord__Status__c != 'Active') {
                    // checking for existing orders on subscription
                    result='error';
                    return result;
                }           
            }
            try {
                //Order request
                csord__Order_Request__c orderRequest=new csord__Order_Request__c();
                orderRequest.csord__Process_Status__c='Requested';
                orderRequest.csord__Request_DateTime__c=Datetime.now();
                orderRequest.csord__Module_Name__c='CS Order Implementation Module Telco A';
                orderRequest.csord__Module_Version__c='1.0';            
                insert orderRequest;
                //Primary order
                csord__Order__c primaryOrder=new csord__Order__c();
                primaryOrder.csord__Account__c=accountId;
                primaryOrder.recordTypeId =Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Order Submitted').getRecordTypeId();
                primaryOrder.csord__Status2__c='Order Submitted';
                primaryOrder.csord__Order_Type__c='Order';
                primaryOrder.csord__Identification__c='Order_123';
                primaryOrder.csord__Start_Date__c=Date.today();
                primaryOrder.telstra_ord_Start_DateTime__c=System.now();//EDGE-182667
                primaryOrder.csord__Product_Type__c='';
                primaryOrder.Name=ordName;
                // primaryOrder.Scenario_Type__c=System.label.ReplaceSIM;//'Replace SIM'; ////added System.label.ReplaceSIM for bug EDGE-89345
                primaryOrder.csord__Order_Request__c=orderRequest.id; 
                primaryOrder.OwnerId=UserInfo.getUserId();
                //added Project_Complexity__c and PM_Required__c for EDGE-91568
                primaryOrder.Project_Complexity__c=SIMPLEX;
                primaryOrder.PM_Required__c=false;
                primaryOrder.Replacement_Reason__c=SelectReplacereason;
                primaryOrder.Fulfilment_Order_Version__c = 1;
                if(tNowCaseRef != '' && tNowCaseRef != null && tNowCaseRef != 'undefined'){
                    primaryOrder.referencenumber__c = tNowCaseRef.toUpperCase();//EDGE-132715
                }                
                insert primaryOrder;
                
                List<CS_SpecificationDTO.ServiceSpecification> srvspecList = new List<CS_SpecificationDTO.ServiceSpecification> ();
                if (primaryOrder.id != null) {
                    Map<id,csord__Service__c> serviceMap=new Map<id,csord__Service__c>();
                    //update subscription
                    for(csord__Subscription__c subs:subscriptionList){
                        subs.csord__Order__c=primaryOrder.id;
                        
                        subs.csord__Status__c='Pending';
                        subs.orderversion__c = primaryOrder.Fulfilment_Order_Version__c; //added as part of EDGE-223085
                        //subs.Primary_Order__c=primaryOrder.id;
                    }
                    List<csord__Service__c> serviceListNew=clearSelectedServiceDetails(serviceList);
                    //update services
                    for(csord__Service__c serv:serviceListNew){
                        csord__Subscription__c subs = new csord__Subscription__c();
                        // Update Status modify for service spec attchment
                        //Start : EDGE-114523
                        //get all the service spec attachments for services
                        srvspecList=ServiceSpecificationUtils.getAllServSpecsByServId(serv.id, 'FULFILMENT');
                        //System.debug('srvspecList==>'+srvspecList);
                        for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecList){
                            /*if(srvSpec.code.contains(DMCAT_420)){
                                csedm.API_1.updateServiceSpecificationPropertyById(srvSpec.serviceId,srvSpec.guid,STATUS,MODIFIED);
                            }*/
                        }
                        //End : EDGE-114523
                        serv.csord__Order__c=primaryOrder.id;
                        
                        serv.csord__Status__c='Pending';
                        
                        //EDGE-93748 qa2 bug
                        //parent service                   
                        if(serv.csord__Service__c == null ){   
                            serv.Scenario_Type__c = REPLACE_SIM;
                            /* Added as part of EDGE-185450 - Start */
                            serv.changeType__c = REPLACE_SIM;
                            subs = new csord__Subscription__c(Id=serv.csord__Subscription__c, changeType__c = REPLACE_SIM);
                            subscriptionList.add(subs);
                            /* Added as part of EDGE-185450 - End */
                        }else{
							serv.changeType__c = CHANGE_TYPE_MODIFY;//DIGI-14511
						}
                        
                        if (orderRequest.id != null) {
                            serv.csord__Order_Request__c=orderRequest.id;
                            //serv.Delivery_Address__c=null; commented as part of 168784 and call clearSelectedServiceDetails for null
                            //serv.Site_Delivery_Contact__c=null; commented as part of 168784 and call clearSelectedServiceDetails for null
                        }
                        serv.Sim_Serial_Number__c=subWrapperToIdMap.get(serv.csord__Subscription__c).SimSerialNumber;
                        if(serv.Sim_Serial_Number__c==null || serv.Sim_Serial_Number__c==''){
                            serv.Delivery_Address__c=subWrapperToIdMap.get(serv.csord__Subscription__c).DeliveryAddressID;
                            serv.Site_Delivery_Contact__c=subWrapperToIdMap.get(serv.csord__Subscription__c).DeliveryContactID;
                        }
                        // Need to update value for Scenerio type which should be from sevice object
                        
                        //serv.Telstra_Committed_Date__c = null; // Added as part of EDGE-154370 commented as part of 168784 and call clearSelectedServiceDetails for null
                        //serv.Forecasted_Delivery_Date__c = null; // Added as part of EDGE-154370 commented as part of 168784 and call clearSelectedServiceDetails for null
                        serviceMap.put(serv.id,serv);
                    }
                    
                    /* Added as part of EDGE-185450 - Start*/
                    map<Id,sObject> mapOfSubs = new Map<Id,sObject>();
                    mapOfSubs = mergeCollections(subscriptionList,mapOfSubs);
                    //update subscriptionList; // Commented as part of EDGE-185450
                    update mapOfSubs.values();
                    /* Added as part of EDGE-185450 - End*/
                    update serviceListNew; 
                   
                    /* Commented part of INC000093944951

                    ServiceSpecificationUtils.updateServiceSpecAttachment(DMCAT_263_FULFILL,serviceMap,subWrapperToIdMap);
                    //Added another method call to resolve the shipping required flag goign true for Mobile Device and device
                    ServiceSpecificationUtils.updateServiceSpecAttachment(DMCAT_423_FULFILL,serviceMap,subWrapperToIdMap);
                    //EDGE-168784 added by ankit ||start
                    ServiceSpecificationUtils.updateServiceSpecAttachment(DMCAT_1196_FULFILL,serviceMap,subWrapperToIdMap);
                    */
                     
                   // adedd part of INC000093944951 to run in System mode

                     SimReplaceServiceSpecUtils.updateServiceSpecAttachment(DMCAT_263_FULFILL,serviceMap,subWrapperToIdMap);
                    //Added another method call to resolve the shipping required flag goign true for Mobile Device and device
                    SimReplaceServiceSpecUtils.updateServiceSpecAttachment(DMCAT_423_FULFILL,serviceMap,subWrapperToIdMap);
                    //EDGE-168784 added by ankit ||start
                    SimReplaceServiceSpecUtils.updateServiceSpecAttachment(DMCAT_1196_FULFILL,serviceMap,subWrapperToIdMap);
                 
                    if (!mapOfSubs.values().isEmpty()) {
                        // Modified as part of EDGE-185450
                        updateNumberSimType(mapOfSubs.values(),subWrapperToIdMap);
                    }
                    //EDGE-168784 added by ankit ||End
                    
                    //}    
                }            
                primaryOrder = [SELECT id, csord__Order_Number__c FROM csord__Order__c WHERE id = :primaryOrder.id];
                //result=primaryOrder.csord__Order_Number__c;
                // Shweta added primaryOrder.id EDGE-185521
                result = primaryOrder.csord__Order_Number__c + ',' + primaryOrder.id;
                if(primaryOrder!=null && primaryOrder.csord__Order_Number__c!=null){
                    SubmitOrderOrchestration.createOrderOrchestrationProcess(primaryOrder.id); // orchestration initiation
                }
                 System.debug('result ' + result);
                return result;
               
            } catch (Exception e) {
                return('Exception' + e);
            }
        }
        return('Exception');
    }
    @AuraEnabled //EDGE-165020 added by ankit || start
    public static void updateNumberSimType( List<csord__Subscription__c>subscriptionList,Map<String,Subwrapper> subWrapperToIdMap){ 
            Map<string,Map<string,string>>subNumberMapToUpdate=new Map<string,Map<string,string>>();
            Map<string,string>subNumberMap=new Map<string,string>();

        list<Number__c> numberList = new List<Number__c>();
            if(!subscriptionList.isEmpty()){
                for(csord__Subscription__c sub:subscriptionList){
                    if(subWrapperToIdMap.containsKey(sub.id)){
                        subNumberMap.put('SIMType',subWrapperToIdMap.get(sub.id).RequestedSIMType);
                        subNumberMap.put('SimAvailabilityType',subWrapperToIdMap.get(sub.id).SimAvailabilityType);
                        subNumberMapToUpdate.put(sub.csordtelcoa__Subscription_Number__c,subNumberMap);    //EDGE-208607
                    }   
                }
                if(subNumberMapToUpdate != null && !subNumberMapToUpdate.isEmpty()){
                for (Number__c num : [
                    SELECT id, Product_Configuration__c, SimAvailabilityType__c, SIM_Type__c,Subscription_number__c
                    FROM Number__c
                    WHERE  Subscription_number__c IN :subNumberMapToUpdate.keyset() And Status__c='Active' ] ) { //// EDGE-208607

                        num.SimAvailabilityType__c=subNumberMapToUpdate.get(num.Subscription_number__c).get('SimAvailabilityType');
                        num.SIM_Type__c=subNumberMapToUpdate.get(num.Subscription_number__c).get('SIMType');

                        numberList.add(num);
                    }
                }
            }
          
            if(!numberList.isEmpty()){
                update numberList;
            }
            
        //EDGE-165020 added by ankit || end
    } 
    //EDGE-168784 - add clearSelectedServiceDetails by ankit
    @AuraEnabled 
    public static List<csord__Service__c> clearSelectedServiceDetails(List<csord__Service__c>serviceList){
       for(csord__Service__c serv:serviceList){
                serv.Telstra_Committed_Date__c = null; 
                serv.Forecasted_Delivery_Date__c = null;
                serv.Delivery_Address__c=null;
                serv.Site_Delivery_Contact__c=null;
       }
       
       return serviceList;
    }
     //EDGE-165020 added by ankit || start
    @AuraEnabled 
    public static Map<string,map<string,string>> simTypeOnNumber(List<csord__Subscription__c>subList){
        List<Number__c> numberList = new List<Number__c>();
        List<string>subNumberList=new List<string>();
        Map<string,map<string,string>>numberMapUpdate=new Map<string,map<string,string>>();
        
        if(!subList.isEmpty()){
            for(csord__Subscription__c sub:subList){
                subNumberList.add(sub.csordtelcoa__Product_Configuration__r.id);
            }
            if(!subNumberList.isEmpty())
                numberList = [SELECT id, Product_Configuration__c, SimAvailabilityType__c, SIM_Type__c FROM Number__c WHERE Product_Configuration__c IN :subNumberList];
        }
        if(!numberList.isEmpty()){
            for(Number__c num : numberList){
                map<string,string>numberMap=new Map<string,string>();
                numberMap.put('SIMType',num.SIM_Type__c);
                numberMap.put('SimAvailabilityType',num.SimAvailabilityType__c); //added as part of EDGE-174221  
                numberMapUpdate.put(num.Product_Configuration__c,numberMap);
            }
        }
        return numberMapUpdate;
    }
      //EDGE-165020 added by ankit || end
      
    //EDGE-167254/EDGE-169091 added by ankit || start
    @AuraEnabled 
    public static List<SubWrapper> verifySIMSerial(List<Subwrapper>verifySIMSerialList){
        Map<String,Map<String,String>> returnResponse=new Map<String,Map<String,String>>();
        List<Subwrapper>StatusResponse = new List < SubWrapper > ();
        List<string>names=new List<string>();
        Map<String,String> simSerialSImtypeMap=new Map<String,String>();
        string isSim=System.Label.isSimvalid;
        for(Subwrapper subw : verifySIMSerialList){
           simSerialSImtypeMap.put(subw.SimSerialNumber,subw.RequestedSIMType);
        }
        if(simSerialSImtypeMap !=null && !simSerialSImtypeMap.isEmpty()){
            returnResponse=ValidateSIMInterface.ValidateSimSerial(simSerialSImtypeMap,false,false,names);
        }
        if(returnResponse !=null && !returnResponse.isEmpty()){
            StatusResponse=verifySIMSerialResponse(returnResponse,verifySIMSerialList);
        }
        return StatusResponse;
    }
     //EDGE-167254/EDGE-169091 added by ankit || start
     
    // EDGE-169091 added by ankit || start
    public static List<SubWrapper> verifySIMSerialResponse(Map<String,Map<String,String>> returnResponse,List<Subwrapper>verifySIMSerialList){
        List <Subwrapper> StatusResponse = new List < SubWrapper > ();
            system.debug('returnResponse:::'+returnResponse);
            for(Subwrapper subw : verifySIMSerialList){
                if(returnResponse.containsKey('LRM Success')){
                if (
                    returnResponse.get('LRM Success').containsKey(subw.SimSerialNumber) && returnResponse.get('LRM Success').get(subw.SimSerialNumber).equalsIgnoreCase('AVAILABLE')
                ) {
                        subw.responseStausMsg=returnResponse.get('LRM Success').get(subw.SimSerialNumber).toUpperCase();
                        subw.isValidSIM=true;
                    }else{
                        subw.responseStausMsg=returnResponse.get('LRM Success').get(subw.SimSerialNumber);
                        subw.isValidSIM=false;
                    }
                }else {
                   subw.responseStausMsg=returnResponse.get('LRM Failure').values()[0];
                   subw.isValidSIM=false;
               }
               StatusResponse.add(subw);
            }
        
        return StatusResponse;
    }
    //EDGE-169091 added by ankit || end  
    
    //  Added as part of EDGE-185450
    public static Map<Id, sObject> mergeCollections(List<sobject> sourceList, map<Id, sObject> destinationMap) {
        List<String > sobjectTypeList = new List<String>();
        Map<String, List<String>> editableFieldPerObjMap = new Map<String, List<String>>();
        Map<Id,String> recIdToObjNameMap = new Map<Id,String>();
        for (sObject rec : sourceList) {
            String sobjectName = String.valueOf(rec.id.getsobjecttype());
            if (!sobjectTypeList.contains(sobjectName)) {
                sobjectTypeList.add(sobjectName);
            }
            recIdToObjNameMap.put(rec.Id,sobjectName);
        }
        if (!sobjectTypeList.isEmpty()) {
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(sobjectTypeList);
            for (Schema.DescribeSobjectResult res : results) {
                String objectName = res.getName();
                Map<String,Schema.SObjectField> mfields = res.fields.getMap();
                List<String> editableFieldList = new List<String>();
                for(String fieldName : mfields.keySet()) {
                    if(mfields.get(fieldName).getDescribe().isUpdateable()) {
                        editableFieldList.add(fieldName.toUpperCase());
                    }
                }
                editableFieldPerObjMap.put(objectName,editableFieldList);
            }
        }
        for (sObject rec : sourceList) {
            if (destinationMap.containsKey(rec.id)) {
                Map<String, Object> recFieldToMap = rec.getPopulatedFieldsAsMap();
                Map<String, Object> retFieldToMap = destinationMap.get(rec.id).getPopulatedFieldsAsMap();
                for (string fieldName : recFieldToMap.keyset()) {
                    if (!retFieldToMap.containsKey(fieldName) && editableFieldPerObjMap.get(recIdToObjNameMap.get(rec.Id)).contains(fieldName.toUpperCase())) {
                        destinationMap.get(rec.id).put(fieldName, recFieldToMap.get(fieldName));
                    }
                }
            } else {
                destinationMap.put(rec.Id,rec);
            }
        }
        return destinationMap;
    }

    /*  
    * Method Name : simReplacementTransactionlogs
    * Owner : Vamsi Krishna Vaddipalli
    * Jira : DIGI-17911
   */
    @AuraEnabled
    public static void simReplacementTransactionlogs(String accountId,String orderId,String datetimeinmillisec)
    {
        Map<String,Object> loggerdetailsMap=new Map<String,Object>();
        string correlationId = accountId+'-SIMREP'+datetimeinmillisec;
        String orderType = 'Sim Replacement';
        if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','beforelogsinsertion'))
        {
            if(String.isNotBlank(accountId) && String.isBlank(orderId))
            {
                String event = 'Order generation initiated';
                
                loggerdetailsMap.put('event',event);
                loggerdetailsMap.put('OrderType',orderType);
                TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'SimReplacementController');
            }
        }
        
        if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','afterlogsinsertion'))
        {
            if(String.isNotBlank(orderId))
            {
                String event = 'Order generation completed';
                
                loggerdetailsMap.put('event',event);
                loggerdetailsMap.put('OrderType',orderType);
                loggerdetailsMap.put('OrderId',orderId);
                TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'SimReplacementController');
            }
        }
        
        
    }
}