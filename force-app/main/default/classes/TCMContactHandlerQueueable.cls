public class TCMContactHandlerQueueable implements Queueable,Database.AllowsCallouts{
    
    public List<String> contactUUID{get;set;}
    
    public TCMContactHandlerQueueable(List<String> contactUUID){
        this.contactUUID = contactUUID;
    }
    
    public void execute(QueueableContext context){
        TCMGetContactInfo searchByContactUUID = new TCMGetContactInfo('TCMCUSTOMERSEEDING');
        searchByContactUUID.contactUUIDs(contactUUID);
    }

}