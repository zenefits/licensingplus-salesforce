import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { toggleChecklist } from '../actions/checklist-actions';
import { VIDEO_LINK } from '../constants/constants';
import Utils from '../utils/utils';
import { Tooltip } from 'reactstrap';

export class ChecklistSidebar extends Component {
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
                    <Link to={`/welcome`}>
                        &lt; Back
                    </Link>
                </h4>
                <div className="check">
                    <div className='sidebar-div link-font integrate-padding'>
                        Configure lines of authority
                    </div>
                    <div className='sidebar-div link-font integrate-padding'>
                        Active compilance rules
                    </div>
                    <div className='sidebar-div link-font integrate-padding'>
                        Integrate NIPR
                    </div>
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
        )
    }
}

export default ChecklistSidebar;