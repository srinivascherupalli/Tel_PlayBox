/********************************************************************************************************************************
Class Name      :   NumberUtil
Test Class     :   NumberUtilTest
==================================================================================================================================
Change.No.    Developer Name        Date      Story Description
1.            Vaibhav Deshpande    07/10/2019      EDGE-115655  Enable mobile / fixed number state lifecycle progress
2.            Sandip Deshmane       17/01/2020      EDGE-92551 Add Removed number to BDS paylot with action code - cease
3.            Sandip Deshmane        13/2/2020      EDGE-132208 Added additional condition in query to update the number records in Removal scenario
4.            Sandip Deshmane       20/2/2020       EDGE-136242 Refactoring of existing UpdateNumberStatus method to handle bulkification
5.            Manish                02/06/2020      EDGE-152563 & EDGE-152814
6.            Prajakta              10/06/2020       EDGE-154773
7.          Pawan                   15/04/2021      EDGE-213541 : Setting SimAvailability blank only when subscription reaches terminal status
***********************************************************************************************************************************/

Public with sharing class NumberUtil{
    // public void NumberUtil(){}
    // EDGE - 136242 Removed code from below method to move it to Refactored bulkified method - UpdateNumberStatusBulkified and getNumbersForUpdate
    public static void UpdateNumberStatus(String ServiceNumber, String productId,String subscriptionNumber,String status){
        List<Number__c> numActive=new List<Number__c>();
        List<Number__c> numList=new  List<Number__c>();
        Map<ID,Number__c> numActiveMap=new  Map<ID,Number__c>();
        List<csord__Service__c> servList=[select id,Scenario_Type__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c,csord__Subscription__r.oldServiceMSISDN__c,csord__Subscription__r.serviceMSISDN__c,csord__Service__c from csord__Service__c where csord__Subscription__r.csordtelcoa__Subscription_Number__c=:subscriptionNumber AND csord__Service__c=null];
        //Added EDGE-119913
        if(productId !=null){
            productId = productId.removeEnd('_Fulfilment');
            System.debug(productId +'---'+subscriptionNumber);}
        if((String.isBlank(ServiceNumber) || ServiceNumber==null) && (string.isNotBlank(productId) || productId!=null) && (string.isNotBlank(subscriptionNumber) || subscriptionNumber!=null) )
        {
             
                numList=[Select id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c From Number__c Where (Product_ID__c=:productId AND Subscription_number__c=:subscriptionNumber) AND (Status__c!='Active' AND status__c!='Inactive')];
            
                
        }else if((String.isBlank(ServiceNumber) || ServiceNumber==null) && (String.isBlank(productId) || productId==null) && (string.isNotBlank(subscriptionNumber) || subscriptionNumber!=null))
        {
              
                numList=[Select id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c From Number__c Where Subscription_number__c=:subscriptionNumber AND (Status__c!='Active' AND status__c!='Inactive')];
            
        }
        for(Number__c numb:numList)
        {
            if(status=='Active') 
            {
                for(csord__Service__c serv:servList)
                {
                    if(serv.Scenario_Type__c=='Change of Mobile Number' && serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c==numb.Subscription_number__c)
                    {
                        if(serv.csord__Subscription__r.oldServiceMSISDN__c==numb.Service_Number__c)
                        {
                            numb.Status__c='Replaced';numActive.add(numb);
                        }else if(serv.csord__Subscription__r.serviceMSISDN__c==numb.Service_Number__c)
                        {
                            numb.Status__c=status;  numActive.add(numb);
                        }
                    }else{
                        numb.Status__c=status; numActive.add(numb);
                    }
                }
            }else {
                System.debug('status '+status);
               //EDGE-132208 - Added confitions to set the Number Status based on Previous Status and Notification Status.
               if(numb.Status__c=='RESERVED'){
                    numb.Status__c=status; 
                    numActive.add(numb);    
               }
               else if(numb.Status__c=='DISCONNECT PENDING'){
                    numb.Status__c='Disconnect in Progress'; 
                    numActive.add(numb); 
               }
               else if(numb.status__c=='Disconnect In Progress'){
                    numb.Status__c='Disconnected'; 
                    numActive.add(numb);
               }
               else if(numb.status__c=='Provisioning In Progress'){
                    numb.Status__c=status; 
                    numActive.add(numb);
               }
               else if(numb.status__c=='Provisioned'){
                    numb.Status__c=status; 
                    numActive.add(numb);    
               }
              else  if(numb.status__c=='Disconnected'){
                    numb.Status__c='InActive'; 
                    numActive.add(numb);    
              }
            else {
                numb.Status__c=status;
            }
         } 
        }
        numActiveMap.putAll(numActive);
        if(numActiveMap.size()>0)
        {
            Update numActiveMap.values();
        }
    }
    public static void UpdateNumberStatus(String productId,String subscriptionNumber,String status){
        String svcNumber=null; String prodId=productId;String subNumber=subscriptionNumber;String numStatus=status;
        UpdateNumberStatus(svcNumber, prodId,subNumber,numStatus);
    }
    public static void UpdateNumberStatus(String subscriptionNumber,String status){
        String svcNumber=null; String prodId=null;String subNumber=subscriptionNumber;String numStatus=status;
        UpdateNumberStatus(svcNumber, prodId,subNumber,numStatus);
    }
    /*********************** 
Method: getNumbersforBDS
Descritpion: fetch numbers from Number Object based on different configurationIds
Story: EDGE-92551
Author: Sandip Deshmane
************************/
    public static List<Number__c> getNumbersforBDS(String srvNumber){
        try{
            System.debug('srvNumber: '+srvNumber);
            List<csord__Service__c> serviceList = [Select Id,csordtelcoa__Product_Configuration__c from csord__Service__c where csordtelcoa__Service_Number__c =:srvNumber order by createddate desc limit 1];
            System.debug('serviceList: '+serviceList);
            cscfga__Product_Configuration__c config = [Select Id,csordtelcoa__Replaced_Product_Configuration__c from cscfga__Product_Configuration__c where id = :serviceList[0].csordtelcoa__Product_Configuration__c];
            String configId = config.Id;
            System.debug('config: '+config);
            String replacedconfigId = NULL;
            if(config.csordtelcoa__Replaced_Product_Configuration__c != NULL){
                replacedconfigId = config.csordtelcoa__Replaced_Product_Configuration__c;
            }
            System.debug('replacedconfigId: '+replacedconfigId);
            Map<String,List<Number__c>> fnnMap = new Map<String,List<Number__c>>(); //EDGE-154773
            List<Number__c> fnnSet = new List<Number__c>();
            fnnMap = getNumbers(configId);
            for(String key : fnnMap.keySet()){
                fnnSet.addAll(fnnMap.get(key));
            }
            System.debug('fnnSet: '+fnnSet);
            //for modify Order
            if(replacedconfigId != NULL){
                Map<String,List<Number__c>> replacedFnnMap = new Map<String,List<Number__c>>();
                List<Number__c> replacedFnnSet = new List<Number__c>(); //EDGE-154773
                replacedFnnMap = getNumbers(replacedconfigId);
                System.debug('replacedFnnMap: '+replacedFnnMap);
                for(String key : replacedFnnMap.keySet()){
                    replacedFnnSet.addAll(replacedFnnMap.get(key));
                }
                System.debug('replacedFnnSet: '+replacedFnnSet);
                //EDGE-154773
                //Check if new config has numbers else send removed bumbers
               /* if(fnnMap != NULL && fnnMap.size()>0){
                    fnnSet.removeAll(replacedFnnSet);
                }else{
                    replacedFnnSet.addAll(replacedFnnMap.get(Label.NumberStatus_DISCONNECT_IN_PROGRESS));
                    fnnSet.addAll(replacedFnnSet);
                }*/
                //EDGE-154773
                if(!replacedFnnSet.isEmpty()){
                fnnSet.addAll(replacedFnnSet);}
            }
            System.debug('fnnSet: '+fnnSet);
            return fnnSet;
        }
        catch(Exception e){
            system.debug('Exception in getNumbersforBDS ' + e);
            return null;
        }
    }
    
    /*********************** 
    Method: getNumbers
    Descritpion: fetch numbers from Number Object based on different status
    Story: EDGE-92551
    Author: Sandip Deshmane
    ************************/
    public static Map<String,List<Number__c>> getNumbers(String UCEConfigId){
        Map<String,List<Number__c>> numberMap = new Map<String,List<Number__c>>();
        
        List<Number__c> ProvisionedNumbers = new List<Number__c>();
        List<Number__c> DisconnectNumbers = new List<Number__c>();
       
        try{
            for(Number__c numberRec : [Select Service_Number__c, Mobile__c, Service_Id__c, Status__c, Start_Range__c, End_range__c, Product_Configuration__r.Id,toBeCancelled__c from Number__c where Product_Configuration__r.Id =: UCEConfigId]){
                ////EDGE-154773
                  if(numberRec.status__c == 'Provisioned'){
                     ProvisionedNumbers.add(numberRec);    
                    System.debug('ProvisionedNumbers::'+ProvisionedNumbers);
                }
                else if(numberRec.status__c.equalsIgnoreCase('Disconnected')){ //EDGE-152563 & EDGE-152814
                     DisconnectNumbers.add(numberRec);  
                    System.debug('DisconnectNumbers::'+DisconnectNumbers);
                }
            }
            ////EDGE-154773
            if(ProvisionedNumbers != null && ProvisionedNumbers.size()>0){
                numberMap.put('Provisioned',ProvisionedNumbers);
            }
            if(DisconnectNumbers != null && DisconnectNumbers.size()>0){ ////EDGE-152563 & EDGE-152814
                numberMap.put('Disconnected',DisconnectNumbers);
            }
            
        }catch(Exception e){
            system.debug('Exception in getNumbersFromNCS ' + e);
        }
        return numberMap;
    }
    
    /********************************
    *Method: getNumberforUpdates
    * Description : Refactored this method to bulkify the Number status update called from ManageOrderNotificationService.checkUCCompletion method.
    * This bulkification only covers Number Removal for NGUC
    * Story : EDGE-136242
    * Author : Sandip Deshmane/Sunil Nangare
    ******************************************/    
     public static Map<String, List<Number__c>> getNumberforUpdates(List<String> prodIdList,List<String> subNumist){
         System.debug('subNumist::'+subNumist );
        List<Number__c> numActiveList=new List<Number__c>();
        List<Number__c> numberList=new  List<Number__c>();
        List<Number__c> lstNumber=new  List<Number__c>();
        Map<String, List<Number__c>> mapNumList = new Map<String, List<Number__c>>();
        // Two diff queries based on prodIdList (Gnana)
        if(prodIdList != null && prodIdList.size() > 0){
            numberList = [Select id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c From Number__c Where (Product_ID__c IN:prodIdList AND Subscription_number__c IN:subNumist)];
        }
        else{
            numberList = [Select id,name,Service_Number__c,Status__c,Subscription_number__c,Product_ID__c From Number__c Where Subscription_number__c IN:subNumist];
        }
        
        System.debug('List of Numbers'+numberList );
        if(numberList!= null && numberList.size() > 0){
            for(Number__c num :numberList){
                if(mapNumList.containsKey(num.Subscription_number__c)){ 
                    lstNumber = mapNumList.get(num.Subscription_number__c);
                    lstNumber.add(num);
                    mapNumList.put(num.Subscription_number__c,lstNumber);
                } 
                else{
                    mapNumList.put(num.Subscription_number__c,new List<Number__c>{num});
                }
            }
        }
        return mapNumList;
    }
    
    
    /********************************
    *Method: UpdateNumberStatusBulkified
    * Description : Refactored this method to bulkify the Number status update called from ManageOrderNotificationService.checkUCCompletion method.
    * This bulkification only covers Number Removal for NGUC
    * Story : EDGE-136242
    * Author : Sandip Deshmane/Sunil Nangare
    ******************************************/        
    public static void UpdateNumberStatusBulkified(List<String> prodIdList, List<String> subNumList, String status){
       /* Map<String, List<Number__C>> numberMap = new Map<String, List<Number__C>>();
        List<Number__c> activeNumbers = new List<Number__C>();
        List<csord__Service__c> serviceLst=[select id,Scenario_Type__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c,csord__Subscription__r.oldServiceMSISDN__c,csord__Subscription__r.serviceMSISDN__c,csord__Service__c from csord__Service__c where csord__Subscription__r.csordtelcoa__Subscription_Number__c IN:subNumList AND csord__Service__c=null];
        // removing prodIdList condition here and rechecking in getNumberforUpdates method (Gnana)
        // because using the same method "getNumberforUpdates" for both with/without prodIdList
        if(/*(prodIdList != null || prodIdList.size() > 0) &&subNumList != null || subNumList.size() > 0){
            //numberMap = getNumberforUpdates(prodIdList,subNumList);
        }
        /*System.debug('numberMap-->'+numberMap);
        
        if(status=='Provisioning In Progress' && numberMap.size() > 0){
            if(numberMap.containsKey('DISCONNECT PENDING')){
                for(Number__c num : numberMap.get('DISCONNECT PENDING')){
                    num.status__c = 'DISCONNECT IN PROGRESS';
                    activeNumbers.add(num);
                    system.debug('num.status__c-->'+num.status__c);
                }
                system.debug('num.status__c');
            }
            if(numberMap.containsKey('RESERVED')){
                for(Number__c num : numberMap.get('RESERVED'))
                {
                    num.status__c = status;
                    activeNumbers.add(num);
                }       
            }            
        }else if(status=='Provisioned' && numberMap.size() > 0){
            if(numberMap.containsKey('Provisioning In Progress')){
                for(Number__c num : numberMap.get('Provisioning In Progress')){
                    num.status__c = status;
                    activeNumbers.add(num);
                }    
            }
            if(numberMap.containsKey('DISCONNECT IN PROGRESS')){
                for(Number__c num : numberMap.get('DISCONNECT IN PROGRESS')){
                    num.status__c = 'DISCONNECTED';
                    activeNumbers.add(num);
                }    
            }
        }else if(status=='Bill Readiness In Progress' && numberMap.size() > 0){
            if(numberMap.containskey('Provisioned')){
                for(Number__c num : numberMap.get('Provisioned')){
                    num.status__c = status;
                    activeNumbers.add(num);
                }    
            }
        }else if(status=='Active' && numberMap.size() > 0){
            if(numberMap.containsKey('Bill Readiness In Progress')){
                for(Number__c num : numberMap.get('Bill Readiness In Progress')){
                    num.status__c = status;
                    activeNumbers.add(num);
                }    
            }
            // Added below block to cover Active Status (Gnana)
            if(numberMap.containsKey('ACTIVE')){
                for(Number__c num : numberMap.get('ACTIVE')){
                    num.status__c = status;
                    activeNumbers.add(num);
                }    
            }
        }else if(status=='Disconnect In Progress' && numberMap.size() > 0){
            if(numberMap.containsKey('ACTIVE')){
                for(Number__c num : numberMap.get('ACTIVE')){
                    num.status__c = status;
                    activeNumbers.add(num);
                }    
            }
        }else if(status=='Disconnected' && numberMap.size() > 0){
            if(numberMap.containsKey('DISCONNECT IN PROGRESS')){
                for(Number__c num : numberMap.get('DISCONNECT IN PROGRESS')){
                    num.status__c = 'DISCONNECTED';
                    activeNumbers.add(num);
                }    
            }
        }else if(status=='Inactive' && numberMap.size() > 0){
            if(numberMap.containsKey('DISCONNECTED')){
                for(Number__c num : numberMap.get('DISCONNECTED')){
                    num.status__c = status;
                    activeNumbers.add(num);
                }    
            }
        }
        
        // This block is to check for Replace scenario - Start (Gnana) 
        if(status=='Active'){
            for(csord__Service__c serv : serviceLst){
                for(String stats : numberMap.keySet()){
                    for(Number__c num : numberMap.get(stats)){
                        if(serv.Scenario_Type__c=='Change of Mobile Number' && serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c==num.Subscription_number__c){
                            if(serv.csord__Subscription__r.oldServiceMSISDN__c==num.Service_Number__c)
                            {
                                num.Status__c='Replaced';
                                activeNumbers.add(num);
                                
                            }// Commented this because, we will use the Status which was set in above block
                            /*else if(serv.csord__Subscription__r.serviceMSISDN__c==num.Service_Number__c) 
                            {
                                num.Status__c=status; 
                                activeNumbers.add(num);
                            }*/
                        //}// Commented this because, we will use the Status which was set in above block
                        /*else{
                            num.Status__c=status; 
                            activeNumbers.add(num);
                        }*//*
                    }  
                }
            }
        }
        // This block is to check for Replace scenario - End (Gnana)
        
        try{
            if(activeNumbers.size()>0){
                Update activeNumbers;
                system.debug('activeNumbers-->'+activeNumbers);
            }
        }catch(Exception e){
            System.debug('Exception:' + e.getTypeName() +','+ e.getMessage() +','+  e.getLineNumber());
    }*/}
    
    
    public static void UpdateNumberStatusBulkified2(List<String> prodIdList, Map<String,List<Number__c>> mapStatusSubNum){
        System.debug('prodIdList...'+prodIdList);
        System.debug('mapStatusSubNum...'+mapStatusSubNum.values());
       // List<String> subNumList = new List<String>();
        
        /*for(String status : mapStatusSubNum.keySet()){
            subNumList.addAll(mapStatusSubNum.get(status));
        }*/
       // Map<String, List<Number__c>> subnumberMap = new Map<String, List<Number__c>>();
       
       ////EDGE-154773
        Map<Id,Number__c> activeNumbers = new Map<Id,Number__c> ();
        List<String> numservList = new List<String>();
         for(string status : mapStatusSubNum.keyset()){
             List<Number__c> numbList = mapStatusSubNum.get(status);
             for(Number__c no :numbList){
             numservList.add(no.Service_Id__c);}
         }
        
         
        List<csord__Service__c> serviceLst=[select id,Scenario_Type__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c,csord__Subscription__r.oldServiceMSISDN__c,csord__Subscription__r.serviceMSISDN__c,csord__Service__c,csordtelcoa__Service_Number__c from csord__Service__c where csordtelcoa__Service_Number__c IN:numservList AND csord__Service__c=null];
        // removing prodIdList condition here and rechecking in getNumberforUpdates method (Gnana)
        // because using the same method "getNumberforUpdates" for both with/without prodIdList
        //if(/*(prodIdList != null || prodIdList.size() > 0) &&*/ subNumList != null || subNumList.size() > 0){
          //  subnumberMap = getNumberforUpdates(prodIdList,subNumList);
        //}
        
       /* for(String status : mapStatusSubNum.keySet()){
            for(String subs : mapStatusSubNum.get(status)){
                List<Number__c> numList = subnumberMap.get(subs);
                if(numList != null) {   //Added null Check Pawan
                for(Number__c num :numList){
                    num.status__c = status;
                    activeNumbers.put(num.id,num);
                }
                
                }*/    
         
        ////EDGE-154773      
        if(!mapStatusSubNum.isEmpty()){
        for(String status : mapStatusSubNum.keyset()){
            
            List<Number__c> numList = mapStatusSubNum.get(status);
            if(!numList.isEmpty()){
            for(Number__c num :numList){
                num.status__c = status;
                //EDGE-213541 : making SImAvailibity blank only when subscription reaches terminal status
                if(status != null && String.isNotBlank(status) && status.equalsIgnoreCase('Active') ){
                num.SimAvailabilityType__c = '';    
                }
                activeNumbers.put(num.id,num);
              
                
               /* if(status=='Provisioning In Progress' && numberMap.size() > 0){
                    if(numberMap.containsKey('DISCONNECT PENDING')){
                        for(Number__c num : numberMap.get('DISCONNECT PENDING')){
                            if(num.Subscription_number__c == subs){
                                num.status__c = 'DISCONNECT IN PROGRESS';
                                activeNumbers.add(num);
                                system.debug('num.status__c-->'+num.status__c); 
                            }
                        }
                        system.debug('num.status__c');
                    }
                    if(numberMap.containsKey('RESERVED')){
                        for(Number__c num : numberMap.get('RESERVED'))
                        {
                            if(num.Subscription_number__c == subs){
                                num.status__c = status;
                                activeNumbers.add(num);
                            }
                        }       
                    }            
                }else if(status=='Provisioned' && numberMap.size() > 0){
                    if(numberMap.containsKey('Provisioning In Progress')){
                        for(Number__c num : numberMap.get('Provisioning In Progress')){
                            if(num.Subscription_number__c == subs){
                                num.status__c = status;
                                activeNumbers.add(num);
                            }
                        }    
                    }
                    if(numberMap.containsKey('DISCONNECT IN PROGRESS')){
                        for(Number__c num : numberMap.get('DISCONNECT IN PROGRESS')){
                            if(num.Subscription_number__c == subs){
                                num.status__c = 'DISCONNECTED';
                                activeNumbers.add(num);
                            }
                        }    
                    }
                }else if(status=='Bill Readiness In Progress' && numberMap.size() > 0){
                    if(numberMap.containskey('Provisioned')){
                        for(Number__c num : numberMap.get('Provisioned')){
                            if(num.Subscription_number__c == subs){
                                num.status__c = status;
                                activeNumbers.add(num);
                            }
                        }    
                    }
                }else if(status=='Active' && numberMap.size() > 0){
                    if(numberMap.containsKey('Bill Readiness In Progress')){
                        for(Number__c num : numberMap.get('Bill Readiness In Progress')){
                            if(num.Subscription_number__c == subs){
                                num.status__c = status;
                                activeNumbers.add(num);
                            }
                        }    
                    }
                    // Added below block to cover Active Status (Gnana)
                    if(numberMap.containsKey('ACTIVE')){
                        for(Number__c num : numberMap.get('ACTIVE')){
                            if(num.Subscription_number__c == subs){
                                num.status__c = status;
                                activeNumbers.add(num);
                            }
                        }    
                    }
                }else if(status=='Disconnect In Progress' && numberMap.size() > 0){
                    if(numberMap.containsKey('ACTIVE')){
                        for(Number__c num : numberMap.get('ACTIVE')){
                            if(num.Subscription_number__c == subs){
                                num.status__c = status;
                                activeNumbers.add(num);
                            }
                        }    
                    }
                }else if(status=='Disconnected' && numberMap.size() > 0){
                    if(numberMap.containsKey('DISCONNECT IN PROGRESS')){
                        for(Number__c num : numberMap.get('DISCONNECT IN PROGRESS')){
                            if(num.Subscription_number__c == subs){
                                num.status__c = 'DISCONNECTED';
                                activeNumbers.add(num);
                            }
                        }    
                    }
                }else if(status=='Inactive' && numberMap.size() > 0){
                    if(numberMap.containsKey('DISCONNECTED')){
                        for(Number__c num : numberMap.get('DISCONNECTED')){
                            if(num.Subscription_number__c == subs){
                                num.status__c = status;
                                activeNumbers.add(num);
                            }
                        }    
                    }
                }*/
            
            
            // This block is to check for Replace scenario - Start (Gnana) 
            if(status=='Active'){
                for(csord__Service__c serv : serviceLst){
                   if(serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c != null ){   //Added null Check Pawan                
                       
                            if(serv.Scenario_Type__c=='Change of Mobile Number' && serv.csord__Subscription__r.csordtelcoa__Subscription_Number__c==num.Subscription_number__c){
                                if(serv.csord__Subscription__r.oldServiceMSISDN__c==num.Service_Number__c)
                                {
                                    num.Status__c='Replaced'; num.SimAvailabilityType__c = ''; activeNumbers.put(num.id,num);
                                    
                                }
                            }
                            
                    }                       
                    
                }
            }
          // This block is to check for Replace scenario - End (Gnana) 
        }}
            }}
        try{
            if(!activeNumbers.isEmpty()){
                Update activeNumbers.values();
                system.debug('activeNumbers-->'+activeNumbers.values());
            }
        }catch(Exception e){
            System.debug('Exception:' + e.getTypeName() +','+ e.getMessage() +','+  e.getLineNumber());
        }
    }
    
}