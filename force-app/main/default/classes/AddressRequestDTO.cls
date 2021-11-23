public class AddressRequestDTO {
    public Data data;
    public class Data{
        public String adborId {get; set;}
    }
    
    public String getEncodedURLParam(){
        String encodedUrl = '';
        if(this.data.adborId == '' || this.data.adborId == null)
            return null;
        else
            encodedUrl = this.data.adborId+'?reqaddformatout=unstructuredAUPost,structured';
        return encodedUrl;
    }
    
    public static AddressRequestDTO parse(String json) {
		return (AddressRequestDTO) System.JSON.deserialize(json, AddressRequestDTO.class);
    } 
}