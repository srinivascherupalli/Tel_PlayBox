public class ManageContactQueueableCallOut implements Queueable,Database.AllowsCallouts{
    
	public static final String EVENT_ACTION_CREATE = 'Create';
    public static final String EVENT_ACTION_UPDATE = 'Update';
    public static final String EVENT_ACTION_CROSSREF = 'CrossRef';
    public static final String Certificate_name = EnvironmentVariable.get('certificate_name');
    private List<ManageContactDAO> manageContactList{set;get;}
    
    public ManageContactQueueableCallOut(List<ManageContactDAO> manageContactList){
        this.manageContactList = manageContactList;
    }
    
    public  void execute(QueueableContext context) { 
        Logger2 log = Logger2.getLogger('ManageContactRequest');
        if(manageContactList != null && !manageContactList.isEmpty()){
            for(ManageContactDAO manageConDAO : manageContactList){
                ManageContactHandler.sendManageContact(manageConDAO.mcReq,manageConDAO.eventType,manageConDAO.identifier,log);
            }
        }
        log.exitLogger();
    }
}