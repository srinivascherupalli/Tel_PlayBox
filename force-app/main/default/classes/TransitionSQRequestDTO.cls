/*
 * DTO class for Transition SQ Request
 */
public class TransitionSQRequestDTO {
    public Data data {get;set;}
    
    public class Data{
       	public String addressId {get;set;}
		public String FNN {get;set;}
		public String tc2Required='true';
    }
	
    public boolean checkMandatoryParams(){
        if(Data.addressId != '' && Data.addressId != null && Data.FNN != '' && Data.FNN != null){
            return true;
        }
        return false;
    }
	public String getEncodedURL(){
         if(this.data.addressId == null || this.data.FNN == ''){
             return null;
         }else{
            String encodedURL = 'addressId='+this.data.addressId;
             if(this.data.FNN != null){
                encodedURL = encodedURL + '&FNN='+this.data.FNN;
             }
             encodedURL = encodedURL + '&tc2Required='+this.data.tc2Required;
        	//return EncodingUtil.URLEncode(encodedURL, 'UTF-8');
        	return encodedURL;   
         }
    }
	public static TransitionSQRequestDTO parse(String json) {
		return (TransitionSQRequestDTO) System.JSON.deserialize(json, TransitionSQRequestDTO.class);
	}
}