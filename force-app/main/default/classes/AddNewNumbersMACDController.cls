/*********************************************************************************************************************************
Class Name : AddNewNumbersMACDController
Test Class : AddNewNumbersMACDControllerTest
Created By : Sonalisa Verma
Created On : 22 Mar 2021
User Story : EDGE - 205903 Enhance Add/Remove Numbers Sales UI flow for Telstra Collaboration offer
***********************************************************************
1.Pawan Devaliya       08-Sep-2021        DIGI-18183: Added new parameter in payload : Fulfilment Order Version
2.Mukta Wadhwani       05-Oct-2021        DIGI-28425: Added submit order method.
3.Rashmi               27-10-2021         DIGI-35918
4.Mukta Wadhwani       16/11/2021         changed order status to fix INC000097910781
***************************************************************************************************
*/
public class AddNewNumbersMACDController {
    
    
    /**************************************************************************************
****** Desc         : Method to create order, number group and update reserved numbers
****** Story        : EDGE-205903
****** Developer    : Sonalisa Verma
***************************************************************************************/
    private static final String CONST_INTERFACENAME = 'AddNewNumbersMACDController';
    private static String correlationId = GuidUtil.NewGuid();
    @AuraEnabled    
    //DIGI-35918 added contactId
    public static String createOrder(List<String> listSelSearchNum, string subscription, string accountId,String contactId){
        try {
            List<SubscriptionDetails> subscriptionDet = (List<SubscriptionDetails>)JSON.deserialize(subscription, List<SubscriptionDetails>.class);
            String accId = accountId;
            List<Number_Group__c> numberGroupList = [SELECT Id,OrderId__c FROM Number_Group__c WHERE Id IN : listSelSearchNum];
            if(subscriptionDet.isEmpty() || numberGroupList.isEmpty()){
                return system.label.MACD_Add_order_submit_err_msg;
            }else{
                csord__Order__c ord = new csord__Order__c();
                ord.Name = subscriptionDet[0].orderNumber+'_MACD_Order';
                ord.csord__Account__c = accountId;
                ord.Scenario_Type__c = 'Manage Fixed Numbers';
                ord.csord__Status2__c  = 'Ready For Submit';
                ord.csord__Identification__c = subscriptionDet[0].orderNumber+'_MACD_Order';
                ord.Order_Requester__c = contactId;
				//DIGI-32827 Changes	
				ord.csord__Start_Date__c = Date.today();	
				ord.telstra_ord_Start_DateTime__c = System.now();
                insert ord;
                //update number groups records with order id
                for(Number_Group__c numGrp : numberGroupList){
                    numGrp.OrderId__c = ord.Id;
                }
                if(!numberGroupList.isEmpty()){
                    update numberGroupList;
                }
                User userObj = [select id,Name,ContactId,Profile.Name,Contact.AccountId,Contact.Account.CWP_Eligible_Partner__c from User where id =: userInfo.getUserId()];
                if(Label.PRM_Community_User_Profile.contains(userObj.Profile.Name)){
                    return PRMBaseURLUtility.getBaseURLForCommunityUser()+'/'+ord.Id;
                }
                return System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+ord.Id;
            }
        } catch (Exception e) {
            NumberReservationHelper.logException('createOrder','',correlationId, e.getMessage(), 'Create order',CONST_INTERFACENAME);
            return system.label.MACD_Add_order_error_msg;
        }
    }
    /**************************************************************************************
****** Desc         : Method to fire platform events.
****** Story        : DIGI-28425
****** Developer    : Mukta Wadhwani
***************************************************************************************/
@AuraEnabled
public static void submitOrder(String orderRecordId){
    List<csord__Order__c> orders = new  List<csord__Order__c>([SELECT Id,csord__Account__r.CIDN__c ,csord__Order_Number__c, Fulfilment_Order_Version__c,csord__Status2__c  FROM csord__Order__c WHERE Id =: orderRecordId]);
    orders[0].csord__Status2__c  = 'Order Submitted';
    try{
        update orders;
        NumberReservationHelper.publishPlatformEvents(orders[0].Id,orders[0].csord__Order_Number__c,orders[0].csord__Account__r.CIDN__c, orders[0].Fulfilment_Order_Version__c);

    }
    catch (Exception e) {
        NumberReservationHelper.logException('createOrsubmitOrderder','',correlationId, e.getMessage(), 'Submit order',CONST_INTERFACENAME);
    }
    
    
}
    
