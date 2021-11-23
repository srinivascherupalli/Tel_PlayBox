global class OEDataProvider implements cssmgnt.RemoteActionDataProvider {
     global Map<String, Object> getData(Map<String, Object> inputMap){
         Map<String, Object> response = new Map<String, Object>();
         if(inputMap.get('object') == 'contact'){
             List<Contact> data = [SELECT Id, name, firstname, lastname, mobilephone, phone, email FROM Contact WHERE Id = :String.valueOf(inputMap.get('id'))];
             response.put('response', data);
         }
         if(inputMap.get('object') == 'address'){
             List<cscrm__Address__c> data = [SELECT Id, name, address_id__c, cscrm__city__c, cscrm__zip_postal_code__c, street_calc__c FROM cscrm__Address__c WHERE Id = :String.valueOf(inputMap.get('id'))];
             response.put('response', data);
         }
         if(inputMap.get('object') == 'funccontact'){
            List<Functional_Contact_Role__c> data = [SELECT Id, name FROM Functional_Contact_Role__c WHERE Role__c='Primary Site Contact' AND Role_Type__c='Site' AND SiteID__c=:String.valueOf(inputMap.get('id')) LIMIT 1];
            /*
                2019/05/31 ddorotic
                *******************
                Functional_Contact_Role__c does not contain entries to satisfy query based on lookup query "LQ_Func_Contact", dummy query to pick up first entry from that table in place (for functioning purposes),
                Note:
                A query condition is still missing -> [ SiteID__c   equals  {SiteID} ]. Please look into this.

                List<Functional_Contact_Role__c> data = [SELECT Id, name FROM Functional_Contact_Role__c WHERE Role_Type__c = 'Site' AND Role__c = 'Primary Contact' AND SiteID__c != '' LIMIT 1];
            */
            response.put('response', data);
         }
         return response;
     }
}