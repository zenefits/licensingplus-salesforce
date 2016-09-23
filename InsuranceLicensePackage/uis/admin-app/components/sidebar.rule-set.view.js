import React, { Component } from 'react';
import { Link } from 'react-router';
import { Tooltip } from 'reactstrap';

export class RulesSidebar extends Component {
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
        let content;
        content = (

            <div>
                <div className='sidebar-div'>
                    <span className='fa fa-check  ok-icon-color icon-font'></span>
                    <span className='link-font'>Configure lines of authority </span>
                </div>
                <div className='sidebar-div integrate-text'>
                    <span className='link-font integrate-padding'>Activate compliance rules</span>
                </div>
                <div className='sidebar-div'>
                    <span className='link-font integrate-padding' to={'/niprchecklist'}>Integrate NIPR </span>
                </div>
            </div>
        )

        return (
            <div className='col-sm-3 zenefits-nav div-padding'>
                <h4>
                    <Link to={`/compliancechecklist`}>
                        &lt; Back
                    </Link>
                </h4>
                {content}

                <div className='salesforce-link-checklist'>
                    <p className='btn-return-padding'>
                        <small>Need more help?<a href='https://www.zenefits.com/licensingplus/help/' target='_blank' className='link'>Go to Help Center</a></small>
                    </p>
                    <p  className='btn-return-padding'>
                        <a href='/'><button className="btn btn-return" >Return to Salesforce</button></a>
                    </p>
                </div>
            </div>
        );
    }
}

export default RulesSidebar