    /**************************************************************************************
****** Desc         : Method to create reserved numbers and number groups records
****** Story        : EDGE-205903
****** Developer    : Nikhil Sharma
***************************************************************************************/
    @AuraEnabled
    public static Response assignReservedNumbers(string inputData, string subscription, string accountId){
        try{
            List<ReservedNumber> inputNumberList = (List<ReservedNumber>)JSON.deserialize(inputData, List<ReservedNumber>.class);
            List<SubscriptionDetails> subscriptionDet = (List<SubscriptionDetails>)JSON.deserialize(subscription, List<SubscriptionDetails>.class);
            String accId = accountId;
            List<Number__c> numberList = new List<Number__c>();
            Map<String,Number_Group__c> numberGroupMap = new Map<String,Number_Group__c>();
            if(!inputNumberList.isEmpty() && !subscriptionDet.isEmpty()) {
                List<Number_Group__c> listOfNumberGroup = getExistingNumberGroups(subscriptionDet[0].subscriptionNumber);
                if(listOfNumberGroup.isEmpty()){
                    listOfNumberGroup = new List<Number_Group__c>();
                    listOfNumberGroup.add(fillNumberGroupRecord(subscriptionDet[0].subscriptionNumber));
                    Insert listOfNumberGroup;
                }
                for(Number_Group__c numGrp : listOfNumberGroup){
                    numberGroupMap.put(numGrp.Subscription_Number__c,numGrp);
                }
                //system.debug('numberGroupList'+numberGroupList);
                if(!numberGroupMap.isEmpty()){
                    for(Integer i=0;i<inputNumberList.size();i++){
                        ReservedNumber numberStr = inputNumberList[i];
                        if(numberStr.phoneNumber.contains(' - ')){
                            List<String> numberRange= numberStr.phoneNumber.Split(' - ');
                            String startRange = numberRange[0].deleteWhitespace();
                            String endRange = numberRange[1].deleteWhitespace();
                            numberList.addAll(NumberReservationHandler.splitRangeofNumbers(startRange,endRange,null,accId,'Reserved','New',subscriptionDet[0].productConfigId,numberGroupMap.get(subscriptionDet[0].subscriptionNumber).Id));
                        }else{
                            Number__c num = new Number__c();
                            num.Service_Number__c = numberStr.phoneNumber;
                            num.Status__c = 'Reserved';
                            num.Type__c = 'New';
                            num.Mobile__c='Fixed';
                            num.Number_Group__c = numberGroupMap.get(subscriptionDet[0].subscriptionNumber).Id;
                            num.Product_Configuration__c = subscriptionDet[0].productConfigId; 
                            num.Account__c = Id.valueOf(accId);
                            num.Service_Id__c = subscriptionDet[0].serviceNumber; //DIGI-13386
                            numberList.add(num);
                        }
                    }
                    for(Number__c num : numberList){
                        num.Subscription_number__c =  subscriptionDet[0].subscriptionNumber;
                        num.Invoke_BDS_Notification__c = true;//EDGE-219683
                    }
                    //system.debug('numberList'+numberList);
                }
                if(!numberList.isEmpty()) {
                    insert numberList;
                    List<String> numberGroupIds = new List<String>();
                    for(Number_Group__c numGrp : listOfNumberGroup){
                        numberGroupIds.add(numGrp.Id);
                    }
                    return new Response(numberList.size()+' '+ system.label.MACD_Add_number_assign_success_msg,numberGroupIds,true);
                }
            }
        }catch(Exception e){
            NumberReservationHelper.logException('assignReservedNumbers','',correlationId, e.getMessage(), 'Assign Reserved Numbers',CONST_INTERFACENAME);
        }
        return new Response(system.label.MACD_Add_assign_info_msg,new List<String>(),false);
    }
      
