import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { toggleChecklist } from '../actions/checklist-actions';
import { VIDEO_LINK } from '../constants/constants';
import Utils from '../utils/utils';
import { Tooltip } from 'reactstrap';

export class LicenseDBSidebar extends Component {
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
                    <Link to={`/approval`}>
                        &lt; Back
                    </Link>
                </h4>
                <div className= 'sidebar-div'>
                    <span className='fa fa-check  ok-icon-color icon-font'></span>
                    <span className='link-font' to={'/lineschecklist'}>Configure lines of authority </span>
                </div>
                <div className= 'sidebar-div'>
                    <span className='fa fa-check  ok-icon-color icon-font'></span>
                    <span className='link-font'>Active compilance rules</span>
                </div>
                <div className= 'integrate-text link-font'>
                    Integrate NIPR
                </div>
                <div className="integrate-padding">
                    <h5 className="font-color">NIPR Intrgration Setup</h5>
                    <h5 className="font-color">License Approval Criteria</h5>
                    <h5>License Database Maintenance</h5>
                </div>
                <div className='salesforce-link-checklist'>
                    <p className='btn-return-padding'>
                        <small><span id="helpToolTip" className='fa fa-question-circle'></span> Need more help?<Link className="link" to={`/help`}>Go to help center</Link></small>
                        <Tooltip placement="bottom" isOpen={this.state.tooltipOpen} target="helpToolTip" toggle={this.toggle}>
                            Lorem Ipsum
                        </Tooltip>
                    </p>
                    <p className='btn-return-padding'>
                        <a href='/'><button className="btn btn-return" >Return to Salesforce</button></a>
                    </p>
                </div>
            </div>
        );
    }
}

export default LicenseDBSidebar