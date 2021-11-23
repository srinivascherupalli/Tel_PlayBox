public without sharing class SimReplaceServiceSpecUtils {

 /*********************************************************************************************************************************
     * Method Name      :   updateServiceSpecAttachment
     *return            :   void
     *Story             :   EDGE-53883/82202  method to handle sim replacement servicespecs update
     *Developer            :   Shubhi
     * modified for INC000092992238 shubhi/manish
     * Jawahar - Added NGEM product code as part of Prod incident. INC000094360478.
    **********************************************************************************************************************************/
     public static void updateServiceSpecAttachment(String speccode,Map<id,csord__Service__c> serviceMap,Map<String,Subwrapper> subWrapperToIdMap){
       Map<String, CS_SpecificationDTO.ServiceSpecification> specsToBeUpdated = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
       Map<Id,Attachment> attchmap= new Map<Id,Attachment>();
       List<Attachment> attachmentListTobeUpdated = new List<Attachment>();
        if(serviceMap.keyset().IsEmpty())
        {
            return;
        }
            //fetching attachment body and modifying it based on service map 
        for(Attachment att:[select ID, name, body, parentId from Attachment where parentId in: serviceMap.keyset() and name = 'ServiceSpecifications.json']){
            String newServiceAttachmentStr = att.body.toString();
            Map<String, Object> updatedResults = (Map<String, Object>)JSON.deserializeUntyped(newServiceAttachmentStr);
            List<Object>lstSpecifications=(List<Object>)updatedResults.get('specifications');
            List<Object> newlstSpecifications = new List<Object>();
            for(Object spec:lstSpecifications){
                Map<String, Object> specificationAttributes = (Map<String, Object>)spec;
                ProductIdentifier__c pMob=ProductIdentifier__c.getValues('mobility');
                string specIdentifier1=pMob.speccode__c;
                ProductIdentifier__c mobdevice=ProductIdentifier__c.getValues('mob_device');
                string specIdentifier2=mobdevice.speccode__c;
                // EDGE-165020/EDGE-168784 || start // Added as part of incident INC000094360478. 
                 ProductIdentifier__c ngemMobility=ProductIdentifier__c.getValues('NGEM_Mobility');
                string specIdentifier3=ngemMobility.speccode__c;
                // EDGE-165020/EDGE-168784 || end   // Added as part of incident INC000094360478.
                if(specificationAttributes!=null && specificationAttributes.get('code')==speccode && (speccode.contains(specIdentifier1) || speccode.contains(specIdentifier3))) //  added OR condition EDGE-165020
                {
                    
                    Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('additionalAttributes'); //added INC000092992238
                    String simSerialNumber=subWrapperToIdMap.get(serviceMap.get(att.parentId).csord__Subscription__c).simSerialNumber;
                    //EDGE-174221 Start
          String SimAvailabilityType=subWrapperToIdMap.get(serviceMap.get(att.parentId).csord__Subscription__c).SimAvailabilityType;
          
                    if (attributesMap!=null && SimAvailabilityType!='' && SimAvailabilityType=='New SIM')
                    {
                        attributesMap.put('ShippingRequired','TRUE'); //if sim serial is there shipping not required
                    }
                    else
                    {
                        attributesMap.put('ShippingRequired','FALSE');
                    }
          //EDGE-174221 END
                    
                    if (attributesMap!=null)
                    {
                        specificationAttributes.put('additionalAttributes',(Object)attributesMap); //INC000092992238
                        specificationAttributes.put('status','Modified');   // updating status to modify for sim replacement mobility specifications
                    }
                    newlstSpecifications.add((Object)specificationAttributes);        
                }
                //EDGE-113351 - Added below code to make shipping req as false in case of mobile device and device for Fullfillment spec 423
                else if (specificationAttributes!=null && specificationAttributes.get('code')==speccode && speccode.contains(specIdentifier2))
                {
                    Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('additionalAttributes');//INC000092992238
                    //EDGE-174221 Start
          String SimAvailabilityType=subWrapperToIdMap.get(serviceMap.get(att.parentId).csord__Subscription__c).SimAvailabilityType;
          
                    if (attributesMap!=null && SimAvailabilityType!='' && SimAvailabilityType=='New SIM')
                    {
                        attributesMap.put('ShippingRequired','TRUE'); //if sim serial is there shipping not required
                    }
                    else
                    {
                        attributesMap.put('ShippingRequired','FALSE');
                    }
          //EDGE-174221 END    
                    newlstSpecifications.add((Object)specificationAttributes);        

                }
                else{
                    newlstSpecifications.add(spec);
                }
            }            
            updatedResults.put('specifications',newlstSpecifications);
            String updatednewServiceattachmentstr = JSON.serializePretty(updatedResults);
            system.debug('updatednewServiceattachmentstr'+updatednewServiceattachmentstr);
            att.Body=Blob.valueOf(updatednewServiceattachmentstr);
            attachmentListTobeUpdated.add(att);            
        }
        if(attachmentListTobeUpdated.size()>0)
        {
            try{
                update attachmentListTobeUpdated;
            }
            catch(Exception e)
            {
                system.debug('Exception'+e);
            }
        }
    }
    }