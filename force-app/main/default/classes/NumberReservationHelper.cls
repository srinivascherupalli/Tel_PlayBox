/*************************************************************************************************
Name : NumberReservationHelper
Description :Helper class for Modified Number Reservation 
Author: Kalashree Borgaonkar, Abinash
Story: EDGE-140792,EDGE-138086
Test Class: NumberReservationHelperTest, NumberReservationHelperFnnTest
Revision: 1. Sandip Deshmane    //EDGE-149261 - Added to set SIMSerial Number based on Plan Type
2. Ankit Goswami       EDGE-197555    Set Subtype on wrapper
3. Anuj Pathak         EDGE-208737    Added Customerfacingid for nguc prodconfg
4 Dheeraj Bhatt        EDGE-203934    Transition Number Management enhancements to enable like to like PLAN mapping for migration services from legacy.
5. Vivek               EDGE-220794    Number Reservation to be optional for Telstra Collaboration.
6. Pawan Devaliya       08-Sep-2021        DIGI-18183: Added new parameter in payload : Fulfilment Order Version
***************************************************************************************************/
public with sharing class NumberReservationHelper {
    public static final String SEARCH =  'SEARCH';
    public static final string TYPE_NEW='New';
    public static final string TYPE_PORT='Port In';
    public static final string TYPE_TRANSITION = 'Transition';
    private static string [] PROD_SPEC_VALUES=new string[]{'DMCAT_ProductSpecification_000419','DMCAT_ProductSpecification_000420','DMCAT_ProductSpecification_001196'};//EDGE-153402
    private static string [] NGUC_PROD_SPEC_VALUES=new string[]{'DMCAT_ProductSpecification_000871'};
    private static String correlationId = GuidUtil.NewGuid();
    /******************************************************************
EDGE-126317
Method:getPatternType 
Description: get Pattern type based on serach type 
Author:Kalashree Borgaonkar
******************************************************************/  
    @AuraEnabled
    public static List<SelectOptionz> getPatternType(String searchType) {
        List<SelectOptionz> patternTypeList = new List<SelectOptionz>();
        patternTypeList.add(new SelectOptionz('None','None'));
        List<Fixed_Number_Search_types__mdt> patternList=[SELECT Is_Include_in_Picklist__c,Pattern_type__c 
                                                          FROM Fixed_Number_Search_types__mdt 
                                                          WHERE Search_type__c=:searchType AND Is_Include_in_Picklist__c=TRUE];
        for(Fixed_Number_Search_types__mdt pattern:patternList){
            patternTypeList.add(new SelectOptionz(pattern.Pattern_type__c,pattern.Pattern_type__c));
        }
        return patternTypeList;
    }
    /******************************************************************
EDGE        -140792
Method      -createSearchPayload 
Description -createPayload for search
Author      -Kalashree Borgaonkar
******************************************************************/ 
    public static FNNSearchRequestDTO createSearchPayload(NumberReservationController.NumberReserve searchObj,String tabStyle){
        Integer resSize=0;
        FNNSearchRequestDTO fnnDto = new FNNSearchRequestDTO();
        FNNSearchRequestDTO.data fdo=new FNNSearchRequestDTO.data();
        fdo.quantity = searchObj.Quantity;
        //EDGE-126317. Kalashree Borgaonkar. Changes for Contiguous pattern. Start
        String pattern = getPattern(searchObj);
        if(pattern!=null){
            fdo.pattern = pattern;
        }
        //EDGE-126317. Kalashree Borgaonkar. Changes for Contiguous pattern. End
        fdo.activityName = SEARCH;
        fdo.searchType = searchObj.selectedSearchType;
        fdo.ageOut='5';//Added as a part of production incident INC000093614716
        if(tabStyle=='Mobile'){
            fdo.resourceType = 'Mobile';
            fdo.premiumType = 'Regular';
        }
        else{
            fdo.resourceType = 'Fixed';
            //EDGE-100661 starts
            if(searchObj.selectedAreaCode != ''){
                fdo.nationalDestinationCode = searchObj.selectedAreaCode;
            }
            System.debug('searchObj.deliveryAddress-->'+searchObj.deliveryAddress);
            cscrm__Address__c   address = (cscrm__Address__c)searchObj.deliveryAddress;
            if(address!=null && address.Address_ID__c != ''){
                fdo.addressId = address.Address_ID__c ;
            }
            if(searchObj.sameExchange==true && address!=null && address.ESA_Code__c != ''){
                fdo.geoParam = 'ESA';
                fdo.geoParamValue = address.ESA_Code__c;
            }
        }
        //EDGE-100661 ends
        fnnDto.data = fdo;
        return fnnDto;
    }
    /*****************************************************************
Story       -EDGE-126317
Method      -getPattern 
Description -get pattern type. (reducing cyclomatic complexity)
Author      -Kalashree Borgaonkar
******************************************************************/
    
    public static string getPattern(NumberReservationController.NumberReserve searchObj){
        string pattern=null;
        if(searchObj.selectedSearchType.equalsIgnoreCase('Contiguous') && searchObj.selectedPatternType.equalsIgnoreCase('None')){
            pattern = '*00';
        }
        if(searchObj.reqpattern!=null  && searchObj.selectedPatternType.equalsIgnoreCase('Starts With')){
            pattern = string.valueOf(searchObj.reqPattern)+'*';
        }  
        else if(searchObj.reqPattern!=null  && searchObj.selectedPatternType.equalsIgnoreCase('Ends With')){
            pattern = '*'+string.valueOf(searchObj.reqPattern);
        }    
        else if(searchObj.reqPattern!=null  && searchObj.selectedPatternType.equalsIgnoreCase('Contains')){
            pattern = '*'+string.valueOf(searchObj.reqPattern)+'*';
        }
        if(searchObj.selectedSearchType.equalsIgnoreCase('Contiguous') && pattern!=null ){
            pattern = pattern + '00';
        }
        return pattern;
    }
    /*****************************************************************
EDGE        -93081,140792
Method      -createSearchPayload 
Description -LRM Reserve and AutoReserve for MSISDN Numbers
Author      -Kalashree Borgaonkar
******************************************************************/
    public static String autoReserveMSISDN(String basketId,Integer searchQuan){
        List<String> lstfinaltoReserve = new List<String>(); //Abinash
        List<NumberReservationController.LRMWrapper> msisdnList = new List<NumberReservationController.LRMWrapper>();
        String status = 'No Number found.';    
        if ((searchQuan != NULL && searchQuan > 0))
        {
            //EDGE-92021 Start
            FNNSearchRequestDTO fnnDto = new FNNSearchRequestDTO();
            FNNSearchRequestDTO.data fdo=new FNNSearchRequestDTO.data();
            fdo.quantity = searchQuan;
            fdo.resourceType = 'Mobile';
            fdo.activityName = 'Reserve Next Available';  
            fnnDto.data = fdo;
            FNNSearchResponseDTO fnnResponse = NumberReservationFixedHandler.searchFNN(fnnDto);
            if(fnnResponse != NULL && fnnResponse.data != NULL && fnnResponse.data.resources != NULL){
                for(FNNSearchResponseDTO.Resources res : fnnResponse.data.resources){
                    //Added by aishwarya
                    lstfinaltoReserve.add(res.resourceId);
                    NumberReservationController.LRMWrapper wrap = new NumberReservationController.LRMWrapper();
                    wrap.numberList= res.resourceId;
                    msisdnList.add(wrap);
                }
            }
            //Added by Aishwarya
            if(!lstfinaltoReserve.isEmpty()){
                MSISDNService.saveReserveMSISDN(lstfinaltoReserve,basketId);
                status = 'Success';            
            }           
        }
        return Status;
    }   
    /*****************************************************************
EDGE        -93081,140792
Method      -createSearchPayload 
Description -LRM Reserve and AutoReserve for MSISDN Numbers
Author      -Kalashree Borgaonkar
******************************************************************/
    public static String reserveNumbers(String fnnListToReserve,String selectedTab,String basketId){
        String status='';
        List<String> msisdnDetailsList = (List<String>)System.JSON.deserialize(fnnListToReserve, List<String>.Class);
        NumberReservationFixedHandler.ResponseWrapper responseWrapperList = new NumberReservationFixedHandler.ResponseWrapper();
        responseWrapperList = NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(msisdnDetailsList,basketId,'Held Order',selectedTab);
        if((responseWrapperList.resIds != null && responseWrapperList.resIds.size() > 0) || responseWrapperList.successMsg != null){
            status = 'Success';
        }else if(responseWrapperList.errList != null){
            for(NumberReservationFixedHandler.ErrorList error: responseWrapperList.errList){
                status = status + '\n'+ error.resourceId + '-'+ error.message;
            }
        }   
        return Status;
    }
    /*****************************************************************
EDGE        -93081,140792
Method      -assignMSISDNNumbers
Description -Assign MSISDN Numbers
Author      -Kalashree Borgaonkar
******************************************************************/   
    public static Object assignMSISDNNumbers(List<string> selectedPcWrapper, List<string> selectedNumbers,String basketId, String selectedSimTypeValue,String newWxistingSIM,String selectedOption){
        List<Number__C> remainingNumberList = new  List<Number__C>();
        List<String> remianingWrapperList = new List<String>();
        set<String> selectedProdConfigSet = new set<String>();
        Map<Id,Number__C> selectedNumberMap = new Map<Id,Number__C>();
        set<String> existingPlanSet = new set<String>();
        Map<Id,Number__C> rejectedNumberMap = new Map<Id,Number__C>();
        List<Number__C> transitionedNumberList = new List<Number__C>();
        Map<Id,Number__C> numberWithNoSuitablePlanMap = new Map<Id,Number__C>();
        Map<string,string>migrationLegacyPlanMap= new map<string,string>();
        Map<string,string>productConfigPlanMap= new map<string,string>();
        Map<String,Object> resultMap = new Map<String,Object>();
        Boolean isMigration=false;
        //EDGE-149261 - Added 2 fields in Query
        //EDGE-176409-Adaptive mobility- More than one number is getting assigned to the Plan
        try{
            List<Number__c>  lstSelectedNumbers=  [SELECT id,Product_Configuration__c,Basket__c,Basket__r.Opportunity_Type__c,SimAvailabilityType__c,Product_Specification_Code__c,
                                                   SIM_Type__c,Sim_Serial_Number__c, Type__c ,Plan_Type__c,Error_in_assigning_plan__c,
                                                   Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,Plan_Name__c
                                                   FROM Number__c WHERE service_number__c IN :selectedNumbers AND basket__c=:basketId]; 
            
            Map<Id, cscfga__Product_Configuration__c> pcMap =new Map<Id, cscfga__Product_Configuration__c>([SELECT Id,Name,Type__c,cscfga__Product_Basket__r.Name,cscfga__Product_Basket__r.csbb__Account__r.Name,
                                                                                                            cscfga__Product_Definition__r.Name,cscfga__Product_Definition__r.product_Specification__c
                                                                                                            FROM cscfga__Product_Configuration__c  WHERE Id In: selectedPcWrapper ]);
            //EDGE-203934-Dheeraj Bhatt-Transition Number Management enhancements to enable like to like PLAN mapping for migration services from legacy.                                                                                               
            if(!lstSelectedNumbers.isEmpty() && lstSelectedNumbers[0].Basket__r.Opportunity_Type__c=='Migration'){
                isMigration=true;
                for(MigrationPlanMapping__mdt plan:[SELECT id,Digi_Plan__c,Legacy_Plan_Name__c,DeveloperName,Legacy_Product_Code__c FROM MigrationPlanMapping__mdt]){
                    migrationLegacyPlanMap.put(plan.Legacy_Plan_Name__c,plan.Digi_Plan__c);
                }
                for(cscfga__Attribute__c att: [SELECT name,cscfga__Value__c, cscfga__Product_Configuration__c  
                                               FROM cscfga__Attribute__c WHERE (name = 'SelectPlanName' Or  name = 'PlanTypeString' ) 
                                               AND cscfga__Product_Configuration__c In:selectedPcWrapper])
                {
                    if(!productConfigPlanMap.isEmpty() && productConfigPlanMap.containsKey(att.cscfga__Product_Configuration__c)){
                        string planName= productConfigPlanMap.get(att.cscfga__Product_Configuration__c);
                        if(att.Name=='PlanTypeString'){
                            planName=att.cscfga__Value__c+' '+planName;
                        }
                        else if(att.Name=='SelectPlanName'){
                            planName=planName+' '+att.cscfga__Value__c;
                        }
                        productConfigPlanMap.put(att.cscfga__Product_Configuration__c,planName);
                    }
                    else{
                        productConfigPlanMap.put(att.cscfga__Product_Configuration__c,att.cscfga__Value__c);
                    }
                }
            }
            for(Number__C numberRecord : lstSelectedNumbers){
                if(numberRecord.Plan_Type__c != null){
                    existingPlanSet.add(numberRecord.Plan_Type__c);
                }
            }
            List<LegacyDigitalPlanTypes__mdt> legacyPlanMdtList = [SELECT Legacy_Plan_type__c,Digi_Plan_type__c,Comments__c FROM  LegacyDigitalPlanTypes__mdt WHERE Legacy_Plan_type__c IN : existingPlanSet];
            Map<String,List<String>> legacyPlanMap = new Map<String,List<String>>();
            for(LegacyDigitalPlanTypes__mdt mdtRecord : legacyPlanMdtList){
                
                if(mdtRecord.Legacy_Plan_type__c != null && mdtRecord.Digi_Plan_type__c != null){
                    
                    if (legacyPlanMap.containsKey(mdtRecord.Legacy_Plan_type__c)) {
                        legacyPlanMap.get(mdtRecord.Legacy_Plan_type__c).add(mdtRecord.Digi_Plan_type__c);
                    } else {
                        legacyPlanMap.put(mdtRecord.Legacy_Plan_type__c, new List<String>{ mdtRecord.Digi_Plan_type__c});
                    }
                }
            } // INC000097769014 incident Fix
            String result='Error'; 
            //EDGE-149261 - Fetching Attribute to check Plan Name
            List<cscfga__Attribute__c> attrList = [SELECT name,cscfga__Value__c,cscfga__Display_Value__c, cscfga__Product_Configuration__c 
                                                   FROM cscfga__Attribute__c WHERE (name = 'SelectPlanName'  OR name = 'SimAvailabilityType')
                                                   AND cscfga__Product_Configuration__c IN: selectedPcWrapper]; // Added By vijay DIGI-456 || start
            
            List<cscfga__Attribute__c> attrListForTransition = [SELECT cscfga__Value__c, cscfga__Product_Configuration__c 
                                                                FROM cscfga__Attribute__c WHERE name = 'PlanTypeString' 
                                                                AND cscfga__Product_Configuration__c IN: selectedPcWrapper];
            Map<String, String> pcPlanNameMap = new Map<String, String>();
            List<cscfga__Attribute__c>simAttrUpdate=new List<cscfga__Attribute__c>();
            for(cscfga__Attribute__c planName:attrList){
                pcPlanNameMap.put(planName.cscfga__Product_Configuration__c, planName.cscfga__Value__c);
                // Added By vijay DIGI-456 || start
                if(newWxistingSIM !=null && planName.name=='SimAvailabilityType'){
                    planName.cscfga__Value__c=newWxistingSIM;
                    planName.cscfga__Display_Value__c=newWxistingSIM;
                    simAttrUpdate.add(planName);
                }
                // Added By vijay DIGI-456 || end
            }//EDGE-149261-End
            // Added By vijay DIGI-456 || start
            if(!simAttrUpdate.isEmpty()){
                update simAttrUpdate;
            }
            // Added By vijay DIGI-456 || End
            Map<String, String> transitionPlanMap = new Map<String,String>();
            for(cscfga__Attribute__c planName:attrListForTransition){
                if(planName.cscfga__Product_Configuration__c!=null &&  planName.cscfga__Value__c!=null){
                    transitionPlanMap.put(planName.cscfga__Product_Configuration__c, planName.cscfga__Value__c);
                }
            }
            if(!lstSelectedNumbers.isEmpty()){
                //EDGE-176409-Adaptive mobility- More than one number is getting assigned to the Plan
                List<Number__c> removePCFromAssingedNumber= new List<Number__c>();
                for(Number__c num:[SELECT id,Product_Configuration__c,Basket__c,SimAvailabilityType__c,Product_Specification_Code__c,
                                   SIM_Type__c,Sim_Serial_Number__c, Type__c ,Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c
                                   FROM Number__c WHERE Product_Configuration__c IN: selectedPcWrapper]){
                                       num.Product_Configuration__c=null;//remove assingned PC from Number
                                       num.SIM_Type__c='';
                                       num.SimAvailabilityType__c =''; 
                                       removePCFromAssingedNumber.add(num);
                                       
                                   }
                update removePCFromAssingedNumber; 
                Map<id,String> mapNumtypeTopc=new Map<id,String>();///EDGE-179277
                if(selectedOption=='Transition'){
                    for(Number__c numberRecord : lstSelectedNumbers){
                        if((numberRecord.Plan_Type__c != null && legacyPlanMap.containskey(numberRecord.Plan_Type__c)) || (String.isNotBlank(numberRecord.Plan_Name__c) && isMigration && !migrationLegacyPlanMap.isEmpty() && migrationLegacyPlanMap.containskey(numberRecord.Plan_Name__c))){
                           List<String> legacyValue = legacyPlanMap.get(numberRecord.Plan_Type__c); //INC000097769014 Fix
                            for(String wrapperValue : selectedPcWrapper){                              
                                if(!isMigration && transitionPlanMap.containsKey(wrapperValue) && (((legacyValue.contains(transitionPlanMap.get(wrapperValue))) || (transitionPlanMap.get(wrapperValue)=='Mobile Broadband' && numberRecord.Plan_Type__c=='Mobile Broadband') || (transitionPlanMap.get(wrapperValue)=='Handheld' && numberRecord.Plan_Type__c=='PostPaid Handheld'))) && !selectedProdConfigSet.contains(wrapperValue) &&  !selectedNumberMap.containsKey(numberRecord.Id)){
                                    numberRecord.Product_Configuration__c = wrapperValue;
                                    numberRecord.SIM_Type__c = selectedSimTypeValue;
                                    numberRecord.SimAvailabilityType__c = newWxistingSIM;
                                    mapNumtypeTopc.put(wrapperValue,numberRecord.Type__c);
                                    selectedNumberMap.put(numberRecord.Id,numberRecord);
                                    selectedProdConfigSet.add(wrapperValue);
                                    transitionedNumberList.add(numberRecord);
                                    if(numberWithNoSuitablePlanMap.containsKey(numberRecord.Id)){
                                        numberWithNoSuitablePlanMap.remove(numberRecord.Id);
                                    }
                                    break;
                                }
                                //EDGE-203934-Dheeraj Bhatt-Transition Number Management enhancements to enable like to like PLAN mapping for migration services from legacy.                                                                                                WHERE Id In: selectedPcWrapper ]);
                                else if(isMigration && !migrationLegacyPlanMap.isEmpty() && !productConfigPlanMap.isEmpty() && !selectedProdConfigSet.contains(wrapperValue) &&  !selectedNumberMap.containsKey(numberRecord.Id) && productConfigPlanMap.containsKey(wrapperValue) && productConfigPlanMap.get(wrapperValue) == migrationLegacyPlanMap.get(numberRecord.Plan_Name__c)){
                                    numberRecord.Product_Configuration__c = wrapperValue;
                                    numberRecord.SIM_Type__c = selectedSimTypeValue;
                                    numberRecord.SimAvailabilityType__c = newWxistingSIM;
                                    mapNumtypeTopc.put(wrapperValue,numberRecord.Type__c);
                                    selectedNumberMap.put(numberRecord.Id,numberRecord);
                                    selectedProdConfigSet.add(wrapperValue);
                                    transitionedNumberList.add(numberRecord);
                                    if(numberWithNoSuitablePlanMap.containsKey(numberRecord.Id)){
                                        numberWithNoSuitablePlanMap.remove(numberRecord.Id);
                                    }
                                    break;
                                }
                                else if(numberRecord.Plan_Type__c!='Unknown'){
                                    numberWithNoSuitablePlanMap.put(numberRecord.Id,numberRecord);
                                }
                            }
                            
                        } 
                        else{
                            rejectedNumberMap.put(numberRecord.Id,numberRecord);
                        }
                    }
                    for(Number__c numberRecord : lstSelectedNumbers){
                        if(!selectedNumberMap.containsKey(numberRecord.Id) && !numberWithNoSuitablePlanMap.containsKey(numberRecord.Id) && !rejectedNumberMap.containsKey(numberRecord.Id) && numberRecord.Plan_Type__c=='Unknown'){
                            remainingNumberList.add(numberRecord);
                        }
                    }
                    for(String wrapperValue : selectedPcWrapper){
                        if(!selectedProdConfigSet.contains(wrapperValue)){
                            remianingWrapperList.add(wrapperValue);
                        }
                    }
                    if(rejectedNumberMap.values().size() > 0 || numberWithNoSuitablePlanMap.values().size() > 0){
                        result='Error'; 
                    }
                    
                }
                else{
                    remainingNumberList.addAll(lstSelectedNumbers);
                    remianingWrapperList.addAll(selectedPcWrapper);
                }
                if(remainingNumberList.size() > 0){
                    for(integer i=0; i<remianingWrapperList.size(); i++){
                        if(!selectedProdConfigSet.contains(remianingWrapperList[i]) && !selectedNumberMap.containsKey(remainingNumberList[i].Id) && !rejectedNumberMap.containsKey(remainingNumberList[i].Id)){
                            remainingNumberList[i].Product_Configuration__c=remianingWrapperList[i];
                            //remainingNumberList[i].SIM_Type__c=selectedSimTypeValue;//EDGE-165572 Assign Selected simType
                            remainingNumberList[i].SimAvailabilityType__c =newWxistingSIM; 
                            //EDGE-193567 
                            if(remainingNumberList[i].Product_Configuration__c != null && (pcMap.get(remainingNumberList[i].Product_Configuration__c).cscfga__Product_Definition__r.product_Specification__c) == 'DMCAT_ProductSpecification_001196'){
                                remainingNumberList[i].SIM_Type__c=selectedSimTypeValue;//EDGE-165572 Assign Selected simType
                            }
                            else if(remainingNumberList[i].Product_Configuration__c != null && (pcMap.get(remainingNumberList[i].Product_Configuration__c).cscfga__Product_Definition__r.product_Specification__c) == 'DMCAT_ProductSpecification_000420'){
                                remainingNumberList[i].SIM_Type__c='SIM card'; //EDGE-229046 Defect Fix (CMP)
                            }
                            else{
                                remainingNumberList[i].SIM_Type__c=null;
                            }
                            mapNumtypeTopc.put(remianingWrapperList[i],remainingNumberList[i].Type__c);///EDGE-179277
                            
                        }
                    }
                }
                if(selectedOption=='Transition'){  
                    remainingNumberList.addAll(transitionedNumberList);
                }
                update remainingNumberList;
                //197555. Removing mapping as this will be done on validate and save.                                                         
                //  mapNumTypeToPCSubtype(mapNumtypeTopc);///EDGE-179277:Calling method to map Number Type to PC subtype 
                if(rejectedNumberMap.isEmpty() && numberWithNoSuitablePlanMap.isEmpty()){
                    result='Success';
                }
            }
            if(result == 'Success'){
                resultMap.put('Status','Success');
            }
            else{
                Map<Id,Number__C> errorNumberMap = new Map<Id,Number__C>();
                resultMap.put('Status','Error');
                Integer unassignedCount = 0;
                Integer assignedCount = 0;
                if(rejectedNumberMap.values().size() > 0){
                    unassignedCount = unassignedCount + rejectedNumberMap.values().size();
                    for(Number__C num : rejectedNumberMap.values()){
                        num.Error_in_assigning_plan__c = true;
                        errorNumberMap.put(num.Id,num);
                    }
                }
                if(numberWithNoSuitablePlanMap.values().size() > 0){
                    unassignedCount = unassignedCount + numberWithNoSuitablePlanMap.values().size();
                    for(Number__C num : numberWithNoSuitablePlanMap.values()){
                        num.Error_in_assigning_plan__c = true;
                        errorNumberMap.put(num.Id,num);
                    }
                }
                if(errorNumberMap.values().size() > 0){
                    update errorNumberMap.values();
                }
                if(transitionedNumberList.size() > 0){
                    assignedCount = assignedCount + transitionedNumberList.size();
                }
                resultMap.put('assignedCount',assignedCount);
                resultMap.put('unassignedCount',unassignedCount);
            }
            return resultMap;
        }
        catch(Exception ex){
            return resultMap;
        }
    }
    
    
    /******************************************************************
EDGE        -140792
Method      -assignFixedNumbers 
Description -Assign FNNs to PC
Author      -Kalashree Borgaonkar
******************************************************************/       
    public static string assignFixedNumbers(List<string> selectedPcWrapper, List<string> selectedNumbers, 
                                            String basketId,String selectedSimTypeValue,String newWxistingSIM, String selectedTab, String selectedOption ){
                                                List<Number__C> lstSelectedNumbers = new List<Number__C>();
                                                List<Number__C> lstUpdateNumbersNCS = new List<Number__C>();
                                                List<Number_Group__c> listNumberGrp = new List<Number_Group__c>();
                                                
                                                List<String> startRange = new List<String> ();      
                                                String result='Error';  
                                                try{
                                                    if(selectedNumbers!= null && !selectedNumbers.isEmpty()){  
                                                        for(String fnn: selectedNumbers){
                                                            String stRange = fnn.substringbefore(' -');
                                                            startRange.add(stRange);
                                                        }
                                                        List<Id> numbersWithoutNumberGrp = new List<Id>();
                                                        for (Number__c selectedNumber : [SELECT id, Type__c,  number_Group__c,number_Group__r.Product_Configuration__c, Product_Configuration__c,Service_Number__c,Start_Range__c,End_Range__c 
                                                                                         FROM Number__c WHERE (Service_Number__c in:selectedNumbers OR Start_Range__c IN :startRange) 
                                                                                         AND basket__c = :basketId]){
                                                                                             lstSelectedNumbers.add(selectedNumber);
                                                                                             if(selectedNumber.Number_Group__c == null){// will be null in "add" scenario, will be populated in Transition scenario
                                                                                                 numbersWithoutNumberGrp.add(selectedNumber.Id);
                                                                                             }
                                                                                         }
                                                        if( selectedPcWrapper!=null && !selectedPcWrapper.isEmpty()){
                                                            // EDGE-221909 changes startrs here 
                                                            // check to see if NG exists or not | 
                                                            if (selectedTab == 'Fixed'  && numbersWithoutNumberGrp.size() > 0) {  //## selectedTab, selectedOption ->make sure to add it  
                                                                listNumberGrp = [SELECT Id,Product_Basket__c,Status__c,Scenario_Type__c FROM Number_Group__c  WHERE Product_Configuration__c =:selectedPcWrapper[0] AND Status__c = 'Reserved' AND Scenario_Type__c  = 'Add'  AND Product_Basket__c =:basketid WITH SECURITY_ENFORCED ];
                                                                if (listNumberGrp.isEmpty()) { 
                                                                    Number_Group__c numGroup = new Number_Group__c();
                                                                    numGroup.Product_Configuration__c =selectedPcWrapper[0];
                                                                    numGroup.Product_Basket__c = basketid;
                                                                    numGroup.Status__c = 'Reserved';
                                                                    numGroup.Scenario_Type__c = 'Add';
                                                                    listNumberGrp.add(numGroup);
                                                                    
                                                                    if (!listNumberGrp.isEmpty() && Number_Group__c.SObjectType.getDescribe().isAccessible()){
                                                                        insert listNumberGrp;
                                                                    }   
                                                                }
                                                            }
                                                            // EDGE-221909 changes ends here 
                                                            Set<number_group__c> setNumberGrp = new Set<number_group__c>();
                                                            for(Number__C num : lstSelectedNumbers){
                                                                //EDGE-166363. Kalashree. Fix to avoid duplicate entries in NCS by checking if the number is assigned to the PC
                                                                if(num.Product_Configuration__c!=selectedPcWrapper[0]){
                                                                    num.Product_Configuration__c=selectedPcWrapper[0];
                                                                    // change for 1325 by shashank -- starts here 
                                                                    if (num.number_group__c!=Null){
                                                                        number_group__c newnumbGroup = new number_group__c(id=num.number_group__c,Product_Configuration__c  = selectedPcWrapper[0]);
                                                                        setNumberGrp.add(newnumbGroup);
                                                                    }
                                                                    // change for 1325 by shashank -- ends here 
                                                                    
                                                                    num.SIM_Type__c=selectedSimTypeValue;//EDGE-165572 Assign Selected simType
                                                                    num.SimAvailabilityType__c = newWxistingSIM;
                                                                    //EDGE-152029. Kalashree Borgaonkar. Adding check for transition number status
                                                                    if(TYPE_TRANSITION.equalsIgnoreCase(num.type__c)){
                                                                        num.status__c = 'IN TRANSITION';
                                                                    }
                                                                    // EDGE-221909 changes start here 
                                                                    if(num.Number_Group__c == null && listNumberGrp.size() > 0){
                                                                        
                                                                        num.Number_Group__c = listNumberGrp.get(0).id; 
                                                                    }
                                                                    // EDGE-221909 changes ends here
                                                                    lstUpdateNumbersNCS.add(num);
                                                                }  
                                                            }   
                                                            if(!lstSelectedNumbers.isEmpty()){
                                                                update lstSelectedNumbers;
                                                                // change for 1325 by shashank -- starts here 
                                                                if(!setNumberGrp.isEmpty()){
                                                                    List<number_group__c> listNumberGrpUpdate = new List<number_group__c>(setNumberGrp); 
                                                                    update listNumberGrpUpdate;
                                                                }
                                                                // change for 1325 by shashank -- ends here 
                                                            }
                                                            //EDGE-166363. Kalashree. Fix to avoid duplicate entries in NCS. 
                                                            if(!lstUpdateNumbersNCS.isEmpty()){
                                                                NumberReservationFixedHandler.saveReserveNCS(lstUpdateNumbersNCS); //EDGE-108230 Create NCS for nguc
                                                            }    
                                                            result='Success';
                                                        }                     
                                                    }
                                                }
                                                catch(Exception ex){
                                                    system.debug('exception==>'+ ex.getLineNumber()+' '+ ex.getMessage()+' '+ex.getStackTraceString());
                                                }
                                                return result;
                                            }
    /******************************************************************
EDGE        -140792,93081,EDGE-140792,EDGE-138086
Method      -unreserveMobileNumbers 
Description -To unreserve MSISDN numbers
Author      -Kalashree Borgaonkar
******************************************************************/
    public static NumberReservationFixedHandler.ResponseWrapper unreserveMobileNumbers(List<string> numberList,String basketId){    
        NumberReservationFixedHandler.ResponseWrapper wrapper = new NumberReservationFixedHandler.ResponseWrapper();
        List<Number__C> portinNumberList= new  List<Number__C>();
        List<Number__C> newNumberList= new  List<Number__C>();
        List<String> unreserveNumList= new  List<String>();
        try{
            if(!numberList.isEmpty()){            
                for(Number__c num: [select id, Type__c, Service_Number__c , Basket__c from Number__c 
                                    where (Service_Number__c IN :numberList OR Id IN :numberList) AND Basket__c=:basketId]){
                                        if(num.Type__c==TYPE_NEW){
                                            newNumberList.add(num);
                                        }
                                        else if(num.Type__c==TYPE_PORT){
                                            portinNumberList.add(num);
                                        }
                                    }
            }
            //EDGE-129218 : LRM [UNMS] to bulk Unreserve/Rollback mobile numbers/MSISDN API enhancement
            if(!newNumberList.isEmpty())
            {  
                wrapper = unreserveNewMobileNumbers(newNumberList,wrapper,basketid);
            }   
            if(!portinNumberList.isEmpty())
            {
                //Delete the unreserved numbers from reservation pool
                delete portinNumberList;
                wrapper.successMsg = 'Numbers successufully removed';
                wrapper.status = true;
            } 
        }
        catch(Exception ex){
            system.debug('exception==>'+ ex.getLineNumber()+' '+ ex.getMessage());
        }  
        return wrapper;
    }  
    /******************************************************************
EDGE        -140792,93081,EDGE-140792,EDGE-138086
Method      -unreserveNewMobileNumbers 
Description -To unreserve MSISDN numbers via API callout (Reducing cyclomatic complexity)
Author      -Kalashree Borgaonkar
******************************************************************/
    public static NumberReservationFixedHandler.ResponseWrapper unreserveNewMobileNumbers(List<Number__c> newNumberList,NumberReservationFixedHandler.ResponseWrapper wrapper,String basketid){ 
        List<String> unreserveNumList= new  List<String>();
        if(newNumberList.size() > 0 || newNumberList.size()<1000){  
            for(Number__c fnn : newNumberList){
                unreserveNumList.add(fnn.Service_Number__c);
            }
            //EDGE-129218
            wrapper= NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(unreserveNumList,basketId,'Rollback', '');//EDGE-92021
        }
        if(wrapper.resIds!=null){
            delete  newNumberList;  
            wrapper.successMsg = 'Numbers successufully removed';       
        }
        return wrapper;
    }
    /******************************************************************
EDGE        -140792,93081,EDGE-140792,EDGE-138086
Method      -unreserveFixedNumbers 
Description -To unreserve MSISDN numbers
Author      -Kalashree Borgaonkar
******************************************************************/
    @AuraEnabled
    public static NumberReservationFixedHandler.ResponseWrapper unreserveFixedNumbers(List<String> selectedNumbers,String basketId){
        NumberReservationFixedHandler.ResponseWrapper resWrap= new NumberReservationFixedHandler.ResponseWrapper();
        if(!selectedNumbers.isEmpty()){
            resWrap=NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(selectedNumbers,basketId,'Rollback', '');//EDGE-92021
        }
        if(resWrap.stRange!=null || resWrap.resIds!=null){
            deleteFromPoolFixed(resWrap.resIds,basketid,resWrap.stRange);
        }
        return resWrap;   
    }
    /*************************************************************************************************
EDGE        -140792,100660,EDGE-140792,EDGE-138086
Method      -unreserveFixedNumbers 
Description -To unreserve MSISDN numbers
Author      -Kalashree Borgaonkar, Ila
***************************************************************************************************/
    @AuraEnabled
    public static void deleteFromPoolFixed(List<String> msisdnLstToDelete,String basketid, List<String> startRange ){
        NumberNCSHelper ncs= new NumberNCSHelper();
        List<Number__c> numList = new List<Number__c>();
        Map<Id,List<String>> ncsMapToDel = new Map<Id,List<String>>();
        //EDGE-124988 fix
        String msisdn = 'AND Service_Number__c IN :msisdnLstToDelete' ;
        String range =' AND Start_Range__c IN :startRange ' ;
        String rangeMsisdn = 'AND (Service_Number__c IN :msisdnLstToDelete OR Start_Range__c IN :startRange) ' ;
        String query = 'SELECT ID,Service_Number__c,Product_Configuration__c,Start_Range__c FROM Number__c WHERE Basket__c =\'' +String.escapeSingleQuotes(basketid) +'\' ';
        if (msisdnLstToDelete!=null && startRange==null)        {
            query+= msisdn;
        }
        else if (startRange!=null && msisdnLstToDelete==null)               {
            query+= range;  
        }
        else{
            query+=rangeMsisdn;
        }
        
        numList=Database.query(query);
        
        if(!numList.isEmpty()){
            try{
                for(Number__c num: numList){ 
                    if(ncsMapToDel.containsKey(num.Product_Configuration__c))
                        ncsMapToDel.get(num.Product_Configuration__c).add(num.Service_Number__c);
                    else
                        ncsMapToDel.put(num.Product_Configuration__c,new List<String>{num.Service_Number__c});
                }
                ncs.deleteExistingNCSMultiplePC(ncsMapToDel);
                if(!numList.isEmpty()){
                    delete numList; 
                }
            }
            catch(DmlException de){
                System.debug('DmlException:'+de.getStackTraceString());
            }
        }
    }    
    /*************************************************************************************************
EDGE        -140792,100660,EDGE-140792,EDGE-138086
Method      -unreserveFixedNumbers 
Description -To unreserve MSISDN numbers
Author      -Kalashree Borgaonkar, Mahima
***************************************************************************************************/
    @AuraEnabled
    public Static String removeAssignedNumbers( List<String> selectedPCList, string basketID, String selectedTab)
    {
        String result='Error';
        List<Number__C > lstNumberPC;
        try{
            lstNumberPC= [select Id, Product_Configuration__c,SIM_Type__c,SimAvailabilityType__c,Sim_Serial_Number__c  from Number__c where 
                          Product_Configuration__c in: selectedPCList and Basket__c=: basketID];
            
            // Added By vijay DIGI-456 || start
            List<cscfga__Attribute__c> attrList = [SELECT name,cscfga__Value__c,cscfga__Display_Value__c, cscfga__Product_Configuration__c 
            FROM cscfga__Attribute__c WHERE  name = 'SimAvailabilityType' AND cscfga__Product_Configuration__c IN: selectedPCList];
            List<cscfga__Attribute__c>simAttrUpdate=new List<cscfga__Attribute__c>();
            for(cscfga__Attribute__c planName:attrList){
                if(planName.name=='SimAvailabilityType'){
                    planName.cscfga__Value__c='';
                    planName.cscfga__Display_Value__c='';
                    simAttrUpdate.add(planName);
                }
            }
            if(!simAttrUpdate.isEmpty()){
                update simAttrUpdate;
            }
            // Added By vijay DIGI-456 || end
            
            if(!lstNumberPC.isEmpty()){
                for(Number__C num : lstNumberPC){
                    num.Product_Configuration__c= null;
                    //EDGE-173151 if number is unassigned then removed the SIM Type and SIM Option
                    //EDGE-224706
                    if(  num.SimAvailabilityType__c=='Existing Blank SIM' || num.SimAvailabilityType__c=='Blank SIM'){
                        num.Sim_Serial_Number__c='';//EDGE-172362. Kalashree Borgaonkar. 
                    }
                    num.SimAvailabilityType__c= '';
                }
                update lstNumberPC;
                result='Success';
            }
            
        }
        catch(exception ex){
            system.debug('EXception in unAssignPCNumber==>'+ex.getStackTraceString());
        }
        return result;
    }
    //EDGE-140792,EDGE-138086
    public static List<EachRecord> getAllreserveNumbers(String basketId, String numberType){
        List<Number__c> lstereservenumber = new List<Number__c>();
        List<EachRecord> lstrec = new List<EachRecord>();
        Map<String,string> startRange = new Map<String,string>();
        List<String> servList = new List<String>();
        List<cscfga__Product_Configuration__c> pconfigList = [SELECT Name,Id,Type__c,csordtelcoa__Replaced_Service__r.csordtelcoa__Service_Number__c,
                                                              cscfga__Product_Definition__r.product_Specification__c
                                                              FROM cscfga__Product_Configuration__c 
                                                              WHERE cscfga__Product_Basket__c = :basketId 
                                                              AND type__c = 'Modify'  
                                                              AND ((cscfga__Product_Definition__r.product_Specification__c IN :PROD_SPEC_VALUES)
                                                                   OR (cscfga__Product_Definition__r.product_Specification__c IN :NGUC_PROD_SPEC_VALUES))];
        for(cscfga__Product_Configuration__c pc : pconfigList ){
            servList.add(pc.csordtelcoa__Replaced_Service__r.csordtelcoa__Service_Number__c);
        }
        if(!pconfigList.isEmpty()){
            List<Number__C> lstNumModify=[SELECT Id, Name,SIM_Type__c,Service_Number__c,Product_Configuration__c,Product_Configuration__r.Name,
                                          Basket__c,Type__c,Status__c,Product_Configuration__r.cscfga__Serial_Number__c,Error_in_assigning_plan__c,
                                          Product_Configuration__r.OfferName__c, Start_Range__c, End_Range__c,Plan_Type__c
                                          FROM Number__c 
                                          WHERE Type__c=: numberType AND Service_Id__c IN :servList];
            List<EachRecord> numberRecordModifyList = getDetailsList(lstNumModify);
            lstrec.addAll(numberRecordModifyList);
        } 
        List<Number__c> numberList = [SELECT Id, Name,SIM_Type__c,Service_Number__c,Product_Configuration__c,Product_Configuration__r.Name,
                                      Basket__c,Type__c,Status__c,Product_Configuration__r.cscfga__Serial_Number__c,Error_in_assigning_plan__c,
                                      Product_Configuration__r.OfferName__c, Start_Range__c, End_Range__c,Plan_Type__c
                                      FROM Number__c 
                                      WHERE Basket__c =:basketId AND Type__c=: numberType ];
        List<EachRecord> numberRecordList = getDetailsList(numberList);
        lstrec.addAll(numberRecordList);
        return lstrec;
    }
    public static List<EachRecord> getDetailsList(List<Number__c> numberList){
        List<EachRecord> numberRecordList = new List<EachRecord>();
        Map<String,string> startRange = new Map<String,string>();
        List<String> servList = new List<String>();
        for(Number__c numrec: numberList){
            EachRecord rec = new EachRecord();
            rec.totalrecord = numberList.size();
            if(numrec.Start_Range__c==null && numrec.End_range__c==null){
                rec.availablenumber = numrec.Service_Number__c;
                rec = getDetails(rec,numrec);
                numberRecordList.add(rec); 
            }
            else{
                if(!startRange.containsKey(numrec.Start_Range__c)){
                    //Added for reserve count
                    rec.totalrecord = numberList.size();
                    startRange.put(numrec.Start_Range__c,numrec.End_range__c);
                    rec.availablenumber = numrec.Start_Range__c +' - '+numrec.End_Range__c;
                    rec = getDetails(rec,numrec);
                    numberRecordList.add(rec);  
                }
            }
        }
        // System.debug('numberRecordList: '+numberRecordList[0].totalrecord);
        return numberRecordList;
    }
    public static EachRecord getDetails(EachRecord rec,Number__c numrec){
        rec.type = numrec.Type__c;                                    
        rec.status = numrec.Product_Configuration__c != null ? 'Assigned': 'Un-Assigned';
        if(numrec.Error_in_assigning_plan__c){
            rec.status = 'Error';
        }
        rec.addcss =rec.status=='Assigned'?'columncss':rec.status=='Error'?'columncsserr':'';
        rec.recordId = numrec.Id;
        rec.Id = numrec.Id;
        rec.planType = numrec.Plan_Type__c; //EDGE-168704: Added New Column
        rec.simType = numrec.SIM_Type__c;
        if(numrec.Product_Configuration__c != null){
            rec.assignedto = numrec.Product_Configuration__r.OfferName__c
                +' | '+ numrec.Product_Configuration__r.Name
                +' | '+numrec.Product_Configuration__r.cscfga__Serial_Number__c;
        }
        return rec;
    }
    //EDGE-140792,EDGE-138086
    public class EachRecord{
        @AuraEnabled public String availablenumber;
        @AuraEnabled public String type;
        @AuraEnabled public String planType; //EDGE-168704: Added New Column
        @AuraEnabled public String status; 
        @AuraEnabled public String assignedto; 
        @AuraEnabled public String recordId;
        @AuraEnabled public String addcss;
        @AuraEnabled public Integer totalrecord;
        @AuraEnabled public String simType;
        @AuraEnabled public String Id;
        public EachRecord(){
            this.availablenumber = '';
            this.type = '';
            this.status = '';
            this.assignedto = '';
            this.recordId = '';
            this.addcss = '';
            this.totalrecord = 0;
            this.simType = '';
            this.Id = '';
        }
    }
    //EDGE-140792,EDGE-138086 
    
    /*************************************************************************************************
EDGE        -140792,59982
Method      -getNGUCProdConfig 
Description -To unreserve MSISDN numbers
Author      -Kalashree Borgaonkar, Aishwarya
***************************************************************************************************/
    public static List<prodConfigWrapper> getNGUCProdConfig(Id basketId,String selTabId) {
        List<prodConfigWrapper> wrapperList=new List<prodConfigWrapper>();
        List<String> prodDefName=new List<String>();
        prodConfigWrapper wrapper=null; 
        
        List< cscfga__Product_Configuration__c > productsAlreadyInTheBasket = new List < cscfga__Product_Configuration__c > ();
        //EDGE-130353 : Removed Replaced Product Config filter from Query.
        productsAlreadyInTheBasket = [SELECT id,Name,cscfga__Serial_Number__c,cscfga__Product_Basket__r.name,
                                      cscfga__Product_Basket__r.csbb__Account__r.Name,
                                      cssdm__solution_association__r.Name
                                      FROM cscfga__Product_Configuration__c
                                      WHERE cscfga__Product_Basket__c =: basketid 
                                      AND cscfga__Product_Definition__r.product_Specification__c =:Label.NextGenerationVoice
                                     ];
        //EDGE-208737 Starts
        List<Id> pcIdList= new List<Id>();
        for(cscfga__Product_Configuration__c pcDetails :productsAlreadyInTheBasket )
        {
            Id pcId ;
            pcId=pcDetails.id;
            pcIdList.add(pcId);
        }
        List<csord__Subscription__c> pcSubscriptions = new List<csord__Subscription__c>();
        pcSubscriptions = [SELECT  csordtelcoa__Product_Configuration__c,customerFacingServiceId__c
                           from csord__Subscription__c
                           where csordtelcoa__Product_Configuration__c IN : pcIdList];
        Map<Id,String> cfsMap= new Map<Id,String>();
        for(csord__Subscription__c cfsdetail :pcSubscriptions)
        {
            cfsMap.put(cfsdetail.csordtelcoa__Product_Configuration__c,cfsdetail.customerFacingServiceId__c);
        }               
        //EDGE-208737 Ends
        for(cscfga__Product_Configuration__c detail: productsAlreadyInTheBasket){
            //added cfsid code edge -208737
            String cfsId = null;
            if(cfsMap.containsKey(detail.id))
            {
                cfsid=cfsMap.get(detail.id);
            }
            //cfsid added as part of edge-208737
            wrapper = new prodConfigWrapper(detail.Name,true,detail.id,null,detail.Name,detail.cssdm__solution_association__r.Name,null,
                                            detail.cscfga__Product_Basket__r.name, detail.cscfga__Product_Basket__r.csbb__Account__r.Name,
                                            detail.cssdm__solution_association__r.Name,
                                            detail.cscfga__Serial_Number__c,null,null,null,false,null,detail.id,null,cfsid);//EDGE-173151 Corrected method parameter 
            wrapperList.add(wrapper);
        }   
        //EDGE-208737 Ends
        return wrapperList;
    }
    /*************************************************************************************************
EDGE        -140792,59982
Method      -finishReservationMobile 
Description -validation on finish and enriched button
Author      -Kalashree Borgaonkar, Aishwarya
***************************************************************************************************/
    public Static ValidationWrapper finishReservationMobile( string basketID){
        ValidationWrapper validWrapper= new ValidationWrapper(); 
        validWrapper.IsValid=true;
        validWrapper.ErrorMessage='';
        List<Number__c> numberList=new List<Number__c>();
        //DIGI-782
        List<Customer_Authority_Form__c> cafList = new List<Customer_Authority_Form__c>();
        List<cscfga__Product_Basket__c> bList = new List<cscfga__Product_Basket__c>();

        //To check if all the PC are assigned with Numbers.
        List<cscfga__Product_Configuration__c> pcList = [SELECT id,csordtelcoa__Replaced_Product_Configuration__c ,subtype__c,
                                                         (SELECT id,isSimvalid__c, Sim_Serial_Number__c,SimAvailabilityType__c,Service_Id__c,Service_Number__c FROM  Numbers__r) 
                                                         FROM cscfga__Product_Configuration__c
                                                         WHERE cscfga__Product_Basket__c = :basketID and 
                                                         cscfga__Product_Definition__r.product_Specification__c in :PROD_SPEC_VALUES
                                                         AND csordtelcoa__Replaced_Product_Configuration__c = null]; // EDGE-127105
        //EDGE-113145,EDGE-123476 Kalashree, start
        for(cscfga__Product_Configuration__c pc: pcList){  
            if(pc.Numbers__r!= null &&  !pc.Numbers__r.isEmpty()){
                numberList.addAll(pc.Numbers__r);    
            }
        }
        
        for(cscfga__Product_Configuration__c pc: pcList){  
            if(pc.Numbers__r== null || pc.Numbers__r.isEmpty())
            {            
                validWrapper= new ValidationWrapper();
                validWrapper.IsValid = false;
                validWrapper.ErrorMessage=(pc.subtype__c==Label.Reactivate_subScenario)?Label.ReactivateServiceSimdetailsMissing: System.Label.NumberReservation_EachPCMustbeAssignedWithNumber;    
                break;
            }
            
        }

        //DIGI-782--START
        bList = [Select Id,csbb__Account__c, cscfga__Opportunity__c, cscfga__Opportunity__r.OwnerId,csbb__Account__r.OwnerId from cscfga__Product_Basket__c where id =: basketID WITH SECURITY_ENFORCED LIMIT 1];
        String oppId  = bList[0].cscfga__Opportunity__c;
        cafList = [Select Id, Contact__c, Is_active__c,Opportunity__c ,PPV_status__c from Customer_Authority_Form__c where (Opportunity__c =: oppId) AND (Is_active__c = True) WITH SECURITY_ENFORCED LIMIT 1];
        

        if(cafList.size()>0){
    
            if(cafList[0].PPV_status__c != 'PPV Completed'){
                
                validWrapper= new ValidationWrapper();
                validWrapper.IsValid= false;
                validWrapper.ErrorMessage=Label.CAFEnrichFailure;
            }
        } 
        //DIGI-782--END  


        //EDGE-113145, Kalashree, end
        //To check if all the Port in numbers are assigned with PC or not.
        List<Number__C> lstNum=[select Id, Type__c, Service_Number__c,Product_Configuration__c, 
                                Product_Configuration__r.Name,Basket__c from Number__C 
                                where Basket__c=: basketID and Type__c =: TYPE_PORT];
        validWrapper = portinValidation(lstNum,validWrapper);
        //EDGE-170884. validating SIM serial numbers
        ValidationWrapper validWrappers = checkValidSIM(numberList);
        if(validWrappers!=null && validWrappers.IsValid==true){
            validWrapper.IsValidForPopup = false;
            validWrapper.isPortInValid = isPortInValid(basketID);
            if(validWrapper.IsValid){
                validWrapper.SuccessMessage = System.Label.Number_Assignment_Success;
            }
        }
        else{
            validWrapper.IsValid = false;
            validWrapper.ErrorMessage=validWrappers.ErrorMessage;    
        }
        System.debug('validWrapper**finish***button***'+validWrapper);
        return validWrapper; 
    }
    /*************************************************************************************************
EDGE        -140792,59982
Method      -portinValidation 
Description -check if portin numbers are assigned. (Reducing cyclomatic complexity)
Author      -Kalashree Borgaonkar, Aishwarya
***************************************************************************************************/
    public static ValidationWrapper portinValidation (List<Number__c> lstNum,ValidationWrapper validWrapper){
        for( Number__c num: lstNum)
        {
            if(num.Product_Configuration__c== null)
            {
                validWrapper= new ValidationWrapper();
                validWrapper.IsValid= false;
                validWrapper.ErrorMessage=System.Label.NumberReservation_AllPortInNumbersMustbeAssigned;
                break;
            }
        }
        return  validWrapper;
    }
    /*************************************************************************************************
EDGE        -140792,59982
Method      -newNmberValdiation 
Description -check if PCs are assigned with a number (Reducing cyclomatic complexity)
Author      -Kalashree Borgaonkar, Aishwarya
***************************************************************************************************/
    public static ValidationWrapper newNmberValdiation ( List<cscfga__Product_Configuration__c> pcList ,ValidationWrapper validWrapper){
        for(cscfga__Product_Configuration__c pc: pcList){  
            if(pc.Numbers__r== null || pc.Numbers__r.isEmpty())
            {            
                validWrapper= new ValidationWrapper();
                validWrapper.IsValid = false;
                validWrapper.ErrorMessage=(pc.subtype__c==Label.Reactivate_subScenario)?Label.ReactivateServiceSimdetailsMissing: System.Label.NumberReservation_EachPCMustbeAssignedWithNumber;    
                break;
            }
            
        }
        return validWrapper;
    }
    /*************************************************************************************************
Name : checkValidSIM
Description : Method for validating SIM serial numbers on finish and enrich button
Author: Kalashree Borgaonkar
Story: EDGE-170884

***************************************************************************************************/
    public Static ValidationWrapper checkValidSIM(List<Number__c> lstNum) {
        ValidationWrapper validWrapper = new ValidationWrapper();
        validWrapper.IsValid= true; 
        for( Number__c num: lstNum){
            if(num.SimAvailabilityType__c!=null && ('Existing Blank SIM'.equalsIgnoreCase(num.SimAvailabilityType__c) || 'Blank SIM'.equalsIgnoreCase(num.SimAvailabilityType__c) )//EDGE-224706
               && ( num.Sim_Serial_Number__c==null || num.Sim_Serial_Number__c=='' 
                   || num.Sim_Serial_Number__c.length()!=13 || num.isSimvalid__c==false || !num.Sim_Serial_Number__c.isNumeric())){
                       validWrapper.IsValid= false;
                       validWrapper.ErrorMessage=System.Label.SIMserialinvalidMsg;
                       break;
                   }
        }
        return validWrapper;        
    }
    
    /*************************************************************************************************
Name : finishReservationFixed
Description : Method for validating Numbers reserved in NgUC
Author: Kalashree Borgaonkar
Story: EDGE-128633
Modify By-Dheeraj Bhatt-EDGE-126433-Enable validation at NGUC product configuration level to have at 
least one number assigned before basket is enriched
***************************************************************************************************/
    public Static ValidationWrapper finishReservationFixed(String basketID){
        List<id> prodConfigIdSet = new List<id>();
        Set<String> scenarioTypeSet = new Set<String>();
        ValidationWrapper validWrapper = new ValidationWrapper();         
        for(cscfga__Product_Configuration__c pc:[SELECT id,Name,cscfga__Serial_Number__c,cscfga__Product_Basket__r.name,ScenarioType__c 
                                                 FROM cscfga__Product_Configuration__c
                                                 WHERE cscfga__Product_Basket__c =: basketID 
                                                 AND cscfga__Product_Definition__r.product_Specification__c =:Label.NextGenerationVoice
                                                 AND csordtelcoa__Replaced_Product_Configuration__c = null]){
                                                     prodConfigIdSet.add(pc.id);
                                                     scenarioTypeSet.add(pc.ScenarioType__c);
                                                 }
        List<AggregateResult> result=[select count(service_number__c),Product_Configuration__c 
                                      FROM Number__c GROUP BY Product_Configuration__c  
                                      Having Product_Configuration__c IN :prodConfigIdSet];
    // EDGE-220794 @VM 11 JUNE
    if( scenarioTypeSet.contains('Transition')){
        if(result.size()==prodConfigIdSet.size()){
            validWrapper.IsValid = true;
        }
        else{
            validWrapper.IsValid= false;
            validWrapper.ErrorMessage=Label.FixedNumberValidation;
            }
        }else{
            validWrapper.IsValid= true;
        }
        // EDGE-220794 @VM 11 JUNE : END
      
        validWrapper.IsValidForPopup = isPopupValidation(basketID);
        validWrapper.isPortInValid = false;
        if(validWrapper.IsValid){
            validWrapper.SuccessMessage = System.Label.Number_Assignment_Success;
        }
        return validWrapper;
    }
    /*************************************************************************************************
EDGE        -140792,100662
Method      -isPopupValidation 
Description -Show pop up if any unassigned numbers 
Author      -Kalashree Borgaonkar, Jannath
***************************************************************************************************/  
    @AuraEnabled
    public static boolean isPopupValidation(string basketId){
        boolean status=false;
        List<Number__c> numlist=[select Id, Type__c,Status__c, Mobile__c,Service_Number__c,
                                 Product_Configuration__c, Product_Configuration__r.Name,Basket__c 
                                 from Number__c where Basket__c=: basketId and Product_Configuration__c = NULL and Type__c ='FNN'];
        if(numlist.size() > 0){
            status=true;
        }
        return status;
    } 
    /******************************************************************
EDGE:59982
Method: unReserveFNN
Description: Unreserve Fixed numbers for nguc
Author:Aishwarya
******************************************************************/
    @AuraEnabled
    public static NumberReservationFixedHandler.ResponseWrapper unReserveFNN(List<String> selectedNumbers,String basketId, String resourceState){
        //Unreserve the numbers for nextgenvoice products
        Boolean Status=false;
        // List<Number__c> fnnListToUnReserve=new List<Number__c>();
        NumberReservationFixedHandler.ResponseWrapper resWrap= new NumberReservationFixedHandler.ResponseWrapper();
        if(!selectedNumbers.isEmpty()){
            resWrap=NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(selectedNumbers,basketId,resourceState, '');//EDGE-92021
        }
        if(resWrap.stRange!=null || resWrap.resIds!=null){
            Status=true;
            //call the method to delete from reservation Pool
            if(!Test.isRunningTest()){
                deleteFromPoolFixed(resWrap.resIds,basketid,resWrap.stRange);
            }
        }else {
            Status=false;
        }
        return resWrap;   
    }
    /******************************************************************
EDGE -89299 , AC6
Method: isPortInValid
Description: Finish button validation to check if CA form is going to expire in 10 days
Author:Aishwarya
******************************************************************/
    @AuraEnabled
    public static Boolean isPortInValid(String basketid){
        Boolean isFinished=PortInController.isPortInValid(basketid);
        return isFinished;
    } 
    public class RadioOptionsWrapper{
        @AuraEnabled
        public Boolean showPortOutReversal = false;
        @AuraEnabled
        public Boolean showReactiveServices =  false;
    }
    
    /*************************************************************************************************
EDGE        -EDGE-185029
Method      -getRadioOptions 
Description -check for displaying radio buttons 
Author      -Kalashree Borgaonkar
***************************************************************************************************/
    @AuraEnabled
    public static RadioOptionsWrapper getRadioOptions(String basketID){
        RadioOptionsWrapper radioOptions = new RadioOptionsWrapper();
        List<cscfga__Product_Configuration__c> productConfigList =[SELECT id, csordtelcoa__Replaced_Product_Configuration__c ,subType__c,
                                                                   (SELECT id,Name,cscfga__Value__c FROM cscfga__Attributes__r 
                                                                    WHERE name = 'isPortOutReversal')
                                                                   FROM cscfga__Product_Configuration__c
                                                                   WHERE cscfga__Product_Basket__c =: basketID 
                                                                   AND cscfga__Product_Definition__r.product_Specification__c IN :PROD_SPEC_VALUES];
        if(!productConfigList.isEmpty()){
            for(cscfga__Product_Configuration__c pc : productConfigList){
                if(!pc.cscfga__Attributes__r.isEmpty()){
                    if(pc.cscfga__Attributes__r[0].cscfga__Value__c=='Yes'){
                        radioOptions.showPortOutReversal = true;
                        
                        break;
                    }
                }  
            }   
            for(cscfga__Product_Configuration__c pc : productConfigList){
                if(pc.csordtelcoa__Replaced_Product_Configuration__c==null && pc.subType__c==Label.Reactivate_subScenario){
                    radioOptions.showReactiveServices=true;
                    
                    break;
                }
            }  
        }   
        
        
        return   radioOptions;
    }
    /*************************************************************************************************
Name : validatSimSerialCallout 
Description : Method for making callout to ValidateSIM interface
Author: Kalashree Borgaonkar
Story: EDGE-170884

***************************************************************************************************/
    public static List<prodConfigWrapper> validatSimSerialCallout(List<SimSerialDetails> simDetailsList,String prodConfigList,String basketid){
        List<prodConfigWrapper> productConfigList =   (List<prodConfigWrapper>)System.JSON.deserialize(prodConfigList, List<prodConfigWrapper>.Class);
        Map<String,String> simSerialNumbersMap=new Map<String,String>();
        Map<String,Map<String,String>> resMap;
        Map<String,String> simToStatusMap=new Map<String,String>(); 
        List<String> names=new List<String>{'SIM Type','SIM Category','Order ID'};
            for(SimSerialDetails simdetail:simDetailsList){
                simSerialNumbersMap.put(simdetail.simNumber,simdetail.simType);
            }
        resMap = ValidateSIMInterface.ValidateSimSerial(simSerialNumbersMap,false,false,names);
        for(String lrmstatus : resMap.keyset()){
            for(String lrm : resMap.get(lrmstatus).keyset()){ 
                simToStatusMap.put(lrm,resMap.get(lrmstatus).get(lrm));
            }
        }
        saveSimValidationDetails(simToStatusMap,basketid);
        Boolean isShowOnhover=false;
        String iconName;
        for(prodConfigWrapper pcWrapper : productConfigList){
            if(pcWrapper.simSerialNumber!=null && simToStatusMap.get(pcWrapper.simSerialNumber)!=null){         
                String message = simToStatusMap.get(pcWrapper.simSerialNumber);
                if(message!='AVAILABLE'){
                    isShowOnhover = true;
                    iconName = 'utility:warning';
                }
                else{
                    isShowOnhover = false;
                    iconName = 'action:approval';
                }
                SimValidateDetails simValid = new SimValidateDetails(iconName,isShowOnhover,message);
                System.debug('simValid: '+simValid);
                pcWrapper.simValidationDetails = simValid;
            }
        }
        return productConfigList;
    }
    /*************************************************************************************************
Name : saveSimValidationDetails
Description : Method for saving isSimValid details.
Author: Kalashree Borgaonkar
Story: EDGE-170884

***************************************************************************************************/
    public static String saveSimValidationDetails( Map<String,String> simToStatusMap,String basketID){
        String result='Success';
        try{
            if(simToStatusMap!=null){
                List<Number__c> numberList = [SELECT isSimValid__c,Sim_Serial_Number__c FROM Number__c WHERE Sim_Serial_Number__c = :simToStatusMap.keyset() AND Basket__c = :basketID]; 
                for(Number__c numRecord : numberList){
                    String simStatus =  simToStatusMap.get(numRecord.Sim_Serial_Number__c);
                    numRecord.isSimValid__c = (simStatus=='AVAILABLE')?true:false;
                }
                if(!numberList.isEmpty()){
                    update numberList;
                }
            }   
        }
        catch(Exception e){
            result='Failure';
        } 
        return result; 
    }
    /*************************************************************************************************
Name : mapNumTypeToPCSubtype
Description :Mapping Numner type to PC subtype for CMP and AM
Author: Aishwarya
Story: EDGE-179277

***************************************************************************************************/
    /* public static void mapNumTypeToPCSubtype(Map<id,string> mapNumTypeToPC){
//EDGE-179277:Mapping Numner type to PC subtype for CMP and AM
try{
List<cscfga__Product_Configuration__c> lstpcsTobeupdated = new List<cscfga__Product_Configuration__c>();
//Retrieve Parent Pc and Assoiated child PC's
For(cscfga__Product_Configuration__c pc : [SELECT id,subType__c,cscfga__Parent_Configuration__c FROM
cscfga__Product_Configuration__c WHERE (cscfga__Parent_Configuration__c IN : mapNumTypeToPC.keySet() 
OR id IN: mapNumTypeToPC.keySet())]){
//Assign Number type to Parent and all child PC's
pc.subType__c = mapNumTypeToPC.containsKey(pc.cscfga__Parent_Configuration__c)?mapNumTypeToPC.get(pc.cscfga__Parent_Configuration__c):mapNumTypeToPC.get(pc.id);
lstpcsTobeupdated.add(pc);

}
system.debug('lstpcsTobeupdated==>' + lstpcsTobeupdated);
if(!lstpcsTobeupdated.isEmpty()){
update lstpcsTobeupdated;
}     
}
catch(Exception e){

System.debug('Exception in upating PC: '+e.getStackTraceString());
}     
} */ 
    //EDGE-170884
    public class SimSerialDetails{
        String simNumber;
        String simType;
        public SimSerialDetails( String simNumber, String simType){
            this.simNumber = simNumber;
            this.simType = simType;
        } 
    }
    //EDGE-170884
    public class SimValidateDetails{
        @AuraEnabled
        public String iconName;
        @AuraEnabled
        public Boolean showOnHover=false;
        @AuraEnabled
        public String errorMsg; 
        public SimValidateDetails( String iconName, Boolean showOnHover,String errorMsg){
            this.iconName = iconName;
            this.showOnHover = showOnHover;
            this.errorMsg = errorMsg;
        } 
    }
    /*************************************************************************************************
EDGE        -EDGE-185029
Method      -assignSIM 
Description -create number records for reactivation of services
Author      -Kalashree Borgaonkar
***************************************************************************************************/
    public static string assignSIM(String selectedPcWrapper,String basketId, String selectedSimTypeValue,String newWxistingSIM){
        String result = 'Success';
        List<Number__c> createNumberList = new List<Number__c>();
        try{
            if(selectedPcWrapper!=null){
                List<ProdConfigWrapper> productConfigList = (List<ProdConfigWrapper>)System.JSON.deserialize(selectedPcWrapper, List<ProdConfigWrapper>.Class);
                cscfga__Product_Basket__c basket = [SELECT csbb__Account__c FROM cscfga__Product_Basket__c WHERE id = :basketId];
                List<String> customerFacingIdList =new  List<String>();
                Map<String, String> cfsToPcMap= new Map<String,String>();
                for(ProdConfigWrapper pc : productConfigList){
                    customerFacingIdList.add(pc.assignedNumber);
                    cfsToPcMap.put(pc.assignedNumber,pc.id);
                }
                Map<String, Number__c> pcToCfsIdMap= getSIMSerialDetails(  cfsToPcMap, customerFacingIdList );  
                for(ProdConfigWrapper pc : productConfigList){
                    if(pc.assignedNumber!=null){ 
                        Number__c num = new Number__c();
                        if(pc.numberId!=null){
                            num.id=pc.numberId;
                        }
                        num.Service_Number__c = pc.assignedNumber;
                        num.Type__c = 'Reactivate';
                        num.Product_Configuration__c = pc.Id;
                        num.SIM_Type__c = selectedSimTypeValue; 
                        num.SimAvailabilityType__c = newWxistingSIM; 
                        num.Mobile__c = 'Mobile';
                        num.basket__c =basketId; 
                        num.Account__c =basket.csbb__Account__c; 
                        //EDGE-214802
                        if(newWxistingSIM=='Existing Active SIM' || newWxistingSIM=='Existing SIM'){
                            num.Sim_Serial_Number__c =(pcToCfsIdMap.get(pc.Id)!=null)?pcToCfsIdMap.get(pc.Id).Sim_Serial_Number__c:null;
                            num.IMSI__c =(pcToCfsIdMap.get(pc.Id)!=null)?pcToCfsIdMap.get(pc.Id).imsi__c:null; 
                        }  
                        else{
                            num.Sim_Serial_Number__c =null;
                            num.IMSI__c =null; 
                        }
                        createNumberList.add(num);
                    } 
                }
                if(!createNumberList.isEmpty()){
                    upsert createNumberList;
                }
            }   
        }
        catch(Exception e){
            result = e.getMessage();
        }
        return result;
    }
    
    
    //Wrapper to get PC for basket
    public class ProdConfigWrapper{
        @AuraEnabled
        public String productConfig;
        @AuraEnabled
        public boolean isngEMPresent;
        @AuraEnabled
        public Boolean isSelected;
        @AuraEnabled
        public Boolean isDisabled;
        //EDGE-96503-Mahima-start
        @AuraEnabled
        public string assignedNumber;
        @AuraEnabled
        public string configId;
        @AuraEnabled
        public string model;
        @AuraEnabled
        public string color;
        @AuraEnabled
        public string planName;
        @AuraEnabled
        public string basketName;
        @AuraEnabled
        public string accountName;//EDGE-188065
        @AuraEnabled
        public string solution;
        @AuraEnabled
        public string serialNumber;
        @AuraEnabled
        public string quantity;
        @AuraEnabled
        public string simType; // used to capture simType
        @AuraEnabled
        public string newExistingSim; // used to capture new or existing sim data
        @AuraEnabled
        public string simSerialNumber;// used to capture sim Serial number
        @AuraEnabled public String Id;// used for InlineDynamic DataTable 
        @AuraEnabled public String numberId;
        @AuraEnabled public List<cscfga__Product_Configuration__c> serviceAddOnList;//EDGE-203929-used to capture Add on
        
        @AuraEnabled
        public SimValidateDetails simValidationDetails; //EDGE-170884. to show details after SIM validation callout
        //EDGE-96503-Mahima-end
        //Sandip UpdatedSim_Serial_Number__c
        @AuraEnabled
        public string pcSubType ; //EDGE-170884. to show details after SIM validation callout
        @AuraEnabled Public String CustomerFacingServiceId; //EDGE-208737 
        //EDGE-197555 added by ankit
        ProdConfigWrapper(String productConfig,Boolean isSelected,Id configId, string numberAssign, string model, 
                          string plan, string color, string bName,String accountName, string Solution, string SerialNumber, 
                          string Quantity,String simType,String newExistingSim,boolean isngEMPresent,String simSerialNumber,String id,List<cscfga__Product_Configuration__c> serviceAddOnList ){
                              this.productConfig = productConfig;
                              this.isSelected = isSelected;
                              this.isDisabled=isSelected;
                              this.configId=configId;
                              this.assignedNumber=numberAssign;
                              this.planName=plan;
                              this.color=color;
                              this.model=model;
                              this.basketName= bName;
                              this.accountName = accountName;
                              this.solution=solution;
                              this.serialNumber=serialNumber;
                              this.quantity=quantity;
                              this.simType = simType;
                              this.newExistingSim = newExistingSim;
                              this.isngEMPresent = isngEMPresent;
                              this.simSerialNumber = simSerialNumber;
                              this.Id=id;
                              this.serviceAddOnList=serviceAddOnList;//EDGE-203929
                              
                          }
        //EDGE-208737 starts
        ProdConfigWrapper(String productConfig,Boolean isSelected,Id configId, string numberAssign, string model, 
                          string plan, string color, string bName,String accountName, string Solution, string SerialNumber, 
                          string Quantity,String simType,String newExistingSim,boolean isngEMPresent,String simSerialNumber,String id,List<cscfga__Product_Configuration__c> serviceAddOnList , String CustomerFacingServiceId){
                              this.productConfig = productConfig;
                              this.isSelected = isSelected;
                              this.isDisabled=isSelected;
                              this.configId=configId;
                              this.assignedNumber=numberAssign;
                              this.planName=plan;
                              this.color=color;
                              this.model=model;
                              this.basketName= bName;
                              this.accountName = accountName;
                              this.solution=solution;
                              this.serialNumber=serialNumber;
                              this.quantity=quantity;
                              this.simType = simType;
                              this.newExistingSim = newExistingSim;
                              this.isngEMPresent = isngEMPresent;
                              this.simSerialNumber = simSerialNumber;
                              this.Id=id;
                              this.serviceAddOnList=serviceAddOnList;//EDGE-203929
                              this.CustomerFacingServiceId=CustomerFacingServiceId; 
                          }
        //EDGE-208737 End                   
        ProdConfigWrapper(){}
    }
    
    //Finish button validation wrapper
    public class ValidationWrapper{
        @AuraEnabled
        public boolean IsValid{get;set;}
        @AuraEnabled
        public boolean IsValidForPopup{get;set;}
        @AuraEnabled
        public boolean isPortInValid{get;set;}
        @AuraEnabled
        public String ErrorMessage{get;set;}
        @AuraEnabled
        public String SuccessMessage{get;set;}
    }
    public static Map<String,Number__c> getSIMSerialDetails( Map<String, String> cfsToPcMap,List<String> customerFacingIdList ){
        Map<String, Number__c> pcToCfsIdMap= new Map<String,Number__c>();
        List<Number__c> customerFacingidDeatils = [SELECT service_number__c,Sim_Serial_Number__c,imsi__c 
                                                   FROM Number__c 
                                                   WHERE service_number__c IN :customerFacingIdList AND type__c != 'Reactivate'];
        for(Number__c num : customerFacingidDeatils){
            String pcid = cfsToPcMap.get(num.service_number__c);
            if(pcid!=null){
                pcToCfsIdMap.put(pcid, num);
            }  
        }
        return pcToCfsIdMap;
    }
    /*************************************************************************************************
EDGE        -EDGE-185029
Method      -getProdConfig 
Description -get Product configs for Mobility. Refactored method
Author      -Kalashree Borgaonkar
***************************************************************************************************/
    
    
    public static List<prodConfigWrapper> getProdConfig(Id basketId,String selectedRadioOption) {
        //EDGE-96503- Mahima
        List<String> deviceAttrName= new List<String>{'CustomerFacingServiceId'};   
            List<prodConfigWrapper> pcWrapList = new List<prodConfigWrapper>();
        //EDGE-173151 added required fields in SOQL
        List<cscfga__Product_Configuration__c> pcList = [SELECT Name ,Type__c, id,cscfga__Product_Basket__r.Name,cscfga__Product_Basket__r.csbb__Account__r.Name,
                                                         cscfga__Product_Definition__r.Name,cscfga__Product_Definition__r.product_Specification__c, subType__c,csordtelcoa__Replaced_Product_Configuration__c,
                                                         (select id, Service_Number__c,SIM_Type__c,SimAvailabilityType__c,
                                                          Sim_Serial_Number__c,Type__c from  Numbers__r), 
                                                         (select id,Name,cscfga__Value__c from cscfga__Attributes__r 
                                                         where name in: deviceAttrName ),
                                                         (SELECT Name,AddOnName__c FROM cscfga__Related_Configurations__r )
                                                        FROM cscfga__Product_Configuration__c 
                                                        WHERE cscfga__Product_Basket__c = :basketId 
                                                        AND cscfga__Product_Definition__r.product_Specification__c IN :PROD_SPEC_VALUES 
                                                        AND csordtelcoa__Replaced_Product_Configuration__c = null]; // EDGE-127105//EDGE-197555
       system.debug('pcList.size=='+ pcList.size());
       system.debug('pcListsize.=='+ pcList);
        Map<cscfga__Product_Configuration__c, string> mobileDeviceIds= new Map<cscfga__Product_Configuration__c,string>();
        Map<cscfga__Product_Configuration__c, string> deviceIds= new Map<cscfga__Product_Configuration__c,string>();
        Map<String, String> pcToServiceNumberMap= new Map<String,String>();
        boolean isngEMPresent = false;
        for(cscfga__Product_Configuration__c pc: pcList){
            for(cscfga__Attribute__c attr:pc.cscfga__Attributes__r){
                if(attr.Name=='CustomerFacingServiceId'){
                    pcToServiceNumberMap.put(pc.id,attr.cscfga__Value__c);
                }
            }
        }
        for(cscfga__Product_Configuration__c pc: pcList){
            prodConfigWrapper wrap;            
            string model,plan, color;
            plan=pc.Name;
            
            if(pc.cscfga__Product_Definition__r.product_Specification__c.contains('DMCAT_ProductSpecification_001196')){
                isngEMPresent=true;
            }
            else{
                isngEMPresent = false;
            }
            if(selectedRadioOption=='reactiveServices'){
                if(pc.subType__c == Label.Reactivate_subScenario && pc.csordtelcoa__Replaced_Product_Configuration__c==null){
                    String serviceNumber = (!pcToServiceNumberMap.keyset().isempty())?pcToServiceNumberMap.get(pc.id):null;
                    if(!pc.Numbers__r.isEmpty()){
                        //EDGE-188065
                        String SimSerialNumber = pc.Numbers__r[0].Sim_Serial_Number__c;
                        wrap = new prodConfigWrapper(pc.Name,true,pc.id,serviceNumber, model, plan, color,
                                                     pc.cscfga__Product_Basket__r.Name,pc.cscfga__Product_Basket__r.csbb__Account__r.Name,plan,null,null,pc.Numbers__r[0].SIM_Type__c,
                                                     
                                                     pc.Numbers__r[0].SimAvailabilityType__c,isngEMPresent,SimSerialNumber,pc.id,pc.cscfga__Related_Configurations__r); 
                        wrap.numberId=pc.Numbers__r[0].id;
                    }
                    else{
                        
                        wrap = new prodConfigWrapper(pc.Name,true,pc.id,serviceNumber, model, plan, color,
                                                     pc.cscfga__Product_Basket__r.Name,pc.cscfga__Product_Basket__r.csbb__Account__r.Name,plan,null,null,null,
                                                     null,isngEMPresent,null,pc.id,pc.cscfga__Related_Configurations__r); 
                    }
                    pcWrapList.add(wrap);
                }
            }
            else {
                //EDGE-188065
                //EDGE-208742 - added condition in if and else , in order to display the PC list based on assigned numbers for respective selected radio button
                if(pc.Numbers__r!= null && pc.Numbers__r.size()>0 && pc.subType__c != Label.Reactivate_subScenario
                   && selectedRadioOption == pc.Numbers__r[0].Type__c){
                       String SimSerialNumber = '';
                       SimSerialNumber = pc.Numbers__r[0].Sim_Serial_Number__c;
                       wrap = new prodConfigWrapper(pc.Name,true,pc.id,pc.Numbers__r[0].Service_Number__c, model, plan, color,
                                                    pc.cscfga__Product_Basket__r.Name,pc.cscfga__Product_Basket__r.csbb__Account__r.Name,
                                                    plan,null,null,pc.Numbers__r[0].SIM_Type__c,
                                                    pc.Numbers__r[0].SimAvailabilityType__c,isngEMPresent,SimSerialNumber,pc.id,pc.cscfga__Related_Configurations__r);
                   }
                else if((pc.Numbers__r).isEmpty() && pc.subType__c != Label.Reactivate_subScenario){
                    wrap = new prodConfigWrapper(pc.Name,false,pc.id,'Un-Assigned', model, plan, color,pc.cscfga__Product_Basket__r.Name,
                                                 pc.cscfga__Product_Basket__r.csbb__Account__r.Name,plan,null,null,null,null,isngEMPresent,null,pc.id,pc.cscfga__Related_Configurations__r);
                }
                if(wrap != null && pc.Numbers__r!= null && pc.Numbers__r.size()>0){
                    wrap.pcSubType=pc.Numbers__r[0].Type__c;//EDGE-197555 Set Subtype on wrapper
                } 
                pcWrapList.add(wrap);
            }
        }
        return pcWrapList;
        
    }
    public static List<NumberReservationHelper.prodConfigWrapper> validatSimCallout(String validSimList,String prodConfigList,String basketid){  
        
        List<NumberReservationHelper.prodConfigWrapper> productConfigList =   (List<NumberReservationHelper.prodConfigWrapper>)System.JSON.deserialize(validSimList, List<NumberReservationHelper.prodConfigWrapper>.Class);
        List<NumberReservationHelper.SimSerialDetails> simdetailsList = new List<NumberReservationHelper.SimSerialDetails>();
        for(NumberReservationHelper.prodConfigWrapper pc: productConfigList){
            if(pc.newExistingSim=='Existing Blank SIM' || pc.newExistingSim=='Blank SIM'){
                String simType = (pc.simType!=null)?pc.simType:'SIM Card';
                NumberReservationHelper.SimSerialDetails simDetail = new NumberReservationHelper.SimSerialDetails(pc.simSerialNumber,simType);
                simdetailsList.add(simDetail);
            }
        }
        return  NumberReservationHelper.validatSimSerialCallout(simdetailsList,prodConfigList,basketid); 
    }
    //EDGE-185029 Kalashree check for Reactivate service.
    public static Boolean checkReactivateServices(Id basketId) {
        Boolean isReactivateServicePresent = false;
        List<cscfga__Product_Configuration__c> pcList = [SELECT subType__c
                                                         FROM cscfga__Product_Configuration__c 
                                                         WHERE cscfga__Product_Basket__c = :basketId 
                                                         AND cscfga__Product_Definition__r.product_Specification__c IN :PROD_SPEC_VALUES 
                                                         AND csordtelcoa__Replaced_Product_Configuration__c = null];
        for(cscfga__Product_Configuration__c pcs : pcList){
            if(pcs.subtype__c == Label.Reactivate_subScenario){
                isReactivateServicePresent = true;
                break;
            }
        }
        return isReactivateServicePresent;
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
       public static void publishPlatformEvents(Id orderId,String orderNumber,String accountCidn, Decimal FulfilmentOrderVersion){
    Logger2 logger = Logger2.getLogger('HighVolumeEvent');
    Logger2 log = Logger2.getLogger('OrderGenerationMSEvent');
        HighVolumeReadyToSubmitOrder__e highVolEvent = new HighVolumeReadyToSubmitOrder__e ();
        highVolEvent.OrderID__c = orderId;
        highVolEvent.Order_Number__c= orderNumber; 
        highVolEvent.CorrelationID__c = EDISSingleManager.getUID();
        highVolEvent.Fulfilment_Order_Version__c= Integer.valueOf(FulfilmentOrderVersion); // DIGI-18183
        system.debug('payload sending for highvolume >> '+highVolEvent); 
        Database.SaveResult saveRes = EventBus.publish(highVolEvent);
        system.debug('highvolume event publish reslut >> '+saveRes);
    String statusCode = '';
    String errorMssg = '';
    if(!saveRes.isSuccess()){
        for(Database.Error err : saveRes.getErrors()) {
            System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
            statusCode = statusCode + ','  + err.getStatusCode();
            errorMssg = errorMssg + ',' + err.getMessage();
        }
    }
    logger.logMessages(JSON.serialize(highVolEvent), JSON.serialize(saveRes), '', 'Functional', statusCode, errorMssg, false, false,null ,null,null,null);
    logger.exitLogger();
        OrderGenerationMSEvent__e orderGenerationEvent = new OrderGenerationMSEvent__e ();
        orderGenerationEvent.orderId__c = orderId;
        orderGenerationEvent.orderNum__c= orderNumber; 
        orderGenerationEvent.cidn__c = accountCidn;
        system.debug('payload sending for orderGeneration >> '+orderGenerationEvent);
        Database.SaveResult saveResOrderEvent = EventBus.publish(orderGenerationEvent);
        system.debug('orderGeneration event publish result >> '+saveResOrderEvent);
    statusCode = '';
    errorMssg = '';
    if(!(saveResOrderEvent.isSuccess())){
        for(Database.Error err : saveResOrderEvent.getErrors()) {
            System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
            statusCode = statusCode + ','  + err.getStatusCode();
            errorMssg = errorMssg + ',' + err.getMessage();
        }
    }
    
    log.logMessages(JSON.serialize(orderGenerationEvent), JSON.serialize(saveResOrderEvent), '', 'Functional', statusCode, errorMssg, false, false, null,null,null,null);
    log.exitLogger();   
    }  
    //  EDGE-223632 Add or Remove Number order status to be changed to Completed once completion is done from O2A
    private static void updateOrderStatus(Id orderId,String status){
        csord__Order__c order = new csord__Order__c();
        order.Id = orderId;
        order.csord__Status2__c = status;
        update order;
    }

/*************************************************************************************************
Name : validateSimSerNumber
Description : Enhance SIM validation to include Active/Previously used check
Author: Irfan Inamdar
Story: DIGI-21833
***************************************************************************************************/
@AuraEnabled
public Static List<String> validateSimSerNumber(List<String> simSerNumberList){

    List<String> serNumList = new List<String>();
    for(Number__c num : [Select id,Type__c, Sim_Serial_Number__c,Service_Number__c, isSimvalid__c,Basket__c FROM Number__c 
                            WHERE  Sim_Serial_Number__c != Null AND Sim_Serial_Number__c IN:simSerNumberList WITH SECURITY_ENFORCED]){
        serNumList.add(num.Sim_Serial_Number__c);
    }
    if(serNumList.size() > 0){
        return serNumList;
    }else {
        return NULL;
    }
    
    }
}