/*
* @Desc : MDM Professional Service class called from RF_ProductBasketDataHandler
* @Jira : DIGI-518
*/
global with sharing class MDMPS_Utilities {
    //EDEG-80783 :Start
    public List<Map<String,Object> > getMDMProfServices(String basketId,Map<String,String> subfilters){
        List<Map<String,Object> > rows = new List<Map<String,Object> >();
        Map<String,String> snapshotMapping = new Map<String,String> {'Unit Of Measure Value'=>'Unit_Of_Measure',
            'TotalPrice'=>'GSTExcl_Total_Onceoff_Charges',
            'Unit Price'=>'Rate',
            'Quantity'=>'Quantity'};
                try{
                    String Offer_Name = subfilters.get('Offer_Name');
                    Set<String> attributeList= snapshotMapping.keySet();
                    //// String soqlQuery='SELECT name,cscfga__unit_one_off_charge__c, OfferName__c, cscfga__Contract_Term__c, cscfga__total_one_off_charge__c, TotalGSTInclusiveTOC__c, type__c, TotalGSTInclusiveTRC__c, cscfga__One_Off_Charge__c, Quantity_Product_Configuration__c, (SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r where Name in :attributeList) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c= \''+ String.escapeSingleQuotes(basketId)+'\'And name =\''+ String.escapeSingleQuotes(Offer_Name)+'\'order by cscfga__Parent_Configuration__r.cscfga__originating_offer__c';
                    //// list<cscfga__Product_Configuration__c> devicePCList = Database.query(soqlQuery);
                    List<cscfga__Product_Configuration__c> devicePCList = [SELECT name, (SELECT Id, Name, cscfga__Value__c FROM cscfga__Attributes__r where Name in :attributeList) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c=:basketId And name =:Offer_Name order by cscfga__Parent_Configuration__r.cscfga__originating_offer__c];
                    Integer externalId = 1;
                    if(devicePCList != null && devicePCList.size()>0){	 //// added this check
                        for(cscfga__Product_Configuration__c pc:devicePCList) {
                            Map<String,Object> newRow = new Map<String,Object>();
                            newRow.put('ExternalId', externalID++);
                            newRow.put('Product_Module_Name', 'T-MDM Professional Services');
                            for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
                                newRow.put(snapshotMapping.get(attribute.name),attribute.cscfga__Value__c);
                            }
                            rows.add(newRow);
                        }
                    }
                }
        catch(Exception e)
        {
            C2O_Utilities.createException(e);            //// added exception
        }
        return rows;
    }
    //EDEG-80783 :End
}