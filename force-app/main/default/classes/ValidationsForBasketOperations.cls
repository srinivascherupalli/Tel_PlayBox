/*************************************************************************************************
Name : ValidationsForBasketOperations
Description : Run validations for Sync,Contract and Quote button
Test Class : ValidationsForBasketOperationsTest,CustomButtonQuoteRFTest (Requires both the classes to run for 85% Coverage)
Sr.No.    Developer Name      Date          Story Description
1.        Gokul            29/09/2020      EDGE-174747        - OpportunityButtonSync refactoring
2.        Payal            29/09/2020      EDGE-176217        - Quote Validations refactoring
3.        Kamlesh          29/09/2020      EDGE-176216        - Contract Validations refactoring
4.        Shweta Mamadapure 29/09/2020     EDGE-179488        - Contract Validations refactoring
5.        Gnana             11/11/2020     EDGE-184043,182456 - Added SubmitOrder button logic
6.        Pooja G           04/01/2021     EDGE-191824        - PONR Check before initiating Contract/Skip Contract/Quote
7.        Arunkumar V       15/02/2021     EDGE-201334        - Stop performing PONR updates to Heroku during basket journey
8.      Gokul        23/02/21     EDGE-195270        - Bypassed Contact Role validation for Chown Basket
9.        Payal             27/04/2021     EDGE-216620        - Added condition to check Basket Status and Billing Account Status for Quote and Contract
10.        Aman Soni        19/04/2021    EDGE-207355  Throw validation for Skip Contract button
11.       Vishal Arbune     10/05/2021    EDGE-216217:        - POS Redemption
12.       V Ravi Shankar    19/05/2021    EDGE-219809:        - Bypassed Quote/Contract Oppty/Acct owner validation for Inflight basket
13.       Purushottam       17/05/2021    EDGE-202824:        - Added Active POR Domain check before initiating Contract for Partners
14.		  Radhika 			20/09/2021	  DIGI-931			  - Validation to ensure if all respective offers are added for SDWAN product 
15.       Vivek              10/04/2021    DIGI-14126         - FIX FOR REMOVING VALIDATION IN CHOWN
*********************************************************************************************************************************************************/
public class  ValidationsForBasketOperations extends ValidateBasketStage {
    public static String DisplayMessage;
    public static String status;
    private static set<String> setMarketableOffers = new Set<String>();
    public static Map<String, Sync_Control_and_Constants__c> syncConstMap;
    public string performValidation(cscfga__Product_Basket__c productBasket, List<cscfga__Product_Configuration__c> configList, String sourceButton) {
        string basketId = productBasket.Id;
        syncConstMap = Sync_Control_and_Constants__c.getAll();
        //START: Added for EDGE-215103
        Boolean productEndDateValidation = isProductEndDateExpired(productBasket);
        //END for EDGE-215103
      //Added by Aman Soni for EDGE-207355 || Start
        if(string.isNotBlank(sourceButton) && sourceButton.equalsIgnoreCase('Skip Contract')){
          //1. If basket status = Invalid --> return error and error message
                if(checkBasketIsInvalid(productBasket) && syncConstMap.get('Basket_Not_Valid_For_Skip_Contract') != null) 
                    return '{"status":"error", "text":"' + syncConstMap.get('Basket_Not_Valid_For_Skip_Contract').value__c +'"}';
                //2. if basket does not have any valid pc --> return error and error message
                if(configList.size() == 0) 
                    return '{"status":"error", "text":"Please add atleast one valid product to progress basket ahead"}';
                //START: Added for EDGE-215103
                System.debug('---skip contract---');
                if(productEndDateValidation){
                    return '{"status":"error","text":"'+Label.Skip_Contract_Remove_Hardware_Error+'"}';  
                }
                //END: EDGE-215103
                //3. check for billing account validation as per ValidateMinimumRequirements.validateBasketforBillingAcc. perform below dml based on the conditions given in this class.
                string billingAccRes = validateBasketforBillingAcc(productBasket,configList);
                if(string.isNotBlank(billingAccRes))
                    return billingAccRes;
        }
        //Added by Aman Soni for EDGE-207355 || End
        if (string.isNotBlank(sourceButton) && (sourceButton.equalsIgnoreCase('sync') || sourceButton.equalsIgnoreCase('quote') || sourceButton.equalsIgnoreCase('contract'))) {
            //PageReference ref = getPageReferenceInfo(productBasket);
            //1. If basket status = Invalid --> return error and error message 
              if(sourceButton.equalsIgnoreCase('sync')){
            if (checkBasketIsInvalid(productBasket) && syncConstMap.get('Basket_Not_Valid_For_Sync') != null) 
                return '{"status":"error", "text":"' + syncConstMap.get('Basket_Not_Valid_For_Sync').value__c +'"}';
                
                  //2. if basket does not have any valid pc --> return error and error message
                  if(configList.size() == 0)
                  return '{"status":"error", "text":"Please add atleast one valid product before sync"}';
              //3. For non modular basket, for all configuration if attr.Name == 'Product' && attr.cscfga_Value_c == null --> return error and error message 
              if(checkProductsinConfig(productBasket,configList))
                  return '{"status":"error", "text":"Please select  products for all configurations or delete unwanted configurations before sync"}';   
              //4 For module basket, run the validation as in ValidateMinimumRequirements.run()
              string OfferResponse = validateOffers(productBasket,configList);
              if(string.isNotBlank(OfferResponse))
                  return OfferResponse;
              //5. process validation as per CustomButtonOpportunitySync.makeprimaryBasketError() method.
              string basketErrorResponse = primaryBasketError(productBasket);
              if(string.isNotBlank(basketErrorResponse))
                  return basketErrorResponse;
              //6. if OpportunityContactRole in associated opportunity is null --> return error and error message
              //EDGE-195270 - Added if condition to check for Chown Basket
  
              if(OpportunityProductType.isModularProductType(productBasket) && !productBasket.Opportunity_Type__c.containsIgnoreCase('CHOWN') && checkOppContactRole(productBasket) && syncConstMap.get('No_Contact_Role_on_Opportunity') != null)
                  return '{"status":"error","text":"' + syncConstMap.get('No_Contact_Role_on_Opportunity').value__c + '"}';
              }
              // 7. check for billing account validation as per ValidateMinimumRequirements.validateBasketforBillingAcc. perform below dml based on the conditions given in this class.
              string billingAccResponse = validateBasketforBillingAcc(productBasket,configList);
              if(string.isNotBlank(billingAccResponse))
                  return billingAccResponse;
          }
          //Conditions for checking quote related validations
          if (string.isNotBlank(sourceButton) && sourceButton.equalsIgnoreCase('quote')) {
              //Quotes are only generated by account or Opportunity owner, below condition is used to check the same
              String accOwnerId = productBasket.csbb__Account__r.OwnerId;
              String oppOwnerId = productBasket.cscfga__Opportunity__r.OwnerId;
              String userId = UserInfo.getUserId();
              if (!(userId.equalsIgnoreCase(accOwnerId) || userId.equalsIgnoreCase(oppOwnerId)) && productBasket.recordType.Name != 'Inflight Change') {//EDGE-219809
                  return '{"status":"error","text":"' + syncConstMap.get('Quote_User_Validation').value__c + '"}';
              } else {
                  Boolean isOppHavingAnotherPrimaryBasket = false;
                  Boolean requireBasketSync = false;
                  String syncMsg = 'ok';
                  if (!productBasket.csbb__Synchronised_with_Opportunity__c) {
                      syncMsg = performValidation(productBasket, configList, 'sync');
                  }
                  if (string.isNotBlank(syncMsg) && syncMsg.containsIgnoreCase('ok')) {
                      //EDGE-216217
                      String redemptionAmountMsg = compareAvailableAmtRedemptionAmt(productBasket);
                      if(String.isNotBlank(redemptionAmountMsg) && redemptionAmountMsg.contains('error')) {
                           return redemptionAmountMsg;
                      }
                      
                      //EDGE-141820 Start : Added by Tejes to check EAP discount end date
                      //EDGE-147970-Added Business calling as per new ngUC model and removed old pd name from filter criteria
                      String isCLIChecked = checkCLI(basketId);
                      if(String.isNotBlank(isCLIChecked)) {
                          return '{"status":"error","text":"' + syncConstMap.get('EAP_QuoteError').value__c+ '"}';
                      }
                      //EDGE-141820 End
                      //EDGE-117966 (Parallel MACD): first validate basket so that we don't waste SOQLs on other checks if basket shouldn't be moved forward
                      String macdValidation = validateMACDbasket(productBasket, false);
                      if (String.isNotEmpty(macdValidation)) {
                          return macdValidation; //returns '{"status":"error", "text":"' + validationMessage + '"}';
                      }
                      Sync_Control_and_Constants__c syncCheck = Sync_Control_and_Constants__c.getInstance('CWP');
                      if (syncCheck != null && !syncCheck.No_Validation__c) {
                          String AccountID = productBasket.csbb__Account__c;
                          string returnVal = checkDisconnectionDate(productBasket, AccountID, true);
                          if (returnVal.contains('error')) {
                              return returnVal;
                          }
                      }
                  }else{
                      return syncMsg;
                  }
                //START: Added for EDGE-215103
                System.debug('---quote---');
                if(productEndDateValidation){
                    return '{"status":"error", "text":"'+ System.Label.Skip_Quote_Remove_Hardware_Error+'"}';
                }
                //END: EDGE-215103
              }
          }
          //Condition for checking Contract related validation
          if (string.isNotBlank(sourceButton) && sourceButton.equalsIgnoreCase('contract')) {
              String syncMessage = 'Ok';
              String accOwnerId = productBasket.csbb__Account__r.OwnerId;
              String oppOwnerId = productBasket.cscfga__Opportunity__r.OwnerId;
              String userId = UserInfo.getUserId();
              if (!(userId.equalsIgnoreCase(accOwnerId) || userId.equalsIgnoreCase(oppOwnerId)) && syncConstMap.get('Contract_User_Validation')!=null && productBasket.recordType.Name != 'Inflight Change') {//EDGE-219809
                  return '{"status":"error","text":"' + syncConstMap.get('Contract_User_Validation').value__c+ '"}';
              } else {
                  Boolean isOppHavingAnotherPrimaryBasket = false;
                  Boolean requireBasketSync = false;
                  List<cscfga__product_basket__c> objProductBasket = [
                      SELECT id,name,csbb__Synchronised_with_Opportunity__c, Primary_Basket__c,csordtelcoa__Basket_Stage__c
                      FROM cscfga__product_basket__c
                      WHERE Primary_Basket__c = TRUE AND cscfga__Opportunity__c = :productBasket.cscfga__Opportunity__c AND Id != :productBasket.id
                  ];
                  if (objProductBasket.size() > 0) {
                      isOppHavingAnotherPrimaryBasket = true;
                  }
                  if (
                      !isOppHavingAnotherPrimaryBasket && CustomConfigurationOptions__c.getValues('ContractInitiate')!=null &&
                      productBasket.csordtelcoa__Basket_Stage__c != CustomConfigurationOptions__c.getValues('ContractInitiate').Enrichment_Basket_Stage__c
                  ) {
                      if (!productBasket.csbb__Synchronised_with_Opportunity__c) {
                          syncMessage = performValidation(productBasket, configList, 'sync');
                          if (String.isNotEmpty(syncMessage) && syncMessage.contains('error')) {
                              return syncMessage;
                          }
                      }
                      if (String.isNotBlank(syncMessage) && syncMessage.containsIgnoreCase('Ok')) {
                          //other validation
                          String redemptionAmountMsg = checkRedemptionAmount(productBasket);
                          if(String.isNotBlank(redemptionAmountMsg) && redemptionAmountMsg.contains('error')) {
                              return redemptionAmountMsg;
                          }
                          String cliErrorMessage = checkCLI(basketId);
                          if (String.isNotEmpty(cliErrorMessage) && cliErrorMessage.contains('error')) {
                              return cliErrorMessage;
                          }
                          //EDGE-117966 (Parallel MACD): first validate basket so that we don't waste SOQLs on other checks if basket shouldn't be moved forward
                          String macdValidation = validateMACDbasket(productBasket, false);
                          if (String.isNotEmpty(macdValidation) && macdValidation.contains('error')) {
                              return macdValidation; //returns '{"status":"error", "text":"' + validationMessage + '"}';
                          }
                          CS_TranslateTransitionNumbertoNCS.TranslateTransistionNumbertoNCS(basketId);
                          String sowMsg = checkSOW(basketId);
                          if(String.isNotBlank(sowMsg) && sowMsg.contains('error')) {
                              return sowMsg;
                          }
                          Sync_Control_and_Constants__c syncCheck = Sync_Control_and_Constants__c.getInstance('CWP');
                          if (syncCheck != null && !syncCheck.No_Validation__c) {
                              String AccountID = productBasket.csbb__Account__c;
                              string returnVal = checkDisconnectionDate(productBasket, '', false);
                              if (returnVal.contains('error')) {
                                  return returnVal;
                              }
                          }
                          //EDGE-202824 Start : Added by Purushottam to Validate Partner
                          if(FeatureManagement.checkPermission('Partner_User') && productBasket.csordtelcoa__Basket_Stage__c != 'Approved'){
                              String activePORMsg = ValidatePRMBasketOperations.checkActivePOR(productBasket,configList);
                              if(String.isNotBlank(activePORMsg) && activePORMsg.contains('error')) {
                                  return activePORMsg;
                              }
                          }
                         //EDGE-202824 End
                      }
                  }
                  else if(isOppHavingAnotherPrimaryBasket) {
                      return checkPrimaryPresentWithContractInitiated(productBasket,objProductBasket);
                  }
              }
            //START: Added for EDGE-215103
            System.debug('---contract---');
            if(productEndDateValidation){
                return '{"status":"error", "text":"'+ System.Label.Skip_Generate_Contract_Remove_Hardware_Error+'"}';
            }
            //END: EDGE-215103
          }
          
          // Added SubmitOrder button logic as part of EDGE-182456,184043
          if (string.isNotBlank(sourceButton) && sourceButton.equalsIgnoreCase('SubmitOrder')) {
              try{
                  // EDGE-182456 : Check Order Requestor Details - Start
                  String reqErrorMessage = checkRequestor(productBasket);
                  if (String.isNotEmpty(reqErrorMessage) && reqErrorMessage.contains('error')) {
                      return reqErrorMessage;
                  }
                  // EDGE-182456 : Check Order Requestor Details - End
                  
                  // EDGE-184043 : Check TelstraNow Refrence Number Details only for Assurance Service Agent - Start
                  String refNumErrorMessage = checkReferenceNumber(productBasket);
                  if (String.isNotEmpty(refNumErrorMessage) && refNumErrorMessage.contains('error')) {
                      return refNumErrorMessage;
                  }
                  // EDGE-184043 : Check TelstraNow Refrence Number Details only for Assurance Service Agent - End
              }
              catch(Exception err){
                  System.debug('err..'+err);
                  return '{"status":"error","text":"'+err+'"}';
              }
          }
        //DIGI-931 ---Starts----------------------------------
		if(string.isNotBlank(sourceButton) && sourceButton.equalsIgnoreCase('sync') && basketId != null && productBasket.Opportunity_Type__c == 'New To Market')
        { 
       		  String validateSDWAN = validateSDWANProduct(basketId,configList,productBasket);
              if(validateSDWAN !='Ok')
              {
                  return validateSDWAN;
              }     
          }
        // DIGI-931 ---Ended--------------------------
          return '{"status":"Ok","text":"Validation Successful"}';
      }
      @TestVisible
      private static boolean checkBasketIsInvalid(cscfga__Product_Basket__c productBasket){
          boolean returnValue = false;
          if (productBasket == null || productBasket.cscfga__Basket_Status__c == null || !productBasket.cscfga__Basket_Status__c.equalsIgnoreCase('valid'))
              returnValue = true;
          return returnValue;
      }
      /*public static pageReference getPageReferenceInfo(cscfga__Product_Basket__c productBasket) {
  PageReference ref = null;
  String queryStr = 'SELECT id, Name FROM PROFILE WHERE id = \'' + UserInfo.getProfileId() + '\'';
  system.debug('queryStr ' + queryStr);
  List<Profile> profileList = Database.query(queryStr);
  if (
  profileList != null &&
  profileList.size() > 0 &&
  (profileList[0].Name == Label.PRM_Community_User ||
  profileList[0].Name == Label.PRM_Indirect_Channel_Mangr ||
  profileList[0].Name == Label.PRM_Indirect_channel_mgrIntl ||
  profileList[0].Name == Label.PRM_CommunityAdmin_User)
  )
  ref = new PageReference('/' + productBasket.id);
  else
  ref = new PageReference('/apex/c__NewBasketOverrideRedirectPage?id=' + productBasket.id);
  ref.setRedirect(true);
  return ref;
  }*/
      @TestVisible
      private static boolean checkProductsinConfig(cscfga__Product_Basket__c productBasket,List <cscfga__Product_Configuration__c> configList){
          boolean returnValue = false;
          if(productBasket.cscfga__Opportunity__r.Product_Type__c == 'Non Modular'){
              for (cscfga__Product_Configuration__c config : configList) {
                  for(cscfga__Attribute__c attr : config.cscfga__Attributes__r) {
                      if(attr.Name == 'Product' && attr.cscfga__Value__c == null) {
                          returnValue = true; 
                          break;
                      }
                  }
              }
          }
          return returnValue;
      }
      @TestVisible 
      private static string primaryBasketError(cscfga__Product_Basket__c productBasket){
          string returnValue = '';
          Id oppId = productBasket.cscfga__Opportunity__r.id;
          id pbId = productBasket.id;
          String queryString = 'SELECT ';
          queryString += 'id, ';
          queryString += 'name, ';
          queryString += 'cscfga__Opportunity__c, ';
          queryString += 'Primary_Basket__c, ';
          queryString += 'csordtelcoa__Basket_Stage__c ';
          queryString += 'FROM ';
          queryString += 'cscfga__Product_Basket__c ';
          queryString += 'WHERE ';
          queryString += '(csordtelcoa__Basket_Stage__c = \'Contract Initiated\' ';
          queryString += 'OR ';
          queryString += 'csordtelcoa__Basket_Stage__c = \'Enriched\') ';
          queryString += 'AND ';
          queryString += 'Primary_Basket__c = true ';
          queryString += 'AND ';
          queryString += 'cscfga__Opportunity__c = :oppId ';
          queryString += 'AND ';
          queryString += 'id != :pbId';
          List<cscfga__Product_Basket__c> basketList = Database.query(queryString);
          if(basketList != null && basketList.size() > 0)
              returnValue = '{"status":"error","text":"' + syncConstMap.get('Make_Primary_Basket_Error').value__c.replace('basketId', basketList[0].name) + '"}';
          return returnValue;
      }
      @TestVisible
      private static boolean checkOppContactRole(cscfga__Product_Basket__c productBasket) {
          boolean returnValue = true;
          List<OpportunityContactRole> contactRolesList = new List<OpportunityContactRole>();
          if (productBasket != null && productBasket.cscfga__Opportunity__c != null && productBasket.cscfga__Opportunity__r.Id != null){
              for(OpportunityContactRole con : [SELECT Id FROM OpportunityContactRole WHERE OpportunityId = :productBasket.cscfga__Opportunity__r.Id]){
                  contactRolesList.add(con);   
              }
              if (contactRolesList != null && contactRolesList.size() > 0)
                  returnValue = false;
          }
          return returnValue;
      }
      @TestVisible
      private static string validateBasketforBillingAcc(cscfga__Product_Basket__c productBasket,List <cscfga__Product_Configuration__c> configList){
          string returnValue = '';
          List<cscfga__Product_Configuration__c> pcTobeUpdatedList=new List<cscfga__Product_Configuration__c>(); 
          if(productBasket != null  && productBasket.csbb__Account__c != null){
              Boolean hasinvalidBillingAcc = false;
              string billingStatus = syncConstMap.get('BillingAccountStatus') != null?syncConstMap.get('BillingAccountStatus').value__c:'N/A';
              Set<String> billingAccStatusSet=new Set<String>(billingStatus.split(','));
              Map<String,Billing_Account__c> billingAccmap=Model_BillingAccount.getBillingAccountOnStatus(productBasket.csbb__Account__c,billingAccStatusSet);
                String banNumber='';//Added by Aditya pareek for EDGE-207352
              if(billingAccmap!=null && !billingAccmap.isEmpty()){
                  string notAllowedTypesStr = syncConstMap.get('notAllowedTypes') != null?syncConstMap.get('notAllowedTypes').value__c: 'N/A';
                  Set<String> notAllowedTypes=new Set<String>(notAllowedTypesStr.split(','));
                  for (cscfga__Product_Configuration__c config : configList) {
                        if(notAllowedTypes!=null && notAllowedTypes.contains(config.Type__c)){
                          for(cscfga__Attribute__c attr : config.cscfga__Attributes__r) {
                              if(syncConstMap.get('BillingAccountAttName') != null && attr.Name == syncConstMap.get('BillingAccountAttName').value__c && attr.cscfga__Value__c != null && billingAccmap.keyset().contains(attr.cscfga__Value__c)){
                                  hasinvalidBillingAcc=true;
                                    if(banNumber=='')
                                    banNumber+=billingAccmap.get(attr.cscfga__Value__c).Billing_Account_Number__c;
                                    else if (!banNumber.contains(billingAccmap.get(attr.cscfga__Value__c).Billing_Account_Number__c))
                                    banNumber += ',' + billingAccmap.get(attr.cscfga__Value__c).Billing_Account_Number__c; ///Added by Aditya pareek for EDGE-207352 
                                  config.cscfga__Configuration_Status__c='Incomplete';
                                  config.cscfga__pricing_status__c='Current';
                                  pcTobeUpdatedList.add(config);
                              }
                          }
                      }
                  }
              }
              if(pcTobeUpdatedList!=null && !pcTobeUpdatedList.isEmpty())
                  update pcTobeUpdatedList;
              if(hasinvalidBillingAcc){
                  if(productBasket!=null && productBasket.cscfga__Basket_Status__c!='Incomplete'){
                      productBasket.cscfga__Basket_Status__c='Incomplete';
                      productBasket.cscfga__pricing_status__c='Current';
                      update productBasket;
                       // String message='Please change the configurations with ' +banNumber+ ' as its in pending finalization stage. Here the ' +banNumber + ' should be replaced with actual billing account numbers.';
                          String message = syncConstMap.get('BillingAccountStatusValidation1').value__c + ' ' +banNumber+ ' '+ syncConstMap.get('BillingAccountStatusValidation2').value__c;                     
                        returnValue = '{"status":"error","text":"' +  message  + '"}';
                  }
              }
          } 
          return returnValue;
      }
      @TestVisible
      private static boolean checkNextGenUC(cscfga__Product_Configuration__c pc){
          boolean returnValue = false;
          if(syncConstMap.get('NextGenUC') != null && pc.OfferName__c == syncConstMap.get('NextGenUC').value__c && pc.ConfigurationType1__c=='SolutionComponent' && String.isNotBlank(pc.Type__c) && pc.Type__c == 'New') 
              returnValue = true;    
          return returnValue;
      }
      @TestVisible
      private static boolean checkUnifiedCommTenancy(cscfga__Product_Configuration__c pc){
          boolean returnValue = false;
          if(syncConstMap.get('UnifiedCommunicationTenancy') != null && pc.OfferName__c == syncConstMap.get('UnifiedCommunicationTenancy').value__c)
              returnValue = true;    
          return returnValue;
      }
      @TestVisible
      private static string checkCWP(cscfga__Product_Basket__c productbasket,List <cscfga__Product_Configuration__c> configList){
          //Flag to if iIPVPCount and iUCECount is checked
          Boolean checkIpvpAndUceCount = false; 
          String prdDefNames = System.Label.CWP_ProDefNames;
          List<String> prddefnamelst = prdDefNames.split(',');
          String PROD_CONFIGURATION_TYPE_MODIFY = 'Modify';
          //Check if there are other subscriptions under the account of the basket which have different sites
          Integer iIPSiteCount = 0, iIPVPNCount = 0, iUCECount = 0; 
          String MacAddRecords1 = EnvironmentVariable__c.getValues('ValidationIPUCE').Value__c;
          //Querying CWP products under the basket for modular basket
          cscfga__Product_Basket__c basket = [Select id, TransitionComplete__c,csbb__Account__c,cscfga__Opportunity__c , cscfga__Opportunity__r.Type,(Select id from cscfga__Product_Configurations__r where cscfga__Product_Definition__r.Name In :prddefnamelst) from cscfga__Product_Basket__c where id=:productbasket.id];
          Id accountId = basket.csbb__Account__c; 
          if(MacAddRecords1=='1'){
              if(accountId != null){  
                  List<csord__Subscription__c> lstSubFromAccount = [SELECT id, Name FROM csord__Subscription__c WHERE csord__Account__c =:accountId and csord__Status__c!='Cancelled'];
                  for(csord__Subscription__c subFromAccount : lstSubFromAccount){
                      if(subFromAccount.Name == System.Label.IP_Site)
                          iIPSiteCount++;
                      else if(subFromAccount.Name == System.Label.IP_Network)
                          iIPVPNCount++;
                      else if(subFromAccount.Name == System.Label.UC_Config_Name)
                          iUCECount++;
                  }
              }
              for(cscfga__Product_Configuration__c prodConfig : configList){
                  if(prodConfig.Type__c == PROD_CONFIGURATION_TYPE_MODIFY)
                      checkIpvpAndUceCount = true;
                  if(iIPSiteCount < 2 && prodConfig.cscfga__Product_Definition__r.name == System.Label.IP_Site)
                      iIPSiteCount++;
                  if(prodConfig.cscfga__Product_Definition__r.name == System.Label.IP_Network)
                      iIPVPNCount++;
                  if(prodConfig.cscfga__Product_Definition__r.name == System.Label.UC_Enterprise)
                      iUCECount++;
              }
              //if there are no CWP products in the modular basket return ok
              if (basket.cscfga__Product_Configurations__r ==null || basket.cscfga__Product_Configurations__r.size()==0)
                  //return 'error' +'-'+'Please add atleast one valid product before sync.';
                  return 'ok';                 
              //If both IP Network and Unified Communication Enterprise  products are not present
              else if(checkIpvpAndUceCount && iIPVPNCount < 1 && iUCECount < 1)
                  return 'error' + '-'+ System.Label.Label_IPUCEnterpriseBothNotPresent_Error;
              //no IP Network module in the basket and no IP Network subscription
              else if(checkIpvpAndUceCount && iIPVPNCount < 1) 
                  return 'error' + '-'+ System.Label.Label_IPNetwork_Error;      
              //no Unified Communication Enterprise module in the basket and no Unified Communication Enterprise subscription
              else if(checkIpvpAndUceCount && iUCECount < 1)
                  return 'error' + '-'+ System.Label.Label_UCEnterprise_Error;  
              else if(iIPSiteCount < 2 && basket.cscfga__Opportunity__r.Type == 'New To Market')
                  return 'error' +'-'+System.Label.Label_CWP_Error; 
              //Marking as a comment as we are not using transition complete flag at the checkpoint screen
              /* else if(basket.TransitionComplete__c == false )
  {
  return 'error' +'-'+System.Label.Label_Transition_Incomplete_Error; 
  }*/
              else if(basket.cscfga__Product_Configurations__r!=null  && iIPVPNCount == 1 && iUCECount == 1)
                  return 'ok'; 
              //if the account has different sites
              else if(iIPSiteCount > 1 )
                  return 'ok';    
              //If 2 sites and IP Network and Unified Communication Enterprise  products are not present
              else
                  return 'error' +'-'+System.Label.Label_2SitesIPUCEnterpriseNotPresent_Error; 
          }
          else{
              if(accountId != null){  
                  List<csord__Subscription__c> lstSubFromAccount = [SELECT id, Name FROM csord__Subscription__c WHERE csord__Account__c =:accountId and csord__Status__c!='Cancelled'];
                  for(csord__Subscription__c subFromAccount : lstSubFromAccount){
                      if(subFromAccount.Name == System.Label.IP_Site)
                          iIPSiteCount++;
                      else if(subFromAccount.Name == System.Label.IP_Network)
                          iIPVPNCount++;
                      else if(subFromAccount.Name == System.Label.UC_Config_Name)
                          iUCECount++;
                  }
              }
              for(cscfga__Product_Configuration__c prodConfig : configList){
                  if(prodConfig.Type__c == PROD_CONFIGURATION_TYPE_MODIFY)
                      checkIpvpAndUceCount = true;
                  if(iIPSiteCount < 2 && prodConfig.cscfga__Product_Definition__r.name == System.Label.IP_Site)
                      iIPSiteCount++;
                  if(prodConfig.cscfga__Product_Definition__r.name == System.Label.IP_Network)
                      iIPVPNCount++;
                  if(prodConfig.cscfga__Product_Definition__r.name == System.Label.UC_Enterprise)
                      iUCECount++;
              }
              //if there are no CWP products in the modular basket return ok
              if (basket.cscfga__Product_Configurations__r ==null || basket.cscfga__Product_Configurations__r.size()==0)
                  return 'ok'; 
              //If there is one IP Site,no IP VPN and UC
              else if(checkIpvpAndUceCount && iIPSiteCount < 2 && iIPVPNCount < 1 && iUCECount < 1 )
                  return 'error' +'-'+System.Label.Label_2SitesIPUCEnterpriseNotPresent_Error; 
              //If both IP Network and Unified Communication Enterprise  products are not present
              else if(checkIpvpAndUceCount && iIPVPNCount < 1 && iUCECount < 1)
                  return 'error' + '-'+ System.Label.Label_IPUCEnterpriseBothNotPresent_Error;
              //no IP Network module in the basket and no IP Network subscription
              else if(checkIpvpAndUceCount && iIPVPNCount < 1) 
                  return 'error' + '-'+ System.Label.Label_IPNetwork_Error;         
              //no Unified Communication Enterprise module in the basket and no Unified Communication Enterprise subscription
              else if(checkIpvpAndUceCount && iUCECount < 1)
                  return 'error' + '-'+ System.Label.Label_UCEnterprise_Error;             
              //more than 1 IP Network module in the basket 
              else if(checkIpvpAndUceCount && iIPVPNCount > 1)
                  return 'error' + '-'+ System.Label.Label_MoreThanOneIPNetwork_Error;      
              // more than 1 Unified Communication Enterprise module in the basket
              else if(checkIpvpAndUceCount && iUCECount > 1)
                  return 'error'+ '-'+ System.Label.Label_MoreThanOneUCEnterprise_Error;  
              else if(iIPSiteCount < 2 && basket.cscfga__Opportunity__r.Type == 'New To Market') // EDGE-125039
                  return 'error' +'-'+System.Label.Label_CWP_Error;
              //IF user does not trasition for legacy site
              /*else if(basket.TransitionComplete__c == false )
  {
  return 'error' +'-'+System.Label.Label_Transition_Incomplete_Error; 
  }*/
              else if(basket.cscfga__Product_Configurations__r!=null  && iIPVPNCount == 1 && iUCECount == 1)
                  return 'ok'; 
              //if the account has different sites
              else if(iIPSiteCount > 1  && ( (iIPVPNCount == 1 && iUCECount == 1) || !checkIpvpAndUceCount) )
                  return 'ok';     
              //If 2 sites and IP Network and Unified Communication Enterprise  products are not present
              else
                  return 'error' +'-'+System.Label.Label_2SitesIPUCEnterpriseNotPresent_Error; 
          }
      } 
      @TestVisible
      private static string validateOffers(cscfga__Product_Basket__c productBasket,List <cscfga__Product_Configuration__c> configList){
          boolean tcPresent = false;
          boolean uctPresent = false;
          Boolean isCOnfigOnlyBasket=false;
          String validateMessage = '';
          string DisplayMessage;
          string status;
          string returnValue = '';
          Boolean isCHOWNBasket =false; // DIGI-14126 : VIVEK
          if(productBasket.cscfga__Opportunity__r.Product_Type__c == Label.Modular){
              for(cscfga__Product_Configuration__c pc : [select id,OfferName__c,Name,ConfigurationType1__c,Type__c,Marketable_Offer__r.Name, cscfga__Product_Basket__r.Opportunity_Type__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:productBasket.id and (OfferName__c != null OR Marketable_Offer__r.Name != '')]){
                  if(!String.isEmpty(pc.Marketable_Offer__r.Name))
                      setMarketableOffers.add(pc.Marketable_Offer__r.Name);
                  if(!tcPresent)
                      tcPresent = checkNextGenUC(pc);
                  if(!uctPresent)
                      uctPresent = checkUnifiedCommTenancy(pc);
                  
                  // DIGI-14126 : VIVEK
                  if(pc.cscfga__Product_Basket__r.Opportunity_Type__c == 'CHOWN'){
                    isCHOWNBasket = true;
                  }
              }
              isCOnfigOnlyBasket = BasketCustomProcess.isConfigOnlyBasket(setMarketableOffers);
              if(!isCOnfigOnlyBasket) {
                  if(tcPresent){
                    if( !isCHOWNBasket){
                      if(!uctPresent){
                          validateMessage = 'error' +'-'+System.Label.Label_UnifiedCommunicationTenancyNotPresent_Error;
                      }else if(uctPresent){
                          validateMessage = 'ok';
                      }
                    }
                    if( isCHOWNBasket ){
                        validateMessage = 'ok';
                    }
                }
                  else if(uctPresent){//  EDGE-137491 Added to show validation error if TC is not present in basket
                      validateMessage = 'error' +'-'+System.Label.Label_UnifiedCommunicationTenancyPresent_Error;
                  }
                  if(!validateMessage.contains('error') && syncConstMap.get('Corporate Mobile Plus') != null && !syncConstMap.get('Corporate Mobile Plus').No_Validation__c){
                      validateMessage = checkCWP(productBasket,configList);     
                  }
                  if(validateMessage.contains('error')) {
                      DisplayMessage =  validateMessage.split('-')[1];
                      status = validateMessage.split('-')[0];
                      returnValue = '{"status":"'+ status + '", "text":"' + DisplayMessage + '"}';
                  }
              }
          }
          return returnValue;
      }
      @TestVisible
      private static string checkDisconnectionDate(cscfga__Product_Basket__c productBasket, String AccountId, Boolean isSiteValidationRequired) {
          Boolean bIsDisconnectionDateBlank = false;
          Set<String> SiteIdSet = new Set<String>();
          List<cscfga__Attribute__c> attributeDDate = [
              SELECT Id, Name, cscfga__Value__c, cscfga__Product_Configuration__c, cscfga__Product_Configuration__r.cscfga__Configuration_Status__c
              FROM cscfga__Attribute__c
              WHERE
              cscfga__Product_Configuration__r.cscfga__Product_Basket__c = :productBasket.Id
              AND ((Name = 'DisconnectionDate'
                    AND cscfga__Product_Configuration__r.Type__c = 'Cancel'
                    AND cscfga__Product_Configuration__r.Name IN ('IP Site', 'Mobility'))
                   OR (Name = 'Site Id'
                       AND cscfga__Product_Configuration__r.Type__c NOT IN ('Cancel', 'Modify')))
          ];
          for (cscfga__Attribute__c att : attributeDDate) {
              if (att.Name == 'DisconnectionDate' && String.isBlank(att.cscfga__Value__c)) {
                  bIsDisconnectionDateBlank = true;
              } else {
                  SiteIdSet.add(att.cscfga__Value__c);
              }
          }
          if (isSiteValidationRequired) {
              List<String> BasketStageList = new List<String>();
              BasketStageList.add(CustomConfigurationOptions__c.getValues('ContractAccepted').Enrichment_Basket_Stage__c);
              BasketStageList.add(CustomConfigurationOptions__c.getValues('Submitted').Enrichment_Basket_Stage__c);
              BasketStageList.add(CustomConfigurationOptions__c.getValues('ServiceDetailing').Enrichment_Basket_Stage__c);
              Boolean siteAlreadyPresentIN_Customer = false;
              for (cscfga__Attribute__c att : [
                  SELECT id, name, cscfga__Value__c
                  FROM cscfga__Attribute__c
                  WHERE
                  name IN ('Site Id')
                  AND cscfga__Product_Configuration__r.cscfga__Product_Basket__c != :productBasket.Id
                  AND cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c = :AccountID
                  AND cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c IN :BasketStageList
                  AND cscfga__Product_Configuration__r.Type__c NOT IN ('Cancel', 'Modify')
              ]) {
                  if (SiteIdSet.size() > 0 && SiteIdSet.Contains(att.cscfga__Value__c))
                      return '{"status":"error","text":"' + syncConstMap.get('Site_Validation') != null? syncConstMap.get('Site_Validation').value__c:'' + '"}';
              }
          }
          if (bIsDisconnectionDateBlank) {
              return '{"status":"error","text":"'+syncConstMap.get('DDate_Validation')!= null? syncConstMap.get('DDate_Validation').value__c:''+'"}';
          }
          return 'ok';
      }
      /**
  * @CreatedBy : Kamlesh/Shweta
  * @Description :  This method will throw validation if discount end date is less than today
  */
      public static string checkCLI(string basketId) {
          String returnVal = '';
          List<charge_line_item__c> cli = [
              SELECT id, name, (SELECT id, name, BusinessID__c, discountEndDate__c FROM Discount_Line_Items__r)
              FROM charge_line_item__c
              WHERE basketId__c = :basketId AND Product_Configuration__r.cscfga__Product_Definition__r.Name IN ('Business Calling', 'Unified Communication Device')
              LIMIT 1
          ]; //EDGE-147970-Added Business Calling as per new ngUC model.
          if (cli.size() > 0 && cli[0].Discount_Line_Items__r.size() > 0) {
              if (cli[0].Discount_Line_Items__r[0].BusinessID__c == 'DMCAT_Discount_000899' && cli[0].Discount_Line_Items__r[0].discountEndDate__c < Date.today() && syncConstMap.get('EAP_ContractError')!=null) {
                  return '{"status":"error","text":"' + syncConstMap.get('EAP_ContractError').value__c + '"}';
              }
          }
          return returnVal;
      }
      /**
  *@Created Date : 29/09/2020
  *@Breif : This method checks if opportunity already has basket with contractinitated status or not
  */
      public static string checkPrimaryPresentWithContractInitiated(cscfga__Product_Basket__c productBasket, List<cscfga__Product_Basket__c> primaryBasket) {
          for(cscfga__Product_Basket__c basket : primaryBasket) {
              if(basket.id != productBasket.id && ((CustomConfigurationOptions__c.getValues('ContractInitiate')!=null && basket.csordtelcoa__Basket_Stage__c == CustomConfigurationOptions__c.getValues('ContractInitiate').Enrichment_Basket_Stage__c)||
                                                   (CustomConfigurationOptions__c.getValues('ContractAccepted')!=null &&  basket.csordtelcoa__Basket_Stage__c == CustomConfigurationOptions__c.getValues('ContractAccepted').Enrichment_Basket_Stage__c)) && syncConstMap.get('OpenContractAlreadyExists')!=null) {
                                                       return '{"status":"error","text": "' + syncConstMap.get('OpenContractAlreadyExists').value__c + ' ' + basket.Name + '"}';
                                                   } else if(productBasket.recordType.Name != 'Inflight Change' && CustomConfigurationOptions__c.getValues('Quote')!=null && basket.csordtelcoa__Basket_Stage__c != CustomConfigurationOptions__c.getValues('Quote').Enrichment_Basket_Stage__c &&
                                                             CustomConfigurationOptions__c.getValues('ContractRejected')!=null && basket.csordtelcoa__Basket_Stage__c != CustomConfigurationOptions__c.getValues('ContractRejected').Enrichment_Basket_Stage__c &&
                                                             CustomConfigurationOptions__c.getValues('CommercialConfiguration')!=null && basket.csordtelcoa__Basket_Stage__c != CustomConfigurationOptions__c.getValues('CommercialConfiguration').Enrichment_Basket_Stage__c &&
                                                             CustomConfigurationOptions__c.getValues('SowApproved')!=null && basket.csordtelcoa__Basket_Stage__c !=CustomConfigurationOptions__c.getValues('SowApproved').Enrichment_Basket_Stage__c &&
                                                             syncConstMap.get('Contract_Initiated_Failed')!=null){
                                                                 return '{"status":"error","text":"' + syncConstMap.get('Contract_Initiated_Failed').value__c+ '"}';
                                                             }
          }
          return 'ok';
      }
      /**
  * @CreatedDate : 29/09/200
  * @Breif : Compare the opportunity redemption amount with total amount
  */
      public static string checkRedemptionAmount(cscfga__Product_Basket__c productBasket) {
          Decimal redemptionamount = productBasket.cscfga__Opportunity__r.Basket_Redemption_amount__c;
          Id oppAccountId = productBasket.cscfga__Opportunity__r.AccountId;
          //Opportunity opp = [SELECT id, Basket_Redemption_amount__c, AccountId FROM Opportunity WHERE id = :productBasket.cscfga__Opportunity__c LIMIT 1];
          if (redemptionamount > 0) {
              // Fetching OneFund Balance for Account
              Map<String, Object> params = new Map<String, Object>();
              params.put('recordId', oppAccountId);
              Flow.Interview.Show_Available_OneFunds_on_Retrospective_Redemption_Screen ShowOneFundBalance = new Flow.Interview.Show_Available_OneFunds_on_Retrospective_Redemption_Screen(
                  params
              );
              ShowOneFundBalance.start();
              Decimal availableOneFundBalance = (Decimal) ShowOneFundBalance.getVariableValue('TotalOneFundAmount');
              //Error on insufficient OneFund balance
              if((redemptionamount > availableOneFundBalance) && syncConstMap.get('Insufficient_OnFund_Balance')!=null) {
                  return '{"status":"error","text":"' + syncConstMap.get('Insufficient_OnFund_Balance').value__c+ '"}';
              }
          }
          return 'Ok';
      }
      /**
  * @CreatedDate : 29/09/2020
  * @Breif : Validation to check contract for SOW
  */
      public static string checkSOW(String basketId) {
          list<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
          prodConfigList = [
              SELECT id, Name, OfferName__c
              FROM cscfga__Product_Configuration__c
              WHERE cscfga__Product_Basket__c = :basketId AND Marketable_Offer__r.Type__c = 'Professional Service'
          ];
          if (prodConfigList.size() > 0) {
              List<SOW__c> SOWlist = [SELECT id, Basket__c, Status__c FROM SOW__c WHERE Basket__c = :basketId];
              //If no SOW generated but creating Contract show Notification
              if (SOWlist.size() == 0 && syncConstMap.get('SOW_Generate_Notification')!=null) {
                  return '{"status":"error","text":"' +syncConstMap.get('SOW_Generate_Notification').value__c+ '"}';
              } else {
                  //if SOW is not approved but generating Contarct show notification
                  for (SOW__c SOW : SOWlist) {
                      if (SOW.Status__c != 'Approved' && syncConstMap.get('SOW_Approval_Notification')!=null) {
                          return '{"status":"error","text":"' + syncConstMap.get('SOW_Approval_Notification').value__c+ '"}';
                      }
                  }
              }
          }
          return 'Ok';
      }
      
