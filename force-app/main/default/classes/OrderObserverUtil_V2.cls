/*************************************************************************************************************************************************
Developer: Kunal Dixit
Description: April 03,2019
changes for EDGE-76805
to see all changes made kindly refer Development Tab in Jira
History: 03-04-2019
Prajakta Patil
Class Name: OrderObserverUtil_V2
Test Class: OrderObserverManager_Test_v2
=====================================================================================================================================================
ChangeSet       No      Name            Date            Description
EDGE-82599      1       Vijayalakshmi   30-May-2019     Added method filterNotRequiredSpecificationsForIpSite
EDGE-88787      2       Rohit T         18-Jul-2019     Removing all changes related to story 81575
Edge-98904      3       Shubhi          24-Jul-2019     Solution Console Integrity for Contract & COM
EDGE-107845     4       Rohit T         25-Sep-2019     During order creation, CS should create fulfilment, charge, assurance and allowance specifications based on chosen product configurations
EDGE-105060     5       Aman Soni       6-Oct-2019      Introduce Cancel for Internet Site || Reason_for_cancellation__c updated as a part of TID cancellation journey 
INC000092318431 6       Rohit Tripathi  17-Mar-2020     Fixing issue for MACD basket without Changing any Subscription in MACD Basket
EDGE-145854     7       Manish Jha      27-04-2020      Added Transition fix
EDGE-148009     8       ROhit Tripathi  12-05-2020      NGUC_Modify_Subscriptions not triggered to newly added device as the Billing account is empty
EDGE-149261     9       Sandip Deshmane 19-05-2020      Commented some code and Added SIMSerialNumber and Shipping Request for BYO plan only.
EDGE-154773     10      Prajakta        10/06/2020      Number which is unreserved from basket is not going in RTB payload and even status is not getting updated correctly
EDGE-136968     11      Pawan Devaliya  11-June-2020    Maintain relationship b/w NGVoice subs and BT subs. & Update NetworkServiceId on subscription.
&EDGE-136271
&EDGE-136271
EDGE-142085     12      Shubhi/Aman     20-05-2020      Mapped Billing_Account__c(Service) to Billing_Account__c(Subscription)
EDGE-148371     13      Purushottam     03-06-2020      Set the Partner Account in Subscription
EDGE-148819     14      Pawan/Vaibhav   16-07-2020      To set AutoExpiry filed on subscription
EDGE-165552     15      Gnana           26-08-2020      Added additional Product Spec "DMCAT_ProductSpecification_001196_Fulfilment" to populate CustomerFacingServiceId 
EDGE-172953     16      Pooja /Payal    03/09/2020       Custom Code Refactoring - Order Observer apex class refactoing to handle large basket processing
EDGE-174924     17      Gnana           14-10-2020      Added logic to update changeType__c of Service and Subscription
EDGE-184856     18      Gnana           19-10-2020      Modified logic to update changeType__c based on ScenarioType
EDGE-174220     19      Pawan           13/10/2020      Added condition for 'Existing Blank SIM'
EDGE-170949     20      Dheeraj         22/10/2020      Capture Service Level Preference for all voice and voice + data plans as SMS and service MSISDN 
&170948
EDGE-181982     21      Vaibhav         02/11/2020      added changes for non commercial order
EDGE-186610     22      Laxmi           30/11/2020      Enable new Scenario Type - Reactivate
EDGE-186885     23    Dheeraj Bhatt     16/12/2020      Enabling of new Scenario Type for Migration Orders
INC000095020812 24    Payal Popat       12/02/2020      Uncommenting code to populate partnerAccount
DPG-3906        25    Lalit/Vitap       06/02/2021      Created custom metadata to store the fulfillment Code
EDGE-207018     27    Dheeraj Bhatt     03/03/2021      Scenario Type should be set as Migration for Adaptive Care for Migration Type Opportunity
EDGE-200291    28    Akanksha Jain      04/03/2021      Added changes for CHOWN Out Order
EDGE-202433    29    Akanksha Jain      12/03/2021      Added changes to set service change type and scenario type for No fault return
EDGE-201613     30   Vamsi Krishna      15MAR2021       Added changes to set International_Direct_Dial__c from addOnCharge__r.addOn_Name__c for EM Calling and Messaging PD
EDGE-199912    31    Aman Soni          25/03/2021      Added changes to retain Nickname__c in MAC order from the new order subscriptions
EDGE-214688     32   Dheeraj Bhatt      15/04/2021  To populate the Scenario type for HRO devices of Migration Order
EDGE-216816     33  Prajakta patil      30/06/2021     To update asset records for chown orders
DPG-5900 & 		34	Dharmik Shah		29/07/2021		Number Reservation for Shared Data Plans 
DIGI-1003												In Partial Cancel, Salesforce fetching new MSISDN from UNMS.
EDGE-216816-Revert35 Prajakta patil    25/08/2021     removed updation of assetfrom here and moved to chwon pre-requsite orch
DIGI-38789/DIGI-39435   Ritika Gupta        16/11/2021      Excluding Ted-81 Orders from Oppty check
***************************************************************************************************************************************************/
 
