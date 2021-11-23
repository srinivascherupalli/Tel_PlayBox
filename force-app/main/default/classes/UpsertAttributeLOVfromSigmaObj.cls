/*Story number: EDGE-206
Description:Inserting and updating attributes LOVs
*/

public with sharing class UpsertAttributeLOVfromSigmaObj {
    
    public static void uppsertattLov(cs_SigmaToCSJSON obj) {
        try{
            Map < String,
                List < cs_SigmaToCSJSON.cls_attributes >> mapProducttoAttribute = new Map < String,
                List < cs_SigmaToCSJSON.cls_attributes >> ();
            cs_SigmaToCSJSON jsonobj = new cs_SigmaToCSJSON();
            jsonobj = obj;
            cs_SigmaToCSJSON.cls_productOffering jsonobjPrdtOff = new cs_SigmaToCSJSON.cls_productOffering();
            jsonobjPrdtOff = jsonobj.productOffering;
            system.debug('====///' + jsonobjPrdtOff);
            upsertProduct2Record(jsonobjPrdtOff);
            List < cs_SigmaToCSJSON.cls_products > prodlist = new List < cs_SigmaToCSJSON.cls_products > ();
            // Change for EDGE-12675 
            for (cs_SigmaToCSJSON.cls_products prod: jsonobjPrdtOff.products) {
                prodlist.add(prod);
                if (prod.attributes != null && (prod.action !='None' && prod.action != 'Affected')) {
                    mapProducttoAttribute.put(prod.name, prod.attributes);
                }
                if (prod.products != null) {
                    for (cs_SigmaToCSJSON.cls_products prods: prod.products) {
                        system.debug('check prod name' + prods.name);
                        prodlist.add(prods);
                        if (prods.attributes != null && (prods.action !='None' && prods.action != 'Affected')) {
                            mapProducttoAttribute.put(prods.name, prods.attributes);
                        }
                        if (prods.products != null) {
                            for (cs_SigmaToCSJSON.cls_products prodsZ: prods.products) {
                                prodlist.add(prodsZ);
                                if (prodsZ.attributes != null && (prodsZ.action !='None' && prodsZ.action != 'Affected')) {
                                    mapProducttoAttribute.put(prodsZ.name, prodsZ.attributes);
                                }
                                if (prodsZ.products != null) {
                                    for (cs_SigmaToCSJSON.cls_products prodsY: prodsZ.products) {
                                        prodlist.add(prodsY);
                                        if (prodsY.attributes != null && (prodsY.action !='None' && prodsY.action != 'Affected')) {
                                            mapProducttoAttribute.put(prodsY.name, prodsY.attributes);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            boolean bIsPreset;
            List<Product_Attribute_LOV__c> attLovList1  = [select id,name,Package_Name__c,Product_Definition__c,Value__c  from Product_Attribute_LOV__c];
            List < Product_Attribute_LOV__c > insertattLov = new List < Product_Attribute_LOV__c > ();
            Set < Product_Attribute_LOV__c > deleteattLov = new Set < Product_Attribute_LOV__c > ();
            for (String prodname: mapProducttoAttribute.keyset()) {
                List < cs_SigmaToCSJSON.cls_attributes > attlist = mapProducttoAttribute.get(prodname);
                for (cs_SigmaToCSJSON.cls_attributes att: attlist) {
                    if (att.values != null) {
                        for (String attlovvalue: att.values) {
                            for(Product_Attribute_LOV__c attLov1: attLovList1){
                                // Change for EDGE-12675 
                                if(attLov1.Name == att.interfaceName && attLov1.Package_Name__c == jsonobjPrdtOff.name && attLov1.Product_Definition__c == prodname)
                                {
                                    deleteattLov.add(attLov1);
                                }
                            }
                            Product_Attribute_LOV__c attlov = new Product_Attribute_LOV__c();
                            attlov.name = att.interfaceName;
                            attlov.Package_Name__c = jsonobjPrdtOff.name;
                            attlov.Product_Definition__c = prodname;                                
                            //System.debug('attlov.Product_Definition1__c====>'+attlov.Product_Definition1__c);
                            attlov.Value__c = attlovvalue;
                            insertattLov.add(attlov);
                        }
                    }
                }
                
            }
            if (!deleteattLov.isEmpty()) {
                List < Product_Attribute_LOV__c > deleteattLovLst = new List < Product_Attribute_LOV__c > ();
                deleteattLovLst.addAll(deleteattLov);
                delete deleteattLovLst;
            }
            if (!insertattLov.isEmpty()) {
                insert insertattLov;
            }
        }
        // Change for EDGE-12675 
        catch (Exception e) {
            
            Logger.getLogger(UpsertAttributeLOVfromSigmaObj.class).debug(e);
            Logger.exitLogger();
        } 
        
    }
    //Edge 20138
    public static void upsertProduct2Record(cs_SigmaToCSJSON.cls_productOffering productOffering){
        
        if(productOffering != null && productOffering.name != null && productOffering.specId != null){
            System.debug('<><><>'+productOffering.Name);
            List<Product2> product = [SELECT Id, Name FROM Product2 WHERE Name =: productOffering.Name AND productcode =: productOffering.specId LIMIT 1];
           
             if(product.isEmpty()){
                Product2 prod = new Product2();
                prod.Name = productOffering.name;
                prod.ProductCode  = productOffering.specId;
                insert prod;
            }
        }  
        
    }      
}