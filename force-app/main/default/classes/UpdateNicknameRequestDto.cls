//DIGI-22527 Update TNOW NickName REST API
public class UpdateNicknameRequestDto {

    public class SubRec {
        public String subNumber;
        public String nickName;
    }
    public UpdateNicknameRequest UpdateNicknameRequest;
    public class UpdateNicknameRequest {
        public List<SubRec> subRec;
    }   
    public static UpdateNicknameRequestDto parse(String json) {
        return (UpdateNicknameRequestDto) System.JSON.deserialize(json, UpdateNicknameRequestDto.class);
    }
}