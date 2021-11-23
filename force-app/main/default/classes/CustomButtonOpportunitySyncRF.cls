/*************************************************************************************************************************************************
 * Name         :   CustomButtonOpportunitySyncRF
 * Description  :   Refactored class CustomButtonOpportunitySync, Sync Validation and DML Operation is seggregated.
                    Test class - ValidationsForBasketOperationsTest
    Sr.No.  Developer Name      Date            Story           Description
    1.      Gokul               29/09/2020      EDGE-174747     OpportunityButtonSync refactoring
    2.      Pooja Bhat          22/09/2020      EDGE-178203     Technical Refactoring - Opportunity Sync - DML Operations
    3.      Kamlesh Kumar       17/12/2020      EDGE - 189844   Added code to open sync status modal window
    4.      Kamlesh Kumar       4/2/2021        EDGE-198027     <Technical>Sync functionality- Change Async Process of createOLI from future to batch
    5.      Kamlesh Kumar       27/2/2021       EDGE-199074     sending list of sync job id as parameter in toCheckSyncJobCompletion
    6.      Kamlesh Kumar       8/3/2021        EDGE-205509     Added Exception handling in this class
   7. 		Payal				26/04/21    	EDGE-216620 - Updated Attribute name "billingAccountLookup" in config query
	8.		Radhika 			20/09/2021		DIGI-931		Added field cscfga__Product_Definition__r.product_Specification__c in cscfga__Product_Configuration__c query
**************************************************************************************************************************************************/

