import React, { Component, PropTypes } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux';
import _ from 'lodash';
import moment from 'moment';
import Toggle from 'react-toggle'
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import {OBJECTPREFIX } from '../constants/constants';
import * as constants from '../constants/constants';
import Utils from '../utils/utils';
import { Tooltip } from 'reactstrap';

import {
  addAdvancedRule,
  addComplianceRule,
  changeAdvancedRuleLogic,
  changeComplianceRuleLogic,
  clearState,
  deleteAdvancedRule,
  deleteComplianceRule,
  getLicenseFields,
  getLicenseRuleSetResult,
  getSobjectWithFields,
  hideToast,
  saveLicenseRuleSetResult,
  selectAdvancedChange,
  selectComplianceChange,
  selectStateRuleChange,
  toggleChangeResidentRule,
  showAdvancedRule
} from '../actions/object-rule-set-actions';
import Sidebar from './sidebar.container';

export class ObjectRuleSet extends Component {

  constructor(props) {
    super(props);
    this.state = {
      advancedRulesList: [],
      advancedRuleLogic: {},
      complianceRulesList: [],
      complianceRuleLogic: {},
      deletedRegularFilterRules: [],
      deletedLicenseRules: [],
      errors: false,
      isFilterRuleLogicRemoved: false,
      isLicenseRuleLogicRemoved: false,
      isReadOnly: false,
      residentRule: null,
      residentRuleOn: false,
      stateRule: {},
      showAdvancedRule: 'All',
      showToast: false,
      sobject: {},
      loaded: false,
      licenseSobject: {}
    }

    this.addAdvancedRule = this.addAdvancedRule.bind(this);
    this.addComplianceRule = this.addComplianceRule.bind(this);
    this.changeAdvancedRuleLogic = this.changeAdvancedRuleLogic.bind(this);
    this.changeComplianceRuleLogic = this.changeComplianceRuleLogic.bind(this);
    this.deleteAdvancedRule = this.deleteAdvancedRule.bind(this);
    this.deleteComplianceRule = this.deleteComplianceRule.bind(this);
    this.handleAdvancedChange = this.handleAdvancedChange.bind(this);
    this.handleComplianceChange = this.handleComplianceChange.bind(this);
    this.handleStateRuleChange = this.handleStateRuleChange.bind(this);
    this.renderAdvancedRules = this.renderAdvancedRules.bind(this);
    this.renderComplianceRules = this.renderComplianceRules.bind(this);
    this.saveLicenseRuleSetResult = this.saveLicenseRuleSetResult.bind(this);
    this.toggleChangeResidentRule = this.toggleChangeResidentRule.bind(this);
    this.toggleShowAdvancedRule = this.toggleShowAdvancedRule.bind(this);
    this.validate = this.validate.bind(this);
    this.toggle = this.toggle.bind(this);
    this.state = {
      tooltipOpen: false
    };
  }

  componentWillMount() {
    this.props.getSobjectWithFields(this.props.params.sobjectname);
    this.props.getLicenseFields(OBJECTPREFIX + 'license__c');
    this.props.getLicenseRuleSetResult(this.props.params.sobjectname);
  }

  componentWillUnmount() {
    this.props.clearState();
  }

  toggle() {
    this.setState({
      tooltipOpen: !this.state.tooltipOpen
    });
  }

  saveLicenseRuleSetResult(event) {
    event.preventDefault();
    var data = {
      advancedRulesList: this.props.advancedRulesList,
      advancedRuleLogic: this.props.advancedRuleLogic,
      complianceRulesList: this.props.complianceRulesList,
      complianceRuleLogic: this.props.complianceRuleLogic,
      deletedRegularFilterRules: this.props.deletedRegularFilterRules,
      deletedLicenseRules: this.props.deletedLicenseRules,
      isFilterRuleLogicRemoved: this.props.isFilterRuleLogicRemoved,
      isLicenseRuleLogicRemoved: this.props.isLicenseRuleLogicRemoved,
      residentRule: this.props.residentRule,
      showAdvancedRule: this.props.showAdvancedRule,
      stateRule: this.props.stateRule
    }

    //only way to copy entire object by value. had issues with Object.assign({},...)
    data = JSON.parse(JSON.stringify(data));
    this.props.saveLicenseRuleSetResult(data);
  }

