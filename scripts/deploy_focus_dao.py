from brownie import FocusDao, network
from scripts.helpful_scripts import get_account


def deploy():
    account = get_account()
    print("Hello ser, we deploying")
    contract = FocusDao.deploy({"from": account})
    print("Hello ser, we deploying")
    return contract

def main():
    deploy()