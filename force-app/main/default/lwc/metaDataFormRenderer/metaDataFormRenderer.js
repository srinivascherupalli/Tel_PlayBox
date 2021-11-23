/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track } from "lwc";
import styles from "@salesforce/resourceUrl/metaDataFormStyle";
import { loadStyle } from "lightning/platformResourceLoader";
import doLookupContactDetails from "@salesforce/apex/orderEnrichmentUtill.doLookupContactDetails";
import doLookupDeliveryAddress from "@salesforce/apex/orderEnrichmentUtill.doLookupDeliveryAddress";
import inputMap from "./config/inputMap";

export default class MetaDataFormRenderer extends LightningElement {
  @api basketId = "";
  @api attributes = {};
  @api validationRules = [];
  @api isApplyConfig = false;
  @api selectedTabMap = {};
  @track isFirstRendered = false;
  @track uiAttributesModel = {};
  @track mandatoryErrorMessages = [];
  @track changedAttribute = {};
  @track changedAttributeValue = "";
  isApplyAll = false;
  isApplyPopup = false;

  connectedCallback() {
    this._transformMetaData();
  }

  // Load JS and CSS files after initial rendering
  renderedCallback() {
    Promise.all([loadStyle(this, styles)])
      .then(() => {
        // console.log("success");
      })
      .catch((error) => {
        // eslint-disable-next-line no-console
        // console.log(error);
      });
  }

  /**
   * @desc Iterating through the meta data attributes. Create the field map for
   * rendering the lightning components with the necessary properties such as required, checked,
   * options, value ..etc;
   */
  _transformMetaData() {
    // console.log(this.attributes);
    const attributes = this.attributes.map((attribute, i) => {
      let field = {};
      let isChecked = false;
      if (inputMap.has(attribute.type)) {
        field = {
          ...inputMap.get(attribute.type)
        };
      }
      if (field.type === "checkbox") {
        // When checkbox value is not empty, we can set checked attribute as true.
        isChecked = attribute.value === "Yes" ? true : false;
      }
      const mappedAttribute = {
        id: i,
        readOnly: field.isReadOnly,
        ...attribute,
        options: [...(attribute.options || [])],
        label: attribute.label || "Label",
        value: attribute.value || "",
        isChecked,
        field: {
          ...field,
          isSpinner: false
        }
      };
      return mappedAttribute;
    });

    this.uiAttributesModel = attributes.filter(
      (attribute) => attribute.showInUI
    );
  }

  /**
   * @desc Update the input values while onchange
   * @param {Object} allColumns - all available columns
   * @param {String} lookupName
   */
  _calculationFieldsUpdate(allColumns = {}, lookupName, isPillRemove) {
    this.uiAttributesModel.forEach((attribute) => {
      if (attribute.lookup && lookupName === attribute.lookup) {
        if (Object.keys(allColumns).length > 0 && !isPillRemove) {
          attribute.value = allColumns[attribute.displayColumn];
        } else {
          attribute.value = ""; // need to empty all while removing the pill
        }
        const selectEvent = new CustomEvent("attributechange", {
          detail: {
            ...attribute
          }
        });
        this.dispatchEvent(selectEvent);
      }
    });
  }

  /**
   * @desc When user enabled the apply to all config, update the isApplyAll
   * @param {Event Object} evt - change event object
   */
  handleToggleChange(evt) {
    this.isApplyAll = evt.detail.toggleValue;
  }

  // open the apply all popup
  handleOpenPopup(evt) {
    this.isApplyPopup = this.isApplyConfig;
    const fieldId = evt.currentTarget.dataset.fieldId; // fieldId from dataset
    const changeField = this.uiAttributesModel.find(
      (item) => item.name === fieldId
    );
    if (this.isApplyPopup) {
      this.changedAttribute = {
        ...JSON.parse(JSON.stringify(changeField))
      };
    }
  }

  /**
   * @desc When More than one PC has selected in a component list, need to prompt the user
   * to he wants to apply those changes all checked PCs attributes.
   */
  handleApplyConfig() {
    const applychangeEvent = new CustomEvent("applychange", {
      detail: {
        ...this.changedAttribute
      }
    });
    if (this.isApplyAll) {
      this.dispatchEvent(applychangeEvent);
    }
    // console.log(this.changedAttribute.value);
    const changeField = this.uiAttributesModel.find(
      (item) => item.name === this.changedAttribute.name
    );
    // console.log(changeField.changedAttribute);
    changeField.showInUI = false;
    setTimeout(() => {
      changeField.showInUI = true;
      console.log(changeField.field.isLookup);
      if (changeField.field.isLookup) {
        changeField.options = [];
        changeField.populateOptions = [];
      }
    });
    this.isApplyPopup = false;
  }

  // cancel the apply config
  handleCancelApplyConfig() {
    this.changedAttribute = {};
    this.isApplyPopup = false;
  }

