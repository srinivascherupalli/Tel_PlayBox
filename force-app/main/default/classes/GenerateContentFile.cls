/*
* This class is written for copying files to agreement records .
* Revisions : 
* RaviTeja 20/09/2019 :  EDGE-107935: Create Agreement Record for Multiple offers 

*/
public with sharing class GenerateContentFile {
    public static void generateContentFileRecord(Boolean doInsert, list<id> listSourceRecord) {
        map<String, Apttus__APTS_Agreement__c> agreementOnContactRecord = new map<String, Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c agreementRecord: [SELECT ID, NAME, Related_Service_Term__r.ServiceTermTemplateName__c,RecordTypeId, RecordType.DeveloperName FROM Apttus__APTS_Agreement__c WHERE Related_Contract__c IN: listSourceRecord]){
            agreementOnContactRecord.put(agreementRecord.Id, agreementRecord);
        }
        system.debug('*************> agmt '+agreementOnContactRecord);
        List<ContentDocumentLink> ContentDocumentLinkList = attachExistingFileToRecord(doInsert, listSourceRecord[0], agreementOnContactRecord);
    	system.debug('*************> link '+ContentDocumentLinkList);
         if (doInsert && ContentDocumentLinkList.size() > 0) {
        Insert ContentDocumentLinkList;
        }
    }
    
    public static list<ContentDocumentLink> attachExistingFileToRecord(Boolean doInsert, id CopyfromId, map<String, Apttus__APTS_Agreement__c> agreementOnContactRecord) {   
		
		//EDGE-107935: Create Agreement Record for Multiple offers
		Map<Id,Service_Term__c> ServiceTermMap= new Map<Id,Service_Term__c>([SELECT id,Name,ParentContract__c FROM Service_Term__c  WHERE ParentContract__c=:CopyfromId]);
		
	            List<ContentDocumentLink> ContentDocumentLinkListSigned = New list<ContentDocumentLink>();

        List<ContentDocumentLink> ContentDocumentLinkList = New list<ContentDocumentLink>();           
        for(ContentDocumentLink CDLink : [SELECT ID, ContentDocumentId,ContentDocument.Title, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink WHERE (LinkedEntityId =:CopyfromId OR LinkedEntityId in :ServiceTermMap.KeySet())]){
           // List<ContentDocumentLink> ContentDocumentLinkListSigned = New list<ContentDocumentLink>(); /*Moved outside loop*/
            If(CDLink.Id != NULL){
                system.debug('CDLink.ContentDocument.Title.contains:'+ CDLink.ContentDocument.Title);
                if((CDLink.ContentDocument.Title.contains('signed') == true || CDLink.ContentDocument.Title.contains('Signed') == true) && (CDLink.ContentDocument.Title.contains('paper') == true || CDLink.ContentDocument.Title.contains('Paper'))){               
                    system.debug('inside signed on paper');
                    for (Id key : agreementOnContactRecord.keySet()){   
                        if(agreementOnContactRecord.get(key).RecordType.DeveloperName == 'SA' || agreementOnContactRecord.get(key).RecordType.DeveloperName == 'Product_Key_Facts' || agreementOnContactRecord.get(key).RecordType.DeveloperName == 'General_Product_Terms'){
                    		ContentDocumentLink cdl1 = new ContentDocumentLink();
                            cdl1.ContentDocumentId = CDLink.ContentDocumentId;
                            cdl1.LinkedEntityId = agreementOnContactRecord.get(key).Id;
           					cdl1.ShareType = 'V';
                            ContentDocumentLinkListSigned.add(cdl1);
                        }
                    }
					/*Moved outside the loop*/
                    //if (doInsert && ContentDocumentLinkListSigned.size() > 0) {
        			//Insert ContentDocumentLinkListSigned;
        			//}                   
                }
                System.debug('Content:'+CDLink.ContentDocument.Title);
                ContentDocumentLink cdl = new ContentDocumentLink();
                for (Id key : agreementOnContactRecord.keySet()) {
					if(agreementOnContactRecord.get(key).RecordType.DeveloperName == 'SA' && CDLink.ContentDocument.Title.contains('BSA') == true){
                        cdl.ContentDocumentId = CDLink.ContentDocumentId;
                        cdl.LinkedEntityId = agreementOnContactRecord.get(key).Id;   
                    }
                    else if(agreementOnContactRecord.get(key).RecordType.DeveloperName == 'SA' && CDLink.ContentDocument.Title.contains('Certificate') == true){
                        cdl.ContentDocumentId = CDLink.ContentDocumentId;
                        cdl.LinkedEntityId = agreementOnContactRecord.get(key).Id;   
                    }
                    else if(agreementOnContactRecord.get(key).RecordType.DeveloperName == 'Product_Key_Facts' && (CDLink.ContentDocument.Title.contains('Offer') == true || CDLink.ContentDocument.Title.contains('Service') == true ) && CDLink.ContentDocument.Title.contains('Terms') == true && CDLink.ContentDocument.Title.contains('General') == false){
                        //EDGE-107935-Create Agreement Record for Multiple offers
						//Mapping the files to corresponding agreement record based on the file name and Agreement Name(Service Term Name)
                       
					   system.debug('CDLink.ContentDocument.Title'+CDLink.ContentDocument.Title);					   
                       system.debug('CDLink.ContentDocument.Title'+agreementOnContactRecord.get(key).Related_Service_Term__r.ServiceTermTemplateName__c);
					   if(agreementOnContactRecord.get(key).Related_Service_Term__r.ServiceTermTemplateName__c!=null && CDLink.ContentDocument.Title.contains(agreementOnContactRecord.get(key).Related_Service_Term__r.ServiceTermTemplateName__c)){
							cdl.ContentDocumentId = CDLink.ContentDocumentId;
							cdl.LinkedEntityId = agreementOnContactRecord.get(key).Id; 
						}						
                    }
                    else if(agreementOnContactRecord.get(key).RecordType.DeveloperName == 'General_Product_Terms' && CDLink.ContentDocument.Title.contains('General') == true && CDLink.ContentDocument.Title.contains('Service') == true && CDLink.ContentDocument.Title.contains('Terms') == true){
                        cdl.ContentDocumentId = CDLink.ContentDocumentId;
                        cdl.LinkedEntityId = agreementOnContactRecord.get(key).Id;   
                    }
                }
                system.debug('****cdl'+ cdl);
                cdl.ShareType = 'V';
                if(cdl.ContentDocumentId != NULL)
                ContentDocumentLinkList.add(cdl);
            }  
        }
		
		
		if (doInsert && ContentDocumentLinkListSigned.size() > 0) {
        			Insert ContentDocumentLinkListSigned;
        			}
        return ContentDocumentLinkList;
    }
}