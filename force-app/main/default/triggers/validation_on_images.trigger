trigger validation_on_images on Knowledge__kav (before insert, before update) {
    
    for(Knowledge__kav kav:trigger.new){
        if(String.isBlank(kav.Featured_Image__c)){
            kav.Featured_Image__c = 'https://telstra-brand.s3-ap-southeast-2.amazonaws.com/elements/1929/previews/1820292467.jpg';
        }
    }
}