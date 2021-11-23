/**
* Developer: Kunal Dixit,Vanita Mude
* Description: Service class to handle Email generating for various order states.
* Jira US: EDGE-53778
Class Name : OrderEmailService
Test Class : OrderEmailServiceTest
****************************************************************************************************************************
Change.No.    Developer Name          Date          Story Description
1.            Vijayalakshmi         11/12/2019    EDGE-127861 Changes to handle cancel scenarios for TID
2.            Manish Kumar          1/1/2020      EDGE-130266 Bug fix for ngUC cancel
3.            Dheeraj Bhatt         27/03/2020    EDGE-139046 Move Order Received email from Conga to Notify
4.            Jayesh                21/04/2020    DPG-1415 Confirmation of canceled services
5.            Prajakta              19/10/2020   EDGE-184023
6.            Prajakta              20/11/2020   EDGE-184247
7. 			  Purushottam			02/02/2020    EDGE-171620
****************************************************************************************************************************
//Defect fix EDGE-117267 - Aniket Srivastava - 25/11/2019
*/
public with sharing class OrderEmailService{
    @InvocableMethod
    public static void processOrderRecord(List<Id> OrderId){
        boolean isMacdAdd =  false; //EDGE-184023

        System.debug('Inside Process Builder');
        List<csord__Order__c> orderList =[Select id,Project_Manager_Email__c,Billing_Account__c,csordtelcoa__Opportunity__c,name, csord__Status2__c,csord__Order_Request__c,csord__Order_Number__c,Billing_Account__r.Billing_Account_Owner__r.Email,csordtelcoa__Opportunity__r.Owner.Email,csord__Account__r.CIDN__c,csord__Account__r.Account_UUID__c,Fulfilment_Order_Version__c from csord__Order__c where id in : OrderId];
        System.debug('orderList::::::'+orderList);
        Map<Id,ContractJunction__c> contractJunctionMap = OrderEmailServiceHelper.getContractJunctionByOpportunity(orderList);
        Map<String,String> metadataToTemplateMap=new Map<String,String>();
        for(Customer_Notify_Metadata__c custMetadata:[select Id,monitorObjectStatus__c,orderType__c,productDefinitionCode__c,emailTemplate__c from Customer_Notify_Metadata__c where (scenarioType__c='' or scenarioType__c=null) and monitorObject__c='Order']){
            String productDefinitionCode=custMetadata.productDefinitionCode__c;
            if(productDefinitionCode.contains(',')) productDefinitionCode=productDefinitionCode.substringBefore(',');
            String key=custMetadata.orderType__c+':'+custMetadata.monitorObjectStatus__c+':'+productDefinitionCode;
            //New:In Progress:DMCAT_ProductOffering_000304,DMCAT_ProductSpecification_000420
            System.debug('key-->'+key);
            System.debug('custMetadata-->'+custMetadata);
            if(metadataToTemplateMap.get(key)==null) metadataToTemplateMap.put(key,custMetadata.emailTemplate__c);
        }
        Map<String,List<csord__Subscription__c>> subscriptionsMap=new Map<String,List<csord__Subscription__c>>();
        //EDGE-117267 - Added ConfigSpecID__c in query
        for(csord__Subscription__c subscription:[Select Id, Name,ConfigSpecID__c,site__c,csord__Order__r.Name, csord__Order__c,csordtelcoa__Product_Configuration__r.Type__c,csordtelcoa__Replaced_Subscription__c,csord__Order_Request__c, offer__r.Offer_Spec_Id__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c, csord__Order__r.csord__Status2__c,Cancellation_Date_of_Effect__c,MarketableOffer__r.Offer_ID__c,
                                                 contractJunction__r.Email__c,ContractJunction__r.Name,Billing_Account__r.Name,PartnerAccount__r.name,PartnerAccount__r.Email__c,PartnerAccount__r.phone from csord__Subscription__c where csord__Order__c in :orderList]){
            if(subscriptionsMap.keySet().contains(subscription.csord__Order__c )){
                subscriptionsMap.get(subscription.csord__Order__c ).add(subscription);
            } else {
                subscriptionsMap.put(subscription.csord__Order__c ,new List<csord__Subscription__c>{subscription});
            }
            system.debug('subscription12:-->' + subscription);
        }
       EmailDTO emailDTO;
       //changes start for EDGE-130266
       List<EmailDTO> emailDTOList = new List<EmailDTO>();
       //changes start for EDGE-130266
        system.debug('subscriptionsMap:-->'+subscriptionsMap);
        NotifyEmail__mdt amendMDT = [Select Event_Type__c,entityId__c,entityType__c,keyValues__c,Support_Hours__c from NotifyEmail__mdt where Event_Type__c='B2B_ADC_ORD_AMENDED' limit 1]; //EDGE-171620
        for(csord__Order__c ord:orderList){
            system.debug('ord:-->'+ord);
            //EDGE-171620 Start
            if(ord.Fulfilment_Order_Version__c > 1.0){
                system.debug('Inside :generateAmendEmailDTO '+ ord.Fulfilment_Order_Version__c);
                emailDTO =OrderEmailServiceHelper.generateAmendEmailDTO(ord,subscriptionsMap.get(ord.Id),amendMDT);
                emailDTOList.add(emailDTO);
            }
            //EDGE-171620 End
            for(csord__Subscription__c sub:subscriptionsMap.get(ord.Id)){
                if(sub.csordtelcoa__Product_Configuration__r.Type__c =='New'){ //EDGE-184023
                    isMacdAdd = true;
                    system.debug('isMacdAdd:'+isMacdAdd);
                }

                system.debug('subscription:-->'+sub);
                String toCompare = '';
                system.debug('sub.MarketableOffer__r.Offer_ID__c :::' + sub.MarketableOffer__r.Offer_ID__c);
                if(sub.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000646'){
                    toCompare = 'New:In Progress:DMCAT_ProductSpecification_000420_CMP';
                }
                //EDGE-117267 Added below else if condition
                else if(sub.csordtelcoa__Product_Configuration__r.Type__c == 'New' && (sub.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000675' || sub.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000618')){
                    toCompare = 'New:In Progress:DMCAT_Offer_000618';
                    system.debug('Inside New:In Progress:DMCAT_Offer_000618');
                }
                // EDGE-127861 Changes start for cancel scenarios for TID
                else if(sub.csordtelcoa__Product_Configuration__r.Type__c == 'Cancel' && sub.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000618'){
                    toCompare = 'Cancel:'+ord.csord__Status2__c+':DMCAT_Offer_000618';
                    system.debug('Inside Cancel:Complete:DMCAT_Offer_000618');
                }
                // EDGE-127861 Changes end for cancel scenarios for TID
                 //Added for DPG-668 : IoT Offer changes
                //DPG-1415 Added condition to check if Type=New
                else if(sub.csordtelcoa__Product_Configuration__r.Type__c == 'New' && sub.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000964'){ 
                    toCompare = 'New:In Progress:DMCAT_ProductSpecification_000965';
                    system.debug('Inside New:In Progress:DMCAT_Offer_000964');
                } //End of DPG-668
                //#################### DPG-1415 START - Jayesh ####################
                /*else if(sub.csordtelcoa__Product_Configuration__r.Type__c == 'Cancel' && sub.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000964'){ 
                    toCompare = 'Cancel:Completed:DMCAT_ProductSpecification_000965';
                    system.debug('Inside --> New:Completed:DMCAT_ProductSpecification_000965 --> toCompare--> ' + toCompare);
                } */
                //#################### DPG-1415 END - Jayesh ####################
                else{
                     toCompare=sub.csordtelcoa__Product_Configuration__r.Type__c+':'+ord.csord__Status2__c+':'+sub.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
                     system.debug('Inside else toCompare' +toCompare);
                }
                System.debug('metadataToTemplateMap-->'+metadataToTemplateMap);
                System.debug('vij:toCompare-->'+toCompare);
                //New:In Progress:DMCAT_ProductSpecification_000420
                String template = metadataToTemplateMap.get(toCompare);
                System.debug('*****Template ID-->::: ' + template);
                if(sub.csordtelcoa__Product_Configuration__r.Type__c != null){
                    System.debug('sub.csordtelcoa__Product_Configuration__r.Type__c-->'+ sub.csordtelcoa__Product_Configuration__r.Type__c);
                    if(sub.csordtelcoa__Product_Configuration__r.Type__c.equals('Cancel') && toCompare != 'Cancel:Completed:DMCAT_ProductSpecification_000965'){
                        if(sub.Cancellation_Date_of_Effect__c > System.today()){
                            System.debug('sub.Cancellation_Date_of_Effect__c -->'+ sub.Cancellation_Date_of_Effect__c);
                             emailDTO=OrderEmailServiceHelper.generateEmailDTO(template,ord,sub);
                             //changes start for EDGE-130266
                              emailDTOList.add(emailDTO);
                              //changes end for EDGE-130266
                              break;
                             // new EmailService().send(emailDTO);
                        }
                    } 
                    //EDGE-117267 - Added below else if condition
                    else if(toCompare == 'New:In Progress:DMCAT_Offer_000618'){
                        system.debug('Inside ngUC spec');
                        if(sub.ConfigSpecID__c == 'DMCAT_Offer_000618'){
                            system.debug('Inside ngUC spec : DMCAT_Offer_000618');
                             /*EDGE-139046-27-Mar-2020-Dheeraj Bhatt-<Appointment Notification> Move Order Received email from Conga to Notify */
                          //  emailDTO=OrderEmailServiceHelper.generateEmailDTO(template,ord,sub);
                            emailDTO =OrderEmailServiceHelper.orderReceivedNgUC(ord,null,'DMCAT_Offer_000618',sub,template);
                            /*End- EDGE-139046*/
                          system.debug('Inside ngUC spec :EmailDTO:'+emailDTO);
                          //changes start for EDGE-130266
                            emailDTOList.add(emailDTO);
                            //changes end for EDGE-130266
                            break;
                        }
                    }
                    // Added part of EDGE-100920 for Telstra collaboration Professional Services
                    else if(toCompare == 'New:In Progress:DMCAT_Offer_000936'){                 
                        system.debug('NGUC Order Inprogress  EMail');
                        list<string> emails= new list<string>();                
                        ContractJunction__c contractJunction = contractJunctionMap.get(ord.csordtelcoa__Opportunity__c);
                        if(contractJunction!=null){
                            for(dsfs__DocuSign_Recipient_Status__c docuSignRecipients : contractJunction.DocuSign_Recipient_Status__r){
                                        emails.add(docuSignRecipients.dsfs__DocuSign_Recipient_Email__c);
                            }
                        }
                         /*EDGE-139046-27-Mar-2020-Dheeraj Bhatt-<Appointment Notification> Move Order Received email from Conga to Notify
                          *Added new parameter in orderReceivedNgUC method to make method generic.     
                          */
                        emailDTO =OrderEmailServiceHelper.orderReceivedNgUC(ord,emails,'DMCAT_Offer_000936',sub,null);
                        emailDTOList.add(emailDTO);
                    }
                    //#################### DPG-1415 START - Jayesh ####################
                    /*else if(toCompare == 'Cancel:Completed:DMCAT_ProductSpecification_000965'){
                        system.debug('*****Inside IoT sub.ConfigSpecID__c ' + sub.ConfigSpecID__c);
                        if(sub.ConfigSpecID__c == 'DMCAT_Offer_000964'){
                            system.debug('*****Inside IoT : DMCAT_Offer_000964');
                            emailDTO=OrderEmailServiceHelper.generateEmailDTO(template,ord,sub);
                            system.debug('*****Inside IoT spec :EmailDTO:'+emailDTO);
                        emailDTOList.add(emailDTO);
                            break;
                        }
                    }*/
                    //#################### DPG-1415 END - Jayesh ####################
                    else if(toCompare == 'New:In Progress:DMCAT_ProductSpecification_001196'){ //EDGE-184023 
                        system.debug('Inside Adaptive mobility');
                        if(isMacdAdd ==  true){
                         emailDTO=OrderEmailServiceHelper.generateEmailDTO(template,ord,sub);
                        System.debug('Adaptive mobility Email:::::'+emailDTO);
                        if(emailDTO.templateId != null && !emailDTO.toEmails.isEmpty()){
                            //changes start for EDGE-130266
                            emailDTOList.add(emailDTO);
                            //changes end for EDGE-130266
                            
                        }
                       break;}
                    }            
                     else if(toCompare == 'New:In Progress:DMCAT_ProductSpecification_000420'){ //EDGE-184247
                        system.debug('Inside CMP MACD');
                        if(isMacdAdd ==  true){
                         emailDTO=OrderEmailServiceHelper.generateEmailDTO(template,ord,sub);
                        System.debug('CMP MACD Email:::::'+emailDTO);
                        if(emailDTO.templateId != null && !emailDTO.toEmails.isEmpty()){
                            emailDTOList.add(emailDTO);
                            
                        }
                       break;}
                    }   
                            
                else {
                        emailDTO=OrderEmailServiceHelper.generateEmailDTO(template,ord,sub);
                        System.debug('Email:::::'+emailDTO);
                        if(emailDTO.templateId != null && !emailDTO.toEmails.isEmpty()){
                            //changes start for EDGE-130266
                            emailDTOList.add(emailDTO);
                            //changes end for EDGE-130266
                            break;
                        }
                     
                    }
                }               
            }         

        }
         System.debug('emailDTO-->'+emailDTO);
         //changes start for EDGE-130266
         for(EmailDTO emails: emailDTOList){
             new EmailService().send(emails);
         }
         //changes end for EDGE-130266
         System.debug('dml last:'+system.Limits.getQueries());
    }
    public static String getSubject(String templateName)
    {
        String emailSubject = '';
        try{
            String queryEmailTemplate ='SELECT '+String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('APXTConga4__Conga_Email_Template__c'))+' FROM APXTConga4__Conga_Email_Template__c WHERE APXTConga4__Name__c = :templateName' ;
            List<APXTConga4__Conga_Email_Template__c> templateConfig = Database.query(queryEmailTemplate);
            if(templateConfig !=null) {
                for(APXTConga4__Conga_Email_Template__c qt : templateConfig){
                    emailSubject = qt.APXTConga4__Subject__c;
                }
            }
        }catch(Exception e){
                System.debug('Exception in getSubject :: '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());
            throw e;
        }
        return emailSubject;
    }
    public static List<String> getContractSignatories(String basketId)
    {
        List<String> listEmailSignatories = new List<String>();
        System.debug('basketId in getContractSignatories:'+basketId);
        cscfga__Product_Basket__c productBasket = ProductUtil.getBasket(basketId);
       // String oppOwnerId  productBasket.cscfga__Opportunity__r.OwnerId;
       // System.debug('oppOwnerId :'+oppOwnerId);
       //User optyowner  [SELECT Email FROM User where id  :oppOwnerId];
        //listEmailSignatories.add(optyowner.Email);
        listEmailSignatories.add(productBasket.cscfga__Opportunity__r.Owner.Email);
        try{
            Contact SignatoryContact2 = New Contact();
            User SignatoryContact3 = New User();
            List<ContractJunction__c> contract = [SELECT Id,DocuSign_Signer_2__c,DocuSign_Signer_3__c,Customer_Primary_Contact__c from ContractJunction__c where Related_Basket__c =:basketId FOR UPDATE];
            System.debug(' getContractSignatories cj'+contract);
            if(contract != null && contract.size() > 0 ){
                //for()
                String signer2 = contract[0].DocuSign_Signer_2__c;
                String signer3 = contract[0].DocuSign_Signer_3__c;
                if(signer2 !=null && !signer2.equals(''))
                    SignatoryContact2 = [SELECT Id,Email FROM Contact WHERE Id = :signer2 FOR UPDATE];
                if(SignatoryContact2 != null)
                    listEmailSignatories.add(SignatoryContact2.email);
                    //listEmailSignatories.add(contract[0].DocuSign_Signer_2__r.Email);
                if(signer3 !=null && !signer3.equals(''))SignatoryContact3 = [SELECT Id,Email FROM user WHERE Id = :signer3];
                if(SignatoryContact3 !=null)
                    listEmailSignatories.add(SignatoryContact3.email);
            }
        } catch(Exception e){ system.debug('exception : '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());throw e;
        }
        return listEmailSignatories;
    }
}