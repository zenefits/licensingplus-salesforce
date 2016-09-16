import React, { Component } from 'react';
import { connect } from 'react-redux';
import {
    getApprovalCriteriaConfig,
    getLicenseApprovalFields,
    selectLicenseChange,
    addLicenseRule,
    deleteLicenseRule,
    changeLicenseRuleLogic,
    toggleChangeActivateLicense,
    toggleChangeForceExpire,
    saveLicenseApprovalRuleSetResult,
    onChangeApprovalProcess,
    getValidationUser,
    setValidationUser,
    getApprovalProcesses,
    clearUserSearchResult,
    setValidationUserError} from '../actions/approval-rule-action';
import ApprovalView from './approval-rule.view';
import * as constants from '../constants/constants';
import {OBJECTPREFIX } from '../constants/constants';
import Utils from '../utils/utils';

class RuleContainer extends Component {
    constructor(props) {
        super(props);
        this.validate = this.validate.bind(this);
        this.renderLicenseFields = this.renderLicenseFields.bind(this);
        this.renderLicenseOperators = this.renderLicenseOperators.bind(this);
        this.addLicenseRule = this.addLicenseRule.bind(this);
        this.changeLicenseRuleLogic = this.changeLicenseRuleLogic.bind(this);
        this.deleteLicenseRule = this.deleteLicenseRule.bind(this);
        this.handleLicenseChange = this.handleLicenseChange.bind(this);
        this.onChangeApprovalProcess = this.onChangeApprovalProcess.bind(this);
        this.onValidationUserChange = this.onValidationUserChange.bind(this);
        this.saveLicenseApprovalRuleSetResult = this.saveLicenseApprovalRuleSetResult.bind(this);
        this.approvalProcessFields = this.approvalProcessFields.bind(this);
        this.cancelLicenseApprovalRuleSetResult = this.cancelLicenseApprovalRuleSetResult.bind(this);
    }

    componentDidMount() {  
        this.props.getApprovalCriteriaConfig();
        this.props.getLicenseApprovalFields(OBJECTPREFIX + 'license__c');
        this.props.getApprovalProcesses();
    }
    onValidationUserChange(value) {
        this.props.setValidationUserError(true);
        if (value.length < 3) {
            this.props.clearUserSearchResult();
            return;
        }
        this.props.getValidationUser(value);
    }

    validate(value) {
        if (_.trim(value) === '') {
            return false;
        } else {
            return true;
        }
    }

    onChangeApprovalProcess(event) {
        this.props.onChangeApprovalProcess(event.target.value);
    }

    addLicenseRule() {
        this.props.addLicenseRule();
    }

    deleteLicenseRule(index) {
        this.props.deleteLicenseRule(index);
    }

    changeLicenseRuleLogic(error, rulesLen, event) {
        var exp = constants.RULE_EXP;
        var logic = event.target.value.replace(exp, '');
        if (Utils.checkSyntax(logic, rulesLen)) {
            this.props.changeLicenseRuleLogic(event.target.value.replace(exp, ''), false);
        } else {
            this.props.changeLicenseRuleLogic(event.target.value.replace(exp, ''), true);
        }
    }


    handleLicenseChange(index, colIndex, fieldValue, colName, event) {
        var valueType = 'STRING_FIELD';
        var error = this.props.errors;
        var value;

        if (colName === OBJECTPREFIX + 'license_field__c') {
            value = event.target.value;
            valueType = this.props.licenseApprovalFileds.fields[value];
            error = (_.trim(value) === '') ? true : false;
        } else if (colName === OBJECTPREFIX + 'operator__c') {
            value = event.target.value;
            valueType = this.props.licenseApprovalFileds.fields[fieldValue];
            error = (_.trim(value) === '') ? true : false;
        } else if (colName === OBJECTPREFIX + 'value__c') {
            valueType = this.props.licenseApprovalFileds.fields[fieldValue];
            switch (valueType) {
                case 'BOOLEAN_FIELD':
                    error = false;
                    value = event.target.value;
                    break;
                case 'DATE_FIELD':
                    value = Utils.formatSfdcDate(event);
                    break;
                case 'DATETIME_FIELD':
                    value = Utils.formatSfdcDateTime(event);
                    break;
                default:
                    value = event.target.value;
                    error = (_.trim(value) === '') ? true : false;
            }
        }
        this.props.selectLicenseChange(value, colName, index, colIndex, error);
    }


    renderLicenseFields() {
        var options = [<option key={'Field'} value=''>Field</option>];
        return options.concat(
            _.chain(this.props.licenseApprovalFileds.fields)
            .keys()
            .sortBy((key) => {return key})
            .map((key) => {
              return (
                    <option key={key} value={key}>{key}</option>
                );
            })
            .value()
        );
    }
    renderLicenseOperators(valueType) {
        var options = [<option key={'Operator'} value=''>Operator</option>];
        var operators = constants.FIELD_OPERATORS;
        return options.concat(
            _.map(operators[this.props.licenseApprovalFileds.fields[valueType]], (value, key) => {
                return (
                    <option key={key} value={key}>{value}</option>
                );
            })
        );
    }
    approvalProcessFields(event) {
        return _.map(this.props.approvalProcessList, (value, key) => {
            return (
                <option key={key} value={value}>{value}</option>
            );
        })
    }
    saveLicenseApprovalRuleSetResult() {
        let licencesRuleObject = Object.assign({}, this.props.licencesRuleObject);
        licencesRuleObject.licenseRuleLogic = Object.assign({}, this.props.licenseRuleLogic);
        licencesRuleObject.licenseRuleLogic[OBJECTPREFIX + 'logic__c'] = Utils.convertUiLogicToDb(licencesRuleObject.licenseRuleLogic[OBJECTPREFIX + 'logic__c']);
        licencesRuleObject.deletedLicenseRules = this.props.deletedLicenseRules;
        licencesRuleObject.isLicenseRuleLogicRemoved = this.props.isLicenseRuleLogicRemoved;
        let niprSyncConfig = Object.assign({}, this.props.niprSyncConfig);
        niprSyncConfig[OBJECTPREFIX + "nipr_integration_user_name__c"] = this.props.validationUser.Username
        this.props.saveLicenseApprovalRuleSetResult(niprSyncConfig, licencesRuleObject);
    }

