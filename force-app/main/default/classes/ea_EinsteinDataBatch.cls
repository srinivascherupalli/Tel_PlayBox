/**
* Author : Shreyansh Sharma(Jaipur)
* Date : 5/24/2021
* Description: P2OB-14430, Batch Class to query and map products againts serviceFNN and custAccNo. from Einstein dataset to Case billing Product field
**/
global class ea_EinsteinDataBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    global string versionId;
    global Boolean hasVersionId = false;
    @TestVisible private static string resultDummy;
     @TestVisible private static string jsonRes;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        string queueId;
        String recId_salesSupportChild=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
        List<group> queue = [select id,developerName from group where developerName = 'Pending_Einstein_Processing_Do_not_use'];
        if(queue != NULL && queue.size()>0){
            queueId = queue[0].id;
        }
        // Filter records of channel care record type and where Owner Id is Pending Einstein Queue
        String query = 'Select Id,ss_billing_Product__c,ss_Type__c,soc_MICA_Account_No__c,soc_FNNs__c,Salesup_Customer_Account_Number__c, OwnerId, Account.APTPS_Off_Shore_Restricted__c from Case where OwnerId =:queueId  AND recordType.Id =: recId_salesSupportChild LIMIT 10';
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Case> records) {
        
        string serviceNo;
        string BillingAccountNo;
        string strServ;
        string strBill;
        List<case>lstCaseServiceNos = new List<case>();
        List<case>lstCaseBANs =  new List<case>();
        List<case>finallstCaseServiceNos = new List<case>();
        List<case>finallstCaseBANs =  new List<case>();
        List<case>NullValueLst =  new List<case>();
        integer i = 0;
        
        //maintain 'hasVersionId' stateful variable to avoid back to back callouts for every record in a transaction
        //callout to the Einstein Dataset to get Version Id of the Dataset
        // store the version Id in a variable and pass to helper method
        if(!hasVersionId){
            String getId = Label.ea_EinsteinDataSet.substringBetween('\"','/'); 
            String endPt = Label.Einstein_EndPoint;
            
            HttpRequest req = new HttpRequest();
            if(Test.isRunningTest()){
                req.setEndpoint('test');
            }
            else{
            	req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+endPt+getId);
            }
            req.setHeader('Authorization', 'OAuth '+ system.UserInfo.getSessionId());
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('GET');
            string json;
            Http http = new Http();
            
            if(!Test.isRunningTest()){
           		 HttpResponse res = http.send(req);
           		 system.debug('--res--' + res.getbody());
           		 json = res.getbody();
            }
            else{
                json=jsonRes;
            }
            map<string,Object> p = (map<string,Object>)system.JSON.deserializeUntyped(json);
            if(Test.isRunningTest()){
           	    versionId = 'test';
            }
            else{
                 versionId = (String)p.get('currentVersionId');
            }
            system.debug('--res--' + versionId);
            hasVersionId = true;
        }
        
        //seggregate between service and customerAccNo records
        //give preference to service fnn is both are present
        if(hasVersionId){
            if(records.size()>0){
                for(Case csServ : records){
                    if(csServ.soc_FNNs__c != NULL && csServ.soc_FNNs__c != ''){
                        lstCaseServiceNos.add(csServ);
                        
                    }
                    else if(csServ.Salesup_Customer_Account_Number__c != NULL && csServ.Salesup_Customer_Account_Number__c != ''){
                        lstCaseBANs.add(csServ);

                       
                    }
                    //check if both service fnn and custAccNo. are blank
                    else if((csServ.Salesup_Customer_Account_Number__c == NULL || csServ.Salesup_Customer_Account_Number__c == '')
                           												&& (csServ.soc_FNNs__c == NULL || csServ.soc_FNNs__c == '')){
                       
                        NullValueLst.add(csServ);
                          system.debug('***'+NullValueLst);

                    }
                }
            } 
            // build string variable for service
            // variable to be passed to handler class for executing query
            if(lstCaseServiceNos.size()>0){
                for(case cs: lstCaseServiceNos){
                    ++i;
                    if(strServ == NULL || strServ == ''){
                        strServ = '["'+cs.soc_FNNs__c+'\"';
                    }
                    else{
                        system.debug('a');
                        strServ =strServ +','+'\"'+cs.soc_FNNs__c+'\"';
                    }
                    if(i == lstCaseServiceNos.size()){
                        strServ= strServ+']';
                    }
                    serviceNo = +strServ;
                    system.debug('&&&&'+serviceNo);
                    finallstCaseServiceNos.add(cs);
                }    
            }
            
            // build string variable for Customer Account Number
            // variable to be passed to handler class for executing query
            if(lstCaseBANs.size()>0){
                for(Case csBil: lstCaseBANs){
                    if(strBill == NULL || strBill == ''){
                        strBill = '\'Billing_Account_Info\' like \"' +csBil.Salesup_Customer_Account_Number__c+ '%MICA\" || \'Billing_Account_Info\' like \"' +csBil.Salesup_Customer_Account_Number__c + '%FlexCAB\"';
                    }
                    else{
                        strBill = strBill +'||'+'\'Billing_Account_Info\' like \"' +csBil.Salesup_Customer_Account_Number__c+ '%MICA\" || \'Billing_Account_Info\' like \"' +csBil.Salesup_Customer_Account_Number__c + '%FlexCAB\"';
                    }
                    
                    BillingAccountNo =+strBill;
                    system.debug('***bilstr'+BillingAccountNo);
                    finallstCaseBANs.add(csBil);
                }
            }
           // call the handler class

            if((serviceNo != NULL && serviceNo != '') || (BillingAccountNo != NULL && BillingAccountNo != '') || (NullValueLst.size()>0)){

                EinsteinDataHandler.getEinsteinProducts(serviceNo,BillingAccountNo,finallstCaseServiceNos,finallstCaseBANs,versionId,resultDummy,NullValueLst); 
            }
        }
    }   
    
    global void finish(Database.BatchableContext BC){    
    }
    
}