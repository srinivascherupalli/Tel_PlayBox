public class UpsertSpecificationChangeRequest {
    public Static Map<String, cs_SigmaToCSJSON.cls_products> mapOnlyChargeProduct = new Map<String, cs_SigmaToCSJSON.cls_products>(); 
    public static Map<String,String> allParentSpecId = new Map<String,String>();
    public static void parseSigmaJsonData(cs_SigmaToCSJSON obj){
        try{
            cs_SigmaToCSJSON jsonObj = new cs_SigmaToCSJSON();        
            jsonObj = obj;
            cs_SigmaToCSJSON.cls_productOffering jsonobjPrdtOff = new cs_SigmaToCSJSON.cls_productOffering();
            jsonobjPrdtOff = jsonObj.productOffering;
            List<cs_SigmaToCSJSON.cls_products> productList = new List<cs_SigmaToCSJSON.cls_products>();        
            if(jsonobjPrdtOff.products != null ) {    
                for(cs_SigmaToCSJSON.cls_products prod : jsonobjPrdtOff.products ){ 
                    // Change for EDGE-12675
                    if(prod.allowances != null && (prod.action !='None'/* && prod.action != 'Affected'*/)){
                        mapOnlyChargeProduct.put(prod.specId, prod);
                    }
                    
                    if(prod.products != null  ){                  
                        for(cs_SigmaToCSJSON.cls_products prod_One : prod.products){  
                            if(prod_One.allowances != null && (prod_One.action !='None'/*&& prod_One.action != 'Affected'*/)){
                                mapOnlyChargeProduct.put(prod.specId+prod_One.specId, prod_One);
                            }
                            if(prod_One.products != null ){                         
                                for(cs_SigmaToCSJSON.cls_products prod_Two : prod_One.products){ 
                                    if(prod_Two.allowances != null && (prod_Two.action !='None'/* && prod_Two.action != 'Affected'*/)){
                                        mapOnlyChargeProduct.put(prod_One.specId+prod_Two.specId, prod_Two);
                                    }
                                    if(prod_Two.products != null ){
                                        for(cs_SigmaToCSJSON.cls_products prod_Three : prod_Two.products){ 
                                            if(prod_Three.allowances != null && (prod_Three.action !='None'/* && prod_Three.action != 'Affected'*/)){
                                                mapOnlyChargeProduct.put(prod_Two.specId+prod_Three.specId, prod_Three);
                                                
                                            }
                                        }                                   
                                        
                                    }
                                }                            
                                
                            }
                        }                    
                        
                    }                
                }                                 
            }
        }
        catch (Exception e) {
            system.debug('exception catch '+e);
            Logger.getLogger(UpsertSpecificationObjectRecord.class).debug(e);
            Logger.exitLogger();
        }
    }
    public static void upsertAllowancesChangeRequest(Map<String, cs_SigmaToCSJSON.cls_products> mapOnlyChargeProduct){
        try{
            system.debug('mapOnlyChargeProduct>>>>>' + mapOnlyChargeProduct);
            List<string> lstAutoAddFailJSON = new List<string>();
            String autoAddfalseBillingJSON = '';
            system.debug('Product List >>>>>' + mapOnlyChargeProduct.size());
            for( String productName :mapOnlyChargeProduct.keySet() ){
                system.debug('productName >>>>>' + mapOnlyChargeProduct.get(productName).specid +'>>>>>'+mapOnlyChargeProduct.get(productName));
                Integer staticAttrCounter = 0;
                Integer commercialAttrCounter = 0;
                cs_SigmaToCSJSON.cls_products productList_One = new cs_SigmaToCSJSON.cls_products();
                productList_One  = mapOnlyChargeProduct.get(productName);
                List<cs_SigmaToCSJSON.cls_allowances> allowancesList = new List<cs_SigmaToCSJSON.cls_allowances>();
                if(mapOnlyChargeProduct.containskey(productName))
                    allowancesList = mapOnlyChargeProduct.get(productName).allowances;   
                //Changes End for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM        
                List<cs_SigmaToCSJSON.cls_attributes> billingSpecAttributes = UpsertRequestObjectRecord.getBillingSpecAttributes(productList_One);
                //Changes End for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM
                if(productList_One != null && mapOnlyChargeProduct.containskey(productName)){               
                    if(allowancesList!= null && !allowancesList.isEmpty()){
                        for(cs_SigmaToCSJSON.cls_allowances allowances:allowancesList){
                            if(allowances.allowanceDetails != null){
                                for(cs_SigmaToCSJSON.cls_allowanceDetails allowancesdet:allowances.allowanceDetails){
                                    String[] arrName; 
                                    if(allowancesdet.externalId != null){
                                        arrName= allowancesdet.externalId.split('Allowance');
                                    }
                                    autoAddfalseBillingJSON= '{ "code" : "'+ productList_One.specId+'_Billing_Allowance'+arrName[1] + '", "attributes" : [  ' ;
                                    
                                    if(String.isNotBlank(allowancesdet.type_x)){                                
                                        autoAddfalseBillingJSON += '{"name": "type", "value": "","type": "string"},';
                                    } 
                                    if( String.isNotBlank(allowances.ocsProdID)){
                                        autoAddfalseBillingJSON +='{"name": "ocsProdID", "value": "","type": "string"},';
                                    }
                                    if( String.isNotBlank(allowances.billingSpecId))
                                    {
                                        autoAddfalseBillingJSON +='{"name": "billingSpecId", "value": "","type": "string"},';
                                    }
                                    if(String.isNotBlank(allowancesdet.unitofMeasure) ){
                                        autoAddfalseBillingJSON +='{"name": "unitofMeasure", "value": "","type": "string"},';
                                    }
                                    if(String.isNotBlank(allowancesdet.value) ){
                                        autoAddfalseBillingJSON +='{"name": "value", "value": "","type": "string"},';
                                    }
                                    System.debug(' 1st autoAddfalseBillingJSON ====>'+autoAddfalseBillingJSON);
                                    //autoAddfalseBillingJSON +='{"name": "description", "value": "","type": "string"},{"name": "units", "value": "","type": "string"},{"name": "unitPrice", "value": "","type": "string"}';
                                    commercialAttrCounter++;  
                                    
                                    //Changes Start for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM
                                    autoAddfalseBillingJSON +='{"name": "billDescription", "value": "","type": "string"},{"name": "rateExcludeGST", "value": "","type": "string"}';
                                    System.debug(' 2nd autoAddfalseBillingJSON ====>'+autoAddfalseBillingJSON);
                                    if(billingSpecAttributes.size() > 0)
                                    {
                                        for(cs_SigmaToCSJSON.cls_attributes att : billingSpecAttributes)
                                        {
                                            if(String.isNotBlank(att.interfaceName))
                                            {        
                                                autoAddFalseBillingJSON += ',{"name": "'+ att.interfaceName + '", "value": "","type": "string"}';
                                            } 
                                        }
                                        System.debug('3rd autoAddfalseBillingJSON  ====>'+autoAddFalseBillingJSON);
                                    }
                                    //Changes End for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM
                                }  
                            }
                            
                        }               
                        autoAddfalseBillingJSON += '], "autoAdd": "false" }';               
                        
                        System.debug('Final autoAddfalseBillingJSON ====>'+autoAddfalseBillingJSON);
                    }  
                    System.debug('CommercialAttrCounter ====>'+CommercialAttrCounter);
                    if(CommercialAttrCounter > 0){
                        if(Test.isRunningTest()){
                            lstAutoAddFailJSON.add(autoAddfalseBillingJSON);
                        }
                        else{
                            csedm.API_1.createCFSChangeRequest(autoAddfalseBillingJSON);     
                        }
                    }              
                }
            }
        }catch (Exception e) {
            system.debug('exception catch '+e);
            Logger.getLogger(UpsertSpecificationObjectRecord.class).debug(e);
            Logger.exitLogger();
        }
    }
}