/**
 * @Author   :   Maq, Rahul 
 * @Date     :   19 Feb 2020
 * @Desc     :   get in lightning view table for ngUc and grouping logic
 * @US       :   EDGE-120154, EDGE-120156
 * @Status   :   In progress.
 * */
 //EDGE-152495 - Vivek/Ankit from Team Apple - Seprating the grouping logic for TIPT-SIPC Product family; using hybrid_new method for this family


public with sharing class ReplicatorGetServiceManagerHandler {
    public static Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> prodGroupTypeMapping = New Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> ();
    public static map < String, Transition_Group_Structure_New__mdt > transGroupStructMapMain = new map < String, Transition_Group_Structure_New__mdt> ();
    public static map < String, Transition_Group_Structure_New__mdt > transGroupStructMapTiptSipc = new map < String, Transition_Group_Structure_New__mdt> ();
    public static Map < String, list < TransitionDataDTO.SiteDTOMobile >> prodSiteMapGlobal = new Map < String, list < TransitionDataDTO.SiteDTOMobile >> ();
    public ReplicatorGetServiceManagerHandler() {
           // Fetch custom metadata value ----
           for (Transition_Group_Structure_New__mdt transGroupStruct: [SELECT DeveloperName, Label, Node_1__c, Node_2__c, Node_3__c, Product_Family__c, Range_Indicator__c FROM Transition_Group_Structure_New__mdt]) {
               transGroupStructMapMain.put((transGroupStruct.Product_Family__c+ '~!@!~' + transGroupStruct.Node_1__c + '~!@!~' + transGroupStruct.Node_2__c + '~!@!~' + transGroupStruct.Node_3__c).toLowerCase().replaceAll('~!@!~null', ''), transGroupStruct);
           }
           system.debug('transGroupStructMapMain#######>>>>>************* transGroupStructMapMain: ' + JSON.serialize(transGroupStructMapMain));
   
       }
   
    @AuraEnabled
       public static Map < String, Map < String,  List < TransitionDataDTO.serviceDTOMobile > >> groupingLogic_ByRange(ReplicatorGetServiceDTO.servicesDTO serviceDetailsRange) {
               TransitionDataDTO.serviceDTOMobile tempService = new TransitionDataDTO.serviceDTOMobile();                  
               tempService = getService(serviceDetailsRange);
               list<TransitionDataDTO.serviceDTOMobile> groupServiceRecordList = new list<TransitionDataDTO.serviceDTOMobile>();   
                   groupServiceRecordList.add(tempService);
                if (ReplicatorGetServiceManager.prodGroupTypeMapping.containsKey(serviceDetailsRange.productFamily)) {
                    ReplicatorGetServiceManager.prodGroupTypeMapping.get(serviceDetailsRange.productFamily).put(serviceDetailsRange.fnn, groupServiceRecordList);
                }
               if (!ReplicatorGetServiceManager.prodGroupTypeMapping.containsKey(serviceDetailsRange.productFamily)) {
                    Map < string,  list<TransitionDataDTO.serviceDTOMobile> > subDetails = New Map < string,  list<TransitionDataDTO.serviceDTOMobile> > ();
                    subDetails.put(serviceDetailsRange.fnn, groupServiceRecordList);
                    ReplicatorGetServiceManager.prodGroupTypeMapping.put(serviceDetailsRange.productFamily, subDetails);
                       
               }
               system.debug('#######>>>>>************* prodGroupTypeMapping: ' + JSON.serialize(ReplicatorGetServiceManager.prodGroupTypeMapping));
               return ReplicatorGetServiceManager.prodGroupTypeMapping;
       }

    @AuraEnabled   
      public static Map < String,Map < String,List < TransitionDataDTO.serviceDTOMobile > >>groupingLogic_ByNodeParent(ReplicatorGetServiceDTO.servicesDTO serviceDetailsGroup) {
        system.debug('$$$$$$$uniqueDataStringserviceDetailsGroup Parent ' + JSON.serialize(serviceDetailsGroup));
        TransitionDataDTO.serviceDTOMobile tempService = new TransitionDataDTO.serviceDTOMobile();
           tempService = getService(serviceDetailsGroup);
           list < TransitionDataDTO.serviceDTOMobile > groupServiceRecordList = new list < TransitionDataDTO.serviceDTOMobile > ();
           groupServiceRecordList.add(tempService);
           Set < String > associationData = New Set < String > ();
           for (ReplicatorGetServiceDTO.serviceAssociationDTO association: serviceDetailsGroup.serviceAssociations) {
               associationData.add(association.linkedServiceRole);
           }
           String childNodes = '';
           for (String eachNodeValue: associationData) {
               childNodes += '~!@!~' + eachNodeValue;
           }
    //       String uniqueDataString = serviceDetailsGroup.productFamily + '~!@!~' + tempService.service_association_role + childNodes;
    // Added Null check for bug Fix EDGE-145394
           String uniqueDataString = serviceDetailsGroup.productFamily;
           if(tempService.service_association_role != null && tempService.service_association_role != '')
           uniqueDataString += '~!@!~' + tempService.service_association_role;
           if(childNodes != null && childNodes != '')
           uniqueDataString += childNodes;
           system.debug('$$$$$$$uniqueDataString' + JSON.serialize(uniqueDataString.toLowerCase()));
           system.debug('$$$$$$$transGroupStructMapMain' + JSON.serialize(transGroupStructMapMain));
        if(transGroupStructMapMain.get(uniqueDataString.toLowerCase()) != null){   
           if (transGroupStructMapMain.get(uniqueDataString.toLowerCase()).Product_Family__c == serviceDetailsGroup.productFamily) {
               if (!ReplicatorGetServiceManager.prodGroupTypeMapping.containsKey(serviceDetailsGroup.productFamily + '_' + transGroupStructMapMain.get(uniqueDataString.toLowerCase()).Label)) {
                   Map < string, list < TransitionDataDTO.serviceDTOMobile > > subDetails = New Map < string, list < TransitionDataDTO.serviceDTOMobile > >();
                   subDetails.put(serviceDetailsGroup.fnn, groupServiceRecordList);
                   ReplicatorGetServiceManager.parentUniqueStringMap.put(serviceDetailsGroup.fnn, uniqueDataString);
                   ReplicatorGetServiceManager.prodGroupTypeMapping.put(serviceDetailsGroup.productFamily + '_' + transGroupStructMapMain.get(uniqueDataString.toLowerCase()).Label+'_'+serviceDetailsGroup.fnn, subDetails);
                   system.debug('$$$$$$$prodGroupTypeMapping>>Inside' + JSON.serialize(ReplicatorGetServiceManager.prodGroupTypeMapping));
       
               }
           }
        }
       
           system.debug('$$$$$$$prodGroupTypeMapping>>' + JSON.serialize(ReplicatorGetServiceManager.prodGroupTypeMapping));
           return ReplicatorGetServiceManager.prodGroupTypeMapping;
       }
       @AuraEnabled   
       public static Map < String,Map < String,List < TransitionDataDTO.serviceDTOMobile > >>groupingLogic_ByNodeChild(ReplicatorGetServiceDTO.servicesDTO serviceDetailsGroup) {

           system.debug('ReplicatorGetServiceManager.parentUniqueStringMap--->'+ReplicatorGetServiceManager.parentUniqueStringMap);
           system.debug('transGroupStructMapMain'+transGroupStructMapMain);
           String parentRoleString = '';
           String nonParentString = '';
           TransitionDataDTO.serviceDTOMobile tempService = new TransitionDataDTO.serviceDTOMobile();
           tempService = getService(serviceDetailsGroup);
           list < TransitionDataDTO.serviceDTOMobile > groupServiceRecordList = new list < TransitionDataDTO.serviceDTOMobile > ();
           groupServiceRecordList.add(tempService);
           Set < String > associationData = New Set < String > ();
           String uniqueStringMetaData = '';
           String parentFNN = '';
             if (serviceDetailsGroup.serviceAssociations != null) {
                   for (ReplicatorGetServiceDTO.serviceAssociationDTO association: serviceDetailsGroup.serviceAssociations) {
                        associationData.add(association.linkedServiceRole);
                        if(ReplicatorGetServiceManager.parentUniqueStringMap.containsKey(association.linkedServiceId)){
                            uniqueStringMetaData = ReplicatorGetServiceManager.parentUniqueStringMap.get(association.linkedServiceId);
                            parentFNN = association.linkedServiceId;
                        }

                   }
                   system.debug(parentFNN +'---p--->'+uniqueStringMetaData );
                   if(transGroupStructMapMain.get(uniqueStringMetaData.toLowerCase()) != null){ 

                    if (transGroupStructMapMain.get(uniqueStringMetaData.toLowerCase()).Product_Family__c == serviceDetailsGroup.productFamily) {
                        if (ReplicatorGetServiceManager.prodGroupTypeMapping.containsKey(serviceDetailsGroup.productFamily + '_' + transGroupStructMapMain.get(uniqueStringMetaData.toLowerCase()).Label+'_'+parentFNN)) {
                           // prodGroupTypeMapping.put(serviceDetailsGroup.productFamily + '_' + transGroupStructMapMain.get(uniqueStringMetaData.toLowerCase()).Label, subDetails);
                            system.debug('$$$$$$$prodGroupTypeMapping>>Inside' + JSON.serialize(ReplicatorGetServiceManager.prodGroupTypeMapping));
                            ReplicatorGetServiceManager.prodGroupTypeMapping.get(serviceDetailsGroup.productFamily + '_' + transGroupStructMapMain.get(uniqueStringMetaData.toLowerCase()).Label+'_'+parentFNN).get(parentFNN).add(tempService);
                
                        }
                    }

                   }                     
            }
             system.debug('$$$$$$$prodGroupTypeMapping>>--->Child' + JSON.serialize(ReplicatorGetServiceManager.prodGroupTypeMapping));
           return ReplicatorGetServiceManager.prodGroupTypeMapping;
       }
       @AuraEnabled   
       public static Map < String,Map < String,List < TransitionDataDTO.serviceDTOMobile > >>groupingLogic_ByHybrid(ReplicatorGetServiceDTO.servicesDTO serviceDetailsGroup) {

        TransitionDataDTO.serviceDTOMobile tempService = new TransitionDataDTO.serviceDTOMobile();
        tempService = getService(serviceDetailsGroup);
        list < TransitionDataDTO.serviceDTOMobile > groupServiceRecordList = new list < TransitionDataDTO.serviceDTOMobile > ();
        groupServiceRecordList.add(tempService);
        Set < String > associationData = New Set < String > ();
        String uniqueStringMetaData = '';
        String parentFNN = '';
        if (serviceDetailsGroup.serviceAssociations != null) {
            for (ReplicatorGetServiceDTO.serviceAssociationDTO association: serviceDetailsGroup.serviceAssociations) {
                associationData.add(association.linkedServiceRole);
                for (ReplicatorGetServiceDTO.serviceCharacteristicDTO serviceCharacteristics: serviceDetailsGroup.serviceCharacteristics) {
                    if (serviceCharacteristics.name == 'service_association_role' && serviceCharacteristics.value == 'service') { //this hardcording need to go
                        if (ReplicatorGetServiceManager.parentUniqueStringMap.containsKey(association.linkedServiceId)) {
                            uniqueStringMetaData = ReplicatorGetServiceManager.parentUniqueStringMap.get(association.linkedServiceId);
                            parentFNN = association.linkedServiceId;
                        }
                    }
                }
    
            }
            if(transGroupStructMapMain.get(uniqueStringMetaData.toLowerCase()) != null){ 
            if (transGroupStructMapMain.get(uniqueStringMetaData.toLowerCase()).Product_Family__c == serviceDetailsGroup.productFamily && parentFNN != '') {
                if (ReplicatorGetServiceManager.prodGroupTypeMapping.containsKey(serviceDetailsGroup.productFamily + '_' + transGroupStructMapMain.get(uniqueStringMetaData.toLowerCase()).Label+'_'+parentFNN)) {
                   // prodGroupTypeMapping.put(serviceDetailsGroup.productFamily + '_' + transGroupStructMapMain.get(uniqueStringMetaData.toLowerCase()).Label, subDetails);
                    system.debug('$$$$$$$prodGroupTypeMapping>>Inside' + JSON.serialize(ReplicatorGetServiceManager.prodGroupTypeMapping));
                    ReplicatorGetServiceManager.prodGroupTypeMapping.get(serviceDetailsGroup.productFamily + '_' + transGroupStructMapMain.get(uniqueStringMetaData.toLowerCase()).Label+'_'+parentFNN).get(parentFNN).add(tempService);
        
                }
            }
        }
        }
        system.debug('$$$$$$$prodGroupTypeMapping>>--->Child--->' + JSON.serialize(ReplicatorGetServiceManager.prodGroupTypeMapping));
        return ReplicatorGetServiceManager.prodGroupTypeMapping;
    }

   @AuraEnabled
       public static TransitionDataDTO.serviceDTOMobile getService(ReplicatorGetServiceDTO.servicesDTO serviceDetails) {
           
           TransitionDataDTO.serviceDTOMobile serviceRecord = new TransitionDataDTO.serviceDTOMobile();
           for (ReplicatorGetServiceDTO.serviceCharacteristicDTO sChars: serviceDetails.serviceCharacteristics) {
               if (sChars.name == 'service_status') {
                   serviceRecord.service_status = sChars.value;
               }
               if (sChars.name == 'service_type_code') {
                   serviceRecord.service_type_code = sChars.value;
               }
               if (sChars.name == 'service_type') {
                   serviceRecord.service_type = sChars.value;
               }
               if (sChars.name == 'imsi_number') {
                   serviceRecord.imsi_number = sChars.value;
               }
               if (sChars.name == 'sim_serial_number') {
                   serviceRecord.sim_serial_number = sChars.value;
               }
               if (sChars.name == 'calling_line_identifier') {
                   serviceRecord.calling_line_identifier = sChars.value;
               }
               if (sChars.name == 'plan_name') {
                   serviceRecord.plan_name = sChars.value;
               }
               if (sChars.name == 'contract_term') {
                   serviceRecord.contract_term = sChars.value;
               }
               if (sChars.name == 'international_roaming') {
                   serviceRecord.international_roaming = sChars.value;
               }
               if (sChars.name == 'message_bank') {
                   serviceRecord.message_bank = sChars.value;
               }
               if (sChars.name == 'idd') {
                   serviceRecord.idd = sChars.value;
               }
               if (sChars.name == 'service_association_role') {
                   serviceRecord.service_association_role = sChars.value;   
               }//EDGE-140420- Changes Start
               if (sChars.name == 'association_type') {
                   serviceRecord.association_type = sChars.value;   
               }
               if (sChars.name == 'reserved_ranges') {
                   serviceRecord.Reserved_ranges = sChars.value;   
               }
               if (sChars.name == 'redirection_product') {
                   serviceRecord.Redirection_product  = sChars.value;   
               }
               if (sChars.name == 'silent_line') {
                   serviceRecord.silent_line  = sChars.value;   
               }
               if (sChars.name == 'is_enterprise_trunk') {
                   serviceRecord.is_enterprise_trunk  = sChars.value;   
               }
               if (sChars.name == 'trunk_capacity') {
                   serviceRecord.trunk_capacity  = sChars.value;   
               }
               if (sChars.name == 'tipt_count') {
                   serviceRecord.tipt_count  = sChars.value;   
               }
               if (sChars.name == 'sipc_count') {
                   serviceRecord.sipc_count  = sChars.value;   
               }

                //EDGE-140420- Changes End
   
           }
           //Start of EDGE-208791 by Abhishek(Osaka) to introduce Account block in json file.
           TransitionDataDTO.accountDTO accountDTOData = New TransitionDataDTO.accountDTO();
           accountDTOData.accountNumber = serviceDetails.account.accountNumber;
           accountDTOData.complexBillingIndicator = serviceDetails.account.complexBillingIndicator;
           accountDTOData.creditManagementFlag = serviceDetails.account.creditManagementFlag;
           accountDTOData.serviceWithEtcFlag = serviceDetails.account.serviceWithEtcFlag;
           accountDTOData.dealerCode = serviceDetails.account.dealerCode; 
           accountDTOData.sourceCIDN = serviceDetails.cidn; 
           serviceRecord.accountDetails = accountDTOData;
           //End of EDGE-208791 by Abhishek(Osaka)
           serviceRecord.Service_Id = serviceDetails.fnn;
           serviceRecord.replicatorUpdateDateTime = serviceDetails.replicatorUpdateDateTime;
           list < TransitionDataDTO.serviceExtensionDTO > extensionList = New list < TransitionDataDTO.serviceExtensionDTO > ();
           if (serviceDetails.serviceExtensions != null) {
               for (ReplicatorGetServiceDTO.serviceExtensionsDTO extension: serviceDetails.serviceExtensions) {
                   TransitionDataDTO.serviceExtensionDTO extensionData = New TransitionDataDTO.serviceExtensionDTO();
                   extensionData.serviceExtensionFrom = extension.serviceExtensionFrom;
                   extensionData.serviceExtensionTo = extension.serviceExtensionTo;
                   extensionList.add(extensionData);
               }
               serviceRecord.serviceExtensions = extensionList;
           }
           
           system.debug('#######>>>>>******* serviceRecord: ' + JSON.serialize(serviceRecord));
           return serviceRecord;
       }

     
/*----------------------------------------------------------------------------------------------------------------------
     * @Author   :   Vivek/Ankit
     * @Date     :   08 feb 2021
     * @Desc     :   This method call from ReplicatorGetServiceManager. Here devloped New logic for TIPT-SIPC prduct family(Hybrid) where range and node both will consider
     * @US       :   EDGE-152495
 ------------------------------------------------------------------------------------------------------------------*/
       @AuraEnabled   
       public static Map < String,List < TransitionDataDTO.serviceDTOMobile > >groupingLogic_ByHybrid_New(ReplicatorGetServiceDTO.servicesDTO serviceDetailsGroup) {

        TransitionDataDTO.serviceDTOMobile tempService                      =   new TransitionDataDTO.serviceDTOMobile();
        tempService                                                         =   getService(serviceDetailsGroup);
        list < TransitionDataDTO.serviceDTOMobile > groupServiceRecordList  =   new list < TransitionDataDTO.serviceDTOMobile > ();
        groupServiceRecordList.add(tempService);
        
        Set < String > associationData                                      =   New Set < String > ();
        Map<string,string>eligiblityMap                                     =   new Map<string,string>();
        Boolean groupFlag                                                   =   false;             

        if ( serviceDetailsGroup != null ) {
            for(ReplicatorGetServiceDTO.serviceCharacteristicDTO sChars: serviceDetailsGroup.serviceCharacteristics){
            if (sChars.name == Label.serviceassociationroleNGUC && sChars.value.equalsIgnoreCase(Label.enterpriseNguc)) {
                    // Combination of FNN of enterprise and service wrapper
                if ( serviceDetailsGroup.fnn != null ) {
                    ReplicatorGetServiceManager.prodGroupTypeNewMapping.put(serviceDetailsGroup.fnn,new list<string>());
                } 
                if ( serviceDetailsGroup.cidn != null ) {
                    ReplicatorGetServiceManager.CIDN_String_List.add( serviceDetailsGroup.cidn );// this list is contains of all enterprise level CIDN                        
                }
                ReplicatorGetServiceManager.FNN_String =  serviceDetailsGroup.fnn;
            }
            if (sChars.name == Label.serviceassociationroleNGUC  && sChars.value.equalsIgnoreCase(Label.serviceNguc)) {
                 if ( serviceDetailsGroup.cidn != null ) {
                    ReplicatorGetServiceManager.CIDN_String_List.add( serviceDetailsGroup.cidn );                           
                 }
                for(ReplicatorGetServiceDTO.serviceAssociationDTO sAssChars:serviceDetailsGroup.serviceAssociations ){ 
                    if( sAssChars.linkedServiceRole.equalsIgnoreCase(Label.groupNguc)){
                        // ReplicatorGetServiceManager.groupUniqueStringMap map contains group level fnn and value as service wrapper
                        if(  ReplicatorGetServiceManager.groupUniqueStringMap != null && !ReplicatorGetServiceManager.groupUniqueStringMap.containsKey(sAssChars.linkedServiceId) ){
                            ReplicatorGetServiceManager.groupUniqueStringMap.put(sAssChars.linkedServiceId,new list < TransitionDataDTO.serviceDTOMobile >());
                        }
                            ReplicatorGetServiceManager.groupUniqueStringMap.get(sAssChars.linkedServiceId).add(tempService);   
                    }
                }
            }      
            if (sChars.name == Label.serviceassociationroleNGUC  && sChars.value.equalsIgnoreCase(Label.groupNguc)) {
                groupFlag=true;       
                for(ReplicatorGetServiceDTO.serviceAssociationDTO sAss: serviceDetailsGroup.serviceAssociations){
                    if(sAss.linkedServiceRole.equalsIgnoreCase(Label.enterpriseNguc) && ReplicatorGetServiceManager.prodGroupTypeNewMapping != null && ReplicatorGetServiceManager.prodGroupTypeNewMapping.containsKey(sAss.linkedServiceId)){
                        ReplicatorGetServiceManager.prodGroupTypeNewMapping.get(sAss.linkedServiceId).add(serviceDetailsGroup.fnn);
                    }  
                } 
            }
            if(groupFlag && (sChars.name == 'bw_eligibility_flag' || sChars.name == 'bw_eligibility_reason_code')){
                eligiblityMap.put(sChars.name,sChars.value);
                if (sChars.value.equalsIgnoreCase('eligible')){
                    if ( serviceDetailsGroup.cidn != null ) {
                        ReplicatorGetServiceManager.CIDN_String_List.add( serviceDetailsGroup.cidn );
                    }
                }
            }
            } 
        }      
       
        if(groupFlag && ReplicatorGetServiceManager.groupEligibleMap != null && serviceDetailsGroup != null && serviceDetailsGroup.fnn != null ){
            
            ReplicatorGetServiceManager.groupEligibleMap.put(serviceDetailsGroup.fnn,eligiblityMap);
        }
        return ReplicatorGetServiceManager.groupUniqueStringMap;
    }
 }