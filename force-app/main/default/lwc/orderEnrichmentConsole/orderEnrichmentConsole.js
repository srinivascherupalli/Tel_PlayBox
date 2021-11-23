import { LightningElement, track, api } from "lwc";
// import styles from "@salesforce/resourceUrl/style";
import { loadStyle } from "lightning/platformResourceLoader";
import metaDataStyle from "@salesforce/resourceUrl/metaDataFormStyle";
import getSolutionsDetail from "@salesforce/apex/orderEnrichmentUtill.getSolutionsDetail";
import mockData from "./config/kk";

import TransformMixin from "./mixins/TransformMixin";
import PayloadMixin from "./mixins/PayloadMixin";
import ValidationRulesMixin from "./mixins/ValidationRulesMixin";
import TabValidationRuleMixin from "./mixins/TabValidationRuleMixin";

export default class OrderEnrichmentConsole extends PayloadMixin(
  TransformMixin(ValidationRulesMixin(TabValidationRuleMixin(LightningElement)))
) {
  @api recordId;
  @api solutionId = "a4f2N0000002aR4";
  @api basketId = "a3Q2N0000004r3QUAQ";
  @api formTitle = "Order Enrichment Console";
  @track basketRecordsDetail = {};
  @track validationRules = [];
  @track tabValidationRules = [];
  @track CLONE_basketRecordsDetail = {};
  @track selectedSolution = {};
  @track solutionList = [];
  @track changedAttribute = {};
  @track changedComponent = {};
  @track isChangeEvent = false;
  activeTabId = 0;
  isLoading = false;
  isApplyConfig = false;

  connectedCallback() {
    this.getEnrichmentRecords();
    this.isShow = true;
  }

  // Load JS and CSS files after initial rendering
  renderedCallback() {
    Promise.all([loadStyle(this, metaDataStyle)])
      .then(() => {
        // console.log("success");
      })
      .catch((error) => {
        // eslint-disable-next-line no-console
        // console.log(error);
      });
  }

  /**
   * @desc Invoke the apex method for getting the OE records with the basket recordId.
   */
  async getEnrichmentRecords() {
    // this.basketRecordsDetail = mockData;
    // this._transformRecords();
    try {
      this.isLoading = true;
      const response = await getSolutionsDetail({
        // solutionId: "a4f2N0000002aR4"
        solutionId: this.solutionId
      });
      // // console.log(JSON.parse(response));
      this.basketRecordsDetail = JSON.parse(response);
      this._transformRecords();
    } catch (err) {
      console.log(err);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * @desc Unselect all the solution and select only user selected solution.
   * @param {Event Object} evt - change event object
   */
  handleSolutionChange(evt) {
    this.isRightSection = false;
    const solutionId = evt.currentTarget.dataset.solutionId;
    this.solutionList.map((solution) => {
      solution.isSelected = false;
      if (solution.id === solutionId) {
        solution.isSelected = true;
        // update the track property of selectedSolution
        this.selectedSolution = {
          ...solution
        };
      }
      return {
        ...solution
      };
    });
    this._createComponentList();
  }

  /**
   * @desc change the meta data form for user selected PC
   * @param {Event Object} evt - change event object
   */
  handlePCChange(evt) {
    this.isRightSection = false;
    const componentId = evt.currentTarget.dataset.componentId;
    const pcId = evt.currentTarget.dataset.pcId;
    const findComponent = this.selectedSolutionMap.find(
      (comp) => comp.componentName === componentId
    );
    const findPC = findComponent.productConfigurationList.find(
      (pc) => pc.Id === pcId
    );
    // unselect all the previous PCs of all component lists
    this.selectedSolutionMap.forEach((component) => {
      component.productConfigurationList.forEach((pc) => {
        pc.isSelected = false;
      });
    });
    this.selectedPcMap = findPC;
    this.selectedPcMap.isSelected = true;
    this._executeTabRules();
    this._setActiveSchemaMaps();
    this._valuePrepopulate();
    this._executeValidationRule();
  }

  /**
   * @desc change state for user selected PC
   * @param {Event Object} evt - change event object
   */
  handlePCSelect(evt) {
    evt.stopPropagation();
    this.isMetaData = false;
    const componentId = evt.currentTarget.dataset.componentId;
    const pcId = evt.currentTarget.dataset.pcId;
    const findComponent = this.selectedSolutionMap.find(
      (comp) => comp.componentName === componentId
    );
    this.selectedSolutionMap.forEach((component) => {
      component.productConfigurationList.forEach((pc) => {
        if (pc.Id === pcId) {
          pc.isChecked = !pc.isChecked;
        }
      });
    });

    // Find all checked PCs based on the isChecked
    const checkedPCs = findComponent.productConfigurationList.filter(
      (pc) => pc.isChecked
    );
    // Show the dialog when user has checked the PC and Checked PCs should be more than one.
    if (checkedPCs.length > 1) {
      this.isApplyConfig = true;
    } else {
      this.isApplyConfig = false;
    }
    this.isMetaData = true;
  }

  /**
   * @desc Show/Hide the tab content of the active tabs
   * @param {Event Object} evt - change event object
   */
  handleTabChange(evt) {
    this.isMetaData = false;
    this.activeTabId = parseInt(evt.detail, 10);

    this.selectedTabSchema = {
      ...this.selectedTabMap.schema[this.activeTabId].Attribute_Json__c
    };
    this._countCheckedPCs();
    this._executeValidationRule();
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.isMetaData = true;
    });
  }

  /**
   * @desc Count the all selected PCs and update the isApplyConfig as true If more than
   * one PC has selected
   * @param {Event Object} evt - change event object
   */
  _countCheckedPCs() {
    // Find the component of the PC
    this.changedComponent = this.selectedSolutionMap.find(
      (comp) => comp.componentName === this.selectedPcMap.componentName
    );
    // Find all checked PCs based on the isChecked
    const checkedPCs = this.changedComponent.productConfigurationList.filter(
      (pc) => pc.isChecked
    );
    // Show the dialog when user has checked the PC and Checked PCs should be more than one.
    if (checkedPCs.length > 1) {
      this.isApplyConfig = true;
    }
  }

  /**
   * @desc update the OE attribute value in the corresponding selected PC
   * @param {Event Object} evt - change event object
   */
  handleAttributeChange(evt) {
    const attributes = this.selectedTabSchema.attributes.map((attribute) => {
      if (evt.detail.name === attribute.name) {
        attribute.value = evt.detail.value;
        attribute.displayValue = evt.detail.displayValue;
      }
      return attribute;
    });
    this.selectedTabSchema.attributes = attributes;
    this._executeValidationRule();

    // Find the component of the PC
    this.changedComponent = this.selectedSolutionMap.find(
      (comp) => comp.componentName === this.selectedPcMap.componentName
    );
    this.changedAttribute = { ...evt.detail };
    if (!this.isApplyConfig) {
      this.isMetaData = false;
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        this.isMetaData = true;
      });
    }
    
  }

  /**
   * @desc Select/Unselect All the PCs available to the component list
   * @param {Event Object} evt - change event object
   */
  handleSelectAll(evt) {
    const componentId = evt.currentTarget.dataset.componentId;
    const findComponent = this.selectedSolutionMap.find(
      (comp) => comp.componentName === componentId
    );
    if (findComponent.buttonConfig.label === "Select All") {
      findComponent.buttonConfig.label = "Deselect All";
      // checked all the PCs available component
      findComponent.productConfigurationList.forEach((pc) => {
        pc.isChecked = true;
      });
      this.isApplyConfig = true;
    } else {
      findComponent.buttonConfig.label = "Select All";
      // unchecked all the PCs available component
      findComponent.productConfigurationList.forEach((pc) => {
        pc.isChecked = false;
      });
      this.isApplyConfig = false;
    }
  }

  /**
   * @desc Filter the PCs list based on the search text
   * @param {Event Object} evt - change event object
   */
  handleQuickSearch(evt) {
    const searchStr = evt.detail.value;
    this.selectedSolutionMap.forEach((component) => {
      component.productConfigurationList.forEach((pc) => {
        if (searchStr) {
          // If user entered some text show/hide PCs based on that
          if (pc.Name.toLowerCase().indexOf(searchStr) > -1) {
            pc.isVisible = true;
          } else {
            pc.isVisible = false;
          }
        } else {
          // else show all PCs.
          pc.isVisible = true;
        }
      });
    });
  }

  /**
   * @desc When More than one PC has selected in a component list, need to prompt the user
   * to he wants to apply those changes all checked PCs attributes.
   */
  handleApplyConfig() {
    this.changedComponent.productConfigurationList.forEach((pc) => {
      if (pc.isChecked) {
        pc.schema[this.activeTabId].Attribute_Json__c.attributes.forEach(
          (attribute) => {
            if (this.changedAttribute.name === attribute.name) {
              if (attribute.type === "Boolean") {
                attribute.isChecked = this.changedAttribute.isChecked;
              }
              // attribute.options = this.changedAttribute.options;
              if (attribute.type === "Lookup") {
                const findOptionIndex = this.changedAttribute.options.findIndex(
                  (opt) => opt.value === this.changedAttribute.value
                );
                // To prepopulate the value in lookup, need to set value obj as stringify
                attribute.value = JSON.stringify(
                  this.changedAttribute.options[findOptionIndex]
                );
                attribute.displayValue = this.changedAttribute.options[findOptionIndex].label;
                this._calculationFieldsUpdate(
                  this.changedAttribute.populateOptions[findOptionIndex],
                  this.changedAttribute.name
                );
              } else {
                attribute.value = this.changedAttribute.value;
              }
            }
          }
        );
      }
    });
    this.isMetaData = false;
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.isMetaData = true;
    });
    this.cancelPrompt();
  }

  /**
   * @desc When user selected Apply to all selected configuration, run this handler
   */
   handleNoApplyAll() {
    this.isMetaData = false;
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.isMetaData = true;
    });
   }

  /**
   * @desc Hide the prompt dialog of selected config
   */
  cancelPrompt() {
    this.isApplyModal = false;
    this.changedAttribute = {};
    this.changedComponent = {};
  }

  /**
   * @desc Update the input values while onchange
   * @param {Object} allColumns - all available columns
   * @param {String} lookupName
   */
  _calculationFieldsUpdate(allColumns, lookupName) {
    this.changedComponent.productConfigurationList.forEach((pc) => {
      if (pc.isChecked) {
        pc.schema[this.activeTabId].Attribute_Json__c.attributes.forEach(
          (attribute) => {
            if (attribute.lookup && lookupName === attribute.lookup) {
              attribute.value = allColumns[attribute.displayColumn];
              attribute.oldValue = "DEFAULT";
            }
          }
        );
      }
    });
  }
}