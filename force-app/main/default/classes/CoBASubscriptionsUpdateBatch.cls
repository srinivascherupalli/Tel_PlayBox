/*************************************************************************************************************************************************
* Name         :   CoBASubscriptionsUpdateBatch  
* Description  :   Batch class is used to handle - on Change of Billing account request for Subcriptions
                        a. Create Subcription to Case Association Records
                        b. Update Subscription Status = 'Update In Progress'
* Test Class   :   CoBASubscriptionsUpdateBatchTest

Sr.No.      Developer Name      Date            Story           Description
1.          Pooja               01/04/2021      EDGE-205599     As a user when change of Billing account is submitted system must create case for tracking
2.          Kamlesh             21/04/2021      EDGE-210193     The finish method will pass all the caseIds to billing API
3.          Pooja               30/04/2021      EDGE-212439     As a User, I should receive Chatter Notification if CoBA request fails/Errors
4.          Kamlesh             6/5/2021        EDGE-212440     Removed return value as calling method does not have return type
**************************************************************************************************************************************************/
public with sharing class CoBASubscriptionsUpdateBatch implements Database.Batchable<SObject>,Database.Stateful {
    
    public Map<String,String> mSubscrptnCaseId          =   new Map<String,String>();
    public Map<String,String> mSubscrptnNewBillAccId    =   new Map<String,String>();
    public Set<String> setErroredCaseIds                =   new Set<String>();  //Added:EDGE-212439
    /*************************************************************************************************************************************************
     * Constructor : CoBASubscriptionsUpdateBatch
     * Description : Accepts Map<SubcriptionId, CaseId>, Map<SubcriptionId, BillingAccountId>
    **************************************************************************************************************************************************/
    public CoBASubscriptionsUpdateBatch(Map<String,String> mSubCaseId, Map<String,String> mSubNewBillAccId) {
        if( mSubCaseId != null && !mSubCaseId.isEmpty() ) {
            this.mSubscrptnCaseId.putAll(mSubCaseId);
        }
        if( mSubNewBillAccId != null && !mSubNewBillAccId.isEmpty() ) {
            this.mSubscrptnNewBillAccId.putAll(mSubNewBillAccId);
        }
    }
    
    /*************************************************************************************************************************************************
     * Method : start()
     * Description : Query and return the List of Subscription Records to batch execute()
    **************************************************************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Set<String> setSubscriptionIds = new Set<String>();
        setSubscriptionIds.addAll(mSubscrptnCaseId.keySet());
        String query = 'SELECT Id, Name, csord__Status__c, Billing_Account__c FROM csord__Subscription__c WHERE Id IN: setSubscriptionIds';
        return Database.getQueryLocator(query);
    } //End of start()

    /*************************************************************************************************************************************************
     * Method : execute()
     * Description : Accepts List of Subscription Records to batch start()
                        * Create Subscription to Case Association Juntion records
                        * Updates the Subcription record status to 'Update In Progress'
    **************************************************************************************************************************************************/
    public void execute(Database.BatchableContext BC, List<csord__Subscription__c> lstSubcriptions){
        List<Subscriptions_to_Case_Association__c> lstSubCaseAssocn =   new List<Subscriptions_to_Case_Association__c>();
        List<csord__Subscription__c> lstUpdateSubcrptn              =   new List<csord__Subscription__c>();
        Map<String,String> mSubCaseId                               =   new Map<String,String>();
        Map<String,String> mSubBillAccId                            =   new Map<String,String>();
        Set<String> setCaseIds                                      =   new Set<String>();  //Added:EDGE-212439
        String correlationId                                        =   GuidUtil.NewGuid();
        if(lstSubcriptions != null && !lstSubcriptions.isEmpty()) {
            for(csord__Subscription__c oSub : lstSubcriptions) {
                if(mSubscrptnCaseId.containsKey(oSub.Id) && mSubscrptnCaseId.get(oSub.Id) != null) {
                    mSubCaseId.put(oSub.Id,mSubscrptnCaseId.get(oSub.Id));
                    setCaseIds.add(mSubscrptnCaseId.get(oSub.Id));  //Added:EDGE-212439
                }
                if(mSubscrptnNewBillAccId.containsKey(oSub.Id) && mSubscrptnNewBillAccId.get(oSub.Id) != null) {
                    mSubBillAccId.put(oSub.Id, mSubscrptnNewBillAccId.get(oSub.Id));
                }
            }
        }
        try {
            if(!mSubCaseId.isEmpty() && !mSubBillAccId.isEmpty()) {
                lstSubCaseAssocn.addAll(CoBASubscriptionsUpdateUtility.getSubscrptnCaseAssocn(mSubCaseId,mSubBillAccId));  
                lstUpdateSubcrptn.addAll(CoBASubscriptionsUpdateUtility.updateSubscriptions(mSubCaseId.keySet(),'Update In Progress'));
            }
            if(!lstSubCaseAssocn.isEmpty()) {
                insert lstSubCaseAssocn;
            }
            if(!lstUpdateSubcrptn.isEmpty()) {
                update lstUpdateSubcrptn;
            }
        } catch (Exception e) {
            setErroredCaseIds.addAll(setCaseIds); //Added:EDGE-212439
            GenericUtilityClass.logException('CoBASubscriptionsUpdateBatch','execute','',correlationId,e.getMessage() + ' - ' + e.getLineNumber(),'Exception occured during submitting Change of Billing Account Request',C2O_ExceptionHandler.Capability.ORD);
        }
    }   //End of execute()
        
    
    /*************************************************************************************************************************************************
     * Method : finish()
     * Modified Date : 23/04/2021
     * Modified By :  Kamlesh Kumar
     * EDGE   : 210193
     * Description : The method will pass the case ids to billing api callout
    **************************************************************************************************************************************************/
    public void finish(Database.BatchableContext BC){
        Set<String> setSuccessCaseIds = new Set<String>(); //Start:EDGE-210193
        if(mSubscrptnCaseId.size()>0) {
            for(String subId : mSubscrptnCaseId.keySet()) {
                setSuccessCaseIds.add(mSubscrptnCaseId.get(subId));
            }
        }   //End:EDGE-210193
        
        if(!setErroredCaseIds.isEmpty()) { //Start:EDGE-212439
            setSuccessCaseIds.removeAll(setErroredCaseIds); 
            CoBAProcessHelper.cobaSubmissionFailureChatterPost(setErroredCaseIds);
        } //End:EDGE-212439
        
        if(setSuccessCaseIds.size()>0) { //Start:EDGE-210193
            CoBAProcessHelper.billingAPICalloutsForCoBA(new List<String>(setSuccessCaseIds));//EDGE-212440 Removed return value as calling method does not have return type
        }   //End:EDGE-210193
    } //End of finish()

} //End of CoBASubscriptionsUpdateBatch