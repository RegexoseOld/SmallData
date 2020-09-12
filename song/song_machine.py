import json


class Transition:
    SIGN = '>'
    source_name = ''
    target_name = ''
    category = ''
    limit = 0

    def __init__(self, name, part_name, category, limit):
        self.source_name = name
        self.target_name = part_name
        self.target_cat = category
        self.target_limit = limit
    #     self.__parse_condition_string()
    #
    # def __parse_condition_string(self, cond_string):
    #     category, limit = cond_string.split(self.SIGN)
    #     self.category = category.strip()
    #     self.limit = int(limit.strip())

    def condition(self, cat_counter):
        return cat_counter[self.target_cat] > self.target_limit

    def get_readable(self):
        """
        :return: a triple with (category, limit, target_name)
        """
        return self.category, self.limit, self.target_name


class State:
    name = ''
    note = 0
    transitions = []
    receipts = {}

    def __init__(self, name, note):
        self.name = name
        self.note = note
        self.transitions = []

    def __str__(self):
        return "<State '{}'>".format(self.name)

    def add_transition(self, transition):
        self.transitions.append(transition)

    def add_receipts(self, receipts):
        self.receipts = receipts

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
        self.current_state = self.parser.song_parts[self.parser.first_state_name]
        # self.last_state = self.parser.song_parts[self.parser.last_state_name]
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
    MAX_UTTERANCES = "max_num_utterances"
    NAME_CATEGORIES = "categories"
    STATES = "states"
    NAME_FIRST_PART = "first_part"

    data = {}
    song_parts = {}
    categories = []

    first_state_name = ''
    max_utterances = 0

    def __init__(self, validated_data):
        self.data = validated_data

    def parse(self):
        self.categories = self.data[self.NAME_CATEGORIES]
        self._create_states()
        self._create_receipts()
        self._add_transitions()

    def _create_states(self):
        for part_dict in self.data[self.STATES]:
            part_name = part_dict["name"]
            note = part_dict["note"]
            self.song_parts[part_name] = State(part_name, int(note))
        self.first_state_name = self.data[self.NAME_FIRST_PART]

    def _create_receipts(self):
        for part_dict in self.data[self.STATES]:
            part_name = part_dict["name"]
            receipts = part_dict["receipts"]
            self.song_parts[part_name].add_receipts(receipts)

    def _add_transitions(self):
        for part in self.song_parts.keys():
            for part_dict in self.data[self.STATES]:
                part_name = part_dict["name"]
                associated_category = part_dict["category"]
                limit = part_dict["limit"]
                if not part_name == part:
                    transition = Transition(part, part_name, associated_category, limit)
                    self.song_parts[transition.source_name].add_transition(transition)


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

        __validate_field(SongParser.STATES)
        __validate_field(SongParser.NAME_CATEGORIES)

    def _validate_consistency(self):
        """
        make sure the transitions contain only states and categories that are explicitly mentioned in the
        corresponding fields of the json
        :return:
        """
        # for idx, transition in enumerate(self.data[SongParser.NAME_TRANSITIONS]):
        #     if len(transition) != 3:
        #         self.errors.append("Transition `{}` has the wrong length".format(idx))
        #     else:
        #         if transition[0] not in self.data[SongParser.NAME_STATES_TO_NOTES]:
        #             self.errors.append(
        #                 "Source state `{}` listed in transition `{}` is not contained in `states`".format(
        #                     transition[0], idx)
        #             )
        #         if transition[1] not in self.data[SongParser.NAME_STATES_TO_NOTES]:
        #             self.errors.append(
        #                 "Target state `{}` listed in transition `{}` is not contained in `states`".format(
        #                     transition[1], idx))
        #         cond_array = transition[2].split(" ")
        #         if len(cond_array) != 3:
        #             self.errors.append("Wrong format of condition in transition `{}`".format(idx))
        #         if cond_array[0] not in self.data[SongParser.NAME_CATEGORIES]:
        #             self.errors.append("Category `{}` of condition `{}` not contained in categories".format(
        #                 cond_array[0], idx))
        part_names = []
        for d in self.data[SongParser.STATES]:
            part_names.append(d["name"])
        if self.data[SongParser.NAME_FIRST_PART] not in part_names:
            self.errors.append(
                "First state (`{}`) is not contained in `states`".format(self.data[SongParser.NAME_FIRST_PART])
            )
        # if self.data[SongParser.NAME_LAST_STATE] not in self.data[SongParser.NAME_STATES_TO_NOTES]:
        #     self.errors.append(
        #         "Last state (`{}`) is not contained in `states`".format(self.data[SongParser.NAME_LAST_STATE])
        #     )


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
