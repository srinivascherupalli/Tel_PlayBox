/****************************************************************************
@Name: serviceTermAttachmentPRM.
@Author: Abinas Panda.
@CreateDate: 08/08/2019.
@Description: This is a helper class for ContentDocumentLink object trigger for Updating the file location of service Terms
EDGE-88882
// EDGE-119211  - To fix ApexSharingViolations issue, added without sharing as discussed with Orlando Team.
// The existing functionality is to delete files from Contract & assign under service term.
// EDGE-141830 - Added fix for deleting service term from contract junction
********************************************************************************/
public with sharing class serviceTermAttachmentPRM {
    public static boolean checkRecur = false;
    public static void attchSTAssign(list<ContentDocumentLink> newListTrig){
        system.debug('inside attchSTAssign');
        //boolean checkRecur = true;
         // tmpSet
        Set<string> setServiceTermsTemplate = new Set<string>();//to Store the Serviceterm templete
        Set<string> cntIdSet = new Set<string>();
        Set<string> cntdocIdSet = new Set<string>();
        set<string> offNameSet = new set<string>();
        List<ContentDocumentLink> newList = new List<ContentDocumentLink>();
        List<ContentDocument> lstcdUpd = new List<ContentDocument>();
        //right naming conventions
        // List<ContentDocumentLink> newListCl = new List<ContentDocumentLink>();
        List<ContentDocumentLink> listSTFilesContract = new List<ContentDocumentLink>();
        List<ContentDocumentLink> ignore = new List<ContentDocumentLink>();
        List<ContentDocumentLink> toDelCntDocList = new List<ContentDocumentLink>();
        List<ContentDocumentLink> listNewST = new List<ContentDocumentLink>();
        List<ContentDocumentLink> listupdateST = new List<ContentDocumentLink>();
        map<string,ContentDocumentLink> LinkdEtyIdCntDocMap = new map<string,ContentDocumentLink>();
        map<string,string> conIdStrmIdMap = new map<string,string>();
        // map<string,List<Service_Term__c>> conIdStrmIdMap = new map<string,List<Service_Term__c>>();
        map<ContentDocumentLink,string> clonedDocLinkdIdMap = new map<ContentDocumentLink,string>();
        map<ContentDocumentLink,string> toInsertDocLinkdIdMap = new map<ContentDocumentLink,string>();
        map<string,ContentDocumentLink> contDocIDMap = new map<string,ContentDocumentLink>();
        Set<String> setLinkedEntityIDs = new Set<String>();
        if(!checkRecur) {
            try{
                //find all service term templates
                for(APXTConga4__Conga_Template__c tmp :[SELECT id,APXTConga4__Name__c,Offer_Name__c,Type__c,Sequence__c,Active_Template_Version__r.Version__c
                                                        FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Template_Group__c ='Contract' AND Type__c LIKE '%Service Terms%' ]) {
                                                            setServiceTermsTemplate.add(tmp.APXTConga4__Name__c);
                                                        }
                //Set<String> setLinkedEntityIDs = new Set<String>();
                //Girish P: if title matches with the name mark them for deletion and for new content document link
                for(ContentDocumentLink eachCDL:newListTrig) {
                    Id contractId = eachCDL.linkedentityid;
                    String sObjName = contractId.getSObjectType().getDescribe().getName();
                    system.debug('sObjName--'+sObjName);
                   // if(!(((String)(eachCDL.linkedentityid)).substring(0,2)=='a7'))
                    if(!(sObjName == 'ContractJunction__c'))
                        continue;
                    setLinkedEntityIDs.add(eachCDL.linkedentityid);
                }
                system.debug('setLinkedEntityIDs--'+setLinkedEntityIDs);
                if(!setLinkedEntityIDs.isEmpty()){
                    for(ContentDocumentLink eachCDL :[SELECT ContentDocumentId,Id,LinkedEntityId,contentDocument.Title,ShareType,visibility,ContentDocument.fileType
                                                      FROM ContentDocumentLink
                                                      WHERE linkedentityid in: setLinkedEntityIDs]) {
                                                          //ignore if any other document other than ST
                                                          String documentName= eachCDL.ContentDocument.Title.split(' - a')[0];
                                                          if(setServiceTermsTemplate.contains(documentName)) {
                                                          // && eachCDL.ContentDocument.fileType == 'WORD_X'
                                                              LinkdEtyIdCntDocMap.put(eachCDL.LinkedEntityId,eachCDL);
                                                              listSTFilesContract.add(eachCDL);
                                                              listNewST.add(eachCDL.clone());
                                                          }
                                                      }
                }
                //proceed only if contract document are inserted
                if(!listSTFilesContract.isEmpty()) {
                    //String offername;//EDGE-119211 - Var to store offername
                    //listNewST = listSTFilesContract.clone(true,true,false,false);
                    //delete ST files under contract
                    //delete listSTFilesContract;
                    Map<Id,String> offerNameMap = new Map<Id,String>();// EDGE-141830 - defect fix
                    List<Service_Term__c> lstServiceTerm = new List<Service_Term__c>();
                    lstServiceTerm = [SELECT id,Name,ParentContract__c,ServiceTermName__c,ServiceTermTemplateName__c ,Status__c,isStatusChange__c,Related_Contract__c
                                             from Service_Term__c where ParentContract__c IN :LinkdEtyIdCntDocMap.keyset()];
                    for(Service_Term__c st :lstServiceTerm) 
                    {
                                                 conIdStrmIdMap.put(st.ParentContract__c+st.ServiceTermTemplateName__c,st.id);
                        //offername = st.ServiceTermName__c;////EDGE-119211 - get offername
                        offerNameMap.put(st.Id,st.ServiceTermName__c);// EDGE-141830 - defect fix
                                             }
                    system.debug('conIdStrmIdMap--'+conIdStrmIdMap);
                    if(!conIdStrmIdMap.isEmpty()) {
                        boolean  proceed = false;
                        system.debug('listNewST--'+listNewST);
                        for(ContentDocumentLink eachCDLNew: listNewST) {
                            string keyName = eachCDLNew.linkedentityid+eachCDLNew.ContentDocument.Title.split(' - a')[0];
                            system.debug('keyName--'+keyName);
                            system.debug('cd and linkdEty--'+eachCDLNew.ContentDocumentId+'-'+eachCDLNew.linkedentityid);
                            if((eachCDLNew.LinkedEntityId != conIdStrmIdMap.get(keyName)) && ((((String)(eachCDLNew.linkedentityid)).substring(0,2)=='a7'))){
                                eachCDLNew.LinkedEntityId = conIdStrmIdMap.get(keyName);
                                eachCDLNew.ShareType = 'V';
                                eachCDLNew.Visibility = 'AllUsers';
                               /* try{
                                    insert eachCDLNew;
                                }
                                catch(Exception e) {
                                    system.debug('exception insert method inside serviceTermAttachmtPrm: '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());
                                }*/
                                //proceed = true;
                                system.debug('inside insert loop'+keyName  +'-'+conIdStrmIdMap.get(keyName));
                            }
                        }
                        system.debug('listNewSTafter--'+listNewST);
                        system.debug('listSTFilesContract--'+listSTFilesContract);
                           // delete listSTFilesContract;
                            Database.insert(listNewST,false) ;
                        system.debug('listNewSTsss--'+listNewST);
                        Set<String> offerNmaes = new set<String>();
                        //EDGE-119211 - update service term document name
                        for(ContentDocumentLink cdl:listNewST)
                        {
                            ContentDocument cd = new ContentDocument();
                            cd.id = cdl.ContentDocumentId;
                            cd.Title = 'Service Term - '+offerNameMap.get(cdl.LinkedEntityId);
                            lstcdUpd.add(cd);
                        }
                        //EDGE-119211 - End
                        boolean toCDLExists ;
                        if(!lstcdUpd.isEmpty()){
                        database.update(lstcdUpd); 
                        toCDLExists = true;
                        }
                        // EDGE-141830 - defect fix
                        List<ContentDocumentLink> lstCDLdel= new List<ContentDocumentLink>();
                        if(toCDLExists=true){
                            //INC000092543961 fix - change in query filter criteria
                            for(ContentDocumentLink cdlinkOLD:[SELECT ContentDocumentId,Id,LinkedEntityId,contentDocument.Title FROM ContentDocumentLink
                                                          WHERE linkedentityid in:setLinkedEntityIDs AND contentDocument.Title LIKE 'Service Term -%']){
                                lstCDLdel.add(cdlinkOLD);
                            }
                        }
                        if(!lstCDLdel.isEmpty() && lstCDLdel!=null){
                        	delete lstCDLdel;
                        }
                        // EDGE-141830 - defect fix end
                    }                   
                }
            }
            catch(Exception e) {
                system.debug('exception in class serviceTermAttachmtPrm: '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());
                //throw e;
            }
        }
    }
}