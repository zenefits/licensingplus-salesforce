import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { toggleChecklist } from '../actions/checklist-actions';
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
                        Activate compliance rules
                    </div>
                    <div className='sidebar-div link-font integrate-padding'>
                        Integrate NIPR
                    </div>
                </div>
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

export default ChecklistSidebar;