/************************************************************************************
* Name             : GuidUtil
* Description      : Apex class for GuidUtil for generating the new Unique Id
* Created Date     : 18/Feb/2019
* Created By       : Team Polaris
*************************************************************************************
* Date         Change-Request          Modified By                    Description
*************************************************************************************
**************************************************************************************/
global class GuidUtil {
    global static String NewGuid() {
            Blob b = Crypto.GenerateAESKey(128);
        	String h = EncodingUtil.ConvertTohex(b);
            return h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);                   
  }     
}