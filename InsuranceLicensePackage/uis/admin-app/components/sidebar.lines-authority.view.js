import React, { Component } from 'react';
import { Link } from 'react-router';
import { Tooltip } from 'reactstrap';

class LinesSidebar extends Component {
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
                <div className='sidebar-div integrate-text'>
                    <span className='link-font integrate-padding' >Configure lines of authority </span>
                </div>
                <div className='sidebar-div'>
                    <span className='link-font integrate-padding'>Active compilance rules</span>
                </div>
                <div className='sidebar-div'>
                    <span className='link-font integrate-padding'>Integrate NIPR </span>
                </div>
            </div>
        )

        return (
            <div className='col-sm-3 zenefits-nav div-padding'>
                <h4>
                    <Link to={`/lineschecklist`}>
                        &lt; Back
                    </Link>
                </h4>
                {content}
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

export default LinesSidebar