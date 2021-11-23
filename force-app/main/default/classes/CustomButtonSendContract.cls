global with sharing class CustomButtonSendContract extends csbb.CustomButtonExt {

    public String performAction(String basketId) {

        String status = OpportunitySyncUtil.syncWithOpportunity(basketId,'Contract Sent');        
        String DISPLAY_MESSAGE = OpportunitySyncUtil.DISPLAY_MESSAGE;
        PageReference ref = new PageReference('/apex/csbb__basketbuilderapp?Id=' + basketId);
        ref.setRedirect(true);
        return '{"status":"'+ status + '","text":"' + DISPLAY_MESSAGE + '", "redirectURL":"' + ref.getUrl() +'"}';
        //String newUrl=CustomButtonSendProposal.updateProductBasket(basketId);
        //String newUrl=CustomButtonSendContract.sendProposal(basketId);

        //return '{"status":"ok","redirectURL":"' + newUrl + '"}';
    }

/*public static string sendProposal(string basketId)
{
    String newUrl='/apex/c__SendProposal';
    PageReference pageRef=new PageReference(newUrl);
    pageRef.getParameters().put('id',basketid);
    return pageRef.getURL();
}

    public static String populateTemplate(string basketId)
    {
        
        map<ID,cscfga__Product_Configuration__c> pcrMap=new map<ID,cscfga__Product_Configuration__c>([SELECT Id,name,cscfga__Product_Basket__c  FROM cscfga__Product_Configuration__c where cscfga__Product_Basket__c=:basketid]);
       
       map<Id,cscfga__Attribute__c> attMap=new Map<ID,cscfga__Attribute__c>([SELECT cscfga__Is_Line_Item__c,cscfga__Line_Item_Description__c,cscfga__Price__c,cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.Name,cscfga__Recurring__c,cscfga__Value__c,Name FROM cscfga__Attribute__c where cscfga__Product_Configuration__c IN :pcrMap.keySet()
                                                                             AND cscfga__Is_Line_Item__c=true]);
        
        System.debug('AAAA' + attMap.values());
        
        String jsonRes = JSON.serializePretty(attMap.values());
        System.debug('BBBB' + jsonRes);
        return jsonRes;
    }

public static string updateProductBasket(string basketId)
{
    cscfga__Product_Basket__c basket=[SELECT csbb__Accessibility_Status__c,csbb__Account__c,cscfga__Basket_Status__c,csordtelcoa__Account__c,csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Basket__c where ID =: basketId LIMIT 1];


    basket.cscfga__Basket_Status__c='Closed Won';


    Database.update(basket);
    
    //This base URL is hard coded as it is for prototype(tactical solution)
    String returl='https://cs6.salesforce.com/' +basket.csordtelcoa__Account__c;
    
    return returl;
}
    public class DocusignParameters
    {
        public string docDescription {get;set;}
        public string docRecprice {get;set;}
        public string docIsrecurr {get;set;}
    }*/
}