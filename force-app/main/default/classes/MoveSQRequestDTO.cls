/*
 * DTO class for Move SQ Request
 */
public class MoveSQRequestDTO {
    public Data data {get;set;}
    
    public class Data{
     	public String addressId {get;set;}
    	public List<String> fnns {get;set;} 
    }
    
    public String getEncodedURL(){
		String encodedURL;
        if(this.data.fnns != null && this.data.addressId != null){
            encodedURL = 'fnns=';
            for(Integer i=0; i < this.data.fnns.Size() ; i++){
                 encodedURL = encodedURL + this.data.fnns[i]+',';
                System.debug('FNN :'+this.data.fnns[i]);
            }
            encodedURL = encodedURL.removeEnd(',');
            encodedURL = encodedURL + ((null != this.data.addressId && this.data.fnns != null)?'&':'')
                + ((null != this.data.addressId)?'addressId='+this.data.addressId:'');
            //return EncodingUtil.URLEncode(encodedURL, 'UTF-8');
            return encodedURL;
        }else{
            return null;
        }
    }
    
    public static MoveSQRequestDTO parse(String json) {
		return (MoveSQRequestDTO) System.JSON.deserializeStrict(json, MoveSQRequestDTO.class);
	}
}