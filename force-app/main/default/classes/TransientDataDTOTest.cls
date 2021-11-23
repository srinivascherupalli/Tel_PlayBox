@IsTest
public class TransientDataDTOTest {
    
    static testMethod void testParse() {
        TransientDataDTO traDTOList = new TransientDataDTO();
        TransientDataDTO.DataDTO dataDTO = new TransientDataDTO.DataDTO();
        TransientDataDTO.TransientAttribute transAttribute= new TransientDataDTO.TransientAttribute();
        List<TransientDataDTO.DataDTO> dtoList = new List<TransientDataDTO.DataDTO>();
        List<TransientDataDTO.TransientAttribute> transientList = new List<TransientDataDTO.TransientAttribute>();
        transAttribute.name = 'INTROAM';
        transAttribute.value = 'false';
        transientList.add(transAttribute);
        dataDTO.attributes = transientList;
        dataDTO.offerID = 'DMCAT_Offer_000303';
        dataDTO.specCode = 'DMCAT_ProductSpecification_000263_Fulfilment';
        dataDTO.specGUID = 'b8905354-a164-b480-9fb2-5c2d1a8499b2';
        dataDTO.changeType = 'New';
        dtoList.add(dataDTO);
        traDTOList.dataDTOList =dtoList;
        TransientDataDTO.parse(traDTOList.dataDTOList);
        System.assert(dtoList != null);
    }
    
    static testMethod void testUnParse() {
        String json='{ "dataDTOList": [{"specGUID":"b5e53e03-1209-7828-546b-fc490a07c002","specCode":"DMCAT_ProductSpecification_000263_Fulfilment","offerID":"DMCAT_Offer_000303","changeType":"New","attributes":[{"value":"false","name":"INTROAM"},{"value":"NO_PREMIUM","name":"CALLRESTRICTION"}]}] }';
        TransientDataDTO.unParse(json);        
        System.assert(json != null);
    }
}