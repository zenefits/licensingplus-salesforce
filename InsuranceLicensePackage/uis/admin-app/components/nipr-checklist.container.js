import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import {updateMaintenanceMode} from '../actions/upload-actions';
import { toggleChecklist } from '../actions/checklist-actions';
import { OBJECTPREFIX,SKIPNIPR} from '../constants/constants';
import _ from 'lodash';
import NIPRCheckView from './nipr-checklist.view';

export class NIPRCheckContainer extends Component {
    constructor(props) {
        super(props)
        this.toggleChecklist = this.toggleChecklist.bind(this);
        this.onSkipClick = this.onSkipClick.bind(this);
    }

    toggleChecklist(key) {
        var checklist = Object.assign({}, this.props.checklist);
        var value = checklist[key] ? !checklist[key] : true;
        checklist[key] = value;
        this.props.toggleChecklist(checklist);
    }

    onSkipClick() {
        var checklist = Object.assign({}, this.props.checklist);
        _.mapKeys(SKIPNIPR, function (value, key) {
            checklist[key] = true;
        });
        checklist[OBJECTPREFIX + "completed_setup__c"] = true;
        this.props.toggleChecklist(checklist);
        this.props.updateMaintenanceMode();
    }


    render() {
        return (
            <div className='license-form'>
                    <NIPRCheckView
                        toggleChecklist={this.toggleChecklist}
                        onSkipClick={this.onSkipClick}
                        checklist={this.props.checklist}
                        />
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
        },
         updateMaintenanceMode: () => {
            dispatch(updateMaintenanceMode());
        }
    }
}

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(NIPRCheckContainer)