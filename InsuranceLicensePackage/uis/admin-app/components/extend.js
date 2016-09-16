import React, { Component } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux';
import { EMBED_VIDEO_LINK } from '../constants/constants';

export class Extend extends Component {
  constructor(props) {
    super(props)
  }

  renderSnippet() {
    var code = `
    trigger TestValidationTrigger on TestCustomObject__c (after insert, after update) {
      if (trigger.isAfter) {
        if (trigger.isInsert || trigger.isUpdate) {
          LicensingPlus.LicensingUtils.checkSObjectLicenseRules(trigger.newMap, \'TestCustomObject__c\');
        }
      }
    }`
    return (
      <pre>
        {code}
      </pre>
    );
  }

  renderLink() {
    let theLink = (this.props.isMaintainanceMode) ? '/checklistcomplete' : '/compliancechecklist';
    return (
      <Link to={theLink} className="welcome-get-started-btn">Go Back to Checklist</Link>
    )
  }

  render() {
    return (
      <div className='license-form welcome'>
        <div className='row welcome-main-row'>
          <h1 className="welcome-main-heading">
            Recommended next steps
          </h1>
          <div className="welcome-vid-container">
            <div className="col-md-3"></div>
            <div className="col-md-6">
              <div className="embed-responsive embed-responsive-16by9 welcome-vid-box">
                <iframe className="embed-responsive-item" src={EMBED_VIDEO_LINK}></iframe>
              </div>
            </div>
            <div className="col-md-3"></div>
          </div>
        </div>
        <div className='row welcome-main-row'>
          <h1 className="welcome-main-heading2">
            Extend application to your custom objects
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
                {this.renderLink()}
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state) => {
    return {
        isMaintainanceMode: state.isMaintainanceMode
    };
}

const mapDispatchToProps = (dispatch) => {
    return {
    }
}

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(Extend)