let inputMap = new Map([
  ["Calculation", { tag: "lightning-input", isInput: true, type: "text", isReadOnly: true }],
  ["String", { tag: "lightning-input", isInput: true, type: "text" }],
  ["Date", { tag: "lightning-input", isInput: true, type: "date" }],
  ["Time", { tag: "lightning-input", isInput: true, type: "time" }],
  ["Boolean", { tag: "lightning-input", isInput: true, type: "checkbox" }],
  ["Datetime", { tag: "lightning-input", isInput: true, type: "datetime" }],
  ["Number", { tag: "lightning-input", isInput: true, type: "number" }],
  ["Lookup", { tag: "c-oe-custom-lookup", isLookup: true, type: "" }],
  ["Dropdown", { tag: "lightning-combobox", isPicklist: true, type: "" }],
  ["Picklist", { tag: "lightning-combobox", isPicklist: true, type: "" }],
  ["Checkbox", { tag: "lightning-input", isCheckbox: true, type: "" }],
  ["Radio", { tag: "lightning-input", isRadio: true, type: "" }],
  ["Textarea", { tag: "lightning-textarea", isTextarea: true, type: "" }],
  ["Label", { tag: "lightning-formatted-text", isLabel: true, type: "" }]
]);

export default inputMap;