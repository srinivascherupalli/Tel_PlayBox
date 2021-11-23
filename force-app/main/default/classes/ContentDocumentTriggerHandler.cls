/*****************************************************************************
@Name : ContentDocumentTriggerHandler
@Description : This Class is Helper for ContentDocument Trigger 
@Modified by : Vamshi (Napier Team) as part of EDGE-135560. 
@Description : Added single line to call ContentDocumentLinkTriggerHandler.attachmentCountUpdate method
*******************************************************************************/

public  without sharing class ContentDocumentTriggerHandler {
    
    static List<id> contractId = new list<id>(); 
    @testvisible private ContentDocumentTriggerHandler(){}
    public static void GetContentDocumentLink(list<ContentDocument> newList) { 
        Set<ID> contentDocumentIds = new Set<ID>();
        
        for ( ContentDocument cd : newList ) {
            contentDocumentIds.add( cd.id );
        }
        
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>([
            SELECT
            id,
            contentDocumentId,  // document being shared
            linkedEntityId,     // who/what the file is shared to
            shareType           // view, edit, owner access to file
            FROM
            ContentDocumentLink
            WHERE
            contentDocumentId IN :contentDocumentIds 
        ]); 
        
        ContentDocumentLinkTriggerHandler.modifiedDateUpdate(cdls, 'Attachcountdelete');
        //Below line added by Vamshi (Napier Team) as part of EDGE-135560. 
        ContentDocumentLinkTriggerHandler.attachmentCountUpdate(cdls,'Attachcountdelete');
        System.debug( 'cdls ->'+cdls );
        
        // Added as part of EDGE-37402
        
        for(ContentDocumentLink nt : cdls){            
            // pId stores the object code related to contentdocumentLink
            String sObjName = nt.linkedentityid.getSObjectType().getDescribe().getName();
            system.debug('************>sObjName ='+sObjName);
            if(sObjName == 'ContractJunction__c'){ // checking whether the record is ContractJunction__c or not
                contractId.add(nt.linkedentityid);
            }    
            
        }
    }
    
    public static void ContentDocumentLinkContractInvoke(list<ContentDocument> newList) { 
        
        ContentDocumentLinkContract.countFilesAttachedToContract(contractId);
        
    }
}