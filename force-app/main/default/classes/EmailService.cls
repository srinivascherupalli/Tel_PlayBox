/***************************************************************************************************************************
*Class Name : EmailService
*Description: To get Email
*Code refactoring as a part of EDGE-109480
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Monali Mukherjee       29/11/19       EDGE-113536 Header Map changes, added Correlation-Id as order Number
2.            Vanita Mude            30/12/2019    EDGE-127368- CLF changes done under the tech debt story
3.            Vishal Arbune          25/09/2020    EDGE-169633 : Use NOTIFY to send an FYI email with Order form to the customer.
4.            Vishal Arbune          31/12/2020    EDGE-195678 Ensure TM2 call is triggered for MACD Order post Contract Accepted
5.            Pooja Gupta            10/03/2021    EDGE-191759 Order Form generation for CHOWN
6.            Vishal Arbune          17/06/2021    EDGE-223497 : Monitoring :: NGUCMISSION || SIT QA2 || In TIPT SIPC transition order,TM2 request is triggered twice
****************************************************************************************************************************/

public with sharing class EmailService {
    public static final String IN_PROGRESS = 'In Progress';
    public static final String ERROR = 'Error';
    
    // This is the method for external parties to call
    public void send(EmailDTO dto) {
        try{
            System.debug('send EmailDTO dto :'+dto);
            Blob b = Crypto.GenerateAESKey(128);
            String GUID = EncodingUtil.ConvertTohex(b);
            IntegrationRecordHandlerUtil.createRequests('EmailHandler', new List<String>{dto.relatedtoId+':'+dto.toEmails+dto.ccEmails+dto.bccEmails},JSON.serialize(dto));
        }catch(Exception e){System.debug('Exception in send from EmailService :: '+e.getMessage());}
    }
    
    //Start of EDGE-116123: Overloaded method to distict params value for differnt status
    public void send(EmailDTO dto,String Status) {
        Blob b = Crypto.GenerateAESKey(128);
        String GUID = EncodingUtil.ConvertTohex(b);IntegrationRecordHandlerUtil.createRequests('EmailHandler', new List<String>{dto.relatedtoId+':'+dto.toEmails+dto.ccEmails+dto.bccEmails+Status},JSON.serialize(dto));
        //Create integration request and pass to handler
    } //End  of EDGE-116123
    
    //This method is for intergration handler to use
    @future(callout=true)
    public static void sendEmail(String param) {
        try{
            String handlerName = 'EmailHandler';
            String orderNumber;
            //EDGE-169633
            String basketid;
            String notification_Event_Type;
            Long requestTime;
            //TM2WebCalloutUtil tm2callout = new TM2WebCalloutUtil();
            Logger2 logger2 = Logger2.getLogger(handlerName);
            Integration_Record__c paramRequest = [SELECT Id, params__c, paramPayload__c
                                                  FROM Integration_Record__c
                                                  WHERE params__c = :param order by CreatedDate desc LIMIT 1 ];
            
            String emailDtoJson =  paramRequest.paramPayload__c;
            EmailDTO dto = (EmailDTO) JSON.deserialize(emailDtoJson, EmailDTO.class);
            //update for EDGE-113536 - Header Map changes, added Correlation-Id as order Number
            String relatedtoId = dto.relatedtoId;
            //EDGE-169633            
            notification_Event_Type = dto.notificationEventType;
            String token = AuthenticationManager.getOauthToken(EmailService.class.getName());
            Map<String,String> headerMap = new Map<String, 
                String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer '+ token};
                    //update for EDGE-113536 - Header Map changes, added Correlation-Id as order Number
                    if(relatedtoId != null)
                {
                    List<csord__Subscription__c> subList = [select id,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where id =: relatedtoId OR csord__Order__c = :relatedtoId LIMIT 1];
                    if(!subList.isEmpty()){
                        orderNumber = subList[0].csord__Order__r.csord__Order_Number__c;                    
                        if(!string.isBlank(orderNumber)){
                            headerMap.put('Correlation-Id',orderNumber);
                        }
                    } 
                } 
            EmailRequest emailReq = EmailTransformer.fromEmailDToToEmailRequest(dto);
            
            //CLF changes startTime,endTime
            String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
            System.debug('correlationId :'+correlationId);
            
            DateTime startTime = DateTime.now();
            HTTPResponse reponse = IntegrationRecordHandlerUtil.callout(JSON.serialize(emailReq),
                                                                        IntegrationRecordHandlerUtil.HTTP_METHOD_POST,
                                                                        headerMap, EmailHandler.class.getName(), new List<String>{param},null);
            
            DateTime endTime = DateTime.now();
            System.debug('reponse here :'+reponse);
            requestTime = logger2.getRequestTimeDifference(startTime, endTime);
            if(reponse != null && reponse.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_ACCEPTED) { //Request was successfully accepted 
                System.debug('Got successful reponse here :'+reponse.getStatusCode());
                if(!Test.isRunningTest()){
                    EmailResponse emailRes = (EmailResponse) JSON.deserialize(reponse.getBody(), EmailResponse.class);                               
                    createEmailMessage(dto, IN_PROGRESS, emailRes.correlationId);                
                    //logger2.logMessages(JSON.serialize(emailReq), reponse.getBody(), '', '', '', '', false, false, Integer.valueOf(reponse.getStatusCode()) , null, null, null);
                    //CLF Start
                    logger2.logMessages(JSON.serialize(emailReq), reponse.getBody(), '', '', '',  '', String.valueOf(reponse.getStatusCode()), correlationId, '','','Read','',requestTime ,'GET',false, false);
                    //CLF end
                    
                    //EDGE-169633 : Update Contract & Basket status to 'Contract Accepted' post email sent.                 
                    System.debug('relatedtoId'+relatedtoId);                    
                    
                    if(relatedtoId != null && notification_Event_Type == System.Label.B2B_P2O_ORDER_REQUEST){
                        ContractJunction__c updateCJ = [Select id, name, status__c,Related_Basket__c from ContractJunction__c where id =: relatedtoId];
                        updateCJ.status__c = 'Contract Accepted';   
                        basketid = updateCJ.Related_Basket__c;          
                        update updateCJ;    
                        System.debug('Contract status changes to Contract Accepted');
                    }
					 System.debug( 'basketid'+basketid);                    
                    if(basketid != null && notification_Event_Type == System.Label.B2B_P2O_ORDER_REQUEST){
                        cscfga__Product_Basket__c pBasket = [Select id,csordtelcoa__Basket_Stage__c,BasketType__c,csordtelcoa__Previous_Product_Basket__c from cscfga__Product_Basket__c where id=:basketid];//Added csordtelcoa__Previous_Product_Basket__c, BasketType__c in the query EDGE-191759
                        pBasket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';                      
                        update pBasket; 
                        System.debug('Basket status changes to Contract Accepted');                    
                    }
                    //EDGE-223497 : Removing below TM2 callout as part of this Edge post discussion with Singh, Gaganjeet & Aswin Kumaran.
                    //System.enqueueJob(new TM2CalloutApex(basketid));                    
                }
            } else {
                //EDGE-157963: handling error sceanrio billing enquiry resolved cases
                if (emailReq.notificationEventType == System.Label.Billing_Enquiry_Event_Type_Resolved){CaseEmailService.handleErrorScenario(emailReq,reponse.getBody());
                }
                String corId;
                String errorMsg;
                if(reponse != null && !String.isEmpty(reponse.getBody())) {EmailResponse emailRes = (EmailResponse) JSON.deserialize(reponse.getBody(), EmailResponse.class);
                                                                           
                                                                           corId = emailRes.correlationId;
                                                                           system.debug('corId***'+corId);
                                                                           errorMsg = ': Email Sent request failed with code ' + reponse.getStatusCode() + ' and error ' + reponse.getBody();
                                                                           system.debug('errorMsg***'+errorMsg);
                                                                           // logger2.logMessages(JSON.serialize(emailReq), reponse.getBody(), '', '', '', '', false, false, Integer.valueOf(reponse.getStatusCode()) , null, null, null);
                                                                           //CLF Start - EDGE-127368
                                                                           logger2.logMessages(JSON.serialize(emailReq), reponse.getBody(), '', '',  '', 
                                                                                               '', String.valueOf(reponse.getStatusCode()), correlationId, '','','Read','',requestTime ,'GET',false, false);
                                                                           //CLF end - EDGE-127368
                                                                          } else {
                                                                              
                                                                              errorMsg = ': Email Sent request failed as response blank';
                                                                              // logger2.logMessages(JSON.serialize(errorMsg), null, '', '', '', '', false, false, null , null, null, null);
                                                                              system.debug('105errorMsg***'+errorMsg);
                                                                              //CLF Start - EDGE-127368
                                                                              logger2.logMessages(JSON.serialize(emailReq),null, '', '',  '', 
                                                                                                  '', null, correlationId, '','','Read','',requestTime ,'GET',false, false);
                                                                              //CLF end - EDGE-127368                                                                        
                                                                              
                                                                              EmailMessage em = createEmailMessage(dto, ERROR, corId);
                                                                              
                                                                              
                                                                          }}
            logger2.exitLogger();}
        catch(Exception e){System.debug('Exception in sendEmail from EmailService :: '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());throw e;           
                          }
    }
    
    @TestVisible
    private static EmailMessage createEmailMessage(EmailDto emailDto, String status, String correlationId) {
        EmailMessage emailMsg = new EmailMessage();
        try{
            emailMsg.FromAddress = emailDto.fromEmail;
            List<String> toEmailAddresses = new List<String>();
            if(emailDto != null && emailDto.toEmails!= null && emailDto.toEmails.size() > 0){
                // emailAddresses.add(emailDto.toEmails);
                toEmailAddresses = emailDto.toEmails;
                emailMsg.ToAddress = String.join(toEmailAddresses, ';');    
            }
            System.debug('emailMsg.ToAddress==>'+emailMsg.ToAddress);
            if(emailDto != null && emailDto.ccEmails != null && emailDto.ccEmails.size() > 0){
                emailMsg.CcAddress = emailDto.ccEmails.get(0);
            }
            if(emailDto != null && emailDto.bccEmails != null && emailDto.bccEmails.size() > 0){
                emailMsg.BccAddress = emailDto.bccEmails.get(0); 
            }
            emailMsg.Subject = emailDto.subject;
            emailMsg.status__c = status;
            emailMsg.status = '0';
            emailMsg.TextBody = '';
            emailMsg.Correlation_Id__c = correlationId;
            emailMsg.HtmlBody = EmailUtils.emailBodyByTemplateId(emailDto.templateId,emailDto.relatedtoId, emailDto.toEmails);
            emailMsg.RelatedtoId = emailDto.relatedtoId;
            emailMsg.IsExternallyVisible = true;
            system.debug('emailMsg&&&&&&'+emailMsg);
            insert emailMsg;
            createEmailDeliveryRecord(emailMsg,emailDto);
            system.debug('--------------->'+emailMsg);}catch(Exception e){System.debug('Exception in createEmailMessage :: '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());throw e;
                                                                         }
        return emailMsg;
    }
    
    
    private static void createEmailDeliveryRecord(EmailMessage emailrecord,EmailDto emailDto)
    {
        try
        {
            //Check relatedID is for Order or Subscription
            List<csord__Order__c > orderId = [select id from csord__Order__c where id =: emailrecord.RelatedtoId];
            List<csord__Subscription__c> subId = [Select id from csord__Subscription__c where id =: emailrecord.RelatedtoId];
            
            String toAddress = '';
            List<String> toEmailAddresses= new List<String>();
            String bccAddress = '';
            String ccAddress = '';
            
            if(!Orderid.isEmpty() || !subId.isEmpty())
            {      
                
                if(emailDto != null && emailDto.toEmails!= null && emailDto.toEmails.size() > 0){
                    toEmailAddresses= emailDto.toEmails;
                    // toAddress = emailDto.toEmails.get(0);
                    toAddress = String.join(toEmailAddresses, ';');
                }
                System.debug('toAddress createEmailDeliveryRecord ==>'+toAddress );
                
                if(emailDto != null && emailDto.ccEmails != null && emailDto.ccEmails.size() > 0){
                    ccAddress = emailDto.ccEmails.get(0);
                }
                
                if(emailDto != null && emailDto.bccEmails != null && emailDto.bccEmails.size() > 0){
                    bccAddress = emailDto.bccEmails.get(0);
                }
                String emailAll = String.valueOf(toAddress) +';' +String.valueOf(bccAddress) +';' +String.valueOf(ccAddress);
                
                List<String> emailList   = emailAll.split(';'); 
                
                Set<String>  setEmails = new Set<String>();
                setEmails.addAll(emailList );
                emailList.clear();
                emailList.addAll(setEmails);
                
                system.debug('email list is'+emailList);
                
                Integer j = 0;
                while (j < emailList.size())
                {
                    if(emailList.get(j) == null || emailList.get(j) == '') {   emailList.remove(j);
                                                                           }else
                                                                           {
                                                                               j++;
                                                                           }
                }
                system.debug(emailList+'***EmailList***');
                for(Integer i = 0; i < emailList.size(); i++)
                {
                    
                    if  (!orderId.isEmpty()){ProcessEmailDeliveryRecord(emailList[i],emailrecord.Correlation_Id__c,Orderid[0].id);
                                             break;
                                            }
                    
                    if  (!subId.isEmpty())
                    {     
                        ProcessEmailDeliveryRecord(emailList[i],emailrecord.Correlation_Id__c,subId[0].id);
                        break;
                    }
                }
            } }catch(Exception e){
                System.debug('Exception:'+ e.getTypeName() + ' ' + e.getMessage());
            }
    }
    
    @TestVisible
    private static void ProcessEmailDeliveryRecord(String emailId,String CorrelationId,String RelatedID)
    {   //code reacftored
        System.debug('In ProcessEmailDeliveryRecord :'+emailId+' CorrelationId:'+CorrelationId+' RelatedID:'+RelatedID);
        List<EmailDeliveryStatus__c> emaildeliveryList = new List<EmailDeliveryStatus__c> ();
        List<EmailMessage> IdList= [select Correlation_ID__c,CreatedDate,HtmlBody,Status__c,Subject FROM EmailMessage where Correlation_ID__c=:CorrelationId order by createddate desc];
        try{ 
            if(!IdList.isEmpty())
            {
                List<csord__Order__c > orderId = [select id from csord__Order__c where id =: RelatedID];
                List<csord__Subscription__c> subId = [Select id from csord__Subscription__c where id =: RelatedID];
                List<Contact> cont = [select id from Contact where email=: emailId  and Contact_Status__c = 'Active' limit 1];      
                //code reacftored
                for (EmailMessage emailrecord : IdList)
                {
                    EmailDeliveryStatus__c emaildelivery = new EmailDeliveryStatus__c();
                    if((!subId.isEmpty() || !orderId.isEmpty()) && !cont.isEmpty())                        
                    { emaildelivery.Name = emailrecord.Subject;
                     emaildelivery.CorrelationId__c = CorrelationId;
                     emaildelivery.Status__c = emailrecord.status__c;
                     if(!subId.isEmpty()) {
                         emaildelivery.Subscription__c = RelatedID;
                     }
                     if(!orderId.isEmpty()){
                         emaildelivery.Order__c = RelatedID;
                     }
                     if(!cont.isEmpty()){
                         emaildelivery.RecipientContact__c = cont[0].id;
                     }
                     emaildeliveryList.add(emaildelivery);
                    }
                    emaildeliveryList.add(emaildelivery);
                }
                system.debug('*********delivery'+emaildeliveryList);
                insert emaildeliveryList;
            }
            
            
        } catch(Exception e){
            System.debug('Exception:'+ e.getTypeName() + ' ' + e.getMessage());
        }   
    }
}