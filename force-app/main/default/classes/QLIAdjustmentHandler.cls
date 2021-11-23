/************************************************************ 
* @version      - 0.1
* @createdBy    - Ramesh Somalagari
* @team         - OSAKA
* @jirastoryRef - EDGE-111167
******************************************************************/ 
public without sharing class QLIAdjustmentHandler {
    public static final String INTEGRATION_HANDLER_NAME = 'QLIAdjustmentHandler';
    
    /**
*  The method will helps to get "Max Credit Amount" on "Queried Line Item" object.
*  @name              - calculateEligibleCreditAmount
*  @param qli_List    - List of Queried Line Item records
*  @return void       - 
*  @throws exception  - Throw an error if callout is failed
*  @jira Story Ref    - EDGE-111167
*  @createdBy         - Ramesh Somalagari
*  @team              - OSAKA
**/
    public static void calculateEligibleCreditAmount(list<Queried_Line_Item__c> qli_List){
        
        try{
            QLIAdjustmentRequestDTO QLI_DTO = generatePayLoad(qli_List);
            if(QLI_DTO != null && !QLI_DTO.chargeDetails.isEmpty() && QLI_DTO.chargeDetails.size() > 0){
                System.debug('Generated Paylaod :: '+JSON.serialize(QLI_DTO,true));
                HttpResponse response  = calloutQLI(QLI_DTO);
                System.debug('response :: '+response);
                if(response != null && response.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_SUCCESS) //200
                {
                    System.debug('response.getBody() :: '+response.getBody());
                    QLIAdjustmentResponseDTO resData  = QLIAdjustmentResponseDTO.parse(response.getBody());
                    System.debug('resData :: '+resData);
                    if(resData == null){
                        throw new CustomException('Response Parsing Error :: '+response.getBody());  
                    }
                    System.debug('resData.creditAdjustmentEligiblity :: '+resData.creditAdjustmentEligibility);
                    if(resData != null && !resData.creditAdjustmentEligibility.isEmpty() && resData.creditAdjustmentEligibility.size() > 0){
                        updateQLIData(resData,qli_List);
                    }
                    
                }
            }
        }catch(Exception e){
            System.debug('eligibleCreditAmount :: Something went wrong :: '+e);
            Logger2 logger = Logger2.getLogger(INTEGRATION_HANDLER_NAME);
            logger.logMessages(JSON.serialize(generatePayLoad(qli_List),true), String.valueOf(e) ,'', 'Technical', '500', '',false,false,500,'',null,null);
            
        }
        
    }
    /**
*  The method will helps to update the "Queried Line Item" object.
*  @name             - updateQLIData
*  @param resData    - QLIAdjustmentResponseDTO Class
*  @param qli_List   - List of Queried Line Item records
*  @return void      - 
*  @throws exception - 
*  @jira Story Ref   - EDGE-111167
*  @createdBy        - Ramesh Somalagari
*  @team             - OSAKA
**/
    public static void updateQLIData(QLIAdjustmentResponseDTO resData,list<Queried_Line_Item__c> qli_List)
    {
        Map<String,Queried_Line_Item__c> qliMap = new Map<String,Queried_Line_Item__c>();
        Map<ID,Queried_Line_Item__c> updateQLI  = new Map<ID,Queried_Line_Item__c>();
        for(Queried_Line_Item__c QLI : qli_List)
        {
            /**  Start of EDGE:113051
@Modified/updatedBy: Sasidhar Devarapalli
@team              : Osaka
@Description:fetching InvoiceLineNumber from InvoiceLineItem object instead of QueriedLineItem object
as InvoiceLineNumber field is deleted from QueriedLineItem
**/
            if(QLI.Invoice_Line_Item__c != null && QLI.Invoice_Line_Item__r.Invoice_Line_Number__c != null ){
                qliMap.put(String.valueOf(QLI.Invoice_Line_Item__r.Invoice_Line_Number__c), QLI);
            }
            //End of EDGE:113051
        }
        for(QLIAdjustmentResponseDTO.creditAdjustmentEligibility creatAdj : resData.creditAdjustmentEligibility){
            if(creatAdj.invoiceLineNumber != null && creatAdj.maxCreditAmount != null  && qliMap.containsKey(String.valueOf(creatAdj.invoiceLineNumber))){
                Queried_Line_Item__c qli = qliMap.get(String.valueOf(creatAdj.invoiceLineNumber));
                qli.Max_Credit_Amount__c = creatAdj.maxCreditAmount;
                updateQLI.put(qli.id, qli);
            }
        }
        if(!updateQLI.isEmpty() && updateQLI.size() > 0){
            update updateQLI.values();
        }
    }
    /**
*  The method will helps to call the BDS external system and get the "Max Credit Amount" data.
*  @name                - calloutQLI
*  @param QLI_DTO       - QLIAdjustmentRequestDTO Class
*  @return HttpResponse - HttpResponse as JSON format and it contains "Billing Line Item Adjustment" datails
*  @throws exception    - CustomException
*  @jira Story Ref      - EDGE-111167
*  @createdBy           - Ramesh Somalagari
*  @team                - OSAKA
**/
    public static HttpResponse calloutQLI(QLIAdjustmentRequestDTO QLI_DTO){
        HttpResponse response        = null;
        Logger2 logger2               = Logger2.getLogger(INTEGRATION_HANDLER_NAME);
        String reqBody               = JSON.serialize(QLI_DTO,true);
        String correlationId         = EDISSingleManager.getUID();
        Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(INTEGRATION_HANDLER_NAME);
        String token                 = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
        if(handleSettingRecord != null) {
            if(handleSettingRecord.Enable_Mock_Integration__c){
                token = System.Label.QLI_Token;
            }
            else{
                token = AuthenticationManager.getOauthToken(INTEGRATION_HANDLER_NAME);
            }
        }  
        
        Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'correlationId'=>correlationId};
            Datetime sdt = Datetime.now();
        Long requestStartTime  = sdt.getTime();
        response                     = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, INTEGRATION_HANDLER_NAME);
        Datetime edt = Datetime.now();
        Long requestEndTime = edt.getTime();
        Long finalTime = requestStartTime-requestEndTime;
        System.debug('calloutQLI :: response :: '+response);
        System.debug('calloutQLI :: response.getBody() :: '+response.getBody());
        if(response != null && response.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_SUCCESS)//200
        {    
            logger2.logMessages(JSON.serialize(reqBody), response.getBody(),'', '', '', '',''+response.getStatusCode(),correlationId, NULL,NULL,NULL, 'Read',finalTime,IntegrationRecordHandlerUtil.HTTP_METHOD_POST,false,false);
            return response;
        }
        else{
            String errorMessage = 'calloutQLI :: Invalid response code for "Billing Line Item Adjustment. "'+response+' :: '+response.getBody();
            logger2.logMessages(JSON.serialize(reqBody), response.getBody(),'', '', '', '',''+response.getStatusCode(),correlationId, NULL,NULL,NULL, 'Read',finalTime,IntegrationRecordHandlerUtil.HTTP_METHOD_POST,false,false);           
            throw new CustomException(errorMessage);
        }
    }
    /**
*  The method will helps to generate the payload for Billing Line Item Adjustment
*  @generatePayLoad     - calloutQLI
*  @param qli_List      - List of Queried Line Item records
*  @return QLIAdjustmentRequestDTO - QLIAdjustmentRequestDTO/null
*  @throws exception    - 
*  @jira Story Ref      - EDGE-111167
*  @createdBy           - Ramesh Somalagari
*  @team                - OSAKA
**/
    public static QLIAdjustmentRequestDTO generatePayLoad(list<Queried_Line_Item__c> qli_List){
        QLIAdjustmentRequestDTO QLI_DTO = null;
        try{
            if(!qli_List.isEmpty() && qli_List.size() > 0 ){
                QLI_DTO = new QLIAdjustmentRequestDTO();
                List<QLIAdjustmentRequestDTO.chargeDetails> chargeDetailsList = new List<QLIAdjustmentRequestDTO.chargeDetails>();
                QLI_DTO.customerAccountNumber = qli_List.get(0).Case__r.Billing_Account__r.Billing_Account_Number__c;
                QLI_DTO.ariaInvoiceNumber = Long.valueOf(qli_List.get(0).Invoice_Line_Item__r.Invoice__r.Aria_Invoice_Number__c);
                for(Queried_Line_Item__c QLI : qli_List)
                {
                    QLIAdjustmentRequestDTO.chargeDetails chargeDetails = new QLIAdjustmentRequestDTO.chargeDetails();
                    chargeDetails.chargeIdentifier = QLI.Invoice_Line_Item__r.Charge_Identifier__c.longValue();
                    chargeDetails.chargeType = QLI.Invoice_Line_Item__r.Charge_Type__c;
                    /**  Start of EDGE:113051
@Modified/updatedBy: Sasidhar Devarapalli
@team              : Osaka
@Description:fetching InvoiceLineNumber from InvoiceLineItem object instead of QueriedLineItem object
as InvoiceLineNumber field is deleted from QueriedLineItem
**/
                    Decimal invoiceNum = QLI.Invoice_Line_Item__r.Invoice_Line_Number__c;
                    //End of EDGE:113051
                    chargeDetails.invoiceLineNumber = invoiceNum.longValue();
                    chargeDetailsList.add(chargeDetails);
                }
                if(!chargeDetailsList.isEmpty() && chargeDetailsList.size()>0){
                    QLI_DTO.chargeDetails =  chargeDetailsList;
                }
            }
            return QLI_DTO;
        }
        catch(Exception e){
            System.debug('generatePayLoad :: Payload generating failed :: '+e);
            return null;
        }
    }
    /**
*  The method will fetch latest Credit and Adjustment Record relatd to Case
*  @generatePayLoad     - 
*  @param qli_List      - Current Case Id
*  @return Credits_and_Adjustments__c - Credits_and_Adjustments__c/null
*  @throws exception    - 
*  @jira Story Ref      - EDGE-157956
*  @createdBy           - Abhishek Mallick
*  @team                - OSAKA
**/
    @AuraEnabled public static Credits_and_Adjustments__c getCreditAndAdjustmentRecord(String id){
        Try{
            if(string.isNotBlank(id)){
                return[SELECT id,Determination_Status__c,Submitted__c,CreatedDate from Credits_and_Adjustments__c 
                       where Case_Number__c =:id ORDER BY CreatedDate desc LIMIT 1];   
            }
        }
        Catch(Exception ex){
            Logger2 log = Logger2.getLogger(INTEGRATION_HANDLER_NAME);
            log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        }
        return null;
    }
    /**
*  The method will fetch data of Current Case record
*  @generatePayLoad     - 
*  @param Id      - Current Case Id
*  @return Case - Case/null
*  @throws exception    - 
*  @jira Story Ref      - EDGE-157956
*  @createdBy           - Abhishek Mallick
*  @team                - OSAKA
**/
    @AuraEnabled public static Case getCaseRecord(String id){
        Try{
            if(string.isNotBlank(id)){
                return[SELECT id,Total_Determination__c from Case 
                       where id =:id ];   
            }
        }
        Catch(Exception ex){
            Logger2 log = Logger2.getLogger(INTEGRATION_HANDLER_NAME);
            log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        }
        return null;
    }
    /**
*  The method will fetch New and Old values of case status of current case record
*  @generatePayLoad     - 
*  @param Id      - Current Case Id
*  @return CaseHistory - CaseHistory/null
*  @throws exception    - 
*  @jira Story Ref      - EDGE-157956
*  @createdBy           - Abhishek Mallick
*  @team                - OSAKA
**/
    @AuraEnabled public static CaseHistory getOldStatusValue(String id){
        Try{
            if(string.isNotBlank(id)){
                return[SELECT Id, CaseId, Field, OldValue, NewValue, CreatedDate FROM CaseHistory 
                       where CaseId = :id order by CreatedDate desc limit 1];   
            }
        }
        Catch(Exception ex){
            Logger2 log = Logger2.getLogger(INTEGRATION_HANDLER_NAME);
            log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        }
        return null;
    }
    /**
*  The method will performs check of QLI related to Case 
*  @generatePayLoad     - 
*  @param Id      - Current Case Id
*  @return Boolean - true/false
*  @throws exception    - 
*  @jira Story Ref      - EDGE-157956
*  @createdBy           - Abhishek Mallick
*  @team                - OSAKA
**/
    @AuraEnabled public static Boolean getQueriedLineItem(String id){
        List<Queried_Line_Item__c> qliList = new List<Queried_Line_Item__c>();
        List<Id> qliId = new List<Id>();
        Boolean flag;
        Try{
            if(string.isNotBlank(id)){
                qliList=[select id,Case__c,No_Credit_Required__c,Determination_Amount__c from Queried_Line_Item__c where Case__c = :id];
                if(!qliList.isEmpty()){
                    for(Queried_Line_Item__c qli_Rec : qliList){
                        if(qli_Rec.No_Credit_Required__c == false && (qli_Rec.Determination_Amount__c == 0 ||qli_Rec.Determination_Amount__c == Null  )){
                            qliId.add(qli_Rec.id);
                        }
                    }
                    if(!qliId.isEmpty()){
                        flag = true; 
                    }
                    else{
                        flag = false;
                    }
                }
                else{
                    flag = true;
                }
            }
        }
        Catch(Exception ex){
            Logger2 log = Logger2.getLogger(INTEGRATION_HANDLER_NAME);
            log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        }
        return flag;
    }
    /**
*  The method will performs check on size of attachments/attachments exists, marked as external for current case record.
*  @generatePayLoad     - 
*  @param Id      - Current Case Id
*  @return Boolean - true/false
*  @throws exception    - 
*  @jira Story Ref      - EDGE-157956
*  @createdBy           - Abhishek Mallick
*  @team                - OSAKA
**/
    @AuraEnabled public static boolean getAttachmentDetails(String id){
        Boolean flag;
        Integer calculateTotalSize = 0;
        List<contentDocumentLink> contentDocumentLinkRecord = new List<contentDocumentLink>();
        List<ContentVersion> contentVersionRecord = new List<ContentVersion>();
        List<Id> contentDocumentId = new List<Id>();
        Try{
            if(string.isNotBlank(id)){
                contentDocumentLinkRecord=[SELECT ContentDocumentId from contentDocumentLink where LinkedEntityId=:id];
            }
            for(contentDocumentLink conId : contentDocumentLinkRecord){
                contentDocumentId.add(conId.ContentDocumentId);
            }
            contentVersionRecord=[Select id,ContentSize,Internal__c from contentversion where contentdocumentId in :contentDocumentId and Internal__c = false];
            if(!contentVersionRecord.isEmpty()){
                for(contentversion contenVersionRec: contentVersionRecord){
                    calculateTotalSize+=contenVersionRec.ContentSize;
                    if(calculateTotalSize>Integer.valueOf(System.Label.Attachment_Size)){
                        flag = true;
                    }
                }
            }
            else{
                flag = false;
            }
        }
        Catch(Exception ex){
            Logger2 log = Logger2.getLogger(INTEGRATION_HANDLER_NAME);
            log.logMessages('' ,'', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        }
        return flag;
    }
}