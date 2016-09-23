import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import _ from 'lodash';
import moment from 'moment';
import Toggle from 'react-toggle';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import {OBJECTPREFIX } from '../constants/constants';
import * as constants from '../constants/constants';
import Utils from '../utils/utils';
import Autocomplete from 'react-autocomplete';
import { APPROVAL_VIDEO_LINK } from '../constants/constants';
import Sidebar from './sidebar.container';
import { Tooltip } from 'reactstrap';

export class ApprovalView extends Component {
    constructor(props) {
        super(props);
        this.state = {
            tooltipOpen1: false,
            tooltipOpen2: false,
            tooltipOpen3: false,
            tooltipOpen4: false
        }
        this.toggle = this.toggle.bind(this);
    }

    toggle(id) {
        this.setState({
            ["tooltipOpen"+id]: !this.state["tooltipOpen"+id]
        });
    }
    renderApprovalCriteria() {
        let force_expire__c = this.props.niprSyncConfig[OBJECTPREFIX + "forceexpire__c"];
        var toggle;
        var filter_toggle;
        if (this.props.loaded) {           
            toggle = (<Toggle               
                checked={force_expire__c}
                onChange={this.props.toggleChangeForceExpire.bind(null, !force_expire__c) }/>
            )
            filter_toggle = (
                <Toggle                
                    checked={this.props.automatic_license_approval}
                    onChange={this.props.toggleChangeActivateLicense.bind(null, !this.props.automatic_license_approval) } />
            )
        }

        var processName;
        if (this.props.niprSyncConfig[OBJECTPREFIX + "approvalprocess__c"] === '' || !this.props.niprSyncConfig[OBJECTPREFIX + "approvalprocess__c"]) {
            processName = (<div className="col-sm-4 col-md-4 has-error">
                <select onChange={this.props.onChangeApprovalProcess} className='form-control form-control-danger'  value={this.props.niprSyncConfig[OBJECTPREFIX + "approvalprocess__c"]}>
                    <option value="">Approval Process Name</option>
                    {this.props.approvalProcessFields() }
                </select>
                <small className='text-help'>Please select a process</small>
            </div>)
        } else {
            processName = (<div className="col-sm-4 col-md-4">
                <select onChange={this.props.onChangeApprovalProcess} className='form-control'  value={this.props.niprSyncConfig[OBJECTPREFIX + "approvalprocess__c"]}>
                    <option value="">Approval Process Name</option>
                    {this.props.approvalProcessFields() }
                </select>
            </div>)
        }
        return (
            <div>
               <h4 className="sub-heading">License Approval Criteria
                    &nbsp;<small>
                        <span id='helpToolTip0' className='fa fa-question-circle question-icon-size'></span>
                        <Tooltip  key='helpToolTip0' placement="top left" isOpen={this.state.tooltipOpen1} target='helpToolTip0' toggle={this.toggle.bind(this,"1")}>
                            Determine the approval criteria for licenses submitted via NIPR integration.
                        </Tooltip>
                    </small>

                </h4>

                <p><a href={APPROVAL_VIDEO_LINK} target='_blank'>Watch the Approval Criteria configuration video</a></p>
                <br></br>
                <div className="row">
                    <div className="form-group">
                        <label className="control-label col-sm-6  col-md-6">Choose Approval Process <small>
                            <span id='helpToolTip1' className='fa fa-question-circle question-icon-size'></span></small></label>
                        <Tooltip key='helpToolTip1' placement="top left" isOpen={this.state.tooltipOpen2} target='helpToolTip1' toggle={this.toggle.bind(this,"2")}>
                            Select a Salesforce approval process for license updates that are not auto approved.
                        </Tooltip>
                        {processName}
                    </div>
                </div>
                <div className="row">
                    <div className="form-group">
                        <label className="control-label col-sm-6 col-md-6">Validation Rule Exception <small>
                            <span id='helpToolTip2' className='fa fa-question-circle question-icon-size'></span></small></label>
                        <Tooltip key='helpToolTip2' placement="top left" isOpen={this.state.tooltipOpen3} target='helpToolTip2' toggle={this.toggle.bind(this,"3")}>
                            This user will be the NIPR integration user. This user makes all NIPR license data changes.
                        </Tooltip>
                        <div className="col-sm-4 col-md-4 validation-rule-field">
                            <Autocomplete
                                inputProps={{ id: "autocomplete", className: " form-control", placeholder: "User Search" }}
                                ref="autocomplete"
                                value={this.props.validationUser.Username}
                                items={this.props.validationUserList}
                                getItemValue={(item) => item.Username}
                                onSelect={(value, item) => {
                                    this.props.setValidationUser(item)
                                } }
                                onChange={(event, value) => {
                                    this.props.setValidationUser({ Username: value })
                                    this.props.onValidationUserChange(value)
                                } }
                                renderItem={(item, isHighlighted) => (
                                    <div
                                        className={ isHighlighted ? "autocomplete-highlightedItem" : "autocomplete-item"}
                                        key={item.id}
                                        id={item.id}
                                        >{item.Username}</div>
                                ) }
                                />
                        </div>
                    </div>
                </div>
                <div className="row">
                    <div className="form-group">
                        <label className="control-label col-sm-6 col-md-6">Force Expire  <small>
                            <span key='3' id='helpToolTip3' className='fa fa-question-circle question-icon-size'></span></small></label>
                        <Tooltip key='helpToolTip3' placement="top left" isOpen={this.state.tooltipOpen4} target='helpToolTip3' toggle={this.toggle.bind(this,"4")}>
                            If NIPR reports a license as inactive the system will automatically force expire the license so it is no longer active.
                        </Tooltip>
                        <div className="col-sm-6 col-md-6 pull-right">
                            {toggle}
                        </div>
                    </div>
                </div>
                <hr/>
                <h5 className="control-label">License Approval Rule Set</h5>
                <div className="row">
                    <div className="form-group">
                        <label className="control-label col-sm-6 col-md-6">Activate Automatic License Approval</label>
                        <div className="col-sm-6 col-md-6 pull-right">
                            {filter_toggle}
                        </div>
                    </div>
                </div>
            </div>
        );
    }
    renderAdvancedRulesList() {
        if (this.props.licenseApprovalFileds.fields && this.props.licencesRuleObject.licenseRules && this.props.licencesRuleObject.licenseRules.length) {
            let valueInput;
            let fieldInput;
            let operatorInput;
            return this.props.licencesRuleObject.licenseRules.map((item, index) => {
                var fieldClassname = !this.props.validate(item[OBJECTPREFIX + 'license_field__c']) ? 'form-group has-error' : ' form-group';
                fieldInput = (
                    <div className={fieldClassname} >
                        <select onChange={this.props.handleLicenseChange.bind(null, index, '0', this.props.licenseApprovalFileds.fields[item[OBJECTPREFIX + 'license_field__c']], OBJECTPREFIX + 'license_field__c') } className='form-control' value={item[OBJECTPREFIX + 'license_field__c']} name={OBJECTPREFIX + 'license_field__c'} >
                            {this.props.renderLicenseFields() }
                        </select>
                    </div>
                );
                var fieldType = this.props.licenseApprovalFileds.fields[item[OBJECTPREFIX + 'license_field__c']];
                var operatorClassname = !this.props.validate(item[OBJECTPREFIX + 'operator__c']) ? 'form-group has-error' : ' form-group';
                operatorInput = (
                    <div className={operatorClassname} >
                        <select onChange={this.props.handleLicenseChange.bind(null, index, '1', item[OBJECTPREFIX + 'license_field__c'], OBJECTPREFIX + 'operator__c') } className='form-control' value={item[OBJECTPREFIX + 'operator__c']} name={OBJECTPREFIX + 'operator__c'} >
                            {this.props.renderLicenseOperators(item[OBJECTPREFIX + 'license_field__c']) }
                        </select>
                    </div>
                );
                var valueClassname = (!this.props.validate(item[OBJECTPREFIX + 'value__c']) && item[OBJECTPREFIX + 'operator__c'] !== 'not blank') ? 'form-group has-error' : ' form-group';
                if (item[OBJECTPREFIX + 'operator__c'] === 'not blank') {
                    valueInput = (
                        <div className={valueClassname} >
                            <input  className='form-control' type='text' disabled={true} value='' name={OBJECTPREFIX + 'value__c'}/>
                        </div>
                    );
                }
                else if (fieldType === 'DATE_FIELD' || fieldType === 'DATETIME_FIELD') {
                    valueInput = (
                        <div className='form-group'>
                            <DatePicker  onChange={this.props.handleLicenseChange.bind(null, index, '2', item[OBJECTPREFIX + 'license_field__c'], OBJECTPREFIX + 'value__c') }  className='form-control' disabled={this.props.licencesRuleObject.automatic_license_approval} selected={moment(item[OBJECTPREFIX + 'value__c']) } />
                        </div>
                    );
                }
                else if (fieldType === 'BOOLEAN_FIELD') {
                    valueInput = (
                        <div className='form-group'>
                            <select onChange={this.props.handleLicenseChange.bind(null, index, '2', item[OBJECTPREFIX + 'license_field__c'], OBJECTPREFIX + 'value__c') } ref={OBJECTPREFIX + 'value__c'} className='form-control' value={item[OBJECTPREFIX + 'value__c'] || 'true'} name={OBJECTPREFIX + 'value__c'} >
                                <option value='true' >True</option>
                                <option value='false'>False</option>
                            </select>
                        </div>
                    );
                }
                else {
                    valueInput = (
                        <div className={valueClassname} >
                            <input className='form-control' type='text' value={_.unescape(item[OBJECTPREFIX + 'value__c']) || ''} name={OBJECTPREFIX + 'value__c'} onChange={this.props.handleLicenseChange.bind(null, index, '2', item[OBJECTPREFIX + 'license_field__c'], OBJECTPREFIX + 'value__c') }/>
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
                        <td><button className='add-btn' onClick={this.props.deleteLicenseRule.bind(null, index) } >-</button></td>
                    </tr>
                );
            });
        } else {
            return (
                <tr>
                    <td colSpan='5'>
                        No rules added
                    </td>
                </tr>
            )
        }
    }
    renderAdvanceRuleFiltering() {
        if (this.props.automatic_license_approval) {
            let logic;
            if (this.props.licencesRuleObject.licenseRules && this.props.licenseRuleLogic) {
                let isValidSyntax = Utils.checkSyntax(this.props.licenseRuleLogic[OBJECTPREFIX + 'logic__c'], this.props.licencesRuleObject.licenseRules.length);

                let length = this.props.licencesRuleObject.licenseRules.length;
                if ((isValidSyntax && length) || (isValidSyntax && !length)) {
                    logic = (
                        <div className='form-group col-md-6'>
                            <input type='text' className='form-control' value={this.props.licenseRuleLogic[OBJECTPREFIX + 'logic__c'] || ''} onChange={this.props.changeLicenseRuleLogic.bind(null, false, length) }></input>
                        </div>
                    );
                }
                else {
                    logic = (
                        <div className='form-group col-md-6 has-error'>
                            <input type='text' className='form-control form-control-danger' value={this.props.licenseRuleLogic[OBJECTPREFIX + 'logic__c'] || ''} onChange={this.props.changeLicenseRuleLogic.bind(null, true, length) }></input>
                            <small className='text-help'>Invalid logic syntax</small>
                        </div>
                    );
                }
            }
            return (
                <span className='data-table'>
                    <div className='heading-table'>
                        <h5>Advanced Rule Filtering</h5>
                    </div>
                    <table className='table table-hover table-fixed custom-table'>
                        <thead>
                            <tr>
                                <th>Rule Number</th>
                                <th>Insurance License</th>
                                <th>Operator</th>
                                <th>Value</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            {this.renderAdvancedRulesList() }
                        </tbody>
                    </table>
                    <p className="add-criteria"  onClick={this.props.addLicenseRule} ><button className='add-btn'>+</button>&nbsp; &nbsp; Add Criteria </p>
                    <div className="row">
                        <label className="control-label col-md-3 col-md-offset-3">Advanced Rule Logic</label>
                        {logic}
                    </div>
                    <hr className='divider-grid'/>
                </span>
            )
        }
    }

    renderSubmit() {
        let validationUser;
        if(this.props.validationUserList.length>0){
            validationUser= _.find(this.props.validationUserList, {Username:this.props.validationUser.Username})
            if(validationUser){
                this.props.setValidationUserError(false)
            }
            else{
                this.props.setValidationUserError(true)
            }
        }
        if (this.props.errors || this.props.validationUserError || this.props.niprSyncConfig[OBJECTPREFIX + "approvalprocess__c"] == "" || !this.props.niprSyncConfig[OBJECTPREFIX + "approvalprocess__c"]
            || (this.props.automatic_license_approval && this.props.licencesRuleObject.licenseRules.length === 0)
        ) {
            return (               
                <input className='btn btn-orange' type='button' disabled={true} value={this.props.isMaintainanceMode ? 'Save' : 'Save & Next'} />                
            );
        } else {
            return (                
                <input className='btn btn-orange' type='button'  onClick={this.props.saveLicenseApprovalRuleSetResult.bind(null, this.props.licencesRuleObject, this.props.validationUser) }  value={this.props.isMaintainanceMode ? 'Save' : 'Save & Next'} />
            );
        }
    }

    render() {
        return (
            <div className='license-form'>
                <Sidebar activePage='approval'/>
                <div className="col-sm-9 inside-container">
                    {this.renderApprovalCriteria() }
                    {this.renderAdvanceRuleFiltering() }
                    <div className='submit-box'>
                        {this.renderSubmit() }                      
                        <input className='btn btn-white' type='button'  onClick={this.props.cancelLicenseApprovalRuleSetResult.bind(null) }  value='Cancel'/>
                    </div>
                </div>
            </div>
        )
    }
}

export default ApprovalView