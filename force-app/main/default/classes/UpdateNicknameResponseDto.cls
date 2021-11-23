//DIGI-22527 Update TNOW NickName REST API
public class UpdateNicknameResponseDto {

	public UpdateNicknameResponse UpdateNicknameResponse;
    
	public class ErrorRec {
		public String subNumber;
		public String errorReason;
	}
    
	public class UpdateNicknameResponse {
		public List<ErrorRec> errorRec;
	}
    
	public static UpdateNicknameResponseDto parse(String json) {
		return (UpdateNicknameResponseDto) System.JSON.deserialize(json, UpdateNicknameResponseDto.class);
	}    
}