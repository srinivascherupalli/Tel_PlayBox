/*
* AUTHOR : Shivaprasad
* TEAM: Napier
* EDGE-205066 Advance fund payment frequency allocation
* EDGE-203818 Fund related additional requirements
* DATE: 12/04/2021 
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Vishal Arbune          05/06/2021     EDGE-219119 :  Create allocation transaction for a New Fund(Advance Fund) on an existing Fund account
2.            Ankush Rana            08/06/2021     EDGE-219116 :  As a Sales/Partner user, When I have offered Fund (Flexi/Advance or No Fund) for a product during NEW FA journey, Then system should update Fund console data as "Allocated" on FA Activation
3.            Manish Berad           08/06/2021     EDGE-219164 : [Tech Story]: System should create a corresponding Provision amount record (with Negative $ value) against Advance Fund Allocation transaction during NEW and Variation FA journey
4.            Shashidhar Kumar       24/06/2021     EDGE-219471: Updated field Contract_Term to PF_Contract_Term
5.            Shivaprasad Patil      25/06/2021     EDGE-219475: Added field Fund Expiry (Fund Term)
6.            Shivaprasad Patil      14/07/2021     EDGE-228130: Tech Story: Governance team review updates
*/

public class OneFundRecordCreationController {
    
    public static id  advanceFundRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Committed').getRecordTypeId();
    public static id  flexiFundRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();
    public static id  oneFundAccrualRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();
    
    public static List<OneFund__c> createOneFund(List<csconta__Frame_Agreement__c> fa, List<DPR_Offer__c> dpr){
        
        
        OneFund__c accTypeOneFund = new OneFund__c();
        List<OneFund__c> lstOneFundToInsert=new List<OneFund__c>();
        
        List<OneFund__c> lstOfOneFund  = [Select ID,CIDN__c 
                                          from OneFund__c 
                                          where CIDN__c =:fa[0].csconta__Account__c
                                          and (RecordTypeId =: advanceFundRecId OR RecordTypeId =: flexiFundRecId)];
        system.debug('lstOfOneFund:::'+lstOfOneFund);
        if(!lstOfOneFund.isEmpty()){
            System.debug('OneFund account already exists, create transactions only');
            return lstOfOneFund;
        }
        
        
        accTypeOneFund.CIDN__c=fa[0].csconta__Account__c;
        accTypeOneFund.Start_Date__c=(fa[0].csconta__effective_start_date__c).Date();
        accTypeOneFund.Contract_Duration__c=String.valueOf(dpr[0].PF_Contract_term__c);
        accTypeOneFund.OneFund_Status__c='Active';
        accTypeOneFund.RecordTypeId=flexiFundRecId;
        
        System.debug('One Fund to be inserted');
        lstOneFundToInsert.add(accTypeOneFund);
        
       
        if(!lstOneFundToInsert.isEmpty()){
            
            Database.SaveResult[] saveResultList = Database.insert(lstOneFundToInsert);
            for (Database.SaveResult sr : saveResultList) {
                if (!sr.isSuccess()) {
                    System.debug('Issue in creating One Fund account :'+sr.getErrors());
                    return new List<OneFund__c>();
                }
            }
            //insert lstOneFundToInsert;
        }

        return lstOneFundToInsert;
    }
    