    /**************************************************************************************
****** Desc         : Method to delete reserved numbers and number groups records 
****** Story        : EDGE-205903
****** Developer    : Nikhil Sharma
***************************************************************************************/
    @AuraEnabled
    public static Response removeReservedNumbers(List<String> selectedNumbers, String subscription){
        try {
            List<SubscriptionDetails> subscriptionDet = (List<SubscriptionDetails>)JSON.deserialize(subscription, List<SubscriptionDetails>.class);
            //System.debug('selectedNumbers'+selectedNumbers);
            //System.debug('selectedNumbers'+subscriptionDet );
            List<Number__c> listOfReservedNumbersToDel = new list<Number__c>();
            Set<Id> numberGroupIds = new Set<Id>();
            List<Number_Group__c> listOfNumberGroupsToDel = new list<Number_Group__c>();
            for(Number__c num :  [SELECT Id, Service_Number__c, Number_Group__c FROM Number__c 
                                    WHERE Service_Number__c IN : selectedNumbers AND 
                                    Subscription_number__c =: subscriptionDet[0].subscriptionNumber 
                                    AND Status__c = 'Reserved']){
                    listOfReservedNumbersToDel.add(num);   
                    numberGroupIds.add(num.Number_Group__c);                    
            }
            if(!listOfReservedNumbersToDel.isEmpty()){
                DELETE listOfReservedNumbersToDel;
                if(numberGroupIds.size() > 0){
                    for(Number_Group__c numGrp : [SELECT Id,(SELECT Id FROM Numbers__r) FROM Number_Group__c WHERE Id IN : numberGroupIds]){
                        if(numGrp.Numbers__r.size() == 0){
                            listOfNumberGroupsToDel.add(numGrp);
                        }
                    }
                    if(!listOfNumberGroupsToDel.isEmpty()){
                        DELETE listOfNumberGroupsToDel;
                    }
                }
                return new Response(listOfReservedNumbersToDel.size()+' '+system.label.MACD_Add_number_unassigned_success_msg,new List<String>(),true);
            }else{
                return new Response(system.label.MACD_Add_no_number_msg,new List<String>(),false);
            }
        } catch (Exception e) {
            NumberReservationHelper.logException('removeReservedNumbers','',correlationId, e.getMessage(), 'Unassign Numbres.',CONST_INTERFACENAME);
        }
        return new Response(system.label.MACD_Add_no_number_msg,new List<String>(),false);
    }
    
