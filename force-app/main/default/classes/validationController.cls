/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 05-22-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   04-06-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
* 2.0   07-May-2021   Gokul P               EDGE-213659
* 3.0   19-May-2021  Nikhil          EDGE-214318
* 4.0   13-Aug-2021  Gokul P 	Defect DIGI-13331 & DIGI-12937 Change the reason value
* 5.0   24-Sep-2021  Rajiv 	    DIGI-577,DIGI-360
**/
public with sharing class validationController {
    //static Boolean checkCondition;  //EDGE-214318
    Boolean checkAllConditions;
    String action_type = '';
    List<object> errorList;
    Boolean errorInCorrelation;
    static AddressResponseDTO nbnAddressDTO = null; //Gokul EDGE-213659
    public validationController() {
        system.debug('inside validation controller');
        this.checkAllConditions = true;
        this.errorList = new List<object>();
        this.errorInCorrelation = false;
        //checkCondition = false; //EDGE-214318
    }
    
/**
* Author: Rajiv Kumar Singh
* Des : To test the master data
* EDGE-209291
* Date : 04.06.2021
*/
    public Map<String,String>  validateMasterData(Map<String,String> inputMap){
        String cidn;
        String value = '';
        String field = '';
        String message = '';
        String Code = '';
        String Status = '';
        String description = '';
       
        system.debug('inside masterdata');
        Map<String,String> finalMap = new Map<String,String>();
        checkCorrelation(inputMap);

        if(this.checkAllConditions){
            system.debug('inside all true');
            Code = '200';
            Status = 'Success';
           description = 'Validation successful for all the services';
            finalMap = finalMessage(status,description,code);
            finalMap.put('CorrelationId__c',inputMap.get('CorrelationId__c'));
        }else{
            if(this.errorInCorrelation){
                Code = '400';
            }else{
                Code = '422';
            }
            Status = 'Failed';
            description = 'Validation failed';
             finalMap = finalMessage(Status,description,code);
            finalMap.put('errors',JSON.serialize(errorList));
            
        }
        System.debug('checkAllConditions '+checkAllConditions);
        System.debug('finalMap '+finalMap);
        return finalMap;
    }
    
      /**
* Author: Rajiv Kumar Singh
* Des : To test the Account that existis in salesforce
* EDGE-209291
* Date : 04.06.2021
*/
    public void checkForAccountCIDN(Map<String,String> inputMap){
        String cidn;
        String value = '';
        String field = '';
        String message = '';
        if(!inputMap.isEmpty() && inputMap!=null && inputMap.containskey('AccountId__c') && inputMap.get('AccountId__c')!=null && inputMap.get('AccountId__c')!=''){
            cidn = inputMap.get('AccountId__c');
            system.debug('cidnnumrt'+cidn);
            system.debug('coming inside');
                List<Account> accList = [SELECT Id,CIDN__c,Account_Status__c FROM Account WHERE (Customer_Status__c ='ACTIVE' OR Customer_Status__c ='ACQUIRED') AND CIDN__c=:cidn];
                if(accList.size() == 1){
                 system.debug('coming inside1');   
                }else{
                system.debug('coming inside2');
                    this.checkAllConditions = false;
                    value = inputMap.get('AccountId__c');
                    field = 'AccountId__c';
                    message = 'AccountId__c is blank or invalid';
                    this.errorList.add(addMessage(field,value,message));
                }
            
        }else{
        system.debug('coming inside3');
            field = 'AccountId__c';
            this.checkAllConditions = false;
            message = 'AccountId__c is blank or invalid';
            this.errorList.add(addMessage(field,value,message));
        }
        
    }
    
     /**
* Author: Rajiv Kumar Singh
* Des : To test the Action type
* EDGE-209291
* Date : 04.06.2021
*/
    public void checkForActionType(Map<String,String> inputMap){
        String actionType; 
        List<String> actionTypeList = new List<String>{'SIM Replacement','Resume','Suspend'};
        action_type =  inputMap.get('ActionType__c');
      //  system.debug('!inputMap.isEmpty() '+!inputMap.isEmpty());
        system.debug('inputMap!=nul '+inputMap!=null);
        system.debug('inputMap.containskey '+inputMap.containskey('ActionType__c'));
        system.debug('inputMap.get  not null '+inputMap.get('ActionType__c') != null);
        system.debug('inputMap.get  not blank '+inputMap.get('ActionType__c') != '');
        system.debug('sny one of type sim '+ action_type.equalsIgnoreCase('SIM Replacement'));
        if(!inputMap.isEmpty() && inputMap!=null && inputMap.containskey('ActionType__c') && inputMap.get('ActionType__c') != null && inputMap.get('ActionType__c') != '' && (action_type.equalsIgnoreCase('SIM Replacement') || action_type.equalsIgnoreCase('Resume') || action_type.equalsIgnoreCase('Suspend'))){
          
            if(action_type.equalsIgnoreCase('SIM Replacement')){
                checkForReason(inputMap); 
            }else{
                system.debug('** ActionType  is ** '+inputMap.get('ActionType__c'));
            }
        }else{
            String value = '';
            String field = '';
            String message = '';
            System.debug('else for ActionType__c');
            this.checkAllConditions = false;
            if(!inputMap.isEmpty() && inputMap!=null && inputMap.containskey('ActionType__c')){
                value = inputMap.get('ActionType__c');
            }
            field = 'ActionType__c';
            message = 'ActionType__c is empty or invalid';
            this.errorList.add(addMessage(field,value,message));
        }
    }
       /**
* Author: Rajiv Kumar Singh
* Des : To test the reason provided in the input
* EDGE-209291
* Date : 04.06.2021
*/
    public void checkForReason(Map<String,String> inputMap){
        String reason;
        set<String> reasonSet = new set<String>(); 
        reasonSet.add('Device Reset');
        reasonSet.add('Device Changed');
        reasonSet.add('Device Lost/Stolen');
        reasonSet.add('Sim Card (Physical SIM) faulty');
        reasonSet.add('eSIM faulty');
        reasonSet.add('SIM Card Lost/Stolen');
        reasonSet.add('eSIM Lost/Stolen');
        reasonSet.add('Change from Sim Card (Physical SIM) to e-Sim');
        reasonSet.add('Change from e-Sim to Sim Card (Physical SIM)');
        if(!inputMap.isEmpty() && inputMap!=null && inputMap.containskey('Reason__c') && inputMap.get('Reason__c') != '' && inputMap.get('Reason__c') != null && reasonSet.contains(inputMap.get('Reason__c'))){
            reason = inputMap.get('Reason__c');
            system.debug('reasonSet '+reasonSet);
            system.debug('reason '+reason);
            system.debug('reasonSet '+reasonSet.contains(reason));
            // resultMap.put('result','success');
        }else{
            String value = '';
            String field = '';
            String message = '';
            if(!inputMap.isEmpty() && inputMap!=null && inputMap.containskey('Reason__c')){
                value = inputMap.get('Reason__c');
            }
            field = 'Reason__c';
            message = 'Reason__c is empty or invalid';
            this.checkAllConditions = false;
             this.errorList.add(addMessage(field,value,message));
        }
        
    }
      /**
* Author: Rajiv Kumar Singh
* Des : This method is used to check that owner is existing in SFDC or not
* EDGE-209291
* Date : 04.06.2021
*/
    public  void checkForOwnerId(Map<String,String> inputMap){
        string ownerID;
        String value = '';
        String field = '';
        String message = '';
        if(!inputMap.isEmpty() && inputMap!=null && inputMap.containskey('OwnerId__c') && inputMap.get('OwnerId__c')!= null && inputMap.get('OwnerId__c') != ''){
            ownerID = inputMap.get('OwnerId__c');
            List<User> userList = [SELECT Id,IsActive FROM User WHERE FederationIdentifier=:ownerID AND IsActive=true];
            if(userList.size() == 1){
                //resultMap.put('result','success');
            }else{
                
                this.checkAllConditions = false;
                value = inputMap.get('OwnerId__c');
                field = 'OwnerId__c';
                message = 'OwnerId__c is invalid';
                 this.errorList.add(addMessage(field,value,message));
            }
    }
}
      /**
* Author: Rajiv Kumar Singh
* Des : This method is used to check the reference number
* EDGE-209291
* Date : 04.06.2021
*/
    public void checkReferenceNumber(Map<String,String> inputMap){
        if(!inputMap.isEmpty() && inputMap!=null && inputMap.containskey('ReferenceNumber__c') && inputMap.get('ReferenceNumber__c') != null && inputMap.get('ReferenceNumber__c') != ''){
            //resultMap.put('result','success');
        }else{
            String value = '';
            String field = '';
            String message = '';
            System.debug('else for ReferenceNumber__c');
            this.checkAllConditions = false;
            if(!inputMap.isEmpty() && inputMap!=null && inputMap.containskey('ReferenceNumber__c')){
                value = inputMap.get('ReferenceNumber__c');
            }
            field = 'ReferenceNumber__c';
            message = 'ReferenceNumber__c is empty or invalid';
            this.errorList.add(addMessage(field,value,message));
        }
    }
     /**
* Author: Rajiv Kumar Singh
* Des : This method is used to check correlation Id
* EDGE-209291
* Date : 04.06.2021
*/
    public void checkCorrelation(Map<String,String> inputMap){
        if(!inputMap.isEmpty() && inputMap!=null && inputMap.containskey('CorrelationId__c') && inputMap.get('CorrelationId__c') != '' && inputMap.get('CorrelationId__c') != null){ 
            String AccountId = inputMap.get('AccountId__c');
            checkForAccountCIDN(inputMap);
            checkForActionType(inputMap);
            checkReferenceNumber(inputMap);
            checkForOwnerId(inputMap);
            // EDGE-214318 start
            if(inputMap.containskey('services')){
                List<Object> serviceList = (List<Object>)JSON.deserializeUntyped(inputMap.get('services'));                      
                List<Map<String,String>> dispatchReqList = new List<Map<String,String>>();
                System.debug('serviceList 241 '+serviceList);
                
                if(action_type != 'Resume' && action_type != 'Suspend'){
                    dispatchReqList = checkRequestedSIMType(serviceList);
                }
                //System.debug('checkCondition 253 '+checkCondition);
                if(!dispatchReqList.isEmpty())
                {
                    System.debug('about to call checkDispatchRequired');
                    checkDispatchRequired(dispatchReqList,AccountId);

                }
                // EDGE-214318 End        
            }}else{
            String value = '';
            String field = '';
            String message = '';
            System.debug('else for CorrelationId__c');
            this.errorInCorrelation = true;
            this.checkAllConditions = false;
            if(!inputMap.isEmpty() && inputMap!=null && inputMap.containskey('CorrelationId__c')){
                value = inputMap.get('CorrelationId__c');
            }
            field = 'CorrelationId__c';
            message = 'CorrelationId__c is empty or already exists';
             this.errorList.add(addMessage(field,value,message));
        }
    }
     /**
* Author: Rajiv Kumar Singh
* Des : This method is used to check the list of service data
* EDGE-209291
* Date : 04.06.2021
*/
    public  Map<String,String> validateServicesData(Map<string,String> inputMap){
        String cidn;
        String value = '';
        String field = '';
        String message = '';
        String Code = '';
        String Status = '';
        String description = '';
        system.debug('action type inside service data '+action_type);
        system.debug('inputMap'+inputMap);
        set<String> subsNumSet = new set<String>();
        set<String> serviceMSIDNSet = new set<String>();
        Map<String,String> finalMap = new Map<String,String>();
        List<Map<String,String>> Listmap = new List<Map<String,String>>(); //EDGE-214318
        if(!inputMap.isEmpty() && inputMap!=null && inputMap.containskey('serviceMSISDN__c')){
            List<Object> serviceList = (List<Object>)JSON.deserializeUntyped(inputMap.get('serviceMSISDN__c'));
            for(Object obj : serviceList){
                Map<String,Object> serviceMAp = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                //EDGE-214318 Start
                Map<String,String> newMap = new Map<String,String>();
                        System.debug('serviceMAp '+serviceMAp);
                        for(String key : serviceMAp.keySet()){
                            newMap.put(key,(String)serviceMap.get(key));
                        }
                        Listmap.add(newMap);
                //EDGE-214318 End
                if(serviceMAp.containskey('Subscription_Number__c')){
                    subsNumSet.add(serviceMAp.get('Subscription_Number__c').toString());
                }
                if(serviceMAp.containskey('serviceMSISDN__c')){
                    serviceMSIDNSet.add(serviceMAp.get('serviceMSISDN__c').toString());
                }
            }
            System.debug('Listmap '+Listmap);//EDGE-214318
            List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
            if(action_type == 'Resume' || action_type == 'Suspend'){
                subscriptionList = [SELECT Id,csordtelcoa__Subscription_Number__c,Suspension_reason__c,csord__Account__c,csord__Status__c,Suspension_reason_summary__c FROM csord__Subscription__c WHERE csordtelcoa__Subscription_Number__c IN: subsNumSet];
            }else{
                subscriptionList = [SELECT Id,csordtelcoa__Subscription_Number__c,Suspension_reason__c,csord__Account__c,csord__Status__c,Suspension_reason_summary__c FROM csord__Subscription__c WHERE csordtelcoa__Subscription_Number__c IN: subsNumSet AND (csord__Status__c = 'Active' OR csord__Status__c = 'Suspended')];
            }

            List<csord__Service__c> serviceRecList = [SELECT Id,serviceMSISDN__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c,csord__Status__c FROM csord__Service__c WHERE serviceMSISDN__c IN :serviceMSIDNSet];
            system.debug('serviceRecList size '+serviceRecList);
           
            if(action_type != 'Resume' && action_type != 'Suspend'){
                if(serviceRecList.size() > 0){
                CheckForServiceMSISDN(serviceList,serviceRecList);
            }else{
                system.debug('service failed no existing service');
                  field = 'serviceMSISDN__c';
                    message = 'service is empty or invalid';
                    errorList.add(addMessage(field,value,message));
                    this.checkAllConditions = false;
            }
            if(subscriptionList.size() > 0){
                checkForSubscriptionNumber(serviceList,subscriptionList);
                 }else if(action_type != 'Resume' && action_type != 'Suspend'){
                   value = '';
                     field = '';
                     message = '';
                    field = 'Subscription_Number__c';
                    message = 'Subscription_Number__c is empty or invalid';
                    errorList.add(addMessage(field,value,message));
                    this.checkAllConditions = false;
            }
            }
           
               
               if(action_type != 'Resume' && action_type != 'Suspend'){
                checkRequestedSIMType(serviceList);      
               }
                checkForDispatch(serviceList);
                //checkForSIMSerialNumber(serviceList); commented  EDGE-214318
               //     EDGE-214318 start
               system.debug('input map contains dispatch '+inputMap.containskey('Dispatch_Required__c'));
            
                system.debug('after initial check');
              //     EDGE-214318 End
              //    
               if((inputMap != null && action_type!=null && action_type!= '' && (action_type == 'Resume' || action_type == 'Suspend')) || test.isRunningTest()){
                system.debug('checking for checkReasonOnServices and action type is '+inputMap.get('ActionType__c'));
                checkReasonOnServices(serviceList,subscriptionList,action_type,serviceRecList);
                }
                if((inputMap != null && action_type!=null && action_type!= '' && action_type == 'Suspend') || test.isRunningTest()){
                    system.debug('checking for checkServicesForSuspend');
                    checkServicesForSuspend(serviceList,subscriptionList,serviceRecList);
                }else if((inputMap != null && action_type!=null && action_type!= '' && action_type == 'Resume') || test.isRunningTest()){
                    system.debug('checking for checkServicesForResume');
                    checkServicesForResume(serviceList,subscriptionList,serviceRecList);
                }
            
            system.debug('before checking condition');
            if(this.checkAllConditions){
                system.debug('inside all true');
                Code = '200';
                Status = 'Success';
                description = 'Validation successful for all the services';
                finalMap = finalMessage(Status,description,Code);
            }else{
                Code = '422';
                Status = 'Failed';
                description = 'Validation failed';
                finalMap = finalMessage(Status,description,Code);
                finalMap.put('errors',JSON.serialize(this.errorList));
            }
            system.debug('errors in services '+errorList);
            System.debug('checkAllConditions '+checkAllConditions);
            system.debug('service date finalMap '+finalMap);
        }
        return finalMap;
    }
    
/**
* Author: Shweta Khandelwal
* Des : To Test validation for the order
* EDGE-209292
* Date : 04.06.2021
*/
    public static Map<String,String> validateRequest(String correlationId,String previousStep){
        System.debug('previousStep '+previousStep);
        Map<String,String> resultMap = new Map<String,String>();
        if(String.isBlank(correlationId)){
            resultMap = createResultMap('Failed','Validation failed','CorrelationId__c is empty or invalid','400','CorrelationId__c');          
        }
        else if(!OC_SessionPayloadValidation.sessionExists(CorrelationId)){
            resultMap = createResultMap('Failed','Validation failed','CorrelationId__c is empty or invalid','400','CorrelationId__c');
        }
        else if(previousStep == null || (previousStep != null && !OC_SessionPayloadValidation.verifyPreviousStep(correlationId,'',previousStep)) ){
            resultMap = createResultMap('Failed','Validation failed','Please complete the previous step ('+previousStep+') before making this request','422','CorrelationId__c'); 
        }
        else{
            //If all the validations are passed then return success message along with code 200
            resultMap = createResultMap('Success','Success','','200','');
        }
        return resultMap;
    }

  
/**
* Author: Shweta Khandelwal
* 
* EDGE-209292
* Date : 04.06.2021
*/

    public static Map<String,String> createResultMap(String status, String des, String message, String code, String field){
        Map<String,String> resultMap = new Map<String,String>();
        Map<String,String> finalMap = new Map<String,String>();
        List<object> errorList = new List<Object>();
        finalMap.put('code',code);
        finalMap.put('status',status);
        finalMap.put('description',des);
        if(code != '200'){
            resultMap.put('field',field);
            resultMap.put('message',message);
            errorList.add(resultMap);
            System.debug('errorList '+errorList);
            System.debug('JSON.serialize(errorList)'+ JSON.serialize(errorList));
            finalMap.put('errors',JSON.serialize(errorList));
        }
        return finalMap;
    }
   

/**
* Author: Rajiv Kumar Singh
* Des : This method is used to check the sim serial number
* EDGE-209291
* Date : 04.06.2021
*/
    public  Boolean checkSerialNumber(String selNum){
        Boolean result;
        if(selNum.length() == 13 && selNum.isNumeric()){
            result = true;
        }else{
            result = false;
        }
        return result;
    }
    
      /**
* Author: Rajiv Kumar Singh
* Des : This method is used to check the subscription number
* EDGE-209291
* Date : 04.06.2021
*/
    
    public void checkForSubscriptionNumber(List<Object> serviceList,List<csord__Subscription__c> subscriptionList){
        Map<String,List<csord__Subscription__c>> subscriptionMap = new Map<String,List<csord__Subscription__c>>();
       system.debug('inside checkForSubscriptionNumber');
        for(csord__Subscription__c subs : subscriptionList){
            System.debug('subs11 ' + subs.csordtelcoa__Subscription_Number__c);
            if(subscriptionMap.containskey(subs.csordtelcoa__Subscription_Number__c)){
                subscriptionMap.get(subs.csordtelcoa__Subscription_Number__c).add(subs);
            }else{
                subscriptionMap.put(subs.csordtelcoa__Subscription_Number__c, new List<csord__Subscription__c>{subs});
            }
        } 
        system.debug('subscriptionMap '+subscriptionMap);
        for(Object service : serviceList){
            Map<String,Object> tempServiceMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(service));
            System.debug('tempServiceMap '+tempServiceMap);
            if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('Subscription_Number__c') && 
            subscriptionMap.containskey((String)tempServiceMap.get('Subscription_Number__c')) && 
            subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString()).size() > 0)
           {
               system.debug('inside first if for subscription '+subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString())[0].csord__Account__c);
             // if validation suceed
             if(subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString())[0].csord__Account__c != null){
               system.debug('validation succeed for subscription');
             }else{
                 system.debug('vallidation failed for subscription');
                String value = '';
            String field = '';
            String message = '';
            field = 'Subscription_Number__c';
            if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('Subscription_Number__c')){
                value = String.valueof(tempServiceMap.get('Subscription_Number__c'));
            }
            message = 'Subscription_Number__c does not belongs to account for serviceMSISDN__c '+tempServiceMap.get('serviceMSISDN__c');
            this.errorList.add(addMessage(field,value,message));
            this.checkAllConditions = false;
            }
        }else{
             system.debug('inside else 1 for checkForSubscriptionNumber');
            String value = '';
            String field = '';
            String message = '';
            field = 'Subscription_Number__c';
            if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('Subscription_Number__c')){
                value = String.valueof(tempServiceMap.get('Subscription_Number__c'));
            }
            message = 'Subscription_Number__c is empty or invalid for serviceMSISDN__c '+tempServiceMap.get('serviceMSISDN__c');
            errorList.add(addMessage(field,value,message));
            this.checkAllConditions = false;
        }
    }
        
       
    }
   
     /**
* Author: Rajiv Kumar Singh
* Des : This method is used to check the service number
* EDGE-209291
* Date : 04.06.2021
*/
    
