/*****************************************************************************
@Author: Shamikh Hassan
@CreateDate: 22/12/2018
@ModifiedByandDate: 19/03/2019
@Description: This class is to assign the case to one of the Queues
*******************************************************************************/
public without sharing class soc_AssignToAllQueue {
    
     /**
    * This method returns the child case record for the provided child record Id.
    * @Author: Pravin Sonawane
    * @Date: 9-APR-2019
    */
    @AuraEnabled
    public static Map<String,Object> initialize(String caseId){ 
        System.debug('Enter in soc_AssignToAllQueue');
        Map<String,Object> results=new Map<String,Object>();
        List<Case> caseList= [SELECT id,subject,Stage__c,
                              Status,OwnerId,requestor__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName,soc_SFD_Offshore_Restricted__c
                              FROM case where id =:caseId limit 1];

                String name=[select Name from profile where id = :userinfo.getProfileId()].Name;
        //caseList = soc_ParentCaseOwnerService.updateCaseOwnerType(caseList);
        results.put('case',caseList[0]);
        results.put('profileName',name);
        return results;                
    }
        
     /**
    * This method assigns the passed queue name for the provided child record Id.
    * @Author: Shamikh Hassan
    * @Date: 22-DEC-2018
    */
    @AuraEnabled
    public static Map<String,Object> assignCase(String caseId,String queueDeveloperName){            
                       
        Map<String,Object> results=new Map<String,Object>();          
        results.put('status','fail');       
        try{  
            String queueId =[select Id from Group where  Type = 'Queue' AND DeveloperNAME =: queueDeveloperName].id; 
            list<Case> caseList = [SELECT id,subject,caseNumber,ownerId FROM case where id =: caseId limit 1];
            if(caseList.size()==1){
                Case cas=caseList[0];
                cas.ownerId=queueId;
                upsert cas;
                results.put('status','pass');
                results.put('response',cas);
            }
           
        }
        catch(Exception e){
            results.put('status','fail');
            results.put('response',e.getMessage());            
        }    
        return results;        
    }  
    
    /**
    * This method create the replica of Child case record and checks the case Line Items record count.
    * @Author: Pravin Sonawane
    * @Date: 9-APR-2019
    */
    @AuraEnabled
    public static Map<String,Object> fetchClonedCase(String Id){
        Map<String,Object> results = new Map<String,Object>();
        system.debug('ParentId='+Id);
        Case parentCase = [SELECT Id,caseNumber,opportunityId__c,Subject,Status,
                           RecordTypeId,Stage__c,Primary_Domain__c,OwnerId,CIDN__c,soc_Domain__c,
                           srvsup_Parent_CIDN__c,srvsup_Ultimate_CIDN__c,Requestor__c,
                           AccountId,ContactId,Description,RecordType.Name,ParentId,
                           soc_Billing_Account_Number__c,MDN_Network_FNN__c,Network_FNN__c,
                           soc_FNNs__c,soc_Number_of_Sites__c,soc_SFD_Offshore_Restricted__c,
                           soc_Product__c,soc_Additional_Technical_Contact__c,soc_Additional_Technical_Contact_Email__c,
                           soc_Additional_Technical_Contact_Phone__c
                           FROM Case where id = :Id];
        
        Case clonedCase= parentCase.clone(false, false, false, false);
        clonedCase.Subject = 'Clone Of - '+ parentCase.Subject;
        
        system.debug('subject='+clonedCase.Subject);
        //Pravin S :: EDGE-68187 :: 19-MAR-2018
        List<soc_Case_Line_Item__c> lstCaseLineItems = soc_ManageProductController.getCaseLineItems(Id);
        if(lstCaseLineItems.size() == 1){
            results.put('cliSizeOne',true);
            results.put('caseLineItems',lstCaseLineItems);
        }
        else
            results.put('cliSizeOne',false);        
        
        results.put('case',clonedCase);
        system.debug('results='+results);
        return results;   
        
    }
    
}