      /**************************************************************************************
****** Desc         : Method to check if reserved numbers already exists in database
****** Story        : EDGE-205903
****** Developer    : shashank kulshreshtha
***************************************************************************************/
    @AuraEnabled
    public static List<NumbersExistWrap>  doNumbersExist(List<String> listSelSearchNum , String subscriptions){
        List<NumbersExistWrap> listNumbersExistWrap = new List<NumbersExistWrap>();
        system.debug('subscriptions'+subscriptions);
        try {
            List<String> listNumbReceived = new List<String>(listSelSearchNum);
            Map<String ,String> mapFirstNumbtoRange = new Map<String ,String>();
            List<String> listFirstNumbOfRange = new List<String>();
            Set<String> subscriptionNumbers = new Set<String>();
            if(String.isNotBlank(subscriptions)){
                List<SubscriptionDetails> subscriptionDet = (List<SubscriptionDetails>)JSON.deserialize(subscriptions, List<SubscriptionDetails>.class);
                for(SubscriptionDetails subs : subscriptionDet){
                    subscriptionNumbers.add(subs.subscriptionNumber);
                }
                system.debug('subscriptionNumber'+subscriptionNumbers);
            }
            
            for(String numRange : listNumbReceived){
                if(numRange.contains(' - ')){
                    listFirstNumbOfRange.add(numRange.split('-')[0].trim());
                    mapFirstNumbtoRange.put( numRange.split('-')[0].trim(),numRange );
                }else{
                    listFirstNumbOfRange.add(numRange);
                }
            }
            //system.debug('doNumbersExist');
            //system.debug('listNumbReceived-'+listNumbReceived);
            List<Number__c> listNumb = !subscriptionNumbers.isEmpty() ? getExistingNumbers(listFirstNumbOfRange,subscriptionNumbers) : new List<Number__c>();
            //System.debug('listNumb-'+listNumb);
            Map<String, Id> mapNumber = new Map<String, Id>();
            for(Number__c num :  listNumb){ 
                mapNumber.put(num.Service_Number__c, num.Id);
            }
            
            for (String selSearchNum : listFirstNumbOfRange) {
                NumbersExistWrap numbersExistWrapObj = new NumbersExistWrap();
                if(mapNumber.containsKey(selSearchNum)){
                    numbersExistWrapObj.PhoneNumber =selSearchNum;
                    numbersExistWrapObj.Status = 'Assigned';
                }else {
                    numbersExistWrapObj.PhoneNumber =selSearchNum;
                    numbersExistWrapObj.Status = 'Unassigned';
                }
                listNumbersExistWrap.add(numbersExistWrapObj);
            }
            //System.debug('listNumbersExistWrap-'+listNumbersExistWrap);
            // for Contiguous
            if (!listFirstNumbOfRange.isEmpty()){
                for (NumbersExistWrap numbersExistWrapObj : listNumbersExistWrap) {
                    if ( mapFirstNumbtoRange.containsKey(numbersExistWrapObj.PhoneNumber)) {
                        String ph =  numbersExistWrapObj.PhoneNumber;
                        numbersExistWrapObj.PhoneNumber = mapFirstNumbtoRange.get(ph) ;
                    }
                }
            }
            //System.debug('listNumbersExistWrap-'+listNumbersExistWrap);
            
        } catch (Exception e) {
            NumberReservationHelper.logException('doNumbersExist','',correlationId, e.getMessage(), 'Return exisitng Numbers.',CONST_INTERFACENAME);
        }
        return listNumbersExistWrap;
        
    }
          /**************************************************************************************
****** Desc         : Method to split Continuous number in the range of 100
****** Story        : EDGE-205903
****** Developer    : Nikhil Sharma
***************************************************************************************/
    @AuraEnabled
    public static List<LRMWrapper> getContiguousSplitNumbers(String searchedNumbers){
        List<LRMWrapper> msisdnList = new List<LRMWrapper>();
        try {
            List<LRMWrapper> numbersList = (List<LRMWrapper>)JSON.deserialize(searchedNumbers, List<LRMWrapper>.class);
            if(!numbersList.isEmpty() && numbersList[0].numberList.contains(' - ')){
                List<String> numberRange= numbersList[0].numberList.Split(' - ');
                String startRange = numberRange[0].deleteWhitespace();
                String endRange = numberRange[1].deleteWhitespace();
                Long stNum= long.valueOf(startRange);
                Long edNum= long.valueOf(endRange);
                Long tempRang = stNum;
                for (Long i = stNum; tempRang < edNum; i) { // testloop and testloop2 are known to be identical in size
                    //system.debug('stNum'+i);
                    String rang = String.valueOf(i);
                    tempRang = (i + 99);
                    i = (i + 99);
                    if(edNum < i){
                        //System.debug('Data ==> '+ i + ' - ' + rang +'-'+ (edNum - Long.valueOf(rang)));
                        Long difference = (edNum - Long.valueOf(rang));
                        rang = (difference > 0 ? rang+' - '+(Long.valueOf(rang) + difference) : rang);
                    }else{
                        rang += ' - '+i;
                    }
                    i=i + 1;
                    LRMWrapper wrap = new LRMWrapper();
                    wrap.numberList = rang;
                    msisdnList.add(wrap);
                }
                //System.debug('msisdnList'+msisdnList);
            }
            
        } catch (Exception e) {
            NumberReservationHelper.logException('getContiguousSplitNumbers','',correlationId, e.getMessage(), 'get Contiguous Numbers.',CONST_INTERFACENAME);
        }
        return msisdnList;
    }
    
