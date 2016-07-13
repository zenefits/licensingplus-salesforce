import * as types from './action-types';

export function toggleLicenseRuleSet(name, index, isactive) {
  return function (dispatch) {
    return LicensingPlus.ComplianceController.toggleLicenseRuleSet(name, isactive, () => {
      dispatch({
        type: types.RULE_SET_TOGGLED,
        name: name,
        isactive: isactive,
        index: index
      })
    })
  }
}

export function getAllLicenseRuleSetResults() {
  return function (dispatch) {
    return LicensingPlus.ComplianceController.getAllLicenseRuleSetResults((allRuleSetResults) => {
      dispatch({
        type: types.ALL_RULES_RECEIVED,
        allRuleSetResults: allRuleSetResults
      })
    })
  }
}

export function getSobjectNames() {
  return function (dispatch) {
    return LicensingPlus.ComplianceController.getSobjectNames((allSobjectNames) => {
      dispatch({
        type: types.ALL_SOBJECT_NAMES_RECEIVED,
        allSobjectNames: allSobjectNames
      })
    })
  }
}