  validate(value) {
    if (_.trim(value) === '') {
      return false;
    } else {
      return true;
    }
  }

  renderSubmit() {
    if (this.props.errors) {
      return (
        <input className='btn btn-orange' type='button' disabled={true} onClick={this.saveLicenseRuleSetResult.bind(this) }  value={this.props.isMaintainanceMode ? 'Save' : 'Save & Next'} />
      );
    } else {
      return (        
        <input className='btn btn-orange' type='button' disabled={this.props.isReadOnly} onClick={this.saveLicenseRuleSetResult.bind(this) } value={this.props.isMaintainanceMode ? 'Save' : 'Save & Next'} />
      );
    }
  }

  toggleShowAdvancedRule(event) {
    this.props.toggleShowAdvancedRule(event.target.value);
  }

  hideToast(event) {
    event.preventDefault();
    this.props.hideToast();
  }

  renderToast() {
    if (this.props.showToast) {
      return (
        <div className="alert alert-danger toast" >
          <a onClick={this.props.hideToast.bind(null) }>Dismiss</a>
          <strong className='fa fa-exclamation-triangle'></strong> Something went wrong
        </div>
      );
    }
  }
  changeAdvancedRuleLogic(error, rulesLen, event) {
    var exp = constants.RULE_EXP;
    var logic = event.target.value.replace(exp, '');
    if (Utils.checkSyntax(logic, rulesLen)) {
      this.props.changeAdvancedRuleLogic(event.target.value.replace(exp, ''), false);
    } else {
      this.props.changeAdvancedRuleLogic(event.target.value.replace(exp, ''), true);
    }
  }

  changeComplianceRuleLogic(error, rulesLen, event) {
    var exp = constants.RULE_EXP;
    var logic = event.target.value.replace(exp, '');
    if (Utils.checkSyntax(logic, rulesLen)) {
      this.props.changeComplianceRuleLogic(event.target.value.replace(exp, ''), false);
    } else {
      this.props.changeComplianceRuleLogic(event.target.value.replace(exp, ''), true);
    }
  }

