/* Class Name: UpsertSpecificationObjectRecord

ChagneSet No    Name            Date                    Description
CH-1            Abinash         10/15/2018              EDGE-45053 CS adaptor changes to support assurance phase flag and EDM package upgrades   
Spring 20       Sandeep Y       18/08/2020              SM Spirng package upgrade csedm__Product_Definition__c is deprecated use new field csedm__Source__c       
*/

public with sharing class UpsertSpecificationObjectRecord {
    public Static Map <String,Id> MapSpecIdWithDef = new Map <String,Id>();
    public Static Map <String,Id> prodspectoId = new Map <String,Id>();
    
    public static void upsertSpecificationRecord(CS_SigmaToCSJSON json) {
        try{
            prodspectoId = prodDefWithIds();  
            Map <String,CS_SigmaToCSJSON.cls_products > mapSpec = new Map < String,CS_SigmaToCSJSON.cls_products > ();
            //CH-1
            Map <String,String> mapParChildSpec = new Map < String,String> ();
            system.debug('json-->'+json);
            CS_SigmaToCSJSON jsonObj = new CS_SigmaToCSJSON();
            jsonObj = json;
            cs_SigmaToCSJSON.cls_productOffering jsonobjPrdtOff = new cs_SigmaToCSJSON.cls_productOffering();            
            jsonobjPrdtOff = jsonObj.productOffering;
            system.debug('jsonobjPrdtOff-->'+jsonobjPrdtOff);
            List <cs_SigmaToCSJSON.cls_products> prodList = new List < cs_SigmaToCSJSON.cls_products > ();
            system.debug('jsonobjPrdtOff-->'+jsonobjPrdtOff.products);
            if(jsonobjPrdtOff.products!=null){
                for (cs_SigmaToCSJSON.cls_products prod: jsonobjPrdtOff.products) {// First Label Product
                    prodList.add(prod);
                    // Change for EDGE-12675
                    if (prod.specId != null /* && prod.attributes != null */&& (prod.action !='None'/* && prod.action != 'Affected'*/)) {
                        mapSpec.put(prod.specId, prod);
                        mapParChildSpec.put(prod.specId,prod.specId);
                        //getSpecIdwithProductDefination(prod.specId,mapParChildSpec,prodspectoId,MapSpecIdWithDef);
                        
                    }
                    if(prod.products!=null){
                        for (cs_SigmaToCSJSON.cls_products prods: prod.products) { // 2nd Label Product
                            prodList.add(prods);
                            if (prods.specId != null  && prods.attributes != null && (prods.action !='None'/* && prods.action != 'Affected'*/)) {
                                mapSpec.put(prod.specId+prods.specId, prods);
                                mapParChildSpec.put(prods.specId,prod.specId);
                                //getSpecIdwithProductDefination(prods.specId,mapParChildSpec,prodspectoId,MapSpecIdWithDef);
                            }
                            if(prods.products!=null){
                                for (cs_SigmaToCSJSON.cls_products prodz: prods.products) { // 3rd Label Product
                                    prodList.add(prodz);
                                    if (prodz.specId != null && prodz.attributes != null && (prodz.action !='None'/* && prodz.action != 'Affected'*/)) {
                                        mapSpec.put(prods.specId+prodz.specId, prodz);
                                        mapParChildSpec.put(prodz.specId,prods.specId);
                                        //getSpecIdwithProductDefination(prodz.specId,mapParChildSpec,prodspectoId,MapSpecIdWithDef);
                                    }
                                    if (prodz.products != null) {
                                        for (cs_SigmaToCSJSON.cls_products prodsY: prodz.products) {//4th label Product
                                            prodList.add(prodsY);
                                            if (prodsY.specId != null && prodsY.attributes != null && (prodsY.action !='None'/* && prodsY.action != 'Affected'*/)) {
                                                mapSpec.put(prodz.specId+prodsY.specId, prodsY);
                                                mapParChildSpec.put(prodsY.specId,prodz.specId);
                                                //getSpecIdwithProductDefination(prodsY.specId,mapParChildSpec,prodspectoId,MapSpecIdWithDef);
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
            
            system.debug('After Parsing MapSpecIdWithDef>>>>' + MapSpecIdWithDef);
            system.debug('prodspectoId>>>>' + prodspectoId);
            List < csedm__Specification__c > specRecList = new List < csedm__Specification__c > ([select Id, csedm__identifier__c,External_Id__c from csedm__Specification__c]);
            Map < String,Id > specRecordIdentifierMap = new Map < String,Id > ();
            if(!specRecList.isEmpty()){
                for (csedm__Specification__c identy: specRecList) {
                    /*if (identy.csedm__identifier__c != '' && identy.csedm__identifier__c != null) {
                        specRecordIdentifierMap.put(identy.csedm__identifier__c, identy.Id);
                    }*/
                    // CH-1 Start
                    if (identy.External_Id__c != '' && identy.External_Id__c != null) {
                        specRecordIdentifierMap.put(identy.External_Id__c, identy.Id);
                    }
                    // CH-1 End
                }
            }
            Map < String,cs_SigmaToCSJSON.cls_products > JSONIdentifiertoSpec = new Map < String,cs_SigmaToCSJSON.cls_products > ();
            cs_SigmaToCSJSON.cls_products obj = new cs_SigmaToCSJSON.cls_products();
            if (obj != null) {  
                JSONIdentifiertoSpec.put(obj.externalId, obj);  
            }
            
            List < csedm__Specification__c > insertSpec = new List < csedm__Specification__c > ();
            map <String, cscfga__Product_Definition__c> MapUpdateDefinationwithVersion = new map <String,cscfga__Product_Definition__c> ();
            Set<String> setExternalIds = new Set<String>();
            system.debug('mapSpec>>>>>'+ mapSpec.size());
            if(mapSpec.keySet()!=null){
                for (String prodname: mapSpec.keySet()) {
                    system.debug('############' + mapSpec.get(prodname).version);
                    system.debug('$$$$$$$$$$$' + mapSpec.get(prodname));
                    for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar : mapSpec.get(prodname).productStaticCharacteristics)
                    {
                        system.debug('TechPhases>>>>>' + prodStcChar.value + '====' + prodStcChar.name);
                        system.debug('FullfilMent Spec Ids >>>>>>>' + mapSpec.get(prodname).specId);
                        // Change for EDGE-12675
                        if(prodStcChar.name == 'TechPhases' && prodStcChar.value == 'true') {
                            csedm__Specification__c specList1 = new csedm__Specification__c();
                            if (specRecordIdentifierMap != null && specRecordIdentifierMap.get(mapSpec.get(prodname).externalId) != null && jsonobjPrdtOff.specId != null) {
                                //specList1.Id = specRecordIdentifierMap.get(mapSpec.get(prodname).externalId);
                                //CH-1 Start
                                specList1.Id = specRecordIdentifierMap.get(jsonobjPrdtOff.specId+mapSpec.get(prodname).specId);
                                //CH-1 End
                            }
                            //CH-1 Start    
                            //specList1.csedm__identifier__c = mapSpec.get(prodname).externalId;
                            //if(mapParChildSpec.containsKey(mapSpec.get(prodname).specId)){
                            //if(mapParChildSpec.containsKey(prodname)){
                                system.debug('External Ids Check>>>' +  mapParChildSpec.get(mapSpec.get(prodname).specId) + '--' + mapSpec.get(prodname).specId);
                                specList1.External_Id__c = prodname;//mapParChildSpec.get(mapSpec.get(prodname).specId)+mapSpec.get(prodname).specId;
                                specList1.csedm__identifier__c =prodname;// mapParChildSpec.get(mapSpec.get(prodname).specId)+mapSpec.get(prodname).specId;
                            //}
                            
                            specList1.csedm__Active__c = true;
                            specList1.csedm__Start_Date__c = Date.valueOf(mapSpec.get(prodname).associationStartDate);
                            specList1.csedm__End_Date__c = Date.valueOf(mapSpec.get(prodname).associationEndDate);
                            // CH-1 End
                            
                            specList1.Name = mapSpec.get(prodname).name+'_Fulfilment';
                            specList1.csedm__Code__c = mapSpec.get(prodname).specId+'_Fulfilment';
                            specList1.csedm__Version__c = mapSpec.get(prodname).version;
                            system.debug('>>>>>>>>>>' + mapParChildSpec.get(mapSpec.get(prodname).specId));
                            system.debug('>>>>>>>>>>******' + prodspectoId.get(mapParChildSpec.get(mapSpec.get(prodname).specId)));
                            
                            /*if(MapSpecIdWithDef.containsKey(prodname)){
                                system.debug('Inside MapSpecIdWithDef >>>');
                                specList1.csedm__Product_Definition__c = MapSpecIdWithDef.get(prodname);
                            }*/
                            
                            String ProductDefId = getProductDefination(mapSpec.get(prodname).specId, mapParChildSpec,prodspectoId);
                            if(ProductDefId != null && ProductDefId !=''){
                                if(ProductDefId != 'Not Found'){
                                  //  specList1.csedm__Product_Definition__c = ProductDefId; //Spring 20 commented
                                    specList1.csedm__Source__c = ProductDefId;  //Spring 20
                                    
                                   // MapUpdateDefinationwithVersion.put(specList1.csedm__Product_Definition__c, new cscfga__Product_Definition__c(Id=specList1.csedm__Product_Definition__c,   //Spring 20 commented
                                    MapUpdateDefinationwithVersion.put(specList1.csedm__Source__c, new cscfga__Product_Definition__c(Id=specList1.csedm__Source__c, //Spring 20
                                    Product_Model_Version__c=mapSpec.get(prodname).version));
                                }
                            }
                            List < cs_SigmaToCSJSON.cls_attributes > attList = new List < cs_SigmaToCSJSON.cls_attributes > ();
                           // system.debug('specList1.csedm__Product_Definition__c>>>' + specList1.csedm__Product_Definition__c); //Spring 20 commented
                            system.debug('specList1.csedm__Source__c>>>' + specList1.csedm__Source__c); //Spring 20
                            if(mapSpec.get(prodname).attributes!=null){
                                attList = mapSpec.get(prodname).attributes;
                            }
                            String ValueJson = '';
                            
                            String Json1 = '{ "code": "' + mapSpec.get(prodname).specId +'_Fulfilment'+ '", "name": "' + mapSpec.get(prodname).name+'_Fulfilment' + '", "description": "",  "cpqAttributes": {}, "attributes": {   ';
                            String json2 = '';
                            if (attList.size() == 1) {
                                for (cs_SigmaToCSJSON.cls_attributes att: attList) {
                                    system.debug('check json2 size' + json2);
                                    if(att.default_x!='' && att.default_x!=null){
                                        json2 += '"' + att.interfaceName + '": {     "value": "' + att.default_x + '",     "type": "' + att.type_x + '"   }';
                                    }
                                }
                            } else if (attList.size() > 1) {
                                for (integer i = 0; i < attList.size() - 1; i++) {
                                    system.debug('inside spec method inside if2 for1 ===///');
                                    system.debug('check json2 size' + json2);
                                    if(attList[i].default_x!='' && attList[i].default_x!=null){
                                        json2 += '"' + attList[i].interfaceName + '": {     "value": "' + attList[i].default_x + '",     "type": "' + attList[i].type_x + '"   },';
                                    }
                                }
                                if(attList[attList.size() - 1].default_x!='' && attList[attList.size() - 1].default_x!=null){
                                    json2 += '"' + attList[attList.size() - 1].interfaceName + '": {     "value": "' + attList[attList.size() - 1].default_x + '",     "type": "' + attList[attList.size() - 1].type_x + '"   },';
                                    
                                }
                            }
                            json2+='"__targetSystem": {"value": "FULFILMENT","type": "string"}';
                            string json3 = '}, "nonCommercialAttributes": []}';
                            
                            ValueJson = Json1 + json2 + json3;
                            
                            if(ValueJson!=''){
                                specList1.csedm__Value__c = ValueJson;
                            }else{
                                specList1.csedm__Value__c = '{}';
                            }
                            setExternalIds.add(specList1.External_Id__c);                            
                            system.debug('FullfilMent External Ids >>>>>>>' + specList1.External_Id__c);
                            
                            insertSpec.add(specList1);
                        }
                    }
                }
            }
            system.debug('insertSpec >>>>>>>' + insertSpec);
            system.debug('External Id Size >>>>>>>' + setExternalIds.size());
            system.debug('insertSpec Size>>>>>>>' + insertSpec.size());
            if (!insertSpec.isEmpty()) {
                //upsert insertSpec;
                upsert insertSpec External_Id__c; // CH-1
            }
            system.debug('UpdateDefinationwithVersion>>>>' + MapUpdateDefinationwithVersion);
            if (!MapUpdateDefinationwithVersion.isEmpty()) {
                //update MapUpdateDefinationwithVersion.values();
            }
            
       }
        // Change for EDGE-12675
        catch (Exception e) {
            
            Logger.getLogger(SQService.class).debug(e);
            Logger.exitLogger();
        }
    }
    
    public static void upsertSpecificationChargeRecord(CS_SigmaToCSJSON json) {
        try{
            Map < String,CS_SigmaToCSJSON.cls_products > mapChargesSpec = new Map < String,CS_SigmaToCSJSON.cls_products > ();
            
            Map < String,String> mapParentChargesSpec = new Map <String,String> ();
            
            CS_SigmaToCSJSON jsonObj = new CS_SigmaToCSJSON();
            jsonObj = json;
            cs_SigmaToCSJSON.cls_productOffering jsonobjPrdtOff = new cs_SigmaToCSJSON.cls_productOffering();
            
            jsonobjPrdtOff = jsonObj.productOffering;
            List < cs_SigmaToCSJSON.cls_products > prodList = new List < cs_SigmaToCSJSON.cls_products > ();
            if(jsonobjPrdtOff.products!=null){
                for (cs_SigmaToCSJSON.cls_products prod: jsonobjPrdtOff.products) {
                    prodList.add(prod);
                    // Change for EDGE-12675 
                    system.debug('prod'+prod + ' ' + 'prod.attributes--->'+prod.attributes + '' + 'prod.specId--->'+prod.specId);
                    if (prod.specId != null && prod.attributes != null && (prod.action !='None'/* && prod.action != 'Affected'*/)) {
                        mapChargesSpec.put(prod.specId, prod);
                        mapParentChargesSpec.put(prod.specId, prod.specId);
                        //getSpecIdwithProductDefination(prod.specId,mapParentChargesSpec,prodspectoId,MapSpecIdWithDef);
                    }
                    if(prod.products!=null){
                        for (cs_SigmaToCSJSON.cls_products prods: prod.products) {
                            prodList.add(prods);
                            if (prods.specId != null && prods.attributes != null && (prods.action !='None' /*&& prods.action != 'Affected'*/)) {
                                mapChargesSpec.put(prod.specId+prods.specId, prods);
                                mapParentChargesSpec.put(prods.specId, prod.specId);
                                //getSpecIdwithProductDefination(prods.specId,mapParentChargesSpec,prodspectoId,MapSpecIdWithDef);
                            }
                            if(prods.products!=null){
                                for (cs_SigmaToCSJSON.cls_products prodz: prods.products) {
                                    prodList.add(prodz);
                                    if (prodz.specId != null && prodz.attributes != null && (prodz.action !='None'/* && prodz.action != 'Affected'*/)) {
                                        mapChargesSpec.put(prods.specId+prodz.specId, prodz);
                                        mapParentChargesSpec.put(prodz.specId, prods.specId);
                                        //getSpecIdwithProductDefination(prodz.specId,mapParentChargesSpec,prodspectoId,MapSpecIdWithDef);
                                    }
                                    if (prodz.products != null) {
                                        for (cs_SigmaToCSJSON.cls_products prodsY: prodz.products) {
                                            prodList.add(prodsY);
                                            if (prodsY.specId != null && prodsY.attributes != null && (prodsY.action !='None'/* && prodsY.action != 'Affected'*/)) {
                                                mapChargesSpec.put(prodz.specId+prodsY.specId, prodsY);
                                                mapParentChargesSpec.put(prodsY.specId, prodz.specId);
                                                //getSpecIdwithProductDefination(prodsY.specId,mapParentChargesSpec,prodspectoId,MapSpecIdWithDef);
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
            Map <String,Id> prodspectoId = prodDefWithIds();
            system.debug('prodspectoId>>>>' + prodspectoId);
            List < csedm__Specification__c > specRecList = new List < csedm__Specification__c > ([select Id, csedm__identifier__c,External_Id__c from csedm__Specification__c]);
            Map < String,Id > specRecordIdentifierMap = new Map < String,Id > ();
            if(!specRecList.isEmpty()){
                for (csedm__Specification__c identy: specRecList) {
                    /*if (identy.csedm__identifier__c != '' && identy.csedm__identifier__c != null) {
                    specRecordIdentifierMap.put(identy.csedm__identifier__c, identy.Id);
                    }*/
                    if (identy.External_Id__c != '' && identy.External_Id__c != null) {
                    specRecordIdentifierMap.put(identy.External_Id__c, identy.Id);
                    }
                }
            }
            system.debug('mapChargesSpec>>>>>'+ mapChargesSpec.size());
            List < csedm__Specification__c > insertSpecChrg = new List < csedm__Specification__c > ();
            Set<String> setBillingIds = new Set<String>();
            if(mapChargesSpec.keySet()!=null){
                for (String prodname: mapChargesSpec.keySet()) {
                    system.debug('mapChargesSpec>>>>>');
                    if(mapChargesSpec.get(prodname).charges!=null){
                        for(cs_SigmaToCSJSON.cls_charges chrgs:mapChargesSpec.get(prodname).charges){
                            system.debug('cls_charges>>>>>');
                            csedm__Specification__c specList1 = new csedm__Specification__c();
                            /*if (specRecordIdentifierMap != null && specRecordIdentifierMap.get(mapChargesSpec.get(prodname).externalId) != null) {*/
                            //CH-1 Start
                            /*if (specRecordIdentifierMap != null && mapParentChargesSpec.containskey(mapChargesSpec.get(prodname).specId) ) {
                                //specList1.Id = mapParentChargesSpec.get(mapChargesSpec.get(prodname).specId)+specRecordIdentifierMap.get(mapChargesSpec.get(prodname).specId);
                                specList1.Id = specRecordIdentifierMap.get(jsonobjPrdtOff.specId+mapChargesSpec.get(prodname).specId);
                                
                                specList1.csedm__identifier__c = mapChargesSpec.get(prodname).externalId+'_chrg'+chrgs.type_x;
                                
                                // CH-1 Start
                                specList1.External_Id__c = mapParentChargesSpec.get(mapChargesSpec.get(prodname).specId)+mapChargesSpec.get(prodname).specId+'_chrg'+chrgs.type_x;
                                // CH-1 End
                              //specList1.Id = specRecordIdentifierMap.get(mapChargesSpec.get(prodname).externalId+'_chrg'+chrgs.type_x);
                            }*/
                            
                            
                            if (specRecordIdentifierMap != null && specRecordIdentifierMap.get(mapChargesSpec.get(prodname).externalId) != null && jsonobjPrdtOff.specId != null) {
                                //specList1.Id = specRecordIdentifierMap.get(mapChargesSpec.get(prodname).externalId);
                                //CH-1 Start
                                specList1.Id = specRecordIdentifierMap.get(jsonobjPrdtOff.specId+mapChargesSpec.get(prodname).specId);
                                //CH-1 End
                            }
                            //CH-1 Start    
                                                        
                            /*if(MapSpecIdWithDef.containsKey(prodname)){
                                specList1.csedm__Product_Definition__c = MapSpecIdWithDef.get(prodname);
                            }*/
                            system.debug('>>>>>>>>>>******' + prodspectoId.get(mapParentChargesSpec.get(mapChargesSpec.get(prodname).specId)));
                            String ProductDefId = getProductDefination(mapChargesSpec.get(prodname).specId, mapParentChargesSpec,prodspectoId);
                            if(ProductDefId != null && ProductDefId !='' && ProductDefId != 'Not Found')
                               // specList1.csedm__Product_Definition__c = ProductDefId;  //Spring 20 commented
                                specList1.csedm__Source__c = ProductDefId; //Spring 20
                                
                            
                            specList1.csedm__Version__c = mapChargesSpec.get(prodname).version;
                            specList1.Name = mapChargesSpec.get(prodname).name+'_Billing_'+chrgs.specId.replace('DMCAT_','');
                            specList1.csedm__Code__c = mapChargesSpec.get(prodname).specId+'_Billing_'+chrgs.specId.replace('DMCAT_','');
                            specList1.BDSEDM__c = true;
                            specList1.Type__c = chrgs.type_x;
                            
                            specList1.External_Id__c = prodname+'_Billing_'+chrgs.specId.replace('DMCAT_','');
                            //mapParentChargesSpec.get(mapChargesSpec.get(prodname).specId)+specList1.csedm__Code__c;
                            system.debug('External Ids>>>>' + specList1.External_Id__c);
                            specList1.csedm__identifier__c = specList1.External_Id__c;
                            
                            String ValueJson = '';
                            
                            String Json1 = '{ "code": "' + specList1.csedm__Code__c+ '", "name": "' + specList1.Name + '", "description": "",  "cpqAttributes": {}, "attributes": {   ';
                            String json2 = '';
                            json2+='"__targetSystem": {"value": "'+Label.targetSystem+'","type": "string"}';
                            
                            string json3 = '}, "nonCommercialAttributes": []}';
                            
                            ValueJson = Json1 + json2 + json3;
                            
                            if(ValueJson!=''){
                                specList1.csedm__Value__c = ValueJson;
                            }else{
                                specList1.csedm__Value__c = '{}';
                            }
                            system.debug('Billing External Ids>>>' + specList1.External_Id__c);
                            setBillingIds.add(specList1.External_Id__c);
                            insertSpecChrg.add(specList1);
                        }
                    }
                    
                    /*
                     * Allowance Section
                     * */
                    
                    if(mapChargesSpec.get(prodname).allowances!=null){
                        for(cs_SigmaToCSJSON.cls_allowances allowances:mapChargesSpec.get(prodname).allowances){
                            system.debug('cls_allowances>>>>>');
                            if(allowances.allowanceDetails != null){
                                for(cs_SigmaToCSJSON.cls_allowanceDetails allowancesdet:allowances.allowanceDetails){
                                    csedm__Specification__c specListallowance = new csedm__Specification__c();
                                    
                                    if (specRecordIdentifierMap != null && specRecordIdentifierMap.get(mapChargesSpec.get(prodname).externalId) != null && jsonobjPrdtOff.specId != null) {
                                        //specListallowance.Id = specRecordIdentifierMap.get(jsonobjPrdtOff.specId+mapChargesSpec.get(prodname).specId);
                                    }
                                    //CH-1 Start    
                                                                
                                    /*if(MapSpecIdWithDef.containsKey(prodname)){
                                        specList1.csedm__Product_Definition__c = MapSpecIdWithDef.get(prodname);
                                    }*/
                                    system.debug('>>>>>>>>>>******' + prodspectoId.get(mapParentChargesSpec.get(mapChargesSpec.get(prodname).specId)));
                                    String ProductDefId = getProductDefination(mapChargesSpec.get(prodname).specId, mapParentChargesSpec,prodspectoId);
                                    if(ProductDefId != null && ProductDefId !='' && ProductDefId != 'Not Found')
                                      //  specListallowance.csedm__Product_Definition__c = ProductDefId; //Spring 20 commented
                                        specListallowance.csedm__Source__c = ProductDefId; //Spring 20
                                        
                                    
                                    specListallowance.csedm__Version__c = mapChargesSpec.get(prodname).version;
                                    String[] arrName; 
                                    if(allowancesdet.externalId != null){
                                        arrName= allowancesdet.externalId.split('Allowance');
                                    }
                                    specListallowance.Name = mapChargesSpec.get(prodname).name+'_Billing_Allowance'+arrName[1];
                                    specListallowance.csedm__Code__c = mapChargesSpec.get(prodname).specId+'_Billing_Allowance'+arrName[1];
                                    specListallowance.BDSEDM__c = true;
                                    specListallowance.Type__c = allowancesdet.type_x;
                                    
                                    specListallowance.External_Id__c = prodname+'_Billing_Allowance'+arrName[1];//mapParentChargesSpec.get(mapChargesSpec.get(prodname).specId)+specListallowance.csedm__Code__c;
                                    specListallowance.csedm__identifier__c = specListallowance.External_Id__c;
                                    specListallowance.csedm__Start_Date__c = Date.valueOf(allowancesdet.startdate);
                                    specListallowance.csedm__End_Date__c = Date.valueOf(allowancesdet.enddate);
                                    String ValueJson = '';
                                    
                                    String Json1 = '{ "code": "' + specListallowance.csedm__Code__c+ '", "name": "' + specListallowance.name + '", "description": "",  "cpqAttributes": {}, "attributes": {   ';
                                    String json2 = '';
                                    json2+='"__targetSystem": {"value": "'+Label.targetSystem+'","type": "string"},';
                                    json2+='"billingSpecId": {"value": "'+allowances.billingSpecId+'","type": "string"},';
                                    json2+='"ocsProdID": {"value": "'+allowances.ocsProdID+'","type": "string"},';
                                    json2+='"type": {"value": "'+allowancesdet.type_x+'","type": "string"},';
                                    json2+='"unitofMeasure": {"value": "'+allowancesdet.unitofMeasure+'","type": "string"},';
                                    json2+='"value": {"value": "'+allowancesdet.value+'","type": "string"}';
                                    
                                    string json3 = '}, "nonCommercialAttributes": []}';
                                    
                                    ValueJson = Json1 + json2 + json3;
                                    
                                    if(ValueJson!=''){
                                        specListallowance.csedm__Value__c = ValueJson;
                                    }else{
                                        specListallowance.csedm__Value__c = '{}';
                                    }
                                    system.debug('specListallowance External Ids>>>' + specListallowance.External_Id__c);
                                    setBillingIds.add(specListallowance.External_Id__c);
                                    insertSpecChrg.add(specListallowance);
                                }
                            }
                        }
                    }
                    
                }
            }
            system.debug('Billing External Ids Size>>>>' + setBillingIds.size());
            system.debug('insertSpec Size>>>>>>>' + insertSpecChrg.size());
             if (!insertSpecChrg.isEmpty()) {
                 //upsert insertSpecChrg;
                upsert insertSpecChrg External_Id__c;
            }
            
            //UpsertSpecificationObjectRecord.getParentProductName(json, insertSpecChrg, true);
            
       }
        // Change for EDGE-12675
        catch (Exception e) {
            system.debug('exception catch '+e);
            Logger.getLogger(UpsertSpecificationObjectRecord.class).debug(e);
            Logger.exitLogger();
        }
    }
    
    
    public static void upsertSpecificationAssuranceRecord(CS_SigmaToCSJSON json) {
        try{
            Map < String,CS_SigmaToCSJSON.cls_products > mapSpec = new Map < String,CS_SigmaToCSJSON.cls_products > ();
            //CH-1
            Map < String,String> mapParChildSpec = new Map < String,String> ();
            
            CS_SigmaToCSJSON jsonObj = new CS_SigmaToCSJSON();
            jsonObj = json;
            cs_SigmaToCSJSON.cls_productOffering jsonobjPrdtOff = new cs_SigmaToCSJSON.cls_productOffering();
            
            jsonobjPrdtOff = jsonObj.productOffering;
            List < cs_SigmaToCSJSON.cls_products > prodList = new List < cs_SigmaToCSJSON.cls_products > ();
            if(jsonobjPrdtOff.products!=null){
                for (cs_SigmaToCSJSON.cls_products prod: jsonobjPrdtOff.products) {// First Label Product
                    prodList.add(prod);
                    // Change for EDGE-12675
                    if (prod.specId != null && prod.attributes != null && (prod.action !='None'/* && prod.action != 'Affected'*/)) {
                        mapSpec.put(prod.specId, prod);
                        mapParChildSpec.put(prod.specId,prod.specId);
                        //getSpecIdwithProductDefination(prod.specId,mapParChildSpec,prodspectoId,MapSpecIdWithDef);
                    }
                    if(prod.products!=null){
                        for (cs_SigmaToCSJSON.cls_products prods: prod.products) { // 2nd Label Product
                            prodList.add(prods);
                            if (prods.specId != null && prods.attributes != null && (prods.action !='None' /*&& prods.action != 'Affected'*/)) {
                                mapSpec.put(prod.specId+prods.specId, prods);
                                mapParChildSpec.put(prods.specId,prod.specId);
                                //getSpecIdwithProductDefination(prods.specId,mapParChildSpec,prodspectoId,MapSpecIdWithDef);
                            }
                            if(prods.products!=null){
                                for (cs_SigmaToCSJSON.cls_products prodz: prods.products) { // 3rd Label Product
                                    prodList.add(prodz);
                                    if (prodz.specId != null && prodz.attributes != null && (prodz.action !='None'/* && prodz.action != 'Affected'*/)) {
                                        mapSpec.put(prods.specId+prodz.specId, prodz);
                                        mapParChildSpec.put(prodz.specId,prods.specId);
                                        //getSpecIdwithProductDefination(prodz.specId,mapParChildSpec,prodspectoId,MapSpecIdWithDef);
                                    }
                                    if (prodz.products != null) {
                                        for (cs_SigmaToCSJSON.cls_products prodsY: prodz.products) {//4th label Product
                                            prodList.add(prodsY);
                                            if (prodsY.specId != null && prodsY.attributes != null && (prodsY.action !='None' /*&& prodsY.action != 'Affected'*/)) {
                                                mapSpec.put(prodz.specId+prodsY.specId, prodsY);
                                                mapParChildSpec.put(prodsY.specId,prodz.specId);
                                                //getSpecIdwithProductDefination(prodsY.specId,mapParChildSpec,prodspectoId,MapSpecIdWithDef);
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
            system.debug('mapSpec>>>>>'+ mapSpec.size());
            Map <String,Id> prodspectoId = prodDefWithIds();
            system.debug('prodspectoId>>>>' + prodspectoId);
            List < csedm__Specification__c > specRecList = new List < csedm__Specification__c > ([select Id, csedm__identifier__c,External_Id__c from csedm__Specification__c]);
            Map < String,Id > specRecordIdentifierMap = new Map < String,Id > ();
            if(!specRecList.isEmpty()){
                for (csedm__Specification__c identy: specRecList) {
                    /*if (identy.csedm__identifier__c != '' && identy.csedm__identifier__c != null) {
                        specRecordIdentifierMap.put(identy.csedm__identifier__c, identy.Id);
                    }*/
                    // CH-1 Start
                    if (identy.External_Id__c != '' && identy.External_Id__c != null) {
                        specRecordIdentifierMap.put(identy.External_Id__c, identy.Id);
                    }
                    // CH-1 End
                }
            }
            Map < String,cs_SigmaToCSJSON.cls_products > JSONIdentifiertoSpec = new Map < String,cs_SigmaToCSJSON.cls_products > ();
            cs_SigmaToCSJSON.cls_products obj = new cs_SigmaToCSJSON.cls_products();
            if (obj != null) {  
                JSONIdentifiertoSpec.put(obj.externalId, obj);  
            }
            
            List < csedm__Specification__c > insertSpec = new List < csedm__Specification__c > ();
            if(mapSpec.keySet()!=null){
                for (String prodname: mapSpec.keySet()) {
                    system.debug('prodname 548>>>>>');
                    Boolean checkProductTechPhase = UpsertRequestObjectRecord.getProductTechPhase(mapSpec.get(prodname).productStaticCharacteristics);
                    system.debug('checkProductTechPhase>>>>>'+ checkProductTechPhase); 
                    if(!checkProductTechPhase){   
                        for(cs_SigmaToCSJSON.cls_productStaticCharacteristics prodStcChar : mapSpec.get(prodname).productStaticCharacteristics)
                        {
                            // Change for EDGE-12675
                            if(prodStcChar.name == 'AssurancePhase' && prodStcChar.value == 'true') {
                                csedm__Specification__c specList1 = new csedm__Specification__c();
                                if (specRecordIdentifierMap != null && specRecordIdentifierMap.get(mapSpec.get(prodname).externalId) != null && jsonobjPrdtOff.specId != null) {
                                    //specList1.Id = specRecordIdentifierMap.get(mapSpec.get(prodname).externalId);
                                    //CH-1 Start
                                    specList1.Id = specRecordIdentifierMap.get(jsonobjPrdtOff.specId+mapSpec.get(prodname).specId);
                                    //CH-1 End
                                }
                                //CH-1 Start    
                                //specList1.csedm__identifier__c = mapSpec.get(prodname).externalId;
                                //if(mapParChildSpec.containsKey(mapSpec.get(prodname).specId)){
                                    specList1.External_Id__c = prodname;//mapParChildSpec.get(mapSpec.get(prodname).specId)+mapSpec.get(prodname).specId;
                                    specList1.csedm__identifier__c = prodname;//mapParChildSpec.get(mapSpec.get(prodname).specId)+mapSpec.get(prodname).specId;
                                //}
                                specList1.csedm__Version__c = mapSpec.get(prodname).version;
                                specList1.csedm__Active__c = true;
                                specList1.csedm__Start_Date__c = Date.valueOf(mapSpec.get(prodname).associationStartDate);
                                specList1.csedm__End_Date__c = Date.valueOf(mapSpec.get(prodname).associationEndDate);
                                
                                system.debug('>>>>>>>>>>******' + prodspectoId.get(mapParChildSpec.get(mapSpec.get(prodname).specId)));
                              //if(prodspectoId.containskey(mapParChildSpec.get(mapSpec.get(prodname).specId)))
                              String ProductDefId = getProductDefination(mapSpec.get(prodname).specId, mapParChildSpec,prodspectoId);
                                if(ProductDefId != null && ProductDefId !='' && ProductDefId != 'Not Found')
                                   // specList1.csedm__Product_Definition__c = ProductDefId; //Spring 20 commented
                                    specList1.csedm__Source__c = ProductDefId; //Spring 20
                                    
                                /*if(MapSpecIdWithDef.containsKey(mapSpec.get(prodname).specId)){
                                    system.debug('Inside MapSpecIdWithDef >>>');
                                    specList1.csedm__Product_Definition__c = MapSpecIdWithDef.get(mapSpec.get(prodname).specId);
                                }*/
                                // CH-1 End
                                
                                specList1.Name = mapSpec.get(prodname).name+'_Assurance';
                                specList1.csedm__Code__c = mapSpec.get(prodname).specId+'_Assurance';
                                
                                List < cs_SigmaToCSJSON.cls_attributes > attList = new List < cs_SigmaToCSJSON.cls_attributes > ();
                                
                                if(mapSpec.get(prodname).attributes!=null){
                                    attList = mapSpec.get(prodname).attributes;
                                }
                                String ValueJson = '';
                                
                                String Json1 = '{ "code": "' + mapSpec.get(prodname).specId +'_Assurance'+ '", "name": "' + mapSpec.get(prodname).name+'_Assurance' + '", "description": "",  "cpqAttributes": {}, "attributes": {   ';
                                String json2 = '';
                                if (attList.size() == 1) {
                                    for (cs_SigmaToCSJSON.cls_attributes att: attList) {
                                        system.debug('check json2 size' + json2);
                                        if(att.default_x!='' && att.default_x!=null){
                                            json2 += '"' + att.interfaceName + '": {     "value": "' + att.default_x + '",     "type": "' + att.type_x + '"   },';
                                        }
                                    }
                                } else if (attList.size() > 1) {
                                    for (integer i = 0; i < attList.size() - 1; i++) {
                                        system.debug('inside spec method inside if2 for1 ===///');
                                        system.debug('check json2 size' + json2);
                                        if(attList[i].default_x!='' && attList[i].default_x!=null){
                                            json2 += '"' + attList[i].interfaceName + '": {     "value": "' + attList[i].default_x + '",     "type": "' + attList[i].type_x + '"   },';
                                        }
                                    }
                                    if(attList[attList.size() - 1].default_x!='' && attList[attList.size() - 1].default_x!=null){
                                        json2 += '"' + attList[attList.size() - 1].interfaceName + '": {     "value": "' + attList[attList.size() - 1].default_x + '",     "type": "' + attList[attList.size() - 1].type_x + '"   },';
                                        
                                    }
                                }
                                json2+='"__targetSystem": {"value": "ASSURANCE","type": "string"}';
                                string json3 = '}, "nonCommercialAttributes": []}';
                                
                                ValueJson = Json1 + json2 + json3;
                                
                                if(ValueJson!=''){
                                    specList1.csedm__Value__c = ValueJson;
                                }else{
                                    specList1.csedm__Value__c = '{}';
                                }
                                
                                insertSpec.add(specList1);
                            }
                        }
                    }
                }
            }
            system.debug('insertSpec Size>>>>>>>' + insertSpec.size());
            if (!insertSpec.isEmpty()) {
                //upsert insertSpec;
                upsert insertSpec External_Id__c; // CH-1
            }
            
            //UpsertSpecificationObjectRecord.getParentProductName(json, insertSpec, false);
            
        }
        // Change for EDGE-12675
        catch (Exception e) {
            
            Logger.getLogger(SQService.class).debug(e);
            Logger.exitLogger();
        }
    }
    
    Public Static Map<String,Id> prodDefWithIds(){
        Map < String,   Id > prodspectoId = new Map < String,   Id > ();
        for (cscfga__Product_Definition__c pd: [SELECT id, product_Specification__c 
                                FROM cscfga__Product_Definition__c where product_Specification__c != '' 
                                AND cscfga__Active__c = true AND RecordType.Name='Product Definition']) { 
            for(String Spec: pd.product_Specification__c.split(',')){
                prodspectoId.put(Spec, pd.id);
            }       
        }
        return prodspectoId;
    } 
    
    Public Static String getProductDefination(String currentSpecId, Map <String,String> mapParChildSpec,Map <String,Id> prodspectoId){
        system.debug('Outside Loop' + currentSpecId);
        String SpecId = currentSpecId;
        String msg ='';
        for(Integer i =0; i<4 ; i++){
            system.debug('Inside Loop' + SpecId);
            
            if(prodspectoId.containsKey(SpecId)){
                system.debug('Inside SpecId' + SpecId + '>>>>' + prodspectoId.get(SpecId));
                return prodspectoId.get(SpecId);
            }else{
                SpecId = mapParChildSpec.get(SpecId);
                msg = 'Not Found';
            }
        }
        return msg;
    } 
    
    
    /*Public Static void getSpecIdwithProductDefination(String currentSpecId, Map <String,String> mapParChildSpec,Map <String,Id> prodspectoId, Map<String,Id> c){
        system.debug('Outside Loop' + currentSpecId);
        String SpecId = currentSpecId;
        String msg ='';
        for(Integer i =0; i<4 ; i++){
            system.debug('Inside Loop' + SpecId);
            
            if(prodspectoId.containsKey(SpecId)){
                system.debug('Inside SpecId' + SpecId + '>>>>' + prodspectoId.get(SpecId));
                system.debug('Compare SpecId' + SpecId + '>>>>' + currentSpecId);
                if(currentSpecId != SpecId){
                    system.debug('Inside If>>>>');
                    MapSpecIdWithDef.put(SpecId+currentSpecId,prodspectoId.get(SpecId));
                    break;
                }
                else{
                    system.debug('Inside Else>>>>');
                    MapSpecIdWithDef.put(SpecId+currentSpecId,prodspectoId.get(SpecId));
                }
            }else{
                SpecId = mapParChildSpec.get(SpecId);
                msg = 'Not Found';
            }
        }
    }*/

    
    
    
}