import json


class Transition:
    SIGN = '>'
    source_name = ''
    target_name = ''
    category = ''
    limit = 0

    def __init__(self, transition_array):
        self.source_name = transition_array[0]
        self.target_name = transition_array[1]
        self.__parse_condition_string(transition_array[2])

    def __parse_condition_string(self, cond_string):
        category, limit = cond_string.split(self.SIGN)
        self.category = category.strip()
        self.limit = int(limit.strip())

    def condition(self, cat_counter):
        return cat_counter[self.category] > self.limit

    def get_readable(self):
        """
        :return: a triple with (category, limit, target_name)
        """
        return self.category, self.limit, self.target_name


class State:
    name = ''
    note = 0
    transitions = []

    def __init__(self, name, note):
        self.name = name
        self.note = note
        self.transitions = []

    def __str__(self):
        return "<State {}>".format(self.name)

    def add_transition(self, transition):
        self.transitions.append(transition)

    def get_targets(self):
        targets = {}
        for trans in self.transitions:
            triple = trans.get_readable()
            targets[triple[0]] = (triple[1], triple[2])
        return targets

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
    last_state = None
    parser = None
    category_counter = {}
    __lock = False

    def __init__(self, parser):
        self.parser = parser
        self.current_state = self.parser.states[self.parser.first_state_name]
        self.last_state = self.parser.states[self.parser.last_state_name]
        self._reset_counter(parser.categories)

    def _reset_counter(self, categories):
        self.category_counter = {}.fromkeys(categories, 0) if categories else {}

    def release_lock(self):
        self._reset_counter(self.category_counter.keys())
        self.__lock = False

    def is_locked(self):
        return self.__lock

    def update_state(self, category):
        """
        :param category:
        :return: Boolean, True if state is changed
        """
        self.category_counter[category] += 1
        next_state_name = self.current_state.test_transitions(self.category_counter)

        if next_state_name == self.current_state.name:
            # no state change
            return False
        else:
            # state change
            self.__lock = True
            self.current_state = self.parser.states[next_state_name]

            if self.current_state == self.last_state:
                print("The END")

            return True


class SongParser:
    NAME_STATES_TO_NOTES = "states_to_notes"
    NAME_CATEGORIES = "categories"
    NAME_TRANSITIONS = "transitions"
    NAME_FIRST_STATE = "first_state"
    NAME_LAST_STATE = "last_state"

    data = {}
    states = {}
    categories = []

    first_state_name = ''
    last_state_name = ''

    def __init__(self, validated_data):
        self.data = validated_data

    def parse(self):
        self.categories = self.data[self.NAME_CATEGORIES]
        self._create_states()
        self._add_transitions()

    def _create_states(self):
        for state_name, note in self.data[self.NAME_STATES_TO_NOTES].items():
            self.states[state_name] = State(state_name, note)
        self.first_state_name = self.data[self.NAME_FIRST_STATE]
        self.last_state_name = self.data[self.NAME_LAST_STATE]

    def _add_transitions(self):
        for transition_array in self.data[self.NAME_TRANSITIONS]:
            transition = Transition(transition_array)
            self.states[transition.source_name].add_transition(transition)


class SongValidator(object):
    data = {}
    errors = []

    def __init__(self, data):
        self.data = data

    @property
    def categories(self):
        return self.data[SongParser.NAME_CATEGORIES]

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

        __validate_field(SongParser.NAME_STATES_TO_NOTES)
        __validate_field(SongParser.NAME_CATEGORIES)
        __validate_field(SongParser.NAME_TRANSITIONS)

    def _validate_consistency(self):
        """
        make sure the transitions contain only states and categories that are explicitly mentioned in the
        corresponding fields of the json
        :return:
        """
        for idx, transition in enumerate(self.data[SongParser.NAME_TRANSITIONS]):
            if len(transition) != 3:
                self.errors.append("Transition `{}` has the wrong length".format(idx))
            else:
                if transition[0] not in self.data[SongParser.NAME_STATES_TO_NOTES]:
                    self.errors.append(
                        "Source state `{}` listed in transition `{}` is not contained in `states`".format(
                            transition[0], idx)
                    )
                if transition[1] not in self.data[SongParser.NAME_STATES_TO_NOTES]:
                    self.errors.append(
                        "Target state `{}` listed in transition `{}` is not contained in `states`".format(
                            transition[1], idx))
                cond_array = transition[2].split(" ")
                if len(cond_array) != 3:
                    self.errors.append("Wrong format of condition in transition `{}`".format(idx))
                if cond_array[0] not in self.data[SongParser.NAME_CATEGORIES]:
                    self.errors.append("Category `{}` of condition `{}` not contained in categories".format(
                        cond_array[0], idx))
        if self.data[SongParser.NAME_FIRST_STATE] not in self.data[SongParser.NAME_STATES_TO_NOTES]:
            self.errors.append(
                "First state (`{}`) is not contained in `states`".format(self.data[SongParser.NAME_FIRST_STATE])
            )
        if self.data[SongParser.NAME_LAST_STATE] not in self.data[SongParser.NAME_STATES_TO_NOTES]:
            self.errors.append(
                "Last state (`{}`) is not contained in `states`".format(self.data[SongParser.NAME_LAST_STATE])
            )


def create_instance(path_to_song_file):
    with open(path_to_song_file, 'r') as f:
        json_data = json.load(f)

    SongValidator(json_data).validate()
    parser = SongParser(json_data)
    parser.parse()
    return SongMachine(parser)


if __name__ == '__main__':
    import sys
    from os import path
    sys.path.append(path.dirname(path.dirname(__file__)))
    from config import settings

    song_machine = create_instance(settings.song_path)

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
