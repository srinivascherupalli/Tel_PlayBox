/**************************************************************************
Name: MSISDNReserveServiceHandler
Description: Class will create payload and invokes searchReserveMSISDN callout for IP Site with Mobile Access and updates corresponding specifications

1			Abinash			03/02/2020		(20.03)EDGE-92021 /EDGE-68661 <LRM><UNMS> Search and Reserve Next Available MSISDN
											<Interface Story> CS->LRM [UNMS] to enable bulk reserve of mobile numbers

***************************************************************************/

global with sharing class MSISDNReserveServiceHandler implements CSPOFA.ExecutionHandler,CSPOFA.Calloutable {
    
    private List<Object> calloutResults;
    Boolean calloutsPerformed = false;  
    public List<String> calloutStatus = new List<String>();
    
    public Boolean performCallouts(List<SObject> data)
    {
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
        List<String> orderIds = new List<String>();
        List<Id> orchesIds= new List<Id>();
        string scenarioType = '';


		List<String> subId = null;
        
        for(CSPOFA__Orchestration_Step__c step: stepList)
        {
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
        }
        for(CSPOFA__Orchestration_Process__c  orch : [Select Order__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds])
        {
            orderIds.add(orch.Order__c);
        }            
        system.debug('orderIds'+orderIds);


        MSISDNReserveServices(orderIds,scenarioType, subId);                     
        calloutsPerformed = true;       
        return calloutsPerformed;
    }
    
    public List<sObject> process(List<sObject> data){
        List<Id> orchesIds= new List<Id>();
        List<sObject> result = new List<sObject>();
        List<Id> orderId = new List<Id>();
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
        system.debug('stepList=='+stepList);
        
        
        for(CSPOFA__Orchestration_Step__c step: stepList)
        {
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
        }
        for(CSPOFA__Orchestration_Process__c  orch : [Select Order__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds])
        {
            orderId.add(orch.Order__c);
        }   
        
        
        for(CSPOFA__Orchestration_Step__c step : stepList){
            
            if (calloutsPerformed != true)
            {
                step.CSPOFA__Status__c = 'Error';
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = 'MSISDN Reserve Failed';
                result.add(step);       
            }
            else
            {
                step.CSPOFA__Status__c = 'Complete';
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = 'Completed';
                result.add(step);
                
            }
            
            
        }
        return result;
    }
    

    //Modified
    public void MSISDNReserveServices(List<Id> orderId,String scenarioType, List<String> subId)
    {
        List <csord__Service__c> serviceList = new List <csord__Service__c> ();
        Map<String,Map<String,String>> guidAddAttrMap = new Map<String,Map<String,String>>();
        Map<String,String> addAttrMap = new Map<String,String>();
        Map<String,Map<String,String>> AttrMap = new Map<String,Map<String,String>>();
        Map<String,FNNDTO> serviceIDFNNDTOMap = new Map<String,FNNDTO>();
        List<RecordType> MSISDNRecordtype = null;
        Boolean MSISDNHeld = null;
        FNNService fnnSer = new FNNService();
        FNNResponseDTO fnnRest = new FNNResponseDTO();
        List<FNNDTO> fnnDTOList = new List<FNNDTO>();
        List<csord__Order__c> ordList = new List<csord__Order__c>();
        try
        { 
            system.debug('Entering MSISDNReserveServices class to fetch service list');
            
            List<csord__Order__c> orderstatus = [select id, isMSISDNHeld__c,RecordTypeId,csord__Status2__c from csord__Order__c where id =: orderId limit 1];
            if (!orderstatus.isEmpty())
            {
                MSISDNRecordtype = [SELECT DeveloperName  FROM RecordType   WHERE Id =: orderstatus[0].RecordTypeId];
                MSISDNHeld = orderstatus[0].isMSISDNHeld__c;
                system.debug('isMSISDNReserved ' +MSISDNHeld+'MSISDNStatus  '+MSISDNRecordtype);
            }
            String handlerName = '';
            String Operation = '';
            if(orderstatus[0].isMSISDNHeld__c == true){ operation = 'MSISDN_Reserved'; }
            
			List<csord__service__c> servList = new List<csord__service__c> ();
            If ( MSISDNHeld == true )
            {


				if(subId != null && scenarioType.equals('Change of Mobile Number')){
					servList = [select id,name from csord__service__c where csord__subscription__c In :subId and csord__Service__c = null];
				}
				else{
					servList = [select id,name from csord__service__c where csord__Order_Request__c IN( select csord__Order_Request__c from csord__order__c where  id IN: orderId) and csord__Service__c = null];
				}
                //removed for fix : and TechnologyType__c= 'Mobile Access'
                for(csord__service__c serv : servList)
                {
                    FNNDTO dto = new FNNDTO();
                    FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
                    fdo.activityName = 'RESERVE';
                    dto.data = fdo;
                    serviceIDFNNDTOMap.put(serv.Id,dto);
                    fnnDTOList.add(dto);
                    handlerName = 'HeldToReserveMSISDNHandler';
                }
                system.debug('Request MAP ' + serviceIDFNNDTOMap);
                
                /* for(csord__Order__c ord : [select id, isMSISDNReserved__c from csord__Order__c where id =:orderId])
                {
                ord.isMSISDNReserved__c = false;
                ordList.add(ord);
                }
                update ordList; */
                
                
            }
            else
            {


				if(subId != null && scenarioType.equals('Change of Mobile Number')){
					servList = [select id,name from csord__service__c where csord__subscription__c In :subId and csord__Service__c = null];
				}
				else{
					servList = [select id,name from csord__service__c where csord__Order_Request__c IN( select csord__Order_Request__c from csord__order__c where  id IN: orderId) and csord__Service__c = null];
				}
                //TechnologyType__c= 'Mobile Access'
                for(csord__service__c serv : servList){
                    system.debug('MSISDN service count');
                    FNNDTO dto = new FNNDTO();
                    FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
                    fdo.poolName = 'Postpaid';
                    fdo.activityName = 'DIRECT HOLD';
                    fdo.searchStatus = 'AVAILABLE';
                    dto.data = fdo;
                    serviceIDFNNDTOMap.put(serv.Id,dto);
                    fnnDTOList.add(dto);
                    handlerName = 'SearchReserveMSISDNHandler';
                }
                system.debug('Request MAP ' + serviceIDFNNDTOMap);
                
            }
            LRMMSISDNService msisdnServiceJob = new LRMMSISDNService(serviceIDFNNDTOMap,orderId[0],operation,handlerName,scenarioType);
            system.debug('debug before job enque');
            ID jobID = System.enqueueJob(msisdnServiceJob);
            system.debug('JOBID of MSISDN Reservation Queue ' + jobID);
        }
        catch(Exception e){
            Logger.getLogger(MSISDNReserveServiceHandler.class).debug(e);
            Logger.exitLogger();
        }
    }
    //EDGE-89982 // Commented by Abinash
    /*public static void getNewMSISDNResponse(String servId,Map<String,HttpResponse> responseMap){
       
        HttpResponse response = responseMap.get(servId);
        FNNResponseDTO fnnResDto = FNNResponseDTO.parse(response.getBody());  
       // String resBody = response.getBody();
        //EDGE:89984:Publishing platform Event
        List<ChangeOfMobileNumber__e> changeOfMobileList = new List<ChangeOfMobileNumber__e>();
        //res.resourceId = 
        Logger2 log = Logger2.getLogger('ChangeOfMobileNumberEvent');
        ChangeOfMobileNumber__e ChangeOfMobileNumberEvent = new ChangeOfMobileNumber__e(); 
        ChangeOfMobileNumberEvent.CorrelationId__c = EDISSingleManager.getUID();
       // ChangeOfMobileNumberEvent.NewMSISDN__c = resBody;
        ChangeOfMobileNumberEvent.NewMSISDN__c = fnnResDto.data.resources[0].resourceId;
        
        System.debug('ChangeOfMobileNumberEvent.NewMSISDN__c==>'+ChangeOfMobileNumberEvent.NewMSISDN__c);
        changeOfMobileList.add(ChangeOfMobileNumberEvent);
        System.debug('ChangeOfMobileNumberEvent'+ChangeOfMobileNumberEvent);
        
        csord__Service__c serv = [Select id,name,csord__Subscription__c, serviceMSISDN__c from csord__Service__c where id =: servId];
        
            String subID = '';
            subID = serv.csord__Subscription__c;

        csord__Subscription__c sub = [Select id, serviceMSISDN__c, oldServiceMSISDN__c from csord__Subscription__c where id =: subID];
       //updating service with new mobile number
            serv.serviceMSISDN__c = ChangeOfMobileNumberEvent.NewMSISDN__c;
            update serv;
            sub.oldServiceMSISDN__c = sub.serviceMSISDN__c;
            sub.serviceMSISDN__c = ChangeOfMobileNumberEvent.NewMSISDN__c;
            update sub;
        
        Database.SaveResult saveRes = EventBus.publish(ChangeOfMobileNumberEvent);
        System.debug('saveRes'+saveRes);
        if(saveRes != null ){
            System.debug('Events are published');
            
            log.logMessages(JSON.serialize(ChangeOfMobileNumberEvent, true),'', '', '', '', '', false, false,200,subID,ChangeOfMobileNumberEvent.NewMSISDN__c,'');
            log.exitLogger();
        }
        //End       
        
    }*/
	
	//EDGE-92021 Start Abinash
    public static void getNewMSISDNResponse(Map<String,String> servicewithFNN, Map<String,csord__Service__c> servicewithSubcription){
       
	   List<csord__Service__c> lstServiceToUpdate = new List<csord__Service__c>();
	   List<csord__Subscription__c> lstSubscriptionToUpdate = new List<csord__Subscription__c>();
		//EDGE:89984:Publishing platform Event
        List<ChangeOfMobileNumber__e> changeOfMobileList = new List<ChangeOfMobileNumber__e>();
	   if(!servicewithSubcription.isEmpty()){
		   for(csord__Service__c service: servicewithSubcription.values()){
			   ChangeOfMobileNumber__e ChangeOfMobileNumberEvent = new ChangeOfMobileNumber__e(); 
				ChangeOfMobileNumberEvent.CorrelationId__c = EDISSingleManager.getUID();
			    ChangeOfMobileNumberEvent.NewMSISDN__c = servicewithFNN.get(service.id); // it will get resourceId
				changeOfMobileList.add(ChangeOfMobileNumberEvent);
				// Add the new mobile number to service and subscription 
				service.serviceMSISDN__c = ChangeOfMobileNumberEvent.NewMSISDN__c;
				lstServiceToUpdate.add(service);
				if(service.csord__Subscription__c != null){
                    lstSubscriptionToUpdate.add(new csord__Subscription__c(id=service.csord__Subscription__c,
						serviceMSISDN__c = ChangeOfMobileNumberEvent.NewMSISDN__c,
						oldServiceMSISDN__c = service.csord__Subscription__r.serviceMSISDN__c));
                }
           }
       }
	   // Update updated service list if list is not blank
	   if(!lstServiceToUpdate.isEmpty()){
		   update lstServiceToUpdate;
	   }
	   // Update updated subscription list if list is not blank
	   if(!lstSubscriptionToUpdate.isEmpty()){
		   update lstSubscriptionToUpdate;
	   }
        Logger2 log = Logger2.getLogger('ChangeOfMobileNumberEvent');
		// Publish ChangeOfMobileNumberEvent platform event if the list is not empaty
		if(!changeOfMobileList.isEmpty()){
			// essentially, this is the bulk DML pattern, all over.
  			List<Database.SaveResult> saveRes = EventBus.publish(changeOfMobileList);
			System.debug('saveRes'+saveRes);
			if(saveRes != null ){
				System.debug('Events are published');				
				//log.logMessages(JSON.serialize(ChangeOfMobileNumberEvent, true),'', '', '', '', '', false, false,200,subID,ChangeOfMobileNumberEvent.NewMSISDN__c,'');
				//log.exitLogger();
			}
		}        
    }//EDGE-92021 End
}