// frontend/src/components/Utterance.js

import React, { Component } from "react";
import fetch from "node-fetch";
import { Button} from 'react-bootstrap';


export default class Utterance extends Component {
    constructor(props) {
        super(props);
        this.utteranceRef = React.createRef();
        this.state = {
            text: ''
        };

        this.handleChange = this.handleChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
    }

    handleSubmit(e) {
        e.preventDefault();

        const url = "http://127.0.0.1:8000";

        fetch(url + "/api/utterances/", {
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

    // this focusses on the textarea after the alert-window is closed
    componentDidUpdate () {
      this.utteranceRef.current.focus();
    }

    // this focusses on the textarea after the page is reloaded
    componentDidMount () {
      this.utteranceRef.current.focus();
    }

    render() {
        return (
            <div className="row ">
                <form>
                    <label>
                        Schreibe hier Deinen Beitrag zur Musik
                    </label>

                    <textarea type="text" style={{width: 600}}
                          ref={this.utteranceRef}
                          onChange={this.handleChange}
                          value={this.state.text}
                    />
                    <Button onClick={this.handleSubmit}>kommentieren</Button>
                </form>
                <p> </p>
            </div>
        );
    }
}
 //  onSubmit=