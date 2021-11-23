/***************************************************************************************************************************
Class Name : EmailUtils
Test Class : EmailUtilsTest
============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Vijayalakshmi         06/11/2019    EDGE-103485 Fetch additional fields from service for TID
2.            Vijayalakshmi         21/11/2019    EDGE-103485 Fetch values for dynamic fields in the TID email notify templates
3.            Vijayalakshmi         02/12/2019    EDGE-126307 Handle cancel scenario for ngUC email notify
4.            Vijayalakshmi         03/12/2019    EDGE-126306 Handle modify scenario for ngUC email notify 
5.            Yash                  13/12/2019    EDGE-98409  CMP Cancellation email notify
6.            Manish Jha            23/03/2020    Edge-141343 defect fix
7.         Aruna Aware              29/06/2020    DPG-1753    IoT Shared Plan - Order confirmation email for new Order
8.            Prajakta              06/08/2020    EDGE-154675
9.          Neha Trivedi            16/09/2020    DPG-2735    IoT Annual Data Plan - Order confirmation email for new Order
10.         Kamlesh Kumar           8/04/2021     EDGE:205667 - Adding check for updating CoBA Email template
11.         Kamlesh Kumar           27/04/2021    EDGE:205667   Creating html button to redirect https://connectapp.telstra.com/
12. 		Vijayalakshmi 			08/11/2021	  DIGI-29612	Changes to fetch offer_name for IoT
****************************************************************************************************************************
*/
public with sharing class EmailUtils {
    
    //TO DO Need to replace with proper email body get method once we have a body
    public static String emailBodyByTemplateId(String templateId, String recordId, List<String> email ) {
        String htmlBodyFromTemplate = '';
        csord__Order__c orderRequest= new csord__Order__c();
        csord__Subscription__c subOrdRequest=new csord__Subscription__c();
        csord__Service__c service = new csord__Service__c();
        String primaryOrderName='';
        String opptOwnerEmail = '';
        String opptOwnerName = '';
        cscfga__Product_Basket__c basket;
        //changes start for EDGE-103485 to fetch additional attributes from service object for TID
        cscfga__Attribute__c attribute;
        String zone = '';
        String AccessType = '';
        String bandwidth = '';
        String siteName = '';
        String customerFacingServiceId = '';
        //changes end for EDGE-103485 to fetch additional attributes from service object for TID
        
        try{
            //EDGE:205667
            Utility_Settings__c utilSettings = Utility_Settings__c.getInstance();
            //END:EDGE:205667
            if(recordId.startsWith('a4b')){
                
                orderRequest =[Select id,csord__Order_Number__c,csord__Order_Request__c,csordtelcoa__Opportunity__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name, (SELECT Id from csord__Subscriptions__r) from csord__Order__c where id = : recordId LIMIT 1];// //EDGE-53778 change
                primaryOrderName=orderRequest.csord__Order_Number__c;
                service = [SELECT Id,Technical_Contact__r.FirstName,Primary_Contact__r.FirstName,Project_Contact__r.FirstName,Primary_Contact__r.Pref_Comm_Method__c, Primary_Contact__r.Email, Primary_Contact__r.MobilePhone,
                           Project_Contact__c, Project_Contact__r.Pref_Comm_Method__c, Project_Contact__r.Email, Project_Contact__r.MobilePhone,
                           Technical_Contact__c, Technical_Contact__r.Pref_Comm_Method__c, Technical_Contact__r.Email,
                           csord__Order__r.csordtelcoa__Opportunity__r.owner.name, csord__Order__r.csordtelcoa__Opportunity__r.owner.email,
                           csord__Order__r.csordtelcoa__Opportunity__r.owner.MobilePhone,
                           csord__Subscription__r.csordtelcoa__Subscription_Number__c,csord__Subscription__r.Site__r.name,
                           csord__Order__r.csordtelcoa__Opportunity__c FROM csord__Service__c
                           WHERE csord__Order__r.csordtelcoa__Opportunity__c =: orderRequest.csordtelcoa__Opportunity__c LIMIT 1];
                //changes start for EDGE-103485 to fetch additional attributes from service object for TID
                if(templateId.equals('TID_New_Order_Recvd') || templateId.equals('TID_New_Order_Completed') ||
                    templateId.equals('TID_Modify_Order_Recvd') || templateId.equals('TID_Modify_Order_Completed') || templateId.equals('TID_Cancel_Order_Completed'))
                {
                    csord__Service__c serviceTID = new csord__Service__c();
                    serviceTID = [SELECT Id,Technical_Contact__r.FirstName,Primary_Contact__r.FirstName,csordtelcoa__Product_Configuration__c,customer_facing_service_id__c 
                                  FROM csord__Service__c
                                  WHERE csord__Order__r.csordtelcoa__Opportunity__c =: orderRequest.csordtelcoa__Opportunity__c and name like '%Internet Site%'];
                    customerFacingServiceId = serviceTID.customer_facing_service_id__c;
                    List<cscfga__Attribute__c> lstAttrib = [SELECT id, name, cscfga__Value__c from cscfga__Attribute__c where cscfga__Product_Configuration__c = : serviceTID.csordtelcoa__Product_Configuration__c AND Name IN ('Bandwidth Shadow', 'Zone Shadow', 'AccessTechnology')];
                    for(cscfga__Attribute__c attr : lstAttrib){
                        if(attr.Name == 'Bandwidth Shadow')
                            bandwidth = attr.cscfga__Value__c;
                        if(attr.Name == 'Zone Shadow')
                            zone = attr.cscfga__Value__c;
                        if(attr.Name == 'AccessTechnology')
                            AccessType = attr.cscfga__Value__c;
                    }
                }
                //changes end for EDGE-103485
                
                
                basket = [SELECT id FROM cscfga__Product_Basket__c WHERE Primary_Basket__c = true and csbb__Synchronised_With_Opportunity__c = true and cscfga__Opportunity__c = :service.csord__Order__r.csordtelcoa__Opportunity__c];
                
                opptOwnerEmail = service.csord__Order__r.csordtelcoa__Opportunity__r.owner.Email;
                opptOwnerName = service.csord__Order__r.csordtelcoa__Opportunity__r.owner.Name;
            }
            /*
             *EDGE:205667 - Adding check for updating CoBA Email template
            */
            else if(templateId.equals(utilSettings.Template_Name__c)) {
                htmlBodyFromTemplate = updateCoBaMergeField(templateId,recordId);
            }
            else{ 
                subOrdRequest =  [Select id,csord__Order_Request__c, csord__Order__r.csordtelcoa__Opportunity__c from csord__Subscription__c where id = : recordId LIMIT 1];
                service = [SELECT Id,Technical_Contact__r.FirstName,Primary_Contact__r.FirstName,Project_Contact__r.FirstName,Primary_Contact__r.Pref_Comm_Method__c, Primary_Contact__r.Email, Primary_Contact__r.MobilePhone,
                           Project_Contact__c, Project_Contact__r.Pref_Comm_Method__c, Project_Contact__r.Email, Project_Contact__r.MobilePhone,
                           Technical_Contact__c, Technical_Contact__r.Pref_Comm_Method__c, Technical_Contact__r.Email,
                           csord__Order__r.csordtelcoa__Opportunity__r.owner.name, csord__Order__r.csordtelcoa__Opportunity__r.owner.email,
                           csord__Order__r.csordtelcoa__Opportunity__r.owner.MobilePhone,
                           //changes start for EDGE-103485 to fetch additional attributes from service object for TID
                           //csord__Subscription__r.csordtelcoa__Subscription_Number__c,csord__Subscription__r.Site__r.name
                           csord__Subscription__r.csordtelcoa__Subscription_Number__c,csord__Subscription__r.Site__r.name, Zone__c, BandwidthWeight__c,AccessType__c,customer_facing_service_id__c
                           //changes end for EDGE-103485 to fetch additional attributes from service object for TID
                           FROM csord__Service__c WHERE csord__Order__r.csordtelcoa__Opportunity__c =: subOrdRequest.csord__Order__r.csordtelcoa__Opportunity__c LIMIT 1];
                csord__Order__c ords=[SELECT ID,csord__Order_Number__c FROM csord__Order__c WHERE csordtelcoa__Opportunity__c = :subOrdRequest.csord__Order__r.csordtelcoa__Opportunity__c AND csord__Primary_Order__c = NULL LIMIT 1];
                primaryOrderName = ords.csord__Order_Number__c;
                opptOwnerEmail = service.csord__Order__r.csordtelcoa__Opportunity__r.owner.Email;
                opptOwnerName = service.csord__Order__r.csordtelcoa__Opportunity__r.owner.Name;
               
            }
            Map<string,string> mapEmailToContact = new Map<string,string>();
            mapEmailToContact.put(service.Primary_Contact__r.Email,service.Primary_Contact__r.FirstName);
            mapEmailToContact.put(service.Project_Contact__r.Email,service.Project_Contact__r.FirstName);
            mapEmailToContact.put(service.Technical_Contact__r.Email,service.Technical_Contact__r.FirstName);
            mapEmailToContact.put(opptOwnerEmail,opptOwnerName);
           // htmlBodyFromTemplate = htmlBodyFromTemplate.replace('FirstName',mapEmailToContact.get(email[0]));
            /*if(templateId == Label.EmailTemplateId){    
            //String primaryConFirstName = serviceList.Primary_Contact__r.FirstName;
            String siteInstallationAddress = serviceList.csord__Subscription__r.Site__r.name;
            String subsNumber = serviceList.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
            APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id,APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
            htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
            System.debug('congaTemplate::: '+htmlBodyFromTemplate);

            htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[Order Idendtifier Prefix] [Sales Order number] [Version number]',subsNumber);
            htmlBodyFromTemplate = htmlBodyFromTemplate.replace('FirstName',mapEmailToContact.get(email[0]));
if(siteInstallationAddress != null)
htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[Installation Site]',siteInstallationAddress);
else 
htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[Installation Site]','');
}*/
            /*if(templateId == Label.Order_acknowledgement_email ){
String primaryConFirstName = serviceList.Primary_Contact__r.FirstName;
//String siteInstallationAddress = serviceList.csord__Subscription__r.Site__r.name;
//String subsNumber = serviceList.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
List<csord__Subscription__c> subscriptions = [SELECT ID,csord__Order_Request__c,Site__r.name FROM csord__Subscription__c WHERE Name = 'Connected Workplace' and csord__Order__r.csordtelcoa__Opportunity__c  =: orderRequest.csordtelcoa__Opportunity__c];
String siteList = '';
for(csord__Subscription__c subs:subscriptions ){
siteList = siteList+'<li><span style=&quot;font-size: 10px;&quot;><span style=&quot;font-family: arial,helvetica,sans-serif;&quot;>'+subs.Site__r.name+'</span></span></li>';
}
siteList= '<ul>'+siteList+'</ul>';
APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
System.debug('congaTemplate::: '+htmlBodyFromTemplate);

htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[ID]',primaryOrderName);
System.debug('------'+mapEmailToContact);
htmlBodyFromTemplate = htmlBodyFromTemplate.replace('FirstName',mapEmailToContact.get(email[0]));
htmlBodyFromTemplate = htmlBodyFromTemplate.replace('SiteInformation',siteList);
}*/
            //start 53778
            /** EDGE-100899 : Replace place holders in Conga Email Template Body */
            if(templateId.equals(Label.CUSTOMER_ORDER_SINGLE_AND_MULTIPLE_OFFER)){
                List<Id> subscriptionIds = new List<Id>();
                for(csord__Subscription__c subscription : orderRequest.csord__Subscriptions__r){
                    subscriptionIds.add(subscription.Id);
                }
                APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
                htmlBodyFromTemplate = htmlBodyFromTemplate.replaceAll('order_number', primaryOrderName);
                htmlBodyFromTemplate = htmlBodyFromTemplate.replaceAll('order_offer_name', orderRequest.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name);
                htmlBodyFromTemplate = htmlBodyFromTemplate.replaceAll('order_appointments', orderRequest.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name);
                String appointments = '';
                for(Appointment__c appointment : [SELECT Id,Category__c,StartDate__c,StartDateText__c,Subscription__r.Site__r.Installation_Address__c from Appointment__c where Subscription__c IN :subscriptionIds]){
                    appointments = ''+appointment.Category__c+''+ appointment.StartDate__c+''+appointment.Subscription__r.Site__r.Installation_Address__c+'';
                }
                if(String.isNotBlank(appointments)){
                    htmlBodyFromTemplate = htmlBodyFromTemplate.replaceAll('order_appointments', appointments);
                }
                if(String.isNotBlank(orderRequest.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name)){
                    if(''.equals(orderRequest.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name)){
                        htmlBodyFromTemplate = htmlBodyFromTemplate.replaceAll('product_specifications_next_steps', '');
                    }
                    if(''.equals(orderRequest.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Name)){
                        htmlBodyFromTemplate = htmlBodyFromTemplate.replaceAll('product_specifications_next_steps', '');
                    }
                }
            }
            /** END EDGE-100899 : Replace place holders in Conga Email Template Body */
            if(templateId.equals('Order_Completed')){
                APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('Reference Number',primaryOrderName);
                List<csord__Subscription__c> subscriptions = [SELECT ID,csord__Order_Request__c,Site__r.name,Site__r.cscrm__Installation_Address__c,Site__r.cscrm__Installation_Address__r.name FROM csord__Subscription__c WHERE Name LIKE 'IP SITE%' and csord__Order__r.csordtelcoa__Opportunity__c  =: orderRequest.csordtelcoa__Opportunity__c];
                String siteList='';
                for(csord__Subscription__c subs:subscriptions ){
                    siteList = siteList+'<li><span style=&quot;font-size: 10px;&quot;><span style=&quot;font-family: arial,helvetica,sans-serif;&quot;>'+subs.Site__r.name+' '+subs.Site__r.cscrm__Installation_Address__r.name+'</span></span></li>';
                }
                siteList= '<ul>'+siteList+'</ul>';
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('Location names',siteList);
            }
            
            if(templateId.equals('CWP_Order_Received')){
                APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('Order ID',primaryOrderName);
                List<csord__Subscription__c> subscriptions = [SELECT ID,csord__Order_Request__c,Site__r.name,Site__r.cscrm__Installation_Address__c,Site__r.cscrm__Installation_Address__r.name FROM csord__Subscription__c WHERE Name LIKE 'IP SITE%' and csord__Order__r.csordtelcoa__Opportunity__c  =: orderRequest.csordtelcoa__Opportunity__c];
                String siteList='';
                for(csord__Subscription__c subs:subscriptions ){
                    siteList = siteList+'<li><span style=&quot;font-size: 10px;&quot;><span style=&quot;font-family: arial,helvetica,sans-serif;&quot;>'+subs.Site__r.name+' '+subs.Site__r.cscrm__Installation_Address__r.name+'</span></span></li>';
                }
                siteList= '<ul>'+siteList+'</ul>';
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('Site Names',siteList);
            }
            //Manoj Kumar : EDGE-108431
            if(templateId.equals(Label.ngUCSignupCommunicationTemplate) ||
            //EDGE-126306 Changes start for ngUC Modify 
            //Edge-141343
            templateId.equals('ngUC_modify_received') || templateId.equals('ngUC_modify_complete') || templateId.equals('ngUC_Order_Recvd'))
            //EDGE-126306 Changes end for ngUC Modify
            {
                APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[ID]',primaryOrderName);
                if(String.isNotBlank(customerFacingServiceId))
                {
                    htmlBodyFromTemplate = htmlBodyFromTemplate.replace('Telstra Service ID', customerFacingServiceId);
                }
            }
            
            /* if(templateId.equals(Label.MACOrderComplete_Template)){
APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[Reference Number]',primaryOrderName);
}*/
            
            if(templateId.equals('Mobility_Order_Received')){
                APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('Order ID',primaryOrderName);
                
            }
            
            // Added for DPG -668
            // DPG-1753 - IoT Shared Plan - Order confirmation email for new Order 
            //DPG -2735 - IoT Annual Data Plan - Order confirmation email for new Order
            if(templateId.equals('IoT_Order_Received')){
                APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[order ID]',primaryOrderName);
                //DIGI-29612 -- changes to use DMCAT_Offer_001522 in the query  start
				csord__Subscription__c subscription = [SELECT Id,csordtelcoa__Product_Configuration__r.Name FROM csord__Subscription__c WHERE csord__Order__r.csordtelcoa__Opportunity__c  =: orderRequest.csordtelcoa__Opportunity__c and (csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_Offer_001522' OR
				csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c= 'DMCAT_ProductSpecification_000965') LIMIT 1];
				//DIGI-29612 -- changes to use DMCAT_Offer_001522 in the query  end
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[Plan Name]',subscription.csordtelcoa__Product_Configuration__r.Name);
				String offerName='';
				//DIGI-29612 -- changes to populate offer_name start
				//offerName = subscription.MarketableOffer__r.name;
				//System.debug('Offer name is ' +offerName);
				//htmlBodyFromTemplate =htmlBodyFromTemplate.replace('offer_name',offerName);
				//DIGI-29612 -- changes to populate offer_name end
				
				//DIGI-41648 -- Changes for telstraConnectSupportButton start
				//Creating html button to redirect https://connectapp.telstra.com/
				String telstraConnectSupportButton = '<button style="background-color: #008CBA;border: none;color: white;padding: 07px 08px;text-align: center;text-decoration: none;display: inline-block;font-size: 12px;font-family: sans-serif;">Telstra Connect Support</button>';
				htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[Telstra_Connect_Support_Button]',telstraConnectSupportButton);
				//DIGI-41648 -- Changes for telstraConnectSupportButton end
				
                if(subscription.csordtelcoa__Product_Configuration__r.Name.contains('Shared')){
                    htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[Final Text]',System.Label.Order_CNF_Text_for_Shared_data);
                }
                else if(subscription.csordtelcoa__Product_Configuration__r.Name.contains('Right')){
                      htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[Final Text]',System.Label.Order_CNF_Text_for_Right_Plan);                    
                }
                else{
                  htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[Final Text]','');                    
                }
                 
           }
            
           
            if(templateId.equals('CMP_Order_Received')){
                
                APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('order ID',primaryOrderName);
            }
            //changes start for EDGE-103485 to populate additional attributes in the template
            if(templateId.equals('TID_New_Order_Recvd') || templateId.equals('TID_New_Order_Completed') ||
            templateId.equals('TID_Modify_Order_Recvd') || templateId.equals('TID_Modify_Order_Completed') || templateId.equals('TID_Cancel_Order_Completed'))
            
            {
                
                APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                String planType = '';
                htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
                if(String.isNotBlank(primaryOrderName))
                {
                    htmlBodyFromTemplate = htmlBodyFromTemplate.replace('order id',primaryOrderName);
                }
                if(String.isNotBlank(customerFacingServiceId))
                {
                    htmlBodyFromTemplate = htmlBodyFromTemplate.replace('Telstra Service ID', customerFacingServiceId);
                }
                if(String.isNotBlank(zone))
                {
                    htmlBodyFromTemplate = htmlBodyFromTemplate.replace('Zone',zone);
                }
                if(String.isNotBlank(AccessType))
                {
                    htmlBodyFromTemplate = htmlBodyFromTemplate.replace('TID type',AccessType);
                }
                planType = 'Telstra Internet Direct - ' + 'Zone '+zone + ' - ' + bandwidth;
                if(String.isNotBlank(planType))
                {
                    htmlBodyFromTemplate = htmlBodyFromTemplate.replace('Plan type',planType);
                }
                List<csord__Subscription__c> subscriptions = [SELECT ID,csord__Order_Request__c,Site__r.name,Site__r.cscrm__Installation_Address__c,Site__r.cscrm__Installation_Address__r.name FROM csord__Subscription__c WHERE Name LIKE '%Internet Site%' and csord__Order__r.csordtelcoa__Opportunity__c  =: orderRequest.csordtelcoa__Opportunity__c];
                String siteList='';
                for(csord__Subscription__c subs:subscriptions ){
                    siteList = siteList+'<li><span style=&quot;font-size: 10px;&quot;><span style=&quot;font-family: arial,helvetica,sans-serif;&quot;>'+subs.Site__r.name+' '+subs.Site__r.cscrm__Installation_Address__r.name+'</span></span></li>';
                }
                siteList= '<ul>'+siteList+'</ul>';
                if(String.isNotBlank(siteList))
                {
                    htmlBodyFromTemplate = htmlBodyFromTemplate.replace('Location',siteList);
                    
                }
            }
            
            //changes end for 103485 
            
            if(templateId.equals('Mobility_Future_Date_Cancellation')){
                APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
                csord__Subscription__c subscription = [SELECT Id,Cancellation_Date_of_Effect__c,ContractJunction__c,csord__Order_Request__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Subscription__c WHERE csord__Order__r.csordtelcoa__Opportunity__c  =: orderRequest.csordtelcoa__Opportunity__c and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c='DMCAT_ProductSpecification_000420'LIMIT 1];
                if(basket!=null){
                    List<String> emails=OrderEmailService.getContractSignatories(basket.Id);
                    if(emails.size()>1){
                        Contact firstNameSignatory=[select id,firstName from Contact where Email=:emails[1]];
                        htmlBodyFromTemplate.replace('first_name_agreement_signatory',firstNameSignatory.firstName);    
                    }
                    
                }
                List<csord__Service__c> services=[select Id,name,serviceMSISDN__c from csord__Service__c where csord__Subscription__c=:subscription.Id and csord__Service__c=null];
                htmlBodyFromTemplate.replace('number_of_services_to_be_ cancelled',String.valueOf(services.size()));
                htmlBodyFromTemplate.replace('cancellation_date',String.valueOf(subscription.Cancellation_Date_of_Effect__c));
                String numberList='';
                for(csord__Service__c subs:services){
                    numberList = numberList+'<li><span style=&quot;font-size: 10px;&quot;><span style=&quot;font-family: arial,helvetica,sans-serif;&quot;>'+subs.serviceMSISDN__c+'</span></span></li>';
                }
                numberList= '<ul>'+numberList+'</ul>';
                htmlBodyFromTemplate.replace('mobile_number e.g. 04…',numberList);
                
                
                
            }
            
            /*if(templateId.equals(Label.MobilityOrderCancellation_Template)){

}*/
            
            if(templateId.equals('CWP_Individual_Location_Complete_Ready_To_Bill')){
                APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
                List<csord__Subscription__c> subscriptions = [SELECT ID,csord__Order_Request__c,Site__r.name,Site__r.cscrm__Installation_Address__c,Site__r.cscrm__Installation_Address__r.name FROM csord__Subscription__c WHERE Name LIKE 'IP SITE%' and emailSent__c=false];
                String siteList='';
                for(csord__Subscription__c subs:subscriptions ){
                    siteList = siteList+'<li><span style=&quot;font-size: 10px;&quot;><span style=&quot;font-family: arial,helvetica,sans-serif;&quot;>'+subs.Site__r.name+' '+subs.Site__r.cscrm__Installation_Address__r.name+'</span></span></li>';
                }
                siteList= '<ul>'+siteList+'</ul>';
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('Site Names',siteList);
            }
            //end 53778
            
            /** Start EDGE-98409 : CMP Offer Cancellation : Replace place holders in Conga Email Template Body */
            if(templateId.equals(Label.OfferCancellation_Id)){
                APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
                csord__Subscription__c subscription = [SELECT Id,ContractJunction__c,csordtelcoa__Product_Configuration__c,csord__Order__r.csordtelcoa__Opportunity__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Subscription__c WHERE id = : recordId LIMIT 1];
                Contact orderRequestor = [SELECT FirstName FROM CONTACT WHERE ID IN (SELECT CONTACTID FROM OPPORTUNITYCONTACTROLE WHERE OPPORTUNITYID = :subscription.csord__Order__r.csordtelcoa__Opportunity__c AND ISPRIMARY = true AND ROLE = 'Decision Maker')];
                List<csord__Service__c> services = new List<csord__Service__c>();
                services=[select Id,name,serviceMSISDN__c from csord__Service__c where csord__Subscription__c=:subscription.Id and csord__Service__c=null];
                String numberList='';
                String offerList='';
                for(csord__Service__c subs:services){
                    numberList = numberList+'<li><span style=&quot;font-size: 10px;&quot;><span style=&quot;font-family: arial,helvetica,sans-serif;&quot;>'+subs.serviceMSISDN__c+'</span></span></li>';
                    offerList = offerList+'<li><span style=&quot;font-size: 10px;&quot;><span style=&quot;font-family: arial,helvetica,sans-serif;&quot;>'+subs.name+'</span></span></li>';
                }
                numberList= '<ul>'+numberList+'</ul>';
                offerList= '<ul>'+offerList+'</ul>';
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[OffCancel SubscriptionList]',numberList);
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[OffCancel OfferName]',offerList);
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[OffCancel SignatoryName]',orderRequestor.FirstName);
            }
            //End EDGE-98409
            //changes start for EDGE-126307 to handle ngUC Cancel
            //changes start for EDGE-103485 to handle TID_Cancel_Order_Completed
            if(templateId.equals('TID_Cancel_Order_Completed') || templateId.equals('ngUC_cancelOrder_complete')){
            //changes end for EDGE-103485
            //changes end for EDGE-126307 to handle ngUC Cancel
                APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
                csord__Subscription__c subscription = [SELECT Id,ContractJunction__c,csordtelcoa__Product_Configuration__c,csord__Order__r.csordtelcoa__Opportunity__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Subscription__c WHERE id = : recordId LIMIT 1];
                Contact orderRequestor = [SELECT FirstName FROM CONTACT WHERE ID IN (SELECT CONTACTID FROM OPPORTUNITYCONTACTROLE WHERE OPPORTUNITYID = :subscription.csord__Order__r.csordtelcoa__Opportunity__c AND ISPRIMARY = true AND ROLE = 'Decision Maker')];
                List<csord__Service__c> services=[select Id,name,serviceMSISDN__c from csord__Service__c where csord__Subscription__c=:subscription.Id and csord__Service__c=null];
                String numberList='';
                String offerList='';
                for(csord__Service__c subs:services){
                    numberList = numberList+'<li><span style=&quot;font-size: 10px;&quot;><span style=&quot;font-family: arial,helvetica,sans-serif;&quot;>'+subs.serviceMSISDN__c+'</span></span></li>';
                    offerList = offerList+'<li><span style=&quot;font-size: 10px;&quot;><span style=&quot;font-family: arial,helvetica,sans-serif;&quot;>'+subs.name+'</span></span></li>';
                }
                numberList= '<ul>'+numberList+'</ul>';
                htmlBodyFromTemplate.replace('OffCancel SubscriptionList',numberList);
                offerList= '<ul>'+offerList+'</ul>';
                htmlBodyFromTemplate.replace('OffCancel OfferName',offerList);
                htmlBodyFromTemplate.replace('OffCancel SignatoryName',orderRequestor.FirstName);
            }
            
            // EDGE-154675 start 
            if(templateId.equals('EnterprizeMobility(NGEM)_Order_Received')){
                
                String offerName='';
                Boolean shippingtrue = false;
                APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('order_ID',primaryOrderName);
                
                List<csord__Subscription__c> solsubscription = [SELECT ID,csord__Order_Request__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c, MarketableOffer__c,MarketableOffer__r.Offer_ID__c,MarketableOffer__r.Name FROM csord__Subscription__c WHERE  csord__Order__r.csordtelcoa__Opportunity__c  =: orderRequest.csordtelcoa__Opportunity__c AND csordtelcoa__Product_Configuration__r.ConfigurationType1__c = 'SolutionComponent'];
                
                for(csord__Subscription__c sub : solsubscription){
                    if(sub.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_001233'){
                        offerName = sub.MarketableOffer__r.name;
                    }
                }
                
                List<csord__Service__c>serviceList = [SELECT Id,Primary_Contact__r.Email,
                           csord__Order__r.csordtelcoa__Opportunity__c,ShippingRequired__c FROM csord__Service__c
                           WHERE csord__Order__r.csordtelcoa__Opportunity__c =: orderRequest.csordtelcoa__Opportunity__c];
                           
                           for(csord__Service__c serv :serviceList){
                               
                                if(serv.ShippingRequired__c != null && serv.ShippingRequired__c =='TRUE'){
                                        shippingtrue = true;
                                        break;
                                }        
                                              
                           }
                           
                           if(shippingtrue == true){
                              htmlBodyFromTemplate = htmlBodyFromTemplate.replace('deviceDelivery_section','<li><span style=&quot;font-size: 10px;&quot;><span style=&quot;font-family: arial,helvetica,sans-serif;&quot;>'+'Delivering your items' +'<br />'+ 'We’ll send you an email confirming when the items have been dispatched and to which address, plus your tracking reference, warranty information and details of what’s in the box.'+'</span></span></li>');  
                           }
                           else {
                                       htmlBodyFromTemplate =htmlBodyFromTemplate.replace('deviceDelivery_section','');}
                                        
                                       htmlBodyFromTemplate =htmlBodyFromTemplate.replace('offer_name',offerName);
                                   
                
            }
            // EDGE-154675 end
            
            

/* if(templateId == Label.Add_Change_CWP_Services_Template){
String primaryConFirstName = serviceList.Primary_Contact__r.FirstName;
//List<csord__Service_Line_Item__c> slItems = [SELECT ID,csord__Service__r.csord__Order__r.Name,csord__Service__r.Name,csord__Service__r.csord__Subscription__r.Site__r.name,csord__Order_Request__c,Quantity__c FROM csord__Service_Line_Item__c WHERE csord__Service__r.csord__Status__c = 'Pending' and csord__Order_Request__c  =: orderRequest.csord__Order_Request__c];
//List<csord__Service__c> listOfServices = [SELECT ID,csordtelcoa__Parent_Product_Configuration__c from csord__Service__c where csord__Order_Request__c = : orderRequest.csord__Order_Request__c ];
//List<Id> prodConfigIds= List<Id>();
String allServiceItemsModified = '<tbody>';

for(csord__Service__c attrService:[Select ID,csord__Subscription__r.Site__r.name, Name, csordtelcoa__Product_Configuration__c from csord__Service__c where csord__Order__r.csordtelcoa__Opportunity__c = : orderRequest.csordtelcoa__Opportunity__c ]){
//prodConfigIds.add(attrService.csordtelcoa__Parent_Product_Configuration__c);
System.debug('attrService'+orderRequest.csordtelcoa__Opportunity__c);
for(cscfga__Attribute__c item:[Select id,Quantity__c from cscfga__Attribute__c where cscfga__Product_Configuration__c = :attrService.csordtelcoa__Product_Configuration__c and Name = 'Quantity'] ){
System.debug('itemServ'+item.Quantity__c);
allServiceItemsModified = allServiceItemsModified+'<tr><td colspan="1">'+attrService.Name+'&nbsp;</td><td colspan="1">'+item.Quantity__c+'&nbsp;</td><td colspan="1">'+attrService.csord__Subscription__r.Site__r.name+'&nbsp;</td><td colspan="1">Modify&nbsp;</td><td colspan="1">Modify&nbsp;</td></tr>';
}
}

allServiceItemsModified = allServiceItemsModified + '</tbody>';
System.debug('Tabular List: '+allServiceItemsModified);
APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
System.debug('congaTemplate::: '+htmlBodyFromTemplate);

htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[Sales Order number]',primaryOrderName);
System.debug('------'+mapEmailToContact);
htmlBodyFromTemplate = htmlBodyFromTemplate.replace('FirstName',mapEmailToContact.get(email[0]));
htmlBodyFromTemplate = htmlBodyFromTemplate.replace('<tbody></tbody>',allServiceItemsModified);
}
if(templateId == Label.Modify_Order_Completion_Template){
String primaryConFirstName = serviceList.Primary_Contact__r.FirstName;

APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id,APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
System.debug('congaTemplate::: '+htmlBodyFromTemplate);

htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[Sales Order number]',primaryOrderName);
System.debug('------'+mapEmailToContact);
htmlBodyFromTemplate = htmlBodyFromTemplate.replace('FirstName',mapEmailToContact.get(email[0]));
// htmlBodyFromTemplate = htmlBodyFromTemplate.replace('<tbody></tbody>',allServiceItemsModified);
}
*/        
            System.debug('congaTemplate after changes::: '+htmlBodyFromTemplate);
        }
        catch(Exception e){
            Logger2 logger=Logger2.getLogger(EmailUtils.class);
            logger.logMessages(null,null,e.getStackTraceString(),'Technical','Exception',e.getMessage(), false, false);
            logger.exitLogger();
        }
        
        return htmlBodyFromTemplate;
    }
    
    /*
* @Author : Rahul/Ritika
* @Date : 2nd Nov 2018
* @Desc : Method to construct email-body from email-template
* @Jira Cloud : EDGE-49450
*/
    public static String cisEmailBodyByTemplateId(String templateId, String recordId, List<String> email ) {
        //EDGE-87289 - Query Update
        ContractJunction__c CJ = [SELECT Related_Opportunity__r.Partner_Account_Name__c,Related_Opportunity__r.Opportunity_Source__c,Customer_Primary_Contact__r.FirstName,Customer_Primary_Contact__r.LastName,Customer_Primary_Contact__r.Email,Related_Opportunity__r.Owner.Name,Related_Opportunity__r.Owner.Title,Related_Opportunity__r.Owner.Phone,Related_Opportunity__r.Owner.Email,Related_Opportunity__r.Owner.MobilePhone FROM ContractJunction__c WHERE id = :recordId LIMIT 1];
        APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id,APXTConga4__Name__c, APXTConga4__HTMLBody__c FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = :templateId LIMIT 1];
        String htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
        
        //start EDGE-78509 - Replace Name by Firstname
        if(CJ.Customer_Primary_Contact__r.FirstName !=null)
            htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[CID]',CJ.Customer_Primary_Contact__r.FirstName);
        //EDGE-87289 - Start
        else
            htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[CID]',CJ.Customer_Primary_Contact__r.LastName);
        //EDGE-87289 - End
        //end EDGE-78509 - Replace Name by Firstname    
        if(CJ.Related_Opportunity__r.Owner.Name != null)
            htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[OpportunityOwnerName]',CJ.Related_Opportunity__r.Owner.Name+'<br />');
        else
            htmlBodyFromTemplate = htmlBodyFromTemplate.remove('[OpportunityOwnerName]');
        if(CJ.Related_Opportunity__r.Owner.Title !=null)
            htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[OpportunityOwnerTitle]',CJ.Related_Opportunity__r.Owner.Title+'<br />');
        else
            htmlBodyFromTemplate = htmlBodyFromTemplate.remove('[OpportunityOwnerTitle]');        
        //start EDGE-78509 - added detail for opportunity-source
        if(String.isBlank(CJ.Related_Opportunity__r.Opportunity_Source__c))
            htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[TelstraSalesDivision_PartnerBusinessName]','Telstra Sales Division'+'<br />');
        else if((CJ.Related_Opportunity__r.Opportunity_Source__c).equalsIgnoreCase('Partner'))
            htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[TelstraSalesDivision_PartnerBusinessName]',CJ.Related_Opportunity__r.Partner_Account_Name__c +'<br />');
        else
            htmlBodyFromTemplate = htmlBodyFromTemplate.remove('[TelstraSalesDivision_PartnerBusinessName]');
        //end EDGE-78509   
        if(CJ.Related_Opportunity__r.Owner.Phone !=null)
            htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[OpportunityOwnerPhone]',CJ.Related_Opportunity__r.Owner.Phone+'<br />');
        else
            htmlBodyFromTemplate = htmlBodyFromTemplate.remove('[OpportunityOwnerPhone]');
        if(CJ.Related_Opportunity__r.Owner.Email !=null)
            htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[OpportunityOwnerEmail]',CJ.Related_Opportunity__r.Owner.Email+'<br />');
        else
            htmlBodyFromTemplate = htmlBodyFromTemplate.remove('[OpportunityOwnerEmail]');
        System.debug('***Telstra:EmailUtils:cisEmailBodyByTemplateId:Final emailBody:'+htmlBodyFromTemplate);
        return htmlBodyFromTemplate;
    }
   
    /*
* @Author : Kamlesh
* @Date : 9th April 2021
* @Desc : Method to replaced merge field with dynamic value in CoBA email-template
* @Jira Cloud : EDGE:205667
*/
    public static String updateCoBaMergeField(String templateId,String recordId) {
            String regionBasedSection = '';
            String htmlBodyFromTemplate;
            List<Subscriptions_to_Case_Association__c> subscriptionToCaseList = new List<Subscriptions_to_Case_Association__c>();

            subscriptionToCaseList = [SELECT Id,Case__c,Case__r.Account.Name,Case__r.CreatedDate,Case__r.Contact.Name,Case__r.Reason,Case__r.Billing_Account__r.Billing_Account_Number__c,Case__r.ClosedDate,csord_Subscription__c,csord_Subscription__r.Name,csord_Subscription__r.csordtelcoa__Subscription_Number__c from Subscriptions_to_Case_Association__c where Case__c =:recordId];
            APXTConga4__Conga_Email_Template__c congaTemplate = [SELECT id, APXTConga4__Name__c, APXTConga4__HTMLBody__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Name__c = :templateId LIMIT 1];
                
            htmlBodyFromTemplate = congaTemplate.APXTConga4__HTMLBody__c;
            //Creating html button to redirect https://connectapp.telstra.com/
            String telstraConnectSupportButton = '<button style="background-color: #008CBA;border: none;color: white;padding: 07px 08px;text-align: center;text-decoration: none;display: inline-block;font-size: 12px;font-family: sans-serif;">Telstra Connect Support</button>';
            htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[Telstra_Connect_Support_Button]',telstraConnectSupportButton);
            if(String.isNotBlank(subscriptionToCaseList[0].Case__r.Billing_Account__r.Billing_Account_Number__c)) {
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[CoBA_Billing_Account]',subscriptionToCaseList[0].Case__r.Billing_Account__r.Billing_Account_Number__c);
            }
            
            if(String.isNotBlank(String.valueOf(subscriptionToCaseList[0].Case__r.ClosedDate))) {
                htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[CoBA_Account_Transfer_Completion_Date]',String.valueOf(subscriptionToCaseList[0].Case__r.ClosedDate.date()).substring(0, 10));
            }
            
            if(subscriptionToCaseList.size()>0) {
               //Creating Dynamic Table
              String tableBody = '';
              tableBody = '<table border="1" style="width:55%;border-collapse: collapse"><tr><th style="font-size: 10px; font-family: sans-serif;">Subscription Name</th><th style="font-size: 10px; font-family: sans-serif;">Subscription Number</th></tr>';
                
              for(Subscriptions_to_Case_Association__c sc : subscriptionToCaseList) {
                    String name = sc.csord_Subscription__r.Name;
                    String scNumber = sc.csord_Subscription__r.csordtelcoa__Subscription_Number__c;
                    tableBody += '<tr><td style="text-align:center;font-size: 10px; font-family: sans-serif;">' + name + '</td><td style="text-align:center;font-size: 10px; font-family: sans-serif;">' + scNumber + '</td></tr>';
              }

              tableBody += '</table>';

             if(subscriptionToCaseList[0].Case__r.Reason == 'Requested by Customer' || subscriptionToCaseList[0].Case__r.Reason == 'Customer error (incorrect BAN selected)') {
                   regionBasedSection = 'Regarding request '+subscriptionToCaseList[0].Case__c+' '+'submitted by '+subscriptionToCaseList[0].Case__r.Contact.Name+' on '+String.valueOf(subscriptionToCaseList[0].Case__r.CreatedDate.date()).substring(0, 10)+' the following products and/or services have now been transferred to billing account '+subscriptionToCaseList[0].Case__r.Billing_Account__r.Billing_Account_Number__c+' for '+subscriptionToCaseList[0].Case__r.Account.Name;
                   regionBasedSection = regionBasedSection+'<br>'+'<br>'+tableBody;
             }
             else if(subscriptionToCaseList[0].Case__r.Reason == 'Telstra error (incorrect BAN selected)') {
                   regionBasedSection = 'Regarding case '+subscriptionToCaseList[0].Case__c+',as discussed the following products and/or services have now been transferred to billing account '+subscriptionToCaseList[0].Case__r.Billing_Account__r.Billing_Account_Number__c+' for '+subscriptionToCaseList[0].Case__r.Account.Name;
                   regionBasedSection = regionBasedSection+'<br>'+'<br>'+tableBody;
             }
            }
            
            htmlBodyFromTemplate = htmlBodyFromTemplate.replace('[Reginon_Based_Initiated_Section]',regionBasedSection);
            return htmlBodyFromTemplate;
    }
    

}