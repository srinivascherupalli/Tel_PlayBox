global with sharing class CustomButtonOrderDecompositionSimulation extends csbb.CustomButtonExt { 
    public String performAction (String basketId) { 
        String newUrl = '/apex/csordtelcoa__OrderDecompositionSimulation?Id=' + basketId; 
        return '{"status":"ok", "redirectURL":"' + newUrl + '"}'; 
    } 
}