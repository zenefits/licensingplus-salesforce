import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { EMBED_VIDEO_LINK } from '../constants/constants';

export class WelcomeScreen extends Component {
  constructor(props){
    super(props)
    this.state = {
      checklist: {}
    }
  }

  render() {
    return (
      <div className='license-form welcome'>
        <div className='row welcome-main-row'>
            <h1 className="welcome-main-heading">
                Welcome to Licensing +
            </h1>
            <p className="welcome-para">
                Licensing+ is the first and only app built to integrate insurance license compliance directly into Salesforce. By automatically cross-checking state requirements against individual agent status, Licensing+ helps ensure that credentials are always up to date—for free!
            </p>
            <div className="welcom-btn-box">
                <Link to='/checklist' className="welcome-get-started-btn link btn btn-warning">Get Started</Link>
            </div>
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
      </div>
    );
  }
}


const mapStateToProps = (state) => {
  return {
    checklist: state.checklist
  };
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
)(WelcomeScreen)