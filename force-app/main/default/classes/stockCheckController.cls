/*Author: Aishwarya
Company: Tesltra 
User Story :EDGE-80858
Description: Lightning UI controller.

***History of Updates 
RaviTeja K: 02/06/2020  EDGE-146972: I do not have to click validate and save to have updated devices in check inventory 
Shresth Dixit : 20/12/2020 DPG-3510 : Implementation to segregate commercial product records returned with respect to PD type
Vamsi Krishn Vaddipalli : 18MAY2021 EDGE-212162 : General Stock Check

*/
public With Sharing class stockCheckController {
    // public static StockCheckResponseDto stockResponse{get;set;}
    
    //Mobile Device Stock Details Wrapper
    public Class DeviceModelWrapper{
        @AuraEnabled
        public String device {get;set;}
        @AuraEnabled
        public String skuId {get;set;}
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public String errorMessage {get;set;}
        @AuraEnabled
        public String restockDate {get;set;}
        @AuraEnabled
        public Integer quantityAvailable {get;set;}
        //Start of EDGE-144680 
        @AuraEnabled
        public String deviceType {get;set;}
        @AuraEnabled
        public String model {get;set;}
        @AuraEnabled
        public String manufacturer {get;set;}
        @AuraEnabled
        public String colour {get;set;}
        //End of EDGE-144680        
    }
    
    //Stock check Wrapper
    public class StockCheck{
        @AuraEnabled
        public String restocked {get;set;}
        @AuraEnabled
        public String stockAvailable {get;set;}
        
    }
    /*-------------------------------------------------------- 
EDGE-80858,98400
Method: getSelectedDevice
Description: Populate devices picklist on UI
Author:Aishwarya
--------------------------------------------------------*/
    @AuraEnabled
    public static map<String,String> getSelectedDevice( string selectedDevice)
    {
        List<String> productName=new List<String>();
        String deviceName='';
        system.debug('selectedDevice' +selectedDevice);
        List<StockProductSpecID__mdt> prodSpec=[SELECT MasterLabel from StockProductSpecID__mdt WHERE StockProductName__c IN 
                                                (SELECT id from StockProductName__mdt WHERE MasterLabel= :selectedDevice)];
        
        for(StockProductSpecID__mdt stMdt:prodSpec){
            productName.add(stMdt.MasterLabel);
        }
        system.debug('productName' +productName);
        
        //EDGE-97079,Map to hold device name and sku Id
        Map<String,String> deviceMap = new Map<String,String>();
        
        List<cspmb__Price_Item__c> modelset = new List<cspmb__Price_Item__c>();
        modelset=[SELECT Model__c,Colour__c ,SKU__c from cspmb__Price_Item__c WHERE ProdSpecId__c IN :productName];
        //deviceSet.add('--None--');
        for(cspmb__Price_Item__c com :modelset ){
            if(com.Model__c !=null && com.Colour__c ==null){
                deviceName=com.Model__c;
                deviceMap.put(com.SKU__c,deviceName); 
                
            }
            
            
            else if(com.Model__c !=null && com.Colour__c !=null){
                deviceName=com.Model__c +' '+ com.Colour__c;
                
            }
            
            deviceMap.put(com.SKU__c,deviceName);  
        }
        system.debug('deviceMap'+deviceMap);
        return deviceMap;
    }
    
    /*-------------------------------------------------------- 
EDGE-98400
Method: getDeviceType
Description: Populate device type picklist on UI
Author:Aishwarya
--------------------------------------------------------*/
    @AuraEnabled
    public static List<String> getDevice(){
        List<String> productName=new List<String>();
        List<StockProductName__mdt> deviceType=[SELECT MasterLabel from StockProductName__mdt];
        system.debug('deviceType' +deviceType);
        productName.add('--None--');
        for(StockProductName__mdt stMdt:deviceType){
            
            productName.add(stMdt.MasterLabel);
        }
        
        return productName;
        
    }
    
    /*-------------------------------------------------------- 
EDGE-80858
Method: getDeviceQuantity
Description: Populate Quantity on UI
Author:Aishwarya
--------------------------------------------------------*/
    
    @AuraEnabled
    public static StockCheck getDeviceQuantity( string selectedDevice)
    {
        system.debug('selectedDevice'+selectedDevice);
        StockCheck wrapper=null;
        wrapper=new StockCheck();
        
        //List<cspmb__Price_Item__c> result= new List<cspmb__Price_Item__c>();
        
        StockCheckCalloutHandler stock=new StockCheckCalloutHandler();
        StockCheckResponseDto stockResponse=new StockCheckResponseDto();
        
        
        //result=[SELECT DeviceModel__c, SKU__c from cspmb__Price_Item__c where DeviceModel__c =:selectedDevice];
        //system.debug('result' + result);
        
        //Callout method of EDGE-80857
        stockResponse=stock.syncExecute(selectedDevice);
        system.debug('stockResponse' + stockResponse);
        
        //Check if stock response from callout of  EDGE-80857 is NUll or not
        //EDGE-97079 Fixes
        if(stockResponse !=NULL && stockResponse.inventory !=Null && (!stockResponse.inventory.isEmpty())){
            
            //Added by Vamsi for EDGE-212162 on 18MAY2021 starts
            Set<String> skuList = getSKUIds();
         if(String.isNotBlank(stockResponse.productId) && skuList != null && !skuList.isEmpty() && skuList.contains(stockResponse.productId))
         {
            //Added by Vamsi for EDGE-212162 on 18MAY2021 ends
            wrapper.stockAvailable=string.valueOf(stockResponse.inventory[0].availableQuantity);
            
            if(stockResponse.inventory[0].nextReplenishmentDate !=Null){
                Datetime restock=(Datetime)Date.valueOf(stockResponse.inventory[0].nextReplenishmentDate);
                wrapper.restocked= restock.format('d MMMM,  yyyy');
                system.debug('restocked' + wrapper.restocked);
            }
            else{
                wrapper.restocked=null;
            }
            
            system.debug('stockAvailable' + wrapper.stockAvailable);
        }
        }
        else{
            
            wrapper.stockAvailable=Label.StockCheckError;
        }
        
        
        return wrapper;
        
    }
    
    /*-------------------------------------------------------- 
EDGE-80858,98400
Method: setProductDetails
Description: set Product Details on UI
Author:Aishwarya

Updates:
RaviTeja K: 02/06/2020  EDGE-146972: Updated Method "setProductDetails" by adding additinal parameter for Attribute map. We can read the devices selected from the Java script.
Shresth : 20/12/2020 DPG-3510 : Added additional parameter type to filter commercial product. Added AccessoryModel in the condition which contains the commercial product for pd mobile accessory
--------------------------------------------------------*/
    
    @AuraEnabled
    public static List<DeviceModelWrapper> setProductDetails(String basketid,string attrJson, string type, string solutionName)//DPG-3510, Ila: Added solutionName parameter
    {
        List<DeviceModelWrapper> wrapperList = new List<DeviceModelWrapper>();
        DeviceModelWrapper wrapper=null;
        List<String> paymentTypelist=new List<String>();
           //EDGE-146972
            if(attrJson!=null && attrJson!=''){
                    system.debug('attrJson'+attrJson);
                    Map<String,Map<String,SolutionDTO.Attributes>>  guidToAttmapOfMap = (Map<String,Map<String,SolutionDTO.Attributes>>)JSON.deserialize(String.valueOf(attrJson), Map<String,Map<String,SolutionDTO.Attributes>>.class);
                    for(String guid:guidToAttMapofMap.keySet()){
                        Map<String,SolutionDTO.Attributes> AttMap=guidToAttMapofMap.get(guid);          
                        for(SolutionDTO.Attributes  attr:AttMap.values()){
                            if(attr.Name=='PaymentTypeLookup' || attr.Name == 'ContractType' || attr.name ==  'AccessoryModel'){//DPG-3510
                                paymentTypelist.add(attr.Value);
                            }                
                          
                        }
                        system.debug('AttMap&&' +AttMap);
                    } 
                } //End EDGE-146972
             else if (basketid!=null){
        List<String> productName=new List<String>();
        List<String> prodDefName=new List<String>();
        
        List<StockProductSpecID__mdt> prodSpec=[SELECT MasterLabel from StockProductSpecID__mdt];
        
        for(StockProductSpecID__mdt stMdt:prodSpec){
            productName.add(stMdt.MasterLabel);
        }
        system.debug('productName' +productName);
        List<cscfga__Product_Definition__c> productDef=new List<cscfga__Product_Definition__c>();
        productDef=[SELECT Name FROM cscfga__Product_Definition__c WHERE product_Specification__c IN :productName];
        for(cscfga__Product_Definition__c confing: productDef){
            prodDefName.add(confing.Name);
        }
        system.debug('productDef' +prodDefName);
        List< cscfga__Product_Configuration__c > productsAlreadyInTheBasket = new List < cscfga__Product_Configuration__c > ();
        productsAlreadyInTheBasket = [
            SELECT id,cscfga__Root_Configuration__c,
            cscfga__Product_Definition__r.Name
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Product_Basket__c =: basketid AND cscfga__Product_Definition__r.Name IN :prodDefName
        ];
        List<ID> productIDs=new List<ID>();
        for(cscfga__Product_Configuration__c confing: productsAlreadyInTheBasket){
            productIDs.add(confing.id);
        }
        
        system.debug('productsAlreadyInTheBasket' + productsAlreadyInTheBasket);
        system.debug('productIDs>>>>' + productIDs);
                    //List<String> paymentTypelist=new List<String>();
        List<cscfga__Attribute__c> detailsList = [SELECT id,cscfga__Value__c,name,cscfga__Product_Configuration__r.Name,cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.cscfga__Description__c  FROM cscfga__Attribute__c where cscfga__Product_Configuration__c IN :productIDs and name IN ('PaymentTypeLookup','ContractType','AccessoryModel')]; //DPG-3510
        system.debug('detailsList' + detailsList);
        
        if(detailsList!=null){
            for(cscfga__Attribute__c detail: detailsList){
                if( detail.name == 'PaymentTypeLookup' ||detail.name == 'ContractType'|| detail.name ==  'AccessoryModel'){//DPG-3510
                            
                                // wrapper=new DeviceModelWrapper();
                                //wrapper.device = detail.cscfga__Product_Configuration__r.Name ;
                                //system.debug('wrapper.device' + wrapper.device);
                    
                    paymentTypelist.add(detail.cscfga__Value__c);
                    // wrapper.skuId = detail.cscfga__Value__c;
                    // wrapperList.add(wrapper.device);
                    system.debug('paymentTypelist' + paymentTypelist);
                }
                
            }
        }
           }
        
        List<cspmb__Price_Item__c> modelset = new List<cspmb__Price_Item__c>();
        if(paymentTypelist!=null){
            system.debug('paymentTypelist'+paymentTypelist);
            //Start of EDGE-144680 - Added additional columns DeviceType,Model,Manufacturer,Colour without concatenation 

            //DPG-3510 start
          
            //modelset=[SELECT id,Name,Model__c,Manufacturer__c,Colour__c ,SKU__c from cspmb__Price_Item__c WHERE id IN :paymentTypelist AND cspmb__Product_Definition_Name__c=:type];
            String query = 'SELECT id,Name,Model__c,Manufacturer__c,Colour__c ,SKU__c from cspmb__Price_Item__c WHERE id IN :paymentTypelist';
            //DPG-3510, Ila: Added solutionName parameter
            if(String.isNotBlank(type) && solutionName=='Adaptive Mobility'){
                query += ' AND cspmb__Product_Definition_Name__c=:type';
            }
            modelset = Database.query(query);
            //DPG-3510 end
            system.debug('modelset'+modelset);
            for(cspmb__Price_Item__c detail: modelset){
                wrapper=new DeviceModelWrapper();
                
                wrapper.deviceType = detail.Name !=null ? detail.Name : null;
                wrapper.model = detail.Model__c !=null ? detail.Model__c : null;
                wrapper.manufacturer = detail.Manufacturer__c !=null ? detail.Manufacturer__c : null;
                wrapper.colour = detail.Colour__c !=null ? detail.Colour__c : null;
                //End of EDGE-144680
                wrapper.skuId = detail.SKU__c;
                wrapperList.add(wrapper);
            }
        }
        
        return wrapperList;
    }
    /*-------------------------------------------------------- 
EDGE-80858
Method: checkStock
Description: Returns stock available in Inventory
Author:Aishwarya
--------------------------------------------------------*/
    
    @AuraEnabled
    public static StockCheck checkStock( string skuID)
    {
        StockCheck wrapper=null;
        wrapper=new StockCheck();
        StockCheckCalloutHandler stock=new StockCheckCalloutHandler();
        StockCheckResponseDto stockResponse=new StockCheckResponseDto();
        //Callout method of EDGE-80857
        stockResponse=stock.syncExecute(skuID);
        system.debug('stockResponse' + stockResponse);
        //Check if stock response from callout of  EDGE-80857 is NUll or not
        if(stockResponse !=NULL && stockResponse.inventory !=Null && (!stockResponse.inventory.isEmpty())){
            
             //Added by Vamsi for EDGE-212162 on 18MAY2021 starts
            Set<String> skuList = getSKUIds();
         if(String.isNotBlank(stockResponse.productId) && skuList != null && !skuList.isEmpty() && skuList.contains(stockResponse.productId))
         {
            //Added by Vamsi for EDGE-212162 on 18MAY2021 ends
            wrapper.stockAvailable=string.valueOf(stockResponse.inventory[0].availableQuantity);
            if(stockResponse.inventory[0].nextReplenishmentDate !=Null){
                Datetime restock=(Datetime)Date.valueOf(stockResponse.inventory[0].nextReplenishmentDate);
                wrapper.restocked= restock.format('d MMMM,  yyyy');
            }
            else{
                wrapper.restocked=null;
            }
            system.debug('stockAvailable' + wrapper.stockAvailable);
        }
        }

        else{
            wrapper.stockAvailable=Label.StockCheckError;
        } 
        return wrapper;
    }
    
    
    /*-------------------------------------------------------- 
EDGE-80860
Method: checkStockQuantity
Description: Returns stock for multiple devices available in Inventory
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    @AuraEnabled
    public static List<DeviceModelWrapper> checkStockQuantity(List<String> skuidList,List<DeviceModelWrapper> displayWrapper)
    {   System.debug('skuidList before'+skuidList);
        StockCheckRequestDto requestDTO = StockCheckCalloutHandler.createPayload(skuidList);
        StockCheckResponseDto responseDto=StockCheckCalloutHandler.calloutToStockCheck(requestDTO);
        Map<String,StockCheckResponseDto.Products> mapSKUtoQuantity =  new Map<String,StockCheckResponseDto.Products>();
        if(responseDto!=null){
            System.debug('responseDto.products: '+responseDto.products);
            if(responseDto.products!=null && !responseDto.products.isEmpty()){
                //Added by Vamsi for EDGE-212162 on 18MAY2021 starts
                Set<String> skuList = getSKUIds();
                //Added by Vamsi for EDGE-212162 on 18MAY2021 ends
                for(StockCheckResponseDto.Products product: responseDto.products){
                    //EDGE-123199 Kalashree Borgaonkar. Remove spaces
                    //Added by Vamsi for EDGE-212162 on 18MAY2021 starts
                      if(skuList != null && !skuList.isEmpty() && skuList.contains(product.id))
                      {
                    //Added by Vamsi for EDGE-212162 on 18MAY2021 ends
                    mapSKUtoQuantity.put(product.id.trim(), product);
                }    
                }    
                if(!mapSKUtoQuantity.keyset().isempty()){
                    for(DeviceModelWrapper wrapper: displayWrapper){
                        System.debug('wrapper: '+displayWrapper);
                            
                        if(mapSKUtoQuantity.keyset().contains(wrapper.skuId) && skuidList.contains(wrapper.skuId)){
                            wrapper.quantityAvailable= mapSKUtoQuantity.get(wrapper.skuId).availableQuantity;
                           //EDGE-192765. Kalashree Borgaonkar. show formatted number  
                            wrapper.message = wrapper.quantityAvailable != 0 ? ((Decimal)wrapper.quantityAvailable).format()+' Available' : null;
                            String restockString = mapSKUtoQuantity.get(wrapper.skuId).nextReplenishmentDate;
                            Datetime restockDate = (restockString!=null && !String.isBlank(restockString))? (Datetime)Date.valueOf(mapSKUtoQuantity.get(wrapper.skuId).nextReplenishmentDate):null;
                            wrapper.restockDate = restockDate!=null? restockDate.format('d MMMM,  yyyy'):null;
                        }
                        //EDGE-125178,EDGE-128883. Kalashree Borgaonkar. Fix for error showing message
                        else{
                            wrapper.message=null;
                            wrapper.errorMessage=null;
                            wrapper.quantityAvailable=null;
                        }
                    } 
                }
            }
            else{
                System.debug('skuidList: '+skuidList);
                for(DeviceModelWrapper wrapper: displayWrapper){
                    if(skuidList.contains(wrapper.skuId)){
                        wrapper.errorMessage = Label.StockCheckErrorMessage; 
                    }
                    
                } 
            }     
        }
        System.debug('displayWrapper: '+displayWrapper);
        return displayWrapper;
    }

    /*-------------------------------------------------------- 
EDGE-212162
Method: getSKUIds
Description: Returns SKUids from StockProductSpecId's metadata
Author:Vamsi Krishna Vaddipalli
--------------------------------------------------------*/
    public static Set<String> getSKUIds()
    {
        Set<String> listOfProducts = new Set<String>();
        Set<String> skuIds = new Set<String>();
        List<StockProductSpecID__mdt> stockList = [SELECT MasterLabel FROM StockProductSpecID__mdt];

        for(StockProductSpecID__mdt stMdt:stockList){
            
            listOfProducts.add(stMdt.MasterLabel);
        }

        Model_PriceItem modelPriceItem = new Model_PriceItem();
        List<cspmb__Price_Item__c> priceItems = modelPriceItem.fetchActiveSKU(listOfProducts);
       for(cspmb__Price_Item__c items:priceItems)
       {
        skuIds.add(items.SKU__c);
       }

       return skuIds;
    }
}