public with sharing class OrderObserverUtil_V2 {
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');//EDGE-186885-Dheeraj Bhatt- Get the constant value from metadata
       
        /*Method Name: outputMapBasketFieldsToOrderFields
        * Purpose : populates Basket fields from Basket and Subscription Object
        * params : orderMap, BasketMap,SubscriptionMap
        * Return Type : void
        * Called from : OrderObserverHelper
        */
        
        public static Map<Id, csord__Order__c> outputMapBasketFieldsToOrderFields(Map<Id, csord__Order__c> orderMap, Map<Id, cscfga__Product_Basket__c> basketMap, Map<Id, Id> orderIdToBasketIdMap,Map<String,List<Basket_To_Order_Field_Map__c>> objBasketMap){
            Map<Id,csord__Order__c> ordersToUpdateList= new Map<Id,csord__Order__c>();
            /*if(!(fieldsToUpdateSize > 0)){
                return orderMap;
            }*/
            for(Id orderId: orderIdToBasketIdMap.keyset()){
                csord__Order__c orderInstance= new csord__Order__c();
                orderInstance = orderMap.get(orderId) ;
                Id basketId = orderIdToBasketIdMap.get(orderId);
                if(objBasketMap.containsKey('cscfga__Product_Basket__c'+'csord__Order__c')){
                    List<Basket_To_Order_Field_Map__c> basketToOrderFieldList = objBasketMap.get('cscfga__Product_Basket__c'+'csord__Order__c');
                    for(Integer i=0; i < basketToOrderFieldList.size(); i++){
                        //orderInstance.put(basketToOrderFieldList[i].Target_Field_Api_Name__c,basketMap.get(basketId).get(basketToOrderFieldList[i].Source_Field_Api_Name__c));
                        Object fieldVal = getFieldValue((Sobject) basketMap.get(basketId),basketToOrderFieldList[i].Source_Field_Api_Name__c);
                        if(fieldVal != null){
                        orderInstance.put(basketToOrderFieldList[i].Target_Field_Api_Name__c,fieldVal);
                        }
                    }                
                }
                ordersToUpdateList.put(orderInstance.Id,orderInstance);
            }
            return ordersToUpdateList;  
        }
        /*Method Name:populateNumberFields
        * Purpose : populates Number fields from Service Object
        * params : ServiceMap, NumberMap
        * Return Type : updated NumberMap
        * Called from : OrderObserverHelper
        * Disclamer :
        */
        public static Map<Id,Number__c> populateNumberFields(Map<Id, csord__Service__c> serviceMap, Map<Id,Number__c> numberMap){
            map<Id,String> pcWithServiceId = new map<Id,String>();
            Map<String,String>mapservnumTobecancel = new Map<String,String>();
            Map<String,String> mapSerNumToBasketType = new Map<String,String>();//EDGE-200291
            system.debug('numberMap72'+numberMap);
            system.debug('serviceMap73'+serviceMap);
            for (csord__Service__c servObj : serviceMap.values()){
                pcWithServiceId.put(servObj.csordtelcoa__Product_Configuration__c,servObj.csordtelcoa__Service_Number__c);
                mapservnumTobecancel.put(servObj.csordtelcoa__Service_Number__c,servObj.toBeCancelled__c); //EDGE-154773
                mapSerNumToBasketType.put(servObj.csordtelcoa__Service_Number__c,servObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c); //EDGE-200291
            }
             system.debug('pcWithServiceId78'+pcWithServiceId);
             system.debug('mapservnumTobecancel79'+mapservnumTobecancel);
            for(Number__c num : numberMap.values()){
                 system.debug('num81'+num);
                String bFlag = mapservnumTobecancel.get(num.Service_Id__c); // changed field from Service_number__c to Service_Id__c
                String ordBaskType =mapSerNumToBasketType.get(num.Service_Id__c);// EDGE-200291
                 system.debug('bFlag83'+bFlag);
                if(!pcWithServiceId.isEmpty() && pcWithServiceId.containsKey(num.Product_Configuration__c)){
                num.Service_Id__c = pcWithServiceId.get(num.Product_Configuration__c);
                }
                if(num.Status__c == 'Disconnect Pending'){
                        num.toBeCancelled__c = true;
                    }
                
                 if (bFlag == 'true') //EDge-182853
                 {
                         num.Status__c ='Disconnect Pending'; //EDGE-175339
                         num.toBeCancelled__c = true;
                 }
                if (ordBaskType!= null && ordBaskType.equalsIgnoreCase('Outgoing')) //EDGE-200291
                 {
                         num.Status__c ='CHOWN Replaced'; //EDGE-200291
                         
                 }
                    numberMap.put(num.Id,num);
                }
            system.debug('numberMap97'+numberMap);
            return numberMap;
        }
        /*Method Name: populateServiceFields
        * Purpose : populates Service fields from Number Object/SelfLookup field
        * params : ServiceMap, NumberMap, serviceAttachmentMap
        * Return Type : Map<Id,csord__Service__c> 
        * Called from : OrderObserverHelper
        * Disclamer :
        * DIGI-455: JJ: Orchestration changes as per new design: Updated signature with a new map
        */
        public static Map<Id,csord__Service__c> populateServiceFields(Map<Id, Number__c> numberMap,Map<Id,csord__Service__c> serviceMap, Map<Id,Orchestration_AttachmentWrapper> serviceAttachmentMap,List<Id> oppId,Map<String, String> pcGUIDServiceMap){
            Map<Id, String> pcWithNumberMap = new Map<Id,String>();
            Map<id,String> pcWithServNumMap = new Map<id,String>();
            Set<Id> accountIdSet = new Set<Id>();
            Map<String,Number__c> mapPCNum = new Map<String,Number__c>();
            Map<String,Number__c> mapNumberwithPC = new Map<String,Number__c>();
            Map<Id,String> pcWithServiceId = new Map<Id,String>();
            Map<Id,String> pcWithIncNumMap = new Map<Id,String>();
            Map<Id,Date> caDate = new Map<Id,Date>();
            Map<Id,csord__Service__c> serviceListToUpdate = new Map<Id,csord__Service__c>();
            //Collection to store attachments that needs updation
            Map<String, Attachment> AttMapTobeUpdated = new Map<String, Attachment>();
            Boolean isPortInSrvc = false;
            Map<string,List<Plan__mdt>> mapOfProductAndPlan=new Map<string,List<Plan__mdt>>(); //EDGE-170949/170948-Map of product and its plans
            List<Notification_Preference__c> notificationPreferenceList =new List<Notification_Preference__c>() ; //EDGE-170949/170948-Store Notification preference record for creation.
            mapOfProductAndPlan=NotificationPreferenceHelper.getProductandPlanMetadata(); //EDGE-170949/170948-Dheeraj/Veena-get product and plans from customMetadata
                    for(Number__c num : numberMap.values()){    
                //EDGE-174220 Start
                if(num.Type__c == 'Transition' && num.SimAvailabilityType__c == 'Existing Blank SIM'){
                    pcWithNumberMap.put(num.Product_Configuration__c,'Transition with Inactive SIM');
                }//EDGE-174220 :End
                 //EDGE-186610 - Added Reactiavte in below line - the purpose is to populate Scenario Type and CHaneg Type on Service in case of Reactiavte
                else if(num.Type__c == 'Transition' || num.Type__c == 'Port In' || num.Type__c == 'Port Out Reversal' || num.Type__c == 'Reactivate')// EDGE-142355 : Added the chek for 'Port Out Reversal' value.
                    pcWithNumberMap.put(num.Product_Configuration__c,num.Type__c);
                if(num.Type__c == 'Port In' || num.Type__c == 'Port Out Reversal'){//EDGE-80750
                    pcWithServNumMap.put(num.Product_Configuration__c, num.Service_Number__c);
                    accountIdSet.add(num.Basket__r.csbb__Account__c);
                    isPortInSrvc = true;
                }
                // EDGE-186885-Dheeraj Bhatt-Enabling of new Scenario Type for Migration Orders
                if(string.isNotBlank(num.Product_Configuration__c) && customMetadataNameValueMap.containsKey('Migration') && num.Product_Configuration__r.subType__c==customMetadataNameValueMap.get('Migration').get('Value__c')){
                         pcWithNumberMap.put(num.Product_Configuration__c,num.Product_Configuration__r.subType__c);                    
                 }
                mapPCNum.put(num.Product_Configuration__c,num);
                mapNumberwithPC.put(num.Service_Number__c, num);
            }
            if(!pcWithServNumMap.IsEmpty()){//EDGE-80750
                list<Service_Qualification__c> sqLst = [SELECT Id, Incumbent_Account_Number__c, Service_Number__c 
                                    FROM Service_Qualification__c WHERE SQ_Type__c = 'Port in SQ' AND Portability_Status__c = 'Y' 
                                    AND Service_Number__c IN :pcWithServNumMap.Values() AND Account__c IN: accountIdSet];
                if(sqLst != null && !sqLst.IsEmpty()){
                    for(Service_Qualification__c sq: sqLst){
                        for(Id pc :pcWithServNumMap.keyset()){
                            if(pcWithServNumMap.get(pc) == sq.Service_Number__c){
                                pcWithIncNumMap.put(pc, sq.Incumbent_Account_Number__c);
                            }
                        }
                    }
                }
            }//EDGE-80750           
            //EDGE-66627 Changes End
            if(isPortInSrvc){//EDGE-80750
                for(Customer_Authority_Form__c caLst : [SELECT Id, Customer_Authorised_date__c,Opportunity__c FROM Customer_Authority_Form__c WHERE Is_active__c = TRUE AND Opportunity__c = :oppId]){
                    caDate.put(caLst.Opportunity__c,caLst.Customer_Authorised_date__c);
                }
            }       
            //TODO-Orchestration: Logic to check RunTimePCGUID__c field's value and get the parent service based on GUID
            for (csord__Service__c servObj : serviceMap.values()){
                system.debug('servObj'+servObj);
                notificationPreferenceList.addAll(NotificationPreferenceHelper.createNotificationPreference(servObj,mapOfProductAndPlan));//EDGE-170949/170948-Dheeraj/Veena-Create Notification Preference
                servObj.Product_Model_Version__c = servObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Product_Model_Version__c;
                
				String channelFrom = '';
                if(servObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c != null){
                    channelFrom = servObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.channelFrom__c;
                }//added for Ted-81/DIGI-38789
				if(servObj.csord__Order__r.csordtelcoa__Opportunity__c!=null || channelFrom == 'TED-81 onlineAPI'){ //check added as part of EDGE-181982 //added channelfrom check for Ted-81/DIGI-38789,DIGI-39435
                    servObj.Incumbent_Account_Number__c = pcWithNumberMap.get(servObj.csordtelcoa__Product_Configuration__c) == 'Port In' && pcWithIncNumMap.containsKey(servObj.csordtelcoa__Product_Configuration__c)?pcWithIncNumMap.get(servObj.csordtelcoa__Product_Configuration__c):null;
                    servObj.Customer_Authorised_date__c = pcWithNumberMap.get(servObj.csordtelcoa__Product_Configuration__c) == 'Port In' || pcWithNumberMap.get(servObj.csordtelcoa__Product_Configuration__c) == 'Port Out Reversal'?caDate.get(servObj.csord__Order__r.csordtelcoa__Opportunity__c):null;
                    if(pcWithNumberMap.get(servObj.csordtelcoa__Product_Configuration__c)!=null){
                        servObj.Scenario_Type__c = pcWithNumberMap.get(servObj.csordtelcoa__Product_Configuration__c);
                    }
                    //EDGE-207018-Dheeraj Bhatt- Set Scenario_Type__c as Migration for Adaptive care for Migration order
                    //EDGE-214688-To populate scenario type for 'HRO devices' for Migration order 
                    if(customMetadataNameValueMap.containsKey('Migration') && servObj.csord__Order__r.csordtelcoa__Opportunity__r.Type==string.valueOf(customMetadataNameValueMap.get('Migration').get('Value__c')) && customMetadataNameValueMap.containsKey('MigrationOrder') ){
                        for(string productCode:String.valueOf(customMetadataNameValueMap.get('MigrationOrder').get('Value__c')).split(';')){
                            if(productCode==servObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c){
                                servObj.Scenario_Type__c =string.valueOf(customMetadataNameValueMap.get('Migration').get('Value__c'));
                            }   
                        }
               }
                    //Get Service Number from Number object and assign to Service Object
                    String PCNum;
                    /*if(servObj.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != null){
                        PCNum = servObj.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c;
                    }else{
                        PCNum = servObj.csordtelcoa__Product_Configuration__c;
                    }*/
                    // EDGE-205935 Start
                    if(servObj.csordtelcoa__Replaced_Service__c != null){
                        PCNum = servObj.csordtelcoa__Replaced_Service__r.serviceMSISDN__c;
                    }else{
                        PCNum = servObj.csordtelcoa__Product_Configuration__c;
                    }
                    
                    
                    if(PCNum != null && (mapPCNum.containsKey(PCNum) || mapNumberwithPC.containsKey(PCNum))){
                        Number__c objNum = new Number__c();
                        if(mapPCNum.containsKey(PCNum)){
                            objNum = mapPCNum.get(PCNum);
                        }
                        else if(mapNumberwithPC.containsKey(PCNum)){
                            objNum = mapNumberwithPC.get(PCNum);
                        }
                        if(servObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c != 'DMCAT_ProductSpecification_000871'){
                            servObj.serviceMSISDN__c = objNum.Service_Number__c;
                        }//INC000093706570
                        if(objNum.Status__c != 'Active'){
                            servObj.Transition_Id__c = objNum.Transition_Id__c;//EDGE-145854
                        }
                    }
                       // EDGE-205935 End
                    //EDGE-174925 Starts: Update Initial_Activation_DateTime__c field based on Parent Services Initial_Activation_DateTime__c value
                    if(servObj.csordtelcoa__Replaced_Service__c !=null && servObj.csordtelcoa__Replaced_Service__r.csord__Status__c =='Connected' && (servObj.csordtelcoa__Replaced_Service__r.Initial_Activation_DateTime__c !=null )){
                        servObj.Initial_Activation_DateTime__c = servObj.csordtelcoa__Replaced_Service__r.Initial_Activation_DateTime__c;
                    }
                    //EDGE-174925 Ends
                }else{ //added as part of EDGE-181982
                    
                     servObj.Not_Before_CRD__c = System.Today();
                     servObj.Preferred_CRD__c = System.Today();
                }
                
    
                // Added below block as part of EDGE-174924 - Start
                if(String.isBlank(servObj.changeType__c)){
                    if(String.isNotBlank(servObj.Scenario_Type__c)){
                        servObj.changeType__c = servObj.Scenario_Type__c == 'Transition with Inactive Sim' ? 'Transition' : servObj.Scenario_Type__c;
                    }
                    else if(servObj.Action_Type__c == 'PayOut'){
                        servObj.changeType__c = 'PayOut';
                    }
                    else if(servObj.toBeCancelled__c == 'true' && servObj.Action_Type__c != null && servObj.Action_Type__c.equalsIgnoreCase('No Fault Return'))//EDGE-202433
                    {
                        servObj.changeType__c = 'No Fault Return';
                        servObj.Scenario_Type__c = 'No Fault Return'; 
                        
                    }
                    else if(String.isNotBlank(servObj.csordtelcoa__Replacement_Service__c)){
                        servObj.changeType__c = 'Modify';
                    }
                    else if(String.isBlank(servObj.csordtelcoa__Replacement_Service__c)){
                        servObj.changeType__c = 'New';
                    }
                    else if(servObj.toBeCancelled__c == 'true' )
                    {
                        servObj.changeType__c = 'Cancel';
                        
                    }
                    System.debug('servObj.changeType__c...'+servObj.changeType__c);
                }
                // Added as part of EDGE-174924 - End
          // EDGE-200291 starts
          
          if (servObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c !=null && servObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c.equalsIgnoreCase('Outgoing')) //EDGE-200291
                 {
                     if(servObj.csordtelcoa__Product_Configuration__r.ConfigurationType1__c=='SolutionComponent' && servObj.csord__Status__c!='Connected')
                     {
                          servObj.csord__Status__c ='Connected'; //EDGE-200291
                     }
                     else
                     {
                         servObj.csord__Status__c ='CHOWN Replaced'; //EDGE-200291
                     }
                 }
          // EDGE-200291 ends
          
                     //Added by Vamsi for EDGE-201613 on 15MAR2021 starts
                    String productSpecification    =   System.Label.Product_Specification;
                    if(servObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c == productSpecification)
                    {
                        servObj.International_Direct_Dial__c = servObj.addOnCharge__r.addOn_Name__c; 
                    }
                    //Added by Vamsi for EDGE-201613 on 15MAR2021 ends
                   
                //JJ-Start: Orchestration new design changes
                if(String.isNotBlank(servObj.RunTimePCGUID__c) && pcGUIDServiceMap != null && pcGUIDServiceMap.containsKey(servObj.RunTimePCGUID__c)){
                    servObj.RunTimeParent__c = pcGUIDServiceMap.get(servObj.RunTimePCGUID__c);
                }
                //JJ-End: Orchestration new design changes
          
                serviceListToUpdate.put(servObj.Id,servObj);
                if(mapPCNum.size()>0 && mapPCNum.containsKey(servObj.csordtelcoa__Product_Configuration__c)){
                    if(serviceAttachmentMap.containsKey(servObj.Id)){
                        string returnVal = populateNumberInServiceSpecAttach(servObj.Id,serviceAttachmentMap,mapPCNum.get(servObj.csordtelcoa__Product_Configuration__c));
                        if (!returnVal.equals('false')) {
                                    Attachment attAdd = new Attachment(Id = serviceAttachmentMap.get(servObj.Id).attchId);
                                    attAdd.body = Blob.valueOf(returnVal);
                                    AttMapTobeUpdated.put(attAdd.id, attAdd);
                        }
                    }
                }
            }
            //Updating all the order records
            List<Database.SaveResult> updateResult = Database.update(AttMapTobeUpdated.values(), false);
              //EDGE-170949/170948-Dheeraj/Veena-Insert Notificatipn preference as per  voice and voice + data plans
            if(!notificationPreferenceList.isEmpty()){
                Database.SaveResult[] saveResult = Database.insert(notificationPreferenceList, false);
                updateResult.addAll(saveResult);
            }
            List<Id> successIds = new List<Id>();
            //Storing the order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    successIds.add(rslt.getId());
                }
            }
            system.debug('serviceListToUpdate '+serviceListToUpdate);
            return serviceListToUpdate;
        }
          
        /*Method Name: populateNumberInServiceSpecAttach
        * Purpose : populates additional attributes like serialNumber, Mobile Number, IMSI for specific products on ServiceSpec
        * params : serviceID, serviceAttachmentMap ,numberObj
        * Return Type : String (body of attachment)
        * Called from : 
        * Disclamer : 
        */
        public static String populateNumberInServiceSpecAttach(Id serviceID, Map<Id, Orchestration_AttachmentWrapper> serviceAttachmentMap,Number__c numberObj){
            Map<String,String> newAddAttrMap = new Map<String,String>();
            List<String> targetSystem = new List<String>{ 'FULFILMENT' };
            List<String> specCodes = new List<String>{ 'DMCAT_ProductSpecification_000263','DMCAT_ProductSpecification_000966_Fulfilment','DMCAT_ProductSpecification_001196_Fulfilment' };
            String bodyToUpdate = '';
            if(numberObj != null) {
                if(numberObj.Service_Number__c != NULL && numberObj.Service_Number__c != ''){
                    newAddAttrMap.put('CustomerFacingServiceId',numberObj.Service_Number__c);
                }
                if(numberObj.IMSI__c != NULL && numberObj.IMSI__c != '') {  //Added by Jayesh - bugfix IMSI
                    newAddAttrMap.put('IMSI',numberObj.IMSI__c);
                }
                //EDGE-149261 - Removed ShippingRequired Check and from If condition and set it only when simSerialNumebr is not null
                if(numberObj.Sim_Serial_Number__c != NULL && numberObj.Sim_Serial_Number__c != '') { //Added by Jayesh - bugfix SimSerialNumber
                    newAddAttrMap.put('SIMSerialNumber',numberObj.Sim_Serial_Number__c);//EDGE-148457 Changed case for Sim to upper case
                    newAddAttrMap.put('ShippingRequired','FALSE');
                }
                bodyToUpdate = Orchestration_Utility.addAdditionalAttribute(serviceAttachmentMap.get(serviceID).attchBody.toString(), newAddAttrMap, targetSystem, specCodes);
            }
            return bodyToUpdate;
        }
    
        /*Method Name: populateSubscriptionFields
        * Purpose : populates Subscription fields from Service Object/ Subscription Object/Number Object/ContractJunction Object
        * params : ServiceMap, NumberMap,ContractJunction Map, Subscription Map
        * Return Type : updated SubscriptionMap
        * Called from : OrderObserverHelper
        * Disclamer : This Method should always be called after updating Services subscriptions are updated based on services
        */
        public static Map<Id,csord__Subscription__c> populateSubscriptionFields(Map<Id,csord__Subscription__c> subListToUpdate, Map<Id,csord__Service__c> serviceMap,Map<Id, ContractJunction__c> basketIdToContractJunctionRecMap,
        Map<String, List<Basket_To_Order_Field_Map__c>> objBasketMap, Set<Id> basketIds, List<csord__Subscription__c> scope){
            //Fetch BT Subscription Id against Each order
            Map<Id,Id> mapOrdIdBTSubId = new Map<Id,Id>();
            for(csord__Subscription__c subInstance : subListToUpdate.values()){
                    if(subInstance.csordtelcoa__Product_Configuration__c != null){
                        if(subInstance.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase('DMCAT_ProductSpecification_000311')){    //Check for Broadsoft Tenancy
                        mapOrdIdBTSubId.put(subInstance.csord__Order__c, subInstance.Id);       //Map of orderId and Broadsoft Tenancy subscriptionId
                            
                        }
                    }
            }
            for (csord__Service__c servObj : serviceMap.values()){
                if(servObj.csord__Service__c==null){
                    csord__Subscription__c updSub = subListToUpdate.get(servObj.csord__Subscription__c)!=null ? subListToUpdate.get(servObj.csord__Subscription__c) 
                                                        : new csord__Subscription__c(ID = servObj.csord__Subscription__c);
                    system.debug('objBasketMap '+objBasketMap);
                    //if(servObj.csord__Order__r.csordtelcoa__Opportunity__c!=null){
                    if(objBasketMap.containsKey('csord__Service__c'+'csord__Subscription__c')){
                        List<Basket_To_Order_Field_Map__c> basketToOrderFieldList = objBasketMap.get('csord__Service__c'+'csord__Subscription__c');
                        for(Integer i=0; i < basketToOrderFieldList.size(); i++){
                        if(servObj.get(basketToOrderFieldList[i].Source_Field_Api_Name__c) !== '' || servObj.get(basketToOrderFieldList[i].Source_Field_Api_Name__c) != null){
                            Object fieldVal = getFieldValue((Sobject) servObj,basketToOrderFieldList[i].Source_Field_Api_Name__c);
                            if(fieldVal != null){
                                updSub.put(basketToOrderFieldList[i].Target_Field_Api_Name__c,fieldVal);
                            }
                        }
                        }
                    }
                    if(objBasketMap.containsKey('csord__Subscription__c'+'csord__Subscription__c')){
                        List<Basket_To_Order_Field_Map__c> basketToOrderFieldList = objBasketMap.get('csord__Subscription__c'+'csord__Subscription__c');
                        for(Integer i=0; i < basketToOrderFieldList.size(); i++){
                            system.debug('updSub=='+updSub);
                            system.debug('testupdSub=='+basketToOrderFieldList[i].Source_Field_Api_Name__c);
                        //if(servObj.get(basketToOrderFieldList[i].Source_Field_Api_Name__c) !== '' || servObj.get(basketToOrderFieldList[i].Source_Field_Api_Name__c) != null){
                            Object fieldVal = getFieldValue((Sobject)updSub,basketToOrderFieldList[i].Source_Field_Api_Name__c);
                            if(fieldVal != null){
                                updSub.put(basketToOrderFieldList[i].Target_Field_Api_Name__c,fieldVal);
                            }
                        //}
                        }
                    }
                    //}
    
                    // Update changeType__c with the Service's changeType__c - EDGE-174924 
                    if(String.isNotBlank(servObj.changeType__c)){
                        updSub.changeType__c = servObj.changeType__c;
                    }
                     // Update changeType__c with the Service's changeType__c - EDGE-174924 
                     //EDGE-200291 starts
                    if (servObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c!=null && servObj.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c.equalsIgnoreCase('Outgoing')) 
                     {
                         if(servObj.csordtelcoa__Product_Configuration__r.ConfigurationType1__c=='SolutionComponent' && servObj.csord__Subscription__r.csord__Status__c!='Active')
                         {
                             updSub.csord__Status__c ='Active';
                            updSub.csordtelcoa__Cancelled_By_Change_Process__c = True;
                         }
                         else
                         {
                             updSub.csord__Status__c ='CHOWN Replaced';
                            updSub.csordtelcoa__Cancelled_By_Change_Process__c = True;
                         }
                         
                             
                     }
                    //EDGE-200291 ends
                    //Self-lookup fields
                    if(servObj.csord__Order__r.csordtelcoa__Opportunity__c!=null){ //check added as part of EDGE-181982 
                        updSub = populateSubscriptionFieldsfromSelfLookup(updSub, basketIdToContractJunctionRecMap,mapOrdIdBTSubId);  
                    }
                    subListToUpdate.put(servObj.csord__Subscription__c, updSub);                
                }
            }
            //START: EDGE-207179
            List<Legacy_Service__c> legacyServiceList = new List<Legacy_Service__c>();
            for(Legacy_Service__c legacyServiceRec: [SELECT Id, Nickname__c, Product_Basket__c, Service_Id__c, TON_Barring_Status__c FROM Legacy_Service__c WHERE Product_Basket__c IN :basketIds]){
                legacyServiceList.add(legacyServiceRec);
            }
            List<csord__Subscription__c> subscriptionToUpdate = new List<csord__Subscription__c>();
            for(csord__Subscription__c sub: scope){
                for(Legacy_Service__c ls: legacyServiceList){
                    if(ls.Nickname__c != null && ls.Nickname__c != '' && sub.Nickname__c == null && ls.Service_Id__c == sub.serviceMSISDN__c){
                        sub.Nickname__c = ls.Nickname__c;
                        subListToUpdate.put(sub.Id, sub);
                    }
                    //Start EDGE-218849
                    if(ls.TON_Barring_Status__c != null && ls.TON_Barring_Status__c != '' && ls.Service_Id__c == sub.serviceMSISDN__c){
                        sub.TON_Barring_Status__c = ls.TON_Barring_Status__c;
                        subListToUpdate.put(sub.Id, sub);
                    }
                    //End EDGE-218849
                }
            }
            /*if(!subscriptionToUpdate.isEmpty()){
                Database.update(subscriptionToUpdate);
            }*/
            //END: EDGE-207179
    
            return subListToUpdate;
        }
    
        /*Method Name: populateSubscriptionFieldsfromSelfLookup
        * Purpose : populates the self lookup fields from the same object
        * params : csord__Subscription__c,mapOrdId-->BTSubId, basketId-->ContractJunctionRec Map
        * Return Type : csord__Subscription__c
        * Called from : populateSubscriptionFields
        * Disclamer : This method is only created to populate the selflookup fields for single record as it is already being called from loop
        */
        public static csord__Subscription__c populateSubscriptionFieldsfromSelfLookup(csord__Subscription__c updateSub, Map<Id, ContractJunction__c> basketIdToContractJunctionRecMap, Map<Id,Id> mapOrdIdBTSubId){
            //Self-lookup Subscription fields
            /*if(updateSub.csordtelcoa__Product_Configuration__r.Offer_Reference__c!=null){
                updateSub.Offer__c = updateSub.csordtelcoa__Product_Configuration__r.Offer_Reference__c;              
            }
            updateSub.Product_Model_Version__c = updateSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Product_Model_Version__c;
            if(updateSub.csordtelcoa__Product_Configuration__c!=null && updateSub.csordtelcoa__Product_Configuration__r.Marketable_Offer__c!=null){
                updateSub.MarketableOffer__c=updateSub.csordtelcoa__Product_Configuration__r.Marketable_Offer__c;//edge-98904
            }*/
            //Added by Purushottam - Start EDGE-148371
            if(updateSub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){
                if(updateSub.csordtelcoa__Replaced_Subscription__c == NULL || updateSub.csordtelcoa__Replaced_Subscription__r.partnerAccount__c == NULL){
                //Is New then assign Partner Account
                updateSub.partnerAccount__c = (updateSub.csord__Order__c != NULL && updateSub.csord__Order__r.csordtelcoa__Opportunity__c != NULL && updateSub.csord__Order__r.csordtelcoa__Opportunity__r.PartnerAccountId != NULL) ? updateSub.csord__Order__r.csordtelcoa__Opportunity__r.PartnerAccountId : NULL;
                } else if(updateSub.partnerAccount__c == null && updateSub.csordtelcoa__Replaced_Subscription__c != null&& updateSub.csordtelcoa__Replaced_Subscription__r.partnerAccount__c !=null){
                updateSub.partnerAccount__c = updateSub.csordtelcoa__Replaced_Subscription__r.partnerAccount__c;
                }
            }
            
            //EDGE-174925 Starts: Update Initial_Activation_DateTime__c field based on Parent Subscription Initial_Activation_DateTime__c value || Modified(updateSub.csordtelcoa__Replaced_Subscription__c != null) if condition for EDGE-199912 by Aman Soni
            if(updateSub.csordtelcoa__Replaced_Subscription__c != null){
                if(updateSub.csordtelcoa__Replaced_Subscription__r.csord__Status__c=='Active' && (updateSub.csordtelcoa__Replaced_Subscription__r.Initial_Activation_DateTime__c !=null)){
                updateSub.Initial_Activation_DateTime__c = updateSub.csordtelcoa__Replaced_Subscription__r.Initial_Activation_DateTime__c;
                }
                updateSub.Nickname__c = updateSub.csordtelcoa__Replaced_Subscription__r.Nickname__c;//Added for EDGE-199912 || Aman Soni
            } 
            //EDGE-174925  Ends
            
            updateSub.ContractJunction__c = basketIdToContractJunctionRecMap.get(updateSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c)!=null ? basketIdToContractJunctionRecMap.get(updateSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c).Id :null;
            updateSub.Contract_Start_Date__c = basketIdToContractJunctionRecMap.get(updateSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c)!=null ? basketIdToContractJunctionRecMap.get(updateSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c).Contract_Start_Date__c :null;                                       
            //EDGE-136968 Starts : Updates Parent Subscription based on Product Type
            if(updateSub.csordtelcoa__Product_Configuration__c != null && updateSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c != null && updateSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c != null){
                if(updateSub.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase('DMCAT_ProductSpecification_000871')){  //Check for NGVoice subscriptions
                if(mapOrdIdBTSubId.containsKey(updateSub.csord__Order__c)){
                    updateSub.Parent_Subscription__c = mapOrdIdBTSubId.get(updateSub.csord__Order__c);
                }else{
                    if(updateSub.csordtelcoa__Replaced_Subscription__c  != null && updateSub.csordtelcoa__Replaced_Subscription__r.Parent_Subscription__c != null ){            //Checking base order for BT subs in case of MAC      
                    updateSub.Parent_Subscription__c = updateSub.csordtelcoa__Replaced_Subscription__r.Parent_Subscription__c;
                    }
                }
                }
            }
            return updateSub;
        }
        
        /*Method Name: executeOrderPrerequisiteMsisdn
        * Purpose : checks required fields for Order and updates status of the order object
        * params : Map<Id,csord__Order__c>, Map<Id, csord__Service__c> ,OrderRecordType-->Name, Prerequiste Boolean, msis
        * Return Type : Map<Id,csord__Order__c>
        * Called from : OrderObserverHelper
        * Disclamer : 
        */
        public static Map<Id,csord__Order__c> executeOrderPrerequisiteMsisdn(Map<Id, csord__Order__c> orderMap, Map<Id, csord__Service__c> serviceMap, Map<String, Id> orderRecordTypeNameToIdMap, boolean orderPrerequisteCheck, boolean msisdnCheck) {
              
            String searchIoTText    =   System.Label.IoTSubscription;
            String searchIoTPlan    =   System.Label.IoTPlans;
            Set<String> numberResvText   =   new set<String>();
            
            //Created custom metadata to store the fulfillment Code, product name, DPG-3906
            List<NumberReservationSetting__mdt> NumberReservationRecords = [Select  type__c,value__c from NumberReservationSetting__mdt where type__c = 'NumberReservationProduct'];
            numberResvText = new Set<String>();
            for(NumberReservationSetting__mdt record:NumberReservationRecords) {
                numberResvText.add(record.value__c);
            }
             
            for(csord__Service__c oServ : serviceMap.values()) {
                
                Boolean isMsisdnRequired            = false;
                Boolean isAppointmentRequired       = false;
                Boolean isIotMsidnRequired          = false;
                Boolean isReadyToSubmit             = false;
                Boolean isReadyToSubmitWithAppnmnt  = false;
        
                if(oServ.csord__Order__c!=null && orderMap.containsKey(oServ.csord__Order__c)) {
                    csord__Order__c oOrder          =   new csord__Order__c();
                    oOrder                          =   orderMap.get(oServ.csord__Order__c);
                    
                    if(oServ.csord__service__c == null){
                        if((orderPrerequisteCheck || msisdnCheck) &&  oServ.TechnologyType__c == 'Mobile Access' && oServ.csordtelcoa__Replaced_Service__c == null && !oServ.modelChange__c) {
                            isMsisdnRequired = true;
                        } 
                        if((orderPrerequisteCheck || !msisdnCheck) && oServ.csord__Order__r.isAppointmentCompleted__c == false && oServ.Appointment_Required__c == 'true' && !oServ.modelChange__c) {
                            isAppointmentRequired       = true;
                        //} else if(orderPrerequisteCheck && String.isBlank(oServ.serviceMSISDN__c) && (oServ.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name == searchIoTText || numberResvText.split(',').contains(oServ.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name)) ) { // DPG-1260 & DPG-697
                        
                        } else if(orderPrerequisteCheck && String.isBlank(oServ.serviceMSISDN__c) && oServ.csordtelcoa__Product_Configuration__r.Type__c != 'Cancel' &&
                            (oServ.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name == searchIoTText || oServ.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name == searchIoTPlan)) { // DPG-1260 & DPG-697 & DIGI-1003 & DPG-5900  
                            isIotMsidnRequired          = true;
                        } else if(!orderPrerequisteCheck && !msisdnCheck && oServ.csord__Order__r.isAppointmentCompleted__c == true && oServ.Appointment_Required__c == 'true' && !oServ.modelChange__c) {
                            isReadyToSubmitWithAppnmnt  = true;
                        } else if(msisdnCheck && oServ.Appointment_Required__c == 'true' && !oServ.modelChange__c) {
                            isAppointmentRequired       = true;
                        } else if(!orderPrerequisteCheck) {
                            isReadyToSubmit             = true;
                        }
    
                        
                        if(isReadyToSubmitWithAppnmnt) {
                            oOrder.csord__Status2__c    =   'Ready for Submit';
                            oOrder.RecordTypeId         =   orderRecordTypeNameToIdMap.get('Ready for Submit With Appointment');
                        } else if(isReadyToSubmit) {
                            oOrder.csord__Status2__c    =   'Ready for Submit';
                            oOrder.RecordTypeId         =   orderRecordTypeNameToIdMap.get('Ready for Submit');
                        } else if(isAppointmentRequired) {
                            oOrder.csord__Status2__c    =   (orderPrerequisteCheck ? 'Pending' : 'Appointment Required');
                            oOrder.RecordTypeId         =   (orderPrerequisteCheck ? orderRecordTypeNameToIdMap.get('Order Prerequisite') : orderRecordTypeNameToIdMap.get('Appointment Required'));
                        } else if(isMsisdnRequired) {
                            oOrder.csord__Status2__c    =   'MSISDN Required';
                            oOrder.RecordTypeId         =   (orderPrerequisteCheck ? orderRecordTypeNameToIdMap.get('Order Prerequisite') : orderRecordTypeNameToIdMap.get('MSISDN Required'));
                            oOrder.isMSISDNRequired__c  =   true;
                        } else if(isIotMsidnRequired) {
                            oOrder.csord__Status2__c    =   'IoT MSISDN Required';
                            oOrder.RecordTypeId         =   orderRecordTypeNameToIdMap.get('MSISDN Required');
                            oOrder.IOTMSISDNRequired__c =   true;
                        }
                    }
                     //check prod spec id
                     if(String.isBlank(oServ.serviceMSISDN__c) && !oOrder.IOTMSISDNRequired__c && numberResvText.contains(oServ.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name)) {  
                        oOrder.csord__Status2__c    =   'MSISDN Required';
                        oOrder.RecordTypeId         =   orderRecordTypeNameToIdMap.get('MSISDN Required');
                        oOrder.IOTMSISDNRequired__c =   true;
                    }
                    //EDGE-200291 adding starts
                    if(oServ.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c!=null && oServ.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c.equalsIgnoreCase('Outgoing')) {
                        oOrder.csord__Status2__c    =   'Completed';
                        oOrder.RecordTypeId         =   orderRecordTypeNameToIdMap.get('Completed Order Page layout');
                        oOrder.telstra_ord_Start_DateTime__c =   system.today();
                        oOrder.telstra_ord_End_DateTime__c =   system.today();
                    }
                    //EDGE-200291 adding ends
                    orderMap.put(oOrder.Id,oOrder);
                }
            }
            return orderMap;
        }   //End of executeOrderPrerequisiteMsisdn
          
          
          
        /*Method Name: updateOperation
        * Purpose : Used to perform dml operation on an object
        * params : Map<Id,csord__Order__c>, Map<Id, csord__Service__c> ,Map<Id,Number__c>,Map<Id,csord__Subscription__c> 
        * Return Type : Void
        * Called from : OrderObserverHelper
        * Disclamer : The method should only be used for performing DML Operations
        */
        public static Map<Id,csord__Order__c> updateOperation(Map<id,csord__Order__c > orderMap,Map<Id,Number__c> numberMap,Map<Id,csord__Service__c> serviceMap,Map<Id,csord__Subscription__c> subscriptionMap){
           system.debug('numberMap388'+numberMap);
            if(numberMap != null){
                if(!numberMap.isEmpty() && numberMap.values().size()>0){
                    Database.update(numberMap.values());
                }
            }
            if(serviceMap != null){
                if(!serviceMap.isEmpty() && serviceMap.values().size()>0){
                    Database.update(serviceMap.values());
                }
            }
            if(subscriptionMap != null){
                if(!subscriptionMap.isEmpty() && subscriptionMap.values().size()>0){
                    Database.update(subscriptionMap.values());
                }
            }
            
            if(orderMap != null){
                Map<Id,csord__Order__c> successOrderMap     =   new Map<Id,csord__Order__c>();
                Map<Id,csord__Order__c> failedOrderMap      =   new Map<Id,csord__Order__c>();
                if(!orderMap.IsEmpty() && orderMap.values().size() >0) {
                    List<Database.SaveResult> results   =   Database.update(orderMap.values());      
                    for(Database.SaveResult sr : results) {
                        if(sr.isSuccess() && sr.getId()!=null) {
                            System.debug('Order Successfully Updated, OrderId: ' + sr.getId());
                            successOrderMap.put(sr.getId(),orderMap.get(sr.getId()));
                        } else if(!sr.isSuccess() && sr.getId()!=null){
                            csord__Order__c oOrder = new csord__Order__c(Id = sr.getId(),csord__Status2__c = 'Order Decomposition Failed');
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('Error returned: ' + err.getStatusCode()  + ' - ' + err.getMessage());
                                oOrder.Observer_Message__c = 'StatusCode: ' + err.getStatusCode() + '\nMessage: ' + err.getMessage();
                            }
                            failedOrderMap.put(oOrder.Id,oOrder);
                        }     
                    }
                }
                if(!failedOrderMap.isEmpty()) {
                    update failedOrderMap.values();
                }
                return successOrderMap;
            }
            return null;       
        }
        
        /*Method Name: publishEventforNewOrders
        * Purpose : publish event for new Orders :EDGE-121678
        * params : JSON.Serialize(Map<Id,csord__Order__c>)
        * Return Type : void
        * Called from : OrderObserverHelper
        * Disclamer : 
        */
        public static void publishEventforNewOrders(String newOrders){
            Map<Id,csord__Order__c> lstOrders = new Map<Id,csord__Order__c>();
            if(String.isNotBlank(newOrders)){
                lstOrders = (Map<Id,csord__Order__c>) JSON.deserialize(newOrders,Map<Id,csord__Order__c>.class);
            }
            //Start of EDGE-121678 changes
            List<OrderGenerationMSEvent__e> customerMs  =   new list<OrderGenerationMSEvent__e>();
            for(csord__Order__c newOrder : lstOrders.values()){
                customerMs.add(new OrderGenerationMSEvent__e(orderId__c=newOrder.id,orderNum__c=newOrder.csord__Order_Number__c,cidn__c=newOrder.csord__Account__r.CIDN__c));
            }
            // Publish the event
            List<Database.SaveResult> results   =   EventBus.publish(customerMs);   
            for(Database.SaveResult sr : results) {
                if(sr.isSuccess()) {
                System.debug('Successfully published event.');
                } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
                }       
            }
            //End of EDGE-121678 changes
        }
      
        /*Method Name: getFieldValue
        * Purpose : fetch field value based on relationship
        * params : sObject, string containing fieldName
        * Return Type : string
        * Called from : 
        * Disclamer : 
        */
        public static Object getFieldValue(sObject s, string fieldName){
            system.debug('s541'+s);
            system.debug('fieldName'+fieldName);
            
            Object returnVal;
            
            if(fieldName.contains('__r.')){
                List<String> fields = fieldName.split('\\.');
                for(Integer i=0;i<fields.size()-1;i++){
                    s = s.getSobject(fields[i]);
                    
                }
                
                if(s!=null){
                    returnVal = s.get(fields[fields.size()-1]);
                }
            }else{
                if(s!=null){
                    returnVal = s.get(fieldname);
                }
                
            }
            
            
            return returnVal;
        }
        
      }