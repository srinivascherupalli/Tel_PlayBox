@isTest
public class EDMMACServiceUtilsTest {
    
    testMethod static void testparseMethod(){
        String json = '{"removed":[],'+
                        '"oldServiceId":"oldServiceId_XXX",'+
                        '"newServiceId":"newServiceId_YYY",'+
                        '"changed":[{"instanceId":"","guid":"11e37026-f241-4c7b-63ec-b5a29607cec9","changedNonCommercialAttributes":[],"changedAttributes":["parentSpec"]},'+
                                   '{"instanceId":"","guid":"91147347-6ccb-4e83-54a5-85b5fad77b3e","changedNonCommercialAttributes":[],"changedAttributes":["IPVPNProductInstanceID"]},'+
                                   '{"instanceId":"","guid":"7c950bdb-3a81-7d3d-3319-82ac11a5b546","changedNonCommercialAttributes":[],"changedAttributes":["IPVASInternetPortProductInstanceID"]}],'+
                        '"added":[]}';
        
        //String JSONStr = '{"removed":[],'+ '"oldServiceId":"oldServiceId_XXX",'+ '"newServiceId":"newServiceId_YYY",'+ '"changed":[{"instanceId":"","guid":"91573e8a-1952-d9c4-83da-9c6f940c3351","changedNonCommercialAttributes":[],"changedAdditionalAttributes":[],"changedAttributes":["Bandwidth","Appointment_EndDateTime","Appointment_StartDateTime","Appointment_ID"]},'+ '{"instanceId":"","guid":"0dc3082a-a09b-7969-386e-a079cd315c5d","changedNonCommercialAttributes":[],"changedAttributes":["UCEnterpriseProductInstanceID","PrimaryAccessProductInstanceID"]},'+ '{"instanceId":"","guid":"6be16f33-edf3-380b-2e9a-5aed4286b7ac","changedNonCommercialAttributes":[],"changedAttributes":["parentSpec"]},'+ '{"instanceId":"","guid":"17159a2f-fade-ecb1-219c-1b862f059889","changedNonCommercialAttributes":[{'+ '"removedNonCommercialProductConfigurations":["a3T2O0000003ZntUAE"],"name":"Voice Numbers","changedNonCommercialProductConfigurations":[],"addedNonCommercialProductConfigurations":[]}],'+ '"changedAttributes":["parentSpec"]},'+ '{"instanceId":"","guid":"08c370d7-75c6-6728-2eca-8ef69553ee6b","changedNonCommercialAttributes":[],"changedAttributes":["IPVPNProductInstanceID"]}],"added":[]}';
        String JSONStr = '{"removed":[],'+ '"oldServiceId":"oldServiceId_XXX",'+ '"newServiceId":"newServiceId_YYY",'+ '"changed":[{"instanceId":"","guid":"91573e8a-1952-d9c4-83da-9c6f940c3351","changedNonCommercialAttributes":[],"changedAdditionalAttributes":[],"changedAttributes":["Bandwidth","Appointment_EndDateTime","Appointment_StartDateTime","Appointment_ID"]},'+ '{"instanceId":"","guid":"0dc3082a-a09b-7969-386e-a079cd315c5d","changedNonCommercialAttributes":[],"changedAttributes":["UCEnterpriseProductInstanceID","PrimaryAccessProductInstanceID"]},'+ '{"instanceId":"","guid":"6be16f33-edf3-380b-2e9a-5aed4286b7ac","changedNonCommercialAttributes":[],"changedAttributes":["parentSpec"]},'+ '{"instanceId":"","guid":"17159a2f-fade-ecb1-219c-1b862f059889","changedNonCommercialAttributes":[{'+ '"removedNonCommercialProductConfigurations":["a3T2O0000003ZntUAE"],"name":"Voice Numbers","changedNonCommercialProductConfigurations":[{"replacedProductConfigurationId":"abcde", "productConfigurationId":"abcde", "changedAttributes":[]}],"addedNonCommercialProductConfigurations":[]}],'+ '"changedAttributes":["parentSpec"]},'+ '{"instanceId":"","guid":"08c370d7-75c6-6728-2eca-8ef69553ee6b","changedNonCommercialAttributes":[],"changedAttributes":["IPVPNProductInstanceID"]}],"added":[]}';
        
        EDMMACServiceUtils.serviceSpecDelta srvDelta =  new EDMMACServiceUtils.serviceSpecDelta();
        srvDelta = EDMMACServiceUtils.parse(JSONStr);
        
        System.debug('srvDelta.changed===>'+srvDelta.changed);
        System.assertEquals('oldServiceId_XXX', srvDelta.oldServiceId);
        System.assertEquals('newServiceId_YYY', srvDelta.newServiceId);
        System.assertEquals(false, srvDelta.changed.isEmpty() );
        System.assertEquals('Bandwidth', srvDelta.changed[0].changedAttributes[0]);
        System.assertEquals(true, srvDelta.changed[0].changedAdditionalAttributes.isEmpty());
        System.assertEquals(true, srvDelta.changed[0].changedNonCommercialAttributes.isEmpty());
        System.assertEquals('', srvDelta.changed[0].instanceId);
        System.assertEquals('91573e8a-1952-d9c4-83da-9c6f940c3351', srvDelta.changed[0].guid);
        System.assertEquals(true, srvDelta.added.isEmpty());
        System.assertEquals(true, srvDelta.removed.isEmpty());
        System.assertEquals(false, srvDelta.changed[3].changedNonCommercialAttributes.isEmpty());
        if(!srvDelta.changed[3].changedNonCommercialAttributes.isEmpty()){
            System.assertEquals(false, srvDelta.changed[3].changedNonCommercialAttributes[0].removedNonCommercialProductConfigurations.isEmpty());
            System.assertEquals('Voice Numbers', srvDelta.changed[3].changedNonCommercialAttributes[0].name);
            System.assertEquals(false, srvDelta.changed[3].changedNonCommercialAttributes[0].changedNonCommercialProductConfigurations.isEmpty());
			System.assertEquals(true, srvDelta.changed[3].changedNonCommercialAttributes[0].changedNonCommercialProductConfigurations[0].changedAttributes.isEmpty());
            System.assertEquals('abcde', srvDelta.changed[3].changedNonCommercialAttributes[0].changedNonCommercialProductConfigurations[0].replacedProductConfigurationId);
           	System.assertEquals('abcde', srvDelta.changed[3].changedNonCommercialAttributes[0].changedNonCommercialProductConfigurations[0].productConfigurationId);
            System.assertEquals(true, srvDelta.changed[3].changedNonCommercialAttributes[0].addedNonCommercialProductConfigurations.isEmpty());
        }
    }
}