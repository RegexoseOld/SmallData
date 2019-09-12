import json


class Transition:
    source_name = ''
    target_name = ''
    condition = None

    def __init__(self, transition_array):
        self.source_name = transition_array[0]
        self.target_name = transition_array[1]
        self.condition = self._parse_condition_string(transition_array[2])

    @staticmethod
    def _parse_condition_string(cond_string):
        """
        convert the condition-string (as contained in the song.json) to a callable
        :param cond_string:
        :return: callable. returns true if the category-counter fulfills the condition
        """
        cond_arr = cond_string.split(" ")
        category = cond_arr[0]
        count = int(cond_arr[2])
        return lambda cat_counter: cat_counter[category] > count


class State:
    name = ''
    transitions = []

    def __init__(self, name):
        self.name = name
        self.transitions = []

    def __str__(self):
        return "<State {}>".format(self.name)

    def add_transition(self, transition):
        self.transitions.append(transition)

    def check_transitions(self, category_counter):
        """
        iterates over all transitions and checks their transfer-conditions. If a condition is true, return the name of
        the corresponding target state. If no condition is true, return the name of the current state
        :param category_counter:
        :return: name of next state
        """
        for transition in self.transitions:
            if transition.condition(category_counter):
                return transition.target_name
        return self.name


class SongMachine:
    current_state = ''
    states = []
    category_counter = {}

    def __init__(self, parser, categories=None):
        self.states = self._create_states(parser)
        self._add_transitions(parser)
        self.category_counter = {}.fromkeys(categories, 0) if categories else {}
        self.current_state = self.states[parser.initial_state]

    @staticmethod
    def _create_states(parser):
        states = {}
        for transition in parser.transitions:
            if transition.source_name not in states:
                states[transition.source_name] = State(transition.source_name)
            if transition.target_name not in states:
                states[transition.target_name] = State(transition.target_name)
        return states

    def update_state(self, category):
        if category in self.category_counter:
            self.category_counter[category] += 1
        else:
            self.category_counter[category] = 1
        next_state_name = self.current_state.check_transitions(self.category_counter)
        self.current_state = self.states[next_state_name]

    def _add_transitions(self, parser):
        for transition in parser.transitions:
            self.states[transition.source_name].add_transition(transition)


class SongParser:
    initial_state = None
    transitions = []

    def __init__(self, path_to_file):
        with open(path_to_file, 'r') as f:
            data = json.load(f)
            self.__parse_json(data)

    def __parse_json(self, data):
        self.initial_state = data['initial_state']
        [self.transitions.append(Transition(line)) for line in data['transitions']]


if __name__ == '__main__':
    path_to_song_file = '../config/song1.json'
    json_parser = SongParser(path_to_song_file)
    song_machine = SongMachine(json_parser)

    print(song_machine.current_state)
    song_machine.update_state("Lob")
    print(song_machine.category_counter)
    song_machine.update_state("Lob")
    print(song_machine.category_counter)
    song_machine.update_state("Lob")
    print(song_machine.category_counter)
    print(song_machine.current_state)
