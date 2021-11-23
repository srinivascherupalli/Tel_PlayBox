/*************************************************************************************************
Name        : PortOutReversalHelper
Description : Helper class for port otu reversal
Author      : Kalashree Borgaonkar
Story       : EDGE-142347
===============================================================================================================================
Change.No.    Developer Name    Date            Story Description
1.            Gnana             11-Oct-2020     EDGE-174924 - Replaced csord__Deactivation_Date__c with Deactivation_Date__c for daysleft calculation
2. Ankit Goswami                13-jan-2021      EDGE-197555    Set Subtype on wrapper
***************************************************************************************************/
public with sharing class PortOutReversalHelper {
	//EDGE-165481. Avail port out reversal for Adaptive Mobility
    private static string [] PROD_SPEC_VALUES=new string[]{'DMCAT_ProductSpecification_000419','DMCAT_ProductSpecification_000420','DMCAT_ProductSpecification_001196'};
        private static final Integer expiry = Integer.valueof(Label.SIMExpiryDuration);  
    /*************************************************************************************************
Name        : getProductConfigDetails
Description : get config details
Author      : Kalashree Borgaonkar
Story       : EDGE-142347
***************************************************************************************************/
    public static List<ProductConfigWrapper> getProductConfigDetails(String basketid){
        Boolean isExisting = false;
        List<ProductConfigWrapper> listProductCongifList = new List<ProductConfigWrapper>();
        List<cscfga__Product_Configuration__c> pcList = [SELECT cscfga__Serial_Number__c,name,
                                                         (SELECT Service_Number__c,Type__c ,Sim_Serial_Number__c, IMSI__c,SIM_Type__c,SimAvailabilityType__c FROM  Numbers__r),
                                                         (SELECT cscfga__Value__c FROM cscfga__Attributes__r 
                                                          WHERE name = 'UseExitingSIM' ) 
                                                         FROM cscfga__Product_Configuration__c 
                                                         WHERE cscfga__Product_Basket__c = :basketid 
                                                         AND cscfga__Product_Definition__r.product_Specification__c IN :PROD_SPEC_VALUES 
                                                         AND csordtelcoa__Replaced_Product_Configuration__c = null]; //Added SimAvailabilityType__c for EDGE-174219//EDGE-197555
        System.debug('pcList'+pcList);
        System.debug('basketid'+basketid);
        if(!pcList.isEmpty()){
            for(cscfga__Product_Configuration__c pconfig: pcList){
                ProductConfigWrapper configWrap = new ProductConfigWrapper();
                if(!pconfig.Numbers__r.isEmpty()){
                    configWrap.simSerial = pconfig.Numbers__r[0].Sim_Serial_Number__c;
                    configWrap.number_x = pconfig.Numbers__r[0].Service_Number__c;
                    configWrap.imsi = pconfig.Numbers__r[0].IMSI__c;
                    configWrap.simtypeval = pconfig.Numbers__r[0].SIM_Type__c;
                    configWrap.SimAvailibilityType = pconfig.Numbers__r[0].SimAvailabilityType__c;//Added for EDGE-174219
                     configWrap.pcSubType = pconfig.Numbers__r[0].Type__c;//EDGE-197555
                    
                }
                if(!pconfig.cscfga__Attributes__r.isEmpty()){
                    configWrap.isExistingSim = isExistingSim(pconfig.cscfga__Attributes__r[0]);
                }
                configWrap.name =  pconfig.name;
                configWrap.pcid =  pconfig.id;
                configWrap.serialNumber = pconfig.cscfga__Serial_Number__c;
                listProductCongifList.add(configWrap);
            }
        }
        return listProductCongifList;
    }
    /*************************************************************************************************
Name        : isExistingSim
Description : check is useExisitng is true
Author      : Kalashree Borgaonkar
Story       : EDGE-142347
***************************************************************************************************/
    public static Boolean isExistingSim(cscfga__Attribute__c attribute){
        Boolean isSimExisitng = false;
        if('Yes'.equalsIgnoreCase(attribute.cscfga__Value__c) ){
            isSimExisitng  = true;
        }
        return isSimExisitng;
    }
    /*************************************************************************************************
Name        : getSimAndImsiNumber
Description : get get Sim And Imsi Number
Author      : Kalashree Borgaonkar
Story       : EDGE-142347,EDGE-150425,EDGE-165480
***************************************************************************************************/
    public static NumberWithDaysLeft  getSimAndImsiNumber(String selectedNumber){
        NumberWithDaysLeft numberDetail = new NumberWithDaysLeft();
        String simNumber ='';
        //EDGE-165480. check if number is present.
        if(isNumberValid(selectedNumber)){
            List<Number__c> numberList= [SELECT Sim_Serial_Number__c,imsi__c,Basket__c,Service_Id__c 
                                         FROM  Number__c  
                                         WHERE Service_Number__c = :selectedNumber LIMIT 1] ;
            if(!numberList.isEmpty()){
                numberDetail.numberDetail= numberList[0];
                if(numberList[0].Service_Id__c!=null){
                    //EDGE-164617. Kalashree Borgaonkar. get number of days left for SIM to expire
                    numberDetail.daysLeft  = getDaysLeft(numberList[0].Service_Id__c);
                    if(numberDetail.daysLeft>0){
                        numberDetail.validationMessage = Label.SIMExpiryDaysLeftMessages.replace('<daysLeft>',String.valueOf(numberDetail.daysLeft)) ;// 'SIM expires in '+daysLeft+' days';
                    }
                    else{
                        numberDetail.validationMessage = Label.SIMExpiredMessage;
                    }
                }
            }
        }
        else{
            numberDetail.validationMessage = Label.PortOutReversalNumberNotFound;
        }
        return numberDetail;
    }
    /*************************************************************************************************
Name        : getDaysLeft
Description : calculate number of days left for SIM expiry
Author      : Kalashree Borgaonkar
Story       : EDGE-164617
***************************************************************************************************/
    public static Integer getDaysLeft(String serviceNumber){
        Integer daysLeft = 0;
        List<csord__Service__c > serviceList = [SELECT id,csord__Deactivation_Date__c,Deactivation_Date__c, lastmodifiedDate
                                                FROM csord__Service__c 
                                                WHERE csordtelcoa__Service_Number__c = :serviceNumber];
        if(!serviceList.isEmpty()){
            if(serviceList[0].csord__Deactivation_Date__c!=null){ // Replace csord__Deactivation_Date__c with Deactivation_Date__c for B2B-1553 capability
                daysLeft = expiry-Math.abs(Date.today().daysBetween(serviceList[0].csord__Deactivation_Date__c));                    
                //daysLeft = expiry-Math.abs(Date.today().daysBetween((serviceList[0].Deactivation_Date__c).date())); Need to uncomment this for B2B-1553 capability
            }
            else{
                daysLeft = expiry-Math.abs(Date.today().daysBetween(serviceList[0].lastmodifiedDate.date()));
            }
        }
        return daysLeft;
    }
    //EDGE-164617. Wrapper class for Number details
    public class NumberWithDaysLeft{
        @AuraEnabled
        public Number__c numberDetail;
        @AuraEnabled
        public String validationMessage;
        @AuraEnabled
        public Integer daysLeft;
    }
    /*************************************************************************************************
Name        : isNumberValid
Description : check if number exists in SFDC
Author      : Kalashree Borgaonkar
Story       : EDGE-142347
***************************************************************************************************/
    public static Boolean isNumberValid(String selectedNumber){
        Integer numCount = [SELECT count() 
                            FROM  Number__c  
                            WHERE Service_Number__c = :selectedNumber];
        return ((numCount==0)?false:true);
    }
    /*************************************************************************************************
Name        : checkInactiveAndPortedOutNumber
Description : check if number is inactive and ported out
Author      : Kalashree Borgaonkar
Story       : EDGE-165480
***************************************************************************************************/
    public static String checkInactiveAndPortedOutNumber(String selectedNumber){
        String validationMsg='Success';
        List<Number__c> numberList = [SELECT Service_Id__c,status__c
                                      FROM  Number__c  
                                      WHERE Service_Number__c = :selectedNumber LIMIT 1];
        if(!numberList.isEmpty()){
            if(!('Inactive'.equalsIgnoreCase(numberList[0].status__c))){
                validationMsg='ErrorMsg'+Label.PortOutReversalNumberStatus.replace('<Status>',numberList[0].status__c);
            }
            else{
                List<csord__Service__c > serviceList = [SELECT Scenario_Type__c
                                                        FROM csord__Service__c 
                                                        WHERE csordtelcoa__Service_Number__c = :numberList[0].Service_Id__c];
                if(!serviceList.isEmpty() && !'Port Out'.equalsIgnoreCase(serviceList[0].Scenario_Type__c)){
                    validationMsg='ErrorMsg'+Label.PortOutReversalNumberNotportedOut;    
                }                                        
            }
        } 
        return validationMsg;
    }
    /*************************************************************************************************
Name        : createNumberRecord
Description : create number record
Author      : Kalashree Borgaonkar
Story       : EDGE-142347
***************************************************************************************************/

    public static String createNumberRecord(String selectedNumber, String pcid, String sim, String imsi, String simType, String simAvailability, String neworExisiting){
        String status = Label.Number_Assignment_Success;
        try{
            //EDGE-142347 check invalid number
            Boolean isValid = isNumberValid(selectedNumber);
            if(isValid==false){
                //EDGE-165480 Custom message if Number is not present in salesforce.
                return 'ErrorMsg'+Label.PortOutReversalNumberNotFound;
            }
            status = checkInactiveAndPortedOutNumber(selectedNumber);
            if(status != 'Success'){
                //EDGE-165480 Custom message if Number is not present in salesforce.
                return status;
            }
            
            //EDGE-170886 - To check whether entered serialnumber is valid or not as part the SIMass Interface responce. 
            else{
                if(neworExisiting == 'Existing Blank SIM'){
                    String captureSerialNumberRes = validateSIMSerialNumber(sim,simType);
                    if(captureSerialNumberRes != 'AVAILABLE'){
                        return 'ErrorMsg' + captureSerialNumberRes ;
                        }
                    //Number record creation code has moved to 'numberRecCreation'method
                    else{
                        system.debug('@V@ Adaptive');
                        Status = numberRecCreation(selectedNumber, pcid, sim, imsi, simType, simAvailability,neworExisiting); 
                    }
                    }
                else{
                    system.debug('@V@ CMP');

                    Status = numberRecCreation(selectedNumber, pcid, sim, imsi, simType, simAvailability,neworExisiting); 
                } 
            }
        }
        catch(Exception ex){
            status = 'Number has been already assinged to the plan';
            System.debug('Exception in createNumberRecord : '+ex.getStackTraceString());
        }
        return status;
    } 
    /*************************************************************************************************
Name        : removeSelected
Description : remove number to PC association, delete number
Author      : Kalashree Borgaonkar
Story       : EDGE-142347
***************************************************************************************************/
    public static String removeSelected(String selectedPCid){
        String result='Failure';
        try{
            List<String> pcidList = (List<String>) JSON.deserialize(selectedPCid, List<String>.class);
            List<Number__c> numList = [SELECT id,product_configuration__c FROM Number__c WHERE product_configuration__c IN :pcidList];
            if(!numList.isEmpty()){
                delete numList;
                result = 'Success';
            } 
        }
        catch(Exception ex){
            result = 'Failure';
            System.debug('Exception in removeSelected : '+ex.getStackTraceString());
        } 
        return result;
    }
    public static Boolean finishReservation(String basketid){
        Boolean isValid = true;
        List<cscfga__Product_Configuration__c> pcList = [SELECT cscfga__Serial_Number__c,name,
                                                         (SELECT id FROM  Numbers__r)
                                                         FROM cscfga__Product_Configuration__c 
                                                         WHERE cscfga__Product_Basket__c = :basketid 
                                                         AND cscfga__Product_Definition__r.product_Specification__c IN :PROD_SPEC_VALUES 
                                                         AND csordtelcoa__Replaced_Product_Configuration__c = null];   
        for(cscfga__Product_Configuration__c pc : pcList){
            if(pc.Numbers__r== null || pc.Numbers__r.isEmpty()){            
                isValid=false; 
                break;
            }  
        }
        return isValid;
    }
    /*************************************************************************************************
EDGE        -EDGE-165481,171843
Method      -getPortOutReversalRadio 
Description -Check whether to show Por out reversal or not. 
Author      -Kalashree Borgaonkar
***************************************************************************************************/
    public static Boolean cafMandatoryOnEnrichBasket(String basketid){
        Boolean isValid=false;
        List<cscfga__Product_Basket__c> basket = [SELECT cscfga__Opportunity__c 
                             					 FROM cscfga__Product_Basket__c where id=:basketid];
        if(!basket.isEmpty()){
            isValid=SubmitOrderOrchestration.checkPortOutReversalOrderCaForm(basket[0].cscfga__Opportunity__c);
        }
        
        return isValid;
    }
    
    /*************************************************************************************************
EDGE        -EDGE-170886
Method      -getPortOutReversalRadio 
Description -Check whether entered serialnumber is valid or not as part the SIMass Interface responce. 
Author      -Veena Putta
***************************************************************************************************/
    public static String validateSIMSerialNumber(String simSerialNumber, String simType){
        Map<String,Map<String,String>> resMap = new Map<String,Map<String,String>>();
        Map<String,String> simSerialNumbersMap=new Map<String,String>();
        List<String> names=new List<String>{'SIM Type','SIM Category','Order ID'};
            
            if(simSerialNumber !=null){
                simSerialNumbersMap.put(simSerialNumber,simType);
                resMap = ValidateSIMInterface.ValidateSimSerial(simSerialNumbersMap,false,false,names);
                system.debug('resMap ' +resMap);
                if(resMap != null){
                    for(String lrmstatus : resMap.keyset()){
                        for(String lrm : resMap.get(lrmstatus).keyset()){ 
                            if(lrm ==simSerialNumber){
                                return resMap.get(lrmstatus).get(lrm);
                            }
                            else{
                                return resMap.get(lrmstatus).get(lrm); 
                            }
                        }
                    }
                }
            }
        
        return null;
    }
    
       /*************************************************************************************************
Name        : numberRecCreation
Description : Number record creation is happening here 
Author      : Veena Putta
***************************************************************************************************/    
    public static string numberRecCreation(String selectedNumberVal, String pcidVal, String simVal, String imsiVal, String simTypeVal, String simAvailabilityVal, String neworExisitingVal){
        String status;
        List<cscfga__Product_Configuration__c> pcList = [SELECT cscfga__Product_Basket__c,cscfga__Product_Basket__r.csordtelcoa__Account__c,
                                                         (SELECT id,service_number__c FROM numbers__r)
                                                         FROM cscfga__Product_Configuration__c 
                                                         WHERE id = :pcidVal
                                                        ];
        system.debug('@V@ pcList' +pcList);
        if(!pcList.isEmpty()){
            system.debug('@V@ Inside if');
            for(Number__c num : pcList[0].numbers__r){
                if(num.service_number__c == selectedNumberVal){
                    //EDGE-165480 Custom message if Number has been assigned.
                    return 'InfoMsg'+Label.PortOutReversalNumberAlreadyAssigned;  
                }
            }
            if(!pcList[0].numbers__r.isEmpty()){
                delete pcList[0].numbers__r;
            }
            Number__c numberRec = new Number__c();
            system.debug('#V# test');
            numberRec.Service_Number__c = selectedNumberVal;
            numberRec.Product_Configuration__c = pcidVal;
            numberRec.Sim_Serial_Number__c = simVal;
            numberRec.IMSI__c = imsiVal;
            numberRec.SIM_Type__c = simTypeVal; // EDGE-166187
            numberRec.SimAvailabilityType__c = simAvailabilityVal; //EDGE-166187
            numberRec.Mobile__c = 'Mobile';
            numberRec.type__c = 'Port Out Reversal';
            numberRec.basket__c = pcList[0].cscfga__Product_Basket__c;
            numberRec.Account__c =  pcList[0].cscfga__Product_Basket__r.csordtelcoa__Account__c;
            // As part of EDGE-193420 , marking isSimvalid__c is true 
           if(neworExisitingVal == 'Existing Blank SIM' ){
                numberRec.isSimvalid__c = true;
            }           
            insert numberRec;
             //197555. Removing mapping as this will be done on validate and save.
            /*Map<Id,String> mapNumTypeToPcSubtype=new Map<Id,String>();
            mapNumTypeToPcSubtype.put( numberRec.Product_Configuration__c,numberRec.type__c);
            NumberReservationHelper.mapNumTypeToPCSubtype(mapNumTypeToPcSubtype);///EDGE-179277:Calling method to map Number Type to PC subtype 
            */
            status = 'SuccessMsg'+Label.Number_Assignment_Success;
            System.debug('numberRec: '+numberRec.id); 
            return status;
        }
        return null;
    }
    
    public class ProductConfigWrapper{
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String number_x;
        @AuraEnabled
        public String simSerial;
        @AuraEnabled
        public String serialNumber;
        @AuraEnabled
        public String pcid;
        @AuraEnabled
        public String imsi;
        @AuraEnabled
        public String simtypeval;  
        @AuraEnabled
        public Boolean isExistingSim;
         @AuraEnabled
        public String SimAvailibilityType; //Added for EDGE-174219       
        @AuraEnabled
        public string pcSubType ;  //EDGE-197555 added by ankit  
    }  
    
}