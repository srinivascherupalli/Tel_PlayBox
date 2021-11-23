/*************************************************************************************************
Name : CustomButtonSubmitOrder
TestClass:CustomButtonSubmitOrderTest
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.         Ankit              2-Nov-2020        EDGE-181979 (New)
2.         Akanksha           3-Nov-2020        EDGE-182456 added validations for Order Requestor Field, set value of Project_Complexity__c in case of null
3.         Gnana              4-Nov-2020        EDGE-184043 Added TelstraNow Case Reference Number Validation Logic 
4.        Shubhi V            9-Nov-2020        EDGE-181979
5.        Vamsi               1-JAN-2021        EDGE-192911 Added for Submit Basket button functionality.
6.        Kamlesh             28-JAN-2021       EDGE-199065 In-Flight: Submit Basket (Invocation of Sync Framework and Order update)
7.        Arinjay Singh          23/02/2021     EDGE-201409 In-Flight: Reset Amend Allowed Heroku PONR flag
8.        Kamlesh             25/2/2021         Edge-199074 Added dispaly dialog box to open InFlightSubmitBasketStatusPage
9.        Kamlesh             22/3/2021         EDGE-205509 Updating the format of jobMessage
10.       Kamlesh             7/4/2021          EDGE-212976 Adding InFlight popup only for commercial amend type.Not for Non Commercial Ament type
11.       Kamlesh             26/4/2021         EDGE-216600 Fixed - Getting error on clicking 'Submit Basket' button using PRM.
12.       Vamsi Vaddipalli    19OCT2021         DIGI-17913 Generate Order(Blank SIM) - Splunk
===============================================================================================================================
***************************************************************************************************/

