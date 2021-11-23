/*************************************************************************************************
Name : getACROnProdBasket
TestClass:getACROnProdBasketTest
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.         Akanksha           5-Nov-2020        EDGE-182456 to fetch contacts from  account contact relationship on console config
===============================================================================================================================
***************************************************************************************************/
global class getACROnProdBasket implements csbb.LookupPlugin
{
     global static String query (Map<String, String> params, String parentFieldValue)
    {
        String orderBy = (params.get('orderByCriteria') == '') ? ' Contact_Name__c desc' : params.get('orderByCriteria');
        List<AccountContactRelation> acrList = (List<AccountContactRelation>)Database.query('select id, ContactId, Contact_Name__c,Roles from AccountContactRelation where AccountId = :parentFieldValue and (Roles =\'Full Authority\' or Roles =\'Legal Lessee\') order by ' + orderBy);
        List<Map<String, String>> returnList = new List<Map<String, String>>();
        for (AccountContactRelation acr : acrList) {
            returnList.add(new Map<String, String>{'id' => acr.ContactId, 'name' => acr.Contact_Name__c,'Roles'=>acr.Roles});
        }
        return JSON.serialize(returnList);
    }
}