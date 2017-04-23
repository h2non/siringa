import sys
import siringa
import logging


@siringa.register
def logger():
    logger = logging.getLogger('siringa')
    handler = logging.StreamHandler(sys.stdout)
    logger.addHandler(handler)
    logger.setLevel(logging.CRITICAL)
    return logger


@siringa.register
def log(logger: '!logger', *args):
    logger().info(*args)


@siringa.register
class Owner(object):
    def __init__(self, name):
        self.name = name


@siringa.register
class Pet(object):
    @siringa.inject
    def __init__(self, name, owner, log: '!log'):
        self.name = name
        self.owner = owner
        log('new pet with name {}'.format(name))


@siringa.inject
def factory(owner, pet_name, Pet: '!Pet', Owner: '!Owner'):
    return Pet(pet_name, Owner(owner))


pet = factory('Tomás', 'Arya')
print('Pet is name:', pet.name)
print('Owner is name:', pet.owner.name)
