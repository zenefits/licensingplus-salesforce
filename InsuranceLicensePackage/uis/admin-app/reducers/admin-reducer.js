import _ from 'lodash';
import moment from 'moment';
import * as constants from '../constants/constants';
import * as types from '../actions/action-types';
import initialState from './initial-state';
import Utils from '../utils/utils'

export default function AdminReducer(state = initialState, action) {
  var errors = [];
  switch (action.type) {
    case types.CHECKLIST_RECEIVED:
      var checklist = Utils.lowKey(action.checklist);
      return Object.assign({}, state, {
        checklist: checklist,
        checklistComplete: action.checklistComplete
      });

    case types.TOGGLE_CHECKLIST:
      return Object.assign({}, state, {
        checklist: action.checklist
      });

    case types.OPEN_CSV:
      var previewRows = Utils.lowKeyArray(action.previewRows);
      var showToast = false
      if (previewRows.length === 0) {
        showToast = true
      }
      return Object.assign({}, state, {
        previewRows: previewRows,
        fileName: action.fileName,
        showToast: showToast
      });

    case types.LINES_OF_AUTH_INSERTED:
      var sfdcRows = Utils.lowKeyArray(action.sfdcRows);
      return Object.assign({}, state, {
        previewRows: [],
        sfdcRows: sfdcRows,
        fileName: constants.CHOOSE_FILE
      });

    case types.LINE_OF_AUTH_DELETED:
      let sfdcRows = Object.assign([], state.sfdcRows);
      sfdcRows = _.without(state.sfdcRows, action.row);
      return Object.assign({}, state, {
        sfdcRows: sfdcRows
      });

    case types.CANCEL_PREVIEW:
      return Object.assign({}, state, {
        previewRows: action.previewRows
      });

    case types.LINES_OF_AUTH_RECEIVED:
      var sfdcRows = Utils.lowKeyArray(action.sfdcRows);
      return Object.assign({}, state, {
        previewRows: [],
        sfdcRows: sfdcRows,
        fileName: constants.CHOOSE_FILE
      });

    case types.SOBJECT_FIELDS_RECIEVED:
      return Object.assign({}, state, {
        sobject: action.sobject
      });

    case types.LICENSE_FIELDS_RECIEVED:
      return Object.assign({}, state, {
        licenseSobject: action.licenseSobject,
      });

    case types.CLEAR_RULE_SET_STATE:
      //is called when detail view is unmounted.
      var defaultRuleSet = Object.assign({}, constants.BLANK_LISCENSE_RULE_SET_RESULT);
      return Object.assign({}, state, {
        advancedRulesList: defaultRuleSet.ruleSets[0].regularFilterRules,
        advancedRuleLogic: defaultRuleSet.ruleSets[0].filterRuleLogic,
        complianceRulesList: defaultRuleSet.ruleSets[0].licenseRules,
        complianceRuleLogic: defaultRuleSet.ruleSets[0].licenseRuleLogic,
        deletedRegularFilterRules: defaultRuleSet.ruleSets[0].deletedRegularFilterRules,
        deletedLicenseRules: defaultRuleSet.ruleSets[0].deletedLicenseRules,
        isFilterRuleLogicRemoved: defaultRuleSet.ruleSets[0].isFilterRuleLogicRemoved,
        isLicenseRuleLogicRemoved: defaultRuleSet.ruleSets[0].isLicenseRuleLogicRemoved,
        isReadOnly: false,
        residentRuleOn: false,
        residentRule: defaultRuleSet.residentLicenseRule,
        stateRule: defaultRuleSet.stateRule,
        loaded: false,
        showAdvancedRule: 'All'
      });

    case types.SAVED_RULE_SET_RESULT:
      if (action.error) {
        //do something with save errors
        return Object.assign({}, state, {
          showToast: true
        })
      }
      else {
        return state;
      }

    case types.RULE_SET_RESULT_RECEIVED:
      var defaultRuleSet = Object.assign({}, constants.BLANK_LISCENSE_RULE_SET_RESULT);
      var ruleSet;
      if (action.ruleSetResult.ruleSets && action.ruleSetResult.ruleSets[0]) {
        ruleSet = action.ruleSetResult.ruleSets[0];
      }
      else {
        ruleSet = defaultRuleSet.ruleSets[0];
      }

      var stateRule, isNew = false;
      if (action.ruleSetResult && action.ruleSetResult.stateRule) {
        stateRule = Utils.lowKey(action.ruleSetResult.stateRule);
      }
      else {
        stateRule = defaultRuleSet.stateRule;
        stateRule.licensingplus__object__c = action.objectName;
        isNew = true;
      }

      var residentLicenseRule;
      if (action.ruleSetResult && action.ruleSetResult.residentLicenseRule) {
        residentLicenseRule = Utils.lowKey(action.ruleSetResult.residentLicenseRule);
      }
      else {
        residentLicenseRule = defaultRuleSet.residentLicenseRule;
      }
      var residentRuleOn = residentLicenseRule.licensingplus__value__c ? true : false;

      ruleSet.filterRuleLogic = Utils.lowKey(ruleSet.filterRuleLogic);
      var advancedRuleLogicStr = '';
      if (ruleSet.filterRuleLogic && ruleSet.filterRuleLogic.licensingplus__logic__c) {
        advancedRuleLogicStr = Utils.convertDbLogicToUi(ruleSet.filterRuleLogic.licensingplus__logic__c);
      }
      ruleSet.licenseRuleLogic = Utils.lowKey(ruleSet.licenseRuleLogic);
      var complianceRuleLogicStr = '';
      if (ruleSet.licenseRuleLogic && ruleSet.licenseRuleLogic.licensingplus__logic__c) {
        complianceRuleLogicStr = Utils.convertDbLogicToUi(ruleSet.licenseRuleLogic.licensingplus__logic__c);
      }

      var advancedRuleLogic = Object.assign({}, state.advancedRuleLogic, ruleSet.filterRuleLogic);
      var complianceRuleLogic = Object.assign({}, state.complianceRuleLogic, ruleSet.licenseRuleLogic);
      advancedRuleLogic.licensingplus__logic__c = advancedRuleLogicStr;
      complianceRuleLogic.licensingplus__logic__c = complianceRuleLogicStr;
      var isReadOnly = (stateRule.licensingplus__isactive__c || stateRule.licensingplus__isactive__c) ? true : false;
      var showAdvancedRule = (ruleSet.regularFilterRules && ruleSet.regularFilterRules.length > 0) ? 'Specific' : 'All';
      return Object.assign({}, state, {
        advancedRulesList: Utils.lowKeyArray(ruleSet.regularFilterRules),
        advancedRuleLogic: Utils.lowKey(advancedRuleLogic),
        complianceRulesList: Utils.lowKeyArray(ruleSet.licenseRules),
        complianceRuleLogic: Utils.lowKey(complianceRuleLogic),
        deletedRegularFilterRules: ruleSet.deletedRegularFilterRules,
        deletedLicenseRules: ruleSet.deletedLicenseRules,
        isFilterRuleLogicRemoved: ruleSet.isFilterRuleLogicRemoved,
        isLicenseRuleLogicRemoved: ruleSet.isLicenseRuleLogicRemoved,
        isReadOnly: isReadOnly,
        residentRuleOn: residentRuleOn,
        residentRule: Utils.lowKey(residentLicenseRule),
        stateRule: Utils.lowKey(stateRule),
        loaded: true,
        errors: isNew,
        showAdvancedRule: showAdvancedRule
      });

    case types.ALL_RULES_RECEIVED:
      var ruleSetResults = _.keys(action.allRuleSetResults).sort().map((key, index) => {
        var ruleSetResult = action.allRuleSetResults[key];
        if (ruleSetResult.stateRule) {
          ruleSetResult.stateRule = Utils.lowKey(ruleSetResult.stateRule)
        }

        var isactive = (ruleSetResult.stateRule.licensingplus__isactive__c || ruleSetResult.stateRule.licensingplus__isactive__c) ? true : false;
        return {
          name: key,
          isactive: isactive
        }
      })
      return Object.assign({}, state, {
        ruleSetResults: ruleSetResults,
        allRuleSetResults: action.allRuleSetResults
      });

    case types.ALL_SOBJECT_NAMES_RECEIVED:
      return Object.assign({}, state, {
        allSobjectNames: action.allSobjectNames
      });

    case types.RULE_SET_TOGGLED:
      var objName = action.objName;
      var isactive = action.isactive;
      var index = action.index;
      // var newState = Object.assign({}, state);
      var ruleSetResults = Object.assign([], state.ruleSetResults);
      ruleSetResults[index].isactive = isactive;
      return Object.assign({}, state, {
        ruleSetResults: ruleSetResults
      });

    case types.DELETE_COMPLIANCE_RULE:
      var rulesList = Object.assign([], state.complianceRulesList);
      var complianceRuleLogic = Object.assign({}, state.complianceRuleLogic);
      var deletedRuleList = Object.assign([], state.deletedLicenseRules);
      var isLogicRemoved = state.isLicenseRuleLogicRemoved;
      var complianceErrors = Object.assign([], state.complianceErrors);
      var error = false;
      var logic = "";
      complianceErrors = _.without(complianceErrors, action.index + '0', action.index + '1', action.index + '2');
      if (state.complianceRulesList.length - 1 > 0) {
        logic = "1";
        for (var i = 2; i < state.complianceRulesList.length; i++) {
          logic = logic + " and " + i;
        }
      }
      complianceRuleLogic.licensingplus__logic__c = logic;
      error = (complianceErrors.length || state.advancedErrors.length);
      var deletedRule = rulesList.splice(action.index, 1);
      if (rulesList.length && deletedRule[0].id) {
        deletedRuleList.push(deletedRule[0]);
      } else if (!rulesList.length && deletedRule[0].id) {
        deletedRuleList.push(deletedRule[0]);
        isLogicRemoved = true;
      } else if (!rulesList.length) {
        isLogicRemoved = true;
      }
      return Object.assign({}, state, {
        complianceRulesList: rulesList,
        complianceRuleLogic: complianceRuleLogic,
        deletedLicenseRules: deletedRuleList,
        isLicenseRuleLogicRemoved: isLogicRemoved,
        complianceErrors: complianceErrors,
        errors: error
      });

    case types.DELETE_ADVANCED_RULE:
      var rulesList = Object.assign([], state.advancedRulesList);
      var advancedRuleLogic = Object.assign({}, state.advancedRuleLogic);
      var deletedRuleList = Object.assign([], state.deletedRegularFilterRules);
      var isLogicRemoved = state.isFilterRuleLogicRemoved;
      var advancedErrors = Object.assign([], state.advancedErrors);
      var error = false;
      advancedErrors = _.without(advancedErrors, action.index + '0', action.index + '1', action.index + '2');
      var logic = "";
      if (state.advancedRulesList.length - 1 > 0) {
        logic = "1";
        for (var i = 2; i < state.advancedRulesList.length; i++) {
          logic = logic + " and " + i;
        }
      }
      advancedRuleLogic.licensingplus__logic__c = logic;
      var deletedRule = rulesList.splice(action.index, 1);
      if (rulesList.length && deletedRule[0].id) {
        deletedRuleList.push(deletedRule[0]);
      } else if (!rulesList.length && deletedRule[0].id) {
        deletedRuleList.push(deletedRule[0]);
        isLogicRemoved = true;
      } else if (!rulesList.length) {
        isLogicRemoved = true;
      }
      error = (advancedErrors.length || state.complianceErrors.length);
      return Object.assign({}, state, {
        advancedRulesList: rulesList,
        advancedRuleLogic: advancedRuleLogic,
        deletedRegularFilterRules: deletedRuleList,
        isFilterRuleLogicRemoved: isLogicRemoved,
        advancedErrors: advancedErrors,
        errors: error
      });

    case types.SHOW_ADVANCED_RULE:
      var showAdvanced = Object.assign([], state.showAdvancedRule);
      return Object.assign({}, state, {
        showAdvancedRule: action.showAdvanced
      });

    case types.ADD_ADVANCED_RULE:
      var advancedRulesList = Object.assign([], state.advancedRulesList);
      var advancedRuleLogic = Object.assign({}, state.advancedRuleLogic);
      var isFilterRuleLogicRemoved = state.isFilterRuleLogicRemoved;
      var currentIndex = advancedRulesList.length;
      var err = [currentIndex + '0', currentIndex + '1', currentIndex + '2']
      var advancedErrors = _.union(state.advancedErrors, err);
      if (isFilterRuleLogicRemoved) {
        isFilterRuleLogicRemoved = false;
      }
      if (advancedRulesList.length > 0) {
        advancedRuleLogic.licensingplus__logic__c = advancedRuleLogic.licensingplus__logic__c + " and " + (advancedRulesList.length + 1);
      } else {
        advancedRuleLogic.licensingplus__logic__c = "1";
      }
      var rule = {
        "licensingplus__object__c": action.objectName,
        "licensingplus__field__c": "",
        "licensingplus__operator__c": "",
        "licensingplus__value__c": "",
        "licensingplus__isactive__c": false,
      }
      advancedRulesList.push(rule);
      return Object.assign({}, state, {
        advancedErrors: advancedErrors,
        advancedRulesList: advancedRulesList,
        advancedRuleLogic: advancedRuleLogic,
        isFilterRuleLogicRemoved: isFilterRuleLogicRemoved,
        errors: true
      });

    case types.ADD_COMPLIANCE_RULE:
      var complianceRulesList = Object.assign([], state.complianceRulesList);
      var complianceRuleLogic = Object.assign({}, state.complianceRuleLogic);
      var isLicenseRuleLogicRemoved = state.isLicenseRuleLogicRemoved;
      var currentIndex = complianceRulesList.length;
      var err = [currentIndex + '0', currentIndex + '1', currentIndex + '2']
      var complianceErrors = _.union(state.complianceErrors, err);
      if (isLicenseRuleLogicRemoved) {
        isLicenseRuleLogicRemoved = false;
      }
      if (complianceRulesList.length > 0) {
        complianceRuleLogic.licensingplus__logic__c = complianceRuleLogic.licensingplus__logic__c + " and " + (complianceRulesList.length + 1);
      } else {
        complianceRuleLogic.licensingplus__logic__c = "1";
      }
      var rule = {
        "licensingplus__object__c": action.objectName,
        "licensingplus__license_field__c": "",
        "licensingplus__operator__c": "",
        "licensingplus__field__c": "",
        "licensingplus__isactive__c": false,
      }
      complianceRulesList.push(rule);
      return Object.assign({}, state, {
        complianceRulesList: complianceRulesList,
        complianceRuleLogic: complianceRuleLogic,
        complianceErrors: complianceErrors,
        isLicenseRuleLogicRemoved: isLicenseRuleLogicRemoved,
        errors: true
      });

    case types.SELECT_ADVANCED_CHANGE_RULE:
      var rulesList = Object.assign([], state.advancedRulesList);
      var itemIndex = action.index;
      var rulesListItem = rulesList[itemIndex];
      var advancedErrors = Object.assign([], state.advancedErrors)
      var error = false;

      switch (action.itemName) {
        case 'licensingplus__field__c':
          rulesListItem.licensingplus__field__c = action.itemValue;
          rulesListItem.licensingplus__operator__c = '';
          rulesListItem.licensingplus__value__c = '';
          var fieldType = state.sobject.fields[rulesListItem.licensingplus__field__c];
          if (fieldType === 'BOOLEAN_FIELD') {
            rulesListItem.licensingplus__value__c = 'true';
            advancedErrors.push(itemIndex + '1');
            advancedErrors = _.without(advancedErrors, itemIndex + '2');
          }
          else if (fieldType === 'DATE_FIELD') {
            rulesListItem.licensingplus__value__c = Utils.formatSfdcDate(new Date());
            advancedErrors.push(itemIndex + '1');
            advancedErrors = _.without(advancedErrors, itemIndex + '2');
          }
          else if (fieldType === 'DATETIME_FIELD') {
            rulesListItem.licensingplus__value__c = Utils.formatSfdcDateTime(new Date());
            advancedErrors.push(itemIndex + '1');
            advancedErrors = _.without(advancedErrors, itemIndex + '2');
          }
          else {
            advancedErrors.push(itemIndex + '1', itemIndex + '2');
          }
          error = true;
          break;
        case 'licensingplus__operator__c':
          var fieldType = state.sobject.fields[rulesListItem.licensingplus__field__c];
          rulesListItem.licensingplus__operator__c = action.itemValue;
          if (action.itemValue==='not blank'){
            advancedErrors = _.without(advancedErrors, itemIndex + '2');
            rulesListItem.licensingplus__value__c = '';
          } 
          else if (fieldType === 'BOOLEAN_FIELD') {
            rulesListItem.licensingplus__value__c = rulesListItem.licensingplus__value__c?rulesListItem.licensingplus__value__c:'true';
          }
          else if (fieldType === 'DATE_FIELD') {
            rulesListItem.licensingplus__value__c = rulesListItem.licensingplus__value__c?rulesListItem.licensingplus__value__c:Utils.formatSfdcDate(new Date());
          }
          else if (fieldType === 'DATETIME_FIELD') {
            rulesListItem.licensingplus__value__c = rulesListItem.licensingplus__value__c?rulesListItem.licensingplus__value__c:Utils.formatSfdcDateTime(new Date());
          } else {
            advancedErrors.push(itemIndex + '2');
          }
          break;
        case 'licensingplus__value__c':
          rulesListItem.licensingplus__value__c = action.itemValue;
          if (rulesListItem.licensingplus__field__c) {
            //there may not be a field selected, so check first
            var fieldType = state.sobject.fields[rulesListItem.licensingplus__field__c]
            if (fieldType === 'DATE_FIELD') {
              rulesListItem.licensingplus__value__c = Utils.formatSfdcDate(action.itemValue);
            }
            else if (fieldType === 'DATETIME_FIELD') {
              rulesListItem.licensingplus__value__c = Utils.formatSfdcDateTime(action.itemValue);
            }
          }
          break;
        default:
          rulesListItem = {};
      }

      if (!action.error) {
        advancedErrors = _.without(advancedErrors, itemIndex + action.colIndex);
      } else if (action.error) {
        if (_.findIndex(advancedErrors, itemIndex + action.colIndex) == -1) {
          advancedErrors.push(itemIndex + action.colIndex);
        }
      }
      error = (advancedErrors.length || state.complianceErrors.length);
      return Object.assign({}, state, {
        advancedRulesList: rulesList,
        advancedErrors: advancedErrors,
        errors: error
      });

    case types.CHANGE_ADVANCED_RULE_LOGIC:
      var logic = Object.assign({}, state.advancedRuleLogic);
      logic.licensingplus__logic__c = action.value;
      var error = false;
      if (action.error) {
        error = true;
      } else if (state.complianceErrors.length || state.advancedErrors.length) {
        error = true;
      } else {
        error = false;
      }
      return Object.assign({}, state, {
        advancedRuleLogic: logic,
        errors: error
      });

    case types.SELECT_COMPLINACE_CHANGE_RULE:
      var rulesList = Object.assign([], state.complianceRulesList);
      var complianceErrors = Object.assign([], state.complianceErrors)
      var itemIndex = action.index;
      var rulesListItem = rulesList[itemIndex];
      var isNewRuleListItem = (rulesListItem.licensingplus__field__c != '' && rulesListItem.licensingplus__operator__c != '' && rulesListItem.licensingplus__value__c != '');
      var error = false;

      switch (action.itemName) {
        case 'licensingplus__license_field__c':
          rulesListItem.licensingplus__license_field__c = action.itemValue;
          if (isNewRuleListItem) {
            rulesListItem.licensingplus__operator__c = '';
            rulesListItem.licensingplus__field__c = '';
            complianceErrors.push(itemIndex + '1', itemIndex + '2');
            error = true;
          }
          break;
        case 'licensingplus__operator__c':
          rulesListItem.licensingplus__operator__c = action.itemValue;
          break;
        case 'licensingplus__field__c':
          rulesListItem.licensingplus__field__c = action.itemValue;
          break;
        default:
          rulesListItem = {};
      }

      if (!action.error) {
        complianceErrors = _.without(complianceErrors, itemIndex + action.colIndex);
      } else {
        if (_.findIndex(complianceErrors, itemIndex + action.colIndex) == -1) {
          complianceErrors.push(itemIndex + action.colIndex);
        }
      }
      error = (complianceErrors.length || state.advancedErrors.length) ? true : false;
      return Object.assign({}, state, {
        complianceRulesList: rulesList,
        complianceErrors: complianceErrors,
        errors: error
      });

    case types.CHANGE_COMPLINACE_RULE_LOGIC:
      var logic = Object.assign({}, state.complianceRuleLogic);
      var error = false;
      logic.licensingplus__logic__c = action.value;
      if (action.error) {
        error = true;
      } else if (state.complianceErrors.length || state.advancedErrors.length) {
        error = true;
      } else {
        error = false;
      }
      return Object.assign({}, state, {
        complianceRuleLogic: logic,
        errors: error
      });

    case types.TOGGLE_RESIDENT_RULE:
      var residentRule = Object.assign({}, state.residentRule);
      if (action.value) {
        residentRule.licensingplus__object__c = action.objectName;
        residentRule.licensingplus__value__c = 'Resident State';
        residentRule.licensingplus__license_field__c = 'RecordType.Name';
        residentRule.licensingplus__operator__c = 'equals';
      }
      else {
        residentRule = null;
      }
      return Object.assign({}, state, {
        residentRule: residentRule,
        residentRuleOn: action.value
      });

    case types.SELECT_STATE_CHANGE_RULE:
      var stateRule = Object.assign({}, state.stateRule);
      var errors = false;
      stateRule.licensingplus__field__c = action.itemValue
      if(stateRule.licensingplus__field__c === ''){
        errors = true;
      }
      return Object.assign({}, state, {
        stateRule: stateRule,
        errors: errors
      });

    case types.HIDE_TOAST:
      return Object.assign({}, state, {
        showToast: false
      });

    default:
      return state;
  }
}