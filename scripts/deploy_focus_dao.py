from brownie import FocusDao, network, config
from scripts.helpful_scripts import get_account


def deploy():
    account = get_account()
    nft_address = "0x705f8B395361218056B20eE5C36853AB84b8bbFF"

    if len(FocusDao) == 0:
        print("Hello ser, we deploying")
        contract = FocusDao.deploy(nft_address, {"from": account}, publish_source = config["networks"][network.show_active()]["verify"])
        
        return contract
    
    else:
        print("Here's the Already deployed contract!")
        return FocusDao[-1]

def create_proposal():
    account = get_account()

    address_list = ["0xA66F90C0B7be6955D6c8f9B16dfD0A56171e038e"]
    description = "Should we start our own farm?"

    contract = deploy()

    print("Woop Woop!, creating new proposal captain")
    contract.createProposal(description, address_list, {"from":account})

def main():
    # deploy()
    create_proposal()
    # print(FocusDao[-1])

    #0x10D736D75ba0d9A937DFf4c8585db4CDD3A3C458
    # 0xD2576Ea24200b90eC58c9c8472469916A1592CeF

    #notes
    # deploy again we change the order of require actions on vote function