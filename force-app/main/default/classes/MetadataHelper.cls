/**
 *  Metadata helper class
*/
public with sharing class MetadataHelper {
	//private static Map<String, Schema.SObjectType> schemaMap = Constants.GLOBAL_DESCRIBE;
	private static Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

	/**
	 * @description : Returns the schema information about the fields.
	 * @return      : List<FieldMetadataWrapper>
	*/
	public static List<FieldMetadataWrapper> generateFieldMetadata(String objectName, List<String> fieldAPINameList) {
		List<FieldMetadataWrapper> fieldMetadataList = new List<FieldMetadataWrapper>();
		Schema.SObjectType sObjectSchema = schemaMap.get(objectName);
		Map<String, Schema.SObjectField> fieldMap = sObjectSchema.getDescribe().fields.getMap();
		for (String fieldName: fieldAPINameList) {
			if(fieldMap.containsKey(fieldName)) {
				Schema.DescribeFieldResult fieldDescribeResult =  fieldMap.get(fieldName).getDescribe();
				fieldMetadataList.add(
					new FieldMetadataWrapper(
						fieldDescribeResult.getName(),
						fieldDescribeResult.getLabel(),
						fieldDescribeResult.getType()
					)
				);
			}
		}
		return fieldMetadataList;
	}

	/**
	 * @description : Returns if the org is multi currecny enabled or not.
	 * @return      : Boolean
	*/
	public static Boolean isMultiCurrencyEnabled() {
		return UserInfo.isMultiCurrencyOrganization();
	}

	/**
	 * @description : A wrapper which will provide the details of the fields.
	*/
	public with sharing class FieldMetadataWrapper {
		public string name;
		public string label;
		public string type;
		public FieldMetadataWrapper(String name, String label, Schema.DisplayType type) {
			this.name = name;
			this.label = label;
			this.type = type.name();
		}
	}
}