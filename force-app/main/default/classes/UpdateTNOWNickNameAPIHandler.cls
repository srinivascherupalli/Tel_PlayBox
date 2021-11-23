//Story number: DIGI-22527
//Description: Update Nickname in Subscriptions based on request from TNOW via microservices
global class UpdateTNOWNickNameAPIHandler {
    global static RestResponse generateResponse(RestResponse res, RestRequest req) {
        ApplicationLog__c logRec = new ApplicationLog__c();
		try{			               
			String regexItem = '^[a-zA-Z0-9.-]*$';
            String strLength = 'Nickname cannot be more than 80 characters long';
			String strInvalidNN = 'Nickname should not have any character apart from a-z,A-Z,0-9';
			String strInvalidSub = 'Nickname change is allowed only for Active AM or CMP Mobile services.';
			String strSubNotFound = 'Subscription not found';
			String validSubLabel = System.Label.ProductsToAllowNickname;
            logRec.Debug_Level__c = 'Integration';
            logRec.Reference_Info__c = 'UpdateTNOWNickNameAPI';
            logRec.Stack_Trace__c = string.valueOf(req.headers);
            logRec.Request_Message__c = req.requestBody.toString();            
            UpdateNicknameResponseDto resDto = new UpdateNicknameResponseDto();
			csord__Subscription__c subRecord;
			List<csord__Subscription__c> subRecordLst = new List<csord__Subscription__c>();
			Pattern NicknamePattern = Pattern.compile(regexItem);
			Matcher NicknameMatcher;
			String reqBody = req.requestBody.toString();
			Map<String, String> subReqMap = new Map<String, String>();
			Map<String, String> subResMap = new Map<String, String>();
			Map<Id, String> subIdMap = new Map<Id, String>();
			UpdateNicknameRequestDto reqDto = UpdateNicknameRequestDto.parse(reqBody);
			List<UpdateNicknameRequestDto.SubRec> reqSubLst = new List<UpdateNicknameRequestDto.SubRec>();
			if(reqDto.UpdateNicknameRequest != null && reqDto.UpdateNicknameRequest.subRec != null && reqDto.UpdateNicknameRequest.subRec.size() > 0){
				reqSubLst = reqDto.UpdateNicknameRequest.subRec;
				for(UpdateNicknameRequestDto.SubRec sb: reqSubLst){
                    if(sb.nickName.length() > 80){
                        subResMap.put(sb.subNumber, strLength);
                    }
                    else{
                        NicknameMatcher = NicknamePattern.matcher(sb.nickName);
                        if(NicknameMatcher.matches()){
                            subReqMap.put(sb.subNumber, sb.nickName);
                        }
                        else{
                            subResMap.put(sb.subNumber, strInvalidNN);
                        }
                    }
				}
				if(!subReqMap.isEmpty()){
					List<String> subNumLst = new List<String>(subReqMap.KeySet());
					List<String> subNumLstPostSoql = new List<String>();
					List<csord__Subscription__c> subscriptionLst = [SELECT Id, csord__Status__c, ConfigSpecID__c, csordtelcoa__Replacement_Subscription__c, Nickname__c, csordtelcoa__Subscription_Number__c FROM csord__Subscription__c WHERE csordtelcoa__Subscription_Number__c IN :subNumLst];
					for(csord__Subscription__c s: subscriptionLst){
						subNumLstPostSoql.add(s.csordtelcoa__Subscription_Number__c);
						if(s.csord__Status__c =='Inactive' || !validSubLabel.containsIgnoreCase(s.ConfigSpecID__c) || s.csordtelcoa__Replacement_Subscription__c != null){
							subResMap.put(s.csordtelcoa__Subscription_Number__c, strInvalidSub);
						}
						else{
							subIdMap.put(s.Id, s.csordtelcoa__Subscription_Number__c);
							subRecord = new csord__Subscription__c();
							subRecord.Id = s.Id;
							subRecord.Nickname__c = subReqMap.get(s.csordtelcoa__Subscription_Number__c);
							subRecordLst.add(subRecord);
						}
					}
					for(String s :subNumLst){
						if(!subNumLstPostSoql.contains(s)){
							subResMap.put(s, strSubNotFound);
						}
					}
					if(!subRecordLst.isEmpty()){
						Database.SaveResult[] srList = Database.update(subRecordLst, false);
						for (Database.SaveResult sr : srList) {
							if (!sr.isSuccess()) {								
								subResMap.put(subIdMap.get(sr.getId()), String.valueOf(sr.getErrors()));
							}
						}						
					}					
				}
				if(!subResMap.isEmpty()){					
					UpdateNicknameResponseDto.UpdateNicknameResponse resHdr = new UpdateNicknameResponseDto.UpdateNicknameResponse();
					list<UpdateNicknameResponseDto.ErrorRec> resErrRecLst = new list<UpdateNicknameResponseDto.ErrorRec>();
					UpdateNicknameResponseDto.ErrorRec resErrRec;
					for(String s :subResMap.KeySet()){
						resErrRec = new UpdateNicknameResponseDto.ErrorRec();
						resErrRec.subNumber = s;
						if(subResMap.get(s) == strInvalidNN || subResMap.get(s) == strInvalidSub || subResMap.get(s) == strLength || subResMap.get(s) == strSubNotFound)
							resErrRec.errorReason = subResMap.get(s);
						else
							resErrRec.errorReason = 'An error has occuured while updating the Subscription';
						resErrRecLst.add(resErrRec);						
					}
					resHdr.errorRec = resErrRecLst;
					resDto.UpdateNicknameResponse = resHdr;
				}
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(resDto,true));
                res.addHeader('Content-Type','application/json');   
                logRec.Status_Code__c = '200';
                logRec.Message__c = string.valueOf(subResMap);
			}
            else{
                res.statusCode = 204;
                res.addHeader('Content-Type','application/json');  
                logRec.Status_Code__c = '204';
            }           
		}
		catch(Exception e){
            system.debug('Error in UpdateTNOWNickNameAPIHandler::::'+e.getLineNumber()+'::::'+e.getMessage()+'::::'+e.getStackTraceString());
            res.statusCode = 500;
            res.addHeader('Content-Type','application/json'); 
            logRec.Status_Code__c = '500';
			logRec.Message__c = 'Error in UpdateTNOWNickNameAPIHandler::::'+e.getLineNumber()+'::::'+e.getMessage()+'::::'+e.getStackTraceString();
		}
        insert logRec;
        return res;
	}
}