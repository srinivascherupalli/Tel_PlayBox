/******************************************************************
@Name: APTPS_AgreementTgrHandler
@Author: Vishal Arbune for 188898
@CreateDate: 23/11/2020
@Description: This is the handler class to stamp Agreement start date once Pricing contract sign off is received in the system from the
customer and status of Agreement record of Record Type = 'SA' is marked as 'In Effect'
@UsedBy: Agreement

Modified by Aarathi for EDGE 198013 for actions when status of Agreement record of Record Type = 'SA' is marked as 'In Signatures'

===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Monali GOlhar         22/02/2021      EDGE-194530 : <Customer moves from OCT to delegated pricing for a product family or in case of FA variations> Updates to price schedule record's start dates, end dates and FA status as part of price schedule variation scenarios.
2.            Aarathi Iyer          15/03/2021      EDGE-203939 : Update Opportunity stage to "Propose" when Frame Agreement status is Contract Generated
3.            Shivaprasad Patil     21/07/2021      EDGE-219168 : Effective End Date is not updated as per the Max. Contract term from Multiple products in FA variation
4.            Shivprasad patil      08/09/2021      DIGI-11225 RCS variation creation
5.         Shivaprasad Patil     21/09/2021    DIGI-16366: As a Customer, I would like the ability to decline the Contract Signature
6.           Lokesh Thathuru       07/10/2021   Update the code as a part of Adobe Implementation to update the ContractJunction Status
7.           Shubham Kumar          19/10/2021      DIGI-29165: Update SA Agreement status to Cancelled when Signature Declined.
******************************************************************/