  handleAdvancedChange(index, colIndex, fieldValue, colName, event) {
    var valueType = 'STRING_FIELD';
    var error = this.props.errors;
    var value;

    if (colName === OBJECTPREFIX + 'field__c') {
      value = event.target.value;
      valueType = this.props.sobject.fields[value];
      error = (_.trim(value) === '') ? true : false;
    } else if (colName === OBJECTPREFIX + 'operator__c') {
      value = event.target.value;
      valueType = this.props.sobject.fields[fieldValue];
      error = (_.trim(value) === '') ? true : false;
    } else if (colName === OBJECTPREFIX + 'value__c') {
      valueType = this.props.sobject.fields[fieldValue];
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
    this.props.selectAdvancedChange(value, colName, index, colIndex, error);
  }

  handleComplianceChange(index, colIndex, error, event) {
    if (_.trim(event.target.value) === '') {
      this.props.selectComplianceChange(event.target.value, event.target.name, index, colIndex, true);
    } else {
      this.props.selectComplianceChange(event.target.value, event.target.name, index, colIndex, false);
    }
  }

  handleStateRuleChange(event) {
    this.props.selectStateRuleChange(event.target.value);
  }

  toggleChangeResidentRule(value, event) {
    this.props.toggleChangeResidentRule(value, this.props.params.sobjectname);
  }

  deleteComplianceRule(index) {
    this.props.deleteComplianceRule(index);
  }

  deleteAdvancedRule(index) {
    this.props.deleteAdvancedRule(index);
  }

  addComplianceRule() {
    this.props.addComplianceRule(this.props.params.sobjectname);
  }

  addAdvancedRule() {
    this.props.addAdvancedRule(this.props.params.sobjectname);
  }

  renderAdvancedFields() {
    var options = [<option key={'Field'} value=''>Field</option>];
    return options.concat(
      _.chain(this.props.sobject.fields)
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

  renderAdvancedFieldsInCompliance(valueType) {
    var fieldType = this.props.licenseSobject.fields[valueType];
    var options = [<option key={'Field'} value=''>Field</option>];
    return options.concat(
      _.chain(this.props.sobject.fields)
        .keys()
        .sortBy((key) => {return key})
        .map((key) => {
          let keyType = this.props.sobject.fields[key];
          if (keyType === fieldType) {
            return (
              <option key={key} value={key}>{_.capitalize(this.props.params.sobjectname) }.{key}</option>
            )
          }
        })
        .value()
    );
  }

  renderAdvancedOperators(valueType) {
    var options = [<option key={'Operator'} value=''>Operator</option>];
    var operators = constants.FIELD_OPERATORS;
    return options.concat(
      _.map(operators[this.props.sobject.fields[valueType]], (value, key) => {
        return (
          <option key={key} value={key}>{value}</option>
        );
      })
    );
  }

  renderComplianceFields() {
    var options = [<option key={'Field'} value=''>Field</option>];
    return options.concat(
      _.chain(this.props.licenseSobject.fields)
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

  renderComplianceOperators(valueType) {
    var options = [<option key={'Operator'} value=''>Operator</option>];
    var operators = constants.FIELD_OPERATORS;
    var excludeOperators = constants.COMPLIANCE_OPERATORS_EXCLUDE;
    return options.concat(
      _.map(operators[this.props.licenseSobject.fields[valueType]], (value, key) => {
        if (!_.includes(excludeOperators, value)) {
          return (
            <option key={key} value={key}>{value}</option>
          )
        }
      })
    )
  }

  renderStateRuleFields() {
    var options = [<option key={'Field'} value=''>Field</option>];
    return (
      options.concat(
        _.chain(this.props.sobject.fields)
        .keys()
        .sortBy((key) => {return key})
        .map((key) => {
          let keyType = this.props.sobject.fields[key];
          if (keyType === 'STRING_FIELD') {
            return (
              <option key={key} value={key}>{key}</option>
            );
          }
        })
        .value()
      )
    )
  }

  renderStateRule() {
    let stateRule = this.props.stateRule;
    //let OBJECTPREFIX = OBJECTPREFIX;
    if (stateRule && stateRule[OBJECTPREFIX + 'license_field__c']) {
      var fieldClassname = (stateRule[OBJECTPREFIX + 'field__c'] === '') ? 'form-group has-error' : ' form-group';
      return (
        <tr key={0}>
          <td></td>
          <td>
            <div className='form-group'>
              <select className='form-control' value={stateRule[OBJECTPREFIX + 'license_field__c']} name={OBJECTPREFIX + 'license_field__c'} disabled={true}>
                <option value={stateRule[OBJECTPREFIX + 'license_field__c']}>{stateRule[OBJECTPREFIX + 'license_field__c']}</option>
              </select>
            </div>
          </td>
          <td>
            <div className='form-group'>
              <select className='form-control' value={stateRule[OBJECTPREFIX + 'operator__c']} name={OBJECTPREFIX + 'operator__c'} disabled={true}>
                <option value={stateRule[OBJECTPREFIX + 'operator__c']}>{stateRule[OBJECTPREFIX + 'operator__c']}</option>
              </select>
            </div>
          </td>
          <td>
            <div className={fieldClassname}>
              <select className='form-control' disabled={this.props.isReadOnly} value={stateRule[OBJECTPREFIX + 'field__c']} onChange={this.handleStateRuleChange.bind(null) } name={OBJECTPREFIX + 'field__c'}>
                {this.renderStateRuleFields() }
              </select>
            </div>
          </td>
          <td></td>
        </tr >
      )
    }
  }

  renderComplianceRulesList() {
    if (this.props.complianceRulesList.length) {
      let licenseInput;
      let fieldInput;
      let operatorInput;
      return this.props.complianceRulesList.map((item, index) => {
        var licClassname = !this.validate(item[OBJECTPREFIX + 'license_field__c']) ? 'form-group has-error' : ' form-group';
        licenseInput = (
          <div className={licClassname} >
            <select className='form-control' disabled={this.props.isReadOnly} value={item[OBJECTPREFIX + 'license_field__c']} name={OBJECTPREFIX + 'license_field__c'} onChange={this.handleComplianceChange.bind(null, index, '0', true) }>
              {this.renderComplianceFields() }
            </select>
          </div>
        );

        var operatorClassname = !this.validate(item[OBJECTPREFIX + 'operator__c']) ? 'form-group has-error' : ' form-group';
        operatorInput = (
          <div className={operatorClassname} >
            <select className='form-control' disabled={this.props.isReadOnly} value={item[OBJECTPREFIX + 'operator__c']} name={OBJECTPREFIX + 'operator__c'} onChange={this.handleComplianceChange.bind(null, index, '1', true) }>
              {this.renderComplianceOperators(item[OBJECTPREFIX + 'license_field__c']) }
            </select>
          </div>
        );

        var fieldClassname = !this.validate(item[OBJECTPREFIX + 'field__c']) ? 'form-group has-error' : ' form-group';
        fieldInput = (
          <div className={fieldClassname} >
            <select className='form-control' disabled={this.props.isReadOnly} value={item[OBJECTPREFIX + 'field__c']} name={OBJECTPREFIX + 'field__c'} onChange={this.handleComplianceChange.bind(null, index, '2', true) }>
              {this.renderAdvancedFieldsInCompliance(item[OBJECTPREFIX + 'license_field__c']) }
            </select>
          </div>
        );

        return (
          <tr key={index + 1}>
            <td>{index + 1}</td>
            <td>
              {licenseInput}
            </td>
            <td>
              {operatorInput}
            </td>
            <td>
              {fieldInput}
            </td>
            <td><button className='add-btn' disabled={this.props.isReadOnly} onClick={this.deleteComplianceRule.bind(null, index) } >-</button></td>
          </tr>
        );
      });
    }
  }

  renderAdvancedRulesList() {
    if (this.props.advancedRulesList && this.props.advancedRulesList.length) {
      let valueInput;
      let fieldInput;
      let operatorInput;
      return this.props.advancedRulesList.map((item, index) => {
        var fieldClassname = !this.validate(item[OBJECTPREFIX + 'field__c']) ? 'form-group has-error' : ' form-group';
        fieldInput = (
          <div className={fieldClassname} >
            <select className='form-control' disabled={this.props.isReadOnly} value={item[OBJECTPREFIX + 'field__c']} name={OBJECTPREFIX + 'field__c'} onChange={this.handleAdvancedChange.bind(null, index, '0', this.props.sobject.fields[item[OBJECTPREFIX + 'field__c']], OBJECTPREFIX + 'field__c') }>
              {this.renderAdvancedFields() }
            </select>
          </div>
        );
        var fieldType = this.props.sobject.fields[item[OBJECTPREFIX + 'field__c']];
        var operatorClassname = !this.validate(item[OBJECTPREFIX + 'operator__c']) ? 'form-group has-error' : ' form-group';
        operatorInput = (
          <div className={operatorClassname} >
            <select className='form-control' disabled={this.props.isReadOnly} value={item[OBJECTPREFIX + 'operator__c']} name={OBJECTPREFIX + 'operator__c'} onChange={this.handleAdvancedChange.bind(null, index, '1', item[OBJECTPREFIX + 'field__c'], OBJECTPREFIX + 'operator__c') }>
              {this.renderAdvancedOperators(item[OBJECTPREFIX + 'field__c']) }
            </select>
          </div>
        );
        var valueClassname = (!this.validate(item[OBJECTPREFIX + 'value__c']) && item[OBJECTPREFIX + 'operator__c'] !== 'not blank') ? 'form-group has-error' : ' form-group';
        if (item[OBJECTPREFIX + 'operator__c'] === 'not blank') {
          valueInput = (
            <div className={valueClassname} >
              <input className='form-control' type='text' disabled={true} value='' name={OBJECTPREFIX + 'value__c'}/>
            </div>
          );
        }
        else if (fieldType === 'DATE_FIELD' || fieldType === 'DATETIME_FIELD') {
          valueInput = (
            <div className='form-group'>
              <DatePicker className='form-control' disabled={this.props.isReadOnly} selected={moment(item[OBJECTPREFIX + 'value__c']) } onChange={this.handleAdvancedChange.bind(null, index, '2', item[OBJECTPREFIX + 'field__c'], OBJECTPREFIX + 'value__c') } />
            </div>
          );
        }
        else if (fieldType === 'BOOLEAN_FIELD') {
          valueInput = (
            <div className='form-group'>
              <select ref={OBJECTPREFIX + 'value__c'} className='form-control' disabled={this.props.isReadOnly} value={item[OBJECTPREFIX + 'value__c'] || 'true'} name={OBJECTPREFIX + 'value__c'} onChange={this.handleAdvancedChange.bind(null, index, '2', item[OBJECTPREFIX + 'field__c'], OBJECTPREFIX + 'value__c') }>
                <option value='true' >True</option>
                <option value='false'>False</option>
              </select>
            </div>
          );
        }
        else {
          valueInput = (
            <div className={valueClassname} >
              <input className='form-control' type='text' disabled={this.props.isReadOnly} value={_.unescape(item[OBJECTPREFIX + 'value__c']) || ''} name={OBJECTPREFIX + 'value__c'} onChange={this.handleAdvancedChange.bind(null, index, '2', item[OBJECTPREFIX + 'field__c'], OBJECTPREFIX + 'value__c') }/>
            </div>
          );
        }

        return (
          <tr key={index}>
            <td>{index + 1}</td>
            <td>
              {fieldInput}
            </td>
            <td>
              {operatorInput}
            </td>
            <td>
              {valueInput}
            </td>
            <td><button className='add-btn' disabled={this.props.isReadOnly} onClick={this.deleteAdvancedRule.bind(null, index) }>-</button></td>
          </tr>
        );
      });
    } else {
      return (
        <tr>
          <td colspan='5'>
            No rules added
          </td>
        </tr>
      )
    }
  }

  renderComplianceRules() {
    let objectName = this.props.params.sobjectname;
    let isValidSyntax = Utils.checkSyntax(this.props.complianceRuleLogic[OBJECTPREFIX + 'logic__c'], this.props.complianceRulesList.length);
    let logic;
    let length = this.props.complianceRulesList.length;
    if ((isValidSyntax && length) || (isValidSyntax && !length)) {
      logic = (
        <div className='form-group col-md-6'>
          <input type='text' className='form-control' disabled={this.props.isReadOnly} value={this.props.complianceRuleLogic[OBJECTPREFIX + 'logic__c'] || ''} onChange={this.changeComplianceRuleLogic.bind(null, false, this.props.complianceRulesList.length) }></input>
        </div>
      );
    }
    else {
      logic = (
        <div className='form-group col-md-6 has-error'>
          <input type='text' className='form-control form-control-danger' disabled={this.props.isReadOnly} value={this.props.complianceRuleLogic[OBJECTPREFIX + 'logic__c'] || ''} onChange={this.changeComplianceRuleLogic.bind(null, true, this.props.complianceRulesList.length) }></input>
          <small className='text-help'>Invalid logic syntax</small>
        </div>
      );
    }
    let addComplianceCriteriaButton;
    if(!this.props.isReadOnly) {
      addComplianceCriteriaButton = <p className="add-criteria"  onClick={this.addComplianceRule.bind(null) } ><button className='add-btn'>+</button>&nbsp; &nbsp; Add Criteria </p>
    }
    return (
      <span className='data-table'>
        <div className='heading-table'>
          <span className='linkcolor div-font'>Compliance Pass Criteria</span>
        </div>
        <table className='table table-hover table-fixed custom-table'>
          <thead>
            <tr>
              <th>Rule Number</th>
              <th>License Field</th>
              <th>Operator</th>
              <th>{_.capitalize(objectName) } Object Field</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {this.renderStateRule() }
            {this.renderComplianceRulesList() }
          </tbody>
        </table>
        {addComplianceCriteriaButton}
        <div className="row">
          <label className="control-label col-md-3 col-md-offset-3">Compliance Pass Logic</label>
          {logic}
        </div>
        <hr className='divider-grid'/>
      </span>
    );
  }

  renderAdvancedRules() {
    if (this.props.showAdvancedRule === 'Specific') {
      let objectName = this.props.params.sobjectname;
      let isValidSyntax = Utils.checkSyntax(this.props.advancedRuleLogic[OBJECTPREFIX + 'logic__c'], this.props.advancedRulesList.length);
      let logic;
      let length = this.props.advancedRulesList.length;
      if ((isValidSyntax && length) || (isValidSyntax && !length)) {
        logic = (
          <div className='form-group col-md-6'>
            <input type='text' className='form-control' disabled={this.props.isReadOnly} value={this.props.advancedRuleLogic[OBJECTPREFIX + 'logic__c'] || ''} onChange={this.changeAdvancedRuleLogic.bind(null, false, this.props.advancedRulesList.length) }></input>
          </div>
        );
      }
      else {
        logic = (
          <div className='form-group col-md-6 has-error'>
            <input type='text' className='form-control form-control-danger' disabled={this.props.isReadOnly} value={this.props.advancedRuleLogic[OBJECTPREFIX + 'logic__c'] || ''} onChange={this.changeAdvancedRuleLogic.bind(null, true, this.props.advancedRulesList.length) }></input>
            <small className='text-help'>Invalid logic syntax</small>
          </div>
        );
      }
      let addAdvancedCriteriaButton;
      if(!this.props.isReadOnly) {
        addAdvancedCriteriaButton = <p className="add-criteria"  onClick={this.addAdvancedRule.bind(null) } ><button className='add-btn'>+</button>&nbsp; &nbsp; Add Criteria </p>
      }
      return (
        <span className='data-table'>
          <div className='heading-table'>
            <span className='linkcolor div-font'>Advanced Rule Filtering</span>
          </div>
          <table className='table table-hover table-fixed custom-table'>
            <thead>
              <tr>
                <th>Rule Number</th>
                <th>{_.capitalize(objectName) } Field</th>
                <th>Operator</th>
                <th>Value</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {this.renderAdvancedRulesList() }
            </tbody>
          </table>
          {addAdvancedCriteriaButton}
          <div className="row">
            <label className="control-label col-md-3 col-md-offset-3">Advanced Rule Logic</label>
            {logic}
          </div>
          <hr className='divider-grid'/>
        </span>
      );
    }
  }

  render() {
    let objectLabel = this.props.sobject.label;
    var toggle;
    if (this.props.loaded) {
      toggle = (
        <Toggle
          disabled={this.props.isReadOnly}
          defaultChecked={this.props.residentRuleOn}
          onChange={this.toggleChangeResidentRule.bind(null, !this.props.residentRuleOn) } />
      );
    }




    return (
      <div className='rules-page license-form'>
        {this.renderToast() }
        <div>
          <Sidebar activePage='objectRules' checklistComplete={this.props.checklistComplete}/>
          <div className='col-sm-9 inside-container'>
            <h4 className="sub-heading">{_.capitalize(objectLabel) } Compliance Rule Set <small>
              <span id="helpToolTipRule" className='fa fa-question-circle  question-icon'></span>
              <Tooltip   placement="bottom" isOpen={this.state.tooltipOpen} target="helpToolTipRule" toggle={this.toggle}>
                {_.capitalize(objectLabel) } Compliance Rule Set
              </Tooltip>
            </small></h4>
            <div className='heading-padding'>
              <span className='div-font linkcolor'>Rule Set Filter</span>
            </div>
            <div className='row row-header row-margin'>
              <div className="col-md-6">
                <span className='div-font'>Resident License Check</span>
                <p className="padding linkcolor"><span>We ensure agent has active resident license</span></p>
              </div>
              <div className="col-md-6 pull-right-custom">{toggle}</div>
            </div>
            <div className='row row-header row-margin'>
              <div className="col-md-6"><span className='div-font'>Filtered Records</span> </div>
              <div className="col-md-6 pull-right-custom">
                <select className='form-control select-filtered-records' disabled={this.props.isReadOnly} value={this.props.showAdvancedRule} onChange={this.toggleShowAdvancedRule.bind(this) }>
                  <option value='All'>All Records</option>
                  <option value='Specific'>Specific Records</option>
                </select>
              </div>
            </div>
            <hr className='divider'/>
            {this.renderAdvancedRules() }
            {this.renderComplianceRules() }
            <div className='submit-box'>
              {this.renderSubmit() }
              <Link to='/rules' className='btn btn-white' role='button'>Cancel</Link>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state) => {
  return {
    advancedRulesList: state.advancedRulesList,
    advancedRuleLogic: state.advancedRuleLogic,
    checklistComplete: state.checklistComplete,
    complianceRulesList: state.complianceRulesList,
    complianceRuleLogic: state.complianceRuleLogic,
    deletedLicenseRules: state.deletedLicenseRules,
    deletedRegularFilterRules: state.deletedRegularFilterRules,
    errors: state.errors,
    isReadOnly: state.isReadOnly,
    isFilterRuleLogicRemoved: state.isFilterRuleLogicRemoved,
    isLicenseRuleLogicRemoved: state.isLicenseRuleLogicRemoved,
    licenseSobject: state.licenseSobject,
    residentRule: state.residentRule,
    residentRuleOn: state.residentRuleOn,
    showAdvancedRule: state.showAdvancedRule,
    sobject: state.sobject,
    loaded: state.loaded,
    stateRule: state.stateRule,
    showToast: state.showToast,
    isMaintainanceMode:state.isMaintainanceMode
  };
}

const mapDispatchToProps = (dispatch) => {
  return {
    getLicenseRuleSetResult: (objectName) => {
      dispatch(getLicenseRuleSetResult(objectName));
    },
    getSobjectWithFields: (objectName) => {
      dispatch(getSobjectWithFields(objectName));
    },
    getLicenseFields: (objectName) => {
      dispatch(getLicenseFields(objectName));
    },
    deleteComplianceRule: (index) => {
      dispatch(deleteComplianceRule(index));
    },
    deleteAdvancedRule: (index) => {
      dispatch(deleteAdvancedRule(index));
    },
    addAdvancedRule: (objectName) => {
      dispatch(addAdvancedRule(objectName));
    },
    addComplianceRule: (objectName) => {
      dispatch(addComplianceRule(objectName));
    },
    saveLicenseRuleSetResult: (data, advancedFilter) => {
      dispatch(saveLicenseRuleSetResult(data, advancedFilter));
    },
    selectAdvancedChange: (itemValue, itemName, index, colIndex, error) => {
      dispatch(selectAdvancedChange(itemValue, itemName, index, colIndex, error));
    },
    selectComplianceChange: (itemValue, itemName, index, colIndex, error) => {
      dispatch(selectComplianceChange(itemValue, itemName, index, colIndex, error));
    },
    selectStateRuleChange: (itemValue) => {
      dispatch(selectStateRuleChange(itemValue));
    },
    toggleShowAdvancedRule: (showAdvanced) => {
      dispatch(showAdvancedRule(showAdvanced));
    },
    changeAdvancedRuleLogic: (value, error) => {
      dispatch(changeAdvancedRuleLogic(value, error));
    },
    changeComplianceRuleLogic: (value, error) => {
      dispatch(changeComplianceRuleLogic(value, error));
    },
    clearState: () => {
      dispatch(clearState());
    },
    toggleChangeResidentRule: (value, objectName) => {
      dispatch(toggleChangeResidentRule(value, objectName));
    },
    hideToast: () => {
      dispatch(hideToast());
    }
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(ObjectRuleSet);