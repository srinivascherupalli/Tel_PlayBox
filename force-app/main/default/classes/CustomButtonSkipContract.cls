/*********************************************************************************************************************************
*Class Name      :   CustomButtonSkipContract
*Story             :   EDGE-81113  MDM from legacy to sfdc
*Developer         :  Rohit Tripathi

Test Class : CustomButtonSkipContractTest
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Shubhi Vijayvergia      21/Aug/2019   EDGE-81113  MDM from legacy to sfdc
2.        Dheeraj Bhatt           26-Nov-2020   EDGE-185845  Ability to skip Quote and Contract for orders that are migrated from AM-L to AM-D
3.        Dheeraj Bhatt           18-jan-2021   EDGE-198055 -Trigger the TM2 for Migration Order
4.        Pooja Gupta             05/01/2021    EDGE-191824 - PONR Check before initiating Contract/Skip Contract/Quote
5.        Venkat T                27/01/2021    EDGE-199023-If record Type InFlight Change and Remediation type basket then Move the basket stage to "Contract Accepted" post "Skip Contract"
6.        Arunkumar V             15/02/2021    EDGE-201334 - Stop performing PONR updates to Heroku during basket journey
7.        Shweta Khandelwal       19/2/2021     EDGE-198910
8.        Aman Soni            19/04/2021    EDGE-207355  Handle validation for skip contract button 
*********************************************************************************************************************************
*/
global with sharing class CustomButtonSkipContract extends csbb.CustomButtonExt {
    /**
* performAction method overriden to provide enrich basket implementation
* @param      basketId  The basket identifier
* @return     String JSON format values
*/
    public static String DisplayMessage;
    public static String orderform = Label.Order_Form;
    public static final Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId(); //EDGE-226364 Schedule Record type fetch
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');//EDGE-185845-Dheeraj Bhatt- Get the constant value from metadata
    public String performAction(String basketId) {
        System.debug('Hi');
        
        
        try{
           //Added by Aman Soni for EDGE-207355 || Start
            List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>();
            Set<String> attNameFilterSet=new Set<String>{'BillingAccountLookup'};
            Map<String,cscfga__Product_Configuration__c> pcMap=Model_ProductConfiguration.getConfigMap(basketId,attNameFilterSet);
            if(pcMap!=null && !pcMap.isEmpty())
                configList=pcMap.values();
            //Added by Aman Soni for EDGE-207355 || End 
            //configList = [SELECT  Id,Name,Marketable_Offer__r.name,cscfga__Configuration_Status__c,cscfga__total_contract_value__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,cscfga__Description__c,cscfga__Contract_Term__c,Type__c,configGUID__c,ConfigurationType1__c,cscfga__Product_Definition__r.name,(SELECT id, Name, cscfga__Value__c FROM cscfga__Attributes__r where name ='BillingAccountLookup') FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c = :basketId];
            
            
            String queryString = 'SELECT ';
            queryString += 'id, ';
            queryString += 'csordtelcoa__Basket_Stage__c, ';
            queryString += 'Name, ';
            queryString += 'cscfga__Basket_Status__c, ';
            queryString += 'BasketType__c, ';   //added for basket type EDGE-199023
            queryString += 'cscfga__Opportunity__c, ';
            queryString += 'csbb__Synchronised_with_Opportunity__c,';
            queryString += 'cscfga__Opportunity__r.Model_Change__c, ';
            queryString += 'csbb__Account__c, ';
            queryString += 'cscfga__Opportunity__r.Type, ';
            queryString += 'cscfga__Opportunity__r.AccountId, ';
            queryString += 'Express_Flow__c,';
            queryString += 'recordType.Name ';//added recordType.Name in the query as part of EDGE-191824
            queryString += 'FROM ';
            queryString += 'cscfga__Product_Basket__c ';
            queryString += 'WHERE ';
            queryString += 'id = :basketId';
            system.debug('QueryString-->'+queryString);
            cscfga__Product_Basket__c productBasket = Database.query(queryString);
            
           //Added by Aman Soni for EDGE-207355 || Start
            String resp = '';
            ValidationsForBasketOperations valdBasketOps = new ValidationsForBasketOperations();
            resp = valdBasketOps.performValidation(productBasket, configList, 'Skip Contract');
            if(resp.contains('error')){
                return resp;
            }
            //Added by Aman Soni for EDGE-207355 || End  

            //EDGE-191824 start
            string recordTypeNamePB = productBasket.recordType.Name;
            Boolean response = false;
            if(recordTypeNamePB == 'Inflight Change'){
                CustomButtonQuoteRF.callingSource = 'Skip Contract';//EDGE-201334
                response  = PONRUtilityClass.ValidatePONRforBasket(productBasket);
                if(!Test.isRunningTest())
                CustomButtonQuoteRF.callingSource = '';
            }
            if(response){
                return '{"status":"error","text":"' + Label.Order_has_reached_PONR + '"}';
            }
            //EDGE-191824 end
            
            List<ContractJunction__c> updatedExistingContract = new List<ContractJunction__c>();
            Set<Id> contractJun = new Set<Id>();
            cscfga__Product_Basket__c basketList = [select id,(select id from ContractJunctions__r) from cscfga__Product_Basket__c where id = :basketId];
            for(ContractJunction__c conJun: basketList.ContractJunctions__r){
                contractJun.add(conJun.id);
            }
            
            
            system.debug('basket--->'+ productBasket);
            String recordTypeID = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get(orderForm).getRecordTypeId();
            
            //EDGE-199023-if Inflight Change record type and BasketType is Remediation type 
            if(productBasket!=null && recordTypeNamePB == 'Inflight Change' /*&& productBasket.BasketType__c=='Remediation'*/){
                //EDGE-217780: Vivek
                Boolean hasCustomPermission = FeatureManagement.checkPermission('Express_Order_Enabled');
                productBasket.csordtelcoa__Basket_Stage__c='Contract Accepted';
                //productBasket.csbb__Synchronised_with_Opportunity__c=true;
                update productBasket; CustomButtonQuoteRF.callingSource = 'Skip Contract Heroku'; //Shweta Added
                HerokuConfigurationsUtility.PushResetHerokuConfigurations(basketId); //Shweta added EDGE 198910 
                CustomButtonQuoteRF.callingSource = ''; //Shweta added
                //EDGE-217780: Vivek
                        if(hasCustomPermission==true){
                            List<Opportunity> Opportunities=[select id , Type from Opportunity where id=:productBasket.cscfga__Opportunity__c];
                            if(!Opportunities.isEmpty() && Opportunities[0].Type == 'Migration'){
                                Opportunities[0].Type='Renewal'; update Opportunities[0];
                            }
                        }
                return '{"status":"ok","text":"Success"}'; 
            }
            
            if(productBasket!=null && (productBasket.Express_Flow__c==true || productBasket.cscfga__Opportunity__r.Type == 'Migration' ) ){
                if(productBasket.cscfga__Opportunity__r.Type == 'Migration'){
                    String serviceResponse = CustomButtonContractSentRF.contractServiceValidation(basketId);  
                    System.debug('@@serviceResponse '+serviceResponse);  
                    if(!String.isBlank(serviceResponse )){  
                        return serviceResponse;  
                    }
                }
                List<Apttus__APTS_Agreement__c> agreement =new List<Apttus__APTS_Agreement__c>();
                //EDGE-185845-Dheeraj Bhatt- fetch AM-L legacy DSA agreement record if  opportunity is Migration type
                if(customMetadataNameValueMap.containsKey('Migration') && productBasket.cscfga__Opportunity__r.Type == customMetadataNameValueMap.get('Migration').get('Value__c')){
                    agreement=fetchDSAAgreementRecord(productBasket.cscfga__Opportunity__r.AccountId);  
                    System.debug('@@agreement '+agreement);
                    //EDGE-208432:Enable system validations to ensure DSA agreement exists before Skip Contract
                    if(agreement.isEmpty()){
                      return '{"status":"error","text":"'+Label.DSA_agreement_Validation+'"}';  
                    }
                }
                 if(recordTypeNamePB != 'Inflight Change'){
                     //EDGE-217780: Vivek
                    Boolean hasCustomPermission = FeatureManagement.checkPermission('Express_Order_Enabled');
                    
                    productBasket.csordtelcoa__Basket_Stage__c='Contract Accepted'; productBasket.csbb__Synchronised_with_Opportunity__c=true;  
                    update productBasket;
                    //EDGE-217780: Vivek
                     if(hasCustomPermission==true){
                        List<Opportunity> Opportunities=[select id , Type from Opportunity where id=:productBasket.cscfga__Opportunity__c];
                        System.debug('@@@Opportunities2'+Opportunities);
                        if(!Opportunities.isEmpty() && Opportunities[0].Type == 'Migration'){
                            Opportunities[0].Type='Renewal';
                            update Opportunities[0];
                        }
                     }
                }
                /* List<Apttus__APTS_Agreement__c> agreement =new List<Apttus__APTS_Agreement__c>();
                //EDGE-185845-Dheeraj Bhatt- fetch AM-L legacy DSA agreement record if  opportunity is Migration type
                if(customMetadataNameValueMap.containsKey('Migration') && productBasket.cscfga__Opportunity__r.Type == customMetadataNameValueMap.get('Migration').get('Value__c')){
                    agreement=fetchDSAAgreementRecord(productBasket.cscfga__Opportunity__r.AccountId);  
                }*/
                ContractJunction__c oldContract=new ContractJunction__c();
                oldContract.Account__c = productBasket.csbb__Account__c;
                oldContract.BSA_Generated__c=true;
                oldContract.Related_Opportunity__c=productBasket.cscfga__Opportunity__c;
                oldContract.Related_Basket__c=productBasket.id;
                oldContract.Status__c='In Effect';
                oldContract.Contract_Activated_Date__c=Date.Today();
                
                // EDGE-97613 - Adding more conditions - Start
                oldContract.CongaStatus__c='Success';
                oldContract.Contract_Expiry_Date__c=Date.Today().addDays(30);
                oldContract.Name='CN' + productBasket.Name.substring(2);
                oldContract.recordTypeId=recordTypeId;
                //EDGE-185845-Dheeraj Bhatt- map AM-L legacy DSA agreement record to contract junction recordfor Migration opportunity
                if(customMetadataNameValueMap.containsKey('Migration') && productBasket.cscfga__Opportunity__r.Type == customMetadataNameValueMap.get('Migration').get('Value__c') && !agreement.isEmpty()){
                    oldContract.Agreement_Number__c= agreement[0].Apttus__Agreement_Number__c;
                    oldContract.Related_Price_Schedule__c= agreement[0].Id;
                }
                
                if(contractJun.isEmpty() && contractJun.size()==0){
                    insert oldContract;
                    if(customMetadataNameValueMap.containsKey('Migration') && productBasket.cscfga__Opportunity__r.Type == customMetadataNameValueMap.get('Migration').get('Value__c')){
                        //EDGE-198055 -Dheeraj Bhatt- Added IsMigratedContract__c to set it to true to trigger TM2 for for Migration Order
                        oldContract.IsMigratedContract__c=true; 
                        update oldContract;
                    }
                }
                else{
                    List<ContractJunction__c> existingContract = [select id,Contract_Activated_Date__c,Agreement_Number__c,Related_Price_Schedule__c from ContractJunction__c where id = :contractJun];
                    system.debug('existingContract=='+existingContract);
                    
                    for(ContractJunction__c con : existingContract){
                        con.Contract_Activated_Date__c = Date.Today();
                        //EDGE-185845-Dheeraj Bhatt- map AM-L legacy DSA agreement record to contract junction recordfor Migration opportunity
                        if(customMetadataNameValueMap.containsKey('Migration') && productBasket.cscfga__Opportunity__r.Type == customMetadataNameValueMap.get('Migration').get('Value__c') && !agreement.isEmpty()){
                            con.Agreement_Number__c= agreement[0].Apttus__Agreement_Number__c;
                            con.Related_Price_Schedule__c= agreement[0].Id;
                            con.IsMigratedContract__c=true;
                        }
                        updatedExistingContract.add(con);
                    }
                }
                if(!updatedExistingContract.isEmpty() && updatedExistingContract.size()>0){
                    update updatedExistingContract;
                }              
                //EDGE-97613 end
                
                //insert oldContract;
                
            /*String serviceResponse = CustomButtonContractSentRF.contractServiceValidation(basketId);
            System.debug('@@serviceResponse '+serviceResponse);
            if(!String.isBlank(serviceResponse)){
                return serviceResponse;
            }*/
                
                return '{"status":"ok","text":"Success"}';
            }
            return '{"status":"error","text":"Failed"}';
            
        }
        catch(Exception e) {
            
            System.debug(LoggingLevel.INFO, 'CustomButtonSkipContract.exception = ' + e+' '+e.getlineNumber());
            DisplayMessage = e.getMessage();
            if(DisplayMessage == null || DisplayMessage.contains('CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY'))
                //DisplayMessage = 'Only the opportunity owner can sync the product basket';
                //status = 'error';
                return '{"status":"error","text":"'+DisplayMessage+'"}';
        }
        return '{"status":"error","text":"Failed"}';
    }
    /*********************************************************************************************
Method      -fetchDSAAgreementRecord
Description -Fetch AM-L legacy DSA agreement record
Author      -Dheeraj Bhatt
EDGE        -EDGE-185845
**********************************************************************************************/
    public static List<Apttus__APTS_Agreement__c> fetchDSAAgreementRecord(String accountId){
        Id SA_Agreement_recordtypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        List<Apttus__APTS_Agreement__c> existingDSAAgreementOnAccount= [SELECT Id, RecordTypeId,name,Apttus__Agreement_Number__c,Apttus__Status_Category__c, Apttus__Agreement_Category__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Status_Category__c ='In Effect' AND Apttus__Account__c = :accountId AND Apttus__Status__c != 'Cancelled Request' AND RecordTypeId=:AGREEMENT_Schedule_RECORDTYPEID  LIMIT 1]; //EDGE-226364-- Record Type change
        return existingDSAAgreementOnAccount;
    }  
}