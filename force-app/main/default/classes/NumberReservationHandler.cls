/*************************************************************************************************
EDGE -93081
Name: NumberReservationBaseComp
Description: Handler for Number reservation UI on Product Basket 
Author:Ila/Mahima 

-------
History
------- 
VERSION     AUTHOR          DATE            DETAIL
-------     ------          -----           ---------
1           Abinash         12/18/2019      (19.17)EDGE-127105 <Number Management> Display number is “assigned” in 
the UI for the existing mobile subscriptions during MAC order
2           Abinash         03/02/2020      (20.03)EDGE-92021 /EDGE-68661 <LRM><UNMS> Search and Reserve Next Available MSISDN
                                            <Interface Story> CS->LRM [UNMS] to enable bulk reserve of mobile numbers
***************************************************************************************************/

public with sharing class NumberReservationHandler {
    //private static string TYPE_NEW='New';
    private static string tYPEPORT='Port In';
    private static string [] pRODSPECVALUES=new string[]{'DMCAT_ProductSpecification_000419','DMCAT_ProductSpecification_000420'};
        //private static string [] NGUC_PROD_SPEC_VALUES=new string[]{'DMCAT_ProductSpecification_000871'};
            
             
            //Wrapper to get PC for basket
            /*public class ProdConfigWrapper{
                @AuraEnabled
                public String productConfig{get;set;}
                @AuraEnabled
                public Boolean isSelected{get;set;}
                @AuraEnabled
                public Boolean isDisabled{get;set;}
                //EDGE-96503-Mahima-start
                @AuraEnabled
                public string AssignedNumber{get;set;}
                @AuraEnabled
                public string configId{get;set;}
                @AuraEnabled
                public string Model{get;set;}
                @AuraEnabled
                public string Color{get;set;}
                @AuraEnabled
                public string PlanName{get;set;}
                @AuraEnabled
                public string BasketName{get;set;}
                @AuraEnabled
                public string Solution{get;set;}
                @AuraEnabled
                public string SerialNumber{get;set;}
                @AuraEnabled
                public string Quantity{get;set;}
                
                //EDGE-96503-Mahima-end
                //Sandip Updated
                ProdConfigWrapper(String productConfig,Boolean isSelected,Id ConfigId, string numberAssign, string model, string plan, string color, string bName, string Solution, string SerialNumber, string Quantity){
                    this.productConfig = productConfig;
                    this.isSelected = isSelected;
                    this.isDisabled=isSelected;
                    this.configId=ConfigId;
                    //EDGE-96503-Mahima
                    this.AssignedNumber=numberAssign;
                    this.PlanName=plan;
                    this.Color=color;
                    this.Model=model;
                    this.BasketName= bName;
                    this.Solution=Solution;
                    this.SerialNumber=SerialNumber;
                    this.Quantity=Quantity;
                }
               
            }*/
    
    //Wrapper to get Number Object 
    /*public class NumberWrapper{
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
    }*/
    
    //EDGE-96505- Mahima
    //Wrapper to get Validation data 
    public class ValidationWrapper{
        @AuraEnabled
        public boolean IsValid{get;set;}
        @AuraEnabled
        public String ErrorMessage{get;set;}
    }
    /*-------------------------------------------------------- 
EDGE -93081
Method: getProdConfig
Description: Get PC for Basket 
Author:Ila
--------------------------------------------------------*/
    
    /*@AuraEnabled
    public static List<prodConfigWrapper> getProdConfig(Id basketId,String selTabId) {
        //EDGE-96503- Mahima 
        string [] deviceAttrName= new string[]{'Mobile Device','Device'};
            string [] lstAttributesdetails= new string[]{'ColourString','ModelString','MobilityPlanSelected'};
                string [] lstAttributesdetailsSubscription= new string[]{'MobileHandsetColour','MobileHandsetModel'};
                    List<prodConfigWrapper> pcWrapList = new List<prodConfigWrapper>();
        if(selTabId =='Mobile'){
            List<cscfga__Product_Configuration__c> pcList = [SELECT Name , id,cscfga__Product_Basket__r.Name,
                                                             cscfga__Product_Definition__r.Name, 
                                                             (select id, Service_Number__c from  Numbers__r), 
                                                             (select id,Name,cscfga__Value__c from cscfga__Attributes__r 
                                                              where name in: deviceAttrName ) 
                                                             FROM cscfga__Product_Configuration__c 
                                                             WHERE cscfga__Product_Basket__c = :basketId and 
                                                             cscfga__Product_Definition__r.product_Specification__c in :PROD_SPEC_VALUES
                                                             AND csordtelcoa__Replaced_Product_Configuration__c = null]; // EDGE-127105
            
            
            system.debug('pcList.size=='+ pcList.size());
            Map<cscfga__Product_Configuration__c, string> mobileDeviceIds= new Map<cscfga__Product_Configuration__c,string>();
            Map<cscfga__Product_Configuration__c, string> deviceIds= new Map<cscfga__Product_Configuration__c,string>();
            for(cscfga__Product_Configuration__c pc: pcList){
                if(pc.cscfga__Attributes__r!= null && pc.cscfga__Attributes__r.size()>0){
                    if(pc.cscfga__Product_Definition__r.Name.contains('Mobility'))
                    {
                        mobileDeviceIds.put(pc,pc.cscfga__Attributes__r[0].cscfga__Value__c);
                        system.debug('mobileDeviceIds.size=='+ pc.cscfga__Attributes__r[0].cscfga__Value__c);
                    }
                    else if(pc.cscfga__Product_Definition__r.Name.contains('Mobile Subscription'))
                    {
                        deviceIds.put(pc,pc.cscfga__Attributes__r[0].cscfga__Value__c);
                    }
                }
                else{
                    mobileDeviceIds.put(pc,'');
                    deviceIds.put(pc,'');
                    system.debug('mobileDeviceIds.size=='+ pc +' ');
                }
            }
            //system.debug('mobileDeviceIds.size=='+ mobileDeviceIds.size());
            List<cscfga__Product_Configuration__c> lstDetailconfigMobility=  [Select id ,(Select id,Name,cscfga__Value__c from cscfga__Attributes__r where Name in: lstAttributesdetails ) From cscfga__Product_Configuration__c Where id in:mobileDeviceIds.values()];        
            
            system.debug('lstDetailconfig.size=='+ lstDetailconfigMobility.size());
            Map<cscfga__Product_Configuration__c,List<cscfga__Attribute__c>> mapProdConfig= new Map<cscfga__Product_Configuration__c,List<cscfga__Attribute__c>> ();       
            
            for (cscfga__Product_Configuration__c PCid: mobileDeviceIds.keyset())
            {
                if(lstDetailconfigMobility!= null && lstDetailconfigMobility.size()>0){    
                    for(cscfga__Product_Configuration__c dpc: lstDetailconfigMobility){
                        
                        //system.debug('dpc.cscfga__Attributes__r=='+dpc.cscfga__Attributes__r.size());
                        if(mobileDeviceIds.get(PCid)=='' || mobileDeviceIds.get(PCid)==null)
                        {
                            mapProdConfig.put(PCid,null);
                        }
                        else if(mobileDeviceIds.get(PCid)==dpc.id)
                        {
                            mapProdConfig.put(PCid,dpc.cscfga__Attributes__r);
                        }    
                    }
                }
                else{ mapProdConfig.put(PCid,null); }
            }
            
            List<cscfga__Product_Configuration__c> lstDetailconfigMobileSubs= [Select id ,cscfga__Parent_Configuration__c,(Select id,Name,cscfga__Value__c From cscfga__Attributes__r Where Name in: lstAttributesdetailsSubscription) From cscfga__Product_Configuration__c Where id in:deviceIds.values()];
            system.debug('lstDetailconfigMobileSubs.size=='+ lstDetailconfigMobileSubs.size());
            Map<cscfga__Product_Configuration__c,string> ComProdIdsModel= new Map<cscfga__Product_Configuration__c,string>();
            Map<cscfga__Product_Configuration__c,string> ComProdIdsColour= new Map<cscfga__Product_Configuration__c,string>();
            for(cscfga__Product_Configuration__c pcdevice: lstDetailconfigMobileSubs)
            {
                if(pcdevice.cscfga__Attributes__r!= null && pcdevice.cscfga__Attributes__r.size()>0){
                    //system.debug('pcdevice.cscfga__Attributes__r=='+pcdevice.cscfga__Attributes__r);
                    for(cscfga__Attribute__c attr:pcdevice.cscfga__Attributes__r){
                        //system.debug('attr.cscfga__Value__c=='+attr.cscfga__Value__c+' '+'pcdevice=='+pcdevice.id);
                        if(attr.Name=='MobileHandsetModel')
                            ComProdIdsModel.put(pcdevice,attr.cscfga__Value__c);
                        else if(attr.Name=='MobileHandsetColour')
                            ComProdIdsColour.put(pcdevice,attr.cscfga__Value__c);
                    }
                }
            }
            
            // List<cspmb__Price_Item__c> lstCommProd= [select id,Colour__c,Model__c from cspmb__Price_Item__c where id in: ComProdIds.values() ];
            //if(ComProdIdsModel.size()>0)
            //{
            //system.debug('ComProdIds==>' + ComProdIds);
            Map<id,cspmb__Price_Item__c> lstCommProd = new Map<id,cspmb__Price_Item__c>([Select id,Colour__c,Model__c From cspmb__Price_Item__c Where id in: ComProdIdsModel.values() or id in: ComProdIdsColour.values() ]);
            system.debug('lstCommProd==>'+lstCommProd);
            for (cscfga__Product_Configuration__c PCid: deviceIds.keyset())
            {
                if(lstDetailconfigMobileSubs!= null && lstDetailconfigMobileSubs.size()>0){    
                    for(cscfga__Product_Configuration__c dpc: lstDetailconfigMobileSubs){
                        
                        system.debug('dpc.cscfga__Attributes__r=='+dpc.cscfga__Attributes__r.size());
                        if(deviceIds.get(PCid)=='' || deviceIds.get(PCid)==null)
                        {
                            mapProdConfig.put(PCid,null);
                        }
                        else if(deviceIds.get(PCid)==dpc.id)
                        { 
                            for(cscfga__Attribute__c att: dpc.cscfga__Attributes__r)
                            {
                                cspmb__Price_Item__c CP= lstCommProd.get(att.cscfga__Value__c);
                                system.debug('commercial product==>'+cp);
                                if(att.Name=='MobileHandsetModel')
                                    att.cscfga__Value__c= (CP!= null?CP.Model__c:'');
                                else if(att.Name=='MobileHandsetColour')
                                    att.cscfga__Value__c= (CP!= null?CP.Colour__c:'');
                            }
                            mapProdConfig.put(PCid,dpc.cscfga__Attributes__r);
                        }    
                    }
                }
                else{ mapProdConfig.put(PCid,null); }
            }
            
            //}
            
            
            
            //Creating wrapper for PC data.
            system.debug('mapProdConfig.size()=='+mapProdConfig.size());
            
            for(cscfga__Product_Configuration__c pc: mapProdConfig.keyset()){
                prodConfigWrapper wrap;            
                string model,plan, color;
                List<cscfga__Attribute__c> lstAttr=mapProdConfig.get(pc);
                if(lstAttr!= null && lstAttr.size()>0)
                {               
                    for(cscfga__Attribute__c attr:lstAttr)
                    {
                        system.debug('attr.cscfga__Value__c'+attr.cscfga__Value__c);
                        if(pc.cscfga__Product_Definition__r.Name.contains('Mobility'))
                        {
                            if(attr.Name=='ModelString')
                                model=attr.cscfga__Value__c;
                            else if(attr.Name=='MobilityPlanSelected')
                                plan=attr.cscfga__Value__c;
                            else if(attr.Name=='ColourString')
                                color=attr.cscfga__Value__c;
                        }
                        else if(pc.cscfga__Product_Definition__r.Name.contains('Mobile Subscription'))
                        {
                            plan=pc.Name;
                            
                            if(attr.Name=='MobileHandsetModel')
                                model=attr.cscfga__Value__c;                   
                            else if(attr.Name=='MobileHandsetColour')
                                color=attr.cscfga__Value__c;
                            
                        }
                    }
                    //}
                }
                else
                {
                    plan=pc.Name;
                }
                
                //}
                if(pc.Numbers__r!= null && pc.Numbers__r.size()>0)
                    wrap = new prodConfigWrapper(pc.Name,true,pc.id,pc.Numbers__r[0].Service_Number__c, model, plan, color,pc.cscfga__Product_Basket__r.Name,null,null,null);
                else
                    wrap = new prodConfigWrapper(pc.Name,false,pc.id,'<Unassigned>', model, plan, color,pc.cscfga__Product_Basket__r.Name,null,null,null);
                
                pcWrapList.add(wrap);
            }
            system.debug('pcWrapList.size()=='+pcWrapList.size());
        }
        else if(selTabId =='Fixed'){
            pcWrapList=getNGUCProdConfig(basketId,selTabId);
            system.debug('pcWrapList.size()=='+pcWrapList.size());
            system.debug('pcWrapList=='+pcWrapList);
            
        }
        return pcWrapList;
    }*/
    /*-------------------------------------------------------- 
EDGE -59982
Method: getNGUCProdConfig
Description: Get nguc for basket 
Author:Aishwarya
--------------------------------------------------------*/
    /*public static List<prodConfigWrapper> getNGUCProdConfig(Id basketId,String selTabId) {
        system.debug('selTabId>>>'+selTabId);
        //Get the list of nextgenvice products added in basket
        List<prodConfigWrapper> wrapperList=new List<prodConfigWrapper>();
        List<String> prodDefName=new List<String>();
        prodConfigWrapper wrapper=null;
        
        
        
        List<cscfga__Product_Definition__c> productDef=new List<cscfga__Product_Definition__c>();
        productDef=[SELECT Name FROM cscfga__Product_Definition__c WHERE product_Specification__c IN :NGUC_PROD_SPEC_VALUES];
        for(cscfga__Product_Definition__c confing: productDef){
            prodDefName.add(confing.Name);
        }
        system.debug('productDef' +prodDefName);
        List< cscfga__Product_Configuration__c > productsAlreadyInTheBasket = new List < cscfga__Product_Configuration__c > ();
        //EDGE-130353 : Removed Replaced Product Config filter from Query.
        productsAlreadyInTheBasket = [
            SELECT id,Name,cscfga__Root_Configuration__c,cscfga__Serial_Number__c,cscfga__Quantity__c,
            cscfga__Product_Definition__r.Name,cscfga__Product_Basket__r.Name
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Product_Basket__c =: basketid AND cscfga__Product_Definition__r.Name IN :prodDefName
        ];
        if(!productsAlreadyInTheBasket.isEmpty()){
            String basketName=productsAlreadyInTheBasket[0].cscfga__Product_Basket__r.Name;
            List<ID> productIDs=new List<ID>();
            for(cscfga__Product_Configuration__c confing: productsAlreadyInTheBasket){
                productIDs.add(confing.id);
            }
            
            system.debug('productsAlreadyInTheBasket' + productsAlreadyInTheBasket);
            system.debug('productIDs>>>>' + productIDs);
            List<cscfga__Attribute__c> detailsList = [SELECT id,cscfga__Value__c,name,cscfga__Product_Configuration__r.Name,cscfga__Product_Configuration__c FROM cscfga__Attribute__c where cscfga__Product_Configuration__c IN :productIDs AND  name =:Label.NgucAttributes]; 
            system.debug('detailsList' + detailsList);
            
            for(cscfga__Product_Configuration__c detail: productsAlreadyInTheBasket){
                //String pcQuantity=String.valueOf(detail.cscfga__Quantity__c);
                String pcQuantity;
                if(detailsList!=null){
                    for(cscfga__Attribute__c attr: detailsList){
                        if(detail.id == attr.cscfga__Product_Configuration__c){
                            
                            wrapper = new prodConfigWrapper(detail.Name,true,detail.id,null,detail.Name,null,null,basketName, 'Telstra Collaboration Solution',detail.cscfga__Serial_Number__c,attr.cscfga__Value__c);
                            
                            wrapperList.add(wrapper);
                            system.debug('wrapperList' + wrapperList);
                        }
                    }
                }
            }   
            
        }
        
        System.debug('wrapperList--->'+wrapperList);
        //Returns the wrapper with solution name,quantity,serial number
        return wrapperList;
    }*/
    
    
    
    /*-------------------------------------------------------- 
EDGE -93081
Method: getNumberList
Description: to get the list of Number__C for given basketID
Author:Mahima 
--------------------------------------------------------*/
   /* @AuraEnabled
    public static List<NumberWrapper> getNumberList(Id basketId,String selectedTab) {
        system.debug('selectedTab+' +selectedTab);
        system.debug('basketId=='+basketId);
        //To get the list of reserved and unreserved numbers 
        List<String> servList = new List<String>();
        
        Map<String,string> startRange = new Map<String,string>();
        
        List< NumberWrapper> lstNumWrap= new List<NumberWrapper>();
        //EDGE-129691. Kalashree Borgoankar. Fix to extend query for NgUc
        List<cscfga__Product_Configuration__c> pconfigList = [SELECT Name,Id,Type__c,csordtelcoa__Replaced_Service__r.csordtelcoa__Service_Number__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c = :basketId and Type__c='Modify'  and((cscfga__Product_Definition__r.product_Specification__c IN :PROD_SPEC_VALUES)OR (cscfga__Product_Definition__r.product_Specification__c IN :NGUC_PROD_SPEC_VALUES))];
        
        system.debug('pconfigList+' +pconfigList);
        for(cscfga__Product_Configuration__c pc : pconfigList ){
            servList.add(pc.csordtelcoa__Replaced_Service__r.csordtelcoa__Service_Number__c);
        }
        system.debug('servList+' +servList);
        if(pconfigList!=NULL && pconfigList.size()>0){
            
            Map<String,Number__C> endRange = new Map<String,Number__C>();
            
            List<Number__C> lstNumModify=[select Id, Type__c,Mobile__c, Service_Id__c, Service_Number__c,Product_Configuration__c, Product_Configuration__r.Name,Basket__c,Start_Range__c,End_range__c from Number__c where Mobile__c= :selectedTab and Service_Id__c IN :servList];
            system.debug('lstNumModify+' +lstNumModify);
            if(lstNumModify!=null && lstNumModify.size()>0){
                
                for(integer i=0; i<lstNumModify.size();i++){
                    NumberWrapper numWrapObj= new NumberWrapper();
                    NumberWrapper detailList = new NumberWrapper();
                    if(lstNumModify[i].Start_Range__c!=null && lstNumModify[i].End_range__c!=null){
                        if(!startRange.containsKey(lstNumModify[i].Start_Range__c)){
                            startRange.put(lstNumModify[i].Start_Range__c,lstNumModify[i].End_range__c);
                            numWrapObj.PhoneNumber= lstNumModify[i].Start_Range__c + ' - ' + lstNumModify[i].End_range__c;
                            //lstNumWrap.add(numWrapObj);
                            detailList =getDetails(lstNumModify[i],numWrapObj);
                            lstNumWrap.add(detailList);
                            
                        }
                        
                        
                    }
                    if(lstNumModify[i].Start_Range__c==null && lstNumModify[i].End_range__c==null){
                        numWrapObj.PhoneNumber=lstNumModify[i].Service_Number__c;
                        //lstNumWrap.add(numWrapObj);
                        detailList= getDetails(lstNumModify[i],numWrapObj);
                        lstNumWrap.add(detailList);
                        
                    }
                    
                }
            }
        }
        //EDGE-112519, Kalashree Borgaonkar. Removed else.
        
        //EDGE-117819, Addded selectedTab in the query
        List<Number__C> lstNum=[select Id, Type__c, Mobile__c,Service_Number__c,Product_Configuration__c, Product_Configuration__r.Name,Basket__c,Start_Range__c,End_range__c from Number__c where Mobile__c= :selectedTab and Basket__c=: basketId];
        //lstNum.add(new Number__C(Service_Number__c='7536417'));
        system.debug('lstNum+' +lstNum);
        if(lstNum!= null && lstNum.size()>0 ){
            for(integer i=0; i<lstNum.size();i++){
                NumberWrapper numWrapObj= new NumberWrapper();
                NumberWrapper detailList = new NumberWrapper();
                if(lstNum[i].Start_Range__c!=null && lstNum[i].End_range__c!=null){
                    if(!startRange.containsKey(lstNum[i].Start_Range__c)){
                        startRange.put(lstNum[i].Start_Range__c,lstNum[i].End_range__c);
                        numWrapObj.PhoneNumber=lstNum[i].Start_Range__c + ' - ' + lstNum[i].End_range__c; 
                        //lstNumWrap.add(numWrapObj);
                        detailList = getDetails(lstNum[i],numWrapObj);
                        lstNumWrap.add(detailList);
                    }
                    
                    
                }
                
                if(lstNum[i].Start_Range__c==null && lstNum[i].End_range__c==null){
                    numWrapObj.PhoneNumber=lstNum[i].Service_Number__c;  
                    //lstNumWrap.add(numWrapObj);
                    detailList = getDetails(lstNum[i],numWrapObj);
                    lstNumWrap.add(detailList);
                    
                }
            }
        }
        system.debug('lstNumWrap+' +lstNumWrap);
        return lstNumWrap;
    }*/
    
    /*@AuraEnabled
    public static NumberWrapper getDetails(Number__C num, NumberWrapper numWrapObj){
        //NumberWrapper lstNumberWrap= new NumberWrapper();
        if(num!=null){
            numWrapObj.numberId=num.id;
            numWrapObj.Type=num.Type__c;
            numWrapObj.IsSelected= num.Product_Configuration__c!=null? true: false;                
            numWrapObj.ProdConfigId=num.Product_Configuration__c;  
            numWrapObj.ProdConfigName=num.Product_Configuration__c!=null? true: false;
            numWrapObj.ProdBasketId=num.Basket__c;
            //lstNumberWrap.add(numWrapObj);
            
        }
        
        return numWrapObj;
    }*/
    /*-------------------------------------------------------- 
EDGE -93081
Method: reserveNumbers
Description: To reserve the selected numbers for selected product Configuration of Current basket.
Author:Mahima
--------------------------------------------------------*/
    //EDGE-144233. Kalashree Borgaonkar. Added basketid in where clause for limiting query to basket
    /*@AuraEnabled
    public static boolean reserveNumbers(List<string> selectedPcWrapper, List<string> selectedNumbers,String identifier,String basketid){
        //Method to reserve numbers for mobility
        system.debug('selectedNumbers+' +selectedNumbers);
        List<Number__C> lstSelectedNumbers= new  List<Number__C>();
        List<String> startRange = new List<String> ();
        try{
            if(selectedNumbers!= null && selectedNumbers.size()>0){  
                system.debug(selectedNumbers);
                if('Fixed'.equalsIgnoreCase(identifier)){
                    for(String fnn: selectedNumbers){ 
                        if(fnn.contains('-')){
                            String stRange = fnn.substringbefore(' -');
                            //String edRange = fnn.substringafter('-');
                            startRange.add(stRange);
                        }
                    }
                    lstSelectedNumbers= [select id, Type__c,Product_Configuration__c,Service_Number__c,Start_Range__c,End_Range__c from Number__c where (Service_Number__c in:selectedNumbers OR Start_Range__c IN :startRange) AND basket__c =:basketid];      
                    
                }else{
                    
                    lstSelectedNumbers= [select id, Type__c,Product_Configuration__c,Service_Number__c,Start_Range__c,End_Range__c from Number__c where id in:selectedNumbers AND basket__c =:basketid];      
                    system.debug('lstSelectedNumbers=='+lstSelectedNumbers);
                }
                if(lstSelectedNumbers!= null && lstSelectedNumbers.size()>0 && selectedPcWrapper!=null && selectedPcWrapper.size()>0){
                    system.debug('selectedPcWrapper=='+selectedPcWrapper);
                    if('Mobile'.equalsIgnoreCase(identifier)){
                        if(selectedPcWrapper.size()==lstSelectedNumbers.size())
                            // {
                            for(integer i=0; i<selectedPcWrapper.size(); i++){
                                lstSelectedNumbers[i].Product_Configuration__c=selectedPcWrapper[i];
                            }
                        // }
                    }
                    else{//EDGE-59982,Associate numbers with PC
                        for(integer i=0; i<lstSelectedNumbers.size(); i++){
                            lstSelectedNumbers[i].Product_Configuration__c=selectedPcWrapper[0];
                        }
                    }
                    system.debug('lstSelectedNumbers=='+lstSelectedNumbers);   
                }
                if(!lstSelectedNumbers.isEmpty()){
                    update lstSelectedNumbers;
                    if('Fixed'.equalsIgnoreCase(identifier)){
                        NumberReservationFixedHandler.saveReserveNCS(lstSelectedNumbers); //EDGE-108230 Create NCS for nguc
                    } 
                }            
            }
            
        }catch(exception ex)
        {
            system.debug('exception==>'+ ex.getLineNumber()+' '+ ex.getMessage());
            return false;
        }
        return true;
    }*/
    
    /*-------------------------------------------------------- 
EDGE -93081
Method: unReserveNumbers
Description: To unreserve the selected numbers for selected product Configuration of Current basket.
Author:Mahima
--------------------------------------------------------*/
    /*@AuraEnabled
    public static void unReserveNumbers(List<string> selectedPcWrapper, List<string> selectedNumbers, string basketId){
        
        List<Number__C> lstSelectedNumbers= new  List<Number__C>();
        List<Number__C> lstPortIn= new  List<Number__C>();
        List<Number__C> lstnew= new  List<Number__C>();
        List<string> unReserveLst= new List<string>();
        string jobid='';
        system.debug('selectedNumbers:'+selectedNumbers);
        system.debug('basketId:'+basketId);
        if(selectedNumbers!= null && selectedNumbers.size()>0){            
            for(Number__c num: [select id, Type__c, Service_Number__c , Basket__c from Number__c 
                                where Service_Number__c in:selectedNumbers AND Basket__c=:basketId])
            {
                if(num.Type__c==TYPE_NEW){
                    lstnew.add(num);
            }
                else if(num.Type__c==TYPE_PORT){
                    lstPortIn.add(num);
        }
            }
        }
        //EDGE-EDGE-135489-26-Feb-2020-Dheeraj Bhatt-Salesforce to disable Unreserve/Rollback API Call for MSISDN on Click of Remove Selected Button
        if(lstnew.size()>0)
        {                    
            if(lstnew.size() > 0 || lstnew.size()<50){                          
                //jobid = unReserveMSISDN(lstnew); 
                delete  lstnew;           
            }       
        }
           
        if(lstPortIn.size()>0)
        {
            //Delete the unreserved numbers from reservation pool
            deleteFromReservationPool(lstPortIn);
            //updateServiceQualification(lstPortIn,basketId);
        }
        //return 'Success';
     //   return jobid;
    }*/
    
    /*-------------------------------------------------------- 
EDGE -93081
Method: unReserveMSISDN
Description: private method to make callout to unreserve the selected numbers 
Author:Mahima
--------------------------------------------------------*/
    /*private static String unReserveMSISDN(List<Number__c> fnnListToUnReserve){
        Map<String,FNNDTO> fnnMap = new Map<String,FNNDTO>();
        for(Number__c fnn : fnnListToUnReserve){
            fnnMap.put(fnn.Service_Number__c,new FNNDTO());
        }
        String jobId = System.enqueueJob(new MSISDNService(fnnMap,'UnReserveMSISDNHandler',fnnListToUnReserve[0].Basket__c,true));
        System.debug('unReserveJobId::' + jobId);
        return jobId;
    }*/
    /*-------------------------------------------------------- 
EDGE -93081
Method: deleteFromReservationPool
Description: private method to delete from Number__c 
Author:Kalashree
--------------------------------------------------------*/
   /* public static void deleteFromReservationPool(List<Number__c> msisdnLstToDelete ){
         try{
            if(msisdnLstToDelete!=null && !msisdnLstToDelete.isEmpty()){
                delete msisdnLstToDelete;   
            }
        }
        catch(Exception e){
            system.debug('EXception in deleteFromReservationPool'+e.getStackTraceString());
        }
        
        
    } */  
    
    /*-------------------------------------------------------- 
EDGE -96503
Method: finishReservation
Description: To Validate the basket if all Mobile PC and Port numbers are assigned or not.
Author:Mahima
--------------------------------------------------------*/
    @AuraEnabled
    Public Static ValidationWrapper finishReservation( string basketID)
    {
        System.debug('finishReservation');
        ValidationWrapper validWrapper= new ValidationWrapper(); 
        validWrapper.IsValid=true;
        validWrapper.ErrorMessage='Number assignment successful.';
        string [] deviceAttrName= new string[]{'Mobile Device','Device'};
            //To check if all the PC are assigned with Numbers.
            List<cscfga__Product_Configuration__c> pcList = [SELECT Name , id,csordtelcoa__Replaced_Product_Configuration__c ,
                                                             Type__c,cscfga__Product_Definition__r.Name, cscfga__Product_Basket__r.Name,
                                                             (SELECT id, Service_Id__c,Service_Number__c FROM  Numbers__r), 
                                                             (SELECT id,Name,cscfga__Value__c FROM cscfga__Attributes__r 
                                                              WHERE Name in :deviceAttrName) FROM cscfga__Product_Configuration__c 
                                                             WHERE cscfga__Product_Basket__c = :basketID and 
                                                             cscfga__Product_Definition__r.product_Specification__c in :PRODSPECVALUES
                                                             AND csordtelcoa__Replaced_Product_Configuration__c = null]; // EDGE-127105
        //EDGE-113145,EDGE-123476 Kalashree, start
        
        
        //Name LIKE 'CWP Mobile Seat%'];
        System.debug('pcList: '+pcList);
        for(cscfga__Product_Configuration__c pc: pcList){ 
            //if(pc.cscfga__Attributes__r!= null && pc.cscfga__Attributes__r.size()>0){ 
            if(pc.csordtelcoa__Replaced_Product_Configuration__c== null ){
                System.debug('pc.Type__c: '+pc.Type__c);
                System.debug('pc.Name: '+pc.Name);
                System.debug('Pd.Name: '+pc.cscfga__Product_Definition__r.Name);
                 System.debug('Basket.Name: '+pc.cscfga__Product_Basket__r.Name);
                
                if(pc.Numbers__r== null || pc.Numbers__r.size()==0)
                {            
                    validWrapper= new ValidationWrapper();
                    validWrapper.IsValid = false;
                    validWrapper.ErrorMessage=System.Label.NumberReservation_EachPCMustbeAssignedWithNumber;    
                    break;
                }   
            }
            
        }
        
        //EDGE-113145, Kalashree, end
        //To check if all the Port in numbers are assigned with PC or not.
        List<Number__C> lstNum=[select Id, Type__c, Service_Number__c,Product_Configuration__c, Product_Configuration__r.Name,Basket__c from Number__C where Basket__c=: basketID and Type__c =: TYPEPORT];
        for( Number__c num: lstNum)
        {
            if(num.Product_Configuration__c== null)
            {
                validWrapper= new ValidationWrapper();
                validWrapper.IsValid= false;
                validWrapper.ErrorMessage=System.Label.NumberReservation_AllPortInNumbersMustbeAssigned;
                //'Each Port In Number in the Reservation Pool must be assigned to a Product Configuration.';    
                break;
            }
            
        }
        
        System.debug('validWrapper: '+validWrapper);
        return validWrapper;
        
    }
    
    
    
    /*-------------------------------------------------------- 
EDGE -96503
Method: unAssignPCNumber
Description: To Validate the basket if all Mobile PC and Port numbers are assigned or not.
Author:Mahima
--------------------------------------------------------*/
    /*@AuraEnabled
    public Static List<Number__C > unAssignPCNumber( string[] selectedPC, string basketID)
    {
        system.debug(selectedPC);
        system.debug(basketID);
        List<Number__C > lstNumberPC= new List<Number__C >();
        try{
            lstNumberPC= [select Id, Product_Configuration__c  from Number__c where 
                          Product_Configuration__c in: selectedPC and Basket__c=: basketID];
            system.debug('lstNumberPC==>'+lstNumberPC);
            if(lstNumberPC!= null && lstNumberPC.size()>0)
            {
                for(Number__C num : lstNumberPC)
                {
                    num.Product_Configuration__c= null;
                }
                update lstNumberPC;
            }
        }catch(exception ex)
        {
            system.debug('EXception in unAssignPCNumber'+ex.getStackTraceString());
        }
        return lstNumberPC;
    }*/
    /*-------------------------------------------------------- 
EDGE -97393
Method: getBasketStage
Description: To get basket stage 
Author:Aishwarya
--------------------------------------------------------*/
    /*@AuraEnabled
    public static String getBasketStage(String basketid){
        //Returns basket stage 
        List<cscfga__Product_Basket__c> basketList= [SELECT Name,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE id =:basketid];       
        String basketStage=basketList[0].csordtelcoa__Basket_Stage__c;
        return basketStage;
    }*/
    
    /******************************************************************
EDGE -89257 , AC6
Method: getJobStatus
Description: get status of Queueable job
Author:Mahima
******************************************************************/
    // Commented by Abinash: No more use ... Edge-92021
    /*@AuraEnabled
    public static Boolean getJobStatus(string jobId){  
        System.Debug('jobId: '+jobId);
        Boolean isJobCompleted = false;
        List<AsyncApexJob> lstjobstatus = [SELECT Id,Status FROM AsyncApexJob Where id =:jobId];
        if(lstjobstatus!=null && lstjobstatus.size()>0)
        {
            AsyncApexJob jobstatus=lstjobstatus[0];
            if('Completed'.equalsIgnoreCase(jobstatus.Status) ){
                system.debug('Job completed');
                isJobCompleted = true;  
            }
        }
        
        return isJobCompleted;
    } */
    /******************************************************************
EDGE -89257 , AC6
Method: checkShowPortin
Description: get custom setting value
Author:Mahima
******************************************************************/
    /*@AuraEnabled
    public static Boolean checkShowPortin(){
        EnvironmentVariable__c variable = EnvironmentVariable__c.getValues('ShowPortinOnScreen');
        System.debug('variable:'+variable); 
        if(variable!=null && variable.value__c!=null){
            System.debug('Boolean.valueOf(variable.value__c)'+Boolean.valueOf(variable.value__c));
            return Boolean.valueOf(variable.value__c);
        }
        return false;
    }*/
    /******************************************************************
EDGE -89299 , AC6
Method: isPortInValid
Description: Finish button validation to check if CA form is going to expire in 10 days
Author:Aishwarya
******************************************************************/
    
   /* @AuraEnabled
    public static Boolean isPortInValid(String basketid){
        Boolean isFinished=PortInController.isPortInValid(basketid);
        return isFinished;
        
    }*/
    
    /******************************************************************
EDGE:59982
Method: unReserveFNN
Description: Unreserve Fixed numbers for nguc
Author:Aishwarya
******************************************************************/
   /* @AuraEnabled
    public static NumberReservationFixedHandler.ResponseWrapper unReserveFNN(List<String> selectedNumbers,String basketId, String resourceState){
        
        //Unreserve the numbers for nextgenvoice products
        Boolean Status=false;
        // List<Number__c> fnnListToUnReserve=new List<Number__c>();
        NumberReservationFixedHandler.ResponseWrapper resWrap= new NumberReservationFixedHandler.ResponseWrapper();
        
        if(!selectedNumbers.isEmpty()){
            
           
            resWrap=NumberReservationFixedHandler.reserveUnreserveFixedMSISDN(selectedNumbers,basketId,resourceState, '');//EDGE-92021
            
            
            
        }
        
        system.debug('resWrap.resIds+' +resWrap.resIds);
        system.debug('resWrap.stRange+' +resWrap.stRange);
        if(resWrap.stRange!=null || resWrap.resIds!=null){
            Status=true;
            system.debug('resWrap+' +resWrap);
            //call the method to delete from reservation Pool
            if(!Test.isRunningTest()){
                deleteFromPoolFixed(resWrap.resIds,basketid,resWrap.stRange);
            }
            
        }else {
            Status=false;
        }
        system.debug('resWrap&&' +resWrap);
        return resWrap;   
    }*/
    /*************************************************************************************************
Name : deleteFromPoolFixed
Description : Delete Fixed numbers from pool 
Author: Ila
Story: EDGE-100660
***************************************************************************************************/
    /*@AuraEnabled
    public static void deleteFromPoolFixed(List<String> msisdnLstToDelete,String basketid, List<String> startRange ){
        NumberNCSHelper ncs= new NumberNCSHelper();
        
        List<Number__c> numList = new List<Number__c>();
        
        //Delete unreserved numbers for fixed from reservation pool
        system.debug('in delete');
        system.debug('msisdnLstToDelete+' +msisdnLstToDelete);
        system.debug('startRange+' +startRange);
        system.debug('basketid=='+basketid);
        Map<Id,List<String>> ncsMapToDel = new Map<Id,List<String>>();
        //EDGE-124988 fix
        String msisdn = 'AND Service_Number__c IN :msisdnLstToDelete' ;
        String range =' AND Start_Range__c IN :startRange ' ;
        String rangeMsisdn = 'AND (Service_Number__c IN :msisdnLstToDelete OR Start_Range__c IN :startRange) ' ;
        
        String query = 'SELECT ID,Service_Number__c,Product_Configuration__c,Start_Range__c FROM Number__c WHERE Basket__c =\'' +basketid +'\' ';
        
        if (msisdnLstToDelete!=null && startRange==null)        
        {
            
            query+= msisdn;
        }
        else if (startRange!=null && msisdnLstToDelete==null)        
        {
            query+= range;
            
        }
        else
        {
            query+=rangeMsisdn;
        }
        system.debug('query+' +query);
        numList = Database.query(query);
        system.debug('in if 795');
        
        //List<Number__c> numList = [SELECT ID,Service_Number__c,Product_Configuration__c,Start_Range__c FROM Number__c WHERE Basket__c = :basketid AND ( Service_Number__c IN :msisdnLstToDelete OR Start_Range__c IN:startRange)];
        System.debug('numList: '+numList);
        if(numList.size()>0){
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
    }*/
    /**********************************
Name: handleRangeException
Author:Ila
Description: Handle Custom Exception
Story:EDGE-100660
******************************************/
    
    public class HandleRangeException extends Exception{}
    
    
    /*************************************************************************************************
Name : splitRangeofNumbers
Description : Split Range of numbers to individual numbers
Author: Ila
Story: EDGE-100660
***************************************************************************************************/
    public static List<Number__c> splitRangeofNumbers(String startnumber, String endnumber, String basketId,String accId,String status, String type,String pcId, Id  numGroupId){
        //system.debug('startnumber+' +startnumber );
        //system.debug('endnumber+' +endnumber );
      
       system.debug('Number Group Record in SplitRange method +' +numGroupId );
        Long stNum= long.valueOf(startnumber);
        Long edNum= long.valueOf(endnumber);
        //system.debug('resourceIdList+' +resourceIdList);
        List<Number__c> splitNumList = new List<Number__c>();
        try{
            if(stNum<edNum){
                for(Long i = stNum;i<=edNum ; i++){
                    String longToStr= String.valueOf(i);
                    
                    //system.debug('longToStr+' +longToStr);
                    // if(!resourceIdList.contains(String.valueOf(i))){
                    
                    Number__c fnnNumber = new Number__c();
                    
                    fnnNumber.Basket__c = basketId;
                    fnnNumber.Account__c = accId;
                    fnnNumber.Service_Number__c = String.valueOf(i);
                    fnnNumber.Status__c = status;
                    if(pcId!=null){
                        fnnNumber.Product_Configuration__c=pcId;
                    }
                    fnnNumber.Mobile__c='Fixed';
                    fnnNumber.Type__c=type;
                    fnnNumber.Start_Range__c=startnumber;
                    fnnNumber.End_range__c=endnumber;
                    fnnNumber.Number_Group__c = numGroupId;//EDGE-201122
                    //EDGE-155301-vilas
                    if(fnnNumber.Service_Number__c.length() < 10){
                        fnnNumber.Service_Number__c = '0'+fnnNumber.Service_Number__c;
                    }
                    splitNumList.add(fnnNumber);
                }
                // }
            }else{
                throw new handleRangeException('StartNumber should be less than EndNumber');
            }
        }catch(handleRangeException e){
            system.debug('In Exception' +e.getMessage());
            
        }
        system.debug('splitNumList+' +splitNumList);
        return splitNumList;
        
    }
    /*************************************************************************************************
Name : isPopupValidation
Description: Show pop up if any unassigned numbers 
Author: Jannath
Story: EDGE-100662
***************************************************************************************************/  
    /*@AuraEnabled
    public static boolean isPopupValidation(string basketId){
        boolean status=false;
        List<Number__c> numlist=[select Id, Type__c,Status__c, Mobile__c,Service_Number__c,Product_Configuration__c, Product_Configuration__r.Name,Basket__c from Number__c where Basket__c=: basketId and Product_Configuration__c = NULL and Type__c ='FNN'];
        if(numlist.size() > 0){
            status=true;
        }
        return status;
    }*/ 
    /*************************************************************************************************
Name : OKunReserveFNN
Description: Check Unassigned numbers on click of OK 
Author: Jannath
Story: EDGE-100662
***************************************************************************************************/    
    
    /*@AuraEnabled
    public static NumberReservationFixedHandler.ResponseWrapper OKunReserveFNN(string basketId){
        boolean Status;
        String Url=URL.getCurrentRequestUrl().toExternalForm();
        List<string> numlist= new List<string>();
        for(Number__c num : [select Id, Type__c,Status__c, Mobile__c,Service_Number__c,Product_Configuration__c, Product_Configuration__r.Name,Basket__c from Number__C where Basket__c=: basketID and Type__c ='FNN' and Status__c ='RESERVED' and Product_Configuration__c = NULL]){
            numlist.add(num.Service_Number__c);   
        }

  
        if(Url.contains('partners')){
            NumberReservationFixedHandler.ResponseWrapper wrap =unReserveFNN(numlist,basketId,'Rollback');
            return wrap;
        }else{
            NumberReservationFixedHandler.ResponseWrapper wrap =unReserveFNN(numlist,basketId,'Rollback');
            return wrap;
        }
        
    }*/
    
    /*************************************************************************************************
Name : getQuantityDetail
Description: Find and calculate the quantity to remove on product selection.
Author: Sandip Deshmane
Story: EDGE-92546
**************************************************************************************************/
    /*@AuraEnabled
    public static Integer getQuantityDetail(List<String> prodConfigs){
        System.debug('***prodConfigs : '+prodConfigs);
        List<String> replacedProdConfigId = new List<String>();
        Integer newQuantity = 0;
        Integer Quantity = 0;
        List<String> configIds = new List<String>();
        List<cscfga__Product_Configuration__c> pcList = [SELECT id, Name, csordtelcoa__Replaced_Product_Configuration__c FROM cscfga__Product_Configuration__c WHERE Id = :prodConfigs];
        System.debug('***PC List : '+pcList);
        if(pcList != null){
            for(cscfga__Product_Configuration__c pcNew : pcList){
                System.debug('***Product Config : '+pcNew);
                if(pcNew != null)
                {
                    if(pcNew.csordtelcoa__Replaced_Product_Configuration__c != null ){
                        replacedProdConfigId.add(pcNew.csordtelcoa__Replaced_Product_Configuration__c);
                    }
                    configIds.add(pcNew.Id);
                }
            }
        }
        if(configIds != null){
            List<cscfga__Attribute__c> attrList = [SELECT id,cscfga__Value__c,name,cscfga__Product_Configuration__r.Name,cscfga__Product_Configuration__c FROM cscfga__Attribute__c where cscfga__Product_Configuration__c In :configIds AND  name =:Label.NgucAttributes]; 
            system.debug('Attribute Detail' + attrList);
            
            for(cscfga__Product_Configuration__c pc: pcList){
                if(attrList!=null){
                    for(cscfga__Attribute__c attr: attrList){
                        if(pc.id == attr.cscfga__Product_Configuration__c){
                            newQuantity = integer.valueof(attr.cscfga__Value__c);
                        }
                    }
                }
            } 
        }
        System.debug('***Config Ids : '+configIds);
        System.debug('***Latest Quantity : '+newQuantity);
        
        List<cscfga__Product_Configuration__c> prodConfigList = [SELECT id, Name, csordtelcoa__Replaced_Product_Configuration__c FROM cscfga__Product_Configuration__c WHERE Id = :replacedProdConfigId];
        System.debug('***PC List : '+prodConfigList);
        if(prodConfigList != null){
            List<cscfga__Attribute__c> attrList = [SELECT id,cscfga__Value__c,name,cscfga__Product_Configuration__r.Name,cscfga__Product_Configuration__c FROM cscfga__Attribute__c where cscfga__Product_Configuration__c In :replacedProdConfigId AND  name =:Label.NgucAttributes]; 
            system.debug('Attribute Detail' + attrList);
            
            for(cscfga__Product_Configuration__c pc: prodConfigList){
                if(attrList!=null){
                    for(cscfga__Attribute__c attr: attrList){
                        if(pc.id == attr.cscfga__Product_Configuration__c){
                            quantity = integer.valueof(attr.cscfga__Value__c);
                            if(quantity > newQuantity){
                                quantity = quantity - newQuantity;
                            }
                        }
                    }
                }
            } 
        }
        System.debug('***Final Quantity : '+quantity);
        return quantity;
    }*/
    /*************************************************************************************************
Name : ngucValidationOnEnrich
Description : Method for validating Numbers reserved in NgUC
Author: Kalashree Borgaonkar
Story: EDGE-128633
***************************************************************************************************/
    
    /*@AuraEnabled
    public Static ValidationWrapper ngucValidationOnEnrich(String basketID){
        List<id> prodDefSet= new List<id>();
        Integer quantity=0;
        List<cscfga__Attribute__c> detailsList;
        List<cscfga__Product_Configuration__c> prodConfigList = [SELECT id, (SELECT id,cscfga__Value__c,name FROM cscfga__Attributes__r where name =:Label.NgucAttributes) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c = :basketID AND cscfga__Product_Definition__r.product_Specification__c IN :NGUC_PROD_SPEC_VALUES AND csordtelcoa__Replaced_Product_Configuration__c = null];
        ValidationWrapper validWrapper = new ValidationWrapper();
        for(cscfga__Product_Configuration__c config: prodConfigList){
            prodDefSet.add(config.id);
        }
        for(cscfga__Product_Configuration__c pc: prodConfigList){
            if(pc.cscfga__Attributes__r!=null){
                for(cscfga__Attribute__c attr: pc.cscfga__Attributes__r){
                    Integer count = Integer.valueOf(attr.cscfga__Value__c);
                    quantity = quantity + count;
                }
            }
        }
        Integer count = [select count() FROM Number__c WHERE Product_Configuration__c IN :prodDefSet];
        if(count==quantity){
            validWrapper.IsValid = true;
        }
        else{
            validWrapper.IsValid= false;
            validWrapper.ErrorMessage=Label.FixedNumberValidation;
        }
        return validWrapper;
    }*/
    /*public static void updateUCNumberSpecNumberStatus(List<String> serviceIdList){
        try{
            Map<Id, Attachment> attsMapToUpdate = new Map<Id, Attachment>();
            system.debug('>>>>>>>>>>>>>..serviceIdList >>'+serviceIdList);
            Map<Id, Attachment> attmAP = new Map<Id, Attachment>([SELECT id, name, body, parentId FROM Attachment WHERE parentId IN :serviceIdList and name = 'ServiceSpecifications.json']);
            FOR(Id attId : attmAP.keyset()  ){
                String serviceattachmentstr = attmAP.get(attId).body.toString();
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(serviceattachmentstr);
                //system.debug('results'+results);
                List<Object> lstSpecifications = (List<Object>)results.get('specifications');
                //system.debug(lstSpecifications[0]);
                system.debug('>>>>>>>>>>>>>..lstSpecifications >>'+lstSpecifications);
                for (Object specification : lstSpecifications) {               
                    // now get attributes for this specification.               
                    Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
                    Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('attributes');
                    Map<String,Object> tempAttributesMap = new Map<String,Object> ();
                    for(String atrributeattName: attributesMap.keyset()){
                        string tempValue = null;
                        if(atrributeattName!=null && atrributeattName.equalsIgnoreCase('Number')){
                            List<Object> tempAttributesMap11 = ( List<Object>)attributesMap.get(atrributeattName);
                            system.debug('>>>>>>>>>>>>>..tempValue >>'+tempAttributesMap11);
                            for(Object aName : tempAttributesMap11){
                                 Map<String, Object> singleComp = (Map<String, Object>)aName;
                                Map<String, Object> comsimpleAttr2 = new Map<String, Object>();
                                Map<String, Object> convertedSimpleAttrs = (Map<String, Object>)singleComp.get('attributes');
                                for(String kk : convertedSimpleAttrs.keyset()){
                                    if(kk == 'status')
                                    comsimpleAttr2.put(kk,'Active12');
                                    else 
                                         comsimpleAttr2.put(kk,convertedSimpleAttrs.get(kk));
                                }
                                singleComp.put('attributes',comsimpleAttr2);
                                //system.debug('>>>>>>>>>>>>>...comsimpleAttr2 >>'+singleComp);
                            }
                            tempAttributesMap.put(atrributeattName,tempAttributesMap11);
                            
                        }
                        
                    }
                    if(tempAttributesMap.size()>0){
                        attributesMap.putAll(tempAttributesMap);
                    }
                } 
                
                serviceattachmentstr = JSON.serializePretty(results);
                String str = serviceattachmentstr;
                attmAP.get(attId).body = blob.valueOf(str);
                attsMapToUpdate.put(attId, attmAP.get(attId));
            }
            if (attsMapToUpdate.size() > 0){
                update attsMapToUpdate.values();        
            }
        }catch(Exception e){
            system.debug('Exception in updateUCNumberSpecNumberStatus '+ e);
        }
    }*/
    
}