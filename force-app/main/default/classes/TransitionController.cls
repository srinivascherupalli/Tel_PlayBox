/*----------------------------------------------------------------------------
EDGE         -85161 
Class Name  -TransitionController
Description -Fetching the service number and its status from Product Configuration  TransitionData attachment 
to show on Transition tab.
Author      -Dheeraj Bhatt
Revision    -Sandip Deshmane    -EDGE-148075     -Updated to Add planType Attribute.
Revision    -Rahul  EDGE-150430     - Added change to remove prod config association from number.
Revision    -Vivek/Ankit EDGE-113751 - Bypass service id for hybrid product
Revision    -Nikhil EDGE-198374     - Create Feedback case.
-------------------------------------------------------------------------------*/
public without sharing class TransitionController {
    public static string cASESUBJECT = 'TRAMAS TM2 request failed';
    public static string dIGITIZEDORDERING = 'Digitised Ordering Issue';
    public static string cHECKPOINTTRANSITION ='Checkpoint/ Transition';
    public static string cASEPRIORITY ='High';
    public static string cASESTATUS ='New';
    public static string cASESEVERITY ='Medium'; 
    public static string cASEORIGIN ='Feedback';
    
    private static String correlationId = GuidUtil.NewGuid();
    private static final String CONSTINTERFACENAME = 'TransitionController';
    private static final C2O_ExceptionHandler.Capability CONSTCAPABILITY = C2O_ExceptionHandler.Capability.BSK;
    
public static transitionWrapper getServicedata(transitionWrapper wrapper,
                                TransitionDataDTO.serviceDTOMobile serviceDTO,Attachment attloop){
    if(serviceDTO.Reserve_status!=null){
        wrapper.tramasStatus =serviceDTO.Reserve_status;
        wrapper.tramasReason =serviceDTO.Reason;
    }
    else{
        wrapper = NumberReservationTM2CallOut.setMobileServiceStatusAndReasonTM2(wrapper,serviceDTO.tramasErrorCode,serviceDTO.Reserve_status); 
        if(wrapper.tramasReason==null){
            wrapper.tramasReason =serviceDTO.Reason;
        }
    }
    if(attloop.name==label.MobileTransitionName){
        wrapper.service_type='Mobile';
    }
    else{
        wrapper.service_type='Fixed';
    }
    return wrapper;
}

    /*-----------------------------------------------------------------------------
EDGE        -85161
Method Name -getServiceNumber
Description -Get service numberand reserve status  to show on transition tab. 
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<transitionWrapper> getServiceNumber(String basketId){
        // Fetch custom metadata value ----EDGE-113751  || start
        map<string,boolean>transGroupStructHybrid =new map<string,boolean>();
        for (Transition_Group_Structure_New__mdt transGroupStruct: [SELECT Hybrid__c, Product_Family__c FROM Transition_Group_Structure_New__mdt]) {
            transGroupStructHybrid.put(transGroupStruct.Product_Family__c,transGroupStruct.Hybrid__c);//EDGE-152495
        }
        //EDGE-113751 || end
        List<transitionWrapper> transitionWrapperList=new List<transitionWrapper>(); 
        List<String> serviceidList=new List<String>(); 
        //EDGE-202851 
        //Map<String,NumberReservationTM2CallOut.ErrorWrapper> errorCodetoStausMap= NumberReservationTM2CallOut.getStatusAndReason();
        try{
            set<Id> productConfigId=new set<Id>();
            String accountId='';
            for(cscfga__Product_Configuration__c productConfig:[select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basketId]){
                productConfigId.add(productConfig.id);
                accountId=productConfig.cscfga__Product_Basket__r.csbb__Account__c;
            }
            
            //system.debug('attachementdetails'+attachList);
            //if(attachList.size()>0){
            for(Attachment attloop:[SELECT Name,ParentId,body FROM Attachment WHERE ParentId IN:productConfigId AND (Name = :label.MobileTransitionName OR Name = 'TransitionDataNgUc.json' )]){
                if(attloop.Name == 'TransitionDataNgUc.json' || attloop.name==label.MobileTransitionName){
                    String attachmentbody=attloop.body.toString();
                    //Parsing attachment body jason to TransitionDataDTO class
                    TransitionDataDTO transitionDTO=TransitionDataDTO.parse(attachmentbody);
                    //iterating to get service Id and other fields from TransitionDataDTO class
                    for(TransitionDataDTO.productListDTO productList:transitionDTO.productList){
                        for(TransitionDataDTO.SiteDTOMobile siteDTO:productList.site ){
                            for(TransitionDataDTO.serviceListDTOMobile serviceListDTO:siteDTO.serviceList ){
                                system.debug('serviceListDTO'+serviceListDTO);
                                system.debug('serviceListDTO.checkValue'+serviceListDTO.checkValue);
                                // If(serviceListDTO.checkValue==true /*&& serviceListDTO.checkReserved==false*/){
                                for(TransitionDataDTO.groupDTOMobile groupDTO:serviceListDTO.groupType ){
                                    for(TransitionDataDTO.serviceDTOMobile serviceDTO:groupDTO.service ){
                                        if((groupDTO.transitionId!=null  && groupDTO.checkValue==true)){
                                            
                                            if(/*serviceListDTO.checkReserved==false && */ (( productList.Product_Type != null && transGroupStructHybrid.containsKey(productList.Product_Type) && !transGroupStructHybrid.get(productList.Product_Type)) || !transGroupStructHybrid.containsKey(productList.Product_Type)  ) ){   //EDGE-113751  additional Condition Added by Vivek                         
                                                transitionWrapper wrapper=new transitionWrapper();
                                                wrapper.Service_Id=serviceDTO.Service_Id;
                                                serviceidList.add(wrapper.Service_Id);
                                                System.debug('productList.Product_Type-'+productList.Product_Type);
                                                wrapper.productFamily=productList.Product_Type;
                                                //Addeb below 2 lines for EDGE-198374 to get CIDN and FNNs
                                                wrapper.CIDN_Number = transitionDTO.CIDN;
                                                wrapper.FNN_Number = serviceDTO.Service_Id;
                                                wrapper.ADBOR_Id = siteDTO.ADBOR_Id; //Add by Nikhil EDGE-217339 as part of B2B 1260
                                                //EDGE-202851 Kalashree Borgaonkar. set reason and status - start
                                                /*if(attloop.name==label.MobileTransitionName){
System.debug('serviceDTO.tramasErrorCode: '+serviceDTO.tramasErrorCode);
// EDGE-207443-Dheeraj Bhatt- Warning numbers from TRAMAS Resource API response to be considerer  as as Eligible/Locked
wrapper.tramasStatus =serviceDTO.Reserve_status;
wrapper = NumberReservationTM2CallOut.setMobileServiceStatusAndReasonTM2(wrapper,serviceDTO.tramasErrorCode,serviceDTO.Reserve_status); 
if(wrapper.tramasReason==null){
wrapper.tramasReason =serviceDTO.Reason;
}
}
else{*/
                                            wrapper = getServicedata(wrapper,serviceDTO,attloop);
                                               /* if(serviceDTO.Reserve_status!=null){
                                                    wrapper.tramasStatus =serviceDTO.Reserve_status;
                                                    wrapper.tramasReason =serviceDTO.Reason;
                                                }
                                                else{
                                                    wrapper = NumberReservationTM2CallOut.setMobileServiceStatusAndReasonTM2(wrapper,serviceDTO.tramasErrorCode,serviceDTO.Reserve_status); 
                                                    if(wrapper.tramasReason==null){
                                                        wrapper.tramasReason =serviceDTO.Reason;
                                                    }
                                                }*/
                                                
                                                // }
                                                System.debug('wrapper response@@@: '+wrapper);
                                                //EDGE-202851 Kalashree Borgaonkar. set reason and status - end
                                                //wrapper.tramasReason= errorCodetoStausMap
                                                //      wrapper.Reserve_status=serviceDTO.Reserve_status.toLowerCase();
                                                wrapper.Reason=serviceDTO.Reason;
                                               /* if(attloop.name==label.MobileTransitionName){
                                                    wrapper.service_type='Mobile';
                                                }
                                                else{
                                                    wrapper.service_type='Fixed';
                                                }*/
                                                
                                                //   wrapper.isSelected=false;
                                                wrapper.productConfigId=attloop.ParentId;
                                                wrapper.transitionId=groupDTO.transitionId;
                                                wrapper.basketId=basketId;
                                                wrapper.accountId=accountId;
                                                //EDGE-148075 - Added planType property to show it on UI.
                                                wrapper.planType = serviceDTO.Plan_Type;
                                                wrapper.currentPlan=serviceDTO.Plan_Name; //EDGE-168704 - New Attribute for capturing Current Plan.
                                                //adding loop for IMSI. Note that it is expected that only one device data existi per service here in the response
                                                if(serviceDTO.devices!=null ){
                                                    for(TransitionDataDTO.devicesDTO serviceDevice:serviceDTO.devices ){
                                                        wrapper.physicalId=serviceDevice.physicalId;
                                                        wrapper.networkId=serviceDevice.networkId;
                                                    }
                                                }
                                                transitionWrapperList.add(wrapper);
                                            }
                                            
                                            system.debug('transitionWrapperList111@@@'+ transitionWrapperList);
                                            
                                            //populate serviceextensions data to wrapperlist__EDGE-EDGE-115694 
                                            //Start changes for Edge-104020- to enable service Extenstion numbers
                                            if(serviceDTO.serviceExtensions!=null ){
                                                
                                                for(TransitionDataDTO.serviceExtensionDTO serviceextension:serviceDTO.serviceExtensions){
                                                    System.debug('serviceextension.checkReserved -'+ serviceextension.checkReserved);
                                                    //   if(serviceextension.checkReserved==false){
                                                    transitionWrapper wrapperExt=new transitionWrapper();
                                                    wrapperExt.Service_Id=serviceextension.serviceExtensionFrom+'-'+serviceextension.serviceExtensionTo;
                                                    serviceidList.add(serviceextension.serviceExtensionFrom+' -  '+serviceextension.serviceExtensionTo);
                                                    wrapperExt.fromNumber=serviceextension.serviceExtensionFrom;
                                                    wrapperExt.toNumber=serviceextension.serviceExtensionTo;
                                                    wrapperExt.Reserve_status=serviceextension.Reserve_status!=null?serviceextension.Reserve_status.toLowerCase():null;
                                                    wrapperExt.Reason=serviceextension.Reason;
                                                    //   wrapperExt.isSelected=false;
                                                    wrapperExt.service_type='Fixed';
                                                    wrapperExt.productConfigId=attloop.ParentId;
                                                    wrapperExt.transitionId=groupDTO.transitionId;
                                                    wrapperExt.ADBOR_Id = siteDTO.ADBOR_Id;
                                                    wrapperExt.productFamily =productList.Product_Type; //##
                                                    System.debug('wrapperExt creation ');
                                                    System.debug(' wrapperExt - productList.Product_Type - '+productList.Product_Type);
                                                    //Addeb below 2 lines for EDGE-198374 to get CIDN and FNNs
                                                    wrapperExt.CIDN_Number = transitionDTO.CIDN;
                                                    wrapperExt.FNN_Number = serviceDTO.Service_Id;
                                                    wrapperExt.basketId=basketId;
                                                    wrapperExt.accountId=accountId;
                                                    //EDGE-202851 Kalashree Borgaonkar. set reason and status - start
                                                    /*if(attloop.name==label.MobileTransitionName){
System.debug('serviceDTO.tramasErrorCode: '+serviceDTO.tramasErrorCode);
wrapperExt = NumberReservationTM2CallOut.setMobileServiceStatusAndReasonTM2(wrapperExt,serviceextension.tramasErrorCode,serviceextension.Reserve_status);
}
else{*/
                                                    if(serviceextension.Reserve_status!=null){
                                                        wrapperExt.tramasReason =serviceextension.Reason;
                                                        wrapperExt.tramasStatus = serviceextension.Reserve_status;
                                                    }
                                                    else{
                                                        wrapperExt = NumberReservationTM2CallOut.setMobileServiceStatusAndReasonTM2(wrapperExt,serviceextension.tramasErrorCode,serviceextension.Reserve_status);
                                                        
                                                    }
                                                    
                                                    //}
                                                    //EDGE-202851 Kalashree Borgaonkar. set reason and status - end
                                                    transitionWrapperList.add(wrapperExt);
                                                    //}
                                                }
                                            }
                                            system.debug('transitionWrapperList222@@@'+ transitionWrapperList);
                                            
                                            //End changes for Edge-104020- to enable service Extenstion numbers
                                        }
                                        
                                        
                                    }
                                }
                                //  }
                            }
                        }
                    }
                }
                
                
            }
            //EDGE-203928. Kalashree Borgaonkar start
            System.debug('serviceidList: '+serviceidList);
            Map<String,Boolean> serviceTogreyMap =  NumberReservationTM2CallOut.checkforNumberAssignment(basketId,serviceidList);
            System.debug('serviceidList: '+serviceTogreyMap);
            //DIGI-1944
            Map<String,String> serviceToAssignedto =  NumberReservationTM2CallOut.populateAssignedToinLegacyTable(basketId,serviceidList);
            for(transitionWrapper wrap : transitionWrapperList){
                //if(serviceTogreyMap.keyset().contains(wrap.Service_Id)){
                wrap.isgreyedout  =  (serviceTogreyMap.get(wrap.Service_Id)!=null)?serviceTogreyMap.get(wrap.Service_Id):false;
                 wrap.assignedTo  =  (serviceToAssignedto.get(wrap.Service_Id)!=null)?serviceToAssignedto.get(wrap.Service_Id):'';
                //}
            }
            //EDGE-203928. Kalashree Borgaonkar end
            System.debug('transitionWrapperList final: '+transitionWrapperList);
        }
        
        catch (Exception ex){
            
            //system.debug('Exception occured in transitionController Class at line number '+ex.getLineNumber()+' due to '+ex.getMessage());
            logException('getServiceNumber', basketId, correlationId, ex.getMessage(), 'Get service number and reserve status');
            
        }
        
        system.debug('transitionWrapperList333@@@'+ transitionWrapperList);
        
        return transitionWrapperList;
    }
    
    @AuraEnabled public static List<string>  createTransitionNumberRecord(String transitionWrapperList,string basketId, List<string> selectedPcWrapper){
        List<Number__c> numList=new  List<Number__c>();
        map<string,Number__c>numberMap=new map<string,Number__c>();
        map<string,Number_Group__c>numberGroupMap=new map<string,Number_Group__c>();
        List<string> serviceNumberList=new List<string>();
        set<string> serviceNumberSet=new set<string>();
        map<string,List<Number__c>>fixedNumberMap=new map<string,List<Number__c>>();
        List<Number_Group__c> numGroupList = new List<Number_Group__c>();
        List<string>currentPlan= new List<string>();
        Map<String,Id> mapTranIdNumGrpId = new Map<String,Id>();
        try{
            List<transitionWrapper> fieldList = (List<transitionWrapper>) JSON.deserialize(transitionWrapperList, List<transitionWrapper>.class);
            System.debug('fieldList-'+fieldList);
            if(fieldList.size()>0){
                // 1325 changes starts here 
                Set<String> setTransId = new Set<String>();
                Set<String> basketIds = new Set<String>();
                
                for (transitionWrapper transition :fieldList) {
                    if(transition.service_type == 'Fixed'){
                        setTransId.add(transition.transitionId);
                        basketIds.add(transition.basketId);
                    }
                }
                
                for(Number_Group__c numGroup:[SELECT id,Transition_Id__c,Product_Basket__c  FROM Number_Group__c WHERE Product_Basket__c In : basketIds AND Status__c = 'Reserved' AND Scenario_Type__c = 'Transition' AND Transition_Id__c IN:setTransId ]){
                    mapTranIdNumGrpId.put(numGroup.Transition_Id__c,numGroup.Id);
                    numberGroupMap.put(numGroup.Transition_Id__c,numGroup);
                    
                }
                // 1325 changes starts here 
                
                Map<String,String> mapStartRangeTransId = new Map<String,String>();
                for (transitionWrapper transition :fieldList) {
                    if(transition.service_type == 'Fixed'){
                        if(!mapTranIdNumGrpId.containsKey(transition.transitionId)){
                            Number_Group__c numGroup = new Number_Group__c();
                            numGroup.Transition_Id__c = transition.transitionId;
                            numGroup.Product_Basket__c = transition.basketId;
                            numGroup.Product_Configuration__c = transition.productConfigId;
                            numGroup.Status__c = 'Reserved';
                            numGroup.Scenario_Type__c = 'Transition';
                            numGroup.SiteID__c=transition.ADBOR_Id;
                            numGroup.Product_Family__c=transition.productFamily;
                            numGroupList.add(numGroup);
                        }
                        /*else {
                            if(!numberGroupMap.isEmpty() && numberGroupMap.containsKey(transition.transitionId)){
                                //mapTranIdNumGrpId.put(transition.transitionId,numberGroupMap.get(transition.transitionId).Id);
                            }
                        }*/
                    }
                    if(transition.fromNumber!=null && transition.toNumber!=null){
                        serviceNumberSet.add(transition.fromNumber);   // ## create a map of  from number  & transition Id 
                        mapStartRangeTransId.put(transition.fromNumber, transition.transitionId);
                    }
                    else {
                        serviceNumberSet.add(transition.Service_Id); 
                    }
                    
                }
                if(!numGroupList.isEmpty() && Number_Group__c.SObjectType.getDescribe().isAccessible()){
                    // SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, numGroupList);
                    // insert securityDecision.getRecords();
                    insert numGroupList;   
                    for( Number_Group__c numGroup : numGroupList){
                        // System.debug('numGroup-'+numGroup);
                        // System.debug('numGroup ID-'+numGroup.Id);
                        mapTranIdNumGrpId.put(numGroup.Transition_Id__c,numGroup.Id );
                    }
                }     
                System.debug('mapTranIdNumGrpId-'+mapTranIdNumGrpId);
                
                for(Number__c num:[SELECT id,service_number__c,basket__c,Start_Range__c,Number_Group__c,Mobile__c,Transition_Id__c  FROM Number__c WHERE basket__c =:basketId AND (service_number__c IN :serviceNumberSet OR Start_Range__c IN :serviceNumberSet)]){
                    if(string.isNotBlank(num.Start_Range__c)){ // ## NG changes only in this condition
                        num.Number_Group__c = mapTranIdNumGrpId.get( mapStartRangeTransId.get(num.Start_Range__c)); // ## from map in 272 - populate NG id with Start_Range__c as key   
                        if(!fixedNumberMap.isEmpty() && fixedNumberMap.containsKey(num.Start_Range__c)) {
                            List<Number__c> numberList = fixedNumberMap.get(num.Start_Range__c);
                            numberList.add(num);
                            fixedNumberMap.put(num.Start_Range__c,numberList);
                        } 
                        else {
                            fixedNumberMap.put(num.Start_Range__c,new List<Number__c>{num}); 
                        }
                    }
                    else{
                        numberMap.put(num.service_number__c,num);
                    }
                }
                // System.debug('fixedNumberMap-'+fixedNumberMap);
                // System.debug('numberMap-'+numberMap);
                // System.debug('mapTranIdNumGrpId-'+mapTranIdNumGrpId);
                // System.debug('mapStartRangeTransId-'+mapStartRangeTransId);
                
                for(transitionWrapper transition :fieldList){
                    // ## need to populate all all the NG field on numbers
                    Number__c num=new Number__c ();
                    if(transition.fromNumber==null && transition.toNumber==null){
                        if(!numberMap.isEmpty() && numberMap.containsKey(transition.Service_Id)){
                            num=numberMap.get(transition.Service_Id);
                            num.Number_Group__c = ( !mapTranIdNumGrpId.isEmpty() && transition.service_type == 'Fixed' && mapTranIdNumGrpId.containskey(transition.transitionId) ) ? mapTranIdNumGrpId.get(transition.transitionId):null;
                        }
                        else{ 
                            num.Service_Number__c=transition.Service_Id;
                            num.Type__c='Transition';
                            num.Plan_Type__c=transition.planType;
                            num.Transition_Id__c=transition.transitionId;
                            num.Basket__c=transition.basketId;
                            num.Mobile__c=transition.service_type;
                            num.Imsi__c=transition.networkId; 
                            num.Sim_Serial_Number__c=transition.physicalId;
                            num.Number_Group__c = ( !mapTranIdNumGrpId.isEmpty() && transition.service_type == 'Fixed' && mapTranIdNumGrpId.containskey(transition.transitionId) ) ? mapTranIdNumGrpId.get(transition.transitionId):null;
                            currentPlan = string.isNotBlank(transition.currentPlan) &&   transition.currentPlan.contains('|')? transition.currentPlan.split('\\|'):null;
                            num.Plan_Name__c= currentPlan!=null && currentPlan.size()>=2 ? currentPlan[1]:'';
                        }
                        numList.add(num);
                    }
                    else if(transition.fromNumber!=null && transition.toNumber!=null){
                        if(!fixedNumberMap.isEmpty() && fixedNumberMap.containsKey(transition.fromNumber) && fixedNumberMap.get(transition.fromNumber)!= NULL ){
                            List<Number__c> numberList = fixedNumberMap.get(transition.fromNumber); 
                            
                            numList.addAll(numberList);
                        }
                        else {
                            Id numberGroupId = (!mapTranIdNumGrpId.isEmpty() && mapTranIdNumGrpId.containsKey(transition.transitionId)) ? mapTranIdNumGrpId.get(transition.transitionId) : null;
                            List<Number__c> numListSplit= new List<Number__c>();
                            numListSplit=NumberReservationHandler.splitRangeofNumbers( transition.fromNumber,transition.toNumber,transition.basketid,transition.accountId,'RESERVED','Transition',null,numberGroupId);//transition.productConfigId);
                            numList.addAll(numListSplit);
                        }
                    }
                    
                } 
                if(numList.size()>0){
                    upsert numList;
                    // System.debug('numList-'+numList);
                    for(Number__c num:numList){
                        serviceNumberList.add(num.Service_Number__c);
                    }
                } 
            }
            return serviceNumberList;
        }
        catch (Exception ex){
            logException('createTransitionNumberRecord', '', correlationId, ex.getMessage(), 'Creation of Number__c record for number selected for transition');
            return null; 
        }
        
    }
    
    /*-----------------------------------------------------------------------------
EDGE        -198374 
Method Name -createFeedbackCase
Description -Create Feedback case.  
Author      -Nikhil Kumar
-------------------------------------------------------------------------------*/
    @AuraEnabled public static case createFeedbackCase(string basketId, string cidnNumber,string transactionId,string fnnList){
        
        try{
            String feedbackCaseRTId  = Schema.SObjectType.Case.RecordTypeInfosByName.get('Feedback').RecordTypeId;  
            Id feedbackQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'Modular_Order' LIMIT 1].Id; //DIGI-6677 changes queue from feedback to Modular
            
            system.debug('createFeedbackCase@@@');
            
            string accountId ='';
            string basketName ='';
            if(basketId != null){   
                List<cscfga__Product_Basket__c> prdBasketList = [select id,Name,csbb__Account__c from cscfga__Product_Basket__c where id=:basketId limit 1];
                if(!prdBasketList.isEmpty()){
                    accountId = prdBasketList[0].csbb__Account__c;
                    basketName = prdBasketList[0].Name;
                }
            }   
            
            Case newCase = new Case( Subject = CASESUBJECT +''+basketName, 
                                    accountId = accountId,
                                    OwnerId = userinfo.getUserid(),
                                    Priority = CASEPRIORITY,
                                    Status = CASESTATUS,
                                    Severity__c = CASESEVERITY,
                                    Description = system.label.Feedback_case_description1 +' '+ cidnNumber +' '+system.label.Feedback_case_description2+' '+ transactionId +' '+ system.label.Feedback_case_description3 +' '+ fnnList,
                                    Feedback_Related_to__c = DIGITIZEDORDERING,
                                    Origin = CASEORIGIN,
                                    RecordTypeId = feedbackCaseRTId,
                                    Feedback_Category__c = CHECKPOINTTRANSITION
                                   );
            
            
            
            Insert newCase;
            
            case caseRec = [select id,caseNumber from case where id=: newCase.id limit 1];
            system.debug('caseRec@@@ ' + caseRec);
            return caseRec;
        }catch(Exception ex){
            //System.debug('Inside-> caseCreate -> Error occured: '+ ex.getMessage() +' Stack Trace: '+ ex.getStackTraceString());
            logException('createFeedbackCase', '', correlationId, ex.getMessage(), 'create Feedback Case');
            
            if(Test.isRunningTest()){               
                logException(null,'createFeedbackCase', '','','', correlationId,'','', ex.getMessage(), 'create Feedback Case','',null,'',''); 
            }
            
            return null;
        }        
        
        //return null;        
    }
    
    /*-----------------------------------------------------------------------------
EDGE        -EDGE-195766 
Method Name -updatetransitionBasketStagetoCheckEligibility
Description -Method to update set the value on Transition_basket_stage__c, inorder to start the Spinner while TM2 callout.  
Author      -Veena Putta
-------------------------------------------------------------------------------*/ 
    @AuraEnabled  
    public static cscfga__Product_Basket__c updatetransitionBasketStagetoCheckEligibility(String basketId){
        List<cscfga__Product_Basket__c> prodbasket = new List<cscfga__Product_Basket__c>();
        system.debug('@V@ inside apex method');
        try
        {
            if(basketId!=null)
            {               
                prodbasket = ConstantMetadataUtility.getbasketdetails(basketId);
                prodbasket[0].Transition_basket_stage__c='Reservation Triggered';
                prodbasket[0].isEligibilityTriggered__c=true;
                update prodbasket[0];
            }   
        }
        catch(Exception e){
            System.debug('Exception: ' + e);
            Logger.getLogger(TransitionController.class + ':' +basketId ).debug(e);
            Logger.exitLogger();
            
            logException('updatetransitionBasketStagetoCheckEligibility', '', correlationId, e.getMessage(), 'Update the value on Transition_basket_stage__c');
            
            return null;    
        }
        return prodbasket[0];      
    }
    
    /*-----------------------------------------------------------------------------
EDGE        -EDGE-195766 
Method Name -getTM2CallServices
Description -Method to execute TM2 callout related code from NumberReservationTM2CallOut.  
Author      -Veena Putta
-------------------------------------------------------------------------------*/ 
    @AuraEnabled 
    public static void getTM2CallServices(string basketId){       
        
        NumberReservationTM2CallOut tm2CallOut = new NumberReservationTM2CallOut();
        tm2CallOut.fetchEligibleProdConfig(basketId);      
    }
    
    /*-----------------------------------------------------------------------------
EDGE        -EDGE-195766 
Method Name -getEligibityStatus
Description -Method to verify TM2 callout status for NGUC, inorder to stop the spinner on click of refresh .  
Author      -Veena Putta
-------------------------------------------------------------------------------*/ 
    
    @AuraEnabled 
    public static List<Integer> getEligibityStatus(String basketId){
        System.debug('@V@ Insite getEligibityStatus');
        List<Integer> progressRing = new List<Integer>();
        
        try
        {
            /*cscfga__Product_Basket__c prodBasket = [SELECT id , isEligibilityCheckComplete__c , isEligibilityTriggered__c,Transition_basket_stage__c 
FROM cscfga__Product_Basket__c 
WHERE id = : basketId ];*/
            List<cscfga__Product_Basket__c> prodBasket = ConstantMetadataUtility.getbasketdetails(basketId);
            List <cscfga__Product_Configuration__c> prodConfig = [SELECT id , name ,  isEligibleForTriggered__c,isEligibleForTransition__c 
                                                                  FROM cscfga__Product_Configuration__c 
                                                                  WHERE cscfga__Product_Basket__r.Id = :  basketId AND (name = 'IP Site' )]; //OR cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecNgUC
            System.debug('prodConfig '+prodConfig);
            Map<id,TramasElgibilityCallbackResponse__c> tm2PCMap=new Map<id,TramasElgibilityCallbackResponse__c>();
            for(TramasElgibilityCallbackResponse__c tm2:[SELECT id , Product_Configuration__c,Eligibility_Criteria__c 
                                                         FROM TramasElgibilityCallbackResponse__c 
                                                         WHERE Product_Basket__c = : basketId AND Product_Configuration__c in : prodConfig order by lastmodifiedDate desc]){
                                                             if(!tm2PCMap.containsKey(tm2.Product_Configuration__c)){                
                                                                 tm2PCMap.put(tm2.Product_Configuration__c,tm2);
                                                             }
                                                         }
            system.debug('@V@ prodConfig ---> '+prodConfig);
            system.debug('@V@ tm2PCMap ---> '+tm2PCMap);
            Integer totalPCItems = 0;
            Integer totalPCEligibiltyDOne = 0;
            Integer flag =1;
            
            totalPCItems = tm2PCMap.size();
            progressRing.add(totalPCItems);
            Integer isEligibilityResultcalculatedCount=0;
            
            for (cscfga__Product_Configuration__c pc : prodConfig ){
                if(tm2PCMap.containskey(pc.id)){
                    if (pc.isEligibleForTriggered__c == true){
                        totalPCEligibiltyDOne++;
                    }
                    if (pc.isEligibleForTriggered__c == false){
                        flag =0;
                    }
                    if(tm2PCMap.get(pc.id).Eligibility_Criteria__c.containsIgnoreCase('Eligible')){
                        isEligibilityResultcalculatedCount++;
                    }
                }                    
            }
            system.debug('totalPCEligibiltyDOne ---> '+totalPCEligibiltyDOne);
            system.debug('isEligibilityResultcalculatedCount ---> '+isEligibilityResultcalculatedCount);
            
            if(tm2PCMap.size()==isEligibilityResultcalculatedCount){
                prodBasket[0].isEligibilityCheckComplete__c=true;
                if(prodBasket[0].Transition_basket_stage__c=='Reservation Triggered'){
                    prodBasket[0].Transition_basket_stage__c='Reservation Completed';
                }
                System.debug('@V@ prodBasket[0]' + prodBasket[0]);
                update prodBasket[0]; 
               
            }
            
            system.debug('totalPCEligibiltyDOne ---> '+isEligibilityResultcalculatedCount);
            system.debug('totalPCItems ---> '+totalPCItems);
            
            progressRing.add(isEligibilityResultcalculatedCount);
            progressRing.add(flag);
            if (prodBasket[0].isEligibilityCheckComplete__c == false){
                progressRing.add(0);
            }
            if (prodBasket[0].isEligibilityTriggered__c == false){
                progressRing.add(0);
            }
            else {
                progressRing.add(1);
            system.debug('return Map ---> '+progressRing); 
            }                                      
        }
        catch(Exception e)
        {
            Logger.getLogger(TransitionController.class + ':' +basketId ).debug(e);
            Logger.exitLogger();
            
            logException('getEligibityStatus', '', correlationId, e.getMessage(), 'Get Eligibility Status');
            
        }
        return progressRing; 
    }
    /*-----------------------------------------------------------------------------
EDGE        -EDGE-195766 
Method Name -getEligibilityStatusMobile
Description -Method to verify TM2 callout status for mobile , inorder to stop the spinner on click of refresh .  
Author      -Veena Putta
-------------------------------------------------------------------------------*/    
    @AuraEnabled
    public static boolean getEligibilityStatusMobile(String basketId){
        Boolean isResponseUpdated;
        String productSpecMobile = Label.ProductSpecificationMobile;
        List<String> listproductSpecMobile = productSpecMobile.split(',');
        
        List<MobileTramasElgibility__c> mobileTramRec = new List<MobileTramasElgibility__c>();
        
        try{
            cscfga__Product_Basket__c prodBasket = getBasket(basketId);
            List <cscfga__Product_Configuration__c> prodConfig = [SELECT id, name, isEligibleForTriggered__c, isEligibleForTransition__c 
                                                                  FROM cscfga__Product_Configuration__c 
                                                                  WHERE cscfga__Product_Basket__r.Id = : basketId AND (cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecMobile)]; 
            System.debug('@V@ prodConfig '+prodConfig);
            
            /*  prodbasket.Transition_basket_stage__c='Reservation Completed';
update prodbasket; */
            
            system.debug('@V@ prodbasket' +prodbasket);
            mobileTramRec = [SELECT id,Type__c 
                             FROM MobileTramasElgibility__c 
                             WHERE Product_Basket__c = :basketId AND Product_Configuration__c in :prodConfig ORDER BY CreatedDate DESC LIMIT 1];
            System.debug('@V@ Mobile Tram Record::::' +mobileTramRec);
            List<Attachment> attRec = new List<Attachment>();
            System.debug('@V@ attRec::::' +attRec);
            if(mobileTramRec.size() > 0){
                attRec = [SELECT id, body FROM Attachment where ParentId = :mobileTramRec[0].id ORDER BY CreatedDate DESC LIMIT 1];
            }
            if(attRec.size() > 0){
                if(attRec[0].body.size()>0 && mobileTramRec[0].Type__c == 'TM2'){
                    System.debug('@V@ attRec[0].body.size()::::' +attRec[0].body.size());
                    isResponseUpdated = true;
                    prodBasket.isEligibilityCheckComplete__c=true;
                    if(prodbasket.Transition_basket_stage__c=='Reservation Triggered'){
                        prodbasket.Transition_basket_stage__c='Reservation Completed';
                    }
                    System.debug('prodBasket Mobile' + prodBasket);
                    update prodBasket;
                    
                      //DIGI-1678 start 
                    List<ChatterUtilityClass.ChatterFeedWrapper> feedsLsts = new List<ChatterUtilityClass.ChatterFeedWrapper>();
                    
                    String communityId=null;
                    String subjectId=prodBasket.id;
                    System.debug('subjectId@@@ ' + subjectId);
                    String textWithMentions='The retireve service call has been completed for the basket '+ prodBasket.Name+'{'+prodBasket.CreatedById+'}\n'+ URL.getSalesforceBaseUrl().toExternalForm()+'/'+prodBasket.Id;
                    feedsLsts.add(new ChatterUtilityClass.ChatterFeedWrapper(communityId,subjectId, textWithMentions ));
                    System.debug('feedsLsts@@@@' + feedsLsts);
                    ChatterUtilityClass.chatterNotificationHelper(feedsLsts);
                     // DIGI-1678 END 
                    
                    user u= [SELECT Id, Name, CreatedById, Email, CreatedBy.Name FROM User WHERE Id = :prodBasket.createdById][0];
                        
                     CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                               FROM CustomNotificationType 
                                                               WHERE DeveloperName='Notification_to_Product_Basket_Creator'];
                    
                    CustomNotificationFromApex.sendNotificationsToBasketUser(notificationType, prodBasket, prodBasket.Name, textWithMentions); 
                   
                    
                    Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
                    //m.setWhatId(prodBasket.id);
                    m.setSubject(prodBasket.id);
                    m.settoaddresses(new string[] {  u.email });
                    //m.setsaveasactivity(true);
                    m.setPlainTextBody(textWithMentions);
                    messaging.sendemail(new messaging.email[] { m });
                }              
                else
                {
                    isResponseUpdated = false;
                   
                }
            }
        }
        catch(Exception e)
        {
            Logger.getLogger(TransitionController.class + ':' +basketId ).debug(e);
            Logger.exitLogger();
            
            logException('getEligibilityStatusMobile', '', correlationId, e.getMessage(), 'Get Eligibility Status for Mobile');  
            
            isResponseUpdated = false;
        }
        return isResponseUpdated;
    }
    
    /** EDGE-195766 To fetch all the attributes of Basket*/
    @AuraEnabled 
    public static cscfga__Product_Basket__c getBasket(String basketId) {
        cscfga__Product_Basket__c prodBasket = [SELECT Id, Name, isEligibilityCheckComplete__c,isEligibilityTriggered__c,cscfga__total_contract_value__c, csbb__Account__c, csbb__Account__r.CIDN__c, csbb__Account__r.ABN__c, csbb__Synchronised_With_Opportunity__c, Primary_Basket__c, csbb__Account__r.Name, cscfga__Opportunity__c, CreatedById, Created_By__c, cscfga__Opportunity__r.Name,cscfga__Opportunity__r.Type, Description__c, csordtelcoa__Basket_Stage__c,Transition_basket_stage__c 
                                                FROM cscfga__Product_Basket__c 
                                                WHERE Id =: basketId];
        return prodBasket;
    } 
    
    /* @AuraEnabled 
public static NumberReservationTM2CallOut.ErrorWrapper getTramsErrorCode(String offerType,string basketId,String exetype){
NumberReservationTM2CallOut.ErrorWrapper errorWrap=NumberReservationTM2CallOut.getTramsErrorCode(offerType,basketId,exetype);
return errorWrap;
//   return null;

}*/
    //EDGE-198374. Kalashree Borgaonkar
    @AuraEnabled 
    public static NumberReservationTM2CallOut.ErrorWrapper getTramsErrorCode(String offerType,string basketId,String exetype,DateTime currentDate){
        NumberReservationTM2CallOut.ErrorWrapper errorWrap=NumberReservationTM2CallOut.getTramsErrorCode(offerType,basketId,exetype,currentDate);
        return errorWrap;
        //return null;
        
    }
    //EDGE-198374. Kalashree Borgaonkar
    @AuraEnabled 
    public static DateTime getCurrentDatetime(){
        DateTime gmtDate =  System.now();
        // String convertedDate = gmtDate.format('yyyy-MM-dd HH:mm:ss');
        //return Datetime.valueofgmt(gmtDate);
        return gmtDate;
        
    }
    //EDGE-218031 : vivek
    @AuraEnabled
    public static String getCommunityUrl() {
        if(Network.getNetworkId()!=null){
            return network.getLoginUrl(Network.getNetworkId()).removeEnd('login');
        }
        return null;
    }
    /*-----------------------------------------------------------------------------
EDGE        -85161
Class Name  -transitionWrapper
Description -Wrapper class to hold data for showing in Transition tab UI.  
Author      -Dheeraj Bhatt  
-------------------------------------------------------------------------------*/
    public class TransitionWrapper{
        @AuraEnabled public string tramasStatus;//EDGE-202851 new attribute to map status from TransitionResponseCodes__c
        @AuraEnabled public string tramasReason;//EDGE-202851 new attribute to map reason from TransitionResponseCodes__c
        @AuraEnabled public string Service_Id ;
        @AuraEnabled public string Reserve_status;
        @AuraEnabled public string CIDN_Number;
        @AuraEnabled public string FNN_Number;
        @AuraEnabled public string Reason;
        @AuraEnabled public boolean isSelected;
        @AuraEnabled public string productConfigId;
        @AuraEnabled public string transitionId;
        @AuraEnabled public string basketId;
        @AuraEnabled public string physicalId; //new attribute for capturing IMSI
        @AuraEnabled public string networkId; //new attribute for capturing Sim_Serial_Number__c
        @AuraEnabled public string fromNumber; //new attribute for capturing number range's starting number__EDGE-115694 
        @AuraEnabled public string toNumber; //new attribute for capturing number range's ending number__EDGE-115694 
        @AuraEnabled public string accountId; //new attribute for capturing number range's ending number__EDGE-115694 
        @AuraEnabled public string service_type;
        @AuraEnabled public string planType; //EDGE-148075 - New Attribute for capturing Plan Type.
        @AuraEnabled public string productFamily; //EDGE-148075 - New Attribute for capturing Plan Type.
        @AuraEnabled public string currentPlan; //EDGE-168704 - New Attribute for capturing Current Plan.
        @AuraEnabled public Boolean isgreyedout; //EDGE-203928 - New Attribute for capturing assigned numbers
        @AuraEnabled public string Id; //inline editing purpose
        @AuraEnabled public string ADBOR_Id; //Add by Nikhil EDGE-217339 as part of B2B 1260
        @AuraEnabled public String assignedTo;//DIGI-1944-New attribute for capturing solution and plan name
    }
    
    /**
* @description Exception Handling Framework 
*/
    private static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('capability', cONSTCAPABILITY);
        eLogMap.put('interfaceName', CONSTINTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
    
    private static void logException(String severity, string methodName, String referenceNumber, String endpointURL, String integrationPayload, String correlationId, String httpStatusCode, String errorCode, String errorMessage,  String responseMessage, String destinationSystem, String sourceName, String businessDescription, String errorCategory) {
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('severity', severity);
        eLogMap.put('interfaceName', CONSTINTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('capability', cONSTCAPABILITY);
        eLogMap.put('endpointURL', endpointURL);
        eLogMap.put('integrationPayload', integrationPayload);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('httpStatusCode', httpStatusCode);
        eLogMap.put('errorCode', errorCode);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('responseMessage', responseMessage);
        eLogMap.put('destinationSystem', destinationSystem);
        eLogMap.put('sourceName', sourceName);
        eLogMap.put('businessDescription', businessDescription);
        eLogMap.put('errorCategory', errorCategory);
        C2O_Utilities.logException(eLogMap, false);
    }
}