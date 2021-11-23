/*************************************************************************************************
Name : getAttributesFromSpecsbatch
Test Class  : getAttributesFromSpecsbatchTest
Ch no 
1.  18/09/2020      Shubhi Vijayvergia   EDGE-157149 (new )
**************************************************************************************************/

global class getAttributesFromSpecsbatch implements Database.batchable<Sobject>,Database.Stateful {

    public Integer count =0;
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {           
        String portforlioCode='UAT01';
        String status='RETIRED';
        String query = 'Select id,csord__Subscription__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c FROM csord__Service__c where csord__Subscription__c IN (Select id from csord__Subscription__c where Billing_Account__r.Account__r.Portfolio_Code__c!= :portforlioCode AND Billing_Account__r.Account__r.Customer_Status__c !=:status AND csordtelcoa__Product_Configuration__c!=null) order by createdDate DESC';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<csord__Service__c> scope)
    {   
        Map<Id,String> serviceIdmap=new Map<Id,String>();
        
        for(csord__Service__c serv:scope){
            serviceIdmap.put(serv.id,serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c);
        }
        String csv = '';
        //fetching attachment body and modifying it based on service map 
        if(serviceIdmap!=null && serviceIdmap.size()>0){
            String serviceid='';
            try{
                for(Attachment att:[select ID, name, body, parentId from Attachment where parentId in: serviceIdmap.keyset() and name = 'ServiceSpecifications.json']){
                    String newServiceAttachmentStr = att.body.toString();
                    serviceid=att.parentId;
                    if(newServiceAttachmentStr!=null && newServiceAttachmentStr!=''){
                        Map<String, Object> updatedResults = (Map<String, Object>)JSON.deserializeUntyped(newServiceAttachmentStr);
                        List<Object>lstSpecifications=(List<Object>)updatedResults.get('specifications');
                        List<Object> newlstSpecifications = new List<Object>();
                        for(Object spec:lstSpecifications){
                            Map<String, Object> specificationAttributes = (Map<String, Object>)spec;
                            
                            if(specificationAttributes!=null && specificationAttributes.containsKey('code') && String.valueof(specificationAttributes.get('code')).contains('Billing'))
                            {
                                system.debug('inside if--> :'); 
                                count++;
                                Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('attributes');
                                csv+=serviceIdmap.get(att.parentId)+'#';
                                csv+=att.parentId+'#';
                                if(specificationAttributes.containskey('code')){
                                    csv +=specificationAttributes.get('code')+'#';
                                }else{
                                     csv +='NoCode#';
                                }
                                if(specificationAttributes.containskey('guid')){
                                    csv +=specificationAttributes.get('guid')+'#';
                                }else{
                                     csv +='NoGuid#';
                                }
                                if(attributesMap!=null && attributesMap.containsKey('billingSpecId')){
                                    csv +=attributesMap.get('billingSpecId')+'#';
                                }else{
                                     csv +='NoSpecId#';
                                }
                                if(attributesMap!=null && attributesMap.containsKey('chargeId')){
                                    csv +=attributesMap.get('chargeId')+'#';
                                }else{
                                    csv +='NoChargeID#';
                                }
                                if(attributesMap!=null && attributesMap.containsKey('externalId')){
                                    csv +=attributesMap.get('externalId')+'**';
                                }else{
                                     csv +='NoextID**';
                                }                 
                            }   
                        }
                    }
                }
                Logger2 logger2 = Logger2.getLogger(getAttributesFromSpecsbatch.class);
                logger2.logMessages(String.valueof(count), csv, '', '', '', '',  true,  false);
                logger2.exitLogger(); 
            }catch(Exception e){
                Logger2 logger2 = Logger2.getLogger(getAttributesFromSpecsbatch.class);
                logger2.logMessages(String.valueof(e), serviceid, '', '', '', '',  true,  false);
                logger2.exitLogger(); 
            }
        }
    }  
    global void finish(Database.BatchableContext BC) {
      
    }
}