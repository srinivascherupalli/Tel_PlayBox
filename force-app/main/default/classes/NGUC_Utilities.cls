/*
* @Desc : NGUC class called from RF_ProductBasketDataHandler
* @Jira : DIGI-518
*/
global with sharing class NGUC_Utilities {
    //Added below function for EDGE-127817. Below function is invoked from function getngUCCancel to calculate remaining terms of the contract.
    public static Integer calculateRemainingTermngUC(Date initialActivationDate,Date disconnectionDate,Integer contractTerm,BillingAccountDetailsDTO billAccDTO){
        Integer remainingTerm;
        //// Decimal deviceCancelAmount = 0.00; 
        //// Decimal planCancelAmount = 0.00;
        Date firstBillDate,lastBillDate;
        //// Map<String,String> results = new Map<String,String>();
        try{ 
            if(billAccDTO != null && billAccDTO.BillingAccount != null && billAccDTO.status == IntegrationRecordHandlerUtil.HTTP_SUCCESS){
                //// String dayValue = billAccDTO.BillingAccount.startDate;
                Integer billCycleDay = billAccDTO.BillingAccount.billCycleDay;
                // Date on which first bill will be generated in BDS
                firstBillDate =  Date.newInstance(initialActivationDate.year(), initialActivationDate.month(), Integer.valueOf(billCycleDay));
                if(initialActivationDate >= firstBillDate)  
                    firstBillDate = firstBillDate.addMonths(1);             
                //Date on which latest bill was generated 
                lastBillDate =  Date.newInstance(disconnectionDate.year(), disconnectionDate.month(), Integer.valueOf(billCycleDay));
                if(disconnectionDate < lastBillDate)
                    lastBillDate = lastBillDate.addMonths(-1);            
                Integer TermPassed = firstBillDate.monthsBetween(lastBillDate)+1; //Added one to include the firstBillMonth
                if(TermPassed<0)
                    TermPassed = 0;
                remainingTerm = contractTerm - TermPassed;
            }
        }
        catch(Exception e){
            C2O_Utilities.createException(e);            //// added exception
            //// return remainingTerm;
        }
        return remainingTerm;
    }
}