/*****************************************************************
@Name: APTPS_AgreementTrigger
@Author: Ruchika Patil 
@CreateDate: 16/03/2016 
@Description: This is the trigger on Agreement object for the events: before insert & after update
@UsedBy: Agreement 

===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Vishal Arbune          25/09/2020    EDGE-188898 : Changes to FA status and date fields when Agreement status is updated to "In Effect".
2.            Aarathi Iyer           13/03/2021    EDGE-203939 : Changed the method name in Hnadler
3.            Lokesh Thathuru        05/10/2021    update the code as a part of Adobe Implementation
******************************************************************/ 
trigger APTPS_AgreementTrigger on Apttus__APTS_Agreement__c (before insert, before update, after update, after insert, before delete) {  
    APTPS_AgreementTriggerHandler handler = new APTPS_AgreementTriggerHandler();
    APTPS_AgreementTgrHandler handler1 = new APTPS_AgreementTgrHandler(); //EDGE-188898 : Changes to FA status and date fields
    public static boolean runOnce = true;
    static final STRING AGREEMENT_CATEGORY_IN_EFFECT = 'In Effect';
    static final STRING AGREEMENT_CATEGORY_IN_SIGNATURE = 'In Signatures';
    static final STRING AGREEMENT_STATUS_ACTIVATED = 'Activated' ;
    static final STRING AGREEMENT_STATUS_SIGNATURE_DECLINED = 'Signature Declined';
    static final STRING AGREEMENT_STATUS_FULLY_SIGNED = 'Fully Signed';
    static final STRING AGREEMENT_STATUS_OTHER_PARTY_SIGNATURES = 'Other Party Signatures';
    System.debug('Batch job : ' + BatchAgmtSalesAccExecutiveUpdate.isSalesAccExecutiveJob);
    
  //Lokesh D : FeatureManagement.checkPermission(APTPS_Constants.checkCalmsPermission) added in if condition under EDGE-81538 for Minimum Spend information from CALMS to CVT 
    if(EnvironmentalSettings.isTriggerDisabled('APTPS_AgreementTrigger') || BatchAgmtSalesAccExecutiveUpdate.isSalesAccExecutiveJob || FeatureManagement.checkPermission(APTPS_Constants.checkCalmsPermission)) {
        return;
    }
    //After Update logic
    if(Trigger.isUpdate && Trigger.isAfter){  
        if(runOnce)
        {   
            handler.handleAfterUpdateEvents(Trigger.newMap, trigger.new, Trigger.oldMap);
            if(FeatureEligibilityChecker.determineFeatureEligiblity('APTPS_AgreementTrigger_TED_383', 'adobe')){
                try{ // Added this Lokesh Thathuru to Log the Errors in Exception Log Object
                    APTPS_AgreementTgrHandler.handleAfterUpdateEvents(Trigger.newMap, trigger.new, Trigger.oldMap);//APTPS_AgreementTgrHandler This is added as a part of adobe implmentation. Lokesh Thathuru 10/5/2021
                }catch(AgreementException agreementExceptionInstance){
                    Agreementutilities.logException(agreementExceptionInstance.methodName,agreementExceptionInstance.referenceNumber,'',agreementExceptionInstance.errorMessage,agreementExceptionInstance.businessDescription);
                }
            }
            for(Apttus__APTS_Agreement__c ag : trigger.new){
                if((Trigger.oldmap.get(ag.id).Apttus__Status_Category__c != ag.Apttus__Status_Category__c && ag.Apttus__Status_Category__c == AGREEMENT_CATEGORY_IN_EFFECT && Trigger.oldmap.get(ag.id).Apttus__Status__c != ag.Apttus__Status__c && ag.Apttus__Status__c == AGREEMENT_STATUS_ACTIVATED) || (ag.Apttus__Status_Category__c == AGREEMENT_CATEGORY_IN_SIGNATURE && ag.Apttus__Status__c == AGREEMENT_STATUS_SIGNATURE_DECLINED)){
                    system.debug('Entered After Update event#####1');
                    
                    if(APTPS_AgreementTgrHandler.updateFAandDealOppflag){
                      handler1.updateFAandDealOpp(trigger.new,trigger.oldmap);     //EDGE-188898 and EDGE-203939
                    }
                    if(APTPS_AgreementTgrHandler.updateFAdetailsScheduleflag){
                        System.debug('updateFAdetailsSchedule**');
                      handler1.updateFAdetailsSchedule(trigger.new,trigger.oldmap);
                    }
                }
                //DIGI-19271 START
                try{
                    if(((ag.Apttus__Status_Category__c == AGREEMENT_CATEGORY_IN_SIGNATURE && Trigger.oldmap.get(ag.id).Apttus__Status__c != ag.Apttus__Status__c) || (ag.Apttus__Status_Category__c == APTPS_Constants.CANCELLED_STATUS_CATEGORY))){
                      //  handler1.agreementActivation(trigger.new,trigger.oldmap);
                        if( FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnableForAll__c==true &&  FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnabledFlows__c=='adobe' ){
							handler1.agreementActivation(trigger.new,trigger.oldmap);
                        handler1.updateAgreementStatus(trigger.new,trigger.oldmap);
                    }
                    }   
                    
                }
                catch(AgreementException agEx){
                     Agreementutilities.logException(agEx.methodName,agEx.referenceNumber,'',agEx.errorMessage,agEx.businessDescription);
                }
                //DIGI-19271 END 
            }
            runOnce = false;
        }        
    }
    //Before Update/Insert/delete logic
    if(Trigger.isbefore){  
        if(Trigger.isUpdate){
            handler.handleBeforeUpdateEvents(trigger.new, Trigger.oldMap);                      
        }
         if(Trigger.isDelete){
            handler.handleBeforeDeleteEvents(trigger.old);            
        }
        if(Trigger.isInsert){
            handler.handleBeforeInsertEvents(trigger.new);            
        }
    }
}