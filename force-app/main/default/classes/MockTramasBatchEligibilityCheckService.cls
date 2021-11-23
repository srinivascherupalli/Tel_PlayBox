/*
* @Author : Rahul
* @Date : 17 Nov 2019
* @Desc : Class for generating MockResponses for TramasBatchEligibilityCheckService
* @Jira Cloud : EDGE-66569
*/
global class MockTramasBatchEligibilityCheckService implements HttpCalloutMock{
    protected String resType;
    
    global MockTramasBatchEligibilityCheckService (String resType){
        this.resType = resType;
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
      
        String success_acknowledgement ='{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/batch/85ad590c-602a-47cc-8aea-099c8f55587f"}],"batchId":"85ad590c-602a-47cc-8aea-099c8f55587f","operations":{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/batch/85ad590c-602a-47cc-8aea-099c8f55587f"}],"data":[{"output":{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/418368ec-8b40-45a2-a93a-aa30a59b3787"}],"transitionId":"418368ec-8b40-45a2-a93a-aa30a59b3787","transitions":[{"type":"service","target":{"type":"cwp"},"properties":{"identifiers":[{"identifier":"0314419400","attributes":null},{"identifier":"0385990400-0385990499","attributes":null}],"family":"isdn2"}}],"states":[{"state":"created","timestamp":"2019-11-15T09:40:53.802Z"}],"metadata":{"batchId":"85ad590c-602a-47cc-8aea-099c8f55587f","createdAt":"2019-11-15T09:40:53.806Z","updatedAt":"2019-11-15T09:40:56.163Z","correlationId":"17bfa155-aea4-473a-8c0d-cd51f4714407"},"resource":{"data":[{"resourceId":"5a031482-dcd0-47c0-b291-e90988c41696","type":"service","identifier":"0314419400","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/5a031482-dcd0-47c0-b291-e90988c41696"}]},{"resourceId":"50b17604-ac87-4007-9f68-68aeb7c60808","type":"service","identifier":"0385990400","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/50b17604-ac87-4007-9f68-68aeb7c60808"}]},{"resourceId":"97880384-72d3-467c-88df-9b55d992b143","type":"service","identifier":"0385990401","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/97880384-72d3-467c-88df-9b55d992b143"}]},{"resourceId":"b3aa4de8-c9aa-4e5e-8824-88efb1dc9d12","type":"service","identifier":"0385990402","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/b3aa4de8-c9aa-4e5e-8824-88efb1dc9d12"}]},{"resourceId":"8e06a12a-16b8-4fb3-a965-b2a94ef2cd5d","type":"service","identifier":"0385990403","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/8e06a12a-16b8-4fb3-a965-b2a94ef2cd5d"}]},{"resourceId":"947a5153-55f6-4f53-ac0e-d1a20088653d","type":"service","identifier":"0385990404","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/947a5153-55f6-4f53-ac0e-d1a20088653d"}]},{"resourceId":"50350700-7a9a-4b63-a3b9-fcfff58e9d5b","type":"service","identifier":"0385990405","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/50350700-7a9a-4b63-a3b9-fcfff58e9d5b"}]},{"resourceId":"5e145529-38e4-48f1-ae5b-31c4c428770b","type":"service","identifier":"0385990406","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/5e145529-38e4-48f1-ae5b-31c4c428770b"}]},{"resourceId":"febb40b8-67c5-494a-9186-f6cd963596b7","type":"service","identifier":"0385990407","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/febb40b8-67c5-494a-9186-f6cd963596b7"}]},{"resourceId":"9d8fa6bb-a6c5-4d6c-a734-6cf138b99cb4","type":"service","identifier":"0385990408","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/9d8fa6bb-a6c5-4d6c-a734-6cf138b99cb4"}]},{"resourceId":"df7cdb6a-0efe-47c7-9bc4-8a16663e1dab","type":"service","identifier":"0385990409","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/df7cdb6a-0efe-47c7-9bc4-8a16663e1dab"}]},{"resourceId":"d0d633e6-4bc4-45e2-8fdb-496c3b4dddf7","type":"service","identifier":"0385990410","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d0d633e6-4bc4-45e2-8fdb-496c3b4dddf7"}]},{"resourceId":"d442d3e2-dd96-4be3-849e-20490c8e52d1","type":"service","identifier":"0385990411","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d442d3e2-dd96-4be3-849e-20490c8e52d1"}]},{"resourceId":"6a4a7e22-c76a-4dff-9bd2-b7d75a71b3b1","type":"service","identifier":"0385990412","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/6a4a7e22-c76a-4dff-9bd2-b7d75a71b3b1"}]},{"resourceId":"732f1823-7d1e-4861-b64e-520cde32eecf","type":"service","identifier":"0385990413","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/732f1823-7d1e-4861-b64e-520cde32eecf"}]},{"resourceId":"12b65055-c64d-4734-9970-276f9a49dc36","type":"service","identifier":"0385990414","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/12b65055-c64d-4734-9970-276f9a49dc36"}]},{"resourceId":"303e18f5-91aa-48f3-88b6-3fd39821da03","type":"service","identifier":"0385990415","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/303e18f5-91aa-48f3-88b6-3fd39821da03"}]},{"resourceId":"dd5a8df9-b13f-4ccb-b831-bc75575ddeb2","type":"service","identifier":"0385990416","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/dd5a8df9-b13f-4ccb-b831-bc75575ddeb2"}]},{"resourceId":"e923bcb5-c114-4990-9740-b319af7642ae","type":"service","identifier":"0385990417","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/e923bcb5-c114-4990-9740-b319af7642ae"}]},{"resourceId":"0a73625b-a989-41bd-a35d-a65c2c8c57ed","type":"service","identifier":"0385990418","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/0a73625b-a989-41bd-a35d-a65c2c8c57ed"}]},{"resourceId":"bdf24a17-4550-4bb6-8acd-f85d820590ad","type":"service","identifier":"0385990419","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/bdf24a17-4550-4bb6-8acd-f85d820590ad"}]},{"resourceId":"a5d753ba-313b-4d6a-9a9b-0aebc1f8ec5d","type":"service","identifier":"0385990420","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/a5d753ba-313b-4d6a-9a9b-0aebc1f8ec5d"}]},{"resourceId":"b7536707-b47e-4c8f-911c-59761c7653ef","type":"service","identifier":"0385990421","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/b7536707-b47e-4c8f-911c-59761c7653ef"}]},{"resourceId":"e3d051c9-94af-47f2-ae9b-027490d8e959","type":"service","identifier":"0385990422","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/e3d051c9-94af-47f2-ae9b-027490d8e959"}]},{"resourceId":"ea9ea8f6-0052-42bb-af76-57e6dbf69c20","type":"service","identifier":"0385990423","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/ea9ea8f6-0052-42bb-af76-57e6dbf69c20"}]},{"resourceId":"1feb6ba2-5e53-44c2-8425-f7636f7623c9","type":"service","identifier":"0385990424","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/1feb6ba2-5e53-44c2-8425-f7636f7623c9"}]},{"resourceId":"d31d3d61-ffb5-4da0-b6c1-26e75429f06d","type":"service","identifier":"0385990425","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d31d3d61-ffb5-4da0-b6c1-26e75429f06d"}]},{"resourceId":"a467477f-546d-40f1-a3e4-f0932cbc70b8","type":"service","identifier":"0385990426","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/a467477f-546d-40f1-a3e4-f0932cbc70b8"}]},{"resourceId":"837102b4-c5c8-477b-b65d-de24d1ad4937","type":"service","identifier":"0385990427","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/837102b4-c5c8-477b-b65d-de24d1ad4937"}]},{"resourceId":"5792eb4c-fcda-41f2-8d41-303ad45b0bcb","type":"service","identifier":"0385990428","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/5792eb4c-fcda-41f2-8d41-303ad45b0bcb"}]},{"resourceId":"19d82c8b-4745-4c2e-8102-6dc637dfd30f","type":"service","identifier":"0385990429","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/19d82c8b-4745-4c2e-8102-6dc637dfd30f"}]},{"resourceId":"68fd1ffa-60fe-487a-989a-a98e73794b0e","type":"service","identifier":"0385990430","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/68fd1ffa-60fe-487a-989a-a98e73794b0e"}]},{"resourceId":"a96433ac-fdfb-46d9-abdf-4d3f2535bd01","type":"service","identifier":"0385990431","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/a96433ac-fdfb-46d9-abdf-4d3f2535bd01"}]},{"resourceId":"b349fc45-3b50-4873-a6d1-528de43bcf6f","type":"service","identifier":"0385990432","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/b349fc45-3b50-4873-a6d1-528de43bcf6f"}]},{"resourceId":"18c20aff-2d36-4067-95df-b7e6b9835f36","type":"service","identifier":"0385990433","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/18c20aff-2d36-4067-95df-b7e6b9835f36"}]},{"resourceId":"5818fbfb-7eb5-42ee-95ba-2b5ec2127739","type":"service","identifier":"0385990434","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/5818fbfb-7eb5-42ee-95ba-2b5ec2127739"}]},{"resourceId":"64f9da74-0422-4cea-8f93-5608c511cbbb","type":"service","identifier":"0385990435","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/64f9da74-0422-4cea-8f93-5608c511cbbb"}]},{"resourceId":"e5b4eec5-8ab8-42d0-98bf-c30f1895172f","type":"service","identifier":"0385990436","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/e5b4eec5-8ab8-42d0-98bf-c30f1895172f"}]},{"resourceId":"ca3dc67e-d27e-47e3-8ce4-b96c46bffca5","type":"service","identifier":"0385990437","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/ca3dc67e-d27e-47e3-8ce4-b96c46bffca5"}]},{"resourceId":"f7c3cdb6-ca4c-4e3f-8483-db4543166564","type":"service","identifier":"0385990438","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/f7c3cdb6-ca4c-4e3f-8483-db4543166564"}]},{"resourceId":"5375bdec-0183-43aa-8bb8-a084b33cafd1","type":"service","identifier":"0385990439","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/5375bdec-0183-43aa-8bb8-a084b33cafd1"}]},{"resourceId":"6dd6cdeb-2e7a-46bd-a19a-3ac0714e1e0a","type":"service","identifier":"0385990440","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/6dd6cdeb-2e7a-46bd-a19a-3ac0714e1e0a"}]},{"resourceId":"35a1021d-035f-4bda-a7cb-56edb58c1323","type":"service","identifier":"0385990441","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/35a1021d-035f-4bda-a7cb-56edb58c1323"}]},{"resourceId":"15926b92-3ccf-416a-9ef6-3dd438447c16","type":"service","identifier":"0385990442","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/15926b92-3ccf-416a-9ef6-3dd438447c16"}]},{"resourceId":"b2894e2e-c699-45d3-915d-3544f37133e1","type":"service","identifier":"0385990443","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/b2894e2e-c699-45d3-915d-3544f37133e1"}]},{"resourceId":"307712bd-a4d3-4a1d-8826-cb5380acc835","type":"service","identifier":"0385990444","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/307712bd-a4d3-4a1d-8826-cb5380acc835"}]},{"resourceId":"c454dfd7-8370-44fd-ae20-29db796baf32","type":"service","identifier":"0385990445","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/c454dfd7-8370-44fd-ae20-29db796baf32"}]},{"resourceId":"93986010-d8ad-43bc-8ec2-8fda76083eda","type":"service","identifier":"0385990446","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/93986010-d8ad-43bc-8ec2-8fda76083eda"}]},{"resourceId":"9ac0e1d5-98a2-4477-85dc-736ab59f0616","type":"service","identifier":"0385990447","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/9ac0e1d5-98a2-4477-85dc-736ab59f0616"}]},{"resourceId":"8d6910f5-d3cc-406f-9903-e8d8e2cf4142","type":"service","identifier":"0385990448","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/8d6910f5-d3cc-406f-9903-e8d8e2cf4142"}]},{"resourceId":"0fe47016-349a-4f41-bf8f-c6b3497e9177","type":"service","identifier":"0385990449","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/0fe47016-349a-4f41-bf8f-c6b3497e9177"}]},{"resourceId":"10b74096-73a0-44b1-885f-4566cdf79ce9","type":"service","identifier":"0385990450","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/10b74096-73a0-44b1-885f-4566cdf79ce9"}]},{"resourceId":"74b7935b-70ee-40bc-8b2c-888525595fcf","type":"service","identifier":"0385990451","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/74b7935b-70ee-40bc-8b2c-888525595fcf"}]},{"resourceId":"a826c379-d818-4b90-a0f5-0a9f29ed8266","type":"service","identifier":"0385990452","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/a826c379-d818-4b90-a0f5-0a9f29ed8266"}]},{"resourceId":"7a566d69-6c9c-4c69-b650-759462ea6d34","type":"service","identifier":"0385990453","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/7a566d69-6c9c-4c69-b650-759462ea6d34"}]},{"resourceId":"9b9a522b-8a51-4838-89b9-5c8ac2d662a2","type":"service","identifier":"0385990454","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/9b9a522b-8a51-4838-89b9-5c8ac2d662a2"}]},{"resourceId":"44285eab-193f-40ec-b46c-9d065f895a06","type":"service","identifier":"0385990455","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/44285eab-193f-40ec-b46c-9d065f895a06"}]},{"resourceId":"3926d159-be70-4533-8e27-4a636a687dd4","type":"service","identifier":"0385990456","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/3926d159-be70-4533-8e27-4a636a687dd4"}]},{"resourceId":"4ed331e1-444a-407a-9a5a-946cea769f74","type":"service","identifier":"0385990457","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/4ed331e1-444a-407a-9a5a-946cea769f74"}]},{"resourceId":"3adfb918-5b4d-4611-a7cd-32471584f5e0","type":"service","identifier":"0385990458","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/3adfb918-5b4d-4611-a7cd-32471584f5e0"}]},{"resourceId":"e3475819-b1ca-4e2c-8019-1f72d0c13bcf","type":"service","identifier":"0385990459","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/e3475819-b1ca-4e2c-8019-1f72d0c13bcf"}]},{"resourceId":"6256e26a-81be-4020-a635-2f007d5c2f01","type":"service","identifier":"0385990460","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/6256e26a-81be-4020-a635-2f007d5c2f01"}]},{"resourceId":"21e0b188-e7ea-4255-b3ba-aa7903699f07","type":"service","identifier":"0385990461","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/21e0b188-e7ea-4255-b3ba-aa7903699f07"}]},{"resourceId":"ae38fbdf-597e-4d49-9e95-562f93774107","type":"service","identifier":"0385990462","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/ae38fbdf-597e-4d49-9e95-562f93774107"}]},{"resourceId":"1ecd1d82-bb1f-4957-9944-43e6324e07a0","type":"service","identifier":"0385990463","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/1ecd1d82-bb1f-4957-9944-43e6324e07a0"}]},{"resourceId":"cd826873-bab3-4a81-bf99-6e14b796b295","type":"service","identifier":"0385990464","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cd826873-bab3-4a81-bf99-6e14b796b295"}]},{"resourceId":"a91bce6d-460c-49c2-9711-527c61914caa","type":"service","identifier":"0385990465","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/a91bce6d-460c-49c2-9711-527c61914caa"}]},{"resourceId":"32da4719-bfc7-41e3-992f-25586970dcdd","type":"service","identifier":"0385990466","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/32da4719-bfc7-41e3-992f-25586970dcdd"}]},{"resourceId":"8be91f36-8794-4886-b144-08bf912ca8d4","type":"service","identifier":"0385990467","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/8be91f36-8794-4886-b144-08bf912ca8d4"}]},{"resourceId":"252d3af5-14d4-46f9-b724-0aad6f2f6a4e","type":"service","identifier":"0385990468","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/252d3af5-14d4-46f9-b724-0aad6f2f6a4e"}]},{"resourceId":"56b9b492-e328-432d-9cb7-583923764be0","type":"service","identifier":"0385990469","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/56b9b492-e328-432d-9cb7-583923764be0"}]},{"resourceId":"e7f7a22f-7bed-4068-b5d6-20a84659cc86","type":"service","identifier":"0385990470","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/e7f7a22f-7bed-4068-b5d6-20a84659cc86"}]},{"resourceId":"8bfe0cb2-5dd7-4363-8794-98d78ca3fa11","type":"service","identifier":"0385990471","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/8bfe0cb2-5dd7-4363-8794-98d78ca3fa11"}]},{"resourceId":"fe89a927-8fb2-496c-bc1f-692c2ecf0fbd","type":"service","identifier":"0385990472","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/fe89a927-8fb2-496c-bc1f-692c2ecf0fbd"}]},{"resourceId":"1c1268a0-fbaa-4952-8018-56c0f3c783ef","type":"service","identifier":"0385990473","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/1c1268a0-fbaa-4952-8018-56c0f3c783ef"}]},{"resourceId":"2fa577fa-d1ea-4812-a7e5-d28d650ce66f","type":"service","identifier":"0385990474","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/2fa577fa-d1ea-4812-a7e5-d28d650ce66f"}]},{"resourceId":"c3e59df6-47f1-4333-abb1-26c40a2cd87a","type":"service","identifier":"0385990475","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/c3e59df6-47f1-4333-abb1-26c40a2cd87a"}]},{"resourceId":"4e194e09-6bd6-419e-b59b-d131b33eead2","type":"service","identifier":"0385990476","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/4e194e09-6bd6-419e-b59b-d131b33eead2"}]},{"resourceId":"d5f29536-c0cb-4fec-96f7-c17c71cd9ecc","type":"service","identifier":"0385990477","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d5f29536-c0cb-4fec-96f7-c17c71cd9ecc"}]},{"resourceId":"6a652f5a-e65b-472d-bd13-f482f7ef7bd6","type":"service","identifier":"0385990478","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/6a652f5a-e65b-472d-bd13-f482f7ef7bd6"}]},{"resourceId":"bc13b705-8345-4616-a11b-da348a55b138","type":"service","identifier":"0385990479","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/bc13b705-8345-4616-a11b-da348a55b138"}]},{"resourceId":"ece85489-2cb1-4909-b299-81d06d517da5","type":"service","identifier":"0385990480","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/ece85489-2cb1-4909-b299-81d06d517da5"}]},{"resourceId":"8b120da1-3f9b-4a82-b833-1b10f833aec7","type":"service","identifier":"0385990481","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/8b120da1-3f9b-4a82-b833-1b10f833aec7"}]},{"resourceId":"c21481d4-2598-44d1-ac66-7a55e37ff76f","type":"service","identifier":"0385990482","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/c21481d4-2598-44d1-ac66-7a55e37ff76f"}]},{"resourceId":"a71539f9-a39b-4d52-8824-5082ec7b8059","type":"service","identifier":"0385990483","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/a71539f9-a39b-4d52-8824-5082ec7b8059"}]},{"resourceId":"04ea3491-4fce-4a55-b687-3af68807ed30","type":"service","identifier":"0385990484","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/04ea3491-4fce-4a55-b687-3af68807ed30"}]},{"resourceId":"5c41c8cc-411e-4928-88d3-85ff26b158d6","type":"service","identifier":"0385990485","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/5c41c8cc-411e-4928-88d3-85ff26b158d6"}]},{"resourceId":"70c34e59-527d-4e85-822d-f899b21e844d","type":"service","identifier":"0385990486","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/70c34e59-527d-4e85-822d-f899b21e844d"}]},{"resourceId":"f056b0ef-3a8f-4b99-958c-62007bf2a9f6","type":"service","identifier":"0385990487","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/f056b0ef-3a8f-4b99-958c-62007bf2a9f6"}]},{"resourceId":"cd099941-cd32-4e21-b6bf-35490e30d91c","type":"service","identifier":"0385990488","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cd099941-cd32-4e21-b6bf-35490e30d91c"}]},{"resourceId":"fac3adfd-0eef-4808-9bfc-a368758994f2","type":"service","identifier":"0385990489","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/fac3adfd-0eef-4808-9bfc-a368758994f2"}]},{"resourceId":"311ac2e6-d722-40d3-b551-b43c80b70e36","type":"service","identifier":"0385990490","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/311ac2e6-d722-40d3-b551-b43c80b70e36"}]},{"resourceId":"844c5e5c-7b23-4d5e-9ef6-a3d48b0d89a9","type":"service","identifier":"0385990491","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/844c5e5c-7b23-4d5e-9ef6-a3d48b0d89a9"}]},{"resourceId":"610c2441-1b3d-423d-9bf9-4e14c7692fc4","type":"service","identifier":"0385990492","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/610c2441-1b3d-423d-9bf9-4e14c7692fc4"}]},{"resourceId":"3fa61a40-3eaa-46c2-b944-d5b30b1ca961","type":"service","identifier":"0385990493","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/3fa61a40-3eaa-46c2-b944-d5b30b1ca961"}]},{"resourceId":"40e8de24-c737-4cf1-8411-3a52f99e11cd","type":"service","identifier":"0385990494","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/40e8de24-c737-4cf1-8411-3a52f99e11cd"}]},{"resourceId":"36230504-e9c7-49a3-897f-9c4079abc47f","type":"service","identifier":"0385990495","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/36230504-e9c7-49a3-897f-9c4079abc47f"}]},{"resourceId":"3e736a49-bd0d-4133-bb5e-d7b523cdd45a","type":"service","identifier":"0385990496","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/3e736a49-bd0d-4133-bb5e-d7b523cdd45a"}]},{"resourceId":"3c51b416-0881-4322-83f5-6548f1753e92","type":"service","identifier":"0385990497","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/3c51b416-0881-4322-83f5-6548f1753e92"}]},{"resourceId":"2f01e215-0872-4af4-a146-7941a48bba9c","type":"service","identifier":"0385990498","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/2f01e215-0872-4af4-a146-7941a48bba9c"}]},{"resourceId":"f08ee820-9372-4d83-bb02-fd30e0263f3c","type":"service","identifier":"0385990499","family":"isdn2","status":"unknown","state":"created","creationType":"transition","validation":{"status":"unknown"},"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/f08ee820-9372-4d83-bb02-fd30e0263f3c"}]}],"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/418368ec-8b40-45a2-a93a-aa30a59b3787/resources"}]}},"result":"success","type":"transition::create","properties":{"transitions":[{"type":"service","target":{"type":"cwp"},"properties":{"identifiers":[{"identifier":"0314419400","attributes":null},{"identifier":"0385990400-0385990499","attributes":null}],"family":"isdn2"}}],"metadata":{"batchId":"85ad590c-602a-47cc-8aea-099c8f55587f","createdAt":"2019-11-15T09:40:53.806Z","updatedAt":"2019-11-15T09:40:53.806Z"}}}]}}';
        String success_Error = '{"code": "500","message": "Discovery service failed with error:ValidationException: One or more parameter values were invalid: An AttributeValue may not contain an empty string"}';
        String success_Exception = '';
        String error_422 = '{"error":{"code":"TM4009","message":"Found existing Transition in progress","details":"Resources are part of another in_progress Transition: TransitionId: 418368ec-8b40-45a2-a93a-aa30a59b3787 - ResourceId: 61474905616,TransitionId: 1d885ccd-9d14-40f2-94d4-d248cc500d37 - ResourceId: 61474905629,TransitionId: 606af294-b450-41df-8032-7812ca85354b - ResourceId: 61474905628,TransitionId: cd7ecaef-c5c4-46bd-9020-d3de96d46431 - ResourceId: 61474905618","timestamp":"2021-02-17T08:08:48+00:00"}}';
        if(resType.contains('success_acknowledgement')){
            res.setBody(success_acknowledgement);
            res.setStatusCode(202);
        }
        else  if(resType.contains('success_Error')){
            res.setBody(success_Error);
            res.setStatusCode(400);
        }
        else if(resType.contains('error_422')){
            res.setBody(error_422);
            res.setStatusCode(422);
        }
        return res;
    }
}