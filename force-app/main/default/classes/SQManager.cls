/*
 *   Description : This class exposes service qualification related operations to required controllers
 *
*/
public with sharing class SQManager {
	
	private SQManager()
	{
	}
    /**
    * Method to fetch the SQ result for Site
    * @params SiteSQRequestDTO
    * @return SiteSQResponseDTO
    */
    
    public static SiteSQResponseDTO fetchSiteSQResult(SiteSQRequestDTO request) {
        return SQService.checkSQForSite(request);
    }
    
     /**
    * Method to fetch the SQ result for Transition
    * @params TransitionSQRequestDTO
    * @return TransitionSQResponseDTO
    */
    
    public static TransitionSQResponseDTO fetchTransitionSQResult(TransitionSQRequestDTO request) {
        return SQService.checkSQForTransition(request);
    }
    
     /**
    * Method to fetch the SQ result for Move
    * @params MoveSQRequestDTO
    * @return MoveSQResponseDTO
    */
    
    public static MoveSQResponseDTO fetchMoveSQResult(MoveSQRequestDTO request) {
        return SQService.checkSQForMove(request);
    }
    
     /**
    * Method to fetch the SQ result for Move
    * @params FullServiceabilitySQRequestDTO
    * @return FullServiceabilitySQResponseDTO
    */
    
    public static FullServiceabilitySQResponseDTO fetchFullServicibilitySQResult(FullServiceabilitySQRequestDTO request) {
        return SQService.checkSQForFullServiceability(request);
    }
    
     /**
    * Method to fetch the SQ result for Move
    * @params PortInSQRequestDTO
    * @return PortInSQResponseDTO
    */
    
    public static PortInSQResponseDTO checkSQForPortability(PortInSQRequestDTO request) {
        return SQService.checkSQForPortability(request);
    }
}