    /**************************************************************************************
****** Desc         : Method to get Existing Numbers
****** Story        : EDGE-205903
****** Developer    : Nikhil Sharma
***************************************************************************************/
    private  static List<Number__c> getExistingNumbers(List<String> serviceNumbers, Set<String> subscriptionNumbers) {
        //system.debug('serviceNumbers'+serviceNumbers);
        List<Number__c> lstOfNumber = [SELECT Service_Number__c,Id,Number_Group__c FROM Number__c where Service_Number__c IN:serviceNumbers AND  Mobile__c='Fixed' 
                                       AND Status__c In ('Reserved') AND Subscription_number__c In : subscriptionNumbers];
        if(!lstOfNumber.isEmpty()){
            return lstOfNumber;
        }else {
            return new List<Number__c>();
        }
    }
    /**************************************************************************************
****** Desc         : Method to get Existing Number Groups
****** Story        : EDGE-205903
****** Developer    : Nikhil Sharma
***************************************************************************************/
    private  static List<Number_group__c> getExistingNumberGroups(String subscriptionNumber) {
        //system.debug('serviceNumbers'+serviceNumbers);
        List<Number_group__c> lstOfNumberGroups = [SELECT Id,Subscription_Number__c FROM Number_group__c WHERE Subscription_Number__c =: subscriptionNumber 
                                    AND Scenario_Type__c = 'Add' AND Status__c = 'Reserved' AND OrderId__c = null AND CreatedById = : UserInfo.getUserId()];
        if(!lstOfNumberGroups.isEmpty()){
            return lstOfNumberGroups;
        }else {
            return new List<Number_group__c>();
        }
    }

    /**************************************************************************************
****** Desc         : Method to fill number group records
****** Story        : EDGE-205903
****** Developer    : Nikhil Sharma
***************************************************************************************/
    private static Number_Group__c fillNumberGroupRecord(String subscriptionNumber){
        Number_Group__c numberGroup = new Number_Group__c();
        numberGroup.Subscription_Number__c = subscriptionNumber;
        numberGroup.Status__c = 'Reserved';
        numberGroup.Scenario_Type__c = 'Add';
        return numberGroup;
    }
    
    //Wrapper to display LRM success response
    public class LRMWrapper{
        @AuraEnabled
        public String numberList;
        @AuraEnabled
        public Boolean isSelectedNew;
        @AuraEnabled
        public String message;
        
    }
    
    public class NumbersExistWrap{
        @AuraEnabled
        public String PhoneNumber;
        @AuraEnabled
        public String Status;
    }
    
    public class SubscriptionDetails{
        @AuraEnabled public string subscriptionId;
        @AuraEnabled public String subscriptionNumber;
        @AuraEnabled public String orderNumber;
        @AuraEnabled public String productConfigId;
        @AuraEnabled public String serviceNumber; //DIGI-13386
    }
    
    public class ReservedNumber{
        public string status;
        public String phoneNumber;
    }
    
    public class Response{
        @AuraEnabled public String message;
        @AuraEnabled public List<String> recordIds;
        @AuraEnabled public boolean isSuccess;
        public Response(String msg, List<String> recIds, boolean isInserted){
            message = msg;
            recordIds  = recIds;
            isSuccess = isInserted;
        }
    }
    
