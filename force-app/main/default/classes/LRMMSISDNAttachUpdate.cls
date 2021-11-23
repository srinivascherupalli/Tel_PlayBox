/*
Class Name : LRMMSISDNAttachUpdate
Description: To update the attachment in withoutsharing mode.
===============================================================================================================================
Change.No.    Developer Name   Date          Story Description
1.          Bhargava           25/11/2020   EDGE-179268 : PRM Action Types change of mobile number.

*/

public without sharing class LRMMSISDNAttachUpdate {
    
    public static Map<String,Attachment> AttMapTobeUpdated = new Map <String,Attachment>(); 
    public static Map<Id,Attachment> AttMapTobeUpdateId = new Map <Id,Attachment>(); 
    
     public static void MISDANAttachUpdate(Map<String,Attachment> AttMapTobeUpdated){
         system.debug('AttMapTobeUpdated LRMMSISDNAttachUpdate>>>>>>'+AttMapTobeUpdated);
         system.debug('AttMapTobeUpdated LRMMSISDNAttachUpdate>>>>>>'+AttMapTobeUpdated.values());
        update AttMapTobeUpdated.values();
     }
     public static void MISDANAttachUpdateId(Map<Id,Attachment> AttMapTobeUpdateId ){
         system.debug('AttMapTobeUpdated LRMMSISDNAttachUpdate>>>>>>'+AttMapTobeUpdateId );
          system.debug('AttMapTobeUpdated LRMMSISDNAttachUpdate>>>>>>'+AttMapTobeUpdateId.values());
        update AttMapTobeUpdateId.values();
     }



}