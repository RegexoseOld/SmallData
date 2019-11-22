// frontend/src/App.js

import Utterance from './components/Utterance';
import TriggerCategory from './components/TriggerCategory';
import React, { Component } from "react";


const ColoredLine = ({ color }) => (
    <hr
        style={{
            color: color,
            backgroundColor: color,
            height: 2
        }}
    />
);


class App extends Component {
    render() {
        return (
            <main className="content">
                <h1 className="text-black text-uppercase text-center my-4">Small Data</h1>
                <div className="col-md-6 col-sm-10 mx-auto p-0">
                    <div>
                        <Utterance/>
                    </div>
                    <ColoredLine color="blue" />
                    <div>
                        <TriggerCategory/>
                    </div>
                 </div>
            </main>
        );
    }
}

export default App;
