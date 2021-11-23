/* 
 * Attachment_TriggerHandler hendler class 
 * Help AttachmentTriggerHandler to create and delete PDFs
 * 
 * @story : EDGE-49995
 * @author : Abinash Barik
 */
public class Attachment_TriggerHandler implements ITrigger {
    
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore() {
    }
        
    
    /**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkAfter() {
        system.debug('inside bulkAfter>>>>>');
        if (Trigger.isInsert) {
            AttachmentTriggerHelper.cleanUpAttachments(Trigger.new);
        }
    }
    
    /**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
    public void beforeInsert(SObject so) {
    }
    
    /**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     */
    public void beforeUpdate(SObject oldSo, SObject so) {
    
    }
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    //void beforeUpdateList(List<SObject> oldSo, List<SObject>so);
    public void beforeDelete(SObject so) {
    
    }
 
    /**
     * afterInsert
     *
     * This method is called iteratively for each record inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point.
     */
    public void afterInsert(SObject so) {
    	AttachmentTriggerHelper.setStatusToSuccessAndPublishEvent(Trigger.New);
        Map<Id, Attachment> newInsertAttachmentsMap = new Map<Id, Attachment>();
        for (Attachment iterator : (List<Attachment>) Trigger.New) {
            System.debug('sendAttachmentPlatformEvent found iterator ---> ' + iterator + '  iterator ' + iterator.Parent.Type);
            if(iterator.Name == 'ServiceSpecifications.json'){
                newInsertAttachmentsMap.put(iterator.id , iterator);
            }
        }
        if(!newInsertAttachmentsMap.isEmpty()){
            //AttachmentTriggerHelper.createSubscriptionPlatformEvent(newInsertAttachmentsMap);
        }    }
 
    /**
     * afterUpdate
     *
     * This method is called iteratively for each record updated during an AFTER
     * trigger.
     */
    public void afterUpdate(SObject oldSo, SObject so) {
        AttachmentTriggerHelper.onTRAMASAttachmentsUpdate(Trigger.newMap,Trigger.oldMap);
        Map<Id, Attachment> newInsertAttachmentsMap = new Map<Id, Attachment>();
        Map<Id, Attachment> oldInsertAttachmentsMap = new Map<Id, Attachment>();
        if(!Trigger.oldMap.isEmpty()){
            oldInsertAttachmentsMap.putAll((List<Attachment>) Trigger.New);
        }
        for (Attachment iterator : (List<Attachment>) Trigger.New) {
            if(iterator.Parent.Type == 'csord__Service__c'){
                if(!oldInsertAttachmentsMap.isEmpty() && iterator.Name == 'ServiceSpecifications.json' && iterator.LastModifiedDate != oldInsertAttachmentsMap.get(iterator.id).LastModifiedDate){
                    newInsertAttachmentsMap.put(iterator.id , iterator);
                }
            }
        }
        System.debug('sendAttachmentPlatformEvent found newInsertAttachmentsMap ---> ' + newInsertAttachmentsMap);
        if(!newInsertAttachmentsMap.isEmpty()){
            //AttachmentTriggerHelper.createSubscriptionPlatformEvent(newInsertAttachmentsMap);
        }
    }
 
    /**
     * afterDelete
     *
     * This method is called iteratively for each record deleted during an AFTER
     * trigger.
     */
    public void afterDelete(SObject so) {
    
    }

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally() {
        if (Trigger.isUpdate && Trigger.isAfter) {//Trigger.isAfter added in condition as part of EDGE - 90967
            //AttachmentTriggerHelper.onTRAMASAttachmentsUpdate(Trigger.newMap,Trigger.oldMap); //EDGE-90967 moved from afterUpdate
                system.debug('Trigger.newMap@@@@' + Trigger.newMap);
                system.debug('Trigger.oldMap@@@@' + Trigger.oldMap);
                AttachmentTriggerHelper.onCallbackTRAMASAttachmentsUpdate(Trigger.newMap,Trigger.oldMap); //EDGE-94797
                
            
            
        }
    }
}