      /**
  * @CreatedDate : 10/11/2020
  * @Breif : Validation to check Requestor field for Non-Commercial Order Basket
  */
      public static string checkRequestor(cscfga__Product_Basket__c productBasket){
          if (String.isBlank(productBasket.Order_Requester__c)) { 
              return '{"status":"error","text":"'+System.Label.Label_OrderRequestor_Null+'"}';
          }   
          else
          {
              Contact con = [SELECT firstName,Email,Phone,MobilePhone,lastName FROM Contact WHERE Id =:productBasket.Order_Requester__c];
              System.debug('con..'+con);
              if((con.Email== '' || con.Email == null) || (con.firstName== '' || con.firstName == null) || (con.lastName== '' || con.lastName == null)|| ((con.phone  =='' || con.phone == null) && (con.MobilePhone =='' ||con.MobilePhone ==null)))
              {
                  return '{"status":"error","text":"'+System.Label.Label_ContactDetails_Null+'"}';
              }
          }
          return 'Ok';
      }
      
      
      
      /**
  * @CreatedDate : 10/11/2020
  * @Breif : Validation to check Reference field for Non-Commercial Order Basket
  */
      public  static string checkReferenceNumber(cscfga__Product_Basket__c productBasket){
          Id profileId = UserInfo.getProfileId();
          Profile profile = [SELECT Id, Name FROM Profile WHERE Id =:profileId];
          if(profile.Name == 'Assurance Service Agent'){
              if(String.isBlank(productBasket.referencenumber__c)){
                  return EnrichBasketConstants.ERROR_STATUS1 + System.Label.NCO_BasketValidation_ReferenceNullCheck + EnrichBasketConstants.CLOSE_BRACKET;
              }
              else{
                  /*Pattern refPattern = Pattern.compile('[T|t]{1}[N|n]{1}[C|c]{1}[0-9]{9}');
  Matcher refMatcher = refPattern.matcher(productBasket.referencenumber__c);
  if(refMatcher.matches())
  {
  return 'Ok';
  }
  else{
  return EnrichBasketConstants.ERROR_STATUS1 + System.Label.NCO_BasketValidation_ReferenceInvalidErrorMsg + EnrichBasketConstants.CLOSE_BRACKET;
  }*/
                  return ProductUtil.refNumPatternCheck(productBasket.referencenumber__c);
              }
          }
          else{
              return 'Ok';
          }
      }
      
      
      
