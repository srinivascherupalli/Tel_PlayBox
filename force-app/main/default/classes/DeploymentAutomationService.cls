public interface DeploymentAutomationService {
	
    void clearAllCustomSettings();
    void runAllCustomSettings();
    void runAllCustomMetadaTypes();
    void runAllDataSetup();
    void clearAllDataSetup();
}