//
// DTO class for SQ Request for Site
//

public class SiteSQRequestDTO {
	public Data data {get;set;}
    
    public class Data {
        public String adborId {get;set;}
        public String customerAuthorityDate {get;set;}
        public String tc2Required='false';
    }
    
    /* Method to get URL Params for SQ Site Request
     * 
     * @return encodedURL
     */
     public String getEncodedURL(){
         if(this.data.adborId == null || this.data.adborId == ''){
             return null;
         }else{
            String encodedURL = 'addressId='+this.data.adborId;
             if(this.data.customerAuthorityDate != null){
                encodedURL = encodedURL + '&customerAuthorityDate='+this.data.customerAuthorityDate;
             }
              if(this.data.tc2Required != 'false'){
                 encodedURL = encodedURL + '&tc2Required='+this.data.tc2Required;
             }
        	//return EncodingUtil.URLEncode(encodedURL, 'UTF-8');
        	return encodedURL;   
         }
    }
    
	public static SiteSQRequestDTO parse(String json) {
		return (SiteSQRequestDTO) System.JSON.deserialize(json, SiteSQRequestDTO.class);
	}
}