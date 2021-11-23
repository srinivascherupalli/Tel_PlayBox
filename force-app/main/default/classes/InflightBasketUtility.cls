/******************************************************************************************************
    *Class Name     : InflightBasketUtility
    *Test Class     : InflightBasketUtilityTest

Ch.No.    Developer Name          Date          Story Description
_________________________________________________________________
1.        Arinjay Singh           15.12.2020    EDGE-191125
2.        Martand Atrey           16.12.2020    EDGE-191125
3.        Pooja Gupta             16.12.2020    EDGE-191125
4.        Martand Atrey           06.01.2021    EDGE-195759
5.        Arinjay Singh           12.01.2021   EDGE-191125 Modified Methods as per suggestions
6.        Vamsi Krishna Vaddipalli 27.01.2021   EDGE-192911
7.        Pooja Bhat              18.01.2021    EDGE-170420
8.        Shweta Khandelwal        05.02.2021    EDGE-192752
9.        Venkat T                 08.02.2021    EDGE-198709
10.       Arunkumar V              08.02.2021    EDGE-201336
11.      Antun Bartoniček      09.09.2021.  R34UPGRADE
*******************************************************************************************************/

public class InflightBasketUtility {
  @AuraEnabled
  public static boolean doesSolutionExistInBasket(String targetBasketId, String oldSolutionId) {
    try {
        List<csord__Solution__c> solutionList = [SELECT cssdm__replaced_solution__c 
            FROM csord__Solution__c 
            WHERE cssdm__product_basket__c = :targetBasketId AND cssdm__replaced_solution__c = :oldSolutionId];
      if (solutionList.size() > 0) {
        return true;
      }
    } catch (Exception ex) {
      System.debug('InflightBasketUtility.doesSolutionExistInBasket' + ex.getLineNumber() + ' ' + ex.getMessage());
    }
    return false;
  }

  @AuraEnabled
  public static cscfga__Product_Basket__c doesInflightBasketExist(csord__Order__c ordRec) {
    try {
     // csord__Order__c ordRec = [SELECT id, csordtelcoa__Opportunity__c FROM csord__Order__c WHERE id = :orderId];
      system.debug('ordRec' + ordRec);
      List<cscfga__Product_Basket__c> prodBasketList = [
        SELECT id, csordtelcoa__Basket_Stage__c, RecordType.Name, cscfga__Opportunity__c
            FROM cscfga__Product_Basket__c
            //WHERE (csordtelcoa__Basket_Stage__c = 'Draft' OR csordtelcoa__Basket_Stage__c = 'Commercial Configuration') 
            WHERE  RecordType.Name = 'Inflight Change' AND cscfga__Opportunity__c = :ordRec.csordtelcoa__Opportunity__c
            ORDER BY CreatedDate desc LIMIT 1
      ];
      System.debug('prodBasketList' + prodBasketList);
      if (!prodBasketList.isEmpty() && prodBasketList != null) {
        return prodBasketList.get(0);
      }
    } catch (Exception e) {
      System.debug('InflightBasketUtility.doesInflightBasketExist' + e.getLineNumber() + ' ' + e.getMessage());
    }
    return null;
  }

  // @AuraEnabled
  // public static ResultWrapper pushSolutionToHeroku(List<Map<String, String>> requestMapsList) {
  //   /*   Map<String, String> requestMap = new Map<String, String>{
    //           'replacedSolutionId' => replacedSolutionId,
    //           'targetSolutionId' => targetSolutionId,
    //           'targetBasketId' => basketId,
    //           'targetMainConfigurationId' => targetMainConfig,////added by shubhi for Parallel macd fix
    //           'changeType' => 'Change Request'
            
