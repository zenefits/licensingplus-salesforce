import React, { Component } from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router';
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
                        <div className='col-md-1'></div>
                        <div className='col-md-6 text-center complete-congratulation'>
                            <div className='congratulations'></div>
                            <div><Link to={'/checklistcomplete'}> Go to the setting Page </Link></div>
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