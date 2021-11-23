/*-------------------------------------------------------- 
EDGE-80751
Mehod: onBeforeInsert
Description: Handler for Trigger MSISDNAccountDuplicate
Author:Ila
--------------------------------------------------------*/
public with sharing class MSISDNAccountDuplicateHandler {
    
    public Static String PORTINSQ = 'Port in SQ';
    
    public static void onBeforeInsert(List<Service_Qualification__c> sqListNew){
        
        List<Service_Qualification__c> sQualList = new List<Service_Qualification__c>();
    Set<String> setName = new Set<String>();
	
    List<Service_Qualification__c> sqListUnique = [SELECT Id,Service_Number__c,UniqueBasketMSISDN__c,Account__c FROM Service_Qualification__c WHERE UniqueBasketMSISDN__c!=null AND SQ_Type__c=: PORTINSQ];
    system.debug('sqListUnique*' +sqListUnique);
    for(Service_Qualification__c sqUnique: sqListUnique){
        setName.add(sqUnique.UniqueBasketMSISDN__c);
        system.debug('setName+' +setName);
    }
    
    for(Service_Qualification__c sq: sqListNew){
        if(sq.SQ_Type__c== PORTINSQ){
        if(sq.UniqueBasketMSISDN__c==null)
  		sq.UniqueBasketMSISDN__c=sq.Service_Number__c + sq.Account__c;
        system.debug('sq.UniqueBasketMSISDN__c+' +sq.UniqueBasketMSISDN__c);
        
        if(setName.contains(sq.UniqueBasketMSISDN__c)){
            system.debug('inside error');
        sq.addError('Duplicate numbers found. Please remove the duplicates and try it again.');
        }
        else{
            setName.add(sq.UniqueBasketMSISDN__c);
        	}
    	}
    }
    
    }
}