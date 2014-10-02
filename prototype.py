#!/usr/bin/env python

from __future__ import print_function
from collections import defaultdict

# A mapping from the one-letter keys to the full names for ship stats.
STAT_NAMES = {
        "S": "speed",
        "C": "capacity",
        "A": "attack",
        "H": "health",
        }


class Effect(object):
    """ A set of changes to one or more stats.  """
    # TODO(tchajed): an effect cannot currently include failing the mission
    # automatically. This could be implemented as a large negative health
    # effect, though.

    def __init__(self, deltas):
        self.deltas_ = deltas

    @classmethod
    def from_s(cls, s):
        deltas = {}
        parts = s.split()
        for part in parts:
            name = part[-1]
            quantity = part[:-1]
            deltas[name] = int(quantity)
        return Effect(deltas)

    def add_to(self, values):
        totals = defaultdict(int)
        for key, v in values.iteritems():
            totals[key] = v
        for key, delta in self.deltas_.iteritems():
            totals[key] += delta
        return totals

    def negate(self):
        negative_deltas = {}
        for key, delta in self.deltas_.iteritems():
            negative_deltas[key] = -delta
        return Effect(negative_deltas)

    def __str__(self):
        parts = []
        for key, value in self.deltas_.iteritems():
            part = "{:+}{}".format(value, key)
            parts.append(part)
        return " ".join(parts)

class Component(object):
    """ A ship component.

    Wraps an effect with a name and the semantics of being attachable to a ship.
    """
    def __init__(self, name, effect):
        self.name_ = name
        self.effect_ = effect

    @property
    def effect(self):
        return self.effect_

    def __str__(self):
        return "{}: {}".format(self.name_, self.effect_)

class StatPredicate(object):
    """A predicate on some set of properties.
    
    In simple terms, represents a function that takes a set of stats and
    returns true or false. This abstract class only provides the parsing
    functionality; subclasses determine how the predicates on the various
    effects are combined.
    """
    def __init__(self, stat_checks):
        self.stat_checks_ = stat_checks

    @classmethod
    def from_s(cls, s):
        """ Parse specs of the form C>2 S<1. """
        def gen_check(direction, comparison):
            """ Create a checker function. """
            if direction not in "<>":
                raise ValueError("%s not known" % direction)
            def check(quantity):
                if direction == ">":
                    return quantity > comparison
                else:
                    return quantity < comparison
            return check

        stat_checks = {}
        for part in s.split():
            key = part[0]
            direction = part[1]
            comparison = int(part[2:])
            stat_checks[key] = gen_check(direction, comparison)

        return cls(stat_checks)

class StatPredicateAnd(StatPredicate):
    """ A predicate that requires that all the individual stat checks pass.
    
    An empty And is defined to be true.

    """
    def eval(self, quantities):
        for key, quantity in quantities.iteritems():
            checker = self.effect_checks_.get(key, lambda x: True)
            if not checker(quantity):
                return False
        return True

class StatPredicateOr(StatPredicate):
    """ A predicate that requires that any of the individual stat checks pass.
    
    An empty Or is defined to be false.
    
    """
    def eval(self, quantities):
        for key, quantity in quantities.iteritems():
            checker = self.effect_checks_.get(key, lambda x: False)
            if checker(quantity):
                return True
        return False

class Ship(object):
    """ A ship has some stats and components.

    The ship has a notion of a baseline produced from its components as well as
    current stats based on the impact of effects, such as those caused by
    events.

    """
    def __init__(self, initial_stats):
        self.initial_stats_ = initial_stats
        self.stats_ = initial_stats.copy()
        self.components_ = []

    @property
    def stats(self):
        return self.stats_

    @property
    def components(self):
        return self.components_

    def add_effect(self, effect):
        self.stats_ = effect.add_to(self.stats_)

    def add_component(self, component):
        self.components_.append(component)
        self.stats_ = component.effect.add_to(self.stats_)

    def remove_component(self, component):
        index = self.components_.index(component)
        component = self.components_.pop(index)
        self.stats_ = component.effect.negate().add_to(self.stats_)

    def reset(self):
        """ Return the ship stats to those determined by its initial stats and
        components. """
        self.stats_ = self.initial_stats_.copy()
        for component in self.components_:
            self.stats_ = component.effect.add_to(self.stats_)

    def __str__(self):
        parts = []
        for key, value in self.stats.iteritems():
            property_name = STAT_NAMES[key]
            part = "{}: {}".format(effect_name, value)
            parts.append(part)
        return " ".join(parts)

