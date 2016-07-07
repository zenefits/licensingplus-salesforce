import _ from 'lodash';
import React, { Component } from 'react';
import { Link, hashHistory } from 'react-router';
import { connect } from 'react-redux';
import { getChecklist } from '../actions/app-manager-actions';

class AppManager extends Component {
  constructor(props){
    super(props)
    this.state = {}
  }

  componentDidMount() {
    //pass the pathname to ensure proper redirect if we are at root ('/')
    var pathname = this.props.location.pathname;
    // javascript remoting to get checklist values
    this.props.getChecklist(pathname);
  }

  render() {
    return (
      <div>
        {this.props.children}
      </div>
    );
  }
}


const mapStateToProps = (state) => {
  return {}
}

const mapDispatchToProps = (dispatch) => {
  return {
    getChecklist: (pathname) => {
      dispatch(getChecklist(pathname));
    }
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(AppManager)