public void  CheckForServiceMSISDN(List<Object> serviceList,List<csord__Service__c> serviceRecList){
    system.debug('inside service msidn');
    if(serviceList != null && serviceList.size() > 0 && serviceRecList.size() > 0){
        Map<String,List<csord__Service__c>> serviceMapNew = new Map<String,List<csord__Service__c>>();
        for(csord__Service__c service : serviceRecList){
            if(serviceMapNew.containskey(service.serviceMSISDN__c)){
                serviceMapNew.get(service.serviceMSISDN__c).add(service);
            }else{
                serviceMapNew.put(service.serviceMSISDN__c, new List<csord__Service__c>{service});
            }
        }
        for(Object service : serviceList){
            Map<String,Object> tempServiceMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(service));
            if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('serviceMSISDN__c') && serviceMapNew.containskey(tempServiceMap.get('serviceMSISDN__c').toString()) &&  serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString()).size() > 0){
                system.debug('salesforce subscription '+serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString())[0].csord__Subscription__r.csordtelcoa__Subscription_Number__c);
                system.debug('input subscription '+tempServiceMap.get('Subscription_Number__c'));
                if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('Subscription_Number__c') && tempServiceMap.containskey('serviceMSISDN__c') && serviceMapNew.containskey(tempServiceMap.get('serviceMSISDN__c').toString()) &&  serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString()).size() > 0){
                    Integer count = 0;
                     for(csord__Service__c serviceNew : serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString())){
                         if(serviceNew.csord__Subscription__r.csordtelcoa__Subscription_Number__c == tempServiceMap.get('Subscription_Number__c')){
                             break;
                         }else{
                             count++;
                         }
                     }
                     if(count == serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString()).size()){
                         String value = '';
                         String field = '';
                         String message = '';
                         field = 'serviceMSISDN__c';
                         if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('serviceMSISDN__c')){
                             value = String.valueof(tempServiceMap.get('serviceMSISDN__c'));
                             message = 'serviceMSISDN__c does not belongs to Subscription';
                         }else if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('serviceMSISDN__c') && !tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.get('serviceMSISDN__c')==''){
                             message = 'serviceMSISDN__c is empty or invalid';
                         }
                         
                         this.errorList.add(addMessage(field,value,message));
                         this.checkAllConditions = false;
                     }
            }else{
                String value = '';
                String field = '';
                String message = '';
                field = 'serviceMSISDN__c';
                if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('serviceMSISDN__c')){
                    value = String.valueof(tempServiceMap.get('serviceMSISDN__c'));
                }
                message = 'serviceMSISDN__c is empty or invalid';
                this.errorList.add(addMessage(field,value,message));
                this.checkAllConditions = false;
            }
        }
    }
    }else{
        system.debug('inside else consition');
        String value = '';
        String field = '';
        String message = '';
        field = 'serviceMSISDN__c';
        message = 'serviceMSISDN__c is empty or invalid';
        errorList.add(addMessage(field,value,message));
        this.checkAllConditions = false;
    }
}
    
      /**
* Author: Rajiv Kumar Singh
* Des : This method is used to check the sim serial number
* EDGE-209291
* Date : 04.06.2021
*/
    public void  checkForSIMSerialNumber(List<Map<String,String>> simSerialList){
        system.debug('calling sim service number checkk');
        for(Map<String,String> tempServiceMap : simSerialList){
            //Map<String,Object> tempServiceMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
            if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('Sim_Serial_Number__c') && tempServiceMap.get('Sim_Serial_Number__c') != '' && checkSerialNumber(tempServiceMap.get('Sim_Serial_Number__c'))){
            system.debug('sim srial num validation succeeded');
            }else{
                system.debug('sim serial number failed');
                String value = '';
                String field = '';
                String message = '';
                field = 'Sim_Serial_Number__c';
                if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('Sim_Serial_Number__c')){
                    value = tempServiceMap.get('Sim_Serial_Number__c');
                }
                message = 'Sim_Serial_Number__c is empty or invalid for serviceMSISDN__c '+tempServiceMap.get('serviceMSISDN__c');
                this.errorList.add(addMessage(field,value,message));
                this.checkAllConditions = false;
            }
          
        }
    }
    
    
      /**
* Author: Rajiv Kumar Singh
* Des : This method is used to check the requested sim type
* EDGE-209291
* Date : 04.06.2021
*/
    public List<Map<String,String>> checkRequestedSIMType(List<Object>  serviceList){ // Shweta added return type
        List<Map<String,String>> simTypeVerifiedList = new List<Map<String,String>>();
        
        for(Object obj : serviceList){
            Map<String,Object> tempServiceMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
            if(!tempServiceMap.isEmpty() && 
      tempServiceMap!=null && 
      tempServiceMap.containskey('Requested_SIM_Type__c') && 
      tempServiceMap.get('Requested_SIM_Type__c') != null && 
      tempServiceMap.get('Requested_SIM_Type__c') != ''  &&
      (tempServiceMap.get('Requested_SIM_Type__c') == 'SIM Card' || tempServiceMap.get('Requested_SIM_Type__c') == 'eSIM' )) //EDGE-214321 added condition
      {
                                // EDGE-214318    
                    //checkCondition = true; //200
                   Map<String,String> newMap = new Map<String,String>();
                   for(String key : tempServiceMap.keySet()){
                         newMap.put(key,(String)tempServiceMap.get(key));
                    }
                    simTypeVerifiedList.add(newMap);
        system.debug('validation succedd for checkRequestedSIMType');
      }
      else{
                system.debug('validation fail for checkRequestedSIMType');
            String value = '';
            String field = '';
            String message = '';
            field = 'Requested_SIM_Type__c';
            if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('Requested_SIM_Type__c')){
                value = String.valueof(tempServiceMap.get('Requested_SIM_Type__c'));
            }
            message = 'Requested_SIM_Type__c is empty or invalid for serviceMSISDN__c '+tempServiceMap.get('serviceMSISDN__c');
            this.errorList.add(addMessage(field,value,message));
            this.checkAllConditions = false;
        }
        }
        return simTypeVerifiedList;
    }
    
     /**
* Author: Rajiv Kumar Singh
* Des : This method is used to check the dispatch
* EDGE-209291
* Date : 04.06.2021
*/
     public void checkForDispatch(List<Object> serviceList){
        for(Object obj : serviceList){
            Map<String,Object> tempServiceMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(obj));
        String value = '';
                String message = '';
                if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('Dispatch_Required__c')){
                    value = String.valueof(tempServiceMap.get('Dispatch_Required__c'));
                }
            if(!tempServiceMap.isEmpty() &&
            tempServiceMap!=null &&
            tempServiceMap.containskey('Dispatch_Required__c') &&
            tempServiceMap.get('Dispatch_Required__c') != null &&
            ((tempServiceMap.get('Requested_SIM_Type__c') == ''  && tempServiceMap.get('Dispatch_Required__c') == 'NO') || (tempServiceMap.get('Requested_SIM_Type__c') == 'eSIM'  && tempServiceMap.get('Dispatch_Required__c') == 'Yes') ||
      (tempServiceMap.get('Requested_SIM_Type__c') == 'SIM Card'  && (tempServiceMap.get('Dispatch_Required__c') == 'Yes' || tempServiceMap.get('Dispatch_Required__c') == 'NO'))) //EDGE-214321 added condition
                      
            ){      
      
            system.debug('dispatch passed');
            }else if (!((tempServiceMap.get('Requested_SIM_Type__c') == 'eSIM'  && tempServiceMap.get('Dispatch_Required__c') == 'Yes') || tempServiceMap.get('Requested_SIM_Type__c') == 'SIM card' )){
        message = 'Dispatch_Required_c should be Yes if Requested_SIM_type is eSIM for serviceMSISDN__c'+tempServiceMap.get('serviceMSISDN__c');
        errorList.add(addMessage('Dispatch_Required__c',value,message));
        this.checkAllConditions = false;
      }else{
                system.debug('dispatch failed');
                message = 'Dispatch_Required__c should be either Yes/ No for serviceMSISDN__c'+tempServiceMap.get('serviceMSISDN__c');
                errorList.add(addMessage('Dispatch_Required__c',value,message));
                this.checkAllConditions = false;
            }
        }
    }
     /**
* Author: Rajiv Kumar Singh
* Des : This method is used to add messages
* EDGE-209291
* Date : 04.06.2021
*/

    public Map<String,String> addMessage(String field,String value,String message){
        Map<String,String> resultMap = new Map<String,String>();
        if(field != null && field != ''){
            resultMap.put('field',field);
        }
        if(value != null && value != ''){
            resultMap.put('value',value);
        }
        if(message != null && message != ''){
            resultMap.put('message',message);
        }
        return resultMap;
    }
   
        public Map<String,String> finalMessage(String status,string description,String code){
        Map<String,String> resultMap = new Map<String,String>();
        if(status!= null && status !=''){
            resultMap.put('status',status);
        }
        if(description != null && description != ''){
            resultMap.put('description',description);
        }
        if(code != null && code != ''){
            resultMap.put('code',code);
        }
        return resultMap;
    }
  
    
    public static Map<String,String> checkForActionType(String ActionType){
   
        Map<String,String> resultMap = new Map<String,String>();

        if(String.isBlank(ActionType) ) {
            resultMap = createResultMap('Failed', 'Validation failed', 'ActionType is empty or invalid', '422', 'ActionType');
        }
        else {
            resultMap = ShowSubscriptionsOnMACButtonController.getMACDActionTypes(ActionType);
        }
   
        System.debug(resultMap);
        return resultMap;
    }

    public  Map <String, Contact> getExistingContact(Set<String> contactSet){
        Map <String, Contact> existingContacts = new Map<String, Contact>([SELECT Id,
                                                                           Account.CIDN__c
                                                                           from Contact
                                                                            where id in : contactSet]);
        return existingContacts;
    }
   
    /*
*Author: Gokul P
*EDGE-213659
*Des: This Methods is to validate Dispatch Required (Yes/ No) and ADBorID, Contact ID if Dispatch Required = Yes
*Date: 19-May-2021
*/

    public  void checkDispatchRequired(List<Map<String,String>> inputVal, String accountId){ //Shweta
        List<Map<String,String>> resultMap = new List<Map<String,String>>();
        Map <String, Contact> existingContact = new Map<String,Contact>();
        System.debug('In checkDispatchRequired '+inputVal);
        String value = '';
        String field = '';
        String message = '';
        List<Map<String,String>> furtherValidationList = new List<Map<String,String>>(); // List for contact and address verification
        List<Map<String,String>> simSerialList = new List<Map<String,String>>();
        List<Map<String,String>> verifiedContactList = new List<Map<String,String>>();
        Set<String> contactSet = new Set<String>();
        for(Map<String,String> ValidValues: inputVal ){
            System.debug('In loop');
            String Dispatch_Required = ValidValues.get('Dispatch_Required__c').toLowerCase();
            String ADBorID = ValidValues.get('AdborID__c');
            String ContactID = ValidValues.get('ContactID__c');
            if(!String.isBlank(ContactID)){
                contactSet.add(ContactID);
            }
            String SerialNumber = ValidValues.get('Sim_Serial_Number__c');
            String serviceMSISDN = ValidValues.get('serviceMSISDN__c');
            //Boolean valid = true;      

            switch on Dispatch_Required {                  
                when 'yes'{  
                    
                        furtherValidationList.add(ValidValues);
                   
                }
                when 'no' { 
                    simSerialList.add(ValidValues);
                    
                }
                
            }        
                     
        }
        if(!contactSet.isEmpty()){
            existingContact = getExistingContact(contactSet);
        }
        if(!furtherValidationList.isEmpty()){
            verifiedContactList = checkContactId(furtherValidationList,existingContact,accountId);
            if(!verifiedContactList.isEmpty()){
                checkAddressId(verifiedContactList);
            }
        }
        if(!simSerialList.isEmpty()){
            checkForSIMSerialNumber(simSerialList);
        }
        
    }


