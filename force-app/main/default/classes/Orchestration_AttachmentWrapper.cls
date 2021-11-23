public class Orchestration_AttachmentWrapper {
    public String attchId;
    public Blob attchBody;
    public String attchName;
    public String parentId;

    public Orchestration_AttachmentWrapper(String attchId, Blob attchBody) {
        this.attchId = attchId;
        this.attchBody = attchBody;
    }
    public Orchestration_AttachmentWrapper(String attchId, String attchName, Blob attchBody, String parentId) {
        this.attchId = attchId;
        this.attchName = attchName;
        this.attchBody = attchBody;
        this.parentId = parentId;
    }
    public Orchestration_AttachmentWrapper(String attchId, String attchName, Blob attchBody) {
        this.attchId = attchId;
        this.attchName = attchName;
        this.attchBody = attchBody;
    }
}