    public static Boolean createOneFundTransactions(List<OneFund__c> lstOfOneFundUpdated, List<csconta__Frame_Agreement__c> fa, List<DPR_Offer__c> dpr){

        List<OneFund_Transactions__c> oneFundTransList = new List<OneFund_Transactions__c>();
        
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        Boolean isMigration = (fa[0].Opportunity__r.Type == 'Migration' && profileName == System.Label.MigrationBOHUser)? true:false;
        
        
        if(isMigration){
            return false;
        }
        
        //Creates One Fund transactions for Advance Fund Type
        for(DPR_Offer__c dprOffer : dpr){
            OneFund_Transactions__c oneFundTrans = new OneFund_Transactions__c();
            OneFund_Transactions__c oneFundTraProvisional=new OneFund_Transactions__c();
            //EDGE-219119
            if(!dprOffer.isAllocated__c){
                if(dprOffer.Fund_Increment_Frequency__c == 'All In Advance'){
                    Double fundAmount =(dprOffer.Fund_Amount__c != null)?dprOffer.Fund_Amount__c : dprOffer.Fund_Amount_Calc__c;
                    oneFundTrans.OneFund__c = lstOfOneFundUpdated[0].Id;
                    oneFundTrans.Start_Date__c=(fa[0].csconta__effective_start_date__c).Date();
                    oneFundTrans.Expiry_Date__c=(fa[0].csconta__effective_start_date__c).Date().addMonths(Integer.valueOf(dprOffer.Fund_Term__c));
                    oneFundTrans.Transaction_Status__c = 'Active';
                    oneFundTrans.RecordTypeId = oneFundAccrualRecordId;
                    oneFundTrans.Transaction_Amount__c =fundAmount; 
                    oneFundTransList.add(oneFundTrans);
                    //EDGE-219164 start
                    oneFundTraProvisional.OneFund__c=lstOfOneFundUpdated[0].Id;
                    oneFundTraProvisional.Start_Date__c=(fa[0].csconta__effective_start_date__c).Date();
                    oneFundTraProvisional.Transaction_Status__c='Active';
                    oneFundTraProvisional.Sub_Type__c='Provisional';
                    oneFundTraProvisional.RecordTypeId=oneFundAccrualRecordId;
                    oneFundTraProvisional.Transaction_Amount__c =-fundAmount;
                    oneFundTransList.add(oneFundTraProvisional);
                    //EDGE-219164 end
                    
                }
                
                else if(dprOffer.Fund_Increment_Frequency__c == 'Annual In Advance'){
                    
                    Integer countTrans = 0;
                    Double contractTerminYears = (dprOffer.PF_Contract_term__c)/12;
                    Date nextStartDate;
                    Double fundAmount = (dprOffer.Fund_Amount__c != null)?(dprOffer.Fund_Amount__c/dprOffer.PF_Contract_term__c)*12 : (dprOffer.Fund_Amount_Calc__c/dprOffer.PF_Contract_term__c)*12;
                    
                    Date startDate = (fa[0].csconta__effective_start_date__c).Date();
                    Date endDate = (fa[0].csconta__effective_end_date__c).Date();
                    
                    while(countTrans < contractTerminYears){
                        
                        OneFund_Transactions__c oneFundTransMulti = new OneFund_Transactions__c();
                        oneFundTransMulti.OneFund__c = lstOfOneFundUpdated[0].Id;
                        if(nextStartDate != null){
                            oneFundTransMulti.Start_Date__c = nextStartDate;
                            oneFundTransMulti.Expiry_Date__c = nextStartDate.addMonths(12);
                            nextStartDate = nextStartDate.addMonths(12);
                        }
                        else{
                            
                            oneFundTransMulti.Start_Date__c = startDate;
                            oneFundTransMulti.Expiry_Date__c = startDate.addMonths(12);
                            nextStartDate = startDate.addMonths(12);
                        }
                        
                        oneFundTransMulti.Transaction_Status__c = (countTrans == 0)?'Active':'Pending';
                        oneFundTransMulti.RecordTypeId = oneFundAccrualRecordId;
                        oneFundTransMulti.Transaction_Amount__c = fundAmount;
                        oneFundTransList.add(oneFundTransMulti);
                        //EDGE-219164 start
                        OneFund_Transactions__c oFTProvisinal = new OneFund_Transactions__c();
                        oFTProvisinal.OneFund__c = lstOfOneFundUpdated[0].Id;
                        oFTProvisinal.Start_Date__c = nextStartDate;
                        oFTProvisinal.Transaction_Status__c = (countTrans == 0)?'Active':'Pending';
                        oFTProvisinal.Sub_Type__c='Provisional';
                        oFTProvisinal.RecordTypeId = oneFundAccrualRecordId;
                        oFTProvisinal.Transaction_Amount__c = -(fundAmount);
                        oneFundTransList.add(oFTProvisinal);
                        //EDGE-219164 end
                        countTrans++;
                    }
                    
                }                
            }
        }
        if(!oneFundTransList.isEmpty()){
            Database.SaveResult[] insertResultList = Database.insert(oneFundTransList);
            for (Database.SaveResult sr : insertResultList) {
                if (!sr.isSuccess()) {
                    System.debug('Issue in creating One Fund account transactions:'+sr.getErrors());
                    return false;
                }
            }
            
            //insert oneFundTransList;
        }
            
        
        return true;
    }
    //EDGE-219116 New Method
    public static void updateFAAttachmentRecord(List<csconta__Frame_Agreement__c> fa, List<DPR_Offer__c> dprOfferList) {
        
        List<Id> faIdList=new List<Id>();
        for(csconta__Frame_Agreement__c faData : fa){
            faIdList.add(faData.id);
        }
        FAM_Utility fm_util=new FAM_Utility(faIdList);
        
        Map<Id,Map<String, FAM_Utility.FundData>>  FundConsoleData = fm_util.getFundConsoleBulkCustomMap();
        
        Map<string,DPR_Offer__c> dprOfferMap = new Map<string,DPR_Offer__c>();
        
        for(DPR_Offer__c offer : dprOfferList){
            dprOfferMap.put(offer.Product_family__c,offer);
        }
        
        for(csconta__Frame_Agreement__c faData : fa){
            if(FundConsoleData!=null && FundConsoleData.get(faData.id)!=null){
                for( String familyName :FundConsoleData.get(faData.id).keyset() ){
                    FAM_Utility.FundData  fundData=FundConsoleData.get(faData.id).get(familyName);
                    fundData.isAllocated = true;
                    if(dprOfferMap.get(familyName).ContractStartDate__c!=null)
                        fundData.ContractStartDate = dprOfferMap.get(familyName).ContractStartDate__c;
                    if(dprOfferMap.get(familyName).ContractEndDate__c!=null)
                        fundData.ContractEndDate = dprOfferMap.get(familyName).ContractEndDate__c;
                    
                }
            }
            
        }
        
        FAM_Utility.setFundConsoleCustomMap(FundConsoleData);
    }
}