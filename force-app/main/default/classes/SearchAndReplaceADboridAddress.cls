global with sharing class SearchAndReplaceADboridAddress implements Database.Batchable<sObject>, Database.AllowsCallouts{ 
    global final String Query; 
    global Integer recordsProcessed = 1;
    
    global SearchAndReplaceADboridAddress(String q){ 
        query=q;
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext BC, List<cscrm__Address__c> address){ 
        try{
         	for(cscrm__Address__c add : address){	
                AddressRequestDTO addressRequestDTO = new AddressRequestDTO();
                addressRequestDTO.data = new AddressRequestDTO.Data();
                System.debug('Adborid for the record '+recordsProcessed+ add.Address_ID__c);
                addressRequestDTO.data.adborId = add.Address_ID__c;
                AddressResponseDTO addressResponseObj = AddressValidateService.searchAddressByAdborId(addressRequestDTO);
                AddressAndSiteObjectUtility.upsertNBNEastAddress(addressResponseObj);
                recordsProcessed = recordsProcessed + 1 ;
                System.debug(recordsProcessed + ' records processed successfully!');
        	}    
        }catch(Exception e){
            Logger.getLogger(SearchAndReplaceADboridAddress.class).debug(e);
            Logger.exitLogger();
            System.debug(e.getMessage());
        }
    } 
    
    global void finish(Database.BatchableContext BC){ 
        System.debug(recordsProcessed + ' records processed successfully!');
    } 
}