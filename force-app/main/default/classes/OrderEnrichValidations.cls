/***********************************************
Class Name      	:   OrderEnrichValidations 
Description 		:   As suggested by code governance team created this class to include validations related to order enrichment
Test Class : CustomButtonEnrichBasketTest 
Sr.No.      Developer Name               Date          Story Description
1.			Shashank kulshreshtha      13-09-21		Order enrichment validations as suggested by code governance team 
****************************************************************/
public class OrderEnrichValidations {   
    
    // DIGI-15582 & DIGI-22239 changes starts here --- added by shashank   
    private static final String CONST_INTERFACENAME = 'OrderEnrichValidations';
    private static String correlationId = GuidUtil.NewGuid();
    public static Boolean isDmsOEValid(String basketId ,List<cscfga__Product_Configuration__c> dmsConfList) {
        Boolean dmsConValid = true;
        Boolean dmsNotBeforeCrdValid = true; 
        //Boolean dmsPrefCrdValid = true;
        try{
            List<contact> listCon = new List<contact>();
            Id conId;
            map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');   
            system.debug('dms pd '+String.valueOf(customMetadataNameValueMap.get('DMS_Product').get('MasterLabel')));
            
            Id podconfigId;
            //Set<Id> productConfigSet = new Set<Id>();
            for (cscfga__Product_Configuration__c sc : dmsConfList) {
                if (sc.cscfga__Product_Definition__r.Name == String.valueOf(customMetadataNameValueMap.get('DMS_Product').get('MasterLabel'))
                    && sc.Type__c == 'New'){
                        //productConfigSet.add(sc.Id);
                        podconfigId = sc.Id;
                    }
            }
            //system.debug('dms  productConfigSet'+productConfigSet);       
            List <cscfga__Attribute__c> attrDmsList =  [select id , name , cscfga__Value__c from cscfga__Attribute__c where name in ('TenancyPrimaryContact','Preferred CRD','Not Before CRD') and cscfga__Product_Configuration__c =:podconfigId ];
            
            // query to fetch contact
            for (cscfga__Attribute__c attr : attrDmsList){ 
                if (attr.name== 'TenancyPrimaryContact' && String.isNotBlank(attr.cscfga__Value__c)){
                    conId = attr.cscfga__Value__c;
                } 
            }
            if (String.isNotBlank(String.valueOf(conId))) {
                listCon = new List<contact>([SELECT id,FirstName,LastName,Phone,Email FROM contact WHERE id=:conId]);
            }


            // checking for validations 
            for (cscfga__Attribute__c attr : attrDmsList){ 
                system.debug('attr'+attr+'--value-'+attr.cscfga__Value__c);
                if (attr.name== 'TenancyPrimaryContact' ){
                    dmsConValid = checkDmsConValid( conId,listCon);
                }                       
                if(attr.name== 'Not Before CRD' ){
                    dmsNotBeforeCrdValid = checkCrdDateValid(attr.cscfga__Value__c);                    
                }            
               
                //if(attr.name== 'Preferred CRD' && String.isBlank(String.valueof(attr.cscfga__Value__c))){
                  //  dmsPrefCrdValid = false;
                //}
            }                        
            system.debug('valid OE DMS ---'+( dmsConValid && dmsNotBeforeCrdValid ));
            
        }
        catch(Exception e){
            logException('isDmsOEValid','',correlationId, e.getMessage(), 'Order Enrichment validation for DMS',CONST_INTERFACENAME);
        }   
        return ( dmsConValid && dmsNotBeforeCrdValid );
    }
    
    // checking whether the contact have all required fields
    @TestVisible
    private static Boolean checkDmsConValid(String conId ,List<contact> listCon ){
        Boolean isConValid=true ;
        //  DIGI-23949 condition added
       // if (String.isBlank(conId))
       // {
         //   isConValid = false;
        //}
         if(listCon!=NULL && !listCon.isEmpty() && listCon.get(0)!=NULL && ( String.isBlank(listCon.get(0).FirstName) || String.isBlank(listCon.get(0).LastName) || String.isBlank(listCon.get(0).Phone) || String.isBlank(listCon.get(0).Email)) )
        {
            isConValid = false;
        }        
        return isConValid;
    }
    
    // checking if CRD dates are valid as per DMS 
    @TestVisible
    private static Boolean checkCrdDateValid(String attrDate){
        Boolean isCrdValid =true ;
        if(String.isBlank(attrDate)){    
            isCrdValid = false;
        }
        else{
            Date notBeforeCrd = Date.valueOf(attrDate);
            if(notBeforeCrd!= NULL && notBeforeCrd < System.Today() ){
                isCrdValid = false;
            }
        }
        return isCrdValid;
    }
    
    public static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription,String CONST_INTERFACENAME){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
    // DIGI-15582 & DIGI-22239 changes ends here --- added by shashank
}