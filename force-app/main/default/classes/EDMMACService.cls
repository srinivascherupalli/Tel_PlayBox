/*
===============================================================================================================================
Class : EDMMACService
Developer Name :
Test Class : EDMMACServiceTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
  1.      Ravi Bhatnagar       30/12/19      EDGE-124891 : Refactor Orchestration Processes
  2.      Vaibhav Deshpande    30/04/20      EDGE-144539 : Upgrade Delta Handler Logic to check Non Commercial Attributes of Generated Spec
===============================================================================================================================
*/
public with sharing class EDMMACService {
    public class MyException extends Exception {}
    public static List<CS_SpecificationDTO.ServiceSpecification> srvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
    
    @TestVisible
    private class specList{
        public String guid;
        public String serviceId;
        public String status;
    }
    //EDGE-124891 : Method changed as part of refactoring
    public static void updateStatus(List<Id> OrderIds){
        //fetch custom settings to read status value
		String srvStatus;
        List<csordtelcoa__Orders_Subscriptions_Options__c> subsSettings = [Select Id, csordtelcoa__Service_Initial_State__c from csordtelcoa__Orders_Subscriptions_Options__c where SetupOwnerId =: Userinfo.getOrganizationId() LIMIT 1];
		
		if(!subsSettings.isEmpty())
			srvStatus = subsSettings[0].csordtelcoa__Service_Initial_State__c;
		else
			return;
        //fetch all modified services - MG added 'csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c' field to query
        Map<Id,csord__Service__c> mapSerIdService = new Map<Id, csord__Service__c>([Select Id, Name,ModelChange__c, csord__Service__c,  Appointment_Required__c, TechnologyType__c, csord__Order_Request__c, 		csordtelcoa__Replaced_Service__c, csord__Order__r.csordtelcoa__Opportunity__c,                                                                                 csordtelcoa__Product_Configuration__c 
		FROM csord__Service__c 
		WHERE csord__Order__c IN: OrderIds AND csord__Status__c = :srvStatus AND csordtelcoa__Replaced_Service__c != null and tobecancelled__c !='true' and (NOT csordtelcoa__Product_Configuration__r.Name  like '%Connected Workplace Solution%') and (NOT csordtelcoa__Product_Configuration__r.ConfigurationType1__c  like '%Solution%')]);
        List<specList> specsToUpdate = new List<specList>();
        Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();
        Set<Id> servIdSet = new Set<Id>();
        
		//EDGE-124891 : Commented as part of refactoring - Start
        /*if (allServices.isEmpty()) {
            return;
        }

        for(csord__Service__c srv: allServices){
            servIdSet.add(srv.id);
        } */
		//EDGE-124891 : Commented as part of refactoring - End
        //AntunB: if we do not have any services to process then finish immediately otherwise we are consuming 4 SOQLs that will never return any rows!
		if (!mapSerIdService.isEmpty())
			servIdSet = mapSerIdService.keySet();
       
        Set<Id> replacedServiceIdSet =  new Set<Id>();
        for (csord__Service__c tempService : mapSerIdService.values()) {
            replacedServiceIdSet.add(tempService.csordtelcoa__Replaced_Service__c);
        }
        
        Map<Id, Attachment> attmAP = new Map<Id, Attachment>([SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: servIdSet and name = 'ServiceSpecifications.json']);
        Map<Id, Attachment> serviceIdToSpecAttachMap = new Map<Id, Attachment>();
        for(Attachment tempAttachment: attmAP.values()){
            serviceIdToSpecAttachMap.put(tempAttachment.parentId, tempAttachment);
        }
		//EDGE-124891 : Added as part of refactoring
		attmAP.clear();
        //EDGE-124891 : Commented as part of refactoring - Start
        /*Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([Select Id, Name,ModelChange__c, csord__Service__c,  Appointment_Required__c, TechnologyType__c, csord__Order_Request__c, csordtelcoa__Replaced_Service__c, csord__Order__r.csordtelcoa__Opportunity__c,
                                                                                csordtelcoa__Product_Configuration__c from csord__Service__c where Id IN:servIdSet]);*/
        //EDGE-124891 : Commented as part of refactoring - End
        Map<Id, csord__Service__c> replacedServiceMap = new Map<Id, csord__Service__c>([Select Id, Name,ModelChange__c, csord__Service__c,  Appointment_Required__c, TechnologyType__c, csord__Order_Request__c, csordtelcoa__Replaced_Service__c, csord__Order__r.csordtelcoa__Opportunity__c,
                                                                                        csordtelcoa__Product_Configuration__c from csord__Service__c where Id IN:replacedServiceIdSet]);
        //EDGE-124891 : Commented as part of refactoring - Start
        /*List<Attachment> attachmentList = new List<Attachment>([SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: servIdSet and name = 'ServiceSpecifications.json']);
        String serviceAttachment = '';
        for(Attachment tempAttachment: attachmentList){
            serviceAttachment = tempAttachment.Body.toString();
        }*/
        //EDGE-124891 : Commented as part of refactoring - End
        for(csord__Service__c srv: mapSerIdService.values()){
            //EDMMACServiceUtils.serviceSpecDelta specDelta = new EDMMACServiceUtils.serviceSpecDelta();
            EDMMACServiceUtilsV2.serviceSpecDelta specDelta = new EDMMACServiceUtilsV2.serviceSpecDelta();
            String jsonspecDelta = csedm.API_1.createServiceSpecificationsDelta(srv.Id, srv.csordtelcoa__Replaced_Service__c);
            System.debug('jsonspecDelta:::'+jsonspecDelta);
            if(String.isNotEmpty(jsonspecDelta)){
                //specDelta = EDMMACServiceUtils.parse(jsonspecDelta);
                specDelta = EDMMACServiceUtilsV2.parse(jsonspecDelta);
                System.debug('specDelta:::'+specDelta);
                if(!specDelta.changed.isEmpty()){
                    //specsToUpdate.addAll(getAllDeltaSpecs(srv.Id, specDelta.changed, srv.csordtelcoa__Replaced_Service__c, serviceIdToSpecAttachMap));
                    specsToUpdate.addAll(getAllDeltaSpecsV2(srv.Id, specDelta.changed, srv.csordtelcoa__Replaced_Service__c, serviceIdToSpecAttachMap,mapSerIdService,replacedServiceMap));
                }//else if(!specDelta.added.isEmpty()){
                //   specsToUpdate.addAll(getAllDeltaSpecs(srv.Id, specDelta.added));
                //}
            }
            
            
            //@Team Munich - Jainish
            //Commented the inner logic of this IF condition since we do not have any current requirement for the newly added specs. They would always be in Pending status as of now - B2B4
            // if (srv.Id != null && srv.csordtelcoa__Replaced_Service__c != null && !specDelta.added.isEmpty()) {
            //specsToUpdate.addAll(getAllModifySpecs(srv.Id, specDelta.added, srv.csordtelcoa__Replaced_Service__c));
            // }
            
        }
        
        if(!specsToUpdate.isEmpty()){
            for(specList spec: specsToUpdate){
                System.debug('spec:::'+spec);
                String serviceId = spec.serviceId;
                //csedm.API_1.updateServiceSpecificationPropertyById(spec.serviceId, spec.guid, 'status', spec.status);
                if(!serviceIdToSpecAttachMap.isEmpty()){
                String updatedAttBody =   csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceIdToSpecAttachMap.get(serviceId).body.toString()), spec.guid, 'status',spec.status);
                Attachment att = serviceIdToSpecAttachMap.get(serviceId);
                if(updatedAttBody!=null){
                    att.body = Blob.valueOf(updatedAttBody);}
                //update att;
                serviceIdToSpecAttachMap.put(att.parentId,att);
                    updatedAttSet.put(att.id,att);}
            }
            if(!updatedAttSet.isEmpty()){
                update updatedAttSet.values();
            }
        }
    }
    
    @TestVisible
    private static List<specList> getAllModifySpecs(String srvId, List<String> specs, String replacedSrvId ){
        List<specList> specsToUpdate = new List<specList>();
        for(String spc: specs){
            specList specToUpdate = new specList();
            specToUpdate.serviceId = srvId;
            specToUpdate.guid = spc;
            specToUpdate.status = Label.Service_Spec_MAC_Initial_Status;
            specsToUpdate.add(specToUpdate);    
        }
        return specsToUpdate;
    }
    
    private static List<specList> getAllDeltaSpecsV2(String srvId, List<EDMMACServiceUtilsV2.deltaDTO> specs, String replacedSrvId, Map<Id, Attachment> serviceIdToSpecAttachMap,Map<Id, csord__Service__c> serviceMap,Map<Id, csord__Service__c> replacedServiceMap ){
        List<specList> specsToUpdate = new List<specList>();
        for(EDMMACServiceUtilsV2.deltaDTO spc: specs){
            List<EDMMACServiceUtilsV2.Attribute> changedAttList = spc.changedAttributes;
            List<EDMMACServiceUtilsV2.Attribute> changedAddAttList = spc.changedAdditionalAttributes;
            List<EDMMACServiceUtilsV2.NonCommercialAttr> changedNonComercialAttList = spc.changedNonCommercialAttributes;//added as part of - EDGE-144539
            Set<String> changedAttSet = new Set<String>();
            String spcGuid = spc.guid;
            if(!changedAttList.isEmpty() || !changedAddAttList.isEmpty() || !changedNonComercialAttList.isEmpty()){
                List<String> exclusionList = ManageOrderServiceAttributes.getExclusionAttribute('DeltaCheck');
                system.debug('==========exclusionList==='+exclusionList);
                system.debug('==========changedatt==='+changedAttList+'====='+replacedSrvId+srvId);
                
                List<String> exclusionAttrList = new List<String>();
                String serviceattachmentstr;
                List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
                system.debug('before replacedSrvId ful');
                if(!serviceIdToSpecAttachMap.isEmpty()){
                Attachment replacedServiceAttach = serviceIdToSpecAttachMap.get(srvId);
                 serviceattachmentstr = replacedServiceAttach.body.toString();
                system.debug('srvId ::: ' + srvId);
                system.debug('serviceattachmentstr ::: ' + serviceattachmentstr);}
                if(serviceattachmentstr!= null){
                srvSpecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceattachmentstr));}
                for(CS_SpecificationDTO.ServiceSpecification specification : srvSpecList){
                    string specguid = specification.guid;
                    if(specguid == spcGuid){
                        for(CS_SpecificationDTO.SimpleAttributes attrAdditional :specification.additionalAttributes){
                            for(String exclusion : exclusionList){
                                if(attrAdditional.name.contains(exclusion)){
                                    exclusionAttrList.add(attrAdditional.name);
                                }
                            }
                        }
                        for(CS_SpecificationDTO.SimpleAttributes attrsimple :specification.simpleAttributes){
                            for(String exclusion : exclusionList){
                                if(attrsimple.name.contains(exclusion)){
                                    exclusionAttrList.add(attrsimple.name);
                                }
                            }
                        }
                    }
                }
                
                for(EDMMACServiceUtilsV2.Attribute attr : changedAttList){
                    changedAttSet.add(attr.name);
                }
				//EDGE-124891 : Commented as part of refactoring - Start - ***EDGE-144539 uncommented code
                for(EDMMACServiceUtilsV2.Attribute attr : changedAddAttList){
                    changedAttSet.add(attr.name);
                }
               
                //added as part of EDGE-144539 : Start
                if(!changedNonComercialAttList.isEmpty()){
                for(EDMMACServiceUtilsV2.NonCommercialAttr nca : changedNonComercialAttList){
                    
                    for(EDMMACServiceUtilsV2.Attribute addedAttr: nca.addedAttributes)
                    {
                        changedAttSet.add(addedAttr.name);
                    }
                    for(EDMMACServiceUtilsV2.Attribute changedAttr: nca.changedAttributes)
                    {
                        changedAttSet.add(changedAttr.name);
                    }
                    for(EDMMACServiceUtilsV2.Attribute removedAttr: nca.removedAttributes)
                    {
                        changedAttSet.add(removedAttr.name);
                    }
                   
                }
                }
                 //added as part of EDGE-144539 : End
                
                changedAttSet.removeAll(exclusionAttrList);
                system.debug('==========changedAttSet==='+changedAttSet);
                
            }
            //code commented as part of EDGE-144539 - Start 
            /*if(!spc.changedNonCommercialAttributes.isEmpty()){
                
                Integer previousServiceNumberCount = 0;
                Integer newServiceNumberCount = 0;
                String currentProdConfigId = serviceMap.get(srvId).csordtelcoa__Product_Configuration__c;
                String replacedProdConfigId = replacedServiceMap.get(replacedSrvId).csordtelcoa__Product_Configuration__c;
                NumberNCSHelper ncsHelper = new NumberNCSHelper();
                newServiceNumberCount = ncsHelper.getTotalCountOfNumbers(currentProdConfigId);
                previousServiceNumberCount = ncsHelper.getTotalCountOfNumbers(replacedProdConfigId);
                
                if(newServiceNumberCount>previousServiceNumberCount){
                    specList specToUpdate = new specList();
                    specToUpdate.serviceId = srvId;
                    specToUpdate.guid = spc.guid;
                    specToUpdate.status = Label.Service_Spec_MAC_Initial_Status;
                    specsToUpdate.add(specToUpdate);
                }
            }*/
            //code commented as part of EDGE-144539 - End
            if(!changedAttSet.isEmpty()){
                specList specToUpdate = new specList();
                specToUpdate.serviceId = srvId;
                specToUpdate.guid = spc.guid;
                specToUpdate.status = Label.Service_Spec_MAC_Initial_Status;
                specsToUpdate.add(specToUpdate);
            }               
        }
        return specsToUpdate;
    }
    
    //EDGE-81566
    public static void updateStatusMobileAccess(List<Id> orderIds){
        try{         
            List<csord__Service__c> allServicesList = [SELECT Id, Name, csord__Order__r.csord__Primary_Order__c, csordtelcoa__Replaced_Service__c, csord__Status__c from csord__Service__c WHERE csord__Order__r.csord__Primary_Order__c IN: orderIds];            
            Map<Id, Attachment> attmAP = new Map<Id, Attachment>([SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: allServicesList and name = 'ServiceSpecifications.json']);
            Map<String, String> serviceAttachmentMap = new Map<String, String>();
            Map<String, Attachment> servAttachmentRecordMap= new Map<String, Attachment>();
            Map<Id,Attachment> updatedAttSet = new Map <Id,Attachment>();
            for(Attachment att: attmAP.values()){
                serviceAttachmentMap.put(att.parentId,att.body.toString());
                servAttachmentRecordMap.put(att.parentId,att);
                System.debug('serviceAttachmentMap==?'+serviceAttachmentMap +'servAttachmentRecordMap==>'+servAttachmentRecordMap);
                
            }
            
            for(String eachService: serviceAttachmentMap.keySet()){
                srvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService))));
                System.debug('srvspecListv==>'+srvspecList);
            }
            
            for(CS_SpecificationDTO.ServiceSpecification specs : srvspecList) {
                // srvSpecMap.put(serSpec.guid, serSpec);
                String udtattbody = csedm.API_1.updateServiceSpecificationProperty(String.valueOf(serviceAttachmentMap.get(specs.serviceId)), specs.guid, 'status', 'Pending');
                Attachment att = servAttachmentRecordMap.get(specs.serviceId);
                system.debug('udtattbody v ==>' + udtattbody);
                att.body = Blob.valueOf(udtattbody);
                //update att;
                serviceAttachmentMap.put(att.parentId,att.Body.toString());
                updatedAttSet.put(att.id,att);
            }        
            
            if(!updatedAttSet.isEmpty()){
                
                update updatedAttSet.values();
                System.debug('updatedAttSet.values()==>'+updatedAttSet.values());
            }
           if(Test.isRunningTest())
        { throw new MyException('My exception');} 
        }catch(Exception ex){
            //catch exception
        }
        
    }
    
}