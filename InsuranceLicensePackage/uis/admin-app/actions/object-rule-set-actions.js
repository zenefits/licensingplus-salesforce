import * as types from './action-types';
import { hashHistory } from 'react-router';
import * as constants from '../constants/constants';
import { OBJECTPREFIX, CLASSPREFIX} from '../constants/constants';
import Utils from '../utils/utils';
import moment from 'moment';

export function getLicenseRuleSetResult(objectName) {
  return function (dispatch) {
    return eval(CLASSPREFIX).getLicenseRuleSetResult(objectName, (ruleSetResult) => {
      dispatch({
        type: types.RULE_SET_RESULT_RECEIVED,
        ruleSetResult: ruleSetResult,
        objectName: objectName
      })
    })
  }
}

export function getSobjectWithFields(objectName) {
  return function (dispatch) {
    return eval(CLASSPREFIX).getSobjectWithFields(objectName, (sobjectFields) => {
      dispatch({
        type: types.SOBJECT_FIELDS_RECIEVED,
        sobject: sobjectFields
      })
    })
  }
}

export function getLicenseFields(objectName) {
  return function (dispatch) {
    return eval(CLASSPREFIX).getSobjectWithFields(objectName, (licenseFields) => {
      dispatch({
        type: types.LICENSE_FIELDS_RECIEVED,
        licenseSobject: licenseFields
      })
    })
  }
}

export function saveLicenseRuleSetResult(data) {
  return function (dispatch) {
    if (data.complianceRuleLogic && data.complianceRuleLogic[OBJECTPREFIX+'logic__c']) {
      data.complianceRuleLogic[OBJECTPREFIX+'logic__c'] = Utils.convertUiLogicToDb(data.complianceRuleLogic[OBJECTPREFIX+'logic__c']);
      data.complianceRuleLogic[OBJECTPREFIX+'object__c'] = data.stateRule[OBJECTPREFIX+'object__c'];
    }
    else if (data.complianceRuleLogic && data.complianceRuleLogic[OBJECTPREFIX+'logic__c'] === '' && !data.complianceRuleLogic.id) {
      data.complianceRuleLogic = null;
    }
    if (data.advancedRuleLogic && data.advancedRuleLogic[OBJECTPREFIX+'logic__c']) {
      data.advancedRuleLogic[OBJECTPREFIX+'logic__c'] = Utils.convertUiLogicToDb(data.advancedRuleLogic[OBJECTPREFIX+'logic__c']);
      data.advancedRuleLogic[OBJECTPREFIX+'object__c'] = data.stateRule[OBJECTPREFIX+'object__c'];
    }
    else if (data.advancedRuleLogic && data.advancedRuleLogic[OBJECTPREFIX+'logic__c'] === '' && !data.advancedRuleLogic.id) {
      data.advancedRuleLogic = null;
    }

    if (data.showAdvancedRule === "All") {
      data.deletedRegularFilterRules = _.filter(data.advancedRulesList, 'id');
      data.isFilterRuleLogicRemoved = (data.deletedRegularFilterRules.length > 0) ? true : false;
      if (data.advancedRuleLogic && data.advancedRuleLogic[OBJECTPREFIX+'logic__c']) {
        data.advancedRuleLogic[OBJECTPREFIX+'logic__c'] = '';
      }
      data.advancedRulesList = [];
    }

    if (data.residentRule && (data.residentRule[OBJECTPREFIX+'value__c'] === '' || !data.residentRule[OBJECTPREFIX+'value__c'])) {
      data.residentRule = null;
    }

    if (data.advancedRulesList) {
      data.advancedRulesList = _.map(data.advancedRulesList, (singleRow) => {
        singleRow[OBJECTPREFIX+'value__c'] = _.escape(singleRow[OBJECTPREFIX+'value__c'])
        return singleRow
      })
    }

    var ruleSetResult = {
      "stateRule": data.stateRule,
      "residentLicenseRule": data.residentRule,
      "ruleSets": [
        {
          "deletedRegularFilterRules": data.deletedRegularFilterRules,
          "deletedLicenseRules": data.deletedLicenseRules,
          "isFilterRuleLogicRemoved": data.isFilterRuleLogicRemoved,
          "isLicenseRuleLogicRemoved": data.isLicenseRuleLogicRemoved,
          "filterRuleLogic": data.advancedRuleLogic,
          "licenseRuleLogic": data.complianceRuleLogic,
          "licenseRules": data.complianceRulesList,
          "regularFilterRules": data.advancedRulesList
        }
      ]
    }
    return eval(CLASSPREFIX).saveLicenseRuleSetResult(ruleSetResult, data.stateRule[OBJECTPREFIX+'object__c'], (result, event) => {
      if (event.status) {
        dispatch({
          type: types.SAVED_RULE_SET_RESULT,
          error: null
        })
        hashHistory.push('/rules');
      }
      else {
        dispatch({
          type: types.SAVED_RULE_SET_RESULT,
          error: event.message
        })
      }
    })
  }
}

export function deleteComplianceRule(index) {
  return {
    type: types.DELETE_COMPLIANCE_RULE,
    index: index

  };
}

export function deleteAdvancedRule(index) {
  return {
    type: types.DELETE_ADVANCED_RULE,
    index: index
  };
}

export function addAdvancedRule(objectName) {
  return {
    type: types.ADD_ADVANCED_RULE,
    objectName: objectName
  };
}

export function addComplianceRule(objectName) {
  return {
    type: types.ADD_COMPLIANCE_RULE,
    objectName: objectName
  };
}

export function showAdvancedRule(showAdvanced) {
  return {
    type: types.SHOW_ADVANCED_RULE,
    showAdvanced: showAdvanced
  };
}

export function selectAdvancedChange(itemValue, itemName, index, colIndex, error) {
  return {
    type: types.SELECT_ADVANCED_CHANGE_RULE,
    itemValue: itemValue,
    itemName: itemName,
    index: index,
    colIndex: colIndex,
    error: error
  };
}

export function selectComplianceChange(itemValue, itemName, index, colIndex, error) {
  return {
    type: types.SELECT_COMPLINACE_CHANGE_RULE,
    itemValue: itemValue,
    itemName: itemName,
    index: index,
    colIndex: colIndex,
    error: error
  };
}

export function selectStateRuleChange(itemValue) {
  return {
    type: types.SELECT_STATE_CHANGE_RULE,
    itemValue: itemValue
  };
}

export function changeAdvancedRuleLogic(value, error) {
  return {
    type: types.CHANGE_ADVANCED_RULE_LOGIC,
    value: value,
    error: error
  };
}

export function clearState() {
  return {
    type: types.CLEAR_RULE_SET_STATE
  };
}

export function changeComplianceRuleLogic(value, error) {
  return {
    type: types.CHANGE_COMPLINACE_RULE_LOGIC,
    value: value,
    error: error
  };
}

export function toggleChangeResidentRule(value, objectName) {
  return {
    type: types.TOGGLE_RESIDENT_RULE,
    value: value,
    objectName: objectName
  };
}

export function hideToast() {
  return {
    type: types.HIDE_TOAST
  };
}