global with sharing class CustomButtonOpportunitySyncRF extends csbb.CustomButtonExt {
    /*Invoked upon the click of sync button*/
    public String performAction(String basketId){
      String basketNumber='';
      try{
        String jobStatus = '';
        String response = '';
        cscfga__Product_Basket__c productBasket;
        List <cscfga__Product_Configuration__c> configList;   
        String queryString = 'SELECT ';
        queryString += 'id, ';
        queryString += 'Name, ';
        queryString += 'cscfga__Opportunity__c, ';
        queryString += 'csordtelcoa__Basket_Stage__c, ';
        queryString += 'csbb__Synchronised_With_Opportunity__c, ';
        queryString += 'Primary_Basket__c, ';
        queryString += 'cscfga__Opportunity__r.Product_Type__c, ';
        queryString += 'cscfga__Opportunity__r.StageName, ';
        queryString += 'cscfga__total_contract_value__c, ';
        queryString += 'cscfga__opportunity__r.pricebook2.isstandard, ';
        queryString += 'cscfga__Basket_Status__c, ';
        queryString += 'Express_Flow__c, '; 
        queryString += 'cscfga__Opportunity__r.Model_Change__c, '; 
        queryString += 'Is_Device_Care_Contact_Required__c, ';

        queryString += 'csbb__Account__c,sync_job_Id__c,cscfga__Product_Basket__c.Opportunity_Type__c '; 

        queryString += 'FROM ';
        queryString += 'cscfga__Product_Basket__c ';
        queryString += 'WHERE ';
        queryString += 'id = :basketId ';
        productBasket = Database.query(queryString);
        basketNumber = productBasket.Name;
        configList = [
            SELECT Id,
            Name,
            Marketable_Offer__r.name,ConfigurationType1__c,
            cscfga__Configuration_Status__c,
            cscfga__total_contract_value__c,
            cscfga__Product_Basket__r.cscfga__Opportunity__c,
            cscfga__Description__c,
            cscfga__Contract_Term__c,
            Type__c,
            configGUID__c,
            cscfga__Product_Definition__r.name,
            (
                SELECT id, Name, cscfga__Value__c
                FROM cscfga__Attributes__r where name IN ('Product','BillingAccountLookup')
            ),
            cscfga__Product_Definition__r.product_Specification__c //DIGI-931
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Product_Basket__c = :basketId
        ];
        
        //EDGE-198027
        if(productBasket.sync_job_Id__c!=null) {
            //EDGE-199074
            Map<String,AsyncApexJob> asyncApexJobMap = CheckAsyncJobDetails.toCheckSyncJobCompletion(new List<String>{productBasket.sync_job_Id__c});      
            jobStatus = asyncApexJobMap.get(productBasket.sync_job_Id__c).Status;
            //End EDGE-199074
        }
        
        //EDGE-198027
        String redirectURL = '';
        Id userId = UserInfo.getProfileId();
        String queryProfileString = 'SELECT id, Name FROM PROFILE WHERE id = :userId';
        List<Profile> profileList = Database.query(queryProfileString);
        if(profileList != null && profileList.size() > 0 && (profileList[0].Name == Label.PRM_Community_User || profileList[0].Name == Label.PRM_Indirect_Channel_Mangr || profileList[0].Name == Label.PRM_Indirect_channel_mgrIntl || profileList[0].Name == Label.PRM_CommunityAdmin_User)) {
            cscfga__Product_Basket__c  baskt =  new cscfga__Product_Basket__c (Id=productBasket.id);  
            redirectURL =  new ApexPages.StandardController(baskt).view().getURL();
        }
        else {
        if(productBasket.cscfga__Opportunity__c!=null) {
         Opportunity opp    =  new Opportunity(Id=productBasket.cscfga__Opportunity__c);  
         redirectURL =   new ApexPages.StandardController(opp).view().getURL();
        }
        }

        //EDGE-198027
        if(productBasket.sync_job_Id__c == null || jobStatus == 'Completed' || jobStatus == 'Failed' || productBasket.cscfga__Opportunity__r.Product_Type__c == 'Non Modular')  {
        //Performing Validations
        ValidationsForBasketOperations valdBasketOps = new ValidationsForBasketOperations();
        response = valdBasketOps.performValidation(productBasket,configList,'sync');
        System.debug('response after validation**** ' + response);
        System.debug('***LIMITS CHECK AFTER SYNC VALIDATION*** CPUTime=' + Limits.getCpuTime() +'(' + Limits.getLimitCpuTime() + ')  DMLROW=' + Limits.getDMLRows() +'(' + Limits.getLimitDMLRows() + ')  SOQL=' + Limits.getQueries() +'(' + Limits.getLimitQueries() + ')' );
        //Performing Basket Sync/Unsync Operation
        // On Validation "error"->  Basket is desynced and validation error message is shown to the user
        // On Validation "ok"   ->  Basket is desynced to delete OLI's, resyncing and checking primary basket flag to create new OLI's, update parent Opportunity Details, desync the the other baskets(if any) related with the same parent opportunity.
        AfterValidationSyncOperations syncBasketOps =   new AfterValidationSyncOperations(productBasket);
        Environment_Configurations__c ecCusSetting  =   Environment_Configurations__c.getInstance(UserInfo.getUserId());    // Custom setting used to disable all the validation rules for the current running user. 
        if (ecCusSetting.No_Validations__c == false) {  
            ecCusSetting.No_Validations__c = true;
            upsert ecCusSetting;
        }
        if(response.contains('error')) {
            syncBasketOps.performBasketUnsync();
        } else {
            response =  syncBasketOps.performBasketUnsync();
            if(response.contains('ok')) {
                response = syncBasketOps.performBasketSync();
            }
            //EDGE - 189844
            if(productBasket.cscfga__Opportunity__r.Product_Type__c == 'Modular') {
            //END - EDGE-198027
            //Commenting as part of EDGE-198027
            /*    
            if(productBasket.cscfga__Opportunity__c!=null) {
             Opportunity opp    =  new Opportunity(Id=productBasket.cscfga__Opportunity__c);  
             oppRedirectURL    =   new ApexPages.StandardController(opp).view().getURL();
            }*/
            String basketUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/'+productBasket.id; 
            String ShowURL = '/apex/c__OpportunitySyncStatusPage?recordUrl='+redirectURL+'&basketName='+productBasket.Name+'&basketIds='+productBasket.id;
            return '{"displayInDialog":true,"size":"s","modalTitle":"Sync Status", "redirectURL":"' + ShowURL + '", "status":"ok","text":"Sync Status"}';
            }
            //END EDGE - 189844
        }   
        if (ecCusSetting.Id != null && ecCusSetting.No_Validations__c == true) {    //After Basket sync, enable the validation rules for the current running user.
            ecCusSetting.No_Validations__c = false;
            update ecCusSetting;
        } 
        System.debug('response after dml**** ' + response);
        System.debug('***LIMITS CHECK AFTER SYNC DML*** CPUTime=' + Limits.getCpuTime() +'(' + Limits.getLimitCpuTime() + ')  DMLROW=' + Limits.getDMLRows() +'(' + Limits.getLimitDMLRows() + ')  SOQL=' + Limits.getQueries() +'(' + Limits.getLimitQueries() + ')' );
        return response;
    }
     
    //EDGE-198027 Added code for Job status not completed and failed
     String basketUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/'+productBasket.id; 
     String ShowURL = '/apex/c__OpportunitySyncStatusPage?recordUrl='+redirectURL+'&basketName='+productBasket.Name+'&basketIds='+productBasket.id;
     return '{"displayInDialog":true,"size":"s","modalTitle":"Sync Status", "redirectURL":"' + ShowURL + '", "status":"ok","text":"Sync In Progress"}';
    }
    catch(Exception e){
      Logger2 logger = Logger2.getlogger('CustomButtonOpportunitySyncRF');
      logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Error in Basket :' +basketId+ 'Line No:' ,e.getLineNumber() + ' ' + e.getMessage(), false, false);
      logger.exitLogger();
      return '{"status":"error","text":"There was a technical exception, please contact your admin and quote the basket number '+ basketNumber +' for analysing the issue."}';}
    }
}