Public Class OrchestrationUtils{
    
    Public static void init(){
        
        //Coms_CorrelationIdGeneration.updateCorrelationIdOnOrderSubscriptionAndServices('a4b2N000000jjSK');
		Map<Id, Attachment> Attachments = New Map<Id, Attachment> ();         
        for (Attachment newAtt : [
                SELECT ID, name, body, parentId
                FROM Attachment
                WHERE  id = '00P2N000004ActB']) {
                    
                Attachments.put(newAtt.Id,newAtt);
                 
            } 
        
        
         System.debug(' ==>  ' + Attachments);
        
        
      // AttachmentTriggerHelper.createSubscriptionPlatformEvent(Attachments);
       
    }
    
    // GLOBAL VARIABLES
    Public Static Map<String, TechnicalObjectFieldMapping__mdt> metaData = TechnicalObjectFieldMapping__mdt.getAll();
	Public Static Set<String> specficationKeys = New Set<String>();

    Public Static List<Object> getAttachDeserialzied(Map<Id, Orchestration_AttachmentWrapper> attchmap, String parentId){
        
        if ( attchmap <> NULL && parentId <> NULL ){
        
            String bodyString = attchmap.get(parentId).attchBody.toString();
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(bodyString);
            List<Object> jsonSpecifications = (List<Object>) results.get(OrchestratorConstants.ServiceSpecificationKey.Specifications);
            
            return jsonSpecifications;
            
        } else {
            return null;
        }
    }
    
    
    
    
    Public Static void createServiceSpecObj(csord__Service__c srv, List<Object> jsonSpecifications){
        // LOCAL VARIABLES
        Map<String,String> fielpMapping = New Map<String,String>(getFieldMapping());
        
        Orchestration_Technical__c techObj = New Orchestration_Technical__c();
        String EDMSpecToSuppressInRTB = srv.csordtelcoa__Product_Configuration__c != NULL && srv.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c != NULL && srv.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.EDMSpecToSuppressInRTB__c != NULL ? srv.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.EDMSpecToSuppressInRTB__c:'';
		
        specficationKeys.add(OrchestratorConstants.ServiceSpecificationKey.Guid);
        specficationKeys.add(OrchestratorConstants.ServiceSpecificationKey.Name);
        
        sObject sObj = Schema.getGlobalDescribe().get('Orchestration_Technical__c').newSObject() ;
        
        for (Object specification : jsonSpecifications) {
            
            Map<String, Object> specificationAttributes = (Map<String, Object>) specification;
            
            for ( String jsonkey :fielpMapping.keyset()){
                if( specficationKeys.contains(jsonkey) ) {
                    String jsonKeyValue = (String) specificationAttributes.get(jsonkey);
                	sObj.put(fielpMapping.get(jsonkey), jsonKeyValue );
                }
            } //INNER FOR ENDS
        }//FOR ENDS
        
        sObj.put('Service__c', srv.Id);
        sObj.put(fielpMapping.get('EDMSpecToSuppressInRTB'), EDMSpecToSuppressInRTB);
		
        //System.debug(' sObj ==> ' + sObj );
        insert sObj;
    }
    
    
    
    Public static Map<String,String> getFieldMapping(){
        Map<String,String> tmpfielpMapping = New Map<String,String>();
        
        for ( String a :metaData.keyset() ){
            tmpfielpMapping.put(a, metaData.get(a).Object_Field_Name__c);
        }
        System.debug('tmpfielpMapping ==> ' + tmpfielpMapping );
        return tmpfielpMapping;
    }

}