global with sharing class CustomButtonSubmitOrder extends csbb.CustomButtonExt {
    public String performAction(String basketId){
        list<id> basketIdList=new  list<id>();
        String validateBasketResp = '';
        String returnString = '';
        Map<string,SharedDisplayMessage__c>errorDisplaySet=SharedDisplayMessage__c.getAll();
        list<csord__Subscription__c> ordId=new list<csord__Subscription__c>();
        Boolean isBeforeLog = false;//Vamsi
        try{list<cscfga__Product_Configuration__c> pcList=Model_ProductConfiguration.getConfigList(basketId);
            if(!pcList.isEmpty()){
                cscfga__Product_Basket__c productBasket = Model_ProductBasket.getProductBasket(basketId);
                if(productBasket != null)
                {
                    if (productBasket.csordtelcoa__Basket_Stage__c == 'Submitted'){                
                        return '{"status":"error","text":"'+errorDisplaySet.get('alreadySubmittedBasket').value__c+'"}';  
                    }
                    //added by Vamsi for  EDGE-192911 on 1/7/2021 starts
                    if( String.isNOTBlank(productBasket.RecordTypeId) && productBasket.RecordType.Name.equalsIgnoreCase('inflight change')){              
                        //EDGE-199065
                        return submitBasket(productBasket,pcList);   
                        //END EDGE-199065 
                    }else if(productBasket.BasketType__c=='Non Commercial'){                    
                        //added by Vamsi for  EDGE-192911 on 1/7/2021 ends
                        boolean QuantityValidity=checkInactiveSimQuantity(pcList);
                        if(QuantityValidity){
                            return '{"status":"error","text":"'+errorDisplaySet.get('quantityValidation').value__c+'"}';
                        }
                        //String validateBasketDetails = validateBasketDetails(basketId,productBasket); // EDGE-184043, EDGE-182456
                        ValidationsForBasketOperations validateBasket = new ValidationsForBasketOperations();
                        validateBasketResp = validateBasket.performValidation(productBasket,pcList,'SubmitOrder');
                        if(validateBasketResp.contains('error')){ // EDGE-184043, EDGE-182456 
                            return validateBasketResp;
                        }
                        basketIdList.add(basketId);
                        //added by Vamsi DIGI-17913 19OCT2021 starts
                        if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','beforelogsinsertion')){
                            isBeforeLog = true;
                            basketTransactionlogs(productBasket,null,isBeforeLog);
                        }
                        //added by Vamsi DIGI-17913 19OCT2021 ends
                        if(!test.isRunningTest())csordtelcoa.API_V1.generateOrdersFromBaskets(basketIdList,false);
                        ordId=Model_Subscription.getOrderFromSubscription(basketId);
                        returnString = ordId.isEmpty() ? CustomButtonSubmitOrder.returnError() : CustomButtonSubmitOrder.returnSuccess(productBasket,ordId[0].csord__Order__c); 
                        //added by Vamsi DIGI-17913 19OCT2021 starts
                        String orderId = ordId[0].csord__Order__c;
                        if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','afterlogsinsertion')){
                            isBeforeLog = false;
                            basketTransactionlogs(productBasket,orderId,isBeforeLog);
                        }
                        //added by Vamsi DIGI-17913 19OCT2021 ends
                    }
                    
                }
                
                return returnString;
                
            }else{return '{"status":"error","text":"'+errorDisplaySet.get('noProductAvailable').value__c+'"}';}     
           }catch(Exception err){return '{"status":"error","text":"'+err+'"}';}
    }
    public static boolean checkInactiveSimQuantity(list<cscfga__Product_Configuration__c> pcList){
        string pdName=Label.inActiveSim;
        boolean quantityValidity=false;
        integer count=0;
        for(cscfga__Product_Configuration__c prodef : pcList){
            if(pdName==prodef.cscfga__Product_Definition__r.product_Specification__c){
                count += integer.valueOf(prodef.Quantity_Product_Configuration__c);
            }
        }
        if(count > 200){
            quantityValidity=true; 
        }
        return quantityValidity;
    }
    
    //added by EDGE-181979
    @TestVisible
    private static string returnError(){
        Map<string,SharedDisplayMessage__c>errorDisplaySet=SharedDisplayMessage__c.getAll();
        return '{"status":"error","text":"'+errorDisplaySet.get('errorOrderGeneration').value__c+'"}';
    }
    //added by EDGE-181979
    @TestVisible
    private static string returnSuccess(cscfga__Product_Basket__c basket,String orderId){
        Map<string,SharedDisplayMessage__c>errorDisplaySet=SharedDisplayMessage__c.getAll();
        basket.csordtelcoa__Basket_Stage__c = 'Submitted';
        update basket; 
        
        // Arinjay EDGE-201409
        HerokuConfigurationsUtility.resetAllowAmendInHeroku(basket.id);
        
        PageReference ref = new PageReference('/' + orderId); 
        ref.setRedirect(true);
        return '{"status":"ok","text":"'+errorDisplaySet.get('orderGenerationSucess').value__c+'", "redirectURL":"' + ref.getUrl() + '"}';        
    }
    /*
*@Created Date : 13-01-2021
*@Modified Date : 2-02-2021
*@Breif : EDGE-199065 Submit Basket button will invoke methods to Check PONR, Sync Opportunity, Close Opportunity, Update order and fund reversals
*/
    private String submitBasket( cscfga__Product_Basket__c productBasket,List<cscfga__Product_Configuration__c> configList)
    {       
        String lastSuccessState = '';
        String status;
        String res = ValidationsForBasketOperations.CheckPONRforServices(productBasket);
        if(Test.isRunningTest()){
            res = null;
        }
        if(res!= null && !res.containsIgnoreCase('ok')){
            return '{"status":"error","text":"' + Label.Order_has_reached_PONR + '"}';
        }
        
        ValidationsForBasketOperations valdBasketOps = new ValidationsForBasketOperations();
        if(productBasket.csbb__Synchronised_With_Opportunity__c == false) {
            String response = valdBasketOps.performValidation(productBasket, configList, 'sync');
            if(response != null && response.containsIgnoreCase('error')){
                return response;
            }
        }
        //Edge-199074,EDGE-205509 - Added one more check to find stage
        //Edge-216600 - Added check for commercial amend type
        if(productBasket.Amend_Type__c =='Commercial' && productBasket.OF_Reversal_Inserted__c == true && productBasket.cscfga__Opportunity__r.StageName == 'Closed Won' && CheckAsyncJobDetails.checkLastRunningApexJobStatus(productBasket.sync_job_Id__c,'fundJobId')) {
            lastSuccessState = 'Fund Reversal';
        }//Edge-216600 - Added check for commercial amend type
        else if(productBasket.Amend_Type__c =='Commercial' && productBasket.csbb__Synchronised_With_Opportunity__c == true && productBasket.cscfga__Opportunity__r.StageName == 'Closed Won' && CheckAsyncJobDetails.checkLastRunningApexJobStatus(productBasket.sync_job_Id__c,'syncJobId')){
            lastSuccessState = 'Opportunity Closure';
        }//Edge-216600 - Added check for commercial amend type
        else if(productBasket.Amend_Type__c =='Commercial' && productBasket.csbb__Synchronised_With_Opportunity__c == true && CheckAsyncJobDetails.checkLastRunningApexJobStatus(productBasket.sync_job_Id__c,'syncJobId')){
            lastSuccessState = 'OLIs Creation';
        }
        String redirectURL = '';
        String opportunityId = productBasket.cscfga__Opportunity__r.Id;
        csord__Order__c order = [Select id from csord__Order__c where csordtelcoa__Opportunity__c =:opportunityId limit 1];
        if(order.Id!=null) {
            csord__Order__c od    =  new csord__Order__c (Id=order.Id);  
            redirectURL =   new ApexPages.StandardController(od).view().getURL();
        }
        //Commented  as part of EDGE-199074
        //Set<String> productBaketId = new Set<String>();
        //productBaketId.add(productBasket.id); 
        Id jobId = database.executeBatch(new InflightSyncBatch(new Set<String>{productBasket.id}));
        String jobMessage = '[{"name":"syncJobId","id":"'+jobId+'","isCompleted":false,"error":false}]';
        ProductUtilityForModular.updateBasketwithJobId(jobMessage,'',new Set<String>{productBasket.id},new Map<String,String>());
        //EDGE-205509 Updated format of jobMessage
        //EDGE-212976 Adding InFlight popup only for commercial amend type
        if(productBasket.Amend_Type__c =='Commercial') {
            //Edge-199074
            String ShowURL = '/apex/c__InFlightSubmitBasketStatusPage?recordUrl='+redirectURL+'&lastSuccessState='+lastSuccessState+'&baskeName='+productBasket.Name+'&basketIds='+productBasket.id;
            return '{"displayInDialog":true,"size":"s","modalTitle":"Submit Basket Status", "redirectURL":"' + ShowURL + '", "status":"ok","text":"Opening Submit Basket Status UI"}';
        }
        //EDGE-212976
        Sync_Control_and_Constants__c sc = Sync_Control_and_Constants__c.getValues('BasketSubmittedSuccessfully');
        if(sc!=null && String.isNotBlank(sc.Value__c)) {
            
            return '{"status":"ok","text":"' +sc.Value__c+ '"}';
        }
        return '{"status":"ok","text":" "}';
    }  //added by Vamsi for EDGE-192911 on 13/JAN/2021 ends
    
    
    /*  
    * Method Name : basketTransactionlogs
    * Owner : Vamsi Krishna Vaddipalli
    * Jira : DIGI-17913
   */
    private static void basketTransactionlogs(cscfga__Product_Basket__c productBasket,String OrderId,Boolean logFlage)
    {
        Map<String,Object> loggerdetailsMap=new Map<String,Object>();
        string correlationId = productBasket.csbb__Account__c+'-'+productBasket.Id;
        String orderType = 'Blank SIM';
        if(productBasket != null && logFlage)
        {
            String URL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + productBasket.Id;
            String event = 'Order generation initiated';
            
            loggerdetailsMap.put('event',event);
            loggerdetailsMap.put('OrderType',orderType);
            loggerdetailsMap.put('basketName',productBasket.Name);
            loggerdetailsMap.put('BasketUrl',URL);
            TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'CustomButtonSubmitOrder');
        }
        if(productBasket != null && String.isNotBlank(OrderId) && !logFlage)
        {
            csord__Order__c order = [Select id,csord__Order_Number__c from csord__Order__c where id =:OrderId limit 1];
            String URL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + order.Id;
            String events = 'Order generation completed';
            
            loggerdetailsMap.put('event',events);
            loggerdetailsMap.put('OrderType',orderType);
            loggerdetailsMap.put('OrderName',order.csord__Order_Number__c);
            loggerdetailsMap.put('OrderURL',URL);
            TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'CustomButtonSubmitOrder');
        }
        
    }
    
}