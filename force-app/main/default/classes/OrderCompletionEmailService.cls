public with sharing class OrderCompletionEmailService implements Queueable,Database.AllowsCallouts{

    private List<Id> orderId;

    public class OrderEmail{
        public String emailRecipient {set;get;}
        public String orderNumber {set;get;}
        public String contractNumber {set;get;}
    }

    public OrderCompletionEmailService(List<Id> orderId){
        this.orderId = orderId;
    }

    @invocablemethod
    public static void sendEmailByOrderID(List<Id> orderIds){
               if(Limits.getQueueableJobs() == 0){
            		System.enqueueJob(new OrderCompletionEmailService(orderIds));
			 }
           }

    public void execute(QueueableContext context){
        List<OrderEmail> orderEmailList = new List<OrderEmail>();
        Map<String,EmailRequest> emailRequestMap = NULL;
        List<csord__Order__c> orderList = [SELECT Id, Name, csord__Order_Number__c, csordtelcoa__Opportunity__c from csord__Order__c where Id IN:orderId];
        Map<Id,ContractJunction__c> contractJunctionMap = OrderEmailServiceHelper.getContractJunctionByOpportunity(orderList);
        for(csord__Order__c order : orderList){
            OrderEmail orderEmail = new OrderEmail();
            orderEmail.orderNumber = order.csord__Order_Number__c;
            ContractJunction__c contractJunction = contractJunctionMap.get(order.csordtelcoa__Opportunity__c);
            
			if(contractJunction!=null){
					orderEmail.contractNumber = contractJunction.Name;
                    orderEmail.emailRecipient = (contractJunction.Customer_Primary_Contact__r.Email!=null)?contractJunction.Customer_Primary_Contact__r.Email  : contractJunction.Email__c;
					//for(dsfs__DocuSign_Recipient_Status__c docuSignRecipients : contractJunction.DocuSign_Recipient_Status__r){
					//	orderEmail.emailRecipient = docuSignRecipients.dsfs__DocuSign_Recipient_Email__c;
					//}
					 orderEmailList.add(orderEmail);
			}
        }		
        emailRequestMap = createEmailRequest(orderEmailList);
        sendEmailUsingNotify(emailRequestMap);
    }

    public static Map<String,EmailRequest> createEmailRequest(List<OrderEmail> orderEmailList){
        String emailBody = null;
        String emailSubject = null;
        List<EmailRequest> emailRequestList = new List<EmailRequest>();
        Map<String,EmailRequest> emailRequestMap = new Map<String,EmailRequest>();
        String templateName = 'Order_Completion_Template_Combined';
        String queryEmailTemplate ='SELECT '+String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('APXTConga4__Conga_Email_Template__c'))+' FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = :templateName' ;
        List<APXTConga4__Conga_Email_Template__c> templateConfig = Database.query(queryEmailTemplate);
        for(APXTConga4__Conga_Email_Template__c congaEmailTemplate : templateConfig){
            emailSubject = congaEmailTemplate.APXTConga4__Subject__c;
            emailBody = congaEmailTemplate.APXTConga4__HTMLBody__c;
        }
        for(OrderEmail orderEmail : orderEmailList){
            EmailRequest emailRequest = emailRequestMapping(orderEmail,emailSubject,emailBody);
            emailRequestMap.put(orderEmail.orderNumber,emailRequest);
            emailRequestList.add(emailRequest);
        }
        return emailRequestMap;
    }

    private static EmailRequest emailRequestMapping(OrderEmail orderEmail, String emailSubject, String emailBody){
        EmailRequest emailReq = new EmailRequest();
        List<EmailRequest.ContentParameters> contentParams = new List<EmailRequest.ContentParameters>();
        emailReq.entityType = 'NOT_APPLICABLE';
        emailReq.notificationEventType = 'EDGESF_ORDER_1';
        emailReq.entityId = 'NOT_APPLICABLE';
        EmailRequest.Recipient toEmailRecipient = new EmailRequest.Recipient();
        toEmailRecipient.emailAddress = orderEmail.emailRecipient;
        toEmailRecipient.msisdn = '';
        toEmailRecipient.emailDeliveryType ='TO';
        emailReq.recipients = new List<EmailRequest.Recipient>{toEmailRecipient};
        //Adding Subject Line
        EmailRequest.ContentParameters cpSubject = new EmailRequest.ContentParameters();
        cpSubject.name = 'email_subject';
        cpSubject.value = emailSubject.replace('order.number',orderEmail.orderNumber);
        contentParams.add(cpSubject);
        //Finished adding Subject line
        //Adding email body
        EmailRequest.ContentParameters cpBody = new EmailRequest.ContentParameters();
        cpBody.name = 'email_body';
        cpBody.value = emailBody.replace('contract.contractnumber',orderEmail.contractNumber).replace('sytem.current.date', Datetime.now().format('dd-MM-yyyy'));
        contentParams.add(cpBody);
        //Finished adding Email body.
        emailReq.ContentParameters = contentParams;
        return emailReq;
        
    }

    public static void sendEmailUsingNotify(Map<String,EmailRequest> emailRequestMap){
        String handlerName = 'EmailHandler';
         Logger2 logger2 = Logger2.getLogger(handlerName);
        for(String orderNumber : emailRequestMap.keySet()){
            try{
                Long requestTime;
                String token = AuthenticationManager.getOauthToken(EmailService.class.getName());
                Map<String,String> headerMap = new Map<String,String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer '+ token};
                headerMap.put('Correlation-Id',orderNumber);
				DateTime startTime = DateTime.now();
                HTTPResponse httpResponse = IntegrationRecordHandlerUtil.callout(JSON.serialize(emailRequestMap.get(orderNumber)), IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, EmailHandler.class.getName(), new List<String>{'1'},null);
				DateTime endTime = DateTime.now();
				requestTime = logger2.getRequestTimeDifference(startTime, endTime);
                if(httpResponse != null /*&& httpResponse.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_ACCEPTED*/) { //Request was successfully accepted				
               				 logger2.logMessages(JSON.serialize(emailRequestMap.get(orderNumber)),  'httpResponse.getBody()', '',  '',  '',  '', String.valueOf(httpResponse.getStatusCode()), '', '',  '', '', 'Update', requestTime, 'POST' ,false, false);//CLF Changes         
				}
            } catch(Exception ex){
			   logger2.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
                System.debug('Email Request exception : ' + ex.getMessage());
            }
			finally {
                   logger2.exitLogger();
              }
        }
    }

}