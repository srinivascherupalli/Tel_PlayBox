import { track } from "lwc";
import doInsertOE from "@salesforce/apex/orderEnrichmentUtill.doInsertOE";

const PayloadMixin = (base) =>
  class Payload extends base {
    @track oePayload = {};

    /**
     * @desc Iterating through the all PCs of the solution and submit it.
     * First prepare the payload for custom OE object. Then invoke the apex method
     * with payload.
     */
    async saveForm() {
      let payload = {
        Order_Enrichment__c: [],
      };
      let attributeList = [];
      this.selectedSolutionMap.forEach((component) => {
        component.productConfigurationList.forEach((pc) => {
          let pcItem = { cobjectType: "Order_Enrichment__c" };
          pcItem.Product_Configuration__c = pc.Id;

          let pcAttributeItem = { sobjectType: "cscfga__Product_Configuration__c" };
          pcAttributeItem.pcId = pc.Id;
          pcAttributeItem.attributeList = [];

          pc.schema.forEach((schemaItem) => {
            schemaItem.Attribute_Json__c.attributes.forEach((attribute) => {
              if (attribute.showInUI && attribute.value) {
                // OE List payload start
                pcItem[
                  attribute.oeApiName
                ] = `${attribute.name}::${attribute.value}`;
                // Lookup Field needs to be saved with name::"{label,value}"
                if (attribute.type === "Lookup" && attribute.displayValue) {
                    // Find the selected value from the options
                    const selectedVal = {
                      label: attribute.displayValue,
                      value: attribute.value
                    };
                    pcItem[attribute.oeApiName] = `${
                      attribute.name
                    }::${JSON.stringify(selectedVal)}`;
                }
                // OE list payload end
                // attribute list payload start
                let attrItem = { cobjectType: "cscfga__Attribute__c" };
                attrItem.Name = attribute.name;
                attrItem.cscfga__Value__c = attribute.value;
                if (attribute.type === "Lookup") {
                  if (attribute.value && attribute.value.indexOf("label") >= 0) {
                    const valueObj = {
                      ...JSON.parse(attribute.value)
                    };
                    if (valueObj.label) {
                      attrItem.cscfga__Value__c = valueObj.value;
                    }
                  }                
                }
                pcAttributeItem.attributeList.push(attrItem);
              }
            });
          });
          if (Object.keys(pcItem).length > 2) {
            payload.Order_Enrichment__c.push(pcItem);
            attributeList.push(pcAttributeItem);
          }
        });
      });
      // Async function invoking is starting here.
      try {
        this.isLoading = true;
        const response = await doInsertOE({
          oeList: payload.Order_Enrichment__c,
          attributeList
        });
        console.log(JSON.stringify(response));
        const closesignalEvent = new CustomEvent('closesignal');
        // Fire the custom event
        this.dispatchEvent(closesignalEvent);
      } catch (err) {
        // console.log(err);
      } finally {
        this.isLoading = false;
      }
    }

    handleGoBack() {
      window.history.back();
    }
  };
export default PayloadMixin;