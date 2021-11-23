/*********************************************************************************************************************************
Class Name : PortOutNumberNGUCController
Test Class : PortOutNumberNGUCControllerTest
Created By : Shashank
Created On : 18 May 2021
User Story : EDGE - 205921 B2B-1260 : Remove, Lock & Port-Out Scenarios
***********************************************************************
1.Pawan Devaliya       08-Sep-2021        DIGI-18183: Added new parameter in payload : Fulfilment Order Version
2.Rashmi               27-10-2021         DIGI-35918 
***************************************************************************************************
*/
public with sharing class PortOutNumberNGUCController {

    private static final String CONST_INTERFACENAME = 'PortOutNumberNGUCController';
    private static String correlationId = GuidUtil.NewGuid();
 
     //This method returns the number wrapper in case of onscreen retrival. 
    @AuraEnabled
      public static List<NumberWrap> fetchNumbers( List<String> subscriptionIdList) {
          try{            
            // System.debug('subscriptionIdList'+subscriptionIdList);
            List<NumberWrap> wrapList = new List<NumberWrap>();
            List<Number__c> numberList = new List<Number__c>();  
            List<String> subNumberList = new List<String>();
            Map<String,csord__Subscription__c> subNumberMap = new Map<String,csord__Subscription__c>();      
            for(csord__Subscription__c subObj : [select csordtelcoa__Subscription_Number__c,customerFacingServiceId__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where Id=:subscriptionIdList   ]){
                subNumberMap.put(subObj.csordtelcoa__Subscription_Number__c,subObj);
            }
            // System.debug('subNumberMap'+ subNumberMap);
        
            if(subNumberMap.isEmpty()){
                return wrapList;
            }

            for(Number__c numberObj : [select Id,Service_Number__c, Service_Id__c,status__c, Number_Range__c,Number_Group__c,Subscription_number__c from Number__c where  Locked_By__c = 'Phoenix UI' AND Subscription_number__c=:subNumberMap.keySet() AND status__c ='Locked' AND Mobile__c = 'Fixed' order by Subscription_number__c ]){
            NumberWrap wrapObj = new  NumberWrap(); 
        
                wrapObj.numberId = numberObj.Id;
                wrapObj.serviceNumber = numberObj.Service_Number__c;
                wrapObj.recordCount = numberList.size();
                wrapObj.status = numberObj.status__c;           
                wrapObj.subscriptionNumber = numberObj.Subscription_number__c;
                wrapObj.serviceId = numberObj.Service_Id__c;
                wrapObj.range =  numberObj.Number_Range__c;
                
                wrapList.add(wrapObj);
            }
            // System.debug('wrapList-'+wrapList);
            return wrapList;
        }
        catch(Exception ex){
            // System.debug('Exception -'+ex.getMessage());
            List<NumberWrap> wrapList = new List<NumberWrap>();
            return wrapList;
        }
    }
    //DIGI-35918 added contact Id
    @AuraEnabled
    public static String createPortOutOrder(String accountId , String numbersWrapStr, String contactId){
        // ng - Subscription_Number__c (SN-000229898) field to fetch sub's NG || csordtelcoa__Subscription_Number__c    
            // System.debug('-accountId'+accountId);
            // System.debug('numbersWrapStr-'+numbersWrapStr);
            try {
                List<NumberWrap> listNumbersWrap =(List<NumberWrap>)JSON.deserialize(numbersWrapStr, List<NumberWrap>.class); 
                // System.debug('listNumbersWrap-'+listNumbersWrap);
                String accId = accountId;
                Set<String> setSubNumb = new Set<String>(); 
                Set<String> setNumbId = new Set<String>();
                List<Number__c> listNumbers = new List<Number__c>();
                Map<String , List<Number__c>> mapSubListNumb = new Map<String , List<Number__c>>();
                for (NumberWrap numbWrapObj : listNumbersWrap) {
                    setNumbId.add(numbWrapObj.numberId);
                }

                for (number__C  numb  :  [SELECT Id,Number_Group__c,Locked_By__c, Status__c,Subscription_number__c  FROM Number__c WHERE Id IN : setNumbId ]) {
                    if(!mapSubListNumb.containskey(numb.Subscription_number__c ) && numb.Subscription_number__c !=NULL ){
                        mapSubListNumb.put(numb.Subscription_number__c ,new List<Number__c>{numb});
                    }else if(mapSubListNumb.containskey(numb.Subscription_number__c ) && numb.Subscription_number__c !=NULL ) {
                        mapSubListNumb.get(numb.Subscription_number__c).add(numb);
                    }
                    listNumbers.add(numb);
                }

                // System.debug('setNumbId-'+setNumbId);
                // System.debug('mapSubListNumb-'+mapSubListNumb);
                
                // fetching sub for order name 
                List<csord__Subscription__c> listSubscription = new List<csord__Subscription__c>([select csordtelcoa__Subscription_Number__c,customerFacingServiceId__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where csordtelcoa__Subscription_Number__c IN:mapSubListNumb.keyset()  and csord__Status__c='Active']);
                


                List<Number_Group__c> numberGroupList = new List<Number_Group__c>();
                String parentOrderNumb = ( (!listSubscription.isEmpty() &&  listSubscription[0].csord__Order__r.csord__Order_Number__c!=NULL) ? listSubscription[0].csord__Order__r.csord__Order_Number__c : '');
                csord__Order__c ord = new csord__Order__c();
                ord.Name = parentOrderNumb + '_PortOut_Order';  
                ord.csord__Account__c = accountId;
                ord.Scenario_Type__c = 'Manage Fixed Numbers';
                ord.csord__Status2__c  = 'Order Submitted';
                ord.csord__Identification__c = parentOrderNumb + '_PortOut_Order';
                ord.Order_Requester__c = contactId;
				//DIGI-32827 Changes
				ord.csord__Start_Date__c = Date.today();
				ord.telstra_ord_Start_DateTime__c = System.now();
                if(csord__Order__c.SObjectType.getDescribe().isAccessible()){
                    insert ord;
                }
                //  create NG/sub  
                // System.debug('insert NG');
                Map<String, Number_Group__c> mapSubNumbGrp = new Map<String, Number_Group__c>();
                for (string  subNum : mapSubListNumb.keyset() ) {
                    Number_Group__c numberGroup = new Number_Group__c();
                    numberGroup.Subscription_Number__c =  subNum; //listSubscriptionDet[0].subscriptionNumber;
                    numberGroup.Status__c = 'Disconnect Pending';
                    numberGroup.Scenario_Type__c = 'Port Out';
                    numberGroup.OrderId__c = ord.Id;
                    numberGroupList.add(numberGroup);
                }

                
                if(!numberGroupList.isEmpty()  &&  Number_Group__c.SObjectType.getDescribe().isAccessible()){
                    insert numberGroupList;
                    for( Number_Group__C numGrpObj : numberGroupList){
                        mapSubNumbGrp.put(numGrpObj.Subscription_Number__c,numGrpObj);
                    }
                }

                List<number__C> listNumb = new List<number__C>();
                for (number__C  numb  :  listNumbers) {
                    numb.status__c= 'Disconnect Pending';
                    numb.locked_By__c = null ;
                    numb.Number_Group__c  =    (( mapSubNumbGrp.containskey(numb.Subscription_number__c) && mapSubNumbGrp.get(numb.Subscription_number__c) !=NULL ) ? mapSubNumbGrp.get(numb.Subscription_number__c).Id : ''  ) ; 
                    listNumb.add(numb);
                }
                if (!listNumb.isEmpty()  && number__C.SObjectType.getDescribe().isAccessible() ) {
                    update listNumb;
                }

                List<csord__Order__c> orders = new  List<csord__Order__c>([SELECT Id,csord__Account__r.CIDN__c ,csord__Order_Number__c, Fulfilment_Order_Version__c    FROM csord__Order__c WHERE Id =: ord.Id]);
                //Method to publish platform events
                  //DIGI-18183
                NumberReservationHelper.publishPlatformEvents(orders[0].Id,orders[0].csord__Order_Number__c,orders[0].csord__Account__r.CIDN__c, orders[0].Fulfilment_Order_Version__c);
                User userObj = [select id,Name,ContactId,Profile.Name,Contact.AccountId from User where id =: userInfo.getUserId() WITH SECURITY_ENFORCED ];
                if(Label.PRM_Community_User_Profile.contains(userObj.Profile.Name)){
                    return PRMBaseURLUtility.getBaseURLForCommunityUser()+'/'+ord.Id;
                } 
                return System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+ord.Id;
            
            } catch (Exception e) { 
                NumberReservationHelper.logException('createOrder','',correlationId, e.getMessage(), 'Create order',CONST_INTERFACENAME);
                return system.label.MACD_Add_order_error_msg;
            }        

    }
        //Created as part of DIGI-27804 to unlock numbers 
    @AuraEnabled 
    public static void unlockFNN(String numberWrapperString){
        List<NumberWrap> listNumbersWrap =(List<NumberWrap>)JSON.deserialize(numberWrapperString, List<NumberWrap>.class); 
        List<Number__c> numberUpdateList = new List<Number__c>();
        for(NumberWrap wrapObj : listNumbersWrap){
            Number__c numObj = new Number__c(Id = wrapObj.numberId);
            numObj.Locked_By__c = null;
            numObj.Status__c = 'Active';
            numberUpdateList.add(numObj);
        }
        if(!numberUpdateList.isEmpty()){
            update numberUpdateList;
        }
    }



    public class NumberWrap {
        
        
        @AuraEnabled public String serviceNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String numberId;
        @AuraEnabled public String serviceId;
        @AuraEnabled public String range;
        @AuraEnabled public Integer recordCount;
        @AuraEnabled public String subscriptionNumber;
    }
        
    public class SubscriptionDetails{
        @AuraEnabled public string subscriptionId;
        @AuraEnabled public String subscriptionNumber;
        @AuraEnabled public String orderNumber;
    }
        
    }