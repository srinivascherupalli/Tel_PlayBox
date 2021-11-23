/*************************************************************************************************
Name : UNMSNumberReservationUtil
Description : Callout class for UNMS Number Rservation for IOT & CWP
Author: Ila/Kiran
Story: DPG-1802 & DPG-1797
Revision : 
DPG-1803 19 May 2020 Kiran
***************************************************************************************************/
public with sharing class UNMSNumberReservationUtil {
    
    public static String HTTP422UNMS = 'The request is invalid due to a missing mandatory parameter or an invalid parameter value';
    public static String HTTP409UNMS = 'Downstream is not allowing the operation to be performed due to resource state violation';
    
    /* Method - UNMSautoReserveMSISDN
    * Description - Method to Auto Reserve IoT Mobile numbers
    * Parameters - Basket Map, Qty
    * Return Type - String
    */ 
    public static String UNMSautoReserveMSISDN(Map<Id,Map<List<csord__service__c>,List<String>>> basketMap,Integer searchQuan){
        List<String> lstfinaltoReserve = new List<String>();
        String status = 'No Number found.';    
        Integer lstfinaltoReserveCnt = 0;
        String failedOrderId = '';
        FNNSearchResponseDTO fnnResponse = new FNNSearchResponseDTO ();
        if ((searchQuan != NULL && searchQuan > 0))
        {
            
            FNNSearchRequestDTO fnnDto = new FNNSearchRequestDTO();
            FNNSearchRequestDTO.data fdo=new FNNSearchRequestDTO.data();
            fdo.quantity = searchQuan;
            fdo.resourceType = 'Mobile';
            fdo.activityName = 'Reserve Next Available';  
            fnnDto.data = fdo;
            fnnResponse = UNMSsearchFNN(fnnDto);
            if(fnnResponse != NULL && fnnResponse.data != NULL && fnnResponse.data.resources != NULL){
                
                for(FNNSearchResponseDTO.Resources res : fnnResponse.data.resources){
                    lstfinaltoReserve.add(res.resourceId);
                    system.debug('lstfinaltoReserve+' +lstfinaltoReserve);
                }
                
            }
            lstfinaltoReserveCnt=lstfinaltoReserve.size();
            if(!lstfinaltoReserve.isEmpty()){
                 for (Id basket : basketMap.keySet())
                     {
                        Map<List<csord__service__c>,List<String>> mapOfserviceToNumber = basketMap.get(basket);
                        for (List<csord__service__c> serviceList : mapOfserviceToNumber.KeySet()) 
                            {
                                for(integer i=0;i<serviceList.size();i++)
                                    {
                                        if(lstfinaltoReserveCnt > 0){
                                        List<String> serviceMsisdn = mapOfserviceToNumber.get(serviceList);
                                        serviceMsisdn.add(lstfinaltoReserve[i]);
                                    if(fnnResponse.responseCode != null ){
                                        if(fnnResponse.responseCode.equalsIgnoreCase('UNMSPARTIAL_SUCCESS'))
                                            failedOrderId = String.ValueOf(serviceList[0].csord__Order__c);
                                            }
                                        lstfinaltoReserveCnt--;

                                    system.debug('inside loop...'+serviceMsisdn+'  lstfinaltoReserveCnt '+lstfinaltoReserveCnt);
                                    }
                                  }

                            }
                    }
                
                String res = UNMSsaveReserveMSISDN(basketMap);
                status = res;
                if(!failedOrderId.equals(''))
                   status +='~'+failedOrderId;         
            }
             system.debug('status++' +status);
            
        }
        return status;
    }
    
    
    /* Method - UNMSsearchFNN
    * Description - Method to CallOut UNMS IoT Mobile numbers
    * Parameters - FNNSearchRequestDTO
    * Return Type - FNNSearchResponseDTO
    */
    public static FNNSearchResponseDTO UNMSsearchFNN(FNNSearchRequestDTO fnnDto){
        String handlerName = 'SearchFNN';
        String reqBody = JSON.serialize(fnnDto,true);
        Logger2 logger = Logger2.getLogger(handlerName);
        FNNSearchResponseDTO fnnRes = new FNNSearchResponseDTO() ;
        HttpResponse adResponse;
        system.debug('Inside FNN Service::searchFNN..');
        try {
            String token = AuthenticationManager.getOauthToken(handlerName);
            //String token = 'MLhlJPHAFdP38Z1CsAnEI1EDts6h'; //Kiran - To be removed
            String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
            system.debug('correlationId****'+correlationId);
            
            DateTime startTime = DateTime.now();
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation_Id'=> +correlationId};
                adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
            
            DateTime endTime = DateTime.now();
            system.debug('requestTime>>>'+startTime + '>>>>' + endTime);
            Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
            system.debug('requestTime>>>'+requestTime);
            system.debug('adResponse::'+adResponse.getBody());
            
            if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                fnnRes = FNNSearchResponseDTO.parse(adResponse.getBody());
                
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', 
                                   '', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Create','',requestTime ,'POST',false, false);
            }
            else if(adResponse.getStatusCode() == 422){
                fnnRes = FNNSearchResponseDTO.parse(adResponse.getBody());
                 logger.logMessages(reqBody, adResponse.getBody(), '', '', '', 
                                   '', String.valueOf(adResponse.getStatusCode())+' : '+HTTP422UNMS + ' : '+fnnRes.responseCode, correlationId, '','','Create','',requestTime ,'POST',false, false);
            
              } else if(adResponse.getStatusCode() == 409){
                fnnRes = FNNSearchResponseDTO.parse(adResponse.getBody());
                   logger.logMessages(reqBody, adResponse.getBody(), '', '', '',
                                   '', String.valueOf(adResponse.getStatusCode())+' : '+HTTP409UNMS, correlationId, '','','Create','',requestTime ,'POST',false, false);
            
              }
            else{
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', 
                                   '', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Create','',requestTime ,'POST',false, false);
            }
            logger.exitLogger();
        }
        catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        
        system.debug('fnnRes++' +fnnRes);
        return fnnRes;
    }
    
    /* Method - UNMSsaveReserveMSISDN
    * Description - Method to Save UNMS Mobile numbers
    * Parameters - fnnListToSave,basketIdList
    * Return Type - FNNSearchResponseDTO
    */
     public static String UNMSsaveReserveMSISDN(Map<Id,Map<List<csord__service__c>,List<String>>> basketMap){
    //public static String UNMSsaveReserveMSISDN(List<String> fnnListToSave, String basketId){
        System.debug('basketMap inside method: '+basketMap);
        String status=null;
        Number__c msisdn = null;
        //List<cscfga__Product_Basket__c> basketDetail = [SELECT cscfga__Opportunity__c,csbb__Account__c FROM cscfga__Product_Basket__c WHERE ID=:basketid ]; //TBR
         List<cscfga__Product_Basket__c> basketDetail = [SELECT Id,cscfga__Opportunity__c,csbb__Account__c FROM cscfga__Product_Basket__c WHERE ID in :basketMap.KeySet() ]; 

        List<Number__c> msisdnListToSave = null;

        for (integer j =0;j<basketDetail.size();j++)
                    {
                        Map<List<csord__service__c>,List<String>> mapOfserviceToNumber = basketMap.get(basketDetail[j].id);
                        
                        for (List<csord__service__c> serviceList : mapOfserviceToNumber.KeySet())
                            {
                                    List<String> msisdnLst =null;
                                    try{
                                    if(mapOfserviceToNumber.get(serviceList)!=null)
                                        {
                                            msisdnListToSave = new List<Number__c>();
                                            msisdnLst = new List<String>();
                                            Integer counter = 0;
                                            for(String msisdns : mapOfserviceToNumber.get(serviceList)){
                                            msisdn = new Number__c();
                                            msisdn.Service_Number__c = msisdns;
                                            msisdn.Basket__c = basketDetail[j].id;
                                            msisdn.Type__c = 'New';
                                            msisdn.Mobile__c='Mobile';
                                            msisdn.ListingCode__c='No Entry Line';
                                            msisdn.Account__c = !basketDetail.isEmpty()? basketDetail[j].csbb__Account__c : null;
                                            msisdn.status__c='RESERVED';
                                            msisdn.Service_Id__c =serviceList[counter].csordtelcoa__Service_Number__c;
                                            msisdn.Product_Configuration__c =serviceList[counter].csordtelcoa__Product_Configuration__c;
                                            msisdnListToSave.add(msisdn);
                                            system.debug('msisdnListToSave+' +msisdnListToSave);
                                            counter++;
                                            }
                                          
                                        }
                                        else{
                                           status = 'SaveError';
                                        }
                                    }
                                    catch(Exception e){
                                          status = 'SaveError';
                                        }   
                                }
                        }
                        if(msisdnListToSave!=null && !msisdnListToSave.isEmpty()){
                           insert msisdnListToSave ;
                           status = 'Success';
                        }
                
     
        return status;
    }
    
    /* Method - createFallbackTask
    * Description - DPG-1803 Method to Create Fallback Task in UNMS CallOut in Order prerequiste
    * Parameters - Order
    * Return Type - void
    */
    public static void createFallbackTask(Map<Id,csord__Order__c> mapOrder)
    {
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('General').getRecordTypeId();
        List<Task> taskList = new List<Task>();
        for(Id key : mapOrder.keySet()){
            Task taskRecord = new Task();
            taskRecord.ActivityDate = date.today();
            taskRecord.RecordTypeId = taskRecordTypeId;
            taskRecord.Subject = Label.DPGTasksubject;
            taskRecord.Description = Label.DPGTaskDesc+' : '+mapOrder.get(key).csord__Order_Number__c;
            taskRecord.Priority = 'High';
            taskRecord.Status = 'Not Started';
            taskRecord.WhatId = key;
            taskRecord.OwnerId = mapOrder.get(key).CreatedById;
            taskList.add( taskRecord );
        }
        insert taskList;
        system.debug('task list &&&' +taskList);
      }
}