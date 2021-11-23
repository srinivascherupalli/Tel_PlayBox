/* ****************************************************************************
Class Name      : SolutionHelperPaymentTypeOneFund
* Author        : Laxmi Rahate : EDGE-127421
* Date          : 05 Feb 2020
* Description   : Remote Action Class for checking if PaymentType is OneFund or not
* ModifiedBy    : Samish
* ModifiedDate  : 26-02-2020
* Modified For  : EDGE-120137
* *****************************************************************************/
global with sharing class SolutionHelperPaymentTypeOneFund implements cssmgnt.RemoteActionDataProvider {

/****************************************************************************************************
* Method Name : getData
* Description : Default method to be overwritten from the Interface to perform Remote Actions
* Parameters  : Map<String, Object>     -   inputMap passed from the JavaScript Plugin
* Return      : Map<String, Object>     -   ReturnMap with the details required for JavaScript Plugin
****************************************************************************************************/
    global Map<String,Object> getData(Map<String,Object> inputMap){
        Map<String, Object> returnMap = new Map<String, Object>();      
        System.debug('inputMap'+inputMap);
        
        String accountId = (inputMap.containsKey('accountId') && (String)inputMap.get('accountId') != '')? (String)inputMap.get('accountId'):'';
        String offerID = (inputMap.containsKey('offerID') &&(String) inputMap.get('offerID') != '')? (String)inputMap.get('offerID'):'';
        boolean isPaymentTypeOneFund =  DP_DealQueryUtil.isHardwareOptionOneFund (offerID,accountId); 
        //Added by Samish for EDGE-120137 START
        String isRecontractingDiscountEligible = 'false';
        Date contractSignedDate = DP_DealQueryUtil.retrieveContractSignDate(offerId, accountId);  //Samish 120137
        Date contractExpiryDate = (contractSignedDate!=null ? contractSignedDate.addDays(30) : null);
        if(contractExpiryDate != null & System.today() <= contractExpiryDate)
            isRecontractingDiscountEligible = 'true';
        returnMap.put('isRecontractingDiscountEligible', isRecontractingDiscountEligible);    //Samish 120137
        //Added by Samish for EDGE-120137 END
        returnMap.put('isPaymentTypeOneFund', isPaymentTypeOneFund);
        return returnMap;
    }
    

      
}