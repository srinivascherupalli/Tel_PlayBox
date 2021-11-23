/* class Name: UpdateMRODetailsUtility
* Test class Name :UpdateMRODetailsSchedulableTest
* Description: Utility class for methods to update final MRO commercial details as received from Replicator in staging object ans send mail when got null values from replicator.
1.  Prajakta          16/10/2020          EDGE-179345
2.  Prajakta          04/11/2020          EDGE-174930
3.  Prajakta          03/12/2020          EDGE-193322
4.  Prajakta          03/02/2021          EDGE-194053
5.  prajakta          16/02/2021          subscription status to Provisioned
6.  Dheeraj Bhatt     12/04/2021          EDGE-208435-Enhance Subscription orchestration process steps to hold Right to Bill trigger for migration MRO subscription
================================================================================================================================*/
public with  sharing class UpdateMRODetailsUtility {
    
    
    public static void updateMRODetails( Map<String,Service_Add_On__c> instanceIdaddonMap) {
        
        Map<String,Service_Add_On__c> failInstanceIdaddonMap = new Map<String,Service_Add_On__c>();
        Map<String, csord__Service__c> transitionIdServiceMap = new Map<String, csord__Service__c>();
        Map<Id, Blob> serviceAttachmentMap = new Map<Id, Blob>();
        List<CS_SpecificationDTO.ServiceSpecification> billSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        List<csord__Service__c> updateServiceList = new  List<csord__Service__c>();
        List<Id> orderId = new List<Id>();
        List<String> subId = new List<String>();
        Set<String> solsubId = new Set<String>();
        Map<String,String>AttrsMap = new Map<String,String>();
        Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>(); 
        Map<String, Attachment> AttMapTobeUpdated = new Map<String, Attachment>();
        List <csord__Subscription__c> updateSubList = new List<csord__Subscription__c>();
        List<Service_Add_On__c> updateaddonList = new List<Service_Add_On__c>();
        Map<String, String> configatt = new Map<String, String>();
        List<csord__Subscription__c> updatesub = new List<csord__Subscription__c>();
        boolean solutionPresent = false;
        boolean isfail = false;
        cssmgnt.API_1 api = new cssmgnt.API_1();
        String response = '';
        String response1 = '';
        String solutionId ='';
        Set<Id> pcSet = new Set<Id>();
        Map<Id,List<cscfga__Attribute__c>> attrMap= new Map<Id,List<cscfga__Attribute__c>>();
        List<cscfga__Attribute__c> updateAttrList = new List<cscfga__Attribute__c>();
        //EDGE-208435-Dheeraj Bhatt- Removed the changeType condition from Service Query
        Map<Id,csord__Service__c> serviceMap = new Map<Id,csord__Service__c>([select id, Transition_Id__c,expiryDuration__c,contract_term__c,csord__Status__c,csord__Subscription__c,csord__Subscription__r.triggerBill_RTB__c,csord__Subscription__r.csord__Status__c,csord__Subscription__r.expiryDuration__c,csord__Subscription__r.Contract_Term__c,csord__Order__c,csordtelcoa__Product_Configuration__r.configGUID__c,cssdm__solution_association__c, csordtelcoa__Product_Configuration__c,changeType__c,csord__Subscription__r.cssdm__solution_association__c from csord__Service__c where Transition_Id__c in:instanceIdaddonMap.keyset() /*AND changeType__c !='Migration'*/]);//EDGE-194053
        
        for(Id serv :serviceMap.keyset()){
            transitionIdServiceMap.put(serviceMap.get(serv).Transition_Id__c ,serviceMap.get(serv));
            pcSet.add(serviceMap.get(serv).csordtelcoa__Product_Configuration__c );
        }
        
        for(cscfga__Attribute__c attr :[select id , name , cscfga__Product_Configuration__c , cscfga__Display_Value__c ,cscfga__Value__c from cscfga__Attribute__c where cscfga__Product_Configuration__c IN: pcSet AND (Name='OC'OR Name='ContractTerm')]){
            if(attrMap.containsKey(attr.cscfga__Product_Configuration__c))
            {
                List<cscfga__Attribute__c> attList = attrMap.get(attr.cscfga__Product_Configuration__c);
                attList.add(attr);
                attrMap.put(attr.cscfga__Product_Configuration__c, attList);
            }
            else{
                attrMap.put(attr.cscfga__Product_Configuration__c, new List<cscfga__Attribute__c>{attr});
            }
            
        }
        
        for (Attachment att : [SELECT Id, body, parentId FROM Attachment WHERE parentId IN :serviceMap.keyset() AND name = :OrchestratorConstants.DataOrchestrationNames.service]) {
            serviceAttachmentMap.put(att.parentId, att.body);
            servAttachmentRecordMap.put(att.parentId,att);
            
        }
        system.debug('serviceAttachmentMap:'+serviceAttachmentMap); 
        if(!instanceIdaddonMap.isEmpty()){
            for(String inst :instanceIdaddonMap.keyset()){
                
                if(instanceIdaddonMap.get(inst).Final_Remaining_Term__c!= null && instanceIdaddonMap.get(inst).Final_Remaining_Amount__c!= null && instanceIdaddonMap.get(inst).Monthly_Amount__c != null){
                    
                    AttrsMap.put('ContractTerm',String.valueOf(Integer.valueOf(instanceIdaddonMap.get(inst).Final_Remaining_Term__c)));
                    AttrsMap.put('rateExcludeGST',String.valueOf(instanceIdaddonMap.get(inst).Final_Remaining_Amount__c));
                    AttrsMap.put('monthlyPrice',String.valueOf(instanceIdaddonMap.get(inst).Monthly_Amount__c));
                    
                    csord__Service__c serv = transitionIdServiceMap.get(inst);
                    if(serv!= null){
                        
                        if (serviceAttachmentMap.containsKey(serv.id)) {
                            String attachmentBody = serviceAttachmentMap.get(serv.id).toString();
                            system.debug('AttrsMap:'+AttrsMap); 
                            String bodyToUpdate = Orchestration_Utility.addSimpleAttributes(attachmentBody,AttrsMap,'BILLING');
                            system.debug('bodyToUpdate:'+bodyToUpdate);
                            if (!bodyToUpdate.equals('false')) {
                                Attachment attAdd = servAttachmentRecordMap.get(serv.id);
                                attAdd.body = Blob.valueOf(bodyToUpdate);
                                AttMapTobeUpdated.put(attAdd.id, attAdd);
                            }
                            
                        }
                        serv.expiryDuration__c = instanceIdaddonMap.get(inst).Final_Remaining_Term__c;
                        serv.contract_term__c =  String.valueOf(Integer.valueOf(instanceIdaddonMap.get(inst).Final_Remaining_Term__c)); //EDGE-193322
                        serv.csord__Subscription__r.contract_term__c =  String.valueOf(Integer.valueOf(instanceIdaddonMap.get(inst).Final_Remaining_Term__c)); //EDGE-193322
                        serv.csord__Status__c = 'Connected';
                        updateServiceList.add(serv);
                        orderId.add(serv.csord__Order__c);
                        updatesub.add(serv.csord__Subscription__r);
                        subId.add(serv.csord__Subscription__c);
                        solsubId.add(serv.csord__Subscription__r.cssdm__solution_association__c);
                        
                        
                        for(cscfga__Attribute__c at :attrMap.get(serv.csordtelcoa__Product_Configuration__c)){
                            if(at.name.Contains('OC')){
                                at.cscfga__Value__c = String.valueOf(instanceIdaddonMap.get(inst).Final_Remaining_Amount__c);
                                at.cscfga__Display_Value__c = String.valueOf(instanceIdaddonMap.get(inst).Final_Remaining_Amount__c);
                            }
                            if(at.name.Contains('ContractTerm')){
                                at.cscfga__Value__c = String.valueOf(Integer.valueOf(instanceIdaddonMap.get(inst).Final_Remaining_Term__c));
                                at.cscfga__Display_Value__c = String.valueOf(Integer.valueOf(instanceIdaddonMap.get(inst).Final_Remaining_Term__c));
                            }
                            updateAttrList.add(at);
                        }
                        
                        instanceIdaddonMap.get(inst).Status__c = 'Complete';
                        updateaddonList.add(instanceIdaddonMap.get(inst));
                        
                    }
                    
                }
                else{
                    
                    failInstanceIdaddonMap.put(inst,instanceIdaddonMap.get(inst));
                    failInstanceIdaddonMap.get(inst).Status__c = 'Failure';
                    updateaddonList.add(instanceIdaddonMap.get(inst));
                    isfail = true;
                    
                    
                }
                if(isfail==true){
                    
                    sendEmailforfailedAddons(failInstanceIdaddonMap);}
            }
            
            
        }
        
        if(orderId!= null){
            List<csord__Subscription__c> subList = [select id,triggerBill_RTB__c,csord__Status__c, csord__Order__c,csordtelcoa__Product_Configuration__r.configurationType1__c,cssdm__solution_association__c from csord__Subscription__c where cssdm__solution_association__c =: solsubId ];
            
            if(subList!= null){
                for(csord__Subscription__c sub :subList){
                    
                    if (sub.csordtelcoa__Product_Configuration__r.configurationType1__c == OrchestratorConstants.ProductConfigType.SolutionComponent){
                        
                        if(sub.csord__Status__c!= 'Provisioned'){
                            sub.csord__Status__c = 'Provisioned';
                        }
                        sub.triggerBill_RTB__c = true;
                        solutionPresent = true;
                        updateSubList.add(sub);
                    }
                    
                }
                
                
            }
            
        }
        
        for(csord__Subscription__c subscription :[select id, expiryDuration__c,csord__Status__c,triggerBill_RTB__c,  cssdm__solution_association__c from csord__Subscription__c where id IN:subId]){
            if(solutionPresent != true){ //EDGE-174930 - subscription status to Provisioned removed
                subscription.triggerBill_RTB__c = true;  
                
            }
            updateSubList.add(subscription);
            
        }
        
        
        system.debug('updateServiceList:'+updateServiceList);
        system.debug('AttMapTobeUpdated:'+AttMapTobeUpdated);
        if(!updateServiceList.isEmpty()){
            update updateServiceList;
        }
        if(!updatesub.isEmpty()){
            update updatesub;
        }
        if(!updateSubList.isEmpty()){
            update updateSubList;
        }
        if(!updateaddonList.isEmpty()){
            update updateaddonList;
        }
        if(!updateAttrList.isEmpty()){
            update updateAttrList;
        }
        
        
        if (AttMapTobeUpdated.size() > 0) {
            //Call update
            List<Database.SaveResult> updateResult = Database.update(AttMapTobeUpdated.values(), false);
        }  
        
    }
    public static void sendEmailforfailedAddons( Map<String,Service_Add_On__c> failureInstanceIdaddonMap){
        system.debug('failureInstanceIdaddonMap:'+failureInstanceIdaddonMap);
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add( Label.DLToBeReceived);
        
        email.setToAddresses(sendTo);
        email.setSubject(' Alert: Transition device batch process failure '+System.now());
        Integer count = 0;
        String msg = '';
        String headerbody ='';
        String rowbody ='';
        
        headerbody +='<style> table, th, td { border: 1px solid black; border-collapse: collapse; } th, td { padding: 15px; } </style><table style="width:auto;"><tr>Alert while processing transition device(s) batch process updates !<br/><br/></tr><tr style="background-color: #dddddd;"><th>Sr. No.</th><th>Salesforce Record Id</th><th>Device Id</th><th>Date</th><th>Error Detail</th></tr>';
        
        
        for(String instId :failureInstanceIdaddonMap.keyset()){
            count++;
            
            
            if((failureInstanceIdaddonMap.get(instId).Final_Remaining_Term__c == null) && (failureInstanceIdaddonMap.get(instId).Final_Remaining_Amount__c== null) && (failureInstanceIdaddonMap.get(instId).Monthly_Amount__c== null)){
                msg= 'Mandatory Information Final Remaining Term, Final Remaining Amount,Monthly Amount not updated by MICA feed.'; 
            }
            else if((failureInstanceIdaddonMap.get(instId).Final_Remaining_Term__c == null) && (failureInstanceIdaddonMap.get(instId).Final_Remaining_Amount__c== null)){
                msg= 'Mandatory Information Final Remaining Term, Final Remaining Amount not updated by MICA feed.';
            }
            else if((failureInstanceIdaddonMap.get(instId).Final_Remaining_Amount__c== null) && (failureInstanceIdaddonMap.get(instId).Monthly_Amount__c== null)){
                msg= 'Mandatory Information Final Remaining Amount,Monthly Amount not updated by MICA feed.'; 
            }
            else if((failureInstanceIdaddonMap.get(instId).Final_Remaining_Term__c == null) && (failureInstanceIdaddonMap.get(instId).Monthly_Amount__c== null)){
                msg= 'Mandatory Information Final Remaining Term,Monthly Amount not updated by MICA feed.';
            }
            else if(failureInstanceIdaddonMap.get(instId).Final_Remaining_Term__c == null){
                msg= 'Mandatory Information Final Remaining Term not updated by MICA feed.';
            }
            else if(failureInstanceIdaddonMap.get(instId).Final_Remaining_Amount__c== null){
                msg= 'Mandatory Information Final Remaining Amount not updated by MICA feed.';
            }
            else if(failureInstanceIdaddonMap.get(instId).Monthly_Amount__c== null){
                msg= 'Mandatory Information Monthly Amount not updated by MICA feed.';
            }    
            
            
            
            rowbody += '<tr><td >'+count+'</td><td >'+failureInstanceIdaddonMap.get(instId).id+'</td><td >'+failureInstanceIdaddonMap.get(instId).Device_Id__c+'</td><td >'+System.now()+'</td><td >'+msg+'</td></tr>';
        }
        
        rowbody += '</table><br/><br/>'; 
        rowbody +='<p style="color:red;">**** This is an automatically generated mail - Please do not reply to this email ****</p>';
        system.debug('headerbody'+headerbody);
        system.debug('rowbody'+rowbody);
        email.setHtmlBody(headerbody + rowbody);       
        system.debug('email'+email);  
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        
    }
/*******************************************************************************************
Method      -triggerRTBForNonMicaDependecy
CreatedBy   -Dheeraj Bhatt
EDGE        -208435
Description -Trigger RTB if there is no dependency on Mica
****************************************************************************************************/
    public static void triggerRTBForNonMicaDependecy(Map<String,Service_Add_On__c> instanceIdaddonMap){
        set<id>subscriptionIdSet=new set<id>();
        set<id>solutionSubscriptionIdSet=new set<id>();
        List<csord__Service__c> serviceList= new List<csord__Service__c>();
        List<csord__Subscription__c> subscriptionList= new List<csord__Subscription__c>();
        map<id,boolean> solutionSubscriptionMap= new map<id,boolean>();
        for(csord__Service__c service:[select id, Transition_Id__c,expiryDuration__c,contract_term__c,csord__Status__c,csord__Subscription__c,csord__Subscription__r.triggerBill_RTB__c,csord__Subscription__r.csord__Status__c,csord__Subscription__r.expiryDuration__c,csord__Subscription__r.Contract_Term__c,csord__Order__c,csordtelcoa__Product_Configuration__r.configGUID__c,cssdm__solution_association__c, csordtelcoa__Product_Configuration__c,changeType__c,csord__Subscription__r.cssdm__solution_association__c from csord__Service__c where Transition_Id__c in:instanceIdaddonMap.keyset()]){
            if( service.csord__Status__c != 'Connected'){
                service.csord__Status__c = 'Connected';
            }
            serviceList.add(service);
            subscriptionIdSet.add(service.csord__Subscription__c);
            solutionSubscriptionIdSet.add(service.csord__Subscription__r.cssdm__solution_association__c);
            
        }
        for(csord__Subscription__c subscription:[select id,triggerBill_RTB__c,csord__Status__c, csord__Order__c,csordtelcoa__Product_Configuration__r.configurationType1__c,cssdm__solution_association__c from csord__Subscription__c where cssdm__solution_association__c IN: solutionSubscriptionIdSet ]){
            if (subscription.csordtelcoa__Product_Configuration__r.configurationType1__c == OrchestratorConstants.ProductConfigType.SolutionComponent){
                if(subscription.csord__Status__c!= 'Provisioned'){
                    subscription.csord__Status__c = 'Provisioned';
                }
                solutionSubscriptionMap.put(subscription.csord__Order__c, true);
                subscription.triggerBill_RTB__c = true;
                subscriptionList.add(subscription);
            } 
            
            
        }
        for(csord__Subscription__c subscription :[select id, expiryDuration__c,csord__Order__c,csord__Status__c,triggerBill_RTB__c,  cssdm__solution_association__c from csord__Subscription__c where id IN:subscriptionIdSet]){
            if((!solutionSubscriptionMap.isEmpty() && !solutionSubscriptionMap.containsKey(subscription.csord__Order__c)) || solutionSubscriptionMap.isEmpty()) {
                subscription.triggerBill_RTB__c = true;  
                subscriptionList.add(subscription);
            }
        }
        
        if(!serviceList.IsEmpty()){
            update serviceList;
        }
        if(!subscriptionList.IsEmpty()){
            update subscriptionList;
        }
    } 
}