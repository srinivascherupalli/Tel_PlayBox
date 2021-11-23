/**
* @Description : Get Customer and Contacts from TCM application based on CIDN and insert/update in Force.com.
* @Author : ChandrakanthReddy B.
* @Date : 21/Jan/2017
* @Story : EDGE-677
*/

public without sharing class TCMCustomerHandlerQueueable implements Queueable,Database.AllowsCallouts{
    
    private String cidn;
    private Id accountId;
    private String loggerType;
    private static Boolean hasQueueableRun = false;
    
    /**static{
     AccountTriggerHandler.pendingCustomerFlag=true;
     ContactTriggerHandler.pendingCustomerFlag=true;
	}**/
    
    public TCMCustomerHandlerQueueable(String cidn, Id accountId, String loggerType){
        this.cidn = cidn;
        this.accountId = accountId;
        this.loggerType = loggerType;
    }
    
    public void execute(QueueableContext context){
		System.debug('Executing - TCMCustomerHandlerQueueable for cidn : ' + cidn);
        TCMCustomerImportByCIDN tcmImportByCIDN = new TCMCustomerImportByCIDN();
		TCMGetInterface getInterface = TCMGetInterface.getInstance();
        boolean isUpdated = false;
        Logger2 logger = Logger2.getLogger(String.isNotBlank(loggerType) ? loggerType : 'TCMPENDINGCUSTOMER');
        Savepoint sp = null;
        try {
            tcmImportByCIDN.tcmObjects(cidn);
            if(tcmImportByCIDN.isAccountRetired == null || !tcmImportByCIDN.isAccountRetired){
                sp = Database.setSavepoint();
            	tcmImportByCIDN.createTCMCustomer(cidn);
                if(tcmImportByCIDN.tcmCustomer != null){
                	TCMGetContactFuture tcmGetConFuture = new TCMGetContactFuture();                    
					tcmGetConFuture.futureCalloutAccount(tcmImportByCIDN.tcmCustomer, 'TCMPENDINGCUSTOMER');
                }
				isUpdated = (TCMGetInterface.getInstance().tcmCustomerError.get(cidn) == null) ? true : false;
            }
        } catch(TCMException.TCMCustomerCreationException tcmException){
            isUpdated = false;
            Database.rollback(sp);
            TCMBusinessErrorCode.getInstance().logCustomerExcepction(cidn,String.isNotBlank(loggerType) ? loggerType : 'TCMPENDINGCUSTOMER',tcmException);
        } catch(TCMException.TCMContactCreationException tcmContactException){
            isUpdated = false;
            Database.rollback(sp);
            TCMBusinessErrorCode.getInstance().logCustomerExcepction(cidn,String.isNotBlank(loggerType) ? loggerType : 'TCMPENDINGCUSTOMER',tcmContactException);
        } catch(Exception e){
            isUpdated = false;
            if(sp != null) Database.rollback(sp);
            logger.logMessages(cidn, '', e.getStackTraceString(), '', '', e.getMessage(), false, false);
        } finally {
			for(String keys : getInterface.callOutDataCapture.keyset()){
                TCMGetInterface.TCMRequestResponseCapture reqResCapture = getInterface.callOutDataCapture.get(keys);
                logger.logMessages(reqResCapture.url, reqResCapture.httpResponse.getBody(), '', '', '', '', false, false, reqResCapture.httpResponse.getStatusCode(),null,reqResCapture.key, null);
            }
            logger.exitLogger();
        }
        if(!isUpdated){
            List<Account> accountUpdation = [select Id, Name, Customer_Status__c from Account where Id = : accountId or CIDN__c = :cidn];
            if(!accountUpdation.isEmpty()){
                System.debug('TCMCustomerHandlerQueueable, Updating cidn status : ' + cidn);
            	Account acc = accountUpdation[0];
            	acc.Customer_Status__c = Label.Acc_CustomerStatus_PENDING; //EDGE-68099 Removed Hard Coding
            	update acc;
            }
        }
    }
    
    public static void OnBeforeUpdate(Map<Id,Account> oldMap,Map<Id,Account> newMap){
        Id accountId = null;
        String cidn = null;
        for(Id accId : newMap.keySet()){
            String newCIDNValue = newMap.get(accId).CIDN__c;
            String oldCIDNValue = (oldMap != null && oldMap.get(accId) != null) ? oldMap.get(accId).CIDN__c : null;
            String customerStatus = newMap.get(accId).Customer_Status__c;
            if (newCIDNValue!= null && String.isNotBlank(newCIDNValue) && 
                (oldCIDNValue == null || String.isBlank(oldCIDNValue)) &&
                (customerStatus != null && customerStatus == Label.Acc_CustomerStatus_PENDING)){ //EDGE-68099 Removed Hard Coding
                cidn =  newCIDNValue;
                accountId = accId;
                newMap.get(accId).Customer_Status__c = Label.Acc_CustomerStatus_Requested; //EDGE-68099 Removed Hard Coding
                System.debug('TCMCustomerHandlerQueueable-OnBeforeUpdate -- ' + cidn + ' -- ' +newMap.get(accId).Customer_Status__c);
            }
        }
        if(cidn!=null && String.isNotBlank(cidn) && !hasQueueableRun){
            System.debug('hasQueueableRun status before : ' + hasQueueableRun);
            System.enqueueJob(new TCMCustomerHandlerQueueable(cidn,accountId,'TCMPENDINGCUSTOMER'));
            hasQueueableRun = true;
            System.debug('hasQueueableRun status after : ' + hasQueueableRun);
        }
    }

	/**
	 * Check for Retry mechanism
	 */    
    public static void onAfterInsert(Account[] newAccounts){
        String cidn = null;
        Id accountId = null;
        for(Account acc : newAccounts){
            if(String.isNotBlank(acc.CIDN__c) && String.isNotBlank(acc.Customer_Status__c) && Label.Acc_CustomerStatus_PENDING.equals(acc.Customer_Status__c)){ //EDGE-68099 Removed Hard Coding
                cidn = acc.CIDN__c;
            }
        }
        if(String.isNotBlank(cidn) && !hasQueueableRun){
            System.debug('hasQueueableRun status before : ' + hasQueueableRun);
            System.enqueueJob(new TCMCustomerHandlerQueueable(cidn,accountId,'TCMLEADCONVERSION'));
            hasQueueableRun = true;
            System.debug('hasQueueableRun status after : ' + hasQueueableRun);
        }
    }
}