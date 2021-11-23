/* ****************************************************************************
* Class Name    : UpdateMobileNoInSubscriptionExt 
* Author        : Vitap Ramdevputra : DPG-2396
* Date          : 14 Aug 2020
* Description   : Update Mobile number from additional attribute.
* TestClass     : UpdateMobileNoInSubscriptionExtTest

* Updates       : removed constructor for VF page, and webservice method which was used from JS button.
* *****************************************************************************/
global without sharing class UpdateMobileNoInSubscriptionExt {
    global static string finalMessage {get;set;}
    webservice static string updateMobileNumber(List<string> listOfSubscriptionId){

        try{
            system.debug('list of subscriptions : ' + listOfSubscriptionId);
            Profile userProfile = [select name from profile where id = :UserInfo.getProfileId() limit 1];
            if(userProfile.Name != 'System Administrator' && userProfile.Name != 'Developer Support'){
                finalMessage = 'Permission denied.';
                return finalMessage;                
            } 
            String subscriptionId = '';
            system.debug('SubscriptionId = ' + SubscriptionId);


            List<string> IoTSubscriptionName = new list<string>{'IOT Subscription'};
            List<csord__Subscription__c> currentSubscriptions = [Select id, serviceMSISDN__c,Name,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name from csord__Subscription__c where id in :listOfSubscriptionId and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name in :IoTSubscriptionName];
            //system.debug('current sups: = ' + currentSubscriptions);
            Map<Id, csord__Service__c> serviceMap = new Map<id,csord__Service__c>([Select id,serviceMSISDN__c,csord__Subscription__c,csord__Subscription__r.serviceMSISDN__c from csord__Service__c where csord__Subscription__c in :listOfSubscriptionId]);


            if(currentSubscriptions.isEmpty() || serviceMap.isEmpty()){
                finalMessage = 'This functionality works only for updating mobile number for IoT subscriptions. IoT Subscription or IoT service was not found.';
                return finalMessage ;
            }

            Map<Id, String> serviceIdMobileNoMap = new map<Id, string>();

            List<csord__Service__c> updateServiceList = new list<csord__Service__c>();
            for(csord__Service__c serviceItem: serviceMap.Values()){
                if(serviceItem.serviceMSISDN__c  != serviceItem.csord__Subscription__r.serviceMSISDN__c ){
                    serviceItem.serviceMSISDN__c = serviceItem.csord__Subscription__r.serviceMSISDN__c;
                    updateServiceList.add(serviceItem);
                }
                serviceIdMobileNoMap.put(serviceItem.id,serviceItem.csord__Subscription__r.serviceMSISDN__c);
            }

            if(!updateServiceList.isEmpty()) update updateServiceList;

            string message = '';
            List<Attachment> atts = [select Id, Name, body, parentId FROM Attachment WHERE parentId IN : serviceMap.KeySet()];
            List<Attachment> updateAttachments = new List<attachment>();
            List<id> listServiceMessageId = new list<id>();
            for(Attachment att: atts){
                String attbody = String.valueOf(att.body.toString());
                List<Script_AttributeSpecsMSDIN.ServiceScriptSpecification> specs = Script_AttributeSpecsMSDIN.parseSpec(attbody);


                for(Script_AttributeSpecsMSDIN.ServiceScriptSpecification spec: specs){
                    Map<String, String> updateAttribute = new Map<String, String>();
                    system.debug('spec.additionalAttributes -- : ' + spec.additionalAttributes);
                    system.debug('spec.additionalAttributes.CustomerFacingServiceId -- : ' + spec.additionalAttributes.CustomerFacingServiceId);

                    updateAttribute.put('CustomerFacingServiceId', serviceIdMobileNoMap.get(att.ParentId));
                    //updateAttribute.put('CustomerFacingServiceId', currentSubscription.serviceMSISDN__c);

                    if(spec.additionalAttributes != null   && !String.isBlank(spec.additionalAttributes.CustomerFacingServiceId)) {
                        System.debug('spec.serviceId, spec.guid::'+spec.serviceId + ' --- '+spec.guid+'--'+updateAttribute);
                        csedm.API_1.updateCharacteristic(spec.serviceId, spec.guid, updateAttribute);
                         if(!listServiceMessageId.contains(att.ParentId)){
                             message += 'Attachment updated for serviceId: ' + att.ParentId + '-- updated CustomerFacingServiceId: ' + serviceIdMobileNoMap.get(att.ParentId);
                             listServiceMessageId.add(att.ParentId);
                         }


                    }
                }
            }
            if(message == '') message = 'Attachment not updated.';
            finalMessage = 'Mobile number updated successfully in Service.  ' + message;
        } Catch(Exception ex){
            finalMessage = 'Error: ' + ex.getMessage();
        }
        return finalMessage;
    }


}