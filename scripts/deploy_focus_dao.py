from brownie import FocusDao, network
from scripts.helpful_scripts import get_account


def deploy():
    account = get_account()

    if len(FocusDao) == 0:
        print("Hello ser, we deploying")
        contract = FocusDao.deploy({"from": account}, publish_source = True)
        
        return contract
    
    else:
        print("Here's the Already deployed contract!")
        return FocusDao[-1]

def main():
    deploy()

    #0x10D736D75ba0d9A937DFf4c8585db4CDD3A3C458