    cancelLicenseApprovalRuleSetResult() {
        this.props.getApprovalCriteriaConfig();
        this.props.getLicenseApprovalFields(OBJECTPREFIX + 'license__c');
        this.props.getApprovalProcesses();     
    }

    render() {
        return (
            <div>
                <ApprovalView
                    licencesRuleObject={this.props.licencesRuleObject}
                    licenseApprovalFileds={this.props.licenseApprovalFileds}
                    validate={this.validate}
                    renderLicenseFields={this.renderLicenseFields}
                    renderLicenseOperators={this.renderLicenseOperators}
                    handleLicenseChange={this.handleLicenseChange}
                    addLicenseRule={this.addLicenseRule}
                    deleteLicenseRule={this.deleteLicenseRule}
                    changeLicenseRuleLogic={this.changeLicenseRuleLogic}
                    licenseRuleLogic={this.props.licenseRuleLogic}
                    errors={this.props.errors}
                    toggleChangeForceExpire={this.props.toggleChangeForceExpire}
                    toggleChangeActivateLicense={this.props.toggleChangeActivateLicense}
                    saveLicenseApprovalRuleSetResult={this.saveLicenseApprovalRuleSetResult}
                    onChangeApprovalProcess={this.onChangeApprovalProcess}
                    validationUserList={this.props.validationUserList}
                    onValidationUserChange={this.onValidationUserChange}
                    setValidationUser={this.props.setValidationUser}
                    validationUser={this.props.validationUser}
                    niprSyncConfig={this.props.niprSyncConfig}
                    approvalProcessFields={this.approvalProcessFields}
                    automatic_license_approval={this.props.automatic_license_approval}
                    loaded={this.props.loaded}
                    deletedLicenseRules= {this.props.deletedLicenseRules}
                    isLicenseRuleLogicRemoved= {this.props.isLicenseRuleLogicRemoved}
                    isMaintainanceMode={this.props.isMaintainanceMode}
                    cancelLicenseApprovalRuleSetResult={this.cancelLicenseApprovalRuleSetResult}
                    validationUserError={this.props.validationUserError}
                    setValidationUserError={this.props.setValidationUserError}
                />
            </div>
        );
    }
}


const mapStateToProps = (state) => {
    return {
        licenseApprovalFileds: state.licenseApprovalFileds,
        licenseRuleLogic: state.licenseRuleLogic,
        errors: state.errors,
        validationUserList: state.validationUserList,
        validationUser: state.validationUser,
        niprSyncConfig: state.niprSyncConfig,
        licencesRuleObject: state.licencesRuleObject,
        approvalProcessList: state.approvalProcessList,
        automatic_license_approval: state.automatic_license_approval,
        loaded: state.loaded,
        deletedLicenseRules: state.deletedLicenseRules,
        isLicenseRuleLogicRemoved: state.isLicenseRuleLogicRemoved,
        isMaintainanceMode: state.isMaintainanceMode,
        validationUserError:state.validationUserError
    }
}

const mapDispatchToProps = (dispatch) => {
    return {
        getApprovalCriteriaConfig: () => {
            dispatch(getApprovalCriteriaConfig());
        },
        getLicenseApprovalFields: (objectName) => {
            dispatch(getLicenseApprovalFields(objectName));
        },
        selectLicenseChange: (itemValue, itemName, index, colIndex, error) => {
            dispatch(selectLicenseChange(itemValue, itemName, index, colIndex, error));
        },
        addLicenseRule: () => {
            dispatch(addLicenseRule());
        },
        deleteLicenseRule: (index) => {
            dispatch(deleteLicenseRule(index));
        },
        changeLicenseRuleLogic: (value, error) => {
            dispatch(changeLicenseRuleLogic(value, error));
        },
        toggleChangeActivateLicense: (value) => {
            dispatch(toggleChangeActivateLicense(value));
        },
        toggleChangeForceExpire: (value) => {
            dispatch(toggleChangeForceExpire(value));
        },
        saveLicenseApprovalRuleSetResult: (niprSyncConfig, licencesRuleObject) => {
            dispatch(saveLicenseApprovalRuleSetResult(niprSyncConfig, licencesRuleObject));
        },
        onChangeApprovalProcess: (value) => {
            dispatch(onChangeApprovalProcess(value));
        },
        getValidationUser: (searchStr) => {
            dispatch(getValidationUser(searchStr));
        },
        setValidationUser: (searchStr) => {
            dispatch(setValidationUser(searchStr));
        },
        getApprovalProcesses: () => {
            dispatch(getApprovalProcesses());
        },
        clearUserSearchResult: () => {
            dispatch(clearUserSearchResult());
        },
        setValidationUserError: (value) => {
            dispatch(setValidationUserError(value));
        },
    }
}

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(RuleContainer)