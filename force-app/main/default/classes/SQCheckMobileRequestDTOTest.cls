/*******************************************************************************************************************
Name : SQCheckMobileRequestDTOTest
EDGE-> 107149
Description : Test class for SQCheckMobileRequestDTO
====================================================================================================================*/
@isTest
public class SQCheckMobileRequestDTOTest {
    @isTest
    public static  void testParse() {
		String json = '{"data":{"resources":[{"resourceId":"61459011237"},{"resourceId":"61459011238"}],"attributes":{"fieldList":"all"}}}';
		SQCheckMobileRequestDTO obj = SQCheckMobileRequestDTO.parse(json);
		System.assert(obj != null);
	}

}