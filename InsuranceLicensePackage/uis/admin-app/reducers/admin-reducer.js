import _ from 'lodash';
import moment from 'moment';
import * as constants from '../constants/constants';
import * as types from '../actions/action-types';
import initialState from './initial-state';
import Utils from '../utils/utils';
import { OBJECTPREFIX } from '../constants/constants';
import { hashHistory } from 'react-router';

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
        stateRule[OBJECTPREFIX + 'object__c'] = action.objectName;
        isNew = true;
      }

      var residentLicenseRule;
      if (action.ruleSetResult && action.ruleSetResult.residentLicenseRule) {
        residentLicenseRule = Utils.lowKey(action.ruleSetResult.residentLicenseRule);
      }
      else {
        residentLicenseRule = defaultRuleSet.residentLicenseRule;
      }
      var residentRuleOn = residentLicenseRule[OBJECTPREFIX + 'value__c'] ? true : false;

      ruleSet.filterRuleLogic = Utils.lowKey(ruleSet.filterRuleLogic);
      var advancedRuleLogicStr = '';
      if (ruleSet.filterRuleLogic && ruleSet.filterRuleLogic[OBJECTPREFIX + 'logic__c']) {
        advancedRuleLogicStr = Utils.convertDbLogicToUi(ruleSet.filterRuleLogic[OBJECTPREFIX + 'logic__c']);
      }
      ruleSet.licenseRuleLogic = Utils.lowKey(ruleSet.licenseRuleLogic);
      var complianceRuleLogicStr = '';
      if (ruleSet.licenseRuleLogic && ruleSet.licenseRuleLogic[OBJECTPREFIX + 'logic__c']) {
        complianceRuleLogicStr = Utils.convertDbLogicToUi(ruleSet.licenseRuleLogic[OBJECTPREFIX + 'logic__c']);
      }

      var advancedRuleLogic = Object.assign({}, state.advancedRuleLogic, ruleSet.filterRuleLogic);
      var complianceRuleLogic = Object.assign({}, state.complianceRuleLogic, ruleSet.licenseRuleLogic);
      advancedRuleLogic[OBJECTPREFIX + 'logic__c'] = advancedRuleLogicStr;
      complianceRuleLogic[OBJECTPREFIX + 'logic__c'] = complianceRuleLogicStr;
      var isReadOnly = (stateRule[OBJECTPREFIX + 'isactive__c'] || stateRule[OBJECTPREFIX + 'isactive__c']) ? true : false;
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

        var isactive = (ruleSetResult.stateRule[OBJECTPREFIX + 'isactive__c'] || ruleSetResult.stateRule[OBJECTPREFIX + 'isactive__c']) ? true : false;
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
      complianceRuleLogic[OBJECTPREFIX + 'logic__c'] = logic;
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
      advancedRuleLogic[OBJECTPREFIX + 'logic__c'] = logic;
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
        advancedRuleLogic[OBJECTPREFIX + 'logic__c'] = advancedRuleLogic[OBJECTPREFIX + 'logic__c'] + " and " + (advancedRulesList.length + 1);
      } else {
        advancedRuleLogic[OBJECTPREFIX + 'logic__c'] = "1";
      }
      var rule = {};

      rule[OBJECTPREFIX + 'object__c'] = action.objectName;
      rule[OBJECTPREFIX + 'field__c'] = "";
      rule[OBJECTPREFIX + 'operator__c'] = "";
      rule[OBJECTPREFIX + 'value__c'] = "";
      rule[OBJECTPREFIX + 'isactive__c'] = false;

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
        complianceRuleLogic[OBJECTPREFIX + 'logic__c'] = complianceRuleLogic[OBJECTPREFIX + 'logic__c'] + " and " + (complianceRulesList.length + 1);
      } else {
        complianceRuleLogic[OBJECTPREFIX + 'logic__c'] = "1";
      }
      var rule = {};
      rule[OBJECTPREFIX + 'object__c'] = action.objectName;
      rule[OBJECTPREFIX + 'license_field__c'] = "";
      rule[OBJECTPREFIX + 'operator__c'] = "";
      rule[OBJECTPREFIX + 'isactive__c'] = false;
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
        case OBJECTPREFIX + 'field__c':
          rulesListItem[OBJECTPREFIX + 'field__c'] = action.itemValue;
          rulesListItem[OBJECTPREFIX + 'operator__c'] = '';
          rulesListItem[OBJECTPREFIX + 'value__c'] = '';
          var fieldType = state.sobject.fields[rulesListItem[OBJECTPREFIX + 'field__c']];
          if (fieldType === 'BOOLEAN_FIELD') {
            rulesListItem[OBJECTPREFIX + 'value__c'] = 'true';
            advancedErrors.push(itemIndex + '1');
            advancedErrors = _.without(advancedErrors, itemIndex + '2');
          }
          else if (fieldType === 'DATE_FIELD') {
            rulesListItem[OBJECTPREFIX + 'value__c'] = Utils.formatSfdcDate(new Date());
            advancedErrors.push(itemIndex + '1');
            advancedErrors = _.without(advancedErrors, itemIndex + '2');
          }
          else if (fieldType === 'DATETIME_FIELD') {
            rulesListItem[OBJECTPREFIX + 'value__c'] = Utils.formatSfdcDateTime(new Date());
            advancedErrors.push(itemIndex + '1');
            advancedErrors = _.without(advancedErrors, itemIndex + '2');
          }
          else {
            advancedErrors.push(itemIndex + '1', itemIndex + '2');
          }
          error = true;
          break;
        case OBJECTPREFIX + 'operator__c':
          var fieldType = state.sobject.fields[rulesListItem[OBJECTPREFIX + 'field__c']];
          rulesListItem[OBJECTPREFIX + 'operator__c'] = action.itemValue;
          if (action.itemValue === 'not blank') {
            advancedErrors = _.without(advancedErrors, itemIndex + '2');
            rulesListItem[OBJECTPREFIX + 'value__c'] = '';
          }
          else if (fieldType === 'BOOLEAN_FIELD') {
            rulesListItem[OBJECTPREFIX + 'value__c'] = rulesListItem[OBJECTPREFIX + 'value__c'] ? rulesListItem[OBJECTPREFIX + 'value__c'] : 'true';
          }
          else if (fieldType === 'DATE_FIELD') {
            rulesListItem[OBJECTPREFIX + 'value__c'] = rulesListItem[OBJECTPREFIX + 'value__c'] ? rulesListItem[OBJECTPREFIX + 'value__c'] : Utils.formatSfdcDate(new Date());
          }
          else if (fieldType === 'DATETIME_FIELD') {
            rulesListItem[OBJECTPREFIX + 'value__c'] = rulesListItem[OBJECTPREFIX + 'value__c'] ? rulesListItem[OBJECTPREFIX + 'value__c'] : Utils.formatSfdcDateTime(new Date());
          } else {
            advancedErrors.push(itemIndex + '2');
          }
          break;
        case OBJECTPREFIX + 'value__c':
          rulesListItem[OBJECTPREFIX + 'value__c'] = action.itemValue;
          if (rulesListItem[OBJECTPREFIX + 'field__c']) {
            //there may not be a field selected, so check first
            var fieldType = state.sobject.fields[rulesListItem[OBJECTPREFIX + 'field__c']]
            if (fieldType === 'DATE_FIELD') {
              rulesListItem[OBJECTPREFIX + 'value__c'] = Utils.formatSfdcDate(action.itemValue);
            }
            else if (fieldType === 'DATETIME_FIELD') {
              rulesListItem[OBJECTPREFIX + 'value__c'] = Utils.formatSfdcDateTime(action.itemValue);
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
      logic[OBJECTPREFIX + 'logic__c'] = action.value;
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
      var isNewRuleListItem = (rulesListItem[OBJECTPREFIX + 'field__c'] != '' && rulesListItem[OBJECTPREFIX + 'operator__c'] != '' && rulesListItem[OBJECTPREFIX + 'value__c'] != '');
      var error = false;

      switch (action.itemName) {
        case OBJECTPREFIX + 'license_field__c':
          rulesListItem[OBJECTPREFIX + 'license_field__c'] = action.itemValue;
          if (isNewRuleListItem) {
            rulesListItem[OBJECTPREFIX + 'operator__c'] = '';
            rulesListItem[OBJECTPREFIX + 'field__c'] = '';
            complianceErrors.push(itemIndex + '1', itemIndex + '2');
            error = true;
          }
          break;
        case OBJECTPREFIX + 'operator__c':
          rulesListItem[OBJECTPREFIX + 'operator__c'] = action.itemValue;
          break;
        case OBJECTPREFIX + 'field__c':
          rulesListItem[OBJECTPREFIX + 'field__c'] = action.itemValue;
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
      logic[OBJECTPREFIX + 'logic__c'] = action.value;
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
        residentRule[OBJECTPREFIX + 'object__c'] = action.objectName;
        residentRule[OBJECTPREFIX + 'value__c'] = 'Resident State';
        residentRule[OBJECTPREFIX + 'license_field__c'] = 'RecordType.Name';
        residentRule[OBJECTPREFIX + 'operator__c'] = 'equals';
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
      stateRule[OBJECTPREFIX + 'field__c'] = action.itemValue
      if (stateRule[OBJECTPREFIX + 'field__c'] === '') {
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
    case types.SET_NIPR_URL:
      return Object.assign({}, state, {
        niprShowUrl: true
      });

    case types.LICENSE_APPROVAL_RESULT_RECEIVED:
      var filter_toggle = false;
      var defaultRuleSet = Object.assign({}, constants.BLANK_LICENSE_APROVAL_RULE_SET_RESULT);
      action.niprSyncConfig = Utils.lowKey(action.niprSyncConfig);
      var ruleSet;
      if (action.licencesRuleObject) {
        action.licencesRuleObject.licenseRuleLogic = Utils.lowKey(action.licencesRuleObject.licenseRuleLogic);
        action.licencesRuleObject.licenseRules = Utils.lowKeyArray(action.licencesRuleObject.licenseRules);
        ruleSet = action.licencesRuleObject;

      }
      else {
        ruleSet = defaultRuleSet.ruleSets[0];
      }
      if (_.filter(ruleSet.licenseRules, { [OBJECTPREFIX + 'isactive__c']: true }).length == ruleSet.licenseRules.length
        && ruleSet.licenseRuleLogic[OBJECTPREFIX + 'isactive__c'] && _.filter(ruleSet.licenseRules, { [OBJECTPREFIX + 'isactive__c']: true }).length != 0) {
        filter_toggle = true;
      }
      var advancedRuleLogicStr = '';
      if (ruleSet.licenseRuleLogic && ruleSet.licenseRuleLogic[OBJECTPREFIX + 'logic__c']) {
        advancedRuleLogicStr = Utils.convertDbLogicToUi(ruleSet.licenseRuleLogic[OBJECTPREFIX + 'logic__c']);
      }
      var advancedRuleLogic = Object.assign({}, state.licenseRuleLogic, ruleSet.licenseRuleLogic);
      advancedRuleLogic[OBJECTPREFIX + 'logic__c'] = advancedRuleLogicStr;
      var validation_user = { 'Username': action.niprSyncConfig[OBJECTPREFIX + 'nipr_integration_user_name__c'] };
      let validationUserError=false
      if(validation_user.Username==="" || validation_user.Username===undefined){
        validationUserError=true
      }

      return Object.assign({}, state, {
        licencesRuleObject: ruleSet,
        licenseRuleLogic: advancedRuleLogic,
        niprSyncConfig: action.niprSyncConfig,
        validationUser: validation_user,
        loaded: true,
        errors: false,
        deletedLicenseRules: ruleSet.deletedLicenseRules,
        isLicenseRuleLogicRemoved: ruleSet.isLicenseRuleLogicRemoved,
        automatic_license_approval: filter_toggle,
        validationUserError:validationUserError
      });

    case types.LICENSE_APPROVAL_FIELDS_RESULT_RECEIVED:
      return Object.assign({}, state, {
        licenseApprovalFileds: action.licenseRuleField
      });

    case types.SELECT_LICENSE_CHANGE_RULE:
      var rulesList = Object.assign([], state.licencesRuleObject.licenseRules);
      var itemIndex = action.index;
      var rulesListItem = rulesList[itemIndex];
      var advancedErrors = Object.assign([], state.advancedErrors)
      var error = false;

      switch (action.itemName) {
        case OBJECTPREFIX + 'license_field__c':
          rulesListItem[OBJECTPREFIX + 'license_field__c'] = action.itemValue;
          rulesListItem[OBJECTPREFIX + 'operator__c'] = '';
          rulesListItem[OBJECTPREFIX + 'value__c'] = '';
          var fieldType = state.licenseApprovalFileds.fields[rulesListItem[OBJECTPREFIX + 'license_field__c']];
          if (fieldType === 'BOOLEAN_FIELD') {
            rulesListItem[OBJECTPREFIX + 'value__c'] = 'true';
            advancedErrors.push(itemIndex + '1');
            advancedErrors = _.without(advancedErrors, itemIndex + '2');
          }
          else if (fieldType === 'DATE_FIELD') {
            rulesListItem[OBJECTPREFIX + 'value__c'] = Utils.formatSfdcDate(new Date());
            advancedErrors.push(itemIndex + '1');
            advancedErrors = _.without(advancedErrors, itemIndex + '2');
          }
          else if (fieldType === 'DATETIME_FIELD') {
            rulesListItem[OBJECTPREFIX + 'value__c'] = Utils.formatSfdcDateTime(new Date());
            advancedErrors.push(itemIndex + '1');
            advancedErrors = _.without(advancedErrors, itemIndex + '2');
          }
          else {
            advancedErrors.push(itemIndex + '1', itemIndex + '2');
          }
          error = true;
          break;
        case OBJECTPREFIX + 'operator__c':
          var fieldType = state.licenseApprovalFileds.fields[rulesListItem[OBJECTPREFIX + 'license_field__c']];
          rulesListItem[OBJECTPREFIX + 'operator__c'] = action.itemValue;
          if (action.itemValue === 'not blank') {
            advancedErrors = _.without(advancedErrors, itemIndex + '2');
            rulesListItem[OBJECTPREFIX + 'value__c'] = '';
          }
          else if (fieldType === 'BOOLEAN_FIELD') {
            rulesListItem[OBJECTPREFIX + 'value__c'] = rulesListItem[OBJECTPREFIX + 'value__c'] ? rulesListItem[OBJECTPREFIX + 'value__c'] : 'true';
          }
          else if (fieldType === 'DATE_FIELD') {
            rulesListItem[OBJECTPREFIX + 'value__c'] = rulesListItem[OBJECTPREFIX + 'value__c'] ? rulesListItem[OBJECTPREFIX + 'value__c'] : Utils.formatSfdcDate(new Date());
          }
          else if (fieldType === 'DATETIME_FIELD') {
            rulesListItem[OBJECTPREFIX + 'value__c'] = rulesListItem[OBJECTPREFIX + 'value__c'] ? rulesListItem[OBJECTPREFIX + 'value__c'] : Utils.formatSfdcDateTime(new Date());
          } else {
            advancedErrors.push(itemIndex + '2');
          }
          break;
        case OBJECTPREFIX + 'value__c':
          rulesListItem[OBJECTPREFIX + 'value__c'] = action.itemValue;
          if (rulesListItem[OBJECTPREFIX + 'license_field__c']) {
            //there may not be a field selected, so check first
            var fieldType = state.licenseApprovalFileds.fields[rulesListItem[OBJECTPREFIX + 'license_field__c']]
            if (fieldType === 'DATE_FIELD') {
              rulesListItem[OBJECTPREFIX + 'value__c'] = Utils.formatSfdcDate(action.itemValue);
            }
            else if (fieldType === 'DATETIME_FIELD') {
              rulesListItem[OBJECTPREFIX + 'value__c'] = Utils.formatSfdcDateTime(action.itemValue);
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
      let licencesRuleObject = Object.assign({}, state.licencesRuleObject)
      licencesRuleObject.licenseRules = rulesList
      return Object.assign({}, state, {
        licencesRuleObject: licencesRuleObject,
        advancedErrors: advancedErrors,
        errors: error
      });

    case types.ADD_LICENSE_RULE:
      var licencesRuleObject = Object.assign([], state.licencesRuleObject);
      var licenseRuleLogic = Object.assign({}, state.licenseRuleLogic);
      //var isFilterRuleLogicRemoved = state.isFilterRuleLogicRemoved;
      var currentIndex = licencesRuleObject.licenseRules.length;
      var err = [currentIndex + '0', currentIndex + '1', currentIndex + '2']
      var advancedErrors = _.union(state.advancedErrors, err);
      if (isFilterRuleLogicRemoved) {
        //  isFilterRuleLogicRemoved = false;
      }
      if (licencesRuleObject.licenseRules.length > 0) {
        licenseRuleLogic[OBJECTPREFIX + 'logic__c'] = licenseRuleLogic[OBJECTPREFIX + 'logic__c'] + " and " + (licencesRuleObject.licenseRules.length + 1);
      } else {
        licenseRuleLogic[OBJECTPREFIX + 'logic__c'] = "1";
      }
      var rule = {};

      rule[OBJECTPREFIX + 'object__c'] = OBJECTPREFIX + 'License__c';
      rule[OBJECTPREFIX + 'license_field__c'] = "";
      rule[OBJECTPREFIX + 'operator__c'] = "";
      rule[OBJECTPREFIX + 'value__c'] = "";
      rule[OBJECTPREFIX + 'isactive__c'] = true;

      licencesRuleObject.licenseRules.push(rule);
      return Object.assign({}, state, {
        advancedErrors: advancedErrors,
        licencesRuleObject: licencesRuleObject,
        licenseRuleLogic: licenseRuleLogic,
        //isFilterRuleLogicRemoved: isFilterRuleLogicRemoved,
        errors: true
      });

    case types.DELETE_LICENSE_RULE:
      var licencesRuleObject = Object.assign([], state.licencesRuleObject);
      var licenseRuleLogic = Object.assign({}, state.licenseRuleLogic);
      var deletedRuleList = Object.assign([], state.deletedLicenseRules);
      var isLogicRemoved = state.isLicenseRuleLogicRemoved;
      var advancedErrors = Object.assign([], state.advancedErrors);
      var error = false;
      advancedErrors = _.without(advancedErrors, action.index + '0', action.index + '1', action.index + '2');
      var logic = "";
      if (licencesRuleObject.licenseRules.length - 1 > 0) {
        logic = "1";
        for (var i = 2; i < licencesRuleObject.licenseRules.length; i++) {
          logic = logic + " and " + i;
        }
      }
      licenseRuleLogic[OBJECTPREFIX + 'logic__c'] = logic;
      var deletedRule = licencesRuleObject.licenseRules.splice(action.index, 1);
      deletedRule[0][OBJECTPREFIX + 'isactive__c'] = false;
      if (licencesRuleObject.licenseRules.length && deletedRule[0].id) {
        deletedRuleList.push(deletedRule[0]);
      } else if (!licencesRuleObject.licenseRules.length && deletedRule[0].id) {
        deletedRuleList.push(deletedRule[0]);
        isLogicRemoved = true;
      } else if (!licencesRuleObject.licenseRules.length) {
        isLogicRemoved = true;
      }

      error = (advancedErrors.length);
      return Object.assign({}, state, {
        licencesRuleObject: licencesRuleObject,
        licenseRuleLogic: licenseRuleLogic,
        deletedLicenseRules: deletedRuleList,
        isLicenseRuleLogicRemoved: isLogicRemoved,
        advancedErrors: advancedErrors,
        errors: error
      });

    case types.CHANGE_LICENSE_RULE_LOGIC:
      var logic = Object.assign({}, state.licenseRuleLogic);
      logic[OBJECTPREFIX + 'logic__c'] = action.value;
      var error = false;
      if (action.error) {
        error = true;
      } else if (state.advancedErrors.length) {
        error = true;
      } else {
        error = false;
      }
      return Object.assign({}, state, {
        licenseRuleLogic: logic,
        errors: error
      });

    case types.TOGGLE_ACTIVATE_LICENSE:
      var licencesRuleObject = Object.assign([], state.licencesRuleObject);
      var licenseRuleLogic = Object.assign({}, state.licenseRuleLogic);
      var deletedRuleList = Object.assign([], state.deletedLicenseRules);
      var isLogicRemoved = state.isLicenseRuleLogicRemoved;
      licencesRuleObject.deletedLicenseRules = deletedRuleList;
      licencesRuleObject.isLicenseRuleLogicRemoved = isLogicRemoved;
      if (!action.value) {
        _.map(licencesRuleObject.licenseRules, (value, key) => {
          licencesRuleObject.licenseRules[key][OBJECTPREFIX + "isactive__c"] = false;
        })
        if (licencesRuleObject.licenseRules.length != 0) {
          licenseRuleLogic[OBJECTPREFIX + "isactive__c"] = false;
          licencesRuleObject.licenseRuleLogic = licenseRuleLogic;
        }
      } else {
        _.map(licencesRuleObject.licenseRules, (value, key) => {
          licencesRuleObject.licenseRules[key][OBJECTPREFIX + "isactive__c"] = true;
        })
        if (licencesRuleObject.licenseRules.length != 0) {
          licenseRuleLogic[OBJECTPREFIX + "isactive__c"] = true;
          licencesRuleObject.licenseRuleLogic = licenseRuleLogic;
        }
      }
      //licencesRuleObject.licenseRuleLogic[OBJECTPREFIX + "isactive__c"] = true;
      return Object.assign({}, state, {
        automatic_license_approval: action.value,
        licenseRuleLogic: licenseRuleLogic
      });

    case types.TOGGLE_FORCE_EXPIRE:
      var niprSyncConfig = Object.assign({}, state.niprSyncConfig);
      niprSyncConfig[OBJECTPREFIX + "forceexpire__c"] = action.value;
      return Object.assign({}, state, {
        niprSyncConfig: niprSyncConfig
      });

    case types.ON_CHANGE_APPROVAL_PROCESS:
      var niprSyncConfig = Object.assign({}, state.niprSyncConfig);
      niprSyncConfig[OBJECTPREFIX + "approvalprocess__c"] = action.value;
      return Object.assign({}, state, {
        niprSyncConfig: niprSyncConfig
      });

    case types.ON_VALIDATION_USER_RECEIVE:
      return Object.assign({}, state, {
        validationUserList: action.usersList
      });

    case types.ON_CHANGE_USER_SEARCH_STRING:
      return Object.assign({}, state, {
        validationUser: action.value,
      });

    case types.SAVE_LICENSE_APPROVAL_RULE:
      hashHistory.push('/db');
      return state;

    case types.ON_APPROVAL_PROCESS_RECEIVE:
      return Object.assign({}, state, {
        approvalProcessList: action.approvalProcessList,
      });

    case types.CLEAR_USER_SEARCH_RESULT:
      return Object.assign({}, state, {
        validationUserList: [],
      });

    case types.XML_RECEIVED:
      return Object.assign({}, state, {
        xmlReceived: action.xmlReceived,
        fileName: action.fileName
      });

    case types.PRODUCERS_UPLOAD_INSERTED:
      var insertedProcedures = Utils.lowKeyArray(action.insertedProcedures);
      var newState = Object.assign({}, state);
      if (_.isArray(action.errorMessages)) {
        action.errorMessages.map(function (item, i) {
          if (!item.isSuccess) {
            newState.errorMessages.push(item);
          }
        }, this);
      }
      return Object.assign({}, state, {
        xmlReceived: {},
        insertedProcedures: insertedProcedures,
        progressBarValue: state.progressBarValue + action.progressBarValue,
        errorMessages: newState.errorMessages,
        showToast: action.showToast
      });

    case types.SHOW_PROGRESS:
      return Object.assign({}, state, {
        showProgress: action.showProgress,
      });

    case types.UPLOAD_SUCCESS:
      return Object.assign({}, state, {
        progressBarValue: 0,
        showProgress: false,
        showToast: true
      });

    case types.UPLOAD_ERROR:
      return Object.assign({}, state, {
        progressBarValue: 0,
        showProgress: false,
      });
    case types.UPDATE_PROGRESS:
      return Object.assign({}, state, {
        progressBarValue: action.progressValue,
        showProgress: action.showProgress
      });

    case types.UPLOAD_STARTED:
      return Object.assign({}, state, {
        xmlReceived: {},
        insertedProcedures: [],
        showProgress: true,
        progressBarValue: 5,
        errorMessages: [],
        fileName: constants.CHOOSE_FILE
      });

    case types.SET_URL_ERROR:
      return Object.assign({}, state, {
        herokuURLError: action.value,
        herokuURLSuccess: !action.value
      });

    case types.HEROKU_URL_CHANGE:
      return Object.assign({}, state, {
        herokuURL: action.value
      });

    case types.IS_MAINTAINANCE_MODE:
      return Object.assign({}, state, {
        isMaintainanceMode: true
      });

    case types.SHOW_INVALID_TOAST:
      return Object.assign({}, state, {
        showInvalidToast: true,
        showProgress: false
      });

    case types.HIDE_INVALID_TOAST:
      return Object.assign({}, state, {
        showInvalidToast: false
      });

    case types.SHOW_INVALID_DB_TOAST:
      return Object.assign({}, state, {
        showInvalidDbToast: true,
        showProgress: false
      });

    case types.HIDE_INVALID_DB_TOAST:
      return Object.assign({}, state, {
        showInvalidDbToast: false
      });

    case types.SHOW_INVALID_FILE_TOAST:
      return Object.assign({}, state, {
        showInvalidFileToast: true,
        showProgress: false
      });

    case types.HIDE_INVALID_FILE_TOAST:
      return Object.assign({}, state, {
        showInvalidFileToast: false
      });
    case types.VALIDATION_USER_ERROR:
      return Object.assign({}, state, {
        validationUserError: action.value
      });
    default:
      return state;
  }
}