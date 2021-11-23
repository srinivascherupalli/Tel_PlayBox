trigger ServiceTriggerCustom on csord__Service__c (before insert, before update, after update) {
    if(trigger.isBefore && (trigger.isInsert||trigger.isUpdate)){
        for(csord__Service__c ser : Trigger.new) {
            if(!String.isEmpty(ser.name) && (ser.name.contains('----') || ser.name.contains(' x '))){
                ser.name = ser.name.replace('------------', '');
                ser.name = ser.name.replace('--------', '');
                ser.name = ser.name.replace('----', '');
                ser.name = ser.name.contains(' x ') ? ser.name.split(' x ',2).get(0) : '';
            }
            if(!String.isEmpty(ser.Model__c) && (ser.Model__c.contains('----') || ser.Model__c.contains(' x '))){
                ser.Model__c = ser.Model__c.replace('------------', '');
                ser.Model__c = ser.Model__c.replace('--------', '');
                ser.Model__c = ser.Model__c.replace('----', '');
                ser.Model__c = ser.Model__c.contains(' x ') ? ser.Model__c.split(' x ',2).get(0) : '';
            }
        }
    }else if(trigger.size>0 && trigger.isUpdate && trigger.isAfter){
        CSPOFA.Events.emit('update', Trigger.newMap.keySet());
    }
    //EDGE-126425
    if(trigger.isAfter && trigger.isUpdate){
        ServiceTriggerCustomHandler.filterAllvalidrecords(Trigger.OldMap, Trigger.New);
    }
}