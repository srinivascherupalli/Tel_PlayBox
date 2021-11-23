/*
===============================================================================================================================
Class : AssetUpsertionHelper
Developer Name : Shubhi
Test Class : AssetUpsertionHelperTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia  3/9/2019     Edge-107843 CS should maintain the association of account to 
                                            subscription / service to device identifiers during 
                                            NEW / MAC scenarios so that reverse logistics solution can be supported
2.        shubhi Vijayvergia  24/9/2019     <Forward Logistics> Device Modelling : Mobile Device and Broadsoft Device Product 
                                            Module change to rename the device identifier
                                            attribute name and introduce device identifier type
3.        Shubhi Vijayvergia                    EDGE-119580
4.        Prajakta Patil                        EDGE-115932 
5.        Vaibhav             13/07/2020        EDGE-158047
6.        Ankit Goswami       05/12/2020        EDGE-193753: Transition Device status update
7.        Ankit Goswami       08/12/2020        EDGE-193752: Device Id and Device status update
8.        Prajakta            22/03/2021        EDGE-170530
9.        Pawan               09-APR-2021       EDGE-203885 :added null check assetListnew != null 
10.       Akanksha            12-04-201         EDGE-202433 added code to update asset status to returned for NFR devices
11.       Suyash Chiplunkar   10/08/2021     DIGI-4289 - DPG | SD-WAN | CloudSense to create assets for SD-WAN related subscriptions
===============================================================================================================================
*/
public  without sharing class AssetUpsertionHelper {
        
    @InvocableMethod
    public static List<ID> processAssetCreation(List<ID> orderIds) {
        system.debug('Inside processAssetCreation>>>>' + orderIds);
        Set<String> AssetEligibleProductCodes=new Set<String>();
        Map<String,AssetCreateDTO> AssetCreateDTOMap=new Map<String,AssetCreateDTO>();
        for(AssetEligibleProductCodes__mdt prodcode:[Select label,DeveloperName from AssetEligibleProductCodes__mdt]){
            AssetEligibleProductCodes.add(prodcode.DeveloperName);
        }
        system.debug('Inside AssetEligibleProductCodes>>>>'+AssetEligibleProductCodes);
        if(!AssetEligibleProductCodes.IsEmpty()){
            Map<Id,csord__Service__c> serviceMap=new Map<Id,csord__Service__c>([SELECT id,csord__Subscription__c, 
                                            csord__Subscription__r.csord__Account__c, 
                                            csord__Subscription__r.MarketableOffer__r.Offer_ID__c,
                                            csordtelcoa__Replaced_Service__c,Scenario_Type__c,Quantity__c 
                                            FROM csord__Service__c 
                                                WHERE csord__Order__c IN:orderIds 
                                                AND csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c IN: AssetEligibleProductCodes]);       
            Map<Id, Attachment> serviceIdToSpecAttachMap = new Map<Id, Attachment>();
            if(!serviceMap.isEmpty()){
                for(Attachment tempAttachment: [SELECT id, name, body, parentId 
                                            FROM Attachment 
                                            WHERE parentId IN: serviceMap.keyset() 
                                            AND name = 'ServiceSpecifications.json']){
                    serviceIdToSpecAttachMap.put(tempAttachment.parentId, tempAttachment);
                }
                system.debug('Inside serviceIdToSpecAttachMap>>>>'+serviceIdToSpecAttachMap);
                system.debug('Inside serviceMap>>>>'+serviceMap);
        Map<String,Integer> guidToQuantityMap= new Map<String,Integer>(); //EDGE-119580
                if(!serviceIdToSpecAttachMap.IsEmpty()){
                    for(Attachment att:serviceIdToSpecAttachMap.values()){
                        system.debug('STring json-->'+att.body.toString());
                        List<CS_ServiceSpecificationV2.ServiceSpecifications> specs = CS_ServiceSpecificationV2.parseSpec(att.body.toString(), 'Fulfilment');
                        AssetCreateDTO assetDTO = new AssetCreateDTO();
                        for(CS_ServiceSpecificationV2.ServiceSpecifications spec: specs){
                            System.debug('spec'+spec);
                            String speccode= String.valueof(spec.code).replace('_Fulfilment','');
                            String specstatus= String.valueof(spec.status); //digi-27111
                            System.debug('speccode:'+specstatus); //digi-27111
                            System.debug('speccode:'+speccode);
                            if(AssetEligibleProductCodes.contains(speccode) && specstatus=='Created'){ //digi-27111 added specStatus condition
                                assetDTO.serviceId=att.parentId;
                                assetDTO.specCode=speccode;
                                assetDTO.name=spec.description;
                                //assetDTO.assetStatus='Provisioning In Progress';//EDGE-193753 commented 
                                assetDTO.description=spec.description;
                                assetDTO.ownership='Unmanaged';
                                assetDTO.assetInstanceId=spec.guid;
                                if(Label.SDWAN_Device_Offer == speccode){//DIGI-4289//DIGI-27641
                                    if(spec.attributes.Device != NULL && !spec.attributes.Device.IsEmpty()){
                                        assetDTO.SKU = spec.attributes.Device[0].attributes.sku;
                                    }   
                                }else{
                                    assetDTO.SKU=spec.attributes.SKU;
                                }
                                
                                assetDTO.assetUUID=spec.attributes.deviceUUID;
                                assetDTO.assetID=spec.attributes.DeviceID; //Edge-112340
                                assetDTO.assetIDType=spec.attributes.DeviceIDType; //Edge-112340
                                assetDTO.assetStatus = (String.isNotBlank(spec.attributes.deviceID)? 'Active':'Provisioning In Progress');   //EDGE-193753                                
                                assetDTO.quantity=spec.attributes.quantity;
                                assetDTO.deviceQuantity=spec.attributes.deviceQuantity;
                                
                                if(assetDTO.quantity!=null && assetDTO.quantity!=0){  
                                  guidToQuantityMap.put(spec.guid,spec.attributes.quantity);
                                }else{
                                  guidToQuantityMap.put(spec.guid,spec.attributes.deviceQuantity);
                                } 
                                
                                if(serviceMap.containskey(att.parentId)){
                                    if(serviceMap.get(att.parentId).csord__Subscription__c!=null){
                                        assetDTO.subcriptionId=serviceMap.get(att.parentId).csord__Subscription__c;
                                    }                       
                                    if(serviceMap.get(att.parentId).csord__Subscription__r.csord__Account__c!=null){
                                        assetDTO.accountID=serviceMap.get(att.parentId).csord__Subscription__r.csord__Account__c;
                                    }
                                    if(serviceMap.get(att.parentId).csord__Subscription__r.MarketableOffer__r.Offer_ID__c!=null){
                                        assetDTO.offerId=serviceMap.get(att.parentId).csord__Subscription__r.MarketableOffer__r.Offer_ID__c;
                                    }
                                }
                                AssetCreateDTOMap.put(assetDTO.serviceId,assetDTO);
                            }
                            
                        }
                    }
                    if(AssetCreateDTOMap.size()>0 && ! AssetCreateDTOMap.IsEmpty()){
                        AssetUpsertionHelper.upsertAsset(AssetCreateDTOMap,guidToQuantityMap);
                    }
                }
            }
        }
        
        return orderIds;
    }
// Modified by Aman Soni as part of Tech Debt story || EDGE-127666 ---> Start
public static void upsertAsset(Map<String,AssetCreateDTO> AssetCreateDTOMap,Map<String,Integer> guidToQuantityMap){
List<Asset> assetList=new List<Asset>();
    try{ 
        Map<String,Integer> guidToQuantityMapexistingAsset=new Map<String,Integer>();
        guidToQuantityMapexistingAsset=AssetUpsertionHelper.checkForExistingAsset(guidToQuantityMap);
        system.debug('AssetCreateDTOMap-->'+AssetCreateDTOMap);
        
        for(AssetCreateDTO assetDTO:AssetCreateDTOMap.Values()){
        system.debug('AssetCreateDTOMapValue-->'+assetDTO);
            if(assetDTO.name!=null){
                if(assetDTO.quantity!=null && assetDTO.quantity!=0){
                    Integer Quantity=0;
                    if(!guidToQuantityMapexistingAsset.isEmpty() && guidToQuantityMapexistingAsset.containskey(assetDTO.assetInstanceId) && guidToQuantityMapexistingAsset.get(assetDTO.assetInstanceId)<Integer.valueof(assetDTO.quantity)){//EDGE-119580           
                        Quantity=Integer.valueof(assetDTO.quantity)-guidToQuantityMapexistingAsset.get(assetDTO.assetInstanceId);
                    }
                    if(!guidToQuantityMapexistingAsset.isEmpty() && !guidToQuantityMapexistingAsset.containskey(assetDTO.assetInstanceId)){
                        Quantity=Integer.valueof(assetDTO.quantity);
                    }
                    else{
                        Quantity=Integer.valueof(assetDTO.quantity);
                    }
                    for(Integer i=0; i<Quantity; i++){
                        checkAst(assetDTO,assetList);
                    }                   
                }
                else{
                    if(!guidToQuantityMapexistingAsset.isEmpty()){//EDGE-119580
                        if(!guidToQuantityMapexistingAsset.containskey(assetDTO.assetInstanceId)){
                            checkAst(assetDTO,assetList);
                        }
                    }
                    else{
                            checkAst(assetDTO,assetList);
                        }
                }  
            }
        }
        system.debug('assetList-->'+assetList);
        if(assetList.size()>0 && !assetList.IsEmpty()){
          upsert assetList;  
        }
    }
    catch(Exception e){
        System.debug('Exception Occur In Asset');
        Logger.getLogger(AssetUpsertionHelper.class).debug(e);
        Logger.exitLogger();
    }
}
// Modified by Aman Soni as part of Tech Debt story || EDGE-127666 ---> End

// Added by Aman Soni as part of Tech Debt story || EDGE-127666 ---> Start
public static void checkAst(AssetCreateDTO assetDTO,List<Asset> assetList){
Asset ast=assetTobeInserted(assetDTO);
    if(ast!=null){
       assetList.add(ast); 
    }
}
// Added by Aman Soni as part of Tech Debt story || EDGE-127666 ---> End

    //EDGE-107844 added by Manish
    public static void updateAsset(List<String> deviceID,String serviceId,String deviceIdType){ 
        List<Asset> asObj = [Select Id, csord__Service__c, AssetIDType__c, AssetID__c, Status  from Asset where csord__Service__c = :serviceId OR csord__Service__r.csord__Service__c = :serviceId];
        List<Asset> assetList = new List<Asset>();
        Integer i=0;
        if(asObj.size()>0){
            for(String str : deviceID ){
                if(i<asObj.size()){
                    asObj.get(i).AssetIDType__c = deviceIdType;
                    asObj.get(i).AssetID__c = str;
                    asObj.get(i).Status = 'Active';
                    assetList.add(asObj.get(i));
                    i++;
                }
          }
            if(assetList.size()>0){
                update assetList;
            }
        }
    
    } 
  
  // added as EDGE-115932
  //modified method as part of EDGE-158047
    public static void updateAssetMSUpdate(Map<String,Map<String,String>>servnumDeviceMap,List<string>srvcNumberList,Map<String, String>servnumDeviceBlankMap){ //EDGE-170530
        List<Id>serviceIdList = new List<Id>();
        Map<string,List<Asset>> servnumAsetMap=new Map<string,List<Asset>>();
        List<csord__Service__c>ServiceList = new List<csord__Service__c>();
        for(csord__Service__c ser : [select id, csordtelcoa__Service_Number__c from csord__Service__c where  csordtelcoa__Service_Number__c IN: srvcNumberList])
        {
            system.debug('Inside for loop=='+ser);
            serviceIdList.add(ser.id);
            ServiceList.add(ser);
        }
        system.debug('serviceIdList::'+serviceIdList);
        //List<Asset> asObj = [Select Id, csord__Service__c from Asset where csord__Service__c IN :serviceIdList];
        for(Asset asObj : [Select Id, csord__Service__c ,csord__Service__r.csordtelcoa__Service_Number__c,AssetIDType__c,AssetID__c,Status from Asset where csord__Service__c IN :serviceIdList])
        {
            if(asObj.csord__Service__r.csordtelcoa__Service_Number__c!=null)
            if(servnumAsetMap.containskey(asObj.csord__Service__r.csordtelcoa__Service_Number__c)){
                    List<Asset> tempAsset = servnumAsetMap.get(asObj.csord__Service__r.csordtelcoa__Service_Number__c);
                    tempAsset.add(asObj);
                    servnumAsetMap.put(asObj.csord__Service__r.csordtelcoa__Service_Number__c,tempAsset);
                }
                else {
                        servnumAsetMap.put(asObj.csord__Service__r.csordtelcoa__Service_Number__c,new List<Asset>{asObj});
                }
            //servnumAsetMap.put(asObj.csord__Service__r.csordtelcoa__Service_Number__c,asObj);
        }
        
        
        List<Asset> assetList = new List<Asset>();
        List<Asset> assetListnew = new List<Asset>();
        /*for(string ser : servnumDeviceMap.keyset()){
            Map<String,String> devicemap = servnumDeviceMap.get(ser);
            
            for(String deviceId : devicemap.keyset())
            {   
                if(servnumAsetMap.get(ser)!=null){
                for(Asset aset : servnumAsetMap.get(ser) ){
                //Asset aset =servnumAsetMap.get(ser);
                aset.AssetIDType__c = devicemap.get(deviceId);
                aset.AssetID__c = deviceId;
                aset.Status = 'Active';
                assetList.add(aset);
                }
                }
            }
        }*/
        
        if(!servnumDeviceMap.isEmpty()){
         for(string ser : servnumDeviceMap.keyset()){
            Map<String,String> devicemap = servnumDeviceMap.get(ser);
            if(servnumAsetMap != null){
            assetListnew=servnumAsetMap.get(ser);
            }
           integer i=0;
           for(String deviceId : devicemap.keyset())
            {   //EDGE-203885 :added null check assetListnew != null
             if(assetListnew != null && !assetListnew.isEmpty() && assetListnew[i]!=null){
                Asset aset =assetListnew[i];
                aset.AssetIDType__c = devicemap.get(deviceId);
                aset.AssetID__c = deviceId;
                aset.Status = 'Active';
                assetList.add(aset);
                i++;
                }
            }
        }}
        else if(!servnumDeviceBlankMap.isEmpty()){ //EDGE-170530
            
            for(string srv :servnumDeviceBlankMap.keyset()){
            
                assetListnew=servnumAsetMap.get(srv);
                integer j=0;
                //EDGE-203885 :added null check assetListnew != null
                if(assetListnew != null && !assetListnew.isEmpty() && assetListnew[j]!=null){
                Asset asset1 =assetListnew[j];
                asset1.AssetIDType__c = '';
                asset1.AssetID__c = '';
                assetList.add(asset1);
                j++;
                }
            }
            
        }
        system.debug('assetList'+assetList);
        if(!assetList.isEmpty()){
            update assetList;
        }
        
    }   
  // End EDGE-115932
  
  //added for EDGE-119580 added by shubhi
  public static Map<String,Integer> checkForExistingAsset(Map<String,Integer> guidToQuantityMap){
    Map<String,Integer> returnmap=new Map<String,Integer>();
    for(AggregateResult ar:[SELECT AssetInstanceID__c,COUNT(Id) myCount FROM asset WHERE AssetInstanceID__c IN:guidToQuantityMap.keyset() group by AssetInstanceID__c]){        
        returnmap.put((string) ar.get('AssetInstanceID__c'),(integer) ar.get('myCount'));
      }
    return returnmap;
  }
  //added for EDGE-119580 added by shubhi
    public static Asset assetTobeInserted(AssetCreateDTO assetDTO){
        Asset ast=new Asset();
        ast.accountId=assetDTO.accountID;
        ast.name=assetDTO.name;
        ast.Product_Code__c=assetDTO.specCode;
        ast.Product_Description__c=assetDTO.description;
        ast.Stock_Keeping_Unit__c=assetDTO.SKU;
        ast.Quantity=1;
        ast.Status=assetDTO.assetStatus;
        ast.csord__Service__c=assetDTO.serviceId;
        ast.Subscription__c=assetDTO.subcriptionId;
        ast.OfferID__c=assetDTO.offerId;    
        ast.AssetUUID__c=assetDTO.assetUUID;
        ast.Ownership__c=assetDTO.ownership;
        ast.AssetInstanceID__c=assetDTO.assetInstanceId; 
        ast.AssetID__c =assetDTO.assetID;//Added as part of EDGE-193752
        ast.AssetIDType__c =assetDTO.assetIDType;//Added as part of EDGE-193752
        return ast;       
    }
    public static void updateAssetToReturned(List<Id>serviceIdList)
    { 
         List<Asset> assetList = new List<Asset>();
        List<Asset> assetToBeUpdated = [Select Id, csord__Service__c ,csord__Service__r.csordtelcoa__Service_Number__c,AssetIDType__c,AssetID__c,Status from Asset where csord__Service__c IN :serviceIdList];
        for(Asset asObj : assetToBeUpdated)
        {
            asObj.Status ='Returned';
            assetList.add(asObj);
        }
        system.debug('assetList'+assetList);
        if(!assetList.isEmpty()){
            update assetList;
        }   
    }
}