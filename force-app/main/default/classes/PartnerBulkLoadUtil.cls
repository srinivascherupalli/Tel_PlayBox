/* EDGE-84585, EDGE-85502, EDGE-84580 : Bulk Tag Utility */
/* Team Hawaii - 08-28-2019 - Populate Partner Account Id on Opportunity Line Item */
public with sharing class PartnerBulkLoadUtil {
    public static  Map<String,Map<String,String>> mapBulkLoadData= new map<String,Map<String,String>>();
    public static Map<string,account> accountPartnerCodeMap = new map<string,Account>();

    public static String STRING_DELIMETER_COMMA= PRMCONSTANTS.STRING_DELIMETER_COMMA;
    public static Map<String, String> oppAccountIdMap = new Map<String, String>(); // Team Hawaii  - 08-29-2019
    public static Map<String, String> accountPrincipleContactMap = new Map<String, String>(); // Team Hawaii  - 08-29-2019
    public static Id PartnerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
    /*EDGE-84580
Process the CSV file uploaded and create Summary record in Bulk Load Staging and start the batch job for the updates*/
    @AuraEnabled
    public static void readFile(String source){
        Logger2 logger = Logger2.getLogger('PartnerBulkLoadUtil.readFile');
        list<Bulk_Load_Staging__c> BulkstgeReclst = new list<Bulk_Load_Staging__c>();
        try{
        system.debug('source'+source);
            Bulk_Load_Staging__c summaryrec=processCSVFile(source); //Process the CSV file uploaded
            BatchPRMPartnerTagging partnertag= new BatchPRMPartnerTagging('',mapBulkLoadData);
            //String batchId = Database.executeBatch(partnertag, 1); //batch job
            String batchId;
             if(!Test.isRunningTest()){
                batchId = Database.executeBatch(partnertag, 1); //batch job
             }else{
                batchId = Database.executeBatch(partnertag, 10); //batch job
             }
            //Id trimmed tomatch with the batchid returned on initiating batch class
            summaryrec.Batch_ID__c=String.valueOf(batchId).substring(0, 15);
            summaryrec.Status__c=PRMConstants.BULK_TAGGING_STATUS_INPROGRESS;

            BulkstgeReclst.add(summaryrec);
          //create Summary record
            for(Bulk_Load_Staging__c stagrec:[SELECT id,OpportunityID__c,Product_Code__c,ExternalId__c FROM Bulk_Load_Staging__c WHERE Bulk_Load_Staging__c= :summaryrec.id]){
                stagrec.ExternalId__c=batchId+''+stagrec.OpportunityID__c+''+stagrec.Product_Code__c;
                BulkstgeReclst.add(stagrec);
            }

            update BulkstgeReclst;
        }
        catch(exception e){
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
        }
        finally{
            logger.exitLogger();
        }
    }
    /*EDGE-84580 Process the CSV file uploaded and create records in Bulk Load Staging*/
    @AuraEnabled
    public static Bulk_Load_Staging__c processCSVFile(String source){
        Logger2 logger = Logger2.getLogger('PartnerBulkLoadUtil.processCSVFile');
        Bulk_Load_Staging__c summaryrec= new Bulk_Load_Staging__c();

        try{
            List<String> csvRows= source.split('\r\n');
            set<string> ParterCodes= new set<string>();

            String header= csvRows[0];
            csvRows.remove(0);

            //Insert Bulk Load Staging summarized record from file
            summaryrec.Total_Records__c=String.valueof(csvRows.size());
            summaryrec.Name=Label.PRM_Bulk_tag_summaryrec_name +string.valueOf(system.today());
            insert summaryrec;

            list<Bulk_Load_Staging__c> bulkStaginglist= new list<Bulk_Load_Staging__c>();

            //Iterating to all CSv columns to capture Partner Codes for Checking whether Partner Code available in Salesforce or not
            for(String eachRow: csvRows){
                List<String> data= eachRow.split(',');
                String partnerCode=data.size()>2?data[2]:'';  //3rd Element will be the Partner Code
                ParterCodes.add(partnerCode);
            }

            Id PartnerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();


            List<Account> accList = new List<Account> ([SELECT id, Partner_Code__c, Name FROM Account WHERE Partner_Code__c in: ParterCodes and Account_Status__c not in('New','Pending Activation','Inactive','Frozen') and IsPartner=true and Recordtypeid=:PartnerRecTypeId]);

           for(Account acc : accList){
               accountPartnerCodeMap.put(acc.Partner_Code__c,acc);
            }

            for(String eachRow: csvRows){
                //prepare the Bulk_Load_Staging__c object records
                bulkStaginglist.add(prepareBulkUploadData(eachRow,summaryrec.id)) ;
            }

            if(bulkStaginglist.size()>0)
                insert bulkStaginglist;
            integer failureRecCount=0;
            for(Bulk_Load_Staging__c bs:bulkStaginglist){
                if(bs.status__c==PRMConstants.BULK_TAGGING_STATUS_FAILED){
                    failureRecCount++;
                }

            }
            //Updating Failure count in Summary record when we have missing fields in CSV file. OpportunityId,Product Code

            summaryrec.Failures__c=String.valueof((summaryrec.Failures__c!=null && Integer.valueOf(summaryrec.Failures__c)>0)?(Integer.valueOf(summaryrec.Failures__c)+failureRecCount):failureRecCount);
            update summaryrec;

        }
        catch(exception e)
        {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
        }
        finally{
            logger.exitLogger();
        }
        return summaryrec ;
    }



    // Prepare Bulk data for upload. input each row from csv and the summaryRecord id
    @AuraEnabled
    public static Bulk_Load_Staging__c prepareBulkUploadData(String eachRow,string summaryrecId ){

        //Each row will look like A-1009,P3653,EDF6
        system.debug('prepareBulkUploadData summaryrecId'+summaryrecId);
        List<String> data= eachRow.split(',');

            String opptyId    =data.size()>0?data[0]:'';
            String ProductCode=data.size()>1?data[1]:'';
            String partnerCode=data.size()>2?data[2]:'';
            String Submittedby=data.size()>3?data[3]:'';


            //Assign Values from the CSV rows
            Bulk_Load_Staging__c stagingrec= new Bulk_Load_Staging__c();
            stagingrec.OpportunityID__c=opptyId;
            stagingrec.Partner_Code__c=partnerCode;
            stagingrec.Product_Code__c=ProductCode;
            stagingrec.Submitter__c=Submittedby;


       //Considering only the CSV file rows having matching partner code in Salesforce, Other case we are capturing Remarks as Missing partner code and status as failed.

       If(accountPartnerCodeMap.ContainsKey(partnerCode)){
          //map of oppty and productcode vs Partner code to be udpated. process each row and get the oppty id, product code and Partner Codes
            if(mapBulkLoadData.containsKey(opptyId)){
                mapBulkLoadData.get(opptyId).put(ProductCode,partnerCode);
            }else{
                map<string,string> PartnerProductMap= new map<string,string>();
                PartnerProductMap.put(ProductCode,partnerCode);
                mapBulkLoadData.put(opptyId,PartnerProductMap);
            }

              //For Updating Summary record Status based on File content, if Opportunityid or Product code is blank then those record will not be processed, so we are setting status for these cases from below logic to capture status in staging records.

            if(opptyId==''){
                        stagingrec.Remarks__c=PRMConstants.BULK_TAGGING_MISSING_OPP_ID;
                        stagingrec.status__c=PRMConstants.BULK_TAGGING_STATUS_FAILED;
             }
            else if(opptyId!='' && ProductCode=='')
            {
                        stagingrec.Remarks__c=PRMConstants.BULK_TAGGING_MISSING_PRODUCT_CODE;
                        stagingrec.status__c=PRMConstants.BULK_TAGGING_STATUS_FAILED;
            }


        }else{
                    stagingrec.Remarks__c=PRMConstants.BULK_TAGGING_MISSING_PARTNER_CODE;
                    stagingrec.status__c=PRMConstants.BULK_TAGGING_STATUS_FAILED;
        }


        stagingrec.Bulk_Load_Staging__c=summaryrecId;
        return stagingrec;
    }
    /*
    @AuraEnabled
    public static void executebatch(String eachRow){ //Execute the Batch Job
        //Each row will look like A-1009,P3653,EDF6
        List<String> data= eachRow.split(',');
        String opptyId=data[0];
        String ProductCode=data[1];
        String partnerCode=data[2];
        //TODO process each row and get the oppty id, product code and Partner Codes
        if(mapBulkLoadData.containsKey(opptyId)){
            //TODO
        }else{

        }
    } */

    public static void updatePartnerTags(String opportunityId, Map<String,String> mapProductToPartner,string batchid){
         Logger2 logger = Logger2.getLogger('PartnerBulkLoadUtil.updatePartnerTags');
        /*String opportunityId='A-00041598';
                                Map<String,String> mapProductToPartner= new map<String,String>();
                                mapProductToPartner.put('1TF6DR','XYZ');
                                mapProductToPartner.put('1TF6DX','ssssss');
                                 string batchid='Test'; */
        //UPDATE the attributes of basket using below code
        //Find All Oppty in the csv
        String productDefName = PRMConstants.BULK_TAGGING_CS_PRODUCTDEFINITION_NAME; //productDefName currently set to 'Current Product Catalog'
        map<string,string> ProductCodeMap= new map<string,string>();
        Set < String > missingProductCodeSet = new set < String > ();
        Set < String > ProductCodeSet = new set < String > ();
        Set < String > UpdatedProductcodeset = new set < String > ();
        Set < String > allUpdatesStatusset = new set < String > ();
        Set < String > missingPartnercodesset = new set < String > ();
        map<string,string> OldPartnerCodeMap= new map<string,string>();

        //Neccessary filters for correct basket selection
        List < cscfga__Product_Basket__c > prodBasketsLoadedByDatahub = [SELECT Id, cscfga__Opportunity__r.Opportunity_Number__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__r.Opportunity_Number__c =:opportunityId];

       //how to exclude the auto archived definitions? there are multiple record for this query
       // Id attrDefnId = [SELECT id FROM cscfga__Attribute_Definition__c WHERE Name = 'Partner' AND cscfga__Product_Definition__r.Name =:productDefName].Id;
        Set < Id > pbIdSet = new Set < Id > ();
        List < cscfga__Product_Configuration__c > pcList = new List < cscfga__Product_Configuration__c > ();
        
   
        /* no where this variable is refered, commented // Commented part of code refector for cyclomatic complexity reduction
        for (cscfga__Product_Basket__c pb: prodBasketsLoadedByDatahub) {
            pbIdSet.add(pb.Id);
        }*/

        //get the account details from partner code in csv and store in a map
        map<String,account> accountPcMap= new map<String,account>();
        accountPcMap=getaccountPcMap(mapProductToPartner);


        Map < Id,cscfga__Product_Configuration__c > prodConfigsLoadedbyDataHub = new Map <Id,cscfga__Product_Configuration__c > ([SELECT id, cscfga__Product_Basket__r.cscfga__Opportunity__r.Opportunity_Number__c, Quantity_Product_Configuration__c, (SELECT id, Name,cscfga__Value__c FROM cscfga__Attributes__r WHERE Name in ('Partner','ProductCode','PartnerName','DealerCode','Channel')) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c in: prodBasketsLoadedByDatahub AND cscfga__Product_Definition__r.Name =:productDefName]);

        List<cscfga__Attribute__c> listAttributes= new List<cscfga__Attribute__c>();
       try{

        //map for identifying the Configuration we need to update based on Product code

        ProductCodeMap=getProductCodeMap(prodConfigsLoadedbyDataHub);



    system.debug('ProductCodeMap'+ProductCodeMap);
    ProductCodeSet.addAll(ProductCodeMap.Values());

    for (cscfga__Product_Configuration__c pc: prodConfigsLoadedbyDataHub.values()) {
    String Productcode=ProductCodeMap.get(pc.id);

    if(mapProductToPartner.containsKey(Productcode))
       {
          String ExtrId=batchId+''+opportunityId+''+Productcode;
                
       if(accountPcMap.containsKey(mapProductToPartner.get(Productcode))){
            Set < String > setValidProductCode = new Set < String > ();
            for (cscfga__Attribute__c att: pc.cscfga__Attributes__r) {
                String attributeName = att.name;

                System.debug('--attributeName----' + attributeName);

                    Boolean Partnerattribute= (attributeName=='DealerCode' || attributeName=='PartnerName' || attributeName=='Channel' || attributeName=='Partner');
                    if(Partnerattribute){
					
					assignAttributevalue(OldPartnerCodeMap,att,mapProductToPartner,Productcode,accountPcMap,ExtrId);

                        /*
                switch on attributeName {
                    when 'DealerCode' {
                    system.debug('DealerCode'+mapProductToPartner.get(Productcode));

                               // if(att.cscfga__Value__c!=null){
                               //   OldPartnerCodeMap.put(ExtrId,att.cscfga__Value__c);
                               //   }
								
									
								OldPartnerCodeMap=addOldpartnercode(OldPartnerCodeMap,att,ExtrId);

                        att.cscfga__Value__c = mapProductToPartner.get(Productcode);
                        att.cscfga__Display_Value__c =mapProductToPartner.get(Productcode);

                    }
                    when 'PartnerName' {
                        // if(accountPcMap.containsKey(mapProductToPartner.get(Productcode))) This is being checked initially
                        att.cscfga__Value__c = accountPcMap.get(mapProductToPartner.get(Productcode)).Name;
                        att.cscfga__Display_Value__c = accountPcMap.get(mapProductToPartner.get(Productcode)).Name;
                    }
                    when 'Channel' {
                        att.cscfga__Value__c = 'Indirect';
                        att.cscfga__Display_Value__c ='Indirect';
                    }
                    when 'Partner' {
                        // if(accountPcMap.containsKey(mapProductToPartner.get(Productcode))) This is being checked initially
                        att.cscfga__Value__c = accountPcMap.get(mapProductToPartner.get(Productcode)).id;
                        att.cscfga__Display_Value__c = accountPcMap.get(mapProductToPartner.get(Productcode)).Name;
                       }
                }
						*/

                        UpdatedProductcodeset.add(ExtrId);
                        allUpdatesStatusset.add(ExtrId);

               }
					
                listAttributes.add(att);
                        
            }
                    
                    
        }
        else{
                missingPartnercodesset.add(ExtrId);
                allUpdatesStatusset.add(ExtrId);
        }
         }
          }

       //if (listAttributes.size() > 0) {
            update listAttributes;
            System.debug('--listAttributes----' + listAttributes);
        //}

		missingProductCodeSet=getMissingProductCodes(mapProductToPartner,ProductCodeSet,batchId,opportunityId);
		allUpdatesStatusset.addall(missingProductCodeSet);

        //Update Success and Failure counts
        list<Bulk_Load_Staging__c> bslist =[SELECT id,status__c,Remarks__c,ExternalId__c FROM Bulk_Load_Staging__c WHERE ExternalId__c in :allUpdatesStatusset];

			updatebulkloadStatus(   
                                bslist,
                                OldPartnerCodeMap,
                                missingProductCodeSet,
                                missingPartnercodesset,
                                UpdatedProductcodeset,
                                batchid);

            updateOpportuntyLineItem(opportunityId,mapProductToPartner,accountPcMap); //update opportunity line item fields
               // }

                }
    catch (Exception ex) {
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        } finally {
            logger.exitLogger();
                    }
                    }

private static void assignAttributevalue(map<string,string> OldPartnerCodeMap,
											cscfga__Attribute__c att,
											Map<String,String> mapProductToPartner,
											String Productcode,
											map<String,account> accountPcMap,
											string ExtrId)
               {
	String attributeName = att.name;
		
	 switch on attributeName {
                            when 'DealerCode' {
                            system.debug('DealerCode'+mapProductToPartner.get(Productcode));
								   
                               /* if(att.cscfga__Value__c!=null){
                                    OldPartnerCodeMap.put(ExtrId,att.cscfga__Value__c);
                    }
									*/

								OldPartnerCodeMap=addOldpartnercode(OldPartnerCodeMap,att,ExtrId);
									
                                att.cscfga__Value__c = mapProductToPartner.get(Productcode);
                                att.cscfga__Display_Value__c =mapProductToPartner.get(Productcode);

               }
                            when 'PartnerName' {
                        // if(accountPcMap.containsKey(mapProductToPartner.get(Productcode))) This is being checked initially
                                att.cscfga__Value__c = accountPcMap.get(mapProductToPartner.get(Productcode)).Name;
                                att.cscfga__Display_Value__c = accountPcMap.get(mapProductToPartner.get(Productcode)).Name;
                            }
                            when 'Channel' {
                                att.cscfga__Value__c = 'Indirect';
                                att.cscfga__Display_Value__c ='Indirect';
                            }
                            when 'Partner' {
                        // if(accountPcMap.containsKey(mapProductToPartner.get(Productcode))) This is being checked initially
                                att.cscfga__Value__c = accountPcMap.get(mapProductToPartner.get(Productcode)).id;
                                att.cscfga__Display_Value__c = accountPcMap.get(mapProductToPartner.get(Productcode)).Name;
                            }
                        }
            }

private static map<string,string> addOldpartnercode(map<string,string> OldPartnerCodeMap,cscfga__Attribute__c att,string ExtrId){

	 if(att.cscfga__Value__c!=null){
              OldPartnerCodeMap.put(ExtrId,att.cscfga__Value__c);
    }
		 
		 return OldPartnerCodeMap;
    }

									
    //EDGE-84585 : Identify and update the Opportunity Line item uisng Product code. Update Dealer Code value and Partner Name
        public static void updateOpportuntyLineItem(String opportunityId,Map<String,String> mapProductToPartner,Map<String,account> accountPcMap){
            Opportunity opp = [SELECT Id, name, Opportunity_Number__c FROM Opportunity WHERE Opportunity_Number__c =:opportunityId];
            System.debug('opp'+opp);
            System.debug('opp Id'+opp.Id);
            List<OpportunityLineItem> lineItem = new List<OpportunityLineItem>();
            //get line item details from opportunity id.
            //Team Hawaii - 08-28-2019 - Added Tagged_Partner__c, OpportunityId
            lineItem = [SELECT id, name, Product_Code__c, Product_Name__c, Dealer_Code__c, Partner_Info__c, cscfga__Attribute__c,Channel__c, Tagged_Partner__c, OpportunityId FROM OpportunityLineItem WHERE Opportunity.id = :opp.Id];
            System.debug('lineItem'+lineItem);

            /*
                 Map<String,account> accountPcMap= new map<String,account>();
                Id PartnerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
                List<Account> accList = new List<Account> ([SELECT id, Partner_Code__c, Name FROM Account WHERE Partner_Code__c in: mapProductToPartner.values() and Account_Status__c not in('New','Pending Activation','Inactive','Frozen') and IsPartner=true and Recordtypeid=:PartnerRecTypeId]);

                for(Account acc : accList){
                   accountPcMap.put(acc.Partner_Code__c,acc);
                   }
            */

        //loop through each line item to update
            Boolean isSamePartner = false; // Team Hawaii
            String partnerId;// Team Hawaii
         for(OpportunityLineItem li: lineItem){
            for(String Pvalue:mapProductToPartner.keyset()){
                if(li.Product_Code__c == Pvalue && accountPcMap.containsKey(mapProductToPartner.get(Pvalue))){
                    li.Dealer_Code__c = mapProductToPartner.get(Pvalue); //dealer code updated with partner code
                    li.Partner_Info__c = accountPcMap.get(mapProductToPartner.get(Pvalue)).Name; //partner info updated with account name
                        li.Tagged_Partner__c = accountPcMap.get(mapProductToPartner.get(Pvalue)).Id; // Team Hawaii populate the Partner Account id
                        li.Channel__c = 'Indirect'; // Team Hawaii
                        accountPrincipleContactMap.put(li.Tagged_Partner__c, accountPcMap.get(mapProductToPartner.get(Pvalue)).PartnerPrincipalContact__c);// Team Hawaii populate the Partner Account id
                    }
                }
                 System.debug('partnerId::'+partnerId + '::'+li.Tagged_Partner__c);
                // Team Hawaii - 08- 29-2019
                if(li.Tagged_Partner__c != null && (partnerId == null || partnerId == li.Tagged_Partner__c)){
                    isSamePartner = true;
                    partnerId = li.Tagged_Partner__c;

                }else{
                    isSamePartner = false;
                    partnerId = null;
                   }
                   }
             // Team Hawaii - 09-03-2019
             if(isSamePartner && partnerId != null){
                 oppAccountIdMap.put(opp.Id, partnerId);
             }else{
                 oppAccountIdMap.put(opp.Id, null);
                }
                update lineItem;
        }

    /*Below method Delete all child records older than an year
EDGE-85502 - Added by Saran
*/
    public static void cleanUp(){

        //list<Bulk_Load_Staging__c> cleanUpRec = [SELECT id,name FROM Bulk_Load_Staging__c WHERE Bulk_Load_Staging__c =null AND is_Summary_Record__c = TRUE AND CreatedDate = Label.PRM_cleanup_Time_period];

        String str= Label.PRM_LAST_N_TIMEPERIOD;
        String query='SELECT id,name FROM Bulk_Load_Staging__c WHERE Bulk_Load_Staging__c != null AND is_Summary_Record__c = FALSE AND CreatedDate > '+str;

        List<Bulk_Load_Staging__c> cleanUpRec = Database.Query(query);
        if(cleanUpRec.size() > 0)
            delete cleanUpRec;
    }

    /*Below method checks the batch apex job status
        EDGE-85502 - Added by Saran
    */
    Public static String checkjobStatus(){
        String jobStatus;
        /*The status of the job. Valid values are:
            Holding
            Queued
            Preparing
            Processing
            Aborted
            Completed
            Failed
        */
        List<AsyncApexJob> AsyncJobList = [SELECT Id,Status FROM AsyncApexJob WHERE ApexClassId IN
                                           (SELECT Id FROM ApexClass WHERE Name = 'BatchPRMPartnerTagging')
                                           AND Status in ( 'Queued','Preparing','Processing')];
        for(AsyncApexJob batchJob : AsyncJobList){
            jobStatus = batchJob.Status;
        }
        return jobStatus;
    }
 /*Below method will send status messages based on the batch job status
        EDGE-85502 - Added by Saran
 */
    @AuraEnabled
    public static string  init()
    {
        Response wrapper = new Response();
        Logger2 logger = Logger2.getLogger('PartnerBulkLoadUtil.init');
        try{//checks permission set and job status

            if(PhoenixGlobalUtil.validatePermission(PRMConstants.Partner_Tagging_Bulk_Util)){
                wrapper.hasBulkTagPermission=true;
                wrapper.status = checkJobStatus();

                switch on wrapper.status {
                    /*when 'Completed'{
                        wrapper.message = 'Bulk job has been completed successfully';
                    } */
                    when 'Queued'{
                        wrapper.message = Label.PRM_Bulk_job_IN_PROGRESS_message;
                    }
                   /* when 'Aborted'{
                        wrapper.message = 'Job was aborted by a user';
                    }*/
                    when 'Preparing'{
                        wrapper.message = Label.PRM_Bulk_job_IN_PROGRESS_message;
                    }
                    when 'Processing'{
                        wrapper.message = Label.PRM_Bulk_job_IN_PROGRESS_message;
                    }
                    /*when 'Failed'{
                        wrapper.message = 'Bulk job has been completed with errors';
                    }*/
                }//Switch Close
            }//if close
            else{
                wrapper.hasBulkTagPermission=false;
                wrapper.message = Label.PRM_Bulk_tag_Insufficient_permission_message;
            }
        }catch (Exception ex) {
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        } finally {
            logger.exitLogger();
        }
        return JSON.serialize(wrapper);
    }

/*Below method gets the field value of sObject record
EDGE-85502 - Added by Girish
*/
    public static String getFieldValue(sObject record, String field){
        String value= String.valueof(record.get(field));
        return !String.isBlank(value)
            ?value+STRING_DELIMETER_COMMA
            :''+STRING_DELIMETER_COMMA;
    }
/*Below method generates CSV file
EDGE-85502 - Added by Saran
*/
    public static void generateOutputCSV(String batchId){
        //declare all variables used within the method at top
        String CSVFileName = Label.PRM_Bulk_job_Output_CSVFile_name + Datetime.now().format('d/M/yyyy h:mm:ss a z') + '.csv';
        string csvColumnHeader = 'Opportunity ID, Product Code , Updated Partner Code, Submitted By,Previous Partner Code,Status,Remarks,Last Modified By,Last Modified Date';
        string csvFile;
        List<String> csvRowValues = new List<String>();
        csvRowValues.add(csvColumnHeader);
        String parentID;
        Logger2 logger = Logger2.getLogger('PartnerBulkLoadUtil.generateOutputCSV');
        try{  //Query all child records
            List<Bulk_Load_Staging__c> outputCSVList = [SELECT id,name,OpportunityID__c,Bulk_Load_Staging__c,Product_Code__c,Partner_Code__c,Submitter__c,Partner_Code_Old_Value__c,Status__c,Remarks__c,LastModifiedBy.Name,LastModifiedDate,ExternalId__c
                                                        FROM Bulk_Load_Staging__c
                                                        WHERE Bulk_Load_Staging__r.Batch_ID__c =: batchId
                                                       ];
            System.debug('batchId: ' +batchId);
            //if there are no child record to process, do not procced
            if(!outputCSVList.isEmpty()){

            for(Bulk_Load_Staging__c bulkLoadrec : outputCSVList){
                String rowStr=getFieldValue(bulkLoadrec,'OpportunityID__c');
                rowStr+=getFieldValue(bulkLoadrec,'Product_Code__c');
                rowStr+=getFieldValue(bulkLoadrec,'Partner_Code__c');
                rowStr+=getFieldValue(bulkLoadrec,'Submitter__c');
                rowStr+=getFieldValue(bulkLoadrec,'Partner_Code_Old_Value__c');
                rowStr+=getFieldValue(bulkLoadrec,'Status__c');
                rowStr+=getFieldValue(bulkLoadrec,'Remarks__c');
                rowStr+=bulkLoadrec.LastModifiedBy.Name+STRING_DELIMETER_COMMA;
                rowStr+=bulkLoadrec.LastModifiedDate.format('d/M/yyyy h:mm:ss a z');
                parentID = bulkLoadrec.Bulk_Load_Staging__c;
                //remove last comma if required
                rowStr=rowStr.removeEnd(STRING_DELIMETER_COMMA);
                csvRowValues.add(rowStr);
            }
            //generate and attach csv file to related list
            csvFile = String.join(csvRowValues,'\r\n');
            Attachment attachment = new Attachment();
            attachment.Body = Blob.valueOf(csvFile);
            attachment.Name = CSVFileName;
            attachment.ParentId = parentID ;
            insert attachment;
            }

        }catch (Exception ex) {
            //logger
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        } finally {
            logger.exitLogger();
        }
    }//generateOutputCSV close

/*Below method updates the Bulk Staging records status if the corresponding Opportunity id,Product basket missing
* EDGE-84585
*/
    public static void UpdateMissingbulkstageStatus(string BatchId,Map<String,Map<String,String>> mapBulkLoadData){
        Logger2 logger = Logger2.getLogger('PartnerBulkLoadUtil.UpdateMissingbulkstageStatus');
        Map<String,opportunity> OppMap= new map<string,opportunity>();
        set<string> MissingOppId= new set<string>();
        set<string> MissingBasketIds= new set<string>();
        set<string> MissingIds= new set<string>();
        set<string> oppids=mapBulkLoadData.keyset();

        try{
            for(opportunity opp:[SELECT id,name,Opportunity_Number__c,(SELECT id,Name FROM cscfga__Product_Baskets__r WHERE Primary_Basket__c=true) FROM opportunity WHERE Opportunity_Number__c in :oppids]){
                OppMap.put(opp.Opportunity_Number__c,opp);
            }
              //Missing ProductCode IDs, Opportuntiy IDs and Basket Id cases; with the Opportunity ID in the current execution
            for(string OppNumber:mapBulkLoadData.keyset()){
                map<string,string> ProductPartnerMap=mapBulkLoadData.get(OppNumber);
                if(!OppMap.containsKey(OppNumber))
                {
                    for(string ProductCode: ProductPartnerMap.keyset()){
                        string Externalid=batchid+''+OppNumber+''+ProductCode;
                        MissingOppId.add(Externalid);
                        MissingIds.add(Externalid);

                    }
                }
                else if(OppMap.containsKey(OppNumber))
                {
                    list<cscfga__Product_Basket__c> listproductbacket=new list<cscfga__Product_Basket__c> (); listproductbacket=OppMap.get(OppNumber).cscfga__Product_Baskets__r;

                    if(listproductbacket.size()==0)
                    {   for(string ProductCode: ProductPartnerMap.keyset()){
                        string Externalid=batchid+''+OppNumber+''+ProductCode;
                        MissingBasketIds.add(Externalid);
                        MissingIds.add(Externalid);
                    }
                    }
                }
            }

             integer ScccessCounts=0;
             integer failedCounts=0;
            list<Bulk_Load_Staging__c>  bslist=[SELECT id,Status__c,Remarks__c,ExternalId__c FROM Bulk_Load_Staging__c WHERE ExternalId__c in :MissingIds];
            for(Bulk_Load_Staging__c bs: bslist){
              //update success and failure counts
                if(MissingOppId.contains(bs.ExternalId__c)){
                    bs.Remarks__c=PRMConstants.BULK_TAGGING_MISSING_OPP_ID;
                    if( bs.Status__c!=PRMConstants.BULK_TAGGING_STATUS_FAILED)
                    {
                        bs.Status__c=PRMConstants.BULK_TAGGING_STATUS_FAILED;
                        failedCounts++;
                    }
                }
                else if(MissingBasketIds.contains(bs.ExternalId__c)){
                    bs.Remarks__c=PRMConstants.BULK_TAGGING_MISSING_PRODUCT_BASKET;
                    if( bs.Status__c!=PRMConstants.BULK_TAGGING_STATUS_FAILED)
                    {
                        bs.Status__c=PRMConstants.BULK_TAGGING_STATUS_FAILED;
                        failedCounts++;
                    }

                }
            }

            Update bslist;
            UpdateSummaryrecordStatus(ScccessCounts,failedCounts,batchid); //update summary records with details
        }
        catch (Exception ex) {
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        } finally {
            logger.exitLogger();
        }

    }

/*Below method updates the Bulk Staging record(Summary record) counts based on child records status
* EDGE-84585
*/
    public static void UpdateSummaryrecordStatus(integer ScccessRecCount,integer failureRecCount,string BatchId){
        Logger2 logger = Logger2.getLogger('PartnerBulkLoadUtil.UpdateSummaryrecordStatus');
        system.debug('inside UpdateSummaryrecordStatus'+BatchId);
        try{
         Bulk_Load_Staging__c  bulkstagingSummary= new Bulk_Load_Staging__c();
         //select the summary record from batch id
         bulkstagingSummary= [SELECT id,Status__c,Bulk_Load_Staging__c,Success__c,Failures__c,Batch_ID__c,Remarks__c,ExternalId__c FROM Bulk_Load_Staging__c WHERE Batch_ID__c =:BatchId limit 1];
        system.debug('bulkstagingSummary'+bulkstagingSummary);

        if(bulkstagingSummary!=null){
        //update success and failure details
                bulkstagingSummary.Success__c=String.valueof((bulkstagingSummary.Success__c!=null && Integer.valueOf(bulkstagingSummary.Success__c)>0)?(Integer.valueOf(bulkstagingSummary.Success__c)+ScccessRecCount):ScccessRecCount);
                bulkstagingSummary.Failures__c=String.valueof((bulkstagingSummary.Failures__c!=null && Integer.valueOf(bulkstagingSummary.Failures__c)>0)?(Integer.valueOf(bulkstagingSummary.Failures__c)+failureRecCount):failureRecCount);

                update bulkstagingSummary ;
                system.debug('bulkstagingSummary'+bulkstagingSummary +'BatchId'+BatchId);
            }
        }
        catch (Exception ex) {
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        } finally {
            logger.exitLogger();
        }

    }

    /*Below method updates the Bulk Staging record(Summary record) Final status from batch class
* EDGE-84585
*/
    public static void UpdateSummaryRecFinalStatus(string BatchId){
        Logger2 logger = Logger2.getLogger('PartnerBulkLoadUtil.UpdateSummaryrecordStatus');
        system.debug('inside UpdateSummaryrecordStatus'+BatchId);
        try{
           Bulk_Load_Staging__c  bulkstagingSummary= new Bulk_Load_Staging__c();
           bulkstagingSummary= [SELECT id,Status__c,Bulk_Load_Staging__c,Success__c,Total_Records__c,Failures__c,Batch_ID__c,Remarks__c,ExternalId__c FROM Bulk_Load_Staging__c WHERE Batch_ID__c =:BatchId limit 1];
           system.debug('bulkstagingSummary'+bulkstagingSummary);

        //update the final status after batch execution
            if( Integer.valueOf(bulkstagingSummary.Success__c) ==  Integer.valueOf(bulkstagingSummary.Total_Records__c))
                bulkstagingSummary.Status__c= PRMConstants.BULK_TAGGING_STATUS_COMPLETED;
            else
                bulkstagingSummary.Status__c=PRMConstants.BULK_TAGGING_STATUS_COMPLETED_WITH_ERRORS;

           update bulkstagingSummary;
        }
        catch (Exception ex) {
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        } finally {
            logger.exitLogger();
        }

    }

        /*Below method updates the Bulk Staging record(Summary record) status as Archived
* EDGE-84585
*/
    public static void UpdateOldRecStatusAsArchived(){
        Logger2 logger = Logger2.getLogger('PartnerBulkLoadUtil.UpdateOldRecStatusAsArchived');
        try{
        list<string> Statuses=Label.BulkTagging_CurrentJob_Statuses.split(',');

           list<Bulk_Load_Staging__c>  bulkstagingSummarylst= new list<Bulk_Load_Staging__c>();
           bulkstagingSummarylst= [SELECT id,Status__c,Bulk_Load_Staging__c,is_Summary_Record__c,Success__c,Total_Records__c,Failures__c,Batch_ID__c,Remarks__c,ExternalId__c FROM Bulk_Load_Staging__c WHERE Status__c in: Statuses and is_Summary_Record__c=true];

        system.debug('bulkstagingSummarylst'+bulkstagingSummarylst);
        for(Bulk_Load_Staging__c bs:bulkstagingSummarylst){
            bs.Status__c=PRMConstants.BULK_TAGGING_STATUS_ARCHIVED;
        }

        update bulkstagingSummarylst;
        }
        catch (Exception ex) {
            System.debug('The following exception occurred: ' + ex.getMessage());
            System.debug('The following exception occurred: ' + ex.getStackTraceString());
            logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
        } finally {
            logger.exitLogger();
        }

    }
    /* P2OB-2714 - Share and unshare the tagged partner opportunity
    * Team Hawaii 08-29-2019
    */

    public static void shareAndUnshareOpportunityToTaggedPartner(){
        Logger2 logger = Logger2.getLogger('PartnerBulkLoadUtil.shareAndUnshareOpportunityToTaggedPartner');
        Map<String, OpportunityShare> opportunityShareRecordsToDelete = new Map<String, OpportunityShare>();
        Map<Id, Id> accountPartnerPrincipleUserMap = new Map<Id,Id>();
        List<OpportunityShare> opportunityShareRecordsToInsert = new List<OpportunityShare>();
        System.debug('::oppAccountIdMap'+oppAccountIdMap);
        if(!oppAccountIdMap.isEmpty()){
            try{
                // get existing sharing records
                List<OpportunityShare> opptyShareRecords = [SELECT id, opportunityId, UserOrGroupId,userOrGroup.Profile.UserType FROM OpportunityShare WHERE opportunityId in : oppAccountIdMap.keySet() AND RowCause = : PRMConstants.SHARING_ROW_CAUSE_MANUAL  AND
                                                            userOrGroup.Type = 'User' AND userOrGroup.Profile.UserType = 'PowerPartner' AND OpportunityAccessLevel = : PRMConstants.SHARING_ACCESS_LEVEL_READ];
                for(OpportunityShare opptyShare : opptyShareRecords){
                    opportunityShareRecordsToDelete.put(opptyShare.opportunityId +'~'+opptyShare.UserOrGroupId,opptyShare);
                }
                System.debug('::accountPrincipleContactMap'+accountPrincipleContactMap);
                // get user of the partner Principle Contact
                for(User usr : [SELECT id, contactId,contact.AccountId, accountId FROM User WHERE contactId in : accountPrincipleContactMap.values()]){
                        accountPartnerPrincipleUserMap.put(usr.contact.AccountId ,usr.Id);
                }
                for(String oppId : oppAccountIdMap.keySet()){
                    Id accId = oppAccountIdMap.get(oppId);
                    System.debug('::accId '+accId );
                    if(accId  != null && accountPartnerPrincipleUserMap.containsKey(accId)){
                        Id userId = accountPartnerPrincipleUserMap.get(accId);
                        if(opportunityShareRecordsToDelete.containsKey(oppId +'~'+userId)){
                            opportunityShareRecordsToDelete.remove(oppId +'~'+userId);
                        }else{
                            opportunityShareRecordsToInsert.add(new OpportunityShare(opportunityId = oppId, UserOrGroupId = userId,
                                                                RowCause = PRMConstants.SHARING_ROW_CAUSE_MANUAL ,OpportunityAccessLevel = PRMConstants.SHARING_ACCESS_LEVEL_READ ));
                        }
                    }
                }
                if(!opportunityShareRecordsToDelete.isEmpty()){
                    delete opportunityShareRecordsToDelete.values();
                }
                if(!opportunityShareRecordsToInsert.isEmpty()){
                    insert opportunityShareRecordsToInsert;
                }
            }catch(Exception ex){
                System.debug('The following exception occurred: ' + ex.getMessage());
                System.debug('The following exception occurred: ' + ex.getStackTraceString());
                logger.logMessages('', '', ex.getStackTraceString(), 'Technical', 'Exception', ex.getMessage(), false, false);
            } finally {
                logger.exitLogger();
            }
        }
    }

    /*Method for updating Status of Bulk load*/
	public static void updatebulkloadStatus(    
                                    list<Bulk_Load_Staging__c> bslist,
                                    map<string,string> OldPartnerCodeMap,
                                    Set<String> missingProductCodeSet,
                                    Set<String> missingPartnercodesset,
                                    Set<String> UpdatedProductcodeset,
                                    string batchid)
        {   
            integer ScccessCounts=0;
             integer failedCounts=0;

         for(Bulk_Load_Staging__c bs: bslist){

            //For updating Old Partner Code in staging record
               if(OldPartnerCodeMap.containsKey(bs.ExternalId__c))
                  bs.Partner_Code_Old_Value__c=OldPartnerCodeMap.get(bs.ExternalId__c);

            //For Updating status in stage records based on their status captured above
                if(missingProductCodeSet.contains(bs.ExternalId__c)){
                    bs.Remarks__c=PRMConstants.BULK_TAGGING_MISSING_PRODUCT_CODE;
                    if(bs.Status__c!=PRMConstants.BULK_TAGGING_STATUS_FAILED){
                        bs.Status__c=PRMConstants.BULK_TAGGING_STATUS_FAILED;
                        failedCounts++;
                    }

                }
               else if(missingPartnercodesset.contains(bs.ExternalId__c)){
                    bs.Remarks__c=PRMConstants.BULK_TAGGING_MISSING_PARTNER_CODE;
                    if(bs.Status__c!=PRMConstants.BULK_TAGGING_STATUS_FAILED){
                    bs.Status__c=PRMConstants.BULK_TAGGING_STATUS_FAILED;
                                        failedCounts++;
                    }
                    }
               else if(UpdatedProductcodeset.contains(bs.ExternalId__c))
               {
                    bs.Remarks__c=PRMConstants.BULK_TAGGING_SUCCESSFULLY_COMPLETED;
                    if(bs.Status__c==PRMConstants.BULK_TAGGING_STATUS_FAILED){ //As we are chaning failed case to success reducing count in failure counts
                        failedCounts--;
                    }

                    bs.Status__c=PRMConstants.BULK_TAGGING_STATUS_COMPLETED;
                                        ScccessCounts++;

               }
            }
            
            Update bslist;
            UpdateSummaryrecordStatus(ScccessCounts,failedCounts,batchid); //update Bulk Staging record(Summary record) counts based on child records status            
        }

/*Method for getting account details based on PartnerCodes*/
public static map<String,account> getaccountPcMap(map<String,String> mapProductToPartner)
    {
        map<String,account> accountPcMap= new map<String,account>();
        
        // Team Hawaii - 08-29-2019 Added Partner Principle Contact 
        List<Account> accList = new List<Account> ([SELECT id, Partner_Code__c, Name, PartnerPrincipalContact__c FROM Account WHERE Partner_Code__c in: mapProductToPartner.values() and Account_Status__c not in('New','Pending Activation','Inactive','Frozen') and IsPartner=true and Recordtypeid=:PartnerRecTypeId ]);
           for(Account acc : accList){
               accountPcMap.put(acc.Partner_Code__c,acc);       
           
        }
        return accountPcMap;
    }

	/*Method for getting Product codes from Product Configuration based on Opportunity*/
    public static map<String,String> getProductCodeMap( map< Id,cscfga__Product_Configuration__c > prodConfigsLoadedbyDataHub)
    {
        map<string,string> ProductCodeMap= new map<string,string>();
        for (cscfga__Product_Configuration__c pc: prodConfigsLoadedbyDataHub.values()) {
            Set < String > setValidProductCode = new Set < String > ();
            for (cscfga__Attribute__c att: pc.cscfga__Attributes__r) {
                String attributeName = att.name;
                switch on attributeName {
                    when 'ProductCode' {
                        ProductCodeMap.put(pc.id,att.cscfga__Value__c);
                    }
                }
            }
        }
        return ProductCodeMap;
    }
	/*Method for filtering missing Product code cases*/
	public static set<string> getMissingProductCodes(Map<String,String> mapProductToPartner,set<String> ProductCodeSet,string batchId,string opportunityId)
	{
		set <string> missingProductCodeSet= new set<string>();
		for(string Pvalue:mapProductToPartner.keyset())
        {
            system.debug('Pvalue'+Pvalue);
            if(!ProductCodeSet.contains(Pvalue)){
						system.debug('Pvalue'+Pvalue);
                        String ExtrId=batchId+''+opportunityId+''+Pvalue;
                        missingProductCodeSet.add(ExtrId);
                        //allUpdatesStatusset.add(ExtrId);
                }
        }
		
		return missingProductCodeSet;
	}
	
   //to store status and message values to be displayed
    public class Response {
        Public string status;
        public string message;
        public boolean hasBulkTagPermission;
    }



}//PartnerBulkLoadUtil close