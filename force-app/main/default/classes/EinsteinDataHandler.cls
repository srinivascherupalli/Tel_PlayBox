/**
* Author : Shreyansh Sharma(Jaipur)
* Date : 5/24/2021
* Description: P2OB-14430, Handler class to perform Einstein Queries
**/
public with sharing class EinsteinDataHandler {
    
    public static void getEinsteinProducts(string ServiceNumberStr, string BillingAccountStr, List<case>lstCaseServiceNos,List<case>lstCaseBANs,String dataSetVersionId,string resultDummy,List<case>updateBlankfieldLst){
        Map<String, String> mapServiceNumber =  new Map<String,String>();
        Map<String, String> mapCustomerAccountNumber =  new Map<String,String>();
        Map<String, String> mapEinsteinProdToServNo = new Map<String,String>();
        List<ApplicationLog__c> errorLogging = new List<ApplicationLog__c>();
        ApplicationLog__c ap = new ApplicationLog__c();
        List<Case> lstCasesToUpdate =  new List<Case>();
        String dataSet = Label.ea_EinsteinDataSet;
        
        String enterpriseBillingId;
        String enterpriseBillingConsentingId;
        String enterpriseBillingNonConsentingId;
        
       //get Queue Id's 
        List<group> enterpriseBilling =  [select id,developerName from group where developerName = 'eb_Enterprise_Billing' LIMIT 1]; 
        if(enterpriseBilling != NULL && enterpriseBilling.size()>0){
            enterpriseBillingId = enterpriseBilling[0].id;
        }
        List<group> enterpriseBillingConsenting = [select id,developerName from group where developerName = 'Enterprise_Billing_WFC_Consenting' LIMIT 1]; 
        if(enterpriseBillingConsenting != NULL && enterpriseBillingConsenting.size()>0){
            enterpriseBillingConsentingId = enterpriseBillingConsenting[0].id;
        }
          List<group> enterpriseBillingCon = [select id,developerName from group where developerName = 'soc_Concierge_Offshore_Support_request' LIMIT 1]; 
        if(enterpriseBillingConsenting != NULL && enterpriseBillingConsenting.size()>0){
            enterpriseBillingConsentingId = enterpriseBillingConsenting[0].id;
        }  List<group> enterpriseBillingWorkflowconsenting= [select id,developerName from group where developerName = 'srvsup_Workflow_Co_ordinator' LIMIT 1]; 
        if(enterpriseBillingConsenting != NULL && enterpriseBillingConsenting.size()>0){
            enterpriseBillingConsentingId = enterpriseBillingConsenting[0].id;
        }
        List<group> enterpriseBillingNonConsenting = [select id,developerName from group where developerName = 'Enterprise_Billing_WFC_Non_Consenting' LIMIT 1]; 
        if(enterpriseBillingNonConsenting != NULL && enterpriseBillingNonConsenting.size()>0){
            enterpriseBillingNonConsentingId = enterpriseBillingNonConsenting[0].id;
        }
        
        try{
            //check if billing Account no. is present on case, if present then process the related Einstein Query
             if(BillingAccountStr != '' && BillingAccountStr != NULL){
                String billingStr = BillingAccountStr;
                String query = 'q = load'+' '+dataSet+dataSetVersionId+'\"'+';';
                query +='q = group q by \'Billing_Account_Info\';';
                query += 'q = filter q by ' + billingStr + ';';
                query += 'q = foreach q generate \'Billing_Account_Info\', count() as \'count\';';
                query += 'q = limit q 20;';
           
                 ea_jsonParser  parsedStr = ea_jsonParser.parse('{"name":"Test"}'); 
                 if(Test.isRunningTest()){
               		parsedStr =  ea_jsonParser.parse(resultDummy);
                }
                 else{
               		   ConnectApi.LiteralJson result =  ConnectApi.Wave.executeQuery(query);
                   	   parsedStr =  ea_jsonParser.parse(result.json);
                }
                 
                //check if there are records returned in Einstein dataset query, if present then prepare a map 
                if(parsedStr.Results.records != NULL){
                    for(ea_jsonParser.Records str: parsedStr.Results.records){
                        //check if the record contains MICA keyword, is it contains then seggregate BAN from keyword and put accordingly in map
                        if(str.Billing_Account_Info.contains('MICA')){
                            String billAccInfo = str.Billing_Account_Info.substringBefore(' ');
                            mapCustomerAccountNumber.put(billAccInfo,'Mobile');
                        }
                        //check if the record contains FlecCAB keyword, is it contains then seggregate BAN from keyword and put accordingly in map
                            else if(str.Billing_Account_Info.contains('FlexCAB')){
                            String billAccInfo = str.Billing_Account_Info.substringBefore(' ');
                            //check if BAN record is already in the map, i.e there are 2 value for a given BAN
                            //one with MICA and one for FlexCAB
                            //then give preference to MICA and update map record accordingly
                            if(mapCustomerAccountNumber.containsKey(billAccInfo) && mapCustomerAccountNumber.get(billAccInfo) == 'Mobile'){

                               // mapCustomerAccountNumber.put(billAccInfo,'Mobile');
                            }
                            else{
                                mapCustomerAccountNumber.put(billAccInfo,'All Other Products');
                            }
                        }
                    }
                }
                
                for(Case cs: lstCaseBANs){
                    //check if einstein returned a value against given BAN from case
                    if(mapCustomerAccountNumber.containsKey(cs.Salesup_Customer_Account_Number__c)){
                        cs.ss_billing_Product__c = mapCustomerAccountNumber.get(cs.Salesup_Customer_Account_Number__c);
                        cs.OwnerId = enterpriseBillingId;
                        lstCasesToUpdate.add(cs);
                    }
                    //If no value is returned then assign the case to respective queues
                    else if(cs.Account.APTPS_Off_Shore_Restricted__c){
                        cs.OwnerId = enterpriseBillingNonConsentingId;
                        lstCasesToUpdate.add(cs);
                    }
                    else if(!cs.Account.APTPS_Off_Shore_Restricted__c){
                        cs.OwnerId = enterpriseBillingConsentingId ;
                        lstCasesToUpdate.add(cs);
                    }
                }
            }
            
            //Check if Service no. is present, if present then process Einstein query for service no.
            if(ServiceNumberStr != '' && ServiceNumberStr != NULL){
                String ServiceStr = ServiceNumberStr;
                String query = 'q = load'+' '+dataSet+dataSetVersionId+'\"'+';';
                query += 'q = filter q by \'VisibleSvcDescription\' in ' +ServiceNumberStr+ ';';
                query += 'q = foreach q generate \'VisibleSvcDescription\',\'Svc_Type\';';
                query += 'q = limit q 20;';
               
				ea_jsonParser  parsedStr = ea_jsonParser.parse('{"name":"Test"}');
                if(Test.isRunningTest()){
               		parsedStr =  ea_jsonParser.parse(resultDummy);
                }
                else{
               		   ConnectApi.LiteralJson result =  ConnectApi.Wave.executeQuery(query);
                   	   parsedStr =  ea_jsonParser.parse(result.json);
                }
               
                List<Einstein_Product_Mapping__mdt> lstEinsteinMapping = [Select Einstein_Product__c,Phoenix_Product__c from Einstein_Product_Mapping__mdt];
                for(Einstein_Product_Mapping__mdt epm : lstEinsteinMapping){
                    mapServiceNumber.put(epm.Einstein_Product__c,epm.Phoenix_Product__c);
                }
                //check if there are records returned in Einstein dataset query, if present then prepare a map 
                if(parsedStr.Results.records != NULL && parsedStr.Results.records.size()>0){
                    for(ea_jsonParser.Records str: parsedStr.Results.records){
                        mapEinsteinProdToServNo.put(str.VisibleSvcDescription,str.Svc_Type);
                    }
                }
                for(case cs: lstCaseServiceNos){
                    //check if einstein returned a value against given service no. from case
                    string testSTR1 = mapEinsteinProdToServNo.get(cs.soc_FNNs__c);
                    if(mapEinsteinProdToServNo != NULL && mapEinsteinProdToServNo.containsKey(cs.soc_FNNs__c)){
                        string testStr = mapEinsteinProdToServNo.get(cs.soc_FNNs__c);
                        
                        //check if there's a corresponding value for einstein record in the Metadata
                        if(mapServiceNumber.containsKey(mapEinsteinProdToServNo.get(cs.soc_FNNs__c))){
                            cs.ss_billing_Product__c = mapServiceNumber.get(mapEinsteinProdToServNo.get(cs.soc_FNNs__c));
                            
                            cs.OwnerId = enterpriseBillingId;
                            lstCasesToUpdate.add(cs);
                        }
                        //if record is not present in metadata then  assign the case to respective queues
                        else if(cs.Account.APTPS_Off_Shore_Restricted__c){
                            cs.OwnerId = enterpriseBillingNonConsentingId;
                            lstCasesToUpdate.add(cs);
                        }
                        else if(!cs.Account.APTPS_Off_Shore_Restricted__c){
                            cs.OwnerId = enterpriseBillingConsentingId;
                            lstCasesToUpdate.add(cs);
                        }
                    }
                    //if record is not found in the Einstein dataSet itself then assign the case record to respective queues
                    else if(cs.Account.APTPS_Off_Shore_Restricted__c){
                        cs.OwnerId = enterpriseBillingNonConsentingId;
                        lstCasesToUpdate.add(cs);    
                    }
                    else if(!cs.Account.APTPS_Off_Shore_Restricted__c){
                        cs.OwnerId = enterpriseBillingConsentingId;
                        lstCasesToUpdate.add(cs);
                    }
                    
                }  
            }
            //traverse through the records where service fnn and customer Account Number are blank 
            if(updateBlankfieldLst.size()>0){
                for(Case cs : updateBlankfieldLst){
                    if(cs.Account.APTPS_Off_Shore_Restricted__c){
                        cs.OwnerId = enterpriseBillingNonConsentingId;
                        lstCasesToUpdate.add(cs);    
                    }
                    else if(!cs.Account.APTPS_Off_Shore_Restricted__c){
                       		  cs.OwnerId = enterpriseBillingConsentingId;
                    	      lstCasesToUpdate.add(cs);
                    }
                }
            }
            // Perform database.update operation if list has records
            // get failed records(DML operation) if any, and create a record for each in application log object
            if(lstCasesToUpdate.size()>0){
               List<Database.SaveResult> dmlResult = database.update(lstCasesToUpdate);
               for(Database.SaveResult results: dmlResult){
                    if(!results.isSuccess()){
                        for(Database.Error e: results.getErrors()){
                            ap.Entity_Name__c = 'BillingEinsteinProudctsBatch';
                            ap.Debug_Level__c = 'Exception';
                            ap.Error_Category__c = 'Technical';
                            ap.Message__c = 'Query Exception - ' + e;
                            system.debug('!!!!'+e);
                            errorLogging.add(ap);
                            system.debug('###'+errorLogging);
                        }
                    }
                }
                insert errorLogging;
            }
        }
        //catch general exception and create a application log record object
        catch(Exception e){
            
            ap.Entity_Name__c = 'BillingEinsteinProudctsBatch';
            ap.Debug_Level__c = 'Exception';
            ap.Error_Category__c = 'Technical';
            ap.Message__c = 'Query Exception - ' + e;
            system.debug('!!!!'+e);
            errorLogging.add(ap);
            
            insert errorLogging;
        }
        
    }
}