/*
*Author: Gokul P
*EDGE-213659
*Des: This method is to validate Contact ID & If exist check it's realated Account ID (AccountId__c is CIDN__c (SalesforceOrg)) for serviceMSISDN__c
*Date: 19-May-2021
*/

    public List<Map<String,String>> checkContactId(List<Map<String,String>> mapMISDNContact2,Map <String,Contact> existingContacts,String accountId) {
        //List<Map<String,String>> resultMap = new List<Map<String,String>>();
        List<Map<String,String>> contactVerifiedList = new List<Map<String,String>>();
        Set<String> sfContactIds = new Set<String>();
        List<Map<String,String>> validRecords = new List<Map<String,String>>();
        String value = '';
        String field = '';
        String message = '';
        for (Map<String,String> setOfInputs : mapMISDNContact2) {
            String ContactId = setOfInputs.get('ContactID__c');
            String serviceMSISDN = setOfInputs.get('serviceMSISDN__c');
            //String accountCIDN2 = setOfInputs.get('AccountId__c');
           
            if(ContactId == null || ContactId ==''){
                value = serviceMSISDN;
                field = 'ContactID__c';
                message = 'ContactID__c is empty or invalid for serviceMSISDN__c '+serviceMSISDN;
                this.checkAllConditions = false;
                this.errorList.add(addMessage(field,value,message));
                //resultMap.add(createResultMap('Failed', 'Validation failed', 'ContactID__c is empty or invalid for serviceMSISDN__c ' , '422', 'ContactID__c'));
                //system.debug(resultMap);
            }
            else{
                validRecords.add(setOfInputs);
                sfContactIds.add(ContactId);
            }
           
        }
               
   
        for (Map<String,String> setOfValidInputs : validRecords) {
            String ContactId2 = setOfValidInputs.get('ContactID__c');
            String serviceMSISDN2 = setOfValidInputs.get('serviceMSISDN__c');
            //String accountCIDN3 = setOfValidInputs.get('AccountId__c');
   
   
            //if contact id from salesforce is empty or does not match to serviceMSISDN__c then fails
            if(existingContacts.values().isempty() || !existingContacts.containsKey(ContactId2) ){
                value = serviceMSISDN2;
                field = 'ContactID__c';
                message = 'ContactID__c is empty or invalid for serviceMSISDN__c '+serviceMSISDN2;
                this.checkAllConditions = false;
                this.errorList.add(addMessage(field,value,message));
                //resultMap.add(createResultMap('Failed', 'Validation failed', 'ContactID__c is empty or invalid for serviceMSISDN__c '+ serviceMSISDN2 , '422', 'ContactID__c'));
               
            }
            //if AccountId__c( same as CIDN__c) is empty or does not match to serviceMSISDN__c then fails
            else if(existingContacts.get(ContactId2).Account.CIDN__c == null || existingContacts.get(ContactId2).Account.CIDN__c != accountId) {
                //resultMap.add(createResultMap('Failed', 'Validation failed', 'AccountId__c is blank or invalid', '400', 'AccountId__c'));//change error messege
                value = serviceMSISDN2;
                field = 'ContactID__c';
                message = 'ContactID__c is empty or invalid for serviceMSISDN__c ' +serviceMSISDN2;
                this.checkAllConditions = false;
                this.errorList.add(addMessage(field,value,message));
            }
            else {
                
                contactVerifiedList.add(setOfValidInputs);
                
            }
     
        }
        return contactVerifiedList;
    }
   