    /**************************************************************************************
****** Desc         : New method for dispaying suspended subscriptions for assurance agent
****** Story        : EDGE-91569
****** Developer    : shashank kulshreshtha
***************************************************************************************/
    @AuraEnabled // EDGE-91569 
    public static List < SubWrapper > fatchSubscriptions(String accountId , String actionTypeSelected, List<String> subscriptionId) {
        String accId = accountId;
        List < Subwrapper > subwrapList = new List < SubWrapper > ();
        csordtelcoa__Orders_Subscriptions_Options__c OS = csordtelcoa__Orders_Subscriptions_Options__c.getOrgDefaults();
        String status = OS.csordtelcoa__Subscription_Closed_Replaced_State__c;
        String blockedStatus = OS.csordtelcoa__Statuses_Not_Allowing_Change__c;
        //hide used subscriptions in MACD
        if(accId !=null){
            List < csord__Subscription__c > subList = new List < csord__Subscription__c >(); 
            //EDGE-208199 -- changes starts here  
            // where clause for PS871 needs to be changed in future to make it configurable
            if(actionTypeSelected=='Manage Fixed Numbers'){
                subList = [
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
                    Suspension_reason__c,
                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name,
                    Is_Bill_Stopped__c,
                    Billing_Account__r.Billing_Account_Number__c,
                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                    MarketableOffer__r.Offer_ID__c,
                    csord__Order__r.csord__Order_Number__c,customerFacingServiceId__c, //EDGE-205903
                    csordtelcoa__Product_Configuration__c,
                    (select Id, csordtelcoa__Service_Number__c from csord__Services__r) //DIGI-13386
                    FROM csord__Subscription__c
                    WHERE
                    Id IN:subscriptionId
                ];
            }
            //EDGE-208199 -- changes ends here 
            
            List<String> args = new List<String>{ '0', 'number', '###,###,##0.00' };
                for (csord__Subscription__c su: subList) {
                    csord__Service__c service = su.csord__Services__r.isEmpty() ? null : su.csord__Services__r[0]; //DIGI-13386
                    SubWrapper suw = new SubWrapper();
                    suw.SubscriptionID = su.id;
                    suw.subscriptionName = su.Name;
                    suw.SiteID = su.Site__c;
                    suw.siteAddress = su.Site__r.Address__c;
                    suw.subscriptionNumber = su.csordtelcoa__Subscription_Number__c;
                    suw.status = su.csord__Status__c;
                    suw.ServiceId = su.customerFacingServiceId__c;
                    suw.createdBy = su.CreatedBy.Name;
                    suw.suspensionReason = su.Suspension_reason__c;
                    suw.productDefinitionName = su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
                    //EDGE-84486
                    suw.isBillStopped = su.Is_Bill_Stopped__c;
                    suw.billingAccount = su.Billing_Account__r.Billing_Account_Number__c;//EDGE-98386 - added BAN
                    //format date
                    String dateFormatString = 'dd/MM/yyyy HH:mm:ss';
                    suw.createdDate = su.CreatedDate.format(dateFormatString);
                    suw.MarketOffer=su.MarketableOffer__r.Offer_ID__c;
                    //format currency
                    Decimal rc = su.csord__Total_Recurring_Charges__c;
                    Decimal oc = su.csord__Total_One_Off_Charges__C;
                    String finalrc = rc.format().contains('.') ? rc.format() : (rc.format() + '.00');
                        String finaloc = oc.format().contains('.') ? oc.format() : (oc.format() + '.00');
                            suw.totalRC = '$ ' + String.format(finalrc, args);
                    suw.totalOC = '$ ' + String.format(finaloc, args);
                    if (su.csord__status__c == null) {
                        suw.disableRow = true;
                    }else{
                        suw.disableRow = false;
                    }
                    suw.isCWP = true;
                    suw.OrderNumber = actionTypeSelected.equalsIgnoreCase('Manage Fixed Numbers') ? su.csord__Order__r.csord__Order_Number__c : null;//EDGE-205903
                    suw.productConfigId = su.csordtelcoa__Product_Configuration__c;
                    suw.serviceNumber = service?.csordtelcoa__Service_Number__c; //DIGI-13386
                    subwrapList.add(suw);
                }             
        }
        return subwrapList;
    }

