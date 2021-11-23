/**
* 
* @author   Bharath Kanagaraj
* @version  1.0
* @since    29/04/2021 
* Description : Partner of Record Domain object's trigger handler based on Kevin O'Hara's trigger framework
*/

public with sharing class PORDomainTriggerHandler extends SYS_TriggerHandler {

    @TestVisible Map<Id,SObject> oldPORDomainMap = Trigger.oldMap;
    @TestVisible Map<Id,SObject> newPORDomainMap = Trigger.newMap;
    @TestVisible List<sObject> newPORDomains = Trigger.new;
    @TestVisible List<sObject> oldPORDomains = Trigger.old;

    @TestVisible final String STATUS_ACTIVE = 'Active';
    @TestVisible final String STATUS_CANCELLED = 'Cancelled';

    public PORDomainTriggerHandler(Schema.SObjectType sobjectType) {
        super(String.valueOf(sObjectType));
    }
    /*----------------------------------------------
    *Method typically invoked from a trigger context
    * @object : Partner_of_Record_Domain__c
    * @event : After Update
    ----------------------------------------------*/ 
    public override void afterUpdate() {
        Map<Id,List<Partner_of_Record_Domain__c>> PORToDomainsMap = new Map<Id,List<Partner_of_Record_Domain__c>>();
        Map<Id,Partner_of_Record__c> porUpdateRecordMap = new Map<Id,Partner_of_Record__c>();
        List<String> porDomainList;
        Set<Id> porRecordIds = new Set<Id>();
        List<String> existingPORDomainList = new List<String>();

        
        set<Id> porIdList = new  set<Id>();
        for(Partner_of_Record_Domain__c porDomain : [Select Id,Partner_of_Record__c FROM Partner_of_Record_Domain__c WHERE ID IN :newPORDomains 
                                                     AND (status__c ='Active' or status__c ='Cancelled')]){
            porIdList.add(porDomain.Partner_of_Record__c);
        }
        
        List<Partner_of_Record_Domain__c> porNewList = [Select Id,Domain_Name__c,Status__c,Sub_Status__c,Partner_of_Record__c,Partner_of_Record__r.TLS_ProductDomain__c,
                                                        Partner_of_Record__r.Status__c,Partner_of_Record__r.Sub_Status__c 
                                                        FROM Partner_of_Record_Domain__c WHERE Partner_of_Record__c IN :porIdList];

        for(Partner_of_Record_Domain__c porDomain : porNewList){
            if(PORToDomainsMap.containsKey(porDomain.Partner_of_Record__c)){
                PORToDomainsMap.get(porDomain.Partner_of_Record__c).add(porDomain);
            }else{
                PORToDomainsMap.put(porDomain.Partner_of_Record__c,new List<Partner_of_Record_Domain__c>{PORDomain});
            }
        }
        

        
        for(Id porRecordId : PORToDomainsMap.keyset()){
            porDomainList = new List<String>();
            for(Partner_of_Record_Domain__c domainRecord : PORToDomainsMap.get(porRecordId)){
                /*if(domainRecord.Status__c.equalsIgnoreCase(STATUS_ACTIVE) && String.isBlank(domainRecord.Partner_of_Record__r.TLS_ProductDomain__c)){

                    porDomainList.add(domainRecord.Domain_Name__c);
                }else if(domainRecord.Status__c.equalsIgnoreCase(STATUS_ACTIVE) && !String.isBlank(domainRecord.Partner_of_Record__r.TLS_ProductDomain__c)){
                    porDomainList = domainRecord.Partner_of_Record__r.TLS_ProductDomain__c.split(';');
                    if(!porDomainList.contains(domainRecord.Domain_Name__c)){
                        porDomainList.add(domainRecord.Domain_Name__c);
                    }
                }else if(!domainRecord.Status__c.equalsIgnoreCase(STATUS_ACTIVE) && !String.isBlank(domainRecord.Partner_of_Record__r.TLS_ProductDomain__c)){
                    porDomainList = domainRecord.Partner_of_Record__r.TLS_ProductDomain__c.split(';');
                    if(porDomainList.contains(domainRecord.Domain_Name__c)){
                        Integer elementIndex = porDomainList.indexOf(domainRecord.Domain_Name__c);
                        porDomainList.remove(elementIndex);
                    }

                }*/
                if(domainRecord.Status__c.equalsIgnoreCase(STATUS_ACTIVE)){
                    porDomainList.add(domainRecord.Domain_Name__c);
                }
            }
            if( !Approval.isLocked(porRecordId)){
                if(!porDomainList.isEmpty())
                porUpdateRecordMap.put(porRecordId,new Partner_of_Record__c(Id=porRecordId,TLS_ProductDomain__c=String.join(porDomainList,',')));
                else
                    porUpdateRecordMap.put(porRecordId,new Partner_of_Record__c(Id=porRecordId,TLS_ProductDomain__c=null));

            }
        }
        if(!porUpdateRecordMap.isEmpty()){
            update porUpdateRecordMap.values();
        }
    }
}