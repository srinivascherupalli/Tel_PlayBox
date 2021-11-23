public class SharedSecretSignService {
    public Integration_Handler__mdt preConstants;     
    public HttpRequest getHeadersSharedSecret(HttpRequest request, String method, String endpoint, String payload,Integration_Handler__mdt preConst) {
      // Query to get the PRE Constant values from Custom metadata.
      preConstants = preConst;
      Long csTime = System.currentTimeMillis();
      request.setHeader('organization', preConstants.Mock_End_Point__c);
      request.setHeader('Authorization', getAuthorizationHeader(method, endpoint, csTime));
      request.setHeader('CS-Time', String.valueOf(csTime));
      request.setHeader('CS-Signature', getSignedPayload(payload));
      request.setHeader('Content-Type', 'application/json');
  
      return request;
    }
  
    private String getSignedPayload(String payload) {
      Blob digest = Crypto.generateDigest('sha1', Blob.valueOf(payload));
      String hexDigest = EncodingUtil.convertToHex(digest);
      Blob hash = Crypto.generateMac(
        'hmacSHA256',
        Blob.valueOf(hexDigest),
        Blob.valueOf(preConstants.Client_Secret__c)
      );
  
      return EncodingUtil.convertToHex(hash);
    }
  
    private String getAuthorizationHeader(String method, String endpoint, Long csTime) {
      String data = 'CS' + preConstants.Client_Id__c+ '\n' +
        csTime + '\n' +
        method.toUpperCase() + '\n' +
        endpoint + '\n';
      Blob hash = Crypto.generateMac(
        'hmacSHA256',
        Blob.valueOf(data),
        Blob.valueOf(preConstants.Client_Secret__c)
      );
      String hex = EncodingUtil.convertToHex(hash);
      String signature = EncodingUtil.base64Encode(Blob.valueOf(hex));
  
      return EncodingUtil.base64Encode(Blob.valueOf('CS' + preConstants.Client_Id__c)) + ':' + signature;
    }
  }