import { LightningElement, api, track } from "lwc";

export default class MetaDataInputRenderer extends LightningElement {
  @api attribute = {};
  @api validationRules = [];
  @api attributes = [];
  @api isNoClick = {};
  @track uiAttribute = {};
  @track isFirstRendered = true;

  connectedCallback() {
    this.uiAttribute = {
      ...this.attribute
    };
  }
  
  // handle on change event of the input element
  handleInputChange(evt) {
    const fieldId = evt.currentTarget.dataset.fieldId; // fieldId from dataset
    const changeEvent = new CustomEvent("change", {
      detail: {
        fieldId,
        value: evt.detail.value,
        checked: evt.detail.checked // Checkbox is using checked
      }
    });
    // this._executeValidationRule(evt.detail.value);
    this.dispatchEvent(changeEvent);
  }

  // handle on focus in event of the input element
  handleFocus(evt) {
    const fieldId = evt.currentTarget.dataset.fieldId; // fieldId from dataset
    const focusEvent = new CustomEvent("focus", {
      detail: {
        fieldId
      }
    });
    this.dispatchEvent(focusEvent);
  }

  // handle on focus out event of the input element
  handleInputBlur(evt) {
    const fieldId = evt.currentTarget.dataset.fieldId; // fieldId from dataset
    const blurEvent = new CustomEvent("blur", {
      detail: {
        fieldId
      }
    });
    this.dispatchEvent(blurEvent);
  }

  // handle on search event of the input element
  handleLookupSearch(evt) {
    const fieldId = evt.currentTarget.dataset.fieldId; // fieldId from dataset
    const searchlookupEvent = new CustomEvent("searchlookup", {
      detail: {
        fieldId,
        searchTerm: evt.detail.searchTerm,
      }
    });
    this.dispatchEvent(searchlookupEvent);
  }
}