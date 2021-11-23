trigger CommercialProductPricingRuleAssociationTrigger on cspmb__Price_Item_Pricing_Rule_Association__c (before insert, before update, before delete,
                                                                                                         after insert, after update, after delete, after undelete) {

	No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
	if (notriggers == null || !notriggers.Flag__c) {
		if (trigger.isAfter && trigger.isInsert) {
            //Will generate and insert list price CPPRA records for all FA generated sales price overrides (as FA decomposition creates only Sales price override)
            FAM_Utility famUtil = new FAM_Utility(new list<Id>{});
            famUtil.createAndInsertListPriceOverrides(trigger.new);
		}
	}
}