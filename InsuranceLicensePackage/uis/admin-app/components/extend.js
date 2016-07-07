import React, { Component } from 'react';
import { Link } from 'react-router';

class Extend extends Component {
  constructor(props) {
    super(props)
  }

  renderSnippet() {
    var code = `
    trigger TestValidationTrigger on TestCustomObject__c (after insert, after update) {
      if (trigger.isAfter) {
        if (trigger.isInsert || trigger.isUpdate) {
          LicensingUtils.checkSObjectLicenseRules(trigger.newMap, \'TestCustomObject__c\');
        }
      }
    }`
    return (
      <pre>
        {code}
      </pre>
    );
  }

  render() {
    return (
      <div className='license-form welcome'>
        <div className='row welcome-main-row'>
          <h1 className="welcome-main-heading">
            Recommended Next Steps
          </h1>
          <div className="welcome-vid-container">
            <div className="col-md-3"></div>
            <div className="col-md-6">
              <div className="welcome-vid-box">
                <div className="embed-responsive embed-responsive-16by9 welcome-vid-box">
                    <iframe className="embed-responsive-item" src="https://www.youtube.com/embed/E-0EpztLz0c"></iframe>
                </div>
              </div>
            </div>
            <div className="col-md-3"></div>
          </div>
        </div>
        <div className='row welcome-main-row'>
          <h1 className="welcome-main-heading2">
            Extend Application To your Custom Objects
          </h1>
          <div className="welcome-vid-container">
            <div className="col-md-3">
            </div>
            <div className="col-md-6 snippet">
              {this.renderSnippet() }
            </div>
            <div className="col-md-3"></div>
          </div>
          <div className='row welcome-main-row'>
            <div className="col-md-12">
              <div className="welcom-btn-box">
                <Link to='/checklist' className="welcome-get-started-btn">Go Back To Checklist</Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}


export default Extend