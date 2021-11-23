/*
* @Author :  Srujana Durvasula
* @Date   :  12 Jan 2021
* @Desc   :  <Cloudsense> <Proposal Builder> Proposal Word document generation
* @Jira   :  P2OB-11268 
*/

public class GenerateProposalHelper  {



//public with sharing class GenerateProposalHelper {

@InvocableMethod
public static List<Opportunity> createProposal(List<FlowInputs> listOfFlowInput){      
    /*Step 1: get opportunity Id*/
    String basketOpptyId;
    String syncMsg = '';
    string basketName;
    string templateName;
    string proposalName;
    String templateId;
    String productBasketId;
    Set<Id> setOfBasketId = new Set<Id>();
    Set<String> setOfTemplateName = new Set<String>();
    String currentUserId = UserInfo.getUserId();
    
    for(FlowInputs obj : listOfFlowInput) {
        setOfBasketId.add(obj.basketId);
        setOfTemplateName.add(obj.templateName);
    }
    List < cscfga__Product_Basket__c > updatedBskts = [Select id,cscfga__Opportunity__c, Name from cscfga__Product_Basket__c where Id IN: setOfBasketId];
    
    for (cscfga__Product_Basket__c bas : updatedBskts) {  
        basketOpptyId = bas.cscfga__Opportunity__c;
        basketName = bas.Name;
        productBasketId = bas.Id;
    }
    
    List < APXTConga4__Conga_Template__c > updatedTemp = [Select id,APXTConga4__Name__c, Name from APXTConga4__Conga_Template__c where APXTConga4__Name__c IN: setOfTemplateName];
    for (APXTConga4__Conga_Template__c temp : updatedTemp) {  
        templateId = temp.Id;
        templateName = temp.APXTConga4__Name__c;
        System.debug('templateName' + templateName);
    }
    proposalName = templateName + '-' + basketName;

    system.debug('basketOpptyId---'+basketOpptyId);
    /*Step 2: Create Conga URL*/
    String congaUrl= '&Id=';
    congaUrl=congaUrl+ basketOpptyId +'&TemplateId='+templateId+'&FP0=0'+'&QMode=Attachments';        


    //Changes Strart related to 13187
        String queryParams='&QueryId=';
        String delimiter=',';        
        String queryCongaStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Proposal_Query__mdt')) + '\n ' +

            ' FROM Proposal_Query__mdt \n ';
        List<Proposal_Query__mdt> congaQueryNamesList = Database.query(queryCongaStr); 
        if(congaQueryNamesList == null || congaQueryNamesList.isEmpty() || templateId == null){

            System.debug('No conga template settings found.');
            return null;
        } 
        List<String> nameOfTemplates = congaQueryNamesList.get(0).QueryNames__c.split(delimiter); 
        Map<String,String> mapOfTemplates = CustomButtonOpportunitySync.getTemplateId(nameOfTemplates,'query');
        System.debug('name of queries:'+nameOfTemplates);
        
        System.debug('name of productBasketID:'+productBasketID);
        System.debug('name of congaQueryNamesList:'+congaQueryNamesList.get(0).Basket_Filter_value__c);
        for(String nameOfTemplate :nameOfTemplates){
            System.debug('name of mapOfTemplates:'+mapOfTemplates.get(nameOfTemplate));
            System.debug('name of nameOfTemplate:'+nameOfTemplate);
           if(nameOfTemplate.contains('OpptyTeamMembers') ){  //added related to DIGI-7032 OpportunityTeamMember Details
               queryParams += '['+nameOfTemplate+']'+mapOfTemplates.get(nameOfTemplate)+'?'+congaQueryNamesList.get(0).Basket_Filter_value__c+'='+basketOpptyId+',';
            }else{
            queryParams += '['+nameOfTemplate+']'+mapOfTemplates.get(nameOfTemplate)+'?'+congaQueryNamesList.get(0).Basket_Filter_value__c+'='+productBasketID+',';  
           }       
        }
        System.debug('namequeryParams:'+queryParams);
        queryParams=queryParams.substringBeforeLast(delimiter);
        System.debug('AfterdelimiterParams:'+queryParams);

        congaUrl=congaUrl+queryParams+ '&OFN=' + proposalName + '&APF=1';
   
     //Changes End related to 13187
    List<Opportunity> listOfOpportunityToUpdate = new List<Opportunity>();
    /*Step 3: Update CongaStatus and CongaURL*/
    for(Opportunity oppty : [Select Id,Conga_URL__c,Conga_Status__c, Proposal_Requested_User__c,SharePoint_Sync__c  from Opportunity where Id =:basketOpptyId]){
        oppty.Conga_URL__c = congaUrl;
        oppty.Conga_Status__c = 'InProgress';
        oppty.Proposal_Requested_User__c = currentUserId;
        oppty.SharePoint_Sync__c = 'InProgress';
        listOfOpportunityToUpdate.add(oppty);
    }
    
    if(!listOfOpportunityToUpdate.isEmpty()) {
        update listOfOpportunityToUpdate;
    }
    /*Redirect to Opportunity

    cscfga__Product_Basket__c productBasket = [Select id,cscfga__Opportunity__c from cscfga__Product_Basket__c where Id =: productBasketID];
    String oppRedirectURL   =   '';
    if(productBasket.cscfga__Opportunity__c!=null) {
        Opportunity opp     =   new Opportunity(Id=productBasket.cscfga__Opportunity__c);   
        oppRedirectURL      =   new ApexPages.StandardController(opp).view().getURL();
    }

    syncMsg = '{"status":"ok","text":"Proposal Request submitted successfully","redirectURL":"' + oppRedirectURL + '"}';
    return syncMsg;*/
    return listOfOpportunityToUpdate;
}

 public class FlowInputs {         
    @InvocableVariable public Id basketId;         
    @InvocableVariable public String templateName;     

}
}