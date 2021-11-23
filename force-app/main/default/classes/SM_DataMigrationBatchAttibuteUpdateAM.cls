/*
 * Created By: Payal
 * Usage : Used to update PC attributes in Heruko
 * Test Class: SM_DataMigrationBatchAttUpdateAMTest
 */
 global class SM_DataMigrationBatchAttibuteUpdateAM implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    Map<String,String> attrDetails = new Map<String,String>();
	String whereClause = '';
    global List<Id> solList = new List<Id>();
    global Map<String,String> solnIdResponseMap = new Map<String,String>();

    global SM_DataMigrationBatchAttibuteUpdateAM(String solutionName, Map<String,String> attrDetails,string whereClause){
        this.attrDetails = attrDetails;
		this.whereClause = whereClause;
        solutionName = '%'+solutionName+'%';
        for(csord__Solution__c sol: [SELECT Id, cssdm__product_basket__c, cssdm__product_basket__r.csordtelcoa__Basket_Stage__c FROM csord__Solution__c 
        WHERE cssdm__product_basket__r.csordtelcoa__Basket_Stage__c NOT IN ('Cancelled', 'Contract Rejected', 'Draft') AND Name Like: solutionName]){
            solList.add(sol.Id);
        }
    }
    global SM_DataMigrationBatchAttibuteUpdateAM(List<Id> solutionIds){
        solList.addAll(solutionIds);
    }
	global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'Select Id, Name, cssdm__solution_association__c, cscfga__product_definition__r.name, (Select Id, Name, cscfga__value__c from cscfga__Attributes__r WHERE Name IN (\'GUID\')) from cscfga__product_configuration__c' 
            +' WHERE cssdm__solution_association__c IN: solList';    //cscfga__product_definition__r.product_Specification__c IN (\'DMCAT_Offer_001233\', \'DMCAT_ProductSpecification_001196\')
        if(String.isNotBlank(whereClause)){
            query = query + ' AND ' + whereClause;
        }else{
            query = query + ' Limit 0';
        }
        System.debug('query***' + query);
        return Database.getQueryLocator(query); 
    }   //End of start() 
    
    //*Loop the identified solutions and execute API to migrate Solutions and OE JSON to Heroku*// 
    global void execute(Database.BatchableContext BC, List<cscfga__product_configuration__c> pcList) { 
		Map<String, String> pcToGUID = new Map<String, String>();
        system.debug('pcList '+pcList);
		for(cscfga__product_configuration__c pc: pcList){

            List<cscfga__Attribute__c> attList = pc.cscfga__Attributes__r;
            String guid = '';
            for(cscfga__Attribute__c att: attList){
                if(att.Name=='GUID' && att.cscfga__value__c!=null){
                    guid = att.cscfga__value__c;
                }
            }
			pcToGUID.put(pc.Id, guid);
		}
		for(cscfga__product_configuration__c pc: pcList) { 
            cssmgnt.API_1 api = new cssmgnt.API_1();
            String response = '';
            try {
                if (!Test.isRunningTest()) {
                    response = api.updateConfigurations(pc.cssdm__solution_association__c, new Map<String, Map<String, String>>{pcToGUID.get(pc.Id) => attrDetails });
                }
				system.debug('response '+response);
                String result = (response.contains('"') ? response.replaceAll('"', '') : response);
                solnIdResponseMap.put(pc.Id, pc.cssdm__solution_association__c + ',"' + result + '"');
				system.debug('solnIdResponseMap '+solnIdResponseMap);
            } catch(Exception e)  {
                solnIdResponseMap.put(pc.Id, pc.cssdm__solution_association__c + ', Error: ' + e.getMessage() + ' LN: ' + e.getLineNumber());
            } 
            
        }  //End of if(!solnList.isEmpty())
    }
    
    //*Invoke another batch to update the field Migrated to Heroku = TRUE for solutions successfully migrated to Heroku*//
    global void finish(Database.BatchableContext BC) {
        try {
            system.debug('solnIdResponseMap '+solnIdResponseMap);
            String documentBody  =  'ProductConfigurationId,SolutionId,Response'; 
            List<Folder> folders = [SELECT Id from Folder WHERE DeveloperName='CS_SolutionUpgrade' LIMIT 1];
            for(String str : solnIdResponseMap.keySet()) {
                documentBody += '\n' + str + ',' + solnIdResponseMap.get(str);
            }
            Document oDocument = new Document (FolderId=folders[0].Id, Name='SM_DataMigrationAttributeUpdateAM', Body = Blob.valueOf(documentBody), Type = 'csv', ContentType='application/vnd.ms-excel' );
            insert oDocument; 
        } catch (Exception e) {
            System.debug('SM_DataMigrationBatchAttributeUpdateTC Exception in finish method ' + e.getMessage() + 'LN:' + e.getLineNumber() );
        }
    }   //End of finish()
}