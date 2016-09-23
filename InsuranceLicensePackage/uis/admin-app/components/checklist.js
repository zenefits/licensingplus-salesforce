import React, { Component } from 'react';
import { Link } from 'react-router';
import { connect } from 'react-redux';
import Sidebar from './sidebar.container';

export class Welcome extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className='license-form'>
        <div>
          <Sidebar activePage='checklist'/>
          <div className='col-md-9 checklist-new padding-bottom checklist-padding'>
            <h2 className='padding-bottom checklist-margin'>Getting started checklist</h2>
            <div className="desc padding-bottom">Before you begin, you’ll need some information from your compliance team. Follow this checklist to get set up!</div>
            <h4>Setup Steps</h4>
            <h5>1. Configure lines of authority</h5>
            <h5>2. Activate compliance rules</h5>
            <h5>3. NIPR integration</h5>
            <br></br>
            <Link to={`/lineschecklist`} className='link btn btn-warning btn-checklist'>
              Lets Go
            </Link>
          </div>
        </div>
      </div>
    );
  }
}


export default Welcome