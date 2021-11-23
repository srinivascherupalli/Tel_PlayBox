public class ProductBasketChatterCls {
    @InvocableMethod
    public static void sendChattertoCE(list<Id> recId){
        Network n = [SELECT Id, Name FROM network WHERE Name = 'EDGE Partners'];
        String Networkid=Network.getnetworkid();
        cscfga__Product_Basket__c pb = [SELECT id, Name,cscfga__Opportunity__r.AccountId,cscfga__Opportunity__r.ownerId, csordtelcoa__Basket_Stage__c,csbb__Account__c,cscfga__Opportunity__r.Partner_Account__c from cscfga__Product_Basket__c WHERE Id =: recId];
        list<string> dominSet = new list<string>();
        list<cscfga__Product_Configuration__c> config = [select id,OfferName__c,Name,Marketable_Offer__r.Product_Category__r.Product_Family_Level_1__c,ConfigurationType1__c,Type__c,Marketable_Offer__r.Name from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:pb.id];
        for(cscfga__Product_Configuration__c prodConfig: config){
            dominSet.add(prodConfig.Marketable_Offer__r.Product_Category__r.Product_Family_Level_1__c);
        }
        list<Partner_of_Record_Domain__c> pod = [select id,Domain_Name__c,Enterprise_Account__c,Partner_of_Record__r.Account_Executive__c,Partner_of_Record__r.name,Partner_Account__c,Partner_of_Record__r.Partner__c from Partner_of_Record_Domain__c where Partner_of_Record__r.Customer__c = :pb.cscfga__Opportunity__r.AccountId and status__c = 'Active' and Domain_Name__c IN :dominSet];
        system.debug('pod'+pod);
        string domains;
        string partnerRec;
        for(Partner_of_Record_Domain__c pd : pod){
            if(pd.Domain_Name__c != '' && pd.Domain_Name__c != null){
                domains = pd.Domain_Name__c + ',' + domains;
            }
            if(pd.Partner_of_Record__r.name != '' && pd.Partner_of_Record__r.name != null){
                partnerRec = pd.Partner_of_Record__r.name + ',' + partnerRec;
            }
        }
        if(partnerRec !='' && partnerRec != null){
            partnerRec = partnerRec.replace(',null',''); 
        }
        if(domains !='' && domains != null){
            domains = domains.replace(',null',''); 
        }
       string userName = userinfo.getName();
        Group g=[select Id from Group Where name='Partner of Record Approvers' AND Type = 'Queue'];
        for( GroupMember gm : [select id, UserOrGroupId  from GroupMember  WHERE groupId =: g.Id ]) {
            if(pb.csordtelcoa__Basket_Stage__c == 'CE POR Basket Review'){
                ConnectApiHelper.postFeedItemWithMentions(n.id, gm.UserOrGroupId,'Hi {' + gm.UserOrGroupId + '}, partner {' + pb.cscfga__Opportunity__r.ownerId + '} is configuring a customer order  ' + pb.Name +'  for product domain(s) '+ domains + ' for which Partner '+ partnerRec +' is a active Partner of record. Please review and action ' + pb.Name); 
            }            
        }
        if(pb.csordtelcoa__Basket_Stage__c == 'Approved') {
            ConnectApiHelper.postFeedItemWithMentions(n.id, pb.cscfga__Opportunity__r.ownerId,'Hi {' + pb.cscfga__Opportunity__r.ownerId + '}, The Basket '+pb.Name+' raised for product domain(s) '+ domains + ' is approved by the '+ userName);     
        }
        if(pb.csordtelcoa__Basket_Stage__c == 'Rejected') { 
            ConnectApiHelper.postFeedItemWithMentions(n.Id, pb.cscfga__Opportunity__r.ownerId,'Hi {' + pb.cscfga__Opportunity__r.ownerId + '}, The Basket '+pb.Name+' raised for product domain(s) '+ domains + ' is rejected by the '+ userName);
        }
    }
}