/*
 * DEVELOPER : Anil,Tejes
 * TEAM: Napier
 * DESCRIPTION : This class has logic to calculate OneFund Amount for Contract Upgrade/Downgrade for contract variation
 * EDGE-112655, EDGE-115681, EDGE-122444, EDGE-128416, EDGE-128640
*/

public with sharing class OneFundTriggerContractVariation {
    public static Id committedFundRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Committed').getRecordTypeId();
    public static Id accrualRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();    
    public static Id chargesRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OneFund_Charges').getRecordTypeId();
    public static Id redemptionRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Redemptions').getRecordTypeId();
    public static Id OneFundchargesRecordId = Schema.SObjectType.Credits_and_Adjustments__c.getRecordTypeInfosByDeveloperName().get('OneFund_Charges').getRecordTypeId();
     
    /*
    @ DEVELOPER : Anil
    @ TEAM: Napier
    @ Below method calculates transaction amount based on change of contract duration and monthly committment of onefund.
    @ EDGE-112655
    */
    public static void calculateOneFundCharge(List<OneFund__c> oldFunds, List<OneFund__c> updatedFunds, Map<ID, OneFund__c> oldFundsMap, Map<ID, OneFund__c> updatedFundsMap){
        
        
        List<OneFund_Transactions__c> oneFundAllocationTransList = new List<OneFund_Transactions__c>();
        List<OneFund_Transactions__c> oneFundRedemptionTransList = new List<OneFund_Transactions__c>();
        List<OneFund_Transactions__c> redemptionTransUpdateList = new List<OneFund_Transactions__c>();
        List<OneFund_Transactions__c> oneFundTransUpdateList = new List<OneFund_Transactions__c>();
        List<Case> caseOneFundList = new List<Case>();
        List<Credits_and_Adjustments__c> creditOneFundList = new List<Credits_and_Adjustments__c>();
        Map<string,string> mdtlabelAmountMap=getMetaData();
        Set<String> setOfoneFundIds=new Set<String>();
        if(updatedFunds.size()>0){
            for(OneFund__c newOnefund: updatedFunds){
                setOfoneFundIds.add(newOnefund.Id);
            } 
        }
        
        OneFundTriggerContractVariation.OneFundTransactionWrapper wrapp=getAllocationTranAmount(setOfoneFundIds);
        Map<String,Decimal> mapOfArrTraAmt=wrapp.mapOfArrearAmt;
        Map<String,Decimal> mapOfAllocationAmt=wrapp.mapOfAllocationAmt;
        for(OneFund__c newOnefund: updatedFunds){
            Id newfundId = newOnefund.id;
            //Pooja: Added null check to resolve - System.NullPointerException: Attempt to de-reference a null object
            if(newOneFund.Contract_Duration__c!=null && !oldFundsMap.isEmpty() && oldFundsMap.containsKey(newfundId) &&
               oldFundsMap.get(newfundId).Contract_Duration__c!=null && oldFundsMap.get(newfundId).End_Date__c!=null &&
               (newOnefund.RecordTypeId == committedFundRecId) 
              && (oldFundsMap.get(newfundId).Contract_Duration__c != newOneFund.Contract_Duration__c ||
                  oldFundsMap.get(newfundId).Customer_Commitment__c != newOneFund.Customer_Commitment__c)){
                /*
                String mdtlabelOld = 'duration'+ integer.valueof(oldFundsMap.get(newfundId).Contract_Duration__c)+ ' commitment'+integer.valueof(oldFundsMap.get(newfundId).Customer_Commitment__c);
                String mdtlabelNew = 'duration'+ integer.valueof(newOneFund.Contract_Duration__c)+ ' commitment'+integer.valueof(newOneFund.Customer_Commitment__c);
                
                //calculating elaped months and remaining months for onefund
                Integer elapsedMonths=newOneFund.Start_Date__c.monthsBetween(system.today());
                Integer remainingMonthsOld=system.today().monthsBetween(oldFundsMap.get(newfundId).End_Date__c);
                Integer remainingMonthsNew=system.today().monthsBetween(newOneFund.End_Date__c); 
                system.debug('newEndDate='+newOneFund.End_Date__c+' remainingMonthsOld='+remainingMonthsOld +' remainingMonthsNew = '+remainingMonthsNew +' elapsedMonths = '+elapsedMonths);
                Decimal oldProRate=0.0;
                Decimal newProRate=0.0;
                if(mdtlabelAmountMap.get(mdtlabelOld)!=null && mdtlabelAmountMap.get(mdtlabelNew)!=null){
                    //calculating pro-rate for the onefund record
                    oldProRate=decimal.valueof(mdtlabelAmountMap.get(mdtlabelOld))/integer.valueof(oldFundsMap.get(newfundId).Contract_Duration__c);
                    newProRate= decimal.valueof(mdtlabelAmountMap.get(mdtlabelNew))/integer.valueof(newOneFund.Contract_Duration__c);                    
                }
                
                string tranSubTypeCommitted='Committed OneFund';
                string tranSubTypeArrears='Arrears';
                string tranSubTypeClawback='Clawback';
                Decimal customerEntitlement=oldProRate*elapsedMonths;
                Decimal oldArrearsAmount=0.0;
                Decimal oldAllocationAmount=0.0;
                if(mapOfArrTraAmt!=null){
                    oldArrearsAmount=mapOfArrTraAmt.get(newOneFund.Id);
                }
                if(mapOfArrTraAmt!=null){
                    oldAllocationAmount=mapOfAllocationAmt.get(newOneFund.Id);
                }
                Decimal consumedFund=oldAllocationAmount-oldFundsMap.get(newfundId).Available_OneFund__c;                    
                Decimal newAllocationFund=remainingMonthsNew*newProRate;
                Decimal oldAllocatedFund=decimal.valueof(mdtlabelAmountMap.get(mdtlabelOld));
                
                //Creating new allocation fund transaction
                OneFund_Transactions__c oneFundTransrec1 = createOneFundAllocationTrans(newOneFund,accrualRecordId,newAllocationFund,tranSubTypeCommitted);
                oneFundAllocationTransList.add(oneFundTransrec1);
                
                if(consumedFund <= customerEntitlement){
                    //calculate Arrear fund amount to create allocation transaction
                    Decimal underspentAmount=customerEntitlement-consumedFund;
                    Decimal arrearsFund=underspentAmount+oldArrearsAmount;
                    
                    if(arrearsFund > 0){
                        //Creating Arrears allocation fund transaction 
                        OneFund_Transactions__c oneFundTransrec2 = createOneFundAllocationTrans(newOneFund,accrualRecordId,arrearsFund,tranSubTypeArrears);
                        oneFundAllocationTransList.add(oneFundTransrec2); 
                    }    
                }
                else if (consumedFund > customerEntitlement){
                    //calculate overspend amount to create redemption oneFund transaction.
                    Decimal overspendAmount=consumedFund-customerEntitlement;
                    Decimal arrearsFund=oldArrearsAmount;
                    if(oldArrearsAmount > 0){
                        //Creating Arrears allocation fund transaction equal to previous arrears amount 
                        OneFund_Transactions__c oneFundTransrec3 = createOneFundAllocationTrans(newOneFund,accrualRecordId,arrearsFund,tranSubTypeArrears);
                        oneFundAllocationTransList.add(oneFundTransrec3); 
                    }
                    
                    if(overspendAmount <= newAllocationFund){                       
                        //creating redemption transaction of overspend amount
                        OneFund_Transactions__c oneFundTransrec4 = createOneFundRedemptionTrans(newOneFund,redemptionRecordId,overspendAmount,tranSubTypeClawback);
                        oneFundRedemptionTransList.add(oneFundTransrec4);   
                    }
                    else{
                        //creating redemption transaction of new Allocation Fund
                        OneFund_Transactions__c oneFundTransrec5 = createOneFundRedemptionTrans(newOneFund,redemptionRecordId,newAllocationFund,tranSubTypeClawback);
                        oneFundRedemptionTransList.add(oneFundTransrec5);
                        
                        //downgradeCharge=overspendAmount-newAllocationFund;
                        decimal arrearsRedemption=overspendAmount-newAllocationFund;
                        if(arrearsRedemption <= arrearsFund){
                            //creating redemption transaction from new Arrear
                            OneFund_Transactions__c oneFundTransrec6 = createOneFundRedemptionTrans(newOneFund,redemptionRecordId,arrearsRedemption,tranSubTypeClawback);
                            oneFundRedemptionTransList.add(oneFundTransrec6);
                        }
                        else{                   
                            if(arrearsFund > 0){
                                //creating redemption transaction from new Arrear
                                OneFund_Transactions__c oneFundTransrec7 = createOneFundRedemptionTrans(newOneFund,redemptionRecordId,arrearsFund,tranSubTypeClawback);
                                oneFundRedemptionTransList.add(oneFundTransrec7);
                            }
                            Decimal downgradeCharge=arrearsRedemption-arrearsFund;
                            string chargeType='Downgrade';
                            system.debug('downgradeCharge= '+downgradeCharge);
                            
                            if(downgradeCharge > 0){
                                //Create a case for Downgrade charge. 
                                Case caseOneFund = createCaseForOneFund(newOneFund,chargesRecordId,downgradeCharge,chargeType);
                                caseOneFundList.add(caseOneFund);               
                            }    
                        }
                        
                    }
                    
                }   
                      */
            }
        }
        
        /*if(oneFundAllocationTransList.size()>0){
            expireOneFundTransRecord(setOfoneFundIds);
            insert oneFundAllocationTransList;            
        }
        Set<String> setOfRedemOneFundIds=new Set<String>();
        if(oneFundRedemptionTransList.size() > 0){
            insert oneFundRedemptionTransList;
            for(OneFund_Transactions__c tranRec:oneFundRedemptionTransList){
                setOfRedemOneFundIds.add(tranRec.OneFund__c);
            } 
            updateRedemptionTransRec(setOfRedemOneFundIds,oneFundRedemptionTransList);    
        }        
        
        if(caseOneFundList.size() > 0){
            insert caseOneFundList;
            createCreditAdjustmentsRecord(oneFundRedemptionTransList,OneFundchargesRecordId,caseOneFundList);
        }*/
    
    }
   
    /*
     @ DEVELOPER : Anil
     @ TEAM: Napier
     @ Below method returns map with metadata label and onefund amount.
     @ EDGE-112655
    */ 
    
    public static Map<string,string> getMetaData(){
        Map<string,string> mdtlabelAmountMap = new Map<string,string>();
        for(OneFund_Committed_Calculation__mdt calmdt: [select label,OneFund_Amount__c from OneFund_Committed_Calculation__mdt]){
            mdtlabelAmountMap.put(calmdt.label, calmdt.OneFund_Amount__c); 
        }
        return mdtlabelAmountMap;
    }

    /*
     @ DEVELOPER : Anil
     @ TEAM: Napier
     @ Below method creates oneFund allocation transaction record depending on contract variation.
     @ EDGE-112655
    */    

  /*  public static OneFund_Transactions__c createOneFundAllocationTrans(OneFund__c oneFund,id recordTypeId,decimal transactionAmount,string subType){
        
        OneFund_Transactions__c allocTranRec = new OneFund_Transactions__c(OneFund__c=oneFund.id,RecordTypeId=recordTypeId,
                                                                           Sub_Type__c=subType,Transaction_Status__c='Active',
                                                                           Transaction_Amount__c=transactionAmount,
                                                                           Start_Date__c=oneFund.Start_Date__c,
                                                                           Expiry_Date__c = oneFund.End_Date__c);
        return allocTranRec;          
    }*/
   
    /*
     @ DEVELOPER : Anil
     @ TEAM: Napier
     @ Below method creates oneFund redemption transaction record depending on contract variation.
     @ EDGE-112655
    */    

   /* public static OneFund_Transactions__c createOneFundRedemptionTrans(OneFund__c oneFund,id recordTypeId,decimal transactionAmount,string subType){
        
        OneFund_Transactions__c oftRec = new OneFund_Transactions__c(OneFund__c = oneFund.id,Transaction_Status__c = 'Active',                                                                     
                                                                     Sub_Type__c =subType,RecordTypeId =recordTypeId,
                                                                     Transaction_Amount__c=transactionAmount,
                                                                     Redemption_date__c = oneFund.Contract_Variation_Date__c);
        return oftRec;        
    }    */
    

    /*
     @ DEVELOPER : Tejes
     @ TEAM: Napier
     @ Below method updates all oneFund allocation transaction status to expired.
     @ EDGE-115681
    */      
  /*  public static void expireOneFundTransRecord(Set<String> oneFundIds){
        List<OneFund_Transactions__c> fundTransactionList = [select id,name,Transaction_Type__c,Transaction_Status__c 
                                                              from OneFund_Transactions__c 
                                                              where OneFund__c IN:oneFundIds 
                                                              and Transaction_Status__c = 'Active' 
                                                              and Transaction_Type__c = 'Allocation'];
        
        for(OneFund_Transactions__c FundTran : fundTransactionList){
            FundTran.Transaction_Status__c = 'Expired';              
        } 
        update fundTransactionList;
    }*/
   
    /*
     @ DEVELOPER : Tejes
     @ TEAM: Napier
     @ Wrapper class to return map of previous Allocation and Arrears transaction amount.
     @ EDGE-128640
    */
    
    public class OneFundTransactionWrapper{
        Map<String,Decimal> mapOfArrearAmt;
        Map<String,Decimal> mapOfAllocationAmt;
        OneFundTransactionWrapper(){
            mapOfArrearAmt=new  Map<String,Decimal>();
            mapOfAllocationAmt=new Map<String,Decimal>();
        }
    }
    
    /*
     @ DEVELOPER : Tejes
     @ TEAM: Napier
     @ Below method returns previous Allocation and Arrears transaction amount.
     @ EDGE-128640
    */      
   
    public static OneFundTriggerContractVariation.OneFundTransactionWrapper getAllocationTranAmount(Set<String> oneFundIds){
        Map<String,Decimal> mapOfArrearAmt=new Map<String,Decimal>();
        Map<String,Decimal> mapOfAlloAmt=new Map<String,Decimal>();       
        OneFundTriggerContractVariation.OneFundTransactionWrapper oftWrapp=new OneFundTriggerContractVariation.OneFundTransactionWrapper();
        List<OneFund_Transactions__c> allocationTranList = [select id,name,Current_Amount__c,OneFund__c,Sub_Type__c,Transaction_Amount__c
                                                            from OneFund_Transactions__c 
                                                            where OneFund__c IN:oneFundIds 
                                                            and Transaction_Status__c = 'Active' 
                                                            and Transaction_Type__c = 'Allocation'];
        for(String fundID: oneFundIds){
            Decimal totalArrearsAmount=0.0;
            Decimal totalAllocationAmount=0.0;
            mapOfArrearAmt.put(fundID,totalArrearsAmount);
            mapOfAlloAmt.put(fundID,totalAllocationAmount);
            if(allocationTranList.size() > 0){
                for(OneFund_Transactions__c ft : allocationTranList){
                    if(fundID==ft.OneFund__c){
                        if(ft.Sub_Type__c!=null && ft.Sub_Type__c=='Arrears'){
                            totalArrearsAmount=totalArrearsAmount + ft.Current_Amount__c;
                            mapOfArrearAmt.put(ft.OneFund__c,totalArrearsAmount);
                        }
                        totalAllocationAmount=totalAllocationAmount + ft.Transaction_Amount__c; 
                        mapOfAlloAmt.put(ft.OneFund__c,totalAllocationAmount);
                    }
                }
            }
        }
        if(mapOfArrearAmt!=null){
            oftWrapp.mapOfArrearAmt=mapOfArrearAmt;  
        }
        if(mapOfAlloAmt!=null){
            oftWrapp.mapOfAllocationAmt=mapOfAlloAmt;  
        }
        return oftWrapp;
    }   


    /*
     @ DEVELOPER : Tejes
     @ TEAM: Napier
     @ Below method updates related accural field for oneFund redemption transaction records.
     @ EDGE-128416
    */      
    
  /*  public static void updateRedemptionTransRec(Set<String> setOfRedemOneFundIds,List<OneFund_Transactions__c> redemTranList){
        List<OneFund_Transactions__c> allocationTranList=[select id,name,OneFund__c,Current_Amount__c,Redeemed_Amount__c,Sub_Type__c 
                                                          from OneFund_Transactions__c 
                                                          where OneFund__c IN: setOfRedemOneFundIds 
                                                          and Transaction_Status__c = 'Active' 
                                                          and Transaction_Type__c = 'Allocation' order by Name];              
        String redemId=null;
        String allocId=null;
        for(OneFund_Transactions__c allocTran : allocationTranList){        
            for(OneFund_Transactions__c redemTran : redemTranList){
                if(redemTran.OneFund__c==allocTran.OneFund__c){
                    if( redemTran.Transaction_Amount__c <= allocTran.Current_Amount__c && redemId!=redemTran.id && allocId!=allocTran.Id){
                        redemTran.Related_Accrual__c=allocTran.id;
                        allocTran.Redeemed_Amount__c=allocTran.Redeemed_Amount__c+redemTran.Transaction_Amount__c;
                        redemId=redemTran.id;
                        allocId=allocTran.Id;
                    }                    
                }
            }
        }
        update allocationTranList;
        update redemTranList;
    }
  */
    /*
     @ DEVELOPER : Tejes
     @ TEAM: Napier
     @ Below method creates Case record with Downgrade charge amount.
     @ EDGE-122481
    */    

  /*  public static Case createCaseForOneFund(OneFund__c oneFund,Id recordTypeId,Decimal chargeAmount, String chargeType){
        Case CaseRecord1 = new Case(OneFund_ID__c = oneFund.id, Billing_Account__c=oneFund.Billing_Account__c,
                                    Status='In Progress', Charge_Amount__c=chargeAmount,RecordTypeId =recordTypeId,
                                    Charge_Type__c = chargeType, AccountId = oneFund.CIDN__c);
        return CaseRecord1;
    } */
    
    /*
     @ DEVELOPER : Tejes
     @ TEAM: Napier
     @ Below method updates redemption transaction and creates Credit and Adjustments record with Downgrade charge amount.
     @ EDGE-122444
    */    
    
   /* public static Void createCreditAdjustmentsRecord(List<OneFund_Transactions__c> clawbackTranList,id recordTypeId,List<Case> caseOneFundList){
        List<Credits_and_Adjustments__c> creditList= new List<Credits_and_Adjustments__c>();             
        for(Case caseRec : caseOneFundList){
            for(OneFund_Transactions__c Tran : clawbackTranList){
                if(caseRec.Onefund_ID__c==Tran.OneFund__c){
                    Tran.Case_Number__c = caseRec.Id; 
                }
            }
            Credits_and_Adjustments__c credRecord = new Credits_and_Adjustments__c(Case_Number__c = caseRec.Id, 
                                                    Charge_Amount__c=caseRec.Charge_Amount__c,RecordTypeId =recordTypeId,
                                                    Charge_Status__c='In Progress', Charge_Type__c = caseRec.Charge_Type__c,
                                                    Billing_Account_Number_BAN__c = caseRec.Billing_Account__c, 
                                                    Corelation_ID__c = EDISSingleManager.getUID());
            creditList.add(credRecord);
        }
        update clawbackTranList;
        insert creditList;
    }  */
}