    //       }; */
  //   ResultWrapper resWrapper = new ResultWrapper();
  //   resWrapper.isSuccess = true;
  //   resWrapper.errorList = new List<String>();
  //   if (requestMapsList != null) {
  //     for (Map<String, String> reqMap : requestMapsList) {
  //       try {
  //         //System.debug('**** pushSolutionToHeroku ' + reqMap);
  //         cssmgnt.SolutionMACDController.createHerokuMACDSolution(reqMap);
  //       } catch (Exception e) {
  //         resWrapper.isSuccess = false;
  //         resWrapper.errorList.add('Exception: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
  //         //Logger2 logger = Logger2.getlogger('InflightSolutionController pushSolutionToHeroku');
  //         //logger.logMessages('', '', '', 'InflightSolutionController pushSolutionToHeroku', 'Exception',e.getMessage(), false, false);
  //         System.debug('InflightBasketUtility.pushSolutionToHeroku' + e.getLineNumber() + ' ' + e.getMessage());
  //       }
  //     }
  //   }
  //   return resWrapper;
  // }

  @AuraEnabled
  public static String pushSolutionToHeroku(String serData, String targetMainConfigurationId) {
    /*   Map<String, String> requestMap = new Map<String, String>{
              'replacedSolutionId' => replacedSolutionId,
              'targetSolutionId' => targetSolutionId,
              'targetBasketId' => basketId,
              'targetMainConfigurationId' => targetMainConfig,////added by shubhi for Parallel macd fix
              'changeType' => 'Change Request'
            
      }; */
    String result='';
    List<Map<String, String>> data=(List<Map<String, String>>)JSON.deserialize(serData,List<Map<String, String>>.class);
    ResultWrapper resWrapper = new ResultWrapper();
    resWrapper.isSuccess = true;
    resWrapper.errorList = new List<String>();
    if (serData != null) {
      for (Map<String, String> dataToPush : data) {
        try {
          dataToPush.put('targetMainConfigurationId',targetMainConfigurationId);
          cssmgnt.SolutionMACDController.createHerokuMACDSolution(dataToPush);
          result='SUCCESS';
        } catch (Exception e) {
          resWrapper.isSuccess = false;
          resWrapper.errorList.add('Exception: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
          System.debug('InflightBasketUtility.pushSolutionToHeroku' + e.getLineNumber() + ' ' + e.getMessage());
          Logger2 logger = Logger2.getlogger('InflightSolutionController');
          logger.logMessages('', '', '', 'Technical', 'Exception',e.getLineNumber() + ' ' + e.getMessage(), false, false);
          logger.exitLogger();
          result='ERROR';
        }
      }
    }
    return result;
  }

  public class ResultWrapper {
    @AuraEnabled
    public Boolean isSuccess { get; set; }
    @AuraEnabled
    public List<String> errorList { get; set; }
  }

    //Created by Pooja for checking the basket subscription result
  // @AuraEnabled
  // public static boolean checkJobStatus(String targetBasketid) {
  //   if(1==1) return true;
  //   try {
  //     string checkJobStatusResponse = '';
  //     csordtelcoa.StatusResult jobStatus = csordtelcoa.API_V1.pollBasketSubscriptionsResult(targetBasketID);
  //     if (jobStatus == null && Test.isRunningTest()) {
  //       checkJobStatusResponse = 'SUCCESS';
  //     } else {
  //       if (jobStatus != null) {
  //         checkJobStatusResponse = string.valueof(jobStatus.status);
  //       }
  //     }
  //     if (checkJobStatusResponse.containsIgnoreCase('SUCCESS'))
  //       return true;
  //   } catch (Exception e) {
  //     System.debug('InflightBasketUtility.checkJobStatus' + e.getLineNumber() + ' ' + e.getMessage());
    //         return false;
  //   }
  //   return false;
  // }

  // Added by Arinjay 11.01.2021
  @AuraEnabled
  public static String getJobStatus(String targetBasketid) {
    try {
        List<csutil__Async_Task_Data__c> lstJobs = [Select id,csutil__status__c from csutil__Async_Task_Data__c 
          where csutil__linked_object_id__c =: targetBasketid 
          and csutil__status__c !='PROCESS_AFTER_FINISH'];

      if(lstJobs!=null && lstJobs.size() > 0)
        return 'FAILURE';
      else
        return 'SUCCESS';
    } catch (Exception e) {
     /* Logger2 logger = Logger2.getlogger('InflightSolutionController');
      logger.logMessages('', '', '', 'Technical', 'Exception','checkJobStatus  >>  ' + e.getMessage(), false, false);
      logger.exitLogger();*/
            return 'ERROR';
    }
  }


  public static String getTargetMainConfigurationId(String targetBasketID, String replacedMainConfigurationId){
      String targetMainConfigId; //R34UPGRADE deliberately not defaulting to '' but to undefined as R34 will not have main PC until solution is saved
    try {
        List<cscfga__Product_Configuration__c> listPC =  [SELECT Id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: targetBasketID
        AND csordtelcoa__Replaced_Product_Configuration__c =: replacedMainConfigurationId];
  
        Logger2 logger = Logger2.getlogger('InflightSolutionController');
        logger.logMessages('', '', '', 'Technical', 'Exception',
        'SELECT Id from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =' +  targetBasketID
        + 'AND csordtelcoa__Replaced_Product_Configuration__c =' +  replacedMainConfigurationId, false, false);
      logger.exitLogger();

      if(listPC!=null && listPC.size()>0)
        targetMainConfigId = listPC.get(0).Id;
  
    } catch (Exception e) {
      /*Logger2 logger = Logger2.getlogger('InflightSolutionController');
      logger.logMessages('', '', '', 'Technical', 'Exception',e.getLineNumber() + ' ' + e.getMessage(), false, false);
      logger.exitLogger();*/
    }
    return targetMainConfigId;
  }

  public static List<Map<String, String>> createInFlightBasket(String orderId, List<String> oldSolutionIds) {
    List<Map<String, String>> solutionList = new List<Map<String, String>>();
    try {
        System.debug('Check InflightBasketUtility.createInFlightBasket oldSolutionIds : ' + oldSolutionIds);
        ResponseList responseList = null;
        ResponseWrapper responseWrapper = null;
        csord__Order__c ordRec = [SELECT id, csordtelcoa__Opportunity__c,csord__Status2__c FROM csord__Order__c WHERE id = :orderId]; //shweta
        cscfga__Product_Basket__c targetBasket =  InflightBasketUtility.doesInflightBasketExist(ordRec);
        String targetBasketId = null;
        Integer i=0;
        System.debug('targetBasket '+targetBasket);
        if(targetBasket !=  null &&!(targetBasket.csordtelcoa__Basket_Stage__c == 'Draft' 
                                || targetBasket.csordtelcoa__Basket_Stage__c == 'Commercial Configuration'
                                || targetBasket.csordtelcoa__Basket_Stage__c == 'Submitted'
                                || targetBasket.csordtelcoa__Basket_Stage__c == 'Cancelled'))
                                {
            Map<String,String> errorList = new Map<String,String>();
            String errorMessage = 'Basket creation failed as there is an existing inflight basket.';
            if(ordRec.csord__Status2__c == 'Amend Rejected'){
                errorMessage = 'Basket creation failed as there is no valid in-flight basket for remediation';
            }
            errorList.put('errorMessage',errorMessage);
            solutionList.add(errorList);
            return solutionList;
        }
        System.debug('arinjay size of old solution ids list ' + oldSolutionIds.size());
        if(targetBasket == null || // When basket does not exist
            (targetBasket !=null && (targetBasket.csordtelcoa__Basket_Stage__c == 'Cancelled' || targetBasket.csordtelcoa__Basket_Stage__c == 'Submitted'))
                   && oldSolutionIds.size() > 0) {
            System.debug('arinjay condition met  ');
                       System.debug('oldSolutionIds '+oldSolutionIds);
                       String response = '';
                       if(!Test.isRunningTest()){           
             response = cssmgnt.API_1.createInflightRequest(oldSolutionIds[0]);
                       }
            i=1;
            System.debug('arinjay response ' + response);
            if(response.contains('Error')){
                Map<String,String> errorList1 = new Map<String,String>();
                errorList1.put('errorMessage',response);
                System.debug('resp'+response);
                solutionList.add(errorList1);
                return solutionList;
            }
            responseList = new ResponseList();
            if (Test.isRunningTest()) {
            response = '{"ResponseList" : [{"targetMainConfigurationId":"a3T4Y0000006IANUA2","changeType":"Inflight","replacedMainConfigurationId":"a3T4Y0000006I9UUAU","targetBasketId":"'+targetBasket.Id+'","targetSolutionId":"a4f4Y0000000WavQAE","replacedSolutionId":"a4f4Y0000000WaWQAU"}]}';
            } else {
            response = '{"ResponseList" : [' + response + ']}';
            }
            System.debug('Response: ' + response);
            Logger2 logger = Logger2.getlogger('InflightSolutionController');
            logger.logMessages('', '', '', 'Technical', 'Response from basket creation ',response, false, false);
            logger.exitLogger();
            responseList = (ResponseList) System.JSON.deserialize(response, ResponseList.class);
            System.debug('responseList' + responseList);
            responseWrapper = responseList.ResponseList[0];
            System.debug('targetMainConfigurationId = ' + responseWrapper.targetMainConfigurationId);
            targetBasketId = responseWrapper.targetBasketId;
            System.debug('Check InflightBasketUtility.createInFlightBasket Basket Exists : ' + targetBasketId);

            targetBasket = [Select Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c where Id =: targetBasketId];
            if (responseWrapper != null) {
                // Push in Solution List
                Map<String, String> dataMap = new Map<String, String>();
                dataMap.put('targetMainConfigurationId', responseWrapper.targetMainConfigurationId);
                dataMap.put('changeType', responseWrapper.changeType);
                dataMap.put('replacedMainConfigurationId', responseWrapper.replacedMainConfigurationId);
                dataMap.put('targetBasketId', responseWrapper.targetBasketId);
                dataMap.put('targetSolutionId', responseWrapper.targetSolutionId);
                dataMap.put('replacedSolutionId', responseWrapper.replacedSolutionId);
        
                solutionList.add(dataMap);
            }
        } 
      
        // Add Remaining Solutions
        targetBasketId = targetBasket.id;
        for (;i < oldSolutionIds.size(); i++) {
            System.debug('Check In Loop');
            System.debug('Check Result ' + InflightBasketUtility.doesSolutionExistInBasket(targetBasketId, oldSolutionIds[i]));
            if (!InflightBasketUtility.doesSolutionExistInBasket(targetBasketId, oldSolutionIds[i])) {
              System.debug('Check In Condition');
              String response = cssmgnt.API_1.addSolutionToChange(targetBasketId, oldSolutionIds[i]);
              System.debug('Check response ' + response);
              responseList = new ResponseList();
              if (Test.isRunningTest()) {
                response = '{"ResponseList" : [{"targetMainConfigurationId":"a3T4Y0000006IANUA2","changeType":"Inflight","replacedMainConfigurationId":"a3T4Y0000006I9UUAU","targetBasketId":"a3Q4Y0000003tF1UAI","targetSolutionId":"a4f4Y0000000WavQAE","replacedSolutionId":"a4f4Y0000000WaWQAU"}]}';
              } else {
                response = '{"ResponseList" : [' + response + ']}';
              }
              responseList = (ResponseList) System.JSON.deserialize(response, ResponseList.class);
              System.debug('Check responseList' + responseList);
              responseWrapper = responseList.ResponseList[0];
              System.debug('targetMainConfigurationId = ' + responseWrapper.targetMainConfigurationId);
              System.debug('Check InflightBasketUtility.createInFlightBasket Adding Solution : ' + oldSolutionIds[i]);
    
              if (responseWrapper != null) {
                // Push in Solution List
                Map<String, String> dataMap = new Map<String, String>();
                dataMap.put('targetMainConfigurationId', responseWrapper.targetMainConfigurationId);
                dataMap.put('changeType', responseWrapper.changeType);
                dataMap.put('replacedMainConfigurationId', responseWrapper.replacedMainConfigurationId);
                dataMap.put('targetBasketId', responseWrapper.targetBasketId);
                dataMap.put('targetSolutionId', responseWrapper.targetSolutionId);
                dataMap.put('replacedSolutionId', responseWrapper.replacedSolutionId);
        
                solutionList.add(dataMap);
              }
            }
          }
    } catch (Exception e) {
      System.debug('&&&&&& InflightBasketUtility.createInFlightBasket' + e.getLineNumber() + ' ' + e.getMessage());
      Logger2 logger = Logger2.getlogger('InflightSolutionController');
      logger.logMessages('', '', '', 'Technical', 'updateBasket',e.getLineNumber() + ' ' + e.getMessage(), false, false);
      logger.exitLogger();
    }
    return solutionList;
  }
  public class ResponseList {
    public List<ResponseWrapper> ResponseList;
  }

  public class ResponseWrapper {
    public string targetMainConfigurationId { get; set; }
    public string changeType { get; set; }
    public string replacedMainConfigurationId { get; set; }
    public string targetBasketId { get; set; }
    public string targetSolutionId { get; set; }
    public string replacedSolutionId { get; set; }
  }

  @AuraEnabled
  public static boolean updateBasket(String targetBasketId, String ammendType, String tconCaseID) {
      
    try {
      Logger2 logger = Logger2.getlogger('InflightSolutionController');
      logger.logMessages('', '', '', 'Technical', 'updateBasket','basket id ' + targetBasketId + ' amend type ' + ammendType + ' caseid ' + tconCaseID , false, false);
      logger.exitLogger();
        cscfga__Product_Basket__c productBasket = [SELECT id, csordtelcoa__Basket_Stage__c,cscfga__Opportunity__c, Amend_Type__c, Name, Description__c, Bakset_Number_Format__c, SalesSupport_CaseNumber__c,csordtelcoa__Previous_Product_Basket__c FROM cscfga__Product_Basket__c WHERE id = :targetBasketId];// Added by Vamsi for previous basket
      //Added by Vamsi for EDGE-192911 on 27JAN21 starts
      String previousBasketId = productBasket.csordtelcoa__Previous_Product_Basket__c;
      cscfga__Product_Basket__c oldBasket = Model_ProductBasket.getProductBasket(previousBasketId);
        
        if(oldBasket != null && oldBasket.Primary_Basket__c == true)
        {
          if(oldBasket.Device_Care_Contact__c != null)
          productBasket.Device_Care_Contact__c = oldBasket.Device_Care_Contact__c;
          if(oldBasket.csconta__Frame_Agreement__c != null)
          productBasket.csconta__Frame_Agreement__c = oldBasket.csconta__Frame_Agreement__c;
            if(String.isNotBlank(oldBasket.Project_ID__c))
            productBasket.Project_ID__c = oldBasket.Project_ID__c;
        }
         //Added by Vamsi for EDGE-192911 on 27JAN21 ends
          csord__Order__c order = [select id, csordtelcoa__Opportunity__c,csord__Status2__c, Fulfilment_Order_Version__c, csord__Order_Number__c from csord__Order__c 
                                   where csordtelcoa__Opportunity__c =:productBasket.cscfga__Opportunity__c order by CreatedDate desc LIMIT 1];
            productBasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
      productBasket.Amend_Type__c = ammendType;
            productBasket.cscfga__total_contract_value__c = 0.0;
      productBasket.Description__c = 'Inflight Order_ ' + order.csord__Order_Number__c + '_' + order.Fulfilment_Order_Version__c + '_' + ammendType + 'Basket';
            //Shweta Added this EDGE: 192752
            if (order.csord__Status2__c == System.label.AmendRejectStatus) {
                productBasket.Description__c =
                    'In-flight of ' +
                    order.csord__Order_Number__c +'_'+
                    order.Fulfilment_Order_Version__c +
                    '_' +
                    productBasket.Amend_Type__c +
                    '_' +
                    'Remediation Basket';
                productBasket.BasketType__c = 'Remediate';
                //update productBasket;
            }
            // Shweta Ended here
      if(tconCaseID != '' && tconCaseID != null)
      productBasket.referencenumber__c = tconCaseID.toUpperCase();
      productBasket.Name = productBasket.Bakset_Number_Format__c;
      Database.SaveResult sr = Database.update(productBasket, false);
      if (sr.isSuccess()) {
        System.debug('Successfully updated the productBasket. ID: ' + sr.getId());
        return true;
      }
    } catch (Exception e) {
      System.debug('InflightBasketUtility.updateBasket' + e.getLineNumber() + ' ' + e.getMessage());
      Logger2 logger = Logger2.getlogger('InflightSolutionController');
      logger.logMessages('', '', '', 'Technical', 'updateBasket',e.getLineNumber() + ' ' + e.getMessage(), false, false);
      logger.exitLogger();
    }
    return false;
  }

  /**
     * Author: Pranit Bhong
     * Description: Method to update opp stage to devlope
     * EDGE-191078
     * Date : 11th Jan 2021
     */
    @AuraEnabled
    public static boolean updateOpportunity(String basketId) {
        List<cscfga__Product_Basket__c> inflightBasketList = new List<cscfga__Product_Basket__c>();
        inflightBasketList = [
            SELECT
                Id,
                cscfga__Opportunity__c,
                RecordType.Name,
                cscfga__Opportunity__r.CloseDate,
                cscfga__Opportunity__r.Original_Closed_Date__c,
                cscfga__Opportunity__r.No_of_reopened_requests__c
            FROM cscfga__Product_Basket__c
            WHERE Amend_Type__c != 'Non-Commercial' AND id = :basketId
        ]; //EDGE-170420: Added addtional field to Query
        //Shweta Added this EDGE: 192752
        csord__Order__c order = [
            SELECT id, csordtelcoa__Opportunity__c, csord__Status2__c
            FROM csord__Order__c
            WHERE csordtelcoa__Opportunity__c = :inflightBasketList[0].cscfga__Opportunity__c
            order by CreatedDate desc LIMIT 1
        ];
        system.debug('inflightBasketList++ ' + inflightBasketList);
        if(inflightBasketList.size()>0 && inflightBasketList[0].cscfga__Opportunity__c!=null){
            Opportunity opp = new Opportunity();
            opp.id = inflightBasketList[0].cscfga__Opportunity__c;
            opp.StageName = 'Develop';
            //EDGE-170420 START
            opp.Original_Closed_Date__c = (inflightBasketList[0].cscfga__Opportunity__r.Original_Closed_Date__c == null
                ? inflightBasketList[0].cscfga__Opportunity__r.CloseDate
                : inflightBasketList[0].cscfga__Opportunity__r.Original_Closed_Date__c);
            opp.No_of_reopened_requests__c = (inflightBasketList[0].cscfga__Opportunity__r.No_of_reopened_requests__c != null
                ? (inflightBasketList[0].cscfga__Opportunity__r.No_of_reopened_requests__c + 1)
                : 1);
            opp.Reopened_reason__c = 'Amend';
            //EDGE-170420 END
            //Shweta Added this EDGE: 192752
            if (inflightBasketList[0].RecordType.Name == 'Inflight Change') {
                if (order.csord__Status2__c == System.label.AmendRejectStatus) {
                    opp.Reopened_reason__c = 'Amend Remediation';
                }
            }
            System.debug('here ' + opp);
            //Shweta ended here
            update opp;
        }
        return true;
    }
        
  @AuraEnabled
  public static Map<boolean, boolean> getOrderDetails(String orderId) {
    Map<boolean, boolean> ponrReachedCancelPONRMap = new Map<boolean, boolean>();
    try {
      csord__Order__c ordRec = [SELECT id, csordtelcoa__Point_of_No_Return_Reached__c, cancel_Point_of_No_Return_Reached__c FROM csord__Order__c WHERE id = :orderId];
      ponrReachedCancelPONRMap.put(ordRec.csordtelcoa__Point_of_No_Return_Reached__c, ordRec.cancel_Point_of_No_Return_Reached__c);
    } catch (Exception e) {
      System.debug('InflightBasketUtility.getOrderDetails' + e.getLineNumber() + ' ' + e.getMessage());
    }
    return ponrReachedCancelPONRMap;
  }

  /**
   * Author: Martand Atrey
   * Refactored By : Shweta khandelwal & Arinjay Singh
   * Description: Method to send the 2 Attributes AllowAmend and AllowWithdrawl to Heroku
   * EDGE-195759
   * Date : 6th Jan 2021
   */
  public static Boolean pushConfigurationstoHeroku(Map<Id, csord__Service__c> servicesMap) {
    return InflightBasketUtility.pushConfigurationstoHeroku(servicesMap, null);
  }

    /**
   * Author: Shweta Khandelwal & Arinjay Singh
   * 
   * 
   * Date : 6th Jan 2021
   */

 public static Boolean pushConfigurationstoHeroku(Map<Id, csord__Service__c> servicesMap, Map<Id, Map<String, String>> serviceConfigurationMap) {
    Boolean result = false;
    try {
    cssmgnt.API_1 api = new cssmgnt.API_1();
    String response = '';
    Logger2 logger = Logger2.getlogger('InflightBasketUtility');

    Map<Id, List<csord__Service__c>> solServicesMap = new Map<Id, List<csord__Service__c>>();
    //Loop to create the Map for solution vs List of services 
    for(csord__Service__c service: servicesMap.values()){
        if(solServicesMap.containsKey(service.cssdm__solution_association__c)){
        solServicesMap.get(service.cssdm__solution_association__c).add(service);
        } else {
        solServicesMap.put(service.cssdm__solution_association__c, new List<csord__Service__c> { service });
        }
    }

    //Make callout for each service
    for (Id solutionId : solServicesMap.keySet()){
        Map<String, Map<String, String>> serviceConfigMap = new Map<String, Map<String, String>>();
        //create map for the payload to be sent for API
        for(csord__Service__c serviceRec : solServicesMap.get(solutionId)){
            if(serviceRec.csordtelcoa__Product_Configuration__c != null && serviceRec.csordtelcoa__Product_Configuration__r.configGUID__c != null){
                System.debug('trying to update ' + serviceRec.id);
                Map<String, String> configMap = null;
                if(serviceConfigurationMap != null && serviceConfigurationMap.size() > 0 ){
                    configMap = serviceConfigurationMap.get(serviceRec.id);
                }
                else{
                    configMap = new Map<String, String>{
                    Label.AllowAmend => ( serviceRec.csordtelcoa__Point_of_No_Return_Reached__c ? '' : 'Amend Allowed' ) ,
                    Label.AllowWithdrawal => ( serviceRec.cancel_Point_of_No_Return_Reached__c ? '' : 'Withdrawal Allowed' )
                };
                }
                if(configMap != null){
                    serviceConfigMap.put(serviceRec.csordtelcoa__Product_Configuration__r.configGUID__c, configMap);
                }
            }
        
            // EDGE-198709 -If services status is "Amend Rejected" then push Remediation Required attribute to Heroku
            if (serviceRec.csordtelcoa__Product_Configuration__c != null && serviceRec.csordtelcoa__Product_Configuration__r.configGUID__c != null && serviceRec.csord__Subscription__r.csord__Status__c=='Amend Rejected') {
                Map<String, String> configMap = new Map<String, String>{
                Label.AllowRemediation => (serviceRec.csord__Subscription__r.csord__Status__c =='Amend Rejected' ? 'Remediation Required':'')   
                };
                serviceConfigMap.put(serviceRec.csordtelcoa__Product_Configuration__r.configGUID__c, configMap);
            }
        }
        //Api call for updation on heroku
        System.debug('before calling api solutionId > ' + solutionId + ' serialized map ' + JSON.serialize(serviceConfigMap));
        response = api.updateConfigurations(solutionId, serviceConfigMap);
         System.debug('after calling api > ' + response);
        if(String.isNotBlank(response)) {
            result = true;
        } else {
            logger.logMessages( solutionId,  response,  '',  'InflightBasketUtility',  'Exception',  'Push configs to Heroku for Solution : ' + solutionId,  false,  false);
            logger.exitLogger();
        }
    }

    } catch (Exception ex) {
    System.debug('InflightBasketUtility.PushConfigurationstoHeroku ' + ex.getLineNumber() + ' ' + ex.getMessage() + ' Stack Trace: ' + ex.getStackTraceString());
    }
    return result;
    }

        /**
     * Author: Arun Kumar 
     * Description: Method to get the status of batchjob 
     * EDGE-201336
     * Date : 8th Feb 2021
     */
    @AuraEnabled
    public static String checkQueuedJobStatus(Id jobID) { 
        List<AsyncApexJob> asyncjob = [SELECT status FROM AsyncApexJob WHERE Id = :jobID];
        if(!asyncjob.isEmpty())
          return asyncjob[0].status;
        else
          return '';
    }

}