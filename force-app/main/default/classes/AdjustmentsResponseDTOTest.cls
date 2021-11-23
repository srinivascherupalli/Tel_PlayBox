/*************************************************************************************************
EDGE -104930
Name: AdjustmentsResponseDTOTest
Description: Test class for AdjustmentsResponseDTO
Author:Mahima 
***************************************************************************************************/
@isTest
public class AdjustmentsResponseDTOTest {
    
    /**********************************
    EDGE-104930 
    Description: creating Success DTO
    Author: Mahima
    ************************************/
    @isTest static void testDtoStructure() {
        AdjustmentsResponseDTO adjDTO = new AdjustmentsResponseDTO();
        adjDTO.code= 200;
        adjDTO.message='Success';
        adjDTO.status= 200;
        adjDTO.billingAccountNumber='452364263467';
        adjDTO.adjustments = new List<AdjustmentsResponseDTO.Adjustment>();
        
        AdjustmentsResponseDTO.Adjustment adjData= new AdjustmentsResponseDTO.Adjustment();    
        adjData.description ='100';
        adjData.dateApplied ='100';
        adjData.adjustmentAmount =100;
        adjData.amountApplied=100;
        adjData.amountUnapplied =100;
        adjData.adjustmentId='100';    
        adjDTO.adjustments.add(adjData);
        
        System.assertEquals(adjDTO.adjustments.size()>0, true);
        
    }
    
    /**********************************
    EDGE-104930 
    Description: creating Error DTO
    Author: Mahima
    ************************************/
    @isTest static void testDtoErrorStructure() {
        AdjustmentsResponseDTO adjDTO = new AdjustmentsResponseDTO();
        adjDTO.code= 422;
        adjDTO.message='Error';
        adjDTO.status= 422;
        adjDTO.billingAccountNumber='452364263467';
        adjDTO.errors = new List<AdjustmentsResponseDTO.Error>();
        
        
        AdjustmentsResponseDTO.Error errData= new AdjustmentsResponseDTO.Error();    
        errData.code =422;
        errData.field ='100';
        errData.message ='100';
          
        adjDTO.errors.add(errData);
        
        System.assertEquals(adjDTO.errors.size()>0, true);
        
    }

}