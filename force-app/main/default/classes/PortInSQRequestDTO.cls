public class PortInSQRequestDTO {
	public Data data;
    
    public class Data {
        public List<String> fnns;
    }

	public String getEncodedURL(){
         if(this.data.fnns == null || this.data.fnns.Size() <=0){
             return null;
         }else{
         	String encodedURL = '';
          	for(Integer i=0; i < this.data.fnns.Size() ; i++){
                 encodedURL = encodedURL + this.data.fnns[i]+',';
            }
            encodedURL = encodedURL.removeEnd(',');
        	//return EncodingUtil.URLEncode(encodedURL, 'UTF-8');
        	return encodedURL;   
         }
    }

    public static PortInSQRequestDTO parse(String json) {
		return (PortInSQRequestDTO) System.JSON.deserialize(json, PortInSQRequestDTO.class);
	}
}