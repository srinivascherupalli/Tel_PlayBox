trigger PiicheckTrigger on PII_Lookup__c (before insert) {
	if(EnvironmentalSettings.isTriggerDisabled('PiicheckTrigger')) {
        return;
    }
    
    Id ObjprefixId = [Select Id, Name from RecordType where name = :Constants_PLR.Object_Prefix limit 1].Id;
    Id piifieldId = [Select Id, Name from RecordType where name = :Constants_PLR.PII_Fields limit 1].Id;
    String ObjName = '';
    for (PII_Lookup__c pc: Trigger.new) {
        if(pc.RecordTypeId == ObjprefixId)
        {
            If(pc.Field_Name__c!= Constants_PLR.PREFIX)
            {
                Trigger.new[0].Adderror(Constants_PLR.TRIGGER_ERROR);              
            }
        }
        else if(pc.RecordTypeId == piifieldId)
        {
            ObjName = (pc.Event_Type__c == 'VisualforceRequest' ?  pc.Related_to_obj__c : pc.Name__c );
            if(Util_PLR.checkSobjectColumn(ObjName,pc.Field_Name__c) || Util_PLR.checkSobjectColumn(ObjName,pc.Field_Name__c+'Id') )
            {
                pc.Field_Type__c =(Util_PLR.checkSobjectColumn(ObjName,pc.Field_Name__c)?Util_PLR.checkFieldFls(ObjName,pc.Field_Name__c) :Util_PLR.checkFieldFls(ObjName,pc.Field_Name__c+'Id'));
            }
            else 
            {
                Trigger.new[0].Adderror(Constants_PLR.TRIGGER_ERROR01);              
                
            }
        }
    }
}