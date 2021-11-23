global with sharing class CS_SubscriptionDataMapper {

    public static List<subscription> getSubscriptions(String accountId, String subscription_name, String subscription_status) {
        list<subscription> retval = new list<subscription>();
        list<csord__subscription__c> subs = [ select Id,Name,
            csord__status__c,
            csord__total_recurring_charges__c,
            Site__r.Name,
            Site__r.cscrm__Account__r.Name,
            Site__r.cscrm__Account__r.cidn__c,
            Site__r.Address__c
                from csord__Subscription__c
                where csord__status__c = :subscription_status
                and name = :subscription_name
                and Site__r.cscrm__Account__r.Id=:accountId];

        for(csord__subscription__c sub: subs) {
            Subscription tmp = new Subscription();
            tmp.Id = sub.Id;
            //START :Changes for EDGE-106634
            //tmp.Name = sub.Name;
            tmp.Name = System.label.Label_CWP;
            //END :Changes for EDGE-106634
            tmp.Status = sub.csord__Status__c;
            tmp.Total_Recurring_Charges = sub.csord__total_recurring_charges__c;
            tmp.Account = new Map<String, String>();
            tmp.Account.put('Id', sub.Site__r.cscrm__Account__r.Id);
            tmp.Account.put('Name', sub.Site__r.cscrm__Account__r.Name);
            tmp.Site = new Map<String, String>();
            tmp.Site.put('Name',sub.Site__r.Name);
            tmp.Site.put('Installation_Address', sub.Site__r.Address__c);

            retval.add(tmp);
        }

        return retval;
    }

    public static GetServicesResponse getServicesForSubscription(String subscription_id, String cidn) {
        GetServicesResponse retval = new GetServicesResponse();
        retval.services = new list<service>();
        list<csord__subscription__c> subs = [ select Id,Name, 
        	csordtelcoa__Subscription_Number__c,
        	csord__total_recurring_charges__c,
        	Site__r.cscrm__Account__r.cidn__c,
            (select id, name from csord__services__r where csord__status__c=:system.label.MO_Service_Status_Connected)
                from csord__Subscription__c
                where id = :subscription_id
                and csord__status__c = :system.label.Active_Status
        ];
        
        if(null == subs || subs.size() != 1 || subs.get(0).Site__r.cscrm__Account__r.cidn__c != cidn) {
            System.debug('no subscriptions');	
        } else {
            csord__subscription__c sub = subs.get(0);
            retval.TotalRecurringCharges = sub.csord__total_recurring_charges__c;
            retval.SubscriptionNumber = sub.csordtelcoa__Subscription_Number__c;
        	retval.SubscriptionName = sub.name;
        	
        	//START :Changes for EDGE-106634
        	set<Id> attachmentParentIds = new set<Id>();
        	map<Id,attachment> attMap = new map<Id,attachment>();
        	for(csord__service__c svc: sub.csord__services__r){
        	    attachmentParentIds.add(svc.Id);
        	}
        	list<Attachment> attsList = [SELECT parentId,body FROM Attachment WHERE parentId IN : attachmentParentIds];
        	for(Attachment att : attsList){
        	    attMap.put(att.parentId, att);
        	}
        	//END :Changes for EDGE-106634
        	//Removing the SOQL query in side for loop
            for(csord__service__c svc: sub.csord__services__r) {
                String serviceId = svc.Id;
               // list<attachment> atts = [select body from attachment where parentId = :serviceId];// Removing SOQL in side for loop
                service tmp = new service();
                tmp.Id = serviceId;
                tmp.Name = svc.Name;
                tmp.specifications = new List<Map<String,Object>>();
                //START :Changes for EDGE-106634
				if(attMap.containsKey(svc.Id)) {
					Map<String,Object> specMap = (Map<String,Object>)JSON.deserializeUntyped(attMap.get(svc.Id).Body.toString());
					//END :Changes for EDGE-106634
					List<Object> lst = (List<Object>)specMap.get('specifications');
					for(Object m: lst) {
						Map<String,Object> m2 = (Map<String,Object>)m; 
						tmp.specifications.add(m2);
					}
				}

                retval.services.add(tmp);
            }

        }

        return retval;
    }

    global class Subscription {
        public String Id { get; set; }
        public String Name { get; set; }
        public String Status { get; set; }
        public Decimal Total_Recurring_Charges { get; set; }
        public Map<String,String> Account { get; set; }
        public Map<String,String> Site { get; set; }
    }

    global class Service {
        public String Id { get; set; }
        public String Name { get; set; }
        public List<Map<String,Object>> specifications { get; set; }
    }

}