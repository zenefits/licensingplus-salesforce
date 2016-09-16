import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
import { VIDEO_LINK } from '../constants/constants';
import Sidebar from './sidebar.container';

export class Complete extends Component {
    constructor(props) {
        super(props)
    }

    render() {
        return (
            <div className='license-form'>
                <div>
                    <Sidebar activePage='complete' />
                    <div className='col-md-9 inside-container'>
                        <div className='col-md-3'>
                        </div>
                        <div className='col-md-5 text-center complete-congratulation'>
                            <h2>Congratulations!</h2>
                            <img src="http://www.tizag.com/pics/htmlT/sunset.gif" height="250" width="300" ></img>
                            <br/><br/>
                             <h4>You did it</h4>
                             <div><Link to={'/checklistcomplete'}> Go to the setting Page  </Link></div>
                        </div>
                        <div className='col-md-4'>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}


const mapStateToProps = (state) => {
    return {
    };
}

const mapDispatchToProps = (dispatch) => {
    return {
    }
}

export default connect(
    mapStateToProps,
    mapDispatchToProps
)(Complete)