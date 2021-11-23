//DIGI-30045
public with sharing class SendChownSubRequestToBDS {
    
    public void createBDSRequest(List<Migration_Change_Request__c> listOfMigChangeReq){
        try{
            List<Orchestration_Technical__c> otList = new List<Orchestration_Technical__c>();
            Orchestration_Technical__c otRec;
            Map<String, List<PayoutDetailsforChownReqDto.ChargesDetails>> mpChrgDtls= new Map<String, List<PayoutDetailsforChownReqDto.ChargesDetails>>();
            PayoutDetailsforChownReqDto.ChargesDetails chgDtl;
            list<PayoutDetailsforChownReqDto.ChargesDetails> chgDtlLst;
            List<String> subIdLst = new List<String>();	
            Id srvcRecId;
            String basketId;
            String correlationId;
            Integer maxCount = Integer.valueOf(EnvironmentVariable__c.getValues('MaxBDSChgInstances').Value__c);
            Integer iCount = 0;
            Map<ID, csord__Service__c> mpSer;
            for(Migration_Change_Request__c mcr :listOfMigChangeReq){
                if(mcr.selected_subscription_ids__c != null){
                    subIdLst.addAll(mcr.selected_subscription_ids__c.split(','));
                }
                if(mcr.macd_basket_ids__c != null){
                    List<String> lstBsktIds = mcr.macd_basket_ids__c.split(',');
                    if(lstBsktIds.size() > 1)
                        basketId = lstBsktIds[1];
                }
            }
            if(subIdLst.size() > 0){
            	mpSer = new Map<ID, csord__Service__c>([SELECT Id,csord__Subscription__r.Billing_Account_Number__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c FROM csord__Service__c WHERE csord__Subscription__c IN :subIdLst AND Payment_Type__c ='Hardware Repayment']);
            }
            if(mpSer.size() > 0){
                list<Id> serIdLst = new list<Id> (mpSer.keySet());
                Map<ID, Orchestration_Technical__c> mpTech = new Map<ID, Orchestration_Technical__c>([SELECT Id,Service__c,Field_2__c,Field_9__c FROM Orchestration_Technical__c WHERE Service__c IN :serIdLst]);
                String baNum;
                String subNum;
                for(Id ot :mpTech.KeySet()){
                    if(iCount == 0){
                        correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
                    }
                    srvcRecId = mpTech.get(ot).Service__c;
                    baNum = mpSer.get(srvcRecId).csord__Subscription__r.Billing_Account_Number__c;
                    subNum = mpSer.get(srvcRecId).csord__Subscription__r.csordtelcoa__Subscription_Number__c;
                    otRec = new Orchestration_Technical__c();
                    otRec.Process_Name__c = 'FetchPayoutDetails';
                    otRec.Field_30__c = correlationId;
                    otRec.Field_16__c = baNum;
                    otRec.Field_17__c = subNum;
                    otRec.Field_18__c = mpTech.get(ot).Field_9__c; //instanceId
                    otRec.Field_19__c = basketId;
                    otRec.Field_29__c = 'Initiated';
                    otList.add(otRec);
                    
                    chgDtl = new PayoutDetailsforChownReqDto.ChargesDetails();
                    chgDtl.subscriptionId = subNum;
                    chgDtl.instanceId = mpTech.get(ot).Field_9__c;
                    if(mpChrgDtls.containsKey(baNum)){
                        mpChrgDtls.get(baNum).add(chgDtl);
                    }
                    else{					
                        chgDtlLst = new list<PayoutDetailsforChownReqDto.ChargesDetails>{chgDtl};
                        mpChrgDtls.put(baNum, chgDtlLst);
                    }
                    iCount++;
                    if(iCount == maxCount){
                        iCount = 0;
                        sendCalltoBDS(mpChrgDtls, correlationId);
                        mpChrgDtls= new Map<String, List<PayoutDetailsforChownReqDto.ChargesDetails>>();
                    }
                }
                if(mpChrgDtls.size() > 0){
                    sendCalltoBDS(mpChrgDtls, correlationId);
                }
                insert otList;
            }
        }
        catch(exception e){
            system.debug('Error occurred in SendChownSubRequestToBDS::'+e.getMessage()+'at line::'+e.getLineNumber());
        }
	}
	public void sendCalltoBDS(Map<String, List<PayoutDetailsforChownReqDto.ChargesDetails>> mpChrgDtls, String correlationId){		
		PayoutDetailsforChownReqDto reqDto = new PayoutDetailsforChownReqDto();
		List<PayoutDetailsforChownReqDto.BillingAccounts> baLst = new List<PayoutDetailsforChownReqDto.BillingAccounts>();
		PayoutDetailsforChownReqDto.BillingAccounts baInd;
		for(String ba :mpChrgDtls.KeySet()){
			baInd = new PayoutDetailsforChownReqDto.BillingAccounts();
			baInd.billingAccountNumber = long.valueOf(ba);
			baInd.chargesDetails = mpChrgDtls.get(ba);
			baLst.add(baInd);
		}
		reqDto.billingAccounts = baLst;
        String reqStr = JSON.serialize(reqDto);
		FetchPayoutDetailsforChown.fetchPayoutDetails(reqStr, correlationId);//call to future method
	}	
}