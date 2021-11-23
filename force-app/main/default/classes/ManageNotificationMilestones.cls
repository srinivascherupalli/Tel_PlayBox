public with sharing class ManageNotificationMilestones {
    
    @InvocableMethod
    public static void processNotificationRecord(List<String> parameters1){
        System.debug('Params:::' + parameters1);
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        Boolean stopprocessing = false;
        String notificationId;
        try{
            for(String paramString: parameters1){
                List<String> parameters = paramString.split(':::');
                String orderItemIdc; String orderItemDetails; String milestoneRecr; String eventType;String sourceSystem;
                if(parameters.size() > 0){ orderItemIdc = parameters[0]; }
                if(parameters.size() > 1){ milestoneRecr = parameters[1]; }
                if(parameters.size() > 2){ eventType = parameters[2]; }
                if(parameters.size() > 3){ orderItemDetails = parameters[3]; }
                //if(parameters.size() > 4){ sourceSystem = parameters[4]; }
                if(parameters.size() > 4){notificationId = parameters[4]; }
                System.debug('Id::' + notificationId);
                if(String.isEmpty(String.valueOf(orderItemIdc)) || String.isEmpty(milestoneRecr) || String.isEmpty(eventType)){
                    System.debug('Parameter Empty: '+String.valueOf(orderItemIdc)+' | '+ milestoneRecr + ' | '+eventType);
                    stopprocessing = true;
                }
                if(!stopprocessing){
                    params.orderIdc = orderItemIdc;
                    if(String.isNotEmpty(milestoneRecr)) params.notifyAttributes = '{'+milestoneRecr+'}'; //convert string to JSON supported format
                    if(String.isNotEmpty(orderItemDetails)) params.orderItemDetails = '{'+orderItemDetails+'}'; //convert string to JSON supported format
                    params.eventType = eventType; 
                }
            }
            if(params != null && !stopprocessing)
                processMileStones(JSON.serialize(params),notificationId);
        }
        catch(Exception e){
            System.debug('Exception:' + e.getTypeName() +' '+ e.getMessage());
        }
    }
    
    public static void processMileStones(String parameters, String notificationId){
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        Notification__c notif = [Select Id,Name,Status__c,Internal_Error_Description__c from Notification__c where Id =: notificationId];
        Savepoint sp = Database.setSavepoint();
        try{
            params = (ManageOrderNotificationUtil.Parameters) JSON.deserialize(parameters, ManageOrderNotificationUtil.Parameters.class);
            System.debug('parameters:::'+parameters);
            String orderItemIdc = params.orderIdc ;
            String orderItemDetails = params.orderItemDetails;
            String milestoneRecr = params.notifyAttributes;
            String eventType = params.eventType;
            String orderId = null ; String srvcNumber = null; String instanceId = null;
            Boolean stopprocessing = false;
            List<String> keyparams = orderItemIdc.split('\\|');
            if(keyparams.size() > 0){ orderId = keyparams[0]; }
            if(keyparams.size() > 1){ srvcNumber = keyparams[1]; }
            if(keyparams.size() > 2){ instanceId = keyparams[2]; }
            if(srvcNumber == null || orderId == null || instanceId == null){
                stopprocessing = true;
            }
            Map<String,String> addAttrs = new Map<String,String>();
            String milestoneStatus = NULL;
            String milestoneName = NULL;
            DateTime startDate = NULL;
            DateTime endDate = NULL;
            Set<Id> srvSpecId= new Set<Id>();
			String serviceId;
			String subscriptionId;
			String relOrderId;
            
            if(!stopprocessing){
                System.debug('milestoneRecr:::' + milestoneRecr);				
                ManageOrderNotificationUtil.NotificationAttributesDataObject notifyAttrs = ManageOrderNotificationUtil.parseAttributes(milestoneRecr);
                System.debug('notifyAttrs:::' + notifyAttrs);
                for(ManageOrderNotificationUtil.NotificationAttributes attr : notifyAttrs.attributes)
                {
                    if(attr.name.contains('MilestoneName')){
                        addAttrs.put(attr.name,attr.value);
                        milestoneName = attr.value;}
                    else if(attr.name.contains('MilestoneStatus')){
                        addAttrs.put(attr.name,attr.value);
                        milestoneStatus = attr.value;}
                    else if(attr.name.contains('MilestoneStartDate')){
                        addAttrs.put(attr.name,attr.value);
                        startDate = (datetime)json.deserialize('"'+attr.value+'"', datetime.class);}
                    else if(attr.name.contains('MilestoneEndDate')){
                        addAttrs.put(attr.name,attr.value);
                        endDate = (datetime)json.deserialize('"'+attr.value+'"', datetime.class);}
                } 
                
                List<Service_Specification__c> serSpecifications = new List<Service_Specification__c>();
				List<Service_Specification__c> allSerSpecifications = new List<Service_Specification__c>();
                
                List<csord__Service__c> serviceList = [SELECT Id, Name, csord__Status__c, csord__Subscription__c, csord__Order__c, csord__Order__r.id ,csord__Order__r.csord__Primary_Order__c, csordtelcoa__Service_Number__c,(Select Id, Name,GUID__c, Service__c  FROM Service_Specifications__r) FROM csord__Service__c WHERE csordtelcoa__Service_Number__c=:srvcNumber Order By CreatedDate];
                
                for(csord__Service__c srv :  serviceList)
                {
					serviceId = srv.Id;
					subscriptionId = srv.csord__Subscription__c;
					relOrderId = srv.csord__Order__r.csord__Primary_Order__c != null ? srv.csord__Order__r.csord__Primary_Order__c : srv.csord__Order__c;
					
                    if(srv.Service_Specifications__r.size()==0){
                        List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(srv.Id),'FULFILMENT');
                        //sizeList =srvspecList.size();
                        system.debug('service spec'+srvspecList);
                        for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvspecList)
                        {
                            boolean checkChildSpec=false;
                            Set<String> serviceGuid = new Set<String>();
							system.debug('attlist===='+srvSpec.name+'00000000==========='+srvSpec.additionalAttributes);
							system.debug('check condition'+srvSpec.additionalAttributes.size());
                            //if(srvSpec.name.contains('_fulfilment')){
								if(srvSpec.additionalAttributes.size()!=0){
									for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes) 
									{
										system.debug('attr===='+attr+'----='+attr.name);
                                        if(attr.name=='parentSpec')
                                        {
                                            checkChildSpec=true;
                                            break;
                                        }            
									}
                                    if(!checkChildSpec){
                                        
                                            
                                            Service_Specification__c serSpec = new Service_Specification__c();
                                            serSpec.Name = srvSpec.name;
                                            serSpec.GUID__c = srvSpec.guid;
                                            serSpec.Service__c = srv.Id;
                                            serSpecifications.add(serSpec);                                            
                                    }
								}else{
									system.debug('entering else======');
										Service_Specification__c serSpec = new Service_Specification__c();
                                        serSpec.Name = srvSpec.name;
                                        serSpec.GUID__c = srvSpec.guid;
                                        serSpec.Service__c = srv.Id;
                                        serSpecifications.add(serSpec);
								}
                            
                        }
                    }else{
						allSerSpecifications.addAll(srv.Service_Specifications__r);
					}
                }
				if(!serSpecifications.isEmpty()){			
					insert serSpecifications;
					
				}
				allSerSpecifications.addAll(serSpecifications);
				
				
                Map<String, Service_Specification__c> srvSpecMap = new Map<String, Service_Specification__c>();
                for(Service_Specification__c srvSpec: allSerSpecifications){
                    srvSpecId.add(srvSpec.Id);
                    srvSpecMap.put(srvSpec.GUID__c,srvSpec );
                }
                system.debug('===srvSpecMap===='+srvSpecMap);
                
                Milestone__c milestone = new Milestone__c();
                system.debug('===milestone===='+milestone);				
                milestone.Name= milestoneName;
                milestone.Status__c= milestoneStatus;
                milestone.Start_Date__c= startDate;     
                milestone.End_Date__c= endDate;
				system.debug('===instanceId===='+instanceId);
                milestone.Service_Specification__c=srvSpecMap.get(instanceId).Id;
                system.debug('===milestone11111===='+milestone);	
                insert milestone;
                
				List<Milestone__c> milestoneLst = new List<Milestone__c>([Select id FROM Milestone__c WHERE name=:milestoneName and Service_Specification__c IN:srvSpecId]);
				system.debug('milestoneLst====size===='+milestoneLst.size());
				
				Map<String,Milestone_Mapping__mdt> milsetonesStageMap=new Map<String,Milestone_Mapping__mdt>();
            
        String queryNotificationMdtStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Milestone_Mapping__mdt')) + '\n ' +
                          ' FROM Milestone_Mapping__mdt \n ';
        List<Milestone_Mapping__mdt> milsetonesStageList = Database.query(queryNotificationMdtStr); 
        if(milsetonesStageList == null || milsetonesStageList.isEmpty()){
            System.debug('No milestone settings found.');
           
        } else if(!milsetonesStageList.isEmpty()){
            for(Milestone_Mapping__mdt milestoneRec: milsetonesStageList){
                milsetonesStageMap.put(milestoneRec.MasterLabel, milestoneRec);
            }

        }
        system.debug('=====milestoneRec-===='+milsetonesStageMap.keyset());
         
				
				if(milestoneLst.size()==srvSpecId.size()){
					system.debug('true--====');
					csord__Service__c servupdate  = new csord__Service__c(id=serviceId, Milestone_Stage_Completed__c=milsetonesStageMap.get(milestoneName).Customer_Sub_stage__c,Milestone__c=milestoneName );
					update servupdate;
				}
				Set<String> prdSet = new Set<String>();
				prdSet.add('User');prdSet.add('IAD');prdSet.add('Bandwidth Clip On');prdSet.add('Handset and Accessories');
                //List<csord__Service__c> srvcList = [SELECT Id, Name, csord__Status__c, csord__Order__c, csord__Order__r.id ,csordtelcoa__Service_Number__c FROM csord__Service__c WHERE csordtelcoa__Service_Number__c=:srvcNumber Order By CreatedDate];
				List<csord__Subscription__c> subscripList = [SELECT Id,Name,csordtelcoa__Subscription_Number__c, csord__Order__c, (SELECT Id,Milestone_Stage_Completed__c,Milestone__c FROM csord__Services__r WHERE csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name NOT IN:prdSet) FROM csord__Subscription__c WHERE Id=:subscriptionId Order By CreatedDate];
				
				boolean updSusbcription = true;
				
				for (csord__Subscription__c subscrip :subscripList ){
					
					for(csord__Service__c srvc: subscrip.csord__Services__r ){
						if(srvc.Milestone_Stage_Completed__c==null || (srvc.Milestone_Stage_Completed__c!=null && milsetonesStageMap.get(srvc.Milestone__c).Level__c<milsetonesStageMap.get(milestoneName).Level__c)){
							updSusbcription=false;
							break;
						}	
					}
				}	
				if(updSusbcription){
					system.debug('true--====');
					csord__Subscription__c subcripupdate  = new csord__Subscription__c(id=subscriptionId, Milestone_Stage_Completed__c=milsetonesStageMap.get(milestoneName).Customer_stage__c, Milestone__c=milestoneName );
					update subcripupdate;
				}
				List<csord__Subscription__c> allSubscripList = [SELECT Id,Name,csordtelcoa__Subscription_Number__c, csord__Order__c, csord__Order__r.csord__Primary_Order__c,Milestone_Stage_Completed__c,Milestone__c  FROM csord__Subscription__c WHERE csord__Order__c=:relOrderId OR csord__Order__r.csord__Primary_Order__c=:relOrderId];
				
				boolean updOrder = true;
				for (csord__Subscription__c subscrips :allSubscripList ){
					
					
						if(subscrips.Milestone_Stage_Completed__c==null || (subscrips.Milestone_Stage_Completed__c!=null && milsetonesStageMap.get(subscrips.Milestone__c).Level__c<milsetonesStageMap.get(milestoneName).Level__c)){
							updOrder=false;
							break;
						}	
					
				}
				
				if(updOrder){
					system.debug('true--====');
					csord__Order__c orderupdate  = new csord__Order__c(id=relOrderId, Milestone_Stage_Completed__c=milsetonesStageMap.get(milestoneName).Order_Stage__c );
					update orderupdate;
				}
				
				
                
            }
            notif.Status__c = 'Completed';
        }
        catch(Exception e){
            notif.Status__c = 'Error';
            notif.Internal_Error_Description__c = e.getTypeName() +' '+ e.getMessage();
			Database.rollback(sp);

        }
        update notif;
    }    
}