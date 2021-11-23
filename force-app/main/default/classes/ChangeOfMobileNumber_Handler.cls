/**================================================================
 * Name: ChangeOfMobileNumber_Handler
 * Description: Class for change of mobile number order callout and updates
 Prajakta       13/01/2021       EDGE-194241
============================================================================*/

public with sharing class ChangeOfMobileNumber_Handler{
   
    public String scenarioType;
    public static Map<String,Attachment> AttMapTobeUpdated = new Map <String,Attachment>(); 
    public static Map<String, Attachment> servAttachmentRecordMap = new Map<String, Attachment>();
    public static Map<Id,String> serviceAttachmentMap = new Map<Id,String>();
    public static Map<String, csord__Service__c> serviceIdMap = new Map<String,csord__Service__c>();   
    
    public static String MSISDNReserveServices(String scenarioType, List<String> subId)
    {
        String result;
		
        List <csord__Service__c> serviceList = new List <csord__Service__c> ();
        Map<String,Map<String,String>> guidAddAttrMap = new Map<String,Map<String,String>>();
        Map<String,String> addAttrMap = new Map<String,String>();
        Map<String,Map<String,String>> AttrMap = new Map<String,Map<String,String>>();
        Map<String,FNNDTO> serviceIDFNNDTOMap = new Map<String,FNNDTO>();
        Boolean MSISDNHeld = null;
        FNNService fnnSer = new FNNService();
        FNNResponseDTO fnnRest = new FNNResponseDTO();
        List<FNNDTO> fnnDTOList = new List<FNNDTO>();
        List<csord__Order__c> ordList = new List<csord__Order__c>();
		  FNNSearchResponseDTO fnnResponse = new FNNSearchResponseDTO();
		  List<String>resourceIds = new List<String>();
        try
        { 
            system.debug('Entering MSISDNReserveServices');
    			FNNSearchRequestDTO fnnDto = new FNNSearchRequestDTO();
                FNNSearchRequestDTO.data fdo=new FNNSearchRequestDTO.data();
                fdo.quantity = subId.size();
                fdo.resourceType = 'Mobile';
                fdo.activityName = 'Reserve Next Available';
                fnnDto.data = fdo;
                system.debug('fnnDto>>>>>>>>'+fnnDto);
                fnnResponse = NumberReservationFixedHandler.searchFNN(fnnDto);
                 system.debug('fnnResponse>>>>>>>>'+fnnResponse);
				 
				  if(fnnResponse.status == 200 || fnnResponse.status == 201 || fnnResponse.status == 202){
                    if(fnnResponse != NULL && fnnResponse.data != NULL && fnnResponse.data.resources != NULL){
                        for(FNNSearchResponseDTO.Resources res : fnnResponse.data.resources){
                            resourceIds.add(res.resourceId);
							
                           
                        }
                        
                        result= updateServiceSub(subId,resourceIds);
                    }
                   					   
                }else{
                    return 'ERROR';
                    
                  
                } 
				
				return result;
             
        }
        catch(Exception e){
           
            return 'ERROR';
        }
    }
    
    public static String updateServiceSub(List<String> subId,List<String>resourceIds){	
        
        try {
			
			Integer i =0;
			String result1;
             Map<String, List<csord__Service__c>> subserviceMap = new Map<String, List<csord__Service__c>>();
				List<csord__Subscription__c> updatedsub = new List<csord__Subscription__c>();
				List<csord__Service__c> updatedservice = new List<csord__Service__c>();
				Map<String, String> servicewithNumber = new Map<String,String>();  
				
			for(csord__Subscription__c sub :[select id,name,serviceMSISDN__c,oldServiceMSISDN__c,(select id,name,serviceMSISDN__c,csord__Subscription__c from csord__services__r) from csord__Subscription__c where id IN:subId]){
               system.debug('inside for:');
                if(i<resourceIds.size()){
				sub.oldServiceMSISDN__c = sub.serviceMSISDN__c;
				sub.serviceMSISDN__c= resourceIds.get(i);
				updatedsub.add(sub);
				
				for(csord__Service__c serv :sub.csord__services__r){
				
				serv.serviceMSISDN__c = resourceIds.get(i);
				servicewithNumber.put(serv.id,resourceIds.get(i));
                serviceIdMap.put(serv.id,serv);
				updatedservice.add(serv);
			     }
				
				i++;
                }	
			}
			system.debug('updatedsub:'+updatedsub);
			system.debug('updatedservice:'+updatedservice);
			
			
			if(!updatedsub.isEmpty()){
				update updatedsub;
			}
			
			if(!updatedservice.isEmpty()){
				update updatedservice;
			}
			result1= updateSpecs();
            LRMMSISDNService.saveReserveNumbers(servicewithNumber, serviceIdMap,'Mobile');
			
         if(result1 == 'SUCCESS'){ 
		      return 'SUCCESS'; }
		 else {
			return 'ERROR'; 
		 }
		 
		}
        catch (Exception e) {
            return 'ERROR';
        }
    }
	
	
	 public static String updateSpecs(){
		
        try { 
		
		 for(Attachment att: [Select id,body,parentId from Attachment where parentId IN:serviceIdMap.keySet()]){
                servAttachmentRecordMap.put(att.parentId,att);
                serviceAttachmentMap.put(att.parentId,att.body.toString());
                 } 
				 
			  
			   if(!servAttachmentRecordMap.isEmpty()){
                  for(String servId : servAttachmentRecordMap.keySet()){
                Attachment att = servAttachmentRecordMap.get(servId);
                List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = LRMMSISDNService.getAllServSpecslist(att,'FULFILMENT');
                      
                AttMapTobeUpdated = LRMMSISDNService.prepareServiceSpecsToupdate(servId,att.body.toString(),srvSpecList,serviceIdMap,AttMapTobeUpdated,servAttachmentRecordMap); 
               }
			}
			system.debug('AttMapTobeUpdated:'+AttMapTobeUpdated);
			if(!AttMapTobeUpdated.isEmpty()){
				update AttMapTobeUpdated.values();
			}
		 return 'SUCCESS';		
	     }
	 
        catch (Exception e) {
            return 'ERROR';
        }
	 }
    
}