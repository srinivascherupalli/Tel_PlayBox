/******************************************************************
User Story   : DIGI-30060
Description  : To update remaining term and amount received from BDS for different subscriptions in Technical Orchestration Object
Class Name   : ProcessBDSResponse
Created By   : Team Alexandria, Divakar Tangudu
Created On   : 6 October 2021
*******************************************************************/
@RestResource(urlMapping='/chownSubUpdate/*')
global without sharing class ProcessBDSResponse {  

    @HttpPost
    global static void UpdateRemainingTermAmount(){ 
		
		Logger2 logger = Logger2.getLogger('ProcessBDSResponse');
        RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
        system.debug('req.requestURI'+req.requestURI);
		system.debug('req.header'+req.headers);
        String reqBody = req.requestBody.toString();
		Map<String, String> headers =new Map<String, String>();
		String correlation_Id;
		UpdateRemainingTermWrapper Request;
		String BDS_Response_Status;
		
		List<UpdateRemainingTermWrapper.BillingAccounts> billingAccountsList=new List<UpdateRemainingTermWrapper.BillingAccounts>();

        List<UpdateRemainingTermWrapper.ChargesDetails> chargesDetailsList=new List<UpdateRemainingTermWrapper.ChargesDetails>();
		
        map<string,UpdateRemainingTermWrapper.ChargesDetails> remainingTermMap=new map<string,UpdateRemainingTermWrapper.ChargesDetails>();
		
		list<Orchestration_Technical__c> orch_list=new list<Orchestration_Technical__c>();
		
		try{
			
		headers = req.headers;
		
		correlation_Id=headers.get('Correlation-Id');
		
		system.debug('Correlation-Id++++++++++'+correlation_Id);
		
		BDS_Response_Status=System.Label.BDS_Response_Record_Status;
		
        UpdateRemainingTermWrapper rTermReq = UpdateRemainingTermWrapper.parse(reqBody);
		
		Request = (UpdateRemainingTermWrapper)JSON.deserialize(reqBody, UpdateRemainingTermWrapper.Class);
		
		
	
        if(rTermReq.billingAccounts != null  && rTermReq.billingAccounts .size() > 0){
            billingAccountsList=rTermReq.billingAccounts;
            for(UpdateRemainingTermWrapper.BillingAccounts billacc:billingAccountsList){
                
                if(billacc.chargesDetails != null  && billacc.chargesDetails  .size() > 0){  
                    chargesDetailsList=billacc.chargesDetails;
					system.debug('chargesDetailsList++++++++'+chargesDetailsList);
                    for(UpdateRemainingTermWrapper.ChargesDetails chargerec:chargesDetailsList)
                    {

							remainingTermMap.put(chargerec.subscriptionId,chargerec);					

                    }


				}
			
			}
		}
		system.debug('remainingTermMap keyset++++++++'+remainingTermMap.keyset());
		system.debug('remainingTermMap++++++++'+remainingTermMap);
		
	orch_list=[select Id,Field_30__c,Field_17__c,Field_20__c,Field_21__c,Field_22__c,Field_23__c,Field_24__c,Field_25__c,Field_26__c,Field_29__c  from Orchestration_Technical__c where Field_30__c=: correlation_Id  AND Field_17__c in : remainingTermMap.keyset()];
		
//	orch_list=[select Id,Field_30__c,Field_17__c,Field_20__c,Field_21__c,Field_22__c,Field_23__c,Field_24__c,Field_25__c,Field_26__c,Field_29__c  from Orchestration_Technical__c where Field_17__c in : remainingTermMap.keyset()];
		
		system.debug('list of matched orch rec++++++++'+orch_list);
		
		//using 16 and 17 fields to store the remaining duration and term Field_16__c, Field_17__c

		for (Orchestration_Technical__c orch:orch_list){
			
			//update durationRemaining
			if((remainingTermMap.get(orch.Field_17__c)).durationRemaining!=null)
			orch.Field_20__c=string.valueOf((remainingTermMap.get(orch.Field_17__c)).durationRemaining);
			//update chargeRemaining
			if((remainingTermMap.get(orch.Field_17__c)).chargeRemaining!=null)
			orch.Field_21__c=string.valueOf((remainingTermMap.get(orch.Field_17__c)).chargeRemaining);
			//update units
			if((remainingTermMap.get(orch.Field_17__c)).units!=null)
			orch.Field_22__c=string.valueOf((remainingTermMap.get(orch.Field_17__c)).units);
			//update taxTreatment
			if((remainingTermMap.get(orch.Field_17__c)).taxTreatment!=null)
			orch.Field_23__c=remainingTermMap.get(orch.Field_17__c).taxTreatment;
			//update status
			if((remainingTermMap.get(orch.Field_17__c)).status!=null)
			orch.Field_24__c=remainingTermMap.get(orch.Field_17__c).status;
			//update code
			if((remainingTermMap.get(orch.Field_17__c)).code!=null)
			orch.Field_25__c=remainingTermMap.get(orch.Field_17__c).code;
			//update message)
			if((remainingTermMap.get(orch.Field_17__c)).message!=null)
			orch.Field_26__c=remainingTermMap.get(orch.Field_17__c).message;
			//update Record Status)
			if((remainingTermMap.get(orch.Field_17__c)).message!=null)
			orch.Field_29__c=BDS_Response_Status;	
				
		}
		if(orch_list.size() >0)
		update orch_list;
	
				res.statusCode=200;
				res.responseBody=Blob.valueOf('Records retrieved and updated successfully');
			    logger.logMessages(JSON.serialize(Request),res.responseBody.toString(), '', '', '', '', false, false, Integer.valueOf(res.statusCode),'','', ''); 
	}
		catch(Exception e){
            system.debug('Error in ProcessBDSResponse::::'+e.getLineNumber()+'::::'+e.getMessage()+'::::'+e.getStackTraceString());
			res.statusCode=500;
			logger.logMessages(JSON.serialize(Request),e.getMessage(),'', '','','', false, false, Integer.valueof(res.statusCode),null,null,null);
		}
		
	logger.exitLogger();  

    }


}