#!/usr/bin/env python

from __future__ import print_function
from collections import defaultdict

class Effect(object):
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
    def __init__(self, name, effect):
        self.name_ = name
        self.effect_ = effect

    @property
    def effect(self):
        return self.effect_

    def __str__(self):
        return "{}: {}".format(self.name_, self.effect_)

class EffectPredicate(object):
    """A predicate on some set of effects."""
    def __init__(self, effect_checks):
        self.effect_checks_ = effect_checks

    @classmethod
    def from_s(cls, s):
        """ Parse specs of the form C>2 S<1. """
        effect_checks = {}
        parts = s.split()
        def gen_check(direction, comparison):
            if direction not in "<>":
                raise ValueError("%s not known" % direction)
            def check(quantity):
                if direction == ">":
                    return quantity > comparison
                else:
                    return quantity < comparison
            return check

        for part in parts:
            key = part[0]
            direction = part[1]
            comparison = int(part[2:])
            effect_checks[key] = gen_check(direction, comparison)

        return cls(effect_checks)

class EffectAndPredicate(EffectPredicate):
    def eval(self, quantities):
        for key, quantity in quantities.iteritems():
            checker = self.effect_checks_.get(key, lambda x: True)
            if not checker(quantity):
                return False
        return True

class EffectOrPredicate(EffectPredicate):
    def eval(self, quantities):
        for key, quantity in quantities.iteritems():
            checker = self.effect_checks_.get(key, lambda x: False)
            if checker(quantity):
                return True
        return False

class Ship(object):
    def __init__(self, initial_stats):
        self.initial_stats_ = initial_stats
        self.stats_ = initial_stats.copy()
        self.components_ = []

    def reset(self):
        self.stats_ = self.initial_stats_.copy()
        for component in self.components_:
            self.stats_ = component.effect.add_to(self.stats_)

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

    def __str__(self):
        parts = []
        for key, value in self.stats.iteritems():
            effect_name = EFFECT_NAMES[key]
            part = "{}: {}".format(effect_name, value)
            parts.append(part)
        return " ".join(parts)

class ShipLogEntry(object):
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
    def __init__(self, items):
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
        sel = None
        while sel is None:
            sel = self.try_selection(prompt)
        return sel

EFFECT_NAMES = {
        "S": "speed",
        "C": "capacity",
        "A": "attack",
        "H": "health",
        }

class Game(object):
    main_menu = Menu([
        ("add", "add component"),
        ("remove", "remove component"),
        ("run", "attempt mission"),
        ])
    def __init__(self, components, mission):
        self.components_ = components
        self.mission_ = mission
        self.ship_ = Ship({"H": 2, "A": 0, "S": 2, "C": 4})

    def execute_action(self):
        print("ship:")
        print(self.ship_)
        self.main_menu.display()
        action = self.main_menu.get_selection()
        def get_component(components, prompt):
            component_menu = Menu(enumerate(components))
            component_menu.display()
            sel_component_index = component_menu.try_selection(prompt)
            if sel_component_index is None:
                return None
            return components[sel_component_index]
        if action == "add":
            component = get_component(self.components_,
                    "component to add > ")
            if component is not None:
                self.ship_.add_component(component)
        if action == "remove":
            component = get_component(self.ship_.components,
                    "component to remove > ")
            if component is not None:
                self.ship_.remove_component(component)
        if action == "run":
            log = self.mission_.run_ship(self.ship_)
            print("results:")
            for entry in log:
                print(entry)
            print("ship finished mission with:")
            print(self.ship_)
            self.ship_.reset()

    def play(self):
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
