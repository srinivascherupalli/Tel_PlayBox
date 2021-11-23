/*
===============================================================================================================================
Class : EarlyCancellationCalcService 
Developer Name : Manoj Kumar
Test Class : EarlyCancellationCalcServiceTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1      Manoj Kumar      8/Aug/2019    EDGE-104678 : Generic class to calculate ETC charges
2      Ritika Jaiswal    16/09/2019    EDGE-81135 : Added error-handing scenario and return-type changes
3      Ritika Jaiswal    25/09/2019    EDGE-81135, 66137 - Defect fixes for incorrect ETC calculation
4	   Ritika Jaiswal    24/10/2019	   EDGE-81135: CMP cancellation remainingTerm
5      Sandip Deshmane:  5/Nov/2019	   EDGE-11053: Cancellation Charges
=============================================================================================================================== */

public class EarlyCancellationCalcService {

      /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-104678
 * Date : 8/Aug/2019
 * Description : Calculate ETC amount value (Plan based + Device based)
 * Parameter : 
 * 
 * *****************************************************************************/
  
 
    public Static Map<String,String> CancelChargesCalc(Decimal maxETC,Date initialActivationDate,Date disconnectionDate,Integer contractTerm, Decimal unitPrice, boolean isDeviceCancellationApplicable, String billingAccNum){
        
        Integer remainingTerm;
        Decimal deviceCancelAmount = 0.00; 
        Decimal planCancelAmount = 0.00;
        Date firstBillDate,lastBillDate;
        BillingAccountDetailsDTO billAccDTO = null;
        Map<String,String> results = new Map<String,String>();
        System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:maxETC:'+maxETC+',initialActivationDate'+initialActivationDate+',disconnectionDate:'+disconnectionDate+',contractTerm:'+contractTerm+',unitPrice:'+unitPrice+',isDeviceCancellationApplicable:'+isDeviceCancellationApplicable+',billingAccNum:'+billingAccNum);
        try{ 
        //invoking BillingAccountRetrieve : web callout
            billAccDTO = BillingOrderService.requestBillingAccountDetails(billingAccNum);
            System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:billAccDTO:'+billAccDTO);
        
            if(billAccDTO != null && billAccDTO.BillingAccount != null && billAccDTO.status == IntegrationRecordHandlerUtil.HTTP_SUCCESS){
         
                String dayValue = billAccDTO.BillingAccount.startDate;
                Integer billCycleDay = billAccDTO.BillingAccount.billCycleDay;
            
                // Date on which first bill will be generated in BDS
                firstBillDate =  Date.newInstance(initialActivationDate.year(), initialActivationDate.month(), Integer.valueOf(billCycleDay));
                if(initialActivationDate >= firstBillDate)  
                    firstBillDate = firstBillDate.addMonths(1);             
                System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:firstBillDate:'+firstBillDate);
            
                //Date on which latest bill was generated
                lastBillDate =  Date.newInstance(disconnectionDate.year(), disconnectionDate.month(), Integer.valueOf(billCycleDay));
                if(disconnectionDate < lastBillDate)
                lastBillDate = lastBillDate.addMonths(-1);            
                System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:lastBillDate:'+lastBillDate);
                // Evaluate if bill was generated for month from which disconnectionDate is selected
                /*Boolean billGenerated_DisconnectionMonth = false;
                if((disconnectionDate.month() == lastBillDate.month()) && (disconnectionDate.day() >= lastBillDate.day())){
                    billGenerated_DisconnectionMonth = true;
                }*/
                Integer TermPassed = firstBillDate.monthsBetween(lastBillDate)+1; //Added one to include the firstBillMonth         
                if(TermPassed<0)
                    TermPassed = 0;
                remainingTerm = contractTerm - TermPassed;
                results.put('RemainingTerm',String.valueOf(remainingTerm ));
                /*if(billGenerated_DisconnectionMonth)
                    remainingTerm--; */
                System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:remainingTerm:'+remainingTerm);
               
                if(remainingTerm>0){            
                planCancelAmount = PlanCancelCalc(maxETC,contractTerm,remainingTerm);
            
                //calculate DvcCancelChargeCalc only when Device_cancellation_applicable is true
                if(isDeviceCancellationApplicable){
                    deviceCancelAmount = DvcCancelChargeCalc(remainingTerm,unitPrice);
                    }
                }
            }
            Decimal totalETCAmount = planCancelAmount + deviceCancelAmount;
            results.put('ETCcharges',String.valueOf(totalETCAmount));  
            return results ;
        }
        catch(Exception e){
            System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:BillingAccount-Response:'+billAccDTO);
            results.put('ETCcharges','Error');
            return results;
        }
        
    }
      /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-104678
 * Date : 8/Aug/2019
 * Description : This method calculates plan based cancelation charges
 * Parameter : Integer maxETC, Integer term, Integer remainingTerm
 * 
 * *****************************************************************************/
    public Static Decimal  PlanCancelCalc(Decimal maxETC,Integer term,Integer remainingTerm){
        Decimal resultAmount = (maxETC * remainingTerm)/term;
        return resultAmount;
    }
      /* ****************************************************************************
 * Author : Ritika Jaiswal : EDGE-66137
 * Date : 19/September/2019 
 * Description : This method calculates device based cancelation charges, without callout for BillCycleDay
 * Parameter : Int RemainingTerm, Decimal UnitPrice
 * 
 * *****************************************************************************/
  public Static Decimal  DvcCancelChargeCalc(Integer remainingTerm,Decimal UnitPrice){
        
        return remainingTerm * UnitPrice ;
    }
  
