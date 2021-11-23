import { track } from "lwc";

const TransformMixin = (base) =>
  class Transformation extends base {
    @track selectedSolutionMap = "";
    @track selectedPcMap = "";
    @track selectedTabMap = "";
    @track selectedTabSchema = "";
    @track isRightSection = false;
    @track isMetaData = true;
    /**
     * @desc Transform the Order Enrichment basket response for rendering the UI.
     * Response have solution list -> component list -> schema Wrapper -> PC1, PC2.
     */
    _transformRecords() {
      this._createSolutionList();
      this._createComponentList();
    }

    /**
     * @desc Create a solution list array from available solutions of the basket.
     */
    _createSolutionList() {
      this.solutionList = Object.keys(this.basketRecordsDetail).map(
        (solution, idx) => {
          // Concatenate the solution and solution id to access the solution from the this.basketRecordsDetail.
          const solutionKey = `${this.basketRecordsDetail[solution].solution}-${this.basketRecordsDetail[solution].solutionId}`;
          return {
            label: this.basketRecordsDetail[solution].solution,
            id: this.basketRecordsDetail[solution].solutionId,
            solutionKey,
            isSelected: idx === 0 ? true : false
          };
        }
      );
      this.selectedSolution = this.solutionList[0];
    }

    /**
     * @desc Create a component list for the selected solution
     */
    _createComponentList() {
      let selectedSolutionMap =
        this.basketRecordsDetail[this.selectedSolution.solutionKey];
      const selectedSolutionMapTemp = selectedSolutionMap.componentList.map(
        (component) => {
          component.componentName =
            component.SchemaWrapper[0].Product_Definition_Name__c;
          component.buttonConfig = {
            label: "Select All"
          };
          component.SchemaWrapper = this._sortingTabs(component.SchemaWrapper);
          component.tabList = this._creatingTabList(component.SchemaWrapper);
          // conver Attribute_Json__c from string to object
          component.SchemaWrapper = component.SchemaWrapper.map((schema) => {
            if (typeof schema.Attribute_Json__c === "string") {
              schema.Attribute_Json__c = JSON.parse(schema.Attribute_Json__c);
            }
            return {
              ...schema
            };
          });
          // clone the schemaWrapper to all the PCs.
          const pcList = component.productConfigurationList.map((pcItem) => {
            return {
              ...pcItem,
              isSelected: false,
              isChecked: false,
              isVisible: true,
              schema: [...JSON.parse(JSON.stringify(component.SchemaWrapper))],
              tabList: [...JSON.parse(JSON.stringify(component.tabList))],
              componentName: component.componentName,
              sortingId: pcItem.Name.match(/\d+/)
            };
          });
          component.productConfigurationList = pcList;
          return component;
        }
      );
      this.selectedSolutionMap = selectedSolutionMapTemp;

      // sort the PCs
      this.selectedSolutionMap.forEach((component) => {
        component.productConfigurationList =
          component.productConfigurationList.sort(
            (a, b) => a.sortingId - b.sortingId
          );
      });
      this.selectedPcMap =
        selectedSolutionMapTemp[0].productConfigurationList[0];
      this.selectedPcMap.isSelected = true;

      this._executeTabRules();
      this._setActiveSchemaMaps();
      this._valuePrepopulate();
      this._executeValidationRule();
      // localStorage.setItem("selectedTabSchema", JSON.stringify(this.selectedTabSchema));
    }

    /**
     * @desc set right side content of meta data form based on the active selectedPcMap
     */
    _setActiveSchemaMaps() {      
      this.selectedTabMap = {
        schema: { ...this.selectedPcMap.schema },
        tabList: [...this.selectedPcMap.tabList],
        selectedTab: 0
      };
      this.selectedTabSchema = {
        ...this.selectedTabMap.schema[0].Attribute_Json__c
      };
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        this.isRightSection = true;
      });
    }

    /**
     * @desc Sorting the tabs based on the Tab_Order__c attributes.
     * @param {Array} arrayItems - Array of collection
     * @return {Array} Return the tabs in Ascending order
     */
    _sortingTabs(arrayItems) {
      let sortedArray = [];
      sortedArray = arrayItems.sort(
        (a, b) => parseInt(a.Tab_Order__c, 8) - parseInt(b.Tab_Order__c, 8)
      );
      return sortedArray;
    }

    /**
     * @desc Create the tablist for pathTabs component
     * @param {Array} arrayItems - Array of collection
     */
    _creatingTabList(arrayItems) {
      const tabs = arrayItems.map((arrayItem) => {
        return {
          label: arrayItem.Tab_Name__c,
          customClasses: "",
          id: arrayItem.Id
        };
      });
      return tabs;
    }

    /**
     * @desc Iterate through the Order Enrichment records and compare with
     * selected PC's schema attributes
     */
    _valuePrepopulate() {
      if (this.selectedPcMap.Order_Enrichments__r) {
        const oeRecords = this.selectedPcMap.Order_Enrichments__r.records[0];
        Object.keys(this.selectedTabMap.schema).forEach((schemaIdx, idx) => {
          this.selectedTabMap.schema[idx].Attribute_Json__c.attributes.forEach(
            (attribute) => {
              if (attribute.showInUI) {
                if (oeRecords[attribute.oeApiName] && !attribute.value) {
                  attribute.value = attribute.defaultValue || "";
                  const recordValue = oeRecords[attribute.oeApiName].split("::")[1]; 
                  // if (!attribute.value && recordValue) {
                  //   attribute.value = recordValue;
                  // }
                  // if (attribute.value && recordValue !== attribute.value) {
                  //   return;
                  // }
                  if (recordValue && !attribute.oldValue) {
                    attribute.value = recordValue;
                  }
                  if (!attribute.oldValue) {
                    attribute.oldValue = attribute.value; 
                  }                  
                } else if (oeRecords[attribute.oeApiName] && attribute.value) {
                  const recordValue = oeRecords[attribute.oeApiName].split("::")[1];
                  if (recordValue !== attribute.value) {
                    return false;
                    // oeRecords[attribute.oeApiName] = "";
                  }
                }
              }
            }
          );
        });
      }
    }
  };

export default TransformMixin;