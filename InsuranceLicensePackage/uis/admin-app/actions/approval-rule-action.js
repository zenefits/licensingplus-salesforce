import * as types from './action-types';
import { OBJECTPREFIX, CLASSPREFIX } from '../constants/constants';
import Utils from '../utils/utils';

export function getApprovalCriteriaConfig() {
  return function (dispatch) {
    return eval(CLASSPREFIX).getApprovalCriteriaConfig((ruleSetResult) => {
      dispatch({
        type: types.LICENSE_APPROVAL_RESULT_RECEIVED,
        niprSyncConfig: ruleSetResult.niprSyncConfig,
        licencesRuleObject: ruleSetResult.licenseRuleSetResult.ruleSets[0]
      })
    })
  }
}

export function getLicenseApprovalFields(objectName) {
  return function (dispatch) {
    return eval(CLASSPREFIX).getSobjectWithFields(objectName,(result) => {
      dispatch({
        type: types.LICENSE_APPROVAL_FIELDS_RESULT_RECEIVED,
        licenseRuleField: result
      })
    })
  }
}

export function selectLicenseChange(itemValue, itemName, index, colIndex, error) {
   return {
    type: types.SELECT_LICENSE_CHANGE_RULE,
    itemValue: itemValue,
    itemName: itemName,
    index: index,
    colIndex: colIndex,
    error: error
  };
}

export function addLicenseRule() {
  return {
    type: types.ADD_LICENSE_RULE,
  };
}

export function deleteLicenseRule(index) {
  return {
    type: types.DELETE_LICENSE_RULE,
    index: index
  };
}

export function changeLicenseRuleLogic(value, error) {
  return {
    type: types.CHANGE_LICENSE_RULE_LOGIC,
    value: value,
    error: error
  };
}

export function toggleChangeActivateLicense(value) {
  return {
    type: types.TOGGLE_ACTIVATE_LICENSE,
    value: value
  };
}

export function toggleChangeForceExpire(value) {
  return {
    type: types.TOGGLE_FORCE_EXPIRE,
    value: value
  };
}

export function saveLicenseApprovalRuleSetResult(niprSyncConfig, licencesRuleObject) {
  return function (dispatch) {
    var ruleSetResult = {
      "stateRule": null,
      "residentLicenseRule": null,
      "ruleSets": [
        licencesRuleObject
      ]
    }
    return eval(CLASSPREFIX).saveApprovalCriteriaConfig(niprSyncConfig, ruleSetResult,() => {
      dispatch({
        type: types.SAVE_LICENSE_APPROVAL_RULE,
        error: null
      });
    });
  };
}

export function onChangeApprovalProcess(value) {
  return {
    type: types.ON_CHANGE_APPROVAL_PROCESS,
    value: value
  };
}

export function getValidationUser(searchStr){
  return function (dispatch) {
    return eval(CLASSPREFIX).getUserNames(searchStr,(usersList) => {
      dispatch({
        type: types.ON_VALIDATION_USER_RECEIVE,
        usersList: usersList
      });
    });
  };
}

export function setValidationUser(value) {
  return {
    type: types.ON_CHANGE_USER_SEARCH_STRING,
    value: value
  };
}

export function getApprovalProcesses(searchStr) {
 return function (dispatch) {
   return eval(CLASSPREFIX).getApprovalProcessNames((result) => {
     dispatch({
       type: types.ON_APPROVAL_PROCESS_RECEIVE,
       approvalProcessList: result
     });
   });
 };
}

export function clearUserSearchResult() {
  return {
    type: types.CLEAR_USER_SEARCH_RESULT
  };
}
export function setValidationUserError(value) {
  return {
    type: types.VALIDATION_USER_ERROR,
    value:value
  };
}
