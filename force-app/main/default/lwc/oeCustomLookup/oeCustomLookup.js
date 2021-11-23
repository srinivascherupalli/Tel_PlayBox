import { api, LightningElement, track } from "lwc";

export default class OeCustomLookup extends LightningElement {
  @api name;
  @api label;
  @api required;
  @api placeholder = "Search";
  @api spinnerActive = false;
  @api options;
  @api value = "";
  @api displayValue = "";
  @api readOnly = false;

  @track selectedLabel;
  // @track blurTimeout;
  selectedValue = "";
  searchTerm;

  // CSS for slds-dropdown
  @track boxClass =
    "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";
  @track inputClass = "";

  connectedCallback() {
    // OE List Object "{"label":"Munich Testing","value":"0032O000002AxNeQAK"}"
    if (this.value && this.value.indexOf("label") >= 0) { // Prepopulate the value saved OE lists
      const valueObj = {
        ...JSON.parse(this.value)
      };
      if (valueObj.label) {
        this.selectedLabel = valueObj.label;
      }
    }
  }

  renderedCallback() {
    console.log('--options: ' + JSON.stringify(this.options));
    if (this.value && this.displayValue) {
      this.selectedLabel = this.displayValue;
    }
  }

  /**
   * @desc While focus adding styles for slds-dropdown and custom event dispatch
   */
  onFocus() {
    this.searchTerm = "";
    this.inputClass = "slds-has-focus";
    let menuDivEle = this.template.querySelector('[data-id="outerDivList"]');
    menuDivEle.classList.add("slds-is-open");
    this.boxClass =
      "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open";
    const focusEvent = new CustomEvent("focuslookup");
    this.dispatchEvent(focusEvent);
  }

  /**
   * @desc Onfocus out hiding the slds-dropdown
   */
  onBlur() {
    this.blurTimeout = setTimeout(() => {
      let menuDivEle = this.template.querySelector('[data-id="outerDivList"]');
      menuDivEle.classList.remove("slds-is-open");
    }, 300);
    
  }

  /**
   * @desc Set the selectedValue and dispatch the event for selection
   * @param {Event Object} event - on select event object
   */
  onSelect(event) {
    this.selectedValue = event.currentTarget.dataset.id;
    this.selectedLabel = event.currentTarget.dataset.name;
    // if (this.blurTimeout) {
    //   clearTimeout(this.blurTimeout);
    // }
    this.boxClass =
      "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus";
    const valueSelectedEvent = new CustomEvent("changelookup", {
      detail: { value: this.selectedValue }
    });
    this.dispatchEvent(valueSelectedEvent);
  }

  /**
   * @desc Remove the selectedValue and dispatch the event for removal
   */
  handleRemovePill() {
    this.selectedLabel = "";
    const removePill = new CustomEvent("removelookupvalue", {
      detail: { value: "" }
    });
    this.dispatchEvent(removePill);
  }

  /**
   * @desc Set the searchTerm and dispatch the event for search
   * @param {Event Object} event - on search event object
   */
  onChange(event) {
    this.searchTerm = event.target.value;
    const searchLookup = new CustomEvent("searchlookup", {
      detail: { searchTerm: this.searchTerm }
    });
    this.dispatchEvent(searchLookup);
  }
}