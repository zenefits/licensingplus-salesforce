import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { toggleChecklist } from '../actions/checklist-actions';

var _csvTemplateLink = (typeof StaticResource === 'undefined') ? '#' : StaticResource.CONFIGURATION_LOA;

class Welcome extends Component {
  constructor(props){
    super(props)
    this.state = {
      checklist: {}
    }
  }

  toggleChecklist(key) {
    var checklist = Object.assign({},this.props.checklist);
    var value = checklist[key] ? !checklist[key] : true;
    checklist[key] = value;
    this.props.toggleChecklist(checklist); 
  }

  renderLoaButton(){
    var isLoaChecklistComplete = this.props.checklist.download_spreadsheet__c
      && this.props.checklist.watch_configuration_video__c
      && this.props.checklist.send_spreadsheet__c
      && this.props.checklist.filled_spreadsheet__c;

    const label = 'Configure Lines of Authority';

    if(isLoaChecklistComplete){
      return <Link to='/lines' className='btn btn-warning btn-checklist' role='button'>{label}</Link>;
    }
    else {
      return <Link to='/lines' className='btn btn-secondary secondary-disabled btn-checklist' role='button' onClick={e => e.preventDefault()}>{label}</Link>;
    }
  }

  renderComplianceButton(){
    var isComplianceChecklistComplete = this.props.checklist.watch_video__c;

    const label = 'Activate Compliance Rules';

    if(isComplianceChecklistComplete){
      return <Link to='/rules' className='btn btn-warning btn-checklist' role='button'>{label}</Link>;
    }
    else {
      return <Link to='/rules' className='btn btn-secondary secondary-disabled btn-checklist' role='button' onClick={e => e.preventDefault()}>{label}</Link>;
    }
  }

  renderExtendButton(){
    var isExtendChecklistComplete = this.props.checklist.set_approvals__c 
      && this.props.checklist.watch_compliance_video__c;

    const label = 'Extend This Application';
    if(isExtendChecklistComplete){
      return <Link to='/extend' className='btn btn-warning btn-checklist' role='button'>{label}</Link>;
    }
    else {
      return <Link to='/extend' className='btn btn-secondary secondary-disabled btn-checklist' role='button' onClick={e => e.preventDefault()}>{label}</Link>;
    }
  }

  renderChecklist() {
    var checklistEmpty = !('download_spreadsheet__c' in this.props.checklist)
    if(checklistEmpty) {
      return (
        <div className='col-sm-9 getting-started inside-container'>
          <div className='checklist'>
            <h5>Configure lines of authority</h5>
            <hr/>
          </div>
        </div>
      )
    }
    else {
      return (
        <div className='col-sm-9 getting-started inside-container'>
        <div className='checklist'>
          <h5>1. Configure lines of authority</h5>
          <small>Check the box as you complete each item</small>
          <hr/>
          <div className='checkbox checkbox-container'>
            <label>
              <input type='checkbox' id='1' checked={this.props.checklist.watch_configuration_video__c} onChange={this.toggleChecklist.bind(this, 'watch_configuration_video__c')}></input>
               <label htmlFor='1' className='label-check'>Watch our <a href='https://www.youtube.com/watch?v=E-0EpztLz0c' target='_blank'>configuration video</a>.</label>
            </label>
          </div>
          <div className='checkbox checkbox-container'>
            <label>
              <input type='checkbox' id='2' checked={this.props.checklist.download_spreadsheet__c} onChange={this.toggleChecklist.bind(this, 'download_spreadsheet__c')}></input>
              <label htmlFor='2' className='label-check'>Download the <a href={_csvTemplateLink}>configuration spreadsheet</a>.</label>
            </label>
          </div>
          <div className='checkbox checkbox-container'>
            <label>
              <input type='checkbox' id='3' checked={this.props.checklist.send_spreadsheet__c} onChange={this.toggleChecklist.bind(this, 'send_spreadsheet__c')}></input>
              <label htmlFor='3' className='label-check'>Send the spreadsheet to your compliance team.</label>
            </label>
          </div>
          <div className='checkbox checkbox-container'>
            <label>
              <input type='checkbox' id='4' checked={this.props.checklist.filled_spreadsheet__c} onChange={this.toggleChecklist.bind(this, 'filled_spreadsheet__c')}></input>
              <label htmlFor='4' className='label-check'>Get the spreadsheet back.</label>
            </label>
          </div>
          <div>
            {this.renderLoaButton()}
          </div>
        </div>
        <div className='checklist'>
          <h5>2. Activate Compliance Rules</h5>
          <small>Check the box as you complete each item</small>
          <hr/>
          <div className='checkbox checkbox-container'>
            <label>
              <input type='checkbox' id='5' checked={this.props.checklist.watch_video__c} onChange={this.toggleChecklist.bind(this, 'watch_video__c')}></input>
              <label htmlFor='5' className='label-check'>Watch our video on <a href='https://www.youtube.com/watch?v=E-0EpztLz0c' target='blank'>standard compliance rules</a>.</label>
            </label>
          </div>
          <div>
            {this.renderComplianceButton()}
          </div>
        </div>
        <div className='checklist'>
          <h5>3. Recommended Next Steps</h5>
          <small>Check the box as you complete each item</small>
          <hr/>
          <div className='checkbox checkbox-container'>
            <label>
              <input type='checkbox' id='6' checked={this.props.checklist.set_approvals__c} onChange={this.toggleChecklist.bind(this, 'set_approvals__c')}></input>
              <label htmlFor='6' className='label-check'>Setup an approval process.</label>
            </label>
          </div>
          <div className='checkbox checkbox-container'>
            <label>
              <input type='checkbox' id='7' checked={this.props.checklist.watch_compliance_video__c} onChange={this.toggleChecklist.bind(this, 'watch_compliance_video__c')}></input>
              <label htmlFor='7' className='label-check'>Watch our video on how to extend the compliance rule engine.</label>
            </label>
          </div>
          <div>
            {this.renderExtendButton()}
          </div>
        </div>
        </div>
      )
    }
  }

  render() {
    return (
      <div className='license-form'>
        <div className='row'>
          <div className='col-sm-3 zenefits-nav'>
            <h4>
              <Link to={`/welcome`}>
                &lt; Back
              </Link>
            </h4>
            <h1>Getting started checklist</h1>
            <p>Before you begin, you’ll need some information from your compliance team. Follow this checklist to get set up!</p>
            <div className='salesforce-link-checklist'>
              <p>
                <small><span className='glyphicon glyphicon-question-sign'></span> Need more help?<a className='link' href='https://www.youtube.com/watch?v=E-0EpztLz0c' target='_blank'>Watch our video!</a></small>
              </p>
              <p>
                <a className='link' href='/'>Return to Salesforce</a>
              </p>
            </div>
          </div>
          {this.renderChecklist()}
        </div>
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
    }
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Welcome)