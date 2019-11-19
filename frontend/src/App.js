// frontend/src/App.js

import Utterance from './components/Utterance';
import TriggerCategory from './components/TriggerCategory';
import React, { Component } from "react";
import fetch from "node-fetch";


class App extends Component {
    render() {
        return (
            <main className="content">
                <div className="col-md-6 col-sm-10 mx-auto p-0">
                    <h1 className="text-black text-uppercase text-center my-4">Small Data</h1>

                    <div>
                        <Utterance/>
                    </div>
                    <div>
                        <TriggerCategory/>
                    </div>
                 </div>
            </main>
        );
    }
}

export default App;
