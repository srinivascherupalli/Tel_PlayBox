/*
EDGE-92626
Name : EnrichmentValidationRemoter 
Description :UI validation for notbeforeCRD selection on enrichment screen

*/

global with sharing class EnrichmentValidationRemoter implements cssmgnt.RemoteActionDataProvider {
    
    @RemoteAction
    global static  Map<String, Object> getData(Map<String, Object> inputMap) {
        
        System.debug('Input Map ' + inputMap);
        Map<String, Object> returnMap = new Map<String, Object>();
        
        if (inputMap.containsKey('NotBefCRD')) {
            returnMap = getNotBeforeCRDValidation(inputMap);
        }
        return returnMap;
    }
    public static  Map<String, Object> getNotBeforeCRDValidation(Map<String, Object> inputMap) 
    {
        Map<String, Object> returnMap = new Map<String, Object>();
        String notBefCrd= (String)inputMap.get('NotBefCRD');
        Date notBeforeCRD = Date.valueof(notBefCrd);
        
        String basketId = (String)inputMap.get('basketId');
        
        system.debug('notBeforeCRD'+notBeforeCRD+'basketId'+basketId);
        String oppId='';
        Date authDate;
        Boolean validationCRD =true; //EDGE-139336. Kalashree Borgaonkar. Set default value
        Integer NumDays;
        
        List<cscfga__Product_Basket__c> basketOpp = [select id,cscfga__Opportunity__c from cscfga__Product_Basket__c  where id=:basketId];
        for(cscfga__Product_Basket__c opp: basketOpp)  
        {
            oppId=opp.cscfga__Opportunity__c;
        }
        List<Customer_Authority_Form__c> authorityOpp = [select Opportunity__c,Customer_Authorised_date__c,CA_Expiry_Date__c from Customer_Authority_Form__c where Opportunity__c=:oppId  and Customer_Authorised_date__c !=NULL AND Type__c!='PPV' order by createddate desc limit 1];
        
        
        for(Customer_Authority_Form__c cau: authorityOpp)  
        {
            authDate=cau.CA_Expiry_Date__c;
        }
        //EDGE-115432,EDGE-139336. Kalashree Borgaonkar. Fix for CDR date validation start
        Integer numberOfDays ;
        Integer absoulteNumDays ;
        if(authDate!=null){
            numberOfDays = authDate.daysBetween(notBeforeCRD);
            absoulteNumDays = Math.abs(numberOfDays);
            if(numberOfDays <=0){
                if(absoulteNumDays >= 15){
                    validationCRD =false;
                }
            }  
        }
        else{
            validationCRD =false;
        }
        //EDGE-139336. Kalashree Borgaonkar. Fix for CDR date validation end
		returnMap.put( 'oppid',oppId);
        returnMap.put( 'validationCRD',validationCRD );
        return returnMap;
    }
}