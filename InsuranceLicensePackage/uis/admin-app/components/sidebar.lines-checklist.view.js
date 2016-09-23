import React, { Component } from 'react';
import { Link } from 'react-router';
import { Tooltip } from 'reactstrap';

class LinesChecklistSidebar extends Component {
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
                    <Link to={`/checklist`}>
                        &lt; Back
                    </Link>
                </h4>
                <div className= 'integrate-text link-font'>
                    Configure lines of authority
                </div>
                <div className= 'sidebar-div integrate-padding'>
                    <span className='link-font'>Activate compliance rules </span>
                </div>
                <div className= 'sidebar-div integrate-padding'>
                    <span className='link-font'>Integrate NIPR</span>
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
        );
    }
}

export default LinesChecklistSidebar