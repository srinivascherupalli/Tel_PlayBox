/*************************************************************************************************
EDGE -93081
Class Name: NumberManagementComp
Description: Handler for Number Management UI on Product Basket 
Author:Sandip Deshmane
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
EDGE-134990   Sandip Deshmane     	10/2/2020     actionCode- CEASE is not passed in MO payload 
EDGE-142086	  Sandip Deshmane		25/4/2020	  Modified code for UX uplift.
***************************************************************************************************/

public with sharing class NumberManagementHandler {
    
    private static string [] PROD_SPEC_VALUES=new string[]{'DMCAT_ProductSpecification_000419','DMCAT_ProductSpecification_000420'};
    private static string [] NGUC_PROD_SPEC_VALUES=new string[]{'DMCAT_ProductSpecification_000871'};
    private static string NUMBER_STATUS = 'DISCONNECT PENDING';
    private static string STATUS_ACTIVE = 'ACTIVE';
    
        
    //Wrapper to get Number Object 
    public class NumberWrapper{
        @AuraEnabled
        public string numberId{get;set;}
        @AuraEnabled
        public String PhoneNumber{get;set;}
        @AuraEnabled
        public boolean IsSelected{get;set;}
        @AuraEnabled
        public String ProdConfigId{get;set;}
        @AuraEnabled
        public Boolean ProdConfigName{get;set;}
        @AuraEnabled
        public String ProdBasketId{get;set;}
        @AuraEnabled
        public String Type{get;set;}
        @AuraEnabled
        public String NumberRange{get;set;}
        @AuraEnabled
        public String Status{get;set;}
        //EDGE-142086 - Updated for UX Uplift
        @AuraEnabled
        public String IsPartOfRange{get;set;}
    }
    
    //Wrapper to pass UI input values
    public class SearchReservedNumberWrapper {
        @AuraEnabled
        public String selectedTabId{get;set;}
        @AuraEnabled
        public String basket_id{get;set;}
        @AuraEnabled
        public List<String> configId{get;set;}
        //EDGE-142086 - Updated for UX Uplift
        @AuraEnabled
        public String searchTerm{get;set;}
    }
/*-------------------------------------------------------- 
Method: getNumberList
Description: to get the list of reserved Number__C for given basketID and Product Configs selected.
Author:Sandip Deshmane 
--------------------------------------------------------*/
    @AuraEnabled
    public static List<NumberWrapper> getNumberList(SearchReservedNumberWrapper searchObj) {
        
        List<String> servList = new List<String>();
        Map<String,string> startRange = new Map<String,string>();
        String basketId = searchObj.basket_id;
        String selectedTab = searchObj.selectedTabId;
        List<String> configId = searchObj.configId;
        system.debug('Configids+' +configId);
        system.debug('basketId+' +basketId);
        system.debug('selectedTab+' +selectedTab);
        List< NumberWrapper> lstNumWrap= new List<NumberWrapper>();
        List<cscfga__Product_Configuration__c> pconfigList ;
        if(configId !=null || configId.size()>0){
            pconfigList = [SELECT Name,Id,Type__c,csordtelcoa__Replaced_Service__r.csordtelcoa__Service_Number__c FROM cscfga__Product_Configuration__c WHERE Id in : configId and cscfga__Product_Basket__c = :basketId and Type__c='Modify' and(cscfga__Product_Definition__r.product_Specification__c in :NGUC_PROD_SPEC_VALUES)];
        }
        system.debug('pconfigList+' +pconfigList);
        for(cscfga__Product_Configuration__c pc : pconfigList ){
            servList.add(pc.csordtelcoa__Replaced_Service__r.csordtelcoa__Service_Number__c);
        }
        system.debug('servList+' +servList);
        if(pconfigList!=NULL && pconfigList.size()>0){
            
            system.debug('Service Type+' +selectedTab);
            system.debug('Basket Id+' +basketId);
            List<Number__C> lstNumber=[select Id, Type__c,Mobile__c, Service_Id__c, Service_Number__c,Product_Configuration__c, Product_Configuration__r.Name,Basket__c,Start_Range__c,End_range__c,Number_Range__c,Status__c, is_Part_of_Range__c from Number__c where Mobile__c= :selectedTab and Service_Id__c IN :servList and Status__c = : STATUS_ACTIVE];
            system.debug('lstNumber+' +lstNumber);
            if(lstNumber!=null && lstNumber.size()>0){
                
                for(integer i=0; i<lstNumber.size();i++){
                    NumberWrapper numWrapObj= new NumberWrapper();
                    NumberWrapper detailList = new NumberWrapper();
                    //EDGE-142086 - Updated for UX Uplift
                    if(lstNumber[i].Start_Range__c!=null && lstNumber[i].End_range__c!=null){
                        if(!startRange.containsKey(lstNumber[i].Start_Range__c)){
                            startRange.put(lstNumber[i].Start_Range__c,lstNumber[i].End_range__c);
                            numWrapObj.PhoneNumber= lstNumber[i].Start_Range__c + ' - ' + lstNumber[i].End_range__c;
                            if(lstNumber[i].is_Part_of_Range__c){
                                numWrapObj.IsPartOfRange = 'Yes';
                            }else{
                                numWrapObj.IsPartOfRange = 'No';
                            }
                            detailList =getDetails(lstNumber[i],numWrapObj);
                            lstNumWrap.add(detailList);
                        }
                    }
                    if(lstNumber[i].Start_Range__c==null && lstNumber[i].End_range__c==null){
                        numWrapObj.PhoneNumber=lstNumber[i].Service_Number__c;
                        if(lstNumber[i].is_Part_of_Range__c){
                        	numWrapObj.IsPartOfRange = 'Yes';
                        }else{
                        	numWrapObj.IsPartOfRange = 'No';
                        }
                        detailList= getDetails(lstNumber[i],numWrapObj);
                        lstNumWrap.add(detailList);
                        system.debug('lstNumWrap+' +lstNumWrap);
                    }
                }
        
            }
        }
        system.debug('lstNumWrap+' +lstNumWrap);
        return lstNumWrap;
    }
/*-------------------------------------------------------- 
Method: getDetails
Description: Populating NumberWrapper by passing from Number Object
Author:Sandip Deshmane 
--------------------------------------------------------*/
    @AuraEnabled
    public static NumberWrapper getDetails(Number__C num, NumberWrapper numWrapObj){
        if(num!=null){
                numWrapObj.numberId=num.id;
                numWrapObj.Type=num.Type__c;
                    numWrapObj.IsSelected= num.Product_Configuration__c!=null? true: false;                
                    numWrapObj.ProdConfigId=num.Product_Configuration__c;  
                    numWrapObj.ProdConfigName=num.Product_Configuration__c!=null? true: false;
                    numWrapObj.ProdBasketId=num.Basket__c;
                    numWrapObj.NumberRange = num.Number_Range__c;
                    numWrapObj.Status = num.Status__c;
        }
        return numWrapObj;
    }
/*************************************************************************************************
Name : removeReservedNumbers
Description : Update status of selected Number to Pending Disconnection
Author: Sandip Deshmane
History : EDGE-134990   Sandip Deshmane  12/2/2020    Added Null Checks, Debug Statements and code to update Status in NumberManagementSchema.
***************************************************************************************************/
    @AuraEnabled
     public static List<NumberWrapper> removeReservedNumbers(String selectedNumList,String removalPoolList, String basketid){
        System.debug('in remove');
        List<NumberWrapper> selectedNums = new List<NumberWrapper>();
        List<NumberWrapper> removalPoolNums = new List<NumberWrapper>();
        List<NumberWrapper> lstNumWrap= new List<NumberWrapper>();
        if(String.isNotBlank(selectedNumList))
        selectedNums = (List<NumberWrapper>)System.JSON.deserialize(selectedNumList, List<NumberWrapper>.Class);
        if(String.isNotBlank(removalPoolList))
        removalPoolNums = (List<NumberWrapper>)System.JSON.deserialize(removalPoolList, List<NumberWrapper>.Class);
        System.debug('selectedNums: '+selectedNums);
        System.debug('removalPoolNums: '+removalPoolNums);
        Map<Id,NumberWrapper> numPoolMap = new Map<Id,NumberWrapper>();
        for(NumberWrapper num : removalPoolNums){
        	if(num != null){
            	numPoolMap.put(num.numberId, num);
            }
        }
         List<String> serviceNumber = new List<String>();
         List<Number__c> updatedNums = new List<Number__c>();
         //EDGE-142086 - Updated for UX Uplift
         List<String> startRange = new List<String> ();
         if(selectedNums!= null && selectedNums.size()>0){  
         	for(NumberWrapper selectedNum : selectedNums){
                if(selectedNum != null){
                	if(selectedNum.PhoneNumber.contains('-')){
                		String stRange = selectedNum.PhoneNumber.substringbefore(' -');
                    	startRange.add(stRange);
                        System.debug('startRange: '+startRange);
                	}
                	else{
                		serviceNumber.add(selectedNum.PhoneNumber);
             		}
            	}
         	}
         }
         System.debug('serviceNumber: '+serviceNumber);
         
        if(!selectedNums.isEmpty()){
        //EDGE-130353 : Removed Basket_Id filter from Query. 
        //EDGE-142086 - Added Start Range clause in the query.
        List<Number__c> numList = [SELECT ID,Type__c,Mobile__c, Service_Id__c, Service_Number__c,Product_Configuration__c, Product_Configuration__r.Name,Basket__c,Start_Range__c,End_range__c,Number_Range__c,Status__c, is_Part_of_Range__c FROM Number__c WHERE Service_Number__c IN :serviceNumber or Start_Range__c IN :startRange];
        System.debug('numList: '+numList);
            try{
            List<String> rootConfigId = new List<String>();
            //EDGE-153588 - Updated query to find PC based on Service Id
            List<String> rootServiceId = new List<String>();
            for(Number__c num: numList){
                rootConfigId.add(num.Product_Configuration__c);
                //EDGE-153588 - Updated query to find PC based on Service Id
                rootServiceId.add(num.Service_Id__c);
                num.Status__c = NUMBER_STATUS;
                if(numPoolMap.containsKey(num.ID)){
                    NumberWrapper numWrapObj= new NumberWrapper();
                    NumberWrapper updatedNumber = new NumberWrapper();
                    //EDGE-142086 - Updated for UX Uplift
                    if(num.Start_Range__c!=null && num.End_range__c!=null){
                        numWrapObj.PhoneNumber= num.Start_Range__c + ' - ' + num.End_range__c;
                        if(num.is_Part_of_Range__c){
                        	numWrapObj.IsPartOfRange = 'Yes';
                        }else{
                            numWrapObj.IsPartOfRange = 'No';
                        }
                        updatedNumber =getDetails(num,numWrapObj);
                        system.debug('updatedNumber+' +updatedNumber);
                        numPoolMap.put(num.ID, updatedNumber);
                    }
                    if(num.Start_Range__c==null && num.End_range__c==null){
                        numWrapObj.PhoneNumber=num.Service_Number__c;
                        if(num.is_Part_of_Range__c){
                        	numWrapObj.IsPartOfRange = 'Yes';
                        }else{
                        	numWrapObj.IsPartOfRange = 'No';
                        }
                        updatedNumber= getDetails(num,numWrapObj);
                        numPoolMap.put(num.ID, updatedNumber);
                        system.debug('updatedNumber+' +updatedNumber);
                        system.debug('numPoolMap+' +numPoolMap);
                    }
                }
                
                updatedNums.add(num);
            }
            System.debug('Root Configuration Ids'+rootConfigId);
            
            if(!updatedNums.isEmpty()){
                update updatedNums; 
                //EDGE-134990 - Added below code to sync the status in NumberManagement Schema
                List<cscfga__Product_Configuration__c> pconfigList = new List<cscfga__Product_Configuration__c>();
                if(serviceNumber != null && serviceNumber.size() > 0){
                    //EDGE-153588 - Updated query to find PC based on Service Id
                    //pconfigList = [select id from cscfga__product_configuration__c where csordtelcoa__Replaced_Product_Configuration__r.id in: rootConfigId and cscfga__Product_Basket__c =:basketid];
                    pconfigList = [select id from cscfga__product_configuration__c where csordtelcoa__Replaced_Service__r.csordtelcoa__Service_Number__c in: rootServiceId and cscfga__Product_Basket__c =:basketid];
                }
                System.debug('MAC Configuration List'+pconfigList);
                List<String> configIds = new List<String>();
                for(cscfga__Product_Configuration__c conf : pconfigList){
                    configIds.add(conf.id);
                }
                System.debug('MAC Configuration Ids'+configIds);
                NumberNCSHelper ncs = new NumberNCSHelper();
                Map<String, List<Attachment>> attachmentMap = new Map<String, List<Attachment>>();
                if(rootConfigId.size() > 0){
                    List<Attachment> attList = new List<Attachment>();
                    attList = [select Id,Body,ParentId FROM Attachment WHERE ParentId In: configIds and Name like '%NumberManagementv1%'];
                    for (Attachment att : attList) {
                        System.debug('Attachment Parent Id'+att.ParentId);
                        if (attachmentMap.containsKey(att.ParentId)) {
                            attachmentMap.get(att.ParentId).add(att);
                        } else {
                            attachmentMap.put(att.ParentId, new List<Attachment>{att});
                        }
                    }
                }
                //collect all info for OE
                List<NumberNCSDTO.Configuration> numberListold = new List<NumberNCSDTO.Configuration>();
                Map<String,List<NumberNCSDTO.Configuration>> configIdToNumberList = new Map<String,List<NumberNCSDTO.Configuration>>();
                for (String configId : configIds) {
                    if (!attachmentMap.containsKey(configId)) {
                        continue;
                    }
                    //we have attachments so add PC and initialize configIdToNumberList for it
                    configIdToNumberList.put(configId, new List<NumberNCSDTO.Configuration>());
                    for (attachment att : attachmentMap.get(configId)) {
                        String jsonStr = att.body.toString();
                        system.debug('jsonStr ==' + jsonStr);
                        NumberNCSDTO ncsDTO = NumberNCSDTO.parse(jsonStr);
                        for (NumberNCSDTO.Configuration config : ncsDTO.configurations) {
                            for(String removedNumber : serviceNumber){
                                if(config.FNN == removedNumber){
                                    if (config.status == Label.NumberStatus_ACTIVE || config.status == Label.NumberStatus_RESERVED) {
                                        config.status = Label.NumberStatus_DISCONNECT_PENDING;
                                    }
                                numberListold.add(config);
                                }
                            }
                        }
                        System.debug('Updated Attachment'+numberListold);
                        configIdToNumberList.get(configId).addAll(numberListold);
                        System.debug('Updated AttachmentList'+configIdToNumberList);
                    }
                }
                System.debug('rootConfigId'+configIds);
                System.debug('configIdToNumberList'+configIdToNumberList);
                ncs.updateExistingNCSbulk(configIds, 'NumberManagementv1', configIdToNumberList);
            }
            for(NumberWrapper numWrap : numPoolMap.values()){
                lstNumWrap.add(numWrap);
            }
                
        }
        catch(DmlException de){
            System.debug('DmlException:'+de.getStackTraceString());
        }
     }
         return lstNumWrap;
     }
/*-------------------------------------------------------- 
Method: addToNumberPool
Description: Add selected number to Number pool and remove from Existing numbers.
Author:Sandip Deshmane 
--------------------------------------------------------*/
    @AuraEnabled
         public static Map<String, List<NumberWrapper>> addToNumberPool(String selectedNumList, String existingNumList, String reservedNumList){
            List<NumberWrapper> existingNums = new List<NumberWrapper>();
            List<NumberWrapper> selectedNums = new List<NumberWrapper>();
            List<NumberWrapper> reservedNums = new List<NumberWrapper>();
            List<NumberWrapper> newReservedNums = new List<NumberWrapper>();
            
            if(String.isNotBlank(selectedNumList))
            selectedNums = (List<NumberWrapper>)System.JSON.deserialize(selectedNumList, List<NumberWrapper>.Class);
            if(String.isNotBlank(existingNumList))
            existingNums = (List<NumberWrapper>)System.JSON.deserialize(existingNumList, List<NumberWrapper>.Class);
            if(String.isNotBlank(reservedNumList))
            reservedNums = (List<NumberWrapper>)System.JSON.deserialize(reservedNumList, List<NumberWrapper>.Class);
            
             if(selectedNums != null){
                 for(NumberWrapper newNumber : selectedNums){
                    existingNums.add(newNumber);
                }
             }
             Map<String, NumberWrapper> reservedNumMap = new Map<String, NumberWrapper>();
             Map<String, List<NumberWrapper>> allNumMap = new Map<String, List<NumberWrapper>>();
             for(NumberWrapper reservedNum : reservedNums){
                 reservedNumMap.put(reservedNum.numberId, reservedNum);
             }
             for(NumberWrapper existingNum : existingNums){
                 if(reservedNumMap.containsKey(existingNum.numberId)){
                     reservedNumMap.remove(existingNum.numberId);
                 }
             }
             
             for(NumberWrapper remNumber : reservedNumMap.values()){
                 newReservedNums.add(remNumber);
             }
             allNumMap.put('NumbersToRemove', existingNums);
             allNumMap.put('NumbersRemaining', newReservedNums);    
             return allNumMap;
         }
     
//EDGE-142086 - Commented for UX Uplift
/*-------------------------------------------------------- 
Method: removeFromNumberPool
Description: Remove selected Numbers from Number Pool and add it to ExistingNumbers
Author:Sandip Deshmane 
--------------------------------------------------------
    @AuraEnabled
         public static Map<String, List<NumberWrapper>> removeFromNumberPool(String selectedNumList, String removalPoolList, String reservedNumList){
            List<NumberWrapper> removalPool = new List<NumberWrapper>();
            List<NumberWrapper> selectedNums = new List<NumberWrapper>();
            List<NumberWrapper> reservedNums = new List<NumberWrapper>();
            List<NumberWrapper> newRemovalNums = new List<NumberWrapper>();
            
            if(String.isNotBlank(selectedNumList))
            selectedNums = (List<NumberWrapper>)System.JSON.deserialize(selectedNumList, List<NumberWrapper>.Class);
            if(String.isNotBlank(removalPoolList))
            removalPool = (List<NumberWrapper>)System.JSON.deserialize(removalPoolList, List<NumberWrapper>.Class);
            if(String.isNotBlank(reservedNumList))
            reservedNums = (List<NumberWrapper>)System.JSON.deserialize(reservedNumList, List<NumberWrapper>.Class);
            
             if(selectedNums != null){
                 for(NumberWrapper newNumber : selectedNums){
                    reservedNums.add(newNumber);
                }
             }
             Map<String, NumberWrapper> removalPoolMap = new Map<String, NumberWrapper>();
             Map<String, List<NumberWrapper>> allNumMap = new Map<String, List<NumberWrapper>>();
             for(NumberWrapper removalNum : removalPool){
                 removalPoolMap.put(removalNum.numberId, removalNum);
             }
             for(NumberWrapper selectedNum : selectedNums){
                 if(removalPoolMap.containsKey(selectedNum.numberId)){
                     removalPoolMap.remove(selectedNum.numberId);
                 }
             }
             
             for(NumberWrapper remNumber : removalPoolMap.values()){
                 newRemovalNums.add(remNumber);
             }
             allNumMap.put('NumbersReserved', reservedNums);
             allNumMap.put('NumbersRemaining', newRemovalNums);    
             return allNumMap;
         }*/
/*-------------------------------------------------------- 
EDGE-142086
Method: getFilteredNumberList
Description: To get the filtered list of reserved Number__C based on Filter String for given basketID and Product Configs selected.
Author:Sandip Deshmane 
--------------------------------------------------------*/
    @AuraEnabled
    public static List<NumberWrapper> getFilteredNumberList(SearchReservedNumberWrapper searchObj) {
        
        List<String> servList = new List<String>();
        Map<String,string> startRange = new Map<String,string>();
        String basketId = searchObj.basket_id;
        String searchTerm = searchObj.searchTerm;
        List<String> configId = searchObj.configId;
        system.debug('Configids+' +configId);
        system.debug('basketId+' +basketId);
        system.debug('searchTerm+' +searchTerm);
        List< NumberWrapper> lstNumWrap= new List<NumberWrapper>();
        List<cscfga__Product_Configuration__c> pconfigList ;
        if(configId !=null || configId.size()>0){
            pconfigList = [SELECT Name,Id,Type__c,csordtelcoa__Replaced_Service__r.csordtelcoa__Service_Number__c FROM cscfga__Product_Configuration__c WHERE Id in : configId and cscfga__Product_Basket__c = :basketId and Type__c='Modify' and(cscfga__Product_Definition__r.product_Specification__c in :NGUC_PROD_SPEC_VALUES)];
        }
        system.debug('pconfigList+' +pconfigList);
        for(cscfga__Product_Configuration__c pc : pconfigList ){
            servList.add(pc.csordtelcoa__Replaced_Service__r.csordtelcoa__Service_Number__c);
        }
        system.debug('servList+' +servList);
        if(pconfigList!=NULL && pconfigList.size()>0){
            
            system.debug('Basket Id+' +basketId);
            List<Number__c> lstNumber = new List<Number__c>();
            if(searchTerm.length() > 0){
                searchTerm = searchTerm+'*';
				List<List<Number__c>> filterList = [Find : searchTerm IN ALL FIELDS RETURNING Number__c(Id, Type__c,Mobile__c, Service_Id__c, Service_Number__c,Product_Configuration__c, Product_Configuration__r.Name,Basket__c,Start_Range__c,End_range__c,Number_Range__c,Status__c, is_Part_of_Range__c where Mobile__c='Fixed' and Service_Id__c IN :servList and Status__c = :STATUS_ACTIVE)];
            	if(filterList != null && filterList.size()>0){
                    system.debug('filterList+' +filterList);
                	lstNumber = filterList[0];
                }
            }else{
                lstNumber=[select Id, Type__c,Mobile__c, Service_Id__c, Service_Number__c,Product_Configuration__c, Product_Configuration__r.Name,Basket__c,Start_Range__c,End_range__c,Number_Range__c,Status__c, is_Part_of_Range__c from Number__c where Mobile__c= 'Fixed' and Service_Id__c IN :servList and Status__c = : STATUS_ACTIVE];
            }
            
            if(lstNumber!=null && lstNumber.size()>0){
                
                for(integer i=0; i<lstNumber.size();i++){
                    NumberWrapper numWrapObj= new NumberWrapper();
                    NumberWrapper detailList = new NumberWrapper();
                    if(lstNumber[i].Start_Range__c!=null && lstNumber[i].End_range__c!=null){
                        if(!startRange.containsKey(lstNumber[i].Start_Range__c)){
                            startRange.put(lstNumber[i].Start_Range__c,lstNumber[i].End_range__c);
                            numWrapObj.PhoneNumber= lstNumber[i].Start_Range__c + ' - ' + lstNumber[i].End_range__c;
                            if(lstNumber[i].is_Part_of_Range__c){
                                numWrapObj.IsPartOfRange = 'Yes';
                            }else{
                                numWrapObj.IsPartOfRange = 'No';
                            }
                            detailList =getDetails(lstNumber[i],numWrapObj);
                            lstNumWrap.add(detailList);
                        }
                    }
                    if(lstNumber[i].Start_Range__c==null && lstNumber[i].End_range__c==null){
                        numWrapObj.PhoneNumber=lstNumber[i].Service_Number__c;
                        if(lstNumber[i].is_Part_of_Range__c){
                        	numWrapObj.IsPartOfRange = 'Yes';
                        }else{
                        	numWrapObj.IsPartOfRange = 'No';
                        }
                        detailList= getDetails(lstNumber[i],numWrapObj);
                        lstNumWrap.add(detailList);
                        system.debug('lstNumWrap+' +lstNumWrap);
                    }
                }
        
            }
        }
        system.debug('lstNumWrap+' +lstNumWrap);
        return lstNumWrap;
    }
}