    /**************************************************************************************
    ****** Desc         : callout to UNMS sync number status
    ****** Developer    : Sonalisa Verma
    ***************************************************************************************/
    private static NumberReservationFixedHandler.ResponseWrapper callUNMSToSyncNumbers(List<string> numberList, string resourceState){
        String handlerName = 'ReserveBulkFnn';
        Logger2 logger = Logger2.getLogger('ReserveBulkFnnMACD');
        NumberReservationFixedHandler.ResponseWrapper responseWrapperList = new NumberReservationFixedHandler.ResponseWrapper();
        FixedNumberRequestDTO fnRequest = new FixedNumberRequestDTO();
        FixedNumberRequestDTO.Data fnRequestData = new FixedNumberRequestDTO.Data();

        List<String> resIdList = new List<String>();
        List<String> startRangeList = new List<String>();
        Integer resSize = 0;
        try {
            
            fnRequestData.resourceState = resourceState;

            List<FixedNumberRequestDTO.Resources> resList = new List<FixedNumberRequestDTO.Resources>();
            if(numberList !=null && (!numberList.isEmpty())) {
                for(String fnn: numberList) {
                    FixedNumberRequestDTO.Resources resDto = new FixedNumberRequestDTO.Resources();
                    if(fnn.contains('-')){
                        resDto.startRange = fnn.substringbefore(' -');
                        resDto.endRange = fnn.substringafter('- ');
                    } else{
                        resDto.resourceId = fnn;
                    }
                    resList.add(resDto);
                } 
            }

            fnRequestData.resources = resList;
            fnRequest.data = fnRequestData;

            FixedNumberResponseDTO fnnRes = NumberReservationFixedHandler.getMSISDNResponse(fnRequest, logger, responseWrapperList, handlerName);
            system.debug('fnnRes+' +fnnRes);
            if(responseWrapperList.status){
                responseWrapperList.status = null;
                system.debug('fnnRes.Errors+' +fnnRes.Errors);
                if(fnnRes.Data!=null && fnnRes.Data.resources!=null){
                    resSize = fnnRes.Data.resources.size();
                }
                
                for(Integer i=0; i<resSize; i++){
                    if(fnnRes.data !=null && fnnRes.data.resources != null){
                        if(fnnRes.data.resources[i].startRange != null){
                            startRangeList.add(fnnRes.data.resources[i].StartRange);
                        }
                        system.debug('fnnRes.data.resources[i].StartRange+' +fnnRes.data.resources[i].StartRange);
                        system.debug('responseWrapperList.stRange+' +startRangeList);
                        system.debug('fnnRes.data.resources[i].resourceId+ before' +fnnRes.data.resources[i].resourceId);
                        
                        if(fnnRes.data.resources[i].resourceId != null){
                            resIdList.add(fnnRes.data.resources[i].resourceId); 
                        }
                        system.debug('fnnRes.data.resources[i].resourceId+' +fnnRes.data.resources[i].resourceId);
                        system.debug('responseWrapperList.resIds+' +resIdList);
                    }
                }
                if(!resIdList.isEmpty()){
                    responseWrapperList.resIds = resIdList;
                    responseWrapperList.status = true;
                }
                if(!startRangeList.isEmpty()){
                    responseWrapperList.stRange=startRangeList;
                    responseWrapperList.status = true;
                }
                
                if(fnnRes.Errors == null){
                    system.debug('in here');
                    responseWrapperList.status = true;
                }
            }
        } catch (Exception e) {
            logger.logMessages(JSON.serialize(fnRequest,true), JSON.serialize(responseWrapperList,true), e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false); 
        } finally {
            logger.exitLogger();
        }
        system.debug('responseWrapperList+' +responseWrapperList);
        return responseWrapperList;
    }


    /**************************************************************************************
    ****** Desc         : return status from callout for number request
    ****** Developer    : Sonalisa Verma
    ***************************************************************************************/
    @AuraEnabled
    public static String numberStatusSync(List<String> numberList, string requestType){
        if(requestType.equalsIgnoreCase('Reserve')){
            return reserveNumbersCallout(numberList);
        }
        if(requestType.equalsIgnoreCase('Remove')){
            return removeNumbersCallout(numberList);
        }
        return 'Failed';
    }

    /**************************************************************************************
    ****** Desc         : return status from callout for reserve number request
    ****** Developer    : Sonalisa Verma
    ***************************************************************************************/
    
    public static String reserveNumbersCallout(List<String> numberList){
        return numberCallout(numberList, 'Held Order');
    }

    /**************************************************************************************
    ****** Desc         : return status from callout for remove number request
    ****** Developer    : Sonalisa Verma
    ***************************************************************************************/
    
    public static String removeNumbersCallout(List<String> numberList){
        return numberCallout(numberList,'Rollback');
    }

    /**************************************************************************************
    ****** Desc         : return status from callout
    ****** Developer    : Sonalisa Verma
    ***************************************************************************************/

    private static string numberCallout(List<String> numberList, string actionType){
        system.debug('numberList>>>>>'+ numberList);
        NumberReservationFixedHandler.ResponseWrapper responseWrapperList = callUNMSToSyncNumbers(numberList,actionType);
        system.debug('responseWrapperList>>>>>'+ responseWrapperList);
        if(responseWrapperList.errList != null){
            String status='';
            for(NumberReservationFixedHandler.ErrorList error : responseWrapperList.errList){
                status = status + '\n'+ error.resourceId + '-'+ error.message;
            }
            system.debug('Status>>>>>'+ status);
            return status;
        }   
        if((responseWrapperList.resIds != null && responseWrapperList.resIds.size()>0) 
            || (responseWrapperList.stRange != null && responseWrapperList.stRange.size()>0)){
            return 'Success';
        } 
        
        return '';
    }
    
}