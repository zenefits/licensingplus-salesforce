import * as types from './action-types';
import { CLASSPREFIX} from '../constants/constants';
export function toggleLicenseRuleSet(name, index, isactive) {
  return function (dispatch) {
    return eval(CLASSPREFIX).toggleLicenseRuleSet(name, isactive, () => {
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
    return eval(CLASSPREFIX).getAllLicenseRuleSetResults((allRuleSetResults) => {
      dispatch({
        type: types.ALL_RULES_RECEIVED,
        allRuleSetResults: allRuleSetResults
      })
    })
  }
}

export function getSobjectNames() {
  return function (dispatch) {
    return eval(CLASSPREFIX).getSobjectNames((allSobjectNames) => {
      dispatch({
        type: types.ALL_SOBJECT_NAMES_RECEIVED,
        allSobjectNames: allSobjectNames
      })
    })
  }
}