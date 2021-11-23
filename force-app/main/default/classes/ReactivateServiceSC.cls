/*********************************************************************************************************************************
*Class Name      :  ReactivateServiceSC
Test Class : ReactivateServiceSCTest
author:  Shubhi V
EDGE-EDGE-185011
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            	shubhi              26.11.20202       EDGE-185011 to display reactivate services
2.              Shubhi V            15-12-2020        Edge-185856 
3.		        Shubhi V			12/03/2021		  INC000095032613
4.              Shubhi v             22/04/2021        EDGE-207352 
================================================================================================================================
*/
global with sharing class ReactivateServiceSC implements cssmgnt.RemoteActionDataProvider{
    //method call from js to get main solution subscription number EDGE-185011
    @RemoteAction
    global static Map<String, Object> getData(Map<String, Object> inputMap){
        Map<String, Object> returnMap=new Map<String, Object>();
        String pcid='';
        if(inputMap!=null && !inputMap.isEmpty()){
            if(inputMap.containsKey('getmainSubscriptionNumber')){
                pcid=String.Valueof(inputMap.get('getmainSubscriptionNumber'));
                cscfga__Product_Configuration__c pc=Model_ProductConfiguration.getConfig(pcid);
                if(String.isNotBlank(pc.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c)){
                    returnMap.put('getmainSubscriptionNumber',pc.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c);
                }
                
            }
        }
        return returnMap;
    }
    //method to get ReactiveService Metadata EDGE-185011
    //metadata holds headers to be displayed
    //class and function to be called based on caller product from solution console
    @AuraEnabled(cacheable=true)
    public static ReactivateServicecategories__mdt getReactiveServiceMetadata(String category){
        ReactivateServicecategories__mdt reactiveServiceMdt=new ReactivateServicecategories__mdt();
        if(String.isNotblank(category))
            reactiveServiceMdt=[SELECT id,DeveloperName,category__c,columnHeaders__c,last_n_days__c,methodName__c,prodSpecid__c,queryAddon__c,addOnSpecCodes__c FROM ReactivateServicecategories__mdt where DeveloperName=:category];
        System.debug('---reactiveServiceMdt---40'+reactiveServiceMdt);
        return reactiveServiceMdt;
    }
    //EDGE-185011 method to get final response for table
    @AuraEnabled(cacheable=false)
    public static List<ReactivateServiceWrapper> getReactivateServicesResult(String subscriptionNumber,String offerId,List<String> alreadyPresentMisdns,String searchString,ReactivateServicecategories__mdt reactiveServiceMdt){
        System.debug('---reactiveServiceMdt---46'+reactiveServiceMdt);
        List<ReactivateServiceWrapper> reactivateServicesList= new List<ReactivateServiceWrapper>();
        List<csord__Service__c> serviceList=new List<csord__Service__c>();
        serviceList=ReactivateServiceSC.getFinalServiceList(subscriptionNumber,offerId,reactiveServiceMdt); // INC000095032613
        System.debug('---serviceList---50'+serviceList);
        if(reactiveServiceMdt!=null && serviceList!=null && !serviceList.isEmpty()){
            System.debug('---reactiveServiceMdt.methodName__c---52'+reactiveServiceMdt.methodName__c);
            switch on reactiveServiceMdt.methodName__c {
                when 'getPlanresponse' {
                    //Edge-185856 start ----------------------
                    List<String> subsNumlist=new List<String>();
                    Map<String,Set<ReactivateServiceWrapper>> getAddonOptionsMap=new Map<String,Set<ReactivateServiceWrapper>>();
                    if(reactiveServiceMdt.queryAddon__c){
                        subsNumlist=ReactivateServiceSC.getSubscriptionNum(serviceList);
                        if(subsNumlist!=null && !subsNumlist.isEmpty()){
                            List<Attachment> attlist=Model_attachment.getServiceSpecs(subsNumlist);
                            if(attlist!=null && !attlist.isEmpty()) getAddonOptionsMap=ReactivateServiceSC.getAddonOptions(attlist,reactiveServiceMdt);
                        }
                    }
                    reactivateServicesList =ReactivateServiceSC.getPlanresponse(serviceList,getAddonOptionsMap);
                    //Edge-185856  end----------------
                }when else{
                    system.debug('Incorrect method name');
                }
            }
        }
        System.debug('---reactivateServicesList---72'+reactivateServicesList);
        return reactivateServicesList;
    }
    //EDGE-185011 map service fields to wrapper class
    private static List<ReactivateServiceWrapper> getPlanresponse(List<csord__Service__c> serviceList,Map<String,Set<ReactivateServiceWrapper>> addonOptionsMap){
        List<ReactivateServiceWrapper> reactivateServicesList= new List<ReactivateServiceWrapper>();
        System.debug('---serviceList---78'+serviceList);
        if(serviceList!=null && !serviceList.isEmpty()){
            for(csord__Service__c serv:serviceList){
                ReactivateServiceWrapper res=new ReactivateServiceWrapper();
                res.Id=serv.id;
                res.serviceNumber=serv.serviceMSISDN__c;
                res.subscriptionName=serv.csord__Subscription__r.name;
                res.subscriptionNumber=serv.csord__Subscription__r.csordtelcoa__subscription_number__c;
                res.disconnectedDate=serv.csord__Deactivation_Date__c;
                //Edge-207352 start
                Billing_Account__c ba=new Billing_Account__c();
                ba.id=serv.Billing_Account__c;
                ba.Billing_Account_Number__c=serv.Billing_Account__r.Billing_Account_Number__c;
                res.billingAcc=ba;
                 //Edge-207352 end
                //Edge-185856 start ----------------------
                system.debug('map--->'+addonOptionsMap);
                if(addonOptionsMap!=null && addonOptionsMap.containsKey(serv.csord__Subscription__r.csordtelcoa__subscription_number__c)){
                    res.addondetails=new List<ReactivateServiceWrapper>();
                    res.addondetails.addAll(addonOptionsMap.get(serv.csord__Subscription__r.csordtelcoa__subscription_number__c));
                }
                //Edge-185856 end ----------------------
                reactivateServicesList.add(res);
            }
        }
        System.debug('---reactivateServicesList---103'+reactivateServicesList);
        return reactivateServicesList;
    }
    
    //Edge-185856 start ----------------------
    private static List<String> getSubscriptionNum(List<csord__Service__c> serviceList){
        List<String> subsNumlist=new List<String>();
        for(csord__Service__c serv:serviceList){
            subsNumlist.add(serv.csord__Subscription__r.csordtelcoa__subscription_number__c);
        }
        return subsNumlist;
    }
    
    private static Map<String,Set<ReactivateServiceWrapper>> getAddonOptions(List<Attachment> attlist,ReactivateServicecategories__mdt reactiveServiceMdt){
        Map<String,Set<ReactivateServiceWrapper>> addonOptionsMap=new Map<String,Set<ReactivateServiceWrapper>>();
         String codesList=String.valueOf(reactiveServiceMdt.addOnSpecCodes__c);
         system.debug('codelist--->'+codesList);
         for(attachment att:attlist){
            if (att.Parent instanceof csord__service__c) {
                csord__service__c serv = att.Parent;
                Map<String, Object> updatedResults = (Map<String, Object>)JSON.deserializeUntyped(att.body.toString());
                List<Object>lstSpecifications=(List<Object>)updatedResults.get('specifications');
                for(Object spec:lstSpecifications){
                    Map<String, Object> specificationAttributes = (Map<String, Object>)spec;
                    if( specificationAttributes!=null && specificationAttributes.containskey('attributes')){
                        Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('attributes');
                        if(attributesMap!=null && attributesMap.containsKey('billDescription') 
                           && attributesMap.containskey('chargeId') 
                           && codesList.contains(String.valueOf(attributesMap.get('chargeId')))){
                            ReactivateServiceWrapper reswrapper=new ReactivateServiceWrapper();
                            reswrapper.AddonDescription=String.valueOf(attributesMap.get('billDescription'));
                            Set<ReactivateServiceWrapper> addondetails=new Set<ReactivateServiceWrapper>();
                            if(addonOptionsMap!=null && addonOptionsMap.containskey(serv.csord__Subscription__r.csordtelcoa__subscription_number__c))
                                addondetails.addAll(addonOptionsMap.get(serv.csord__Subscription__r.csordtelcoa__subscription_number__c));
                            addondetails.add(reswrapper);
                            addonOptionsMap.put(serv.csord__Subscription__r.csordtelcoa__subscription_number__c,addondetails);
                        }
                    }           
                }
            }
        }
        return addonOptionsMap;
    }
	//INC000095032613 start-----------
	private static List<csord__Service__c> getFinalServiceList(String subscriptionNumber,String offerId,ReactivateServicecategories__mdt reactiveServiceMdt){
		List<csord__Service__c> serviceList=new List<csord__Service__c>();
		Map<String,csord__Service__c> serviceMap=new Map<String,csord__Service__c>();
		Integer ndays=Integer.valueof(reactiveServiceMdt.last_n_days__c);
        Boolean Reactivate_CMP_To_AMToggle =  FeatureEligibilityChecker.determineFeatureEligiblity('Reactivate_CMP_To_AM',null); 
        List<PermissionSetAssignment> perAssignments = [SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment 
                                                        WHERE  PermissionSet.Name = 'ReactiveService_PS' AND AssigneeId=:UserInfo.getUserId()];
        //Added for DIGI-16925: CMP transfer to AM
        System.debug('---perAssignments---155'+perAssignments);
        if(perAssignments.isEmpty()){
            for(csord__Service__c serv:Model_service.getDisconnectedServicesFromSolution(subscriptionNumber,offerId,reactiveServiceMdt.prodSpecid__c,ndays)){
                serviceMap.put(serv.serviceMSISDN__c,serv);
            }
        }
        else if(Reactivate_CMP_To_AMToggle){
            for(csord__Service__c serv:Model_service.getDisconnectedServicesFromSolution(offerId,ndays)){
                serviceMap.put(serv.serviceMSISDN__c,serv);
                System.debug('---serviceMap---164'+serviceMap);   
            }
        }
		if(serviceMap!=null && !serviceMap.isEmpty()){
            System.debug('---serviceMap---168'+serviceMap);
			for(csord__Service__c serv:Model_service.getActiveMisDNService(serviceMap.keySet())){
                System.debug('---serv.serviceMSISDN__c---170'+serv.serviceMSISDN__c);
				if(serviceMap.containskey(serv.serviceMSISDN__c))
                    serviceMap.remove(serv.serviceMSISDN__c);
                System.debug('---serviceMap---173'+serviceMap);
			}
		}
        System.debug('---serviceMap---176'+serviceMap);
		serviceList=serviceMap.values();
        System.debug('---serviceList---178'+serviceList);
		return serviceList;
	}
	//INC000095032613 end-------------
    //Edge-185856 end ----------------------
}