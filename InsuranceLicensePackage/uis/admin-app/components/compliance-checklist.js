import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { toggleChecklist } from '../actions/checklist-actions';
import { VIDEO_LINK, OBJECTPREFIX, SKIPCOMPLIANCE} from '../constants/constants';
import _ from 'lodash';
import Sidebar from './sidebar.container';

export class ComplianceCheck extends Component {
    constructor(props) {
        super(props)
        this.state = {
            checklist: {}
        }
        this.toggleChecklist = this.toggleChecklist.bind(this);
        this.skipCompliance = this.skipCompliance.bind(this);
    }

    toggleChecklist(key) {
        var checklist = Object.assign({}, this.props.checklist);
        var value = checklist[key] ? !checklist[key] : true;
        checklist[key] = value;
        this.props.toggleChecklist(checklist);
    }

    skipCompliance() {
        var checklist = Object.assign({}, this.props.checklist);
        _.mapKeys(SKIPCOMPLIANCE, function (value, key) {
            checklist[key] = true;
        });
        this.props.toggleChecklist(checklist);
    }

    renderComplianceButton() {
        var isComplianceChecklistComplete = this.props.checklist[OBJECTPREFIX + 'watch_video__c'] && this.props.checklist[OBJECTPREFIX + 'custom_object__c']
        const label = 'Activate Compliance Rules';
        if (isComplianceChecklistComplete) {
            return <Link to='/rules' className='btn btn-warning btn-checklist' role='button'>{label}</Link>;
        }
        else {
            return (
                <div>
                    <Link to='/rules' className='btn btn-secondary secondary-disabled btn-checklist' role='button' onClick={e => e.preventDefault() }>{label}</Link>
                    <br/><br/>
                    <Link to='/niprchecklist' className="skip" onClick={this.skipCompliance.bind(this) }>Skip ></Link>
                </div>
            )
        }
    }

    renderChecklist() {
        var checklistEmpty = !(OBJECTPREFIX + 'download_spreadsheet__c' in this.props.checklist)
        if (checklistEmpty) {
            return (
                <div className='col-sm-9 getting-started inside-container'>
                    <div className='checklist'>
                        <h2>Activate compliance rules</h2>
                        <hr/>
                    </div>
                </div>
            )
        } else {
            return (
                <div className='col-sm-9 getting-started inside-container'>
                    <div className='checklist'>
                        <h2>Activate compliance rules</h2>
                        <br/>
                        <div className='checkbox checkbox-container'>
                            <label>
                                <input type='checkbox' id='5' checked={this.props.checklist[OBJECTPREFIX + 'watch_video__c']} onChange={this.toggleChecklist.bind(this, OBJECTPREFIX + 'watch_video__c') }></input>
                                <label htmlFor='5' className='label-check'> Watch our video on <a href={VIDEO_LINK} target='_blank'>compliance rules best practices</a></label>
                            </label>
                        </div>
                        <div className='checkbox checkbox-container'>
                            <label>
                                <input type='checkbox' id='6' checked={this.props.checklist[OBJECTPREFIX + 'custom_object__c']} onChange={this.toggleChecklist.bind(this, OBJECTPREFIX + 'custom_object__c') }></input>
                                <label htmlFor='6' className='label-check'>Enable Compliance Rules on <Link to='/extend' target='_blank'>custom objects</Link></label>
                            </label>
                        </div>
                        <br/>
                        <div>
                            {this.renderComplianceButton() }
                        </div>
                        <br/>
                    </div>

                </div>
            )
        }
    }

    render() {
        return (
            <div className='license-form'>
                <div>
                    <Sidebar activePage='compliancechecklist'/>
                    {this.renderChecklist() }
                </div>
            </div>
        )
    }

}

const mapStateToProps = (state) => {
    return {
        checklist: state.checklist
    }
}

const mapDispatchToProps = (dispatch) => {
    return {
        toggleChecklist: (checklist) => {
            dispatch(toggleChecklist(checklist));
        }
    }
}

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(ComplianceCheck)