  /**
   * @desc Update the input values while onchange
   * @param {Event Object} evt - change event object
   */
  handleInputChange(evt) {
    const fieldId = evt.detail.fieldId; // fieldId from dataset
    if (!fieldId) {
      return;
    }
    // Find the field from the meta data.
    const changeField = this.uiAttributesModel.find(
      (item) => item.name === fieldId
    );
    if (changeField.field.type === "checkbox") {
      changeField.value = evt.detail.checked ? "Yes" : "No";
      changeField.isChecked = evt.detail.checked;
      this._dispatchAttributeChange(changeField);
      return;
    }
    changeField.value = evt.detail.value;
    if (changeField.type === "Lookup") {
      if (evt.detail.value === "") {
       this.changedAttribute.value = ""; 
      }      
      if (changeField.options.length === 0) {
        changeField.populateOptions = [];
      }
      const findOptionIndex = changeField.options.findIndex(
        (opt) => opt.value === evt.detail.value
      );
      const hasValue = (findOptionIndex >= 0) ? true : false;
      if (hasValue) {
        changeField.displayValue = changeField.options[findOptionIndex].label;
      }

      this._calculationFieldsUpdate(
        changeField.populateOptions[findOptionIndex],
        changeField.name,
        !hasValue
      );
      if (!this.isApplyConfig) {
        changeField.options = [];
        changeField.populateOptions = [];
      }      
    }
    if (
      changeField.field.isPicklist ||
      changeField.field.isLookup ||
      changeField.type === "Date"
    ) {
      this._dispatchAttributeChange(changeField);
    }
  }

  /**
   * @desc Update the input values while onblur
   * @param {Event Object} evt - change event object
   */
  handleInputBlur(evt) {
    const fieldId = evt.detail.fieldId; // fieldId from dataset
    const selectedField = this.uiAttributesModel.find(
      (item) => item.name === fieldId
    );
    if (selectedField.type !== "Date" && selectedField.type !== "Boolean") {
      this._dispatchAttributeChange(selectedField);
    }
  }

  /**
   * @desc dispatch the onattributechange event to the parent component with the selected field
   * @param {Object} selectedField - input element
   */
  _dispatchAttributeChange(selectedField) {
    const selectEvent = new CustomEvent("attributechange", {
      detail: {
        ...selectedField
      }
    });
    this.dispatchEvent(selectEvent);
  }

  /**
   * @desc Fetch the optiond from the provided columns
   * @param {Event Object} evt - change event object
   */
  handleFocus(evt) {
    const fieldId = evt.detail.fieldId; // fieldId from dataset
    const changeField = this.uiAttributesModel.find(
      (item) => item.name === fieldId
    );
    if (changeField.field.isPicklist || changeField.field.isLookup) {
      if (
        Array.isArray(changeField.options) &&
        changeField.options.length < 1
      ) {
        changeField.field.isSpinner = true;
        if (this.isApplyPopup && changeField.field.isLookup) {
          this.changedAttribute.field.isSpinner = true;
        }
        this[changeField.lookupMethod](changeField);
      }
    }
  }

  /**
   * @desc Trigger the api call with the user entered search text
   * @param {Event Object} evt - change event object
   */
  handleLookupSearch(evt) {
    const fieldId = evt.detail.fieldId; // fieldId from dataset
    const changeField = this.uiAttributesModel.find(
      (item) => item.name === fieldId
    );
    changeField.field.isSpinner = true;
    if (this.isApplyPopup) {
      this.changedAttribute.field.isSpinner = true;
    }
    this[changeField.lookupMethod](changeField, evt.detail.searchTerm);
  }

  /**
   * @desc Utility to invoke SOQL query via Apex and return the output
   * @param {Object} changeField
   */
  async doLookupContactDetails(changeField, searchTerm = "") {
    try {
      const contacts = await doLookupContactDetails({
        basketId: this.basketId,
        searchValue: searchTerm,
        CommercialPDName: ""
      });
      changeField.options = contacts.map((contact) => ({
        label: contact.Name,
        value: contact.Id
      }));
      changeField.populateOptions = contacts.map((contact) => ({
        ...contact
      }));
    } catch (err) {
      changeField.options = [
        {
          label: "No result found",
          value: ""
        }
      ];
    } finally {
      changeField.field.isSpinner = false;
      if (this.isApplyPopup) {
        this.changedAttribute = {
          ...JSON.parse(JSON.stringify(changeField))
        };
      }
    }
  }

  /**
   * @desc Utility to invoke SOQL query via Apex and return the output
   * @param {string} query
   * @return {Array} SOQL query output mapped to Combo box label, value format
   */
  async doLookupDeliveryAddress(changeField, searchTerm = "") {
    try {
      const addresses = await doLookupDeliveryAddress({
        basketId: this.basketId,
        searchValue: searchTerm
      });
      changeField.options = addresses.map((address) => ({
        label: address.Name,
        value: address.Id
      }));
      changeField.populateOptions = addresses.map((address) => ({
        ...address
      }));
    } catch (err) {
      changeField.options = [
        {
          label: "No result found",
          value: ""
        }
      ];
    } finally {
      changeField.field.isSpinner = false;
      if (this.isApplyPopup) {
        this.changedAttribute = {
          ...JSON.parse(JSON.stringify(changeField))
        };
      }
    }
  }
}