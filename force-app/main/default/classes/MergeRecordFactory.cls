public class MergeRecordFactory{
	public enum type {ACCOUNT, CONTACT}
    
    public static map<MergeRecordFactory.type, RecordMerge> getMergeRecords(List<Merge_Request__c> MergeRecords) {
        map<MergeRecordFactory.type, RecordMerge> mapMerge =  new map<MergeRecordFactory.type, RecordMerge>();
        list<Merge_Request__c> conMergeList =  new list<Merge_Request__c>();
        list<Merge_Request__c> accMergeList =  new list<Merge_Request__c>();
        for(Merge_Request__c MergeRecord : MergeRecords)
        {
            system.debug('MergeRecord===='+MergeRecord);
            system.debug('MergeRecord.Type__c===='+MergeRecord.Type__c);
            if(MergeRecord.Type__c == 'CONTACT'){
                system.debug('CONTACT===='+MergeRecord);
     			conMergeList.add(MergeRecord);
			} 
            
            if (MergeRecord.Type__c == 'ACCOUNT'){
                system.debug('ACCOUNT===='+MergeRecord);
				accMergeList.add(MergeRecord);
			}
		}
        if(conMergeList.size() > 0)
        mapMerge.put(MergeRecordFactory.type.CONTACT, new ContactMerge(conMergeList));
        
        if(accMergeList.size() > 0)
        mapMerge.put(MergeRecordFactory.type.ACCOUNT, new CustomerMerge(accMergeList));
        
         return mapMerge;
    } 

}