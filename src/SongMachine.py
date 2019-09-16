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
        category, condition, count = cond_string.split(" ")
        return lambda cat_counter: cat_counter[category] > int(count)


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

    def test_transitions(self, category_counter):
        """
        iterates over all transitions and checks their transfer-conditions. If a condition is true, return the name of
        the corresponding target state. If no condition is true, return the name of the current state
        :param category_counter:
        :return: name of next state (can be the current state if no condition is met)
        """
        for transition in self.transitions:
            if transition.condition(category_counter):
                return transition.target_name
        return self.name


class SongMachine:
    current_state = None
    final_state = None
    states = {}
    category_counter = {}

    def __init__(self, parser, categories=None):
        self._create_states(parser)
        self._add_transitions(parser)
        self._reset_counter(categories)

    def _create_states(self, parser):
        for state_name in parser.state_names:
            self.states[state_name] = State(state_name)

        self.current_state = self.states[parser.state_names[0]]
        self.final_state = self.states[parser.state_names[-1]]

    def _add_transitions(self, parser):
        for transition in parser.transitions:
            self.states[transition.source_name].add_transition(transition)

    def _reset_counter(self, categories):
        self.category_counter = {}.fromkeys(categories, 0) if categories else {}

    def update_state(self, category):
        if category in self.category_counter:
            self.category_counter[category] += 1
        else:
            self.category_counter[category] = 1

        next_state_name = self.current_state.test_transitions(self.category_counter)

        if next_state_name != self.current_state.name:
            self.current_state = self.states[next_state_name]
            self._reset_counter(self.category_counter.keys())

            if self.current_state == self.final_state:
                print("The END")


class SongParser:
    STATES = "states"
    CATEGORIES = "categories"
    TRANSITIONS = "transitions"

    data = {}
    transitions = []
    state_names = []

    def __init__(self, data):
        self.data = data

    def parse(self):
        self.state_names = self.data[self.STATES]
        [self.transitions.append(Transition(line)) for line in self.data[self.TRANSITIONS]]


class SongValidator(object):
    data = {}
    errors = []

    def __init__(self, data):
        self.data = data

    def validate(self):
        self._validate_fields()
        self._validate_consistency()

        if len(self.errors) > 0:
            raise Exception("Errors in song file:\n" + "\n".join(self.errors))

    def _validate_fields(self):
        """
        make sure the json contains all required fields
        :return:
        """
        def __validate_field(field):
            if field not in self.data:
                self.errors.append("song file misses required field `{}`".format(field))

        __validate_field(SongParser.STATES)
        __validate_field(SongParser.CATEGORIES)
        __validate_field(SongParser.TRANSITIONS)

    def _validate_consistency(self):
        """
        make sure the transitions contain only states and categories that are explicitly mentioned in the
        corresponding fields of the json
        :return:
        """
        for idx, transition in enumerate(self.data[SongParser.TRANSITIONS]):
            if len(transition) != 3:
                self.errors.append("Transition `{}` has the wrong length".format(idx))
            if transition[0] not in self.data[SongParser.STATES]:
                self.errors.append("Source state `{}` listed in transition `{}` is not contained in `states`".format(
                    transition[0], idx))
            if transition[1] not in self.data[SongParser.STATES]:
                self.errors.append("Target state `{}` listed in transition `{}` is not contained in `states`".format(
                    transition[1], idx))
            cond_array = transition[2].split(" ")
            if len(cond_array) != 3:
                self.errors.append("Wrong format of condition in transition `{}`".format(idx))
            if cond_array[0] not in self.data[SongParser.CATEGORIES]:
                self.errors.append("Category `{}` of condition `{}` not contained in categories".format(
                    cond_array[0], idx))


if __name__ == '__main__':
    path_to_song_file = '../config/song_example.json'
    with open(path_to_song_file, 'r') as f:
        json_data = json.load(f)
    SongValidator(json_data).validate()
    json_parser = SongParser(json_data)
    json_parser.parse()
    song_machine = SongMachine(json_parser)

    print(song_machine.current_state)
    song_machine.update_state("Lob")
    print(song_machine.category_counter)
    song_machine.update_state("Lob")
    print(song_machine.category_counter)
    song_machine.update_state("Lob")
    print(song_machine.category_counter)
    print(song_machine.current_state)
    song_machine.update_state("Kritik")
    print(song_machine.category_counter)
    song_machine.update_state("Kritik")
    print(song_machine.current_state)
