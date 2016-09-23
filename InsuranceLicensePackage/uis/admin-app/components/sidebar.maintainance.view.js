import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { toggleChecklist } from '../actions/checklist-actions';
import Utils from '../utils/utils';
import { Tooltip } from 'reactstrap';

export class MaintainaceSidebar extends Component {
    constructor(props) {
        super(props);
        this.toggle = this.toggle.bind(this);
        this.state = {
            tooltipOpen: false
        };
    }
    toggle() {
        this.setState({
            tooltipOpen: !this.state.tooltipOpen
        });
    }

    render() {
        return (
            <div className='col-sm-3 zenefits-nav div-padding'>
                <h4>
                    <Link to={'/checklistcomplete'} className={this.props.disableLink ? 'disabled-true' : ''}>
                        <i className="fa fa-list-ul" aria-hidden="true"></i> Checklist
                    </Link>
                </h4>

                <ul className='nav sidebar-menu'>
                    <li><Link className={this.props.activePage === 'rules' ? 'sidebar-color sidebar-text' : 'sidebar-text'} to={`/rules`}>Compliance Rules</Link></li>
                    <li><Link  className={this.props.activePage === 'lines' ? 'sidebar-color sidebar-text' : 'sidebar-text'} to={`/lines`}>Configure Lines of Authority</Link></li>
                    <li><Link  className={this.props.activePage === 'nipr' ? 'sidebar-color sidebar-text' : 'sidebar-text'} to={`/nipr`}>Integrate NIPR</Link></li>
                    <li><Link  className={this.props.activePage === 'approval' ? 'sidebar-color sidebar-text' : 'sidebar-text'} to={`/approval`}>License Approval Criteria</Link></li>
                    <li><Link  className={this.props.activePage === 'db' ? 'sidebar-color sidebar-text' : 'sidebar-text'} to={`/db`}>New License Upload</Link></li>
                </ul>
                <div className='salesforce-link-checklist'>
                    <p className='btn-return-padding'>
                        <small>Need more help?<a href='https://www.zenefits.com/licensingplus/help/' target='_blank' className='link'>Go to Help Center</a></small>
                    </p>
                    <p className='btn-return-padding'>
                        <a href='/'><button className="btn btn-return" >Return to Salesforce</button></a>
                    </p>
                </div>
            </div>
        )
    }
}

MaintainaceSidebar.propTypes = {
    activePage: React.PropTypes.string.isRequired
};

export default MaintainaceSidebar;