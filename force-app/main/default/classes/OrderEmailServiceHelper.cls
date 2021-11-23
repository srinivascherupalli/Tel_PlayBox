/**
* Developer: Kunal Dixit,Vanita Mude
* Description: Helper class to generate EmailDTO instance for OrderEmailService class
Class Name : EmailUtils
Test Class : EmailUtilsTest
============================================================================================================================
Change.No.    Developer Name        Date          Story Description
1.            Vijayalakshmi         22/11/2019    EDGE-103485 Changes to handle modify and cancel scenarios for TID
2.            Vijayalakshmi         27/11/2019    EDGE-113407 Changes to handle NGUC email notify
3.            Vijayalakshmi         03/12/2019    EDGE-126306 Changes to handle modify for NGUC email notify
4.            Vijayalakshmi         06/12/2019    EDGE-103485 Changes to remove mobile number population
5.            Vijayalakshmi         12/12/2019    EDGE-127861 Changes for cancel scenario
6.            Dheeraj Bhatt         27/03/2020    EDGE-139046 Move Order Received email from Conga to Notify
7.            Prajakta Patil        21/04/2020    Null checkFix at line 224
8.            Jayesh                23/04/2020    DPG-1415 Confirmation of canceled services
9.            Prajakta              06/08/2020   EDGE-154675
10. 		  Purushottam			02/02/2020    EDGE-171620
11.			  Mukta				    08/09/2021 		DIGI-5635 : Telstra Collaboration changed to Adaptive collaboration

****************************************************************************************************************************
//Defect fix EDGE-117267 - Aniket Srivastava - 25/11/2019
*/
public with sharing class OrderEmailServiceHelper{
    
    /*CONSTANTS - begin --*/
    //private final static String emailQuery = ' FROM APXTConga4__Conga_Email_Template__c WHERE Id = :cTemplateId';
    private final static String ENTITY_TYPE = 'NOT_APPLICABLE';
    private final static String NOTIFICATION_EVENT_TYPE ='EDGESF_ORDER_1';
    private final static String MSISDN='';
    private final static String ROLE_VALUE = 'Decision Maker';
    private final static String PRIMARY_SITE_CONTACT = 'Primary Site Contact';
    private final static String DELIVERY_CONTACT  = 'Delivery Contact';
    private static String IP_SITE = 'IP Site'; 
    //DIGI-5635 NameChange
    private  static String NGUC_OFFER_NAME = Offer_Id__mdt.getInstance('Telstra_Collaboration')?.Template_family__c;   
    //Conga template Contants
    private final static String CWP_SERVICE_REQUEST_COMPLETE = 'CWP_Service_Request_Order_Complete';
    private static String ORDER_PRIMARY_CONTACT_EMAILID = 'ORDER_PRIMARY_CONTACT_EMAILID';
    private static String ORDER_TECHNICAL_CONTACT_EMAILID = 'ORDER_TECHNICAL_CONTACT_EMAILID';
    private static String ORDER_TECHNICAL_CONTACT_MOBILE = 'ORDER_TECHNICAL_CONTACT_MOBILE';
    private static String ORDER_PROJECT_CONTACT_EMAILID = 'ORDER_PROJECT_CONTACT_EMAILID';
    private static String ORDER_PRIMARY_SITE_CONTACT_EMAILID = 'ORDER_PRIMARY_SITE_CONTACT_EMAILID';
    private static String ORDER_DELIVERY_SITE_CONTACT_EMAILID = 'ORDER_DELIVERY_SITE_CONTACT_EMAILID';
    private static String ORDER_BILLING_CONTACT_EMAILID = 'ORDER_BILLING_CONTACT_EMAILID';
    private static String OPPOURTUNITY_EMAILID = 'OPPOURTUNITY_EMAILID';
    private static String SITE_DELIVERY_CONTACT = 'SITE_DELIVERY_CONTACT';
    private static String CUSTOMER_CONTRACT_SIGNATORY = 'CUSTOMER_CONTRACT_SIGNATORY';
    //private static String 
    /*CONSTANTS - end --*/
    
    //method to generate EmailDTO
    public static EmailDTO generateEmailDTO(Id cTemplateId,csord__Order__c ord,csord__Subscription__c sub){
        String fromEmail=null;
        List<String> toEmails=new List<String>();
        List<String> ccEmails=new List<String>();
        List<String> bccEmails=new List<String>();
        String templateId;
        String subject;
        List<Id> attachmentIds= new List<Id>();
        Map<String, String> otherKayValues = new Map<String, String>();
        String relatedtoId = String.valueOf(ord.id).substring(0,15);
        //Mobility_Order_Received
        EmailDTO emailDTO;
        try{
            if(cTemplateId!=null){
                String queryEmailTemplate ='SELECT '+String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('APXTConga4__Conga_Email_Template__c'))+' FROM APXTConga4__Conga_Email_Template__c WHERE Id = :cTemplateId' ;
                APXTConga4__Conga_Email_Template__c template=Database.query(queryEmailTemplate);
                System.debug('dml 3:'+system.Limits.getQueries());
                //templateId=template.APXTConga4__Name__c;
                //subject=OrderEmailService.getSubject(templateId);
                
                if(template != null){
                    templateId=template.APXTConga4__Name__c;
                    subject = template.APXTConga4__Subject__c;
                    System.debug('subject===>'+subject);
                }
                
                Map<String,String>  contactDeliveryMap = new Map<String,String>();
                contactDeliveryMap = getContactDeliveryMap(ord,sub);
                Set<String> toEmailsSet=new Set<String>();
                System.debug('templateId is '+templateId);
                system.debug('contactDeliveryMap::' + contactDeliveryMap );
                String customerFacingServiceId = '';
                csord__Service__c serviceTID = new csord__Service__c();
                //EDGE - 103485 Changes start for modify and cancel scenario for TID
                // Added for DPG-668 : IoT Offer changes
                switch on templateId {
                    when 'CWP_Order_Received','Mobility_Order_Received','Mobility_Cancellation','Mobility_Future_Date_Cancellation','CUSTOMER_ORDER_SINGLE_AND_MULTIPLE_OFFER','CMP_Order_Received','TID_New_Order_Recvd','TID_New_Order_Completed','TID_Modify_Order_Recvd','TID_Modify_Order_Completed','TID_Cancel_Order_Completed','IoT_Order_Received','IoT_Cancel_Order_Complete','EnterprizeMobility(NGEM)_Order_Received' {
                        //EDGE - 103485 Changes end for modify and cancel scenario for TID
                        toEmails=getToEmailsList(ord,contactDeliveryMap,templateId);
                        /** EDGE-100899 : Replace place holders in Conga Email Template Body */
                        System.debug('toEmails is '+toEmails);
                        if(templateId.equals(System.Label.CUSTOMER_ORDER_SINGLE_AND_MULTIPLE_OFFER) || templateId.equals('CMP_Order_Received') || templateId.equals('IoT_Order_Received')){
                            System.debug('Inside CMP/IoT template subject');
                            System.debug('toEmails is '+toEmails);
                            subject = subject + ' : ' + ord.csord__Order_Number__c;
                        }
                        // Changes start for 103485 -- subject line changes
                        if(templateId.equals('TID_New_Order_Recvd') || templateId.equals('TID_Modify_Order_Recvd'))
                        {
                            //DIGI-5635 NameChange
                            subject = 'Your '+NGUC_OFFER_NAME +' order:  ' + ord.csord__Order_Number__c;
                        }
                        if(templateId.equals('TID_New_Order_Completed'))
                        {
                            serviceTID = [SELECT Id,Technical_Contact__r.FirstName,Primary_Contact__r.FirstName,csordtelcoa__Product_Configuration__c,customer_facing_service_id__c 
                                          FROM csord__Service__c
                                          WHERE csord__Order__r.csordtelcoa__Opportunity__c =: ord.csordtelcoa__Opportunity__c and name like '%Internet Site%'];
                            customerFacingServiceId = serviceTID.customer_facing_service_id__c;
                            subject = 'Your Telstra Internet Direct service is ready to go:  ' + customerFacingServiceId;
                        }
                        if(templateId.equals('TID_Modify_Order_Completed'))
                        {
                            subject = 'We’ve completed your Telstra order :  ' + ord.csord__Order_Number__c;
                        }
                        if(templateId.equals('TID_Cancel_Order_Completed'))
                        {
                            //EDGE-127861 Changes start for cancel scenario
                            subject = 'Order ' + ord.csord__Order_Number__c + ' cancellation confirmation';
                            //EDGE-127861 Changes end for cancel scenario
                        }
                        // Changes end for 103485 -- subject line changes

            //#################### DPG-1415 START - Jayesh ####################
                        if(templateId.equals('IoT_Cancel_Order_Complete'))
                        {
              System.debug('Inside IoT Order Subject');
                            subject = 'Order ' + ord.csord__Order_Number__c + ' cancellation confirmation';
                        }
            //#################### DPG-1415 END - Jayesh ####################
            
                       //EDGE-154675 start 
                       if(templateId.equals('EnterprizeMobility(NGEM)_Order_Received'))
                        {
                            System.debug('Inside EnterprizeMobility(NGEM)');
                            subject =   'Your Adaptive Mobility '+'order ' +ord.csord__Order_Number__c;  //EDGE-184269- Changed the offer name from 'Adaptive Mobility Plan' to 'Adaptive Mobility'
                      
                       //EDGE-154675 End
                    }
                    }
                    when 'CWP_Individual_Location_Complete_Ready_To_Bill','CWP_Service_Request_Order_Complete' {                        
                        toEmails = getToEmailsList(ord,contactDeliveryMap,templateId);
                        ccEmails = getCCEmailsList(ord,templateId);
                    }
                    when 'Order_Completed' {
                        toEmails = getToEmailsList(ord,contactDeliveryMap,templateId);
                        //bccEmails.add(ord.Project_Manager_Email__c);
                        bccEmails = getBCCEmailsList(ord);
                    }
                    //EDGE -113407 Changes start for NGUC email notify
                    //EDGE-126306 -- Changes start for ngUC Modify
                    when 'ngUC_Order_Recvd', 'ngUC_modify_received', 'ngUC_modify_complete', 'ngUC_cancelOrder_complete' {
                        System.debug('Inside ngUCSignupCommunicationTemplate');
                        toEmails = getToEmailsList(ord,contactDeliveryMap,templateId);
                        if(templateId.equals('ngUC_Order_Recvd') || templateId.equals('ngUC_modify_received'))
                        {
                            //DIGI-5635 NameChange
                            subject = 'Your '+NGUC_OFFER_NAME+' order  ' + ord.csord__Order_Number__c;
                        }
                        if(templateId.equals('ngUC_modify_complete'))
                        {
                            System.debug('Inside ngUC_modify_complete');
                            subject = 'We’ve completed your Telstra order ' + ord.csord__Order_Number__c;
                        }
                        if(templateId.equals('ngUC_cancelOrder_complete'))
                        {
                            System.debug('Inside ngUC_cancelOrder_complete');
                            //EDGE-127861 Changes start for cancel scenario
                            subject = 'Order ' + ord.csord__Order_Number__c + ' cancellation confirmation';
                            //EDGE-127861 Changes end for cancel scenario
                        }
                        //EDGE-126306 -- Changes end for ngUC Modify
                    }
                    //EDGE -113407 Changes end for NGUC email notify
                }
            }
        } catch(Exception e) {
            System.debug('i am in catch');
            Logger2 logger=Logger2.getLogger(OrderEmailServiceHelper.class);
            logger.logMessages(null,null,e.getStackTraceString(),'Technical','Exception',e.getMessage(), false, false);
            System.debug('Exception here :: '+e.getMessage());
            logger.exitLogger();
        }
        System.debug('toEmails is ' +toEmails);
        emailDTO = new EmailDTO(fromEmail, toEmails,ccEmails,bccEmails,templateId, subject, attachmentIds, ENTITY_TYPE, ENTITY_TYPE, NOTIFICATION_EVENT_TYPE, MSISDN, relatedtoId, otherKayValues);
        System.debug('emailDTO is '+emailDTO);
        return emailDTO;
    }
    
    
    /*********************************************************************************************************************************
* Method Name      :   getContactDeliveryMap
*Return            :   Returns Map<String,String>
************************************************************************************************************************************/
    public static Map<String,String> getContactDeliveryMap(csord__Order__c ord,csord__Subscription__c sub){
        Map<String,String>  contactDeliveryMap = new Map<String,String>();  
        Map<String,String>  finalContactDeliveryMap = new Map<String,String>();    
        List<String> siteContactRole = new List<String>{PRIMARY_SITE_CONTACT,DELIVERY_CONTACT};
            try{
                List<Functional_Contact_Role__c> functionalContactRoleList = new List<Functional_Contact_Role__c>();
                if(sub.site__c != null){
                    functionalContactRoleList = [select Id,ContactID__c,ContactID__r.Email,Role__c from Functional_Contact_Role__c where siteID__c=:sub.site__c and Role__c IN :siteContactRole];
                }
                
                for(Functional_Contact_Role__c functionalContactRole : functionalContactRoleList){
                    if(PRIMARY_SITE_CONTACT.equals(functionalContactRole.Role__c)){
                        contactDeliveryMap.put(ORDER_PRIMARY_SITE_CONTACT_EMAILID,functionalContactRole.ContactID__r.Email);
                    }
                    if(DELIVERY_CONTACT.equals(functionalContactRole.Role__c)){
                        contactDeliveryMap.put(ORDER_DELIVERY_SITE_CONTACT_EMAILID,functionalContactRole.ContactID__r.Email);
                    }
                }
                
                //get primary billing contacts                                     
                //  Billing_Account__c billingAccount=[select Id,Billing_Account_Owner__c,Billing_Account_Owner__r.Email from Billing_Account__c where Id=:ord.Billing_Account__c];
                //contactDeliveryMap.put(ORDER_BILLING_CONTACT_EMAILID,billingAccount.Billing_Account_Owner__r.Email);
                contactDeliveryMap.put(ORDER_BILLING_CONTACT_EMAILID,ord.Billing_Account__r.Billing_Account_Owner__r.Email);
                //to add oppty email id
                contactDeliveryMap.put(OPPOURTUNITY_EMAILID,ord.csordtelcoa__Opportunity__r.Owner.Email);
                system.debug('contactDeliveryMap===>'+contactDeliveryMap);
                System.debug('ord.csordtelcoa__Opportunity__r.Owner.Email===>'+ord.csordtelcoa__Opportunity__r.Owner.Email);
                //get contact details from Service
                List<csord__Service__c> serviceList = [SELECT Order_Primary_Contact__c, Order_Primary_Contact__r.Email,
                                                       Technical_Contact__c,Technical_Contact__r.Email,Technical_Contact__r.MobilePhone,
                                                       Project_Contact__c,Project_Contact__r.Email,Site_Delivery_Contact__c,Site_Delivery_Contact__r.Email FROM csord__Service__c WHERE(csord__Order__c = :ord.id OR csord__Order__r.csord__Primary_Order__c = :ord.id)];
                for(csord__Service__c service : serviceList){
                    
                    contactDeliveryMap.put(ORDER_PRIMARY_CONTACT_EMAILID,service.Order_Primary_Contact__r.Email);
                    contactDeliveryMap.put(ORDER_TECHNICAL_CONTACT_EMAILID,service.Technical_Contact__r.Email);
                    contactDeliveryMap.put(ORDER_PROJECT_CONTACT_EMAILID,service.Project_Contact__r.Email); 
                    if(service.Site_Delivery_Contact__c!= null && service.Site_Delivery_Contact__r.Email!= null){
                       contactDeliveryMap.put(SITE_DELIVERY_CONTACT,service.Site_Delivery_Contact__r.Email); //EDGE-181176
                    }
                    // system.debug('contactDeliveryMapjhdsjfh===>'+contactDeliveryMap);
                }
                
                 //EDGE-181176
                if(ord.csordtelcoa__Opportunity__c!= null){
                    
                List<dsfs__DocuSign_Recipient_Status__c>docSignContact =[select id,ContractJunction__c,ContractJunction__r.Related_Opportunity__c,dsfs__DocuSign_Recipient_Email__c from dsfs__DocuSign_Recipient_Status__c where ContractJunction__r.Related_Opportunity__c!= null AND ContractJunction__r.Related_Opportunity__c=:ord.csordtelcoa__Opportunity__c];
                
                if(docSignContact!= null){
                for(dsfs__DocuSign_Recipient_Status__c dcs:docSignContact){
                     
                     if(dcs.dsfs__DocuSign_Recipient_Email__c!= null){
                        contactDeliveryMap.put(CUSTOMER_CONTRACT_SIGNATORY,dcs.dsfs__DocuSign_Recipient_Email__c);  
                     }
                }}
                }
                finalContactDeliveryMap.putAll(contactDeliveryMap);
                system.debug('contactDeliveryMapjhdsjfh===>'+finalContactDeliveryMap);
            }catch(Exception e){ System.debug('Exception in getContactDeliveryMap :: '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());throw e;
                               }
        return finalContactDeliveryMap;
    }
    
    
    /*********************************************************************************************************************************
* Method Name      :   getToEmailsList
*Return            :   Returns List<String>
************************************************************************************************************************************/
    public static List<String> getToEmailsList(csord__Order__c ord,Map<String,String> contactDeliveryMap,String templateId ){       
        Set<String> toEmailsSet=new Set<String>();                      
        List<String> toEmailsList = new List<String>(); 
        
        try{
            
            if(templateId !='EnterprizeMobility(NGEM)_Order_Received'){ // EDGE-154675
            //to add order requestor   //tfauirizmj@gmail.com             
            List<Contact> orderRequestor = [SELECT EMAIL FROM CONTACT WHERE ID IN (SELECT CONTACTID FROM OPPORTUNITYCONTACTROLE WHERE OPPORTUNITYID = :ord.csordtelcoa__Opportunity__c AND ISPRIMARY = true AND ROLE =: ROLE_VALUE) LIMIT 1];
            //to add Contract Signatory
            //cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE Primary_Basket__c = true and csbb__Synchronised_With_Opportunity__c = true and cscfga__Opportunity__c = :ord.csordtelcoa__Opportunity__c];
            
            //Project manager Id
            // String pmEmail=[select id,Project_Manager_Email__c from csord__Order__c where id=:ord.id].Project_Manager_Email__c;
            if(!orderRequestor.isEmpty()){
                toEmailsSet.add(orderRequestor[0].Email);
                System.debug('orderRequestor->'+orderRequestor[0]);
            }               
            if(templateId != CWP_SERVICE_REQUEST_COMPLETE){
                // toEmailsSet.addAll(OrderEmailService.getContractSignatories(basket.Id));
                System.debug('inside oppty');
                if(contactDeliveryMap.get(OPPOURTUNITY_EMAILID) != null)
                    toEmailsSet.add(contactDeliveryMap.get(OPPOURTUNITY_EMAILID));
                System.debug('toEmailsSet-->'+toEmailsSet);
            }
            
            if(contactDeliveryMap.get(ORDER_PRIMARY_CONTACT_EMAILID) != null){
                toEmailsSet.add(contactDeliveryMap.get(ORDER_PRIMARY_CONTACT_EMAILID));
            }
            if(contactDeliveryMap.get(ORDER_TECHNICAL_CONTACT_EMAILID) != null){
                toEmailsSet.add(contactDeliveryMap.get(ORDER_TECHNICAL_CONTACT_EMAILID));
            }
            if(contactDeliveryMap.get(ORDER_PRIMARY_SITE_CONTACT_EMAILID) != null){
                toEmailsSet.add(contactDeliveryMap.get(ORDER_PRIMARY_SITE_CONTACT_EMAILID));
            }
            System.debug('toEmailsSetdhsjh-->'+toEmailsSet);
            //add all emails to original list
            toEmailsList.addAll(toemailsSet); 
            System.debug('toEmailsList===>'+toEmailsList);
            }else{ // EDGE-154675 start
               // EDGE-154675 start
                if(contactDeliveryMap.get(SITE_DELIVERY_CONTACT) != null){
                toEmailsSet.add(contactDeliveryMap.get(SITE_DELIVERY_CONTACT));
                }
                if(contactDeliveryMap.get(CUSTOMER_CONTRACT_SIGNATORY) != null){
                 toEmailsSet.add(contactDeliveryMap.get(CUSTOMER_CONTRACT_SIGNATORY));  
                }
            // EDGE-154675 end
            // EDGE-154675 end
            }
            toEmailsList.addAll(toemailsSet); 
            System.debug('toEmailsList===>'+toEmailsList);
                        
        }catch(Exception e){System.debug('Exception in getToEmailsList ::'+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());throw e;
                           }
        return toEmailsList;
    }
    
    /*********************************************************************************************************************************
* Method Name      :   getCCEmailsList
*Return            :   Returns List<String>
************************************************************************************************************************************/
    public static List<String> getCCEmailsList(csord__Order__c ord,String templateId){
        List<String> ccEmailsList=new List<String>();
        Set<String> ccEmailsSet=new Set<String>();
        try{
            
            // cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE Primary_Basket__c = true and csbb__Synchronised_With_Opportunity__c = true and cscfga__Opportunity__c = :ord.csordtelcoa__Opportunity__c];
            //Project manager Id
            String pmEmail=[select id,Project_Manager_Email__c from csord__Order__c where id=:ord.id].Project_Manager_Email__c;
            ccEmailsSet.add(pmEmail);
            if(templateId.contains(CWP_SERVICE_REQUEST_COMPLETE)){
                //ccEmailsSet.addAll(OrderEmailService.getContractSignatories(basket.Id));
                ccEmailsSet.add(ord.csordtelcoa__Opportunity__r.Owner.Email);
                
            }
            ccEmailsList.addAll(ccEmailsSet);}catch(Exception e){system.debug('Exception in getCCEmailsList ::'+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString()); throw e;}
        
        return ccEmailsList;
    }
    
    /*********************************************************************************************************************************
* Method Name      :   getBCCEmailsList
*Return            :   Returns List<String>
************************************************************************************************************************************/
    public static List<String> getBCCEmailsList(csord__Order__c ord){
        List<String> bccEmailsList=new List<String>();
        try{           
            bccEmailsList.add(ord.Project_Manager_Email__c);
        }catch(Exception e){System.debug('Exception in getBCCEmailsList ::'+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());throw e;
                           } 
        
        return bccEmailsList;
    }
    
    public static Map<Id,ContractJunction__c> getContractJunctionByOpportunity(List<csord__Order__c> orderList){
        Double routingOrder = 2.0;
        List<Id> opportunityIds = new List<Id>();
        Map<Id,ContractJunction__c> contractJunctionMap = new Map<Id,ContractJunction__c>();
        for(csord__Order__c order : orderList){
            opportunityIds.add(order.csordtelcoa__Opportunity__c);
        }
        for(List<ContractJunction__c> contractJunctionList : [SELECT Id, Name, Related_Opportunity__c, Contract_Number__c,Customer_Primary_Contact__r.Email, Email__c,
                                                              (select Id, dsfs__DocuSign_Recipient_Email__c from DocuSign_Recipient_Status__r where dsfs__DocuSign_Routing_Order__c = :routingOrder)
                                                              from ContractJunction__c where Related_Opportunity__c IN : opportunityIds]){
                                                                  for(ContractJunction__c contractJunction : contractJunctionList){
                                                                      contractJunctionMap.put(contractJunction.Related_Opportunity__c,contractJunction);
                                                                  }
                                                              }
        return contractJunctionMap;
    }
    
    /*********************************************************************************************************************************
* Method Name      :   orderReceivedNgUC
*Return            :   Returns EmailDTO
******/
    public static EmailDTO orderReceivedNgUC(csord__Order__c order,List<String> toemails,String offerId,csord__Subscription__c subscription,Id TemplateId){//EDGE-100920
        EmailDTO psNgUCOrderReceived = new EmailDTO();
        /*EDGE-139046-27-Mar-2020-Dheeraj Bhatt-Added below if condition to make orderReceivedNgUC method genric.Email Dto will be formed as per offer code*/
        if(offerId.equals('DMCAT_Offer_000936')){
            psNgUCOrderReceived.notificationEventType = 'PROFESSIONAL_SERVICE_TELSTRA_COLLABORATION';
            psNgUCOrderReceived.entityId = 'NOT_APPLICABLE';
            psNgUCOrderReceived.entityType = 'NOT_APPLICABLE';
            psNgUCOrderReceived.toEmails = toemails;
            //psNgUCOrderReceived.subject = 'Your Professional Services for Adaptive Collaboration order '+order.csord__Order_Number__c;
            psNgUCOrderReceived.otherKayValues = new Map<String, String>{'order_number'=>order.csord__Order_Number__c,'cid'=>order.csord__Account__r.CIDN__c};
                }
        
        /*EDGE-139046-27-Mar-2020-Dheeraj Bhatt-<Appointment Notification> Move Order Received email from Conga to Notify */
        else if(offerId.equals('DMCAT_Offer_000618')){
            Map<String,String>  contactDeliveryMap = new Map<String,String>();
            contactDeliveryMap = getContactDeliveryMap(order,subscription);
            psNgUCOrderReceived.notificationEventType = Label.DMCAT_Offer_000618_notificationEventType;
      //APPOINTMENT_COLLAB_ORDER_RECEIVED
            psNgUCOrderReceived.entityId = order.csord__Account__r.Account_UUID__c;
            psNgUCOrderReceived.entityType = 'NOT_APPLICABLE';
            psNgUCOrderReceived.toEmails=getToEmailsList(order,contactDeliveryMap,templateId);
            psNgUCOrderReceived.otherKayValues = new Map<String, String>
            {'Order_ID'=>order.csord__Order_Number__c,
                'first_name'=>'',
                'ct_app_booked'=>'False',
                'app_list'=>'',
                'cid'=>order.csord__Account__r.CIDN__c
                };
        }
        /*********End-EDGE-139046***************/
            return psNgUCOrderReceived;
    } 
    /*********************************************************************************************************************************
	* Method Name      :   generateAmendEmailDTO - EDGE-171620
	*Return            :   Returns EmailDTO
	**********************************************************************************************************************************/
    public static EmailDTO generateAmendEmailDTO(csord__Order__c order,List<csord__Subscription__c> subscriptionList,NotifyEmail__mdt amendMDT){
        set<string> toEmails= new set<string>();
        set<String> agreementRefList= new set<String>();
        set<String> billingAccountList= new set<String>();
        set<String> partnerNameList= new set<String>();
        set<String> partnerPhoneList= new set<String>();
        set<String> partnerEmailList= new set<String>();
        for(csord__Subscription__c sub : subscriptionList){
            if(sub.contractJunction__c != null && sub.contractJunction__r.Name != null){
                toEmails.add(sub.contractJunction__r.Email__c);
                agreementRefList.add(sub.contractJunction__r.Name);
            }
            if(sub.Billing_Account__c != null && sub.Billing_Account__r.Name != null){
                billingAccountList.add(sub.Billing_Account__r.Name);
            }
            if(sub.PartnerAccount__c != null){
                partnerNameList.add(sub.PartnerAccount__r.name);
                partnerPhoneList.add(sub.PartnerAccount__r.phone);
                partnerEmailList.add(sub.PartnerAccount__r.Email__c);
            }
        }
        EmailDTO emailDTO = new EmailDTO();
        emailDTO.notificationEventType = amendMDT.Event_Type__c;
        emailDTO.entityType = amendMDT.entityType__c;
        emailDTO.entityId = amendMDT.entityId__c;
        emailDTO.relatedtoId = order.id;
        emailDTO.toEmails=new List<String>(toEmails);
        emailDTO.otherKayValues=new Map<String, String>
            {	'agreement_ref'=>String.join(new List<String>(agreementRefList), ','),
                'cid'=>order.csord__Account__r.CIDN__c,
				'order_number'=>order.csord__Order_Number__c,
                'billing_account_number'=>String.join(new List<String>(billingAccountList), ','),
                'por_name'=>String.join(new List<String>(partnerNameList), ','),
				'por_phone'=>String.join(new List<String>(partnerPhoneList), ','),
				'por_email'=>String.join(new List<String>(partnerEmailList), ','),
                'support_hrs'=> amendMDT.Support_Hours__c
                };
        return emailDTO;
    }
}