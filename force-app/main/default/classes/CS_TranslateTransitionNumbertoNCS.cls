/*
===============================================================================================================================
Class : CS_TranslateTransitionNumbertoNCS
Developer Name : Shubhi
Test Class : CS_TranslateTransitionNumbertoNCSTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1.          Shubhi              Aug/8/2019      Edge-106748 Transition Number ranges showing in the checkpoint screen are not 
                                                reflecting in the enrichment number reservation screen for legacy site
2.          Pawan               Dec/27/2019     EDGE-127666 : Changed for Cyclomatic complexity                             
===============================================================================================================================
*/
public with sharing class CS_TranslateTransitionNumbertoNCS {
    
    @future
    public static void TranslateTransistionNumbertoNCS(String basktId){
        FINAL String ipSitePDSpec = 'DMCAT_ProductOffering_000304';
        FINAL String ucePDSpec = 'DMCAT_ProductOffering_000323';
        FINAL String numberNCS = 'NumberManagementv1';
        
        Integer numberQty = 0;
        List<String> syncNumberList = new List<String>();// List to be used to sync the numbers with numbers already present in the NCS       

        //EDGE-127666 : Created seperate method getLegacyServices to reduce Cyclomatic complexity
        List<Attachment> legacyServices = getLegacyServices(ipSitePDSpec, basktId);
        
        System.debug('Attachment::'+legacyServices);
        System.debug('AttachmentSize::'+legacyServices.size());
        
        map <Id, cscfga__Product_Configuration__c> bsktConfigsMap = New Map<Id, cscfga__Product_Configuration__c>();
        map <String, cscfga__Product_Configuration__c> ADBorIDbsktConfigsMap = New Map<String, cscfga__Product_Configuration__c>();
        //find UC Enterprise configuration within the basket
        List<cscfga__Product_Configuration__c> bsktConfigs = [SELECT Id, Name, cscfga__Product_Basket__r.csbb__Account__c, cscfga__product_definition__r.product_Specification__c, cscfga__Product_Basket__c, Quantity_Product_Configuration__c, csordtelcoa__Replaced_Product_Configuration__c 
                                                              FROM cscfga__Product_Configuration__c
                                                              WHERE cscfga__product_definition__r.product_Specification__c = :ipSitePDSpec
                                                              AND cscfga__Product_Basket__c = :basktId AND TYPE__c != 'Cancel' ];
        
        System.debug('bsktConfigs:'+bsktConfigs);
        for(cscfga__Product_Configuration__c pConfig : bsktConfigs)
        {
            bsktConfigsMap.put(pConfig.Id, pConfig);
        }
        system.debug('++++>'+bsktConfigsMap.keyset());
        
        //EDGE-127666 : Created seperate method getAdboreIdsForConfigs to reduce Cyclomatic complexity
        ADBorIDbsktConfigsMap = getAdboreIdsForConfigs(bsktConfigs, bsktConfigsMap);
        
        //Read the attachment find numbers and ranges
        List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2> rplServiceList = new List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2>();
        //EDGE-127666 : Created seperate method getRplServiceList to reduce Cyclomatic complexity
        rplServiceList = getRplServiceList(legacyServices);
        System.debug('rplServiceList::'+rplServiceList);
        
        map <String, List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2>> rplServiceMap = New Map<String, List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2>>();
        //EDGE-127666 : Created seperate method getrplServiceMap to reduce Cyclomatic complexity
        rplServiceMap = getrplServiceMap(rplServiceList, ADBorIDbsktConfigsMap);
        
        if(rplServiceList.size() > 0 && bsktConfigs.size() > 0){
            //update the UCE NCE with numbers
            //find the schema name
            List<csoe__Non_Commercial_Schema__c> ncs = [SELECT id, Name from csoe__Non_Commercial_Schema__c
                                                        WHERE Name = :numberNCS
                                                       ];
            system.debug('###----Before ForAdbOrId--->###');
            for (String key : ADBorIDbsktConfigsMap.keySet()) {
                if(rplServiceMap.containsKey(key)){
                    system.debug('###--------AdbOrId--->'+key);
                    //generate NCS payload with replicator numbers
                    //fetch all products
                    List<ReplicatorGetServiceDataObject_V2.productListDTO> siteLegProducts = new List<ReplicatorGetServiceDataObject_V2.productListDTO>();
                    //  for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 rpls : rplServiceList){
                    for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 rpls : rplServiceMap.get(key)){
                        if(rpls.productList != null){ siteLegProducts.addAll(rpls.productList);}
                        system.debug('###--------AdbOrId  rpls--->'+rpls);
                    }
                    
                    //if products is selected then select all services
                    //as of B2B3 only product level selection is allowed once this changes more logic required here
                    List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> selectedLegServices = new List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>();
                    for(ReplicatorGetServiceDataObject_V2.productListDTO prodDTO : siteLegProducts){
                        if(prodDTO.checkValue == true){
                            selectedLegServices.addAll(getSelectLegacyServices(prodDTO));
                        } 
                    }
                    //for every services check the extensions
                    List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> servicesWithSingleNmbr = new List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>();
                    List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> servicesWithRanges = new List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>();
                    for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 legacyService : selectedLegServices){
                        if(legacyService.serviceExtension.size() == 0){
                            servicesWithSingleNmbr.add(legacyService);
                        } else {
                            servicesWithRanges.add(legacyService);
                        }
                    }
                    System.debug('servicesWithSingleNmbr::'+servicesWithSingleNmbr);
                    System.debug('servicesWithRanges::'+servicesWithRanges);
                    //get single numbers and put them in NCS configurations
                    List<NumberNCSDTO.Configuration> ncsConfigList = new List<NumberNCSDTO.Configuration>();
                    for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 singleSvc :servicesWithSingleNmbr){
                        NumberNCSDTO.Configuration ncsConfig = new NumberNCSDTO.Configuration();
                        ncsConfig.FNN = singleSvc.Service_Id;
                        ncsConfig.status = Label.NumberStatus_TRANSITION;
                        ncsConfig.listCode = singleSvc.Directory_Option == null ? 'No Entry Line' : singleSvc.Directory_Option;
                        ncsConfigList.add(ncsConfig);
                        System.debug('ncsConfig::'+ncsConfig);
                        syncNumberList.add(singleSvc.Service_Id);
                    }
                    ///Added as part of Edge-68639
                    //if more than one extensions check if they can be merged
                    //merge and create schema
                ///Added as part of Edge-68639  
                //system.debug('serEXtList**'+serEXtList);            
                for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 rel: servicesWithRanges)
                {
                    //List<ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2> extList = rel.serviceExtension;
                    List<ServiceExtentionComparableWrapper > extList = new List<ServiceExtentionComparableWrapper > ();
                    for(ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2 serExt:rel.serviceExtension){
                        extList.add(new ServiceExtentionComparableWrapper(serExt.Services_To,serExt.Services_From));
                    }
                    system.debug('extList before sort'+extList);
                    if(extList!= null && extList.size () > 0) {
                    extList.sort();
                    //serEXtList.addAll(serEXtList);
                    }
                    system.debug('extList'+extList);
                        Boolean addServiceId = true;
                        if(extList !=null){                     
                            for(integer i=0; i<extList.size(); i++){
                                NumberNCSDTO.Configuration tempncsConfig = new NumberNCSDTO.Configuration();
                                if(i+1 <= extList.size()-1 && Integer.valueOf(extList[i+1].Services_From) - Integer.valueOf(extList[i].Services_To) == 2){
                                    system.debug('inside if' );
                                    
                                    /*if(i==0)
                                        tempncsConfig.rangeFrom = rel.Service_Id;*/ 
                                    tempncsConfig.rangeFrom = extList[i].Services_From;
                                    tempncsConfig.rangeTo = extList[i+1].Services_To;
                                        tempncsConfig.status = Label.NumberStatus_TRANSITION;
                                        tempncsConfig.listCode = 'No Entry Line';
                                    if(Integer.valueOf(rel.Service_Id) >= Integer.valueOf(extList[i].Services_From) && Integer.valueOf(rel.Service_Id) <= Integer.valueOf(extList[i+1].Services_TO)){
                                            addServiceId = false;
                                        }
                                    syncNumberList.add(extList[i].Services_From+':'+extList[i+1].Services_TO);
                                        i++;
                                }
                                else if(i+1<= extList.size()-1 && (Integer.valueOf(extList[i+1].Services_To) - Integer.valueOf(extList[i].Services_FROM) < 2 || Integer.valueOf(extList[i+1].Services_To) - Integer.valueOf(extList[i].Services_FROM) >2)){
                                    system.debug('inside elseif 1' );
                                        tempncsConfig.rangeFrom = extList[i].Services_FROM;
                                    tempncsConfig.rangeTo = extList[i].Services_To;
                                        tempncsConfig.status = Label.NumberStatus_TRANSITION;
                                        tempncsConfig.listCode = 'No Entry Line';
                                    if(Integer.valueOf(rel.Service_Id) >= Integer.valueOf(extList[i].Services_FROM) && Integer.valueOf(rel.Service_Id) <= Integer.valueOf(extList[i].Services_To)){
                                            addServiceId = false;
                                        }
                                    syncNumberList.add(extList[i].Services_FROM+':'+extList[i].Services_To);
                                        //i++;   //EDGE-106478 code was uncommented in copado
                                }   
                                else {
                                    system.debug('inside else' );
                                    tempncsConfig.rangeFrom = extList[i].Services_FROM;
                                    tempncsConfig.rangeTo = extList[i].Services_To;
                                        tempncsConfig.status = Label.NumberStatus_TRANSITION;
                                        tempncsConfig.listCode = 'No Entry Line';
                                    if(Integer.valueOf(rel.Service_Id) >= Integer.valueOf(extList[i].Services_FROM) && Integer.valueOf(rel.Service_Id) <= Integer.valueOf(extList[i].Services_To)){
                                            addServiceId = false;
                                        }
                                    syncNumberList.add(extList[i].Services_FROM+':'+extList[i].Services_To);
                                        //i++;   //EDGE-106478 code was uncommented in copado
                                }
                                
                                ncsConfigList.add(tempncsConfig);
                                
                                System.debug('tempncsConfig::'+tempncsConfig);
                            }
                        }
                        if(addServiceId){
                            NumberNCSDTO.Configuration tempncsConfig2 = new NumberNCSDTO.Configuration();
                            tempncsConfig2.status = Label.NumberStatus_TRANSITION;
                            tempncsConfig2.FNN = rel.Service_Id;
                            tempncsConfig2.listCode = 'No Entry Line';
                            ncsConfigList.add(tempncsConfig2);
                        }  
                    }
                    
                    System.debug('ncsConfigList::'+ncsConfigList);
                    
                    //Find existing numbers - TBD
                    NumberNCSHelper ncsHelper = new NumberNCSHelper();
                    Map<String,List<String>> existingNumbers = ncsHelper.getNumbersFromNCS(bsktConfigs[0].Id);
                    if(existingNumbers.size() > 0){
                        
                        //TBI - delete Transition numbers
                        // ncsHelper.deleteExistingNCS(bsktConfigs[0].Id, syncNumberList);
                        ncsHelper.deleteExistingNCS(ADBorIDbsktConfigsMap.get(key).Id, syncNumberList); 
                        system.debug('---####----'+ADBorIDbsktConfigsMap.get(key).Id +'*******'+syncNumberList);
                        //add new transition numbers
                        // ncsHelper.updateExistingNCS(bsktConfigs[0].Id, ncs[0].Name, ncsConfigList, ncs[0]);
                        ncsHelper.updateExistingNCS(ADBorIDbsktConfigsMap.get(key).Id, ncs[0].Name, ncsConfigList, ncs[0]);
                        
                    } else{
                        //  ncsHelper.createNewNCS(bsktConfigs[0].Id, ncs[0].Name, ncsConfigList, ncs[0]);
                        ncsHelper.createNewNCS(ADBorIDbsktConfigsMap.get(key).Id, ncs[0].Name, ncsConfigList, ncs[0]);
                        system.debug('---####-Else---'+ADBorIDbsktConfigsMap.get(key).Id +'*******'+ncsConfigList);
                    }
                    
                    
                    
                    //return 'Success';
                }
            }
        } else {
            //return 'No numbers to be counted';
        }
        
    }
    
    
    public static List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> getSelectLegacyServices(ReplicatorGetServiceDataObject_V2.productListDTO prodDTO){
        List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> selectedServices = new List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>();
        if(prodDTO.serviceList != null){
            for(ReplicatorGetServiceDataObject_V2.serviceListDTO svcDTO : prodDTO.serviceList){
                selectedServices.addAll(svcDTO.service);
            }
        }
        return selectedServices;
    }
    
     ////EDGE-127666
     //Query numbers attachment for IP Sites it is replicator attachment, for UCE NCE attachment
     //for IP Site PCR query for replicator dto-ReplicatorGetServiceDataObject_V2 att-TransitionJSONData.json
    public static List<Attachment> getLegacyServices(String ipSitePDSpec, String basktId){
        List<Attachment> legacyServices = [SELECT Id, Name, Body, BodyLength, ParentId
                                           FROM Attachment
                                           WHERE ParentId IN (SELECT Id FROM cscfga__Product_Configuration__c //updated query for solution console pcr tp pc change
                                                              WHERE cscfga__product_definition__r.product_Specification__c = :ipSitePDSpec
                                                              AND cscfga__Product_Basket__c = :basktId
                                                              AND cscfga__product_definition__r.name like '%IP%'
                                                             )
                                           AND Name = 'TransitionJSONData.json'
                                          ];
        return legacyServices;
    }
    
    //EDGE-127666
    // retrive For all the Prod Configs fetched, retrieve the ADBorID 
        public static map <String, cscfga__Product_Configuration__c> getAdboreIdsForConfigs(List<cscfga__Product_Configuration__c> bsktConfigs, map <Id, cscfga__Product_Configuration__c> bsktConfigsMap){
        map <String, cscfga__Product_Configuration__c> ADBorIDbsktConfigsMap = New Map<String, cscfga__Product_Configuration__c>();
        
                for(cscfga__Attribute__c cscfgaAttributec : [SELECT cscfga__Value__c,Name, cscfga__Product_Configuration__c FROM cscfga__Attribute__c WHERE Name = 'AdborID' AND cscfga__Product_Configuration__c IN :bsktConfigs])
        {
            if(cscfgaAttributec.cscfga__Value__c != NULL){
                if( bsktConfigsMap.containsKey(cscfgaAttributec.cscfga__Product_Configuration__c) )
                {
                    ADBorIDbsktConfigsMap.put(cscfgaAttributec.cscfga__Value__c,bsktConfigsMap.get(cscfgaAttributec.cscfga__Product_Configuration__c));
                    system.debug('++++>Inside If adborId-->'+cscfgaAttributec.cscfga__Value__c);
                    system.debug('++++>Inside If Value-->'+bsktConfigsMap.get(cscfgaAttributec.cscfga__Product_Configuration__c));
                }
            }
        }
    
    return ADBorIDbsktConfigsMap;
    }

        //EDGE-127666
        //Read the attachment find numbers and ranges
        public static List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2> getRplServiceList(List<Attachment> legacyServices){
        
                List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2> rplServiceList = new List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2>();
        for(Attachment att: legacyServices){
            if(att.Body !=null && String.valueOf(att.Body) != null && String.valueOf(att.Body) != ''){
                System.debug('attbody'+att.Body.toString());
                ReplicatorGetServiceDataObject_V2 rplService = (ReplicatorGetServiceDataObject_V2) JSON.deserialize(att.Body.toString(), ReplicatorGetServiceDataObject_V2.Class); 
                rplServiceList.addAll(rplService.site);
            }
        }
    
    return rplServiceList;
    }    

        //EDGE-127666
        public static map <String, List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2>> getrplServiceMap(List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2> rplServiceList, map <String, cscfga__Product_Configuration__c> ADBorIDbsktConfigsMap){
        
        map <String, List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2>> rplServiceMap = New Map<String, List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2>>();
        List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2> rplServiceListIterator ;
        
        for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 rpls : rplServiceList){
            if(rpls.ADBOR_Id != null) {
                //    rplServiceMap.put(rpls.ADBOR_Id, rpls);
                if(ADBorIDbsktConfigsMap.containsKey(rpls.ADBOR_Id) ){
                    rplServiceListIterator = new List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2>();
                    rplServiceListIterator.add(rpls);
                    rplServiceMap.put(rpls.ADBOR_Id, rplServiceListIterator);
                } 
            }
        }
    
    return rplServiceMap;
    }
    
}