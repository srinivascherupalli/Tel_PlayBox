import operators from "../config/operators";

const ValidationRulesMixin = (base) =>
  class ValidationRules extends base {
    
    // return the current attribute
    /**
     * @desc Iterate through the active tab fields and find the rule field.
     * @param {String} fieldName - name of the field to find
     */
    _findRuleField(fieldName) {
      const selectedTabSchema = localStorage.getItem("selectedTabSchema");
      const findField = JSON.parse(selectedTabSchema).attributes.find(
        (attribute) => attribute.name === fieldName
      );
      return findField;
    }

    /**
     * @desc Iterate through the rules logics
     * @param {Array} logics - rule logic
     * @return {Array} ruleResult - Return the each executed rules result as array.
     */
    _executeRuleLogic(logics, currentValue) {
      let rulesResults = [];
      // Execute Rules
      if (Array.isArray(logics)) {
        logics.forEach((logic) => {
          if (!logic.attName.includes(this.uiAttribute.name)) {
            return;
          }
          let extracAttValue = "";
          // check attName or attValue has @ expression
          if (
            logic.attValue.includes("@", 0)
          ) {
            // string match utils will return the array or null
            extracAttValue = logic.attValue.match(/(?<=@).+?(?=@)/g); // Remove the @ from the string
          }
          extracAttValue = extracAttValue ? extracAttValue[0] : "";

          // Find the compare field based on the attValue.
          const findCompareField = this._findRuleField(extracAttValue);
          // console.log(this.uiAttribute.name);
          // console.log(extracAttName);
          if (this.uiAttribute.type === "Date") {
            const findRuleFieldDate = new Date(currentValue); // convert string to date
            let compareFieldDate = new Date(); // by default compare value is date
            if (!currentValue && logic.attValue !== "") {
              // ONLOAD_RULE should not excecute the rule when value is not filled by the user.
              rulesResults.push(false);
              return;
            }
            if (!extracAttValue && !currentValue) {
              rulesResults.push(true);
              return;
            }
            if (extracAttValue !== "today" && findCompareField) {
              compareFieldDate = new Date(findCompareField.value);
            }
            // console.log(findRuleFieldDate.toString() === "Invalid Date");
            if (
              findRuleFieldDate.toString() === "Invalid Date" ||
              compareFieldDate.toString() === "Invalid Date"
            ) {
              rulesResults.push(true);
              return;
            }
            // Invoke the operators config to execute the operation and push the result
            rulesResults.push(
              operators[logic.operator](+findRuleFieldDate, +compareFieldDate)
            );
          } else {
            if (!this.uiAttribute.value) {
              // ONLOAD_RULE should not excecute the rule when value is not filled by the user.
              rulesResults.push(false);
              return;
            }
            if (!extracAttValue && !currentValue) {
              rulesResults.push(true);
              return;
            }
            if (findCompareField) {
              // Invoke the operators config to execute the operation and push the result
              rulesResults.push(
                operators[logic.operator](
                  this.uiAttribute.value,
                  findCompareField.value
                )
              );
            }
          }
        });
      }
      return rulesResults;
    }

    /**
     * @desc Iterate through the rules logics
     * @param {Array} logics - rule logic
     * @param {boolean} hasError
     * @return {Array} ruleResult - Return the each executed rules result as array.
     */
    _executeRuleAction(actions, hasError) {
      // Execute Rules
      if (Array.isArray(actions.isTrue)) {
        actions.isTrue.forEach((action) => {
          let extracAttValue = "";
          // check attName or attValue has @ expression
          if (action.value.includes("@", 0)) {
            // string match utils will return the array or null
            extracAttValue = action.value.match(/(?<=@).+?(?=@)/g); // Remove the @ from the string
          }
          extracAttValue = extracAttValue ? extracAttValue[0] : "";

          // Find the compare field based on the attValue.
          const findCompareField = this._findRuleField(extracAttValue);

          if (!hasError) {
            this.uiAttribute.errorMessage = "";
            return;
          }
          // console.log(extracAttName);
          if (!this.uiAttribute.errorMessage) {
            this.uiAttribute.errorMessage = action.errorMessage;
          }
          if (!action.errorMessage && extracAttValue && findCompareField) {
            this.uiAttribute.value = findCompareField.value;
          }
        });
      }
    }

    /**
     * @desc Iterate through the validationlist, execute the logic and perform the action
     */
    _executeValidationRule(currentValue) {
      this.validationRules.forEach((rule, idx) => {
        let rulesResults = this._executeRuleLogic(rule.logics, currentValue);

        if (rule.condition === "AND") {
          const hasError = (item) => item === true;
          // console.log(rulesResults.every(hasError));
          if (rulesResults.every(hasError)) {
            this._executeRuleAction(rule.actions, true);
          }
        } else { // OR condition rule
          if (rulesResults.includes(true)) {
            this._executeRuleAction(rule.actions, true);
          }
        }
        

        const hasError = (item) => item === true;
        // console.log(rulesResults.every(hasError));
        if (!rulesResults.every(hasError)) {
          this._executeRuleAction(rule.actions, false);
        }
      });
    }
  };
export default ValidationRulesMixin;