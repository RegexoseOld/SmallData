import json


class Transition:
    SIGN = '>'
    source_name = ''
    target_part_name = ''
    target_cat = ''
    limit = 0

    def __init__(self, name, part_name, category, limit):
        self.source_name = name
        self.target_part_name = part_name
        self.target_cat = category
        self.limit = limit

    def condition(self, cat_counter):
        return cat_counter[self.target_cat] > self.limit


class Part:
    name = ''
    category = ''
    note = 0
    transitions = []
    fb_note = 0

    def __init__(self, name, cat, note, fb_note):
        self.name = name
        self.category = cat
        self.note = note
        self.fb_note = fb_note
        self.transitions = []

    def __str__(self):
        return "<Part '{}'>".format(self.name)

    def add_transition(self, transition):
        self.transitions.append(transition)

    def get_targets(self):
        """
        :return: a dictionary with target transitions as keys and the corresponding (limit,part_name) as values
        """
        return {trans.target_cat: (trans.limit, trans.target_part_name) for trans in self.transitions}

    def test_transitions(self, category_counter):
        """
        iterates over all transitions and checks their transfer-conditions. If a condition is true, return the name of
        the corresponding target part. If no condition is true, return the name of the current part
        :param category_counter:
        :return: name of next part (can be the current part if no condition is met)
        """
        for transition in self.transitions:
            if transition.condition(category_counter):
                return transition.target_part_name
        return self.name


class SongMachine:
    current_part = None
    parser = None
    category_counter = {}
    __lock = False

    def __init__(self, parser):
        self.parser = parser
        self.current_part = self.parser.song_parts[self.parser.first_part_name]
        self._reset_counter(parser.categories)

    def _reset_counter(self, categories):
        self.category_counter = {}.fromkeys(categories, 0) if categories else {}

    def release_lock(self):
        self._reset_counter(self.category_counter.keys())
        self.set_lock(False)

    def set_lock(self, value=True):
        self.__lock = value

    def is_locked(self):
        return self.__lock

    def update_part(self, category):
        """
        :param category:
        :return: Boolean, True if part is changed
        """
        self.category_counter[category] += 1
        next_part_name = self.current_part.test_transitions(self.category_counter)

        if next_part_name == self.current_part.name:
            # no part change
            return False
        else:
            # part change
            self.set_lock()
            self.current_part = self.parser.song_parts[next_part_name]
            return True

    def get_counter_for_visuals(self):
        """
        :return: a dictionary with 'target_cat_names' as keys and {'count':target_cat_count, 'limit': number} as values
        """
        targets = self.current_part.get_targets()
        visual_counter = {}
        for category, count in self.category_counter.items():
            limit = targets[category][0] if category in targets else -1
            visual_counter[category] = {'count': count, 'limit': limit}
        return visual_counter


class SongParser:
    MAX_UTTERANCES = "max_num_utterances"
    NAME_CATEGORIES = "categories"
    PARTS = "parts"
    NAME_FIRST_PART = "first_part"
    SYNTH_CC =  "synth_fb"

    data = {}
    song_parts = {}
    categories = []
    synth_fb = {}

    first_part_name = ''
    max_utterances = 0

    def __init__(self, validated_data):
        self.data = validated_data

    def parse(self):
        self.categories = self.data[self.NAME_CATEGORIES]
        self.max_utterances = self.data[self.MAX_UTTERANCES]
        self.synth_fb = self.data[self.SYNTH_CC]
        self._create_parts()
        self._add_transitions()

    def _create_parts(self):
        for part_dict in self.data[self.PARTS]:
            part_name = part_dict["name"]
            cat_name = part_dict["category"]
            note = part_dict["note"]
            fb_note = part_dict["fb_note"]
            self.song_parts[part_name] = Part(part_name, cat_name, int(note), fb_note)
        self.first_part_name = self.data[self.NAME_FIRST_PART]

    def _add_transitions(self):
        for part in self.song_parts.keys():
            for part_dict in self.data[self.PARTS]:
                part_name = part_dict["name"]
                associated_category = part_dict["category"]
                limit = part_dict["limit"]
                print(part_dict)
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

        __validate_field(SongParser.PARTS)
        __validate_field(SongParser.NAME_CATEGORIES)

    def _validate_consistency(self):
        """
        make sure the transitions contain only parts and categories that are explicitly mentioned in the
        corresponding fields of the json
        :return:
        """
        part_names = []
        for d in self.data[SongParser.PARTS]:
            part_names.append(d["name"])
        if self.data[SongParser.NAME_FIRST_PART] not in part_names:
            self.errors.append(
                "First part (`{}`) is not contained in `parts`".format(self.data[SongParser.NAME_FIRST_PART])
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

    print(song_machine.current_part)
    song_machine.update_part("Lob")
    print(song_machine.category_counter)
    song_machine.update_part("Lob")
    print(song_machine.category_counter)
    song_machine.update_part("Lob")
    print(song_machine.category_counter)
    print(song_machine.current_part)
    song_machine.update_part("Kritik")
    print(song_machine.category_counter)
    song_machine.update_part("Kritik")
    print(song_machine.current_part)