/*
*Author: Gokul P
*EDGE-213659
* This Method is to Validate ADBorID(Address__ID) and check if it is exist in salesforce. If not fetch it from AddressSQ and Save it.
*Date: 19-May-2021
*/

@future(callout=true)
public static void addressSQcall (String addr){

            //fetch the address from AddressSQ
            AddressResponseDTO nbnAddressDTO = null;
            nbnAddressDTO = AddressSearch.searchAdborIdAddress(addr,'AdborIdAddressHandler');
            // System.debug('nbnAddressDTOKala: '+nbnAddressDTO);
           
            //Save the Address from AddressSQ to Salesforcce
            system.debug('****upserting using new nbn east method '+nbnAddressDTO );
                //addrAdd = 
                AddressAndSiteObjectUtility.upsertNBNEastAddress(nbnAddressDTO, false);
                
}

    public  void checkAddressId(List<Map<String,String>> ADBorIDList ) {
        //List<Map<String,String>> resultMap = new List<Map<String,String>>();
        Set<String> sfserviceMSISDN = new Set<String>();
        List<String> validADBorIds = new List<String>();
        List<String> finalADBorIds = new List<String>();
        String value = '';
        String field = '';
        String message = '';
        List<Map<String,String>> validRecords = new List<Map<String,String>>();
        List<Map<String,String>> finalRecords = new List<Map<String,String>>();
        for (Map<String,String> setOfInputs : ADBorIDList) {
          String SubscriptionNumber = setOfInputs.get('Subscription_Number__c');
          String serviceMSISDN = setOfInputs.get('serviceMSISDN__c');
          String AdborID = setOfInputs.get('AdborID__c');
          
          if(AdborID == null || AdborID ==''){
            value = serviceMSISDN;
            field = 'AdborID__c';
            message = 'AdborID__c is empty or invalid for serviceMSISDN__c '+serviceMSISDN;
            this.checkAllConditions = false;
            this.errorList.add(addMessage(field,value,message));
            //resultMap.add(createResultMap('Failed', 'Validation failed', 'AdborID__c is empty or invalid for serviceMSISDN__c '+serviceMSISDN , '422', 'AdborID__c'));
             
         }
         else{
                validRecords.add(setOfInputs);
                validADBorIds.add(AdborID);
             sfserviceMSISDN.add(serviceMSISDN);
            }
           
        }
       // system.debug(validRecords);
       // system.debug(sfserviceMSISDN);
        
        Map <String, csord__Service__c> existingService = new Map<String, csord__Service__c> ();//Map for store Salesforce org record
         for (csord__Service__c val : [SELECT  Delivery_Address__r.Address_ID__c,
                                               serviceMSISDN__c,Id 
                                               FROM csord__Service__c 
                                               where serviceMSISDN__c in : sfserviceMSISDN]) {
                                
             existingService.put(val.serviceMSISDN__c,val);
         }
       
        Map<String, String> addresssfId = new Map<String, String> ();
        Map<String,cscrm__Address__c> addres = new Map<String,cscrm__Address__c>();
        for(cscrm__Address__c sfAdId : [select Id, Address_ID__c  from cscrm__Address__c where Address_ID__c in : validADBorIds ]){
            addresssfId.put(sfAdId.Address_ID__c, sfAdId.Id);
            addres.put(sfAdId.Address_ID__c, sfAdId); //Search and save address to match with valid records
        }
    
        for(String addr : validADBorIds ){
            if(!addres.containskey(addr)){
                            //fetch the address from AddressSQ
                
                nbnAddressDTO = AddressSearch.searchAdborIdAddress(addr,'AdborIdAddressHandler');
                System.debug('nbnAddressDTOKala: '+nbnAddressDTO);
                if(nbnAddressDTO != null && nbnAddressDTO.code == 200 && nbnAddressDTO.ErrorCode==null && nbnAddressDTO.ErrorDescription==null){
                //if upcoming valid records from payload are not in Salesforce, then via API call save it in salesforce from AddressSQ   
                addressSQcall(addr);//in diff org
                System.debug('After call future method'); 
                }else{

                    finalADBorIds.add(addr);
                } 
            }
            else{
                finalADBorIds.add(addr);
            }
        }

        for(Map<String,String> finalrecord : validRecords){
            if(!finalADBorIds.isEmpty() && finalrecord.containsKey('AdborID__c') 
                && finalADBorIds.contains(finalrecord.get('AdborID__c'))){
                    finalRecords.add(finalrecord);
                    System.debug('finalRecords '+finalRecords);
                }
        }
                
        List<csord__Service__c> needToUpdate = new List<csord__Service__c>();

           for(Map<String,String> setOfValidInputs :finalRecords){
            String SubscriptionNumber2 = setOfValidInputs.get('Subscription_Number__c');
            String serviceMSISDN2 = setOfValidInputs.get('serviceMSISDN__c');
            String AdborID2 = setOfValidInputs.get('AdborID__c'); //18090
               
               //check AdborID__c exist for serviceMSISDN__c
              if( !existingService.containsKey(serviceMSISDN2) || !addresssfId.containsKey(AdborID2) ){ 
                system.debug('enter here');
                value = serviceMSISDN2;
                field = 'AdborID__c';
                message = 'AdborID__c is empty or invalid for serviceMSISDN__c '+serviceMSISDN2 ;
                this.checkAllConditions = false;
                this.errorList.add(addMessage(field,value,message));
                //resultMap.add(createResultMap('Failed', 'Validation failed', 'AdborID__c is empty or invalid for serviceMSISDN__c '+ serviceMSISDN2 , '422', 'AdborID__c'));
                
               }
               else if(existingService.containsKey(serviceMSISDN2) && AdborID2 != existingService.get(serviceMSISDN2).Delivery_Address__r.Address_ID__c){
                //update salesforce with current payload address for ServiceMSISDN
                System.debug('here in the last condition');
                existingService.get(serviceMSISDN2).Delivery_Address__c = addresssfId.get(AdborID2);
                needToUpdate.add(existingService.get(serviceMSISDN2));
                
               }
           }
            update needToUpdate;
      }
  
     /**
* Author: Rajiv Kumar Singh
* Des : This method is used to add messages
* EDGE-214319
* Date : 
*/
    public void checkServicesForSuspend(List<Object> serviceList,List<csord__Subscription__c> subscriptionList,List<csord__Service__c> serviceRecList){
        Map<String,List<csord__Subscription__c>> subscriptionMap = new Map<String,List<csord__Subscription__c>>();
        Map<String,List<csord__Service__c>> serviceMapNew = new Map<String,List<csord__Service__c>>();
        for(csord__Service__c service : serviceRecList){
            if(serviceMapNew.containskey(service.serviceMSISDN__c)){
                serviceMapNew.get(service.serviceMSISDN__c).add(service);
            }else{
                serviceMapNew.put(service.serviceMSISDN__c, new List<csord__Service__c>{service});
            }
        }

        for(csord__Subscription__c subs : subscriptionList){
            System.debug('subs11 ' + subs.csordtelcoa__Subscription_Number__c);
            if(subscriptionMap.containskey(subs.csordtelcoa__Subscription_Number__c)){
                subscriptionMap.get(subs.csordtelcoa__Subscription_Number__c).add(subs);
            }else{
                subscriptionMap.put(subs.csordtelcoa__Subscription_Number__c, new List<csord__Subscription__c>{subs});
            }
        }
        List<Object> serviceTempList = new List<Object>();
        List<csord__Subscription__c> subscriptionTempList = new List<csord__Subscription__c>();

        for(Object service : serviceList){
            Map<String,Object> tempServiceMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(service));
           /* if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('serviceMSISDN__c') && serviceMapNew.containskey(tempServiceMap.get('serviceMSISDN__c').toString()) &&  serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString()).size() > 0 && (serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString())[0].csord__Status__c != 'Active' && serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString())[0].csord__Status__c != 'Suspended')){
                this.checkAllConditions = false;
                system.debug('status '+serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString())[0].csord__Status__c);
                this.errorList.add(addMessage('csord__Status__c',serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString())[0].csord__Status__c,'Service needs to be active or suspended to raise a suspension request'));
            }else if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('serviceMSISDN__c') && serviceMapNew.containskey(tempServiceMap.get('serviceMSISDN__c').toString()) &&  serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString()).size() > 0){
                CheckForServiceMSISDN(serviceList,serviceRecList);
            }*/

            if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('Subscription_Number__c') &&
            subscriptionMap.containskey((String)tempServiceMap.get('Subscription_Number__c')) &&
            subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString()).size() > 0 && (subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString())[0].csord__Status__c != 'Active' && subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString())[0].csord__Status__c != 'Suspended')){
                this.checkAllConditions = false;
                system.debug('subc status '+subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString())[0].csord__Status__c);
                this.errorList.add(addMessage('csord__Status__c',subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString())[0].csord__Status__c,'Subscription needs to be active or suspended to raise a suspension request'));
            }
        }
        if(this.checkAllConditions){
            system.debug('isnide calling checkForSubscriptionNumber for checkServicesForResume');
            checkForSubscriptionNumber(serviceList,subscriptionList);
        }

    }
   
   
     public void checkServicesForResume(List<Object> serviceList,List<csord__Subscription__c> subscriptionList,List<csord__Service__c> serviceRecList){
        Map<String,List<csord__Subscription__c>> subscriptionMap = new Map<String,List<csord__Subscription__c>>();
        Map<String,List<csord__Service__c>> serviceMapNew = new Map<String,List<csord__Service__c>>();
        for(csord__Service__c service : serviceRecList){
            if(serviceMapNew.containskey(service.serviceMSISDN__c)){
                serviceMapNew.get(service.serviceMSISDN__c).add(service);
            }else{
                serviceMapNew.put(service.serviceMSISDN__c, new List<csord__Service__c>{service});
            }
        }

        for(csord__Subscription__c subs : subscriptionList){
            System.debug('subs11 ' + subs.csordtelcoa__Subscription_Number__c);
            if(subscriptionMap.containskey(subs.csordtelcoa__Subscription_Number__c)){
                subscriptionMap.get(subs.csordtelcoa__Subscription_Number__c).add(subs);
            }else{
                subscriptionMap.put(subs.csordtelcoa__Subscription_Number__c, new List<csord__Subscription__c>{subs});
            }
        }
        List<Object> serviceTempList = new List<Object>();
        List<csord__Subscription__c> subscriptionTempList = new List<csord__Subscription__c>();
        system.debug('inside checkServicesForResume');
        for(Object service : serviceList){
            system.debug('inside for loop checkServicesForResume');
            Map<String,Object> tempServiceMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(service));
           /* if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('serviceMSISDN__c') && serviceMapNew.containskey(tempServiceMap.get('serviceMSISDN__c').toString()) &&  serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString()).size() > 0 & serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString())[0].csord__Status__c != 'Suspended'){
                this.checkAllConditions = false;
                this.errorList.add(addMessage('csord__Status__c',serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString())[0].csord__Status__c,'Service needs to be suspended to raise a resume request'));
            }else if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('serviceMSISDN__c') && serviceMapNew.containskey(tempServiceMap.get('serviceMSISDN__c').toString()) &&  serviceMapNew.get(tempServiceMap.get('serviceMSISDN__c').toString()).size() > 0){
                CheckForServiceMSISDN(serviceList,serviceRecList);
            }*/
            //system.debug('susbsdci[tion check '+subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString())[0].csord__Status__c);
            if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('Subscription_Number__c') &&
            subscriptionMap.containskey((String)tempServiceMap.get('Subscription_Number__c')) &&
            subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString()).size() > 0 && subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString())[0].csord__Status__c != 'Suspended'){
                system.debug('inside if for checkServicesForResume');
                this.checkAllConditions = false;
                this.errorList.add(addMessage('csord__Status__c',subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString())[0].csord__Status__c,'Subscription needs to be suspended to raise a resume request'));
            }
        }
        if(this.checkAllConditions){
            system.debug('isnide calling checkForSubscriptionNumber for checkServicesForResume');
            checkForSubscriptionNumber(serviceList,subscriptionList);
        }
    }
   
    public void checkReasonOnServices(List<Object> serviceList,List<csord__Subscription__c> subscriptionList,String actiontype,List<csord__Service__c> serviceRecList){
        set<String> reasonSet = new set<String>();
        reasonSet.add('lostStolen');//Defect DIGI-13331 & DIGI-12937
       // reasonset.add('Lost or stolen - no service access - diversion only');
        for(Object service : serviceList){
            Map<String,Object> tempServiceMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(service));
            if(tempServiceMap != null && tempServiceMap.containskey('Reason__c') && !reasonSet.contains(String.valueof(tempServiceMap.get('Reason__c')))){
                system.debug('reason is '+String.valueof(tempServiceMap.get('Reason__c')));
                this.errorList.add(addMessage('Reason__c',String.valueof(tempServiceMap.get('Reason__c')),'Not a valid Service Reason'));
                this.checkAllConditions = false;
            }
        }
        system.debug('subscription list '+subscriptionList);
        system.debug('inside checkReasonOnServices');
        Map<String,csord__Subscription__c> subscriptionMap = new Map<String,csord__Subscription__c>();
        Map<String,List<csord__Service__c>> serviceMapNew = new Map<String,List<csord__Service__c>>();

        for(csord__Service__c service : serviceRecList){
            if(serviceMapNew.containskey(service.serviceMSISDN__c)){
                serviceMapNew.get(service.serviceMSISDN__c).add(service);
            }else{
                serviceMapNew.put(service.serviceMSISDN__c, new List<csord__Service__c>{service});
            }
        }
        system.debug('serviceMapNew in check reason '+serviceMapNew);
        for(csord__Subscription__c subs : subscriptionList){
                subscriptionMap.put(subs.csordtelcoa__Subscription_Number__c,subs);
        }
        system.debug('subscriptionMap in check reason '+subscriptionMap);
        for(Object service : serviceList){
            system.debug('inside service list for lopp');
            system.debug('action type is '+actiontype);
            Map<String,Object> tempServiceMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(service));
            if(subscriptionMap != null && subscriptionMap.containskey(tempServiceMap.get('Subscription_Number__c').toString()) && subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString()) != null){
                system.debug('temp serv '+subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString()).Suspension_reason_summary__c);
            }
            if(actiontype == 'Resume'){
                system.debug('inside resume check reason on services');
                system.debug('reason summary '+subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString()));
                if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('Subscription_Number__c') &&
                subscriptionMap.containskey((String)tempServiceMap.get('Subscription_Number__c')) && subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString()).Suspension_reason_summary__c != null && tempServiceMap.containskey('Reason__c') && tempServiceMap.get('Reason__c') != null){
                    String SuspensionReasonSummary = subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString()).Suspension_reason_summary__c;
                    if(! SuspensionReasonSummary.contains(String.valueOf(tempServiceMap.get('Reason__c')))){
                        this.checkAllConditions = false;
                        this.errorList.add(addMessage('Reason__c',String.valueOf(tempServiceMap.get('Reason__c')),'To Resume a subscription, reason needs to be one of the reasons provided during suspension.'));
                    }
                }
            }else if(actiontype == 'Suspend'){
                system.debug('inside Suspend check reason on services');
                if(!tempServiceMap.isEmpty() && tempServiceMap!=null && tempServiceMap.containskey('Subscription_Number__c') &&
                subscriptionMap.containskey((String)tempServiceMap.get('Subscription_Number__c')) &&
                subscriptionMap.containskey(tempServiceMap.get('Subscription_Number__c').toString()) && subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString()).Suspension_reason__c != null && tempServiceMap.containskey('Reason__c') && tempServiceMap.get('Reason__c') != null && subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString()).csord__Status__c == 'Suspended'){
                    String SuspensionReasonSummary = subscriptionMap.get(tempServiceMap.get('Subscription_Number__c').toString()).Suspension_reason__c;
                    if(SuspensionReasonSummary == String.valueOf(tempServiceMap.get('Reason__c'))){
                        this.checkAllConditions = false;
                        this.errorList.add(addMessage('Reason__c',String.valueOf(tempServiceMap.get('Reason__c')),'Suspension request cannot be made with the same reason on already suspended subscription'));
                    }
                }
            }
        }
    }
    //DIGI-577 By Rajiv-Start
    public Map<String,String> validateTONData(Map<String,String> inputMap){
        Map<String,String> responseMap = new Map<String,String>();
        
        String value = '';
        String field = '';
        String message = '';
        String Code = '';
        String Status = '';
        String description = '';
        system.debug('inside ton data');
        Account acc = new Account();
        csord__Subscription__c subscription = new csord__Subscription__c();
        system.debug('inputMap '+inputMap);
        if(!inputMap.isEmpty() && inputMap.containsKey('CorrelationId__c')){
            Map<String,Object> tempService = new Map<string,Object>();
            if(inputMap.get('CorrelationId__c') == '' || inputMap.get('CorrelationId__c') == null){
                system.debug('CorrelationId__c is null');
                this.checkAllConditions = false;
                this.errorInCorrelation = true;
                this.errorList.add(addMessage('CorrelationId__c ',inputMap.get('CorrelationId__c'),'CorrelationId__c is empty or already exists'));
            }
            else{
                system.debug('corlation not null');
                if(!inputMap.isEmpty() && inputMap.containsKey('services')){
                    List<Object> serviceList = (List<Object>)JSON.deserializeUntyped(inputMap.get('services'));
                    tempService = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(serviceList[0]));
                    system.debug('tempService '+tempService.get('serviceMSISDN__c'));
                    List<csord__Service__c > serviceRecList = [SELECT Id,csord__Subscription__r.csordtelcoa__Subscription_Number__c,serviceMSISDN__c,csord__Subscription__c,csord__Subscription__r.csord__Status__c,csord__Status__c,csord__Subscription__r.csord__Account__c,csord__Subscription__r.csord__Account__r.Customer_Status__c,csord__Subscription__r.TON_Barring_Status__c FROM csord__Service__c WHERE serviceMSISDN__c=:string.valueOf(tempService.get('serviceMSISDN__c'))  ORDER BY CreatedDate DESC LIMIT 1];
                    system.debug('serviceRecList ton data'+serviceRecList.size());
                    if(serviceRecList.size() == 0 || string.valueOf(tempService.get('serviceMSISDN__c')) == '' || string.valueOf(tempService.get('serviceMSISDN__c')) == null){
                        this.checkAllConditions = false;
                        this.errorList.add(addMessage('serviceMSISDN__c ',string.valueOf(tempService.get('serviceMSISDN__c')),'serviceMSISDN__c is empty or inactive'));
                    }else{
                        inputMap.put('serviceMSISDN__c',String.valueOf(tempService.get('serviceMSISDN__c')));
                    }
                   

                    if(serviceRecList != null && serviceRecList.size() > 0 &&serviceRecList[0].csord__Subscription__r.csord__Status__c != 'Active'){
                        this.checkAllConditions = false;
                        this.errorList.add(addMessage('serviceMSISDN__c ',string.valueOf(tempService.get('serviceMSISDN__c')),'Subscription associated with the serviceMSISDN__c is inactive'));
                    }
                    
                    system.debug('inside check all cofition'+ this.checkAllConditions);
                    
                    if(this.checkAllConditions){
                        
                        if(!(serviceRecList != null && serviceRecList.size() > 0 && serviceRecList[0].csord__Subscription__r.csord__Account__r.Customer_Status__c == 'ACTIVE' || serviceRecList[0].csord__Subscription__r.csord__Account__r.Customer_Status__c == 'ACQUIRED')){
                            this.checkAllConditions = false;
                            this.errorList.add(addMessage('serviceMSISDN__c',string.valueOf(tempService.get('serviceMSISDN__c')),'Account associated with the serviceMSISDN__c is inactive'));
                        }
                        system.debug('inputMap.get Reason__c '+inputMap.get('Reason__c'));
                        if(inputMap.containskey('Reason__c') && inputMap.get('Reason__c') == 'TON Connect' && serviceRecList != null && serviceRecList.size() > 0){
                            system.debug('inisde reason check '+serviceRecList[0].csord__Subscription__r.TON_Barring_Status__c);
                            if( serviceRecList[0].csord__Subscription__r.TON_Barring_Status__c == 'Unbarred'){
                                
                                validateParallelMACDProcessing(serviceRecList[0].csord__Subscription__r.TON_Barring_Status__c);
                            }else{
                                this.checkAllConditions = false;
                                this.errorList.add(addMessage('Reason__c',serviceRecList[0].csord__Subscription__r.TON_Barring_Status__c,'TON_Barring_Status__c is invalid'));
                            }
                        }
                    }
                    if(checkAllConditions){
                        validateSecondaryMSISDN(tempService,inputMap.get('CorrelationId__c'));
                    }        
                }
            
            }
        }
        
        
        if(this.checkAllConditions){
            system.debug('inside all true');
            Code = '200';
            Status = 'Success';
            description = 'Validation successful for all the services';    
            responseMap = finalMessage(status,description,code);
            responseMap.put('AccountId__c',acc.ID);
            responseMap.put('Service MSIDN',inputMap.get('serviceMSISDN__c'));
            responseMap.put('CorrelationId__c',inputMap.get('CorrelationId__c'));
            responseMap.put('Subscription Number',subscription.csordtelcoa__Subscription_Number__c);
            responseMap.put('status',Status);
            responseMap.put('code',Code);
            responseMap.put('validateData','Success');
            responseMap.put('ActionType__c',inputMap.get('ActionType__c'));//Added newly
            system.debug('last response map '+responseMap);
            OC_SessionPayloadValidation.createSession(inputMap.get('CorrelationId__c'), 'validateTONData', this);
            OC_SessionPayloadValidation.addSessionData(inputMap.get('CorrelationId__c'), 'validateData', responseMap);
        }else{
            if(this.errorInCorrelation){
                Code = '400';
            }else{
                Code = '422';
            }
            Status = 'Failed';
            description = 'Validation failed';
            responseMap = finalMessage(Status,description,code);
            responseMap.put('errors',JSON.serialize(errorList));
        }
        
        system.debug('responseMap '+responseMap);
        return responseMap;
    }
   
    public void validateSecondaryMSISDN(Map<String,Object> tempService,String correlationId){
        Map<String,String> responseMap = new Map<String,String>();
        Boolean validateCondition = true;
        String secondaryMSISDN = '';
        String Code= '';
        String Status = '';
        String description = 'Validation successful for all the services';
         if(string.valueOf(tempService.get('secondaryMSISDN__c')) == '' || string.valueOf(tempService.get('secondaryMSISDN__c')) == null){
               this.checkAllConditions = false;
               this.errorList.add(addMessage('secondaryMSISDN__c ',string.valueOf(tempService.get('secondaryMSISDN__c')),'secondaryMSISDN__c is empty or inactive'));
         }else{
             secondaryMSISDN = String.valueOf(tempService.get('secondaryMSISDN__c'));
             List<Number__c> numberList = [SELECT id,Status__c FROM Number__c WHERE Service_Number__c =:secondaryMSISDN ];             
             if(numberList.size() == 0){
           validateCondition = true;
             }else if (numberList[0].Status__c == 'Inactive'){
             validateCondition = true;
             }
             else{
               this.checkAllConditions = false;
               this.errorList.add(addMessage('Status__c ',string.valueOf(numberList[0].Status__c),'Status__c is not Inactive'));      
             }            
            }                                         
         if(validateCondition && this.checkAllConditions){

            Map<String,String> msidnMap = new Map<String,String>();
            msidnMap.put('serviceMSDIDN',string.valueOf(tempService.get('serviceMSISDN__c')));
            msidnMap.put('secondayMSDIDN',secondaryMSISDN);
            responseMap.put('SecondaryMSDN',secondaryMSISDN);
            OC_SessionPayloadValidation.createSession(correlationId, 'validateTONData', this);
            OC_SessionPayloadValidation.addSessionData(correlationId, 'validateData', responseMap);
            
          }
    }
   
    public void validateParallelMACDProcessing(String solutionId){
        Map<String,String> responseMap = new Map<String,String>();
       try{
        if(solutionId != null && solutionId != ''){
           List<csord__Solution__c> solutionList = [SELECT Id FROM csord__Solution__c WHERE cssdm__replaced_solution__c=:solutionId and cssdm__product_basket__c != null and cssdm__product_basket__r.cscfga__Basket_Status__c != 'cancelled'];
            if(solutionList.size() > 0){

                    this.errorList.add(addMessage('Reason__c','Reason__c','A MACD is already in progress. Please try after some time'));
                    this.checkAllConditions = false;
            }
        }
       }catch(Exception e){
 
       }
    }
}