class ShipLogEntry(object):
    """ An entry in the ship's log, both what happened and what the result was.
    """
    def __init__(self, event, effect, is_success):
        self.event_ = event
        self.effect_ = effect
        self.is_success_ = is_success

    @property
    def effect(self):
        return self.effect_

    def __str__(self):
        return "{event} {success}: {effect}".format(
                event=self.event_.name,
                success=("succeeded" if self.is_success_ else "failed"),
                effect=self.effect_)


class Event(object):
    """ An event has a condition that determine whether a success effect
    will occur or a failure effect.

    The condition takes the form of a StatPredicate

    Either of the effects could be empty, meaning nothing happens.
    """
    def __init__(self, name, predicate, success_effect, failure_effect):
        self.name_ = name
        self.predicate_ = predicate
        self.success_effect_ = success_effect
        self.failure_effect_ = failure_effect

    def result(self, ship):
        is_success = self.predicate_.eval(ship.stats)
        if is_success:
            effect = self.success_effect_
        else:
            effect = self.failure_effect_
        log = ShipLogEntry(self, effect, is_success)
        return log

    @property
    def name(self):
        return self.name_

class Mission(object):
    """ A mission is a sequence of events. """
    def __init__(self, events):
        self.events_ = events

    def run_ship(self, ship):
        log = []
        for event in self.events_:
            entry = event.result(ship)
            log.append(entry)
            ship.add_effect(entry.effect)
        return log

class Menu(object):
    """ Utility to display and interact with a text menu of options. """
    def __init__(self, items):
        """ items should be a list of tuples; the first is the key, which is
        returned to represent the selection, while the second is what gets
        printed in the menu.

        If there is no natural key, items = enumerate(options) will give the
        index of the selected option.
        """
        self.items_ = list(items)

    def empty_(self):
        if not self.items_:
            return True
        return False

    def display(self):
        if self.empty_():
            print("(no options)")
        for num, item in enumerate(self.items_):
            item_val = item[1]
            print("%d) %s" % (num+1, item_val))
    
    def try_selection(self, prompt=None):
        """ Ask the user for a selection and return None if the input is invalid. """
        if self.empty_():
            return None
        if prompt is None:
            prompt = "> "
        s = raw_input(prompt)
        try:
            index = int(s)
        except ValueError:
            return None
        if not 1 <= index <= len(self.items_):
            return None
        item = self.items_[index-1]
        item_key = item[0]
        return item_key

    def get_selection(self, prompt=None):
        """ Attempt to try_selection until something is selected. """
        sel = None
        while sel is None:
            sel = self.try_selection(prompt)
        return sel

class Game(object):
    """ A Game provides state management for an in-progress sequence of
    missions on a ship. """
    main_menu = Menu([
        ("add", "add component"),
        ("remove", "remove component"),
        ("mission", "attempt mission"),
        ])
    def __init__(self, components, mission):
        self.components_ = components
        self.mission_ = mission
        self.ship_ = Ship({"H": 2, "A": 0, "S": 2, "C": 4})

    def execute_action(self):
        """ Use the main menu to get a top-level action to dispatch to. """
        print("ship:")
        print(self.ship_)
        self.main_menu.display()
        action = self.main_menu.get_selection()
        if action == "add":
            self.action_add_()
        if action == "remove":
            self.action_remove_()
        if action == "mission":
            self.action_mission_()

    def get_component_(self, components, prompt):
        component_menu = Menu(enumerate(components))
        component_menu.display()
        sel_component_index = component_menu.try_selection(prompt)
        if sel_component_index is None:
            return None
        return components[sel_component_index]

    def action_add_(self):
        """ Add a component. """
        component = self.get_component_(self.components_,
                "component to add > ")
        if component is None:
            return
        self.ship_.add_component(component)

    def action_remove_(self):
        """ Remove a component. """
        component = self.get_component(self.ship_.components,
                "component to remove > ")
        if component is None:
            return
        self.ship_.remove_component(component)

    def action_mission_(self):
        """ Attempt a mission. """
        log = self.mission_.run_ship(self.ship_)
        print("results:")
        for entry in log:
            print(entry)
        print("ship finished mission with:")
        print(self.ship_)
        self.ship_.reset()

    def play(self):
        # TODO(tchajed): there's no way to end the game
        while True:
            self.execute_action()

def main():
    components = [
            Component("engine", Effect.from_s("+1S -1C")),
            Component("turret", Effect.from_s("+2A -1S -1C"))
            ]

    events = [
            Event("bandits", EffectOrPredicate.from_s("A>0 S>2"),
                Effect.from_s("+1C"),
                Effect.from_s("-1C"))
            ]
    game = Game(components, Mission(events))
    game.play()

if __name__ == "__main__":
    main()