      /**
  * @CreatedDate : 04/01/2021
  * @Breif : EDGE-191824 In-Flight: PONR Check before initiating Contract/Skip Contract/Quote
  */
  @AuraEnabled
      public static string CheckPONRforServices(cscfga__Product_Basket__c productBasket){
      system.debug('inside CheckPONRforServices');
          String recordtypename = productBasket.recordType.Name;
          system.debug('recordtypename = ' + recordtypename + productbasket.recordTypeId);
          Boolean validationResponse = false;
              if ( recordtypename == 'Inflight Change') {  
                      CustomButtonQuoteRF.callingSource = 'Contract';//EDGE-201334
                      validationResponse = PONRUtilityClass.ValidatePONRforBasket(productBasket);
                      CustomButtonQuoteRF.callingSource = '';                 
                  if(validationResponse){
                      return '{"status":"error","text":"' + Label.Order_has_reached_PONR + '"}';
                  }  
          }
          system.debug('out CheckPONRforServices');
          return 'Ok'; 
      }
      
      /**
          * @CreatedDate : 06/05/2021
          * @Breif : Compare the Available amount and basket redemption amount.
          */
          public static string compareAvailableAmtRedemptionAmt(cscfga__Product_Basket__c productBasket) {
              string basketId = productBasket.Id;           
              Decimal redemptionamount;
              Id oppAccountId;
              
              for(cscfga__Product_Basket__c prodBsktLst : [Select cscfga__Opportunity__r.Basket_Redemption_amount__c, cscfga__Opportunity__r.AccountId from cscfga__Product_Basket__c where id=:basketId LIMIT 1]){
                  redemptionamount = prodBsktLst.cscfga__Opportunity__r.Basket_Redemption_amount__c;
                  oppAccountId = prodBsktLst.cscfga__Opportunity__r.AccountId;
              }           
              
              if (redemptionamount > 0) {
                  // Fetching OneFund Balance for Account
                  Map<String, Object> params = new Map<String, Object>();
                  params.put('recordId', oppAccountId);
                  Flow.Interview.Show_Available_OneFunds_on_Retrospective_Redemption_Screen ShowOneFundBalance = new Flow.Interview.Show_Available_OneFunds_on_Retrospective_Redemption_Screen(
                  params
                  );
                  ShowOneFundBalance.start();
                  Decimal availableOneFundBalance = (Decimal) ShowOneFundBalance.getVariableValue('TotalOneFundAmount');
                  //Error on insufficient OneFund balance
                  if((redemptionamount > availableOneFundBalance) && syncConstMap.get('Insufficient_OnFund_Balance')!=null) {
                      return '{"status":"error","text":"' + syncConstMap.get('Insufficient_OnFund_Balance').value__c+ '"}';
                  }
              }
              return 'Ok';
          }
        /************************************************************************
        Name: isProductEndDateExpired
        Description: Invokes validation after clicking on SkipContract/Quote/Contract button..
        Story : EDGE-215103
        Developer: Sajal Shah(Team Cairo)
        Description: This method Invokes validations related to services and its associated add-ons for Skip Contract/Quote/Contract button
        ************************************************************************/
        public static Boolean isProductEndDateExpired(cscfga__Product_Basket__c productBasket){
            System.debug('---isProductEndDateExpired---');
            Boolean showValidation = false;
            if(productBasket != null){
                List<Legacy_Service__c> legacyServiceList = new List<Legacy_Service__c>([SELECT Id FROM Legacy_Service__c WHERE Product_basket__c =:productBasket.Id]);
                Set<Id> legacyServiceIdSet = new Set<Id>();
                List<Service_add_on__c> serviceAddOnList = new List<Service_add_on__c>();
                List<Service_add_on__c> selectedServiceAddOnList = new List<Service_add_on__c>();
                String dateToday = String.valueOf(date.today());
                for(Legacy_Service__c legacyService : legacyServiceList){
                    legacyServiceIdSet.add(legacyService.Id);
                }
                serviceAddOnList = [SELECT Id, Status__c, Legacy_Service__r.select__c, Product_End_Date__c FROM Service_add_on__c WHERE Legacy_Service__r.Id IN :legacyServiceIdSet];
                for(Service_add_on__c serviceAddOns : serviceAddOnList){
                    //START: Modified for EDGE-9338
                    if(serviceAddOns.Legacy_Service__r.select__c == true && serviceAddOns.Status__c == 'Sync Completed' && serviceAddOns.Product_End_Date__c < Date.today()) {
                    //END for EDGE-9338
                        selectedServiceAddOnList.add(serviceAddOns);
                    }
                }      
                System.debug('Selected::'+selectedServiceAddOnList);
                
                if(!selectedServiceAddOnList.isEmpty()){
                    showValidation =  true;                    
                }     
            }
            System.debug('---showValidation---'+showValidation);
            return showValidation;
        }
    /************************************************************************
        Name: validateSDWANProduct
        Story : DIGI-931
        Developer: Radhika 
        Description: This method is used to validate if all SDWAN offers are added into the basket on click of Sync Button
        ************************************************************************/
        public static string validateSDWANProduct(String basketId,List<cscfga__Product_Configuration__c> configList,cscfga__Product_Basket__c productBasket){
            try
            {
                List<String> specList = new List<String> {System.Label.SDWAN_OFFER,System.Label.SECUREEDGE_OFFER,System.Label.VELOCLOUD_OFFER};
                 Map<String,String> mapSpecIdPDName =new Map<String,String>();
                    mapSpecIdPDName.put(System.Label.SDWAN_OFFER,System.Label.SDWAN_ADAPT_S1_PD_Name);
                    mapSpecIdPDName.put(System.Label.SECUREEDGE_OFFER,System.Label.SecureEdgeSolution);
                    mapSpecIdPDName.put(System.Label.VELOCLOUD_OFFER,System.Label.VeloCloudSolution);
                String accId = productBasket.csbb__Account__c;
                List<csord__Subscription__c> pcListCIdn =[SELECT ConfigSpecID__c FROM csord__Subscription__c
																	WHERE csord__Account__c=:accId 
                                                                    and ConfigSpecID__c in(:System.Label.SECUREEDGE_OFFER,:System.Label.VELOCLOUD_OFFER) 
                                                                    and csord__Status__c = 'Active']; 
                        for(csord__Subscription__c config:pcListCIdn)
                        { 
                                  
                                if(specList.contains(config.ConfigSpecID__c))
                                {
                                    Integer index =specList.indexOf(config.ConfigSpecID__c);
                                    specList.remove(index);
                                }
                         }
                 List<cscfga__Product_Configuration__c> pcList =[select cscfga__Product_Definition__r.product_Specification__c from cscfga__Product_Configuration__c
                                                  where cscfga__Product_Basket__c =:basketId
                                                  and cscfga__Product_Definition__r.product_Specification__c in(:System.Label.SDWAN_OFFER,:System.Label.SECUREEDGE_OFFER,:System.Label.VELOCLOUD_OFFER)]; 
                        for(cscfga__Product_Configuration__c config:pcList)
                        { 
                                  
                                if(specList.contains(config.cscfga__Product_Definition__r.product_Specification__c))
                                {
                                    Integer index =specList.indexOf(config.cscfga__Product_Definition__r.product_Specification__c);
                                    specList.remove(index);
                                }
                         }
                        if(pcList!=null && !pcList.isEmpty())
                        {
                           
                             if(specList!=null && !specList.isEmpty())
                             {
                                      String pdnameList='';
                                        for(String sp:specList)
                                        {
                                             if(mapSpecIdPDName.containskey(sp))
                                             {
                                                 if(pdnameList =='')
                                                 {
                                                     pdnameList += ' '+ mapSpecIdPDName.get(sp);
                                                 }
                                                 else
                                                 {
                                                     pdnameList += ','+ mapSpecIdPDName.get(sp);
                                                 }
                                                 
                                             }
                                        }
                                      return '{"status":"error", "text":"Please add Product '+ pdnameList + ' in SDWAN basket before proceeding"}';    
                                }
                        }
       
                return 'Ok';
            }
     		catch(Exception err){
                  System.debug('err..'+err);
                   return '{"status":"error","text":"'+err+'"}';
              }
        }
  }