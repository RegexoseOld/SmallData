// frontend/src/components/Utterance.js

import React, { Component } from "react";
import fetch from "node-fetch";


export default class TriggerCaegory extends Component {
    constructor(props) {
        super(props);
        this.state = {
            text: ''
        };

        this.handleChange = this.handleChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    handleSubmit(e) {
        e.preventDefault();
        fetch("http://localhost:8000/api/categories/1/trigger", {
            method: "POST",
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
        }).then(response => {
            (response.json().then(data => {alert('message: ' + data['message'] )
            }).then(val => this.resetForm()))
        });
    }

    handleChange(event) {
        this.setState({text: event.target.value});
    }

    resetForm() {
        this.setState({text: ''});
    }

    render() {
        return (
            <div>
                <div className="row ">
                    <label>
                        Please select your category:
                    </label>
                </div>

                <div className="row ">
                    <form onSubmit={this.handleSubmit}>
                <textarea type="text" style={{width: 350}}
                          onChange={this.handleChange}
                          value={this.state.text}
                />
                        <div>
                            <input type="submit" value="Submit" />
                        </div>
                    </form>
                </div>
            </div>
        );
    }
}
