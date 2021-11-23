/*************************************************************************************************************************************************
* Name         :   CoBASubscriptionsUpdateUtility  
* Description  :   On Change of Billing account request for Subcriptions
                        a. Create Subcription to Case Association Records
                        b. Update Subscription Status = 'Update In Progress'
* Test Class   :   CoBASubscriptionsUpdateUtilityTest

Sr.No.      Developer Name      Date            Story           Description
1.          Pooja               01/04/2021      EDGE-205599     As a user when change of Billing account is submitted system must create case for tracking
2.          Kamlesh             26/04/2021      EDGE-210193     The lines of code will be used to execute batch CoBABatchHanlder and in case of exceptio
                                                                will send a feedmessage to user.
3.          Kamlesh             6/5/2021        EDGE-212440     Removed return value as calling method does not have return type
**************************************************************************************************************************************************/
public with sharing class CoBASubscriptionsUpdateUtility {
    
    static String correlationId = GuidUtil.NewGuid();
    
    /*************************************************************************************************************************************************
     * Method       :   getSubscrptnCaseAssocn
     * Description  :   Used to create Subcriptions to Case Association juntion record.
                        * Accepts parameters Map<SubcriptionId, CaseId>, Map<SubcriptionId, BillingAccountId> and returns list of 
                          Subcriptions to Case Association records.
    **************************************************************************************************************************************************/
    public static List<Subscriptions_to_Case_Association__c> getSubscrptnCaseAssocn(Map<String,String> mSubCaseId, Map<String,String> mSubNewBillAccId) {
        List<Subscriptions_to_Case_Association__c> lstSubCaseAssocn =   new List<Subscriptions_to_Case_Association__c>();
        if(mSubCaseId != null && !mSubCaseId.isEmpty()) {
            for(String subscrptnIds : mSubCaseId.keySet()) {
                if(mSubNewBillAccId != null && mSubNewBillAccId.containsKey(subscrptnIds) && mSubNewBillAccId.get(subscrptnIds)!=null) {
                    Subscriptions_to_Case_Association__c oSCA   =   new Subscriptions_to_Case_Association__c();
                    oSCA.Case__c                                =   mSubCaseId.get(subscrptnIds);
                    oSCA.csord_Subscription__c                  =   subscrptnIds;
                    oSCA.Billing_Account__c                     =   mSubNewBillAccId.get(subscrptnIds);
                    oSCA.Status__c                              =   'Pending';
                    lstSubCaseAssocn.add(oSCA);
                }
            }
        }
        return lstSubCaseAssocn;
    } //End of getSubscrptnCaseAssocn()

    /*************************************************************************************************************************************************
     * Method       :   updateSubscriptions
     * Description  :   Used to update Subcription Record Status 
                        * Accepts parameters Set<SubcriptionId>, Status and returns list of updated Subcription records.
    **************************************************************************************************************************************************/
    public static List<csord__Subscription__c> updateSubscriptions(Set<String> setSubscrptnIds, String status) {
        List<csord__Subscription__c> lstSubcriptions = new List<csord__Subscription__c>();
        if(setSubscrptnIds != null && !setSubscrptnIds.isEmpty()) {
            for(String oSubscrptnId : setSubscrptnIds) {
                csord__Subscription__c oSubscription    =   new csord__Subscription__c();
                oSubscription.Id                        =   oSubscrptnId;
                oSubscription.csord__Status__c          =   status;
                lstSubcriptions.add(oSubscription);
            }
        }
        return lstSubcriptions;
    } //End of updateSubscriptions()

    /*************************************************************************************************************************************************
     * Method       :   createNewCase
     * Description  :   Used to create new Case with record type Change of Billing Account.
                        * Accepts parameters Account Id, Contact Id, TargetBillingAccountId, Reason and returns a Case record.
    **************************************************************************************************************************************************/
    public static Case createNewCase(String accountId, String contactId, String targetBillAccId, String reason) {
        List<Billing_Account__c> targetBillngAccLst =   [SELECT Id,Billing_Account_Number__c,Account__c,Account__r.Name 
                                                            FROM Billing_Account__c WHERE Id=:targetBillAccId AND Account__c=:accountId];
        String accName          =   (targetBillngAccLst.size() == 1 ? ' for ' + targetBillngAccLst[0].Account__r.Name : '');
        String targetBillAccNum =   (targetBillngAccLst.size() == 1 ? ' to ' + targetBillngAccLst[0].Billing_Account_Number__c : '');
        Case oCase              =   new Case();
        oCase.RecordTypeId      =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Change_of_Billing_Account').getRecordTypeId();
        oCase.AccountId         =   AccountId;
        oCase.ContactId         =   ContactId;
        oCase.Billing_Account__c=   targetBillAccId;
        oCase.OwnerId           =   UserInfo.getUserId();
        oCase.Reason            =   reason;
        oCase.Status            =   'New';
        oCase.Priority          =   'Medium';
        oCase.Subject           =   'Change of Digital Billing Account' + targetBillAccNum + accName;
        oCase.Description       =   'Refer to Related Subscriptions for list of records undergoing change';
        return oCase;
    }   //End of createNewCase()

    /*************************************************************************************************************************************************
     * Method       :   syncUpdateSubsCaseAssocAndSubsRec
     * Description  :   Used to create Subscriptions to Case Association Juntion Record and Update associated subscription status
                        * Accepts parameters Account Id, Contact Id, TargetBillingAccountId, Reason and returns a Case record.
    **************************************************************************************************************************************************/
    public static void syncUpdateSubsCaseAssocAndSubsRec(Map<String,String> mSubscrptnCaseId, Map<String,String> mSubscrptnNewBillAccId) {
        List<Subscriptions_to_Case_Association__c> lstSubCaseAssocn =   new List<Subscriptions_to_Case_Association__c>();
        List<csord__Subscription__c> lstUpdateSubcriptions          =   new List<csord__Subscription__c>();
        lstSubCaseAssocn.addAll(getSubscrptnCaseAssocn(mSubscrptnCaseId,mSubscrptnNewBillAccId));
        lstUpdateSubcriptions.addAll(updateSubscriptions(mSubscrptnCaseId.keySet(),'Update In Progress'));
        if(!lstSubCaseAssocn.isEmpty()) {
            insert lstSubCaseAssocn;
        }
        if(!lstUpdateSubcriptions.isEmpty()) {
            update lstUpdateSubcriptions;
        }
    }   //End of syncUpdateSubsCaseAssocAndSubsRec()
    
    /*************************************************************************************************************************************************
     * Method       :   submitCoBA
     * Description  :   Used to create new Case and Subscriptions to Case Association record on Change of Billing Account request.
                        * Invoked from class ShowSubscriptionsOnMACButtonController, method submitBillAcc()
                        * Accepts parameters Account Id, Contact Id, TargetBillingAccountId, Reason and List<SubscriptionId>
                        * Custom Setings named Utility Settings, field value Use_Batch_Mode_For_CoBA__c is used to determine 
                            Subcription to Case Association records either created in Async or Sync mode. 
                            UtilitySettings.Use_Batch_Mode_For_CoBA__c = True - Async Mode, Batch class CoBASubscriptionsUpdateBatch
    **************************************************************************************************************************************************/
    @AuraEnabled
    public static Case submitCoBA(String accountId, String contactId, String targetBillAccId, String reason, List<String> lstSubscrptnIds) {        
        Map<String,String> mSubscrptnCaseId                         =   new Map<String,String>();
        Map<String,String> mSubscrptnNewBillAccId                   =   new Map<String,String>();
        Case oCase                                                  =   new Case();
        try {
            oCase       =   createNewCase(accountId,contactId,targetBillAccId,reason);
            insert oCase;
            List<Case> caseLst  =   [SELECT Id, CaseNumber FROM Case WHERE Id=:oCase.Id];
            oCase               =   caseLst[0];
            for(String subcrptnId : lstSubscrptnIds) {
                mSubscrptnCaseId.put(subcrptnId,oCase.Id);
                mSubscrptnNewBillAccId.put(subcrptnId,targetBillAccId);
            }
            if(!mSubscrptnCaseId.isEmpty() && !mSubscrptnNewBillAccId.isEmpty()) {
                Utility_Settings__c utilitySettings = Utility_Settings__c.getInstance();
                if(utilitySettings.Use_Batch_Mode_For_CoBA__c) {
                    Database.executeBatch(new CoBASubscriptionsUpdateBatch(mSubscrptnCaseId,mSubscrptnNewBillAccId), Integer.valueOf(utilitySettings.Batch_size_for_CoBA__c));
                } else { 
                    syncUpdateSubsCaseAssocAndSubsRec(mSubscrptnCaseId,mSubscrptnNewBillAccId);
                    //EDGE:212440-Removed return value as calling method does not have return type
                    CoBAProcessHelper.billingAPICalloutsForCoBA(new List<String>{oCase.Id}); //Added:EDGE-210193 
                }
            }
        } catch(Exception e) {
            throw new AuraHandledException('Exception** ' + e.getLineNumber() + ' ' + e.getMessage() );
        }
        return oCase;
    }   //End of submitCoBA()
}   //End of CoBASubscriptionUpdateUtility