  /*
  * Developer - Ritika Jaiswal
  * Jira - EDGE -66137
  * Parameters : 1. maxETC - ETC charges from PriceItem record
  * 2. initialActivationDate - Date on which service was activated by O2A, read from initialActivationDate field of Service record
  * 3. disconnectionDate  
  * 4. contractTerm - total months of contract for the service
  * 5. unitPrice - Monthly charges of device
  * 6. isDeviceCancellationApplicable - Boolean to include/exclude ETC charges of device
  * 7. billingAccNum - Billing Account Number linked against subscription
  * 8. billCycleDay - Day of month on which bill is generated by BDS
  */
  
  public Static String CancelChargesCalcWithBillDay(Decimal maxETC,Date initialActivationDate,Date disconnectionDate,Integer contractTerm, Decimal unitPrice, boolean isDeviceCancellationApplicable, String billingAccNum,String billCycleDay){
        
        Integer remainingTerm;
        Decimal deviceCancelAmount = 0.00; 
        Decimal planCancelAmount = 0.00;
        Date firstBillDate,lastBillDate;
        System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalcWithBillDay:maxETC:'+maxETC+',initialActivationDate'+initialActivationDate+',disconnectionDate:'+disconnectionDate+',contractTerm:'+contractTerm+',unitPrice:'+unitPrice+',isDeviceCancellationApplicable:'+isDeviceCancellationApplicable+',billingAccNum:'+billingAccNum+',billCycleDay:'+billCycleDay);
        try{ 
            
            // Date on which first bill will be generated in BDS
            firstBillDate =  Date.newInstance(initialActivationDate.year(), initialActivationDate.month(), Integer.valueOf(billCycleDay));
            if(initialActivationDate >= firstBillDate)  
                firstBillDate = firstBillDate.addMonths(1);             
            System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalcWithBillDay:firstBillDate:'+firstBillDate);
            
            //Date on which latest bill was generated
            lastBillDate =  Date.newInstance(disconnectionDate.year(), disconnectionDate.month(), Integer.valueOf(billCycleDay));
            if(disconnectionDate < lastBillDate)
                lastBillDate = lastBillDate.addMonths(-1);            
            System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalcWithBillDay:lastBillDate:'+lastBillDate);
            // Evaluate if bill was generated for month from which disconnectionDate is selected
            /*Boolean billGenerated_DisconnectionMonth = false;
            if((disconnectionDate.month() == lastBillDate.month()) && (disconnectionDate.day() >= lastBillDate.day())){
                billGenerated_DisconnectionMonth = true;
            }*/
            Integer TermPassed = firstBillDate.monthsBetween(lastBillDate)+1; //Added one to include the firstBillMonth         
            if(TermPassed<0)
                    TermPassed = 0;
            remainingTerm = contractTerm - TermPassed;
            /*if(billGenerated_DisconnectionMonth)
                remainingTerm--; */
            System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalcWithBillDay:remainingTerm:'+remainingTerm);
            if(remainingTerm>0){            
             planCancelAmount = PlanCancelCalc(maxETC,contractTerm,remainingTerm);
            
            //calculate DvcCancelChargeCalc only when Device_cancellation_applicable is true
            if(isDeviceCancellationApplicable){
                deviceCancelAmount = DvcCancelChargeCalc(remainingTerm,unitPrice);
                }
            }
            Decimal totalETCAmount = planCancelAmount + deviceCancelAmount;
            return String.valueOf(totalETCAmount);   
            
        }
        catch(Exception e){
            System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalcWithBillDay:'+e.getLineNumber()+','+e.getMessage());
            return 'Error';
        }
        
    }
  	/* ****************************************************************************
    * Author : Sandip Deshmane: EDGE-11053
    * Date : 5/Nov/2019
    * Description : This method calculates plan based cancelation charges for TID
    * Parameter : Integer maxETC, Integer term, Integer remainingTerm
    * 
    * *****************************************************************************/
    public Static Map<String,String> CancelChargesCalcforTID(Integer maxETC,Date initialActivationDate,Date disconnectionDate,Integer contractTerm, Decimal unitPrice, boolean isDeviceCancellationApplicable, String billingAccNum){
        
        Integer remainingTerm;
        //Integer TermPassed = initialActivationDate.monthsBetween(disconnectionDate);
        //Integer remainingTerm = contractTerm - TermPassed;
        Decimal deviceCancelAmount = 0.00; 
        Decimal planCancelAmount = 0.00;
        Date firstBillDate,lastBillDate;
        BillingAccountDetailsDTO billAccDTO = null;
        Map<String,String> results = new Map<String,String>();
        System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:maxETC:'+maxETC+',initialActivationDate'+initialActivationDate+',disconnectionDate:'+disconnectionDate+',contractTerm:'+contractTerm+',unitPrice:'+unitPrice+',isDeviceCancellationApplicable:'+isDeviceCancellationApplicable+',billingAccNum:'+billingAccNum);
        try{ 
        //invoking BillingAccountRetrieve : web callout
            billAccDTO = BillingOrderService.requestBillingAccountDetails(billingAccNum);
            System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:billAccDTO:'+billAccDTO);
        
            if(billAccDTO != null && billAccDTO.BillingAccount != null && billAccDTO.status == IntegrationRecordHandlerUtil.HTTP_SUCCESS){
         
                String dayValue = billAccDTO.BillingAccount.startDate;
                Integer billCycleDay = billAccDTO.BillingAccount.billCycleDay;
            
                // Date on which first bill will be generated in BDS
                firstBillDate =  Date.newInstance(initialActivationDate.year(), initialActivationDate.month(), Integer.valueOf(billCycleDay));
                if(initialActivationDate >= firstBillDate)  
                    firstBillDate = firstBillDate.addMonths(1);             
                System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:firstBillDate:'+firstBillDate);
            
                //Date on which latest bill was generated
                lastBillDate =  Date.newInstance(disconnectionDate.year(), disconnectionDate.month(), Integer.valueOf(billCycleDay));
                if(disconnectionDate < lastBillDate)
                lastBillDate = lastBillDate.addMonths(-1);            
                System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:lastBillDate:'+lastBillDate);
                // Evaluate if bill was generated for month from which disconnectionDate is selected
                Integer TermPassed = firstBillDate.monthsBetween(lastBillDate)+1; //Added one to include the firstBillMonth         
                if(TermPassed<0)
                    TermPassed = 0;
                remainingTerm = contractTerm - TermPassed;
                results.put('RemainingTerm',String.valueOf(remainingTerm ));
                
                System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:remainingTerm:'+remainingTerm);
               
                if(remainingTerm>0){            
                    planCancelAmount = PlanCancelCalcforTID(maxETC,remainingTerm, unitPrice);
                }
        	}
            Decimal totalETCAmount = planCancelAmount;
            results.put('ETCcharges',String.valueOf(totalETCAmount));  
            return results ;
        }
        catch(Exception e){
            System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:BillingAccount-Response:'+billAccDTO);
            results.put('ETCcharges','Error');
            return results;
        }
        
    }

/* ****************************************************************************
 * Author : Sandip Deshmane: EDGE-11053
 * Date : 5/Nov/2019
 * Description : This method calculates plan based cancelation charges for TID
 * Parameter : Integer maxETC, Integer term, Integer remainingTerm
 * 
 * *****************************************************************************/
public Static Decimal  PlanCancelCalcforTID(Integer maxETC,Integer remainingTerm,Decimal unitPrice){
    Integer etcPercent;
    if(maxETC != 0 && maxETC > 0 ){
        etcPercent = maxETC;
    }else if(maxETC == null || maxETC == 0){
        etcPercent = 100;
    }
        
    Decimal resultAmount = ((unitPrice/100) * etcPercent)*remainingTerm;
    return resultAmount;
}
}