import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { toggleChecklist } from '../actions/checklist-actions';
import { VIDEO_LINK } from '../constants/constants';
import Utils from '../utils/utils';
import LicenseDBSidebar from './sidebar.license-db.view';
import MaintainaceSidebar from './sidebar.maintainance.view';
import NIPRSidebar from './sidebar.nipr.view';
import ChecklistSidebar from './sidebar.checklist.view';
import ApprovalRuleSidebar from './sidebar.approval-rule.view';
import RulesSidebar from './sidebar.rule-set.view';
import ObjectRuleSidebar from './sidebar.object-rule-set.view';
import ComplianceChecklistSidebar from './sidebar.compliance-checklist.view';
import LinesSidebar from './sidebar.lines-authority.view';
import CompleteSidebar from './sidebar.complete.view';
import LinesChecklistSidebar from './sidebar.lines-checklist.view';
import NiprChecklistSidebar from './sidebar.nipr-checklist.view';


export class Sidebar extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        if (this.props.isMaintainanceMode) {
            return (
                <MaintainaceSidebar activePage={this.props.activePage} />
            )
        } else if (this.props.activePage === 'db') {
            return (
                <LicenseDBSidebar />
            )
        } else if (this.props.activePage === 'nipr') {
            return (
                <NIPRSidebar />
            )
        } else if (this.props.activePage === 'checklist') {
            return (
                <ChecklistSidebar />
            )
        } else if (this.props.activePage === 'approval') {
            return (
                <ApprovalRuleSidebar />
            )
        } else if (this.props.activePage === 'rules') {
            return (
                <RulesSidebar checklistComplete={this.props.checklistComplete}/>
            )
        } else if (this.props.activePage === 'objectRules') {
            return (
                <ObjectRuleSidebar checklistComplete={this.props.checklistComplete}/>
            )
        } else if (this.props.activePage === 'compliancechecklist') {
            return (
                <ComplianceChecklistSidebar />
            )
        } else if (this.props.activePage === 'lines') {
            return (
                <LinesSidebar checklistComplete={this.props.checklistComplete}/>
            )
        } else if (this.props.activePage === 'complete') {
            return (
                <CompleteSidebar />
            )
        } else if (this.props.activePage === 'lineschecklist') {
            return (
                <LinesChecklistSidebar />
            )
        }else if (this.props.activePage === 'niprchecklist') {
            return (
                <NiprChecklistSidebar />
            )
        }
    }
}

Sidebar.propTypes = {
    activePage: React.PropTypes.string.isRequired
};

const mapStateToProps = (state) => {
    return {
        isMaintainanceMode: state.isMaintainanceMode
    };
}

const mapDispatchToProps = (dispatch) => {
    return {
    }
}

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(Sidebar);
