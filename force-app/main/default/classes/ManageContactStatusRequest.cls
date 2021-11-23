global class ManageContactStatusRequest {

    public Data data;

    public class Data
    {
        public Fault fault;
    }

    public class Fault
    {
        public String faultcode;
        public String faultString;
        public String faultActor;
        public String serverName;
        public String processId;
        public String threadId;
        public String programName;
        public String programLocation;
        public String timestamp;
        public String initiatingEntityId;
        public String programStatusCode;
        public String programStatusDescription;
        public String programFaultId;
        public String programFaultDescription;
        public String faultCategory;
        public String entityName;
        public String entityValue;
    }

}