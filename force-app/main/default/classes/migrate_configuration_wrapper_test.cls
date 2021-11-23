@isTest
public class migrate_configuration_wrapper_test {
	@isTest
    public static void testWrapper() {
        migrate_configuration_wrapper test = new migrate_configuration_wrapper();
        test.configCurrency = '';
        test.orderEnrichmentSave = '';
        test.attributes = new List<migrate_attribute_wrapper>();
        test.other = '';
        test.parent = '';
        test.statusMessage = '';
        test.replacedConfigId = '';
        test.solutionId = '';
        test.status = True;
        test.name = '';
        test.configurationName = '';
        test.configurationStatus = '';
        test.errorMessage = '';
        test.guid = '';
        test.id = '';
        test.oneOffPrice = 1.1;
        test.totalContractValue = 1.1;
        test.recurringPrice = 1.1;
        test.contractTerm = 1.1;
        test.error = True;
        test.disabled = True;
        test.dirty = True;
		System.assertEquals(false, test.dirty);
    }
}