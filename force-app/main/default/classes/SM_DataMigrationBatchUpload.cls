/*************************************************************************************************************************************************************************************
 * Class Name   : SM_DataMigrationBatchUpload
 * Description  : Batch class to move the Solution JSON and OE JSON attachments from Salesforce to Heroku as part of Spring'20 release update.
                    Apex APIs cssmgnt.API_1.addSolutionToDatabase (BasketID,SolutionID) is used to migrate JSON attachment.
                    basketId – Parameter will accept the 15 character SFDC ID of the Product Basket.
                    solutionId - Parameter will accept the 18 character SFDC ID of the Solution.
 * Test Class   : SM_DataMigrationBatchUploadTest
  
    *** SolutionToBeMigratedList File Format ***
            SolutionId, MigratedToHeroku, Error Message (If Any)
            xxxxxxx111, False
            xxxxxxx112, True
            xxxxxxx113, False  
===================================================================================================================================================================================
Sr.No.  Developer Name          Date            Change Description
1.      Pooja P Bhat            14/07/2020      New - Batch class to move the Solution JSON and OE JSON attachments from Salesforce to Heroku as part of Spring'20 release update.
**************************************************************************************************************************************************************************************/
global class SM_DataMigrationBatchUpload implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    global Map<String,String> solnIdMigrFlagMap = new Map<String,String>();
    global Id documentId;
    global String documentName;
    
    global SM_DataMigrationBatchUpload(String docuName) {
        //Reading the CSV file SolutionToBeMigratedList stored in Document, to collect Solution Ids
        try {
            Document oDoc           =   [SELECT Id,Name,Body FROM Document WHERE Name =:docuName LIMIT 1];  System.debug('oDoc*** ' + oDoc);
            documentId              =   oDoc.Id;                                                    System.debug('documentId*** ' + documentId);
            documentName            =   oDoc.Name;                                                  System.debug('documentName*** ' + documentName);
            List<String> columns    =   oDoc.Body.toString().split('\n');                           System.debug('columns*** ' + columns);
            columns.remove(0); //Discarding the first row i.e Column Header from CSV file
            
            for(String oStr : columns) {
                System.debug('oStr***' + oStr);
                if(oStr.split(',').size() >= 2 && oStr.split(',')[1].trim().equalsIgnoreCase('FALSE')) {
                    solnIdMigrFlagMap.put(oStr.split(',')[0].trim(),oStr.split(',')[1].trim());
                }
            }
        } catch (Exception e) {
            System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() ); 
        }
    }

    global SM_DataMigrationBatchUpload(Set<Id> solnIds) {
        for(Id solutionId : solnIds) {
            solnIdMigrFlagMap.put(solutionId,'False'); 
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        //*Query to extract solutions to be migrated*// 
        System.debug('solnIdMigrFlagMap***' + solnIdMigrFlagMap.size() + ' ' + solnIdMigrFlagMap);
        Set<String> solnIdsSet  = new Set<String>(); 
        solnIdsSet.addAll(solnIdMigrFlagMap.keySet());
        String query = 'SELECT Id,cssdm__product_basket__c FROM csord__Solution__c WHERE Id IN: solnIdsSet';    System.debug('query***' + query);
        return Database.getQueryLocator(query); 
    }   //End of start()

    //*Loop the identified solutions and execute API to migrate Solutions and OE JSON to Heroku*// 
    global void execute(Database.BatchableContext BC, List<csord__Solution__c> solnList) { 
        String basketId; 
        if(!solnList.isEmpty()) {
            for(csord__Solution__c oSoln : solnList) {
                System.debug('Solution Id***'+oSoln.Id);
                try {
                    basketId                        =   String.valueOf(oSoln.cssdm__product_basket__c).subString(0,15); System.debug('basketId***'+basketId);
                    String result                   =   cssmgnt.Api_1.addSolutionToDatabase(basketId,oSoln.Id);         System.debug('result***'+result);
                    Map<String,Object> resultmap    =   (Map<String, Object>) JSON.deserializeUntyped(result);          System.debug('resultmap***'+resultmap);
                    solnIdMigrFlagMap.put(oSoln.Id, ( (resultmap.containsKey('data') && resultmap.get('data') == true) ? 'True' : ('False'  + ', Error: ' + resultmap)));
                } catch (Exception e)  {
                    solnIdMigrFlagMap.put(oSoln.Id,'FALSE' + ', Error: ' + e.getMessage() + 'LN:' + e.getLineNumber());
                    System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() ); 
                }
            }   //End of for(csord__Solution__c soln:solnList)
        }   //End of if(!solnList.isEmpty())
    }   //End of execute()

    //*Invoke another batch to update the field Migrated to Heroku = TRUE for solutions successfully migrated to Heroku*//
    global void finish(Database.BatchableContext BC) {
        try {
            String documentBody  =  'SolutionId,Migrated To Heroku,Error Message (if Any)';
            for(String str : solnIdMigrFlagMap.keySet()) {
                documentBody += '\n' + str + ',' + solnIdMigrFlagMap.get(str);
            }
            System.debug('Solution Update Status*** ' + documentBody);

            if(documentId!=null) {
                Document oDocu = new Document ( Id = documentId, Body = Blob.valueOf(documentBody), Type = 'csv', ContentType='application/vnd.ms-excel' );
                System.debug('Document before Update*** ' + documentBody);
                update oDocu;
                System.debug('Document after Status*** ' + documentBody);
            }

            Messaging.EmailFileAttachment attachFile = new Messaging.EmailFileAttachment();
            attachFile.setFileName((String.isNotBlank(documentName)?documentName+'.csv':'SolutionToBeMigratedList.csv'));
            attachFile.setBody(Blob.valueOf(documentBody));
            attachFile.setcontenttype('application/vnd.ms-excel');

            AsyncApexJob a = [SELECT Id,Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,TotalJobItems,CreatedBy.Email FROM AsyncApexJob WHERE Id=:BC.getJobId()];
            
            //To send Email Notification to the batch running user, about the Batch Job Status
            Messaging.SingleEmailMessage mail   =   new Messaging.SingleEmailMessage();
            String[] toAddresses                =   new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Solution & OE Data migration Batch Jobs completed with Status - ' + a.Status);
            mail.setPlainTextBody('Records processed ' + a.TotalJobItems +   'with '+ a.NumberOfErrors + ' failures. Please find the attachment for more details');
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachFile});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            System.debug('SM_DataMigrationBatchUpload Exception in finish method ' + e.getMessage() + 'LN:' + e.getLineNumber() );
        }
    }   //End of finish()
}   //End of class SM_DataMigrationBatchUpload