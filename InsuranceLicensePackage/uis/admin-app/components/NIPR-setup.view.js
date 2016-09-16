import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { toggleChecklist } from '../actions/checklist-actions';
import { VIDEO_LINK } from '../constants/constants';
import Utils from '../utils/utils';
import Sidebar from './sidebar.container';
import { Tooltip } from 'reactstrap';

export class NIPRSetupView extends Component {
    constructor(props) {
        super(props);
        this.renderURLField = this.renderURLField.bind(this);
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

    renderURLField() {
        let inputURL;
        if (this.props.herokuURLError) {
            inputURL = (
                <div className="form-group col-md-6 has-error">
                    <input type="text" className="col-md-6 form-control url-textbox" placeholder='URL' onChange={this.props.onChangeHerokuURL} value={this.props.herokuURL}/>
                    <small className='text-help'>Heroku App setup incorrectly / incomplete</small>
                </div>
            );
        }
        else if (this.props.herokuURLSuccess) {
            inputURL = (
                <div className="form-group col-md-6">
                    <input type="text" className="col-md-6 form-control url-textbox" placeholder='URL' onChange={this.props.onChangeHerokuURL} value={this.props.herokuURL}/>
                    <span className='heroku-success'>Success!</span>
                </div>
            );
        }
        else {
            inputURL = (
                <div className="form-group col-md-6">
                    <input type="text" className="col-md-6 form-control url-textbox" placeholder='URL' onChange={this.props.onChangeHerokuURL} value={this.props.herokuURL}/>
                </div>
            );
        }
        if (this.props.showURL || this.props.isHerokuCreated) {
            return (
                <div>
                    <h6> Enter Heroku Credentials</h6>
                    <div className="row license-db-div ">
                        {inputURL}
                        <button className="btn check-connection-button col-md-3" onClick={this.props.checkHerokURL.bind(null, this.props.herokuURL) }>Check Connection</button>
                    </div>
                    <div className="row">
                        <div className="col-md-3">
                            <a className="btn" onClick={this.props.onRetryHerokuClick}>Retry Heroku Application</a>
                        </div>
                        <div className="col-md-6 div-align">
                            <Link  to={'/approval'}><button className={this.props.isMaintainanceMode ? 'btn donebtn-visibility' : 'btn btn-warning next-button'} >Next</button></Link>
                        </div>
                    </div>
                </div>
            );
        }
    }

    renderCreateHeroku() {
        if (!this.props.showURL && !this.props.isHerokuCreated) {
            return (
                <button className="btn btn-warning btn-checklist" onClick={this.props.onCreateHerokuClick}>Create Heroku Application</button>
            )
        }
    }

    renderNIPR() {
        return (
            <div className="col-sm-9 getting-started inside-container">
                <h4 className="sub-heading">NIPR Integration Setup <small><span id='helpToolTipNipr' className='fa fa-question-circle question-icon-size'></span></small> </h4>
                <Tooltip placement="bottom" isOpen={this.state.tooltipOpen} target="helpToolTipNipr" toggle={this.toggle}>
                    NIPR Integration Setup
                </Tooltip>
                <br/>
                <p>In order to manage the NIPR integration daily feed you need to setup a simple 3rd party application
                (Heroku). We have pre-configured the setup to make it as easy as possible for you, 5 minutes and
                    a few clicks is all it takes.</p>
                <br/>
                <p>To complete the NIPR integration you also need to create an NIPR Producer Database Account which can be setup via email through NIPR. Note that it can take NIPR a few business days to
                    process.</p>
                <br/>

                {this.renderCreateHeroku() }
                {this.renderURLField() }
            </div>
        );
    }

    render() {
        return (
            <div className='license-form'>
                <div>
                    <Sidebar activePage='nipr'/>
                    {this.renderNIPR() }
                </div>
            </div>
        )
    }
}

NIPRSetupView.propTypes = {
    showURLField: React.PropTypes.func.isRequired,
    showURL: React.PropTypes.bool.isRequired,
};
export default NIPRSetupView