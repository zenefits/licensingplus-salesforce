import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';

class WelcomeScreen extends Component {
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
                Welcome to Compliance +
            </h1>
            <p className="welcome-para">
                We built this compliance tool for Salesforce as a way to ensure our company was staying compliant. We thought it might be useful for your company, too.
            </p>
            <div className="welcom-btn-box">
                <Link to='/checklist' className="welcome-get-started-btn">Get Started</Link>
            </div>
            <div className="welcome-vid-container">
                <div className="col-md-3"></div>
                <div className="col-md-6">
                  <div className="embed-responsive embed-responsive-16by9 welcome-vid-box">
                    <iframe className="embed-responsive-item" src="https://www.youtube.com/embed/E-0EpztLz0c"></iframe>
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