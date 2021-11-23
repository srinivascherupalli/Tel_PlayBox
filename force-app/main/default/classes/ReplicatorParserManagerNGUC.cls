// Class to parse replicator response covering all scenarios

public with sharing class ReplicatorParserManagerNGUC {
    // Map of EnterpriseFnn to Group , Group to related Services
    //public static Map< String , Map < String , List < ReplicatorGetServiceDTO.servicesDTO >>> enterpriseToServicesList= new Map < String , Map < String , List < ReplicatorGetServiceDTO.servicesDTO >>> ();
    public static Map< String , Map < String , List < TransitionDataDTO.serviceDTOMobile >>> enterpriseToServicesList= new Map < String , Map < String , List < TransitionDataDTO.serviceDTOMobile >>> ();
    public static Map< String , String> fnnToServiceType        =   new Map <String , String>();
    public static Map< String , String> fnnToServiceTypeG       =   new Map <String , String>();
    public static Map< String , List<String>> fnToAssociation   =   new Map < String , List<String>>();          
    public static Map< String , List<String>> fnToAssociationE  =   new Map < String , List<String>>(); 
    public static Set<String> relatedGroupAssocSet              =   new Set<String>();
    public static Set<String> relatedEnterpriseAssocSet         =   new Set<String>();         
    public static Boolean hasEnterpriseBlock                    =   false;
    public static Boolean hasGroupBlock                         =   false;
    public static Boolean hasServiceBlock                       =   false;
    public static String isOsakaDormant							= 	System.Label.Is_Osaka_Dormant_21_09; //Added flag for dormancy by Jay (Osaka) as a part of EDGE-208790
    
    //Comment Alone Added by Abhishek(Osaka) for readability.
    //Map of Product Family and Hybrid Boolean flag fetched from Transition Group Structure Metadata.
    public static Map <String , Boolean > productFamilyToHybridCheck                            =     new map < String , Boolean >(); 
    
    //Comment Alone Added by Abhishek(Osaka) for readability.
    //Map of Product Family and its related Metadata record from Transition Group Structure Metadata
    public static map < String, Transition_Group_Structure_New__mdt > transGroupStructHybrid    =     new map < String, Transition_Group_Structure_New__mdt> ();//EDGE-152495
    
    // public static map<string,List <TransitionDataDTO.serviceDTOMobile >>groupUniqueStringMap                    =   new map<string,List < TransitionDataDTO.serviceDTOMobile >>();
    // public static Map< String , Map < String , TransitionDataDTO.serviceDTOMobile>> enterpriseToServicesListNEW =   new Map < String , Map < String , TransitionDataDTO.serviceDTOMobile>> ();
    
    public static Map<String,String> groupCidnAssociation = new Map<String,String>();
    // Method to read replicator response and break it to form TranstionJSON [ TransitionDataDTO ]
    public static TransitionDataDTO.SiteDTOMobile transformReplicatorResponseNgUc( ReplicatorGetServiceDTO responseFmReplicator, String basketId, String finCIDN, List<String> selectedCIDN ) {
        
        // Fill map to Check Hybrid
        for ( Transition_Group_Structure_New__mdt transGroupStruct: [SELECT DeveloperName, Label, Node_1__c, Node_2__c, Node_3__c, Product_Family__c, Range_Indicator__c, Hybrid__c FROM Transition_Group_Structure_New__mdt] ) {
            //Comment Alone Added by Abhishek(Osaka) for readability
            //Population of Product Family and its associated Hybrid Value from metadata
            productFamilyToHybridCheck.put( transGroupStruct.Product_Family__c , transGroupStruct.Hybrid__c  ); 
            //Comment Alone Added by Abhishek(Osaka) for readability
            //Population of Product Family and its related Metadata record from metadata.
            transGroupStructHybrid.put(transGroupStruct.Product_Family__c,transGroupStruct);
        }
        
        // First  loop over and get all details of association to identift lone services
        for ( ReplicatorGetServiceDTO.servicesDTO serviceDetails: responseFmReplicator.servicesList ) { 
            if ( productFamilyToHybridCheck != null && productFamilyToHybridCheck.containskey( serviceDetails.productFamily ) &&  productFamilyToHybridCheck.get( serviceDetails.productFamily ) ) { 
                fillServiceAssociations(serviceDetails , serviceDetails.fnn);
            }
        }
        
        // System.debug('1 -- this is against group>' +  fnToAssociation );
        // System.debug('1.1 this is against enterprise-->' +  fnToAssociationE );
        
        List<ReplicatorGetServiceDTO.servicesDTO> sortedServiceList = new List<ReplicatorGetServiceDTO.servicesDTO>();
        // SORTING REQUIRED TO HANDLE AS PER CODE : E - G - S
        
        //EDGE-222176--> Commenting to remove enterprise block from json by Abhishek(Osaka)
        if(isOsakaDormant == 'true'){ //Added flag for dormancy by Jay (Osaka) as a part of EDGE-208790
            for ( ReplicatorGetServiceDTO.servicesDTO serviceDetails: responseFmReplicator.servicesList ) {
                for ( ReplicatorGetServiceDTO.serviceCharacteristicDTO serviceCharacteristics : serviceDetails.serviceCharacteristics ) {
                    if ( serviceCharacteristics.name == 'service_association_role' && serviceCharacteristics.value != null && serviceCharacteristics.value != '' )  {
                        
                        //if ( serviceCharacteristics.value == transGroupStructHybrid.get(serviceDetailsGroup.productFamily).Node_2__c ) {
                        if ( transGroupStructHybrid.containsKey(serviceDetails.productFamily)  && serviceCharacteristics.value.equalsIgnoreCase(transGroupStructHybrid.get(serviceDetails.productFamily).Node_1__c) ) {
                            sortedServiceList.add(serviceDetails);
                        }
                    }
                }       
            }
        }
        
        for ( ReplicatorGetServiceDTO.servicesDTO serviceDetails: responseFmReplicator.servicesList ) {
            for ( ReplicatorGetServiceDTO.serviceCharacteristicDTO serviceCharacteristics : serviceDetails.serviceCharacteristics ) {
                if ( serviceCharacteristics.name == 'service_association_role' && serviceCharacteristics.value != null && serviceCharacteristics.value != '' )  {
                    
                    if ( transGroupStructHybrid.containsKey(serviceDetails.productFamily)  && serviceCharacteristics.value.equalsIgnoreCase(transGroupStructHybrid.get(serviceDetails.productFamily).Node_2__c) ) {
                        sortedServiceList.add(serviceDetails);
                    }
                }
            }       
        }
        
        for ( ReplicatorGetServiceDTO.servicesDTO serviceDetails: responseFmReplicator.servicesList ) {
            for ( ReplicatorGetServiceDTO.serviceCharacteristicDTO serviceCharacteristics : serviceDetails.serviceCharacteristics ) {
                if ( serviceCharacteristics.name == 'service_association_role' && serviceCharacteristics.value != null && serviceCharacteristics.value != '' )  {
                    
                    if ( transGroupStructHybrid.containsKey(serviceDetails.productFamily)  && serviceCharacteristics.value.equalsIgnoreCase(transGroupStructHybrid.get(serviceDetails.productFamily).Node_3__c) ) {
                        sortedServiceList.add(serviceDetails);
                    }
                }
            }       
        }
        
        System.debug( '@ vm  sortedServiceList ---> ' + sortedServiceList );
        
        // loop over all services block [ enterpise , group , services ] returned by replicator
        for ( ReplicatorGetServiceDTO.servicesDTO serviceDetails: sortedServiceList ) {
            if ( productFamilyToHybridCheck != null && productFamilyToHybridCheck.containskey( serviceDetails.productFamily ) &&  productFamilyToHybridCheck.get( serviceDetails.productFamily ) ) { 
                prepareDataByNodes( serviceDetails );
            }
        }
        
        
        if ( enterpriseToServicesList.size() > 0 ) { 
            
            string enterpiseKey = (new list<string>(enterpriseToServicesList.keySet()) )[0];
            // String enterpiseKey = enterpriseToServicesList.keySet().get(0);
            Set<String> groupSet = enterpriseToServicesList.get(enterpiseKey).keySet();
            System.debug( '@ vm  enterpiseKey ---> ' + enterpiseKey );
            System.debug( '@ vm  groupSet ---> ' + groupSet );
            List<String> groupList = new List<String>(groupSet);
            
            ReplicatorGetServiceManager.prodGroupTypeNewMapping.put( enterpiseKey , groupList );
            ReplicatorGetServiceManager.groupUniqueStringMap = new Map < String , List < TransitionDataDTO.serviceDTOMobile >>(enterpriseToServicesList.get(enterpiseKey));  
            
            System.debug( '@ vm  prodGroupTypeNewMapping ---> ' + ReplicatorGetServiceManager.prodGroupTypeNewMapping );
            System.debug( '@ vm  groupUniqueStringMap ---> ' + ReplicatorGetServiceManager.groupUniqueStringMap );
            
            System.debug( '@ vm  Result ---> ' + enterpriseToServicesList );
            
            return getSiteLogicNgUc( responseFmReplicator , enterpiseKey, basketId, finCIDN, selectedCIDN );
        }else{
            return null;
        }
        
        
    }
    
    // Method to take care of all Mapping required to create TransitionNGUC JSON.
    public static void prepareDataByNodes( ReplicatorGetServiceDTO.servicesDTO serviceDetailBlock ) {
        
        
        TransitionDataDTO.serviceDTOMobile tempService                      =   new TransitionDataDTO.serviceDTOMobile();
        tempService                                                         =   ReplicatorGetServiceManagerHandler.getService(serviceDetailBlock);
        list < TransitionDataDTO.serviceDTOMobile > groupServiceRecordList  =   new list < TransitionDataDTO.serviceDTOMobile > ();
        groupServiceRecordList.add(tempService);
        
        for ( ReplicatorGetServiceDTO.serviceCharacteristicDTO serviceCharacteristics : serviceDetailBlock.serviceCharacteristics ) {
            if ( serviceCharacteristics.name == 'service_association_role' && serviceCharacteristics.value != null && serviceCharacteristics.value != '' )  {
                
                //EDGE-222716 --> Comment Enterprise block by Abhishek(Osaka)
                if ( transGroupStructHybrid.containsKey(serviceDetailBlock.productFamily)  && serviceCharacteristics.value.equalsIgnoreCase(transGroupStructHybrid.get(serviceDetailBlock.productFamily).Node_1__c) ) {
                    hasEnterpriseBlock = true;
                    ReplicatorGetServiceManager.FNN_String = serviceDetailBlock.fnn ;
                    if ( serviceDetailBlock.fnn != null && !enterpriseToServicesList.containsKey( serviceDetailBlock.fnn ) ) {
                        enterpriseToServicesList.put ( serviceDetailBlock.fnn , new Map < String , List < TransitionDataDTO.serviceDTOMobile >>() );
                    }  
                }else if ( transGroupStructHybrid.containsKey(serviceDetailBlock.productFamily)  && serviceCharacteristics.value.equalsIgnoreCase(transGroupStructHybrid.get(serviceDetailBlock.productFamily).Node_2__c) ) {
                    
                    hasGroupBlock = true;
                    boolean val1 = false;
                    if ( fnToAssociationE.size() > 0 ){
                        val1 = true;
                    }
                    handleGroupNode( serviceDetailBlock.serviceAssociations , serviceDetailBlock.fnn , val1 , tempService);
                }else if ( transGroupStructHybrid.containsKey(serviceDetailBlock.productFamily)  && serviceCharacteristics.value.equalsIgnoreCase(transGroupStructHybrid.get(serviceDetailBlock.productFamily).Node_3__c) ) {
                    
                    hasServiceBlock = true;
                    boolean val2 = false;
                    boolean val3 = false;
                    //EDGE-222716 --> Comment Enterprise block by Abhishek(Osaka)
                    if(isOsakaDormant == 'true'){ //Added flag for dormancy by Jay (Osaka) as a part of EDGE-208790
                        if ( fnToAssociationE.size() > 0 ){
                            for ( String ky : fnToAssociationE.keySet()){
                                if (fnToAssociationE.get(ky).contains(serviceDetailBlock.fnn)){
                                    val2 = true; // Enterprise
                                }
                            }
                            
                        }
                    }
                    if ( fnToAssociation.size() > 0 ) {
                        for ( String ky : fnToAssociation.keySet()){
                            if (fnToAssociation.get(ky).contains(serviceDetailBlock.fnn)){
                                val3 = true; // Group
                            }
                        }
                        
                    }
                    System.debug('val3 group --> ' + val3 );
                    System.debug('val2 group --> ' + val2 );
                    
                    handleServiceNode( serviceDetailBlock.serviceAssociations , serviceDetailBlock.fnn , val3 , val2 , tempService);
                }
                
                if ( !fnnToServiceType.containsKey( serviceDetailBlock.fnn ) ) {
                    //fnnToServiceType.put( serviceDetailBlock.fnn , serviceCharacteristics.value );
                }
                
            }
        }
        
        
        
    }
    
    
    public static void handleGroupNode( List<ReplicatorGetServiceDTO.serviceAssociationDTO> serviceAssociationList , String blockFnn , Boolean hasEnterpriseBlock ,  TransitionDataDTO.serviceDTOMobile tempService ) {
        // System.debug('hasEnterpriseBlock --> ' + hasEnterpriseBlock);
        //EDGE-222716 --> Comment Enterprise block by Abhishek(Osaka)
        if ( !hasEnterpriseBlock ) {
            if (  !enterpriseToServicesList.containsKey( 'dummyenterprise' ) ) {
                enterpriseToServicesList.put ( 'dummyenterprise' , new Map < String , List < TransitionDataDTO.serviceDTOMobile >>() );
                if ( serviceAssociationList.size() == 0 ) {
                    enterpriseToServicesList.get( 'dummyenterprise' ).put( blockFnn , new List< TransitionDataDTO.serviceDTOMobile >() );
                }
                for ( ReplicatorGetServiceDTO.serviceAssociationDTO serviceAssociation : serviceAssociationList ) {
                    if ( enterpriseToServicesList.containsKey( 'dummyenterprise' ) && !enterpriseToServicesList.get( 'dummyenterprise' ).containsKey( blockFnn ) ) {
                        enterpriseToServicesList.get( 'dummyenterprise' ).put( blockFnn , new List< TransitionDataDTO.serviceDTOMobile >() );
                    }
                }
            }else{
                for ( ReplicatorGetServiceDTO.serviceAssociationDTO serviceAssociation : serviceAssociationList ) {
                    if ( enterpriseToServicesList.containsKey( 'dummyenterprise' ) && !enterpriseToServicesList.get( 'dummyenterprise' ).containsKey( blockFnn ) ) {
                        enterpriseToServicesList.get( 'dummyenterprise' ).put( blockFnn , new List< TransitionDataDTO.serviceDTOMobile >() );
                    }
                }
            }
        }
        else{
            for ( ReplicatorGetServiceDTO.serviceAssociationDTO serviceAssociation : serviceAssociationList ) {
                if ( serviceAssociation.linkedServiceId != null && serviceAssociation.linkedServiceId != '' ) {
                    if ( enterpriseToServicesList.containsKey( serviceAssociation.linkedServiceId ) && !enterpriseToServicesList.get( serviceAssociation.linkedServiceId ).containsKey( blockFnn ) ) {
                        enterpriseToServicesList.get( serviceAssociation.linkedServiceId ).put( blockFnn , new List< TransitionDataDTO.serviceDTOMobile >() );
                    }
                }
            }
        }
         System.debug('enterpriseToServicesList --> ' + enterpriseToServicesList);        
        
    }
    
    public static void handleServiceNode( List<ReplicatorGetServiceDTO.serviceAssociationDTO> serviceAssociationList , String blockFnn , Boolean hasGroupBlock , Boolean hasEnterpriseBlock ,  TransitionDataDTO.serviceDTOMobile tempService) {
        System.debug('hasEnterpriseBlock --> ' + hasEnterpriseBlock);
        System.debug('hasGroupBlock --> ' + hasGroupBlock);        
        
        
        
        
        String enterpiseId = '';
        Boolean hasBothNotAvailable = false;
        if ( !hasEnterpriseBlock && !hasGroupBlock ) {
            enterpiseId =  'dummyenterprise';
            //hasBothNotAvailable = true;
            System.debug('Inside both not available');        
            
            //EDGE-222716 --> Comment Enterprise block by Abhishek(Osaka)
            if ( !enterpriseToServicesList.containsKey( enterpiseId ) ) {
                enterpriseToServicesList.put ( 'dummyenterprise' , new Map < String , List < TransitionDataDTO.serviceDTOMobile >>() );
            }
            
            if ( enterpriseToServicesList.containsKey( enterpiseId ) && !enterpriseToServicesList.get( enterpiseId ).containsKey( 'dummygroup' ) ) {
                enterpriseToServicesList.get( enterpiseId ).put( 'dummygroup' , new List< TransitionDataDTO.serviceDTOMobile >() );
            }
            
            if ( enterpriseToServicesList.containsKey( enterpiseId ) && enterpriseToServicesList.get( enterpiseId ).containsKey( 'dummygroup' ) ) {
                enterpriseToServicesList.get( enterpiseId ).get( 'dummygroup' ).add( tempService ) ;
            }
        }
        
        //EDGE-222716 --> Comment Enterprise block by Abhishek(Osaka)
        if ( !hasEnterpriseBlock ) {
            enterpiseId =  'dummyenterprise';
        }
        if ( !hasGroupBlock ) {
            
            System.debug('Inside group not available');        
            
            for ( ReplicatorGetServiceDTO.serviceAssociationDTO serviceAssociation : serviceAssociationList ) {
                
                if ( serviceAssociation.linkedServiceId != null && serviceAssociation.linkedServiceId != ''  && serviceAssociation.linkedServiceRole == 'enterprise' ) {
                    enterpiseId =  serviceAssociation.linkedServiceId ;
                    if ( enterpriseToServicesList.containsKey( enterpiseId ) && !enterpriseToServicesList.get( enterpiseId ).containsKey( 'dummygroup' ) ) {
                        enterpriseToServicesList.get( enterpiseId ).put( 'dummygroup' , new List< TransitionDataDTO.serviceDTOMobile >() );
                    }
                }
            }
            // System.debug('enterpiseId 1111111--> ' + enterpiseId);
            if ( enterpriseToServicesList.containsKey( enterpiseId ) && enterpriseToServicesList.get( enterpiseId ).containsKey( 'dummygroup' ) ) {
                enterpriseToServicesList.get( enterpiseId ).get( 'dummygroup' ).add( tempService ) ;
            }
            
            
        }
        else{
            System.debug('Inside group  available');   
            if ( hasEnterpriseBlock ) {
                for ( ReplicatorGetServiceDTO.serviceAssociationDTO serviceAssociation : serviceAssociationList ) {
                    if ( serviceAssociation.linkedServiceId != null && serviceAssociation.linkedServiceId != ''  && serviceAssociation.linkedServiceRole == 'enterprise' ) {
                        enterpiseId =  serviceAssociation.linkedServiceId ;
                    }
                }
            }
            for ( ReplicatorGetServiceDTO.serviceAssociationDTO serviceAssociation : serviceAssociationList ) {
                
                // System.debug('enterpiseId --> ' + enterpiseId);
                if ( serviceAssociation.linkedServiceId != null && serviceAssociation.linkedServiceId != '' && serviceAssociation.linkedServiceRole == 'group' ) {
                    //  System.debug('attaching services --> ' + serviceAssociation.linkedServiceId);
                    if ( enterpriseToServicesList.containsKey( enterpiseId ) && enterpriseToServicesList.get( enterpiseId ).containsKey( serviceAssociation.linkedServiceId ) ) {
                        // System.debug('attaching services 111 --> ' + serviceAssociation.linkedServiceId);
                        enterpriseToServicesList.get( enterpiseId ).get( serviceAssociation.linkedServiceId ).add( tempService ) ;
                    }
                }
            }
        }
        
         System.debug('enterpriseToServicesList --> ' + enterpriseToServicesList);        
        
        
    }
    
    // Method to fill serviceAssociation
    public static void fillServiceAssociations( ReplicatorGetServiceDTO.servicesDTO serviceDetails , String blockFnn) {
        Map<string,string>eligiblityMap    =     new Map<string,string>();
        
        if ( !fnToAssociation.containsKey( serviceDetails.fnn )) {
            List<String> associatedServices = new List<String>();
            Boolean groupFlag = false;
            for ( ReplicatorGetServiceDTO.serviceCharacteristicDTO serviceCharacteristics : serviceDetails.serviceCharacteristics ) {
                if ( serviceCharacteristics.name == 'service_association_role' && serviceCharacteristics.value != null && serviceCharacteristics.value != '' )  {
                    
                    //EDGE-222176--> Commenting Enterprise block by Abhishek(Osaka)
                    if(isOsakaDormant == 'true'){ //Added flag for dormancy by Jay (Osaka) as a part of EDGE-208790
                        if ( transGroupStructHybrid.containsKey(serviceDetails.productFamily)  && serviceCharacteristics.value.equalsIgnoreCase(transGroupStructHybrid.get(serviceDetails.productFamily).Node_1__c) ) {
                            
                            if ( !fnnToServiceType.containsKey( blockFnn ) ) {
                                fnnToServiceType.put( serviceDetails.fnn , serviceCharacteristics.value );
                            } 
                        }
                    }
                    if ( transGroupStructHybrid.containsKey(serviceDetails.productFamily)  && serviceCharacteristics.value.equalsIgnoreCase(transGroupStructHybrid.get(serviceDetails.productFamily).Node_2__c) ) {
                        
                        groupFlag = true;
                        
                        if ( !fnnToServiceTypeG.containsKey( blockFnn ) ) {
                            fnnToServiceTypeG.put( serviceDetails.fnn , serviceCharacteristics.value );
                        } 
                    }
                }
                
                if( groupFlag && serviceCharacteristics.name == 'bw_eligibility_flag' || serviceCharacteristics.name == 'bw_eligibility_reason_code' || serviceCharacteristics.name == 'eligibility_flag' || serviceCharacteristics.name == 'eligibility_reason' ) {
                    eligiblityMap.put(serviceCharacteristics.name,serviceCharacteristics.value);
                }
            }
            // System.debug('2-> ' + fnnToServiceType);
            // System.debug('2.1-> ' + fnnToServiceTypeG);
            for ( ReplicatorGetServiceDTO.serviceAssociationDTO serviceAssociation : serviceDetails.serviceAssociations ) {
                if ( serviceAssociation.linkedServiceId != null && serviceAssociation.linkedServiceId != '' ) {
                    associatedServices.add(serviceAssociation.linkedServiceId);
                }
            }
            // System.debug('3-> ' + associatedServices);
            if ( fnnToServiceTypeG.containsKey( serviceDetails.fnn ) &&  fnnToServiceTypeG.get( serviceDetails.fnn ) != 'enterprise' ){
                fnToAssociation.put( serviceDetails.fnn , associatedServices );
                //relatedGroupAssocSet.add(associatedServices);  
            }
            //EDGE-222176--> Commenting Enterprise block by Abhishek(Osaka)
            if(isOsakaDormant == 'true'){ //Added flag for dormancy by Jay (Osaka) as a part of EDGE-208790
                if ( fnnToServiceType.containsKey( serviceDetails.fnn ) &&  fnnToServiceType.get( serviceDetails.fnn ) == 'enterprise' ){
                    fnToAssociationE.put( serviceDetails.fnn , associatedServices );  
                }
            }
            System.debug('groupFlag --> ' + groupFlag);
            if(groupFlag && serviceDetails != null && serviceDetails.fnn != null ){
                System.debug('Inside eleigibleMap--> ' + eligiblityMap );
                ReplicatorGetServiceManager.groupEligibleMap.put(serviceDetails.fnn,eligiblityMap);
            }
            
            // System.debug('5-> ' + fnToAssociation);
            // System.debug('6-> ' + fnToAssociationE);
            
        }
    }
    
    
    @AuraEnabled
    public static TransitionDataDTO.SiteDTOMobile getSiteLogicNgUc(ReplicatorGetServiceDTO responseFmReplicator , String enterpriseId, String basketId, String finCIDN, List<String> selectedCIDN ) {
        //Start of EDGE-222176 by Abhishek(Osaka) TIPT-SIPC eligibility for GH based on Target/Selected CIDN
        Map<String,Set<String>> groupIdCidnMap = new Map<String,Set<String>>();
        Map < string, map < string, string >> groupEligibilityMap = new Map < string, map < string, string >>();
        //EDGE-222176
        if(isOsakaDormant ==  'false'){
            groupIdCidnMap = groupAsscoiatedServices(responseFmReplicator);
            System.debug('Group ID and CIDN Association::' +groupIdCidnMap);
            groupEligibilityMap = groupEligibility(groupIdCidnMap,finCIDN,selectedCIDN);
            System.debug('Group ID and Eligibility Association::' +groupEligibilityMap);
        }
        //End of EDGE-222176 by Abhishek(Osaka) TIPT-SIPC eligibility for GH based on Target/Selected CIDN
        
        TransitionDataDTO.groupDTOMobile groupDTOMobileList                 =        new TransitionDataDTO.groupDTOMobile();
        groupDTOMobileList.service                                          =        new List < TransitionDataDTO.serviceDTOMobile > ();
        TransitionDataDTO.serviceListDTOMobile serviceListDTOMobileList     =        new TransitionDataDTO.serviceListDTOMobile();
        serviceListDTOMobileList.groupType                                  =        new List < TransitionDataDTO.groupDTOMobile > ();
        
        system.debug('$$$$$$$$$$$$>>>>>ReplicatorGetServiceManager.prodGroupTypeNewMapping.values() : ' + ReplicatorGetServiceManager.prodGroupTypeNewMapping.values());
        System.debug('ReplicatorGetServiceManager.groupEligibleMap --> ' + ReplicatorGetServiceManager.groupEligibleMap);
        
        for (   String groupId   : ReplicatorGetServiceManager.prodGroupTypeNewMapping.get(enterpriseId) ) {
            TransitionDataDTO.groupDTOMobile serviceMobileList      =   new TransitionDataDTO.groupDTOMobile();
            serviceMobileList.service                               =   new List < TransitionDataDTO.serviceDTOMobile > ();
            serviceMobileList.groupId                               =   groupId != 'dummygroup' ? groupId : null ;
            serviceMobileList.service                               =   ReplicatorGetServiceManager.groupUniqueStringMap.get(groupId); 
            
            if ( ReplicatorGetServiceManager.groupEligibleMap.containskey(groupId) && ReplicatorGetServiceManager.groupEligibleMap.get(groupId).containskey('bw_eligibility_flag')){
                serviceMobileList.EligibilityStatus                 =   ReplicatorGetServiceManager.groupEligibleMap.get(groupId).get('bw_eligibility_flag');
            }
            //Existing eligibility condition adding dormancy flag for EDGE-222176
            else if ( ReplicatorGetServiceManager.groupEligibleMap.containskey(groupId) && ReplicatorGetServiceManager.groupEligibleMap.get(groupId).containskey('eligibility_flag') && isOsakaDormant ==  'true'){
                serviceMobileList.EligibilityStatus                 =   ReplicatorGetServiceManager.groupEligibleMap.get(groupId).get('eligibility_flag');
            }
            //EDGE-222176: Added eligibility check for tipt-sipc based on sourceCidn by Abhishek(Osaka)
            else if ( groupEligibilityMap.containskey(groupId) && groupEligibilityMap.get(groupId).containskey('eligibility_flag')){
                serviceMobileList.EligibilityStatus                 =   groupEligibilityMap.get(groupId).get('eligibility_flag');
            }
            
            if ( ReplicatorGetServiceManager.groupEligibleMap.containskey(groupId) && ReplicatorGetServiceManager.groupEligibleMap.get(groupId).containskey('bw_eligibility_reason_code')){
                serviceMobileList.EligibilityReason                 =   ReplicatorGetServiceManager.groupEligibleMap.get(groupId).get('bw_eligibility_reason_code');
            }
            //Existing condition adding dormancy flag for EDGE-222176
            else if ( ReplicatorGetServiceManager.groupEligibleMap.containskey(groupId) && ReplicatorGetServiceManager.groupEligibleMap.get(groupId).containskey('eligibility_reason') && isOsakaDormant ==  'true'){
                serviceMobileList.EligibilityReason                 =   ReplicatorGetServiceManager.groupEligibleMap.get(groupId).get('eligibility_reason');
            }
            //EDGE-222176: Added eligibility check for tipt-sipc based on sourceCidn by Abhishek(Osaka)
            else if ( groupEligibilityMap.containskey(groupId) && groupEligibilityMap.get(groupId).containskey('eligibility_reason') ){
                serviceMobileList.EligibilityReason                 =   groupEligibilityMap.get(groupId).get('eligibility_reason');
            }
            
            //serviceMobileList.EligibilityStatus                     =   ReplicatorGetServiceManager.groupEligibleMap.containskey(groupId)?ReplicatorGetServiceManager.groupEligibleMap.get(groupId).get('bw_eligibility_flag'):null;
            //serviceMobileList.EligibilityReason                     =   ReplicatorGetServiceManager.groupEligibleMap.containskey(groupId)?ReplicatorGetServiceManager.groupEligibleMap.get(groupId).get('bw_eligibility_reason_code'):null; 
            serviceListDTOMobileList.groupType.add(serviceMobileList);
            
            System.debug('serviceMobileList.EligibilityStatus --> ' + serviceMobileList.EligibilityStatus);
            System.debug('ReplicatorGetServiceManager.groupEligibleMap.containskey(groupId) --> ' + ReplicatorGetServiceManager.groupEligibleMap.containskey(groupId));
            
        }
        
        system.debug('$$$$$$$$$$$$>>>>>groupDTOMobile : ' + JSON.serialize(serviceListDTOMobileList));
        system.debug('$$$$$$$$$$$$>>>>>groupDTOMobile : ' + JSON.serialize(groupDTOMobileList));
        
        TransitionDataDTO.SiteDTOMobile siteListDTOList;
        for ( ReplicatorGetServiceDTO.servicesDTO serviceDetails: responseFmReplicator.servicesList ) {
            if ( enterpriseId ==  serviceDetails.fnn || enterpriseId == 'dummyenterprise') {
                for (ReplicatorGetServiceDTO.serviceCharacteristicDTO sChars: serviceDetails.serviceCharacteristics) {
                    if (sChars.name == 'service_type') {
                        serviceListDTOMobileList.Service_Type = sChars.value;
                    }            
                }
                //    serviceListDTOMobileList.Service_Type = serviceDetails.fnn; // to be changed
                siteListDTOList = new TransitionDataDTO.SiteDTOMobile();
                siteListDTOList.serviceList = new List < TransitionDataDTO.serviceListDTOMobile > ();
                // 05/20/2021 Fix @vm
                if (serviceDetails.site.siteType.equalsIgnoreCase('adbor_id')) {
                    siteListDTOList.ADBOR_Id = serviceDetails.site.siteId;
                }
                siteListDTOList.linkedSiteId = serviceDetails.site.linkedSiteId;
                siteListDTOList.serviceList.add(serviceListDTOMobileList);
            }
        }
        system.debug('$$$$$$$$$$$$>>>>>siteListDTOList : ' + JSON.serialize(siteListDTOList));
        return siteListDTOList;
    }
    //EDGE-151827 Prepare transtion UI table grouping for TIPT-SIPC
    //EDGE-218343 : Added additional parameter Map<String, String> cidnAbnMap to capture ABN by Pradeep(Osaka).
    public static List<ReplicatorGetServiceManager.NgUCTableWrapper> preapreNGUCTableWrapper(TransitionDataDTO.productListDTO tNgUcDataProduct,TransitionDataDTO.groupDTOMobile tNgUcDataGroupType,boolean isResponseExist,Map<String, String> cidnAbnMap){
        
        ReplicatorGetServiceManager.NgUCTableWrapper ngUCTableWrapperGroup = new ReplicatorGetServiceManager.NgUCTableWrapper();
        Boolean parentCheckValue = false;
        ngUCTableWrapperGroup.Product_Type = tNgUcDataProduct.Product_Type;
        List <ReplicatorGetServiceManager.NgUCTableWrapper> ngUCTableWrapperClassList = new List <ReplicatorGetServiceManager.NgUCTableWrapper>();   
        //Added as part of EDGE-204581
        if(tNgUcDataGroupType.service != null && tNgUcDataGroupType.service.size()>0){
            ngUCTableWrapperGroup.Id = tNgUcDataGroupType.groupId+'_PFamily';
        }
        else{
            ngUCTableWrapperGroup.Id = tNgUcDataGroupType.groupId+'_Invalid';
        }
        //EDGE-204581 ends
        ngUCTableWrapperGroup.FNN_Number = tNgUcDataGroupType.groupId;
        if (isResponseExist == true){
            parentCheckValue = tNgUcDataGroupType.checkValue;
        }
        ngUCTableWrapperGroup.checkValue = parentCheckValue;
        ngUCTableWrapperGroup.Association_Type = 'Group';
        if(tNgUcDataGroupType.EligibilityStatus != null && tNgUcDataGroupType.EligibilityStatus.equalsIgnoreCase('Yes')){
            ngUCTableWrapperGroup.EligibilityStatus = 'Eligible';    
        }
        else if(tNgUcDataGroupType.EligibilityStatus != null && tNgUcDataGroupType.EligibilityStatus.equalsIgnoreCase('No')){
            ngUCTableWrapperGroup.EligibilityStatus = 'Not Eligible';    
        }
        else{
            ngUCTableWrapperGroup.EligibilityStatus = tNgUcDataGroupType.EligibilityStatus;
        }
        ngUCTableWrapperGroup.eligibilityReason = tNgUcDataGroupType.EligibilityReason;
        ngUCTableWrapperClassList.add(ngUCTableWrapperGroup); 
        String extensionRangeString = '';
        String extensionTypeString = '';
        if(tNgUcDataGroupType.service != null){
            for (TransitionDataDTO.serviceDTOMobile tNgUcDataService: tNgUcDataGroupType.service) {  
                for (TransitionDataDTO.serviceExtensionDTO extensionList: tNgUcDataService.serviceExtensions) {
                    if(extensionList.serviceExtensionFrom == extensionList.serviceExtensionTo){
                        extensionRangeString =  extensionList.serviceExtensionFrom;
                        extensionTypeString  =  'Single';
                    } 
                    else{
                        extensionRangeString = extensionList.serviceExtensionFrom + ' - ' + extensionList.serviceExtensionTo;
                        extensionTypeString  =  'Range';
                    }
                    
                    
                    ReplicatorGetServiceManager.NgUCTableWrapper serviceWrapperObj = new ReplicatorGetServiceManager.NgUCTableWrapper();
                    if(tNgUcDataGroupType.EligibilityStatus != null && tNgUcDataGroupType.EligibilityStatus.equalsIgnoreCase('Yes')){
                        serviceWrapperObj.EligibilityStatus = 'Eligible';    
                    }
                    else if(tNgUcDataGroupType.EligibilityStatus != null && tNgUcDataGroupType.EligibilityStatus.equalsIgnoreCase('No')){
                        serviceWrapperObj.EligibilityStatus = 'Not Eligible';    
                    }
                    else{
                        serviceWrapperObj.EligibilityStatus = tNgUcDataGroupType.EligibilityStatus;
                    }
                    serviceWrapperObj.EligibilityReason = tNgUcDataGroupType.EligibilityReason;
                    serviceWrapperObj.checkValue = parentCheckValue;
                    serviceWrapperObj.Product_Type = '';
                    serviceWrapperObj.Id = tNgUcDataGroupType.groupId+' '+extensionList.serviceExtensionTo;
                    serviceWrapperObj.FNN_Number = extensionRangeString;
                    serviceWrapperObj.Association_Type = extensionTypeString;
                    //Start of EDGE-218343 by Pradeep Mudenur(Osaka) to persist CIDN, ABN and BAN.
                    if(tNgUcDataService.accountDetails != NULL){
                       ngUCTableWrapperGroup.source_CIDN=tNgUcDataService.accountDetails.sourceCIDN;
                       ngUCTableWrapperGroup.ABN=cidnAbnMap.get(ngUCTableWrapperGroup.source_CIDN);
                       ngUCTableWrapperGroup.BAN=tNgUcDataService.accountDetails.accountNumber;
                     }
                    //End of EDGE-218343
                    ngUCTableWrapperClassList.add(serviceWrapperObj);
                }
            }
        }
        return ngUCTableWrapperClassList;
    }
    //EDGE-151827 ends
 
/***********************************************************************************************    
*Method Name : groupAsscoiatedServices

*Developer : Abhishek (Osaka)

*Story Number : EDGE-222176

*Description : This method returns a Map of Group fnn and List of cidn to which its services belong
************************************************************************************************/

    public static Map<String,Set<String>> groupAsscoiatedServices(ReplicatorGetServiceDTO responseFmReplicator){
        Map<String,Set<String>> mapOfCidnServices = new Map<String,Set<String>>();
        
        for ( ReplicatorGetServiceDTO.servicesDTO serviceDetails: responseFmReplicator.servicesList ) {
            for ( ReplicatorGetServiceDTO.serviceCharacteristicDTO serviceCharacteristics : serviceDetails.serviceCharacteristics ) {
                if ( serviceCharacteristics.name == 'service_association_role' && serviceCharacteristics.value.equalsIgnoreCase('group') )  {
                    //Map of Group Fnn and its associated CIDN.
                    groupCidnAssociation.put(serviceDetails.fnn,serviceDetails.cidn);
                    for ( ReplicatorGetServiceDTO.serviceAssociationDTO serviceAssociation : serviceDetails.serviceAssociations ) {
                        if ( serviceAssociation.linkedServiceId != null && serviceAssociation.linkedServiceId != '' && 
                            serviceAssociation.linkedServiceCidn != null && serviceAssociation.linkedServiceCidn != ''){
                                Set<String> serviceCidnList = new Set<String>();
                                if(serviceAssociation.linkedServiceRole.equalsIgnoreCase('service')) {
                                    //Map of Group fnn and list of cidn associated to each of groups service. 
                                    serviceCidnList.add(serviceAssociation.linkedServiceCidn);
                                    mapOfCidnServices.put(serviceDetails.fnn,serviceCidnList);
                                }
                            }
                    }
                }       
            }
            System.debug('Map of Group and its associated CIDN' +mapOfCidnServices);
        }
                    return mapOfCidnServices;
    }
    
/***********************************************************************************************    
*Method Name : groupEligibility

*Developer : Abhishek (Osaka)

*Story Number : EDGE-222176

*Description : This method returns a Map to determine eligibility of GH based on its associated GKs.
************************************************************************************************/    
    public static Map < string, map < string, string >> groupEligibility(Map<String,Set<String>> groupIdCidnMap,String finCIDN, List<String> selectedCIDN){
        Set<String> cidnSet = new Set<String>(selectedCIDN);
        cidnSet.add(finCIDN);
        System.debug('Selected CIDN Set:::'+cidnSet);
        Map < string, map < string, string >> groupEligibilityMap = new map < string, map < string, string >>();
        
        //Iterating over map of Group fnn and list of cidn associated to each of its services.
        for(String mapKey : groupIdCidnMap.keySet()){
            Set<String> groupCidn = new Set<String>();
            groupCidn = groupIdCidnMap.get(mapKey);
            System.debug('Group CIDN Set:::'+groupCidn);
            Map <String,String> eligibilityMap = new Map <String,String>();
            //Checking if Group head belongs to Target/Selected Source CIDN.
            if(cidnSet.contains(groupCidnAssociation.get(mapKey))){
                //Checking if GKs belong to Target/Selected Source CIDN.
                if(!cidnSet.containsAll(groupCidn)){
                    eligibilityMap.put('eligibility_flag','No');
                    eligibilityMap.put('eligibility_reason','Linked CIDN does not belongs to CIDN Hierarchy.');
                    groupEligibilityMap.put(mapKey,eligibilityMap); 
                }
                else{
                    eligibilityMap.put('eligibility_flag','Yes');
                    eligibilityMap.put('eligibility_reason','');
                    groupEligibilityMap.put(mapKey,eligibilityMap); 
                    
                }
            }
            else{
                eligibilityMap.put('eligibility_flag','No');
                eligibilityMap.put('eligibility_reason','Linked CIDN does not belongs to CIDN Hierarchy.');
                groupEligibilityMap.put(mapKey,eligibilityMap); 
            }
            
        }
        return groupEligibilityMap;
    }
}