public with sharing class APTPS_AgreementTgrHandler {
    
    private static final Id AGREEMENT_SA_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();    
    private static final Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
    private static final Id AGREEMENT_RCS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Related_Company_Schedule').getRecordTypeId();
    public static Decimal oppContractTerms = 0.0;  
    public static Decimal contractTerms = 0.0;    
    public static Boolean updateFAandDealOppflag = true;
    public static Boolean updateFAdetailsScheduleflag = true;
    public static Boolean updateAgreementToRecallFlag = true;
    public void updateFAandDealOpp(List<Apttus__APTS_Agreement__c> newList,map<id,Apttus__APTS_Agreement__c>oldmap) {
        updateFAandDealOppflag =false;
        Set<id> aggrementIds1 = new Set<id>();
        Set<id> dprIds1 = new Set<id>();
        Set<id> aggrementIds2 = new Set<id>();
        Set<id> dprIds2 = new Set<id>();
        List<id> frameAggrList1 = new List<id>();
        List<id> frameAggrList2 = new List<id>();
        List<csconta__Frame_Agreement__c> csFrameAgreementUpdate1 = new List<csconta__Frame_Agreement__c>();
        List<csconta__Frame_Agreement__c> csFrameAgreementUpdate2 = new List<csconta__Frame_Agreement__c>();        
        List<Apttus__APTS_Agreement__c> csAgrUpdate = new List<Apttus__APTS_Agreement__c>();
        List<Delegated_Pricing_Request__c> dprUpdate1 = new List<Delegated_Pricing_Request__c>();
        List<Delegated_Pricing_Request__c> dprUpdate2 = new List<Delegated_Pricing_Request__c>();
        List<FA_Agreement_Association__c> newPSFAAgreements = new List<FA_Agreement_Association__c>();
        system.debug('inside trigger' + newList);
        
        //Fetching AgreementId & DPRId associated with Agreement record where Status is Activated
        for(Apttus__APTS_Agreement__c ag1:newList) {
            if((oldmap.get(ag1.id).Apttus__Status_Category__c != ag1.Apttus__Status_Category__c) && ag1.Apttus__Status_Category__c =='In Effect' && (oldmap.get(ag1.id).Apttus__Status__c != ag1.Apttus__Status__c) && ag1.Apttus__Status__c =='Activated' && ag1.APTPS_Record_Type_Name__c =='SA') {
                aggrementIds1.add(ag1.id);
                dprIds1.add(ag1.Delegated_Pricing_Request__c);
                system.debug('inside loop for in effect agreement' + aggrementIds1);
                system.debug('inside loop for in effect agreement' + dprIds1);
            }
        }
        
        //Fetching AgreementId & DPRId associated with Agreement record where status is Signature Declined
        for(Apttus__APTS_Agreement__c ag2:newList) {
            if(ag2.Apttus__Status_Category__c =='In Signatures' && (oldmap.get(ag2.id).Apttus__Status__c != ag2.Apttus__Status__c) && ag2.Apttus__Status__c =='Signature Declined' && ag2.APTPS_Record_Type_Name__c =='SA') {
                aggrementIds2.add(ag2.id);
                dprIds2.add(ag2.Delegated_Pricing_Request__c);
            }
        }
        
        if(!aggrementIds1.isEmpty() && !dprIds1.isEmpty() && dprIds1 != null ){
            frameAggrList1 = fetchFrameAgreementIDContractGenerated(aggrementIds1, dprIds1);
            csAgrUpdate = agreementRecordUpdation(aggrementIds1);
            dprUpdate1 = dprRecordUpdationContractGenerated(dprIds1);
            system.debug('inside loop for fetch frame agreement' + frameAggrList1);
            
        }
        
        if(!aggrementIds2.isEmpty() && !dprIds2.isEmpty() && dprIds2 != null ){
            frameAggrList2 = fetchFrameAgreementIDContractRejected(aggrementIds2, dprIds2);
            dprUpdate2 = dprRecordUpdationContractRejected(dprIds2);
        }
        
        if (!frameAggrList1.isEmpty()){
            csFrameAgreementUpdate1 = frameAgreementRecordUpdationContractGenerated(frameAggrList1);
            system.debug('inside loop for is frameAggrList1.isEmpty' + frameAggrList1);
        }
        
        if (!frameAggrList2.isEmpty()){
            csFrameAgreementUpdate2 = frameAgreementRecordUpdationContractRejected(frameAggrList2);
        }
        
        /*if(!aggrementIds.isEmpty()){
csAgrUpdate = agreementRecordUpdation(aggrementIds);
} */            
        
        
        try{
            if(!Test.isRunningTest()){
                if (!csFrameAgreementUpdate1.isEmpty()){
                    update csFrameAgreementUpdate1;
                    update dprUpdate1;
                }
                if (!csFrameAgreementUpdate2.isEmpty()){
                    update csFrameAgreementUpdate2;
                    update dprUpdate2;
                }
                if (!csAgrUpdate.isEmpty()){
                    update csAgrUpdate;
                }
            }
            
        }catch (DmlException e) {
            System.debug('Exception while updating : ' + e.getMessage());
        }
    }
    /**
* @Author   :   Monali Golhar
* @Date     :   22/02/2021
* @Desc     :   Call methods to update FA,PS Agreement, DPR, and FA Agreement Association record on In Effect Activated
* @US       :   EDGE-194530
* @Status   :   Development
* */
    public void updateFAdetailsSchedule(List<Apttus__APTS_Agreement__c> newList,map<id,Apttus__APTS_Agreement__c>oldmap) {
        //   updateFAdetailsScheduleflag = false;
        Set<id> aggrementIds1 = new Set<id>();
        Set<id> dprIds1 = new Set<id>();
        Set<id> aggrementIds2 = new Set<id>();
        Set<id> dprIds2 = new Set<id>();
        Set<id> pSAggrementIds1 = new Set<id>();
        Set<id> pSDprIds1 = new Set<id>();
        Set<id> pSAggrementIds2 = new Set<id>();
        Set<id> pSDprIds2 = new Set<id>();
        Set<id> saAggrementIds = new Set<id>();
        List<id> frameAggrList1 = new List<id>();
        List<id> frameAggrList2 = new List<id>();
        List<csconta__Frame_Agreement__c> csFrameAgreementUpdate1 = new List<csconta__Frame_Agreement__c>();
        List<csconta__Frame_Agreement__c> csFrameAgreementUpdate2 = new List<csconta__Frame_Agreement__c>();        
        List<Apttus__APTS_Agreement__c> csAgrUpdate = new List<Apttus__APTS_Agreement__c>();
        List<Delegated_Pricing_Request__c> dprUpdate1 = new List<Delegated_Pricing_Request__c>();
        List<Delegated_Pricing_Request__c> dprUpdate2 = new List<Delegated_Pricing_Request__c>();
        List<FA_Agreement_Association__c> newPSFAAgreements = new List<FA_Agreement_Association__c>();
        Map<Id,Apttus__APTS_Agreement__c> idVsUpdateAgg = new Map<Id,Apttus__APTS_Agreement__c>();
        Map<Id,FA_Agreement_Association__c> idVsUpdateFAAgg = new Map<Id,FA_Agreement_Association__c>();
        List<id> nonRecentAgg = new List<id>();
        List<Apttus__APTS_Agreement__c> agreementListToUpdate = new List<Apttus__APTS_Agreement__c>();
        
        
        for(Apttus__APTS_Related_Agreement__c ifLatestAgg : [SELECT Apttus__APTS_Contract_From__r.Id,Apttus__APTS_Contract_To__c FROM Apttus__APTS_Related_Agreement__c WHERE Apttus__APTS_Contract_From__c IN:  newList]){
            nonRecentAgg.add(ifLatestAgg.Apttus__APTS_Contract_From__c);
        }                    
        System.debug('nonRecentAgg**'+nonRecentAgg);
        
        
        
        //EDGE-194530 For Price Schedule Agreement
        for(Apttus__APTS_Agreement__c ag1:newList) {
            system.debug('ag1**'+ag1);
            if(!nonRecentAgg.contains(ag1.Id)){
                system.debug('APTPS_AgreementTgrHandler:updateFAdetailsSchedule:Inside First loop'+ag1.Apttus__Status_Category__c+'**'+ag1.Apttus__Status__c);
                system.debug('oldmap.get(ag1.id).Apttus__Status_Category__c**'+oldmap.get(ag1.id).Apttus__Status_Category__c);
                system.debug('oldmap.get(ag1.id).Apttus__Status__c **'+oldmap.get(ag1.id).Apttus__Status__c );
                system.debug('ag1.APTPS_Record_Type_Name__c**'+ag1.APTPS_Record_Type_Name__c);  
                if((oldmap.get(ag1.id).Apttus__Status_Category__c != ag1.Apttus__Status_Category__c) && ag1.Apttus__Status_Category__c =='In Effect' && (oldmap.get(ag1.id).Apttus__Status__c != ag1.Apttus__Status__c) && ag1.Apttus__Status__c =='Activated' && (ag1.APTPS_Record_Type_Name__c =='Schedule' || ag1.APTPS_Record_Type_Name__c =='Related_Company_Schedule')) {        
                    //DIGI-11225 start
                    Boolean Ted_115 = Test.IsRunningTest()? true : FeatureEligibilityChecker.determineFeatureEligiblity('TED_115','');
                    if(Ted_115){
                        if(ag1.Apttus__Parent_Agreement__c != null /*&& ag1.RecordTypeId == AGREEMENT_Schedule_RECORDTYPEID*/ && ag1.VariationType__c != null){
                            
                            List<string> str = ag1.VariationType__c.split(';');
                            if(str.contains('Price Schedule') && str.contains('Related Company')){
                                saAggrementIds.add(ag1.Apttus__Parent_Agreement__c);
                            }              
                        }
                    }
                    
                    pSAggrementIds1.add(ag1.id);
                    pSDprIds1.add(ag1.Delegated_Pricing_Request__c);
                    system.debug('APTPS_AgreementTgrHandler:updateFAdetailsSchedule:Inside First loop'+pSAggrementIds1+'**'+pSDprIds1);
                }
                updateFAdetailsScheduleflag = false;
            }
        }
        Boolean Ted_115 = Test.IsRunningTest()? true : FeatureEligibilityChecker.determineFeatureEligiblity('TED_115','');
        if(Ted_115){
            List<Apttus__APTS_Agreement__c> siblingAgreement = [select id,Apttus__FF_Agreement_Number__c,Apttus__Contract_End_Date__c,Apttus__Term_Months__c, Apttus__Status__c,Apttus__Status_Category__c,Apttus__Parent_Agreement__c,Apttus__Source__c
                                                                from Apttus__APTS_Agreement__c where Apttus__Parent_Agreement__c IN :saAggrementIds AND Apttus__Status_Category__c NOT IN ('In Effect', 'Cancelled', 'Amended') /*AND RecordTypeId =:AGREEMENT_RCS_RECORDTYPEID*/];
            system.debug('####Sibling##'+siblingAgreement);
            if(siblingAgreement.size() > 0){
                for(Apttus__APTS_Agreement__c siblingAgreementToUpdate : siblingAgreement){
                    siblingAgreementToUpdate.Apttus__Status_Category__c = 'In Effect';
                    siblingAgreementToUpdate.Apttus__Status__c = 'Activated';
                }
                agreementListToUpdate.addAll(siblingAgreement);
            }
            system.debug('####SiblingUpdated##'+siblingAgreement);
        }
        //DIGI-11225 End
        for(Apttus__APTS_Agreement__c ag2:newList) {
            if(ag2.Apttus__Status_Category__c =='In Signatures' && (oldmap.get(ag2.id).Apttus__Status__c != ag2.Apttus__Status__c) && ag2.Apttus__Status__c =='Signature Declined' && (ag2.APTPS_Record_Type_Name__c =='Schedule' || ag2.APTPS_Record_Type_Name__c =='Related_Company_Schedule')) {
                //DIGI-16366 Start
                if(ag2.Apttus__Parent_Agreement__c != null /*&& ag1.RecordTypeId == AGREEMENT_Schedule_RECORDTYPEID*/ && ag2.VariationType__c != null){
                    
                    List<string> str = ag2.VariationType__c.split(';');
                    if(str.contains('Price Schedule') && str.contains('Related Company')){
                        saAggrementIds.add(ag2.Apttus__Parent_Agreement__c);
                    }              
                }
                //DIGI-16366 End
                pSAggrementIds2.add(ag2.id);
                psDprIds2.add(ag2.Delegated_Pricing_Request__c);
            }
        }
        //DIGI-16366 Start
        List<Apttus__APTS_Agreement__c> siblingAgreementToCancel = [select id,APTPS_Record_Type_Name__c,RecordTypeId,Apttus__Version_Number__c,Apttus__FF_Agreement_Number__c,Apttus__Contract_End_Date__c,Apttus__Term_Months__c, Apttus__Status__c,Apttus__Status_Category__c,Apttus__Parent_Agreement__c,Apttus__Source__c, (select Id,APTPS_Account__c from Related_Companies__r) from Apttus__APTS_Agreement__c where Apttus__Parent_Agreement__c IN :saAggrementIds AND Apttus__Status_Category__c NOT IN ('In Effect', 'Cancelled', 'Amended') /*AND RecordTypeId =:AGREEMENT_RCS_RECORDTYPEID*/];
        system.debug('####siblingAgreementToCancel##'+siblingAgreementToCancel);
        if(siblingAgreementToCancel.size() > 0){
            Apttus__APTS_Agreement__c parentAgmt = new Apttus__APTS_Agreement__c();
            parentAgmt.Id = siblingAgreementToCancel[0].Apttus__Parent_Agreement__c;
            Boolean isSubCatUpdated = false;
            
            for(Apttus__APTS_Agreement__c siblingAgreementToUpdate : siblingAgreementToCancel){
                siblingAgreementToUpdate.Apttus__Status_Category__c = 'Cancelled';
                siblingAgreementToUpdate.Apttus__Status__c = 'Cancelled Request';
                if(siblingAgreementToUpdate.RecordTypeId == AGREEMENT_RCS_RECORDTYPEID && siblingAgreementToUpdate.Apttus__Version_Number__c  == 0){
					parentAgmt.APTPS_Validation_on_Fully_Signed__c = true;
                    parentAgmt.APTPS_Agreement_Subcategory__c = 'Single Customer';
                    isSubCatUpdated = true;
                    system.debug('####parentAgmt.APTPS_Agreement_Subcategory__c'+parentAgmt.APTPS_Agreement_Subcategory__c);
                }
                if(siblingAgreementToUpdate.RecordTypeId == AGREEMENT_RCS_RECORDTYPEID && siblingAgreementToUpdate.Apttus__Version_Number__c  > 0 && siblingAgreementToUpdate.Related_Companies__r.size() == 0 ){
                    parentAgmt.APTPS_Validation_on_Fully_Signed__c = true;
					parentAgmt.APTPS_Agreement_Subcategory__c = 'Comany Group';
                    isSubCatUpdated = true;
                    system.debug('####parentAgmt.APTPS_Agreement_Subcategory__c'+parentAgmt.APTPS_Agreement_Subcategory__c);
                }
            }
            if(isSubCatUpdated){
                siblingAgreementToCancel.add(parentAgmt);    
            }
            agreementListToUpdate.addAll(siblingAgreementToCancel);
        }
        
        update agreementListToUpdate;
        //DIGI-16366 End
        //EDGE-194530 End  
        
        //EDGE-194530
        if(!pSAggrementIds1.isEmpty() && !pSDprIds1.isEmpty() && psDprIds1 != null ){
            frameAggrList1 = fetchFrameAgreementIDContractGenerated(pSAggrementIds1, pSDprIds1);
            csAgrUpdate = pSAgreementRecordUpdation(pSAggrementIds1,frameAggrList1);
            dprUpdate1 = dprRecordUpdationContractGenerated(pSDprIds1);
            System.debug('dprUpdate1'+dprUpdate1);
            newPSFAAgreements = dSAFrageAgreementAssociationRecoredCreation(pSAggrementIds1,pSDprIds1);
        }
        if(!pSAggrementIds2.isEmpty()){
            if(!psDprIds2.isEmpty() && psDprIds2 != null){
                frameAggrList2 = fetchFrameAgreementIDContractRejectedScheduled(pSAggrementIds2, psDprIds2);
                dprUpdate2 = dprRecordUpdationContractRejected(psDprIds2);
            }
            csAgrUpdate = pSAgreementRecordUpdationRejected(pSAggrementIds2,psDprIds2);
        }
        //EDGE-194530 End
        
        if (!frameAggrList1.isEmpty()){
            csFrameAgreementUpdate1 = frameAgreementRecordUpdationContractGenerated(frameAggrList1);
        }
        
        if (!frameAggrList2.isEmpty()){
            csFrameAgreementUpdate2 = frameAgreementRecordUpdationContractRejected(frameAggrList2);
        }
        
        /*if(!aggrementIds.isEmpty()){
csAgrUpdate = agreementRecordUpdation(aggrementIds);
} */    
        for(Apttus__APTS_Agreement__c ag : csAgrUpdate){
            idVsUpdateAgg.put(ag.Id, ag);
        }
        
        for(FA_Agreement_Association__c ag : newPSFAAgreements){
            idVsUpdateFAAgg.put(ag.Id, ag);
        }
        
            if(!Test.isRunningTest()){
                if (!csFrameAgreementUpdate1.isEmpty()){
                    update csFrameAgreementUpdate1;
                    update dprUpdate1;
                }
                if (!csFrameAgreementUpdate2.isEmpty()){
                    update csFrameAgreementUpdate2;
                    update dprUpdate2;
                }
                if (!csAgrUpdate.isEmpty()){
                    update idVsUpdateAgg.values();
                }
                //EDGE-194530  
                if (!newPSFAAgreements.isEmpty()){
                    update idVsUpdateFAAgg.values();
                }
                //EDGE-194530 End
                //update dprUpdate;
            }
            
            
        
    }  
    
    //Fetching Frame agreement association record associated with Agreement record where Status is Activated
    public static List<id> fetchFrameAgreementIDContractGenerated(Set<id> aggrementIds1, Set<id> dprIds1){
        system.debug('APTPS_AgreementTgrHandler:updateFAdetailsSchedule:Inside First loop'+aggrementIds1+'**'+dprIds1);
        List<id> frameAggrList1 = new List<id>();
        List<FA_Agreement_Association__c> associationList = new List<FA_Agreement_Association__c>([Select id,FA__c From FA_Agreement_Association__c Where FA__r.Delegated_Pricing_Request__c in:dprIds1 order by createdDate Desc limit 1]);
        //List<FA_Agreement_Association__c> associationList = new List<FA_Agreement_Association__c>([Select id,FA__c From FA_Agreement_Association__c Where FA__r.Delegated_Pricing_Request__c in:dprIds1 LIMIT 1]);
        if (!associationList.isEmpty()){
            for(FA_Agreement_Association__c ac:associationList) {
                frameAggrList1.add(ac.FA__c);
            }
        }
        system.debug('APTPS_AgreementTgrHandler:updateFAdetailsSchedule:Inside First loop'+frameAggrList1);
        return frameAggrList1;
    }
    
    //Fetching Frame agreement association record associated with Agreement record where Status is Signature Declined
    public static List<id> fetchFrameAgreementIDContractRejected(Set<id> aggrementIds2, Set<id> dprIds2){
        List<id> frameAggrList2 = new List<id>();
        List<FA_Agreement_Association__c> associationList = new List<FA_Agreement_Association__c>([Select id,FA__c From FA_Agreement_Association__c Where Agreement__c IN:aggrementIds2 and FA__r.Delegated_Pricing_Request__c in:dprIds2 order by createdDate Desc LIMIT 1]);
        if (!associationList.isEmpty()){
            for(FA_Agreement_Association__c ac:associationList) {
                frameAggrList2.add(ac.FA__c);
            }
        }
        return frameAggrList2;
    }
    
    
    //EDGE-194530
    public static List<id> fetchFrameAgreementIDContractRejectedScheduled(Set<id> pSAggrementIds2, Set<id> pSDprIds2){
        List<id> frameAggrList2 = new List<id>();
        List<FA_Agreement_Association__c> associationList = new List<FA_Agreement_Association__c>([select id, FA__r.csconta__Status__c , Agreement__c  from FA_Agreement_Association__c where FA__r.Delegated_Pricing_Request__c in:pSDprIds2 ]);
        if (!associationList.isEmpty()){
            for(FA_Agreement_Association__c ac:associationList) {
                frameAggrList2.add(ac.FA__c);
            }
        }
        return frameAggrList2;
    }
    //EDGE-194530 End
    
    //Calculate Date with adding Opportunities Contract term as Month
    public static Date calculateDate(Decimal term){
        Date calculatedDate = Date.Today().addMonths(Integer.valueOf(term));
        return calculatedDate;
    }
    
    //Calculate DateTime with adding Opportunities Contract term as Month
    public static DateTime calculateDateTime(Decimal term){
        DateTime currentDateTime = DateTime.now().addMonths(Integer.valueOf(term));
        return currentDateTime;
    }
    
    //EDGE-219473 Setting FA end date in multi product scenario
    public static List<csconta__Frame_Agreement__c> frameAgreementRecordUpdationContractGenerated(List<id> frameAggrList1){
        DPR_Offer__c maxEndDateDPROffer = new DPR_Offer__c();
        List<csconta__Frame_Agreement__c> csFrameAgrUpdate =[Select Id,Delegated_Pricing_Request__r.Id,csconta__Status__c,Contract_Acceptance_Date__c,csconta__effective_start_date__c, csconta__effective_end_date__c,Opportunity__c,Opportunity__r.StageName,Opportunity__r.Contract_Term__c From csconta__Frame_Agreement__c Where ID IN:frameAggrList1 LIMIT 1];                  
        if (csFrameAgrUpdate.size()<=0){ return csFrameAgrUpdate;}
        maxEndDateDPROffer= UpdateContractDateinDPROffer(csFrameAgrUpdate[0].Delegated_Pricing_Request__r.ID);
        csFrameAgrUpdate[0].csconta__Status__c ='Contract Generated';
        csFrameAgrUpdate[0].Opportunity__r.StageName = 'Propose';//EDGE-203939 by team Amsterdam
        if(csFrameAgrUpdate[0].csconta__effective_start_date__c == null){              
            csFrameAgrUpdate[0].csconta__effective_start_date__c = DateTime.now();
        }
        //EDGE-219168 start
        if(maxEndDateDPROffer.ContractEndDate__c != null){
            csFrameAgrUpdate[0].csconta__effective_end_date__c = maxEndDateDPROffer.ContractEndDate__c;
            UpdateContractTerminOpportunity(csFrameAgrUpdate[0].Opportunity__c,maxEndDateDPROffer.ContractEndDate__c);
        }
        //EDGE-219168 End
        return csFrameAgrUpdate;
    }
    //EDGE-219474 Adding contract start and end date for each product family and calculating max contract end date among all families
    public static DPR_Offer__c UpdateContractDateinDPROffer(id dprid){
        List<DPR_Offer__c> DPROfferstobeupdated = new List<DPR_Offer__c>();
        DPR_Offer__c maxEndDateDPROffer = new DPR_Offer__c();
        List<DPR_Offer__c> DPROfferID= [Select Id,ContractStartDate__c,ContractEndDate__c,PF_Contract_Term__c from DPR_Offer__c where Delegated_Pricing_Request__r.Id =:dprid];
        if (DPROfferID.size()==0) {
            return maxEndDateDPROffer;
        }
        maxEndDateDPROffer = DPROfferID[0];
        for(DPR_Offer__c DPRContractDate:DPROfferID){
            if (DPRContractDate.ContractEndDate__c==Null){
                DPRContractDate.ContractStartDate__c= DateTime.now();
                DPRContractDate.ContractEndDate__c= calculateDateTime(DPRContractDate.PF_Contract_Term__c);
                DPROfferstobeupdated.add(DPRContractDate);
            }
            if( DPRContractDate.ContractEndDate__c > maxEndDateDPROffer.ContractEndDate__c)
            {maxEndDateDPROffer = DPRContractDate;
            }
        }
        
        if(DPROfferstobeupdated.size()>0){
            update DPROfferstobeupdated;
        }
        return maxEndDateDPROffer;
    }
    //EDGE- 219740 Setting Opportunity contract term as highest among all the product family contract terms
    public static void UpdateContractTerminOpportunity(id Opptyid,DateTime effectiveEndDate){  
        List<Opportunity> OpportunityContractTerm =[Select ID,Contract_Term__c From opportunity Where id=:Opptyid];                  
        DateTime dT = datetime.now() ;
        Date todaysDate = date.newinstance(dT.year(), dT.month(), dT.day());
        Date endDate = date.newinstance(effectiveEndDate.year(), effectiveEndDate.month(), effectiveEndDate.day());
        
        Integer monthDiff = todaysDate.monthsBetween(endDate);
        
        if(endDate.day() > todaysDate.day()){
            monthDiff++;
        }
        
        OpportunityContractTerm[0].Contract_Term__c= monthDiff;
        update OpportunityContractTerm;
    }
    //Updating Frame Agreement field values as contract rejected
    public static List<csconta__Frame_Agreement__c> frameAgreementRecordUpdationContractRejected(List<id> frameAggrList2){
        List<csconta__Frame_Agreement__c> csFrameAgrUpdate =  new List<csconta__Frame_Agreement__c>();                  
        for(csconta__Frame_Agreement__c csFrameAgreement:[Select ID,csconta__Status__c From csconta__Frame_Agreement__c Where ID IN:frameAggrList2 LIMIT 1]) {
            csFrameAgreement.csconta__Status__c ='Contract Rejected';  
            csFrameAgrUpdate.add(csFrameAgreement);
        }  
        return csFrameAgrUpdate;
    }
    
    //Updating Agreement
    public static List<Apttus__APTS_Agreement__c> agreementRecordUpdation(Set<id> aggrementIds1){
        List<Apttus__APTS_Agreement__c> csAgrUpdate =  new List<Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c csAgreement:[Select id,APTPS_Record_Type_Name__c,Apttus__Company_Signed_Date__c,Apttus__Other_Party_Signed_Date__c,Apttus__Agreement_Category__c, Apttus__Contract_Start_Date__c, Apttus__Contract_End_Date__c, APTPS_Effective_End_Date__c,Apttus__Related_Opportunity__r.Contract_Term__c From Apttus__APTS_Agreement__c Where id IN:aggrementIds1 LIMIT 1]) {
            contractTerms = csAgreement.Apttus__Related_Opportunity__r.Contract_Term__c;
            //csAgreement.Apttus__Contract_Start_Date__c = Date.Today();
            if(csAgreement.APTPS_Record_Type_Name__c == 'SA' && csAgreement.Apttus__Agreement_Category__c == 'Digital Services'){
                IF ((csAgreement.Apttus__Company_Signed_Date__c == null ) && (csAgreement.Apttus__Other_Party_Signed_Date__c == null)) {
                    csAgreement.Apttus__Contract_Start_Date__c = system.today();
                }else if (csAgreement.Apttus__Company_Signed_Date__c != null && csAgreement.Apttus__Other_Party_Signed_Date__c != null) {
                    csAgreement.Apttus__Contract_Start_Date__c = csAgreement.Apttus__Company_Signed_Date__c;
                }else if (csAgreement.Apttus__Company_Signed_Date__c != null) {
                    csAgreement.Apttus__Contract_Start_Date__c = csAgreement.Apttus__Company_Signed_Date__c;
                }else {
                    csAgreement.Apttus__Contract_Start_Date__c = csAgreement.Apttus__Other_Party_Signed_Date__c;
                }
            }
            system.debug('startdate'+csAgreement.Apttus__Contract_Start_Date__c);
            if(contractTerms!=null){
                csAgreement.Apttus__Contract_End_Date__c = calculateDate(contractTerms);
                csAgreement.APTPS_Effective_End_Date__c = calculateDate(contractTerms);
            }
            csAgrUpdate.add(csAgreement);
        }
        return csAgrUpdate;
    }
    
    //Updating deal status field value as contract generated
    public static List<Delegated_Pricing_Request__c> dprRecordUpdationContractGenerated(Set<id> dprIds1){
        List<Delegated_Pricing_Request__c> dprRecordUpdate1 =  new List<Delegated_Pricing_Request__c>();
        System.debug('dprIds1'+dprIds1);
        for(Delegated_Pricing_Request__c dprRecord : [Select ID, Deal_Status__c from Delegated_Pricing_Request__c where ID IN:dprIds1 LIMIT 1]){
            System.debug('dprRecord'+dprRecord);
            dprRecord.Deal_Status__c = 'Contract Generated';
            dprRecordUpdate1.add(dprRecord);            
        }  
        return dprRecordUpdate1;
    }
    
    //Updating deal status field value as contract rejected
    public static List<Delegated_Pricing_Request__c> dprRecordUpdationContractRejected(Set<id> dprIds2){
        List<Delegated_Pricing_Request__c> dprRecordUpdate2 =  new List<Delegated_Pricing_Request__c>();
        for(Delegated_Pricing_Request__c dprRecord : [Select ID, Deal_Status__c from Delegated_Pricing_Request__c where ID IN:dprIds2 LIMIT 1]){
            dprRecord.Deal_Status__c = 'Contract Rejected';
            dprRecordUpdate2.add(dprRecord);            
        }  
        return dprRecordUpdate2;
    }
    
    /**
* @Author   :   Monali Golhar
* @Date     :   22/02/2021
* @Desc     :   Agreement record updation New and Old
* @US       :   EDGE-194530
* @Status   :   Development
* */
    //Agreement Record updation for PS Agreement Accepted
    public static List<Apttus__APTS_Agreement__c> pSAgreementRecordUpdation(Set<id> aggrementIds1,List<Id> frameAggrList1){
        system.debug('aggrementIds1'+aggrementIds1);
        List<Apttus__APTS_Agreement__c> csAgrUpdate =  new List<Apttus__APTS_Agreement__c>();
        List<Id> aggId = new List<Id>();
        Map<Id,Date> fAVsDSAEndDate  =  new Map<Id,Date>();
        Map<Id,Decimal> fAVsDSATerms= new Map<Id,Decimal>();
        Map<Id,Id> aggVsFA = new Map<Id,Id>();
        //Take out Parent DSA Record
        For(FA_Agreement_Association__c activeDSAAssociation : [Select id,Agreement__r.Id,Agreement__r.Apttus__Contract_End_Date__c,FA__r.Id, FA__r.csconta__Status__c,Agreement__r.Apttus__Related_Opportunity__r.Contract_Term__c From FA_Agreement_Association__c Where  FA__c in:frameAggrList1 And Agreement__r.APTPS_Record_Type_Name__c = 'SA' ]){
            system.debug('activeDSAAssociation'+activeDSAAssociation);
            system.debug('activeDSAAssociation'+activeDSAAssociation.FA__r.csconta__Status__c);
            system.debug('activeDSAAssociation'+activeDSAAssociation.Agreement__r.Apttus__Contract_End_Date__c);
            system.debug('activeDSAAssociation'+activeDSAAssociation.Agreement__r.Apttus__Related_Opportunity__r.Contract_Term__c);
            if(activeDSAAssociation.FA__r.csconta__Status__c == 'Active' ){
                //    fAVsDSAEndDate.put(activeDSAAssociation.FA__r.Id,activeDSAAssociation.Agreement__r.Apttus__Contract_End_Date__c);
                fAVsDSAEndDate.put(activeDSAAssociation.Agreement__r.Id,activeDSAAssociation.Agreement__r.Apttus__Contract_End_Date__c);
                fAVsDSATerms.put(activeDSAAssociation.Agreement__r.Id,activeDSAAssociation.Agreement__r.Apttus__Related_Opportunity__r.Contract_Term__c);
                
                system.debug('fAVsDSATerms'+fAVsDSATerms);
            }
        }      
        for(Apttus__APTS_Agreement__c csAgreement:[Select id,APTPS_Record_Type_Name__c,Apttus__Agreement_Category__c,Apttus__Company_Signed_Date__c,Apttus__Other_Party_Signed_Date__c,  Apttus__Parent_Agreement__c, Apttus__Contract_Start_Date__c, Apttus__Contract_End_Date__c, APTPS_Effective_End_Date__c,Apttus__Related_Opportunity__r.Contract_Term__c From Apttus__APTS_Agreement__c Where ID IN:aggrementIds1]) {
            system.debug('Inside loop contractTerms');
            contractTerms = csAgreement.Apttus__Related_Opportunity__r.Contract_Term__c;
            system.debug('contractTerms'+contractTerms);
            //csAgreement.Apttus__Contract_Start_Date__c = Date.Today();
            if((csAgreement.APTPS_Record_Type_Name__c == 'Schedule' || csAgreement.APTPS_Record_Type_Name__c =='Related_Company_Schedule') && csAgreement.Apttus__Agreement_Category__c == 'Pricing'){
                IF ((csAgreement.Apttus__Company_Signed_Date__c == null ) && (csAgreement.Apttus__Other_Party_Signed_Date__c == null)) {
                    csAgreement.Apttus__Contract_Start_Date__c = system.today();
                }else if (csAgreement.Apttus__Company_Signed_Date__c != null && csAgreement.Apttus__Other_Party_Signed_Date__c != null) {
                    csAgreement.Apttus__Contract_Start_Date__c = csAgreement.Apttus__Company_Signed_Date__c;
                }else if (csAgreement.Apttus__Company_Signed_Date__c != null) {
                    csAgreement.Apttus__Contract_Start_Date__c = csAgreement.Apttus__Company_Signed_Date__c;
                }else {
                    csAgreement.Apttus__Contract_Start_Date__c = csAgreement.Apttus__Other_Party_Signed_Date__c;
                }
            }
            system.debug('startdate'+csAgreement.Apttus__Contract_Start_Date__c);
            system.debug('fAVsDSAEndDate'+fAVsDSAEndDate);
            system.debug('fAVsDSATerms'+fAVsDSATerms);
            if(fAVsDSAEndDate.containskey(csAgreement.Apttus__Parent_Agreement__c)){
                system.debug('inside PARENT DSA Date');
                csAgreement.Apttus__Contract_End_Date__c = fAVsDSAEndDate.get(csAgreement.Apttus__Parent_Agreement__c);
                csAgreement.APTPS_Effective_End_Date__c = fAVsDSAEndDate.get(csAgreement.Apttus__Parent_Agreement__c);
            }
            else if(contractTerms!=null){
                csAgreement.Apttus__Contract_End_Date__c = calculateDate(contractTerms);
                csAgreement.APTPS_Effective_End_Date__c = calculateDate(contractTerms);
            }
            if(fAVsDSATerms.containskey(csAgreement.Apttus__Parent_Agreement__c)){
                system.debug('inside BuyingWindow');
                csAgreement.APTPS_buyingWindow__c=fAVsDSATerms.get(csAgreement.Apttus__Parent_Agreement__c);
            }
            
            csAgrUpdate.add(csAgreement);
        }
        for(Apttus__APTS_Related_Agreement__c aggJun : [SELECT Apttus__APTS_Contract_From__r.Id,Apttus__APTS_Contract_To__c FROM Apttus__APTS_Related_Agreement__c WHERE Apttus__APTS_Contract_To__c IN: aggrementIds1]) {
            aggId.add(aggJun.Apttus__APTS_Contract_From__r.Id);
        }
        if(!aggId.isEmpty()){
            for(Apttus__APTS_Agreement__c oldAgreement : [Select id,Apttus__Status_Category__c,Apttus__Status__c   From Apttus__APTS_Agreement__c Where Id IN:aggId]){
                if(oldAgreement.Apttus__Status_Category__c != 'Amended' && oldAgreement.Apttus__Status__c != 'Superseded'){
                    oldAgreement.Apttus__Status_Category__c = 'Amended';
                    oldAgreement.Apttus__Status__c = 'Superseded';
                    csAgrUpdate.add(oldAgreement);
                }
            }
        }
        return csAgrUpdate;
    }
    /**
* @Author   :   Monali Golhar
* @Date     :   22/02/2021
* @Desc     :   Agreement Record updation contract Rejected
* @US       :   EDGE-194530
* @Status   :   Development
* */
    //Agreement Record updation for PS Agreement Rejected
    public static List<Apttus__APTS_Agreement__c> pSAgreementRecordUpdationRejected(Set<id> aggrementIds2 , Set<id> psDprIds2){
        List<Apttus__APTS_Agreement__c> csAgrUpdate =  new List<Apttus__APTS_Agreement__c>();
        List<Id> aggId = new List<Id>();
        Apttus__APTS_Agreement__c parentAgmt = new Apttus__APTS_Agreement__c();
        List<Id> cjIdList =new List<Id>();
        List<cscfga__Product_Basket__c> pbList = new List<cscfga__Product_Basket__c>();
        List<ContractJunction__c> cjList = new List<ContractJunction__c>();
        for(Apttus__APTS_Agreement__c csAgreement:[Select id,Apttus__Status__c,Apttus__Status_Category__c,Apttus__Parent_Agreement__r.Apttus__Status_Category__c,(Select APTPS_Account__c from Related_Companies__r),RecordTypeId,APTPS_Agreement_Subcategory__c,Apttus__Parent_Agreement__c,Apttus__Version_Number__c,Related_Basket__c,Related_Contract__c,Related_Contract__r.Id From Apttus__APTS_Agreement__c Where ID IN:aggrementIds2 ]) {
            if(csAgreement.Apttus__Parent_Agreement__c !=null){
                parentAgmt.Id = csAgreement.Apttus__Parent_Agreement__c;
                if(csAgreement.Apttus__Parent_Agreement__r.Apttus__Status_Category__c == APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY  || csAgreement.Apttus__Parent_Agreement__r.Apttus__Status_Category__c == APTPS_Constants.IN_SIGNATURES_STATUS_CATEGORY || csAgreement.Apttus__Parent_Agreement__r.Apttus__Status_Category__c == APTPS_Constants.IN_FILING_STATUS_CATEGORY){
                    parentAgmt.Apttus__Status__c = APTPS_Constants.CANCELLEDREQUEST;
                    parentAgmt.Apttus__Status_Category__c = APTPS_Constants.CANCELLED_STATUS_CATEGORY;
                }
            }
            csAgreement.Apttus__Status__c = 'Cancelled Request';
            csAgreement.Apttus__Status_Category__c='Cancelled';
            //DIGI-29165 Start
            if(csAgreement.Related_Basket__c != null  && csAgreement.Related_Contract__c != null ){
                cjIdList.add(csAgreement.Related_Contract__r.Id);
            }
            //DIGI-29165 End
            //DIGI-16366 Start
            if(csAgreement.RecordTypeId == AGREEMENT_RCS_RECORDTYPEID && csAgreement.Apttus__Version_Number__c  == 0){
                parentAgmt.APTPS_Validation_on_Fully_Signed__c = true;
				parentAgmt.APTPS_Agreement_Subcategory__c = 'Single Customer';
            }
            if(csAgreement.RecordTypeId == AGREEMENT_RCS_RECORDTYPEID && csAgreement.Apttus__Version_Number__c  > 0 && csAgreement.Related_Companies__r.size() == 0 ){
				parentAgmt.APTPS_Validation_on_Fully_Signed__c = true;
                parentAgmt.APTPS_Agreement_Subcategory__c = 'Comany Group';
                
            }
            //DIGI-16366 End
            csAgrUpdate.add(csAgreement);
        }
        if(parentAgmt.id !=null){
            csAgrUpdate.add(parentAgmt);
        }
        //DIGI-29165 Start    
        if(!cjIdList.isEmpty()){
            for(ContractJunction__c cj : [SELECT Id , Status__c , Related_Basket__r.csordtelcoa__Basket_Stage__c ,Related_Basket__c  ,isTransitionContract__c  FROM ContractJunction__c WHERE Id IN: cjIdList]){
                cj.Status__c = APTPS_Constants.SIGNATUREDECLINED;
                cjList.add(cj) ;
                if(cj.Related_Basket__c  != null ){
                    cscfga__Product_Basket__c pb = new cscfga__Product_Basket__c();  
                    pb.Id = cj.Related_Basket__c  ;
                    pb.csordtelcoa__Basket_Stage__c = APTPS_Constants.CONTRACTREJECTED;
                    pbList.add(pb);
                }
            }
        }
        if(!Test.isRunningTest()){
            if (!pbList.isEmpty()){
                update pbList;
            }
            if (!cjList.isEmpty()){
                update cjList;
            }
        }
        //DIGI-29165 End
        for(Apttus__APTS_Related_Agreement__c aggJun : [SELECT Apttus__APTS_Contract_From__r.Id,Apttus__APTS_Contract_To__c FROM Apttus__APTS_Related_Agreement__c WHERE Apttus__APTS_Contract_To__c IN: aggrementIds2]) {
            aggId.add(aggJun.Apttus__APTS_Contract_From__r.Id);
        }
        if(!aggId.isEmpty()){
            for(Apttus__APTS_Agreement__c oldAgreement : [Select id,Apttus__Status_Category__c,Apttus__Status__c   From Apttus__APTS_Agreement__c  Where  Id IN:aggId]){
                if(oldAgreement.Apttus__Status__c == APTPS_Constants.BEINGAMENDED_STATUS && oldAgreement.Apttus__Status_Category__c == APTPS_Constants.IN_EFFECT_STATUS_CATEGORY){
                    oldAgreement.Apttus__Status__c = APTPS_Constants.ACTIVATED_STATUS;
                    oldAgreement.Apttus__Status_Category__c = APTPS_Constants.IN_EFFECT_STATUS_CATEGORY;
                    csAgrUpdate.add(oldAgreement);
                }
            }
        }
        return csAgrUpdate;
    }
    /**
* @Author   :   Monali Golhar
* @Date     :   22/02/2021
* @Desc     :   FA Agreement Record Updation New and Old
* @US       :   EDGE-194530
* @Status   :   Development
* */
    public static List<FA_Agreement_Association__c> dSAFrageAgreementAssociationRecoredCreation(Set<id> aggrementIds1, Set<id> pSDprIds1){
        List<Id> oldDPRId = new List<Id>();
        List<FA_Agreement_Association__c > updateFAAgreementAssociation = new List<FA_Agreement_Association__c >();
        for(Apttus__APTS_Related_Agreement__c aggJun : [SELECT Apttus__APTS_Contract_From__r.Id, Apttus__APTS_Contract_From__r.Delegated_Pricing_Request__c,Apttus__APTS_Contract_To__c,Apttus__APTS_Contract_To__r.Delegated_Pricing_Request__c FROM Apttus__APTS_Related_Agreement__c WHERE Apttus__APTS_Contract_To__r.Delegated_Pricing_Request__c IN: pSDprIds1]) {
            oldDPRId.add(aggJun.Apttus__APTS_Contract_From__r.Delegated_Pricing_Request__c);
        }
        //Update old FA AGreement Association to Active
        if(!oldDPRId.isEmpty()){
            For(FA_Agreement_Association__c associationList :[Select id,FA__r.Id,Agreement__r.Id,Agreement__r.APTPS_Parent_Agreement_Id__c  ,Agreement__r.APTPS_Variation_Identifier__c From FA_Agreement_Association__c Where FA__r.Delegated_Pricing_Request__c IN:oldDPRId]){ // Take old record
                associationList.Status__c = 'Amended';
                updateFAAgreementAssociation.add(associationList);
            }
        }
        //Update new FA AGreement Association to Active
        For(FA_Agreement_Association__c associationList :[Select id,FA__r.Id,Agreement__r.Id,Agreement__r.APTPS_Parent_Agreement_Id__c  ,Agreement__r.APTPS_Variation_Identifier__c From FA_Agreement_Association__c Where FA__r.Delegated_Pricing_Request__c IN:pSDprIds1]){
            associationList.Status__c = 'Active';
            updateFAAgreementAssociation.add(associationList);
        }
        
        return updateFAAgreementAssociation;
    }
    //EDGE-194530 End  
    //DIGI-19271 START
    public void updateAgreementStatus(List<Apttus__APTS_Agreement__c> newList,map<id,Apttus__APTS_Agreement__c>oldmap){
        system.debug('inside updateAgreementStatus method---');
        set<id>pSAggrementIds = new set<id>();
        try{
            for(Apttus__APTS_Agreement__c ag1:newList) {
                
                if(ag1.Apttus__Status__c == APTPS_Constants.SIGNATUREDECLINED && ag1.Apttus__Status_Category__c == APTPS_Constants.INSIGNATURES  && ag1.Apttus__Source__c==APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL && ag1.Related_Basket__c != null  && ag1.Related_Contract__c != null) {
                    system.debug('APTPS_AgreementTgrHandler:activateAgreement DECLINED ' + ag1.Related_Basket__c + ' ' + ag1.Related_Contract__c);
                    cjCancel(newList, oldmap);
                    system.debug('Checkpoint cjCancel:'+Limits.getQueries());
                    
                }
                if(ag1.Apttus__Status__c == APTPS_Constants.CANCELLEDREQUEST && ag1.Apttus__Status_Category__c == APTPS_Constants.CANCELLED_STATUS_CATEGORY  && ag1.Apttus__Source__c==APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL && ag1.Related_Basket__c != null  && ag1.Related_Contract__c != null) {
                    system.debug('APTPS_AgreementTgrHandler:activateAgreement cancelled ' + ag1.Related_Basket__c + ' ' + ag1.Related_Contract__c);
                    if(ag1.APTPS_Record_Type_Name__c =='Schedule'){
                        pSAggrementIds.add(ag1.Id);
                    }
                    cjCancel(newList, oldmap);
                    system.debug('Checkpoint2 cjCancel:'+Limits.getQueries());
                    
                }
                if(ag1.Related_Basket__c != null  && ag1.Related_Contract__c != null && ag1.Apttus__Status__c == APTPS_Constants.OTHERPARTYSIGN && ag1.Apttus__Status_Category__c == APTPS_Constants.INSIGNATURES && ag1.Apttus__Source__c==APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL) {
                    system.debug('APTPS_AgreementTgrHandler:activateAgreement OTHERPARTY  ' + ag1.Related_Basket__c + ' ' + ag1.Related_Contract__c);
                    cjOtherPartySign(newList, oldmap);
                    system.debug('Checkpoint cjOtherPartySign:'+Limits.getQueries());
                }
                
            }
            if(!pSAggrementIds.isEmpty())
                pSAgreementVariationRecordUpdation(pSAggrementIds);
        }
        
        catch(Exception ex){
            system.debug('######Exception######'+ ex.getMessage());
            String methodName = 'updateAgreementStatus ' ;
            String referenceNumber = '';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = 'class AgreementDealUtilities.createAgreementRecords at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx;
        }
    }
    public void agreementActivation(List<Apttus__APTS_Agreement__c> newList,map<id,Apttus__APTS_Agreement__c>oldmap){
        system.debug('inside updateAgreementStatus method---');
        set<id>pSAggrementIds = new set<id>();
        try{
            for(Apttus__APTS_Agreement__c ag1:newList) {
                if(ag1.Related_Basket__c != null  && ag1.Related_Contract__c != null && ag1.Apttus__Status__c == APTPS_Constants.FULLYSIGNED && ag1.Apttus__Status_Category__c == APTPS_Constants.INSIGNATURES && ag1.Apttus__Source__c==APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL && (ag1.APTPS_Record_Type_Name__c == 'Schedule' || ag1.APTPS_Record_Type_Name__c == 'Related_Company_Schedule')&& ag1.Apttus__Agreement_Category__c == 'Pricing') {
                    system.debug('APTPS_AgreementTgrHandler:activateAgreement FULLYSIGNED ' + ag1.Related_Basket__c + ' ' + ag1.Related_Contract__c);
                    cjActivation(newList, oldmap);
                    system.debug('Checkpoint cjActivation:'+Limits.getQueries());
                }
                
                if(ag1.Delegated_Pricing_Request__c != null  && ag1.Apttus__Status__c == APTPS_Constants.FULLYSIGNED && ag1.Apttus__Status_Category__c == APTPS_Constants.INSIGNATURES && ag1.Apttus__Source__c==APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL && (ag1.APTPS_Record_Type_Name__c == 'Schedule' || ag1.APTPS_Record_Type_Name__c == 'Related_Company_Schedule')&& ag1.Apttus__Agreement_Category__c == 'Pricing') {
                    system.debug('APTPS_AgreementTgrHandler:activateAgreement DPRFULLYSIGNED ' + ag1.Related_Basket__c + ' ' + ag1.Related_Contract__c);
                    dprActivation(newList, oldmap);
                    system.debug('Checkpoint dprActivation:'+Limits.getQueries());
                }
            }
        }
        
        catch(Exception ex){
            system.debug('######Exception######'+ ex.getMessage());
            String methodName = 'agreementActivation ' ;
            String referenceNumber = '';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = 'class AgreementDealUtilities.createAgreementRecords at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx;
        }
    }
    /**
* @Author   :   Charan
* @Date     :   22/10/2021
* @Desc     :   To handle the PS variation records when agreement is cancelled
* @US       :   DIGI-23889
* @Status   :   Development
* */
    public static void pSAgreementVariationRecordUpdation(Set<id> pSAggrementIds){
        system.debug('inside pSAgreementVariationRecordUpdation---');
        List<Apttus__APTS_Agreement__c> csAgrUpdate =  new List<Apttus__APTS_Agreement__c>();
        set<Id> aggId = new set<Id>();
        Apttus__APTS_Agreement__c agrToUpdate;
        
        
        for(Apttus__APTS_Related_Agreement__c aggJun : [SELECT Apttus__APTS_Contract_From__c,Apttus__APTS_Contract_To__c,Apttus__APTS_Contract_From__r.Apttus__Status__c,
                                                        Apttus__APTS_Contract_From__r.Apttus__Status_Category__c FROM Apttus__APTS_Related_Agreement__c WHERE Apttus__APTS_Contract_To__c IN: pSAggrementIds]) {
                                                            if(aggJun.Apttus__APTS_Contract_From__c!=null){
                                                                agrToUpdate = new Apttus__APTS_Agreement__c();
                                                                agrToUpdate.Id = aggJun.Apttus__APTS_Contract_From__c;
                                                                agrToUpdate.Apttus__Status__c = 'Activated';
                                                                agrToUpdate.Apttus__Status_Category__c ='In Effect';
                                                                csAgrUpdate.add(agrToUpdate);
                                                                aggId.add(aggJun.Apttus__APTS_Contract_To__c);
                                                            }
                                                            system.debug('updated schedule agreement to in effect----'+ aggId);                                              
                                                        }
        
        for(Apttus__APTS_Agreement__c childAgr : [select id,Apttus__Status__c,Apttus__Status_Category__c,Apttus__Parent_Agreement__c from Apttus__APTS_Agreement__c where id IN:pSAggrementIds]){
            if(aggId.contains(childAgr.id) && !aggId.isEmpty()){
                agrToUpdate = new Apttus__APTS_Agreement__c();
                agrToUpdate.Id = childAgr.Apttus__Parent_Agreement__c;
                agrToUpdate.Apttus__Status__c = 'Activated';
                agrToUpdate.Apttus__Status_Category__c ='In Effect';
                csAgrUpdate.add(agrToUpdate);
            }
            else{
                agrToUpdate = new Apttus__APTS_Agreement__c();
                agrToUpdate.Id = childAgr.Apttus__Parent_Agreement__c;
                agrToUpdate.Apttus__Status__c = APTPS_Constants.CANCELLEDREQUEST;
                agrToUpdate.Apttus__Status_Category__c =APTPS_Constants.CANCELLED_STATUS_CATEGORY;
                csAgrUpdate.add(agrToUpdate);
            }
        }
        
        try{
            if(!csAgrUpdate.isEmpty())
                update csAgrUpdate;
        }
        catch(Exception ex){
            system.debug('######Exception######'+ ex.getMessage());
            String methodName = 'pSAgreementVariationRecordUpdation ' ; 
            String referenceNumber = ''; 
            String errorMessage =  ex.getMessage(); 
            String businessDescriptionEX = 'class APTPS_AgreementTgrHandler.pSAgreementVariationRecordUpdation at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
    
    public void cjActivation(List<Apttus__APTS_Agreement__c> newList,map<id,Apttus__APTS_Agreement__c>oldmap) {
        Map<Id,Apttus__APTS_Agreement__c> aggrementIds1 = new Map<Id,Apttus__APTS_Agreement__c>();
        List<Id> cjIdList =new List<Id>();
        List<Id> pbIdList =new List<Id>();
        List<cscfga__Product_Basket__c> pbListUpdate = new List<cscfga__Product_Basket__c>();
        List<ContractJunction__c> cjListUpdate = new List<ContractJunction__c>();
        try{
            for(Apttus__APTS_Agreement__c ag1:newList) {
                // if(ag1.Related_Basket__c != null  && ag1.Related_Contract__c != null && ag1.Apttus__Status__c == 'Fully Signed' && ag1.Apttus__Status_Category__c == 'In Signatures' && ag1.Apttus__Agreement_Category__c == 'Pricing') {
                aggrementIds1.put(ag1.Id, ag1);
                cjIdList.add(ag1.Related_Contract__r.Id);
                pbIdList.add(ag1.Related_Basket__r.Id);
                //  }
            }
            system.debug('APTPS_AgreementTgrHandler:cjActivation ' + cjIdList );
            if(!aggrementIds1.isEmpty()){
                AgreementRecordStatusChange.changeAgreementStatus(aggrementIds1.values()) ;
            }
            if(!cjIdList.isEmpty()){
                for(ContractJunction__c cj : [SELECT Id , Status__c , Related_Basket__r.csordtelcoa__Basket_Stage__c ,Related_Basket__c  ,isTransitionContract__c  FROM ContractJunction__c WHERE Id IN: cjIdList]){
                    if(cj.isTransitionContract__c == false ){
                        cj.Status__c = APTPS_Constants.CONTRACTACCEPTED;
                        cjListUpdate.add(cj) ;
                    }
                    if(pbIdList.contains(cj.Related_Basket__r.Id)){
                        cscfga__Product_Basket__c pb = new cscfga__Product_Basket__c();  
                        pb.Id = cj.Related_Basket__c  ;
                        pb.csordtelcoa__Basket_Stage__c = APTPS_Constants.CONTRACTACCEPTED;
                        pbListUpdate.add(pb);
                        
                    }
                }
            }
            
            if(!Test.isRunningTest()){
                
                if (!pbListUpdate.isEmpty()){
                    update pbListUpdate;
                }
                
                if (!cjListUpdate.isEmpty()){
                    update cjListUpdate;
                }
                
            }
        }
        catch(Exception ex){
            system.debug('######Exception######'+ ex.getMessage());
            String methodName = 'cjActivation' ;
            String referenceNumber = '';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = 'class AgreementDealUtilities.createAgreementRecords at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx;
        }
    }  
    public void cjCancel(List<Apttus__APTS_Agreement__c> newList,map<id,Apttus__APTS_Agreement__c>oldmap) {
        system.debug('Inside cjCancel method---');
        Map<Id,string> cjIdMap =new Map<Id,string>();
        List<id> cjIdList = new List<id>();
        List<cscfga__Product_Basket__c> pbListUpdate = new List<cscfga__Product_Basket__c>();
        List<ContractJunction__c> cjListUpdate = new List<ContractJunction__c>();
        try{
            for(Apttus__APTS_Agreement__c ag1:newList) {
                //  if(ag1.Related_Basket__c != null  && ag1.Related_Contract__c != null && ag1.Apttus__Status__c == 'Signature Declined' && ag1.Apttus__Status_Category__c == 'In Signatures' && ag1.Apttus__Agreement_Category__c == 'Pricing') {
                cjIdMap.put(ag1.Related_Contract__c,ag1.Apttus__Status_Category__c);
                cjIdList.add(ag1.Related_Contract__c);
                //  }
            }
            system.debug('in list---'+cjIdList);
            if(!cjIdMap.isEmpty()){
                for(ContractJunction__c cj : [SELECT Id , Status__c , Related_Basket__r.csordtelcoa__Basket_Stage__c ,Related_Basket__c   FROM ContractJunction__c WHERE Id IN: cjIdList]){
                    if(cjIdMap.get(cj.id) == 'In Signatures')    
                        cj.Status__c = APTPS_Constants.CONTRACTJUNCTION_STATUS_SIGNATURE_DECLINED;
                    else{
                        cj.Status__c = APTPS_Constants.CONTRACTJUNCTION_STATUS_CANCELLED;
                    }
                    cjListUpdate.add(cj) ;
                    
                    if(cj.Related_Basket__c  != null ){
                        cscfga__Product_Basket__c pb = new cscfga__Product_Basket__c();  
                        pb.Id = cj.Related_Basket__c  ;
                        pb.csordtelcoa__Basket_Stage__c = APTPS_Constants.CONTRACTREJECTED;
                        pbListUpdate.add(pb);
                    }
                }
            }
            
            if(!Test.isRunningTest()){
                
                if (!pbListUpdate.isEmpty()){
                    update pbListUpdate;
                }
                
                if (!cjListUpdate.isEmpty()){
                    update cjListUpdate;
                }
                
            }
            
            
        }catch(Exception ex){
            system.debug('######Exception######'+ ex.getMessage());
            String methodName = 'cjCancel' ;
            String referenceNumber = '';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = 'class AgreementDealUtilities.createAgreementRecords at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx;
        }
    }  
    public void cjOtherPartySign(List<Apttus__APTS_Agreement__c> newList,map<id,Apttus__APTS_Agreement__c>oldmap) {
        List<Id> cjIdList =new List<Id>();
        List<cscfga__Product_Basket__c> pbListUpdate = new List<cscfga__Product_Basket__c>();
        List<ContractJunction__c> cjListUpdate = new List<ContractJunction__c>();
        try{
            for(Apttus__APTS_Agreement__c ag1:newList) {
                // if(ag1.Related_Basket__c != null  && ag1.Related_Contract__c != null && ag1.Apttus__Status__c == 'Other Party Signatures' && ag1.Apttus__Status_Category__c == 'In Signatures' && ag1.Apttus__Agreement_Category__c == 'Pricing') {
                cjIdList.add(ag1.Related_Contract__r.Id);
                //  }
            }
            if(!cjIdList.isEmpty()){
                for(ContractJunction__c cj : [SELECT Id , Status__c , Related_Basket__r.csordtelcoa__Basket_Stage__c ,Related_Basket__c  ,isTransitionContract__c  FROM ContractJunction__c WHERE Id IN: cjIdList]){
                    cj.Status__c = APTPS_Constants.CUSTOMERREVIEW;
                    cjListUpdate.add(cj) ;
                    
                }
            }
            
            
            if(!Test.isRunningTest()){
                
                if (!pbListUpdate.isEmpty()){
                    update pbListUpdate;
                }
                
                if (!cjListUpdate.isEmpty()){
                    update cjListUpdate;
                }
                
            }
        }catch(Exception ex){
            system.debug('######Exception######'+ ex.getMessage());
            String methodName = 'cjOtherPartySign' ;
            String referenceNumber = '';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = 'class AgreementDealUtilities.createAgreementRecords at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx;
        }
    }  
    public void dprActivation(List<Apttus__APTS_Agreement__c> newList,map<id,Apttus__APTS_Agreement__c>oldmap) {
        Map<Id,Apttus__APTS_Agreement__c> aggrementIds1 = new Map<Id,Apttus__APTS_Agreement__c>();
        List<Id> cjIdList =new List<Id>();
        List<cscfga__Product_Basket__c> pbListUpdate = new List<cscfga__Product_Basket__c>();
        List<ContractJunction__c> cjListUpdate = new List<ContractJunction__c>();
        
        try{
            for(Apttus__APTS_Agreement__c ag1:newList) {
                //     if(ag1.Delegated_Pricing_Request__c != null  && ag1.Related_Contract__c != null && ag1.Apttus__Status__c == 'Fully Signed' && ag1.Apttus__Status_Category__c == 'In Signatures' && ag1.Apttus__Agreement_Category__c == 'Pricing') {
                aggrementIds1.put(ag1.Id, ag1);
                //     }
            }
            if(!aggrementIds1.isEmpty()){
                AgreementRecordStatusChange.changeAgreementStatus(aggrementIds1.values()) ;
            }
            
        }catch(Exception ex){
            system.debug('######Exception######'+ ex.getMessage());
            String methodName = 'dprActivation' ;
            String referenceNumber = '';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = 'class AgreementDealUtilities.createAgreementRecords at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx;
        }
    }  
    //DIGI-19271 END  
    /**========================================================================================
* @Author :       Lokesh Thathuru
* @Description : This method helps to handleAfterUpdateEvents
* @CreatedDate : 10/5/2021
* @Param :  Map<id,Apttus__APTS_Agreement__c > mapNewAgreement
* @Param :  List<Apttus__APTS_Agreement__c> agreementList
* @Param :  Map<id,Apttus__APTS_Agreement__c > mapOldAgreement
*===========================================================================================*/
    public static void handleAfterUpdateEvents(Map<id,Apttus__APTS_Agreement__c > mapNewAgreement, List<Apttus__APTS_Agreement__c> agreementList, Map<id,Apttus__APTS_Agreement__c > mapOldAgreement)
    {
        //Added by Lokesh Thathuru as a part of Adobe Implementation - Start (10/6/2021)
        List<Apttus__APTS_Agreement__c> listOfAgreementsWithStatusAsWaitingforCounterSignatur=new List<Apttus__APTS_Agreement__c>();
        //Lokesh Thathuru End (10/6/2021)
        
        for(Apttus__APTS_Agreement__c agreement: agreementList) {
            //Added By Lokesh Thathuru the below filter as a part of Adobe User story- Start (10/6/2021) // Added the Null for Related_Contract__c
            if(agreement.Apttus__Company_Signed_Date__c==null && agreement.Apttus__Other_Party_Signed_Date__c!=null && agreement.Apttus__Other_Party_Signed_Date__c!=mapOldAgreement.get(agreement.Id).Apttus__Other_Party_Signed_Date__c && agreement.Related_Contract__c!=null ){
                listOfAgreementsWithStatusAsWaitingforCounterSignatur.add(agreement);
            }
            //End   Lokesh Thathuru (10/6/2021)
        }
        
        //Added By Lokesh Thathuru the below filter as a part of Adobe User story- Start
        if(listOfAgreementsWithStatusAsWaitingforCounterSignatur.size()>0){
            updateContractJunctionStatusAsPendingCountersign(listOfAgreementsWithStatusAsWaitingforCounterSignatur);
        }//End  Lokesh Thathuru (10/6/2021)
    }
    
    /**========================================================================================
* @Author :       Lokesh Thathuru
* @Description : This method helps to listOfAgreementsWithStatusAsWaitingforCounterSignatur
* @CreatedDate : 10/5/2021
* @Param :  listOfAgreementsWithStatusAsWaitingforCounterSignatur
*===========================================================================================*/
    @testVisible
    private static void updateContractJunctionStatusAsPendingCountersign(List<Apttus__APTS_Agreement__c> listOfAgreementsWithStatusAsWaitingforCounterSignatur){
        
        Map<Id,ContractJunction__c> mapOfcontractJunctionIds=new Map<id,ContractJunction__c>();
        try{
            if(listOfAgreementsWithStatusAsWaitingforCounterSignatur.size()>0){
                for(Apttus__APTS_Agreement__c apttusAgreementInstance:listOfAgreementsWithStatusAsWaitingforCounterSignatur){
                    if(!mapOfcontractJunctionIds.containsKey(apttusAgreementInstance.Related_Contract__c)){
                        ContractJunction__c contractJunctionInstance=new ContractJunction__c();
                        contractJunctionInstance.Id=apttusAgreementInstance.Related_Contract__c;
                        contractJunctionInstance.Status__c=APTPS_Constants.CONTRACTJUNCTION_STATUS_PENDING_COUNTERSIGN;
                        mapOfcontractJunctionIds.put(apttusAgreementInstance.Related_Contract__c,contractJunctionInstance);
                    }
                }
            }
            
            if(!mapOfcontractJunctionIds.isEmpty()){
                
                update mapOfcontractJunctionIds.Values();
            }
        }catch(Exception ex){
            String methodName = 'updateContractJunctionStatusAsPendingCountersign';
            String referenceNumber = '';
            if(mapOfcontractJunctionIds.values().size()>0)
                referenceNumber = mapOfcontractJunctionIds.values()[0].Id!=null ? String.valueOf(mapOfcontractJunctionIds.values()[0].Id):'';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = ' Exception for APTS Agreement :'+ referenceNumber  +' failed in class APTPS_AdobeAgreementTriggerHandler at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx;
        }
        
    }
    // End (10/6/2021)
}