/* Class Name: UpsertRequestObjectRecord

ChagneSet No    Name            Date                    Description
CH-1            Abinash         10/18/2018              EDGE-45053 CS adaptor changes to support assurance phase flag and EDM package upgrades          
*/
public with sharing class UpsertRequestObjectRecord {
    static Map<String,String> allParentSpecId = new Map<String,String>();  
    public static List<string> lstAutoAddTrueJSON = new List<string>();
    public static List<string> lstAutoAddFailJSON = new List<string>();
    public static void upsertAttribute(cs_SigmaToCSJSON obj){
        try{
            Map<String, cs_SigmaToCSJSON.cls_products> mapOnlyProduct = new Map<String, cs_SigmaToCSJSON.cls_products>();        
            cs_SigmaToCSJSON jsonObj = new cs_SigmaToCSJSON();        
            jsonObj = obj;
            cs_SigmaToCSJSON.cls_productOffering jsonobjPrdtOff = new cs_SigmaToCSJSON.cls_productOffering();
            jsonobjPrdtOff = jsonObj.productOffering;
            List<cs_SigmaToCSJSON.cls_products> productList = new List<cs_SigmaToCSJSON.cls_products>();        
            if(jsonobjPrdtOff.products != null ) {    
                for(cs_SigmaToCSJSON.cls_products prod : jsonobjPrdtOff.products ){ 
                    // Change for EDGE-12675
                    if(prod.attributes != null && (prod.action !='None'/* && prod.action != 'Affected'*/)){
                        for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar : prod.productStaticCharacteristics)
                        {
                            if(prodStcChar.name == 'TechPhases' && prodStcChar.value != 'false')
                            {
                                mapOnlyProduct.put(prod.specId, prod);
                                allParentSpecId.put(prod.specId, null);  
                            }
                        }                 
                    }
                    
                    if(prod.products != null  ){                  
                        for(cs_SigmaToCSJSON.cls_products prod_One : prod.products){  
                            if(prod_One.attributes != null && (prod_One.action !='None'/* && prod_One.action != 'Affected'*/)){
                                for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_2 : prod_One.productStaticCharacteristics)
                                {
                                    if(prodStcChar_2.name == 'TechPhases' && prodStcChar_2.value != 'false')
                                    {
                                        mapOnlyProduct.put(prod.specId+prod_One.specId, prod_One);
                                        
                                        for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_3 : prod.productStaticCharacteristics)
                                        {
                                            if(prodStcChar_3.name == 'TechPhases' && prodStcChar_3.value != 'false')
                                            {
                                                allParentSpecId.put(prod_One.specId, prod.specId);
                                            }      
                                        }
                                    }
                                }
                            }
                            if(prod_One.products != null ){                         
                                for(cs_SigmaToCSJSON.cls_products prod_Two : prod_One.products){ 
                                    if(prod_Two.attributes != null && (prod_Two.action !='None'/* && prod_Two.action != 'Affected'*/)){
                                        for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_5 : prod_Two.productStaticCharacteristics)
                                        {
                                            if(prodStcChar_5.name == 'TechPhases' && prodStcChar_5.value != 'false')
                                            {
                                                mapOnlyProduct.put(prod_One.specId+prod_Two.specId, prod_Two);
                                                for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_6 : prod_One.productStaticCharacteristics)
                                                {
                                                    if(prodStcChar_6.name == 'TechPhases' && prodStcChar_6.value != 'false')
                                                    {
                                                        allParentSpecId.put(prod_Two.specId, prod_One.specId);
                                                    }                                    
                                                }      
                                            }
                                        }
                                    }
                                    if(prod_Two.products != null ){
                                        for(cs_SigmaToCSJSON.cls_products prod_Three : prod_Two.products){ 
                                            if(prod_Three.attributes != null && (prod_Three.action !='None'/* && prod_Three.action != 'Affected'*/)){
                                                for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_8 : prod_Three.productStaticCharacteristics)
                                                {
                                                    if(prodStcChar_8.name == 'TechPhases' && prodStcChar_8.value != 'false')
                                                    {
                                                        mapOnlyProduct.put(prod_Two.specId+prod_Three.specId, prod_Three);
                                                        for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_9 : prod_Two.productStaticCharacteristics)
                                                        {
                                                            if(prodStcChar_9.name == 'TechPhases' && prodStcChar_9.value != 'false')
                                                            {
                                                                allParentSpecId.put(prod_Three.specId, prod_Two.specId);
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
                        
                    }                
                }                                 
            }    
            String autoAddTrueJSON = '';
            String autoAddfalseJSON = '';
            
            //Changes for 20565 Mapping Block -- start
            Map<String, Map<String, String>> mapsourceTarget = new Map<String, Map<String, String>> ();
            for( String productName :mapOnlyProduct.keySet() )
            {
                List<cs_SigmaToCSJSON.cls_mappingRules> mappingRulesList = new List<cs_SigmaToCSJSON.cls_mappingRules>();
                if(mapOnlyProduct.get(productName).mappingRules !=null){
                    mappingRulesList = mapOnlyProduct.get(productName).mappingRules;
                }
                if (mappingRulesList.size() > 0) {
                    for (cs_SigmaToCSJSON.cls_mappingRules mappingRule: mappingRulesList) {
                        Map<String, String> sourceTargetMap = new Map<String,String> ();
                        sourceTargetMap.put(mappingRule.target.characteristicId, mappingRule.source.productId);
                        mapsourceTarget.put(mappingRule.target.productId, sourceTargetMap);
                    }
                }
            }
            //Changes for 20565 Mapping Block -- end
            
            for( String productName :mapOnlyProduct.keySet() ){
                Integer staticAttrCounter = 0;
                Integer commercialAttrCounter = 0;
                cs_SigmaToCSJSON.cls_products productList_One = new cs_SigmaToCSJSON.cls_products();
                productList_One  = mapOnlyProduct.get(productName);
                List<cs_SigmaToCSJSON.cls_attributes> attList = new List<cs_SigmaToCSJSON.cls_attributes>();
                attList = mapOnlyProduct.get(productName).attributes;            
                if(productList_One != null ){               
                    autoAddTrueJSON = '{ "code" : "'+ productList_One.specId+'_Fulfilment' + '", "attributes" : [  ' ;
                    autoAddfalseJSON= autoAddTrueJSON;
                    boolean checkSuccess = false;
                    boolean checkfalse = false;  
                    boolean isFulfillmentcreate = false;
                    if(attList.size() > 0){
                        for(cs_SigmaToCSJSON.cls_attributes att : attList){    
                            isFulfillmentcreate = getFulfilmentresult(att.staticCharacteristics);
                            if(isFulfillmentcreate){
                                if(att.default_x != null && att.default_x != ''){
                                    
                                    autoAddTrueJSON +=  '{"name" : "'+ att.interfaceName + '", "value" : "'+att.default_x+'" , "type" : "' + 'String' + '",  "description": "' + '"' + '},'; 
                                    
                                    checkSuccess = true;
                                    staticAttrCounter++;
                                    
                                }else {
                                    if(checkfalse){
                                        autoAddfalseJSON +=',';
                                    }
                                    String failJsonStr = '{"name" : "'+ att.interfaceName + '", "value" : "" , "type" : "' + 'String' + '",  "description": "' + '"' + '}';
                                    autoAddfalseJSON += failJsonStr;                            
                                    checkfalse = true; 
                                    checkSuccess = true;
                                    commercialAttrCounter++;                           
                                } 
                            }
                        }
                        String parentSpecID = ''; // CH-1
                        if(isFulfillmentcreate){
                            //Changes for 20565 Mapping Block -- start
                            for( String specId :mapsourceTarget.keySet() ){
                                if(specId == productList_One.specId)
                                {
                                    staticAttrCounter++;
                                    checkSuccess = true;
                                    /*how to fetch the value from mapsourceTarget which is another map*/
                                    Map<String, String> innermap = mapsourceTarget.get(specId);
                                    for( String characteristicId :innermap.keySet() )
                                    {
                                        String specId1 = innermap.get(characteristicId);
                                        autoAddTrueJSON +=  '{"name" : "'+ characteristicId + '", "value" : "'+specId1+'" , "type" : "' + 'String' + '",  "description": "' + '"' + '},';
                                    }
                                }
                            }
                            //Changes for 20565 Mapping Block -- end
                            parentSpecID = allParentSpecIds(productList_One.SpecId);        
                            if(parentSpecID !='')
                            {
                                for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_10 : productList_One.productStaticCharacteristics)
                                {
                                    if(prodStcChar_10.name == 'TechPhases' && prodStcChar_10.value == 'true')
                                    {
                                        staticAttrCounter++;
                                        parentSpecID = '{"name" : "parentSpec" , "value" : "' + parentSpecID.removeEnd(',')+'_Fulfilment';
                                        parentSpecID+= '","type": "string"}';
                                    }
                                }
                                
                            }
                        }
                        
                        if(parentSpecID == ''){
                            autoAddTrueJSON = autoAddTrueJSON.removeEnd(',');
                        }
                        
                        autoAddTrueJSON += parentSpecID;
                        
                        
                    }
                                     
                    autoAddTrueJSON += '], "autoAdd": "true" }';
                    autoAddfalseJSON += '], "autoAdd": "false" }';
                    
                    System.debug('autoAddTrueJSON ====>'+autoAddTrueJSON);
                    System.debug('autoAddfalseJSON ====>'+autoAddfalseJSON);        
                }      
                if(staticAttrCounter > 0){
                    if(Test.isRunningTest()){
                        lstAutoAddTrueJSON.add(autoAddTrueJSON);
                    }
                    else{
                        csedm.API_1.createCFSChangeRequest(autoAddTrueJSON);
                    }
                }
                if(CommercialAttrCounter > 0){
                    if(Test.isRunningTest()){
                        lstAutoAddFailJSON.add(autoAddfalseJSON);
                    }
                    else{
                        csedm.API_1.createCFSChangeRequest(autoAddfalseJSON);     
                    }
                }              
            } 
        }
        // Change for EDGE-12675 
        catch (Exception e) {
            system.debug('exception catch '+e);
            Logger.getLogger(UpsertSpecificationObjectRecord.class).debug(e);
            Logger.exitLogger();
        }
    }
    
    // CH-1
    public static void upsertAssuranceAttributes(cs_SigmaToCSJSON obj){
        try{
            Map<String, cs_SigmaToCSJSON.cls_products> mapOnlyProduct = new Map<String, cs_SigmaToCSJSON.cls_products>();        
            cs_SigmaToCSJSON jsonObj = new cs_SigmaToCSJSON();        
            jsonObj = obj;
            cs_SigmaToCSJSON.cls_productOffering jsonobjPrdtOff = new cs_SigmaToCSJSON.cls_productOffering();
            jsonobjPrdtOff = jsonObj.productOffering;
            List<cs_SigmaToCSJSON.cls_products> productList = new List<cs_SigmaToCSJSON.cls_products>();        
            if(jsonobjPrdtOff.products != null ) {    
                for(cs_SigmaToCSJSON.cls_products prod : jsonobjPrdtOff.products ){ 
                    // Change for EDGE-12675
                    if(prod.attributes != null && (prod.action !='None' && prod.action != 'Affected')){
                        for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar : prod.productStaticCharacteristics)
                        {
                            if(prodStcChar.name == 'AssurancePhase' && prodStcChar.value != 'false')
                            {
                                mapOnlyProduct.put(prod.specId, prod);
                                allParentSpecId.put(prod.specId, null);  
                            }
                        }                 
                    }
                    
                    if(prod.products != null  ){                  
                        for(cs_SigmaToCSJSON.cls_products prod_One : prod.products){  
                            if(prod_One.attributes != null && (prod_One.action !='None' && prod_One.action != 'Affected')){
                                for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_2 : prod_One.productStaticCharacteristics)
                                {
                                    if(prodStcChar_2.name == 'AssurancePhase' && prodStcChar_2.value != 'false')
                                    {
                                        mapOnlyProduct.put(prod.specId+prod_One.specId, prod_One);
                                        
                                        for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_3 : prod.productStaticCharacteristics)
                                        {
                                            if(prodStcChar_3.name == 'AssurancePhase' && prodStcChar_3.value != 'false')
                                            {
                                                allParentSpecId.put(prod_One.specId, prod.specId);
                                            }      
                                        }
                                    }
                                }
                            }
                            if(prod_One.products != null ){                         
                                for(cs_SigmaToCSJSON.cls_products prod_Two : prod_One.products){ 
                                    if(prod_Two.attributes != null && (prod_Two.action !='None' && prod_Two.action != 'Affected')){
                                        for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_5 : prod_Two.productStaticCharacteristics)
                                        {
                                            if(prodStcChar_5.name == 'AssurancePhase' && prodStcChar_5.value != 'false')
                                            {
                                                mapOnlyProduct.put(prod_One.specId+prod_Two.specId, prod_Two);
                                                for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_6 : prod_One.productStaticCharacteristics)
                                                {
                                                    if(prodStcChar_6.name == 'AssurancePhase' && prodStcChar_6.value != 'false')
                                                    {
                                                        allParentSpecId.put(prod_Two.specId, prod_One.specId);
                                                    }                                    
                                                }      
                                            }
                                        }
                                    }
                                    if(prod_Two.products != null ){
                                        for(cs_SigmaToCSJSON.cls_products prod_Three : prod_Two.products){ 
                                            if(prod_Three.attributes != null && (prod_Three.action !='None' && prod_Three.action != 'Affected')){
                                                for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_8 : prod_Three.productStaticCharacteristics)
                                                {
                                                    if(prodStcChar_8.name == 'AssurancePhase' && prodStcChar_8.value != 'false')
                                                    {
                                                        mapOnlyProduct.put(prod_Two.specId+prod_Three.specId, prod_Three);
                                                        for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_9 : prod_Two.productStaticCharacteristics)
                                                        {
                                                            if(prodStcChar_9.name == 'AssurancePhase' && prodStcChar_9.value != 'false')
                                                            {
                                                                allParentSpecId.put(prod_Three.specId, prod_Two.specId);
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
                        
                    }                
                }                                 
            }    
            String autoAddTrueJSON = '';
            String autoAddfalseJSON = '';
            
            //Changes for 20565 Mapping Block -- start
            Map<String, Map<String, String>> mapsourceTarget = new Map<String, Map<String, String>> ();
            for( String productName :mapOnlyProduct.keySet() )
            {
                List<cs_SigmaToCSJSON.cls_mappingRules> mappingRulesList = new List<cs_SigmaToCSJSON.cls_mappingRules>();
                if(mapOnlyProduct.get(productName).mappingRules !=null){
                    mappingRulesList = mapOnlyProduct.get(productName).mappingRules;
                }
                if (mappingRulesList.size() > 0) {
                    for (cs_SigmaToCSJSON.cls_mappingRules mappingRule: mappingRulesList) {
                        Map<String, String> sourceTargetMap = new Map<String,String> ();
                        sourceTargetMap.put(mappingRule.target.characteristicId, mappingRule.source.productId);
                        mapsourceTarget.put(mappingRule.target.productId, sourceTargetMap);
                    }
                }
            }
            //Changes for 20565 Mapping Block -- end
            
            for( String productName :mapOnlyProduct.keySet() ){
                Integer staticAttrCounter = 0;
                Integer commercialAttrCounter = 0;
                cs_SigmaToCSJSON.cls_products productList_One = new cs_SigmaToCSJSON.cls_products();
                productList_One  = mapOnlyProduct.get(productName);
                List<cs_SigmaToCSJSON.cls_attributes> attList = new List<cs_SigmaToCSJSON.cls_attributes>();
                attList = mapOnlyProduct.get(productName).attributes;            
                if(productList_One != null ){               
                    autoAddTrueJSON = '{ "code" : "'+ productList_One.specId+'_Assurance' + '", "attributes" : [  ' ;
                    autoAddfalseJSON= autoAddTrueJSON;
                    boolean checkSuccess = false;
                    boolean checkfalse = false;  
                    boolean isFulfillmentcreate = false;
                    if(attList.size() > 0){
                        for(cs_SigmaToCSJSON.cls_attributes att : attList){    
                            isFulfillmentcreate = getAssurancePhase(att.staticCharacteristics);
                            if(isFulfillmentcreate){
                                if(att.default_x != null && att.default_x != ''){
                                    
                                    autoAddTrueJSON +=  '{"name" : "'+ att.interfaceName + '", "value" : "'+att.default_x+'" , "type" : "' + 'String' + '",  "description": "' + '"' + '},'; 
                                    
                                    checkSuccess = true;
                                    staticAttrCounter++;
                                    
                                }else {
                                    if(checkfalse){
                                        autoAddfalseJSON +=',';
                                    }
                                    String failJsonStr = '{"name" : "'+ att.interfaceName + '", "value" : "" , "type" : "' + 'String' + '",  "description": "' + '"' + '}';
                                    autoAddfalseJSON += failJsonStr;                            
                                    checkfalse = true; 
                                    checkSuccess = true;
                                    commercialAttrCounter++;                           
                                } 
                            }
                        }
                        String parentSpecID = ''; // CH-1
                        if(isFulfillmentcreate){
                            //Changes for 20565 Mapping Block -- start
                            for( String specId :mapsourceTarget.keySet() ){
                                if(specId == productList_One.specId)
                                {
                                    staticAttrCounter++;
                                    checkSuccess = true;
                                    /*how to fetch the value from mapsourceTarget which is another map*/
                                    Map<String, String> innermap = mapsourceTarget.get(specId);
                                    for( String characteristicId :innermap.keySet() )
                                    {
                                        String specId1 = innermap.get(characteristicId);
                                        autoAddTrueJSON +=  '{"name" : "'+ characteristicId + '", "value" : "'+specId1+'" , "type" : "' + 'String' + '",  "description": "' + '"' + '},';
                                    }
                                }
                            }
                            //Changes for 20565 Mapping Block -- end
                            parentSpecID = allParentSpecIds(productList_One.SpecId);        
                            if(parentSpecID !='')
                            {
                                for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar_10 : productList_One.productStaticCharacteristics)
                                {
                                    if(prodStcChar_10.name == 'AssurancePhase' && prodStcChar_10.value == 'true')
                                    {
                                        staticAttrCounter++;
                                        parentSpecID = '{"name" : "parentSpec" , "value" : "' + parentSpecID.removeEnd(',')+'_Assurance';
                                        parentSpecID+= '","type": "string"}';
                                    }
                                }
                                
                            }
                        }
                        
                        if(parentSpecID == ''){
                            autoAddTrueJSON = autoAddTrueJSON.removeEnd(',');
                        }
                        
                        autoAddTrueJSON += parentSpecID;
                        
                        
                    }
                                     
                    autoAddTrueJSON += '], "autoAdd": "true" }';
                    autoAddfalseJSON += '], "autoAdd": "false" }';
                    
                    System.debug('autoAddTrueJSON ====>'+autoAddTrueJSON);
                    System.debug('autoAddfalseJSON ====>'+autoAddfalseJSON);        
                }      
                if(staticAttrCounter > 0){
                    if(Test.isRunningTest()){
                        lstAutoAddTrueJSON.add(autoAddTrueJSON);
                    }
                    else{
                        csedm.API_1.createCFSChangeRequest(autoAddTrueJSON);
                    }
                }
                if(CommercialAttrCounter > 0){
                    if(Test.isRunningTest()){
                        lstAutoAddFailJSON.add(autoAddfalseJSON);
                    }
                    else{
                        csedm.API_1.createCFSChangeRequest(autoAddfalseJSON);     
                    }
                }              
            } 
        }
        // Change for EDGE-12675 
        catch (Exception e) {
            system.debug('exception catch '+e);
            Logger.getLogger(UpsertSpecificationObjectRecord.class).debug(e);
            Logger.exitLogger();
        }
    }
    
    
    public static string allParentSpecIds(String SpecId)
    {
        String parentSpecID1 = '';
        if(allParentSpecId.get(SpecId)!= null ){           
            parentSpecID1 = allParentSpecId.get(SpecId);         
        }
        return parentSpecID1;
    }
    public static void upsertchargesAttribute(cs_SigmaToCSJSON obj){
        try{
            Map<String, cs_SigmaToCSJSON.cls_products> mapOnlyChargeProduct = new Map<String, cs_SigmaToCSJSON.cls_products>();        
            cs_SigmaToCSJSON jsonObj = new cs_SigmaToCSJSON();        
            jsonObj = obj;
            cs_SigmaToCSJSON.cls_productOffering jsonobjPrdtOff = new cs_SigmaToCSJSON.cls_productOffering();
            jsonobjPrdtOff = jsonObj.productOffering;
            List<cs_SigmaToCSJSON.cls_products> productList = new List<cs_SigmaToCSJSON.cls_products>();        
            if(jsonobjPrdtOff.products != null ) {    
                for(cs_SigmaToCSJSON.cls_products prod : jsonobjPrdtOff.products ){ 
                    // Change for EDGE-12675
                    if(prod.charges != null && (prod.action !='None'/* && prod.action != 'Affected'*/)){
                        mapOnlyChargeProduct.put(prod.specId, prod);
                    }
                    
                    if(prod.products != null  ){                  
                        for(cs_SigmaToCSJSON.cls_products prod_One : prod.products){  
                            if(prod_One.charges != null && (prod_One.action !='None'/* && prod_One.action != 'Affected'*/)){
                                mapOnlyChargeProduct.put(prod.specId+prod_One.specId, prod_One);
                            }
                            if(prod_One.products != null ){                         
                                for(cs_SigmaToCSJSON.cls_products prod_Two : prod_One.products){ 
                                    if(prod_Two.charges != null && (prod_Two.action !='None'/* && prod_Two.action != 'Affected'*/)){
                                        mapOnlyChargeProduct.put(prod_One.specId+prod_Two.specId, prod_Two);
                                    }
                                    
                                    if(prod_Two.products != null ){
                                        for(cs_SigmaToCSJSON.cls_products prod_Three : prod_Two.products){ 
                                            if(prod_Three.charges != null && (prod_Three.action !='None'/* && prod_Three.action != 'Affected'*/)){
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
            String autoAddfalseBillingJSON = '';
            
            for( String productName :mapOnlyChargeProduct.keySet() ){
                Integer staticAttrCounter = 0;
                Integer commercialAttrCounter = 0;
                cs_SigmaToCSJSON.cls_products productList_One = new cs_SigmaToCSJSON.cls_products();
                productList_One  = mapOnlyChargeProduct.get(productName);
                List<cs_SigmaToCSJSON.cls_charges> chargeList = new List<cs_SigmaToCSJSON.cls_charges>();
                chargeList = mapOnlyChargeProduct.get(productName).charges;   
                //Changes End for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM        
                List<cs_SigmaToCSJSON.cls_attributes> billingSpecAttributes = getBillingSpecAttributes(productList_One);
                //Changes End for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM
                if(productList_One != null ){               
                    if(chargeList.size() > 0){
                        for(cs_SigmaToCSJSON.cls_charges chrgs : chargeList){
                            
                            autoAddfalseBillingJSON= '{ "code" : "'+ productList_One.specId+'_Billing_'+chrgs.specId.replace('DMCAT_','') + '", "attributes" : [  ' ;
                            
                            if(String.isNotBlank(chrgs.type_x)){                                
                                autoAddfalseBillingJSON += '{"name": "type", "value": "","type": "string"},';
                            } 
                            if(String.isNotBlank(chrgs.currency_x)){
                                autoAddfalseBillingJSON +='{"name": "currency", "value": "","type": "string"},';
                            }
                            if( String.isNotBlank(chrgs.frequency_x)){
                                autoAddfalseBillingJSON +='{"name": "frequency", "value": "","type": "string"},';
                            }
                            if( String.isNotBlank(chrgs.billingSpecId))
                            {
                                autoAddfalseBillingJSON +='{"name": "billingSpecId", "value": "","type": "string"},';
                            }
                            if(String.isNotBlank(chrgs.billInAdvance) ){
                                autoAddfalseBillingJSON +='{"name": "billInAdvance", "value": "","type": "string"},';
                            }
                            if(String.isNotBlank(chrgs.prorate) ){
                                autoAddfalseBillingJSON +='{"name": "prorate", "value": "","type": "string"},';
                            }
                            if( String.isNotBlank(chrgs.billingSubType))
                            {
                                autoAddfalseBillingJSON +='{"name": "billingSubType", "value": "","type": "string"},';
                            }
                            
                            //autoAddfalseBillingJSON +='{"name": "description", "value": "","type": "string"},{"name": "units", "value": "","type": "string"},{"name": "unitPrice", "value": "","type": "string"}';
                            commercialAttrCounter++;  
                            
                            //Changes Start for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM
                            autoAddfalseBillingJSON +='{"name": "billDescription", "value": "","type": "string"},{"name": "rateExcludeGST", "value": "","type": "string"}';
                            if(billingSpecAttributes.size() > 0)
                            {
                                for(cs_SigmaToCSJSON.cls_attributes att : billingSpecAttributes)
                                {
                                    if(String.isNotBlank(att.interfaceName))
                                    {        
                                        autoAddFalseBillingJSON += ',{"name": "'+ att.interfaceName + '", "value": "","type": "string"}';
                                    } 
                                }
                                System.debug('autoAddFalseBillingJSON with new attributes ====>'+autoAddFalseBillingJSON);
                            }
                            //Changes End for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM
                        }                   
                        
                    }               
                    autoAddfalseBillingJSON += '], "autoAdd": "false" }';               
                    
                    System.debug('autoAddfalseBillingJSON ====>'+autoAddfalseBillingJSON);
                    
                }  
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
        // Change for EDGE-12675 
        catch (Exception e) {
            system.debug('exception catch '+e);
            Logger.getLogger(UpsertSpecificationObjectRecord.class).debug(e);
            Logger.exitLogger();
        }
    }
    
    //Changes Start for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM 
    // Method to get those billing attributes whose "Send_to_Billing" is true
    public static List<cs_SigmaToCSJSON.cls_attributes> getBillingSpecAttributes(cs_SigmaToCSJSON.cls_products prod)
    {
        List<cs_SigmaToCSJSON.cls_attributes> billingSpecAttributes = new List<cs_SigmaToCSJSON.cls_attributes>();
        for(cs_SigmaToCSJSON.cls_attributes locAttr : prod.attributes)
            {
                if(locAttr.staticCharacteristics!=null) 
                {
                    for(cs_SigmaToCSJSON.cls_staticCharacteristics sc : locAttr.staticCharacteristics)
                    { 
                        if(sc.name == 'CommPhases' && sc.value == 'true')
                        {
                            billingSpecAttributes.add(locAttr);
                        } 
                    }  
                }
            }
        return billingSpecAttributes;
    }
    //Changes End for Edge - 32965 -- Enhancement to consume "Send to Billing" data and create those attributes automatically in Billing EDM 
    public static boolean getFulfilmentresult(List<cs_SigmaToCSJSON.cls_staticCharacteristics> staticChar){
        
        for(cs_SigmaToCSJSON.cls_staticCharacteristics sChar : staticChar){
            if(sChar.name == 'TechPhases' && sChar.value == 'true'){
                return true;
            }
        }
        return false;
    }
    
    public static boolean getAssurancePhase(List<cs_SigmaToCSJSON.cls_staticCharacteristics> staticChar){
        
        for(cs_SigmaToCSJSON.cls_staticCharacteristics sChar : staticChar){
            if(sChar.name == 'Send_to_Assurance' && sChar.value == 'true'){
                return true;
            }
        }
        return false;
    }
    
     public static boolean getProductTechPhase(List<cs_SigmaToCSJSON.cls_productStaticCharacteristics> productChar){
        
        for(cs_SigmaToCSJSON.cls_productStaticCharacteristics sChar : productChar){
            if(sChar.name == 'TechPhases' && sChar.value == 'true'){
                return true;
            }
        }
        return false;
    }
    
}