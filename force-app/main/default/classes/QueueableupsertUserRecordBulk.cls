public class QueueableupsertUserRecordBulk implements Queueable {
        List<Id> lstContactIds;
        map<Id,String> mapConIdUserId;
        String profileName;
        Boolean ISActive;
        Boolean Isprofileupdatable;
        
        public QueueableupsertUserRecordBulk(List<Id> lstContactIds,map<Id, string> mapConIdUserId,String profileName,Boolean ISActive,boolean Isprofileupdatable) {
            this.lstContactIds = lstContactIds;
            this.mapConIdUserId = mapConIdUserId;
            this.profileName = profileName;
            this.ISActive = ISActive;
            this.Isprofileupdatable=Isprofileupdatable;
        }
        
        public void execute(QueueableContext context) {
            PhoenixGlobalUtil.upsertUserRecordBulk(lstContactIds, mapConIdUserId, profileName,ISActive,Isprofileupdatable);
        }
    }