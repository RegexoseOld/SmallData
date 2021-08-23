// frontend/src/components/Utterance.js

import React, { Component } from "react";
import fetch from "node-fetch";


export default class Utterance extends Component {
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
        fetch("http://localhost:8000/api/utterances/", {
            method: "POST",
            body: JSON.stringify(this.state),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
        }).then(response => {
            (response.json().then(data => {alert('You said: ' + data['text'] +
                '\n Machine thinks: ' + data['category']['name'])
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
                        Schreibe hier Deinen Beitrag zur Musik
                    </label>
                </div>

                <div className="row ">
                    <form onSubmit={this.handleSubmit}>
                <textarea type="text" style={{width: 600}}
                          onChange={this.handleChange}
                          value={this.state.text}
                />

                        <div>
                            <input type="submit" value="kommentieren" />
                            <p>  </p>

                        </div>
                    </form>
                </div>
            </div>
        );
    }
}
